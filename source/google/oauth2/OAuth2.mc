module Google { module OAuth2 {

class Context {
	
	var error = null;
	var error_description = null;
	
	var errorChain = null;
	var oauthChain = null;
	var refreshChain = null;
	
	var clientId = null;
	var scopes = null;
	var codes = null;
	var tokens = null;
}

module Scopes {

	const DRIVE_FILE = "https://www.googleapis.com/auth/drive.file";
	const EMAIL = "email";
	const PROFILE = "profile";
	const OPENID =  "openid";

}

module Errors {

	const UNKNOWN = -1;
	
	const NO_CLIENT_ID = 0;
	const NO_SCOPE = 1;
	
	const NO_CODES = 2;
	const NO_USER_CODE = 3;
	const NO_VERIFICATION_URL = 4;
	
	const NO_TOKENS = 5;
	const NO_REFRESH_TOKEN = 6;
	const NO_ACCESS_TOKEN = 7;
	const NO_TOKEN_TYPE = 7;
}

const GRANT_TYPE = "urn:ietf:params:oauth:grant-type:device_code";


}}