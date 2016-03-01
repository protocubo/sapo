package sapo.route;
import common.db.MoreTypes.Privilege;
import neko.Web;
import sapo.Context;
import sapo.spod.Survey;
import sapo.spod.User;
import sys.db.Manager;

/**
 * ...
 * @author Caio
 */
using Lambda;
class Summary extends AccessControl
{
	@:authorize(PSupervisor, PSurveyor, PSuperUser)
	public static function doDefault()
	{
		var queryResults = new List<Dynamic>();
		switch(Context.loop.group.privilege)
		{
			case Privilege.PSurveyor:
				// queries/User_summary.sql
				//TODO: Mudar a syncTimestamp para T-6 dias ou no modo B para todas agrupado por semana e mudar o user_id (nao há relação ainda)
				queryResults = Manager.cnx.request("SELECT STRFTIME('%Y-%m-%d', s.date_finished) as date_end,s.`group` as grupo, COUNT(*) as pesqGrupo, SUM(CASE /* Qdo algum é nulo, a pesquisa está 'Completa'*/ WHEN checkSupervisor IS NULL OR checkCT IS NULL OR checkSuper IS NULL THEN 1 ELSE 0 END) as hasNull, SUM(CASE /* Tudo false = RECUSADO */ WHEN checkSupervisor = 0 AND checkCT = 0 AND checkSuper = 0 THEN 1 ELSE 0 END) as allFalse, SUM(CASE /*Quando algum é falso -> Pendente */ WHEN checkSupervisor = 0 OR checkCT = 0 OR checkSuper = 0 THEN 1 ELSE 0 END) as hasFalse, SUM(CASE/* Quando todos são ok -> YAY */ WHEN checkSupervisor = 1 AND checkCT = 1 AND checkSuper = 1 THEN 1 /*WTH?*/ ELSE 0 END) as hasTrue FROM Survey s JOIN UpdatedSession us ON s.old_survey_id = us.old_survey_id AND s.syncTimestamp = us.syncTimestamp WHERE s.syncTimestamp > 1000 AND user_id = 99999 GROUP BY s.`group`, date_end").results().array();
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
				queryResults = Survey.manager.unsafeObjects("SELECT s.* FROM Survey s JOIN UpdatedSurvey us ON s.old_survey_id = us.old_survey_id AND s.syncTimestamp = us.syncTimestamp " + str + " ORDER BY s.old_survey_id").array();
			case Privilege.PSuperUser:
				queryResults = Survey.manager.unsafeObjects("SELECT s.* FROM Survey s JOIN UpdatedSurvey us ON s.old_survey_id = us.old_survey_id AND s.syncTimestamp = us.syncTimestamp ORDER BY s.old_survey_id").array();
			default:
				Web.redirect("index");
				return;
		}
		
		var groupCheck = new Map();
		//Pensei em algo do tipo (data;
		var dateVal = new Map();
		//TODO:Repensar isso
		for (q in queryResults)
		{
			var retval = 10;
			
			if (q.allFalse != 0)
				retval = -2;
			else if (q.hasFalse != 0)
				retval = -1;
			else if (q.hasTrue >= 1)
				retval = 1;
			else 
				retval = 0;
			
			//TODO:Reescrever
			if (groupCheck.exists(q.grupo))
			{
				var cur = groupCheck.get(q.grupo);
				//TODO:Pensar melhor nisso
				if ((cur > retval && retval != 0) || (cur == 0 && retval == 1))
					groupCheck.set(q.grupo, retval);
			}
			else
				groupCheck.set(q.grupo, retval);
		}
	}
	
	public function new() 
	{
		
	}
	
}