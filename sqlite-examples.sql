-- General
SELECT MIN(datetime), MAX(datetime) from "schema" GROUP BY substr(datetime, 0, 16);
SELECT MIN(datetime), MAX(datetime) from "kafka" GROUP BY substr(datetime, 0, 16);
SELECT MIN(datetime), MAX(datetime) from "connect" GROUP BY substr(datetime, 0, 16);

-- LDAP Issues
SELECT k.class, k."method", substr(k.datetime, 0, 11) as day, count(1) FROM kafka k WHERE log LIKE '%javax.naming.CommunicationException:%' GROUP BY k.class, k."method", substr(k.datetime, 0, 11);
SELECT k.class, k."method", substr(k.datetime, 0, 11) as day, count(1) FROM kafka k WHERE log LIKE '%Caused by: java.net.SocketException: Connection reset%' GROUP BY k.class, k."method", substr(k.datetime, 0, 11);

SELECT * FROM kafka WHERE log LIKE '%javax.naming.CommunicationException: %';
SELECT * FROM kafka WHERE log LIKE '%Caused by: java.net.SocketException: Connection reset%';
SELECT * FROM kafka k WHERE k.log LIKE '%Caused by: java.net.SocketException: Connection reset%' and k."method" = 'searchForLdapUser' and k.log not LIKE '%rtdkafkaconsume.im%';
SELECT * FROM kafka k WHERE k.log LIKE '%LDAP search failed%';


-- Connector Issues

SELECT class, method, substr(datetime, 0, 11) as "day", count(1) FROM "connect" WHERE log like '%Exception%' GROUP BY "day" order by datetime asc;

-- categories
SELECT class, substr(datetime, 0, 11) as "day",
CASE
	WHEN log like '%Failed to deserialize data for topic%' THEN 'SerDe Exception'
	WHEN log like '%Unauthorized%' THEN 'Unauthorized Exception'
	WHEN log like '%rebalance failed%' THEN 'Rebalance Exception'
	ELSE 'Other' 
END AS ExceptionType,
count(1) as count
FROM "connect" WHERE log like '%Exception%' 
GROUP BY class, method, "day", ExceptionType 
ORDER by "day" asc, "count" desc;

-- rebalances
SELECT * from "connect" c WHERE log like '%rebalance failed%';

-- unauthorized
SELECT * from "connect" c WHERE log like '%Unauthorized%';

-- context / match logs
SELECT * FROM "connect" c WHERE datetime LIKE '2023-02-21 13:56:05%';
SELECT * FROM kafka k WHERE datetime LIKE '2023-02-21 13:56:0%';

-- match by: 20-second, 17-minute, 14-hour, 11-day (e.g. 10s:19)
SELECT * FROM "connect" c 
INNER JOIN "kafka" k on substr(k.datetime, 0, 20)=substr(c.datetime, 0, 20)
WHERE c.log like '%Unauthorized%';