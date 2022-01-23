#!/bin/sh

#######################################################################
# (1) run process from superuser root (less security)
# (0) run process from unprivileged user "nobody" (more security)
SVC_ROOT=0

# process priority (0-normal, 19-lowest)
SVC_PRIORITY=5
#######################################################################

SVC_NAME="FileBrowser"
SVC_PATH="/media/AiDisk_a1/.filebrowser/filebrowser"
WORK_DIR="/media/AiDisk_a1/.filebrowser"
DIR_CONF="/media/AiDisk_a1/.filebrowser/config.yaml"
MEDIA_PATH="/media/AiDisk_a1"

func_start()
{
	if [ -n "`pidof filebrowser`" ] ; then
		return 0
	fi

	echo "Starting $SVC_NAME:."

    if [ ! -d "${MEDIA_PATH}" ] ; then
        echo "No valid storage device found!"
        return 1
    fi

	if [ ! -d "${WORK_DIR}" ] ; then
		mkdir -p "${WORK_DIR}"
	fi

    if [ ! -f "${SVC_PATH}" ] ; then
        logger "Downloading FileBrowser..."
        wget -O ${SVC_PATH} https://gitlab.com/justanemo/pdv-extras-bin/-/raw/main/filebrowser
        chmod +x ${SVC_PATH}
        logger "Done downloading FileBrowser."
    fi

	if [ $SVC_ROOT -eq 0 ] ; then
		chmod 777 "${WORK_DIR}"
		svc_user=" -c nobody"
	fi

	filebrowser_port=`nvram get filebrowser_port`
	lan_ipaddr=`nvram get lan_ipaddr`
    
    cd ${WORK_DIR}
	start-stop-daemon -S -b -N $SVC_PRIORITY$svc_user -x $SVC_PATH -- -a "$lan_ipaddr" -p "$filebrowser_port" -r "/media" -c "$DIR_CONF"
	
	if [ $? -eq 0 ] ; then
		echo "[  OK  ]"
		logger -t "$SVC_NAME" "daemon is started"
	else
		echo "[FAILED]"
	fi
}

func_stop()
{
	# Make sure not running
	if [ -z "`pidof filebrowser`" ] ; then
		return 0
	fi
	
	echo -n "Stopping $SVC_NAME:."
	
	# stop daemon
	killall -q filebrowser
	
	# gracefully wait max 25 seconds while AGH stop
	i=0
	while [ -n "`pidof filebrowser`" ] && [ $i -le 25 ] ; do
		echo -n "."
		i=$(( $i + 1 ))
		sleep 1
	done
	
	tr_pid=`pidof filebrowser`
	if [ -n "$tr_pid" ] ; then
		# force kill (hungup?)
		kill -9 "$tr_pid"
		sleep 1
		echo "[KILLED]"
		logger -t "$SVC_NAME" "Cannot stop: Timeout reached! Force killed."
	else
		echo "[  OK  ]"
	fi
}

case "$1" in
start)
	func_start
	;;
stop)
	func_stop
	;;
restart)
	func_stop
	func_start
	;;
*)
	echo "Usage: $0 {start|stop|restart}"
	exit 1
	;;
esac
