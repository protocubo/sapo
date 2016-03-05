package sapo.route;
import neko.Web;
import sapo.spod.Survey;
import sapo.spod.User;

/**
 * ...
 * @author RV
 */
class PaymentRoutes extends AccessControl
{
	@authorize(PSuperUser)
	public function doDefault(?args:{ ?surveyor:Int, ?paid:Bool, ?state:String })
	{
		if (args == null) args = { };
		if (args.surveyor == null) { args.surveyor = 0; }
		var surveys = Survey.manager.search(
			(args.surveyor == 0? 1 == 1 : $user_id == args.surveyor) &&
			$paid == args.paid
			// to do survey state
		);
		trace("LENGHT: " + surveys.length);
		Sys.println(sapo.view.Payments.superPage(surveys));
	}
	
	@authorize(PSuperUser)
	public function doSearch(?args:{ ?survey:Survey, ?reference:String })
	{
		if (args == null) args = { };
		var surveys = new List<Survey>();
		if (args.survey != null)
			surveys.add(args.survey);
		if (args.reference !=  null)
			surveys = Survey.manager.search($paymentRef == args.reference);
			
		Sys.println(sapo.view.Payments.superPage(surveys));
	}
	
	@authorize(PSuperUser)
	public function doPay(?args:{ ?toPay:String, ?reference:String })
	{
		if (args == null) args = { };
		if (args.toPay.length > 1)
		{
			var ids = args.toPay.split("e");
			for (id in ids)
			{
				if (Std.parseInt(id) == null)
					continue;
				var s = Survey.manager.get(Std.parseInt(id));
				if (s.paid != null)
				{
					s.lock();
					s.paymentRef = args.reference;
					s.date_paid = Context.now;
					s.paid = true;
					s.update();
				}
			}
		}
		
		var surveys = new List<Survey>();
		Web.redirect("/payments");
	}
	
	public function new() {}
	
}
