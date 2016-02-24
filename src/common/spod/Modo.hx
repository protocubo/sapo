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
	public var firstpoint_id : SInt;
	@:relation(secondpoint_id) public var secondpoint : Ponto;
	public var secondpoint_id : SInt;
	public var date : SDateTime;
	
	public var isEdited : SInt;
	public var isDeleted : SBool;
	
	public var meiotransporte : SEnum<MeioTransporte>;
	
	public var linhaOnibus_id : SNull<SInt>;
	@:relation(linhaOnibus_id) public var linhaOnibus : SNull<LinhaOnibus>;
	
	public var estacaoEmbarque_id : SNull<SInt>;
	//@:relation(estacaoEmbarque_id) public var estacaoEmbarque : SNull<EstacaoMetro>;
	public var estacaoDesembarque_id : SNull<SInt>;
	//@:relation(estacaoDesembarque_id) public var estacaoDesembarque : SNull<EstacaoMetro>;
	
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