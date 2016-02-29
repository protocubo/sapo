package sync;
import common.spod.EnumSPOD;
import common.spod.statics.EstacaoMetro;
import common.spod.statics.LinhaOnibus;
import common.spod.statics.Referencias;
import common.spod.statics.UF;
import haxe.Http;
import haxe.Json;
import haxe.Log;
import haxe.PosInfos;
import common.spod.InitDB;
import sapo.Context;
import sapo.spod.Survey;

import sys.db.Connection;
import sys.db.Manager;
import sys.db.Mysql;
import sys.db.Types.SFloat;
import sys.FileSystem;
import sys.io.File;
import common.tools.StringTools;

/**
 * ...
 * @author Caio
 */
using Lambda;
class MainSync
{

	static var targetCnx : Connection;
	
	static var maxtimestamp : SFloat;
	
	static var sessHash : Map<Int, Survey>;
	static var famHash : Map<Int, Familia>;
	static var morHash : Map<Int, Morador>;
	static var pointhash : Map<Int,Ponto>;
	
	static var refValue : Map<String,Map<Int,Int>>;
	
	//User_id , Group, Count
	static var userGroup : Map<Int, Map<Int,Int>>;
	
	static var syncex : Map<String,Int>;
	
	static var ours : Map<String,Int>;
	static var warning : Int = 0;
	
	public static function main()
	{
		Log.trace = function(txt : Dynamic, ?infos : PosInfos)
		{
			var v = File.append("Log.txt");
			v.writeString(txt + '\n');
			v.close();
			
			Sys.println(infos.className + " " + infos.lineNumber + ": " + txt);
		}
		//TODO:Apagar
		{
			//Context.init();
			//Context.resetMainDb();
		}
		//END
		syncex = new Map();
		ours = new Map();
		
		InitDB.run();
		
		if (!FileSystem.exists("./private/cnxstring"))
		{
			trace("No cnxstring file!");
			return;
		}
		
		var cnxstring = Json.parse(File.getContent("./private/cnxstring"));
		targetCnx = Mysql.connect(Reflect.field(cnxstring, "DFTTPODD"));
		targetCnx.request("START TRANSACTION");
		
		#if debug
		var serverTimestamp = Date.now();
		#else
		var serverTimestamp = serverTimestamp();
		#end
		
		//SQLite - yay versao antiga
		try{
		Manager.cnx.request("CREATE VIEW UpdatedSession AS SELECT MAX(id) as session_id, old_survey_id, MAX(syncTimestamp) as syncTimestamp FROM Survey GROUP BY old_survey_id");
		}
		catch (e : Dynamic)
		{
			
		}
		//MySQL
		//Manager.cnx.request("CREATE OR REPLACE VIEW UpdatedSession AS SELECT MAX(id) as session_id, old_survey_id, MAX(syncTimestamp) as syncTimestamp FROM Survey GROUP BY old_survey_id");
		
		var resUsers = Manager.cnx.request("SELECT id, user_id, `group` FROM Survey s JOIN UpdatedSession us ON s.id = us.session_id ORDER BY user_id, `group`");
		userGroup = new Map();
		for (r in resUsers)
		{
			var submap : Map<Int, Int>;
			if (userGroup.get(r.user_id) == null)
			{
				trace("woot");
				submap = new Map();
			}
			else
				submap = userGroup.get(r.user_id);
			
			var v = submap.get(r.group) != null ? submap.get(r.group) : 0;
			submap.set(r.group, v + 1);
			
			userGroup.set(r.user_id, submap);			
		}
		
		
		//Todos os valores de enums -> usa as keys "EnumName" e "Old_val" => "New_val" para conversão das entradas originais para as novas
		//A estrutura é Map<String,Map<Int,Int>>
		refValue = populateHash();
		
		// Query -> ../../extras/main.sql
		//Session_id only 
		//var updateVars = targetCnx.request("SELECT DISTINCT session_id FROM ((SELECT ep.session_id as session_id FROM SyncMap sm join EnderecoProp ep ON sm.tbl = 'EnderecoProp' AND sm.new_id = ep.id /*AND sm.timestamp > x*/) UNION ALL (SELECT  s.id as session_id FROM SyncMap sm JOIN Session s ON sm.tbl = 'Session' AND sm.new_id = s.id /*AND sm.timestamp > x*/) UNION ALL ( select f.session_id as session_id FROM SyncMap sm JOIN Familia f ON f.id = sm.new_id AND sm.tbl = 'Familia'  /*AND sm.timestamp > x*/) UNION ALL (select  m.session_id as session_id FROM SyncMap sm JOIN Morador m ON m.id = sm.new_id AND sm.tbl = 'Morador'  /*AND sm.timestamp > x*/) UNION ( select  p.session_id as session_id FROM SyncMap sm JOIN Ponto p ON  sm.tbl = 'Ponto' AND p.id = sm.new_id  /*AND sm.timestamp > x*/) UNION ALL (select m.session_id as session_id FROM SyncMap sm JOIN Modo m ON m.id = sm.new_id AND sm.tbl = 'Modo'  /*AND sm.timestamp > x*/)	) ack WHERE session_id IS NOT NULL ORDER BY session_id ASC").results().map(function(v) { return v.session_id; } ).array();
		var updateVars = targetCnx.request("SELECT id as session_id FROM Session WHERE id < 100").results().map(function(v) { return v.session_id; } ).array();
		#if debug
		maxtimestamp = Date.now().getTime();
		#else
		maxtimestamp = targetCnx.request("SELECT timestamp as tmp FROM SyncMap ORDER BY timestamp DESC LIMIT 1").results().first().tmp;
		#end
		
		//Hash old_id -> new instance
		sessHash = new Map<Int, Survey>();
		famHash = new Map<Int, Familia>();
		morHash = new Map<Int, Morador>();
		pointhash = new Map<Int, Ponto>();
		
		for (u in updateVars)
		{
			var shouldInsert = processSessionID(u, false);
		}
		
		Manager.cleanup();
		Manager.cnx.close();
		targetCnx.close();
		
		//TODO: Mandar mensagem
		for (k in syncex.keys())
		{
			var v = ours.get(k);
			v = (v != null) ? v : 0;
			trace("Table " + k + ": Syncex had " + syncex.get(k) + " entries. Updated : " + v);
		}
		
		trace("Done with only " + warning + " warnings!");
	}
	
