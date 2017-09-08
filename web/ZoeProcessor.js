/**
 * Create an asynchronous script process for the given script. The given "stripElement" is the SVG
 * canvas that contains the target pixels. You can put as many strips on one SVG element as you 
 * want -- or separate each strip into a separate element.
 * 
 * event(name)   - starts the asynchronous running of the "name" function. The thread will continue
 *                 to run commands releasing the thread on all PAUSE commands.
 * stop()        - stop the asynchronous running
 * reset(script) - stop the asynchronous running and load up a new script
 *  
 * @param stripElement the SVG area that has the pixels for this script
 * @param script the lines of the script to run
 * @returns the asynchronous script object
 */
function initZoeProcessor(stripElement,script) {
	
	// The pixels are SVG elements:
	// <circle id="D1_4" cx="110" cy="10" r="4" stroke="#E0E0E0" stroke-width="1" fill="#F8F8F8"></circle>
	//
	// The ID is the strip number (D1, D2, D3, or D4) and the pixel number (starting with 0)
    
    "use strict";
	
    var stripElement = stripElement;	
    
    var stripConfig;
    var lines;
    var colors;        
    var callStack;
    var functionStartStack;
    var variables;
    var patterns;
    var running;
    var scriptPos;
	
	var my = {};	
	
	function setPixel(pix,color) {
		stripElement.find("#"+stripConfig.out+"_"+pix).attr("fill",color);	
	}
	
	function setAllPixels(color) {
		// Could be faster with a single query that picks up like "D1_*"
		for(var x=0;x<stripConfig.length;++x) {
			setPixel(x,color);
		}		
	}
					
	function substituteVars(line) {
		while(true) {
			var i = line.indexOf("[");
			if(i<0) return line;
			var j = line.indexOf("]",i);
			if(j<0) throw "Missing variable close ']'.";
			var name = line.substring(i+1,j).trim();
			if(variables[name]===undefined) {
				throw "Variable "+name+" has not been defined.";
			}
			line = line.substring(0,i)+variables[name]+line.substring(j+1);
		}
	}
	
	function getLines(script) {
		var lines = script.split("\n");	
		for(var x=lines.length-1;x>=0;--x) {
			lines[x] = lines[x].replace(/;/g,'');
			lines[x] = lines[x].replace(/\s+/g, ' ').toUpperCase();			
			var i = lines[x].indexOf("//");
			if(i>=0) {
				lines[x] = lines[x].substring(0,i);
			}
			lines[x] = lines[x].trim();
			if(lines[x]==="") {
				lines.splice(x,1);
			}
		}
		return lines;
	}

	function parseCommand(command) {		
		var i = command.indexOf("(");
		if(i<0) throw "The opening '(' is required.";
		var j = command.indexOf(")");
		if(j<0) throw "The closing ')' is required.";
		if(j<i) throw "The closing ')' must be AFTER the opening '('.";
		
		var pparts = command.substring(i+1,j).split(",");
		
		var ret = [];
		ret.push(command.substring(0,i).trim());
		
		var params = [];
		for(var x=0;x<pparts.length;++x) {
			var p = pparts[x];
			i = p.indexOf("=");
			if(i>=0) {
				var key = p.substring(0,i).trim();
				var value = p.substring(i+1).trim();
				if(key==="") throw "Must have a name before the '='.";
				if(value==="") throw "Must have a value after the '='.";
				params.push([key,value]);		
			} else {
				params.push([p]);			
			}
		}
		
		ret.push(params);
		return ret;
	}

	function getParameter(name,parts,validator,required) {
		if(required===undefined) required=true; // Default is TRUE	
		for(var x=0;x<parts.length;++x) {
			if(parts[x][0]===name) {
				if(Array.isArray(validator)) {
					
				} else if(validator==="number") {
					
				} else if(validator==="boolean") {
					
				} else if(validator==="colorNumber") {
					
				} else if(validator==="colorByte") {
					
				} else {
					throw "INTERNAL SOFTWARE ERROR. Unknown validator "+validator;
				}		
				return parts[x][1];		
			}
		}
		if(required) {
			throw "Parameter "+name+" must be given.";
		}
		return null;
	}

	function twoDigitHex(value) {
		var ret = value.toString(16).toUpperCase();
		if(ret.length<2) ret="0"+ret;
		return ret;
	}
	
	function findFunction(name) {
		name = "FUNCTION "+name+"(";
		for(var x=0;x<lines.length;++x) {
			if(lines[x].startsWith(name)) {
				return x;
			}
		}
		return undefined;
	}
	
	function findLabel(name,functionStart) {
		var dst = name+":"
		for(var x=functionStart+1;x<lines.length;++x) {
			if(lines[x]===dst) {
				return x;
			}
			if(lines[x].startsWith("FUNCTION ")) {
			    break;
			}
		}
		throw "Could not find label  "+name+" in current function.";
	}
	
	function mapPixel(x,y) {
	    var po = 0;
	    while(x>7) {
	        po = po + 1;
	        x = x - 8;
	    }
	    return po*64 + y*8 + x;
	}
	
	var OPERATORS = ['+','-','*','/','%'];
	var LOGIC = ['<=','>=','==','!=','<','>'];
	
	function runNext(cb) {				
				
		try {
						
			var curLine = lines[scriptPos++];	
			var fillLine = substituteVars(curLine);
			
			// Ignore labels
			if(curLine[curLine.length-1]===':') {
				cb();
				return;
			}
						
			if(curLine==="}" || curLine==="RETURN") {
			    if(callStack.length===0) {
			        running = false;
			        cb();
			        return;
			    }
			    scriptPos = callStack.pop();
			    functionStartStack.pop();
			    cb();
			    return;
			}
			
			if(curLine.startsWith("VAR ")) {
                curLine = curLine.substring(4);
                var i = curLine.indexOf("=");
                var name = curLine.trim();
                var value = 0;
                if(i>0) {   
                    name = curLine.substring(0,i).trim();
                    value = curLine.substring(i+1).trim();                  
                }
                if(variables[name]!==undefined) {
                    throw "Variable "+name+" has already been defined";
                }
                variables[name] = value;
                cb();
                return;
            }
			
			if(curLine[0]==='[') {
			    // A = B op C     +,-,*,/,%
			    // or 
			    // A = B
			    var i = curLine.indexOf("=");
			    if(i<0) throw "Expected '=' for math expression.";
			    var left = curLine.substring(0,i).trim();
			    
			    if(left[left.length-1]!==']') throw "Missing ']' before '='.";
			    left = left.substring(1,left.length-1).trim();
			    if(variables[left]===undefined) throw "Unknown variable ["+left+"]";
			    
			    var right = curLine.substring(i+1).trim();	
			    right = substituteVars(right);
			    
			    for(var x=0;x<OPERATORS.length;++x) {
			        i = right.indexOf(OPERATORS[x]);
			        if(i>0) break;
			    }
			    
			    if(i<0) { // Assignment			        
			        variables[left] = right;
			        cb();
			        return;
			    }
			    
			    // B op C
			    var partA = parseInt(right.substring(0,i).trim());
			    var partB = parseInt(right.substring(i+1).trim());
			    var op = right[i];
			    
			    switch(op) {
			    case '+':
			        variables[left] = partA + partB;
			        break;
			    case '-':
                    variables[left] = partA - partB;
                    break;
			    case '*':
                    variables[left] = partA * partB;
                    break;
			    case '/':
                    variables[left] = partA / partB;
                    break;
			    case '%':
                    variables[left] = partA % partB;
                    break;
			    }
			    
			    cb();
                return;			    
			}
							
			var parts = parseCommand(fillLine);								
						
			if(scriptPos==0 && parts[0]!='CONFIGURE') {
				throw "CONFIGURE must be the first command.";				
			}			
			
			if(parts[0]==='CONFIGURE') {
				if(stripConfig) {
					throw "CONFIGURE may only be given once.";
				}
				stripConfig = {};				
				stripConfig.out = getParameter('OUT',parts[1],["D1","D2","D3","D4"]);			
				stripConfig.length = getParameter('LENGTH',parts[1],"number");
				stripConfig.hasWhite = getParameter('HASWHITE',parts[1],"boolean")
				cb();
			}
			
			else if(parts[0]==='GOTO') {
				scriptPos = findLabel(parts[1][0],functionStartStack[functionStartStack.length-1]);
				cb();
			}
			
			else if(parts[0]==='GOSUB') {
			    callStack.push(scriptPos);			    
			    scriptPos = findFunction(parts[1][0]);
			    if(scriptPos===undefined) throw "Unknown function "+parts[1][0];
			    functionStartStack.push(scriptPos);
			    ++scriptPos;
                cb();
			}
			
			else if(parts[0]==='IF') {
			    var exp;
			    if(parts[1][0].length===1) {
			        exp = parts[1][0][0];
			    } else {
			        // TODO YUCK
			        exp = parts[1][0][0] + "="+parts[1][0][1];
			    }
			    for(var x=0;x<LOGIC.length;++x) {
                    i = exp.indexOf(LOGIC[x]);
                    if(i>0) break;
                }
			    if(i<0) throw "Expected a logic operator in expression "+exp;
			    var left = parseInt(exp.substring(0,i).trim());
			    var right = parseInt(exp.substring(i+LOGIC[x].length).trim());
			    var op = LOGIC[x];
			    var pass = false;
			    switch(op) {
			    case '<=':
			        pass = left <= right;
			        break;
			    case '>=':
			        pass = left >= right;
			        break;
			    case '==':
			        pass = left == right;
			        break;
			    case '!=':
			        pass = left != right;
			        break;
			    case '<':
			        pass = left < right;
			        break;
			    case '>':
			        pass = left > right;
			        break;
			    }
			    
			    // If pass fall into next line
			    // If fail:
			    //   Look for closing "}" (might be "} else {"
			    
			    if(!pass) ++scriptPos; // skip next statement
			    cb();
			}
									
			else if(parts[0]==='PAUSE') {
			    var that = this;
				var time = getParameter('TIME',parts[1],"number");
				my.pauseTimeout = setTimeout(function() {
				    my.pauseTimeout = undefined;
					cb.call(that);
				},time);				
			}
			
			else if(parts[0]==='DEFINECOLOR') {				
				var num = getParameter('COLOR',parts[1],"colorNumber");
				colors[num] = {
					white : getParameter('W',parts[1],"colorByte",stripConfig.hasWhite),
					red : getParameter('R',parts[1],"colorByte"),
					green : getParameter('G',parts[1],"colorByte"),
					blue : getParameter('B',parts[1],"colorByte")
				};
				cb();
			} 
			
			else if(parts[0]==='PATTERN') {
			    var num = getParameter('NUMBER',parts[1],'number');
			    if(patterns[num]!==undefined) throw "Pattern number "+num+" is already defined.";
			    patterns[num] = [];
			    while(lines[scriptPos]!=='}') {
			        patterns[num].push(lines[scriptPos]);
			        ++scriptPos;
			    }
			    
			    ++scriptPos;			    
			    cb();
			}
			
			else if(parts[0]==='SET') {
			    var c = getParameter('COLOR',parts[1],"colorNumber");
			    if(colors[c]===undefined) throw "Undefined color "+c;
                var rc = "#"+twoDigitHex(Math.floor((colors[c].red/150)*255))+
                          twoDigitHex(Math.floor((colors[c].green/150)*255))+
                          twoDigitHex(Math.floor((colors[c].blue/150)*255));
			    var pix = getParameter('PIXEL',parts[1],"number");
			    setPixel(pix,rc);	
			    cb();
			}
			
			else if(parts[0]==='DRAWPATTERN') {
			    var x = parseInt(getParameter('X',parts[1],"number"));
			    var y = parseInt(getParameter('Y',parts[1],"number"));
			    var pat = parseInt(getParameter('NUMBER',parts[1],"number"));
			    var off = getParameter('COLOROFFSET',parts[1],"colorNumber",false);			    
			    if(off===undefined || off===null) off=0;
			    else off = parseInt(off);
			    for(var yy=0;yy<patterns[pat].length;++yy) {
			        for(var xx=0;xx<patterns[pat][yy].length;++xx) {
			            var pix = mapPixel(xx+x,yy+y);
			            var c = patterns[pat][yy][xx];
			            if(c==".") c="0";
			            c = parseInt(c)+off;
			            var rc = "#"+twoDigitHex(Math.floor((colors[c].red/150)*255))+
                            twoDigitHex(Math.floor((colors[c].green/150)*255))+
                            twoDigitHex(Math.floor((colors[c].blue/150)*255));
			            setPixel(pix,rc);			             
			        }
			    }			    
			    cb();			    
			}
			
			else if(parts[0]==='SOLID') {
				var c = getParameter('COLOR',parts[1],"colorNumber");
				if(colors[c]===undefined) throw "Undefined color "+c;
				var rc = "#"+twoDigitHex(Math.floor((colors[c].red/150)*255))+
				          twoDigitHex(Math.floor((colors[c].green/150)*255))+
				          twoDigitHex(Math.floor((colors[c].blue/150)*255));
				setAllPixels(rc);
				cb();
			}
			
			else {
				throw "Unknown command "+parts[0];			
			}
			
		} catch (err) {
			running = false;
			alert(err+"\n"+curLine);			
		}
				
	};
	
	function run() {
	    runNext(function() {
            if(running) {
                //setTimeout(my.run,0);
                run();
            }
        });     
	}
	
	my.event = function(eventName) {	    
	    var pos = findFunction(eventName.toUpperCase());
	    if(pos!==undefined) {	        
	        // abort anything currently running
	        if(my.pauseTimeout) {
	            clearTimeout(my.pauseTimeout);
	            my.pauseTimeout = undefined;
	        }
	        callStack = [];
	        functionStartStack = [pos];
	        scriptPos = pos+1;
	        running = true;
	        run();
	    }	    
	};
			
	my.stop = function() {
		my.running = false;
		if(my.pauseTimeout) {
			clearTimeout(my.pauseTimeout);
			my.pauseTimeout = undefined;
		}
	};
	
	my.reset = function(script) {
	    my.stop();
	    lines = getLines(script);
	    stripConfig = undefined;
	    colors = [];        
	    callStack = [];
	    functionStartStack = [];
	    variables = {};
	    patterns = {};
	    
	    // Sanity check the script. It must have an INIT function		
		scriptPos = findFunction("INIT");
	    if(scriptPos===undefined) {
	    	throw "Must have an INIT function.";
	    }
	    ++scriptPos; // Skip over the INIT function declaration
	    	    
	};
	
	// Get ready to run
	my.reset(script);
    	
	return my;	
	
}

