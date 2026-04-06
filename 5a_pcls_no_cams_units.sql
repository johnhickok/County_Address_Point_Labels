drop table if exists pcls_no_cams_units;
create table pcls_no_cams_units as 
select distinct 
pcls_no_cams.situsunit, 
pcls_no_cams.situsunit as situsunit_clean
from  pcls_no_cams
left join address_labels
on ST_Intersects(pcls_no_cams.geom, address_labels.geom)
where address_labels.fulladdress is null
order by pcls_no_cams.situsunit
;

alter table pcls_no_cams_units add column id serial primary key;

update pcls_no_cams_units
set situsunit_clean = replace(situsunit_clean, '# ', '')
where situsunit_clean ilike '# %';

update pcls_no_cams_units
set situsunit_clean = replace(situsunit_clean, '#', '')
where situsunit_clean ilike '#%';

update pcls_no_cams_units
set situsunit_clean = situsunit_clean::integer::varchar(8)
where situsunit_clean ilike '0%';

update pcls_no_cams_units
set situsunit_clean = replace(situsunit_clean, 'NO ', '')
where situsunit_clean ilike 'NO %';

update pcls_no_cams_units
set situsunit_clean = replace(situsunit_clean, 'PH ', '')
where situsunit_clean ilike 'PH %';

update pcls_no_cams_units
set situsunit_clean = replace(situsunit_clean, 'PH', '')
where situsunit_clean ilike 'PH%';

update pcls_no_cams_units
set situsunit_clean = replace(situsunit_clean, 'UNIT ', '')
where situsunit_clean ilike 'UNIT %';

update pcls_no_cams_units
set situsunit_clean = replace(situsunit_clean, 'SPC#', '')
where situsunit_clean ilike 'SPC#%';

update pcls_no_cams_units
set situsunit_clean = replace(situsunit_clean, 'STE ', '')
where situsunit_clean ilike 'STE %';

update pcls_no_cams_units
set situsunit_clean = replace(situsunit_clean, 'APT', '')
where situsunit ilike 'APT%';

update pcls_no_cams_units
set situsunit_clean = replace(situsunit_clean, ' ', '')
where situsunit_clean like ' %';

update pcls_no_cams_units
set situsunit_clean = replace(situsunit_clean, '  ', '')
where situsunit_clean like '  %';

--update public.pcls_no_cams_units
--set situsunit_clean = trim(situsunit_clean, ' ')
--where substring(situsunit_clean, 1, 1) like ' ';
