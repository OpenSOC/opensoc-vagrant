#!/bin/bash

source "/vagrant/scripts/common.sh"

while getopts t:r: option; do
    case $option in
        t) TOTAL_NODES=$OPTARG;;
        r) HBASE_ROLE=$OPTARG;;
    esac
done

function installHbase {
    downloadApacheFile hbase $HBASE_VERSION_NUM "${HBASE_VERSION}-bin.tar.gz"

    tar -oxzf $TARBALL -C /opt
    safeSymLink "/opt/${HBASE_VERSION}" /opt/hbase

    mkdir -p /var/log/hbase
}

function configureHbase {

    generateZkStringNoPorts $TOTAL_NODES
    sed "s/__ZK_QUORUM__/${ZK_STRING_NOPORTS}/" /vagrant/resources/hbase/hbase-site.xml > /opt/hbase/conf/hbase-site.xml
    cp "/vagrant/resources/hbase/supervisor-${HBASE_ROLE}.conf" /etc/supervisor.d/hbase.conf
}

echo "Setting up HBase"
installHbase
configureHbase

