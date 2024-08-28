import csv
from csv import DictReader
import logging
import json
import time
import argparse
import sys
import requests
with open('/tmp/es_metrics.csv', 'r') as f:
 #reading csv file
    csvfile = csv.DictReader(f)
    x = []
    y = []
    n = []
    s = []
    l = []
    a = []
    k = []
    z = []
    i = []
    j = []

    for line in csvfile:
        key = line["Metric Name"]
        MINIMUM = 0
        value = line["Value"]
        if key == "elasticsearch_thread_pool_rejected_write_count":
            x.append(value)
        elif key == "elasticsearch_thread_pool_rejected_search_count":
            y.append(value)
        elif key == "elasticsearch_jvm_gc_collection_timein_milliseconds_old":
            n.append(value)
        elif key == "elasticsearch_jvm_gc_collection_timein_milliseconds_young":
            s.append(value)
        elif key == "elasticsearch_jvm_memory_max_gigabytes":
            l.append(round((int(value)/1024**3),2))
        elif key == "cluster_health_status":
            a.append(value)
        elif key == "os_memory_free_percent":
            k.append(value)
        elif key == "process_open_file_descriptors":
            z.append(value)
        elif key == "jvm_heap_used_percent":
            i.append(value)
        elif key == "io_stats_device_write_operations":
            j.append(value)
lim = {}
lim["elasticsearch_thread_pool_rejected_write_count"] = x
lim["elasticsearch_thread_pool_rejected_search_count"] = y
lim["elasticsearch_jvm_gc_collection_timein_milliseconds_old"] = n
lim["elasticsearch_jvm_gc_collection_timein_milliseconds_young"] = s
lim["elasticsearch_jvm_memory_max_gigabytes"] = l
lim["cluster_health_status"] = a
lim["os_memory_free_percent"] = k
lim["process_open_file_descriptors"] = z
lim["jvm_heap_used_percent"] = i
lim["io_stats_device_write_operations"] = j

dict_list = []
for key, value in lim.items():
    MINIMUM = 0
    if key == "elasticsearch_thread_pool_rejected_write_count":
        MINIMUM = 0
    elif key == "elasticsearch_thread_pool_rejected_search_count":
        MINIMUM = 0
    elif key == "elasticsearch_jvm_gc_collection_timein_milliseconds_old":
        MINIMUM = 2000
    elif key == "elasticsearch_jvm_gc_collection_timein_milliseconds_young":
        MINIMUM = 8000
    elif key == "elasticsearch_jvm_memory_max_gigabytes":
        MINIMUM = 7.7
    elif key == "os_memory_free_percent":
        MINIMUM = 50
    elif key == "process_open_file_descriptors":
        MINIMUM = 64000
    elif key == "jvm_heap_used_percent":
        MINIMUM = 75
    elif key == "io_stats_device_write_operations":
        MINIMUM = 560000

    MINIMUM = str(MINIMUM)

    if key == "elasticsearch_thread_pool_rejected_write_count" and int(max(value)) == 0:
        j = {'name': key, 'subRowDesc': 'Number of write count rejected by threads in pool', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'PASS'}
        dict_list.append(j)
    elif key == "elasticsearch_thread_pool_rejected_search_count" and int(max(value)) == 0:
        j = {'name': key, 'subRowDesc': 'Number of search count rejected by threads in pool', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'PASS'}
        dict_list.append(j)
    elif key == "elasticsearch_jvm_gc_collection_timein_milliseconds_old" and int(max(value)) <= 2000:
        j = {'name': key, 'subRowDesc': 'Total time spent on old generation garbage collections', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'PASS'}
        dict_list.append(j)
    elif key == "elasticsearch_jvm_gc_collection_timein_milliseconds_young" and int(max(value)) <= 8000:
        j = {'name': key, 'subRowDesc': 'Total time spent on young generation garbage collections', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'PASS'}
        dict_list.append(j)
    elif key == "elasticsearch_jvm_memory_max_gigabytes" and int(max(value)) <= 7.7:
        j = {'name': key, 'subRowDesc': 'Maximum memory occupied by jvm in GB', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'PASS'}
        dict_list.append(j)
    elif key == "os_memory_free_percent" and int(max(value)) <= 50:
        j = {'name': key, 'subRowDesc': 'Operating system memory free percent', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'PASS' }
        dict_list.append(j)
    elif key == "process_open_file_descriptors" and int(max(value)) <= 64000:
        j = {'name': key, 'subRowDesc': 'Number of file process running in es', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'PASS' }
        dict_list.append(j)
    elif key == "jvm_heap_used_percent" and int(max(value)) <= 75:
        j = {'name': key, 'subRowDesc': 'Heap percent used by jvm', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'PASS' }
        dict_list.append(j)
    elif key == "io_stats_device_write_operations" and int(max(value)) <= 560000:
        j = {'name': key, 'subRowDesc': 'Number of io write operations performed by elasticsearch', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'PASS' }
        dict_list.append(j)
    elif key == "cluster_health_status":
        if any([True if i in value else False for i in ["yellow", "red"]]):
            j = {'name': key, 'subRowDesc': 'Health status of elasticsearch db cluster', 'achievedResult': 'yellow', 'expectedResult': 'green','status': 'FAIL'}
            dict_list.append(j)
        else:
            j = {'name': key, 'subRowDesc': 'Health status of elasticsearch db cluster', 'achievedResult': 'green', 'expectedResult': 'green','status': 'PASS'}
            dict_list.append(j)
    else:
        if key == "elasticsearch_thread_pool_rejected_write_count":
            j = {'name': key, 'subRowDesc': 'Number of write count rejected by threads in pool', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'FAIL'}
            dict_list.append(j)
        elif key == "elasticsearch_thread_pool_rejected_search_count":
            j = {'name': key, 'subRowDesc': 'Number of search count rejected by threads in pool', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'FAIL'}
            dict_list.append(j)
        elif key == "elasticsearch_jvm_gc_collection_timein_milliseconds_old":
            j = {'name': key, 'subRowDesc': 'Total time spent on old generation garbage collections', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'FAIL'}
            dict_list.append(j)
        elif key == "elasticsearch_jvm_gc_collection_timein_milliseconds_young":
            j = {'name': key, 'subRowDesc': 'Total time spent on young generation garbage collections', 'achievedResult': str(max(value)), 'expectedResult': 'maximum:' + MINIMUM, 'status': 'FAIL'}
            dict_list.append(j)
        elif key == "elasticsearch_jvm_memory_max_gigabytes":
            j = {'name': key, 'subRowDesc': 'Maximum memory occupied by jvm in GB', 'achievedResult': str(max(value)), 'expectedResult': 'maximum:' + MINIMUM, 'status': 'FAIL'}
            dict_list.append(j)
        elif key == "os_memory_free_percent":
            j = {'name': key, 'subRowDesc': 'Operating system memory free percent', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'FAIL' }
            dict_list.append(j)
        elif key == "process_open_file_descriptors":
            j = {'name': key, 'subRowDesc': 'Number of file process running in es', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'FAIL' }
            dict_list.append(j)
        elif key == "jvm_heap_used_percent":
            j = {'name': key, 'subRowDesc': 'Heap percent used by jvm', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'FAIL' }
            dict_list.append(j)
        elif key == "io_stats_device_write_operations":
            j = {'name': key, 'subRowDesc': 'Number of io write operations performed by elasticsearch', 'achievedResult': str(max(value)), 'expectedResult': 'maximum: ' + MINIMUM, 'status': 'FAIL' }
            dict_list.append(j)

 
