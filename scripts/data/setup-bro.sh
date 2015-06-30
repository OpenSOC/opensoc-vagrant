#!/bin/bash

source "/vagrant/scripts/common.sh"

function installBro {

    cd /etc/yum.repos.d/
    wget -nv http://download.opensuse.org/repositories/network:bro/CentOS_6/network:bro.repo
    yum install -y bro

}

function configureBro {

    cp /vagrant/resources/data/local.bro /opt/bro/share/bro/site/local.bro

    sed -i 's/interface=eth0/interface=lo/' /opt/bro/etc/node.cfg

    /opt/bro/bin/broctl install
}

echo "Setting up Bro"
installBro
configureBro
/opt/bro/bin/broctl restart
