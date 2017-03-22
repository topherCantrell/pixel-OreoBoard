package oreoboard;

import java.util.List;

public abstract class ZoeCommand {
	
	protected Zoe zoe;
	
	public abstract boolean assemble(boolean firstPass, int origin, String command, List<String[]> params, ZoeEvent event, ZoeLine line);
	
	protected ZoeCommand(Zoe zoe) {
		this.zoe = zoe;
	}
	
	public String getParam(List<String[]> params, String name,boolean required) {
		for(String[] param : params) {
			if(name.equals(param[0])) return param[1];
		}
		if(required) {
			throw new CompileException("Parameter '"+name+"' is required.");
		}
		return null;
	}
	
	public void addParam(List<Integer> data, String vs) {
		int value = 0;
		if(vs.startsWith("[")) {
			vs = vs.substring(1,vs.length()-1);
			value = zoe.variables.indexOf(vs);
			if(value<0) throw new CompileException("Unknown variable '"+vs+"'.");
			value = value | 0x8000; // Upper bit means var access
		} else {
			value = Integer.parseInt(vs);
		}
		addWord(data,value);
	}
	
	public void addWord(List<Integer> data, int value) {
		data.add((value>>8)&0xFF);
		data.add(value&0xFF);
	}

}
