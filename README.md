# Fabric 3 Org 2 Channel Network Deployment

Fabric 3组织，2 channel环境部署脚本

- cli容器目录说明

下面3个变量默认放到了cli中，方便测试！
FABRIC_ROOT=/opt/gopath/src/github.com/hyperledger/fabric
CRYPTO_DIR=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

chaincode 加载到容器目录 /opt/gopath/src/github.com/chaincode

CouchDB 管理地址 http://localhost:5984/_utils/   用户名： fabric 密码 fabric888

服务名称使用服务域名，这样在depends_on:的时候docker就会自动解析服务名对应的容器IP地址


如果需要更改容器的运行版本，到文件.env中修改接口

在.env文件中定义后的变量即可在 docker-compose.yaml 文件中使用，使用方法同环境变量的使用。


## 基础环境一键搭建
~~~sh
#一键拉取相关的镜像和重新tag
sh docker_images.sh

# 下载好脚本和bin文件后一键运行基础环境
sh run.sh up

# 停止环境
sh run.sh down

# 删除所有已经下载的 hyperledger/fabric镜像
sh rm_img.sh
# 强制删除
sh rm_img.sh -f

~~~


[详细步骤参考docs/Fabric基本环境搭建.md](docs/Fabric%E5%9F%BA%E6%9C%AC%E7%8E%AF%E5%A2%83%E6%90%AD%E5%BB%BA.md)

## 打开3个窗口并配置基本环境变量

*Org1*
org1的基础环境变量已经配置在了cli容器中，所以这里无需再次配置，直接进入容器即可。

```sh
docker exec -it cli bash 

# 下面3个变量默认放到了cli中，方便测试！
# export FABRIC_ROOT=/opt/gopath/src/github.com/hyperledger/fabric
# export CRYPTO_DIR=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto
# export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

```

*Org2*
通过在运行exec时使用 -e指定环境变量进入容器
```sh

docker exec -e "CORE_PEER_LOCALMSPID=Org2MSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp" -e "CORE_PEER_ADDRESS=peer0.org2.example.com:7051" -it cli bash

```

*Org3*
```sh
docker exec -e "CORE_PEER_LOCALMSPID=Org3MSP" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp" -e "CORE_PEER_ADDRESS=peer0.org3.example.com:7051" -it cli bash

# export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

```

## create and join channel

For channelall

*Org1*

```sh
# 创建 channelall
peer channel create -o orderer.example.com:7050 -c channelall -f ${FABRIC_ROOT}/peer/channel-artifacts/channelall.tx --tls --cafile $ORDERER_CA
# 加入初始区块
peer channel join -b channelall.block --tls --cafile $ORDERER_CA

# 更新锚点
peer channel update -o orderer.example.com:7050 -c channelall -f ${FABRIC_ROOT}/peer/channel-artifacts/Org1MSPanchors_channelall.tx --tls --cafile $ORDERER_CA
```

*Org2*
```sh
# 加入频道 channelall
peer channel join -b channelall.block --tls --cafile $ORDERER_CA
# 更新锚点
peer channel update -o orderer.example.com:7050 -c channelall -f ${FABRIC_ROOT}/peer/channel-artifacts/Org2MSPanchors_channelall.tx --tls --cafile $ORDERER_CA
```

*Org3*
```sh
# 加入频道 channelall
peer channel join -b channelall.block --tls --cafile $ORDERER_CA
# 更新锚点
peer channel update -o orderer.example.com:7050 -c channelall -f ${FABRIC_ROOT}/peer/channel-artifacts/Org3MSPanchors_channelall.tx --tls --cafile $ORDERER_CA
```

For channel12

*Org1*
```sh
# 创建频道 channel12
peer channel create -o orderer.example.com:7050 -c channel12 -f ${FABRIC_ROOT}/peer/channel-artifacts/channel12.tx --tls --cafile $ORDERER_CA
# 加入频道
peer channel join -b channel12.block --tls --cafile $ORDERER_CA
# 更新锚点
peer channel update -o orderer.example.com:7050 -c channel12 -f ${FABRIC_ROOT}/peer/channel-artifacts/Org1MSPanchors_channel12.tx --tls --cafile $ORDERER_CA
```

*Org2*
```sh
peer channel join -b channel12.block --tls --cafile $ORDERER_CA

peer channel update -o orderer.example.com:7050 -c channel12 -f ${FABRIC_ROOT}/peer/channel-artifacts/Org2MSPanchors_channel12.tx --tls --cafile $ORDERER_CA

```

Step 6: Check each peer the channel(s) it has joint. 

For each terminal,
```sh
peer channel list
```

You should see org1 and org2 has two channels, while org3 only on channelall.

If everything looks good, you now have a fabric network with 3 organizations set, and ready for testing any chaincode.


## Reuse the crypto material and channel artifacts
You can keep the content inside *config/crypto* and *channel-artifacts* for next test. If you have them already you can start with Step 4.

Enjoy Hyperledger Fabric!


## Fabric多通道安装Simple Asset链码（SACC）

现在我们的Fabric多通道实验网络已经起来了，可以开始部署链码了。
代码参考： chaincode/sacc/SimpleAsset.go



