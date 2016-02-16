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
	public var address:String;

	public function new(surveyor, address)
	{
		// in this case it's not so easy to decide what to put in the
		// constructor and what to set later
		this.surveyor = surveyor;
		this.address = address;
		super();
	}
}

class Ticket extends sys.db.Object {
	public var id:SId;
	@:relation(survey_id) public var survey:Survey;
	@:relation(author_id) public var author:User;
	public var opened_at:HaxeTimestamp;
	public var closed_at:Null<HaxeTimestamp>;

	public function isClosed()
		return closed_at == null;

	public function new(survey, author, ?now)
	{
		if (now == null) now = Date.now();
		this.survey = survey;
		this.author = author;
		this.opened_at = now;
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

