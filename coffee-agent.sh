#!/bin/sh

AGENT_NAME="coffee-agent"
AGENT_ID_FILE="/etc/persistent/bin/${AGENT_NAME}.id"
AGENT_CONFIG_FILE="/etc/persistent/bin/${AGENT_NAME}.cfg"

LOG_FILE="/tmp/tmp-coffee-agent-log.txt"

if [ ! -z ${COFFEE_DEBUG} ]; then
    SERVER="http://localhost:5000"
    AGENT_CONFIG_FILE=./${AGENT_NAME}.cfg
fi

. ${AGENT_CONFIG_FILE}

if [ -z ${SERVER} ]; then
    SERVER="http://fresh-coffee-server.herokuapp.com"
fi


SERVICE_URL="${SERVER}/v1/post_data"

set -x

# make sure power is on
if [ ! -z ${COFFEE_DEBUG} ]; then
    echo 1 > /proc/power/relay1
fi

# remove old log files
rm -f $LOG_FILE

if [ ! -f {AGENT_ID_FILE} ]; then
    AGENT_ID=$(</dev/urandom tr -dc 0-9A-F | dd bs=1 count=8)
else
    AGENT_ID=$(cat ${AGENT_ID_FILE})
fi

read_sensor() {

    if [ -z ${COFFEE_DEBUG} ]; then
        POWER=$(cat /proc/power/active_pwr1)
        POWER=$(awk -v pwr=${POWER} 'BEGIN{print int(pwr)}')
    else
        #POWER=$(</dev/urandom tr -dc 0-9 | dd bs=1 count=1)
        #POWER=$(awk -v pwr=${POWER} 'BEGIN{print int(pwr) * 100}')
        POWER=$(awk 'BEGIN{srand(); x=rand(); print int(x*x*x*x * 2000)}')
    fi
    echo $POWER
}


take_one_sample() {
    POWER=0
    SUM=0
    for i in $(seq 1 ${SUBSAMPLES_TAKE_N}) 
    do
        POWER=$(read_sensor)
        SUM=$((${POWER} + ${SUM}))
        sleep ${SUBSAMPLES_SLEEP_BETWEEN}
    done
    AVERAGE=$((${SUM} / ${SUBSAMPLES_TAKE_N}))

    echo ${AVERAGE}
}

get_time() {
    TIME=$(date | sed 's/ /%20/g')
    #TIME=$(date +%s)

    echo ${TIME}
}

collect_data() {
    COUNTER=0
    PREV_VALUE=-1
    VALUES=""
    START_TIME=$(get_time)
    while true; do
        VALUE=$(take_one_sample)
        echo "$(date) Value:${VALUE}" >> ${LOG_FILE}
        if [ -z ${VALUES} ]; then
            VALUES=${VALUE}
        else
            VALUES=${VALUES}","${VALUE}
        fi
        if [ ${VALUE} -ne ${PREV_VALUE} ] || [ ${COUNTER} -gt 20 ]; then
            RET=$(send_data "${VALUES}" "${START_TIME}" "$(get_time)")
            if [ ${RET} -eq 0 ]; then
                COUNTER=0
                VALUES=""
                START_TIME=$(get_time)
            fi
        fi
        PREV_VALUE=${VALUE} 
        COUNTER=$((COUNTER+1))
    done
}

send_data() {
    VALUES=$1
    START_TIME=$2
    END_TIME=$3

    wget -O - --quiet --post-data "id=${AGENT_ID}&values=${VALUES}&start=${START_TIME}&end=${END_TIME}" ${SERVICE_URL} >> ${LOG_FILE}
    
    if [ $? -ne 0 ]; then
        echo 1
    else
        echo 0
    fi

}

collect_data

