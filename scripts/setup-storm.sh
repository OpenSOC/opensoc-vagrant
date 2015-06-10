#!/bin/bash

source "/vagrant/scripts/common.sh"


while getopts t:r: option; do
    case $option in
        t) TOTAL_NODES=$OPTARG;;
        r) STORM_ROLE=$OPTARG;;
    esac
done


function installStorm {
    STORM_TARBALL="/tmp/${STORM_VERSION}.tar.gz"
    STORM_URL="http://mirror.reverse.net/pub/apache/storm/${STORM_VERSION}/${STORM_VERSION}.tar.gz"

    downloadFile $STORM_TARBALL $STORM_URL

    tar -oxzf $STORM_TARBALL -C /opt
    safeSymLink "/opt/${STORM_VERSION}" /opt/storm

    mkdir -p /var/log/storm
}

function configureStorm {
    echo "Configuring Storm"

    echo "storm.zookeeper.servers:" >> /opt/storm/conf/storm.yaml
    for i in $(seq 2 $TOTAL_NODES); do
        echo "  - node${i}" >> /opt/storm/conf/storm.yaml
    done

    echo "nimbus.host: node1" >> /opt/storm/conf/storm.yaml

}

function setupNimbus {
    echo "Setting up Storm Nimbus"

    cp /vagrant/resources/storm/supervisor-nimbus-ui.conf /etc/supervisor.d/storm.conf
}

function setupSupervisor {
    echo "Setting up Storm Supervisor"

    cp /vagrant/resources/storm/supervisor-worker.conf /etc/supervisor.d/storm.conf
}

echo "Setting up Storm"
installStorm
configureStorm


case $STORM_ROLE in
    nimbus) setupNimbus;;
    supervisor) setupSupervisor;;
esac
