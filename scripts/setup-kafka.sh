#!/bin/bash

source "/vagrant/scripts/common.sh"

while getopts t: option; do
    case $option in
        t) TOTAL_NODES=$OPTARG;;
    esac
done

function installKafka {
    KAFKA_TARBALL="/tmp/${KAFKA_VERSION}.tgz"
    KAFKA_URL="http://apache.mirrors.lucidnetworks.net/kafka/${KAFKA_VERSION_NUM}/${KAFKA_VERSION}.tgz"

    downloadFile $KAFKA_TARBALL $KAFKA_URL

    tar -oxzf $KAFKA_TARBALL -C /opt
    ln -f -s "/opt/${KAFKA_VERSION}" /opt/kafka

    mkdir -p /var/lib/kafka-logs
}

function configureKafka {
    # copy over config with static properties
    cp /vagrant/resources/kafka/server.properties /opt/kafka/config/

    # echo in dynamic ones
    echo "broker.id=${NODE_NUMBER}" >> /opt/kafka/config/server.properties

    generateZkString $TOTAL_NODES

    echo "zookeeper.connect=${ZK_STRING}" >> /opt/kafka/config/server.properties

}

function startKafka {

    echo "Starting Kafka"
    cd /opt/kafka; bin/kafka-server-start.sh config/server.properties &

}
echo "Setting up Kafka"
installKafka
configureKafka
startKafka