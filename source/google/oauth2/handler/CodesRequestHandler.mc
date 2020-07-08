module Google { module OAuth2 {

class CodesRequestHandler extends AbstractRequestHandler {

	function initialize() {
		AbstractRequestHandler.initialize();
	}
	
	function getRequest() {
		
		// get from context
		var clientId = mContext.clientId;
		var scope = buildScope();
		
		// no clientId available
		if (clientId == null) {
			mContext.error = Errors.NO_CLIENT_ID;
			return null;
		}
		
		// no scope available
		if (scope == null) {
			mContext.error = Errors.NO_SCOPE;
			return null;
		}
		
		return new CodesRequest(clientId, scope, method(:onRecieved), method(:onError));
		
	}

	function setRecievedIntoContext(data) {
		mContext.codes = data;
	}
	
	function buildScope() {
	
		var scopes = mContext.scopes;
	
		var scopeText = scopes[0];
		for( var i = 1; i < scopes.size(); i++ ) {
			scopeText = scopeText + " " + scopes[i];
		}
		
		return scopeText;
	}

}

}}