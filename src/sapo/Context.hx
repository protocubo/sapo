package sapo;
import common.db.MoreTypes.Privilege;
import common.Web;
import sapo.Spod.AccessLevel;
import sapo.Spod.Group;
import sapo.Spod.Session;
import sapo.Spod.User;

/**
 * ...
 * @author Caio
 */
class Context
{
	public var user(default, null) : User;
	public var group(default, null) : Group;
	public var privilege(default, null) : Privilege;
	
	public function new() 
	{
		var sid = Web.getCookies().get("session_id");
		var u = Session.manager.get(sid);
		if (u != null)
		{
			this.user = u.user;
			this.group = u.user.group;
			this.privilege = u.user.group.privilege;
		}
	}
	
}
