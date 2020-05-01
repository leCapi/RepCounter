from fitparse import FitFile
import os
import sys

fitfile = FitFile(sys.argv[1])

def dump_record(type, data_filter=None):
    # Get all data messages that are of type record
    for msg in fitfile.get_messages(type):
        # print(record.mesg_type)
        # can call get_messages without a type to dump all messages
        # Go through all the data entries in this record
        data_found = False
        for data in msg:
            if filter is not None and not (data.name in data_filter):
                continue
            data_found = True
            # Print the records name and value (and units if it has any)
            if data.units:
                print(" * %s: %s %s " % (
                    data.name, data.value, data.units
                ))
            else:
                print(" * %s: %s" % (data.name, data.value))
        if data_found:
            print()

filter={"total_repetitions", "repetitions", "duration", "rest", "high_threshold", "low_threshold"}

print("> SESSION INFO")
dump_record("session", filter)
print("> LAP INFO")
dump_record("lap", filter)
print("> RECORD INFO")
dump_record("record", filter)
