package oreoboard;

import java.util.List;

public class ZoeCommandSOLID extends ZoeCommand {	

	protected ZoeCommandSOLID(Zoe zoe) {
		super(zoe);		
	}

	@Override
	public boolean assemble(boolean firstPass, int origin, String command, List<String[]> params, ZoeEvent event, ZoeLine line) {
		if(command.startsWith("SOLID(")) {
			String col = getParam(params,"COLOR",true);
			line.data.add(0x0A);event.codeLength+=1;
			addParam(line.data,col);event.codeLength+=2;					
			return true;
		}
		return false;
	}
	
}
