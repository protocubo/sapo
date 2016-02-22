package sapo;

import haxe.web.Dispatch;
import neko.Web;
import sapo.Spod;

class TinkRoutes {
	public function doTickets(?args:{ ?ofUser:User })
	{
		if (args == null) args = {};
		Sys.println(sapo.view.Tickets.render(args.ofUser));
	}
		
	public function doLogin()
		Sys.println(sapo.view.Login.render());

	public function doDefault()
		Sys.println(sapo.view.Summary.render());
		
	public function doRegistration()
		Sys.println(sapo.view.Registration.render());
		
	public function doPayment()
		Sys.println(sapo.view.Payment.render());
		
	// public function doSurveys()
	// 	Sys.println(sapo.view.Surveys.render());
	
	// public function doSurvey(s:sapo.Survey)
	// 	Sys.println(sapo.view.Survey.render(s));

	public function new() {}
}

class Routes {
	public function doDefault()
	{
		Web.redirect("/tink/login");
	}

	public function doReset()
	{
		Index.dbReset();
		Web.redirect("/");
	}

	public function doTink(d:Dispatch)
		d.dispatch(new TinkRoutes());

	public function new() {}
}

