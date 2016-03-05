package sapo;

import common.Dispatch;
import common.Web;
import common.crypto.Password;
import common.db.MoreTypes;
import neko.Random;
import sapo.model.TicketModel;
import sapo.route.AccessControl;
import sapo.spod.Other;
import sapo.spod.Survey;
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
			Token.manager,
			User.manager
		];
		function viewExists(name) {
			return try {
				db.request('SELECT * FROM $name LIMIT 1');
				true;
			} catch (e:Dynamic) {
				false;
			}
		}

		for (m in managers)
			if (!TableCreate.exists(m))
				TableCreate.create(m);

		if (!viewExists("UpdatedSurvey")) {
			db.request("CREATE VIEW UpdatedSurvey AS SELECT
						MAX(id) as session_id,
						old_survey_id,
						MAX(syncTimestamp) as syncTimestamp
					FROM Survey GROUP BY old_survey_id");
		}
	}

	public static function init(?now)
	{
		common.spod.InitDB.run();
		db = Manager.cnx;
		dbInit();
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
		if (db == null) return;
		db.close();
		db = Manager.cnx = null;
	}

#if tink_template
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

