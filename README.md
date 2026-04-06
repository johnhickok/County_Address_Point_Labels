# County Address Point Labels
Code samples using PotGIS to generate address point labels used on maps within Los Angeles County

<h2>County Address Labels</h2>
The steps below outline creating address labels from CAMS Points, L.A. City Addresses, and Assessor Parcels data. It is assumed the user knows how to use the GIS tools mentioned.

0. You'll need some software.
<a href="https://www.esri.com/en-us/arcgis/products/arcgis-pro/">ArcGIS Pro</a>, 
<a href="https://qgis.org/en/site/">QGIS</a>, 
<a href="https://www.postgresql.org/">PostgreSQL</a> + <a href="https://postgis.net/">PostGIS</a>,
<a href="https://www.pgadmin.org/">pgAdmin 4</a>, and your favorite text editor. You'll also need to know Python if you need to update any of the scripts in this repo for local use.

1. Before everything else, drop these tables in PostgreSQL
<ul>
<li>cams_points</li>
<li>cams_lines</li>
<li>city_boundaries</li>
<li>parcels</li>
<li>addresses_lacity (Download the CSV at <a href="https://data.lacity.org/City-Infrastructure-Service-Requests/Addresses-in-the-City-of-Los-Angeles/4ca8-mxuh">City of L.A. Open Data Portal</a>.)</li>
</ul>

You can run the scripts below to download the feature classes into local GDB files:
<dl>
<dd>1a_download_city_boundaries.py</dd>
<dd>1b_download_csa.py</dd>
<dd>1c_download_cams_lines.py</dd>
<dd>1d_download_cams_points.py</dd>
<dd>1e_download_parcels.py</dd>
</dl>

The scripts above create local file geodatabase layers below.

<dl>
<dd>downloaded_city_boundaries.gdb/city_boundaries</dd>
<dd>downloaded_csa.gdb/csa</dd>
<dd>downloaded_cams_lines.gdb/cams_lines</dd>
<dd>downloaded_cams_points.gdb/cams_points</dd>
<dd>downloaded_parcels.gdb/parcels</dd>
</dl>

If you have trouble running or updating these scripts, you can download the layers into local GDB files manually.
<br>
<br>
A very fast way to load your geodatabase feature classes into PostgreSQL is to copy/paste ogr2ogr expressions from the file 1o_ogr_upload_to_pg.txt and run them in the OSGeo4W Shell.
<br>
<br>
If you are unfamiliar with the the OSGeo4W Shell or GDAL, you can use QGIS to import the feature classes, though it may take longer.
<br>
<br>
<i>Note steps 2-6 below are SQL code you can run in pgAdmin4</i>
<br>
<br>
2. Cleanup cams_points and create/update the pcls_no_cams table
<br>
<br>
2a_delete_bad_cams_addresses.sql - this script removes records from the cams_points table with unusable values, like 0, -1 or null. Utility addresses are not used outside of DPW and are also removed.

2b_create_pcls_no_cams.sql - Running this script creates two tables
<li>pcls_no_cams - This table includes geometry of parcels with no cams_points touching them
</li>
<li>pcls_no_cams_geocode_test - This creates a script with a table similar to the above, but without geometry. 
  - Geocode this table in ArcGIS pro against the cams_points geocoding service.
  - Import your geocoded feature class from your local file geodatabase into your PostgreSQL database.
  - Create a delete query to remove values from your pcls_no_cams based on successfully geocoded values.
  <pre>
    delete from pcls_no_cams where ain in (select user_ain from geocode_results)
  </pre>
<br>
NOTE: You may run the script geocode_pcls_no_cams.py to geocode these values and output a file geocode_results.csv. Just bear in mind the Python script will take about 2 hours, while ArcGIS Pro will take a few minutes.
</li>

Last, summarize the pcls_no_cams table by geo_city and update <i>cams_missing_by_city.xlsx</i>.
<br>
<br>
3. Create labels from cams_points outside the City of Los Angeles
<br>
Run the following SQL scripts
<li>3a_cams_not_la.sql - creates table cams_points_notla</li>
<li>3b_cams_hi_lo.sql - creates table with high and low values</li>
<li>3c_labels_from_hi_lo.sql - creates initial address_labels from high and low values</li>
<br>
4. Insert values from the City of Los Angeles
<li>4_insert_addresses_lacity.sql - inserts values from the addresses_lacity table</li>
<br>
5. Insert points from parcels not found in cams_points or L.A. City
<li>5a_pcls_no_cams_units.sql - creates table pcls_no_cams_units with unique values along with some cleanup expressions. After running this query, search for and update any values that were not cleaned up.</li>
<li>5b_pcls_points.sql - converts parcels to points</li>
<li>5c_pcls_points_to_labels.sql - adds values to the address_labels table.</li>
<br>
6. Prepare parcel lines and address points for uploading as tiles
<li>6_tansform_3857.sql - This SQL transforms address labels and parcels into Web Mercator (EPSG:3857) for uploading vector tiles. It also compresses parcels into unique geometries for faster rendering.</li>
<li>shp - This is the folder you will download your PostgreSQL tables into shapefiles. ArcGIS Pro can be problematic for exporting large PostgreSQL tables. This folder inclues ogr2ogr expressions in a file postgis_to_shapefiles.txt, or you can use QGIS to export these files.</li>
<br>
7. addresses_vector_tiles.aprx - Open this file in ArcGIS Pro and import the tables from PostgreSQL into addresses_vector_tiles.gdb.

<table>
  <tr>
    <th>PostgerSQL</th>
    <th>Geodatabase</th>
    <th>AGOL Vector Tile Layers</th>
  </tr>
  <tr>
    <td>address_labels</td>
    <td>address_labels_3857</td>
    <td>DCFS Address Labels</td>
  </tr>
  <tr>
    <td>parcels_geom</td>
    <td>parcel_geometry_3857</td>
    <td>DCFS Parcels</td>
  </tr>
</table>

Once the new feature classes are uploaded, truncate and append the geodatabase feature classes with new data. Run the model Truncate and Load from Shapefile. Once complete, compare feature counts in your PostgreSQL tables and local file geodatabase feature classes before going onto the next step.
<br>

8. Share the two layers as new vector tile layers. 
<br>
Right-click and share each as a web layer. Under Layer Type, select Vector Tile, and make sure the Feature box is unchecked. This creates a layer based on a Tile.
<br>

9. Update existing layers in ArcGIS Online
<br>
See the <a href="https://pro.arcgis.com/en/pro-app/latest/help/sharing/overview/replace-web-layer.htm">Esri docs</a> on how to replace existing vector tiles with the new ones you just uploaded.
