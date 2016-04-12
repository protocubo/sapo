package sapo.route;

import common.Dispatch;
import common.Web;
import common.db.MoreTypes;
import sapo.Context.loop;
import sapo.spod.Other;
import sapo.spod.Survey;
import sapo.spod.Ticket;
import sapo.spod.User;

class ManyTicketRoutes extends AccessControl {
	public static inline var PAGE_SIZE = 20;
	public static inline var PARAM_ALL = "all";
	public static inline var PARAM_GROUP = "group";
	public static inline var PARAM_INDIVIDUAL = "individual";
	public static inline var PARAM_OPEN = "open";
	public static inline var PARAM_CLOSED = "closed";

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doDefault(?args:{?recipient:String, ?state:String, ?survey : Survey, ?page : Int })
	{
		if (args == null) args = {};
		var open = args.state == null || args.state == PARAM_OPEN;
		if (!open && args.state != PARAM_CLOSED) throw 'Unexpected state value: ${args.state}';
		var survey_id = (args.survey != null) ? args.survey.id : null;
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
					WHERE (ts.user_id = ${u.id} ) AND';
		case other:
			throw 'Unexpected recipient value: $other';
		}

		if (survey_id != null)
			sql += " t.survey_id = " + survey_id + " AND ";

		sql += ' t.closed_at ${open ? "IS" : "NOT"} NULL';

		sql += ' ORDER BY t.opened_at LIMIT ${PAGE_SIZE + 1}';
		if (args.page > 1)
		{
			var p = args.page -1;
			sql += ' OFFSET ' + PAGE_SIZE * p;
		}

		var tickets = Ticket.manager.unsafeObjects(sql, false);
		var total = tickets.length;
		//Pego 11 somente para comparação se devo colocar o btn Proximo
		if (total > PAGE_SIZE)
			tickets.pop();
		Sys.println(sapo.view.Tickets.page(tickets,args.page,total));
	}

	@authorize(PSupervisor, PSuperUser)
	public function postOpen(args : { author : Int, recipient : String, subject : String, message : String, survey : Survey } )
	{
		var author = User.manager.get(args.author);

		var t = new Ticket(args.survey, author, args.subject);
		t.insert();

		var msg = new TicketMessage(t, author, args.message);
		msg.insert();

		var intVal = Std.parseInt(args.recipient);

		var rec : TicketRecipient;
		var sub : TicketSubscription;
		if (intVal != null)
		{
			var user = User.manager.get(intVal);
			sub = new TicketSubscription(t, null, user);

		}
		else
		{
			var group = Group.manager.select($name == args.recipient, null, false);
			sub = new TicketSubscription(t, group, null);
		}
		//
		sub.insert();
		rec = new TicketRecipient(t, sub);
		rec.insert();

		Web.redirect('/ticket/${t.id}');

	}

	public function new() {}
}

class TicketRoutes extends AccessControl {
	var ticket:Ticket;

	function resetOrRedirect(?tid:Null<Int>)
	{
		var uri = Web.getLocalReferer();
		if (uri == null) {
			if (tid != null)
				uri = '/ticket/$tid';
			else
				uri = "/tickets";
		} else if (tid != null)
			uri += "#BodyTicket" + tid;
		Web.redirect(uri);
	}
 
	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doDefault()
	{
		var tickets = new List();
		tickets.add(ticket);
		Sys.println(sapo.view.Tickets.page(tickets,1,tickets.length));
	}


	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function postReply(args:{ text:String })
	{
		if (ticket.closed_at != null && !canClose(ticket))
			throw '${Context.loop.user.email} cannot reopen ticket ${ticket.id}';

		var u = Context.loop.user;
		try {
			Context.db.startTransaction();
			if (ticket.closed_at != null)
			{
				ticket.lock();
				ticket.closed_at = null;
				ticket.update();
				// TODO compute this automagically
				var msg = new TicketMessage(ticket,u, "~ TICKET REABERTO ~", Context.now);
				msg.insert();
			}

			var msg = new TicketMessage(ticket, u, args.text);
			msg.insert();
			var sub = TicketSubscription.manager.select($user == u || $group == u.group);
			if (sub == null) {
				sub = new TicketSubscription(ticket, u);
				sub.insert();
			}
			Context.db.commit();
		} catch (e:Dynamic) {
			Context.db.rollback();
			Web.setReturnCode(500);
			return;
		}
		resetOrRedirect(ticket.id);
	}

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function postInclude(args : { value : String } )
	{
		if (args == null)
		{
			Web.redirect("/tickets/");  // FIXME
			return;
		}
		var intval = Std.parseInt(args.value);
		var user : User = null;
		var group : Group = null;

		if (intval != null)
			user = User.manager.get(intval);
		else
			group = Group.manager.select($name == args.value, null, false);

		var msg = new TicketMessage(ticket, Context.loop.user, "~ " + ((user != null) ? user.name : group.name) + " incluído(a) ao ticket ~".toUpperCase());
		msg.insert();

		var ref = TicketSubscription.manager.select($ticket == ticket && ($group == group || $user == user), null, false);
		if (ref == null)
		{
			var sub = new TicketSubscription(ticket, group, user);
			sub.insert();
		}

		resetOrRedirect(ticket.id);
	}

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function postClose()
	{
		if (!canClose(ticket)) throw '${Context.loop.user.email} cannot close ticket ${ticket.id}';

		// TODO do this inside a transaction
		ticket.lock();
		ticket.closed_at = Context.now;
		ticket.update();
		// TODO do this automagically
		var msg = new TicketMessage(ticket, Context.loop.user, "~ TICKET FECHADO ~");
		msg.insert();

		resetOrRedirect();
	}

	public function new(ticket)
	{
		this.ticket = ticket;
	}

	public static function canClose(t:Ticket)
	{
		return switch Context.loop.privilege {
		case PSuperUser:
			true;
		case PPhoneOperator if (t.recipient.group == Context.loop.group && t.survey.checkCT != null && t.survey.isPhoned):
			true;
		case PSupervisor if (t.author == Context.loop.user):
			true;
		case _:
			false;
		}
	}

	public static function doTicketsImpl(d:Dispatch)
		d.dispatch(new ManyTicketRoutes());

	public static function doSingleTicketImpl(d:Dispatch, t:Ticket)
	{
		switch loop.privilege {
		case PSuperUser:
			// ok
		case PPhoneOperator | PSupervisor
				if (TicketSubscription.manager.count($ticket == t && ($group == loop.group || $user == loop.user)) > 0):
			// ok
		case _:
			throw 'ACCESS ERROR: user ${loop.user.email} for ticket ${t.id}';
		}
		d.dispatch(new TicketRoutes(t));
	}
}

