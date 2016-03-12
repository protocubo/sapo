package comn;

import sys.db.Types;
import common.db.MoreTypes;

class QueuedMessage extends sys.db.Object {
	public var id:SId;
	public var pos:HaxeTimestamp;
	public var enqueuedAt:HaxeTimestamp;
	public var errors:Int;
	public var sentAt:Null<HaxeTimestamp>;
	public var data:SData<Message>;

	public function delay(seconds:Float)
		pos = DateTools.delta(Date.now(), 1e3*seconds);
}

class ExportLog extends sys.db.Object {
	public var id:SId;
	public var sha1:String;
	public var time:HaxeTimestamp;

	public function new(sha1, time)
	{
		this.sha1 = sha1;
		this.time = time;
		super();
	}
}

