#!/bin/bash

source "/vagrant/scripts/common.sh"

STORM_FOL=/opt/storm

while getopts t:r: option; do
    case $option in
        t) TOTAL_NODES=$OPTARG;;
        r) STORM_ROLE=$OPTARG;;
    esac
done


function installStorm {
    downloadApacheFile storm ${STORM_VERSION} "${STORM_VERSION}.tar.gz"

    tar -oxzf $TARBALL -C /opt
    safeSymLink "/opt/${STORM_VERSION}" $STORM_FOL

    mkdir -p /var/log/storm
}

function configureStorm {
    echo "Configuring Storm"

    echo "storm.zookeeper.servers:" >> /opt/storm/conf/storm.yaml
    for i in $(seq 2 $TOTAL_NODES); do
        echo "  - node${i}" >> /opt/storm/conf/storm.yaml
    done

    echo "nimbus.host: node1" >> /opt/storm/conf/storm.yaml
    echo "java.library.path: /usr/local/lib:/opt/local/lib:/usr/lib:/opt/hadoop/lib/native:/usr/lib64" >> /opt/storm/conf/storm.yaml
    echo "LD_LIBRARY_PATH:/usr/local/lib:/opt/local/lib:/usr/lib:/opt/hadoop/lib/native:/usr/lib64" >> /opt/storm/conf/storm_env.ini
    echo "export PATH=/opt/storm/bin:$PATH">>~/.bashrc

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
