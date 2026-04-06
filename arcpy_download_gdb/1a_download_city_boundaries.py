# arcpy script for downloading City Boundaries
# DCFS GIS Team 2023-07-28

import datetime

# Current time and date
now = datetime.datetime.now()
now_txt = now.strftime("%Y-%m-%d %H:%M:%S")
print("start: ", now_txt)

print("Importing arcpy and other libraries")
import arcpy, os
 
# Set environment settings
arcpy.env.workspace = this_folder = os.getcwd()

# Remove downloaded_city_boundaries.gdb if exists:
try:
  arcpy.Delete_management('downloaded_city_boundaries.gdb')
  print('downloaded_city_boundaries.gdb deleted')
except OSError:
  pass

print('Connect to SDE')
cities = 'sde_connections\\eGIS_Boundaries_Political.sde\eGIS_Boundaries_Political.EGIS.DPW_CITY_BOUNDARIES'

print('Create a file geodatabase')
arcpy.CreateFileGDB_management(this_folder, "downloaded_city_boundaries.gdb", "CURRENT")

print('importing city boundaries...')
arcpy.FeatureClassToFeatureClass_conversion(cities, 'downloaded_city_boundaries.gdb', 'city_boundaries')

now = datetime.datetime.now()
now_txt = now.strftime("%Y-%m-%d %H:%M:%S")
print("Process Completed! ", now_txt)

