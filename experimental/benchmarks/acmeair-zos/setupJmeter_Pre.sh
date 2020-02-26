#!/bin/bash
#Run on linux
JMETER_VERSION=apache-jmeter-3.1
DIR=`dirname $0`
CURRENT_DIR=`cd $DIR;pwd`
echo $DIR
echo $CURRENT_DIR
mkdir ${CURRENT_DIR}/nd/Jmeter_setup
pushd ${CURRENT_DIR}/nd/Jmeter_setup
cp ${JMETER_PATH}/${JMETER_VERSION}.tgz ./
gunzip ${JMETER_VERSION}.tgz
tar -xfUXo ${JMETER_VERSION}.tar

git clone https://github.com/acmeair/acmeair-nodejs
pushd acmeair-nodejs
#git checkout 009bd063700089a2680b696336d87bd97e412f0e
if [ -z $ACME_PORT ]; then
    ACME_PORT=9080
fi
sed -i 's/9080/'"$ACME_PORT"'/g' settings.json
chtag -tc 819 settings.json
popd

mv acmeair-nodejs ../
mv ${JMETER_VERSION}/*  ../Jmeter
chtag -tc 819 ../Jmeter/bin/*
popd
#mkdir ${CURRENT_DIR}/nd/mongo3
#cp ${CURRENT_DIR}/mongodb.sh ${CURRENT_DIR}/nd/mongo3/

