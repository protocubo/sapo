package common.spod;
import sys.db.Object;
import sys.db.Types;

/**
 * ...
 * @author Caio
 */
class Survey extends Object
{
	public var id : SId;
	public var user_id : SInt;
	public var tentativa_id : SNull<Int>;
	
	public var lastPageVisited : SNull<SString<255>>;
	public var isValid : SBool;
	
	public var isRestored : SBool;
	
	public var date_create : SDateTime;
	public var date_finished : SNull<SDateTime>;
	
	
	public var old_survey_id : SInt;
	public var syncTimestamp : SFloat;
}