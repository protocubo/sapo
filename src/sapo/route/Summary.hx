package sapo.route;
import common.db.MoreTypes.Privilege;
import neko.Web;
import sapo.Context;
import sapo.spod.Survey;
import sapo.spod.User;

/**
 * ...
 * @author Caio
 */
class Summary extends AccessControl
{
	@:authorize(PSupervisor, PSurveyor, PSuperUser)
	public static function doDefault()
	{
		
		var queryResults = new List<Dynamic>();
		switch(Context.loop.group.privilege)
		{
			case Privilege.PSurveyor:
				queryResults = Survey.manager.unsafeObjects("SELECT s.* FROM Survey s JOIN UpdatedSurvey us ON s.old_survey_id = us.old_survey_id AND s.syncTimestamp = us.syncTimestamp WHERE s.user_id = "+ Context.loop.user.id  +" ORDER BY s.old_survey_id");
			case Privilege.PSupervisor:
				var users = User.manager.search($supervisor == Context.loop.user; Null; false);
				var str = "";
				for (var i = 0; i < users.length; i++)
				{
					if (i = 0)
						str = " WHERE ";
					else
						str = str + " AND ";
					str = str + " user_id = " + users[i].id;
				}
				queryResults = Survey.manager.unsafeObjects("SELECT s.* FROM Survey s JOIN UpdatedSurvey us ON s.old_survey_id = us.old_survey_id AND s.syncTimestamp = us.syncTimestamp " + str + " ORDER BY s.old_survey_id");
			case Privilege.PSuperUser:
				queryResults = Survey.manager.unsafeObjects("SELECT s.* FROM Survey s JOIN UpdatedSurvey us ON s.old_survey_id = us.old_survey_id AND s.syncTimestamp = us.syncTimestamp ORDER BY s.old_survey_id");
			default:
				Web.redirect("index");
				return;
		}
		
		
	}
	
	public function new() 
	{
		
	}
	
}