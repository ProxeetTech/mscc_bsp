#!/bin/sh

nr_frames=10000

turn_red()
{
        tmp=$1
        case $tmp in
                eth1)
                        echo 1 > /sys/class/leds/cu0:red/brightness
                        ;;
                eth2)
                        echo 1 > /sys/class/leds/cu1:red/brightness
                        ;;
                eth3)
                        echo 1 > /sys/class/leds/s0:red/brightness
                        ;;
                eth4)
                        echo 1 > /sys/class/leds/s1:red/brightness
                        ;;
        esac
}

turn_green()
{
        tmp=$1
        case $tmp in
                eth1)
                        echo 1 > /sys/class/leds/cu0:green/brightness
                        ;;
                eth2)
                        echo 1 > /sys/class/leds/cu1:green/brightness
                        ;;
                eth3)
                        echo 1 > /sys/class/leds/s0:green/brightness
                        ;;
                eth4)
                        echo 1 > /sys/class/leds/s1:green/brightness
                        ;;
        esac
}

# set up the ports
for i in $(seq 0 8)
do
        tmp=`cat /sys/class/net/eth$i/phys_switch_id 2>&1 > /dev/null`
        if [ $? -eq 0 ]
        then
                sysctl -w net.ipv6.conf.eth$i.disable_ipv6=1
                ip link set dev eth$i up
        fi
done

# read statistics
for i in $(seq 0 8)
do
        tmp=`cat /sys/class/net/eth$i/phys_switch_id 2>&1 > /dev/null`
        if [ $? -eq 0 ]
        then
                packets=`cat /sys/class/net/eth$i/statistics/rx_packets`
                echo "/tmp/eth#{i}_rx_packets"
                echo $packets > /tmp/eth${i}_rx_packets
        fi
done

# wait for link
for i in $(seq 0 8)
do
        tmp=`cat /sys/class/net/eth$i/phys_switch_id 2>&1 > /dev/null`
        if [ $? -eq 0 ]
        then
                echo "Waiting for eth$i to get link"
                timeout=0
                while true
                do
                        link=`cat /sys/class/net/eth$i/carrier`
                        if [[ $link -eq 1 ]]
                        then
                                break
                        fi
                        sleep 1
                        if [ $timeout -ge 15 ]
                        then
                                echo "No link for eth$i"
                                break
                        fi
                        timeout=$((timeout + 1))
                done
        fi
done

echo 0 > /sys/class/leds/cu0:green/brightness
echo 0 > /sys/class/leds/cu1:green/brightness

# send frames
for i in $(seq 0 8)
do
        tmp=`cat /sys/class/net/eth$i/phys_switch_id 2>&1 > /dev/null`
        if [ $? -eq 0 ]
        then
                ef tx eth$i repeat $nr_frames eth smac ::1 dmac ::2 data repeat 1000 0
        fi
done

# wait to send all frames and for statistics to be updated
sleep 10

# check the new statistics
fail=false
for i in $(seq 0 8)
do
        tmp=`cat /sys/class/net/eth$i/phys_switch_id 2>&1 > /dev/null`
        if [ $? -eq 0 ]
        then
                new=`cat /sys/class/net/eth$i/statistics/rx_packets`
                old=`cat /tmp/eth${i}_rx_packets`
                old=$(($old + $nr_frames))
                if [ $new -ne $old ]
                then
                        echo "Port eth$i failed to receive $nr_frames"
                        turn_red eth${i}
                        fail=true
                else
                        echo "Port eth$i OK"
                        turn_green eth${i}
                fi
        fi
done

if [ $fail = true ]; then
    echo "Test network failed"
    exit 1
fi

exit 0
