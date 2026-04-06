--insert values from the City of L.A.
insert into address_labels (pt_label, fulladdress, src, geom)
select
case
when hse_frac_nbr like '' and unit_range like ''
then hse_nbr
when hse_frac_nbr > '' and unit_range like ''
then hse_nbr || ' ' || hse_frac_nbr
when hse_frac_nbr like '' and unit_range > ''
then hse_nbr || ' #' || unit_range
when hse_frac_nbr > '' and unit_range > ''
then hse_nbr || ' ' || hse_frac_nbr  || ' #' || unit_range
end
as pt_label,
replace (hse_nbr || ' ' ||
hse_frac_nbr || ' ' ||
hse_dir_cd || ' ' ||
str_nm || ' ' ||
str_sfx_cd || ' ' ||
str_sfx_dir_cd || ' ' ||
unit_range || ' ' ||
zip_cd, '  ', ' ')
as fulladdress,
'City LA' as src,
ST_SetSRID(ST_MakePoint(x_coord_nbr::numeric, y_coord_nbr::numeric),2229) as geom
from addresses_lacity
;

create index idx_address_labels_geom on address_labels using gist(geom);

