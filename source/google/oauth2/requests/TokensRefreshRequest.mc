module Google { module OAuth2 {

class TokensRefreshRequest extends AbstractTokensRequest {

	var mRefreshToken = null;

	/**
	* @parameter {Google.OAuth.Tokens} callback with the signature (tokens)
	*/
	function initialize(clientID, refreshToken, callback, errorCallback) {
		AbstractTokensRequest.initialize(clientID, callback, errorCallback);
		mRefreshToken = refreshToken;
	}
	
	protected function getParams() {
	
		var params = AbstractTokensRequest.getParams();
		var refreshTokenKey = "refresh_token";
	
		params[refreshTokenKey] = mRefreshToken;
		
        /**
         * @see https://developers.google.com/identity/protocols/oauth2/limited-input-device#offline
         * As defined in the OAuth 2.0 specification, this field must contain the value: "refresh_token".
        */
        params["grant_type"] = refreshTokenKey;
        
        return params;
        
	} 

}

}}