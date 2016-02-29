package sapo.route;

import sapo.spod.Survey;

class SurveyRoutes extends AccessControl {
	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doDefault(?args:{ ?group:String, ?user:String, ?valid:String, ?payment:String, ?status:String, ?order:String })
	{
		if (args == null) args = { };
		
		var surveys = Survey.manager.all();
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

