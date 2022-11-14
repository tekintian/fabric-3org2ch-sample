#!/bin/sh
#
# 接收脚本参数 $0 为脚本名称； $1为第一个参数；$2为第二个参数； 
DC_ACT=$1
: ${DC_ACT:="up"} # 设置默认为 up

set -eux

WORK_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $WORK_DIR

if [ $DC_ACT == "up" ];then

	export PATH="${WORK_DIR}/bin:$PATH"
	# 配置文件路径配置
	export FABRIC_CFG_PATH="${WORK_DIR}/config"

	if [ -d "crypto" ];then
		rm -rf config/crypto/*
	fi
	# Step 2: generate the required crypto material for organizations
	# 将证书信息生成到crypto文件夹中
	cryptogen generate --config ./config/crypto-config.yaml --output="config/crypto"

	# Step 3: generate the channel artifacts
	if [ ! -d "channel-artifacts" ];then
		mkdir channel-artifacts
	else
		rm -rf channel-artifacts/*
	fi

	# 注意下面的 configtxgen 命令如果和configtx.yaml所在目录不一致，则必须要指定配置文件路径，否则后面无法创建频道！！！
	# configtxgen -profile ./config/configtx.yaml -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block

	configtxgen -profile ./config/configtx.yaml -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block

	export CHANNEL_ONE_NAME=channelall
	export CHANNEL_ONE_PROFILE=ChannelAll
	export CHANNEL_TWO_NAME=channel12
	export CHANNEL_TWO_PROFILE=Channel12

	# 频道初始区块创建
	configtxgen -profile ./config/configtx.yaml -profile ${CHANNEL_ONE_PROFILE} -outputCreateChannelTx ./channel-artifacts/${CHANNEL_ONE_NAME}.tx -channelID $CHANNEL_ONE_NAME

	configtxgen -profile ./config/configtx.yaml -profile ${CHANNEL_TWO_PROFILE} -outputCreateChannelTx ./channel-artifacts/${CHANNEL_TWO_NAME}.tx -channelID $CHANNEL_TWO_NAME

	# 锚点频道创建 3个用户的anchor channel
	configtxgen -profile ./config/configtx.yaml -profile ${CHANNEL_ONE_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors_${CHANNEL_ONE_NAME}.tx -channelID $CHANNEL_ONE_NAME -asOrg Org1MSP

	configtxgen -profile ./config/configtx.yaml -profile ${CHANNEL_ONE_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors_${CHANNEL_ONE_NAME}.tx -channelID $CHANNEL_ONE_NAME -asOrg Org2MSP

	configtxgen -profile ./config/configtx.yaml -profile ${CHANNEL_ONE_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors_${CHANNEL_ONE_NAME}.tx -channelID $CHANNEL_ONE_NAME -asOrg Org3MSP

	# 锚点 2个用户的anchor channel
	configtxgen -profile ./config/configtx.yaml -profile ${CHANNEL_TWO_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors_${CHANNEL_TWO_NAME}.tx -channelID $CHANNEL_TWO_NAME -asOrg Org1MSP

	configtxgen -profile ./config/configtx.yaml -profile ${CHANNEL_TWO_PROFILE} -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors_${CHANNEL_TWO_NAME}.tx -channelID $CHANNEL_TWO_NAME -asOrg Org2MSP

	docker-compose up -d

else
	# clean
	rm -rf config/crypto
	rm -rf channel-artifacts

	docker-compose down -v

	# 删除dev-xx的容器和镜像
	docker rm -f $(docker ps -a|awk '/dev-*/{print $1}')
	docker rmi -f $(docker images|awk '/dev-*/{print $3}')

fi
