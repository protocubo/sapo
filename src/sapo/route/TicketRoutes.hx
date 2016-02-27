package sapo.route;

import sapo.spod.Other;
import sapo.spod.Ticket;
import sapo.spod.User;

class TicketRoutes implements AccessControl {
	@authorizeAll
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

		if (args.inbox == "out")
		{

		}
		else if (args.inbox == "in")
		{
			//Todo: Spod Recipients
			//if(args.recipient == "all")
			//	tickets = Ticket.manager.search( (args.state == "open"? $closed_at == null:$closed_at != null));
			//else
			//	tickets = Ticket.manager.search( (args.state == "open"? $closed_at == null:$closed_at != null));
		}
		else
		{

		}

		/*tickets = Ticket.manager.search(
		switch args.inbox {
			case "in": 1 == 1; //$recipient == u;
			case "out": $author == u;
			default: 1==1;
		}

		$author == u

		);*/

		Sys.println(sapo.view.Tickets.render(tickets));
	}

	@authorize("PPhoneOperator", "PSuper", "PSupervisor")
	public function doSearch(?args:{ ?ofUser:User, ?ticket:Ticket, ?survey:NewSurvey })
	{
		if (args == null) args = { };
		var tickets : List<Ticket> = new List();
		if (args.ticket != null)
			tickets.push(args.ticket);
		else if (args.survey != null)
			tickets = Ticket.manager.search($survey == args.survey);
		Sys.println(sapo.view.Tickets.render(tickets));
	}

	public function new() {}
}

