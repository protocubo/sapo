package sync.db.statics;
import haxe.Template;
import sys.db.Object;
import sys.db.Types.SId;
import sys.db.Types.SNull;
import sys.db.Types.SString;

/**
 * ...
 * @author Caio
 */

 class EnumTable extends Object
 {
	public var id : SId;
	public var name : SString<32>;
	public var desc : SNull<SString<255>>;
 }
 
 //Classes de Relação com id/desc apenas
enum AguaEncanada {
	Sim;
	SimPropriedade;
	Nao;
}

 class AguaEncanadaTbl extends EnumTable
{}

 @:dnNullVal(101) enum AnoVeiculo {
	@:dbVal(1) Mais2014;
	@:dbVal(2) De2010;
	@:dbVal(3) De2005;
	@:dbVal(4) De2000;
	@:dbVal(5) De1995;
	@:dbVal(6) De1990;
	@:dbVal(7) De1989;
	@:dbVal(90) NaoSabe;
}

 class AnoVeiculoTbl extends EnumTable
{}

@:dbNullVal(101) enum AtividadeMorador
{
	@:dbVal(1) EmpresaPrivada;
	@:dbVal(2) Publico;
	@:dbVal(3) Liberal;
	@:dbVal(4) Empresario;
	@:dbVal(5) Informal;
	@:dbVal(6) Domestico;
	@:dbVal(7) Voluntario;
	@:dbVal(8) Lar;
	@:dbVal(9) Aposentado;
	@:dbVal(10) Desempregado;
	@:dbVal(11) EstudanteRegular;
	@:dbVal(12) EstudanteOutros;
	@:dbVal(13) NaoTem;
	@:dbVal(99) Outros;
}

 class AtividadeMoradorTbl extends EnumTable
 {}
	
 @:dbNullVal(101) enum CondicaoMoradia {
	@:dbVal(1) Propria;
	@:dbVal(2) PropriaAquisicao;
	@:dbVal(3) Alugada;
	@:dbVal(4) Cedida;
	@:dbVal(5) Funcional;
	@:dbVal(6) ConcessaoUso;
	@:dbVal(99) Outros;
}
  class CondicaoMoradiaTbl extends EnumTable{}
 
  @:dbNullVal(5) enum Empregado {
	@:dbVal(1) Residente;
	@:dbVal(2) Mensalista;
	@:dbVal(3) Diarista;
	@:dbVal(4) NaoPossui;
 }
   
 class EstacaoMetro extends Object
 {
	 public var id : SId;
	 public var desc : SString<255>;
 }
 
 @:dbNullVal(0) enum EstadoPesquisa {
	@:dbVal(1) Concluida;
	@:dbVal(2) ConcluidaParcial;
	@:dbVal(3) Incompleta;
	@:dbVal(99) Outros;
 }
  class EstadoPesquisaTbl extends EnumTable {
	 
 }
 
  @:dbNullVal(101) enum FormaPagamento {
	@:dbVal(1) Dinheiro;
	@:dbVal(2) Cartao;
	@:dbVal(3) VT;
	@:dbVal(4) Estudante;
	@:dbVal(5) Gratuidade;
	@:dbVal(99) Outros;
 }
 
  class FormaPagamentoTbl extends EnumTable {
	 
 }
 
  @:dbNullVal(8) enum FrequenciaViagem {
	@:dbVal(1) Raramente;
	@:dbVal(2) Menos1Mes;
	@:dbVal(3) Vez1Mes;
	@:dbVal(4) Vez2Mes;
	@:dbVal(5) Semana1a2;
	@:dbVal(6) Semana3a4;
	@:dbVal(7) MaisSemana5;
 }
 
  class FrequenciaViagemTbl extends EnumTable {
	 
 }
 
  @:dbNullVal(99) enum GrauInstrucao
 {
	 @:dbVal(1) Analfabeto;
	 @:dbVal(2) Alfabetizado;
	 @:dbVal(3) PreEscolar;
	 @:dbVal(4) FundamentalIncompleto;
	 @:dbVal(5) FundamentalCompleto;
	 @:dbVal(6) MedioIncompleto;
	 @:dbVal(7) MedioCompleto;
	 @:dbVal(8) SuperiorIncompleto;
	 @:dbVal(9) SuperiorCompleto;
	 @:dbVal(10) Pos;
	 @:dbVal(11) NaoEstuda;
 }
 
  class GrauInstrucaoTbl extends EnumTable {
	 
 }
 
  @dbNullVal(101) enum Idade
 {
	@:dbVal(1) De00Ate04;
	@:dbVal(2) De05Ate09;
	@:dbVal(3) De10Ate14;
	@:dbVal(4) De15Ate17;
	@:dbVal(5) De18Ate19;
	@:dbVal(6) De20Ate24;
	@:dbVal(7) De25Ate29;
	@:dbVal(8) De30Ate39;
	@:dbVal(9) De40Ate49;
	@:dbVal(10) De50Ate59;
	@:dbVal(11) De60Ate69;
	@:dbVal(12) De70Ate79;
	@:dbVal(13) Mais80;
 }
 
  class IdadeTbl extends EnumTable {
	 
 }

 class LinhaOnibus extends Object {
	 public var id : SId;
	 public var desc : SString<255>;
 }
 
  @:dbNullVal(0) enum MeioTransporte{
	 @:dbVal(1) Ape;
	 @:dbVal(2) Bicicleta;
	 @:dbVal(3) OnibusConv;
	 @:dbVal(4) BRT;
	 @:dbVal(5) Escolar;
	 @:dbVal(6) Fretado;
	 @:dbVal(7) Clandestino;
	 @:dbVal(8) Metro;
	 @:dbVal(9) AutoCond;
	 @:dbVal(10) AutoPass;
	 @:dbVal(11) MotoCond;
	 @:dbVal(12) MotoPass;
	 @:dbVal(13) Taxi;
	 @:dbVal(14) MotoristaPrivado;
	 @:dbVal(15) MotoTaxi;
	 @:dbVal(99) Outros;
 }
 
  class MeioTransporteTbl extends EnumTable {
	 
 }
 
  @:dbNullVal(101) enum Motivo
 {
	@:dbVal(1) Residencia;
	@:dbVal(2)  TrabPrincipal;
	@:dbVal(3) TrabSecundario;
	@:dbVal(4) Negocios;
	@:dbVal(5) EstudoReg;
	@:dbVal(6) EstudoSec;
	@:dbVal(7) Compras;
	@:dbVal(8) Pessoais;
	@:dbVal(9) Refeicao;
	@:dbVal(10) Saude;
	@:dbVal(11) Lazer;
	@:dbVal(12) LevarPessoa;
	@:dbVal(99) Outros;
 }
 
  class MotivoTbl extends EnumTable {
	 
 }
 //TODO
 @:dbNullVal(3) enum MotivoSemViagem
 {
	@:dbVal(1) NaoRealizou;
	@:dbVal(2) NaoSoube;
 }
 
  class MotivoSemViagemTbl extends EnumTable {
	 
 }
 
 @:dbNullVal(0) enum OcupacaoDomicilio
 {
	@:dbVal(1) Uni;
	@:dbVal(2) Multi;
	@:dbVal(3) Republica;
	@:dbVal(4) Compartilhado;
	@:dbVal(99) Outros;
 }
 
  class OcupacaoDomicilioTbl extends EnumTable {
	 
 }
 
 @:dbNullVal(0) enum PortadorNecessidadesEspeciais
 {
	@:dbVal(1) NaoAplica;
	@:dbVal(2) Cognitiva;
	@:dbVal(3) Cegueira;
	@:dbVal(4) FisicaTemp;
	@:dbVal(5) FisicaPerm;
	@:dbVal(6) Cadeirante;
	@:dbVal(7) Outros;
 }
 
  class PortadorNecessidadesEspeciaisTbl extends EnumTable {
	 
 }
 
  enum PossuiHabilitacao
 {
	Sim;
	Nao;
	NR;
 }
  class PossuiHabilitacaoTbl extends EnumTable {
	 
 }
 
 @:dbNullVal(13) enum Renda
 {
	@:dbVal(1) Sem;
	@:dbVal(2) De0;
	@:dbVal(3) De440;
	@:dbVal(4) De880;
	@:dbVal(5) De1760;
	@:dbVal(6) De2640;
	@:dbVal(7) De4400;
	@:dbVal(8) De8800;
	@:dbVal(9) De13200;
	@:dbVal(10) De17600;
	@:dbVal(11) De22000;
	@:dbVal(12) De26400;	
 }
 
  class RendaTbl extends EnumTable {
	 
 }
 
 @:dnNullVal(0) enum SituacaoFamiliar
 {
	@:dbVal(1) Responsavel;
	@:dbVal(2) Conjuge;
	@:dbVal(3) Filho;
	@:dbVal(4) Pai;
	@:dbVal(5) Parente;
	@:dbVal(6) Pensionista;
	@:dbVal(7) Agregado;
	@:dbVal(8) EmpregadoResidente;
	@:dbVal(9) ResidenteTemp;
	@:dbVal(99) Outros;
 }
 
  class SituacaoFamiliarTbl extends EnumTable {
	 
 }
 
 @:dnNullVal(9) enum TempoEstacionamento
 {
	 @:dbVal(1) MeiaHora;
	 @:dbVal(2) UmaHora;
	 @:dbVal(3) DuasHoras;
	 @:dbVal(4) Turno;
	 @:dbVal(5) Diaria;
	 @:dbVal(6) Pernoite;
	 @:dbVal(7) MaisDeUmDia;
	 @:dbVal(8) NaoSabe;
 }
 
  class TempoEstacionamentoTbl extends EnumTable {
	 
 }
 
 @:dbNullVal(0) enum TipoImovel
 {
	 @:dbVal(1) Apartamento;
	 @:dbVal(2) CasaAlvenaria;
	 @:dbVal(3) AlvenariaInacabada;
	 @:dbVal(4) BarracoComPiso;
	 @:dbVal(5) BarracoSemPiso;
	 @:dbVal(6) PredioComercial;
	 @:dbVal(99) Outros;
 }
 
  class TipoImovelTbl extends EnumTable {
	 
 }
 
  enum TvCabo
 {
	 Sim;
	 Nao;
	 NR;
 }
 
  class TvCaboTbl extends EnumTable {
	 
 }
 
 