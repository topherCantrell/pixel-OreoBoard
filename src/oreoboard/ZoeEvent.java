package oreoboard;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ZoeEvent {
	
	String name;
	int codeLength;
	List<ZoeLine> lines = new ArrayList<ZoeLine>();
	Map<String,Integer> labels = new HashMap<String,Integer>();

}
