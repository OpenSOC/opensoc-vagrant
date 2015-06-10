#!/bin/bash

source "/vagrant/scripts/common.sh"

while getopts t: option; do
    case $option in
        t) TOTAL_NODES=$OPTARG;;
    esac
done

function installKafka {
    downloadApacheFile kafka ${KAFKA_VERSION_NUM} "${KAFKA_VERSION}.tgz"

    tar -oxzf $TARBALL -C /opt
    safeSymLink "/opt/${KAFKA_VERSION}/" /opt/kafka 

    mkdir -p /var/lib/kafka-logs
    mkdir -p /var/log/kafka
}

function configureKafka {
    echo "Configuring Kafka"
    # copy over config with static properties
    cp /vagrant/resources/kafka/server.properties /opt/kafka/config/

    # echo in dynamic ones
    echo "broker.id=${NODE_NUMBER}" >> /opt/kafka/config/server.properties

    generateZkString $TOTAL_NODES

    echo "zookeeper.connect=${ZK_STRING}" >> /opt/kafka/config/server.properties

    cp /vagrant/resources/kafka/supervisor-kafka.conf /etc/supervisor.d/kakfa.conf
}


echo "Setting up Kafka"
installKafka
configureKafka