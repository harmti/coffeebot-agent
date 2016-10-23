#!/bin/bash

USER="admin"
PASSWORD="kahvi123"

#HOST="172.16.10.177"

TEMP_DIR="/tmp"
AGENT_SETUP="agent-setup.sh"
AGENT="coffee-agent.sh"
AGENT_DIR="/etc/persistent/bin/"

SCP_CMD="/usr/bin/sshpass -p ${PASSWORD} /usr/bin/scp -p -oKexAlgorithms=+diffie-hellman-group1-sha1"
SSH_CMD="/usr/bin/sshpass -p ${PASSWORD} /usr/bin/ssh -oKexAlgorithms=+diffie-hellman-group1-sha1"

if [ -z "$1" ]; then
    echo "Usage $0 <HOST>"
    exit
fi

HOST=$1
CLIENT=${USER}@${HOST}

${SCP_CMD} ${AGENT_SETUP} "${CLIENT}:${TEMP_DIR}"
${SCP_CMD} ${AGENT} "${CLIENT}:${AGENT_DIR}"
${SSH_CMD} ${CLIENT} ${TEMP_DIR}/${AGENT_SETUP}

