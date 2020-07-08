module Google { module OAuth2 {

using Toybox.Time;
using Toybox.Timer;

class TokensPollRequest extends AbstractTokensRequest {

	var mCodes = null;
	var mEnd = null;
	var mDelay = null;

	/**
	* @parameter {Google.OAuth.Codes} callback with the signature (codes)
	*/
	function initialize(clientID, codes, callback, errorCallback) {
		AbstractTokensRequest.initialize(clientID, callback, errorCallback);
		mCodes = codes;
		initializePolling();
	}
	
	function initializePolling() {
		var pollingDuration = new Time.Duration( mCodes["expires_in"] );
		mEnd = getNow().add(pollingDuration);
		mDelay =  mCodes["interval"] * 1000;
	}
	
	function execute() {
		scheduleExecute();
	}
	
	protected function scheduleExecute() {
		
		// Check of codes have expired
		if ( mEnd.lessThan( getNow() ) ) {
			var expired = {
				"error" => "error_login_expired",
 				"error_description" => "No valid login authorization recieved during timeout!"
			};
			handleError(-1, expired);
			return;
		}
		
	   // start poll timer with delay
	    var pollTimer = new Timer.Timer();
    	pollTimer.start( method(: timedExecute), mDelay, false);
		
	}
	
	function timedExecute() {
		AbstractRequest.execute();
	}
	
	protected function getNow() {
		return new Time.Moment(Time.now().value()); 
	}
	
	protected function getParams() {
	
		// get base params
		var params = AbstractTokensRequest.getParams();
		
		// add params for polling
		params["grant_type"] = GRANT_TYPE;
		params["device_code"] = mCodes["device_code"];
		
		return params;
	}
	
	protected function handleError(responseCode, data) {
	  
	  // Schedule next poll if the authorization is pending 
      if ( responseCode == 428 ) {
      	scheduleExecute();
      } else {
      	// Otherwise delegate to super class
      	AbstractTokensRequest.handleError(responseCode, data);
      }
	
	}
	
	protected function handleOk(responseCode, data) {
		
		// Save refresh token
		var key = "refresh_token";
		Application.Storage.setValue(key, data[key]);
	
		// delegate to super class
		AbstractTokensRequest.handleOk(responseCode, data);
	}
	
}

}}