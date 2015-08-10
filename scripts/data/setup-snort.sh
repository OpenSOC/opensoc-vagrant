#!/bin/bash

source "/vagrant/scripts/common.sh"

DAQ_VER=2.0.6-1
SNORT_VER=2.9.7.5-1
RULES_TARBALL=snortrules-snapshot-2975.tar.gz

function installDeps {
    echo "installing dependencies"
    yum install -y rpm-build wget gcc flex bison zlib zlib-devel libpcap libpcap-devel libdnet-devel zlib-devel pcre pcre-devel tcpdump mysql mysql-server mysql-devel git libtool curl man

}

function installSnort {

    downloadFile "https://www.snort.org/downloads/snort/daq-${DAQ_VER}.src.rpm" "daq-${DAQ_VER}.src.rpm"
    rpmbuild --rebuild $TARBALL
    yum localinstall -y "/root/rpmbuild/RPMS/x86_64/daq-${DAQ_VER}.x86_64.rpm"

    downloadFile "https://www.snort.org/downloads/snort/snort-${SNORT_VER}.src.rpm" "snort-${SNORT_VER}.src.rpm"
    rpmbuild -D 'debug_package %{nil}' --rebuild $TARBALL
    yum localinstall -y "/root/rpmbuild/RPMS/x86_64/snort-${SNORT_VER}.x86_64.rpm"

    mkdir -p /usr/local/lib/snort_dynamicrules

}

function configureSnort {
    echo "installing local rules"
    tar -xzf "/vagrant/resources/data/${RULES_TARBALL}" -C /etc/snort

    echo "installing community rules"
    wget --no-check-certificate -nv -O community.tar.gz https://www.snort.org/rules/community # uses cloudflare's SSL cert.
    tar -xzf community.tar.gz -C /etc/snort/rules

    echo "configuring snort.conf"
    sed -i "s/^ipvar HOME_NET any/ipvar HOME_NET [10.0.0.0\/8,192.168.0.0\/16,172.16.0.0\/12]/" /etc/snort/snort.conf
    sed -i "s/^# output alert_syslog: LOG_AUTH LOG_ALERT/output alert_syslog: LOG_LOCAL3 LOG_ALERT/" /etc/snort/snort.conf
    
    # disable reputation pre-processor
    commentLine "var WHITE_LIST_PATH" /etc/snort/snort.conf
    commentLine "var BLACK_LIST_PATH" /etc/snort/snort.conf
    commentLine "preprocessor reputation" /etc/snort/snort.conf
    commentLine "   memcap 500" /etc/snort/snort.conf
    commentLine "   priority whitelist," /etc/snort/snort.conf
    commentLine "   nested_ip inner," /etc/snort/snort.conf
    commentLine "   whitelist \$WHITE_LIST_PATH\/white_list.rules," /etc/snort/snort.conf
    commentLine "   blacklist \$BLACK_LIST_PATH\/black_list.rules" /etc/snort/snort.conf

    echo "configuring /etc/sysconfig/snort"
    sed -i "s/INTERFACE=eth0/INTERFACE=lo/" /etc/sysconfig/snort
}

echo "Setting up Snort"
installDeps
installSnort
configureSnort

service snortd start
