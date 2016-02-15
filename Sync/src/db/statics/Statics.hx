package db.statics;
import haxe.Template;
import sys.db.Object;
import sys.db.Types.SId;
import sys.db.Types.SString;

/**
 * ...
 * @author Caio
 */

 class EnumTable extends Object
 {
	public var id : SId;
	public var name : SString<32>;
	public var desc : SString<255>;
 }
 //Classes de Relação com id/desc apenas
enum AguaEncanada {
	Sim;
	SimPropriedade;
	Nao;
}

 class AguaEncanadaTbl extends EnumTable
{}

 enum AnoVeiculo {
	Mais2014;
	De2010;
	De2005;
	De2000;
	De1995;
	De1990;
	De1989;
	NaoSabe;
	NaoRespondeu;
}

 class AnoVeiculoTbl extends EnumTable
{}

 enum AtividadeMorador
{
	EmpresaPrivada;
	Publico;
	Liberal;
	Empresario;
	Informal;
	Domestico;
	Voluntario;
	Lar;
	Aposentado;
	Desempregado;
	EstudanteRegular;
	EstudanteOutros;
	NaoTem;
	Outros;
	NaoRespondeu;
}

 class AtividadeMoradorTbl extends EnumTable
{}
	
  enum CondicaoMoradia {
	Propria;
	PropriaAquisicao;
	Alugada;
	Cedida;
	Funcional;
	ConcessaoUso;
	Outros;
	NaoRespondeu;
 }
  class CondicaoMoradiaTbl extends EnumTable{}
 
  enum Empregado {
	Residente;
	Mensalista;
	Diarista;
	NaoPossui;
	NaoRespondeu;
 }
   
 class EstacaoMetro extends Object
 {
	 public var id : SId;
	 public var desc : SString<255>;
 }
 
 enum EstadoPesquisa {
	Concluida;
	ConcluidaParcial;
	Incompleta;
	Outros;
 }
  class EstadoPesquisaTbl extends EnumTable {
	 
 }
 
  enum FormaPagamento {
	Dinheiro;
	Cartao;
	VT;
	Estudante;
	Gratuidade;
	Outros;
	NaoRespondeu;
 }
 
  class FormaPagamentoTbl extends EnumTable {
	 
 }
 
  enum FrequenciaViagem {
	Raramente;
	Menos1Mes;
	Vez1Mes;
	Vez2Mes;
	Semana1a2;
	Semana3a4;
	MaisSemana5;
	NaoRespondeu;
 }
 
  class FrequenciaViagemTbl extends EnumTable {
	 
 }
 
  enum GrauInstrucao
 {
	 Analfabeto;
	 Alfabetizado;
	 PreEscolar;
	 FundamentalIncompleto;
	 FundamentalCompleto;
	 MedioIncompleto;
	 MedioCompleto;
	 SuperiorIncompleto;
	 SuperiorCompleto;
	 NaoEstuda;
	 NR;
 }
 
  class GrauInstrucaoTbl extends EnumTable {
	 
 }
 
  enum Idade
 {
	De0004;
	De0509;
	De1014;
	De1517;
	De1819;
	De2024;
	De2529;
	De3039;
	De4049;
	De5059;
	De6069;
	De7079;
	Mais80;
 }
 
  class IdadeTbl extends EnumTable {
	 
 }

 class LinhaOnibus extends Object {
	 public var id : SId;
	 public var desc : SString<255>;
 }
 
  enum MeioTransporte{
	 Ape;
	 Bicicleta;
	 OnibusConv;
	 BRT;
	 Escolar;
	 Fretado;
	 Clandestino;
	 Metro;
	 AutoCond;
	 AutoPass;
	 MotoCond;
	 MotoPass;
	 Taxi;
	 MotoristaPrivado;
	 MotoTaxi;
	 Outros;
 }
 
  class MeioTransporteTbl extends EnumTable {
	 
 }
 
  enum Motivo
 {
	 Residencia;
	 TrabPrincipal;
	 TrabSecundario;
	 Negocios;
	 EstudoReg;
	 EstudoSec;
	 Compras;
	 Pessoais;
	 Refeicao;
	 Saude;
	 Lazer;
	 LevarPessoa;
	 Outros;
	 NR;
 }
 
  class MotivoTbl extends EnumTable {
	 
 }
 
  enum MotivoSemViagem
 {
	NaoRealizou;
	NaoSoube;
	NR;
 }
 
  class MotivoSemViagemTbl extends EnumTable {
	 
 }
 
  enum OcupacaoDomicilio
 {
	Uni;
	Multi;
	Republica;
	Compartilhado;
	Outros;
 }
 
  class OcupacaoDomicilioTbl extends EnumTable {
	 
 }
 
  enum PortadorNecessidadesEspeciais
 {
	NaoAplica;
	Cognitiva;
	Cegueira;
	FisicaTemp;
	FisicaPerm;
	Cadeirante;
	Outros;
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
 
  enum Renda
 {
	 Sem;
	 De440;
	 De880;
	 De1760;
	 De2640;
	 De4400;
	 De8800;
	 De13200;
	 De17600;
	 De22000;
	 De26400;
	 NR;
	
 }
 
  class RendaTbl extends EnumTable {
	 
 }
 
  enum SituacaoFamiliar
 {
	Responsavel;
	Conjuge;
	Filho;
	Pai;
	Parente;
	Pensionista;
	Agregado;
	EmpregadoResidente;
	ResidenteTemp;
	Outros;
 }
 
  class SituacaoFamiliarTbl extends EnumTable {
	 
 }
 
  enum TempoEstacionamento
 {
	 MeiaHora;
	 UmaHora;
	 DuasHoras;
	 Turno;
	 Diaria;
	 Pernoite;
	 MaisDeUmDia;
	 NaoSabe;
	 NR;	 
 }
 
  class TempoEstacionamentoTbl extends EnumTable {
	 
 }
 
  enum TipoImovel
 {
	 Apartamento;
	 CasaAlvenaria;
	 AlvenariaInacabada;
	 BarracoComPiso;
	 BarracoSemPiso;
	 PredioComercial;
	 Outros;
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
 
 