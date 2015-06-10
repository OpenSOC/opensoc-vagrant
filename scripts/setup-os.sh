#!/bin/bash

while getopts t: option; do
    case $option in
        t) TOTAL_NODES=$OPTARG;;
    esac
done

function disableFirewall {
    echo "Disabling the Firewall"
    service iptables save
    service iptables stop
    chkconfig iptables off
}

function writeHostFile {
    echo "setting up /etc/hosts file"

    echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
    echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts

    for i in $(seq 1 $TOTAL_NODES); do
        echo "10.0.0.10${i}   node${i}" >> /etc/hosts
    done
}

function installSupervisorD {
    echo "Installing Supervisor"
    yum install -y epel-release
    yum install -y python-pip

    pip install supervisor
    
    cp /vagrant/resources/supervisord.conf /etc/supervisord.conf

    mkdir -p /etc/supervisor.d
    mkdir -p /var/log/supervisor
}
disableFirewall
writeHostFile
installSupervisorD