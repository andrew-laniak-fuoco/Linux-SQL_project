/*
SQL solution 1
*/
SELECT cpu_number, 
       id, 
       total_mem 
FROM   host_info 
GROUP  BY cpu_number, 
          id 
ORDER  BY total_mem DESC; 

/*
SQL solution 2
round_minutes function copied from internet
URL: https://stackoverflow.com/questions/6195439/postgres-how-do-you-round-a-timestamp-up-or-down-to-the-nearest-minute
*/
SELECT Date_trunc('minute', Round_minutes(timestamp, 5)) AS time, 
       Round(Avg(cpu_idle), 0)                           AS Average 
FROM   host_usage 
GROUP  BY time 
ORDER  BY time; 

/*
SQL solution 3
Not a full solution
The resulting table shows if a record was made that minute
*/
SELECT time.minute, 
       CASE 
         WHEN recorded.success IS NULL THEN 'failed' 
         ELSE 'recoreded' 
       end AS record 
FROM   (SELECT DISTINCT Generate_series((SELECT Date_trunc('minute', timestamp) 
                                                AS time 
                                         FROM   host_usage 
                                         ORDER  BY time 
                                         LIMIT  1), (SELECT 
                               Date_trunc('minute', timestamp) AS time 
                                                     FROM   host_usage 
                                                     ORDER  BY time DESC 
                                                     LIMIT  1), '1 minute') AS 
                        minute) 
       AS time 
       LEFT OUTER JOIN (SELECT Date_trunc('minute', host_usage.timestamp) AS 
                               success 
                        FROM   host_usage) AS recorded 
                    ON time.minute = recorded.success 
ORDER  BY time.minute; 