def write_report():
    #print({'report':dict_list,'description':"Elasticsearch Benchmark",'nodename': "ieatworker"})
    data={'report':dict_list,'description': "Verifies if elasticsearch is performing well on deployment"}
    return json.dumps(data)

def get_logger(name):
  msg_format = '%(asctime)s %(name)s %(levelname)s: %(message)s'
  logging.basicConfig(level='INFO', format=msg_format)
  return logging.getLogger(name=name)

def send_report(report,url):
    counter=SEND_ATTEMPTS
    log.info('Sending report to: %s', url)
    while True:
        headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}
        res= requests.post(url, data=report,headers=headers)
        if res.status_code == 202:
            log.info(' Report sent successfully')
            break
        counter -= 1
        if not counter:
            raise requests.exceptions.RequestException(f'Server response: {res.status_code}')
        time.sleep(2)




def main():
    report= write_report()
    print(report)
    print(sys.argv)
    #print({BENCH_NAME: report})
    if AGENT_ENABLED:
        send_report(report, URL)
    else:
        log.info('The CNIV agent is disabled, report will not be sent')

BENCH_GROUP = BENCH_NAME = \
    AGENT_HOSTNAME = AGENT_PORT = AGENT_ENABLED = \
    NODE_NAME = URL = None

SEND_ATTEMPTS = 3
URL_TEMPLATE = 'http://{}:{}/result/{}/{}'

if __name__ == '__main__':
    print(sys.argv)
    BENCH_GROUP = "custom-bench"
    BENCH_NAME = "eric-enm-es-benchmark"   
    AGENT_HOSTNAME = sys.argv[1]
    AGENT_PORT = "8080"
    AGENT_ENABLED = True
    NODE_NAME = "ieatworker"
    URL = URL_TEMPLATE.format(AGENT_HOSTNAME, AGENT_PORT, BENCH_GROUP,BENCH_NAME)
    log = get_logger("eric-enm-es-benchmark")
    main()

else:
    log = get_logger('eric-enm-es-benchmark')