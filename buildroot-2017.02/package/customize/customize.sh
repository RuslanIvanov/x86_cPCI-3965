#!/bin/bash
#выполняется перед cборкой образа файловой системы из деректория target в /buildroot*/output/

echo [run customize.sh]

CURRENT_DIR=$PWD
SERV_DIR=ksdserv

echo [current dir: $CURRENT_DIR]
echo [BASE_DIR: $BASE_DIR]
echo [TARGET_DIR: $TARGET_DIR]

PATH_SERV=/home/russl1404/projects/${SERV_DIR} #менять при необходимости
#PATH_SERV=/home/russl1404/linuxTraining/work/serverM
HOMEDIR=/home/russl1404

echo [PATH_SERVER: $PATH_SERV]

#cp -R ${CURRENT_DIR}/package/customize/www ${TARGET_DIR}/var
cp -R ${CURRENT_DIR}/package/customize/files_for_rootfs/etc ${TARGET_DIR}
cp -R ${CURRENT_DIR}/package/customize/files_for_rootfs/usr ${TARGET_DIR}
#cp -R ${CURRENT_DIR}/package/customize/files_for_rootfs/lib ${TARGET_DIR}

echo "[remove ${TARGET_DIR}/${SERV_DIR}]"
rm -R  ${TARGET_DIR}/${SERV_DIR}

echo "[make ${TARGET_DIR}/${SERV_DIR}]"
mkdir ${TARGET_DIR}/${SERV_DIR}
mkdir ${TARGET_DIR}/${SERV_DIR}/server_saksd

mkdir ${TARGET_DIR}/${SERV_DIR}/server_saksd/bin
mkdir ${TARGET_DIR}/${SERV_DIR}/server_saksd/lib
mkdir ${TARGET_DIR}/${SERV_DIR}/server_saksd/log
mkdir ${TARGET_DIR}/${SERV_DIR}/dbase_bin
mkdir ${TARGET_DIR}/${SERV_DIR}/dbase_xml

cp -R ${PATH_SERV}/server_saksd/bin ${TARGET_DIR}/${SERV_DIR}/server_saksd/
cp -R ${PATH_SERV}/server_saksd/log ${TARGET_DIR}/${SERV_DIR}/server_saksd/
cp -R ${PATH_SERV}/server_saksd/lib ${TARGET_DIR}/${SERV_DIR}/server_saksd/

cp -R ${PATH_SERV}/dbase_xml ${TARGET_DIR}/${SERV_DIR}/
cp -R ${PATH_SERV}/dbase_bin ${TARGET_DIR}/${SERV_DIR}/

#cp -p ${PATH_SERV}/infobus/ksdbus ${TARGET_DIR}/${SERV_DIR}/infobus/
#cp -p ${PATH_SERV}/infobus/imitserv_start_local.sh ${TARGET_DIR}/${SERV_DIR}/infobus/

cp -p ${PATH_SERV}/server_saksd/startserv.sh	${TARGET_DIR}/${SERV_DIR}/server_saksd/
cp -p ${PATH_SERV}/server_saksd/killserv.sh	${TARGET_DIR}/${SERV_DIR}/server_saksd/
cp -p ${PATH_SERV}/server_saksd/startservM.sh   ${TARGET_DIR}/${SERV_DIR}/server_saksd/
cp -p ${PATH_SERV}/server_saksd/startservS.sh   ${TARGET_DIR}/${SERV_DIR}/server_saksd/

#cp -p ${PATH_SERV}/ipcsrun.sh 		${TARGET_DIR}/server_saksd/

echo [copy syslinux.cfg]
cp -p ${CURRENT_DIR}/package/customize/syslinux.cfg ${BASE_DIR}/images/



