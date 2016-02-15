package sapo;

import haxe.web.Dispatch;
import neko.Web;
import sapo.Spod;

class TinkRoutes {
	public function doTicket(t:Ticket)
		Sys.println(sapo.view.tink.Ticket.render(t));

	public function doDefault()
		Sys.println(sapo.view.tink.Summary.render());

	public function new() {}
}

class ErazorRoutes {
	public function doTicket(t:Ticket)
		Sys.println(new sapo.view.erazor.Ticket(t).execute());

	public function doDefault()
		Sys.println(new sapo.view.erazor.Summary().execute());

	public function new() {}
}

class Routes {
	public function doDefault()
	{
		Sys.println("<!DOCTYPE html><html>");
		Sys.println("<head><title>SAPO</title></head>");
		Sys.println("<body>");
		Sys.println("<p>Do you want to see a <a href='tink'><code>tink_template</code></a> or a <a href='erazor'><code>erazor</code></a> template example?</p>");
		Sys.println("<p>You can also <a href='reset'>reset</a> your db</a></p>");
		Sys.println("</body>");
		Sys.println("</html>");
	}

	public function doReset()
	{
		Index.dbReset();
		Web.redirect("/");
	}

	public function doTink(d:Dispatch)
		d.dispatch(new TinkRoutes());

	public function doErazor(d:Dispatch)
		d.dispatch(new ErazorRoutes());

	public function new() {}
}

