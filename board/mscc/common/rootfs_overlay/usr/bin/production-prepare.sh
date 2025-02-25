#!/bin/sh

file=$1
local_ip=$2
peer_ip=$3
serial=$4

ip link set dev eth0 up
ip addr add ${local_ip}/24 dev eth0

echo "Waiting for eth0 to get link"
while true
do
    link=`cat /sys/class/net/eth0/carrier`
    if [[ $link -eq 1 ]]
    then
        break
    fi
    sleep 1
done

sleep 10

cd /tmp
wget http://${peer_ip}:8000/${file}
chmod +x /tmp/${file}
/tmp/${file} ${local_ip} ${peer_ip} ${serial}
