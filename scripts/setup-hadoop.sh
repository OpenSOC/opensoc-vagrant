#!/bin/bash

source "/vagrant/scripts/common.sh"

HADOOP_PATH=/opt/hadoop

while getopts r:t: option; do
    case $option in
        t) TOTAL_NODES=$OPTARG;;
        r) ROLE=$OPTARG;;
    esac
done

function installHadoop {
    
    downloadApacheFile hadoop/common $HADOOP_VERSION "${HADOOP_VERSION}.tar.gz"

    tar -oxzf $TARBALL -C /opt
    safeSymLink "/opt/${HADOOP_VERSION}/" $HADOOP_PATH

    mkdir -p /var/lib/hadoop/hdfs/namenode
    mkdir -p /var/lib/hadoop/hdfs/datanode
    mkdir -p /var/log/hadoop
    mkdir -p $HADOOP_PATH/logs

    # neeed for writing to HDFS
    yum install -y snappy snappy-devel

}

function configureHadoop {
    HADOOP_RESOURCE_DIR=/vagrant/resources/hadoop
    for file in `ls ${HADOOP_RESOURCE_DIR}/*.xml`; do
        echo "Copying ${file}"
        cp $file $HADOOP_PATH/etc/hadoop
    done

    echo "Setting slaves file"
    for i in $(seq 2 $TOTAL_NODES); do
        echo "node${i}" >> $HADOOP_PATH/etc/hadoop/slaves
    done

    echo "export JAVA_LIBRARY_PATH=\${JAVA_LIBRARY_PATH}:/usr/lib/hadoop/lib/native:/usr/lib64" >> $HADOOP_PATH/etc/hadoop/hadoop-env.sh
}

function configureNameNode {
    echo "Copying over Supervisor config for namenode and resourcemanager"
    cp /vagrant/resources/hadoop/supervisor-namenode.conf /etc/supervisor.d/namenode.conf
    cp /vagrant/resources/hadoop/supervisor-resourcemanager.conf /etc/supervisor.d/resourcemanager.conf
}

function configureDataNode {
    echo "Copying over Supervisor config for datenode"
    cp /vagrant/resources/hadoop/supervisor-datanode.conf /etc/supervisor.d/datanode.conf
}

echo "Setting up Hadoop"
installHadoop
configureHadoop

if [ "${ROLE}" == "namenode" ]; then
    configureNameNode
elif [ "${ROLE}" == "datanode" ]; then
    configureDataNode
fi
