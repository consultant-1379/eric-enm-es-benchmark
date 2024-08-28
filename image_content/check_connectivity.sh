#!/bin/bash
BAR='.............................................'
iter=1
SECONDS=0
TimeoutMin=10
dir=$(dirname "${BASH_SOURCE[0]}")
#source "$dir/es.sh"
CHECK_CONN_FLAG=1
while ((SECONDS < TimeoutMin*60))
do
        echo -ne "\r${BAR:0:$iter}"
        #NodeCount=`GET "/_cat/nodes"|grep data|wc -l`
	NodeCount=`curl -Gs elasticsearch:9200/_cat/nodes|grep data|wc -l`
        if [ $NodeCount -eq 2 ]; then
          echo "Cluster status is health"
          exit 0;
        fi
        sleep 10
        iter=$((iter + 1))
        if [ $SECONDS -ge 600 ]; then
                printf "%s\n"
                echo "Could not connect to the cluster,operation timed out"
                exit 1;
        fi
done

