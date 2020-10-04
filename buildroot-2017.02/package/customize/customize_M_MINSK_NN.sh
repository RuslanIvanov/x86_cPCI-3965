#!/bin/bash
#выполняется перед cборкой образа файловой системы из деректория target в /buildroot*/output/

echo [run customize.sh]

CITY=$2
echo "*************************************"
echo "ASSEMBLY FOR CITY '$CITY'"
echo "*************************************"

CURRENT_DIR=$PWD
SERV_DIR=ksdserv

echo [current dir: $CURRENT_DIR]
echo [BASE_DIR: $BASE_DIR]
echo [TARGET_DIR: $TARGET_DIR]

if [[ "$CITY" == "MINSK" ]]
then
#MINSK
PATH_SERV=/home/russl1404/linuxTraining/work/serverM_tArmSh_Minsk/serverM_tArmShUpu_1.4.4.2
PATH_DB=/home/russl1404/linuxTraining/work/serverM_tArmSh_Minsk
fi

if [[ "$CITY" == "NNOVGOROD" ]]
then
#NNOVGOROD
PATH_SERV=/home/russl1404/linuxTraining/work/serverM_tArmSh_1.4.2.1
PATH_DB=/home/russl1404/projects/ksdserv
fi

#########################################################################
#PATH_SERV=/home/russl1404/projects/${SERV_DIR} #менять при необходимости
#PATH_SERV=/home/russl1404/linuxTraining/work/serverM_tArmSh_1.4.2
#PATH_SERV=/home/russl/projects2/work/serverM_tArmSh_1.4.2
#PATH_DB=/home/russl/projects/ksdserv

echo [PATH_SERVER: $PATH_SERV]

#cp -R ${CURRENT_DIR}/package/customize/www ${TARGET_DIR}/var
cp -R ${CURRENT_DIR}/package/customize/files_for_rootfs/etc ${TARGET_DIR}
cp -R ${CURRENT_DIR}/package/customize/files_for_rootfs/usr ${TARGET_DIR}

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

cp -R ${PATH_SERV}/bin ${TARGET_DIR}/${SERV_DIR}/server_saksd/
cp -R ${PATH_SERV}/log ${TARGET_DIR}/${SERV_DIR}/server_saksd/
cp -R ${PATH_SERV}/lib ${TARGET_DIR}/${SERV_DIR}/server_saksd/

cp -R ${PATH_DB}/dbase_xml ${TARGET_DIR}/${SERV_DIR}/
cp -R ${PATH_DB}/dbase_bin ${TARGET_DIR}/${SERV_DIR}/

#cp -p ${PATH_SERV}/infobus/ksdbus ${TARGET_DIR}/${SERV_DIR}/infobus/
#cp -p ${PATH_SERV}/infobus/imitserv_start_local.sh ${TARGET_DIR}/${SERV_DIR}/infobus/

cp -p ${PATH_SERV}/startserv.sh	${TARGET_DIR}/${SERV_DIR}/server_saksd/
cp -p ${PATH_SERV}/killserv.sh	${TARGET_DIR}/${SERV_DIR}/server_saksd/

if [[ "$CITY" == "MINSK" ]]
then
cp -p ${PATH_SERV}/startservAssembly.sh  ${TARGET_DIR}/${SERV_DIR}/server_saksd/
cp -p ${PATH_SERV}/startservDesctop.sh   ${TARGET_DIR}/${SERV_DIR}/server_saksd/
fi

if [[ "$CITY" == "NNOVGOROD" ]]
then
cp -p ${PATH_SERV}/startservM.sh   ${TARGET_DIR}/${SERV_DIR}/server_saksd/
cp -p ${PATH_SERV}/startservS.sh   ${TARGET_DIR}/${SERV_DIR}/server_saksd/
fi

echo [copy syslinux.cfg]
cp -p ${CURRENT_DIR}/package/customize/syslinux.cfg ${BASE_DIR}/images/

echo [run adding my services]

#for ARMDS bus
VAR=`cat  ${TARGET_DIR}/etc/services | grep Servers_services`
if [[ -z "$VAR" ]]
then
	cat ${CURRENT_DIR}/package/customize/files_for_rootfs/etc/services_add >>  ${TARGET_DIR}/etc/services
	echo "${CURRENT_DIR}/package/customize/files_for_rootfs/etc/services_add >> ${TARGET_DIR}/etc/services "
else
	echo "my services already added!!!"
fi

if [[ "$CITY" == "MINSK" ]]
then
	echo [run adding services CP]

	VAR2=`cat  ${TARGET_DIR}/etc/services | grep Servers_central_point_MINSK`
	if [[ -z "$VAR2" ]]
	then
		cat ${CURRENT_DIR}/package/customize/files_for_rootfs/etc/services_cp_add >>  ${TARGET_DIR}/etc/services
		echo "${CURRENT_DIR}/package/customize/files_for_rootfs/etc/services_cp_add >> ${TARGET_DIR}/etc/services "
	else
		echo "services for CP already added!!!"
	fi

	echo [run adding host addresses]

        VAR3=`cat  ${TARGET_DIR}/etc/hosts | grep _MINSK_`
        if [[ -z "$VAR3" ]]
        then
                cat ${CURRENT_DIR}/package/customize/files_for_rootfs/etc/hosts_add >>  ${TARGET_DIR}/etc/hosts
                echo "${CURRENT_DIR}/package/customize/files_for_rootfs/etc/hosts_add >> ${TARGET_DIR}/etc/hosts "
        else
                echo "host addresses for CP already added!!!"
        fi

fi
