package sapo.spod;

import common.db.MoreTypes;
import sapo.spod.Other;
import sapo.spod.User;
import sys.db.Types;

enum TicketRecipient {
	RUser(u:User);
	RGroup(g:Group):
}

class Ticket extends sys.db.Object {
	public var id:SId;
	@:relation(survey_id) public var survey:NewSurvey;
	@:relation(author_id) public var author:User;
	public var subject:String;
	public var opened_at:HaxeTimestamp;

	public var closed_at:Null<HaxeTimestamp>;
	@:skip public var recipient(get,never):TicketRecipient;
		function get_recipient()
		{
			var ts = TicketSubscription.manager.seach($ticket == this && isRecipient == true);
			return ts.user != null ? RUser(ts.user) : RGroup(ts.group);
		}

	public function isClosed()
		return closed_at == null;

	public function new(survey, author, subject, ?opened_at)
	{
		if (opened_at == null) opened_at = Context.loop.now;
		this.survey = survey;
		this.author = author;
		this.opened_at = opened_at;
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

@:id(ticket_id, group_id, user_id)
@:index(ticket_id, isRecipient, unique)
class TicketSubscription extends sys.db.Object {
	@:relation(ticket_id) public var ticket:Ticket;
	@:relation(group_id) public var group:Null<Group>;
	@:relation(user_id) public var user:Null<User>;
	public var isRecipient:Bool;

	public function new(ticket, ?group, ?user, ?isRecipient=false)
	{
		if (group != null && user != null) throw "Can't simultaneously subscribe group and user";
		this.ticket = ticket;
		this.group = group;
		this.user = user;
		this.isRecipient = isRecipient;
		super();
	}
}

