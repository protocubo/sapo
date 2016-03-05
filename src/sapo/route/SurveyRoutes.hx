package sapo.route;

import sapo.spod.Survey;
import sapo.spod.User;

class SurveyRoutes extends AccessControl {
	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doDefault(?args:{ ?user:Int, ?status:String, ?order:String })
	{
		if (args == null) args = { };
		
		var surveys = Survey.manager.search(
				(args.user == 0 ? 1 == 1: $user_id == args.user)
				, { orderBy : date_completed });  // TODO orderBy, date, pages

		Sys.println(sapo.view.Surveys.page(surveys));
	}

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doSearch(?args:{ ?survey:Survey })
	{
		if (args == null) args = { };
		var surveys : List<Survey> = new List();
		if (args.survey != null)
			surveys.add(args.survey);
		Sys.println(sapo.view.Surveys.page( surveys ));
	}

	public function new() {}
}

