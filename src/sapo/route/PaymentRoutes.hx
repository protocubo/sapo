package sapo.route;
import neko.Web;
import sapo.spod.Survey;
import sapo.spod.User;
import common.db.MoreTypes;

/**
 * ...
 * @author RV
 */
class PaymentRoutes extends AccessControl
{
	@authorize(PSuperUser)
	public function doDefault(?args:{ ?surveyor:User, ?paid:Bool, ?status:SurveyStatus, ?page:Int })
	{
		var elementsPerPage = 20;		
		if (args == null) args = { };
		//default values
		args.page = args.page == null?0:args.page;
		args.paid = args.paid == null?false:args.paid;
		args.status = args.status == null? SSAll : args.status;
		var users = [];
		if (args.surveyor == null)
		{			
			var group = Group.manager.select($privilege == PSurveyor);
			users = Lambda.array(User.manager.search($group == group)).map(function (i) return i.id);
		}
		else
			users = [args.surveyor.id];
		
		/*var surveys = Survey.manager.search(
			(args.surveyor == null? 1 == 1 : $user_id == args.surveyor.id) &&
			$paid == args.paid
		);*/
		
		var surveys = filterStates(users, args.page, elementsPerPage, args.status, "cres", args.paid);		
		var pagination = setPagination(surveys, args.page, elementsPerPage);
		Sys.println(sapo.view.Payments.superPage(surveys,args, pagination.showPrev, pagination.showNext ));
	}
	
	function setPagination(surveys:List<Survey>, page:Int, elementsPerPage:Int)
	{
		var showPrev = page == 0?false:true;
		var showNext = false;
		if (surveys.length == elementsPerPage+1)
		{
			surveys.pop();
			showNext = true;
		}
		return { showPrev:showPrev, showNext:showNext }
	}
	
	
	function filterStates(users:Array<Int>, page:Int, elementsPerPage:Int, status:SurveyStatus, ?order:String="cres", ?paid:Bool = null)
	{
		
		var surveys = new List<Survey>(); 
		if (order == "cres")
		{
			switch status 
			{
				//all checks true
				case SSAccepted:
				{
					surveys = Survey.manager.search(
						(paid == null? 1==1 : $paid==paid) &&
						($user_id in users) && 
						($checkSV && $checkCT && $checkCQ)
						,{ orderBy : date_completed, limit : [elementsPerPage * page, elementsPerPage+1 ] } );
				};
				//all checks false
				case SSRefused:
				{
					surveys = Survey.manager.search(
						(paid == null? 1==1 : $paid==paid) &&
						($user_id in users) && 
						($checkSV == false && $checkCT == false && $checkCQ == false)
						,{ orderBy : date_completed, limit : [elementsPerPage * page, elementsPerPage+1 ] } );
				};
				//any check false && all checks not false
				case SSPending:
				{
					surveys = Survey.manager.search(
						(paid == null? 1==1 : $paid==paid) &&
						($user_id in users) && 
						($checkSV==false || $checkCT==false || $checkCQ==false) &&
						($checkSV==false && $checkCT==false && $checkCQ==false) == false
						,{ orderBy : date_completed, limit : [elementsPerPage * page, elementsPerPage+1 ] } );
				};
				//any check not false && all checks not true
				case SSCompleted:
				{
					surveys = Survey.manager.search(
						(paid == null? 1==1 : $paid==paid) &&
						($user_id in users) && 
						($checkSV != false || $checkSV == null) &&
						($checkCT != false || $checkCT == null) &&
						($checkCQ != false || $checkCQ == null)
						,{ orderBy : date_completed, limit : [elementsPerPage * page, elementsPerPage+1 ] } );
				};
				//all
				case SSAll:
				{
					surveys = Survey.manager.search(
						(paid == null? 1==1 : $paid==paid) &&
						($user_id in users)
						,{ orderBy : date_completed, limit : [elementsPerPage * page, elementsPerPage+1 ] } );
				};
			}
		}
		else
		{
			switch status 
			{
				//all checks true
				case SSAccepted:
				{
					surveys = Survey.manager.search(
						(paid == null? 1==1 : $paid==paid) &&
						($user_id in users) && 
						($checkSV && $checkCT && $checkCQ)
						,{ orderBy : -date_completed, limit : [elementsPerPage * page, elementsPerPage+1 ] } );
				};
				//all checks false
				case SSRefused:
				{
					surveys = Survey.manager.search(
						(paid == null? 1==1 : $paid==paid) &&
						($user_id in users) && 
						($checkSV == false && $checkCT == false && $checkCQ == false)
						,{ orderBy : -date_completed, limit : [elementsPerPage * page, elementsPerPage+1 ] } );
				};
				//any check false && all checks not false
				case SSPending:
				{
					surveys = Survey.manager.search(
						(paid == null? 1==1 : $paid==paid) &&
						($user_id in users) && 
						($checkSV==false || $checkCT==false || $checkCQ==false) &&
						($checkSV==false && $checkCT==false && $checkCQ==false) == false
						,{ orderBy : -date_completed, limit : [elementsPerPage * page, elementsPerPage+1 ] } );
				};
				//any check not false && all checks not true
				case SSCompleted:
				{
					surveys = Survey.manager.search(
						(paid == null? 1==1 : $paid==paid) &&
						($user_id in users) && 
						($checkSV != false || $checkSV == null) &&
						($checkCT != false || $checkCT == null) &&
						($checkCQ != false || $checkCQ == null)
						,{ orderBy : -date_completed, limit : [elementsPerPage * page, elementsPerPage+1 ] } );
				};
				//all
				case SSAll:
				{
					surveys = Survey.manager.search(
						(paid == null? 1==1 : $paid==paid) &&
						($user_id in users)
						,{ orderBy : -date_completed, limit : [elementsPerPage * page, elementsPerPage+1 ] } );
				};
			}
		}
		return surveys;		
	}

	@authorize(PSuperUser)
	public function doSearch(?args:{ ?survey:Survey, ?reference:String })
	{
		if (args == null) args = { };
		var surveys = new List<Survey>();
		if (args.survey != null)
			surveys.add(args.survey);
		if (args.reference !=  null)
			surveys = Survey.manager.search($paymentRef == args.reference);

		Sys.println(sapo.view.Payments.superPage(surveys));
	}

	@authorize(PSuperUser)
	public function doPay(?args:{ ?toPay:String, ?reference:String })  // TODO only POST
	{
		if (args == null) args = { };
		if (args.toPay.length > 1)
		{
			var ids = args.toPay.split("e");
			for (id in ids)
			{
				if (Std.parseInt(id) == null)
					continue;
				var s = Survey.manager.get(Std.parseInt(id));
				if (s.paid != null)
				{
					s.lock();
					s.paymentRef = args.reference;
					s.date_paid = Context.now;
					s.paid = true;
					s.update();
				}
			}
		}

		var surveys = new List<Survey>();
		Web.redirect("/payments");
	}

	public function new() {}

}