	static function processSessionID(u : Int, insertMode : Bool) : Bool
	{
		for (p in [processSession, processFamilia, processMorador, processPonto, processModo, processOcorrencias]) {
			if (p(u, insertMode))
				return processSessionID(u, true);
		}
		return true;
	}
	
	static function processSession(sid : Int, insertMode : Bool) : Bool
	{
		var dbSession = targetCnx.request("SELECT * FROM Session WHERE id = " + sid).results().first();
		
		var new_sess = new Survey();
		for (f in Reflect.fields(dbSession))
		{
			switch(f)
			{
				case "id":
					new_sess.old_survey_id = dbSession.id;
				//Conversao de bool (hoorray)
				case "isValid", "isRestored":
					Reflect.setField(new_sess, f, (Reflect.field(dbSession, f) == 1));
				//Copia simples de campo
				case "user_id", "tentativa_id", "lastPageVisited", 
				"dataInicioPesquisaPapel", "dataFimPesquisaPapel", "codigoFormularioPapel", 
				"date_create", "date_started", "date_finished", "date_completed",
				"endereco_id", "pin", "latitude", "longitude",
				"municipio", "bairro", "logradouro", "numero", "complemento","cep",
				"zona","macrozona","lote","estratoSocioEconomico":
					Reflect.setField(new_sess, f, Reflect.field(dbSession, f));
				//Enum
				case "estadoPesquisa_id":
					Macros.setEnumField(f, new_sess, dbSession);
				case "ponto","gps_id","client_ip", "closedFromIndex":
					continue;
				default:
					Macros.warnTable("Survey", f, null);
			}
		}
		
		new_sess.syncTimestamp = maxtimestamp;
		if (insertMode)
		{
			var groups = userGroup.get(new_sess.user_id);
			var biggest = 1;
			if (groups == null)
				groups = new Map();
				
			for(k in groups.keys())
			{
				if (k > biggest)
					biggest = k;
			}
			trace("cur? " + biggest);
			
			//trace(groups != null);
			if (groups.get(biggest) == null || groups.get(biggest) < 10)
			{
				var curval = groups.get(biggest) != null ? groups.get(biggest) : 0;
				groups.set(biggest, curval + 1);
				userGroup.set(new_sess.user_id, groups);
				
				new_sess.group = biggest;
			}
			else
			{
				trace("null? ");
				
				var v = biggest + 1;
				groups.set(v, 1);
				userGroup.set(new_sess.user_id, groups);
				
				new_sess.group = v;
			}
		
		}
		
		Macros.validateEntry(Survey, ["syncTimestamp", "id"], [ { key : "old_survey_id", value : new_sess.old_survey_id } ], new_sess);
		
		sessHash.set(new_sess.old_survey_id, new_sess);
		return false;
	}
	
