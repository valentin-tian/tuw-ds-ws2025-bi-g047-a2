-- Q27: Show Data Volume (KB) by Country in Eastern Europe for 2023 and 2024. Return Eastern European countries on rows and two columns—2023 and 2024 totals of Data Volume (KB).
SET search_path TO dwh2_047;

WITH dvolume_kb AS (
		SELECT 
			c.country_name AS country,
			t.year_num AS year,
			AVG(f.data_volume_kb_sum) as dvolume_kb
		FROM ft_param_city_month f
		JOIN dim_city c ON f.city_key = c.city_key
		JOIN dim_timemonth t ON f.month_key = t.month_key
		WHERE t.year_num IN (2023, 2024) AND c.region_name = 'Eastern Europe'
		GROUP BY c.country_name, t.year_num
	)
	
SELECT
	country,
	MAX(CASE WHEN year = 2023 THEN dvolume_kb END) AS dvolume_kb_2023,
	MAX(CASE WHEN year = 2024 THEN dvolume_kb END) AS dvolume_kb_2024
FROM dvolume_kb
GROUP BY country
ORDER BY country