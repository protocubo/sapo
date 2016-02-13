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
class Familia extends Object
{
	public var id : SId;
	public var session_id : SInt;
	
	public var date : SDateTime;
	public var isDeleted : SBool;
	public var isEdited : SInt;
	
	public var numeroResidentes : SNull<SInt>;
	public var ocupacaoDomicilio_id : SNull<SInt>;
	public var condicaoMoradia_id : SNull<SInt>;
	public var tipoImovel_id : SNull<SInt>;
	
	public var tentativa_id : SInt;
	
	public var banheiros : SNull<SInt>;
	public var quartos : SNull<SInt>;
	public var veiculos : SNull<SInt>;
	public var bicicletas : SNull<SInt>;
	public var motos : SNull<SInt>;
	
	public var aguaEncanada_id : SNull<SInt>;
	public var ruaPavimentada_id : SNull<SInt>;
	public var vagaPropriaEstacionamento_id : SNull<SInt>;
	public var anoVeiculoMaisRecente_id : SNull<SInt>;
	public var empregadosDomesticos_id : SNull<SInt>;
	public var tvCabo_id : SNull<SInt>;
	
	public var editedNumeroResidentes : SNull<SInt>;
	//?
	public var editsNumeroResidentes : SNull<SString<255>>;
	
	
	
	public var nomeContato : SNull<SString<255>>;
	public var telefoneContato : SNull<SString<255>>;
	public var rendaDomiciliar_id : SNull<SInt>;
	public var recebeBolsaFamilia_id : SNull<SInt>;
	
	public var codigoReagendamento : SNull<SString<255>>;
	
	public var syncTimestamp : SFloat;
	public var old_id : SInt;
	public var old_session_id : SInt;
	
	
}