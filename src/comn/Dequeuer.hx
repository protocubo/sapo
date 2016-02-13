package comn;

import comn.Spod;

class Dequeuer {
	var config:{
		dbCnx : sys.db.Connection,
		qmessages : sys.db.Manager<QueuedMessage>,
		creds : Credentials
	};
	var keepGoing:Bool;

	public dynamic function onSuccess(msg:Message):Void {}
	public dynamic function onError(msg:Message, e:Dynamic):Void {}
	public dynamic function onShutdown():Void {}

	function dequeue():Null<QueuedMessage>
	{
		return config.qmessages.select(
			$sentAt == null && $pos <= Date.now().getTime(),
			{ orderBy : pos });
	}

	function loop()
	{
		while (keepGoing) {
			config.dbCnx.request("BEGIN");
			var next = dequeue();
			if (next == null) {
				config.dbCnx.request("COMMIT");
				Sys.sleep(.1);
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
			config.dbCnx.request("COMMIT");
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
	}
}

