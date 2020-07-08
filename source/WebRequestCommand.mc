//
// the.old.dev
//

using Toybox.Communications;
using Toybox.WatchUi;

class WebRequestCommand  {

	var notify;
	var mResponseCode = null;
	var mReceivedData = null;
	
	function initialize(handler) {
	  notify = handler;
	  System.println("Rez.Strings.AppName:=" + WatchUi.loadResource(Rez.Strings.AppName));
	  System.println("Rez.Strings.client_id:=" + WatchUi.loadResource(Rez.Strings.client_id));
    }

	// show the recieved data and code
	function showResponse () {
		
		System.println("response code:=" + mResponseCode);
		
		if (mResponseCode == 200) {
           notify.invoke(mReceivedData);
        } else if (mResponseCode == -402) {
        	notify.invoke("Response body to large\nError: " + mResponseCode.toString());
         } else {
            notify.invoke("Failed to load\nError: " + mResponseCode.toString());
        }
	}

	// === Making the web request ===
	function makeRequest() {
		
		notify.invoke("Executing\nRequest");

		// GPX
        var url = "http://connect.garmin.com/modern/proxy/course-service/course/gpx/31903617";  
		// FIT
		url = "http://connect.garmin.com/modern/proxy/course-service/course/fit/31903617/0?elevation=true";
		// JSON
		url = "http://connect.garmin.com/modern/proxy/course-service/course/32010456";
		
		// wormnav json
		//        https://drive.google.com/file/d/1Fig18VKxoXjpTlTPquuZODTSmBa0-1j5/"
		url = "https://drive.google.com/u/0/uc?id=1Fig18VKxoXjpTlTPquuZODTSmBa0-1j5&export=download";
         
         // set the parameters
         var params = {                                              
         };

		 // set the options
         var options = {                                        
             // set HTTP method     
             :method => Communications.HTTP_REQUEST_METHOD_GET, 
             // set headers
             :headers => { },                                          
             // set response type
             :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON  
         };

		 // set responseCallback to onReceive() method
         var responseCallback = method(:onReceive);
                          
        // Make the Communications.makeWebRequest() call
        try {
         	Communications.makeWebRequest(url, params, options, method(:onReceive));
        } catch( ex ) {
			// Code to catch all execeptions
			var errorMessage = ex.getErrorMessage();
			System.println( "Exception during web request: " + errorMessage);
			ex.printStackTrace();
		}
		
    }

     // Receive the data from the web request
    function onReceive(responseCode, data) {
    
    	mResponseCode = responseCode;
		mReceivedData = data;   
        showResponse();
    }

}