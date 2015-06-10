#!/bin/bash

source "/vagrant/scripts/common.sh"

while getopts t: option; do
    case $option in 
        t) TOTAL_NODES=$OPTARG;;
    esac
done

function installZookeeper {
    ZOOKEEPER_TARBALL="/tmp/${ZOOKEEPER_VERSION}.tar.gz"
    ZOOKEEPER_URL="http://apache.mirrors.lucidnetworks.net/zookeeper/${ZOOKEEPER_VERSION}/${ZOOKEEPER_VERSION}.tar.gz"

    downloadFile $ZOOKEEPER_TARBALL $ZOOKEEPER_URL

    tar -oxzf $ZOOKEEPER_TARBALL -C /opt
    safeSymLink "/opt/${ZOOKEEPER_VERSION}/" /opt/zookeeper

    mkdir -p /var/lib/zookeeper
    mkdir -p /var/log/zookeeper

    echo "0 0 * * *  /usr/local/bin/zookeeper_cleanup" >> /etc/crontab

    echo "cd /opt/zookeeper" > /usr/local/bin/zookeeper_cleanup
    echo "echo `date` > /root/last_zk_cleanup" >> /usr/local/bin/zookeeper_cleanup
    echo "bin/zkCleanup.sh /var/lib/zookeeper -n 5 >> /root/last_zk_cleanup" >> /usr/local/bin/zookeeper_cleanup

    chmod +x /usr/local/bin/zookeeper_cleanup

    echo $NODE_NUMBER > /var/lib/zookeeper/myid
}

function configureZookeeper {

    echo "Configuring Zookeeper..."
    echo "tickTime=2000" >  /opt/zookeeper/conf/zoo.cfg
    echo "initLimit=10" >> /opt/zookeeper/conf/zoo.cfg
    echo "syncLimit=5" >> /opt/zookeeper/conf/zoo.cfg
    echo "dataDir=/var/lib/zookeeper" >> /opt/zookeeper/conf/zoo.cfg
    echo "clientPort=2181" >> /opt/zookeeper/conf/zoo.cfg

    for i in $(seq 1 $TOTAL_NODES); do
        echo "server.${i}=node${i}:2888:3888" >> /opt/zookeeper/conf/zoo.cfg
    done

    cp /vagrant/resources/zookeeper/supervisor-zookeeper.conf /etc/supervisor.d/zookeeper.conf
} 

echo "Setting up Zookeeper"

installZookeeper
configureZookeeper