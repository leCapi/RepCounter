from fitparse import FitFile
import os
import sys
import math

fitfile = FitFile(sys.argv[1])

print("tick,x,y,z,m,r,p")
tick = 0

for record in fitfile.get_messages('record'):
    x_rec = None
    y_rec = None
    z_rec = None

    # Go through all the data entries in this record
    for record_data in record:
        if record_data.name == "SensorAccelerationX_HD":
            x_rec = record_data.value
        if record_data.name == "SensorAccelerationY_HD":
            y_rec = record_data.value
        if record_data.name == "SensorAccelerationZ_HD":
            z_rec = record_data.value

    if len(x_rec) != len(y_rec) or len(x_rec) != len(z_rec):
        raise Exception("missing data")

    for i in range(0, len(x_rec)):
        if x_rec[i] == None:
            break
        mi = math.sqrt(x_rec[i]**2 + y_rec[i]**2 + z_rec[i]**2)
        ri = math.atan2(-x_rec[i], z_rec[i]) * 180 / math.pi
        pi = math.atan2(y_rec[i], math.sqrt(x_rec[i]**2 + z_rec[i]**2)) * 180 / math.pi
        print("%s,%s,%s,%s,%.2f,%.2f,%.2f" %(tick, x_rec[i], y_rec[i], z_rec[i], mi, ri, pi))
        tick = tick + 1