	static function processFamilia(old_sid : Int, insertMode : Bool) : Bool
	{
		var dbFam = targetCnx.request("SELECT * FROM Familia WHERE session_id = " + old_sid + " ORDER BY id").results();
		var new_familia = new Familia();
		
		for (f in dbFam)
		{
			for (field in Reflect.fields(f))
			{
				switch(field)
				{
					case "id":
						new_familia.old_id = f.id;
					case "session_id":
						new_familia.survey = sessHash.get(f.session_id);
						new_familia.old_survey_id = f.session_id;
					case "ocupacaoDomicilio_id", "condicaoMoradia_id", "tipoImovel_id",
					"aguaEncanada_id", "anoVeiculoMaisRecente_id", "empregadosDomesticos_id", 
					"rendaDomiciliar_id":
						Macros.setEnumField(field, new_familia, f);
					//Fields ctrl+c ctrl+v
					case "date", "isEdited", "numeroResidentes", "banheiros", "quartos", 
					"veiculos", "bicicletas", "motos",  "nomeContato", "telefoneContato","tentativa_id":
						Reflect.setField(new_familia, field, Reflect.field(f, field));
					//Bool simples
					case "isDeleted","ruaPavimentada_id", "recebeBolsaFamilia_id":
						Reflect.setProperty(new_familia, field, Reflect.field(f, field) == 1);
					//Conversao enum -> bool
					case "tvCabo_id","vagaPropriaEstacionamento_id, ruaPavimentada_id":
						var v = Reflect.field(f, field);
						Reflect.setField(new_familia, field, (v != 3) ? (v == 1) : null);
					case "gps_id", "editedNumeroResidentes", "editsNumeroResidentes",
					"editedNomeContato", "editsNomeContato", "editedTelefoneContato",
					"editsTelefoneContato", "editedRendaDomiciliar", "editsRendaDomiciliar",
					"codigoReagendamento":
						continue;
					default:
						Macros.warnTable("Familia", field, null);					
				}
			}
			new_familia.syncTimestamp = maxtimestamp;
			
			Macros.validateEntry(Familia, ["syncTimestamp", "id"], [ { key : "old_id" , value : new_familia.old_id }, { key : "old_survey_id", value : new_familia.old_survey_id } ], new_familia); 
			
			famHash.set(new_familia.old_id, new_familia);
		}
		return false;
	}
	
	static function processMorador(old_session : Int, insertMode : Bool) : Bool
	{
		var dbMorador = targetCnx.request("SELECT * FROM Morador WHERE session_id = " + old_session + " ORDER BY familia_id").results();
		for (m in dbMorador)
		{
			var new_morador = new Morador();
			for (field in Reflect.fields(m))
			{
				switch(field)
				{
					case "id":
						new_morador.old_id = m.id;
					case "session_id":
						new_morador.survey = sessHash.get(m.session_id);
						new_morador.old_survey_id = m.session_id;
					case "familia_id":
						new_morador.familia = famHash.get(m.familia_id);
					case "quemResponde_id":
						new_morador.quemResponde = morHash.get(m.quemResponde_id);
					//Enums
					case "idade_id", "grauInstrucao_id", "situacaoFamiliar_id", "atividadeMorador_id", "portadorNecessidadesEspeciais_id", "motivoSemViagem_id","setorAtividadeEmpresaPrivada_id","setorAtividadeEmpresaPublica_id":
						Macros.setEnumField(field, new_morador, m);
					//Bools
					case "isDeleted", "possuiHabilitacao_id","proprioMorador_id":
						var f = (Reflect.field(m, field) == null) ? null : (Reflect.field(m, field) == 1);
						Reflect.setField(new_morador, field, f);
					//ctrl+c ctrl+v
					case "date", "isEdited", "nomeMorador", "genero_id":
						Reflect.setField(new_morador, field, Reflect.field(m, field));
					case "gps_id","codigoReagendamento":
						continue;
					default:
						Macros.warnTable("Morador", field, null);	
				}
			}
			
			new_morador.syncTimestamp = maxtimestamp;
			
			Macros.validateEntry(Morador, ["syncTimestamp", "id"], [ { key : "old_id", value : new_morador.old_id }, { key: "old_survey_id" , value : new_morador.old_survey_id } ], new_morador);
			
			morHash.set(new_morador.old_id , new_morador);
		}
		return false;
	}
	
