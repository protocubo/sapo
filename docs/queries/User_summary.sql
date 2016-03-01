SELECT
STRFTIME("%Y-%m-%d", s.date_finished) as date_end,
s.`group` as grupo,
COUNT(*) as pesqGrupo,
SUM(CASE 
/* Qdo algum é nulo, a pesquisa está "Completa"*/
WHEN checkSupervisor IS NULL OR checkCT IS NULL OR checkSuper IS NULL THEN 1
ELSE 0
END) as hasNull,
SUM(CASE
/* Tudo false = RECUSADO */
WHEN checkSupervisor = 0 AND checkCT = 0 AND checkSuper = 0 THEN 1
ELSE 0
END) as allFalse,
SUM(CASE
/*Quando algum é falso -> Pendente */
WHEN checkSupervisor = 0 OR checkCT = 0 OR checkSuper = 0 THEN 1
ELSE 0
END) as hasFalse,
SUM(CASE/* Quando todos são ok -> YAY */
WHEN checkSupervisor = 1 AND checkCT = 1 AND checkSuper = 1 THEN 1
ELSE 0
END) as hasTrue
FROM Survey s JOIN UpdatedSession us ON s.old_survey_id = us.old_survey_id AND s.syncTimestamp = us.syncTimestamp 
WHERE s.syncTimestamp > 1000 AND user_id = 99999
GROUP BY s.`group`, date_end