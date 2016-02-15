package sapo.view.erazor;

import sapo.Spod;

@:includeTemplate("ticket.html")
class Ticket extends erazor.macro.HtmlTemplate {
	var ticket:Spod.Ticket;
	public function new(ticket)
	{
		this.ticket = ticket;
		super();
	}
}