	static function processPonto(session_id : Int, insertMode : Bool) : Bool
	{
		var dbPoints = targetCnx.request("SELECT * FROM Ponto WHERE session_id = " + session_id + " ORDER BY morador_id, ordem").results();
		for (p in dbPoints)
		{
			var new_point = new Ponto();
			for (field in Reflect.fields(p))
			{
				switch(field)
				{
					case "id":
						new_point.old_id = p.id;
					case "session_id":
						new_point.survey = sessHash.get(p.session_id);
						new_point.old_survey_id = p.session_id;
					case "morador_id":
						new_point.morador = morHash.get(p.morador_id);
					case "copiedFrom_id":
						new_point.copiedFrom = pointhash.get(p.id);
					case "pontoProximoRef_id":
						new_point.pontoProx = pointhash.get(p.pontoProxRef_id);
					case "isDeleted", "isPontoProx":
						new_point.isDeleted = (p.isDeleted == 1);
					//Static refs
					case "uf_id":
						new_point.uf = UF.manager.get(p.uf_id);
					case "ref_id":
						new_point.ref = Referencias.manager.get(p.ref_id);
					//ctrl+c ctrl+v
					case "date", "isEdited", "uf_id", "city_id", "regadm_id", "street_id", "complement_id", "complement_two_id", "complement2_str", "ref_str", "tempo_saida", "tempo_chegada":
						Reflect.setField(new_point, field, Reflect.field(p, field));
					//Enums
					case "motivoID", "motivoOutraPessoaID":
						Macros.setEnumField("motivo", new_point, p);
					case "gps_id", "anterior_id", "posterior_id", "ordem", "city_str", "regadm_str", "street_str", "complement_str", "complement_two_str", "isIntermediario":
						continue;
					default:
						Macros.warnTable("Ponto", field, null);						
				}
			}
			
			new_point.syncTimestamp = maxtimestamp;
			
			Macros.validateEntry(Ponto, [ "id", "syncTimestamp"], [ { key : "old_id", value : new_point.old_id } ], new_point);
			pointhash.set(new_point.old_id, new_point);
		}
		
		return false;
	}
	
