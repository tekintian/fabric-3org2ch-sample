#!/bin/sh
# 删除所有 hyperledger/fabric* 的容器
# 
OPTS=$1
: ${OPTS:=""} # 设置默认为空 ，如果 -f 则为强制删除

docker rmi ${OPTS} $(docker images -a|awk '/^hyperledger\/fabric/{print $3}')

echo "${OPTS} DELETE OK!"
