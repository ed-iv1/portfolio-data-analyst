WITH sum_day AS (
  SELECT
    date_trunc('day', p.payment_date) AS day_date,
    sum(p.amount) AS sum_amt
  FROM payment p
  WHERE p.payment_date >= DATE '2007-01-01'
    AND p.payment_date <  DATE '2008-01-01'
  GROUP BY day_date
)
SELECT
  day_date AS "дата_продажи",
  sum_amt  AS "выручка",
  SUM(sum_amt) OVER(
    ORDER BY day_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS "выручка_накопительно_с_начала_года",
  ROUND(
    sum_amt::numeric * 100 / NULLIF(SUM(sum_amt) OVER(), 0),
    2
  ) AS "доля_дня_в_выручке_года_%"
FROM sum_day
ORDER BY day_date;