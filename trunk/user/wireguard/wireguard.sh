#!/bin/sh
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

cfg_file="/etc/storage/wireguard.conf"

if [ ! -f "$cfg_file" ] || [ ! -s "$cfg_file" ] ; then
	cat > "$cfg_file" <<-\EEE
WAN="ppp0"
ADDR="10.127.0.1" # Server (our) address in WireGuard network
SUBNET="10.127.0.0/24"
IFACE="wg0"
MASK="24" # WireGuard network mask
PRIVATE_KEY="iBgjJQutq3JUpixs8Su25YS4Jd5SDlYLxgaJAvy4rm4=" # Server (our) private key
SERVER_PORT="55551" # WireGuard Client port

ENDPOINT_PUBLIC_KEY_1="UrnVAkJLr/n4FzGdX4XUo/MOscnG5CRwws8Z0ZP9mhM=" # WireGuard Client public key
ENDPOINT_ALLOWED_IP_1="10.127.0.2/32"

ENDPOINT_PUBLIC_KEY_2="gjxr2Lf0AkX5jzlBACklKVG0VSFJu8a1xe4XoVJiVBU=" # WireGuard Client public key
ENDPOINT_ALLOWED_IP_2="10.127.0.3/32"

ENDPOINT_PUBLIC_KEY_3="fsEWNFdxxJhzZiWgKMqST2/7FYm7hcmVmzTiJGSYOg4=" # WireGuard Client public key
ENDPOINT_ALLOWED_IP_3="10.127.0.4/32"

ENDPOINT_PUBLIC_KEY_4="dGdWjXT7PSutgNawJ5P0e6+l9jm07KnzgmYxd1EKEUQ=" # WireGuard Client public key
ENDPOINT_ALLOWED_IP_4="10.127.0.5/32"

ENDPOINT_PUBLIC_KEY_5="fgR1hK6+SpX7NHrORj38Coy1/ICTEWsTXn3RwYY4gRw=" # WireGuard Client public key
ENDPOINT_ALLOWED_IP_5="10.127.0.6/32"

CFG="/tmp/wireguard_${IFACE}.conf"


EEE
fi

. "$cfg_file"

  printf '%s\n' \
  "[Interface]" \
  "ListenPort = ${SERVER_PORT}" \
  "PrivateKey = ${PRIVATE_KEY}" \
  "" \
  "[Peer]" \
  "PublicKey = ${ENDPOINT_PUBLIC_KEY_1}" \
  "AllowedIPs = ${ENDPOINT_ALLOWED_IP_1}" \
  "" \
  "[Peer]" \
  "PublicKey = ${ENDPOINT_PUBLIC_KEY_2}" \
  "AllowedIPs = ${ENDPOINT_ALLOWED_IP_2}" \
  "" \
  "[Peer]" \
  "PublicKey = ${ENDPOINT_PUBLIC_KEY_3}" \
  "AllowedIPs = ${ENDPOINT_ALLOWED_IP_3}" \
  "" \
  "[Peer]" \
  "PublicKey = ${ENDPOINT_PUBLIC_KEY_4}" \
  "AllowedIPs = ${ENDPOINT_ALLOWED_IP_4}" \
  "" \
  "[Peer]" \
  "PublicKey = ${ENDPOINT_PUBLIC_KEY_5}" \
  "AllowedIPs = ${ENDPOINT_ALLOWED_IP_5}" > "$CFG"

  #cat "$CFG"
  echo -n "Setting up WireGuard interface... "

[ -e /sys/module/wireguard ] `modprobe wireguard`
!(ip link show ${IFACE} 2>/dev/null) && \
    (ip link add dev ${IFACE} type wireguard) && \
    (ip addr add ${ADDR}/${MASK} dev ${IFACE}) && \
    (sleep 1) && \
    (wg setconf ${IFACE} "$CFG") && \
    (sleep 1) && \
    (ip link set ${IFACE} up)

ifconfig ${IFACE} up

  echo "done"
  rm -f "$CFG"

echo 1 > /proc/sys/net/ipv4/ip_forward
echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects

iptables -I INPUT -i ${WAN} -p udp -m udp --dport ${SERVER_PORT} -j ACCEPT
iptables -I INPUT -i ${IFACE} -j ACCEPT
iptables -I FORWARD -i ${IFACE} -o ${IFACE} -j ACCEPT
iptables -I FORWARD -i ${IFACE} -o br0 -j ACCEPT
iptables -I FORWARD -i br0 -o ${IFACE} -j ACCEPT

iptables -I FORWARD -i ${IFACE} -o ${WAN} -j ACCEPT
iptables -I FORWARD -i ${WAN} -o ${IFACE} -j ACCEPT

iptables -t nat -A POSTROUTING -s ${SUBNET} -o ${WAN} -j MASQUERADE

/bin/ip route add ${SUBNET} dev ${IFACE}
