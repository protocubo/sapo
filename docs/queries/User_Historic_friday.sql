SELECT 
	s.user_id as user, 
	s.`group` as grupo,	
	DATE(s.date_finished, 'weekday 5') as date_end , 
	COUNT(*) as pesqGrupo,  
	SUM( CASE WHEN checkSupervisor IS NULL THEN 1 ELSE 0 END) as nullSupervisor, 
	SUM( CASE WHEN checkCT IS NULL THEN 1 ELSE 0 END) as nullCT, 
	SUM(CASE WHEN checkSuper IS NULL THEN 1 ELSE 0 END) AS nullSuper 
FROM Survey s 
JOIN UpdatedSurvey us 	
	ON s.old_survey_id = us.old_survey_id AND s.syncTimestamp = us.syncTimestamp 
WHERE 
	STRFTIME('%w',s.date_finished) = '5' 
GROUP BY 
	s.user_id, s.`group`, date_end 
ORDER BY 
	s.user_id, s.`group`, date_end 