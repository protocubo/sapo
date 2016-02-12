EXPLAIN SELECT DISTINCT session_id FROM 
(
	(
		SELECT ep.session_id as session_id
		FROM SyncMap sm
			join EnderecoProp ep ON sm.tbl = 'EnderecoProp' AND sm.new_id = ep.id /*AND sm.timestamp > x*/
	)
	UNION ALL
	(
		SELECT  s.id as session_id
		FROM SyncMap sm
			JOIN Session s ON sm.tbl = 'Session' AND sm.new_id = s.id /*AND sm.timestamp > x*/
	)
	UNION ALL
	(
		select f.session_id as session_id
		FROM SyncMap sm
		JOIN Familia f ON f.id = sm.new_id AND sm.tbl = 'Familia'  /*AND sm.timestamp > x*/
	)
	UNION ALL
	(
		select  m.session_id as session_id
		FROM SyncMap sm
		JOIN Morador m ON m.id = sm.new_id AND sm.tbl = 'Morador'  /*AND sm.timestamp > x*/
	)
	UNION
	(
		select  p.session_id as session_id
		FROM SyncMap sm
		JOIN Ponto p ON  sm.tbl = 'Ponto' AND p.id = sm.new_id  /*AND sm.timestamp > x*/
	)
	UNION ALL
	(
		select m.session_id as session_id
		FROM SyncMap sm
		JOIN Modo m ON m.id = sm.new_id AND sm.tbl = 'Modo'  /*AND sm.timestamp > x*/
	)	
)
