package db;
import sys.db.Object;
import sys.db.Types.SBool;
import sys.db.Types.SDateTime;
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
	public var session_id : SInt;
	public var morador_id : SInt;
	
	public var firstpoint_id : SInt;
	public var secondpoint_id : SInt;
	
	public var date : SDateTime;
	
	public var isEdited : SBool;
	public var isDeleted : SBool;
	
	public var meiotransporte_id : SInt;
	public var linhaOnibus_id : SNull<SInt>;
	public var estacaoEmbarque_id : SNull<SInt>;
	public var estacaoDesembarque_id : SNull<SInt>;
	
	public var formaPagamento_id : SNull<SInt>;
	public var tipoEstacionamento_id : SNull<SFloat>;
	
	//Coisas resumidas:
	
	public var valorViagem : SNull<SFloat>;
	public var naoSabe : SNull<SBool>;
	public var naoRespondeu : SNull<SBool>;
	
	public var syncTimestamp : SFloat;
	public var old_session_id : SInt;
	public var old_morador_id : SInt;
	public var old_id : SInt;
}