package sapo.spod;

import common.db.MoreTypes;
import sapo.spod.Other;
import sapo.spod.User;
import sys.db.Types;

class Ticket extends sys.db.Object {
	public var id:SId;
	@:relation(survey_id) public var survey:NewSurvey;
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
	@:relation(recipient_id) public var recipient:User;
	public var text:String;
	public var posted_at:HaxeTimestamp;

	public function new(ticket, author, recipient, text, ?now)
	{
		if (now == null) now = Date.now();
		this.ticket = ticket;
		this.author = author;
		this.recipient = recipient;
		this.text = text;
		this.posted_at = now;
		super();
	}
}

