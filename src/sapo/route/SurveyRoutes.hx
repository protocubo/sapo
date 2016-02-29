package sapo.route;

import common.spod.*;
import sapo.spod.Other;

class SurveyRoutes extends AccessControl {
	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doDefault(?args:{ ?group:String, ?user:String, ?valid:String, ?payment:String, ?status:String, ?order:String })
	{
		if (args == null) args = { };
		
		var surveys = NewSurvey.manager.all();
		Sys.println(sapo.view.Surveys.render(surveys));
	}

	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doSearch(?args:{ ?survey:Survey })
	{
		if (args == null) args = { };
		var surveys : List<NewSurvey> = new List();
		if (args.survey != null)
			surveys.add(args.survey);
		Sys.println(sapo.view.Surveys.render( surveys ));
	}

	public function new() {}
}

