#!/bin/bash

USER="admin"
PASSWORD="kahvi123"

#HOST="172.16.10.177"

TEMP_DIR="/tmp"
AGENT_SETUP="agent-setup.sh"
AGENT="coffee-agent.sh"
CONFIG="coffee-agent.cfg"
AGENT_DIR="/etc/persistent/bin/"


MODIFIED_CONFIG=${TEMP_DIR}"/"${CONFIG}
SCP_CMD="/usr/bin/sshpass -p ${PASSWORD} /usr/bin/scp -p -oKexAlgorithms=+diffie-hellman-group1-sha1"
SSH_CMD="/usr/bin/sshpass -p ${PASSWORD} /usr/bin/ssh -oKexAlgorithms=+diffie-hellman-group1-sha1"

if [ -z "$1" ]; then
    echo "Usage $0 <HOST> (<SERVER>)"
    exit
fi

/bin/cp ${CONFIG} ${MODIFIED_CONFIG}

if [ ! -z "$2" ]; then
    echo "SERVER=$2" >> ${MODIFIED_CONFIG}
fi


HOST=$1
CLIENT=${USER}@${HOST}

${SCP_CMD} ${AGENT_SETUP} "${CLIENT}:${TEMP_DIR}"
${SCP_CMD} ${AGENT} "${CLIENT}:${AGENT_DIR}"
${SCP_CMD} ${MODIFIED_CONFIG} "${CLIENT}:${AGENT_DIR}"
${SSH_CMD} ${CLIENT} ${TEMP_DIR}/${AGENT_SETUP}

