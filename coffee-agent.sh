#!/bin/sh

CACHE_FILE="/tmp/tmp-coffee-agent-values.txt"


# one sample consists of N subsamples
SUBSAMPLES_TAKE_N=5
SUBSAMPLES_SLEEP_BETWEEN=2

set -x

read_sensor() {

    if [ -z ${COFFEE_DEBUG} ]
    then
        POWER=$(cat /proc/power/active_pwr1)
        POWER=$(awk -v pwr=${POWER} 'BEGIN{print int(pwr)}')
    else
        #POWER=$(</dev/urandom tr -dc 0-9 | dd bs=1 count=1)
        #POWER=$(awk -v pwr=${POWER} 'BEGIN{print int(pwr) * 100}')
        POWER=$(awk 'BEGIN{srand(); print int(rand()+1.9) * 1000}')
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
    PREV_VALUE=-1
    VALUES=""
    START_TIME=$(get_time)
    while true; do
        VALUE=$(take_one_sample)
        echo $(date) ${VALUE} >> ${CACHE_FILE}
        if [ -z ${VALUES} ]; then
            VALUES=${VALUE}
            START_TIME=$(get_time)
        else
            VALUES=${VALUES}","${VALUE}
        fi
        if [ ${VALUE} -ne ${PREV_VALUE} ]; then
            RET=$(send_data "${VALUES}" "${START_TIME}" "$(get_time)")
            if [ ${RET} -eq 0 ]; then
                VALUES=""
            fi
        fi
        PREV_VALUE=${VALUE}
    done
}

send_data() {
    VALUES=$1
    START_TIME=$2
    END_TIME=$3

    wget -O - --quiet --post-data "values=${VALUES}&start=${START_TIME}&end=${END_TIME}" http://172.16.1.22:5000/v1/post_data >> ${CACHE_FILE}
    
    if [ $? -ne 0 ]; then
        echo 1
    else
        echo 0
    fi

}

collect_data

