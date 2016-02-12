package db;
import sys.db.Object;
import sys.db.Types.SBool;
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
class Ponto extends Object
{
	public var id : SId;
	public var session_id : SInt;
	public var morador_id : SInt;
	public var date : SDateTime;
	
	public var isEdited : SInt;
	public var isDeleted : SBool;
	/*
	public var anterior_id : SNull<SInt>;
	public var posterior_id : SNull<SInt>;
	
	public var ordem : SNull<SInt>;
	*/
	public var uf : SInt;
	public var city_id : SInt;
	public var regadm_id : SInt;
	public var street_id : SInt;
	public var complement_id : SInt;
	public var complement_two_id : SInt;
	public var complement2_str : SString<255>;
	public var ref_id : SInt;
	
	public var motivoID : SInt;
	public var motivoOutraPessoaID : SInt;
	public var tempo_saida : SString<255>;
	public var tempo_chegada : SString<255>;
	
	public var copiedFrom_id : SInt;
	
	
	public var old_id : SInt;
	public var syncTimestamp : SFloat;
	public var old_session_id : SInt;
}