-- Q7: For parameter PM10, show Avg Recorded Value and P95 Recorded Value by Country for 2023. Return Countries on rows and two columns—Avg Recorded Value and P95 Recorded Value for the year 2023.
SET search_path TO dwh2_047;

SELECT
	c.country_name AS country,
	AVG(f.recordedvalue_avg) as pm10_avg,
	AVG(f.recordedvalue_p95) as pm10_p95
FROM ft_param_city_month f
JOIN dim_city c ON f.city_key = c.city_key
JOIN dim_param p ON f.param_key = p.param_key
JOIN dim_timemonth t ON f.month_key = t.month_key
WHERE t.year_num = 2023 AND p.param_name = 'PM10'
GROUP BY c.country_name
ORDER BY c.country_name
