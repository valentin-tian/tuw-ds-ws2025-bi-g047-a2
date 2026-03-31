select
    c.country_name as country,
    SUM(case when t.year_num = 2024 and t.month_num = 1 then f.exceed_days_any else 0 end) as jan_2024,
    SUM(case when t.year_num = 2024 and t.month_num = 2 then f.exceed_days_any else 0 end) as feb_2024,
    SUM(case when t.year_num = 2024 and t.month_num = 3 then f.exceed_days_any else 0 end) as mar_2024
from ft_param_city_month f
join dim_timemonth t on f.month_key = t.month_key
join dim_city c on f.city_key = c.city_key
join dim_param p on f.param_key = p.param_key
where
    p.param_name = 'PM2' 
    and t.year_num = 2024
    and t.month_num between 1 and 3 
group by c.country_name
order by c.country_name;
