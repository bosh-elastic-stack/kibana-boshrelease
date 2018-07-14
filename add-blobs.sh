#!/bin/sh

DIR=`pwd`

mkdir -p .downloads

cd .downloads

if [ ! -f ${DIR}/blobs/kibana/kibana-6.3.1-linux-x86_64.tar.gz ];then
    curl -L -O -J https://artifacts.elastic.co/downloads/kibana/kibana-6.3.1-linux-x86_64.tar.gz
    bosh add-blob --dir=${DIR} kibana-6.3.1-linux-x86_64.tar.gz kibana/kibana-6.3.1-linux-x86_64.tar.gz
fi

cd -
