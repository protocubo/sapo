package sync.db;
import haxe.Json;
import sync.db.statics.Referencias;
import sync.db.statics.UF;
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
	
	
	public static function run()
	{
		
		Manager.initialize();
		
		//TODO: Implementar cnxstring do nosso server!
		Manager.cnx = Sqlite.open("db.db3");
		Manager.cnx.request("PRAGMA journal_mode=WAL");
		Manager.cnx.request("PRAGMA page_size = 4096");
		
		
		if (!TableCreate.exists(Modo.manager))
		{
			TableCreate.create(Familia.manager);
			TableCreate.create(Modo.manager);
			TableCreate.create(Morador.manager);
			TableCreate.create(Ponto.manager);
			TableCreate.create(Session.manager);
			
			/******/
			TableCreate.create(Referencias.manager);
			TableCreate.create(UF.manager);
			
			
		}
	}
}