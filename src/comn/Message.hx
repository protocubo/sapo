package comn;

interface Message {
	function deliver(creds:Credentials):Void;  // throws DeliveryError
}

