#!/bin/bash

echo "********************************************************************"
echo "*help: '$0' <interface> <port> <'in' or 'out' or 'inout'>			 *"
echo "********************************************************************"

sleep 5

PORT=$2
INTER=$1
TYPE=$3

echo "UDP: Interface $INTER, port $PORT type $TYPE"

sleep 5

sudo tcpdump udp -i $INTER $PLACE port $PORT -X -Q $TYPE
