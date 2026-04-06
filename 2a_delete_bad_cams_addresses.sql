--July 2025 cams_points had
--338 unusable records with number values as 0, -1, or null
--3,089 utility addresses, useful only to dpw
--0 records where unitname like ' ' that need to be null
--346 Records where streetname is null

--Remove unusable address locations
delete from cams_points
where number in (0, -1)
or number is null
or numsuffix ilike '%u%'
;

--Unit names need nulls where there are blank spaces
update cams_points
set unitname = null
where unitname like ' '
;

--Update numsuffix values where there are blank spaces
update cams_points
set numsuffix = null
where numsuffix like ''
;
