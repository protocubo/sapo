/***** Usando a lógica de -x (gráfico de improdutividade) *********/
SELECT
s.user_id as user,
STRFTIME("%Y-%m-%d", s.date_finished) as date_end,
s.`group` as grupo,
COUNT(*) as pesqGrupo,
SUM(CASE 
/* Qdo algum é nulo, a pesquisa está "Completa"*/
WHEN checkSupervisor IS NULL  AND checkCT IS NULL  AND checkSuper IS NULL THEN 1
ELSE 0
END) as AllNull,
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
END) as isTrue,
SUM( CASE
WHEN checkSupervisor IS NULL THEN 1 
ELSE 0 END) as nullSupervisor,
SUM( CASE 
WHEN checkCT IS NULL THEN 1 ELSE 0 END) as nullCT,
SUM(CASE WHEN checkSuper IS NULL THEN 1 ELSE 0 END) AS nullSuper
FROM Survey s JOIN UpdatedSession us ON s.old_survey_id = us.old_survey_id AND s.syncTimestamp = us.syncTimestamp 
WHERE s.syncTimestamp > 1000 
GROUP BY s.user_id, s.`group`, date_end
ORDER BY s.user_id, s.`group`, date_end