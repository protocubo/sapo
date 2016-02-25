package common.spod;
import common.spod.EnumSPOD;
import sys.db.Object;
import sys.db.Types.SBool;
import sys.db.Types.SDateTime;
import sys.db.Types.SEnum;
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
	
	@:relation(survey_id) public var survey : Survey;
	
	@:relation(morador_id) public var morador : Morador;
	
	public var date : SDateTime;
	
	public var isEdited : SInt;
	public var isDeleted : SBool;
	/*
	public var anterior_id : SNull<SInt>;
	public var posterior_id : SNull<SInt>;
	
	public var ordem : SNull<SInt>;
	*/
	public var uf_id : SInt;
	public var city_id : SInt;
	public var regadm_id : SNull<SInt>;
	public var street_id : SNull<SInt>;
	public var complement_id : SNull<SInt>;
	public var complement_two_id : SNull<SInt>;
	public var complement2_str : SNull<SString<255>>;
	public var ref_id : SNull<SInt>;
	public var ref_str : SNull<SString<255>>;
	
	public var motivo : SNull<SEnum<Motivo>>;
	public var motivoOutraPessoa : SNull<SEnum<Motivo>>;
	public var tempo_saida : SNull<SString<255>>;
	public var tempo_chegada : SNull<SString<255>>;
	
	public var copiedFrom_id : SNull<SInt>;
	@:relation(copiedFrom_id) public var copiedFrom : SNull<Ponto>;
	
	public var old_id : SInt;
	public var syncTimestamp : SFloat;
	public var old_survey_id : SInt;
}