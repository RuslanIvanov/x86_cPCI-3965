#!/bin/bash

CITY=$2
echo "*************************************"
echo "ASSEMBLY FOR CITY '$CITY'"
echo "*************************************"

TFTPBOOT=/tftpboot/SERVER #менять при необходимости
IMAGEDIR=${BASE_DIR}/images/*

echo "----------------------------------------------------------------------------------------------------------------------------------"
echo "Copy in $TFTPBOOT from $IMAGEDIR"
echo "----------------------------------------------------------------------------------------------------------------------------------"

cp -v -r ${IMAGEDIR} ${TFTPBOOT}

touch ${TFTPBOOT}/readme.txt
echo "assembly for '$CITY'" > ${TFTPBOOT}/readme.txt

