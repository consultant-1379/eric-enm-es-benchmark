import os
import sys
import json
import argparse
from datetime import datetime
import requests
import csv
from requests.structures import CaseInsensitiveDict
from time import time, sleep
dateTimeObj = datetime.now()
print(dateTimeObj)
url1 = "http://elasticsearch:9200/_nodes/stats"
url2 = "http://elasticsearch:9200/_cluster/health"
headers = CaseInsensitiveDict()
headers["Accept"] = "application/json"
resp = requests.get(url1, headers=headers)
json_output = resp.json()
resp = requests.get(url2, headers=headers)
cluster_health_json = resp.json()
#print(str(list(json_output.values()[2])[0]))
node_vlist=list(json_output.values())[2]
#node_id = str(list(json_output.values()[2])[0])
print(node_vlist)
node_id=list(node_vlist)[0]
print("NODE_ID - ", node_id)
fileName = "/tmp/es_metrics.csv"
parser = argparse.ArgumentParser()
parser.add_argument("-t", "--time_interval", help="Provide time duration in minutes for script to run")
args = parser.parse_args()
if args.time_interval:
    time_interval = int(args.time_interval)
#while True:
    for i in range(time_interval):
        outputFile = open("/tmp/es_metrics.csv", "a")
        mydict = {"elasticsearch_jvm_memory_max_gigabytes": json_output['nodes'][node_id]['jvm']['mem']['heap_max_in_bytes'],
    "elasticsearch_jvm_gc_collection_timein_milliseconds_young": json_output['nodes'][node_id]['jvm']['gc']["collectors"]["young"]["collection_time_in_millis"],
    "elasticsearch_jvm_gc_collection_timein_milliseconds_old": json_output['nodes'][node_id]['jvm']["gc"]["collectors"]["old"]["collection_time_in_millis"],
    "elasticsearch_thread_pool_rejected_search_count": json_output['nodes'][node_id]["thread_pool"]['analyze']["rejected"],
    "elasticsearch_thread_pool_rejected_write_count": json_output['nodes'][node_id]["thread_pool"]['analyze']["rejected"],
    "cluster_health_status ": cluster_health_json['status'],
    "os_memory_free_percent": json_output['nodes'][node_id]["os"]["mem"]["free_percent"],
    "process_open_file_descriptors": json_output['nodes'][node_id]['process']['open_file_descriptors'],
    "jvm_heap_used_percent": json_output['nodes'][node_id]['jvm']['mem']['heap_used_percent'],
    "io_stats_device_write_operations": json_output['nodes'][node_id]['fs']['io_stats']['devices'][0]['write_operations']}


        print(mydict)

        try:
            writer = csv.writer(outputFile)
            if os.stat(fileName).st_size == 0:
                print("Filesize is 0")
                writer.writerow(["Metric Name", "Value", "Timestamp"])
            for key, value in mydict.items():
                writer.writerow([key, value, dateTimeObj])

            outputFile.close()
        except IOError:
            print("I/O error")
        sleep(60 - time() % 60)

