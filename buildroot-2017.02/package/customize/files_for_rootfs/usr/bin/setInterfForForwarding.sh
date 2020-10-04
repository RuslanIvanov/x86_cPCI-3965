#!/bin/bash

if [[ -z "$1" ]]
then
	logger "ERROR: 1 param is NULL"
 	logger "HELP: thisscript.sh interfFrom interfTo destIP"

elif [[ -z "$2" ]]
then
	logger "ERROR: 2 param is NULL"
	logger "HELP: thisscript.sh interfFrom interfTo destIP"

elif [[ -z "$3" ]]
then
	logger "ERROR: 3 param is NULL"
	logger "HELP: thisscript.sh interfFrom interfTo destIP"
else

DEST_IP=$3
INTERF_FROM=`ifconfig $1 | grep "inet addr" | head -n 1 | cut -d : -f 2 | cut -d " " -f 1`
INTERF_TO=`ifconfig $2 | grep "inet addr" | head -n 1 | cut -d : -f 2 | cut -d " " -f 1`

#INTERF_FROM=`ifconfig $1 | sed -n /inet addr:/s/^[^:]*:\([0-9\.]*\).*/\1/gp'`
#INTERF_TO=`ifconfig $2 | sed -n /inet addr:/s/^[^:]*:\([0-9\.]*\).*/\1/gp'`

if [[ -z "$INTERF_FROM" ]]
then
        logger "ERROR: error in  interface 'from'"
elif [[ -z "$INTERF_TO" ]]
then
	logger "ERROR: error in  interface 'to'"
else

logger "forwarding ftp:  from $INTERF_FROM  to  $INTERF_TO on $DEST_IP"

fwIsSet=`cat /proc/sys/net/ipv4/ip_forward`
logger "ip_forward is $fwIsSet"
if [[ "$fwIsSet" -eq "0" ]]
then
        sudo sysctl -w net.ipv4.ip_forward=1
        logger "forwarding ftp: seted ip_forward=1"
fi

EXT_IP=$INTERF_FROM # внешний, реальный IP-адрес шлюза;
INT_IP=$INTERF_TO # внутренний IP-адрес шлюза, в локальной сети
EXT_IF=$1 # Внешний интерфейс (от АРМ ШН на Сервер)
INT_IF=$2 # внутренний интерфейс (на АРМ ДС от Серевер)
LAN_IP=$DEST_IP  # Локальный адрес назначения (АРМ ДС),
SRV_PORT="20"  # порт 
SRV_PORT2="21" # порт

#1)
iptables -t nat -A PREROUTING --dst $EXT_IP -p tcp -m tcp --dport 64000:65535 -j DNAT --to-destination $LAN_IP
iptables -t nat -A POSTROUTING --dst $LAN_IP -p tcp --dport 64000:65535 -j SNAT --to-source $INT_IP
#iptables -t nat -A OUTPUT --dst $EXT_IP -p tcp --dport 64000:65535 -j DNAT --to-destination $LAN_IP
#iptables -I FORWARD -i $EXT_IF -o $INT_IF -d $LAN_IP -p tcp -m tcp --dport 64000:65535 --match state --state NEW,ESTABLISHED,RELATED -j ACCEPT

#2)
iptables -t nat -A PREROUTING --dst $EXT_IP -p tcp --dport $SRV_PORT -j DNAT --to-destination $LAN_IP
iptables -t nat -A POSTROUTING --dst $LAN_IP -p tcp --dport $SRV_PORT -j SNAT --to-source $INT_IP
#iptables -t nat -A OUTPUT --dst $EXT_IP -p tcp --dport $SRV_PORT -j DNAT --to-destination $LAN_IP
#iptables -I FORWARD -i $EXT_IF -o $INT_IF -d $LAN_IP -p tcp -m tcp --dport $SRV_PORT --match state --state NEW,ESTABLISHED,RELATED  -j ACCEPT

#3)
iptables -t nat -A PREROUTING --dst $EXT_IP -p tcp --dport $SRV_PORT2 -j DNAT --to-destination $LAN_IP
iptables -t nat -A POSTROUTING --dst $LAN_IP -p tcp --dport $SRV_PORT2 -j SNAT --to-source $INT_IP
#iptables -t nat -A OUTPUT --dst $EXT_IP -p tcp --dport $SRV_PORT2 -j DNAT --to-destination $LAN_IP
#iptables -I FORWARD -i $EXT_IF -o $INT_IF -d $LAN_IP -p tcp -m tcp --dport $SRV_PORT2 --match state --state NEW,ESTABLISHED,RELATED  -j ACCEPT

logger "forwarding ftp: is set (PREROUTING & POSTROUTING)"

fi
fi
