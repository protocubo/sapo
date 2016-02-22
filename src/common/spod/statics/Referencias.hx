package common.spod.statics;
import sys.db.Object;
import sys.db.Types.SFloat;
import sys.db.Types.SId;
import sys.db.Types.SInt;
import sys.db.Types.SString;

/**
 * ...
 * @author Caio
 */
class Referencias extends Object
{
	public var id : SId;
	public var longitude : SFloat;
	public var latitude : SFloat;
	public var desc : SString<255>;
	public var RA : SString<128>;
	public var ordem : SInt;
	public var latin_desc : SString<255>;
}