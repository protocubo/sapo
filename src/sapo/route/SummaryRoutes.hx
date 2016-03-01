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
class SummaryRoutes extends AccessControl
{
	//TODO: Pegar params de filtro
	@authorize(PSupervisor, PSuperUser)
	public function doDefault()
	{
		//Todos os estados atuais da pesquisa por grupo
		var controlResults = Manager.cnx.request("SELECT s.user_id as user, s.`group` as grupo, COUNT(*) as pesqGrupo, SUM(CASE WHEN (checkSupervisor IS NULL OR checkCT IS NULL OR checkSuper IS NULL) OR ((checkSuperVisor IS NOT NULL AND checkSupervisor != 0 AND checkCT IS NOT NULL AND checkCT != 0 AND checkSuper IS NOT NULL AND checkSuper != 0) AND NOT (checkSupervisor = 1  AND checkCT = 1 AND checkSuper = 1) ) THEN 1 ELSE 0 END) as Completa, SUM(CASE WHEN checkSupervisor = 0 AND checkCT = 0 AND checkSuper = 0 THEN 1 ELSE 0 END) as allFalse, SUM(CASE WHEN checkSupervisor = 0 OR checkCT = 0 OR checkSuper = 0 THEN 1 ELSE 0 END) as hasFalse, SUM(CASE WHEN checkSupervisor = 1 AND checkCT = 1 AND checkSuper = 1 THEN 1 ELSE 0 END) as isTrue, SUM( CASE WHEN checkSupervisor IS NULL THEN 1 ELSE 0 END) as nullSupervisor, SUM( CASE WHEN checkCT IS NULL THEN 1 ELSE 0 END) as nullCT, SUM(CASE WHEN checkSuper IS NULL THEN 1 ELSE 0 END) AS nullSuper FROM Survey s JOIN UpdatedSurvey us ON s.old_survey_id = us.old_survey_id AND s.syncTimestamp = us.syncTimestamp WHERE s.syncTimestamp > 1000 GROUP BY s.user_id, s.`group` ORDER BY s.user_id, s.`group`").results();
		
		//User;group;status - 
		var userCheck : Map<Int,Map<Int,PesqStatus>> = new Map();
		userCheck = new Map();
		for (c in controlResults)
		{
			var group : Map<Int, PesqStatus> = new Map();
			if (userCheck.exists(c.user))
				group = userCheck.get(c.user);
			
			var status;
			if (c.allFalse != 0)
				status = PesqStatus.Recusada;
			else if (c.hasFalse != 0)
				status = PesqStatus.Pendente;
			else if (c.isTrue != 0)
				status = PesqStatus.Aceita;
			else
				status = PesqStatus.Completa;
			
			group.set(c.group, status);
			userCheck.set(c.user, group);				
		}
		
		//Map do tipo data; categoria; val que vai para a view (para todos fazer Completas, pendentes e recusadas + os params adicionais (grupo ou usuários)
		var dateVal : Map<Date, Map<String, Int>> = new Map();
		
		var resultsQuery = Manager.cnx.request("SELECT s.user_id as user, s.`group` as grupo,STRFTIME('%Y-%m-%d', s.date_finished) as date_end , COUNT(*) as pesqGrupo,  SUM( CASE WHEN checkSupervisor IS NULL THEN 1 ELSE 0 END) as nullSupervisor, SUM( CASE WHEN checkCT IS NULL THEN 1 ELSE 0 END) as nullCT, SUM(CASE WHEN checkSuper IS NULL THEN 1 ELSE 0 END) AS nullSuper FROM Survey s JOIN UpdatedSurvey us ON s.old_survey_id = us.old_survey_id AND s.syncTimestamp = us.syncTimestamp WHERE s.syncTimestamp > 1000 GROUP BY s.user_id, s.`group`, date_end ORDER BY s.user_id, s.`group`, date_end").results();
		var header = ["Data", "Supervisor", "CT", "Super", "Completa", "Recusadas", "Aceitas"];
		for (r in resultsQuery)
		{
			var date = Date.fromString(r.date_end);
			var curDateHash : Map<String,Int> = new Map();
			if (dateVal.exists(date))
				curDateHash = dateVal.get(date);
			
			var mode = userCheck.get(r.user_id).get(r.group);
			switch(mode)
			{
				//Obrigatoriamente todos responderam...n sobe barra, sobem os controles
				case PesqStatus.Aceita:
					var curval = curDateHash.get("Aceitas");
					curDateHash.set("Aceitas", curval + r.pesqGrupo);
				case PesqStatus.Recusada:
					var curval = curDateHash.get("Recusadas");
					curDateHash.set("Recusadas", curval + r.pesqGrupo);
				case PesqStatus.Pendente:
					if (r.nullCT == r.pesqGrupo)
						curDateHash.set("CT", curDateHash.get("CT") + r.pesqGrupo);
					curDateHash.set("Supervisor",curDateHash.get("Supervisor") +  r.pesqGrupo);
					curDateHash.set("Super", curDateHash.get("Super") + r.pesqGrupo);
				case PesqStatus.Completa:
					curDateHash.set("Completas", curDateHash.get("Completas") + r.pesqGrupo);
					if (r.nullCT == r.pesqGrupo)
						curDateHash.set("CT", curDateHash.get("CT") + r.pesqGrupo);
					curDateHash.set("Supervisor",curDateHash.get("Supervisor") +  r.pesqGrupo);
					curDateHash.set("Super", curDateHash.get("Super") + r.pesqGrupo);
			}
			
			dateVal.set(Date.fromString(r.date_end), curDateHash);
		}
		
		Sys.println(sapo.view.Summary.render(dateVal, header));
	}
	
	public function new() 
	{
		
	}
	
}

enum PesqStatus {
	Completa;
	Pendente;
	Recusada;
	Aceita;
}