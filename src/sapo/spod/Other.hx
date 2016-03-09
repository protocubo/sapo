package sapo.spod;

import common.db.MoreTypes;
import sys.db.Types;

@:id(key)
class SapoVersion extends sys.db.Object {
	public var key:String;
	public var version:String;
	public var updated_at:HaxeTimestamp;

	public function new(key, version)
	{
		this.key = key;
		this.version = version;
		this.updated_at = Context.now;
		super();
	}

	override public function update()
	{
		this.updated_at = Context.now;
		super.update();
	}
}

