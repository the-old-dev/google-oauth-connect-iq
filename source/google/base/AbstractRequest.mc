module Google { module Base {

class AbstractRequest {

	private var mCallback = null;
	private var mErrorCallback = null;

	function initialize(callback, errorCallback) {
		mCallback = callback;
		mErrorCallback = errorCallback;		
	}
	
	function execute() {
	
		var url = getUrl();
         
         // set the parameters
         var params = getParams();
   
		 // set the options
         var options = {
                                                 
             // set HTTP method     
             :method => getRequestMethod(), 
         
             // set headers
             :headers => getHeaders(),                                          
 
             // set response type
             :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON  
         };

		 // set responseCallback to onReceive() method
         var responseCallback = method(:onResponse);
                          
        // Make the Communications.makeWebRequest() call
      	Communications.makeWebRequest( url, params, options, responseCallback );
	}
		
	function onResponse(responseCode, data) {
		if (responseCode == 200) {
			handleOk(responseCode, data);
		} else {
			handleError(responseCode, data);
		}
	}
	
	protected function handleError(responseCode, data) {
		mErrorCallback.invoke(responseCode, data);
	}
	
	protected function getRequestMethod() {
		return Communications.HTTP_REQUEST_METHOD_POST;
	}

	protected function handleOk(responseCode, data) {
		mCallback.invoke(data);
	}
	
	protected function getHeaders() {
		return {};
	}
	
	protected function getUrl() {
		return null;
	}
	
	protected function getParams() {
		return null;
	}
	
}

}}