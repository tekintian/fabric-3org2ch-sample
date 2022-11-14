# Fabric创建通道Channel的配置文件configtx.yaml详解

最新官方文档
https://hyperledger-fabric.readthedocs.io/en/release-2.4/create_channel/create_channel_participation.html?highlight=configtxgen#set-up-the-configtxgen-tool

命令参考
https://hyperledger-fabric.readthedocs.io/en/release-2.4/commands/configtxgen.html?highlight=configtxgen

transaction的英文缩写是TX(表示交易)，configtx表示交易配置，所以和交易相关的配置，如应用通道、锚节点、Ordering服务等，都是在configtx.yaml文件中配置的；
 
configtx.yaml文件由6个部分组成：

## 1. Organizations
---组织配置：用来定义不同的组织，MSP(Membership Service Provider)是一个组织的身份标识，在fabric中组织是由MSP来唯一标识的；
~~~yaml
    Organizations:
    # 在此定义的MSP将在Profile部分被引用；
    - &SampleOrg
        # 组织名
        Name: SampleOrg
        # 
        SkipAsForeign: false
        # 组织ID
        ID: SampleOrg
 
        # MSP配置的文件系统路径
        MSPDir: msp
 
        # 组织策略
        Policies: &SampleOrgPolicies
            Readers:
                Type: Signature
                Rule: "OR('SampleOrg.member')"
            Writers:
                Type: Signature
                Rule: "OR('SampleOrg.member')"
            Admins:
                Type: Signature
                Rule: "OR('SampleOrg.admin')"
            Endorsement:
                Type: Signature
                Rule: "OR('SampleOrg.member')"
 
        # 领导节点(Leader Peer)：当有新的交易产生的时候，领导节点就会与Orderer排序服务节点通信，从排序服务节点处获取最新的区块，并随机的传播给其他的记账节点(Committer Peer)，记账节点获取到之后也会继续的往外散播；
        OrdererEndpoints:
            - "127.0.0.1:7050"
 
        # 锚节点(Anchor Peer)：每个组织可以指定Anchor Peer，其他组织的节点就可以将Gossip消息发送到这个Anchor Peer上，进而Anchor Peer将获得整个网络信息，区块广播到本组织内；
        AnchorPeers:
            - Host: 127.0.0.1
              Port: 7051
~~~

## 2. Capabilities
  ---通道能力配置：用来定义fabric网络的能力，通过定义通道的能力，就明确了不满足该能力要求的fabric程序，将无法处理交易，除非升级到对应的版本；
~~~yaml
# 通过定义通道的能力，就明确了不满足该能力要求的fabric程序，将无法处理交易，除非升级到新的版本
Capabilities:
    # Global配置同时针对Orderer节点和Peer节点(设置为ture表明要求节点具备该能力)；
    Channel: &ChannelCapabilities
        # 在启用V2.0功能之前，请确保在同一个Channel上的所有Orderer节点和Peer节点都升级到v2.0.0或更高版本；
        V2_0: true
 
    # Orderer配置仅针对Orderer节点，不需考虑Peer节点的升级(设置为ture表明要求节点具备该能力)；
    Orderer: &OrdererCapabilities
        # 在启用V2.0功能之前，请确保在同一个Channel上的所有Orderer节点升级到v2.0.0或更高版本；
        V2_0: true
 
    # Application配置仅应用于对等网络，不需考虑排序节点的升级
    Application: &ApplicationCapabilities
        # V2.0 for Application enables the new non-backwards compatible
        # features and fixes of fabric v2.0.
        # Prior to enabling V2.0 orderer capabilities, ensure that all
        # orderers on a channel are at v2.0.0 or later.
        V2_0: true
 ~~~
## 3. Application
   ---应用配置：该部分定义了交易配置相关的值，以及创世区块相关的值；
