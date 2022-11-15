# docker-compose.yaml 公共模板抽取配置示例
下面以couchdb的配置为例来演示模板抽取配置

下面抽取了Peer节点的公共信息为模板，所以只需要在这一个地方配置couchdb即可
peer-base.yaml
~~~yaml
version: '2'

services:
  peer-base:
    image: hyperledger/fabric-peer:${FABRIC_VERSION}
    environment:
      # couchdb
      # 指定账本状态的数据库为 CouchDB
      - CORE_LEDGER_STATE_STATEDATABASE=CouchDB
      # CouchDB的服务信息配置 服务地址，链接用户名密码
      - CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=couchdb:5984  
      - CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=fabric
      - CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=fabric888

    working_dir: ${FABRIC_ROOT}/peer
    command: peer node start
    depends_on:
      - couchdb # 这个将couchdb服务链接到peer服务中，这样在peer服务中就可以通过服务名来访问couchdb 
~~~

将每个节点的配置信息抽取为模板 docker-compose-base.yaml
~~~yaml
version: '2'

services:
  # peer0服务
  peer0.org1.example.com:
    container_name: peer0.org1.example.com
    # 这里使用extends加载被提取出去的公共配置，指定文件名和服务即可将公共配置加载到当前服务中来
    extends:
      file: peer-base.yaml
      service: peer-base
~~~


docker-compose.yaml中使用
~~~yaml
version: '2'

volumes:
  orderer.example.com:
  peer0.org1.example.com:
  peer0.org2.example.com:
  peer0.org3.example.com:

# 创建网络并指定子网
networks:
  byfn:
    name: byfn
    ipam:
      config:
        - subnet: 172.19.0.0/16

services:
################### peer service 172.19.2.x ##################
  # 
  # peer0 org1  172.19.2.10
  # 
  peer0.org1.example.com:
    container_name: peer0.org1.example.com
    extends:
      file:  base/docker-compose-base.yaml
      service: peer0.org1.example.com
    networks:
      byfn:
        ipv4_address: 172.19.2.10
~~~

注意上面的 base/docker-compose-base.yaml 中使用的volumes需要在docker-compose.yaml中定义，否则是加载不到的。

总结： 抽取出去的yaml定义中可以定义服务节点services中能定义的所有内容，Docker在加载时会先加载extends中的内容到services中，所以他可以使用在主yaml中定义的其他内容，如volumes和网络等。



