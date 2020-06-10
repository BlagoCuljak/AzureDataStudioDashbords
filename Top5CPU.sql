
SELECT TOP 5
t.[text] 'Upit', 
	Convert(varchar, qs.creation_time, 109) as 'Vrijeme kompaliranja', 
	qs.execution_count as 'Ponovljeno puta', 
	qs.total_worker_time as 'Utrošeno vrijeme CPU', 
    cast(qs.last_worker_time as varchar) +'   ('+ cast(qs.max_worker_time as Varchar)+' najviše)' as 'CPU vrijeme zadnjeg upita (ms)',
	DB_Name(t.dbid) as 'Ime baze'
FROM sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
ORDER BY 'Utrošeno vrijeme CPU' DESC
Go