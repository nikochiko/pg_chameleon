/*
WITH 	t_batch AS
	(
		SELECT 
			*
		FROM 
			sch_chameleon.t_replica_batch  
		WHERE 
				b_started 
			AND 	b_processed 
		ORDER BY 
			ts_created 
		LIMIT 1
	),
	t_events AS
	(
		SELECT 
			log.v_table_name,
			log.v_schema_name,
			log.v_binlog_event,
			log.jsb_event_data,
			tab.v_table_pkey as v_table_pkeys,
			replace(array_to_string(tab.v_table_pkey,','),'"','') as v_table_pkey,
			array_length(tab.v_table_pkey,1) as i_pkeys
		FROM 
			sch_chameleon.t_log_replica  log
			INNER JOIN sch_chameleon.t_replica_tables tab
				ON
						tab.v_table_name=log.v_table_name
					AND 	tab.v_schema_name=log.v_schema_name
				INNER JOIN t_batch bat
				ON	bat.i_id_batch=log.i_id_batch
			
		ORDER BY ts_event_datetime
	),
	t_sub AS
	(
		SELECT 
			generate_subscripts(v_table_pkeys,1) sub
		FROM 
			t_events
	)
SELECT
	v_table_name,
	v_schema_name,
	v_binlog_event,
	jsb_event_data,
	string_to_array(v_table_pkey,',') as t_keys,
	v_table_pkey,
	i_pkeys
FROM
	t_events
;


WITH 	t_jsb AS
	(
		SELECT '{"id": 1379492, "data": "Hello", "data2": "friend", "date_test": "2016-09-02 11:30:46"}'::jsonb jsb_event_data,
		ARRAY['id','data'] v_table_pkey
	),
	t_subscripts AS
	(
		SELECT 
			generate_subscripts(v_table_pkey,1) sub
		FROM 
			t_jsb
	)
SELECT 
	array_to_string(v_table_pkey,','),
	array_to_string(array_agg((jsb_event_data->>v_table_pkey[sub])::text),',') as pk_value
FROM
	t_subscripts,t_jsb
GROUP BY v_table_pkey
;
*/

SELECT 
	array_to_string(array_agg(format('%I',t_field)),',') t_field,
	array_to_string(array_agg(format('%L',t_value)),',') t_value
	
FROM
(
	SELECT 
		unnest('{id,data,data2,date_test}'::text[]) t_field, 
		unnest('{1379262,Hello," my friend","2016-09-02 11:30:46"}'::text[]) t_value
) t_val

	(
		SELECT 
			count(v_log_table) AS i_cnt_tables,
			v_log_table 
		FROM 
			sch_chameleon.t_replica_batch 
		GROUP BY 
			v_log_table
	UNION ALL
		SELECT 
			1  AS i_cnt_tables,
			't_log_replica_1'  AS i_cnt_tables
	)
	ORDER BY 1
	LIMIT 1

	
	
	SELECT 
	*
		FROM 
			sch_chameleon.t_replica_batch