Fabric Samples提供的SACC链码的逻辑很简单：

- 当链码实例化时就会执行`Init()`函数，该函数需要两个参数，分别对应键和值
- 将传入Init()函数的键/值对使用PutState方法保存到账本中
- 在链码实例化之后，对交易的处理是由`Invoke()`函数来负责的。 该函数的参数 包括一个方法名以及若干参数。
- 如果调用Invoke()函数时方法名为set，那么就需要传入两个参数，分别表示要 设置的键和值
- 如果调用Invoke()函数时方法名为get，那么就需要一个参数，表示要读取的键

通过链码安装操作，就可以在各节点上启动链码。注意在链码实例化之前还不可用。

在各节点对应的终端中使用如下命令安装链码：

```sh
peer chaincode install -n sacc_v1_0 -p github.com/chaincode/sacc -v 1.0
```

参数说明：

-n sacc_v1_0 指定链码的名称为 sacc_v1_0

-p 指定链码的代码目录,注意，这里的相对目录为 GOPATH的根目录

-v 指定版本号 1.0




如果执行成功，我们应当可以看到如下的输出结果：

install -> INFO 003 Installed remotely response:<status:200 payload:"OK" >

现在所有的节点上都安装了SACC链码，我们可以实例化这个链码了。



## Fabric多通道实验1：ChannelAll通道上Fabric链码的实例化与访问



首先我们看包含所有三个机构的ChannelAll通道。

### 在Org1对应的终端中，在ChannelAll通道上实例化链码：

```sh
peer chaincode instantiate -o orderer.example.com:7050 --tls \
  --cafile $ORDERER_CA -C channelall -c '{"Args":["a", "100"]}' \
  -n sacc_v1_0 -v 1.0 -P "OR('Org1MSP.peer', 'Org2MSP.peer', 'Org3MSP.peer')"
```

参数说明：

-o 指定orderer服务地址和端口  orderer.example.com:7050

--tls 使用呢tls认证通信

--cafile  指定用于认证身份的ca证书，这里对应cryptogen生成的 ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

-C  指定链码要安装的channel名称  channelall  ，注意这里是大写C

-c  小写c,指定调用参数JSON字符串，这里设置了a参数的值为100

-n  要安装的链码名称  sacc_v1_0

-v 链码版本  1.0

-P  背书策略，`OR`表示只需要 3个机构中的任何一个背书即可。



### 在通道ChannelAll上查询键`a`的值。

- 进入Org1对应的终端，运行如下命令：

```sh
peer chaincode query -C channelall -n sacc_v1_0 -c '{"Args":["get","a"]}'
```

结果： 100

- 现在在Org2对应的终端中运行如下命令：

```sh
peer chaincode query -C channelall -n sacc_v1_0 -c '{"Args":["get","a"]}'
```

结果：100

- 现在在Org3对应的终端中运行如下命令：

```sh
peer chaincode query -C channelall -n sacc_v1_0 -c '{"Args":["get","a"]}'
```

结果：100

现在我们可以看到在三个节点上得到了相同的值，它们共享同一个账本。


## Fabric多通道实验2：在Channel12通道上SACC链码的实例化与交互

现在让我们在通道Channel12上实例化这个SACC链码。

在Org1对应的终端中，运行如下命令：

```sh
peer chaincode instantiate -o orderer.example.com:7050 \
  --tls --cafile $ORDERER_CA -C channel12 \
  -c '{"Args":["b", "200"]}' -n sacc_v1_0 -v 1.0 \
  -P "OR('Org1MSP.peer', 'Org2MSP.peer')"
```

这次我们将初始的键/值对设置为`b/200`，背书策略为任一机构完成背书即可。

- 还是从Org1开始：

```
peer chaincode query -C channel12 -n sacc_v1_0 -c '{"Args":["get","b"]}'
```

结果：200

- 然后进入Org2对应的终端：

```sh
peer chaincode query -C channel12 -n sacc_v1_0 -c '{"Args":["get","b"]}'
```

结果:200

- 如果我们在Org3对应的终端运行同样的命令，

  就会看到提示禁止访问。这是 因为Org3没有加入通道Channel12：

```sh
peer chaincode query -C channel12 -n sacc_v1_0 -c '{"Args":["get","b"]}'
```

结果如下：

~~~txt
Error: error endorsing query: rpc error: code = Unknown desc = access denied: channel [channel12] creator org [Org3MSP] - proposal response: <nil>
~~~

如果我们尝试在通道Channel12上读取键`a`的值，会发现提示没有定义`a`。 在Hyperledger Fabric中，每个通道都有自己的账本，不同通道的状态是不共享的。



- 在Org1和Org2的终端中运行如下命令：

```sh
peer chaincode query -C channel12 -n sacc_v1_0 -c '{"Args":["get","a"]}'
```

结果如下：

~~~txt
Error: endorsement failure during query. response: status:500 message:"Asset not found: a"
~~~

## clean up: always good practice for cleaning up stuff after testing
```sh
sh run.sh down
```

## Fabric多通道实验小节

在本教程中，我们介绍了如何搭建一个多通道Fabric网络，并展示了不同 通道的数据隔离能力。





