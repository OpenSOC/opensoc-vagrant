#!/bin/bash

source "/vagrant/scripts/common.sh"

function configureRsyslog {

    cp /vagrant/resources/data/rsyslog.conf /etc/rsyslog.conf

    echo "configuring rsyslog for snort"
    cp /vagrant/resources/data/snort-rsyslog.conf /etc/rsyslog.d/snort.conf

}

echo "Setting up rsyslog"
configureRsyslog
service rsyslog restart