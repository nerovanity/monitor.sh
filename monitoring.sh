#!/bin/bash
arch=$(uname -a)
pcpu=$(lscpu | grep Core | tail -1 | cut -d ":" -f2- | tr -d ' ')
vcpu=$(grep "^processor" /proc/cpuinfo | wc -l)
fmem=$(free --mega | awk 'NR==2'| tr -s ' ' : | cut -d ':' -f 2)
umem=$(free --mega | awk 'NR==2'| tr -s ' ' : | cut -d ':' -f 3)
pmem=$((umem * 100 / fmem))
fcap=$(df -h | awk 'NR==4'| tr -s ' ' ':' | cut -d ':' -f 2)
ucap=$(df -m | awk 'NR==4'| tr -s ' ' ':' | cut -d ':' -f 3)
fullcap=$(df -m | awk 'NR==4' | tr -s ' ' ':' | cut -d ':' -f 2)
pcap=$((ucap * 100 / fullcap))
ucpu=$(mpstat | grep all | awk '{printf "%.2f%%", 100 - $13}')
lbootdate=$(last reboot --time-format iso | head -1 | awk '{print $5}' | cut -d 'T' -f 1)
lboottime=$(last reboot --time-format iso | head -1 | awk '{print $5}' | cut -d 'T' -f 2 | cut -d ':' -f2- | cut -d '-' -f 1)
ulvm=$(cat /etc/fstab | grep "mapper" | wc -l | awk '{if($1 >= "1") {printf("yes\n")} else {printf("no\n")}}')
etcp=$(ss -Ht state established | wc -l)
usr=$(who | wc -l)
ip=$(hostname -I)
mac=$(ip link show | grep ether | awk '{print $2}')
cmds=$(journalctl _COMM=sudo -q | grep COMMAND | wc -l)
wall "
	#Architecture: $arch
	#CPU physical: $pcpu
	#vCPU: $vcpu
	#Memory Usage: $umem/${fmem}MB (${pmem}%)
	#Disk Usage: $ucap/${fcap}b (${pcap}%)
	#CPU load: $ucpu
	#Last boot: $lbootdate $lboottime
	#LVM use: $ulvm
	#Connection TCP: $etcp ESTABLISHED
	#User log: $usr
	#Network: IP $ip (${mac})
	#Sudo : $cmds cmd"
