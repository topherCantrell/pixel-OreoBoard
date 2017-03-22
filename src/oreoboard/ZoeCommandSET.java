package oreoboard;

import java.util.List;

public class ZoeCommandSET extends ZoeCommand {	

	protected ZoeCommandSET(Zoe zoe) {
		super(zoe);		
	}

	@Override
	public boolean assemble(boolean firstPass, int origin, String command, List<String[]> params, ZoeEvent event, ZoeLine line) {	
		if(command.startsWith("SET(")) {
			String pixel = getParam(params,"PIXEL",true);
			String col = getParam(params,"COLOR",true);
			line.data.add(2);event.codeLength+=1;
			addParam(line.data,pixel);event.codeLength+=2;
			addParam(line.data,col);event.codeLength+=2;
			return true;
		}
		return false;
	}

}
