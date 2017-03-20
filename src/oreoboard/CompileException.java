package oreoboard;

public class CompileException extends RuntimeException {

	private static final long serialVersionUID = 1L;
	
	ZoeLine problemLine;
	
	public CompileException(String reason) {
		this(reason,null);
	}
	
	public CompileException(String reason, ZoeLine problemLine) {
		super(reason);
		this.problemLine = problemLine;
	}

}
