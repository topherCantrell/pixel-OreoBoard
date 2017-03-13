function initZoeProcessor(stripElement,script) {
	
	var stripConfig;
	var colors = [];	
	
	var stripElement = stripElement;
	var running = false;
	var lines = getLines(script);
	var variables = getVars();
	if(lines.length>0) running=true;
	
	var scriptPos = findFunction("START");
	if(scriptPos===undefined) throw "Must have a START function.";
	++scriptPos;
		
	var my = {};	
	
	function getVars() {
		var ret = {};
		for(var x=0;x<lines.length;++x) {
			var curLine = lines[x];
			if(curLine.startsWith("VAR ")) {
				curLine = curLine.substring(4);
				var i = curLine.indexOf("=");
				var name = curLine.trim();
				var value = 0;
				if(i>0) {	
					name = curLine.substring(0,i).trim();
					value = curLine.substring(i+1).trim();					
				}
				if(ret[name]!==undefined) {
					throw "Variable "+name+" has already been defined";
				}
				ret[name] = value;
			} else if(curLine.startsWith("FUNCTION ")) {
				break;
			}			
		}	
		return ret;
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
	
	function findLabel(name) {
		var dst = name+":"
		for(var x=0;x<lines.length;++x) {
			if(lines[x]===dst) {
				return x;
			}
		}
		throw "Could not find label  "+name;
	}
	
	my.runNext = function(cb) {				
				
		try {
						
			var curLine = lines[scriptPos++];	
			var fillLine = substituteVars(curLine);
			
			// Ignore labels
			if(curLine[curLine.length-1]===':') {
				cb();
				return;
			}
						
			if(curLine==="}" || curLine==="RETURN") {
				throw "IMPLEMENT ME";
			}
			
			// TODO assuming a function here. Better to look for "word(" first.
			
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
				scriptPos = findLabel(parts[1][0]);
				cb();
			}
									
			else if(parts[0]==='PAUSE') {
				var time = getParameter('TIME',parts[1],"number");
				
				my.pauseTimeout = setTimeout(function() {
					my.pauseTimeout = undefined;
					cb();
				},time);				
			}
			
			else if(parts[0]==='COLOR') {				
				var num = getParameter('COLOR',parts[1],"colorNumber");
				colors[num] = {
					white : getParameter('W',parts[1],"colorByte",stripConfig.hasWhite),
					red : getParameter('R',parts[1],"colorByte"),
					green : getParameter('G',parts[1],"colorByte"),
					blue : getParameter('B',parts[1],"colorByte")
				};
				cb();
			}
			
			else if(parts[0]==='STRIP.SOLID') {
				var c = getParameter('COLOR',parts[1],"colorNumber");
				var rc = "#"+twoDigitHex(Math.floor((colors[c].red/100)*255))+
				          twoDigitHex(Math.floor((colors[c].green/100)*255))+
				          twoDigitHex(Math.floor((colors[c].blue/100)*255));
				stripElement.find("circle").attr("fill",rc);
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
	
	my.run = function() {
		my.runNext(function() {
			if(running) {
				setTimeout(my.run,0);
			}
		});		
	};
	
	my.stop = function() {
		my.running = false;
		if(my.pauseTimeout) {
			clearTimeout(my.pauseTimeout);
			my.pauseTimeout = undefined;
		}
	};
	
	return my;	
	
}