#!/bin/bash
## This is a load job
function Pushdocs() {
index_name=$1
# curl -XPOST -H "Content-Type:application/json"  "elasticsearch:9200/enm_adp_logs_index-2021.09.07/_doc" -d '{"message":"Hello world"}'
curl -XPOST -sH "Content-Type:application/json"  "elasticsearch:9200/"${index_name}"/_bulk"  --data-binary @/tmp/load.json
Result=$?
if [ $Result -eq 0 ]; then
echo -e "\n Successfully inserted $docsize documents";
fi
#index_size=`curl -sX GET "elasticsearch:9200/_cat/indices/$index_name?h=store.size&bytes=gb?pretty"`

}

function createindices() {
dt=`date '+%Y.%m.%d'`
curl -X PUT "elasticsearch:9200/enm_adp_logs_index-$dt?pretty"
curl -X PUT "elasticsearch:9200/enm_info_logs_index-$dt?pretty"
curl -X PUT "elasticsearch:9200/enm_audit_logs_index-$dt?pretty"
curl -X PUT "elasticsearch:9200/enm_logs-opendj-$dt?pretty"
curl -X PUT "elasticsearch:9200/enm_info_syslog_logs_index-$dt?pretty"
curl -X PUT "elasticsearch:9200/enm_security_logs_index-$dt?pretty"
curl -X PUT "elasticsearch:9200/enm_warn_and_above_logs_index-$dt?pretty"
}

function Createjson()
{
index_name=$3
echo IN CREATEJSON - $index_name
echo -e { '"index"' : { '"_index"' : '"'${index_name}'"','"_type"' : '"_doc"'} } >/tmp/load.json
TS=`date '''+%Y-%m-%d'T'%H:%M:%S.%6N%z'''`
echo $TS
#echo -e {'"timestamp"' : '"2021-09-06T06:34:01.733035+01:00"','"host"' : '"svc-2-mscmapg"','"program"' : '"kernel"','"severity"' : '"info"','"severity_code"' : 6,'"facility"' : '"kern"','"facility_code"' : 0,'"pri"' : 6,'"tag"' : '"kernel:"','"message"' : '"BIOS-e820: 00000000fffbc000 - 0000000100000000 (reserved)"'} >>/tmp/load.json
total_count=$1
message=$2
#index_name=$3
echo "DOC -" $total_count
echo "Load_start_time" - `date`
for ((i=1;i<=$total_count; i++))
 do
#       echo -e {'"timestamp"' : '"'"$TS"'"','"host"' : '"svc-2-mscmapg"','"program"' : '"kernel"','"severity"' : '"info"','"severity_code"' : 6,'"facility"' : '"kern"','"facility_code"' : 0,'"pri"' : 6,'"tag"' : '"kernel:"','"message"' : '"BIOS-e820: 00000000fffbc000 - 0000000100000000 (reserved)"'} >>/tmp/load.json
        echo -e {'"timestamp"' : '"'"$TS"'"','"host"' : '"svc-2-mscmapg"','"program"' : '"kernel"','"severity"' : '"info"','"severity_code"' : 6,'"facility"' : '"kern"','"facility_code"' : 0,'"pri"' : 6,'"tag"' : '"kernel:"','"message"' : '"'"$message"'"'} >>/tmp/load.json
        echo -e { '"index"' : { '"_index"' : '"'${index_name}'"','"_type"' : '"_doc"'} } >>/tmp/load.json
        message=`LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c $DOCSIZE_IN_BYTES;echo ''`
        TS=`date '''+%Y-%m-%d'T'%H:%M:%S.%6N%z'''`
done
echo "Load end time -" `date`
}

