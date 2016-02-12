package;

import db.Familia;
import db.Morador;
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
		if (!FileSystem.exists("/private/cnxstring"))
		{
			trace("No cnxstring file!");
			return;
		}
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
		
		
		
		var cnxstring = Json.parse(File.getContent("/private/cnxstring"));
		//TODO: Implementar cnxstring do nosso server!
		Manager.cnx = Sqlite.open("db.db3");
		
		var targetCnx = Mysql.connect(Reflect.field(cnxstring, "DFTTPODD"));
		
		targetCnx.request("SET AUTOCOMMIT = 0");
		targetCnx.request("START TRANSACTION");
		
		// Query -> ../../extras/main.sql
		//Session_id only 
		var updateVars = targetCnx.request("SELECT DISTINCT session_id FROM ((SELECT ep.session_id as session_id FROM SyncMap sm join EnderecoProp ep ON sm.tbl = 'EnderecoProp' AND sm.new_id = ep.id /*AND sm.timestamp > x*/) UNION ALL (SELECT  s.id as session_id FROM SyncMap sm JOIN Session s ON sm.tbl = 'Session' AND sm.new_id = s.id /*AND sm.timestamp > x*/) UNION ALL ( select f.session_id as session_id FROM SyncMap sm JOIN Familia f ON f.id = sm.new_id AND sm.tbl = 'Familia'  /*AND sm.timestamp > x*/) UNION ALL (select  m.session_id as session_id FROM SyncMap sm JOIN Morador m ON m.id = sm.new_id AND sm.tbl = 'Morador'  /*AND sm.timestamp > x*/) UNION ( select  p.session_id as session_id FROM SyncMap sm JOIN Ponto p ON  sm.tbl = 'Ponto' AND p.id = sm.new_id  /*AND sm.timestamp > x*/) UNION ALL (select m.session_id as session_id FROM SyncMap sm JOIN Modo m ON m.id = sm.new_id AND sm.tbl = 'Modo'  /*AND sm.timestamp > x*/)	)").results().map(function(v) { return v.session_id; } ).array();
		var maxTimeStamp = targetCnx.request("SELECT timestamp as tmp FROM SyncMap ORDER BY timestamp DESC LIMIT 1").results().first().tmp;
		
		//var sess = targetCnx.request("SELECT * FROM Session WHERE id IN (" + updateVars.join(',') + ")").results();
		for (id in updateVars)
		{
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
				if(Reflect.hasField(new_sess, f))
					Reflect.setField(new_sess, f, Reflect.field(s, f));
			}
			new_sess.syncTimestamp = maxTimeStamp;
			
			var old_sess = Session.manager.unsafeObject("SELECT * FROM Session WHERE old_session_id = " + id + " ORDER BY syncTimestamp DESC LIMIT 1", false);
			var shouldInsert = false;
			for (f1 in Session.manager.dbInfos().fields)
			{
				var f = f1.name;
				if(f != "id" && f != "syncTimestamp" && Reflect.field(old_sess, f) != Reflect.field(new_sess, f))
					shouldInsert = true;
			}
			
			if(shouldInsert)
				new_sess.insert();
			else
				new_sess = old_sess;
			
			
			var new_familia = new Familia();
			var familias = targetCnx.request("SELECT * FROM Familia WHERE session_id = " + id).results();
			for (f in familias)
			{
				for (field in Reflect.fields(f))
				{
					if (field == "id")
					{
						new_familia.old_id = f.id;
						continue;
					}
					if (field == "session_id")
					{
						new_familia.session_id = new_sess.id;
						new_familia.old_session_id = f.session_id;
						continue;
					}
					
					if (Reflect.hasField(new_familia, field))
						Reflect.setField(new_familia, field, Reflect.field(f, field));					
				}
				new_familia.syncTimestamp = maxTimeStamp;
				shouldInsert = false;
				var old_familia = Familia.manager.unsafeObject("SELECT * FROM Familia WHERE old_id = " + f.id + " ORDER BY syncTimestamp DESC LIMIT 1", false);
				for (f1 in Familia.manager.dbInfos().fields)
				{
					var f = f1.name;
					if (f != "syncTimestamp" && f != "id" && Reflect.field(new_familia, f) != Reflect.field(old_familia, f))
						shouldInsert = true;
				}
				if (shouldInsert)
					new_familia.insert();
				else
					new_familia = old_familia;
					
					
				var new_morador = new Morador();
				var moradores = targetCnx.request("SELECT * FROM Moradores WHERE session_id = " + id).results();
				for (m in moradores)
				{
					for (f1 in Morador.manager.dbInfos().fields)
					{
						var f = f1.name;
						if (f == "id")
						{
							new_morador.old_id = m.id;
							continue;
						}
						if (f == "session_id")
						{
							new_morador.old_session_id = m.session_id;
							continue;
						}
						if (f != "syncTimestamp" && f != "old_id" && f != "old_session_id")
						{
							Reflect.setField(new_morador, f, Reflect.field(m, f));
						}
					}
					
					new_morador.syncTimestamp = maxTimeStamp;
					
					shouldInsert = false;
					var old_morador = Morador.manager.unsafeObject("SELECT * FROM Morador WHERE old_id = " + m.id + " ORDER BY syncTimestamp DESC LIMIT 1", false);
					for (f1 in Morador.manager.dbInfos().fields)
					{
						var f = f1.name;
						if (f != "syncTimestamp" && f != "old_id" && Reflect.field(new_morador, f) != Reflect.field(old_morador, f))
							shouldInsert = true;
					}
					
					if (shouldInsert)
						new_morador.insert();
					else
						new_morador = old_morador;
				}
				
				//TODO : Continuar no PTO
				
			}			
		}
	}
}