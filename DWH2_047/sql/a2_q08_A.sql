select
    c.country_name as country,
    AVG(f.data_quality_avg) as avg_data_quality_2024
from ft_param_city_month f
join dim_city c on f.city_key = c.city_key
join dim_timemonth t on f.month_key = t.month_key
where t.year_num = 2024
group by c.country_name
having SUM(f.devices_reporting_count) >= 2000
order by c.country_name;
