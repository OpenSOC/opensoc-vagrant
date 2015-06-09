#!/bin/bash

source "/vagrant/scripts/common.sh"

while getopts t: option; do
    case $option in
        t) TOTAL_NODES=$OPTARG;;
    esac
done

function installHadoop {
    HADOOP_TARBALL="/tmp/${HADOOP_VERSION}.tar.gz"
    HADOOP_URL="http://mirror.metrocast.net/apache/hadoop/common/${HADOOP_VERSION}/${HADOOP_VERSION}.tar.gz"
    
    downloadFile $HADOOP_TARBALL $HADOOP_URL

    tar -oxzf $HADOOP_TARBALL -C /opt

    ln -f -s "/opt/${HADOOP_VERSION}" /opt/hadoop

    mkdir -p /var/lib/hadoop/hdfs/namenode
    mkdir -p /var/lib/hadoop/hdfs/datanode
}

function configureHadoop {
    HADOOP_RESOURCE_DIR=/vagrant/resources/hadoop
    for file in `ls ${HADOOP_RESOURCE_DIR}`; do
        echo "Copying ${file}"
        cp "${HADOOP_RESOURCE_DIR}/${file}" /opt/hadoop/etc/hadoop
    done

    echo "Setting slaves file"
    for i in $(seq 2 $TOTAL_NODES); do
        echo "node${i}" >> /opt/hadoop/etc/hadoop/slaves
    done
}

echo "Setting up Hadoop"
installHadoop
configureHadoop