using Toybox.Lang;

module Google { module OAuth2 {

class Login {

	var mContext = null;
	
	function initialize(clientId, scopes, codeDisplayCallback, resultCallback, errorCallback) {
		
		// check parameter
		checkParameter(clientId, scopes, codeDisplayCallback, resultCallback, errorCallback);
				
		// create handlers
		var codesRequestHandler = new CodesRequestHandler();
		var codeDisplayHandler = new CodeDisplayHandler(codeDisplayCallback);
		var openWebsiteHandler = new OpenWebsiteHandler(); 
		var tokensPollHandler = new TokensPollHandler();
		var tokensRefreshHandler = new TokensRefreshHandler();
		var resultHandler = new ResultHandler(resultCallback);
		var errorHandler = new ErrorHandler(errorCallback);
		
		// create chains
		var errorChain = errorHandler;
		
		var refreshChain = tokensRefreshHandler;
		tokensRefreshHandler.add(resultHandler);
		
		var oauthChain = codesRequestHandler;
		codesRequestHandler.add(codeDisplayHandler).add(openWebsiteHandler).add(tokensPollHandler).add(resultHandler);
		
		// create context
		mContext = new Context();
		mContext.clientId = clientId;
		mContext.scopes = scopes;
		mContext.errorChain = errorChain;
		mContext.refreshChain = refreshChain;
		mContext.oauthChain = oauthChain;
	
	}
	
	function startOAuthFlow() {
		// start the refresh chain, if there is not refresh token, this chain will delegate to the OAuth chain.
		mContext.refreshChain.handle(mContext);
	}
	
	function checkParameter(clientId, scopes, codeDisplayCallback, resultCallback, errorCallback)  {
		
		// Check for null
		checkForNull("clientId", clientId);
		checkForNull("scopes", scopes);
		checkForNull("codeDisplayCallback", codeDisplayCallback);
		checkForNull("resultCallback", resultCallback);
		checkForNull("errorCallback", errorCallback);
	
		// Check clientId
		checkForNull("client_id", clientId["client_id"]);
		checkForNull("client_secret", clientId["client_secret"]);
		
		// check scopes
		checkForZero("scopes.size()", scopes.size());
		
		// check callbacks
		checkForFalse("codeDisplayCallback must be a method not a function! Wrap like this: method(:function)", codeDisplayCallback instanceof Method );
		checkForFalse("resultCallback must be a method not a function! Wrap like this: method(:function)", resultCallback instanceof Method );
		checkForFalse("errorCallback must be a method not a function! Wrap like this: method(:function)", errorCallback instanceof Method );
		
	}
	
	function checkForFalse(msg, value) {
		if( value == false) {
			throw new Lang.InvalidValueException(msg);
		}
	}
	
	function checkForZero(name, value) {
		if( value == 0) {
			throwParameterException(name, value);
		}
	}
	
	function checkForNull(name, value) {
		if( value == null) {
			throwParameterException(name, value);
		}
	}
	
	function throwParameterException(name, value) {
		var msg = "The handed parameter: " + name +" must not have the value:=" + value;
		throw new Lang.InvalidValueException(msg);
	}

}

}}