~~~yaml
    Application: &ApplicationDefaults
    # ACLs配置段为系统中各种资源提供默认的策略
    ACLs: &ACLsDefault
        # ACLs配置段为系统中各种资源提供默认的策略。（这里的资源可以是系统链码的函数，也可以是其他资源）
        # 这个配置段不是用来定义资源或API，而仅仅是定义资源的访问控制策略
        # 用户可以在通道定义中重写这些默认策略
 
        # _lifecycle系统链码相关函数定义策略
        # _lifecycle系统链码CheckCommitReadiness函数定义的策略
        _lifecycle/CheckCommitReadiness: /Channel/Application/Writers
 
        # _lifecycle系统链码CommitChaincodeDefinition函数定义的策略
        _lifecycle/CommitChaincodeDefinition: /Channel/Application/Writers
 
        # _lifecycle系统链码QueryChaincodeDefinition函数的定义的策略
        _lifecycle/QueryChaincodeDefinition: /Channel/Application/Writers
 
        # _lifecycle系统链码QueryChaincodeDefinitions函数的定义的策略
        _lifecycle/QueryChaincodeDefinitions: /Channel/Application/Writers
 
        #---Lifecycle System Chaincode (lscc) function to policy mapping for access control---#
 
        # lscc系统链码相关函数定义的策略
        # lscc系统链码的ChaincodeExists函数定义的策略
        lscc/ChaincodeExists: /Channel/Application/Readers
 
        # ACL policy for lscc's "getdepspec" function
        lscc/GetDeploymentSpec: /Channel/Application/Readers
 
        # ACL policy for lscc's "getccdata" function
        lscc/GetChaincodeData: /Channel/Application/Readers
 
        # ACL Policy for lscc's "getchaincodes" function
        lscc/GetInstantiatedChaincodes: /Channel/Application/Readers
 
        # qscc系统链码相关函数定义的策略
        # qscc系统链码GetChainInfo函数定义的策略
        qscc/GetChainInfo: /Channel/Application/Readers
 
        # ACL policy for qscc's "GetBlockByNumber" function
        qscc/GetBlockByNumber: /Channel/Application/Readers
 
        # ACL policy for qscc's  "GetBlockByHash" function
        qscc/GetBlockByHash: /Channel/Application/Readers
 
        # ACL policy for qscc's "GetTransactionByID" function
        qscc/GetTransactionByID: /Channel/Application/Readers
 
        # ACL policy for qscc's "GetBlockByTxID" function
        qscc/GetBlockByTxID: /Channel/Application/Readers
 
        # cscc系统链码相关函数定义的策略
        # cscc系统链码GetConfigBlock函数定义的策略
        cscc/GetConfigBlock: /Channel/Application/Readers
 
        # ACL policy for cscc's "GetChannelConfig" function
        cscc/GetChannelConfig: /Channel/Application/Readers
 
        # peer节点策略
        # 访问peer节点上链码定义的策略
        peer/Propose: /Channel/Application/Writers
 
        # 从链码中访问其他链码定义的策略
        peer/ChaincodeToChaincode: /Channel/Application/Writers
 
        # 事件策略
        # 发送区块事件的定义的策略
        event/Block: /Channel/Application/Readers
 
        # 发送过滤区块事件定义的策略
        event/FilteredBlock: /Channel/Application/Readers
 
    # Organizations配置列出参与到网络中的机构清单
    Organizations:
 
    # 定义本层级的应用控制策略，路径可以这么写 /Channel/Application/<PolicyName>
    Policies: &ApplicationDefaultPolicies
        LifecycleEndorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
        Endorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
 
    # 前面Capabilities配置段中的ApplicationCapabilities配置项，这里直接引用(Capabilities配置定义了应用层级的能力需求)
    Capabilities:
        <<: *ApplicationCapabilities
~~~

## Orderer
   ---排序节点配置：定义了排序服务的相关参数，这些参数将用于创建创世区块或交易；
