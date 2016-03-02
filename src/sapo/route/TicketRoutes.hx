package sapo.route;

import common.Dispatch;
import common.Web;
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

		var tickets;

		if (args.inbox == PARAM_OUTBOX) {
			tickets = Ticket.manager.search(
					$author == u &&
					(args.state == PARAM_CLOSED ? $closed_at != null : $closed_at == null));
		} else {
			var subs = TicketSubscription.manager.search($user == u || $group == u.group);
			tickets = Ticket.manager.search(
					// TODO ticket in subs
					(args.state == PARAM_CLOSED ? $closed_at != null : $closed_at == null));
		}

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

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function postReply(t:Ticket, args:{ text:String })
	{
		switch Context.loop.privilege {
		case PSupervisor, PPhoneOperator:
			trace("TODO check if supervisor/phone operator in list of recipients");
		case PSuperUser:
			// ok;
		case _: throw "Assertion failed";
		}

		var u = Context.loop.user;
		try {
			Context.db.startTransaction();
			var msg = new TicketMessage(t, u, args.text);
			msg.insert();
			var sub = TicketSubscription.manager.select($user == u);
			if (sub == null) {
				sub = new TicketSubscription(t, u);
				sub.insert();
			}
			Context.db.commit();
		} catch (e:Dynamic) {
			Context.db.rollback();
			Web.setReturnCode(500);
			return;
		}
		Web.redirect('/tickets/search?ticket=${t.id}');
	}

	@authorize(PSupervisor, PSuperUser)
	public function postClose(t:Lock<Ticket>)
	{
		// TODO separate route for PPhoneOperators
		switch Context.loop.privilege {
		case PSupervisor if (Context.loop.user != t.author):
			throw 'Can\'t close ticket authored by someone else';
		case PSuperUser:
			// ok;
		case _: throw "Assertion failed";
		}

		t.closed_at = Context.loop.now;
		t.update();
		Web.redirect('/tickets/search?ticket=${t.id}');
	}

	public function new() {}
}

