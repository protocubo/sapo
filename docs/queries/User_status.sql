SELECT 
s.user_id as user, 
s.`group` as grupo, 
COUNT(*) as pesqGrupo, 
SUM(CASE WHEN (checkSupervisor IS NULL OR checkCT IS NULL OR checkSuper IS NULL) 
	OR ((checkSuperVisor IS NOT NULL AND checkSupervisor != 0 AND checkCT IS NOT NULL AND checkCT != 0 AND checkSuper IS NOT NULL AND checkSuper != 0) 
	AND NOT (checkSupervisor = 1  AND checkCT = 1 AND checkSuper = 1) ) THEN 1 ELSE 0 END) as Completa,
SUM(CASE WHEN checkSupervisor = 0 AND checkCT = 0 AND checkSuper = 0 THEN 1 ELSE 0 END) as allFalse, 
SUM(CASE WHEN checkSupervisor = 0 OR checkCT = 0 OR checkSuper = 0 THEN 1 ELSE 0 END) as hasFalse, 
SUM(CASE WHEN checkSupervisor = 1 AND checkCT = 1 AND checkSuper = 1 THEN 1 ELSE 0 END) as isTrue, 
SUM( CASE WHEN checkSupervisor IS NULL THEN 1 ELSE 0 END) as nullSupervisor, 
SUM( CASE WHEN checkCT IS NULL THEN 1 ELSE 0 END) as nullCT, 
SUM(CASE WHEN checkSuper IS NULL THEN 1 ELSE 0 END) AS nullSuper 
FROM Survey s 
JOIN UpdatedSurvey us 
	ON s.old_survey_id = us.old_survey_id AND s.syncTimestamp = us.syncTimestamp 
WHERE s.syncTimestamp > 1000 GROUP BY s.user_id, s.`group` 
ORDER BY s.user_id, s.`group`