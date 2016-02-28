package sapo.route;

import common.spod.*;
import sapo.spod.Other;

class SurveyRoutes extends AccessControl {
	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doDefault()
	{
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
		Sys.println(sapo.view.Surveys.page(surveys));
	}

	public function new() {}
}

