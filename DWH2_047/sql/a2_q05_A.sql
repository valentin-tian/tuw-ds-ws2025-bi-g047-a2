select
    p.category as param_category,
    SUM(case when t.year_num = 2023 then f.data_volume_kb_sum else 0 end) as year_2023,
    SUM(case when t.year_num = 2024 then f.data_volume_kb_sum else 0 end) as year_2024
from ft_param_city_month f
join dim_param p on f.param_key = p.param_key
join dim_timemonth t on f.month_key = t.month_key
where t.year_num in (2023, 2024)
group by p.category
order by p.category;
