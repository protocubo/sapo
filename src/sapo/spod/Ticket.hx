package sapo.spod;

import common.db.MoreTypes;
import sapo.spod.Other;
import sapo.spod.User;
import sys.db.Object;
import sys.db.Types;

class Ticket extends Object {
	public var id:SId;
	@:relation(survey_id) public var survey:Survey;
	@:relation(author_id) public var author:User;
	public var subject:String;
	public var opened_at:HaxeTimestamp;

	public var closed_at:Null<HaxeTimestamp>;
	@:skip public var recipient(get,never):TicketSubscription;
		function get_recipient()
		{
			var tr = TicketRecipient.manager.select($ticket == this);
			if (tr == null || tr.subscription == null) throw 'Assert failed: no recipient for ticket $id';
			return tr.subscription;
		}

	public function isClosed()
		return closed_at == null;

	public function new(survey, author, subject, ?now)
	{
		if (now == null) now = Context.now;
		this.survey = survey;
		this.author = author;
		this.opened_at = now;
		this.subject = subject;
		super();
	}
}

class TicketMessage extends Object {
	public var id:SId;
	@:relation(ticket_id) public var ticket:Ticket;
	@:relation(author_id) public var author:User;
	public var text:String;
	public var posted_at:HaxeTimestamp;

	public function new(ticket, author, text, ?now)
	{
		if (now == null) now = Context.now;
		this.ticket = ticket;
		this.author = author;
		this.text = text;
		this.posted_at = now;
		super();
	}
}

@:index(ticket_id, group_id, user_id, unique)
class TicketSubscription extends Object {
	public var id:SId;
	@:relation(ticket_id) public var ticket:Ticket;
	@:relation(group_id) public var group:Null<Group>;
	@:relation(user_id) public var user:Null<User>;

	@:skip public var privilege(get,never):Privilege;
		function get_privilege() return (group != null ? group : user.group).privilege;
	@:skip public var name(get,never):String;
		function get_name() return user != null ? user.name : "";

	public function new(ticket, ?group, ?user)
	{
		if (group != null && user != null) throw "Can't simultaneously subscribe group and user";
		this.ticket = ticket;
		this.group = group;
		this.user = user;
		super();
	}
}

@:id(ticket_id, subscription_id)
class TicketRecipient extends Object {
	@:relation(ticket_id) public var ticket:Ticket;
	@:relation(subscription_id) public var subscription:TicketSubscription;

	public function new(ticket, subscription)
	{
		this.ticket = ticket;
		this.subscription = subscription;
		super();
	}
}

