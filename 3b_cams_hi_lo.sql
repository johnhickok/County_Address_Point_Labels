--create cams points with high and low values from cams_points_notla_centroids
drop table if exists cams_points_notla_centroids_hi_lo;
create table cams_points_notla_centroids_hi_lo as
select
lownum.low_number,
hinum.hi_number,
lownumsuffix.low_numsuffix,
hinumsuffix.hi_numsuffix,
lowunitname.low_unitname,
hiunitname.hi_unitname,
fulladdress.fulladdress,
lownum.geom
from
-- Low House Numbers
(select
geom,
min(number) as low_number
from cams_points_notla_centroids
group by geom) lownum
join
-- High House Numbers
(select
geom,
max(number) as hi_number
from cams_points_notla_centroids
group by geom) hinum
on lownum.geom = hinum.geom
join
-- Low House Number Suffixes
(select
geom,
min(numsuffix) as low_numsuffix
from cams_points_notla_centroids
group by geom) lownumsuffix
on lownum.geom = lownumsuffix.geom
join
-- High House Number Suffixes
(select
geom,
max(numsuffix) as hi_numsuffix
from cams_points_notla_centroids
group by geom) hinumsuffix
on lownum.geom = hinumsuffix.geom
join
-- Low Unit Numbers
(select
geom,
min(unitname) as low_unitname
from cams_points_notla_centroids
--order by geom, NULLIF(regexp_replace(unitname, '\D','','g'), '')::integer) lowunitname
group by geom) lowunitname
on lownum.geom = lowunitname.geom
join
-- High Unit Numbers
(select
geom,
max(unitname) as hi_unitname
from cams_points_notla_centroids
--order by geom, NULLIF(regexp_replace(unitname, '\D','','g'), '')::integer desc) hiunitname
group by geom) hiunitname
on lownum.geom = hiunitname.geom
join
-- Full Address (Low Address)
(select distinct on (geom)
geom,
fulladdress
from cams_points_notla_centroids
order by geom, fulladdress) fulladdress
on lownum.geom = fulladdress.geom
;
alter table cams_points_notla_centroids_hi_lo add column id serial primary key;
create index idx_cams_points_notla_centroids_hi_lo_geom on cams_points_notla_centroids_hi_lo using gist(geom);