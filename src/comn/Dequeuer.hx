package comn;

import common.EnvVars;
import comn.Spod;
import sys.db.*;

// keep
import comn.message.DataExport;
import comn.message.Email;
import comn.message.Slack;

class Dequeuer {
	var cnx:Connection;
	var queue:Manager<QueuedMessage>;
	var creds:Credentials;
	var keepGoing:Bool;

	public dynamic function onHalt():Void {}
	public dynamic function onDbError(e:Dynamic):Bool return false;  // return value -> retry?
	public dynamic function onShutdown():Void {}

	public dynamic function onSuccess(msg:Message):Void {}
	public dynamic function onError(msg:Message, e:Dynamic):Void {}

	function dequeue():Null<QueuedMessage>
	{
		while (true)
		try {
			return queue.select(
				$sentAt == null && $pos <= Date.now().getTime(),
				{ orderBy : pos });
		} catch (e:Dynamic) {
			if (!onDbError(e)) neko.Lib.rethrow(e);
		}
	}

	function loop()
	{
		while (keepGoing) {
			var next = dequeue();
			if (next == null) {
				onHalt();
				continue;
			}

			var msg = next.data;
			var error = null;
			try {
				msg.deliver(queue, creds);
				next.sentAt = Date.now().getTime();
			} catch (e:DeliveryError) {
				error = e;
				next.delay(e.wait);
				next.errors++;
			} catch (e:Dynamic) {
				error = e;
				next.delay(10);
				next.errors++;
			}

			while (true)
			try {
				next.update();
				break;
			} catch (e:Dynamic) {
				if (!onDbError(e)) neko.Lib.rethrow(e);
			}

			if (error != null)
				onError(msg, error);
			else
				onSuccess(msg);
		}
		onShutdown();
	}

	public function start()
	{
		if (keepGoing)
			return;
		keepGoing = true;
		loop();
	}

	public function shutdown()
		keepGoing = false;

	public function new(cnx, queue, creds)
	{
		this.cnx = cnx;
		this.queue = queue;
		this.creds = creds;
		keepGoing = false;
	}


	public static function initDb(cnx:Connection, queue:Manager<QueuedMessage>)
	{
		if (!TableCreate.exists(queue))
		{
			if (cnx.dbName().toLowerCase() == "sqlite") {
				cnx.request("PRAGMA journal_mode=WAL");
			}
			TableCreate.create(queue);
		}
	}

	static function main()
	{
		function msgType(msg:comn.Message) {
			return switch Type.typeof(msg) {
				case TClass(cl): Type.getClassName(cl);
				case t: throw 'Unexpected message type: $t'; }
		}

		var verbose = Lambda.has(Sys.args(), "--verbose");
		var dbPath = Sys.getEnv(COMN_DB);
		if (dbPath == null) throw 'Missing $COMN_DB environment variable';

		var creds = {
			slackUrl : Sys.getEnv(COMN_SLACK_URL),
			sendGridKey : Sys.getEnv(COMN_SENDGRID_API_KEY)
		}
		if (creds.slackUrl == null) throw 'Missing $COMN_SLACK_URL environment variable';
		if (creds.sendGridKey == null) throw 'Missing $COMN_SENDGRID_API_KEY environment variable';

		Manager.initialize();
		var cnx = Manager.cnx = Sqlite.open(dbPath);
		var queue = QueuedMessage.manager;
		initDb(cnx, queue);

		var dq = new Dequeuer(cnx, queue, creds);
		dq.onHalt = function () {
			if (verbose) trace("Halted: no messages to send now");
			Sys.sleep(1);
		}
		dq.onDbError = function (e) {
			var pat = ~/database is (busy|locked)/i;
			if (pat.match(Std.string(e))) {
				trace('WARNING database ${pat.matched(1)}, retrying in 50ms');
				Sys.sleep(.05);
				return true;
			}
			return false;
		}

		dq.onSuccess = function (msg) {
			if (verbose) trace('Sent message: ${msgType(msg)} #??');
			Sys.sleep(.1);
		}
		dq.onError = function (msg, e) {
			trace('ERROR on message #?: $e');
			Sys.sleep(1);
		}

		bodge.Flare.register(
			function (signum) {
				if (signum != /*SIGTERM*/ 15) return;
				dq.shutdown();
				trace('Gracefully shutting down after receiving signal $signum');
			});
		dq.start();
	}
}

