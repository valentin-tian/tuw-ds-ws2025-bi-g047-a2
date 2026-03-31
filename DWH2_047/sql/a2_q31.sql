-- Q31: O3 — Top 10 Cities by P95 Recorded Value for 2023
SET search_path TO dwh2_047;

SELECT
	c.region_name AS region,
	SUM(f.exceed_days_any) AS days
FROM ft_param_city_month f
JOIN dim_city c ON f.city_key = c.city_key
JOIN dim_param p ON f.param_key = p.param_key
JOIN dim_timemonth t ON f.month_key = t.month_key
WHERE t.year_num = 2024 AND p.category = 'Gas'
GROUP BY region
