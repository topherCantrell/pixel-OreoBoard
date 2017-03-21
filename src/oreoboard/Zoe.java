package oreoboard;

import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public class Zoe {
	
	boolean hasWhite = true;
	int numPixels = 8*8*3;
	int pinNumber = 15;
	
	List<String> variables = new ArrayList<String>();	
	List<ZoeEvent> events = new ArrayList<ZoeEvent>();
	
	String [] MATHOPS = {"+",  "-",  "*",  "/",  "%",  "&",  "|",  "^",  "<<", ">>"};
	int [] MATHOPSVAL = {0x20, 0x21, 0x00, 0x01, 0x02, 0x18, 0x1A, 0x1B, 0x0B, 0x0A};
	
	String [] LOGICOPS = {"==", "!=", ">=", "<=", ">",  "<"};
	int [] LOGICOPSVAL = {0x0A, 0x05, 0x03, 0x0E, 0x01, 0x0C};
			
	public Zoe(String filename) throws Exception {
		
		List<String> raws = Files.readAllLines(Paths.get(filename));
		int ln = 1;
		List<ZoeLine> lines = new ArrayList<ZoeLine>();
		for(String r : raws) {
			ZoeLine z = new ZoeLine();
			z.originalText = r;
			z.originalLine = ln;
			++ln;
			z.command = r.toUpperCase();
			int i = z.command.indexOf("//");
			if(i>=0) z.command = z.command.substring(0, i);
			z.command = z.command.trim();
			lines.add(z);
		}		
		
		for(int x=lines.size()-1;x>=0;--x) {
			if(lines.get(x).command.isEmpty()) {
				lines.remove(x);
			}
		}
		
		ZoeEvent cur = null;
		for(ZoeLine z : lines) {
			if(z.command.startsWith("FUNCTION ")) {
				if(cur!=null) {
					ZoeLine last = cur.lines.get(cur.lines.size()-1);
					last.command = "RETURN";									
				}
				cur = new ZoeEvent();
				int i = z.command.indexOf("(");
				cur.name = z.command.substring(9, i).trim();
				events.add(cur);
			} else {
				if(z.command.endsWith(":")) {
					z.label = z.command.substring(0, z.command.length()-1).trim();
					z.command = null;
				}
				if(cur!=null) {
					cur.lines.add(z);
				}
			}
		}
		if(cur!=null) {
			ZoeLine last = cur.lines.get(cur.lines.size()-1);
			last.command = "RETURN";		
		}
		
		// Two passes ... first to make labels
		int origin = 0;
		for(ZoeEvent event : events) {			
			assemble(origin,event,true);
			origin = origin+event.codeLength;
		}
		origin = 0;
		for(ZoeEvent event : events) {
			event.origin = origin;
			assemble(origin,event,false);
			origin = origin+event.codeLength;
		}
		
	}
	
	String getParam(List<String[]> params, String name,boolean required) {
		for(String[] param : params) {
			if(name.equals(param[0])) return param[1];
		}
		if(required) {
			throw new CompileException("Parameter '"+name+"' is required.");
		}
		return null;
	}
	
	List<String[]> parseParams(String command) {
		List<String[]> ret = new ArrayList<String[]>();
		int i = command.indexOf("(");
		int j = command.indexOf(")",i);
		//System.out.println(command);
		command = command.substring(i+1, j);
		String [] params = command.split(",");
		for(String param : params) {
			i = param.indexOf("=");
			if(i<0) {
				String [] k = {null,param};
				ret.add(k);				
			} else {
				String [] k = {param.substring(0,i),param.substring(i+1)};
				ret.add(k);				
			}
		}
		return ret;
	}
	
	void addParam(List<Integer> data, String vs) {
		int value = 0;
		if(vs.startsWith("[")) {
			vs = vs.substring(1,vs.length()-1);
			value = variables.indexOf(vs);
			if(value<0) throw new CompileException("Unknown variable '"+vs+"'.");
			value = value | 0x8000; // Upper bit means var access
		} else {
			value = Integer.parseInt(vs);
		}
		addWord(data,value);
	}
	
	void addWord(List<Integer> data, int value) {
		data.add((value>>8)&0xFF);
		data.add(value&0xFF);
	}
	
	public void assemble(int origin, ZoeEvent event,boolean firstPass) {
		int gotoFailLabelNum = 0;
		event.origin = origin;
		
		event.codeLength = 0;
		for(int zp = 0;zp<event.lines.size();++zp) {
			ZoeLine line = event.lines.get(zp);		
			
			try {
			
				if(line.label!=null) {
					if(firstPass) {
						if(event.labels.containsKey(line.label)) {
							throw new CompileException("Label '"+line.label+"' is already defined in function '"+event.name+"'.");
						}
						event.labels.put(line.label, origin+event.codeLength);
					}
					continue;
				}
				
				// Commands with white spacing
				
				if(line.command.startsWith("VAR ")) {
					String vname = line.command.substring(4).trim();
					if(firstPass) {
						if(variables.contains(vname)) {
							throw new CompileException("Variable '"+vname+"' has already been defined.");
						}
						variables.add(vname);
					} 
					continue;
				}
				
				if(line.command.equals("RETURN")) {
					line.data = new ArrayList<Integer>();
					line.data.add(8);event.codeLength+=1;					
					continue;
				}
				
				if(line.command.startsWith("[")) {
					line.data = new ArrayList<Integer>();
					int j = line.command.indexOf("]",1);
					String dest = line.command.substring(1, j);
					String op = line.command.substring(j+1).trim();
					if(!op.startsWith("=")) throw new CompileException ("Bad format.");
					op = op.substring(1).trim();
					
					int vn = variables.indexOf(dest);
					if(vn<0) throw new CompileException("Undefined destination '"+dest+"'.");
					
					int i = -1;
					int x;
					for(x=0;x<MATHOPS.length;++x) {
						i = op.indexOf(MATHOPS[x]);
						if(i>=0) break;
					}					
					
					if(i<0) {
						line.data.add(0x04);event.codeLength+=1;
						line.data.add(vn);event.codeLength+=1;
						addParam(line.data,op);event.codeLength+=2;
					} else {
						line.data.add(0x05);event.codeLength+=1;
						line.data.add(vn);event.codeLength+=1;
						line.data.add(MATHOPSVAL[x]);event.codeLength+=1;
						addParam(line.data,op.substring(0, i).trim());event.codeLength+=2;
						addParam(line.data,op.substring(i+MATHOPS[x].length()).trim());event.codeLength+=2;						
					}
					
					continue;
				}
				
				// Commands without white spacing
				String command = line.command.replaceAll(" ", "");
				
				if(command.startsWith("IF(")) {
					line.data = new ArrayList<Integer>();
					int i = command.indexOf(")");
					String op = command.substring(3, i);
					i = -1;
					int x;
					for(x=0;x<LOGICOPS.length;++x) {
						i = op.indexOf(LOGICOPS[x]);
						if(i>=0) break;
					}
					if(i<0) {
						throw new CompileException("Excpected a logic operator in expression.");
					}
					String left = op.substring(0,i);
					String right = op.substring(i+LOGICOPS[x].length());
					line.data.add(6);event.codeLength+=1;
					String lab = "__gotoFail_"+gotoFailLabelNum;
					++gotoFailLabelNum;
					if(firstPass) {
						ZoeLine failLab = new ZoeLine();
						failLab.label = lab;
						event.lines.add(zp+2,failLab); // No the "IF", not the next, but the one after that
						addWord(line.data,0);event.codeLength+=2;
					} else {
						if(!event.labels.containsKey(lab)) {
							throw new CompileException("INTERNAL 'IF' ERROR. Unknown label '"+lab+"'.");
						}
						int address = event.labels.get(lab);
						address = address - (origin+event.codeLength+7);
						if(address<0) address = address + 65536;
						addWord(line.data,address); event.codeLength+=2;
					}
					line.data.add(LOGICOPSVAL[x]);event.codeLength+=1;
					addParam(line.data,left);event.codeLength+=2;
					addParam(line.data,right);event.codeLength+=2;
					continue;
				}
								
				List<String[]> params;
				try {
					params = parseParams(command);
				} catch (Exception e) {
					throw new CompileException("Syntax error '"+e.getMessage()+"'.");
				}
				
				if(command.startsWith("DRAWPATTERN(")) {					
					line.data = new ArrayList<Integer>();
					line.data.add(0x0C);event.codeLength+=1;
					String num = getParam(params,"NUMBER",true);
					String x = getParam(params,"X",true);
					String y = getParam(params,"Y",true);
					String ofs = getParam(params,"COLOROFFSET",false);
					if(ofs==null) ofs="0";
					addParam(line.data,num);event.codeLength+=2;
					addParam(line.data,x);event.codeLength+=2;
					addParam(line.data,y);event.codeLength+=2;
					addParam(line.data,ofs);event.codeLength+=2;
					continue;
				}
				
				if(command.startsWith("PATTERN(")) {
					line.data = new ArrayList<Integer>();
					String num = getParam(params,"NUMBER",true);					
					List<String> patLines = new ArrayList<String>();
					++zp;
					while(true) {
						ZoeLine s = event.lines.get(zp++);
						if(s.command.equals("}")) break;
						patLines.add(s.command.trim());
					}
					--zp;
					int width = patLines.get(0).length();
					int height = patLines.size();
					line.data.add(0x0B);event.codeLength+=1;
					line.data.add(Integer.parseInt(num));event.codeLength+=1;
					line.data.add(width);event.codeLength+=1;
					line.data.add(height);event.codeLength+=1;
					for(String s : patLines) {
						for(int x=0;x<width;++x) {
							char c = s.charAt(x);
							if(c=='.') c='0';
							line.data.add(c-'0');event.codeLength+=1;
						}
					}
					
					continue;
				}
				
				if(command.startsWith("CONFIGURE(")) {
					String dd = getParam(params,"OUT",true);				
					switch(dd) {
					case "D1":
						pinNumber = 15;
						break;
					case "D2":
						pinNumber = 14;
						break;
					case "D3":
						pinNumber = 13;
						break;
					case "D4":
						pinNumber = 12;
						break;
						default:
							throw new CompileException("Unknown value 'OUT="+dd+"'.");
					}				
					numPixels = Integer.parseInt(getParam(params,"LENGTH",true));
					String hsw = getParam(params,"HASWHITE",true);
					this.hasWhite = Boolean.parseBoolean(hsw);			
					continue;
				}
	
				
				// Everything here down generates opcodes
				
				line.data = new ArrayList<Integer>();
							
				if(command.startsWith("DEFINECOLOR(")) {
					String col = getParam(params,"COLOR",true);
					String w = getParam(params,"W",hasWhite);
					if(w==null) w="0";
					String r = getParam(params,"R",true);
					String g = getParam(params,"G",true);
					String b = getParam(params,"B",true);
					line.data.add(0x09);event.codeLength+=1;					
					addParam(line.data,col);event.codeLength+=2;
					addParam(line.data,w);event.codeLength+=2;
					addParam(line.data,r);event.codeLength+=2;
					addParam(line.data,g);event.codeLength+=2;
					addParam(line.data,b);event.codeLength+=2;					
					continue;
				}
				
				if(command.startsWith("SOLID(")) {
					String col = getParam(params,"COLOR",true);
					line.data.add(0x0A);event.codeLength+=1;
					if(!firstPass) {					
						for(int x=0;x<1*2;++x) {
							line.data.add(0);event.codeLength+=1;							
						}
					} else {
						addParam(line.data,col);event.codeLength+=2;						
					}
					continue;
				}
				
				if(command.startsWith("SET(")) {
					String pixel = getParam(params,"PIXEL",true);
					String col = getParam(params,"COLOR",true);
					line.data.add(2);event.codeLength+=1;
					addParam(line.data,pixel);event.codeLength+=2;
					addParam(line.data,col);event.codeLength+=2;
					continue;
				}
				
				if(command.startsWith("PAUSE(")) {
					String tm = getParam(params,"TIME",true);
					line.data.add(1);event.codeLength+=1;
					addParam(line.data,tm);event.codeLength+=2;
					continue;
				}
				
				if(command.startsWith("GOTO(")) {
					line.data.add(3);event.codeLength+=1;
					if(firstPass) {
						line.data.add(0);event.codeLength+=1;
						line.data.add(0);event.codeLength+=1;
					} else {
						String lab = params.get(0)[1];
						if(!event.labels.containsKey(lab)) {
							throw new CompileException("Unknown label '"+lab+"'.");
						}
						int address = event.labels.get(lab);
						address = address - (origin+event.codeLength+2);
						if(address<0) address = address + 65536;
						addWord(line.data,address);event.codeLength+=2;
					}
					continue;
				}
				
				if(command.startsWith("GOSUB(")) {
					line.data.add(7);event.codeLength+=1;
					if(firstPass) {
						line.data.add(0);event.codeLength+=1;
						line.data.add(0);event.codeLength+=1;
					} else {
						String lab = params.get(0)[1];
						ZoeEvent ze = null;
						for(ZoeEvent z : events) {
							if(z.name.equals(lab)) {
								ze = z;
								break;
							}
						}
						if(ze==null) {
							throw new CompileException("Unknown function '"+lab+"'.");
						}						
						int address = ze.origin;
						address = address - (origin+event.codeLength+2);
						if(address<0) address = address + 65536;
						addWord(line.data,address);event.codeLength+=2;
					}
					continue;
				}
				
				throw new CompileException("Unknown command '"+command+"'.");
			
			} catch (CompileException e) {
				e.problemLine = line;
				throw e;
			}			
												
		}		
		
	}

	public static void main(String[] args) throws Exception {		
						
		try {
			Zoe zoe = new Zoe("Test.zoe");
			ZoeSpin zs = new ZoeSpin();
			String s = zs.makeSpinString(zoe);
			
			PrintWriter pw = new PrintWriter("spin/ProgramData.spin");
			pw.println(s);
			pw.flush();
			pw.close();
			
			System.out.println(s);
		} catch (CompileException e) {
			System.out.println(e.problemLine.originalLine+": "+e.problemLine.originalText);
			System.out.println(e.getMessage());
			e.printStackTrace();
		}				
		
	}

}
