#!/bin/bash

JRE_RPM=jre-7u45-linux-x64.rpm
HADOOP_VERSION=hadoop-2.6.0
ZOOKEEPER_VERSION=zookeeper-3.4.6
KAFKA_SCALA_VERSION=2.9.2
KAFKA_VERSION_NUM=0.8.1.1
KAFKA_VERSION="kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION_NUM}"
STORM_VERSION=apache-storm-0.9.4

# So we dont need to pass in i to the scripts
NODE_NUMBER=`hostname | tr -d node`

function downloadFile {

    cached_file="/vagrant/resources${1}"
    if [ ! -e $cached_file ]; then
        echo "Downloading ${cached_file} from ${2}"
        echo "This will take some time. Please be patient..."
        wget -nv -O $cached_file $2
    fi

    cp $cached_file $1
}

function join {
    local IFS="$1"; shift; echo "$*"
}

function generateZkString {
    # Yes its ugly, but so is bash :)
    ZK_STRING=`python -c "print ','.join([ 'node{0}:2181'.format(x) for x in range(2,${1}+1)])"`
}

function safeSymLink {
    target=$1
    symlink=$2

    if [ -e $symlink ]; then
        echo "${symlink} exists. Deleteing."
        rm $symlink
    fi

    ln -s $target $symlink
}