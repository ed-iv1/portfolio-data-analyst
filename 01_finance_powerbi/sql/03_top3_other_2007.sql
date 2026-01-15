WITH fact_month AS(SELECT
	date_trunc('month', p.payment_date) AS month_date,
	sum(p.amount) AS revenue_fact
FROM
	payment p
WHERE
	p.payment_date >= DATE '2007-01-01'
	AND p.payment_date < DATE '2008-01-01'
GROUP BY
	month_date),
plan_month AS(SELECT * FROM(VALUES
(DATE '2007-01-01', 10000::NUMERIC), 
(DATE '2007-02-01', 11000::NUMERIC), 
(DATE '2007-03-01', 12000::NUMERIC),
(DATE '2007-04-01', 13000::NUMERIC), 
(DATE '2007-05-01', 14000::NUMERIC), 
(DATE '2007-06-01', 15000::NUMERIC),
(DATE '2007-07-01', 16000::NUMERIC), 
(DATE '2007-08-01', 17000::NUMERIC), 
(DATE '2007-09-01', 18000::NUMERIC),
(DATE '2007-10-01', 19000::NUMERIC), 
(DATE '2007-11-01', 20000::NUMERIC), 
(DATE '2007-12-01', 21000::NUMERIC))
AS p(month_date, plan_revenue)),
vetrine AS(
SELECT fm.month_date AS "месяц",
	fm.revenue_fact AS "выручка_факт",
	pm.plan_revenue AS "выручка_план",
	ROUND((
		fm.revenue_fact - pm.plan_revenue
	)::NUMERIC * 100 / NULLIF(pm.plan_revenue, 0), 2) AS "отклонение_проценты"
FROM
	fact_month fm
JOIN plan_month pm ON
	pm.month_date = fm.month_date),
final_vetrine AS (
	SELECT
		"месяц"::text,
		"выручка_факт",
		"выручка_план",
		"отклонение_проценты",
		ROW_NUMBER() OVER(ORDER BY "отклонение_проценты" DESC) AS "ранг_по_отклонению"
	FROM
		vetrine
), year_total AS(SELECT sum("выручка_факт") AS "год_факт" FROM final_vetrine),
final_rows AS (
	SELECT
		"месяц",
		"выручка_факт",
		"выручка_план",
		"отклонение_проценты",
		"ранг_по_отклонению"
	FROM
		final_vetrine
	WHERE
		"ранг_по_отклонению" <= 3
UNION ALL
	SELECT
		'Прочие' AS "месяц",
		sum("выручка_факт") AS "выручка_факт",
		sum("выручка_план") AS "выручка_план",
		ROUND((sum("выручка_факт") - sum("выручка_план"))::NUMERIC * 100 / NULLIF(sum("выручка_план"), 0), 2) AS "отклонение_проценты", 4 AS "ранг_по_отклонению"
	FROM
		final_vetrine
	WHERE
		"ранг_по_отклонению" >= 4
)
SELECT
	"месяц",
	"выручка_факт",
	"выручка_план",
	"отклонение_проценты",
		ROUND("выручка_факт"::NUMERIC * 100 / NULLIF((SELECT "год_факт" FROM year_total), 0), 2) AS "доля_месяца_год_проценты", "ранг_по_отклонению"
FROM
	final_rows
ORDER BY "ранг_по_отклонению"