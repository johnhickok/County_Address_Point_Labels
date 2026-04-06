# arcpy script for downloading CAMS Address Points
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

# Remove downloaded_cams_points.gdb if exists:
try:
  arcpy.Delete_management('downloaded_cams_points.gdb')
  print('downloaded_cams_points.gdb deleted')
except OSError:
  pass

print('Connect to SDE')
cams_points = 'sde_connections\\eGIS_Addressing.sde\eGIS_Addressing.EGIS.CAMS_ADDRESS_POINTS'

print('Create a file geodatabase')
arcpy.CreateFileGDB_management(this_folder, "downloaded_cams_points.gdb", "CURRENT")

print('importing CAMS Points...')
arcpy.FeatureClassToFeatureClass_conversion(cams_points, 'downloaded_cams_points.gdb', 'cams_points')

now = datetime.datetime.now()
now_txt = now.strftime("%Y-%m-%d %H:%M:%S")
print("Process Completed! ", now_txt)

