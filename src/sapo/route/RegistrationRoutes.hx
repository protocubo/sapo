package sapo.route;
import common.crypto.Password;
import common.db.MoreTypes.EmailAddress;
import neko.Web;
import sapo.spod.User;

/**
 * ...
 * @author RV
 */
class RegistrationRoutes extends AccessControl {
	@authorize(PSuperUser)
	public function doDefault(?args:{ ?activeFilter:String })
	{
		if (args == null) args = { };
		var users = new List<User>();
		if(args.activeFilter == "deactivated")
			users = User.manager.search($deactivated_at != null);
		else
			users = User.manager.search($deactivated_at == null);
		Sys.println(sapo.view.Registration.page(users));
	}

	@authorize(PSuperUser)
	public function doEdit(?args:{ ?user:User, ?name:String, ?email:String, ?group:Group, ?supervisor:User })
	{
		if (args == null) args = { };
		var u = args.user;
		
		u.lock();
		u.name = args.name;
		u.email = new EmailAddress(args.email);
		u.group = args.group;
		u.supervisor = (args.supervisor != null? args.supervisor:null);
		u.update();
		Web.redirect("/registration");
	}
	@authorize(PSuperUser)
	public function doAdd(?args:{ ?name:String, ?email:String, ?group:Group, ?supervisor:User })
	{
		if (args == null) args = { };
		var u = new User(args.group, new EmailAddress(args.email), args.name, (args.supervisor != null? args.supervisor:null));
		u.insert();
		
		Web.redirect("/registration");
	}
	@authorize(PSuperUser)
	public function doDeactivate(?args:{ ?user:User })
	{
		if (args == null) args = { };
		args.user.lock();
		args.user.deactivated_at = Context.now;
		args.user.update();
		Web.redirect("/registration");
	}
	
	@authorize(all)
	public function doChangepassword(args : { token : String } )
	{
		if (args.token == null)
		{
			Web.redirect("index");
			return;
		}
		
		var t = Token.manager.get(args.token);
		if (t != null && !t.isExpired && t.expirationTime > Context.now)
			Sys.println(sapo.view.Password.render(args.token));
		else
			Web.redirect("index");
		
		
	}
	
	@authorize(all)
	public function postChange(args : { pass : String, confirm : String, token : String } )
	{
		if (args.pass != null && args.pass.length >= 6 && args.pass == args.confirm && args.token != null && args.token.length > 0)
		{
			var t = Token.manager.get(args.token, true);
			if (t != null)
			{
				t.user.password = Password.make(args.pass);
				t.update();
			}
		}
		
		Web.redirect("index");
	}
	public function new() {}
}
