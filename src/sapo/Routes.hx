package sapo;
import common.db.MoreTypes.Privilege;
import common.Web;
import common.crypto.Random;
import common.db.MoreTypes.EmailAddress;
import haxe.web.Dispatch;
import sapo.Spod;

@:build(sapo.MetaMacros.ReplaceMeta())
class TicketRoutes {
	@noauth
	public function doDefault(?args:{ ?ofUser:User, ?inbox:String, ?recipient:String, ?state:String })
	{
		if (args == null) args = { };
		var tickets : List<Spod.Ticket> = new List();

		Sys.println(sapo.view.Tickets.render(tickets));
	}

	@:authbuild("PPhoneOperator", "PSuper", "PSupervisor")
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

@:build(sapo.MetaMacros.ReplaceMeta())
class SurveysRoutes
{
	@authbuild("PPhoneOperator", "PSuper", "PSupervisor")
	public function doDefault()
	{
		var surveys = NewSurvey.manager.all();
		Sys.println(sapo.view.Surveys.render(surveys));
	}
	@authbuild("PPhoneOperator", "PSuper", "PSupervisor")
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

@:build(sapo.MetaMacros.ReplaceMeta())
class Routes
{
	@noAuth()
	public function doDefault()
	{
		if (Context.loop.session == null) Web.redirect("/login");
		Web.redirect("/tickets");
	}
	
	@:authbuild(PPhoneOperator, PSuper, "PSupervisor")
	public function doTickets(d:Dispatch)
		d.dispatch(new TicketRoutes());
		
	@:authbuild("PPhoneOperator", "PSuper", "PSupervisor")
	public function doRegistration()
		Sys.println(sapo.view.Registration.render());
		
	@:authbuild("PPhoneOperator", "PSuper", "PSupervisor")
	public function doPayment()
		Sys.println(sapo.view.Payment.render());
		
	@:authbuild("PSurveyor")
	public function doPayments()
		Sys.println(sapo.view.Payments.render());

	@:authbuild("PSurveyor", "PSupervisor", "PPhoneOperator", "PSuper")
	public function doSummary()
		Sys.println(sapo.view.Summary.render());
	
	@:authbuild("PPhoneOperator", "PSuper", "PSupervisor")
	public function doSurveys(d:Dispatch)
		d.dispatch(new SurveysRoutes());
	
	@:authbuild("PPhoneOperator", "PSuper", "PSupervisor")
	public function doSurvey(s:sapo.NewSurvey)
		Sys.println(sapo.view.Survey.render(s));

	@noauth	
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

	@noauth
	public function doBye()
	{
		Context.loop.session.expire();
		Web.redirect("/login");
	}

	public function new() { }
}

