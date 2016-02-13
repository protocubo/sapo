package comn;

import common.EnvVars;
import comn.Spod;
import sys.db.*;

// keep
import comn.message.Slack;

typedef DequeuerConfig = {
	db : sys.db.Connection,
	queue : sys.db.Manager<QueuedMessage>,
	creds : Credentials
}

class Dequeuer {
	var config:DequeuerConfig;
	var keepGoing:Bool;

	public dynamic function onHalt():Void {}
	public dynamic function onSuccess(msg:Message):Void {}
	public dynamic function onError(msg:Message, e:Dynamic):Void {}
	public dynamic function onShutdown():Void {}

	function dequeue():Null<QueuedMessage>
	{
		return config.queue.select(
			$sentAt == null && $pos <= Date.now().getTime(),
			{ orderBy : pos });
	}

	function loop()
	{
		while (keepGoing) {
			config.db.request("BEGIN");
			var next = dequeue();
			if (next == null) {
				config.db.request("COMMIT");
				onHalt();
				continue;
			}

			var msg = next.data;
			var error = null;
			try {
				msg.deliver(config.creds);
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

			next.update();
			config.db.request("COMMIT");
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

	public function new(config)
	{
		this.config = config;
		keepGoing = false;
	}

	static function main()
	{
		var verbose = Lambda.has(Sys.args(), "--verbose");
		var dbPath = Sys.getEnv(COMN_DB);
		var slackUrl = Sys.getEnv(COMN_SLACK_URL);

		if (dbPath == null) throw 'Missing $COMN_DB environment variable';
		if (slackUrl == null) throw 'Missing $COMN_SLACK_URL environment variable';

		Manager.initialize();
		Manager.cnx = Sqlite.open(dbPath);
		var config = {
			db : Manager.cnx,
			queue : QueuedMessage.manager,
			creds : {
				slackUrl : slackUrl
			}
		}
		if (!TableCreate.exists(config.queue)) TableCreate.create(config.queue);

		var dq = new Dequeuer(config);
		dq.onHalt = function () {
			if (verbose) trace("Halted");
			Sys.sleep(1);
		}
		dq.onSuccess = function (msg) {
			if (verbose) trace("Sent message");
			Sys.sleep(.1);
		}
		dq.onError = function (msg, e) {
			if (verbose) trace('Error: $e');
			Sys.sleep(1);
		}

		dq.start();
	}
}

