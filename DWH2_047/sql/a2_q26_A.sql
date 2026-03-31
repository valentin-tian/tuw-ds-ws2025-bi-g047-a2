select 
    c.country_name as country,
    coalesce(AVG(case when p.param_name = 'PM1' then f.recordedvalue_avg end),0) as avg_pm1_2024,
    coalesce(AVG(case when p.param_name = 'NO2' then f.recordedvalue_avg end),0) as avg_no2_2024
from ft_param_city_month f
join dim_city c on f.city_key = c.city_key
join dim_param p on f.param_key = p.param_key
join dim_timemonth t on f.month_key = t.month_key
where t.year_num = 2024 and p.param_name in ('PM1', 'NO2')
group by c.country_name
order by c.country_name;
 


