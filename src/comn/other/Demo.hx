package comn.other;

import common.EnvVars;
import comn.Spod;
import sys.db.*;

class Demo {
	static function main()
	{
		var dbPath = Sys.getEnv(COMN_DB);
		if (dbPath == null) throw 'Missing $COMN_DB environment variable';

		Manager.initialize();
		Manager.cnx = Sqlite.open(dbPath);
		var queue = QueuedMessage.manager;
		comn.Dequeuer.initDb(Manager.cnx, queue);
		var eq = new comn.LocalEnqueuer(queue);

		trace("Enqueuing Slack");
		var slackChannel = Sys.getEnv(COMN_DEMO_SLACK_CHANNEL);
		eq.enqueue(new comn.message.Slack({ text : "hi!", channel : slackChannel }));
		eq.enqueue(new comn.message.Slack({ text : "hi again", channel : slackChannel }));

		trace("Enqueue Email");
		var author = Sys.getEnv(COMN_DEMO_EMAIL_AUTHOR);
		var recipient = Sys.getEnv(COMN_DEMO_EMAIL_RECIPIENT);
		if (author == null) throw 'Missing $COMN_DEMO_EMAIL_AUTHOR environment variable';
		if (recipient == null) throw 'Missing $COMN_DEMO_EMAIL_RECIPIENT environment variable';
		eq.enqueue(new comn.message.Email({
			from : author, to : [recipient],
			subject : "Hello from sapo",
			text : "Hi, just letting you known that I'm working just fine" }));
	}
}

