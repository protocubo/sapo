package common.spod;
import haxe.Template;
import sys.db.Object;
import sys.db.Types.SEnum;
import sys.db.Types.SId;
import sys.db.Types.SInt;
import sys.db.Types.SNull;
import sys.db.Types.SString;

/**
 * ...
 * @author Caio
 */
 
 class EnumTable extends Object
 {
	public var id : SId;
	public var val : SNull<SInt>;
	public var name : SString<255>;
 }
 
 //Classes de Relação com id/desc apenas
 @dbNullVal(0) enum AguaEncanada {
	@dbVal(1) Sim;
	@dbVal(2) SimPropriedade;
	@dbVal(3) Nao;
}

class AguaEncanada_Tbl extends EnumTable {}

 @dbNullVal(101) @tempstring("Ano de fabricação do veículo mais novo:") enum AnoVeiculoMaisRecente {
	@dbVal(1) @tt("Posterior a 2014") Mais2014;
	@dbVal(2) @tt("De 2010 a 2013") De2010;
	@dbVal(3) @tt("De 2005 a 2009") De2005;
	@dbVal(4) @tt("De 2000 a 2004") De2000;
	@dbVal(5) @tt("De 1995 a 1999") De1995;
	@dbVal(6) @tt("De 1990 a 1994") De1990;
	@dbVal(7) @tt("Anterior a 1989") De1989;
	@dbVal(90) @tt("Não sabe") NaoSabe;
	@dbVal(101) @tt("Não respondeu") NaoRespondeu;
}

 class AnoVeiculoMaisRecente_Tbl extends EnumTable
{}

@dbNullVal(8) enum FrequenciaViagem {
	@dbVal(1) Raramente;
	@dbVal(2) Menos1Mes;
	@dbVal(3) Vez1Mes;
	@dbVal(4) Vez2Mes;
	@dbVal(5) Semana1a2;
	@dbVal(6) Semana3a4;
	@dbVal(7) MaisSemana5;
	@dbVal(8) NaoRespondeu;
 }
 
//@:keep class FrequenciaViagem_Tbl extends EnumTable {}
  
@dbNullVal(9) enum TempoPermanenciaEstacionamento {
	 @dbVal(1) MeiaHora;
	 @dbVal(2) UmaHora;
	 @dbVal(3) DuasHoras;
	 @dbVal(4) Turno;
	 @dbVal(5) Diaria;
	 @dbVal(6) Pernoite;
	 @dbVal(7) MaisDeUmDia;
	 @dbVal(8) NaoSabe;
	 @dbVal(9) NaoRespondeu;
 }
 
//  class TempoPermanenciaEstacionamento_Tbl extends EnumTable {}

