#!/bin/bash

source "/vagrant/scripts/common.sh"


function downloadGeoData {

    downloadFile http://geolite.maxmind.com/download/geoip/database/GeoLiteCity_CSV/GeoLiteCity-latest.zip GeoLiteCity-latest.zip
    geo_folder=`unzip -l $TARBALL | grep -m 1 -o -E GeoLiteCity_[0-9]{8}`
    cd /tmp && unzip $TARBALL

}

function provisionMySql {

    sed "s/__GEO_FOLDER__/${geo_folder}/" /vagrant/resources/opensoc/geo.sql > /tmp/geo.sql
    mysql -u root < /tmp/geo.sql
}

echo "Setting up Geo Enrichment Data"
downloadGeoData
provisionMySql
