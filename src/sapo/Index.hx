package sapo;

import common.db.MoreTypes;
import common.spod.InitDB;
import haxe.PosInfos;
import haxe.web.Dispatch;
import neko.Web;
import sapo.Spod;
import sys.db.*;

class Index {
	static var DBPATH = Sys.getEnv("SAPO_DB");

	public static function dbReset()
	{
		Manager.cleanup();
		Manager.cnx.close();
		Manager.cnx = null;
		sys.FileSystem.deleteFile(DBPATH);
		InitDB.run();
		dbInit();

		Manager.cnx.request("BEGIN");
		try {
			var superGroup = new Group(new AccessName("super"), PSuper);
			superGroup.insert();

			var arthur = new User(new AccessName("arthur"), superGroup, "Arthur Dent", new EmailAddress("arthur@sapo"));
			var ford = new User(new AccessName("ford"), superGroup, "Ford Prefect", new EmailAddress("ford@sapo"));

			arthur.insert();
			ford.insert();

			var survey1 = new Survey(ford, "Arthur's house", 945634);
			var survey2 = new Survey(arthur, "Betelgeuse, or somewhere near that planet", 6352344);
			survey1.insert();
			survey2.insert();

			var ticket1 = new Ticket(survey1, arthur, "Overpass???");
			ticket1.insert();
			new TicketMessage(ticket1, arthur, ford, "Hey, I was distrought over they wanting to build an overpass over my house").insert();
			new TicketMessage(ticket1, ford, arthur, "Don't panic... don't panic...").insert();

			var ticket2 = new Ticket(survey2, ford, "About Time...");
			ticket2.insert();
			new TicketMessage(ticket2, ford, arthur, "Time is an illusion, lunchtime doubly so. ").insert();
			new TicketMessage(ticket2, arthur, ford, "Very deep. You should send that in to the Reader's Digest. They've got a page for people like you.").insert();
		} catch (e:Dynamic) {
			Manager.cnx.request("ROLLBACK");
			neko.Lib.rethrow(e);
		}
		Manager.cnx.request("COMMIT");
	}


	static function dbInit()
	{
		var managers:Array<Manager<Dynamic>> = [User.manager, Survey.manager, Ticket.manager, TicketMessage.manager, Group.manager];
		for (m in managers)
			if (!TableCreate.exists(m))
				TableCreate.create(m);
	}

	static function main()
	{
		haxe.Log.trace = function (msg, ?pos:haxe.PosInfos) {
			if (pos.customParams != null) msg += "\n{" + pos.customParams.join(" ") + "}";
			msg += '  @${pos.className}:${pos.methodName}  (${pos.fileName}:${pos.lineNumber})';
			Web.logMessage(msg);
		}

		try {
			InitDB.run();
			dbInit();
			var uri = Web.getURI();
			if (uri == "/favicon.ico") return;

			// treat visibly empty params as missing
			var params = Web.getParams();
			var cparams = [ for (k in params.keys()) if (StringTools.trim(params.get(k)).length > 0) k => params.get(k) ];
			var d = new Dispatch(uri, cparams);
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

