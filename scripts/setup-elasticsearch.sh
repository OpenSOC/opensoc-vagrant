#!/bin/bash

source "/vagrant/scripts/common.sh"

ELASTIC_PATH=/opt/elasticsearch


while getopts ci: option; do
    case $option in
        c) ES_CLIENT=yes;;
        i) IP_ADDR=$OPTARG;;
    esac
done

function installElasticsearch {

    downloadFile "https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz" "elasticsearch-${ES_VERSION}.tar.gz"

    tar -oxf $TARBALL -C /opt
    safeSymLink "/opt/elasticsearch-${ES_VERSION}" $ELASTIC_PATH 

    mkdir -p /var/lib/elasticsearch
    mkdir -p /var/log/elasticsearch
    mkdir -p $ELASTIC_PATH/plugins
}

function configureElasticsearch {

    hostname=`hostname -f`
    if [ -z "${ES_CLIENT}" ]; then
        echo "Configuring elasticsearch as a normal node"
        sed "s/__HOSTNAME__/${hostname}/" /vagrant/resources/elasticsearch/elasticsearch.yml | sed "s/__IP_ADDR__/${IP_ADDR}/" > $ELASTIC_PATH/config/elasticsearch.yml
    else 
        echo "Configuring elasticsearch as a client"
        sed "s/__HOSTNAME__/${hostname}/" /vagrant/resources/elasticsearch/elasticsearch-client.yml | sed "s/__IP_ADDR__/${IP_ADDR}/" > $ELASTIC_PATH/config/elasticsearch.yml
    fi

    if [ ! -e $ELASTIC_PATH/plugins/kopf ]; then
        echo "Installing kopf plugin"
        $ELASTIC_PATH/bin/plugin --install lmenezes/elasticsearch-kopf/1.5.6
    fi

    cp /vagrant/resources/elasticsearch/supervisor-elasticsearch.conf /etc/supervisor.d/elasticsearch.conf
    echo "export PATH=$ELASTIC_PATH/bin:$PATH">>/home/vagrant/.bashrc

}
echo "Setting up Elasticsearch"
installElasticsearch
configureElasticsearch


