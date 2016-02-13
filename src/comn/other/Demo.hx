package comn.other;

import sys.db.*;
import comn.Spod;

class Demo {
	static function msgType(msg:comn.Message)
	{
		return switch Type.typeof(msg) {
			case TClass(cl): Type.getClassName(cl);
			case t: throw 'Unexpected message type: $t'; }
	}

	static function main()
	{
		var dbPath = Sys.getEnv("COMN_DB");
		var slackUrl = Sys.getEnv("COMN_SLACK_URL");

		if (dbPath == null) throw "Missing COMN_DB environment variable";
		if (slackUrl == null) throw "Missing COMN_SLACK_URL environment variable";

		Manager.initialize();
		Manager.cnx = Sqlite.open(dbPath);
		var qmessages = QueuedMessage.manager;
		if (!TableCreate.exists(qmessages)) TableCreate.create(qmessages);

		var config = {
			dbCnx : Manager.cnx,
			qmessages : qmessages,
			creds : {
				slackUrl : slackUrl
			}
		}

		trace("Enqueuing");
		var slackChannel = Sys.getEnv("COMN_DEMO_SLACK_CHANNEL");
		var eq = new comn.LocalEnqueuer(qmessages);
		eq.enqueue(new comn.message.Slack({ text : "hi!", channel : slackChannel }));
		eq.enqueue(new comn.message.Slack({ text : "hi again", channel : slackChannel }));

		trace("Dequeuing");
		var dq = new comn.Dequeuer(config);
		dq.onSuccess = function (msg) {
			trace('Delivered ${msgType(msg)} messsage $msg');
			if (qmessages.select($sentAt == null) == null)
				dq.shutdown();
		}
		dq.onError = function (msg, e) {
			trace('Error when sending ${msgType(msg)} message: $e');
			Sys.sleep(1);
		}
		dq.onShutdown = function () Manager.cnx.close();
		dq.start();
	}
}

