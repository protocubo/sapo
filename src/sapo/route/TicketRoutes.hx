package sapo.route;

import common.Dispatch;
import common.Web;
import common.db.MoreTypes;
import sapo.spod.Other;
import sapo.spod.Ticket;
import sapo.spod.User;

class TicketRoutes extends AccessControl {
	public static inline var PARAM_ALL = "all";
	public static inline var PARAM_GROUP = "group";
	public static inline var PARAM_INDIVIDUAL = "individual";
	public static inline var PARAM_OPEN = "open";
	public static inline var PARAM_CLOSED = "closed";

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doDefault(?args:{?recipient:String, ?state:String })
	{
		if (args == null) args = {};
		var u = Context.loop.user;

		var subs = switch args.recipient {
		case null, PARAM_ALL if (Context.loop.privilege.match(PSupervisor | PPhoneOperator)):
			TicketSubscription.manager.search($user == u || $group == u.group);
		case null, PARAM_ALL:
			TicketSubscription.manager.all();  // TODO optimize this
		case PARAM_GROUP:
			TicketSubscription.manager.search($group == u.group);
		case PARAM_INDIVIDUAL:
			TicketSubscription.manager.search($user == u);
		case other:
			throw 'Unexpected recipient value: $other';
		}

		var tickets = new List();
		var open = args.state == null || args.state == PARAM_OPEN;
		if (!open && args.state != PARAM_CLOSED) throw 'Unexpected state value: ${args.state}';
		for (ts in subs) {
			if (open == (ts.ticket.closed_at == null))
				tickets.add(ts.ticket);
		}

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

