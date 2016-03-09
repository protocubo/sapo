package sapo.spod;

import common.db.MoreTypes;
import sapo.spod.User;
import sys.db.Types;

enum TicketStatus {
	TOpen;
	TClosed;
}

class NewSurvey extends sys.db.Object {
	public var id:SId;
	@:relation(surveyor_id) public var surveyor:User;
	public var closed_at:HaxeTimestamp;
	public var address:String;
	public var code:Int;
	public var status : String;

	public function new(surveyor, address, code)
	{
		// in this case it's not so easy to decide what to put in the
		// constructor and what to set later
		this.surveyor = surveyor;
		this.address = address;
		this.code = code;
		closed_at = Context.now;
		status = TicketStatus.TOpen.getName();
		super();
	}
}

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

