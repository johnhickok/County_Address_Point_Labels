-- create table with address points from parcels not in address labels
drop table if exists pcls_no_cams_address_points;
create table pcls_no_cams_address_points as
select
pcls_no_cams.ain,
pcls_no_cams.situshouseno,
pcls_no_cams.situsfraction,
pcls_no_cams.situsdirection,
pcls_no_cams_units.situsunit_clean as situsunit,
pcls_no_cams.situsstreet,
pcls_no_cams.situsaddress,
pcls_no_cams.situscity,
pcls_no_cams.situsstate,
pcls_no_cams.situszip,
pcls_no_cams.geo_city,
--pcls_no_cams.fulladdress,
pcls_no_cams.situscity as mail_city,
--address_labels.fulladdress as test,
ST_PointOnSurface(pcls_no_cams.geom) as geom
from  pcls_no_cams
left join address_labels
on ST_Intersects(pcls_no_cams.geom, address_labels.geom)
left join pcls_no_cams_units
on pcls_no_cams.situsunit = pcls_no_cams_units.situsunit
where address_labels.fulladdress is null;

create index idx_pcls_no_cams_address_points_geom on pcls_no_cams_address_points using gist(geom);



-- create table with high and low address points
drop table if exists pcls_no_cams_address_points_hi_lo;
create table pcls_no_cams_address_points_hi_lo as
select
lownum.low_number,
hinum.hi_number,
lowsitusfraction.low_situsfraction,
hisitusfraction.hi_situsfraction,
lowunit.low_unit,
hiunit.hi_unit,
fulladdress.fulladdress,
lownum.geom
from
-- Low House Numbers
(select
geom,
min(situshouseno) as low_number
from pcls_no_cams_address_points
group by geom) lownum
join
-- High House Numbers
(select distinct on (geom)
geom,
max(situshouseno) as hi_number
from pcls_no_cams_address_points
group by geom) hinum
on lownum.geom = hinum.geom
join
-- Low House Number Fraction
(select distinct on (geom)
geom,
min(situsfraction) as low_situsfraction
from pcls_no_cams_address_points
group by geom) lowsitusfraction
on lownum.geom = lowsitusfraction.geom
join
-- High House Number Fraction
(select distinct on (geom)
geom,
max(situsfraction) as hi_situsfraction
from pcls_no_cams_address_points
group by geom) hisitusfraction
on lownum.geom = hisitusfraction.geom
join
-- Low Unit Numbers
(select distinct on (geom)
geom,
min(situsunit) as low_unit
from pcls_no_cams_address_points
group by geom) lowunit
on lownum.geom = lowunit.geom
join
-- High Unit Numbers
(select distinct on (geom)
geom,
max(situsunit) as hi_unit
from pcls_no_cams_address_points
group by geom) hiunit
on lownum.geom = hiunit.geom
join
-- Full Address (Low Address)
(select distinct on (geom)
geom,
situsaddress || ', ' || situscity || ' ' ||  situszip as fulladdress
from pcls_no_cams_address_points
order by geom, fulladdress) fulladdress
on lownum.geom = fulladdress.geom
;


-- replace blank spaces with nulls
update pcls_no_cams_address_points_hi_lo
set low_situsfraction =  null where low_situsfraction like ' ';
update pcls_no_cams_address_points_hi_lo
set hi_situsfraction =  null where hi_situsfraction like ' ';
update pcls_no_cams_address_points_hi_lo
set low_situsfraction =  null where low_situsfraction like '';
update pcls_no_cams_address_points_hi_lo
set hi_situsfraction =  null where hi_situsfraction like '';
update pcls_no_cams_address_points_hi_lo
set low_unit =  null where low_unit like ' ';
update pcls_no_cams_address_points_hi_lo
set hi_unit =  null where hi_unit like ' ';
update pcls_no_cams_address_points_hi_lo
set low_unit =  null where low_unit like '';
update pcls_no_cams_address_points_hi_lo
set hi_unit =  null where hi_unit like '';


