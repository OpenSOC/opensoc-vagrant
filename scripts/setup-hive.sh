#!/bin/bash

source "/vagrant/scripts/common.sh"

function installHive {
    
    downloadApacheFile hive $HIVE_VERSION "apache-${HIVE_VERSION}-bin.tar.gz"

    tar -oxzf $TARBALL -C /opt
    safeSymLink "/opt/apache-${HIVE_VERSION}-bin/" /opt/hive

    mkdir -p /var/log/hive

    cp /vagrant/resources/hive/supervisor-hive-metastore.conf /etc/supervisor.d/hive-metastore.conf

}

function installMySql {
    yum install -y mysql-server mysql-connector-java

    chkconfig mysqld on
    service mysqld start

    safeSymLink /usr/share/java/mysql-connector-java.jar /opt/hive/lib/mysql-connector-java.jar

    echo "Setting up mysql user"
    if mysql -u root mysql -e "select User from user where User='hive';" | grep hive; then
        echo "hive user exists..."
    else
        mysql -u root < /vagrant/resources/hive/hive-user.sql
    fi

    echo "Setting up metastore schema"
    if mysql -u root -e "show databases like 'hivemeta';" | grep hivemeta; then
        echo "metastore table exists..."
    else
        mysql -u root -e "CREATE DATABASE hivemeta;"
        cd /opt/hive/scripts/metastore/upgrade/mysql && mysql -u hive -phive123 hivemeta < hive-schema-1.2.0.mysql.sql
    fi
}

function configureHive {

    cp /vagrant/resources/hive/hive-site.xml /opt/hive/conf/
}

echo "Setting up Hive"
installHive
installMySql
configureHive