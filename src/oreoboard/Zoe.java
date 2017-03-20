package oreoboard;

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
					cur.lines.remove(cur.lines.size()-1);					
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
			cur.lines.remove(cur.lines.size()-1);
		}
		
		// Two passes ... first to make labels
		int origin = 0;
		for(ZoeEvent event : events) {
			assemble(origin,event,true);
			origin = origin+event.codeLength;
		}
		origin = 0;
		for(ZoeEvent event : events) {
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
		data.add((value>>8)&0xFF);
		data.add(value&0xFF);
	}
	
	public void assemble(int origin, ZoeEvent event,boolean firstPass) {
		// Return the origin past all this data
		event.codeLength = 0;
		event.labels.clear();
		for(ZoeLine line : event.lines) {
			
			try {
			
				if(line.label!=null) {
					if(event.labels.containsKey(line.label)) {
						throw new CompileException("Label '"+line.label+"' is already defined in function '"+event.name+"'.");
					}
					event.labels.put(line.label, origin+event.codeLength);
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
				
				if(line.command.startsWith("[")) {
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
					
					line.data = new ArrayList<Integer>();
					
					if(i<0) {
						line.data.add(0x04);
						line.data.add(vn);
						addParam(line.data,op);
					} else {
						line.data.add(0x05);
						line.data.add(vn);
						line.data.add(MATHOPSVAL[x]);
						addParam(line.data,op.substring(0, i).trim());
						addParam(line.data,op.substring(i+MATHOPS[x].length()).trim());
					}
					
					continue;
				}
				
				// Commands without white spacing
				String command = line.command.replaceAll(" ", "");
				List<String[]> params = parseParams(command);
				
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
					line.data.add(0x09);					
					addParam(line.data,col);
					addParam(line.data,w);
					addParam(line.data,r);
					addParam(line.data,g);
					addParam(line.data,b);										
					continue;
				}
				
				if(command.startsWith("SOLID(")) {
					String col = getParam(params,"COLOR",true);
					line.data.add(0x0A);
					if(!firstPass) {					
						for(int x=0;x<1*2;++x) line.data.add(0);
					} else {
						addParam(line.data,col);						
					}
					continue;
				}
				
				if(command.startsWith("PAUSE(")) {
					String tm = getParam(params,"TIME",true);
					line.data.add(1);
					addParam(line.data,tm);
					continue;
				}
				
				if(command.startsWith("GOTO(")) {
					
				}
				
				throw new CompileException("Unknown command '"+command+"'.");
			
			} catch (CompileException e) {
				e.problemLine = line;
				throw e;
			}
									
		}		
		
	}

	public static void main(String[] args) throws Exception {
		
		Zoe zoe = new Zoe("Test.zoe");
						
		ZoeSpin zs = new ZoeSpin();
				
		String s = zs.makeSpinString(zoe);
		System.out.println(s);
	}

}
