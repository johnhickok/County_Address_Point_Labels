# Script pulls addresses from PostgreSQL table pcls_no_cams,
# scrapes the locator name from the eGIS geocode server, and
# loads the AIN and locator name (CAMS_POINTS, CAMS_STREETS,
# or No Geocode) into a file geocode_results.csv

# The pcls_no_cams table was created based on parcels with valid 
# addresses which don't intersect CAMS address points. This step 
# searches for any of these addresses that successfully geocode 
# against the CAMS address points (locator name = CAMS_POINTS)
# that need to be removed.

# WARNING! Using this script takes about 2 hours to geocode 
# 60,000 records. ArcGIS Pro is faster.

# 2023-07-18 DCFS GIS Team

import requests, psycopg2, requests

# output file
outfile = open('geocode_results.csv', 'w')
outfile.write('ain,loc_name\n')

# Connect to locally hosted PostgreSQL database and set a cursor
conn = psycopg2.connect("dbname='laco_backup' user='postgres' host=localhost password='postgres'") 

cur = conn.cursor()

# Query fields for geocoding
cur.execute("""
select
ain,
situsaddress,
left(situscity, length(situscity)-3) as city,
left(situszip,5)
from pcls_no_cams
"""
)

rows = cur.fetchall()

# Parse strings for the geocoding service and extract locator name
url_begin = "https://geocode.gis.lacounty.gov/geocode/rest/services/CAMS_Locator/GeocodeServer/findAddressCandidates"

url_end = "&SingleLine=&category=&outFields=Loc_name&maxLocations=1&outSR=&searchExtent=&location=&distance=&magicKey=&f=pjson"

counter = 1

for row in rows:
  ain = row[0]
  street = "?Street=" + row[1].strip().replace(' ', '+')
  #street = "?Street=" + row[1]
  city = "&City=" + row[2]
  state = "&State=CA"
  zip = "&ZIP=" + row[3]
  url = url_begin + street + city + state + zip + url_end
  #print(row[0], row[1], row[2], row[3])

  response = requests.get(url)
  
  try:
    data = response.json()
    loc_name = data['candidates'][0]['attributes']['Loc_name']
    print(counter, ain, loc_name)
    outfile.write(ain + ',' + loc_name + '\n')
    counter += 1

  except:
    print(counter, ain, "No Geocode")
    outfile.write(ain + ',No Geocode\n')
    counter += 1

outfile.close()