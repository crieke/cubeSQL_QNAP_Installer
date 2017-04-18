#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="cubeSQL"
QPKG_ROOT=`/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF}`
MODEL=`getsysinfo model`
QNAP_SERIAL=`get_hwsn`
ARCH=$(uname -m)
QTS_VER=`/sbin/getcfg system version`
QPKG_VERSION=`/sbin/getcfg $QPKG_NAME Version -f ${CONF}`
MTU=`ifconfig | grep eth[0-9] -A1 | grep MTU | grep MTU | cut -d ":" -f 2 | awk '{print $1}' | xargs | sed "s/ ---- /\n---- /g"`
TMP_DIR="${QPKG_ROOT}/tmp"
QPKG_DATAROOT=`/sbin/getcfg $QPKG_NAME path -f /etc/config/smb.conf`
PIDFILE="${QPKG_DATAROOT}/databases/cubesql.pid"
QPKG_LOG_FILE="${QPKG_ROOT}/cubesql.log"
QPKG_DEBUG_EXTERNAL_LOG="${QPKG_DATAROOT}/CUBESQL_DEBUG_EXTERNAL_LOG.txt"

ST_COLOR="\033[38;5;34m"
HL_COLOR="\033[38;5;197m"
REG_COLOR="\033[0m"

if [ -f ${PIDFILE} ]; then
    PID=`cat "${PIDFILE}"`
fi

if [ "${ARCH}" == "x86_64" ]; then
	CPU="64bit";
elif [ "${ARCH}" == "i686" ]; then
	CPU="32bit";
elif [ "${ARCH}" == "i386" ]; then
        CPU="32bit";
else
	CPU="unsupported"
fi


## Log Function
echolog(){
    TIMESTAMP=$(date +%d.%m.%y-%H:%M:%S)
    if [[ $# == 2 ]]; then
        PARAMETER1=$1
        PARAMETER2=$2
        echo -e "${ST_COLOR}${TIMESTAMP}${REG_COLOR} --- ${HL_COLOR}${PARAMETER1}:${REG_COLOR} ${PARAMETER2}"
        echo "${TIMESTAMP} --- ${PARAMETER1}: ${PARAMETER2}" >> $QPKG_LOG_FILE
    elif [[ $# == 1 ]]; then
        PARAMETER1=$1
        echo -e "${ST_COLOR}${TIMESTAMP}${REG_COLOR} --- ${PARAMETER1}"
        echo "${TIMESTAMP} --- ${PARAMETER1}" >> $QPKG_LOG_FILE
    else
        echo -e "The echolog function requires 1 or 2 parameters."
    fi
}

info()
{
   ## Echoing System Info
   echolog "QPKG_DATAROOT" "${QPKG_DATAROOT}"
   echolog "QPKG_DIR" "${QPKG_ROOT}"
   echolog "Model" "${MODEL}"
   echolog "QNAP Serial" "${QNAP_SERIAL}"
   echolog "Architecture" "${ARCH}"
   echolog "QTS Version" "${QTS_VER}"
   echolog "PKG Version" "${QPKG_VERSION}"
   echolog "Hostname" "${HOSTNAME}"
   echolog "MTU" "${MTU}"
}

start_daemon(){			
    info

    if [ "${QPKG_DATAROOT}" != "" ]; then

	if [ ! -d "${QPKG_DATAROOT}"/settings ]; then
		mkdir "${QPKG_DATAROOT}"/settings
		echolog "Settings folder has been created." 
	else
		echolog "Settings folder exists."
	fi

        "${QPKG_ROOT}"/"${QPKG_NAME}"/core/Linux/"${CPU}"/cubesql -x "${QPKG_DATAROOT}"/databases -s "${QPKG_DATAROOT}/settings/cubesql.settings" &
        PID=$!
    fi
}

case "$1" in
  start)
    ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)
    if [ "$ENABLED" != "TRUE" ]; then
        echo "$QPKG_NAME is disabled."
    fi

    if [ -f "$PIDFILE" ]; then
        if kill -s 0 $PID; then
            echolog "${QPKG_NAME} is already running with PID: $PID"
        else
            echo "" > $QPKG_LOG_FILE
            echolog "INFO: ${QPKG_NAME} has previously not been stopped properly."
            /sbin/write_log "${QPKG_NAME} has previously not been stopped properly." 2
            echolog "Starting ${QPKG_NAME} ..."
            start_daemon
        fi
    else
        echo "" > $QPKG_LOG_FILE
        echolog "Starting ${QPKG_NAME} ..."
        start_daemon
    fi
    ;;


  stop)
   if [ -f "${PIDFILE}" ]; then
        echolog "Stopping ${QPKG_NAME}..."
        echolog "${QPKG_NAME} PID to be killed" "$PID"
        kill ${PID} >> "${QPKG_LOG_FILE}"
        while [ -e /proc/${PID} ]; do sleep 0.1; done
        echolog "${QPKG_NAME} has been stopped."
    else
        echolog "${QPKG_NAME} is not running."
    fi
    ;;
    
  restart)
    ;;

  *)
    echo "Usage: $0 {start|stop|restart}"
esac
