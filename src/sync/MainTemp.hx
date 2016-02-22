package sync;
import common.spod.EnumSPOD;
import common.spod.Familia;
import common.spod.Morador;
import common.spod.Session;
import haxe.Http;
import haxe.Json;
import haxe.Log;
import haxe.PosInfos;
import common.spod.InitDB;

import sys.db.Connection;
import sys.db.Manager;
import sys.db.Mysql;
import sys.db.Types.SFloat;
import sys.FileSystem;
import sys.io.File;
import common.stringTools.Tools;

/**
 * ...
 * @author Caio
 */
using Lambda;
class MainTemp
{

	static var targetCnx : Connection;
	
	static var maxtimestamp : SFloat;
	
	static var sessHash : Map<Int, Session>;
	static var famHash : Map<Int, Familia>;
	static var morHash : Map<Int, Morador>;
	
	public static function main()
	{
		Log.trace = function(txt : Dynamic, ?infos : PosInfos)
		{
			var v = File.append("Log.txt");
			v.writeString(txt + '\n');
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
		
		#if Debug
		var serverTimestamp = Date.now();
		#else
		var serverTimestamp = serverTimestamp();
		#end
		
		//Todos os valores de enums -> usa as keys "EnumName" e "Old_val" => "New_val" para conversão das entradas originais para as novas
		//A estrutura é Map<String,Map<Int,Int>>
		var refValues = populateHash();
		
		// Query -> ../../extras/main.sql
		//Session_id only 
		var updateVars = targetCnx.request("SELECT DISTINCT session_id FROM ((SELECT ep.session_id as session_id FROM SyncMap sm join EnderecoProp ep ON sm.tbl = 'EnderecoProp' AND sm.new_id = ep.id /*AND sm.timestamp > x*/) UNION ALL (SELECT  s.id as session_id FROM SyncMap sm JOIN Session s ON sm.tbl = 'Session' AND sm.new_id = s.id /*AND sm.timestamp > x*/) UNION ALL ( select f.session_id as session_id FROM SyncMap sm JOIN Familia f ON f.id = sm.new_id AND sm.tbl = 'Familia'  /*AND sm.timestamp > x*/) UNION ALL (select  m.session_id as session_id FROM SyncMap sm JOIN Morador m ON m.id = sm.new_id AND sm.tbl = 'Morador'  /*AND sm.timestamp > x*/) UNION ( select  p.session_id as session_id FROM SyncMap sm JOIN Ponto p ON  sm.tbl = 'Ponto' AND p.id = sm.new_id  /*AND sm.timestamp > x*/) UNION ALL (select m.session_id as session_id FROM SyncMap sm JOIN Modo m ON m.id = sm.new_id AND sm.tbl = 'Modo'  /*AND sm.timestamp > x*/)	) ack WHERE session_id IS NOT NULL ORDER BY session_id ASC").results().map(function(v) { return v.session_id; } ).array();
		
		#if Debug
		var maxTimestamp = Date.now().getTime();
		#else
		var maxTimestamp = targetCnx.request("SELECT timestamp as tmp FROM SyncMap ORDER BY timestamp DESC LIMIT 1").results().first().tmp;
		#end
		
		//Hash old_id -> new instance
		sessHash = new Map<Int, Session>();
		famHash = new Map<Int, Familia>();
		morHash = new Map<Int, Morador>();
		
		for (u in updateVars)
		{
			processSession(u);
			
		}
	}
	
	static function processSession(sid : Int)
	{
		var dbSession = targetCnx.request("SELECT * FROM Session WHERE id = " + sid).results().first();
		
		var new_sess = new Session();
		for (f in Reflect.fields(dbSession))
		{
			switch(f)
			{
				case "id":
					new_sess.old_session_id = dbSession.id;
				//Conversao de bool (hoorray)
				case "isValid", "isRestored":
					Reflect.setField(new_sess, f, (Reflect.field(dbSession, f) == 1));
				//Copia simples de campo
				case "user_id", "tentativa_id", "lastPageVisited", "date_create", "date_finished":
					Reflect.setField(new_sess, f, Reflect.field(dbSession, f));
				case "client_ip", "location", "ponto":
					continue;
				default:
					Macros.warnTable("Session", f, null);
			}
		}
		
		new_sess.syncTimestamp = maxtimestamp;
		
		Macros.validateEntry(Session, ["syncTimestamp", "id"], [ { key : "old_session_id", value : new_sess.old_session_id } ], new_sess);
		sessHash.set(new_sess.old_session_id, new_sess);
	}
	
	static function processFamilia(old_sid : Int, new_sid : Int)
	{
		var dbFam = targetCnx.request("SELECT * FROM Familia WHERE session_id = " + old_sid).results();
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
						new_familia.session = sessHash.get(f.session_id);
						new_familia.old_session_id = f.session_id;
					//Fields ctrl+c ctrl+v
					case "date", "numeroResidentes", "banheiros", "quartos", "veiculos", "bicicletas", "motos", "editedNumeroResidentes", "editsNumeroResidentes", "nomeContato", "telefoneContato", "codigoReagendamento":
						Reflect.setField(new_familia, field, Reflect.field(f, field));
					//Bool simples
					case "isDeleted","ruaPavimentada_id", "recebeBolsaFamilia_id":
						Reflect.setField(new_familia, field, Reflect.field(f, field) == 1);
					//Conversao enum -> bool
					case "tvCabo_id","vagaPropriaEstacionamento_id":
						var v = Reflect.field(f, field);
						Reflect.setField(new_familia, field, (v != 3) ? (v == 1) : null);
					case "gps_id":
						continue;
					default:
						Macros.warnTable(Familia, field, Reflect.field(f, field));					
				}
			}
		}
	}
	
	
	static function populateHash() : Map<String,Map<Int,Int>>
	{
		var t = new Map<String,Map<Int,Int>>();
		for (c in CompileTime.getAllClasses("common.db", false, EnumTable))
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