@dbNullVal(101) enum AtividadeMorador
{
	@dbVal(1) EmpresaPrivada;
	@dbVal(2) Publico;
	@dbVal(3) Liberal;
	@dbVal(4) Empresario;
	@dbVal(5) Informal;
	@dbVal(6) Domestico;
	@dbVal(7) Voluntario;
	@dbVal(8) Lar;
	@dbVal(9) Aposentado;
	@dbVal(10) Desempregado;
	@dbVal(11) EstudanteRegular;
	@dbVal(12) EstudanteOutros;
	@dbVal(13) NaoTem;
	@dbVal(99) Outros;
	@dbVal(101) NaoRespondeu;
}

 class AtividadeMorador_Tbl extends EnumTable
 {}
	
 @dbNullVal(101) enum CondicaoMoradia {
	@dbVal(1) Propria;
	@dbVal(2) PropriaAquisicao;
	@dbVal(3) Alugada;
	@dbVal(4) Cedida;
	@dbVal(5) Funcional;
	@dbVal(6) ConcessaoUso;
	@dbVal(99) Outros;
	@dbVal(101) NaoRespondeu;
}
  class CondicaoMoradia_Tbl extends EnumTable{}
 
  @dbNullVal(5) enum EmpregadosDomesticos {
	@dbVal(1) Residente;
	@dbVal(2) Mensalista;
	@dbVal(3) Diarista;
	@dbVal(4) NaoPossui;
	@dbVal(5) NaoRespondeu;
 }
 
 class EmpregadosDomesticos_Tbl extends EnumTable {
	 
 }
   

 @dbNullVal(0) enum EstadoPesquisa {
	@dbVal(1) Concluida;
	@dbVal(2) IncompletaMorador;
	@dbVal(3) IncompletaViagem;
 }
  class EstadoPesquisa_Tbl extends EnumTable {
	 
 }
 
  @dbNullVal(101) enum FormaPagamento {
	@dbVal(1) Dinheiro;
	@dbVal(2) Cartao;
	@dbVal(3) VT;
	@dbVal(4) Estudante;
	@dbVal(5) Gratuidade;
	@dbVal(99) Outros;
	@dbVal(101) NaoRespondeu;
 }
 
  class FormaPagamento_Tbl extends EnumTable {
	 
 }
 
   
  @dbNullVal(99) enum GrauInstrucao
 {
	 @dbVal(1) Analfabeto;
	 @dbVal(2) Alfabetizado;
	 @dbVal(3) PreEscolar;
	 @dbVal(4) FundamentalIncompleto;
	 @dbVal(5) FundamentalCompleto;
	 @dbVal(6) MedioIncompleto;
	 @dbVal(7) MedioCompleto;
	 @dbVal(8) SuperiorIncompleto;
	 @dbVal(9) SuperiorCompleto;
	 @dbVal(10) Pos;
	 @dbVal(11) NaoEstuda;
	 @dbVal(99) NaoRespondeu;
 }
 
  class GrauInstrucao_Tbl extends EnumTable {
	 
 }
 
  @dbNullVal(101) enum Idade
 {
	@dbVal(1) @tt("0 - 4") De00Ate04;
	@dbVal(2) @tt("5 - 9") De05Ate09;
	@dbVal(3) @tt("10 - 14") De10Ate14;
	@dbVal(4) @tt("15 - 17") De15Ate17;
	@dbVal(5) @tt("18 - 19") De18Ate19;
	@dbVal(6) @tt("20 - 24") De20Ate24;
	@dbVal(7) @tt("25 - 29") De25Ate29;
	@dbVal(8) @tt("30 - 39") De30Ate39;
	@dbVal(9) @tt("40 - 49") De40Ate49;
	@dbVal(10) @tt("50 - 59") De50Ate59;
	@dbVal(11) @tt("60 - 69") De60Ate69;
	@dbVal(12) @tt("70 - 79") De70Ate79;
	@dbVal(13) @tt(" 80 - 120") Mais80;
	@dbVal(101) @tt(" N/I ") NaoRespondeu;
 }
 
  class Idade_Tbl extends EnumTable {
	 
 }


 
  @dbNullVal(0) enum MeioTransporte{
	 @dbVal(1) Ape;
	 @dbVal(2) Bicicleta;
	 @dbVal(3) OnibusConv;
	 @dbVal(4) BRT;
	 @dbVal(5) Escolar;
	 @dbVal(6) Fretado;
	 @dbVal(7) Clandestino;
	 @dbVal(8) Metro;
	 @dbVal(9) AutoCond;
	 @dbVal(10) AutoPass;
	 @dbVal(11) MotoCond;
	 @dbVal(12) MotoPass;
	 @dbVal(13) Taxi;
	 @dbVal(14) MotoristaPrivado;
	 @dbVal(15) MotoTaxi;
	 @dbVal(99) Outros;
 }
 
  class MeioTransporte_Tbl extends EnumTable {
	 
 }
 
  @dbNullVal(101) enum Motivo
 {
	@dbVal(1) Residencia;
	@dbVal(2)  TrabPrincipal;
	@dbVal(3) TrabSecundario;
	@dbVal(4) Negocios;
	@dbVal(5) EstudoReg;
	@dbVal(6) EstudoSec;
	@dbVal(7) Compras;
	@dbVal(8) Pessoais;
	@dbVal(9) Refeicao;
	@dbVal(10) Saude;
	@dbVal(11) Lazer;
	@dbVal(12) LevarPessoa;
	@dbVal(99) Outros;
	@dbVal(101) NaoRespondeu;
 }
 
  class Motivo_Tbl extends EnumTable {
	 
 }
 //TODO
 @dbNullVal(3) enum MotivoSemViagem
 {
	@dbVal(1) NaoRealizou;
	@dbVal(2) NaoSoube;
	@dbVal(3) NaoRespondeu;
 }
 
  class MotivoSemViagem_Tbl extends EnumTable {
	 
 }
 
 @dbNullVal(0) enum OcupacaoDomicilio
 {
	@dbVal(1) Uni;
	@dbVal(2) Multi;
	@dbVal(3) Republica;
	@dbVal(4) Compartilhado;
	@dbVal(99) Outros;
 }
 
  class OcupacaoDomicilio_Tbl extends EnumTable {
	 
 }



 @dbNullVal(0) enum PortadorNecessidadesEspeciais
 {
	@dbVal(1) NaoAplica;
	@dbVal(2) Cognitiva;
	@dbVal(3) Cegueira;
	@dbVal(4) FisicaTemp;
	@dbVal(5) FisicaPerm;
	@dbVal(6) Cadeirante;
	@dbVal(7) Outros;
 }
 
  class PortadorNecessidadesEspeciais_Tbl extends EnumTable {
	 
 }
 
 @dbNullVal(101) enum SetorAtividadeEmpresaPrivada
 {
	 @dbVal(1) Agropecuaria;
	 @dbVal(2) ConstrucaoCivil;
	 @dbVal(3) Industria;
	 @dbVal(4) Comercio;
	 @dbVal(5) Financeiro;
	 @dbVal(6) Servicos;
	 @dbVal(99) Outro;
	 @dbVal(101) NR;
 }
 
 class SetorAtividadeEmpresaPrivada_Tbl extends EnumTable {
	 
 }
 
 @dbNullVal(101) enum SetorAtividadeEmpresaPublica {
	@dbVal(1) AdministracaoFederal;
	@dbVal(2) AdministracaoGDF;
	@dbVal(3) AdministracaoMunicipal;
	@dbVal(101) NR;
 }
 
 class SetorAtividadeEmpresaPublica_Tbl extends EnumTable {
	 
 }
 
 @dbNullVal(13) enum RendaDomiciliar
 {
	@dbVal(1) Sem;
	@dbVal(2) De0;
	@dbVal(3) De440;
	@dbVal(4) De880;
	@dbVal(5) De1760;
	@dbVal(6) De2640;
	@dbVal(7) De4400;
	@dbVal(8) De8800;
	@dbVal(9) De13200;
	@dbVal(10) De17600;
	@dbVal(11) De22000;
	@dbVal(12) De26400;	
	@dbVal(13) NaoRespondeu;
 }
 
  class RendaDomiciliar_Tbl extends EnumTable {
	 
 }
 
 @dbNullVal(0) enum SituacaoFamiliar
 {
	@dbVal(1) Responsavel;
	@dbVal(2) Conjuge;
	@dbVal(3) Filho;
	@dbVal(4) Pai;
	@dbVal(5) Parente;
	@dbVal(6) Pensionista;
	@dbVal(7) Agregado;
	@dbVal(8) EmpregadoResidente;
	@dbVal(9) ResidenteTemp;
	@dbVal(99) Outros;
 }
 
  class SituacaoFamiliar_Tbl extends EnumTable {
	 
 }
 
 @dbNullVal(101) enum TipoEstacionamento
 {
	@dbVal(1) Propria;
	@dbVal(2) GratuitoViaPublica;
	@dbVal(3) GratuitoFora;
	@dbVal(4) EstPagoMensal;
	@dbVal(5) EstPagoHora;
	@dbVal(6) NaoEstacionou;
	@dbVal(99) Outros;
	@dbVal(101) NaoRespondeu;
 }
 
 class TipoEstacionamento_Tbl extends EnumTable {
	 
 }
 
  
 @dbNullVal(0) enum TipoImovel
 {
	 @dbVal(1) Apartamento;
	 @dbVal(2) CasaAlvenaria;
	 @dbVal(3) AlvenariaInacabada;
	 @dbVal(4) BarracoComPiso;
	 @dbVal(5) BarracoSemPiso;
	 @dbVal(6) PredioComercial;
	 @dbVal(99) Outros;
 }
 
  class TipoImovel_Tbl extends EnumTable {
	 
 }
 
 
 
