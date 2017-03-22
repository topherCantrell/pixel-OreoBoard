package oreoboard;

import java.util.ArrayList;
import java.util.List;

public class ZoeCommandPAUSE extends ZoeCommand {	

	protected ZoeCommandPAUSE(Zoe zoe) {
		super(zoe);		
	}

	@Override
	public boolean assemble(boolean firstPass, int origin, String command, List<String[]> params, ZoeEvent event, ZoeLine line) {	
		if(command.startsWith("PAUSE(")) {
			line.data = new ArrayList<Integer>();
			String tm = getParam(params,"TIME",true);
			line.data.add(1);event.codeLength+=1;
			addParam(line.data,tm);event.codeLength+=2;
			return true;
		}
		return false;
	}

}
