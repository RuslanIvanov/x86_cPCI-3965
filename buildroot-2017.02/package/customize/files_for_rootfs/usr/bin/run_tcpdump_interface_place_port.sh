#!/bin/bash

echo "********************************************************************"
echo "*help: '$0' <interface> <place ('src' or 'dst')> <port>*"
echo "********************************************************************"

sleep 5

PORT=$3
INTER=$1
PLACE=$2

echo "UDP: Interface $INTER, place (src or dst) $PLACE,  port $PORT"

sleep 5

sudo tcpdump udp -i $INTER $PLACE port $PORT -X
