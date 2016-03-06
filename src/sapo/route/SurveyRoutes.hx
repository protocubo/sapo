package sapo.route;

import sapo.spod.Survey;
import sapo.spod.User;
import common.db.MoreTypes;

class SurveyRoutes extends AccessControl {
	@authorize(PSupervisor, PPhoneOperator, PSuperUser)
	public function doDefault(?args:{ ?user:Int, ?status:String, ?order:String, ?page:Int })
	{
		var elementsPerPage = 20;
		
		if (args == null) args = { };
		//default values
		args.page = args.page == null?0:args.page;	
		args.user = args.user == null?0: args.user;
		
		var surveys = new List<Survey>();
		
		switch state
		{
			case SSAccepted:
			{

			};
			case SSRefused:
			{
				ct = false;
				sv = false;
				cq = false;
			};
			case SSCompleted:
			{
				ct = null;
				sv = null;
				cq = null;
			};
			case SSPending
		}
		
		
		
		//search All
		if (args.user == 0)
		{
			surveys = Survey.manager.search(
				1==1
				, { orderBy : date_completed, limit : [elementsPerPage * args.page, elementsPerPage+1 ] } );  // TODO orderBy, date, pages
		}
		//Search Surveyor
		else
		{
			var user = User.manager.get(args.user);
			if (user.group.privilege == PSurveyor)
			{
				
			}
			//Search for all surveys from supervisor
			else if(user.group.privilege == PSupervisor)
			{
				//var surveyors = User.manager.search($supervisor == user);
				//for ( u in surveyors)
				//{
				//	var surveyorSurveys = Survey.manager.search($user_id == u.id);
				//	for (s in surveyorSurveys)
				//		surveys.push(s);
				//}
			}
		}
		
				
		
				
		var showPrev = args.page == 0?false:true;
		var showNext = false;
		if (surveys.length == elementsPerPage+1)
		{
			surveys.pop();
			showNext = true;
		}

		Sys.println(sapo.view.Surveys.page(surveys, args, showPrev, showNext));
	}
	
	public function asdasdStatus(surveys:List<Survey>, state:SurveyStatus)
	{
		var ct, sv, cq;
		var filtered = new List<Survey>();
		for (s in surveys)
		{
			switch state
			{
				case SSAccepted:
				{

				};
				case SSRefused:
				{
					ct = false;
					sv = false;
					cq = false;
				};
				case SSCompleted:
				{
					ct = null;
					sv = null;
					cq = null;
				};
			}
		}
		
		
		return {ct:ct, sv:sv,cq:cq}
		
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

