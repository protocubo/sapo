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
		var wherestr = "";
		var espGroupBy = "";
		switch(Context.loop.group.privilege)
		{
			case Privilege.PSurveyor:
				wherestr = " AND user_id = " + Context.loop.user;
			case Privilege.PSupervisor:
				var users = User.manager.search($supervisor == Context.loop.user, null, false);
				for (u in users)
					wherestr = wherestr + " AND user_id = " + u.id + " ";
			case Privilege.PSuperUser:
				return;
			default:
				Web.redirect("index");
				return;
		}
		if(wherestr.length > 0)
			queryResults = Manager.cnx.request("SELECT STRFTIME('%Y-%m-%d', s.date_finished) as date_end, s.`group` as grupo, COUNT(*) as pesqGrupo, SUM(CASE /* Qdo algum é nulo, a pesquisa está 'Completa'*/ WHEN checkSupervisor IS NULL OR checkCT IS NULL OR checkSuper IS NULL THEN 1 ELSE 0 END) as hasNull, SUM(CASE /* Tudo false = RECUSADO */ WHEN checkSupervisor = 0 AND checkCT = 0 AND checkSuper = 0 THEN 1 ELSE 0 END) as allFalse, SUM(CASE /*Quando algum é falso -> Pendente */ WHEN checkSupervisor = 0 OR checkCT = 0 OR checkSuper = 0 THEN 1 ELSE 0 END) as hasFalse, SUM(CASE/* Quando todos são ok -> YAY */ WHEN checkSupervisor = 1 AND checkCT = 1 AND checkSuper = 1 THEN 1 ELSE 0 END) as hasTrue FROM Survey s JOIN UpdatedSession us ON s.old_survey_id = us.old_survey_id AND s.syncTimestamp = us.syncTimestamp  WHERE s.syncTimestamp > 1000 AND "+wherestr+" GROUP BY s.`group`, date_end").results().array();
		else //TODO
			queryResults = [];
		
		//User;group;val
		var userCheck : Map<Int,Map<Int,Int>> = new Map();
		
		//Map do tipo data; categoria; val que vai para a view (para todos fazer Completas, pendentes e recusadas + os params adicionais (grupo ou usuários)
		var dateVal : Map<Date, Map<String, Int>> = new Map();
		
		var i = 0;
		while (i < queryResults.length)
		{
			var isSameUserGroup = false;
			//Rever..altas chances de dar pau
			if (i > 0 && userCheck.exists(queryResults[i - 1].user_id) && userCheck.get(queryResults[i - 1].user_id).exists(queryResults[i - 1].group_id))
				isSameUserGroup = true;
			
			var retval = 5;
			var cur = queryResults[i];
			//Reprovado
			if (cur.allFalse != 0)
				reval = -2;
			//Pendente
			else if (cur.hasFalse != 0)
				retval = -1;
			//Aprovado
			else if (cur.hasTrue >= 1)
				retval = 1;
			//Completo
			else
				retval = 0;
			
			var groupHash = userCheck.get(cur.user_id);
			if (groupHash == null)
				groupHash = new Map();
			
			var curGroup = groupHash.get(q.grupo);
			//N existe valor ou valor existe e é menor que o atual qdo o valor atual é diferente de zero (p.e. atual é 1 e o novo é -1,
			//mostrando que é uma pesquisa pendente 
			//Ou o grupo atual é 0 e o novo é 1 (Pesquisas aprovadas)
			if (curGroup == null || ((curGroup != null && curGroup > retval && retval != 0) || (curGroup == 0 && retval == 1))
				groupHash.set(q.grupo, retval);
			
			var curDate = Date.fromString(queryResults[i].date_end);
			var curCat : Map<String,Int>;
			
			if(!dateVal.exists(curDate))
				curCat = new Map();
			else
				curCat = dateVal.get(curDate);
			
			curCat.
			
			
			i++;
		}
	}
	
	public function new() 
	{
		
	}
	
}