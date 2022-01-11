#!/bin/sh

#######################################################################
# (1) run process from superuser root (less security)
# (0) run process from unprivileged user "nobody" (more security)
SVC_ROOT=1

# process priority (0-normal, 19-lowest)
SVC_PRIORITY=5
#######################################################################

SVC_NAME="AdGuardHome"
SVC_PATH="/usr/bin/AdGuardHome"
WORK_DIR="/tmp/agh"
DIR_CONF="/etc/storage/AdGuardHome.yaml"
LOG_FILE="syslog"

func_start()
{
	if [ -n "`pidof AdGuardHome`" ] ; then
		return 0
	fi

	echo -n "Starting $SVC_NAME:."
	
	if [ ! -d "${WORK_DIR}" ] ; then
		mkdir -p "${WORK_DIR}"
	fi

	if [ $SVC_ROOT -eq 0 ] ; then
		chmod 777 "${WORK_DIR}"
		svc_user=" -c nobody"
	fi

	start-stop-daemon -S -b -N $SVC_PRIORITY$svc_user -x $SVC_PATH -- -w "$WORK_DIR" -c "$DIR_CONF" -l "$LOG_FILE"
	
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
	if [ -z "`pidof AdGuardHome`" ] ; then
		return 0
	fi
	
	echo -n "Stopping $SVC_NAME:."
	
	# stop daemon
	killall -q AdGuardHome
	
	# gracefully wait max 25 seconds while AGH stop
	i=0
	while [ -n "`pidof AdGuardHome`" ] && [ $i -le 25 ] ; do
		echo -n "."
		i=$(( $i + 1 ))
		sleep 1
	done
	
	tr_pid=`pidof AdGuardHome`
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
