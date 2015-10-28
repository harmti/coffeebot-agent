#!/bin/sh

CACHE_FILE="/tmp/tmp-coffee-agent-values.txt"


# one sample consists of N subsamples
SUBSAMPLES_TAKE_N=5
SUBSAMPLES_SLEEP_BETWEEN=1

set -x

read_sensor() {

    if [ -z ${COFFEE_DEBUG} ]
    then
        POWER=$(cat /proc/power/active_pwr1)
    else
        POWER=$(</dev/urandom tr -dc 0-9 | dd bs=3 count=1)
    fi
    POWER=$(awk -v pwr=${POWER} 'BEGIN{print int(pwr)}')
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


calc_sample() {
    while true; do
        VALUE=$( take_one_sample )
        echo $(date) ${VALUE} >> ${CACHE_FILE}
    done
}

calc_sample
