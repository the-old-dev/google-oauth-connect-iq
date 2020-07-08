using Toybox.Communications;
using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Timer;

class GoogleOAuthLogin  {

	var Google = {
		
		:CLIENT_ID => "client_id",
		:CLIENT_SECRET => "client_secret",
		
		:GRANT_TYPE => "grant_type",
		:SCOPE => "scope",
		
		:REQUEST_CODES_URL => "request_codes_url",
		:REQUEST_TOKENS_URL => "request_tokens_url",
		:REFRESH_TOKENS_URL => "refresh_tokens_url"
		
	};
	
	var OAuthCodes = {
	
		:DEVICE_CODE => "device_code",
		:USER_CODE => "user_code",
		
		:VERIFICATION_URL => "verification_url",
		
		:EXPIRES_IN => "expires_in",
		:INTERVAL => "interval",
		
	};
	
	var OAuthTokens = {
	
		:ACCESS_TOKEN  => "access_token",
 		:REFRESH_TOKEN => "refresh_token",
 		:TOKEN_TYPE => "token_type",
	
		:SCOPE => "scope",
		:EXPIRES_IN => "expires_in"
	
	};

	var mGoogle = {
	
		Google[:GRANT_TYPE] => "urn:ietf:params:oauth:grant-type:device_code",
		
		/**
		 * @see https://developers.google.com/identity/protocols/oauth2/limited-input-device#allowedscopes
		 */
		Google[:SCOPE] => "openid profile email https://www.googleapis.com/auth/drive.file",
	
		Google[:REQUEST_CODES_URL] =>  "https://oauth2.googleapis.com/device/code",
		Google[:REQUEST_TOKENS_URL] => "https://oauth2.googleapis.com/token",
		Google[:REFRESH_TOKENS_URL] => "https://oauth2.googleapis.com/token"
	
	};
	
	var mOAuthCodes = {};
	var mOAuthTokens = {};
	
	var mPolling = {
		"end" => -1
	};
	
	var mShowCodeFunction = null;
	var mLoginSucceededCallback;
	
	function initialize(googleClientID, googleClientSecret, showCodeFunction) {
		
		// Initialize handed parameters
		mGoogle[ Google[:CLIENT_ID] ] = googleClientID;
		mGoogle[ Google[:CLIENT_SECRET] ] = googleClientSecret;
		mShowCodeFunction = showCodeFunction;
		
		// Initialize refresh token
		mOAuthTokens[ OAuthTokens[:REFRESH_TOKEN] ] = readPermanently( OAuthTokens[:REFRESH_TOKEN] );
		if("".equals( mOAuthTokens[ OAuthTokens[:REFRESH_TOKEN] ] )) {
			mOAuthTokens[ OAuthTokens[:REFRESH_TOKEN] ] = null;
		}
		
    }
    
    function savePermanently(key, value) {
    	Application.Storage.setValue(key, value);
    }
    
    function readPermanently(key) {
    	return Application.Storage.getValue(key);
    }

    /**
    * Can throw an exception when there is an error during Communications.makeWebRequest
    */
    function start(loginSucceededCallback) {
    
    	mLoginSucceededCallback = loginSucceededCallback;
    	
    	if (mOAuthTokens[OAuthTokens[:REFRESH_TOKEN]] != null) {
    		refreshTokens();
    	} else {
    		requestCodes();
    	}
    }
    
    function onLoginSucceeded() {
    	mLoginSucceededCallback.invoke();
    }
    
    function requestCodes() {
		
		var url = mGoogle[Google[:REQUEST_CODES_URL]];
         
         // set the parameters
         var params = {};
         copy( mGoogle, params, Google[:CLIENT_ID] );
         copy( mGoogle, params, Google[:SCOPE] );

		 // set the options
         var options = {                                        
             // set HTTP method     
             :method => Communications.HTTP_REQUEST_METHOD_POST, 
             // set headers
             :headers => { 
             	
             },                                          
             // set response type
             :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON  
         };

		 // set responseCallback to onReceive() method
         var responseCallback = method(:onRequestCodesReceived);
                          
        // Make the Communications.makeWebRequest() call
      	Communications.makeWebRequest( url, params, options, responseCallback );
		
    }

     // Receive the data from requestCodes
    function onRequestCodesReceived(responseCode, data) {
		
		if (200 == responseCode) {
			
			// Remember codes
			copy( data, mOAuthCodes, OAuthCodes[:DEVICE_CODE]);
			copy( data, mOAuthCodes, OAuthCodes[:USER_CODE]);
			copy( data, mOAuthCodes, OAuthCodes[:VERIFICATION_URL]);
			copy( data, mOAuthCodes, OAuthCodes[:EXPIRES_IN]);
			copy( data, mOAuthCodes, OAuthCodes[:INTERVAL]);
			
			System.println( "mOAuthCodes:=" + mOAuthCodes );
	
			// continue flow
			showCode();
			openLoginPage();
			schedulePollTokens();
			
		} else {
			handleError("onRequestCodesReceived", responseCode, data);		
		}
		
    }
    
    function handleError(fn, responseCode, data) {
    		System.println( "responseCode:=" + responseCode );
			System.println( "data:=" + data );
			System.println( "GoogleOAuthLogin." + fn + " --!-- Handle response error" );	
    }

	function showCode() {
		mShowCodeFunction.invoke(mOAuthCodes[OAuthCodes[:USER_CODE]]);
	}
	
