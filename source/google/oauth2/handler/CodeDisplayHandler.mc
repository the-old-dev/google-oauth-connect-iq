module Google { module OAuth2 {

class CodeDisplayHandler extends AbstractHandler {

	var mCodeDisplayCallback = null;

	function initialize(codeDisplayCallback) {
		AbstractHandler.initialize();
		mCodeDisplayCallback = codeDisplayCallback;
	}
	
	function handle(context) {
		
		// no codes available
		if (context.codes == null) {
			context.error = Errors.NO_CODES;
			AbstractHandler.handle(context);
			return;
		}
		
		var user_code = context.codes["user_code"];
		
		// no user code available
		if (user_code == null) {
			context.error = Errors.NO_USER_CODE;
			AbstractHandler.handle(context);
			return;
		}
			
		// hand the acces token to the caller
		mCodeDisplayCallback.invoke(user_code);
		
		// Go on
		AbstractHandler.handle(context);
	}

}

}}