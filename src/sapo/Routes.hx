package sapo;

import haxe.web.Dispatch;
import neko.Web;
import sapo.Spod;

class TinkRoutes {
	public function doTicket()
		Sys.println(sapo.view.Ticket.render());
		
	public function doLogin()
		Sys.println(sapo.view.Login.render());

	public function doDefault()
		Sys.println(sapo.view.Summary.render());
		
	public function doRegistration()
		Sys.println(sapo.view.Registration.render());
		
	public function doPayment()
		Sys.println(sapo.view.Payment.render());

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

