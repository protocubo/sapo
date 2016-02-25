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
class Familia extends Object
{
	public var id : SId;
	@:relation(survey_id) public var survey : Survey;
	
	public var date : SDateTime;
	public var isDeleted : SBool;
	public var isEdited : SInt;
	
	public var numeroResidentes : SNull<SInt>;
	public var ocupacaoDomicilio : SNull<SEnum<OcupacaoDomicilio>>;
	
	public var condicaoMoradia : SNull<SEnum<CondicaoMoradia>>;
	public var tipoImovel : SNull<SEnum<TipoImovel>>;
	
	
	public var tentativa_id : SInt;
	
	public var banheiros : SNull<SInt>;
	public var quartos : SNull<SInt>;
	public var veiculos : SNull<SInt>;
	public var bicicletas : SNull<SInt>;
	public var motos : SNull<SInt>;
	
	public var aguaEncanada : SNull<SEnum<AguaEncanada>>;
	public var ruaPavimentada_id : SNull<SBool>;
	public var vagaPropriaEstacionamento_id : SNull<SBool>;
	public var anoVeiculoMaisRecente : SNull<SEnum<AnoVeiculoMaisRecente>>;
	public var empregadosDomesticos : SNull<SEnum<EmpregadosDomesticos>>;
	public var tvCabo_id : SNull<SBool>;
	
	public var editedNumeroResidentes : SNull<SInt>;
	//?
	public var editsNumeroResidentes : SNull<SString<255>>;
	
	public var nomeContato : SNull<SString<255>>;
	public var telefoneContato : SNull<SString<255>>;
	public var rendaDomiciliar : SNull<SEnum<RendaDomiciliar>>;
	public var recebeBolsaFamilia : SNull<SBool>;
	
	public var codigoReagendamento : SNull<SString<255>>;
	
	public var syncTimestamp : SFloat;
	public var old_id : SInt;
	public var old_survey_id : SInt;
	
	
}