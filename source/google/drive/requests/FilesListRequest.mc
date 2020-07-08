using Google.Base;
using Toybox.Communications;

module Google { module Drive {

/**
 * @see https://developers.google.com/identity/protocols/oauth2/limited-input-device#callinganapi
 */
class FilesListRequest extends Base.AbstractRequest {

	private var mAuthorization = null;

	/**
	* @parameter {Google.OAuth.Codes} callback with the signature (codes)
	*/
	function initialize(authorization, callback, errorCallback) {
		Base.AbstractRequest.initialize(callback, errorCallback);
		mAuthorization = authorization;
	}
	
	protected function getUrl() {
		return "https://www.googleapis.com/drive/v3/files";
	}
	
	protected function getParams() {
		return {
         	"pageSize" => 10,
         	"fields" => "nextPageToken, files(id, name)"
        };  
	}
	
	protected function getHeaders() {
		
		var value = mAuthorization["token_type"] +" "+ mAuthorization["access_token"];
	
		return {
			"Authorization" => value
		};
	}
	
	protected function getRequestMethod() {
		return Communications.HTTP_REQUEST_METHOD_GET;
	}

}

}}