~~~yaml
    Orderer: &OrdererDefaults
 
    # 排序节点类型用来指定要启用的排序节点实现，不同的实现对应不同的共识算法(目前可用的类型为solo和kafka)。
    OrdererType: solo
 
    Addresses:
        # - 127.0.0.1:7050
 
    BatchTimeout: 2s
 
    BatchSize:
        MaxMessageCount: 500
        AbsoluteMaxBytes: 10 MB
        PreferredMaxBytes: 2 MB
 
    MaxChannels: 0
 
    Kafka:
        Brokers:
            - kafka0:9092
            - kafka1:9092
            - kafka2:9092
 
    EtcdRaft:
        Consenters:
            - Host: raft0.example.com
              Port: 7050
              ClientTLSCert: path/to/ClientTLSCert0
              ServerTLSCert: path/to/ServerTLSCert0
            - Host: raft1.example.com
              Port: 7050
              ClientTLSCert: path/to/ClientTLSCert1
              ServerTLSCert: path/to/ServerTLSCert1
            - Host: raft2.example.com
              Port: 7050
              ClientTLSCert: path/to/ClientTLSCert2
              ServerTLSCert: path/to/ServerTLSCert2
 
        Options:
            TickInterval: 500ms
 
            ElectionTick: 10
 
            HeartbeatTick: 1
 
            MaxInflightBlocks: 5
   
            SnapshotIntervalSize: 16 MB
 
    Organizations:
 
    # 定义本层级的排序节点策略，路径可以这么写：/Channel/Orderer/<PolicyName>
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
        # BlockValidation配置项指定了哪些签名必须包含在区块中，以便peer节点进行验证
        BlockValidation:
            Type: ImplicitMeta
            Rule: "ANY Writers"
 
    # 前面Capabilities配置段中的OrdererCapabilities配置项，这里直接引用(Capabilities配置描述排序节点层级的能力需求)
    Capabilities:
        <<: *OrdererCapabilities
~~~

## 5. Channel
  ---通道配置：用来定义要写入创世区块或配置交易的通道参数；

~~~yaml
    Channel: &ChannelDefaults
    # 定义本层级的通道访问策略，推荐路径为 /Channel/<PolicyName> 
    Policies:
        # Who may invoke the 'Deliver' API
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        # Writers策略定义了调用Broadcast API提交交易的许可规则
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        # Admin策略定义了修改本层级配置的许可规则
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
 
    # 前面Capabilities配置段中的ChannelCapabilities配置项，这里直接引用(Capabilities配置描通道层级的能力需求)
    Capabilities:
        <<: *ChannelCapabilities
 ~~~
## 6. Profiles

