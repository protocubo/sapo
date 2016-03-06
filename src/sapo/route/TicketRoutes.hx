package sapo.route;

import common.Dispatch;
import common.Web;
import common.db.MoreTypes;
import sapo.spod.Other;
import sapo.spod.Survey;
import sapo.spod.Ticket;
import sapo.spod.User;

class TicketRoutes extends AccessControl {
	public static inline var PAGE_SIZE = 10;
	public static inline var PARAM_ALL = "all";
	public static inline var PARAM_GROUP = "group";
	public static inline var PARAM_INDIVIDUAL = "individual";
	public static inline var PARAM_OPEN = "open";
	public static inline var PARAM_CLOSED = "closed";

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doDefault(?args:{?recipient:String, ?state:String })
	{
		if (args == null) args = {};
		var open = args.state == null || args.state == PARAM_OPEN;
		if (!open && args.state != PARAM_CLOSED) throw 'Unexpected state value: ${args.state}';

		var u = Context.loop.user;
		var g = Context.loop.group;
		var p = Context.loop.privilege;

		var sql = "SELECT t.* FROM Ticket t";
		sql += switch args.recipient {
		case null, PARAM_ALL if (p.match(PSuperUser)):
			' WHERE';  // done: all
		case null, PARAM_ALL:
			' JOIN TicketSubscription ts ON t.id = ts.ticket_id
					WHERE (ts.user_id = ${u.id} OR ts.group_id = ${g.id}) AND';
		case PARAM_GROUP:
			' JOIN TicketSubscription ts ON t.id = ts.ticket_id
					WHERE (ts.group_id = ${g.id}) AND';
		case PARAM_INDIVIDUAL:
			' JOIN TicketSubscription ts ON t.id = ts.ticket_id
					WHERE (ts.user_id = ${u.id}) AND';
		case other:
			throw 'Unexpected recipient value: $other';
		}
		sql += ' t.closed_at ${open ? "IS" : "NOT"} NULL';
		sql += ' ORDER BY t.opened_at LIMIT $PAGE_SIZE';

		var tickets = Ticket.manager.unsafeObjects(sql, false);
		Sys.println(sapo.view.Tickets.page(tickets));
	}

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doSearch(?args:{ ?ofUser:User, ?ticket:Ticket, ?survey:Survey })
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
			if(t.author != Context.loop.user && t.recipient.user != Context.loop.user && t.recipient.group != Context.loop.user.group)
			Web.redirect("/tickets");
			return;
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

		t.closed_at = Context.now;
		t.update();
		
		var msg = new TicketMessage(t, Context.loop.user, "TICKET FECHADO.");
		msg.insert();
		
		Web.redirect('/tickets/search?ticket=${t.id}');
	}
	
	@authorize(PSupervisor, PSuperUser)
	public function postReopen(t : Lock<Ticket>)
	{
		switch(Context.loop.privilege)
		{
			case PSupervisor:
			if (Context.loop.user != t.author)
				throw "Can\'t reopen ticket authored by someone else";
			case PSuperUser:
			case _: throw "Assertion failed";
		}
		
		t.closed_at = null;
		t.update();
		var msg = new TicketMessage(t, Context.loop.user, "TICKET REABERTO");
		msg.insert();
		
		Web.redirect('/tickets/search?ticket=${t.id}');
	}

	public function new() {}
}

