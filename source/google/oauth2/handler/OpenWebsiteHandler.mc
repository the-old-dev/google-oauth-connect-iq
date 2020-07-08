using Toybox.Communications;

module Google { module OAuth2 {

class OpenWebsiteHandler extends AbstractHandler {


	function initialize() {
		AbstractHandler.initialize();
	}

	function handle(context) {
	
		// no codes available
		if (context.codes == null) {
			context.error = Errors.NO_CODES;
			AbstractHandler.handle(context);
			return;
		}
		
		// no verifacationUrl available
		var verification_url = context.codes["verification_url"];
		if ( verification_url == null) {
			context.error = Errors.NO_VERIFICATION_URL;
			AbstractHandler.handle(context);
			return;
		}
		
		// Open default web browser on phone
		var params = {};
		var options = {
			:method => Communications.HTTP_REQUEST_METHOD_GET 
		};
		Communications.openWebPage(verification_url, params, options);
	
		// go on
		AbstractHandler.handle(context);
	}
	
}

}}	