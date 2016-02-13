package comn;

import comn.Spod;

class LocalEnqueuer {
	var qmessages:sys.db.Manager<QueuedMessage>;

	public function enqueue(msg:Message, ?sendAt:Date)
	{
		var now = Date.now();
		if (sendAt == null) sendAt = now;

		var qm = new QueuedMessage();
		qm.pos = sendAt;
		qm.enqueuedAt = now;
		qm.errors = 0;
		qm.data = msg;

		while (true)
		try {
			qm.insert();
			return;
		} catch (e:Dynamic) {
			Sys.sleep(.05);
		}
	}

	public function new(qmessages)
	{
		this.qmessages = qmessages;
	}
}

