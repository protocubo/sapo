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
			this.group = user.group;
			this.privilege = group.privilege;
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
		if (Manager.cnx != null) {
			Manager.cnx.close();
			Manager.cnx = null;
		}
		sys.FileSystem.deleteFile(DBPATH);
		init();

		Manager.cnx.request("BEGIN");
		try {
			// system groups
			var surveyors = new Group(PSurveyor, new AccessName("pesquisador"), "Pesquisador");
			var supervisors = new Group(PSupervisor, new AccessName("supervisor"), "Supervisor");
			var phoneOperators = new Group(PPhoneOperator, new AccessName("telefonista"), "Telefonista");
			var superUsers = new Group(PSuperUser, new AccessName("super"), "Super usuário");
			for (g in [surveyors, supervisors, phoneOperators, superUsers])
				g.insert();

			// users
			var arthur = new User(superUsers, new EmailAddress("arthur@sapo"), "Arthur Dent");
			var ford = new User(superUsers, new EmailAddress("ford@sapo"), "Ford Prefect");
			var judite = new User(phoneOperators, new EmailAddress("judite@sapo"), "Judite da NET");
			var magentoCol = [ for (i in 0...4) new User(supervisors, new EmailAddress('magento.$i@sapo'), 'Magento Maria #$i') ];
			for (u in [arthur, ford, judite].concat(magentoCol)) {
				u.password = Password.make("secret");
				u.insert();
			}
			var maneCol = [ for (i in 0...20) new User(surveyors, new EmailAddress('mane.$i@sapo'), 'Mané Manê #$i', magentoCol[i%magentoCol.length]) ];
			for (u in maneCol) {
				u.password = Password.make("secret");
				u.insert();
			}

			// some surveys
			var survey1 = new NewSurvey(maneCol[0], "Arthur's house", 945634);
			var survey2 = new NewSurvey(maneCol[1], "Betelgeuse, or somewhere near that planet", 6352344);
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

