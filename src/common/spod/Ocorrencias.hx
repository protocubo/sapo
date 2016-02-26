package common.spod;
import sys.db.Object;
import sys.db.Types.SDateTime;
import sys.db.Types.SFloat;
import sys.db.Types.SId;
import sys.db.Types.SInt;
import sys.db.Types.SNull;
import sys.db.Types.SString;

/**
 * ...
 * @author Caio
 */
class Ocorrencias extends Object
{
	public var id : SId;
	//?
	public var desc : SNull<SString<4096>>;
	@:relation(survey_id) public var survey : Survey;
	public var datetime : SDateTime;
	
	public var syncTimestamp : SFloat;
	public var old_id : SInt;
	public var old_survey_id : SInt;
	
}