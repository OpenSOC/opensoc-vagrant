#!/bin/bash

source "/vagrant/scripts/common.sh"

function installPycapa {
    yum install -y git
    git clone https://github.com/OpenSOC/pycapa /opt/pycapa
    cd /opt/pycapa
    pip install -r requirements.txt
    python setup.py install

}

function configurePycapa {
    cp /vagrant/resources/data/pycapa.conf /etc/init
}

echo "Setting up Pycapa"
installPycapa
configurePycapa
start pycapa
