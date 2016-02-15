package;

import db.Familia;
import db.InitDB;
import db.Modo;
import db.Morador;
import db.Ponto;
import db.Session;
import haxe.Http;
import haxe.Json;
import haxe.remoting.HttpConnection;
import neko.Lib;
import sys.db.Manager;
import sys.db.Mysql;
import sys.db.Sqlite;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author Caio
 */

 using Lambda;
class Main 
{
	
	static function main() 
	{
		if (!FileSystem.exists("./private/cnxstring"))
		{
			trace("No cnxstring file!");
			return;
		}
		/*var http = new Http("syncex.comtacti.com");
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
		*/
		
		InitDB.run();
		Manager.cnx.startTransaction();
		var targetCnx = InitDB.targetCnx;
		// Query -> ../../extras/main.sql
		//Session_id only 
		var updateVars = targetCnx.request("SELECT DISTINCT session_id FROM ((SELECT ep.session_id as session_id FROM SyncMap sm join EnderecoProp ep ON sm.tbl = 'EnderecoProp' AND sm.new_id = ep.id /*AND sm.timestamp > x*/) UNION ALL (SELECT  s.id as session_id FROM SyncMap sm JOIN Session s ON sm.tbl = 'Session' AND sm.new_id = s.id /*AND sm.timestamp > x*/) UNION ALL ( select f.session_id as session_id FROM SyncMap sm JOIN Familia f ON f.id = sm.new_id AND sm.tbl = 'Familia'  /*AND sm.timestamp > x*/) UNION ALL (select  m.session_id as session_id FROM SyncMap sm JOIN Morador m ON m.id = sm.new_id AND sm.tbl = 'Morador'  /*AND sm.timestamp > x*/) UNION ( select  p.session_id as session_id FROM SyncMap sm JOIN Ponto p ON  sm.tbl = 'Ponto' AND p.id = sm.new_id  /*AND sm.timestamp > x*/) UNION ALL (select m.session_id as session_id FROM SyncMap sm JOIN Modo m ON m.id = sm.new_id AND sm.tbl = 'Modo'  /*AND sm.timestamp > x*/)	) ack ORDER BY session_id ASC").results().map(function(v) { return v.session_id; } ).array();
		//var updateVars = targetCnx.request("SELECT DISTINCT id as session_id FROM Session WHERE id = 1 ").results().map(function(v) { return v.session_id; } ).array();
		#if Release
		var maxTimeStamp = targetCnx.request("SELECT timestamp as tmp FROM SyncMap ORDER BY timestamp DESC LIMIT 1").results().first().tmp;
		#else
		var maxTimeStamp = Date.now().getTime();
		#end
		//Cant reflect my fields - TODO: Corrigir isso
		var sessHash = new Map<String, String>();
		for (name in Session.manager.dbInfos().fields.map(function(v) { return v.name; } ))
			sessHash.set(name, name);
		
		var famHash = new Map<String, String>();
		for (name in Familia.manager.dbInfos().fields.map(function(v) { return v.name; } ))
			famHash.set(name, name);
		
		var morHash = new Map<String, String>();
		for (name in Morador.manager.dbInfos().fields.map(function(v) { return v.name; } ))
			morHash.set(name, name);
		
		var pontoHash = new Map<String,String>();
		for (name in Ponto.manager.dbInfos().fields.map(function(v) { return v.name; } ))
			pontoHash.set(name, name);
		
		var modoHash = new Map<String, String>();
		for (name in Modo.manager.dbInfos().fields.map(function(v) { return v.name; } ))
			modoHash.set(name, name);
		
		
		var famFields = Familia.manager.dbInfos().fields.map(function(v) { return v.name; } );
		
		for (id in updateVars)
		{
			trace("Processing sess id = " + id);
			var s = targetCnx.request("SELECT * FROM Session WHERE id = " + id).results().first(); 
			
			var new_sess = new Session();
			var fields = Reflect.fields(s);
			
			for (f in fields)
			{
				if (f == "id")
				{
					new_sess.old_session_id = Reflect.field(s, "id");
					continue;
				}
				
				if (sessHash.get(f) != null && sessHash.get(f) != "")
				{
					
					Reflect.setField(new_sess, f, Reflect.field(s, f));
				}
			}
			new_sess.syncTimestamp = maxTimeStamp;
			
			var old_sess = Session.manager.unsafeObject("SELECT * FROM Session WHERE old_session_id = " + id + " ORDER BY syncTimestamp DESC LIMIT 1", false);
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
			
			
			
			var familias = targetCnx.request("SELECT * FROM Familia WHERE session_id = " + id).results();
			for (f in familias)
			{
				var new_familia = new Familia();
				//trace("processing fam " + Std.string(f.id));
				for (field in Reflect.fields(f))
				{
					if (field == "id")
					{
						new_familia.old_id = f.id;
					}
					else if (field == "session_id")
					{
						new_familia.session_id = new_sess.id;
						new_familia.old_session_id = f.session_id;
					}
					else if (field == "isDeleted")
					{
						new_familia.isDeleted = (f.isDeleted == 1);
					}
					else if (famHash.get(field) != "" && famHash.get(field) != null)
						Reflect.setField(new_familia, field, Reflect.field(f, field));					
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
					var new_morador = new Morador();
					//trace("processing morador " + Std.string(m.id));
					for (f1 in Morador.manager.dbInfos().fields)
					{
						var f = f1.name;
						//trace(f);
						if (f == "id")
						{
							new_morador.old_id = m.id;
						}
						else if (f == "session_id")
						{
							new_morador.session_id = new_sess.id;
							new_morador.old_session_id = m.session_id;
						}
						else if (f == "isDeleted")
						{
							new_morador.isDeleted = (m.isDeleted == 1);
						}
						else if (f == "proprioMorador_id")
						{
							new_morador.proprioMorador_id = (m.proprioMorador_id == 1);
						}
						else if (f != "syncTimestamp" && f != "old_id" && f != "old_session_id" && f != "session_id" && f != "id")
						{
							Reflect.setField(new_morador, f, Reflect.field(m, f));
						}
					}
					//trace(new_morador.id);
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
				var points = targetCnx.request("SELECT * FROM Ponto WHERE session_id = " + id + " AND morador_id = " + new_morador.old_id + " ORDER BY anterior_id").results().array();
				var i = 0;
				while (i < points.length)
				{
					//trace("Processing point " + points[i].id);
					var ref = points[i];
					var new_point = new Ponto();
					for (f in Reflect.fields(ref))
					{
						if (f == "id")
							new_point.old_id = Reflect.field(ref, f);
						else if (f == "session_id")
						{
							new_point.session_id = new_sess.id;
							new_point.old_session_id = Reflect.field(ref, f);
						}
						else if (f == "morador_id")
							new_point.morador_id = new_morador.id;
						else if (f == "isDeleted")
							new_point.isDeleted = (points[i].isDeleted == 1)
						else if (pontoHash.get(f) != null && pontoHash.get(f) != "")
							Reflect.setField(new_point, f, Reflect.field(ref, f));	
					}
					new_point.syncTimestamp = maxTimeStamp;
					var old_point = Ponto.manager.unsafeObject("SELECT * FROM Ponto WHERE old_id = " + ref.id + " ORDER BY syncTimestamp DESC LIMIT 1 ", false);
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
					i++;
					/**/
					//TODO: Implementar checks (não são intuitivos se considerar entradas isDeleted)
					//if(shouldInsert && 
						
					var modos = targetCnx.request("Select * FROM Modo WHERE morador_id = " +new_morador.old_id + " AND firstpoint_id = " +new_point.old_id + " ORDER BY anterior_id").results();
					for (mo in modos)
					{
						//trace("processing modo " + Std.string(mo.id));
						var new_modo = new Modo();
						for (f in Reflect.fields(mo))
						{
							switch(f)
							{
								case "id":
									new_modo.old_id = mo.id;
								case "session_id":
									new_modo.old_session_id = mo.session_id;
								case "morador_id":
									new_modo.old_morador_id = mo.morador_id;
								case "date":
									new_modo.date = mo.date;
								case "isDeleted":
									new_modo.isDeleted = (mo.isDeleted == 1);
								case "isEdited":
									new_modo.isEdited = mo.isEdited;
								case "meiotransporte_id":
									new_modo.meiotransporte_id = mo.meiotransporte_id;
								case "linhaOnibus_id":
									new_modo.linhaOnibus_id = mo.linhaOnibus_id;
								case "estacaoEmbarque_id":
									new_modo.estacaoEmbarque_id = mo.estacaoEmbarque_id;
								case "estacaoDesembarque_id":
									new_modo.estacaoDesembarque_id = mo.estacaoDesembarque_id;
								case "formaPagamento_id":
									new_modo.formaPagamento_id = mo.formaPagamento_id;
								case "tipoEstacionamento_id":
									new_modo.tipoEstacionamento_id = mo.tipoEstacionamento_id;
								case "firstpoint_id":
									new_modo.firstpoint_id = mo.firstpoint_id;
								case "secondpoint_id":
									new_modo.secondpoint_id = mo.secondpoint_id;
								case "valorPagoTaxi", "valorViagem":
									new_modo.valorViagem = mo.valorViagem;
								case "naoSabeLinhaOnibus", "naoSabeEstacaoEmbarque", "naoSabeEstacaoDesembarque", "naoSabeValorViagem", "naoSabeValorPagoTaxi":
									new_modo.naoSabe = (new_modo.naoSabe) ? true : (Reflect.field(mo, f) != 0);
								case "naoRespondeuLinhaOnibus", "naoRespondeuEstacaoEmbarque", "naoRespondeuEstacaoDesembarque", "naoRespondeuValorViagem", "naoRespondeuValorPagoTaxi":
									new_modo.naoRespondeu = (new_modo.naoRespondeu) ? true : (Reflect.field(mo, f) != 0);
							}
						}
						
						new_modo.session_id = new_sess.id;
						new_modo.morador_id = new_morador.id;
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
		}
		Manager.cnx.commit();
	}
}