	function openLoginPage() {
		var url = mOAuthCodes[OAuthCodes[:VERIFICATION_URL]];
		var params = {};
		var options = {
			:method => Communications.HTTP_REQUEST_METHOD_GET 
		};
		Communications.openWebPage(url, params, options);
	}
	
	function schedulePollTokens() {

		// Set polling end		
		if ( mPolling["end"] == -1) {
			var pollingDuration = new Time.Duration( mOAuthCodes[OAuthCodes[:EXPIRES_IN]] );
			mPolling["end"] = getNow().add(pollingDuration);
			mPolling["delay"] =  mOAuthCodes[OAuthCodes[:INTERVAL]] * 1000;
		}
		
		// Check of codes have expired
		if ( mPolling["end"].lessThan( getNow() ) ) {
			var expired = {
				"error" => "error_login_expired",
 				"error_description" => "No valid login authorization recieved during timeout!"
			};
			onPollTokensReceived(expired);
			return;
		}
		
		// start poll timer with delay
	    var pollTimer = new Timer.Timer();
    	pollTimer.start(method(:pollTokens), mPolling["delay"], false);

	}

	function getNow() {
		return new Time.Moment(Time.now().value()); 
	}
	
	function pollTokens() {

		 var url = mGoogle[Google[:REQUEST_TOKENS_URL]];

         var parameters = {};
         copy(mGoogle, parameters, Google[:CLIENT_ID] );
         copy(mGoogle, parameters, Google[:CLIENT_SECRET] );
         copy(mGoogle, parameters, Google[:GRANT_TYPE] );
         copy(mOAuthCodes, parameters, OAuthCodes[:DEVICE_CODE] );

		 // set the options
         var options = {                                        
             // set HTTP method     
             :method => Communications.HTTP_REQUEST_METHOD_POST, 
             // set headers
             :headers => { 
             	
             },                                          
             // set response type
             :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON  
         };

        // start the request
        Communications.makeWebRequest( url, parameters, options, method(:onPollTokensReceived) );
	}
	
	function onPollTokensReceived(responseCode, data) {
	  
	  System.println(data);
	  
     // Schedule next poll if the authorization is pending 
      if ( responseCode == 428 ) {
      	schedulePollTokens();
      	return;
      }
      
      if (responseCode == 200) {
	 	
	 	copy( data, mOAuthTokens, OAuthTokens[:ACCESS_TOKEN] );
	 	copy( data, mOAuthTokens, OAuthTokens[:REFRESH_TOKEN] );
	 	copy( data, mOAuthTokens, OAuthTokens[:TOKEN_TYPE] );
	 	copy( data, mOAuthTokens, OAuthTokens[:SCOPE] );
	 	copy( data, mOAuthTokens, OAuthTokens[:EXPIRES_IN] );
	 	
	 	savePermanently( OAuthTokens[:REFRESH_TOKEN], data[ OAuthTokens[:REFRESH_TOKEN] ]);
	 	
	 	onLoginSucceeded();
	 	
      } else {
        handleError("onPollTokensReceived", responseCode, data);
      }
        
	}
	
	function callApi() {
		
		 var url ="https://www.googleapis.com/drive/v3/files";

         var parameters = {};
         copy(mOAuthTokens, parameters, OAuthTokens[:ACCESS_TOKEN] );
         
         parameters["pageSize"] = 10;
		 parameters["fields"] = "nextPageToken, files(id, name)";

		 // set the options
         var options = {                                        
             // set HTTP method     
             :method => Communications.HTTP_REQUEST_METHOD_GET, 
             // set headers
             :headers => { 
             	
             },                                          
             // set response type
             :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON  
         };

        // start the request
        Communications.makeWebRequest( url, parameters, options, method(:onCallApiReceived) );
		
	}
	
	function onCallApiReceived(responseCode, data) {
	
		System.println("responseCode:=" + responseCode);
		System.println("data:=" + data);
	  
	}
	
	function copy(source, target, key) {
		target[key] = source[key];
	}
	
	function refreshTokens() {

		 var url = mGoogle[Google[:REFRESH_TOKENS_URL]];

         var parameters = {};
         copy(mGoogle, parameters, Google[:CLIENT_ID] );
         copy(mGoogle, parameters, Google[:CLIENT_SECRET] );
         copy(mOAuthTokens, parameters, OAuthTokens[:REFRESH_TOKEN] );
         
         /**
         * @see https://developers.google.com/identity/protocols/oauth2/limited-input-device#offline
         * As defined in the OAuth 2.0 specification, this field must contain the value: "refresh_token".
         */
         parameters[ Google[:GRANT_TYPE] ] =  OAuthTokens[:REFRESH_TOKEN];
         
		 // set the options
         var options = {                                        
             // set HTTP method     
             :method => Communications.HTTP_REQUEST_METHOD_POST, 
             // set headers
             :headers => { 
             	
             },                                          
             // set response type
             :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON  
         };

        // start the request
        Communications.makeWebRequest( url, parameters, options, method(:onRefreshTokensReceived) );
	}
	
	function onRefreshTokensReceived(responseCode, data) {
	  
	  System.println(data);
	      
      if (responseCode == 200) {
	 	copy( data, mOAuthTokens, OAuthTokens[:ACCESS_TOKEN] );
	 	copy( data, mOAuthTokens, OAuthTokens[:TOKEN_TYPE] );
	 	copy( data, mOAuthTokens, OAuthTokens[:SCOPE] );
	 	copy( data, mOAuthTokens, OAuthTokens[:EXPIRES_IN] );
	 	onLoginSucceeded();
      } else {
        handleError("onRefreshTokensReceived", responseCode, data);
      }
        
	}

}