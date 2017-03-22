package oreoboard;

import java.util.ArrayList;
import java.util.List;

public class ZoeCommandRETURN extends ZoeCommand {
	
	protected ZoeCommandRETURN(Zoe zoe) {
		super(zoe);		
	}

	@Override
	public boolean assemble(boolean firstPass, int origin, String command, List<String[]> params, ZoeEvent event, ZoeLine line) {
		if(line.command.equals("RETURN")) {
			line.data = new ArrayList<Integer>();
			line.data.add(8);event.codeLength+=1;					
			return true;
		}
		return false;
	}

}
