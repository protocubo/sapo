package sapo.route;

import common.Web;
import common.crypto.Password;
import common.db.MoreTypes;
import comn.LocalEnqueuer;
import sapo.spod.User;
import sys.db.Manager;

class RegistrationRoutes extends AccessControl {
	public static inline var PARAM_ACTIVE = "active";
	public static inline var PARAM_DEACTIVATED = "deactivated";

	@authorize(PSuperUser)
	public function doDefault(?args:{ ?activeFilter:String, ?page:Int })
	{
		var elementsPerPage = 20;
		if (args == null) args = { };
		args.page = args.page == null?0:args.page;
		args.activeFilter = args.activeFilter == null?PARAM_ACTIVE: args.activeFilter;
		var users = new List<User>();
		users = User.manager.search(
			(args.activeFilter == PARAM_DEACTIVATED ? $deactivated_at != null : $deactivated_at == null),
			{ orderBy : name, limit : [elementsPerPage * args.page, elementsPerPage+1 ] }
		);
		var showPrev = args.page == 0?false:true;
		var showNext = false;
		if (users.length == elementsPerPage+1)
		{
			users.pop();
			showNext = true;
		}
		Sys.println(sapo.view.Registration.page(users, args, showPrev, showNext));
	}

	@authorize(PSuperUser)
	public function postEdit(?args:{ ?user:User, ?name:String, ?group:Group, ?supervisor:User })
	{
		//OK TODO superuser can't disable or change group of other superusers
		//OK TODO supervisors can't have their group changed (or be disabled) if they have active surveyors
		// TODO add "selecione" to UI elements
		if (args == null) args = { };
		var u = args.user;
		u.lock();
		u.name = args.name;
		//cant change if is Super
		if (u.group.privilege != PSuperUser)
		{	
			//check if supervisor has subordinates
			if (u.group.privilege == PSupervisor)
			{
				
				var sub = User.manager.search($supervisor == u);
				if (sub.length == 0)
				{
					u.group = args.group;
					u.supervisor = (args.supervisor != null? args.supervisor:null);
				}				
			}
			else 
			{
				u.group = args.group;
				u.supervisor = (args.supervisor != null? args.supervisor:null);
			}
		}
		//supervisor=null if changed from surveyor
		if (u.group.privilege != PSurveyor)
			u.supervisor = null;
		
		u.update();	
		Web.redirect("/registration");
	}

	@authorize(PSuperUser)
	public function postAdd(?args:{ ?name:String, ?email:String, ?group:Group, ?supervisor:User })
	{
		if (args == null) args = { };
		Context.db.startTransaction();
		try {
			var u = new User(args.group, new EmailAddress(args.email), args.name, (args.supervisor != null? args.supervisor:null));
			u.insert();

			Token.invalidate(u);
			var t = new Token(u);
			t.insert();

			var email = new comn.message.Email({
				from : "sapo@sapo.robrt.io",
				to : [u.email],
				subject : sapo.view.email.PasswordResetEmail.subject(),
				text : sapo.view.email.PasswordResetEmail.text(t.token)});
			Context.comn.enqueue(email);
		} catch (e:Dynamic) {
			Context.db.rollback();
			neko.Lib.rethrow(e);
		}
		Context.db.commit();
		Web.redirect("/registration");
	}

	@authorize(PSuperUser)
	public function postDeactivate(?args:{ ?user:User })
	{
		if (args == null) args = { };
		args.user.lock();
		args.user.deactivated_at = Context.now;
		args.user.update();
		Web.redirect("/registration");
	}

	public function new() {}
}
