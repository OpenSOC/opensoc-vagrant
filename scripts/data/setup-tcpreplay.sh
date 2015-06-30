#!/bin/bash

source "/vagrant/scripts/common.sh"

function installTcpreplay {
    yum install -y tcpreplay
}

echo "Setting up Tcpreplay"
installTcpreplay
