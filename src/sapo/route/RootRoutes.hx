package sapo.route;

import common.Dispatch;
import common.Web;
import common.crypto.Password;
import common.db.MoreTypes;
import sapo.route.RegistrationRoutes;
import sapo.spod.Other;
import sapo.spod.Ticket;
import sapo.spod.User;
import StringTools.urlEncode in urlEn;

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
			Web.redirect("/error?" +
					'title=${urlEn("O login falhou!")}' +
					'&message=${urlEn("O usuário não existe ou a senha não bate.  Por favor, corrija os dados e tente outra vez.")}');
			return;
		}

		var session = new Session(user);
		session.insert();
		Web.setCookie(Session.COOKIE_KEY, session.id, session.expires_at, null, "/", Web.isTora, true);
		Web.redirect(args.redirect != null ? args.redirect : initialLocation(user));
	}
	
	@authorize(all, guest)
	public function doError( ?args:{ ?title:String, ?message:String } )
	{
		if (args == null) args = { };
		Sys.println(sapo.view.Error.render(args.title, args.message));
	}

	@authorize(all, guest)
	public function doPwd(args : { token : String } )
	{
		if (args.token == null)
		{
			Web.redirect("/");
			return;
		}

		var t = Token.manager.get(args.token);
		if (t != null && !t.isExpired && t.expirationTime > Context.now)
			Sys.println(sapo.view.Password.render(args.token));
		else
			Web.redirect("/");
	}

	@authorize(all, guest)
	public function postPwd(args : { pass : String, confirm : String, token : String } )
	{
		if (args.pass != null && args.pass.length >= 6 && args.pass == args.confirm && args.token != null && args.token.length > 0)
		{
			var t = Token.manager.get(args.token, true);
			if (t != null)
			{
				t.user.lock();
				t.user.password = Password.make(args.pass);
				t.user.update();

				t.setExpired();
				t.update();
			}
		}

		Web.redirect("/");
	}

	@authorize(all, guest)
	public function postForgotPassword(args : {email : String})
	{
		var u = User.manager.select($email == new EmailAddress(args.email));
		if (u == null) {
			trace('WARNING: email ${args.email} not found');
			Web.redirect("/error?" +
					'title=${urlEn("Email não encontrado.")}' +
					'&message=${urlEn("O usuário não existe.  Por favor, corrija o endereço e tente outra vez.")}');
			return;
		}

		Context.db.startTransaction();
		try {
			Token.invalidate(u);
			var t = new Token(u);
			t.insert();

			var email = new comn.message.Email({
				from : "sapo@sapo.robrt.io",
				to : [u.email],
				subject : sapo.view.email.PasswordResetEmail.subject(),
				text : sapo.view.email.PasswordResetEmail.text(t.token)});
			Context.comn.enqueue(email);
		} catch (e:Dynamic) {
			Context.db.rollback();
			neko.Lib.rethrow(e);
		}
		Context.db.commit();
		Web.redirect("/login");
	}

	@authorize(all)
	public function doBye()
	{
		Context.loop.session.expire();
		Web.redirect("/login");
	}

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	var doTickets = TicketRoutes.doTicketsImpl;

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	var doTicket = TicketRoutes.doSingleTicketImpl;

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doSurveys(d:Dispatch)
		d.dispatch(new SurveyRoutes());

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doSurvey(s:sapo.spod.Survey)
		Sys.println(sapo.view.Survey.render(s));

	@authorize(PSupervisor, PSuperUser)
	public function doSummary(d : Dispatch)
		d.dispatch(new SummaryRoutes());

	@authorize(PSurveyor, PSuperUser)
	public function doPayments(d:Dispatch)
		d.dispatch(new PaymentRoutes());

	@authorize(PSuperUser)
	public function doRegistration(d:Dispatch)
		d.dispatch(new RegistrationRoutes());

	@authorize(all)
	public function doDefault()
		Web.redirect(initialLocation());

	public function new() { }
}

