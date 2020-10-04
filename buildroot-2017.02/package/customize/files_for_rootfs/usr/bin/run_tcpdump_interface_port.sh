#!/bin/bash

echo "****************************************"
echo "*help: '$0'<interf> <port>			 *"
echo "****************************************"

sleep 5

PORT=$2
INTERF=$1

echo "UDP: interface '$INTERF' port '$PORT'"

sleep 5

sudo tcpdump udp -i $INTERF port $PORT -X