	static function processModo(session_id : Int, insertMode : Bool)
	{
		var dbModos = targetCnx.request("SELECT * FROM Modo WHERE session_id = " + session_id + " ORDER BY morador_id, firstpoint_id, anterior_id").results();
		
		for (m in dbModos)
		{
			var new_modo = new Modo();
			for(f in Reflect.fields(m))
			{
				//TODO: Syncar Tabela do Anderson de LINHA
				switch(f)
				{
					case "id":
						new_modo.old_id = m.id;
					case "session_id":
						new_modo.old_survey_id = m.session_id;
						new_modo.survey = sessHash.get(m.session_id);
					case "morador_id":
						new_modo.morador = morHash.get(m.morador_id);
						new_modo.old_morador_id = m.morador_id;
					case "firstpoint_id", "secondpoint_id":
						Reflect.setProperty(new_modo, f, (pointhash.get(Reflect.field(m, f)) != null) ? pointhash.get(Reflect.field(m,f)).id : null );
					case "meiotransporte_id":
						if (Macros.checkEnumValue(MeioTransporte, m.meiotransporte_id))
							new_modo.meiotransporte = Macros.getStaticEnum(MeioTransporte, m.meiotransporte_id);
					case "estacaoEmbarque_id", "estacaoDesembarque_id":
						Reflect.setProperty(new_modo, f.split("_")[0], EstacaoMetro.manager.get(Reflect.field(m, f)));
					case "linhaOnibus_id":
						new_modo.linhaOnibus = LinhaOnibus.manager.get(m.linhaOnibus_id);
					case "formaPagamento_id", "tipoEstacionamento_id":
						Macros.setEnumField(f, new_modo, m);
					case "isDeleted":
						new_modo.isDeleted = (m.isDeleted == 1);
					case "date", "isEdited":
						Reflect.setField(new_modo, f, Reflect.field(m, f));
					//Conversoes de um mte de field pra um 
					case "valorPagoTaxi", "valorViagem", "custoEstacionamento":
						new_modo.valorViagem = m.valorViagem;
					case "naoSabeLinhaOnibus", "naoSabeEstacaoEmbarque", "naoSabeEstacaoDesembarque", "naoSabeValorViagem", "naoSabeValorPagoTaxi", "naoSabeCustoEstacionamento":
						new_modo.naoSabe = (new_modo.naoSabe) ? true : (Reflect.field(m, f) != 0);
					case "naoRespondeuLinhaOnibus", "naoRespondeuEstacaoEmbarque", "naoRespondeuEstacaoDesembarque", "naoRespondeuValorViagem", "naoRespondeuValorPagoTaxi","naoRespondeuCustoEstacionamento":
						new_modo.naoRespondeu = (new_modo.naoRespondeu) ? true : (Reflect.field(m, f) != 0);
					//fim conversao
					case "anterior_id", "posterior_id","ordem", "gps_id", "linhaOnibus_str","estacaoEmbarque_str", "estacaoDesembarque_str":
						continue;
					default:
						Macros.warnTable("Modo", f, null);
				}	
			}
			
			new_modo.syncTimestamp = maxtimestamp;
			Macros.validateEntry(Modo, ["id", "syncTimestamp"], [ { key : "old_id" , value : new_modo.old_id } ], new_modo);
		}
		return false;
	}
	
	static function processOcorrencias(sid : Int, insertMode : Bool)
	{
		var res = targetCnx.request("SELECT * FROM Ocorrencias WHERE session_id = " + sid).results();
		for (r in res)
		{
			var c = new Ocorrencias();
			for (f in Reflect.fields(r))
			{
				switch(f)
				{
					case "id":
						c.old_id = r.id;
					case "session_id":
						c.survey = sessHash.get(r.session_id);
						c.old_survey_id = r.session_id;
					case "desc", "datetime":
						Reflect.setField(c, f, Reflect.field(r, f));
					case "sessionTime_id", "gps_id":
						continue;
					default:
						Macros.warnTable("Ocorrencias", f, null);
				}
			}
			
			c.syncTimestamp = maxtimestamp;
			Macros.validateEntry(Ocorrencias, ["id", "syncTimestamp"], [ { key : "old_id", value : c.old_id } ], c);
		}
		
		return false;
		
	}
	
	static function populateHash() : Map<String,Map<Int,Int>>
	{
		var t = new Map<String,Map<Int,Int>>();
		for (c in CompileTime.getAllClasses("common.spod", true, EnumTable))
		{
			var tempmap = new Map<Int,Int>();
			var res = (untyped c.manager : Manager<EnumTable>).all().map(function(v) { return [v.val, v.id]; } ).array();
			for (r in res)
			{
				tempmap.set(r[0], r[1]);
			}
			
			//Minha nomenclatura de tabelas estáticas é EnumName_Tbl
			var name = Type.getClassName(c).split("_")[0];
			t.set(name, tempmap);
		}
		
		return t;
	}
	
	static function serverTimestamp() : Float
	{
		var http = new Http("syncex.comtacti.com");
		http.setHeader("X-sync-type", "timestamp");
		http.onData = function(s : String)
		{
			var f = Std.parseFloat(s);
			var now = Date.now().getTime();
			//1min
			var dif = 60*1000;
			if ((now - dif) < f && f < (now + dif))
			{
				//TODO: Log error
				throw "Error: Time difference is too damn high!";
			}
		}
		
		http.onError = function(e : Dynamic)
		{
			//TODO: Log
			throw e;
		}
		http.request();
		
	}

}