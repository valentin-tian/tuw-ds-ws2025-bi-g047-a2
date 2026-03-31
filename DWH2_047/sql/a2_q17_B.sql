-- Q17: Show Avg Data Quality by Country for 2023 and 2024. Return Countries on rows and two columns - 2023 and 2024 values of Avg Data Quality.
SET search_path TO dwh2_047;

WITH dquality AS (
		SELECT 
			c.country_name AS country,
			t.year_num AS year,
			AVG(f.data_quality_avg) as data_quality
		FROM ft_param_city_month f
		JOIN dim_city c ON f.city_key = c.city_key
		JOIN dim_timemonth t ON f.month_key = t.month_key
		WHERE t.year_num IN (2023, 2024)
		GROUP BY c.country_name, t.year_num
	)

SELECT
	country,
	MAX(CASE WHEN year = 2023 THEN data_quality END) AS data_quality_2023,
	MAX(CASE WHEN year = 2024 THEN data_quality END) AS data_quality_2024
FROM dquality
GROUP BY country
ORDER BY country