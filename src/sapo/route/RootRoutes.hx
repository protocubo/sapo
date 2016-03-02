package sapo.route;

import common.Dispatch;
import common.Web;
import common.db.MoreTypes;
import sapo.route.RegistrationRoutes;
import sapo.spod.Other;
import sapo.spod.Ticket;
import sapo.spod.User;

class RootRoutes extends AccessControl {
	function initialLocation(?user:User)
	{
		var priv = user == null ? Context.loop.privilege : user.group.privilege;
		return priv.match(PSurveyor) ? "/payments" : "/tickets";
	}

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
	{
		var url = args.redirect == null || args.redirect == "/" ? null : args.redirect;
		Sys.println(sapo.view.Login.render(url));
	}

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
		Web.redirect(args.redirect != null ? args.redirect : initialLocation(user));
	}

	@authorize(all)
	public function doBye()
	{
		Context.loop.session.expire();
		Web.redirect("/login");
	}

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doTickets(d:Dispatch)
		d.dispatch(new TicketRoutes());

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doSurveys(d:Dispatch)
		d.dispatch(new SurveyRoutes());

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doSurvey(s:NewSurvey)
		Sys.println(sapo.view.Survey.render(s));

	@authorize(PSupervisor, PSuperUser)
	public function doSummary(d : Dispatch)
		d.dispatch(new SummaryRoutes());
		//Sys.println(sapo.view.Summary.render());

	@authorize(PSurveyor, PSuperUser)
	public function doPayments(d:Dispatch)
	{
		switch Context.loop.privilege {
		case PSurveyor: Sys.println(sapo.view.Payments.surveyorPage());
		case PSuperUser: d.dispatch(new PaymentRoutes());
		case other: throw 'access control model failure: got $other';
		}
	}

	@authorize(PSuperUser)
	public function doRegistration(d:Dispatch)
		d.dispatch(new RegistrationRoutes());

	@authorize(all)
	public function doDefault()
		Web.redirect(initialLocation());

	public function new() { }
}

