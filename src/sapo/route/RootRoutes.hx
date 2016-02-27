package sapo.route;

import common.Dispatch;
import common.Web;
import common.db.MoreTypes;
import sapo.Spod;

class RootRoutes implements AccessControl {
	@authorizeAll
	public function doDefault()
	{
		if (Context.loop.session == null) Web.redirect("/login");
		Web.redirect("/tickets");
	}

	@authorize(PPhoneOperator, PSuper, "PSupervisor")
	public function doTickets(d:Dispatch)
		d.dispatch(new TicketRoutes());

	@authorize("PPhoneOperator", "PSuper", "PSupervisor")
	public function doRegistration()
		Sys.println(sapo.view.Registration.render());

	@authorize("PPhoneOperator", "PSuper", "PSupervisor")
	public function doPayment()
		Sys.println(sapo.view.Payment.render());

	@authorizeAll
	public function doAbout()
		Sys.println(sapo.view.About.render());

	@authorizeAll
	public function doHelp()
		Sys.println(sapo.view.Help.render());

	@authorizeAll
	public function doLicenses()
	Sys.println(sapo.view.Licenses.render());

	@authorize("PSurveyor")
	public function doPayments()
		Sys.println(sapo.view.Payments.render());

	@authorize("PSurveyor", "PSupervisor", "PPhoneOperator", "PSuper")
	public function doSummary()
		Sys.println(sapo.view.Summary.render());

	@authorize("PPhoneOperator", "PSuper", "PSupervisor")
	public function doSurveys(d:Dispatch)
		d.dispatch(new SurveyRoutes());

	@authorize("PPhoneOperator", "PSuper", "PSupervisor")
	public function doSurvey(s:sapo.NewSurvey)
		Sys.println(sapo.view.Survey.render(s));

	@authorizeAll
	public function doLogin()
		Sys.println(sapo.view.Login.render());

	@authorizeAll
	public function postLogin()
	{
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
	}

	@authorizeAll
	public function doBye()
	{
		Context.loop.session.expire();
		Web.redirect("/login");
	}

	public function new() { }
}

