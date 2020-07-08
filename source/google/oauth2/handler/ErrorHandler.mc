module Google { module OAuth2 {

class ErrorHandler extends AbstractHandler {

	var mErrorCallback = null;

	function initialize(errorCallback) {
		AbstractHandler.initialize();
		mErrorCallback = errorCallback;
	}
	
	function handle(context) {
		
		// get from context
		var error = context.error;
		
		// handle unknown error
		if (error == null) {
			error = Errors.UNKNOWN;
		} 
		
		// error switch
		if (error == Errors.NO_REFRESH_TOKEN) {
			delegateToOAuthChain(context);
		} else {
			handleUnrecoverableError(error);
		}
		
	}
	
	function delegateToOAuthChain(context) {
		context.error = null;
		context.oauthChain.handle(context);
	}
	
	function handleUnrecoverableError(error) {
		mErrorCallback.invoke(error);
	}
	
}

}}