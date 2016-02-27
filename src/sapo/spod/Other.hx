package sapo.spod;

import common.db.MoreTypes;
import sapo.spod.User;
import sys.db.Types;

enum SurveyStatus {
	SOpen;
	sClosed;
	Sverified;
	SCT;
	SAccepted;
	SRejected;
	SSubJudice;	
}

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
		closed_at = Date.now();
		status = TicketStatus.TOpen.getName();
		super();
	}
}

