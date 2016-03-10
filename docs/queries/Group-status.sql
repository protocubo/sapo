CREATE VIEW SurveyGroupStatus AS SELECT 
s.user_id as user_id, 
s.`group` as `group`, 
COUNT(*) as pesqGrupo, 
SUM(
	CASE WHEN 
	(checkSV = 1 OR checkSV IS NULL) 
	AND 
	(checkCT = 1 OR checkCT IS NULL) 
	AND 
	(checkCQ = 1 OR checkCQ IS NULL)  
	AND 
	((checkSV+checkCT+checkCQ != 3)  OR (checkSV+checkCT+checkCQ is null)) 
	THEN 1 
	ELSE 0 END
) AS Completa,
MIN(s.checkSV) AS checkSV,
MIN(s.checkCT) AS checkCT,
MIN(s.checkCQ) AS checkCQ,
SUM(CASE WHEN checkSV = 0 AND checkCT = 0 AND checkCQ = 0 THEN 1 ELSE 0 END) as allFalse, 
SUM(CASE WHEN checkSV = 0 OR checkCT = 0 OR checkCQ = 0 THEN 1 ELSE 0 END) as hasFalse, 
SUM(CASE WHEN checkSV = 1 AND checkCT = 1 AND checkCQ = 1 THEN 1 ELSE 0 END) as isTrue
FROM Survey s 
JOIN UpdatedSurvey us 
	ON s.old_survey_id = us.old_survey_id AND s.syncTimestamp = us.syncTimestamp 
GROUP BY s.user_id, s.`group` 
ORDER BY s.user_id, s.`group`


CREATE VIEW SurveyCheckStatus AS 
SELECT 
s.id as id,
s.`group` as `group`,
s.isPhoned as isPhoned,
CASE WHEN s.checkSV IS NULL THEN sg.checkSV ELSE s.checkSV END as checkSV,
CASE WHEN s.checkCT IS NULL THEN sg.checkCT ELSE s.checkCT END as checkCT,
CASE WHEN s.checkCQ IS NULL THEN sg.checkCQ ELSE s.checkCQ END AS checkCQ,
s.date_completed as date_completed
FROM Survey s 
JOIN SurveyGroupStatus sg 
	ON 
		s.user_id = sg.`user_id` 
			AND 
		s.`group` = sg.`group`		