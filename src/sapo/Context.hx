package sapo;
import neko.Web;
import sapo.Spod.User;

/**
 * ...
 * @author Caio
 */
class Context
{

	public function new() 
	{
		
	}
	
	
	public static function getUser() : User
	{
		var sess_id = Web.getClientHeader("session_id");
		var session = 
		if (sess_id == null || sess_id == "")
			return null;
			
		return null;
	}
}