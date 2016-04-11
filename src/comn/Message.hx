package comn;

import comn.Spod;
import sys.db.Manager;

interface Message {
	#if sapo_comn
	function deliver(queue:Manager<QueuedMessage>, creds:Credentials):Void; 
	#end // throws DeliveryError 
}

