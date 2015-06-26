#!/bin/bash

source "/vagrant/scripts/common.sh"


function installFlume {

    downloadApacheFile flume $FLUME_VERSION "apache-flume-${FLUME_VERSION}-bin.tar.gz"

    tar -oxf $TARBALL -C /opt
    safeSymLink "/opt/apache-flume-${FLUME_VERSION}-bin" /opt/flume

}

echo "Setting up Flume"
installFlume