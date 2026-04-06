# arcpy script for downloading CAMS Street Lines
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

# Remove downloaded_cams_lines.gdb if exists:
try:
  arcpy.Delete_management('downloaded_cams_lines.gdb')
  print('downloaded_cams_lines.gdb deleted')
except OSError:
  pass

print('Connect to SDE')
cams_lines = 'sde_connections\\eGIS_Addressing.sde\eGIS_Addressing.EGIS.CAMS_ADDRESS_LINES'

print('Create a file geodatabase')
arcpy.CreateFileGDB_management(this_folder, "downloaded_cams_lines.gdb", "CURRENT")

print('importing CAMS Lines...')
arcpy.FeatureClassToFeatureClass_conversion(cams_lines, 'downloaded_cams_lines.gdb', 'cams_lines')

now = datetime.datetime.now()
now_txt = now.strftime("%Y-%m-%d %H:%M:%S")
print("Process Completed! ", now_txt)

