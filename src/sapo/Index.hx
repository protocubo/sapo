package sapo;

import haxe.web.Dispatch;
import neko.Web;
import sapo.Spod;
import sys.db.*;

class Index {
	static inline var DBPATH = ".sapo.db3";

	public static function dbReset()
	{
		Manager.cleanup();
		Manager.cnx.close();
		Manager.cnx = null;
		sys.FileSystem.deleteFile(Index.DBPATH);
		dbInit();

		var arthur = new User("arthur@sapo", "Arthur Dent");
		var ford = new User("ford@sapo", "Ford Prefect");
		arthur.insert();
		ford.insert();

		var survey1 = new Survey(ford, "Arthur's house");
		var survey2 = new Survey(arthur, "Betelgeuse, or somewhere near that planet");
		survey1.insert();
		survey2.insert();

		var ticket1 = new Ticket(survey1, arthur);
		ticket1.insert();
		new TicketMessage(ticket1, arthur, "Hey, I was distrought over they wanting to build an overpass over my house").insert();
		var ticket2 = new Ticket(survey2, ford);
		ticket2.insert();
		new TicketMessage(ticket2, ford, "Don't panic!").insert();
	}

	static function dbInit()
	{
		Manager.initialize();
		Manager.cnx = Sqlite.open(DBPATH);
		Manager.cnx.request("PRAGMA page_size=4096");
		// later windows can't close the connection in wal mode...
		// an issue with sqlite.ndll perhaps?
		if (Sys.systemName() != "Windows") Manager.cnx.request("PRAGMA journal_mode=wal");
		var managers:Array<Manager<Dynamic>> = [User.manager, Survey.manager, Ticket.manager, TicketMessage.manager];
		for (m in managers)
			if (!TableCreate.exists(m))
				TableCreate.create(m);
	}

	static function main()
	{
		try {
			dbInit();

			var uri = Web.getURI();
			var params = Web.getParams();
			if (uri == "/favicon.ico") return;

			var d = new Dispatch(uri, params);
			d.dispatch(new Routes());
			Manager.cnx.close();
			Manager.cnx = null;
		} catch (e:Dynamic) {
			if (Manager.cnx != null)
				Manager.cnx.close();
			Manager.cnx = null;
			neko.Lib.rethrow(e);
		}
	}
}

