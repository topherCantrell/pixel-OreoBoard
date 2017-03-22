package oreoboard;

import java.util.List;

public class ZoeCommandGOSUB extends ZoeCommand {
	
	protected ZoeCommandGOSUB(Zoe zoe) {
		super(zoe);		
	}

	@Override
	public boolean assemble(boolean firstPass, int origin, String command, List<String[]> params, ZoeEvent event, ZoeLine line) {
		if(command.startsWith("GOSUB(")) {
			line.data.add(7);event.codeLength+=1;
			if(firstPass) {
				line.data.add(0);event.codeLength+=1;
				line.data.add(0);event.codeLength+=1;
			} else {
				String lab = params.get(0)[1];
				ZoeEvent ze = null;
				for(ZoeEvent z : zoe.events) {
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
			return true;
		}
		return false;
	}

}
