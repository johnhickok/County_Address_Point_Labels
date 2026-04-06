# arcpy script for downloading Assessor parcels
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

# Remove downloaded_parcels.gdb if exists:
try:
  arcpy.Delete_management('downloaded_parcels.gdb')
  print('downloaded_parcels.gdb deleted')
except OSError:
  pass

print('Connect to SDE')
pcls = 'sde_connections\\eGIS_Cadastral.sde\\eGIS_Cadastral.EGIS.ASSR_PARCELS'

print('Create a file geodatabase')
arcpy.CreateFileGDB_management(this_folder, "downloaded_parcels.gdb", "CURRENT")

print('importing pcls...')
arcpy.FeatureClassToFeatureClass_conversion(pcls, 'downloaded_parcels.gdb', 'parcels')

now = datetime.datetime.now()
now_txt = now.strftime("%Y-%m-%d %H:%M:%S")
print("Process Completed! ", now_txt)

