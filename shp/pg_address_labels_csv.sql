--create table address_labels_text as
select
pt_label,
fulladdress,
src,
round(st_x(st_transform(geom,4326))::numeric,6)::text as lon,
round(st_y(st_transform(geom,4326))::numeric,6)::text as lat
from public.address_labels