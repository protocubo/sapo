package sapo.route;
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
		var surveys = Survey.manager.search(
			(args.surveyor == 0? 1 == 1 : $user_id == args.surveyor) &&
			$paid == args.paid
			// to do survey state
		);
		Sys.println(sapo.view.Payments.superPage());
	}
	
	@authorize(PSuperUser)
	public function doSearch(?args:{ ?survey:Survey, ?reference:String })
	{
		if (args == null) args = { };
		var surveys = new List<Survey>();
		if (args.survey != null)
			surveys.add(args.survey);
		if (args.reference !=  null)
		{}//select reference
			
		Sys.println(sapo.view.Payments.superPage());
	}
	
	public function new() {}
	
}