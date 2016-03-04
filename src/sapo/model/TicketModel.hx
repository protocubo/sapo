package sapo.model;

import sapo.spod.Ticket;

class TicketModel {
	/**
		Add a new ticket message.

		Creates the message and subscribes its author to the ticket.
	**/
	public static function addMessage(ticket, author, text, ?now)
	{
		var tm = new TicketMessage(ticket, author, text, now);
		tm.insert();
		var tas = new TicketSubscription(ticket, null, author);  // TODO already subscribed
		tas.insert();
		return tm;
	}

	/**
		Open and insert a new ticket.

		Creates the ticket, the initial message, subscriptions for both
		author and recipient and the recipient record.
	**/
	public static function open(survey, author, subject, text, ?opened_at, ?toGroup, ?toUser)
	{
		if (toGroup != null && toUser != null) throw "Can't simultaneously write to group and user";
		var t = new Ticket(survey, author, subject, opened_at);
		t.insert();
		var trs = new TicketSubscription(t, toGroup, toUser);  // TODO already subscribed
		trs.insert();
		var tr = new TicketRecipient(t, trs);
		tr.insert();
		addMessage(t, author, text, opened_at);
		return t;
	}
}

