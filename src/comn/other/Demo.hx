package comn.other;

import common.EnvVars;
import comn.Spod;
import sys.db.*;

class Demo {
	static function msgType(msg:comn.Message)
	{
		return switch Type.typeof(msg) {
			case TClass(cl): Type.getClassName(cl);
			case t: throw 'Unexpected message type: $t'; }
	}

	static function main()
	{
		var dbPath = Sys.getEnv(COMN_DB);

		if (dbPath == null) throw 'Missing $COMN_DB environment variable';

		Manager.initialize();
		Manager.cnx = Sqlite.open(dbPath);
		var queue = QueuedMessage.manager;
		if (!TableCreate.exists(queue)) TableCreate.create(queue);

		trace("Enqueuing");
		var slackChannel = Sys.getEnv(COMN_DEMO_SLACK_CHANNEL);
		var eq = new comn.LocalEnqueuer(queue);
		eq.enqueue(new comn.message.Slack({ text : "hi!", channel : slackChannel }));
		eq.enqueue(new comn.message.Slack({ text : "hi again", channel : slackChannel }));
	}
}

