-- Q2: For parameter O3, show Missing Days in Austria by City × Month for Q1 of 2023. Return Austrian Cities on rows and the first three months of 2023 (Jan–Mar) on columns.
SET search_path TO dwh2_047;

WITH o3_q1_2023 AS (
	SELECT
		c.city_name,
		t.year_num,
		t.month_num,
		f.missing_days
	FROM ft_param_city_month f
	JOIN dim_city c ON f.city_key = c.city_key
	JOIN dim_param p ON f.param_key = p.param_key
	JOIN dim_timemonth t ON f.month_key = t.month_key
	WHERE c.country_name = 'Austria'
		AND p.param_name = 'O3'
		AND t.year_num = 2023
		AND t.quarter_num = 1
)


SELECT
	city_name AS city,
	MAX(CASE WHEN month_num = 1 THEN missing_days END) AS jan_2023,
	MAX(CASE WHEN month_num = 2 THEN missing_days END) AS feb_2023,
	MAX(CASE WHEN month_num = 3 THEN missing_days END) AS mar_2023
FROM o3_q1_2023
GROUP BY city_name
ORDER BY city_name

