package sapo.route;

import common.Dispatch;
import common.Web;
import common.db.MoreTypes;
import sapo.spod.Other;
import sapo.spod.Ticket;
import sapo.spod.User;

class RootRoutes extends AccessControl {
	function initialLocation()
		return Context.loop.privilege.match(PSurveyor) ? "/payments" : "/tickets";

	@authorize(all, guest)
	public function doAbout()
		Sys.println(sapo.view.About.render());

	@authorize(all, guest)
	public function doHelp()
		Sys.println(sapo.view.Help.render());

	@authorize(all, guest)
	public function doLicenses()
		Sys.println(sapo.view.Licenses.render());

	@authorize(all, guest)
	public function doLogin(args:{ ?redirect:String })
		Sys.println(sapo.view.Login.render(args.redirect));

	@authorize(all, guest)
	public function postLogin(args:{ email:String, password:String, ?redirect:String })
	{
		var user = User.manager.select($email == new EmailAddress(args.email));
		if (user == null || !user.password.matches(args.password)) {
			trace('User "${args.email}" ' + (user == null ? "unknown" : "known, but password did not match"));
			Web.redirect('default?error=${StringTools.urlEncode("Usuário ou senha inválidos")}');
			return;
		}

		var session = new Session(user);
		session.insert();
		Web.setCookie(Session.COOKIE_KEY, session.id, session.expires_at, null, "/", Web.isTora, true);
		Web.redirect(args.redirect != null ? args.redirect : initialLocation());
	}

	@authorize(all)
	public function doBye()
	{
		Context.loop.session.expire();
		Web.redirect("/login");
	}

	@authorize(PSupervisor, PPhoneOperator, PSuper)
	public function doTickets(d:Dispatch)
		d.dispatch(new TicketRoutes());

	@authorize(PSupervisor, PPhoneOperator, PSuper)
	public function doSurveys(d:Dispatch)
		d.dispatch(new SurveyRoutes());

	@authorize(PSupervisor, PPhoneOperator, PSuper)
	public function doSurvey(s:NewSurvey)
		Sys.println(sapo.view.Survey.render(s));

	@authorize(PSupervisor, PSuper)
	public function doSummary()
		Sys.println(sapo.view.Summary.render());

	@authorize(PSurveyor, PSuper)
	public function doPayments()
	{
		switch Context.loop.privilege {
		case PSurveyor: Sys.println(sapo.view.Payments.surveyorPage());
		case PSuper: Sys.println(sapo.view.Payments.superPage());
		case other: throw 'access control model failure: got $other';
		}
	}

	@authorize(PSuper)
	public function doRegistration()
		Sys.println(sapo.view.Registration.render());

	@authorize(all)
	public function doDefault()
		Web.redirect(initialLocation());

	public function new() { }
}

