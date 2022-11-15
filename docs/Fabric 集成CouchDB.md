# Fabric 集成CouchDB

fabric网络使用CouchDB来保存状态数据主要是在Peer节点中。
使用CouchDB只需要再peer节点增加环境配置即可。

这里直接使用官方Alpine版本的CouchDB, Fabric做的那个CouchDB容器体积太大。

## 第一步：在docker-compose.yaml服务中增加couchdb服务
代码如下
~~~yaml
services:
  ############################# CouchDB ##################
  # couchdb
  # https://hub.docker.com/_/couchdb
  # 172.19.0.5
  couchdb:
    container_name: couchdb
    image: couchdb:2
    # Populate the COUCHDB_USER and COUCHDB_PASSWORD to set an admin user and password
    # for CouchDB.  This will prevent CouchDB from operating in an "Admin Party" mode.
    environment:
      - TZ=PRC
      - COUCHDB_USER=fabric
      - COUCHDB_PASSWORD=fabric888
    # Comment/Uncomment the port mapping if you want to hide/expose the CouchDB service,
    # for example map it to utilize Fauxton User Interface in dev environments.
    ports:
      - "5984:5984"
    networks:
      byfn:
        ipv4_address: 172.19.0.5
~~~
上面的 ipv4_address: 172.19.0.5 是为couchdb服务指定固定IP地址，这个需要在docker-compose.yaml中先指定网络子网，如：
~~~yaml
# docker-compose.yaml
version: '2'

# 创建网络并指定子网
networks:
  byfn:
    name: byfn
    ipam:
      config:
        - subnet: 172.19.0.0/16
~~~

## 第二步，在Peer节点增加配置

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

更多信息
[docker-compose.yaml 公共模板抽取配置示例](docker-compose.yaml公共模板抽取配置示例.md)

