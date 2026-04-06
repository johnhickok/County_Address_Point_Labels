-- create table with cams points outside the City of L.A.
drop table if exists cams_points_notla;
create table cams_points_notla as
select * from (
select cams_points.*,
city_boundaries.city_name as geo_city
from city_boundaries
join cams_points
on st_intersects(city_boundaries.geom, cams_points.geom)) cams_cities
where geo_city not ilike 'Los Angeles';

create index idx_cams_points_notla_geom on cams_points_notla using gist(geom);

-- consolidate address points to parcel point-on-surface geometries

-- create a simplified geometry layer from parcels (SRID 2229 = CCS Zone 5)
create table parcels_geom_2229 as select distinct geom from parcels;
alter table parcels_geom_2229 add column id serial primary key;
create index idx_parcels_geom_2229 on parcels_geom_2229 using gist(geom);

drop table if exists cams_points_notla_centroids;

create table if not exists cams_points_notla_centroids
(
    "number" integer,
    numsuffix character varying(5),
    unitname character varying(15),
    fulladdress character varying(75),
    geom geometry(point,2229)
)
;

insert into cams_points_notla_centroids (
number,
numsuffix,
unitname,
fulladdress,
geom ) select
cams_points_notla.number,
cams_points_notla.numsuffix,
cams_points_notla.unitname,
cams_points_notla.fulladdress,
ST_PointOnSurface(parcels_geom_2229.geom) as geom
from cams_points_notla
left join parcels_geom_2229
on st_intersects(cams_points_notla.geom, parcels_geom_2229.geom)
where parcels_geom_2229.id is not null
;

insert into cams_points_notla_centroids (
number,
numsuffix,
unitname,
fulladdress,
geom ) select
cams_points_notla.number,
cams_points_notla.numsuffix,
cams_points_notla.unitname,
cams_points_notla.fulladdress,
cams_points_notla.geom
from cams_points_notla
left join parcels_geom_2229
on st_intersects(cams_points_notla.geom, parcels_geom_2229.geom)
where parcels_geom_2229.id is null
;

create index idx_cams_points_notla_centroids on cams_points_notla_centroids using gist(geom);

