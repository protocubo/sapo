package comn;

interface Message {
	#if hxssl 
	function deliver(creds:Credentials):Void; 
	#end // throws DeliveryError 
}

