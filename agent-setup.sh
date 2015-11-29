#!/bin/sh

AGENT_NAME="coffee-agent"
POSTSTART='/etc/persistent/rc.poststart'
MARKER="coffee-agent"
MARKER_START="### ${MARKER}-start ###"
MARKER_END="### ${MARKER}-end   ###"
AGENT_SCRIPT="/etc/persistent/bin/${AGENT_NAME}.sh"
AGENT_ID_FILE="/etc/persistent/bin/${AGENT_NAME}.id"

SHELL="/bin/sh"
SHELL_FIRST_LINE="#!${SHELL}"

# truncate the file if the first line is not shell...
head -1 ${POSTSTART} | grep -q ${SHELL_FIRST_LINE} ${POSTSTART}
if [ $? -ne 0 ] || [ ! -f ${POSTSTART} ]; then
    echo ${SHELL_FIRST_LINE} > ${POSTSTART}
    echo "" >> ${POSTSTART}
    chmod 0755 ${POSTSTART}
fi

# add agent to rc.poststart
grep -q ${MARKER} ${POSTSTART}
if [ $? -ne 0 ]; then
    echo ${MARKER_START} >> ${POSTSTART}
    echo ${AGENT_SCRIPT}"&" >> ${POSTSTART}
    echo ${MARKER_END} >> ${POSTSTART}
fi

# create the client id file
if [ ! -f ${AGENT_ID_FILE} ]; then
    </dev/urandom tr -dc 0-9A-F | dd bs=1 count=8 > ${AGENT_ID_FILE}
fi

# make changes persistent across reboots
cfgmtd -w -p /etc

# should reboot?
# reboot
