SELECT
  date, 
  sum(users) OVER (ORDER BY date ASC ROWS BETWEEN unbounded preceding AND CURRENT ROW) AS total_users
FROM
  (SELECT
    date,
    count(USER) AS users
   FROM
     (SELECT
       min(date) AS date,
       account AS USER
      FROM
        (SELECT
          date_trunc('day', block_time) AS date,
          "from" AS account
         FROM ethereum."transactions"
         WHERE "to" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'
           AND success = 'true'
         ) AS table1
      GROUP BY account) AS table2
   GROUP BY date
   ORDER BY date)
