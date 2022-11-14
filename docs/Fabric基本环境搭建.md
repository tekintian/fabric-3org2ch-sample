# Fabric基本环境搭建

mac下可执行文件下载， 下载后解压到bin目录，然后配置PATH变量和FABRIC_CFG_PATH变量
~~~txt
已经打好包的bin文件下载地址
https://wwl.lanzoue.com/iJH1C0fwz4uh

https://www.123pan.com/s/z1M9-C22id 提取码:ynws

官方地址：
fabric

https://gh.flyinbug.top/gh/https://github.com/hyperledger/fabric/releases/download/v1.4.3/hyperledger-fabric-darwin-amd64-1.4.3.tar.gz

fabric-ca

https://gh.flyinbug.top/gh/https://github.com/hyperledger/fabric-ca/releases/download/v1.4.9/hyperledger-fabric-ca-darwin-amd64-1.4.9.tar.gz

~~~

docker-compose.yaml 服务容器中加载外部主机到容器 hosts映射配置

~~~yaml
        extra_hosts:
            - "peer0.org1.example.com:172.31.58.209"
            - "peer0.org2.example.com:172.31.51.44"
            - "peer0.org3.example.com:172.31.53.42"
~~~

## Step 1: clone this repo in fabric-samples directory

```sh
git clone https://codeup.aliyun.com/627c790ae4166464dc30236b/hyperledger/fabric-3org2h_143.git
cd fabric-3org2h_143

```

set the bin to PATH
~~~sh
WORK_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $WORK_DIR
# 将bin运行程序加入到环境变量 这样后面就可以直接执行命令，否则需要 加上 ./bin/来指定命令所在路径
export PATH="${WORK_DIR}/bin:$PATH"
# 配置文件路径配置
export FABRIC_CFG_PATH="${WORK_DIR}/config"

# 拉取相关的docker镜像
sh docker_images.sh
~~~

##Step 2: generate the required crypto material for organizations

```sh
# 将证书信息生成到crypto文件夹中
cryptogen generate --config ./crypto-config.yaml --output="config/crypto"
```

## Step 3: generate the channel artifacts

```sh
mkdir channel-artifacts

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


```
参数说明：
-profile 指定configtx.yaml中定义的 profile

-outputAnchorPeersUpdate  [DEPRECATED] Creates a config update to update an anchor peer (works only with the default channel creation, and only for the first update)

-channelID 指定频道的名称

-asOrg  Performs the config generation as a particular organization (by name), only including values in the write set that org (likely) has privilege to set



## Step 4: bring up all the containers, and you should see total 5 containers up and running
```sh
docker-compose up -d
docker ps
```


