-- Assignment 2 ETL: ft_param_city_month
-- GRAIN: month_key × city_key × param_key

-- EXAMPLE SHAPE (sketch only):
-- TRUNCATE TABLE ft_param_city_month;
-- WITH cte1 AS (...),
--      cte2 AS (...),
--      cte3 AS (...),
--      ... AS (...),
--      final_cte AS (...)
-- INSERT INTO ft_param_city_month (...columns...)
-- SELECT ... FROM final_cte;

-- Make A2 dwh2_xxx, stg2_xxx schemas the default for this session
SET search_path TO dwh2_047, stg2_047;

-- =======================================
-- Load ft_param_city_month
-- =======================================

-- Step 1: Truncate target table - ft_param_city_month
TRUNCATE TABLE ft_param_city_month RESTART IDENTITY CASCADE;

WITH cte1 AS (
		SELECT
	        r.id AS reading_id,
	        r.sensordevid AS sensordevice_id,
	        sd.cityid AS city_id,
	        c.cityname AS city_name,
	        co.countryname AS country_name,
	        r.paramid AS param_id,
	        p.paramname AS param_name,
	        r.readat::date AS reading_date,
	        date_trunc('month', r.readat)::date AS month_start,
	        r.recordedvalue,
	        r.datavolumekb,
	        r.dataquality
	    FROM tb_readingevent r
	    JOIN tb_sensordevice sd ON sd.id = r.sensordevid
	    JOIN tb_city c ON c.id = sd.cityid
	    JOIN tb_country co ON co.id = c.countryid
	    JOIN tb_param p ON p.id = r.paramid
	),
	
	cte2 AS (
	    SELECT
	        tm.month_key,
	        tm.days_in_month,
	        dc.city_key,
	        dp.param_key,
	        cte1.sensordevice_id,
	        cte1.param_id,
	        cte1.reading_date,
	        cte1.recordedvalue,
	        cte1.datavolumekb,
	        cte1.dataquality
	    FROM cte1
	    JOIN dim_timemonth tm ON tm.mfirst_day = cte1.month_start
	    JOIN dim_city dc ON dc.city_name = cte1.city_name AND dc.country_name = cte1.country_name
	    JOIN dim_param dp ON dp.param_name = cte1.param_name
	),
	
	cte3 AS (
		SELECT
			pa.paramid AS param_id,
			pa.threshold,
			a.alertname,
			ROW_NUMBER() OVER (PARTITION BY pa.paramid ORDER BY pa.threshold) AS alert_rank
		FROM tb_paramalert pa 
		JOIN tb_alert a ON a.id = pa.alertid
	),
	
	cte4 AS (
		SELECT
			cte2.month_key,
			cte2.days_in_month,
			cte2.city_key,
			cte2.param_key,
			cte2.sensordevice_id,
			cte2.param_id,
			cte2.reading_date,
			cte2.recordedvalue,
			cte2.datavolumekb,
			cte2.dataquality,
			COALESCE (MAX(cte3.alert_rank) FILTER (WHERE cte2.recordedvalue >= cte3.threshold), 0) AS reading_rank
		FROM cte2
		LEFT JOIN cte3 ON cte3.param_id = cte2.param_id
		GROUP BY 
			cte2.month_key,
			cte2.days_in_month,
			cte2.city_key,
			cte2.param_key,
			cte2.sensordevice_id,
			cte2.param_id,
			cte2.reading_date,
			cte2.recordedvalue,
			cte2.datavolumekb,
			cte2.dataquality
	),
	
	cte5 AS (
		SELECT
			month_key,
			city_key,
			param_key,
			reading_date,
			MAX(reading_rank) AS daily_rank
		FROM cte4
		GROUP BY
			month_key,
			city_key,
			param_key,
			reading_date
	),
	
	final_cte AS (
		SELECT
			cte4.month_key,
			cte4.city_key,
			cte4.param_key,
			COUNT(DISTINCT (cte4.sensordevice_id, cte4.reading_date)) AS reading_events_count,
			COUNT(DISTINCT cte4.sensordevice_id) AS devices_reporting_count,
			SUM(cte4.datavolumekb) AS data_volume_kb_sum,
			AVG(cte4.recordedvalue) AS recordedvalue_avg,
			percentile_disc(0.95) WITHIN GROUP (ORDER BY cte4.recordedvalue) AS recordedvalue_p95,
			AVG(cte4.dataquality) AS data_quality_avg,
			MIN(cte4.days_in_month) AS days_in_month,
			COUNT(DISTINCT cte4.reading_date) AS days_with_readings,
			COALESCE(MAX(cte5.daily_rank), 0) AS monthly_peak_rank,
			COUNT(DISTINCT CASE
							  WHEN cte5.daily_rank >= 1
							  THEN cte5.reading_date 
						   END) AS exceed_days_any
			FROM cte4
			LEFT JOIN cte5 ON cte5.month_key = cte4.month_key AND cte5.city_key = cte4.city_key AND cte5.param_key = cte4.param_key AND cte5.reading_date = cte4.reading_date
			GROUP BY
				cte4.month_key,
				cte4.city_key,
				cte4.param_key
	)

INSERT INTO ft_param_city_month (
	ft_pcm_key,	
	month_key,
	city_key,
	param_key,
	alertpeak_key,
	reading_events_count,
	devices_reporting_count,
	recordedvalue_avg,
	recordedvalue_p95,
	exceed_days_any,
	data_volume_kb_sum,
	data_quality_avg,
	missing_days,
	etl_load_ts
)

SELECT
	ROW_NUMBER() OVER (ORDER BY month_key, city_key, param_key) AS ft_pcm_key,
	month_key,
	city_key,
	param_key,
	CASE monthly_peak_rank
		WHEN 0 THEN 1000
		WHEN 1 THEN 1001
		WHEN 2 THEN 1002
		WHEN 3 THEN 1003
		WHEN 4 THEN 1004
	END AS alertpeak_key,
	reading_events_count,
    devices_reporting_count,
    recordedvalue_avg,
    recordedvalue_p95,
    exceed_days_any,
    data_volume_kb_sum,
    data_quality_avg,
    (days_in_month - days_with_readings) AS missing_days,
    CURRENT_TIMESTAMP AS etl_load_ts
FROM final_cte

