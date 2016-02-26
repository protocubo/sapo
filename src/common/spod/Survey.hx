package common.spod;
import common.spod.EnumSPOD;
import sys.db.Object;
import sys.db.Types;

/**
 * ...
 * @author Caio
 */
class Survey extends Object
{
	public var id : SId;
	public var user_id : SInt;
	public var tentativa_id : SNull<Int>;
	
	public var lastPageVisited : SNull<SString<255>>;
	public var isValid : SBool;
	
	public var isRestored : SBool;
	
	public var dataInicioPesquisaPapel : SNull<SDateTime>;
	public var dataFimPesquisaPapel : SNull<SDateTime>;
	public var codigoFormularioPapel : SNull<SString<255>>;
	
	public var date_create : SDateTime;
	public var date_started : SNull<SDateTime>;
	public var date_finished : SNull<SDateTime>;
	public var date_completed : SNull<SDateTime>;
	public var estadoPesquisa : SNull<SEnum<EstadoPesquisa>>;
	
	public var endereco_id : SNull<SInt>;
	public var pin : SNull<SString<255>>;
	public var latitude : SNull<SFloat>;
	public var longitude : SNull<SFloat>;
	public var municipio : SNull<SString<255>>;
	public var bairro : SNull<SString<255>>;
	public var logradouro : SNull<SString<255>>;
	public var numero : SNull<SString<255>>;
	public var complemento : SNull<SString<255>>;
	public var cep : SNull<SString<255>>;
	public var zona : SNull<SString<255>>;
	public var macrozona : SNull<SString<255>>;
	public var lote : SNull<SString<255>>;
	public var estratoSocioEconomico : SNull<SString<255>>;
	
	
	public var old_survey_id : SInt;
	public var syncTimestamp : SFloat;
}