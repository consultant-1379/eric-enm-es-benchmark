import logging
import threading
from datetime import datetime, timedelta
import json
from time import sleep
import argparse
import random
import queue
#from multiprocessing import Queue
import requests


class Index:
    def __init__(self, name):
        self.name = name


def generate_query(mins, **kwargs):
    current_datetime = datetime.now()
    to_time = current_datetime.replace(second=0, microsecond=0)
    from_time = to_time - timedelta(minutes=mins)
    to_time = str(to_time).replace(' ', 'T')
    from_time = str(from_time).replace(' ', 'T')
    from_time_key = "gte"
    to_time_key = "lt"
    query = {"query": {"bool": {"must": [{
             "range": {
             "timestamp": {
               from_time_key: from_time,
               to_time_key: to_time
                             }
                     }
            }                           ]}
                      }
            }

    if kwargs is not {}:
        for key, value in kwargs.items():
            filter_dict = {"constant_score": {
                "filter": {
                    "term": {}
                }
            }}
            if 'facility_code' in key:
                filter_dict['constant_score']['filter']['term'] = {"facility_code": value}
            else:
                filter_dict['constant_score']['filter']['term'] = {key + ".keyword": value}

            query["query"]["bool"]["must"].append(filter_dict)

    return query


def get_response_from_queries(cluster_name, query_data, q, thread_no, type):
    current_index_date = str(datetime.now().date()).replace("-", ".")
    index = Index("enm_audit*-{0},enm_debug*-{0},enm_info*-{0},enm_logs-opendj*-{0},enm_warn*-{0},enm_adp_logs_index-{0}".format(current_index_date))

    url = 'http://{0}:9200/{1}/_search?pretty'.format(cluster_name, index.name)
    params = {
              'size': 10000,
              'sort': 'timestamp:asc',
              'ignore_unavailable': 'true'
             }
    header = {
              'Content-Type': 'application/json'
             }

    logging.info("Create and start thread %d", thread_no)
    try:
        response = requests.get(url, headers=header, params=params, data=query_data)
        q.put("For Thread {2}, Query Type:{3}, Response code:{0}, Time Elapsed:{1}".format(response.status_code, response.elapsed, thread_no, type))
    except requests.exceptions.RequestException as ex:
        q.put(ex)
    logging.info("Response from thread %d: received", thread_no)

if __name__ == "__main__":

    
    format = "%(asctime)s: %(message)s"
    logging.basicConfig(format=format, level=logging.INFO, datefmt="%H:%M:%S")
    threads = []
    q = queue.Queue()
    queries_list = [
        ({"range": 1}, json.dumps(generate_query(mins=1))),
        ({"range": 15}, json.dumps(generate_query(mins=15))),
        ({"range": 1, "severity": "info"}, json.dumps(generate_query(mins=1, severity="info"))),
        ({"range": 1, "tag": "JBOSS:"}, json.dumps(generate_query(mins=1, tag="JBOSS:"))),
        ({"range": 1, "host": "vaultserv-0"}, json.dumps(generate_query(mins=1, host="vaultserv-0"))),
        ({"range": 1, "program": "JBOSS"}, json.dumps(generate_query(mins=1, program="JBOSS"))),
        ({"range": 1, "facility_code": 5}, json.dumps(generate_query(mins=1, facility_code=5))),
        ({"range": 1, "severity": "info", "tag": "JBOSS:"}, json.dumps(generate_query(mins=1, severity="info", tag="JBOSS:"))),
        ({"range": 1, "type": "audit", "facility_code": [5, 10, 13]}, json.dumps(generate_query(mins=1, facility_code1=5, facility_code2=10, facility_code3=13))),
    ]

    parser = argparse.ArgumentParser()
    parser.add_argument("-t", "--time_interval", help="Provide time duration in minutes for script to run")
    parser.add_argument("-c", "--cluster", help="Provide cluster name: 'elasticsearch' or 'eshistory'")
    args = parser.parse_args()
    if args.time_interval:
        time_interval = int(args.time_interval)
    cluster_name = args.cluster

    if cluster_name == 'elasticsearch':
        no_of_query = 40
    else:
        no_of_query = 50

    for i in range(time_interval):
        #logging.info("Main    : create and start thread %d", index+1)
        print("Starting query threads in minute {0}".format(i))
        print("***********************************")
        for index in range(no_of_query):
            type, query = random.choice(queries_list)
            x = threading.Thread(target=get_response_from_queries, args=(cluster_name, query, q, index + 1, type))
            threads.append(x)
            x.start()

        for index, thread in enumerate(threads):
            #logging.info("Main    : before joining thread %d.", index+1)
            thread.join()
            

        while not q.empty():
            print(q.get())

        sleep(60)
