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
		args.order = args.order == null?"cres":args.order;
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
		
		//switch survey status
		if (args.order == "cres")
		{
			switch args.status 
			{
				//all checks true
				case SSAccepted:
				{
					surveys = Survey.manager.search(
						($user_id in users) && 
						($checkSV && $checkCT && $checkCQ)
						,{ orderBy : date_completed, limit : [elementsPerPage * args.page, elementsPerPage+1 ] } );
				};
				//all checks false
				case SSRefused:
				{
					surveys = Survey.manager.search(
						($user_id in users) && 
						($checkSV == false && $checkCT == false && $checkCQ == false)
						,{ orderBy : date_completed, limit : [elementsPerPage * args.page, elementsPerPage+1 ] } );
				};
				//any check false && all checks not false
				case SSPending:
				{
					surveys = Survey.manager.search(
						($user_id in users) && 
						($checkSV==false || $checkCT==false || $checkCQ==false) &&
						($checkSV==false && $checkCT==false && $checkCQ==false) == false
						,{ orderBy : date_completed, limit : [elementsPerPage * args.page, elementsPerPage+1 ] } );
				};
				//any check not false && all checks not true
				case SSCompleted:
				{
					surveys = Survey.manager.search(
						($user_id in users) && 
						($checkSV != false || $checkSV == null) &&
						($checkCT != false || $checkCT == null) &&
						($checkCQ != false || $checkCQ == null)
						,{ orderBy : date_completed, limit : [elementsPerPage * args.page, elementsPerPage+1 ] } );
				};
				//all
				case SSAll:
				{
					surveys = Survey.manager.search(
						($user_id in users)
						,{ orderBy : date_completed, limit : [elementsPerPage * args.page, elementsPerPage+1 ] } );
				};
			}
		}
		else
		{
			switch args.status 
			{
				//all checks true
				case SSAccepted:
				{
					surveys = Survey.manager.search(
						($user_id in users) && 
						($checkSV && $checkCT && $checkCQ)
						,{ orderBy : -date_completed, limit : [elementsPerPage * args.page, elementsPerPage+1 ] } );
				};
				//all checks false
				case SSRefused:
				{
					surveys = Survey.manager.search(
						($user_id in users) && 
						($checkSV == false && $checkCT == false && $checkCQ == false)
						,{ orderBy : -date_completed, limit : [elementsPerPage * args.page, elementsPerPage+1 ] } );
				};
				//any check false && all checks not false
				case SSPending:
				{
					surveys = Survey.manager.search(
						($user_id in users) && 
						($checkSV==false || $checkCT==false || $checkCQ==false) &&
						($checkSV==false && $checkCT==false && $checkCQ==false) == false
						,{ orderBy : -date_completed, limit : [elementsPerPage * args.page, elementsPerPage+1 ] } );
				};
				//any check not false && all checks not true
				case SSCompleted:
				{
					surveys = Survey.manager.search(
						($user_id in users) && 
						($checkSV != false || $checkSV == null) &&
						($checkCT != false || $checkCT == null) &&
						($checkCQ != false || $checkCQ == null)
						,{ orderBy : -date_completed, limit : [elementsPerPage * args.page, elementsPerPage+1 ] } );
				};
				//all
				case SSAll:
				{
					surveys = Survey.manager.search(
						($user_id in users)
						,{ orderBy : -date_completed, limit : [elementsPerPage * args.page, elementsPerPage+1 ] } );
				};
			}
		}
		
		//all
		/*if(args.order == "cres")
			surveys = Survey.manager.search(
				($user_id in users)
				,{ orderBy : date_completed, limit : [elementsPerPage * args.page, elementsPerPage+1 ] } );
		else
			surveys = Survey.manager.search(
				($user_id in users)
				,{ orderBy : -date_completed, limit : [elementsPerPage * args.page, elementsPerPage+1 ] } );*/
		//pagination		
		var showPrev = args.page == 0?false:true;
		var showNext = false;
		if (surveys.length == elementsPerPage+1)
		{
			surveys.pop();
			showNext = true;
		}

		Sys.println(sapo.view.Surveys.page(surveys, args, showPrev, showNext));
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

