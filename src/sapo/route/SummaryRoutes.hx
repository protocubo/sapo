package sapo.route;

import common.db.MoreTypes;
import haxe.Serializer;
import haxe.Unserializer;
import neko.Web;
import sapo.Context;
import sapo.spod.Survey;
import sapo.spod.User;
import sys.db.Manager;

using Lambda;
using sapo.route.SummaryRoutes.SummaryTools;

class SummaryRoutes extends AccessControl
{
	//Constante de dia para a query de Histórico (usando %w no STRFTIME)
	static inline var HistoricDay = 5;

	public static inline var DATE_KEY = "Date";
	public static inline var SUP_KEY = "Supervisores";
	public static inline var CT_KEY = "CT";
	public static inline var SUPER_KEY = "Super";
	public static inline var COMPLETA_KEY =  "Completas";
	public static inline var RECUSADAS_KEY = "Recusadas";
	public static inline var ACEITA_KEY = "Aceitas";

	//static inline var
	//TODO: Pegar params de filtro
	@authorize(PSupervisor, PSuperUser)
	public function doDefault(?args : {?data : String})
	{
		var data = args != null ? args.data : null;
		var wherestr = "";
		if (data != null && data.length > 0)
		{
			var unserializer = new Unserializer(data);
			var users : Array<Int> = unserializer.unserialize();

			for (u in users)
			{
				if (wherestr == "")
					wherestr = " AND ( user_id = " + u;
				else
					wherestr = wherestr + " OR user_id = " + u;
			}
			wherestr = wherestr + ")";
		}

		//Todos os estados atuais da pesquisa por grupo
		//User;group;status -
		var userCheck = statusGen();

		//Map do tipo data; categoria; val que vai para a view (para todos fazer Completas, pendentes e recusadas + os params adicionais (grupo ou usuários)
		var dateVal : Map<String, Map<String, Int>> = new Map();

		// TODO make compatible with mysql
		// TODO when syncing, change WHERE s.date_completed to s.sync_timestamp
		var resultsQuery = Context.db.request('
				SELECT
					s.user_id as user,
					s.`group` as grupo,
					DATE(s.date_finished/1e3, \'unixepoch\') as date_end,
					COUNT(*) as pesqGrupo,
					SUM(CASE WHEN checkSV IS NULL THEN 1 ELSE 0 END) as nullSupervisor,
					SUM(CASE WHEN checkCT IS NULL THEN 1 ELSE 0 END) as nullCT,
					SUM(CASE WHEN checkCQ IS NULL THEN 1 ELSE 0 END) AS nullSuper
				FROM Survey s
				JOIN UpdatedSurvey us
					ON s.old_survey_id = us.old_survey_id
					AND s.syncTimestamp = us.syncTimestamp
				WHERE
					s.date_completed > ${Context.now.delta(-30*$day).getTime()}
					$wherestr
				GROUP BY s.user_id, s.`group`, date_end
				ORDER BY s.user_id, s.`group`, date_end
		');

		var header = [DATE_KEY, SUP_KEY, CT_KEY, SUPER_KEY, COMPLETA_KEY, RECUSADAS_KEY, ACEITA_KEY];
		for (r in resultsQuery)
		{
			if (r.date_end == null)
				continue;
			trace(r.date_end);
			var date = r.date_end;
			var curDateHash : Map<String,Int> = new Map();
			if (dateVal.exists(date))
				curDateHash = dateVal.get(date);

			var mode = userCheck.get(r.user).get(r.grupo);
			//trace(userCheck.get(r.user);

			switch(mode)
			{
				//Obrigatoriamente todos responderam...n sobe barra, sobem os controles
				case PesqStatus.Aceita:
					var curval = curDateHash.get(ACEITA_KEY);
					curDateHash.set(ACEITA_KEY, curval.getVal() + r.pesqGrupo);
				case PesqStatus.Recusada:
					var curval = curDateHash.get(RECUSADAS_KEY);
					curDateHash.set(RECUSADAS_KEY, curval.getVal() + r.pesqGrupo);
					case PesqStatus.Pendente:
					if (r.nullCT == r.pesqGrupo)
						curDateHash.set(CT_KEY, curDateHash.get(CT_KEY).getVal() + r.pesqGrupo);
					curDateHash.set(SUP_KEY,curDateHash.get(SUP_KEY).getVal() +  r.pesqGrupo);
					curDateHash.set(SUPER_KEY, curDateHash.get(SUPER_KEY).getVal() + r.pesqGrupo);
				case PesqStatus.Completa:
					curDateHash.set(COMPLETA_KEY, curDateHash.get(COMPLETA_KEY).getVal() + r.pesqGrupo);
					if (r.nullCT == r.pesqGrupo)
						curDateHash.set(CT_KEY, curDateHash.get(CT_KEY).getVal() + r.pesqGrupo);
					curDateHash.set(SUP_KEY,curDateHash.get(SUP_KEY).getVal() +  r.pesqGrupo);
					curDateHash.set(SUPER_KEY, curDateHash.get(SUPER_KEY).getVal() + r.pesqGrupo);
			}

			dateVal.set(r.date_end, curDateHash);
		}
		Sys.println(sapo.view.Summary.render(dateVal, header));
	}

	@authorize(PSupervisor, PSuperUser)
	public function doHistoric(?args : {data:String})
	{
		var data = args != null ? args.data : null;
		var wherestr = "";
		if (data != null && data.length > 0)
		{
			var unserializer = new Unserializer(data);
			var users : Array<Int> = unserializer.unserialize();
			var i = 0;
			while(i < users.length)
			{
				if (i == 0)
					wherestr = " WHERE user_id = " + users[0];
				else
					wherestr = wherestr + " AND user_id = " + users[i];

				i++;
			}


		}

		var userCheck = statusGen();

		var dateVal : Map<String,Map<String,Int>> = new Map();
		var headers = [DATE_KEY, SUP_KEY, CT_KEY, SUPER_KEY, COMPLETA_KEY, ACEITA_KEY, RECUSADAS_KEY];
		// TODO make compatible with mysql
		var queryDay = Context.db.request('
				SELECT
					s.user_id as user,
					s.`group` as grupo,
					DATE(s.date_completed/1e3, \'unixepoch\', \'weekday $HistoricDay\') as date_end ,
					COUNT(*) as pesqGrupo,
					SUM(CASE WHEN checkSV IS NULL THEN 1 ELSE 0 END) as nullSupervisor,
					SUM(CASE WHEN checkCT IS NULL THEN 1 ELSE 0 END) as nullCT,
					SUM(CASE WHEN checkCQ IS NULL THEN 1 ELSE 0 END) AS nullSuper
				FROM Survey s
				JOIN UpdatedSurvey us
					ON s.old_survey_id = us.old_survey_id
					AND s.syncTimestamp = us.syncTimestamp
					AND STRFTIME(\'%w\', s.date_completed/1e3) = \'$HistoricDay\'
					$wherestr
				GROUP BY s.user_id, s.`group`, date_end
				ORDER BY s.user_id, s.`group`, date_end');
		for (q in queryDay)
		{
			if (q.date_end == null)
				break;
			//submap de dateVal
			var dateMap = new Map<String,Int>();

			if (dateVal.exists(q.date_end))
				dateMap = dateVal.get(q.date_end);

			switch(userCheck.get(q.user).get(q.grupo))
			{
				case PesqStatus.Pendente:
					if (q.nullCT == q.pesqGrupo)
						dateMap.set(CT_KEY, dateMap.get(CT_KEY).getVal() + q.pesqGrupo);
					dateMap.set(SUP_KEY, dateMap.get(SUP_KEY).getVal() + q.pesqGrupo);
					dateMap.set(SUPER_KEY, dateMap.get(SUPER_KEY).getVal() + q.pesqGrupo);
				case PesqStatus.Completa:
					dateMap.set(COMPLETA_KEY, dateMap.get(COMPLETA_KEY).getVal() + q.pesqGrupo);
					dateMap.set(SUP_KEY, dateMap.get(SUP_KEY).getVal() + q.pesqGrupo);
					dateMap.set(CT_KEY, dateMap.get(CT_KEY).getVal() + q.pesqGrupo);
					dateMap.set(SUPER_KEY, dateMap.get(SUPER_KEY).getVal() + q.pesqGrupo);
				case PesqStatus.Aceita, PesqStatus.Recusada:
					continue;
			}

			dateVal.set(q.date_end, dateMap);
		}

		// TODO make compatible with mysql
		var queryHistoric = Context.db.request("
				SELECT
					s.user_id as user,
					s.`group` as grupo,
					DATE(s.date_completed/1e3, 'unixepoch', 'weekday "+HistoricDay+"') as date_end,
					COUNT(*) as pesqGrupo,
					SUM(CASE WHEN checkSV IS NULL THEN 1 ELSE 0 END) as nullSupervisor,
					SUM(CASE WHEN checkCT IS NULL THEN 1 ELSE 0 END) as nullCT,
					SUM(CASE WHEN checkCQ IS NULL THEN 1 ELSE 0 END) AS nullSuper
				FROM Survey s
				JOIN UpdatedSurvey us
					ON s.old_survey_id = us.old_survey_id
					AND s.syncTimestamp = us.syncTimestamp "+((wherestr != "") ? wherestr : "")+"
				GROUP BY s.user_id, s.`group`, date_end
				ORDER BY s.user_id, s.`group`, date_end");
		for (q in queryHistoric)
		{
			if (q.date_end == null)
				break;

			var dateMap = new Map<String,Int>();

			if (dateVal.exists(q.date_end))
				dateMap = dateVal.get(q.date_end);

			switch(userCheck.get(q.user).get(q.grupo))
			{
				case PesqStatus.Aceita:
					dateMap.set(ACEITA_KEY, dateMap.get(ACEITA_KEY).getVal() + q.pesqGrupo);
				case PesqStatus.Recusada:
					dateMap.set(RECUSADAS_KEY, dateMap.get(RECUSADAS_KEY).getVal() + q.pesqGrupo);
				case PesqStatus.Pendente, PesqStatus.Completa:
					continue;
			}

			dateVal.set(q.date_end, dateMap);
		}


		Sys.println(sapo.view.Summary.render(dateVal, headers));
	}

	@authorize(PSupervisor, PSuperUser)
	public function postUser(?args : {?user:User})
	{
		if (args == null)
		{
			args = { user : null};
		}
		var user = args.user;


		var ret = [];
		switch(user.group.privilege)
		{
			case PSurveyor:
				ret.push(user.id);
			case PSupervisor:
				ret = User.manager.search($supervisor == user, null, false).map(function (v) { return v.id; } ).array();
			default:
				ret = [];
		}

		var referer = Web.getClientHeader("Referer");
		referer = referer.split("?")[0];
		var serializer = new Serializer();
		if(ret.length > 0)
			serializer.serialize(ret);
		trace(referer);
		if(ret.length > 0)
			Web.redirect(referer + "?data=" + serializer.toString());
		else
			Web.redirect(referer);
	}

	//Pega todos os status por grupo e um Map de user_id, grupo, e enum de estado
	function statusGen() : Map<Int,Map<Int,PesqStatus>>
	{
		// TODO make compatible with mysql
		// TODO when syncing, change WHERE s.date_completed to s.sync_timestamp
		var controlResults = Context.db.request("
				SELECT
					s.user_id as user,
					s.`group` as grupo,
					COUNT(*) as pesqGrupo,
					SUM(CASE WHEN (checkSV IS NULL OR checkCT IS NULL OR checkCQ IS NULL) OR ((checkSV IS NOT NULL AND checkSV != 0 AND checkCT IS NOT NULL AND checkCT != 0 AND checkCQ IS NOT NULL AND checkCQ != 0) AND NOT (checkSV = 1  AND checkCT = 1 AND checkCQ = 1) ) THEN 1 ELSE 0 END) as Completa,
					SUM(CASE WHEN checkSV = 0 AND checkCT = 0 AND checkCQ = 0 THEN 1 ELSE 0 END) as allFalse,
					SUM(CASE WHEN checkSV = 0 OR checkCT = 0 OR checkCQ = 0 THEN 1 ELSE 0 END) as hasFalse,
					SUM(CASE WHEN checkSV = 1 AND checkCT = 1 AND checkCQ = 1 THEN 1 ELSE 0 END) as isTrue,
					SUM(CASE WHEN checkSV IS NULL THEN 1 ELSE 0 END) as nullSupervisor,
					SUM(CASE WHEN checkCT IS NULL THEN 1 ELSE 0 END) as nullCT,
					SUM(CASE WHEN checkCQ IS NULL THEN 1 ELSE 0 END) AS nullSuper
				FROM Survey s JOIN UpdatedSurvey us
					ON s.old_survey_id = us.old_survey_id
					AND s.syncTimestamp = us.syncTimestamp
				WHERE
					s.syncTimestamp > 1000
				GROUP BY s.user_id, s.`group`
				ORDER BY s.user_id, s.`group`");

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

			group.set(c.grupo, status);
			userCheck.set(c.user, group);
		}

		return userCheck;
	}

	public function new()
	{

	}




}

class SummaryTools
{
	public static function getVal(v : Int) : Int
	{
		return v != null ? v : 0;
	}
}

enum PesqStatus {
	Completa;
	Pendente;
	Recusada;
	Aceita;
}
