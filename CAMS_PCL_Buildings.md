<h2>Regroup CAMS Points</h2>
PostGIS can be used to regroup multiple address locations to LARIAC Building centroids. The code samples can be helpful, but the user needs to have some background in PostGIS, Python, and desktop GIS software like ArcGIS Pro or QGIS.
<br>
<br>
First, create a PostgreSQL database and enable PostGIS.
<br>
<pre>
CREATE EXTENSION POSTGIS;
</pre>
Download copies of LARIAC Buildings, Assessor Parcels, and CAMS Points into local file geodatases. Some sample Python scripts are provided in the folder <b>arcpy_download_gdb</b>.
<br>
<br>
Bring the buildings, cams points, and parcels layers (tables) into your database. The QGIS DB Manager is a popular tool, but some ogr2ogr expressions are included in the file <b>1o_ogr_upload_to_pg.txt</b>.
<br>
<br>
Create a non-stacked version of the parcels layer.
<br>
<pre>
CREATE TABLE PCLS_GEOM (
ID SERIAL PRIMARY KEY,
GEOM GEOMETRY(MultiPolygon,2229)
);
</pre>
Populate this table and create a spatial index.
<br>
<pre>
INSERT INTO PCLS_GEOM (GEOM) SELECT DISTINCT GEOM FROM PARCELS;
CREATE INDEX IDX_PCLS_GEOM ON PCLS_GEOM USING GIST(GEOM);
</pre>
Create an interim table for buildings with pcls_geom ids obtained from spatially joining building centroids. Note we are only using buildings where code = 'Building' and not 'Courtyard' or 'Free Standing Solar Structure'.
<br>
<pre>
CREATE TABLE BLDG_PCL AS
SELECT
PCLS_GEOM.ID AS PCL_ID,
ROUND(ST_AREA(BLDG.GEOM)::NUMERIC,0)::INTEGER AS BLDG_AREA,
BLDG.GEOM
FROM PCLS_GEOM
JOIN (SELECT GEOM FROM BUILDINGS WHERE CODE LIKE 'Building') BLDG
ON ST_INTERSECTS(PCLS_GEOM.GEOM, ST_CENTROID(BLDG.GEOM))
</pre>

Create an interim table with the largest building on each parcel.
<br>
<pre>
CREATE TABLE BLDG_LARGE AS
SELECT
BLDG_PCL.PCL_ID,
BLDG_PCL.GEOM
FROM
(SELECT
PCL_ID,
MAX(BLDG_AREA) AS BLDG_AREA
FROM BLDG_PCL
GROUP BY PCL_ID) AS B
LEFT JOIN BLDG_PCL
ON B.PCL_ID::TEXT || B.BLDG_AREA::TEXT = BLDG_PCL.PCL_ID::TEXT || BLDG_PCL.BLDG_AREA::TEXT
</pre>

Create and populate centroids of the largest buildings.
<br>
<pre>
CREATE TABLE PCL_PTS (
ID SERIAL PRIMARY KEY,
GEOM GEOMETRY(Point,2229)
;

INSERT INTO PCL_PTS 
(GEOM)
SELECT
ST_CENTROID(GEOM)
FROM BLDG_LARGE;

CREATE INDEX IDX_PCL_PTS ON PCL_PTS USING GIST(GEOM);
</pre>

Create an interim table of parcels with no building points.
<br>
CREATE TABLE PCL_NO_BLDG AS
SELECT a.*
FROM pcls_geom a
WHERE NOT EXISTS (
    SELECT 1
    FROM pcl_pts b
    WHERE ST_Intersects(a.geom, b.geom)
);
<br>
Insert points on surface of parcels with no buildings into PCL_PTS.
<br>
INSERT INTO PCL_PTS 
(GEOM)
SELECT
ST_POINTONSURFACE(GEOM)
FROM PCL_NO_BLDG;
<br>
At this stage, each parcel should have a single point. To verify, run some simple SQL tests below to see if counts are all the same. You can run more elaborate SQL tests or use desktop geoprocessing tool to find and fix excess or missing points.
<br>
SELECT COUNT(*) FROM PCL_PTS;
SELECT DISTINCT COUNT(*) FROM PCL_PTS;

SELECT COUNT(*) FROM PCLS_GEOM;
SELECT DISTINCT COUNT(*) FROM PCLS_GEOM;
<br>
NOTE: These steps may be a great help in large suburban areas where the main residential building represents a good rooftop location. Parcels with multiple large buildings may need to be edited one at a time as time permits.
<br>
<br>
Finally, load CAMS Points, grouped onto these new geometries.
<br>
CREATE TABLE CAMS_POINTS_REV AS
SELECT
CAMS_POINTS.OGC_FID,
CAMS_POINTS.OBJIDSTR,
CAMS_POINTS.AIN,
CAMS_POINTS.NUMPREFIX,
CAMS_POINTS.NUMBER,
CAMS_POINTS.NUMBERSUFFIX,
CAMS_POINTS.NUMSUFFIX,
CAMS_POINTS.PREMOD,
CAMS_POINTS.PREDIR,
CAMS_POINTS.PRETYPE,
CAMS_POINTS.STARTICLE,
CAMS_POINTS.STREETNAME,
CAMS_POINTS.POSTTYPE,
CAMS_POINTS.POSTDIR,
CAMS_POINTS.POSTMOD,
CAMS_POINTS.BLDGID,
CAMS_POINTS.BLDGSOURCE,
CAMS_POINTS.BLDGTYPEPL,
CAMS_POINTS.BLDGTYPE,
CAMS_POINTS.BLDGNAME,
CAMS_POINTS.FLRTYPEPL,
CAMS_POINTS.FLRTYPE,
CAMS_POINTS.FLRNAME,
CAMS_POINTS.UNITTYPE,
CAMS_POINTS.UNITNAME,
CAMS_POINTS.ZIPCODE,
CAMS_POINTS.ZIP4,
CAMS_POINTS.LEGALCOMM,
CAMS_POINTS.POSTCOMM1,
CAMS_POINTS.POSTCOMM2,
CAMS_POINTS.POSTCOMM3,
CAMS_POINTS.OTHERCOMM1,
CAMS_POINTS.OTHERCOMM2,
CAMS_POINTS.SOURCE,
CAMS_POINTS.SOURCEID,
CAMS_POINTS.MADRANK,
CAMS_POINTS.AROIDSTR,
CAMS_POINTS.OIDSTR,
CAMS_POINTS.PROPTYPE,
CAMS_POINTS.OBJID,
CAMS_POINTS.PREDIRABBR,
CAMS_POINTS.POSTDIRABBR,
CAMS_POINTS.PRETYPEABBR,
CAMS_POINTS.POSTTYPEABBR,
CAMS_POINTS.FULLNAME,
CAMS_POINTS.UPDATEDATE,
CAMS_POINTS.FULLADDRESS,
CAMS_POINTS.UNIQUEID,
CAMS_POINTS.STNAME_ENERGOV,
CAMS_POINTS.FULLADDRESS_ENERGOV,
CAMS_POINTS.MSAG_CITY,
CAMS_POINTS.ESN,
PCL_PTS.GEOM
FROM PCLS_GEOM
JOIN CAMS_POINTS
ON ST_INTERSECTS(PCLS_GEOM.GEOM, CAMS_POINTS.GEOM)
JOIN PCL_PTS
ON ST_INTERSECTS(PCLS_GEOM.GEOM, PCL_PTS.GEOM)
;

