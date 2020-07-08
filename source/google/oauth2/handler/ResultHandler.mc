module Google { module OAuth2 {

class ResultHandler extends AbstractHandler {

	var mResultCallback = null;

	function initialize(resultCallback) {
		AbstractHandler.initialize();
		mResultCallback = resultCallback;
	}
	
	function handle(context) {
		
		// no tokens available
		if (context.tokens == null) {
			context.error = Errors.NO_TOKENS;
			AbstractHandler.handle(context);
			return;
		}
		
		var acces_token = context.tokens["access_token"];
		var token_type = context.tokens["token_type"];
		
		// no access token available
		if (acces_token == null) {
			context.error = Errors.NO_ACCESS_TOKEN;
			AbstractHandler.handle(context);
			return;
		}
		
		// no token_type available
		if (token_type == null) {
			context.error = Errors.NO_TOKEN_TYPE;
			AbstractHandler.handle(context);
			return;
		}
				
		// hand the acces token to the caller
		mResultCallback.invoke({
			"access_token" => acces_token,
			"token_type" => token_type
		});
		
		// Go on
		AbstractHandler.handle(context);
	}

}

}}