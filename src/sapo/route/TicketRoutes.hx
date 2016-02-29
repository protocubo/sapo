package sapo.route;

import sapo.spod.Other;
import sapo.spod.Ticket;
import sapo.spod.User;

class TicketRoutes extends AccessControl {
	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doDefault(?args:{ ?inbox:String, ?recipient:String, ?state:String })
	{
		if (args == null) args = { };
		var tickets : List<Ticket> = new List();
		var u = Context.loop.user;
		var tickets : List<Ticket> = new List();

		tickets = Ticket.manager.search(
		(args.inbox == "out"? $author == u : 1 == 1) &&
		(args.state == "open"? $closed_at == null:$closed_at != null)

		);

		Sys.println(sapo.view.Tickets.page(tickets));
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
		Sys.println(sapo.view.Tickets.page(tickets));
	}

	public function new() {}
}

