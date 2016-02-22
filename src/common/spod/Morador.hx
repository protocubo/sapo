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
class Morador extends Object
{
	public var id : SId;
	public var session_id : SInt;
	public var familia_id : SInt;
	public var date : SDateTime;
	public var isDeleted : SBool;
	public var isEdited : SInt;
	
	public var nomeMorador : SNull<SString<255>>;
	public var proprioMorador_id : SNull<SBool>;
	public var idade : SNull<SEnum<Idade>>;
	
	public var genero_id : SNull<SInt>;
	public var grauInstrucao : SNull<SEnum<GrauInstrucao>>;
	
	public var codigoReagendamento : SNull<SString<255>>;
	
	public var quemResponde_id : SNull<SInt>;
	public var situacaoFamiliar : SNull<SEnum<SituacaoFamiliar>>;
	public var atividadeMorador : SNull<SEnum<AtividadeMorador>>;
	public var possuiHabilitacao_id : SNull<SBool>;
	public var portadorNecessidadesEspeciais : SNull<SEnum<PortadorNecessidadesEspeciais>>;
	
	public var motivoSemViagem : SNull<SEnum<MotivoSemViagem>>;
	
	public var syncTimestamp : SFloat;
	public var old_id : SInt;
	public var old_session_id : SInt;
	
}