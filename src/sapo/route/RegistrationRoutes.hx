package sapo.route;
import neko.Web;
import sapo.spod.User;

/**
 * ...
 * @author RV
 */
class RegistrationRoutes extends AccessControl {
	@authorize(PSuperUser)
	public function doDefault(?args:{ ?active:String })
	{
		if (args == null) args = { };
		var users;
		if(args.active == "deactivated")
			users = User.manager.search($deactivated_at != null);
		else
			users = User.manager.search($deactivated_at == null);
		Sys.println(sapo.view.Registration.page(users));
	}

	@authorize(PSuperUser)
	public function doEdit(?args:{ ?user:User, ?name:String, ?email:String, ?group:Group, ?supervisor:User })
	{
		if (args == null) args = { };
		
		Web.redirect("/registration");
	}
	@authorize(PSuperUser)
	public function doAdd(?args:{ ?user:User, ?name:String, ?email:String, ?group:Group, ?supervisor:User })
	{
		if (args == null) args = { };
		
		//Web.redirect("/registration");
	}
	@authorize(PSuperUser)
	public function doDeactivate(?args:{ ?user:User })
	{
		if (args == null) args = { };
		
		//Web.redirect("/registration");
	}

	public function new() {}
}
