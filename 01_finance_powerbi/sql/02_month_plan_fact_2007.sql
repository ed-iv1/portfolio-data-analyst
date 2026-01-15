WITH fact_month AS (
  SELECT
    date_trunc('month', p.payment_date) AS month_date,
    sum(p.amount) AS revenue_fact
  FROM payment p
  WHERE p.payment_date >= DATE '2007-01-01'
    AND p.payment_date <  DATE '2008-01-01'
  GROUP BY month_date
),
plan_month AS (
  SELECT *
  FROM (VALUES
    (DATE '2007-01-01', 10000::numeric),
    (DATE '2007-02-01', 11000::numeric),
    (DATE '2007-03-01', 12000::numeric),
    (DATE '2007-04-01', 13000::numeric),
    (DATE '2007-05-01', 14000::numeric),
    (DATE '2007-06-01', 15000::numeric),
    (DATE '2007-07-01', 16000::numeric),
    (DATE '2007-08-01', 17000::numeric),
    (DATE '2007-09-01', 18000::numeric),
    (DATE '2007-10-01', 19000::numeric),
    (DATE '2007-11-01', 20000::numeric),
    (DATE '2007-12-01', 21000::numeric)
  ) AS p(month_date, plan_revenue)
)
SELECT
  fm.month_date AS "месяц",
  fm.revenue_fact AS "выручка_факт",
  pm.plan_revenue AS "выручка_план",
  (fm.revenue_fact - pm.plan_revenue) AS "отклонение",
  ROUND(
    (fm.revenue_fact - pm.plan_revenue) * 100 / NULLIF(pm.plan_revenue, 0),
    2
  ) AS "отклонение_проценты"
FROM fact_month fm
JOIN plan_month pm
  ON pm.month_date = fm.month_date
ORDER BY "месяц";