package db;
import sys.db.Object;
import sys.db.Types;

/**
 * ...
 * @author Caio
 */
class Session extends Object
{
	public var id : SId;
	public var user_id : SInt;
	public var tentativa_id : Int;
	
	public var client_ip : SString<255>;
	public var lastPageVisited : SNull<SString<255>>;
	public var isValid : Int;
	
	//?
	public var isRestored : SInt;
	
	public var date_create : SDateTime;
	public var date_finished : SNull<SDateTime>;
	
	
	public var old_session_id : SInt;
	public var syncTimestamp : SFloat;
}