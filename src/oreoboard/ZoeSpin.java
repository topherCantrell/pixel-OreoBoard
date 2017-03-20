package oreoboard;

import java.util.ArrayList;
import java.util.List;

public class ZoeSpin {
			
	static String [] twoHexDigits(int value) {		
		int a = value/256;
		int b = value%256;
		String sa = Integer.toString(a,16).toUpperCase();
		while(sa.length()<2) sa="0"+sa;
		String sb = Integer.toString(b,16).toUpperCase();
		while(sb.length()<2) sb="0"+sb;
		String [] ret = {sa,sb};
		return ret;
	}
	
	static String getSpinString(List<Integer> data) {		
		String ret = "  byte ";
		
		for(int i : data) {
			String s = Integer.toString(i,16).toUpperCase();
			while(s.length()<2) s="0"+s;
			ret = ret + "$"+s+",";
		}
		
		return ret.substring(0, ret.length()-1);
	}
	
	public List<String> makeSpin(Zoe zoe) {		
		List<String> ret = new ArrayList<String>();
		
		ret.add("zoeProgram");
		ret.add("");
		ret.add("'config");
		ret.add("  byte "+zoe.pinNumber);
		ret.add("  byte "+zoe.numPixels);
		if(zoe.hasWhite) ret.add("  byte 32");
		else         ret.add("  byte 24");
		ret.add("  byte "+zoe.variables.size());
		
		ret.add("");
		ret.add("'eventInput");
		ret.add("  byte 1, \"INIT\",0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0");
		
		ret.add("");
		ret.add("'palette  ' 64 longs (64 colors)");
		ret.add("  long 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0");
		ret.add("  long 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0");
		ret.add("  long 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0");
		ret.add("  long 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0");
		
		ret.add("");
		ret.add("'patterns ' 16 pointers");
		ret.add("  word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0");
		
		ret.add("");
		ret.add("'callstack ' 32 pointers");
		ret.add("  word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0");
		ret.add("  word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0"); 
		
		ret.add("");
		ret.add("'variables ' Variable storage (2 bytes each)");
		String cur = "";		
		for(int x=0;x<zoe.variables.size();++x) {
			if(x%16==0) {
				if(!cur.isEmpty()) ret.add(cur.substring(0, cur.length()-1));
				cur = "  word ";
			}
			cur = cur + "0,";
		}
		if(!cur.isEmpty()) ret.add(cur.substring(0, cur.length()-1));
		
		ret.add("");
		ret.add("'pixbuffer ' 1 byte per pixel");
		cur = "";		
		for(int x=0;x<zoe.numPixels;++x) {
			if(x%32==0) {
				if(!cur.isEmpty()) ret.add(cur.substring(0, cur.length()-1));
				cur = "  byte ";
			}
			cur = cur + "0,";
		}
		if(!cur.isEmpty()) ret.add(cur.substring(0, cur.length()-1));
		
		int rp = 1; // Terminator
		for(ZoeEvent e:zoe.events) {
			rp = rp + e.name.length()+3;
		}		
		
		// events table
		ret.add("");
		ret.add("'events");		 
		for(ZoeEvent e : zoe.events) {
			String [] ptr = twoHexDigits(rp);
			ret.add("  byte \""+e.name+"\",0, $"+ptr[0]+",$"+ptr[1]);
			rp = rp + e.codeLength;
		}
		ret.add("  byte $FF");		
		
		// events one by one
		for(ZoeEvent e : zoe.events) {
			ret.add("");
			ret.add("'"+e.name+"_handler");
			for(ZoeLine line : e.lines) {
				if(line.data == null) {
					ret.add("  '"+line.label+":");
				} else {
					String data = getSpinString(line.data);
					ret.add(data+" ' "+line.originalText);
				}
			}
		}
		
		return ret;
	}
	
	public String makeSpinString(Zoe zoe) {
		List<String> lines = makeSpin(zoe);
		StringBuilder sb = new StringBuilder();
		for(String s : lines) {
			sb.append(s);
			sb.append("\n");
		}
		return sb.toString();
	}

}