---配置入口：Profile部分，主要是引用其余五个部分的参数。
configtxgen通过调用Profile参数，可以实现生成特定的区块文件；
 在Profile配置中，TwoOrgsOrdererGenesis，OrdererDefaults，SampleConsortium，TwoOrgsChannel，以及ApplicationCapabilities 五个字段，可以自定义完成自己搭建联盟链的相关名称。

 ~~~yaml
 Profiles:
 
    # SampleSingleMSPSolo定义了一个使用Solo排序节点、包含单一MSP的配置
    SampleSingleMSPSolo:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
            Organizations:
                - *SampleOrg
        Consortiums:
            SampleConsortium:
                Organizations:
                    - *SampleOrg
 
    # SampleSingleMSPKafka
    SampleSingleMSPKafka:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
            OrdererType: kafka
            Organizations:
                - *SampleOrg
        Consortiums:
            SampleConsortium:
                Organizations:
                    - *SampleOrg
 
    # SampleInsecureSolo定义了一个使用Solo排序节点的简单配置
    SampleInsecureSolo:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
        Consortiums:
            SampleConsortium:
                Organizations:
 
    # SampleInsecureKafka定义了一个使用Kfaka排序节点的配置
    SampleInsecureKafka:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
            OrdererType: kafka
        Consortiums:
            SampleConsortium:
                Organizations:
 
    # SampleDevModeSolo defines a configuration which uses the Solo orderer,
    # contains the sample MSP as both orderer and consortium member, and
    # requires only basic membership for admin privileges. It also defines
    # an Application on the ordering system channel, which should usually
    # be avoided.
    SampleDevModeSolo:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
            Organizations:
                - <<: *SampleOrg
                  Policies:
                      <<: *SampleOrgPolicies
                      Admins:
                          Type: Signature
                          Rule: "OR('SampleOrg.member')"
        Application:
            <<: *ApplicationDefaults
            Organizations:
                - <<: *SampleOrg
                  Policies:
                      <<: *SampleOrgPolicies
                      Admins:
                          Type: Signature
                          Rule: "OR('SampleOrg.member')"
        Consortiums:
            SampleConsortium:
                Organizations:
                    - <<: *SampleOrg
                      Policies:
                          <<: *SampleOrgPolicies
                          Admins:
                              Type: Signature
                              Rule: "OR('SampleOrg.member')"
 
    # SampleDevModeKafka defines a configuration that differs from the
    # SampleDevModeSolo one only in that it uses the Kafka-based orderer.
    SampleDevModeKafka:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
            OrdererType: kafka
            Organizations:
                - <<: *SampleOrg
                  Policies:
                      <<: *SampleOrgPolicies
                      Admins:
                          Type: Signature
                          Rule: "OR('SampleOrg.member')"
        Application:
            <<: *ApplicationDefaults
            Organizations:
                - <<: *SampleOrg
                  Policies:
                      <<: *SampleOrgPolicies
                      Admins:
                          Type: Signature
                          Rule: "OR('SampleOrg.member')"
        Consortiums:
            SampleConsortium:
                Organizations:
                    - <<: *SampleOrg
                      Policies:
                          <<: *SampleOrgPolicies
                          Admins:
                              Type: Signature
                              Rule: "OR('SampleOrg.member')"
 
    # SampleSingleMSPChannel定义了一个仅包含单一成员机构的通道。
    # 该配置通常与SampleSingleMSPSolo或SampleSingleMSPKafka同时使用
    SampleSingleMSPChannel:
        <<: *ChannelDefaults
        Consortium: SampleConsortium
        Application:
            <<: *ApplicationDefaults
            Organizations:
                - <<: *SampleOrg
 
    # SampleDevModeEtcdRaft defines a configuration that differs from the
    # SampleDevModeSolo one only in that it uses the etcd/raft-based orderer.
    SampleDevModeEtcdRaft:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
            OrdererType: etcdraft
            Organizations:
                - <<: *SampleOrg
                  Policies:
                      <<: *SampleOrgPolicies
                      Admins:
                          Type: Signature
                          Rule: "OR('SampleOrg.member')"
        Application:
            <<: *ApplicationDefaults
            Organizations:
                - <<: *SampleOrg
                  Policies:
                      <<: *SampleOrgPolicies
                      Admins:
                          Type: Signature
                          Rule: "OR('SampleOrg.member')"
        Consortiums:
            SampleConsortium:
                Organizations:
                    - <<: *SampleOrg
                      Policies:
                          <<: *SampleOrgPolicies
                          Admins:
                              Type: Signature
                              Rule: "OR('SampleOrg.member')"
 
    # SampleAppChannelInsecureSolo defines an application channel configuration
    # which uses the Solo orderer and contains no MSP definitions.
    SampleAppChannelInsecureSolo:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
        Application:
            <<: *ApplicationDefaults
 
    # SampleAppChannelEtcdRaft defines an application channel configuration
    # that uses the etcd/raft-based orderer.
    SampleAppChannelEtcdRaft:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
            OrdererType: etcdraft
            Organizations:
                - <<: *SampleOrg
                  Policies:
                      <<: *SampleOrgPolicies
                      Admins:
                          Type: Signature
                          Rule: "OR('SampleOrg.member')"
        Application:
            <<: *ApplicationDefaults
            Organizations:
                - <<: *SampleOrg
                  Policies:
                      <<: *SampleOrgPolicies
                      Admins:
                          Type: Signature
                          Rule: "OR('SampleOrg.member')"
~~~

