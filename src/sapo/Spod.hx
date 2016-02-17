package sapo;

// TODO move surveys (and related stuff) and tickets (and related stuff) to
// separated spod modules

import common.db.MoreTypes;
import sys.db.Types;

// necessary only because we need mentions to groups
@:index(group_name, unique)
class Group extends sys.db.Object {
	public var id:SId;
	public var group_name:AccessName;
	public var privilege:SEnum<Privilege>;

	public function new(group_name, privilege)
	{
		this.group_name = group_name;
		this.privilege = privilege;
		super();
	}
}

@:index(user_name, unique)
@:index(email, unique)
class User extends sys.db.Object {
	public var id:SId;
	public var user_name:AccessName;
	@:relation(group_id) public var group:Group;
	public var name:String;
	public var email:EmailAddress;

	public function new(user_name, group, name, email)
	{
		this.user_name = user_name;
		this.group = group;
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

