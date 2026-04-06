--lists city names and counts of parcels with no CAMS points
select distinct
c.city_name,
case
when p.cnt is null then 0
else p.cnt
end as cnt
from 
(select distinct
case
    when city_type like 'City' then city_name
    else 'Unincorporated'
end as city_name
from city_boundaries
) c
left join
(select geo_city, count(geo_city) as cnt from public.pcls_no_cams
group by geo_city) p
on c.city_name = p.geo_city