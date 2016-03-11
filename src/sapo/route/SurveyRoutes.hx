package sapo.route;

import common.Web;
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
		var privilege = Context.loop.privilege;
		if (args.user != null) 
		{
			//all supervisor's surveyors
			if (args.user.group.privilege.match(PSupervisor)) 
			{
				if(privilege == PSuperUser || privilege == PPhoneOperator || (privilege == PSupervisor && Context.loop.user == args.user))
					users = Lambda.array(User.manager.search($supervisor == args.user)).map(function (i) return i.id);
			}
			//single surveyor
			else if(privilege == PSuperUser || privilege == PPhoneOperator || Context.loop.user == args.user.supervisor)
				users = [args.user.id];
		}
		//all surveyors
		else 
		{
			
			if (privilege == PSuperUser || privilege == PPhoneOperator)
			{
				var group = Group.manager.select($privilege == PSurveyor);
				users = Lambda.array(User.manager.search($group == group)).map(function (i) return i.id);
			}	
			else
				users = Lambda.array(User.manager.search($supervisor == Context.loop.user, null, false).map(function(i) return i.id);
			
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
		switch(Context.loop.privilege)
		{
			case PSuperUser, PPhoneOperator:
				//Ok
			case PSupervisor:
				var u = User.manager.get(args.survey.user_id);
				if (u.supervisor == Context.loop.user)
					surveys.add(args.survey);
				else
					Web.redirect("/tickets");
					return;
			default:
				throw "Invalid permission!";
		}
		
		Sys.println(sapo.view.Surveys.page( surveys ));
	}

	@authorize(PSuperUser, PSupervisor, PPhoneOperator)
	public function doChangecheck(args:{ surveyid:Int, checkSV:Null<Bool>, checkCT:Null<Bool>, checkCQ:Null<Bool> })  // TODO only POST
	{
        var s = Survey.manager.select($id == args.surveyid);
		var user = User.manager.get(s.user_id, false);
        
		var changecheckSV = false;
        var changecheckCT = false;
        var changecheckCQ = false;
		
		var priv = Context.loop.privilege;
		switch(priv)
		{
			case PSupervisor:
				changecheckSV = (user.supervisor == Context.loop.user) ? true : false;
			case PSuperUser:
				changecheckSV = changecheckCT = changecheckCQ = true;
			case PPhoneOperator:
				changecheckCT = true;
			default:
				throw "Invalid permission";
		}
		
        if (changecheckSV || changecheckCT || changecheckCQ) 
		{
            s.lock();
            if (changecheckSV)  s.checkSV = args.checkSV;
            if (changecheckCT)  s.checkCT = args.checkCT;
            if (changecheckCQ)  s.checkCQ = args.checkCQ;
            s.update();
        }
		
		Web.redirect("/survey/" + s.id);
	}

	public function new() {}
}

