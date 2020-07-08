module Google { module Drive {

class DriveApi {

	var mAuthorization = null;
	
	function initialize(authorization) {
		mAuthorization = authorization;
	}

	function listFiles(resultCallback, errorCallback) {
		var request = new FilesListRequest(mAuthorization, resultCallback, errorCallback);
		request.execute();	
	}

}

}}