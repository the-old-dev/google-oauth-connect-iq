using Google.Base;

module Google { module OAuth2 {

class CodesRequest extends Base.AbstractRequest {

	private var mClientID = null;
	private var mScope = null;

	/**
	* @parameter {Google.OAuth.Codes} callback with the signature (codes)
	*/
	function initialize(clientID, scope, callback, errorCallback) {
		Base.AbstractRequest.initialize(callback, errorCallback);
		mClientID = clientID;
		mScope = scope;
	}
	
	protected function getUrl() {
		return "https://oauth2.googleapis.com/device/code";
	}
	
	protected function getParams() {
		return {
         	"client_id" => mClientID["client_id"],
         	"scope" => mScope
         };
	} 

}

}}