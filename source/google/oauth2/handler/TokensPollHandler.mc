module Google { module OAuth2 {

class TokensPollHandler extends AbstractRequestHandler {

	function initialize() {
		AbstractRequestHandler.initialize();
	}
	
	function getRequest() {
		
		// get from context
		var clientId = mContext.clientId;
		var codes = mContext.codes;
		
		// no clientId available
		if (clientId == null) {
			mContext.error = Errors.NO_CLIENT_ID;
			return null;
		}
		
		// no scope available
		if (codes == null) {
			mContext.error = Errors.NO_CODES;
			return null;
		}
		
		return new TokensPollRequest(clientId, codes, method(:onRecieved), method(:onError));
		
	}

	function setRecievedIntoContext(data) {
		mContext.tokens = data;
	}

}

}}