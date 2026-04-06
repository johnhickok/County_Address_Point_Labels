--Transform address labels and parcels to 3857 to create vector tiles

--create unique parcel geometries, then reproject to 3857
--create table parcels_geom_2229 as select distinct geom from parcels;

drop table if exists parcels_geom;
create table parcels_geom as 
select st_transform(geom, 3857) as geom
from parcels_geom_2229;
create index idx_parcels_geom_geom on parcels_geom using gist(geom);
drop table parcels_geom_2229;

--reproject address labels to 3857
create table address_labels_2229 as select * from address_labels;
drop table public.address_labels;
create table public.address_labels as
select
pt_label,
fulladdress,
src,
st_transform(geom, 3857) as geom
from address_labels_2229;
create index idx_address_labels_geom on address_labels using gist(geom);
drop table address_labels_2229;

alter table address_labels add column id serial primary key;

/*
updating vector tile layer
https://pro.arcgis.com/en/pro-app/2.8/help/sharing/overview/replace-web-layer.htm


joseph efelt service endpoints on datasets

usps zip webservice

https://eddm.usps.com/eddm/select-routes.htm
*/


