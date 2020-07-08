using Google.Base;

module Google { module OAuth2 {

class AbstractTokensRequest extends Base.AbstractRequest {

	private var mClientID = null;

	/**
	* @parameter {Google.OAuth.Codes} callback with the signature (codes)
	*/
	function initialize(clientID, callback, errorCallback) {
		Base.AbstractRequest.initialize(callback, errorCallback);
		mClientID = clientID;
	}
	
	protected function getUrl() {
		return "https://oauth2.googleapis.com/token";
	}
	
	protected function getParams() {
		
		return {
         	"client_id" => mClientID["client_id"],
         	"client_secret" => mClientID["client_secret"]
        };
        
	} 

}

}}