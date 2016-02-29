package sapo.route;

import sapo.spod.Survey;
import sapo.spod.User;

class SurveyRoutes extends AccessControl {
	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doDefault(?args:{ ?group:String, ?user:User, ?valid:String, ?payment:String, ?status:String, ?order:String })
	{
		
		if (args == null) args = { };
		
		var surveys = Survey.manager.search(
		(args.valid == "all" ? (args.valid == "yes" ? $isValid == true: $isValid == false) : 1 == 1) &&
		(args.payment == "all" ? (args.payment == "yes" ? $paid == true: $paid == false) : 1 == 1)
		//Group and user (spod not implemented yet)
		, { orderBy : id } //need to make
		);

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

