package common.spod;
import common.spod.EnumSPOD;
import common.spod.statics.EstacaoMetro;
import common.spod.statics.LinhaOnibus;
import sys.db.Object;
import sys.db.Types.SBool;
import sys.db.Types.SDateTime;
import sys.db.Types.SEnum;
import sys.db.Types.SFloat;
import sys.db.Types.SId;
import sys.db.Types.SInt;

import sys.db.Types.SNull;

/**
 * ...
 * @author Caio
 */
class Modo extends Object
{
	public var id : SId;

	@:relation(survey_id) public var survey : Survey;
	
	@:relation(morador_id) public var morador : Morador;
	
	@:relation(firstpoint_id) public var firstpoint : Ponto;
	@:relation(secondpoint_id) public var secondpoint : Ponto;
	
	public var date : SDateTime;
	
	public var isEdited : SInt;
	public var isDeleted : SBool;
	
	public var meiotransporte : SEnum<MeioTransporte>;
	
	@:relation(linhaOnibus_id) public var linhaOnibus : SNull<LinhaOnibus>;
	
	
	@:relation(estacaoEmbarque_id) public var estacaoEmbarque : SNull<EstacaoMetro>;
	
	@:relation(estacaoDesembarque_id) public var estacaoDesembarque : SNull<EstacaoMetro>;
	
	public var formaPagamento : SNull<SEnum<FormaPagamento>>;
	public var tipoEstacionamento : SNull<SEnum<TipoEstacionamento>>;
	
	//Coisas resumidas:
	
	public var valorViagem : SNull<SFloat>;
	public var naoSabe : SNull<SBool>;
	public var naoRespondeu : SNull<SBool>;
	
	public var syncTimestamp : SFloat;
	public var old_survey_id : SInt;
	public var old_morador_id : SInt;
	public var old_id : SInt;
}