#curl -G elasticsearch:9200/
#indices=`curl -sG elasticsearch:9200/_cat/indices?h=i|grep `date '''+%Y.%m.%d'''``
#index_name="enm_adp_logs_index-2021.01.09"
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -n|--totalcount)
      TOTALCOUNT="$2"
       #dp_logs_index-2021.09.09 Createjson "$TOTALCOUNT"
        #Pushdocs
      shift # past argument
      shift # past value
      ;;
    -s|--docsize)
      DOCSIZE_ACTUAL="$2"
      DOCSIZE_UNIT=`echo $DOCSIZE_ACTUAL | awk '{ n=$1+0; sub(n,"",$1); print $1}'`
      DOCSIZE=`echo $DOCSIZE_ACTUAL | awk '{ n=$1+0; sub(n,"",$1); print n}'`
      #echo DOCSIZE - $DOCSIZE""KB
       echo ACTUAL - $DOCSIZE_ACTUAL
       echo UNIT - $DOCSIZE_UNIT
       echo DOCSIZE - $DOCSIZE
      #DOCSIZE_IN_BYTES=$((DOCSIZE * 1024))
        case $DOCSIZE_UNIT in
           kb|KB|K|k)
              DOCSIZE_IN_BYTES=$((DOCSIZE * 1024));;
           mb|MB|M|m)
              DOCSIZE_IN_BYTES=$((DOCSIZE * 1024 * 1024));;
           gb|GB|G|g)
             DOCSIZE_IN_BYTES=$((DOCSIZE * 1024 * 1024 * 1024));;
        esac
      message=`LC_ALL=C tr -dc A-Za-z0-9 </dev/urandom | head -c $DOCSIZE_IN_BYTES;echo ''`
      #echo $message
      shift # past argument
      shift # past value
        echo DOCSIZE_IN_BYTES : $DOCSIZE_IN_BYTES
        ;;
    -m|--maxsize)
      #MAXSIZE="$2"
        MAXSIZE_ACTUAL="$2"
        MAXSIZE_UNIT=`echo $MAXSIZE_ACTUAL | awk '{ n=$1+0; sub(n,"",$1); print $1}'`
        MAXSIZE=`echo $MAXSIZE_ACTUAL | awk '{ n=$1+0; sub(n,"",$1); print n}'`
        echo MAXSIZE - $MAXSIZE
        echo MAXSIZE_ACTUAL - $MAXSIZE_ACTUAL
         case $MAXSIZE_UNIT in
           kb|KB|K|k)
             # MAXSIZE_IN_BYTES=$((MAXSIZE * 1024));;
              MAXSIZE_IN_BYTES=`echo "$MAXSIZE+1024" |  awk -F "+" '{print ($1*$2)}'`;;
           mb|MB|M|m)
              #MAXSIZE_IN_BYTES=$((MAXSIZE * 1024 * 1024));;
              MAXSIZE_IN_BYTES=`echo "$MAXSIZE+1024+1024" |  awk -F "+" '{print ($1*$2*$3)}'`;;
           gb|GB|G|g)
             # MAXSIZE_IN_BYTES=$((MAXSIZE+1024+1024+1024));;
                MAXSIZE_IN_BYTES=`echo "$MAXSIZE+1024+1024+1024" |  awk -F "+" '{print ($1*$2*$3*$4)}'`;;
         esac
        echo MAXSIZE_IN_BYTES - $MAXSIZE_IN_BYTES
         REQ_SIZE=$((TOTALCOUNT * DOCSIZE_IN_BYTES))
        echo REQ_SIZE: $REQ_SIZE
                if [ $REQ_SIZE -gt $MAXSIZE_IN_BYTES ]; then
                #       echo "TOTAL:"  $((TOTAL_COUNT * DOCSIZE_IN_BYTES))
                   #echo "Maxsize should be more than (($TOTAL_COUNT * $DOCSIZE_IN_BYTES)"
                    echo "Maxsize must be more"
                   exit 1;
                fi
      shift # past argument
      shift # past value
      ;;
   -i|--index)
        index_name="$2"
         #shift # past argument
         #shift # past value
        #indices=$(curl -sG elasticsearch:9200/_cat/indices?h=i|grep `date '''+%Y.%m.%d'''`)
        indices=$(curl -sG elasticsearch:9200/_cat/indices?h=i|grep $index_name)
        res=$?
        #echo In index option $indices
        #length=${#indices[@]}
          if [ $res -eq 1 ]; then
                echo "No indices present for this date.."
                exit 1
          fi
         shift # past argument
         shift # past value
        ;;

#       is_index_exists=`curl -Is "elasticsearch:9200/${index_name}?pretty"|grep "HTTP/1.1"|cut -d ' ' -f 2`
#             if [ $is_index_exists -ne 200 ]; then
#               echo Index exists -  $is_index_exists
                #echo "Creating the index.."
                #curl -XPUT elasticsearch:9200/$index_name
#               echo "Index not present, quitting.."
#               exit 1;
#             fi

    --default)
      DEFAULT=YES
      shift # past argument
      ;;

    *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

echo "TOTAL COUNT  = ${TOTALCOUNT}"
echo "DOC SIZE     = ${DOCSIZE}KB"
echo "MAXSIZE    = ${MAXSIZE}"
echo "DEFAULT         = ${DEFAULT}"
#echo "Number files in SEARCH PATH with TOTALCOUNT:" $(ls -1 "${DOCSIZE}"/*."${TOTALCOUNT}" | wc -l)
#if [[ -n $1 ]]; then
#    echo "Last line of file specified as non-opt/last argument:"
#    tail -1 "$1"
#fi
#echo "Creating JSON \n"
#Createjson "$TOTALCOUNT" "$message"

