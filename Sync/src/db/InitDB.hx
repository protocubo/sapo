package db;
import haxe.Json;
import sys.db.Connection;
import sys.db.Manager;
import sys.db.Mysql;
import sys.db.Sqlite;
import sys.db.TableCreate;
import sys.io.File;

/**
 * ...
 * @author Caio
 */
class InitDB
{
	//TODO: Unpog
	public static var targetCnx : Connection;
	public static function run()
	{
		
		Manager.initialize();
		var cnxstring = Json.parse(File.getContent("./private/cnxstring"));
		//TODO: Implementar cnxstring do nosso server!
		Manager.cnx = Sqlite.open("db.db3");
		Manager.cnx.request("PRAGMA journal_mode=WAL");
		Manager.cnx.request("PRAGMA page_size = 4096");
		trace(cnxstring);
		targetCnx = Mysql.connect(Reflect.field(cnxstring, "DFTTPODD"));
		
		targetCnx.request("SET AUTOCOMMIT = 0");
		targetCnx.request("START TRANSACTION");
		
		
		if (!TableCreate.exists(Modo.manager))
		{
			TableCreate.create(Familia.manager);
			TableCreate.create(Modo.manager);
			TableCreate.create(Morador.manager);
			TableCreate.create(Ponto.manager);
			TableCreate.create(Session.manager);
		}
	}
}