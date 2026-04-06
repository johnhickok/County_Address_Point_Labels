-- insert assessor addresses into address_labels table
insert into address_labels(pt_label, fulladdress, src, geom)
select
-- single house numbers
case 
when low_number like hi_number and coalesce (low_situsfraction,hi_situsfraction,low_unit,hi_unit) is null
then low_number
-- single house numbers with multiple units
when low_number like hi_number and coalesce (low_unit,hi_unit) is not null and low_unit not like hi_unit
then low_number || ' #' || low_unit || '-' || hi_unit
-- multiple house numbers with a single unit
when low_number not like hi_number 
  and coalesce(low_situsfraction,hi_situsfraction,low_unit) is null
  and hi_unit is not null
then low_number || '-' || hi_number || ' #' || hi_unit
-- single house numbers with a single unit
when low_number like hi_number and coalesce (low_unit,hi_unit) is not null and low_unit like hi_unit
then low_number || ' #' || hi_unit
when low_number like hi_number 
  and coalesce(low_situsfraction,hi_situsfraction,low_unit) is null
  and hi_unit is not null
then low_number || ' #' || hi_unit
-- multiple house numbers on a single point with no units
when low_number not like hi_number and coalesce (low_unit,hi_unit) is null
then low_number || '-' || hi_number
-- multiple house numbers on a single point with units
when low_number not like hi_number and coalesce (low_unit,hi_unit) is not null
then low_number || '-' || hi_number || ' #' || low_unit || '-' || hi_unit
-- house numbers with fractions
when coalesce(low_situsfraction,hi_situsfraction) is not null
then low_number || ' ' || hi_situsfraction
end as pt_label,
fulladdress,
'Assessor' as src,
geom
from pcls_no_cams_address_points_hi_lo

