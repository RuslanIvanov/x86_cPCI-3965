#!/bin/bash

logger "set ip table..."
./setInterfForForwarding.sh eth0 eth2 192.168.8.100
#./setInterfForForwarding.sh eth1 eth3 192.168.9.100 #orig
./setInterfForForwarding.sh eth1 eth2 192.168.8.100  #temp

#./setInterfForForwarding.sh eth0 eth1 192.168.9.100 #debug


