#!/bin/sh

DIR=`pwd`

mkdir -p .downloads

cd .downloads

KIBANA_VERSION=6.6.1

if [ ! -f ${DIR}/blobs/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz ];then
    curl -L -O -J https://artifacts.elastic.co/downloads/kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz
    bosh add-blob --dir=${DIR} kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz kibana/kibana-${KIBANA_VERSION}-linux-x86_64.tar.gz
fi

cd -
