package sapo;

import common.Dispatch;
import common.Web;
import common.crypto.Password;
import common.db.MoreTypes;
import common.spod.InitDB;
import sapo.route.AccessControl;
import sapo.spod.Other;
import sapo.spod.Ticket;
import sapo.spod.User;
import sys.db.*;

class Context {
	static var DBPATH = Sys.getEnv("SAPO_DB");

	public static var version(default,null) = { commit : Version.getGitCommitHash() }
	public static var now(default,null):HaxeTimestamp;
	public static var db(default,null):common.db.AutocommitConnection;
	public static var loop(default,null):Context;

	var dispatch:Dispatch;

	public var uri(default,null):String;
	public var params(default,null):Map<String,String>;
	public var method(default,null):String;

	public var session(default,null):Null<Session>;
	public var user(default,null):Null<User>;
	public var group(default,null):Null<Group>;
	public var privilege(default,null):Null<Privilege>;

	function new(uri:String, params:Map<String, String>, method:String, session:Null<Session>)
	{
		this.uri = uri;
		this.params = params;
		dispatch = new Dispatch(uri, params, method);

		if (session == null)
			return;
		if (session.expired(now)) {
			session.expire();
			session.update();
			return;
		}
		this.session = session;
		this.user = session.user;
		this.group = user.group;
		this.privilege = group.privilege;
	}

	static function dbInit()
	{
		var managers:Array<Manager<Dynamic>> = [
			Group.manager,
			NewSurvey.manager,
			Session.manager,
			Ticket.manager,
			TicketMessage.manager,
			TicketRecipient.manager,
			TicketSubscription.manager,
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
		if(sys.FileSystem.exists(DBPATH))
			sys.FileSystem.deleteFile(DBPATH);
		init();

		startTransaction();
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
			var ford = new User(superUsers, new EmailAddress("ford@sapo"), "Ford efect");
			var judite = new User(phoneOperators, new EmailAddress("judite@sapo"), "Judite da NET");
			var magentoCol = [ for (i in 0...4) new User(supervisors, new EmailAddress('magento.${i+1}@sapo'), 'Magento Maria #${i+1}') ];
			for (u in [arthur, ford, judite].concat(magentoCol)) {
				u.password = Password.make("secret");
				u.insert();
			}
			var maneCol = [ for (i in 0...20) new User(surveyors, new EmailAddress('mane.${i+1}@sapo'), 'Mané Manê #${i+1}', magentoCol[i%magentoCol.length]) ];
			for (u in maneCol) {
				u.password = Password.make("secret");
				u.insert();
			}

			// some surveys
			var survey1 = new NewSurvey(maneCol[0], "Arthur's house", 945634);
			var survey2 = new NewSurvey(maneCol[1], "Betelgeuse, or somewhere near that planet", 6352344);
			survey1.insert();
			survey2.insert();
			var surveyCol = [survey1, survey2];

			// some tickets
			var authorCol = [arthur, ford].concat(magentoCol);
			var recipientCol = authorCol.concat([judite]);  // TODO create some for groups too
			var ticketCol = [];
			for (i in 0...20) {
				var s = surveyCol[i%surveyCol.length];
				var a = authorCol[i%authorCol.length];
				var r = recipientCol[(recipientCol.length + i)%recipientCol.length];
				var t = new Ticket(s, a, 'Lorem ${s.id} ipsum ${a.name} ${r.name}');
				t.insert();
				var trs = new TicketSubscription(t, null, r);
				trs.insert();
				new TicketRecipient(t, trs).insert();
				var m = new TicketMessage(t, a, 'Heyy!!  Just letting you know I found an issue with survey ${s.id}');
				new TicketSubscription(t, null, a).insert();
				m.insert();
			}

			var ticket1 = new Ticket(survey1, arthur, "Overpass???");
			ticket1.insert();
			var trs = new TicketSubscription(ticket1, superUsers);
			trs.insert();
			new TicketRecipient(ticket1, trs).insert();
			new TicketMessage(ticket1, arthur, "Hey, I was distrought over they wanting to build an overpass over my house").insert();
			new TicketSubscription(ticket1, null, arthur).insert();
			new TicketMessage(ticket1, ford, "Don't panic... don't panic...").insert();
			new TicketSubscription(ticket1, null, ford).insert();

			var ticket2 = new Ticket(survey2, ford, "About Time...");
			ticket2.insert();
			var trs = new TicketSubscription(ticket2, phoneOperators);
			trs.insert();
			new TicketRecipient(ticket2, trs).insert();
			new TicketMessage(ticket2, ford, "Time is an illusion, lunchtime doubly so. ").insert();
			new TicketSubscription(ticket2, null, ford).insert();
			new TicketMessage(ticket2, arthur, "Very deep. You should send that in to the Reader's Digest. They've got a page for people like you.").insert();
			new TicketSubscription(ticket2, null, arthur).insert();
		} catch (e:Dynamic) {
			rollback();
			neko.Lib.rethrow(e);
		}
		commit();
	}

	public static function init(?now)
	{
		InitDB.run();
		dbInit();
		db = Manager.cnx;
		updateClock();
	}

	public static function updateClock()
	{
		now = Date.now();
	}

	public static function startTransaction()
		db.request("BEGIN");

	public static function commit()
		db.request("COMMIT");

	public static function rollback()
		db.request("ROLLBACK");

	public static function shutdown()
	{
		if (Manager.cnx == null) return;
		Manager.cnx.close();
		db = Manager.cnx = null;
	}

#if !sapo_sync
	public static function iterate()
	{
		updateClock();

		var uri = Web.getURI();
		var params = Web.getParams();
		var method = Web.getMethod();

		// treat visibly empty params as missing
		var cparams = [ for (k in params.keys()) if (StringTools.trim(params.get(k)).length > 0) k => params.get(k) ];

		var key = Session.COOKIE_KEY;
		var cookies = Web.getAllCookies();
		if (cookies.exists(key) && cookies[key].length > 1)
			trace('WARNING multiple (${cookies[key].length}) values for cookie ${key}; we can\'t handle that yet');
		var sid = Web.getCookies()[key];  // FIXME
		var session = Session.manager.get(sid);

		loop = new Context(uri, cparams, method, session);

		trace(loop.session);
		if (loop.session != null) trace(loop.session.expires_at.toDate());
		if (loop.session != null) trace(loop.session.expired());
		if (loop.session != null && loop.session.expired_at != null) trace(loop.session.expired_at.toDate());

		// log if we're loosing any params
		var aparams = Web.getAllParams();
		for (p in aparams.keys())
			if (aparams[p].length > 1)
				trace('WARNING multiple (${aparams[p].length}) values for param $p; we can\'t handle that yet');

		loop.dispatch.onMeta = AccessControl.onDispatchMeta;
		try {
			loop.dispatch.dispatch(new sapo.route.RootRoutes());
		} catch (e:AccessControlError) {
			Context.shutdown();
			trace('Access control error: $e');
			var url = Web.getURI();
			if (Web.getMethod().toLowerCase() == "get")
				url += "?" + [
					for (k in Web.getParams().keys())
						'${StringTools.urlEncode(k)}=${StringTools.urlEncode(Web.getParams().get(k))}'
				].join("&");
			Web.redirect('/login?redirect=${StringTools.urlEncode(url)}');
		}
	}
#end
}

