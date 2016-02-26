package sapo;

import common.Web;
import common.crypto.Password;
import common.db.MoreTypes;
import common.spod.InitDB;
import sapo.Spod;
import sys.db.*;

class Context {
	static var DBPATH = Sys.getEnv("SAPO_DB");

	public static var loop:Context;

	public var now(default,null):HaxeTimestamp;
	public var session(default,null):Session;
	public var user(default,null):User;
	public var group(default,null):Group;
	public var privilege(default,null):Privilege;

	function new(now, session)
	{
		this.now = now;
		if (session != null)
		{
			this.session = session;
			this.user = session.user;
			this.group = session.user.group;
			this.privilege = session.user.group.privilege;
		}
	}

	static function dbInit()
	{
		var managers:Array<Manager<Dynamic>> = [
			Group.manager,
			NewSurvey.manager,
			Session.manager,
			Ticket.manager,
			TicketMessage.manager,
			User.manager
		];
		for (m in managers)
			if (!TableCreate.exists(m))
				TableCreate.create(m);
	}

	public static function resetMainDb()
	{
		Manager.cleanup();
		Manager.cnx.close();
		Manager.cnx = null;
		sys.FileSystem.deleteFile(DBPATH);
		InitDB.run();
		dbInit();

		Manager.cnx.request("BEGIN");
		try {
			// some groups
			var superGroup = new Group(new AccessName("super"), PSuper);
			superGroup.insert();
			// more
			new Group(new AccessName("telefonista"), PPhoneOperator).insert();
			new Group(new AccessName("supervisor"), PSupervisor).insert();
			new Group(new AccessName("pesquisador"), PSurveyor).insert();

			// some users
			var arthur = new User(new AccessName("arthur"), superGroup,
					"Arthur Dent", new EmailAddress("arthur@sapo"));
			arthur.password = Password.make("secret");
			var ford = new User(new AccessName("ford"), superGroup,
					"Ford Prefect", new EmailAddress("ford@sapo"));
			ford.password = Password.make("secret");
			arthur.insert();
			ford.insert();

			// some surveys
			var survey1 = new NewSurvey(ford, "Arthur's house", 945634);
			var survey2 = new NewSurvey(arthur, "Betelgeuse, or somewhere near that planet", 6352344);
			survey1.insert();
			survey2.insert();

			// some tickets
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

	public static function init()
	{
		InitDB.run();
		dbInit();
	}

	public static function shutdown()
	{
		if (Manager.cnx == null) return;
		Manager.cnx.close();
		Manager.cnx = null;
	}

	public static function iterate()
	{
		var key = Session.COOKIE_KEY;
		var cookies = Web.getAllCookies();
		if (cookies.exists(key) && cookies[key].length > 1)
			trace('WARNING multiple (${cookies[key].length}) values for cookie ${key}');

		var sid = Web.getCookies()[key];  // FIXME
		var session = Session.manager.get(sid);
		loop = new Context(Date.now(), session);
	}
}