#Createjson
index_name=`date '''+%Y.%m.%d'''`
#indices=$(curl -sG elasticsearch:9200/_cat/indices?h=i|grep `date '''+%Y.%m.%d'''`)
declare -a indices=(`curl -sG elasticsearch:9200/_cat/indices?h=i|grep $index_name`)
echo $indices
echo ${indices[0]}
echo ${indices[1]}
length=${#indices[@]}
if [ $length -ne 7 ]; then
createindices 2>/dev/null
sleep 30
declare -b indices=(`curl -sG elasticsearch:9200/_cat/indices?h=i|grep $index_name`)
length=${#indices[@]}
fi
if [ $length -eq 0 ]
then
echo "Please check if elasticsearch DB is up and running!!!"
exit 1;
fi
#declare -a indices=$(`curl -sG elasticsearch:9200/_cat/indices?h=i|grep `date '''+%Y.%m.%d'''``)
declare -a indices=(`curl -sG elasticsearch:9200/_cat/indices?h=i|grep $index_name`)
size_per_index=`echo "$MAXSIZE_IN_BYTES+$length" |  awk -F "+" '{print ($1/$2)}'`
echo  Indices list - $indices
echo length - $length
echo size_per_index - $size_per_index
COUNT_INCR=0
echo START_TIME : `date`
for index_name in "${indices[@]}"
do
 while true; do
 #index_size_actual=`curl -sX GET "elasticsearch:9200/_cat/indices/$index_name?h=store.size&bytes=gb?pretty"`
  echo Index-name - $index_name
  index_size_actual=`curl -sX GET "elasticsearch:9200/_cat/indices/${index_name}?h=store.size&bytes=gb?pretty"`
  index_size_unit=`echo $index_size_actual | awk '{ n=$1+0; sub(n,"",$1); print $1}'`
  index_size=`echo $index_size_actual | awk '{ n=$1+0; sub(n,"",$1); print n}'`
  echo index_size_actual - $index_size_actual
  echo index_size_unit - $index_size_unit

         case $index_size_unit in
           b)
            index_size_in_bytes=$index_size;;
           kb|KB|K|k)
              #index_size_in_bytes=$((index_size * 1024));;
              index_size_in_bytes=`echo "$index_size+1024" |  awk -F "+" '{print ($1*$2)}'`
                echo INDEX-SIZE-IN-BYTES - $index_size_in_bytes;;
           mb|MB|M|m)
              #index_size_in_bytes=$((index_size * 1024 * 1024));;
              index_size_in_bytes=`echo "$index_size+1024+1024" |  awk -F "+" '{print ($1*$2*$3)}'`
                echo INDEX-SIZE-IN-BYTES - $index_size_in_bytes;;
           gb|GB|G|g)
              #index_size_in_bytes=$((index_size * 1024 * 1024 * 1024));;
              index_size_in_bytes=`echo "$index_size+1024+1024+1024" |  awk -F "+" '{print ($1*$2*$3*$4)}'`;;

         esac
echo "Pushing docs..\n"
echo Index size - $index_size_in_bytes
echo Maxsize - $MAXSIZE_IN_BYTES
#if [ $index_size_in_bytes -le $MAXSIZE_IN_BYTES ]
#if (( $(echo "$ndex_size_in_bytes < $MAXSIZE_IN_BYTES" |bc -l) )); then
#echo "Creating JSON.."
#while true; do
#echo "In while"
echo index_name $index_name
echo index_size_in_bytes - $index_size_in_bytes
echo Size_per_index - $size_per_index
cluster_size=`curl -sX GET "elasticsearch:9200/_cluster/stats?human&pretty&filter_path=indices.store.size_in_bytes"|grep size_in_bytes|awk -F: '{print $2}'`
        if [ $cluster_size -ge $MAXSIZE_IN_BYTES ]; then
                 echo "Cluster size is already greater than Maxsize specified"
                 exit 0;
        else
        awk 'BEGIN{if ('$index_size_in_bytes'<'$size_per_index') exit 1}'
        #echo HELLO...
        if [ $? -eq 1 ]
        then
            #echo "Before createjson In while loop"
            Createjson "$TOTALCOUNT" "$message" "$index_name"
            #COUNT_INCR=$TOTALCOUNT+$COUNT_INCR
            COUNT_INCR=$(($TOTALCOUNT + $COUNT_INCR))
            echo  Createjson "$TOTALCOUNT"  "$index_name"
            Pushdocs $index_name  # Pushing docs
        else
            echo "Index size is already greater than Maxsize specified : $MAXSIZE_ACTUAL"
            break;
        fi
        fi

#doc_count=`curl -sX GET "elasticsearch:9200/_cat/indices/enm_adp_logs_index-2021.10.26?h=docs.count"`
#echo DOC COUNT - $doc_count
#sleep 2
 if [ $COUNT_INCR -ge `expr $TOTALCOUNT + 100` ]; then
    sleep 5
    COUNT_INCR=0;
 fi
done
done

echo END time -  `date`
exit 0
