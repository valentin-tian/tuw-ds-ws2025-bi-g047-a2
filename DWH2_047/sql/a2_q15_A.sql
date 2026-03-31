select
    c.country_name as country,
    SUM(case when t.year_num = 2023 then f.exceed_days_any else 0 end) as exceed_days_2023,
    SUM(case when t.year_num = 2024 then f.exceed_days_any else 0 end) as exceed_days_2024
from ft_param_city_month f
join dim_city c on f.city_key = c.city_key
join dim_timemonth t on f.month_key = t.month_key
where t.year_num in (2023, 2024) and c.region_name = 'Eastern Europe'
group by c.country_name
order by c.country_name;
