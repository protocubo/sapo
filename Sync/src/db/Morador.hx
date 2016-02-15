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
	public var idade_id : SNull <SInt>;
	
	public var genero_id : SNull<SInt>;
	public var grauInstrucao_id : SNull<SInt>;
	
	public var codigoReagendamento : SNull<SString<255>>;
	
	public var quemResponde_id : SNull<SInt>;
	public var situacaoFamiliar_id : SNull<SInt>;
	public var atividadeMorador_id : SNull<SInt>;
	public var possuiHabilitacao_id : SNull<SInt>;
	public var portadorNecessidadesEspeciais_id : SNull<SInt>;
	
	public var motivoSemViagem_id : SNull<SInt>;
	
	public var syncTimestamp : SFloat;
	public var old_id : SInt;
	public var old_session_id : SInt;
	
}