--create table address_labels from hi and lo values
drop table if exists address_labels;
create table address_labels as
select
case
-- single house numbers
when low_number = hi_number and coalesce (low_numsuffix,low_unitname,hi_numsuffix,hi_unitname) is null
then low_number::varchar(100)
-- multiple house numbers on a single point. fractions and units are ignored due to limited label space
when low_number != hi_number
then low_number::varchar(100) || '-' || hi_number::varchar(100)
-- fractional units
when low_number = hi_number and low_numsuffix ilike '%/%'
then low_number::varchar(100) || ' ' || low_numsuffix
-- addresses with multiple units
when low_number = hi_number 
  and coalesce(low_unitname, hi_unitname) is not null
  and (low_unitname != hi_unitname)
then low_number::varchar(100) || ' #' || low_unitname || '-' || hi_unitname
-- addresses with single units
when low_number = hi_number 
  and coalesce(low_unitname, hi_unitname) is not null
  and (low_unitname = hi_unitname or hi_unitname is null)
then low_number::varchar(100) || ' #' || low_unitname
end 
as pt_label,
fulladdress,
'CAMS' as src,
geom
from cams_points_notla_centroids_hi_lo;