SET search_path TO demo9;

-- 1) Sesiones activas y qué están ejecutando
SELECT
  pid, usename, datname, state,
  now() - query_start AS running_for,
  left(query, 120) AS query_sample
FROM pg_stat_activity
WHERE datname = 'demos'
ORDER BY running_for DESC NULLS LAST;

-- 2) Top queries por tiempo total (pg_stat_statements)
SELECT
  calls,
  total_exec_time,
  mean_exec_time,
  rows,
  left(query, 120) AS query_sample
FROM pg_stat_statements
WHERE dbid = (SELECT oid FROM pg_database WHERE datname='demos')
ORDER BY total_exec_time DESC
LIMIT 15;

-- 3) Reseteo (opcional) antes de comenzar una demo “limpia”
-- SELECT pg_stat_statements_reset();
