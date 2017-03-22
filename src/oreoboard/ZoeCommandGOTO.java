package oreoboard;

import java.util.ArrayList;
import java.util.List;

public class ZoeCommandGOTO extends ZoeCommand {	

	protected ZoeCommandGOTO(Zoe zoe) {
		super(zoe);		
	}

	@Override
	public boolean assemble(boolean firstPass, int origin, String command, List<String[]> params, ZoeEvent event, ZoeLine line) {	
		if(command.startsWith("GOTO(")) {
			line.data = new ArrayList<Integer>();
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
			return true;
		}
		return false;
	}

}
