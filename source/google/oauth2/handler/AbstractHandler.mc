module Google { module OAuth2 {

class AbstractHandler {

	var mNext = null;
	
	function initialize() {
	}

	function add(next) {
		mNext = next;
		return mNext;
	}

	function getNext() {
		return mNext;
	}

	function handle(context) {
		if (context.error == null) {
	 		if (getNext() != null) {
	 			getNext().handle(context);
	 		}
	 		
	 		// handler will stop here, because there is no next
	 		
	 	} else {
	 		context.errorChain.handle(context);
	 	}
	}
	
}

}}