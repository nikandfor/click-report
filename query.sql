WITH
	--('2e5d8c78-4e4e-488f-84c5-31222482eaa6',2) AS arg0,
	--('3c2b5a64-d7a9-42d4-9f1c-974d489559ae',1) AS arg1,
	(SELECT arg0 FROM _params) AS arg0,
	(SELECT arg1 FROM _params) AS arg1,

	(SELECT min(ts) FROM q WHERE id = arg0 AND name = 'reason' AND value.String = 'shift start') AS start,
	(SELECT max(ts) FROM q WHERE id = arg0 AND name = 'reason' AND value.String = 'end of shift') AS end,

	states AS (SELECT ts, value.String AS value, lead(ts, 1, ts) OVER w - ts AS secs FROM q WHERE id = arg0 AND name = 'state' WINDOW w AS (ORDER BY ts)),
	uptime AS (SELECT sumIf(secs, value = 'up') AS up, (end - start) AS tot, up / (tot+1) AS uptime FROM states),

	perf AS (SELECT count() AS c, (toStartOfMinute(end) - toStartOfMinute(start)) / 180 AS exp, exp / c AS perf FROM q WHERE id = arg1 AND name = 'produced'),

	quality AS (SELECT sumIf(toInt64(value), name = 'produced') AS pd, sumIf(toInt64(value), name = 'scrap') AS scrap, (pd - scrap) / pd AS q FROM q WHERE id = arg1),

	(SELECT (SELECT q FROM quality) * (SELECT uptime FROM uptime) * (SELECT perf FROM perf)) AS oee,

	1 AS _
--SELECT * FROM uptime
--SELECT * FROM cycles
--SELECT toJSONString(map('values', [map('name', 'oee'::Dynamic, 'value', oee::Dynamic)])) AS j
SELECT toJSONString(map('ts', end::Dynamic, 'values', [map('name', 'oee'::Dynamic, 'value', oee::Dynamic)])) AS j
