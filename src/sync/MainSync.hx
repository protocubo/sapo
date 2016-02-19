package sync;

import haxe.Log;
import haxe.PosInfos;
import sync.db.Familia;
import sync.db.InitDB;
import sync.db.Modo;
import sync.db.Morador;
import sync.db.Ponto;
import sync.db.Session;
import haxe.Http;
import haxe.Json;
import haxe.remoting.HttpConnection;
import neko.Lib;
import sys.db.Connection;
import sys.db.Manager;
import sys.db.Mysql;
import sys.db.Sqlite;
import sys.FileSystem;
import sys.io.File;
import sync.db.statics.Statics;


/**
 * ...
 * @author Caio
 */

 using Lambda;
class MainSync 
{

	public static var targetCnx : Connection;
	static function main() 
	{
		Log.trace = function(txt : Dynamic, ?posInfos : PosInfos)
		{
			var v = File.append("traces.txt");
			v.writeString(txt + "\n");
			v.close();
			
			Sys.println(txt);
		}
		InitDB.run();
		Manager.cnx.startTransaction();
		
		if (!FileSystem.exists("./private/cnxstring"))
		{
			trace("No cnxstring file!");
			return;
		}
		
		var cnxstring = Json.parse(File.getContent("./private/cnxstring"));
		targetCnx = Mysql.connect(Reflect.field(cnxstring, "DFTTPODD"));
		targetCnx.request("START TRANSACTION");
		
		#if Release
		var serverTimestamp = serverTimestamp();
		#else
		var serverTimestamp = Date.now();
		#end
		
		//Ref Tables -> key - Table, value: OldVal<NewVal> onde OldVal é o ID da tabela de ref. do Anderson e o NewVal é o meu valor de enum;
		var refValue = new Map<String, Map<Int,Int>>();

		for (c in CompileTime.getAllClasses("sync.db.statics", true, EnumTable))
		{
			var tempmap = new Map<Int,Int>();
			var manager = Reflect.getProperty(c, "manager");
			
			var res = (untyped c.manager:Manager<EnumTable>).all();
			var res1 = Lambda.map(res,function(v) {
				return [v.val , v.id];
			}).array();
			for(r in res1)
			{
				tempmap.set(r[0], r[1]);
			}
			var name = Type.getClassName(c).split("_")[0];
			refValue.set(name, tempmap);
		}
		
		// Query -> ../../extras/main.sql
		//Session_id only 
		var updateVars = targetCnx.request("SELECT DISTINCT session_id FROM ((SELECT ep.session_id as session_id FROM SyncMap sm join EnderecoProp ep ON sm.tbl = 'EnderecoProp' AND sm.new_id = ep.id /*AND sm.timestamp > x*/) UNION ALL (SELECT  s.id as session_id FROM SyncMap sm JOIN Session s ON sm.tbl = 'Session' AND sm.new_id = s.id /*AND sm.timestamp > x*/) UNION ALL ( select f.session_id as session_id FROM SyncMap sm JOIN Familia f ON f.id = sm.new_id AND sm.tbl = 'Familia'  /*AND sm.timestamp > x*/) UNION ALL (select  m.session_id as session_id FROM SyncMap sm JOIN Morador m ON m.id = sm.new_id AND sm.tbl = 'Morador'  /*AND sm.timestamp > x*/) UNION ( select  p.session_id as session_id FROM SyncMap sm JOIN Ponto p ON  sm.tbl = 'Ponto' AND p.id = sm.new_id  /*AND sm.timestamp > x*/) UNION ALL (select m.session_id as session_id FROM SyncMap sm JOIN Modo m ON m.id = sm.new_id AND sm.tbl = 'Modo'  /*AND sm.timestamp > x*/)	) ack WHERE session_id IS NOT NULL ORDER BY session_id ASC").results().map(function(v) { return v.session_id; } ).array();
		//var updateVars = targetCnx.request("SELECT DISTINCT id as session_id FROM Session WHERE id = 1 ").results().map(function(v) { return v.session_id; } ).array();
		#if Release
		var maxTimeStamp = targetCnx.request("SELECT timestamp as tmp FROM SyncMap ORDER BY timestamp DESC LIMIT 1").results().first().tmp;
		#else
		var maxTimeStamp = Date.now().getTime();
		#end
		
		
		var famFields = Familia.manager.dbInfos().fields.map(function(v) { return v.name; } );
		
		for (id in updateVars)
		{
			trace("Processing sess id = " + Std.string(id));
			var s = targetCnx.request("SELECT * FROM Session WHERE id = " + Std.string(id)).results().first(); 
			
			var new_sess = new Session();
			var fields = Reflect.fields(s);
			
			for (f in fields)
			{
				switch(f)
				{
					case "id":
						new_sess.old_session_id = s.id;
					case "user_id":
						new_sess.user_id = s.user_id;
					case "tentativa_id":
						new_sess.tentativa_id = s.tentativa_id;
					case "lastPageVisited":
						new_sess.lastPageVisited = s.lastPageVisited;
					case "isValid":
						new_sess.isValid = (s.isValid == 1);
					case "isRestored":
						new_sess.isRestored =  (s.isRestored == 1);
					case "date_create":
						new_sess.date_create = s.date_create;
					case "date_finished":
						new_sess.date_finished = s.date_finished;
					case "client_ip", "location", "ponto":
						continue;
					default:
						//TODO:Warn
						continue;
				}
				
			}
			new_sess.syncTimestamp = maxTimeStamp;
			
			var old_sess = Session.manager.unsafeObject("SELECT * FROM Session WHERE old_session_id = " + Std.string(id) + " ORDER BY syncTimestamp DESC LIMIT 1", false);
			var shouldInsert = false;
			for (f1 in Session.manager.dbInfos().fields)
			{
				var f = f1.name;
				if (f != "id" && f != "syncTimestamp" && Std.string(Reflect.field(old_sess, f)) != Std.string(Reflect.field(new_sess, f)))
				{
					shouldInsert = true;
					//trace(f);
				}
			}
			
			if (shouldInsert)
			{
				try{
					new_sess.insert();
				}
				catch (e : Dynamic)
				{
					trace(e);
					continue;
				}
			}
			else
				new_sess = old_sess;
			
			
			
			var familias = targetCnx.request("SELECT * FROM Familia WHERE session_id = " + Std.string(id)).results();
			for (f in familias)
			{
				var new_familia = new Familia();
				//trace("processing fam " + Std.string(f.id));
				for (field in Reflect.fields(f))
				{
					switch(field)
					{
						case "id":
							new_familia.old_id = f.id;
						case "session_id":
							new_familia.old_session_id = id;
							new_familia.session_id = new_sess.id;
						case "date":
							new_familia.date = f.date;
						case "isDeleted":
							new_familia.isDeleted = (f.isDeleted == 1);
						case "isEdited":
							new_familia.isEdited = f.isEdited;
						case "numeroResidentes":
							new_familia.numeroResidentes = f.numeroResidentes;
						case "ocupacaoDomicilio_id":
							if(Macros.checkEnumValue(OcupacaoDomicilio, f.ocupacaoDomicilio_id))
								new_familia.ocupacaoDomicilio =  Macros.getStaticEnum(OcupacaoDomicilio, f.ocupacaoDomicilio_id);
						case "condicaoMoradia_id":
							if(Macros.checkEnumValue(CondicaoMoradia, f.condicaoMoradia_id))
								new_familia.condicaoMoradia = Macros.getStaticEnum(CondicaoMoradia, f.condicaoMoradia_id);
						case "tipoImovel_id":
							if(Macros.checkEnumValue(TipoImovel, f.tipoImovel_id))
								new_familia.tipoImovel = Macros.getStaticEnum(TipoImovel, f.tipoImovel_id);
						//TODO: Perguntar pro Anderson WTH is going on nesse campo (existe em session)
						case "tentativa_id":
							new_familia.tentativa_id = f.tentativa_id;
						case "banheiros":
							new_familia.banheiros = f.banheiros;
						case "quartos":
							new_familia.quartos = f.quartos;
						case "veiculos":
							new_familia.veiculos = f.veiculos;
						case "bicicletas":
							new_familia.bicicletas = f.bicicletas;
						case "motos":
							new_familia.motos = f.motos;
						case "aguaEncanada_id":
							if(Macros.checkEnumValue(AguaEncanada, f.aguaEncanada_id))
								new_familia.aguaEncanada =  Macros.getStaticEnum(AguaEncanada, f.aguaEncanada_id);
						case "ruaPavimentada_id":
							new_familia.ruaPavimentada_id = (f.ruaPavimentada_id == 1);
						case "vagaPropriaEstacionamento_id":
							new_familia.vagaPropriaEstacionamento_id = (f.vagaPropriaEstacionamento_id == 3) ? null : (f.vagaPropriaEstacionamento_id == 1);
						case "anoVeiculoMaisRecente_id":
							if(Macros.checkEnumValue(AnoVeiculo, f.anoVeiculoMaisRecente_id))
								new_familia.anoVeiculoMaisRecente = Macros.getStaticEnum(AnoVeiculo, f.anoVeiculoMaisRecente_id);
						case "empregadosDomesticos_id":
							if(Macros.checkEnumValue(Empregado, f.empregadosDomesticos_id))
								new_familia.empregadosDomesticos = Macros.getStaticEnum(Empregado, f.empregadosDomesticos_id);
						case "tvCabo_id":
							new_familia.tvCabo = (f.tvCabo_id != 3) ? (f.tvCabo == 1) : null;
						case "editedNumeroResidentes":
							new_familia.editedNumeroResidentes = f.editedNumeroResidentes;
						case "editsNumeroResidentes":
							new_familia.editsNumeroResidentes = f.editsNumeroResidentes;
						case "nomeContato":
							new_familia.nomeContato = f.nomeContato;
						case "telefoneContato":
							new_familia.telefoneContato = f.telefoneContato;
						case "rendaDomiciliar_id":
							if(Macros.checkEnumValue(Renda, f.rendaDomiciliar_id))
								new_familia.rendaDomiciliar = Macros.getStaticEnum(Renda, f.rendaDomiciliar_id);
						case "recebeBolsaFamilia_id":
							new_familia.recebeBolsaFamilia = (f.recebeBolsaFamilia_id == 1);
						case "codigoReagendamento":
							new_familia.codigoReagendamento = f.codigoReagendamento;
						case "gps_id":
							continue;
						default:
							trace(field);
							//TODO:Warn something
							
					}
				}
				new_familia.syncTimestamp = maxTimeStamp;
				shouldInsert = false;
				var old_familia = Familia.manager.unsafeObject("SELECT * FROM Familia WHERE old_id = " + f.id + " AND old_session_id = " + id + " ORDER BY syncTimestamp DESC LIMIT 1", false);
				for (f1 in Familia.manager.dbInfos().fields)
				{
					var f = f1.name;
					if (f != "syncTimestamp" && f != "id" && Std.string(Reflect.field(new_familia, f)) != Std.string(Reflect.field(old_familia, f)))
					{
						shouldInsert = true;
					}
				}
				if (shouldInsert)
					new_familia.insert();
				else
					new_familia = old_familia;
					
				
				var moradores = targetCnx.request("SELECT * FROM Morador WHERE session_id = " + id + " AND familia_id = " + new_familia.old_id).results();
				for (m in moradores)
				{
					//trace("processing morador m "  + Std.string(m.id));
					var new_morador = new Morador();
					for (f in Reflect.fields(m))
					{
						switch(f)
						{
							case "id":
								new_morador.old_id = m.id;
							case "session_id":
								new_morador.old_session_id = id;
								new_morador.session_id = new_sess.id;
							case "familia_id":
								new_morador.familia_id = new_familia.id;
							case "date":
								new_morador.date = m.date;
							case "isDeleted":
								new_morador.isDeleted = (m.isDeleted == 1);
							case "isEdited":
								new_morador.isEdited = m.isEdited;
							case "nomeMorador":
								new_morador.nomeMorador = m.nomeMorador;
							case "proprioMorador_id":
								new_morador.proprioMorador_id = (m.proprioMorador_id == 2);
							case "idade_id":
								Macros.checkEnumValue(Idade, m.idade_id);
								new_morador.idade = Macros.getStaticEnum(Idade, m.idade_id);
							case "genero_id":
								new_morador.genero_id = m.genero_id;
							case "grauInstrucao_id":
								Macros.checkEnumValue(GrauInstrucao, m.grauInstrucao_id);
								new_morador.grauInstrucao = Macros.getStaticEnum(GrauInstrucao, m.grauInstrucao_id);
							case "codigoReagendamento":
								new_morador.codigoReagendamento = m.codigoReagendamento;
							case "quemResponde_id":
								new_morador.quemResponde_id = m.quemResponde_id;
							case "situacaoFamiliar_id":
								Macros.checkEnumValue(SituacaoFamiliar, m.situacaoFamiliar_id);
								new_morador.situacaoFamiliar = Macros.getStaticEnum(SituacaoFamiliar, m.situacaoFamiliar_id);
							case "atividadeMorador_id":
								Macros.checkEnumValue(AtividadeMorador, m.atividadeMorador_id);
								new_morador.atividadeMorador = Macros.getStaticEnum(AtividadeMorador, m.atividadeMorador_id);
							case "possuiHabilitacao_id":
								new_morador.possuiHabilitacao_id = (m.possuiHabilitacao != null) ? (m.possuiHabilitacao == 1) : null;
							case "portadorNecessidadesEspeciais_id":
								Macros.checkEnumValue(PortadorNecessidadesEspeciais, m.portadorNecessidadesEspeciais);
								new_morador.portadorNecessidadesEspeciais = Macros.getStaticEnum(PortadorNecessidadesEspeciais, m.portadorNecessidadesEspeciais_id);
							case "motivoSemViagem_id":
								Macros.checkEnumValue(MotivoSemViagem, m.motivoSemViagem_id);
								new_morador.motivoSemViagem = Macros.getStaticEnum(MotivoSemViagem, m.motivoSemViagem_id);
							case "gps_id":
								continue;
							default:
								trace(f);
								//TODO: Warn smthing
						}
					}
					
					new_morador.syncTimestamp = maxTimeStamp;
					
					shouldInsert = false;
					var old_morador = Morador.manager.unsafeObject("SELECT * FROM Morador WHERE old_id = " + m.id + " AND old_session_id = "+id+ " ORDER BY syncTimestamp DESC LIMIT 1", false);
					for (f1 in Morador.manager.dbInfos().fields)
					{
						var f = f1.name;
						if (f != "syncTimestamp" && f != "id" && Std.string(Reflect.field(new_morador, f)) != Std.string(Reflect.field(old_morador, f)))
						{
							shouldInsert = true;
						}
					}
					
					if (shouldInsert)
						new_morador.insert();
					else
						new_morador = old_morador;
				
				
				//Convertido para array para pegar points[i-1]
				var points = targetCnx.request("SELECT * FROM Ponto WHERE session_id = " + id + " AND morador_id = " + new_morador.old_id + " ORDER BY anterior_id").results();
				
				var pointMap = new Map<Int, Ponto>();
				for(p in points)
				{
					var new_point = new Ponto();
					for (f in Reflect.fields(p))
					{
						switch(f)
						{
							case "id":
								new_point.old_id = p.id;
							case "session_id":
								new_point.old_session_id = id;
								new_point.session_id = new_sess.id;
							case "morador_id":
								new_point.morador_id = new_morador.id;
							case "date":
								new_point.date = p.date;
							case "isEdited":
								new_point.isEdited = p.isEdited;
							case "isDeleted":
								new_point.isDeleted = (p.isDeleted == 1);
							case "uf_id":
								new_point.uf_id = p.uf_id;
							case "city_id":
								new_point.city_id = p.city_id;
							case "regadm_id":
								new_point.regadm_id = p.regadm_id;
							case "street_id":
								new_point.street_id = p.street_id;
							case "complement_id":
								new_point.complement_id = p.complement_id;
							case "complement_two_id":
								new_point.complement_two_id = p.complement_two_id;
							case "complement2_str":
								new_point.complement2_str = p.complement2_str;
							case "ref_id":
								new_point.ref_id = p.ref_id;
							case "motivoID":
								Macros.checkEnumValue(Motivo, m.motivoID);
								new_point.motivo = Macros.getStaticEnum(Motivo, m.motivoID);
							case "motivoOutraPessoaID":
								Macros.checkEnumValue(Motivo, m.motivoOutraPessoaID);
								new_point.motivoOutraPessoa = Macros.getStaticEnum(Motivo, m.motivoOutraPessoaID);
							case "tempo_saida":
								new_point.tempo_saida = p.tempo_saida;
							case "tempo_chegada":
								new_point.tempo_chegada = p.tempo_chegada;
							case "ref_str":
								new_point.ref_str = p.ref_str;
							case "copiedFrom_id":
								new_point.copiedFrom_id = p.copiedFrom_id;
							case "gps_id", "anterior_id", "posterior_id", "ordem", "city_str", "regadm_str", "street_str", "complement_str", "complement_two_str":
								continue;
							default:
								//trace(f);
								//TODO:Throw smthing
							
						}
					}
					new_point.syncTimestamp = maxTimeStamp;
					var old_point = Ponto.manager.unsafeObject("SELECT * FROM Ponto WHERE old_id = " + p.id + " ORDER BY syncTimestamp DESC LIMIT 1 ", false);
					shouldInsert = false;
					for (f1 in Ponto.manager.dbInfos().fields)
					{
						var f = f1.name;
						if (f != "session_id" && f != "id" && f != "syncTimestamp" && Std.string(Reflect.field(new_point, f)) != Std.string(Reflect.field(old_point, f)))
						{
							shouldInsert = true;						
						}
					}
					
					if (shouldInsert)
						new_point.insert();
					else
						new_point = old_point;
					pointMap.set(new_point.old_id, new_point);
					
					//TODO: Implementar checks (não são intuitivos se considerar entradas isDeleted)
					var modos = targetCnx.request("Select * FROM Modo WHERE morador_id = " +new_morador.old_id + " AND firstpoint_id = " +new_point.old_id + " ORDER BY anterior_id").results();
					for (mo in modos)
					{
						var new_modo = new Modo();
						for (f in Reflect.fields(mo))
						{
							switch(f)
							{
								case "id":
									new_modo.old_id = mo.id;
								case "session_id":
									new_modo.old_session_id = mo.session_id;
									new_modo.session_id = new_sess.id;
								case "morador_id":
									new_modo.old_morador_id = mo.morador_id;
									new_modo.morador_id = new_morador.id;
								case "date":
									new_modo.date = mo.date;
								case "isDeleted":
									new_modo.isDeleted = (mo.isDeleted == 1);
								case "isEdited":
									new_modo.isEdited = mo.isEdited;
								case "meiotransporte_id":
									Macros.checkEnumValue(MeioTransporte, mo.meiotransporte_id);
									new_modo.meiotransporte = Macros.getStaticEnum(MeioTransporte, mo.meiotransporte_id);
								case "linhaOnibus_id":
									new_modo.linhaOnibus_id = mo.linhaOnibus_id;
								case "estacaoEmbarque_id":
									new_modo.estacaoEmbarque_id = mo.estacaoEmbarque_id;
								case "estacaoDesembarque_id":
									new_modo.estacaoDesembarque_id = mo.estacaoDesembarque_id;
								case "formaPagamento_id":
									if(Macros.checkEnumValue(FormaPagamento, mo.formaPagamento_id))
									new_modo.formaPagamento = Macros.getStaticEnum(FormaPagamento, mo.formaPagamento_id);
								case "tipoEstacionamento_id":
									Macros.checkEnumValue(TipoEstacionamento, mo.tipoEstacionamento_id);
									new_modo.tipoEstacionamento = Macros.getStaticEnum(TipoEstacionamento, mo.tipoEstacionamento_id);
								case "firstpoint_id":
									new_modo.firstpoint_id = mo.firstpoint_id;
								case "secondpoint_id":
									new_modo.secondpoint_id = mo.secondpoint_id;
								case "valorPagoTaxi", "valorViagem", "custoEstacionamento":
									new_modo.valorViagem = mo.valorViagem;
								case "naoSabeLinhaOnibus", "naoSabeEstacaoEmbarque", "naoSabeEstacaoDesembarque", "naoSabeValorViagem", "naoSabeValorPagoTaxi", "naoSabeCustoEstacionamento":
									new_modo.naoSabe = (new_modo.naoSabe) ? true : (Reflect.field(mo, f) != 0);
								case "naoRespondeuLinhaOnibus", "naoRespondeuEstacaoEmbarque", "naoRespondeuEstacaoDesembarque", "naoRespondeuValorViagem", "naoRespondeuValorPagoTaxi","naoRespondeuCustoEstacionamento":
									new_modo.naoRespondeu = (new_modo.naoRespondeu) ? true : (Reflect.field(mo, f) != 0);
								case "anterior_id", "posterior_id", "gps_id", "linhaOnibus_str","estacaoEmbarque_str", "estacaoDesembarque_str":
									continue;
								default:
									//trace(f);
									//TODO: Throw smthing
							}
						}
						new_modo.syncTimestamp = maxTimeStamp;
						
						shouldInsert = false;
						var oldmodo = Modo.manager.unsafeObject("SELECT * FROM Modo WHERE old_id = " + new_modo.old_id + " ORDER BY syncTimeStamp DESC LIMIT 1", false);
						for (f1 in  Modo.manager.dbInfos().fields)
						{
							var f = f1.name;
							if (f != "id" && f != "syncTimestamp" && Std.string(Reflect.field(new_modo, f)) != Std.string(Reflect.field(oldmodo, f)))
							{
								shouldInsert = true;							
							}
						}
						if (shouldInsert)
							new_modo.insert();
						else
							new_modo = oldmodo;
					}
					
					
				}
				
				}
			}
			Manager.cleanup();
		}
		
		var req = targetCnx.request("SELECT s.id FROM SyncMap sm JOIN Session s ON sm.tbl = 'Session' and new_id = s.id AND user_id IS NULL /*AND syncTimestamp > x*/").results();
		for (r in req)
		{
			//TODO: Warn smthing
		}
		
		req = targetCnx.request("SELECT f.id FROM SyncMap sm JOIN Familia f ON sm.tbl = 'Familia' AND new_id = f.id AND f.session_id IS NULL /*AND syncTimestamp > x*/").results();
		for(r in req)
		{
			//TODO: Warn smthing
		}
		
		req = targetCnx.request("SELECT p.id FROM SyncMap sm JOIN Ponto p ON sm.tbl = 'Ponto' AND new_id = p.id AND p.session_id IS NULL /* AND syncTimestamp > x */").results();
		for (r in req)
		{
			//Same TODO
		}
		req = targetCnx.request("SELECT m.id FROM SyncMap sm JOIN Modo m ON sm.tbl = 'Modo' AND new_id = m.id AND m.session_id IS NULL /* AND sm.syncTimestamp > x */").results();
		for (r in req)
		{
			//Same TODO
		}
		
		Manager.cnx.commit();
		Manager.cnx.close();
		targetCnx.close();
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