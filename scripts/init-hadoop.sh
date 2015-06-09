#!/bin/bash

source "/vagrant/scripts/common.sh"

while getopts r: option; do
    case $option in 
        r) ROLE=$OPTARG;;
    esac
done

function startHadoopRole {
    ps -ef | grep -v grep | grep -v vagrant | grep $1
    if [ $? -ne 0 ]; then 
        /opt/hadoop/sbin/hadoop-daemon.sh --config /opt/hadoop/etc/hadoop --script hdfs start $1
    fi
}

function startYarnRole {
    ps -ef | grep -v grep | grep -v vagrant | grep $1
    if [ $? -ne 0 ]; then
        /opt/hadoop/sbin/yarn-daemon.sh --config /opt/hadoop/etc/hadoop start $1
    fi
}
function formatHdfs {
    /opt/hadoop/bin/hdfs namenode -format vagrant -nonInteractive

}

echo "Starting Hadoop"

if [ "${ROLE}" == "namenode" ]; then
    formatHdfs
    startHadoopRole $ROLE
    startYarnRole "resourcemanager"
elif [ "${ROLE}" == "datanode" ]; then
    startHadoopRole $ROLE
    startYarnRole "nodemanager"
fi