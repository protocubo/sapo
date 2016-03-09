package sapo.route;

import sapo.spod.Survey;
import sapo.spod.User;
import common.db.MoreTypes;

class SurveyRoutes extends AccessControl {
	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doDefault(?args:{ ?user:User, ?status:SurveyStatus, ?order:String, ?page:Int })
	{
		var elementsPerPage = 20;
		
		if (args == null) args = { };
		//default values
		args.page = args.page == null?0:args.page;
		args.order = args.order == null?"desc":args.order;
		args.status = args.status == null? SSAll : args.status;
		
		var surveys = new List<Survey>(); 
		var users;
		
		if (args.user != null) 
		{
			//all supervisor's surveyors
			if (args.user.group.privilege.match(PSupervisor)) 
				users = Lambda.array(User.manager.search($supervisor == args.user)).map(function (i) return i.id);
			//single surveyor
			else 
				users = [args.user.id];			
		}
		//all surveyors
		else 
		{
			var group = Group.manager.select($privilege == PSurveyor);
			users = Lambda.array(User.manager.search($group == group)).map(function (i) return i.id);
		}
		surveys = PaymentRoutes.filterStates(users, args.page, elementsPerPage, args.status, args.order);
		var pagination = PaymentRoutes.setPagination(surveys, args.page, elementsPerPage);
		
		Sys.println(sapo.view.Surveys.page(surveys, args, pagination.showPrev, pagination.showNext));
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

