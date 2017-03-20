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
	
	public void assemble(int origin, ZoeEvent event,boolean firstPass) {
		// Return the origin past all this data
		event.codeLength = 0;
		event.labels.clear();
		for(ZoeLine line : event.lines) {
			
			if(line.label!=null) {
				if(event.labels.containsKey(line.label)) {
					throw new RuntimeException("Label '"+line.label+"' is already defined in function '"+event.name+"'.");
				}
				event.labels.put(line.label, origin+event.codeLength);
				continue;
			}
			
			if(line.command.startsWith("VAR ")) {
				String vname = line.command.substring(4).trim();
				if(firstPass) {
					if(variables.contains(vname)) {
						throw new RuntimeException("Variable '"+vname+"' has already been defined.");
					}
					variables.add(vname);
				} 
				continue;
			}
			
			if(firstPass) System.out.println("::"+line.command+"::");
			line.data = new ArrayList<Integer>();
			line.data.add(16);
			line.data.add(17);
			line.data.add(18);
			event.codeLength += 3;
			
		}		
	}

	public static void main(String[] args) throws Exception {
		
		Zoe zoe = new Zoe("Test.zoe");
						
		ZoeSpin zs = new ZoeSpin();
				
		String s = zs.makeSpinString(zoe);
		System.out.println(s);
	}

}
