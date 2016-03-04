package sapo.spod;

import common.spod.EnumSPOD;
import common.spod.statics.EstacaoMetro;
import common.spod.statics.LinhaOnibus;
import common.spod.statics.Referencias;
import common.spod.statics.UF;
import sapo.Spod.SurveyStatus;
import sys.db.Object;
import sys.db.Types;

class Survey extends Object {
	public var id : SId;
	public var user_id : SInt;
	public var tentativa_id : SNull<Int>;

	public var lastPageVisited : SNull<SString<255>>;
	public var isValid : SBool;
	
	public var paid : SNull<SBool> = false;

	public var isRestored : SBool;

	public var dataInicioPesquisaPapel : SNull<SDateTime>; //
	public var dataFimPesquisaPapel : SNull<SDateTime>; //
	public var codigoFormularioPapel : SNull<SString<255>>; //

	public var date_create : SDateTime;
	public var date_started : SNull<SDateTime>; // 
	public var date_finished : SNull<SDateTime>; 
	public var date_completed : SNull<SDateTime>; //
	public var estadoPesquisa : SNull<SEnum<EstadoPesquisa>>;

	public var endereco_id : SNull<SInt>;
	public var pin : SNull<SString<255>>; //
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
	public var json : Null<String>;
	
	/** CHECKS -> Verificado? - TODO:IGNORAR NO SYNC! **/
	public var checkSV : SNull<SBool>; 
	public var checkCT : SNull<SBool>; 
	public var checkCQ : SNull<SBool>; 
    public var isPhoned : SBool; 
	public var group : Null<Int>;
	public var date_edited : SNull<SDateTime>;
	/*********************************/
	
	public var old_survey_id : SInt;
	public var syncTimestamp : SFloat;
	
	override public function insert()
	{
		date_edited = Date.now();
		super.insert();
	}
}

class Ocorrencias extends Object {
	public var id : SId;
	//?
	public var desc : SNull<SString<4096>>; //
	@:relation(survey_id) public var survey : Survey;
	public var datetime : SDateTime;
	public var json : Null<String>;
	public var syncTimestamp : SFloat;
	public var old_id : SInt;
	public var old_survey_id : SInt;
}

class Familia extends Object {
	public var id : SId;
	@:relation(survey_id) public var survey : Survey;

	public var date : SDateTime;
	public var tentativa_id : SInt;
	public var isDeleted : SBool;
	public var isEdited : SInt;

	public var numeroResidentes : SNull<SInt>;
	public var ocupacaoDomicilio : SNull<SEnum<OcupacaoDomicilio>>;

	public var condicaoMoradia : SNull<SEnum<CondicaoMoradia>>;
	public var tipoImovel : SNull<SEnum<TipoImovel>>;

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


	public var nomeContato : SNull<SString<255>>;
	public var telefoneContato : SNull<SString<255>>;
	public var rendaDomiciliar : SNull<SEnum<RendaDomiciliar>>;
	public var recebeBolsaFamilia : SNull<SBool>;
	
	public var json : Null<String>;
	public var syncTimestamp : SFloat;
	public var old_id : SInt;
	public var old_survey_id : SInt;
}

class Morador extends Object {
	public var id : SId;

	@:relation(survey_id) public var survey : Survey;
	@:relation(familia_id) public var familia : Familia;
	public var date : SDateTime;
	public var isDeleted : SBool;
	public var isEdited : SInt;

	public var nomeMorador : SNull<SString<255>>;
	public var proprioMorador_id : SNull<SBool>;
	public var idade : SNull<SEnum<Idade>>;
	public var genero_id : SNull<SInt>;
	public var grauInstrucao : SNull<SEnum<GrauInstrucao>>;
	@:relation(quemResponde_id) public var quemResponde : SNull<Morador>;

	public var situacaoFamiliar : SNull<SEnum<SituacaoFamiliar>>;
	public var atividadeMorador : SNull<SEnum<AtividadeMorador>>;
	public var possuiHabilitacao_id : SNull<SBool>;
	public var portadorNecessidadesEspeciais : SNull<SEnum<PortadorNecessidadesEspeciais>>;
	// TODO
	public var setorAtividadeEmpresaPrivada : SNull<SEnum<SetorAtividadeEmpresaPrivada>>;
	public var setorAtividadeEmpresaPublica : SNull<SEnum<SetorAtividadeEmpresaPublica>>;

	public var motivoSemViagem : SNull<SEnum<MotivoSemViagem>>;
	public var json : Null<String>;
	public var syncTimestamp : SFloat;
	public var old_id : SInt;
	public var old_survey_id : SInt;
}

class Ponto extends Object {
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
	@:relation(uf_id) public var uf : UF;
	public var city_id : SInt;
	public var regadm_id : SNull<SInt>;
	public var street_id : SNull<SInt>;
	public var complement_id : SNull<SInt>;
	public var complement_two_id : SNull<SInt>;
	public var complement2_str : SNull<SString<255>>;
	@:relation(ref_id) public var ref : SNull<Referencias>;
	public var ref_str : SNull<SString<255>>;

	public var motivo : SNull<SEnum<Motivo>>;
	public var motivoOutraPessoa : SNull<SEnum<Motivo>>;
	public var tempo_saida : SNull<SString<255>>;
	public var tempo_chegada : SNull<SString<255>>;
	public var json : Null<String>;
	
	@:relation(copiedFrom_id) public var copiedFrom : SNull<Ponto>;
	public var isPontoProx : SNull<SBool>;
	@:relation(pontoProx_id) public var pontoProx : SNull<Ponto>;
	public var old_id : SInt;
	public var syncTimestamp : SFloat;
	public var old_survey_id : SInt;
}

class Modo extends Object {
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

	// Coisas resumidas:

	public var valorViagem : SNull<SFloat>;
	public var naoSabe : SNull<SBool>;
	public var naoRespondeu : SNull<SBool>;

	public var json : Null<String>;
	
	public var syncTimestamp : SFloat;
	public var old_survey_id : SInt;
	public var old_morador_id : SInt;
	public var old_id : SInt;
}

