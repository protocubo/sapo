package sapo;

import common.Web;
import common.crypto.Password;
import common.db.MoreTypes;
import common.spod.InitDB;
import sapo.spod.Other;
import sapo.spod.Ticket;
import sapo.spod.User;
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
			User.manager,
			UserGroups.manager
		];
		for (m in managers)
			if (!TableCreate.exists(m))
				TableCreate.create(m);
	}

	public static function resetMainDb()
	{
		if (Manager.cnx != null) {
			Manager.cnx.close();
			Manager.cnx = null;
		}
		sys.FileSystem.deleteFile(DBPATH);
		init();

		Manager.cnx.request("BEGIN");
		try {
			// some groups
			var surveyorGroup = new Group(new AccessName("pesquisador"), PSurveyor);
			surveyorGroup.insert();
			var superGroup = new Group(new AccessName("super"), PSuperUser);
			superGroup.insert();
			// more
			new Group(new AccessName("telefonista"), PPhoneOperator).insert();
			new Group(new AccessName("supervisor"), PSupervisor).insert();

			// some users
			var mane = new User(surveyorGroup, "Mane Mane", new EmailAddress("mane@sapo"));
			mane.password = Password.make("secret");
			var arthur = new User(superGroup, "Arthur Dent", new EmailAddress("arthur@sapo"));
			arthur.password = Password.make("secret");
			var ford = new User(superGroup, "Ford Prefect", new EmailAddress("ford@sapo"));
			ford.password = Password.make("secret");
			mane.insert();
			arthur.insert();
			ford.insert();

			// some surveys
			var survey1 = new NewSurvey(ford, "Arthur's house", 945634);
			var survey2 = new NewSurvey(arthur, "Betelgeuse, or somewhere near that planet", 6352344);
			survey1.insert();
			survey2.insert();

			// some tickets
			var ticket1 = new Ticket(survey1, arthur, ford, "Overpass???");
			ticket1.insert();
			new TicketMessage(ticket1, arthur, "Hey, I was distrought over they wanting to build an overpass over my house").insert();
			new TicketMessage(ticket1, ford, "Don't panic... don't panic...").insert();
			var ticket2 = new Ticket(survey2, ford, arthur, "About Time...");
			ticket2.insert();
			new TicketMessage(ticket2, ford, "Time is an illusion, lunchtime doubly so. ").insert();
			new TicketMessage(ticket2, arthur, "Very deep. You should send that in to the Reader's Digest. They've got a page for people like you.").insert();
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
			trace('WARNING multiple (${cookies[key].length}) values for cookie ${key}; we can\'t handle that yet');

		var sid = Web.getCookies()[key];  // FIXME
		var session = Session.manager.get(sid);
		loop = new Context(Date.now(), session);
	}
}

