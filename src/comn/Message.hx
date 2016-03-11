package comn;

import comn.Spod;
import sys.db.Manager;

interface Message {
	#if hxssl 
	function deliver(queue:Manager<QueuedMessage>, creds:Credentials):Void; 
	#end // throws DeliveryError 
}

