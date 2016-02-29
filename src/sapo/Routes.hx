package sapo;

import common.Web;
import common.crypto.Random;
import common.db.MoreTypes.EmailAddress;
import haxe.web.Dispatch;
import sapo.Spod;

class TicketRoutes {
	public function doDefault(?args:{ ?inbox:String, ?recipient:String, ?state:String })
	{
		if (args == null) args = { };
		var u = Context.loop.user;		
		var tickets = Ticket.manager.search(
		(args.inbox == "out"? $author == u : 1 == 1) && // out-> individual
		(args.inbox == "in" && args.recipient == "individual"? /*to do: recipient == user*/ 1 == 1: 1 == 1) &&
		(args.inbox == "in" && args.recipient == "group"? /*to do: recipient == user.group*/ 1 == 1: 1 == 1) &&
		(args.state == "closed"? $closed_at != null:$closed_at == null)
		);
		Sys.println(sapo.view.Tickets.render(tickets));
	}

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

class SurveysRoutes
{
	public function doDefault(?args:{ ?group:String, ?user:String, ?valid:String, ?payment:String, ?status:String, ?order:String } )
	{
		if (args == null) args = { };
		
		var surveys = NewSurvey.manager.all();
		Sys.println(sapo.view.Surveys.render(surveys));
	}
	public function doSearch(?args:{ ?survey:NewSurvey })
	{
		if (args == null) args = { };
		var surveys : List<NewSurvey> = new List();
		if (args.survey != null)
			surveys.add(args.survey);
		Sys.println(sapo.view.Surveys.render( surveys ));
	}

	public function new() {}
}

class Routes
{
	public function doDefault()
	{
		if (Context.loop.session == null) Web.redirect("/login");
		Web.redirect("/tickets");
	}

	public function doTickets(d:Dispatch)
		d.dispatch(new TicketRoutes());

	public function doRegistration()
		Sys.println(sapo.view.Registration.render());

	public function doPayment()
		Sys.println(sapo.view.Payment.render());

	public function doPayments()
		Sys.println(sapo.view.Payments.render());

	public function doSummary()
		Sys.println(sapo.view.Summary.render());

	public function doSurveys(d:Dispatch)
		d.dispatch(new SurveysRoutes());

	public function doSurvey(s:sapo.NewSurvey)
		Sys.println(sapo.view.Survey.render(s));

	public function doLogin()
	{
		if (Web.getMethod() == "POST") {
			var p = Web.getParams();
			var email = p.get("email");
			var pass = p.get("password");

			var u = User.manager.search($email == new EmailAddress(email), null, false).first();
			if (u == null) {
				Web.redirect("default?error=" + StringTools.urlEncode("Usuário inválido!"));
				return;
			}
			//TODO: Validade password!
			if (!u.password.matches(pass)) {
				Web.redirect("default?error=" + StringTools.urlEncode("Senha inválida!"));
				return;
			}

			var s = new Session(u);
			s.insert();
			trace(s.expired());

			Web.setCookie(Session.COOKIE_KEY, s.id, s.expires_at);
			Web.redirect("/");
		} else {
			Sys.println(sapo.view.Login.render());
		}
	}

	public function doBye()
	{
		Context.loop.session.expire();
		Web.redirect("/login");
	}

	public function new() { }
}

