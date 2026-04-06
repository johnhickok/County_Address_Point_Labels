# arcpy script for downloading Countywide Statistical Areas (CSA)
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

# Remove downloaded_csa.gdb if exists:
try:
  arcpy.Delete_management('downloaded_csa.gdb')
  print('downloaded_csa.gdb deleted')
except OSError:
  pass

print('Connect to SDE')
csa = 'sde_connections\\eGIS_Boundaries_Political.sde\eGIS_Boundaries_Political.EGIS.BOS_COUNTYWIDE_STATISTICAL_AREAS'

print('Create a file geodatabase')
arcpy.CreateFileGDB_management(this_folder, "downloaded_csa.gdb", "CURRENT")

print('importing CSAs...')
arcpy.FeatureClassToFeatureClass_conversion(csa, 'downloaded_csa.gdb', 'csa')

now = datetime.datetime.now()
now_txt = now.strftime("%Y-%m-%d %H:%M:%S")
print("Process Completed! ", now_txt)

