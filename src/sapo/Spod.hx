package sapo;

import common.db.MoreTypes;
import sys.db.Types;

@:index(email, unique)
class User extends sys.db.Object {
	public var id:SId;
	public var email:String;
	public var name:String;

	public function new(email, name)
	{
		this.email = email;
		this.name = name;
		super();
	}
}

class Survey extends sys.db.Object {
	public var id:SId;
	@:relation(surveyor_id) public var surveyor:User;
	public var closed_at:HaxeTimestamp;
	public var address:String;
	public var code:Int;
	@:relation(status_id) public var status : SurveyStatus;

	public function new(surveyor, address, code)
	{
		// in this case it's not so easy to decide what to put in the
		// constructor and what to set later
		this.surveyor = surveyor;
		this.address = address;
		this.code = code;
		closed_at = Date.now();
		status = SurveyStatus.manager.get(1);
		super();
	}
}

class Ticket extends sys.db.Object {
	public var id:SId;
	@:relation(survey_id) public var survey:Survey;
	@:relation(author_id) public var author:User;
	
	public var opened_at:HaxeTimestamp;
	public var closed_at:Null<HaxeTimestamp>;
	public var subject:String;

	public function isClosed()
		return closed_at == null;

	public function new(survey, author, subject, ?now)
	{
		if (now == null) now = Date.now();
		this.survey = survey;
		this.author = author;
		this.opened_at = now;
		this.subject = subject;
		super();
	}
}

class TicketMessage extends sys.db.Object {
	public var id:SId;
	@:relation(ticket_id) public var ticket:Ticket;
	@:relation(author_id) public var author:User;
	public var text:String;
	public var posted_at:HaxeTimestamp;

	public function new(ticket, author, text, ?now)
	{
		if (now == null) now = Date.now();
		this.ticket = ticket;
		this.author = author;
		this.text = text;
		this.posted_at = now;
		super();
	}
}

class SurveyStatus extends sys.db.Object 
{
	public var id:SId;
	public var name:String;
	public function new(status)
	{
		this.name = status;
		super();
	}
}

