//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.WatchUi;
using Google.OAuth2;
using Google.Drive;

class WebRequestDelegate extends WatchUi.BehaviorDelegate {

    var notify;
	var authorization = null;

   // Set up the callback to the view
    function initialize(handler) {
        WatchUi.BehaviorDelegate.initialize();
        notify = handler;
    }

    // Handle menu button press
    function onMenu() {
        makeRequest();
        return true;
    }

    function onSelect() {
        startDownload();
        return true;
    }

	function startDownload() {
	
		var clientId = {
	    	"client_id" => WatchUi.loadResource(Rez.Strings.client_id),
	    	"client_secret" => WatchUi.loadResource(Rez.Strings.client_key)
	    };
	    
	    var scopes = new [1];
	    scopes[0] = OAuth2.Scopes.DRIVE_FILE;
	    
	    if(authorization == null) {
			try {
				var login = new Google.OAuth2.Login(clientId, scopes, method(:displayCode), method(:displayResult), method(:displayError));
				login.startOAuthFlow();
			} catch( ex ) {
				// Code to catch all execeptions
				var errorMessage = ex.getErrorMessage();
				System.println( "Exception during web request: " + errorMessage);
				ex.printStackTrace();
			}
		} else {
		  var drive = new Drive.DriveApi(authorization);
		  drive.listFiles(method(:displayResult), method(:displayCodeAndError));
		}
	}
	
	function displayCodeAndError(responseCode, error) {
		System.println("The responseCode: " + responseCode);
		System.println("The error: " + error);
	}
	
	function displayError(error) {
		System.println("The error: " + error);
	}
	
	function displayResult(result) {
		System.println("The result: " + result);
		authorization = result;
	}
	
	function displayCode(code) {
		System.println("Input the code: " + code);
	}

}