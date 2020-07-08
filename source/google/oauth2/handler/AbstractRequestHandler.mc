module Google { module OAuth2 {

class AbstractRequestHandler extends AbstractHandler {

	var mContext = null;

	function initialize() {
		AbstractHandler.initialize();
	}
	
	function handle(context) {
		mContext = context;
		var request = getRequest();
		if (request != null) {
			request.execute();
		} else {
			AbstractHandler.handle(mContext);
		}	
	}
	
	function onRecieved(data) {
		setRecievedIntoContext(data);
		AbstractHandler.handle(mContext);
	}
	
	function onError(responseCode, data) {
		mContext.error = data["error"];
		mContext.error_description = data["error_description"];
		AbstractHandler.handle(mContext);
	}

	// ======== TO IMPLEMENT FROM HERE ==============
	
	function getRequest() {
		return null;
	}

	function setRecievedIntoContext(data) {
	}

}

}}