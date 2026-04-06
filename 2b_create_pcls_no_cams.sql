--find parcels with no cams_points intersecting them
drop table if exists pcls_no_cams;
create table pcls_no_cams as
select
pcls.ain,
pcls.situshouseno,
pcls.situsfraction,
pcls.situsdirection,
pcls.situsunit,
pcls.situsstreet,
pcls.situsaddress,
pcls.situscity,
'CA' as situsstate,
pcls.situszip,
city_boundaries.city_name as geo_city,
--cams_points.fulladdress,
case
when csa.community like ' '
then csa.lcity
when csa.community is not null
then csa.community
end as mail_city,
case
when pcls.legaldescription ilike '%condo%'
  or pcls.legaldescription ilike '%airspace%'
then 'Yes'
else 'No'
end as condo,
pcls.legaldescription,
pcls.geom as geom
from (select * from parcels where situshouseno > '0') as pcls
left join cams_points
on ST_Intersects(pcls.geom, cams_points.geom)
left join city_boundaries
on ST_Intersects(city_boundaries.geom, ST_Centroid(pcls.geom))
left join csa
on ST_Intersects(csa.geom, ST_Centroid(pcls.geom))
where cams_points.fulladdress is null;

create index idx_pcls_no_cams_geom on pcls_no_cams using gist(geom);

--create a table to test geocoding (no geometry)
drop table if exists pcls_no_cams_geocode_test;
create table pcls_no_cams_geocode_test as
select 
ain,
situsaddress,
left(situscity, length(situscity)-3) as situscity,
situsstate,
left(situszip, 5) as zip
from public.pcls_no_cams
;
