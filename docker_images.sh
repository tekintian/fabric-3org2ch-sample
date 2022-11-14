#!/bin/sh
#
# fabric主版本； v1的CA版本和主版本一致，V2的CA版本为单独发行
FABRIC_VERSION=1.4.3

# 1.4版本的其他版本都是 0.4.x； 2.x以后的版本都与主版本一致了
# zookeeper   kafka    baseos
# https://hub.docker.com/r/hyperledger/fabric-zookeeper/tags
# 
EXT_VERSION=0.4

# 
docker pull hyperledger/fabric-ca:${FABRIC_VERSION}
docker tag hyperledger/fabric-ca:${FABRIC_VERSION} hyperledger/fabric-ca:latest

docker pull hyperledger/fabric-tools:${FABRIC_VERSION}
docker tag hyperledger/fabric-tools:${FABRIC_VERSION} hyperledger/fabric-tools:latest

docker pull hyperledger/fabric-ccenv:${FABRIC_VERSION}
docker tag hyperledger/fabric-ccenv:${FABRIC_VERSION} hyperledger/fabric-ccenv:latest

docker pull hyperledger/fabric-orderer:${FABRIC_VERSION} 
docker tag hyperledger/fabric-orderer:${FABRIC_VERSION} hyperledger/fabric-orderer:latest

docker pull hyperledger/fabric-peer:${FABRIC_VERSION} 
docker tag hyperledger/fabric-peer:${FABRIC_VERSION} hyperledger/fabric-peer:latest

docker pull hyperledger/fabric-javaenv:${FABRIC_VERSION}
docker tag hyperledger/fabric-javaenv:${FABRIC_VERSION} hyperledger/fabric-javaenv:latest

# https://hub.docker.com/r/hyperledger/fabric-zookeeper/tags
docker pull hyperledger/fabric-zookeeper:${EXT_VERSION}
docker tag hyperledger/fabric-zookeeper:${EXT_VERSION} hyperledger/fabric-zookeeper:latest

# https://hub.docker.com/r/hyperledger/fabric-kafka/tags
docker pull hyperledger/fabric-kafka:${EXT_VERSION} 
docker tag hyperledger/fabric-kafka:${EXT_VERSION} hyperledger/fabric-kafka:latest

# https://hub.docker.com/_/couchdb/tags
docker pull couchdb:2
docker tag couchdb:2 hyperledger/fabric-couchdb:latest

# https://hub.docker.com/r/hyperledger/fabric-baseos/tags
docker pull hyperledger/fabric-baseos:${EXT_VERSION}
docker tag hyperledger/fabric-baseos:${EXT_VERSION} hyperledger/fabric-baseos:latest
