package sapo.route;

import sapo.spod.Other;
import sapo.spod.Ticket;
import sapo.spod.User;
import sapo.view.Tickets.*;

class TicketRoutes extends AccessControl {
	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doDefault(?args:{ ?inbox:String, ?recipient:String, ?state:String })
	{
		if (args == null) args = {};
		var u = Context.loop.user;

		var tickets = Ticket.manager.search(
			(args.inbox == PARAM_OUTBOX ? $author == u : $author != u) &&
			(args.state == PARAM_CLOSED ? $closed_at != null : $closed_at == null));

		Sys.println(page(tickets));
	}

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doSearch(?args:{ ?ofUser:User, ?ticket:Ticket, ?survey:NewSurvey })
	{
		if (args == null) args = { };
		var tickets : List<Ticket> = new List();
		if (args.ticket != null)
			tickets.push(args.ticket);
		else if (args.survey != null)
			tickets = Ticket.manager.search($survey == args.survey);
		Sys.println(page(tickets));
	}

	public function new() {}
}

