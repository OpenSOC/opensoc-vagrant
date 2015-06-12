#!/bin/bash

source "/vagrant/scripts/common.sh"

while getopts ci: option; do
    case $option in
        c) ES_CLIENT=yes;;
        i) IP_ADDR=$OPTARG;;
    esac
done

function installElasticsearch {

    downloadFile "https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz" "elasticsearch-${ES_VERSION}.tar.gz"

    tar -oxf $TARBALL -C /opt
    safeSymLink "/opt/elasticsearch-${ES_VERSION}" /opt/elasticsearch

    mkdir -p /var/lib/elasticsearch
    mkdir -p /var/log/elasticsearch
    mkdir -p /opt/elasticsearch/plugins
}

function configureElasticsearch {

    hostname=`hostname -f`
    if [ -z "${ES_CLIENT}" ]; then
        echo "Configuring elasticsearch as a normal node"
        sed "s/__HOSTNAME__/${hostname}/" /vagrant/resources/elasticsearch/elasticsearch.yml | sed "s/__IP_ADDR__/${IP_ADDR}/" > /opt/elasticsearch/config/elasticsearch.yml
    else 
        echo "Configuring elasticsearch as a client"
        sed "s/__HOSTNAME__/${hostname}/" /vagrant/resources/elasticsearch/elasticsearch-client.yml | sed "s/__IP_ADDR__/${IP_ADDR}/" > /opt/elasticsearch/config/elasticsearch.yml
    fi

    if [ ! -e /opt/elasticsearch/plugins/kopf ]; then
        echo "Installing kopf plugin"
        /opt/elasticsearch/bin/plugin --install lmenezes/elasticsearch-kopf/1.5.3
    fi

    cp /vagrant/resources/elasticsearch/supervisor-elasticsearch.conf /etc/supervisor.d/elasticsearch.conf

}
echo "Setting up Elasticsearch"
installElasticsearch
configureElasticsearch