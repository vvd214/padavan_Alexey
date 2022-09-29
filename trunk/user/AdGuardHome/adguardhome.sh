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

count=0
while :
do
	ping -c 1 -W 1 -q 8.8.8.8 1>/dev/null 2>&1
	if [ "$?" == "0" ]; then
		break
	fi
	sleep 5
	count=$((count+1))
	if [ $count -gt 18 ]; then
		break
	fi
done

getconfig(){
if [ ! -f "$DIR_CONF" ] || [ ! -s "$DIR_CONF" ] ; then
	cat > "$DIR_CONF" <<-\EEE
bind_host: 0.0.0.0
bind_port: 3000
auth_name: admin
auth_pass: admin
language: 
rlimit_nofile: 0
dns:
  bind_host: 0.0.0.0
  port: 53
  protection_enabled: true
  filtering_enabled: true
  filters_update_interval: 24
  blocking_mode: nxdomain
  blocked_response_ttl: 10
  querylog_enabled: false
  ratelimit: 20
  ratelimit_whitelist: []
  refuse_any: true
  bootstrap_dns:
  - 8.8.8.8
  - 8.8.4.4
  - https://dns.google/dns-query
  - tls://dns.google
  all_servers: true
  allowed_clients: []
  disallowed_clients: []
  blocked_hosts: []
  parental_sensitivity: 0
  parental_enabled: false
  safesearch_enabled: false
  safebrowsing_enabled: false
  resolveraddress: ""
  upstream_dns:
  - 8.8.8.8
  - 8.8.4.4
tls:
  enabled: false
  server_name: ""
  force_https: false
  port_https: 443
  port_dns_over_tls: 853
  certificate_chain: ""
  private_key: ""
filters:
- enabled: true
  url: https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt
  name: AdGuard DNS filter
  id: 1
- enabled: true
  url: https://adaway.org/hosts.txt
  name: AdAway Default Blocklist
  id: 2
- enabled: true
  url: https://abpvn.com/android/abpvn.txt
  name: ABVN
  id: 1643333073
- enabled: false
  url: https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt
  name: WindowsSpyBlocker - Hosts spy rules
  id: 1643333518
user_rules: []
dhcp:
  enabled: false
  interface_name: ""
  gateway_ip: ""
  subnet_mask: ""
  range_start: ""
  range_end: ""
  lease_duration: 86400
  icmp_timeout_msec: 1000
clients: []
log_file: ""
verbose: false
schema_version: 3
EEE
	chmod 755 "$DIR_CONF"
fi
}

func_start()
{
	getconfig
	if [ -n "`pidof AdGuardHome`" ] ; then
		return 0
	fi

	echo -n "Starting $SVC_NAME:."
	
	replace_dnsmasq=`nvram get adguard_replace_dns`
	
	if [ $replace_dnsmasq -eq 1 ] ; then
		if grep -q "^#port=0$" /etc/storage/dnsmasq/dnsmasq.conf; then
			sed -i '/port=0/s/^#//g' /etc/storage/dnsmasq/dnsmasq.conf
		else
			if grep -q "^port=0$" /etc/storage/dnsmasq/dnsmasq.conf; then
				true
			else
				echo "port=0" >> /etc/storage/dnsmasq/dnsmasq.conf
			fi
		fi
		/sbin/restart_dhcpd
	fi

	if [ ! -d "${WORK_DIR}" ] ; then
		mkdir -p "${WORK_DIR}"
	fi

	if [ $SVC_ROOT -eq 0 ] ; then
		chmod 777 "${WORK_DIR}"
		svc_user=" -c nobody"
	fi
	adg_port=`nvram get adguard_port`
	lan_ipaddr=`nvram get lan_ipaddr`

	start-stop-daemon -S -b -N $SVC_PRIORITY$svc_user -x $SVC_PATH -- -w "$WORK_DIR" -c "$DIR_CONF" -h "$lan_ipaddr" -p "$adg_port" --no-check-update
	
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

	restart_dnsmasq=`nvram get adguard_replace_dns`
	if [ $restart_dnsmasq -eq 1 ] ; then
		if grep -q "^port=0$" /etc/storage/dnsmasq/dnsmasq.conf; then
			sed -i '/port=0/s/^/#/g' /etc/storage/dnsmasq/dnsmasq.conf
		fi
		/sbin/restart_dhcpd
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
