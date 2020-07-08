module Google { module OAuth2 {

class TokensRefreshHandler extends AbstractRequestHandler {

	function initialize() {
		AbstractRequestHandler.initialize();
	}
	
	function getRequest() {
		
		// get from context
		var clientId = mContext.clientId;
		
		// get from application storage
		var refresh_token  = Application.Storage.getValue("refresh_token");
		
		// no clientId available
		if (clientId == null) {
			mContext.error = { error => Errors.NO_CLIENT_ID };
			return null;
		}
		
		// no scope available
		if ( (refresh_token == null) || ("".equals(refresh_token)) ) {
			mContext.error = Errors.NO_REFRESH_TOKEN;
			return null;
		}
		
		return new TokensRefreshRequest(clientId, refresh_token, method(:onRecieved), method(:onError));
		
	}

	function setRecievedIntoContext(data) {
		mContext.tokens = data;
	}

}

}}