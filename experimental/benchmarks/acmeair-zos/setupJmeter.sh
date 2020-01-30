#!/bin/bash
JMETER_VERSION=apache-jmeter-3.1
DIR=`dirname $0`
CURRENT_DIR=`cd $DIR;pwd`
echo $DIR
echo $CURRENT_DIR
mkdir ${CURRENT_DIR}/nd/Jmeter_setup
pushd ${CURRENT_DIR}/nd/Jmeter_setup
wget http://archive.apache.org/dist/jmeter/binaries/${JMETER_VERSION}.tgz
gunzip ${JMETER_VERSION}.tgz
tar -xf ${JMETER_VERSION}.tar
#git clone https://github.com/acmeair/acmeair-driver
#pushd acmeair-driver
#	git checkout f4ee2b451cc381b7539601d1b741d8b01684fe2b
#popd

wget http://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/json-simple/json-simple-1.1.1.jar
#pushd ${CURRENT_DIR}/nd/Jmeter_setup/acmeair-driver
#	./gradlew build
#popd
cp json-simple-1.1.1.jar ${CURRENT_DIR}/nd/Jmeter_setup/${JMETER_VERSION}/lib/ext/
git clone https://github.com/acmeair/acmeair-nodejs
cp acmeair-nodejs/document/workload/jmeter/lib/acmeair-driver-1.0-SNAPSHOT.jar  ${CURRENT_DIR}/nd/Jmeter_setup/${JMETER_VERSION}/lib/ext/
#pushd acmeair-nodejs
#git checkout 009bd063700089a2680b696336d87bd97e412f0e
#sed -i 's/9080/4000/g' settings.json
#
#popd

mv acmeair-nodejs ../
mv ${JMETER_VERSION}/*  ../Jmeter
tagfile ../Jmeter/bin/*
popd
#mkdir ${CURRENT_DIR}/nd/mongo3
#cp ${CURRENT_DIR}/mongodb.sh ${CURRENT_DIR}/nd/mongo3/

