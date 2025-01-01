+++
title = "实操：Starknet Dojo 入门之 Dojo 安装、编译、部署和交互"
description = "实操：Starknet Dojo 入门之 Dojo 安装、编译、部署和交互"
date = 2025-01-01 12:48:11+08:00
[taxonomies]
categories = ["Starknet", "Dojo"]
tags = ["Starknet", "Dojo"]
+++

<!-- more -->
# 实操：Starknet Dojo 入门之 Dojo 安装、编译、部署和交互

Dojo 是一个社区驱动的开源项目，旨在为开发者提供构建、部署和管理 Starknet 链上游戏的基础设施。它提供了一套工具和框架，帮助开发者快速构建和部署复杂的链上游戏，同时提供了一套丰富的 API 和组件，帮助开发者实现各种游戏功能。

## 什么是 Dojo

Dojo 是一个社区驱动的开源可证明游戏引擎，为构建可验证游戏和自主世界提供了全面的工具包。

## 全链游戏

链上游戏，包括状态和逻辑，都完全位于公共区块链上，由智能合约定义。

## 可证明的游戏

可证明的游戏是在 zkvms 上设计的，并且可以验证其执行情况，从而实现客户端游戏。

## 自主世界

Dojo 使得在 Starknet 链上构建自主世界的游戏变得非常容易。

## 链游发展史

Dark Forest

- 最初的链上游戏
- 使用 Snarks 隐藏信息
- 开放游戏界面、插件生态系统、新兴 UI
- 催生了整个链上游戏行业

## 全新模式

- 金融化是游戏的一部分 - 不仅仅是NFT
- Chain 是托管人和仲裁者
- 可能出现新的更高效的商业模式
- 可组合性优先游戏
  
## 为什么做链游

- 共享状态，开放API
- 在链上游戏中不可能作弊
- 实现以前不可能的信任和以前不可能的价值转移

## 为什么使用 Dojo

- 标准化构建链上游戏的构建和管理
- 通过模型更轻松的建立链上状态
- 开发人员工具
- 最小化样板代码

## 工具链

- Sozo
- Katana
- Torii
- Origami

## 1. 安装

### 安装 dojo

```bash
# asdf plugin-add dojo
asdf plugin add dojo https://github.com/dojoengine/asdf-dojo
# Install the latest version of Dojo
asdf install dojo latest   
# check installed version
asdf list dojo
```

![dojo-install](/images/dojo_asdf.png)

### 查看当前版本并卸载旧版本

![dojo-install](/images/dojo_asdf02.png)

## 2. 创建项目并用 Cursor 打开项目

```bash
sozo init dojo-starter


 ⛩️ ====== STARTING ====== ⛩️ 

Setting up project directory tree...
warn: Couldn't find template for your current sozo version. Getting the latest version 
            instead.

🎉 Successfully created a new ⛩️ Dojo project!

====== SETUP COMPLETE! ======


To start using your new project, try running: `sozo build`
cd dojo-starter/
cc
```

## 3. Build Project

```bash
Code/starknet-code/dojo-starter via 🅒 base 
➜ sozo build            
    Updating git repository https://github.com/dojoengine/dojo
   Compiling dojo_starter v1.0.9 (/Users/qiaopengjun/Code/starknet-code/dojo-starter/Scarb.toml)
    Finished `dev` profile target(s) in 25 seconds
```

## 4. katana 本地运行

```bash
Code/starknet-code/dojo-starter via 🅒 base 
➜ katana --version

katana 1.0.9 (04b5f02)

Code/starknet-code/dojo-starter via 🅒 base 
➜ katana --dev --dev.no-fee                         



██╗  ██╗ █████╗ ████████╗ █████╗ ███╗   ██╗ █████╗
██║ ██╔╝██╔══██╗╚══██╔══╝██╔══██╗████╗  ██║██╔══██╗
█████╔╝ ███████║   ██║   ███████║██╔██╗ ██║███████║
██╔═██╗ ██╔══██║   ██║   ██╔══██║██║╚██╗██║██╔══██║
██║  ██╗██║  ██║   ██║   ██║  ██║██║ ╚████║██║  ██║
╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝


PREDEPLOYED CONTRACTS
==================

| Contract        | ETH Fee Token
| Address         | 0x49d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7
| Class Hash      | 0x00a2475bc66197c751d854ea8c39c6ad9781eb284103bcd856b58e6b500078ac

| Contract        | STRK Fee Token
| Address         | 0x4718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d
| Class Hash      | 0x00a2475bc66197c751d854ea8c39c6ad9781eb284103bcd856b58e6b500078ac

| Contract        | Universal Deployer
| Address         | 0x41a78e741e5af2fec34b695679bc6891742439f7afb8484ecd7766661ad02bf
| Class Hash      | 0x07b3e05f48f0c69e4a65ce5e076a66271a527aff2c34ce1083ec6e1526997a69

| Contract        | Account Contract
| Class Hash      | 0x07dc7899aa655b0aae51eadff6d801a58e97dd99cf4666ee59e704249e51adf2


PREFUNDED ACCOUNTS
==================

| Account address |  0x127fd5f1fe78a71f8bcd1fec63e3fe2f0486b6ecd5c86a0466c3a21fa5cfcec
| Private key     |  0xc5b2fcab997346f3ea1c00b002ecf6f382c5f9c9659a3894eb783c5320f912
| Public key      |  0x33246ce85ebdc292e6a5c5b4dd51fab2757be34b8ffda847ca6925edf31cb67

| Account address |  0x13d9ee239f33fea4f8785b9e3870ade909e20a9599ae7cd62c1c292b73af1b7
| Private key     |  0x1c9053c053edf324aec366a34c6901b1095b07af69495bffec7d7fe21effb1b
| Public key      |  0x4c339f18b9d1b95b64a6d378abd1480b2e0d5d5bd33cd0828cbce4d65c27284

| Account address |  0x17cc6ca902ed4e8baa8463a7009ff18cc294fa85a94b4ce6ac30a9ebd6057c7
| Private key     |  0x14d6672dcb4b77ca36a887e9a11cd9d637d5012468175829e9c6e770c61642
| Public key      |  0x16e375df37a7653038bd9eccd767e780c2c4d4c66b4c85f455236a3fd75673a

| Account address |  0x2af9427c5a277474c079a1283c880ee8a6f0f8fbf73ce969c08d88befec1bba
| Private key     |  0x1800000000300000180000000000030000000000003006001800006600
| Public key      |  0x2b191c2f3ecf685a91af7cf72a43e7b90e2e41220175de5c4f7498981b10053

| Account address |  0x359b9068eadcaaa449c08b79a367c6fdfba9448c29e96934e3552dab0fdd950
| Private key     |  0x2bbf4f9fd0bbb2e60b0316c1fe0b76cf7a4d0198bd493ced9b8df2a3a24d68a
| Public key      |  0x640466ebd2ce505209d3e5c4494b4276ed8f1cde764d757eb48831961f7cdea

| Account address |  0x4184158a64a82eb982ff702e4041a49db16fa3a18229aac4ce88c832baf56e4
| Private key     |  0x6bf3604bcb41fed6c42bcca5436eeb65083a982ff65db0dc123f65358008b51
| Public key      |  0x4b076e402835913e3f6812ed28cef8b757d4643ebf2714471a387cb10f22be3

| Account address |  0x42b249d1633812d903f303d640a4261f58fead5aa24925a9efc1dd9d76fb555
| Private key     |  0x283d1e73776cd4ac1ac5f0b879f561bded25eceb2cc589c674af0cec41df441
| Public key      |  0x73c8a29ba0e6a368422d0551b3f45a30a27166b809ba07a41a1bc434b000ba7

| Account address |  0x4e0b838810cb1a355beb7b3d894ca0e98ee524309c3f8b7cccb15a48e6270e2
| Private key     |  0x736adbbcdac7cc600f89051db1abbc16b9996b46f6b58a9752a11c1028a8ec8
| Public key      |  0x570258e7277eb345ab80803c1dc5847591efd028916fc826bc7cd47ccd8f20d

| Account address |  0x5b6b8189bb580f0df1e6d6bec509ff0d6c9be7365d10627e0cf222ec1b47a71
| Private key     |  0x33003003001800009900180300d206308b0070db00121318d17b5e6262150b
| Public key      |  0x4c0f884b8e5b4f00d97a3aad26b2e5de0c0c76a555060c837da2e287403c01d

| Account address |  0x6677fe62ee39c7b07401f754138502bab7fac99d2d3c5d37df7d1c6fab10819
| Private key     |  0x3e3979c1ed728490308054fe357a9f49cf67f80f9721f44cc57235129e090f4
| Public key      |  0x1e8965b7d0b20b91a62fe515dd991dc9fcb748acddf6b2cf18cec3bdd0f9f9a


ACCOUNTS SEED
=============
0
    
2025-01-01T04:43:43.417844Z  INFO katana_node: Starting node. chain=0x4b4154414e41
2025-01-01T04:43:43.418179Z  INFO rpc: RPC server started. addr=127.0.0.1:5050
2025-01-01T05:51:43.829197Z DEBUG server: method="starknet_getBlockWithTxHashes"
2025-01-01T05:51:43.843903Z DEBUG server: method="starknet_chainId"
2025-01-01T05:51:47.045115Z DEBUG server: method="starknet_getBlockWithTxHashes"
2025-01-01T05:51:47.045518Z DEBUG server: method="starknet_specVersion"
2025-01-01T05:51:47.045760Z DEBUG server: method="starknet_chainId"
2025-01-01T05:51:47.045975Z DEBUG server: method="starknet_getClassHashAt"
2025-01-01T05:51:47.376701Z DEBUG server: method="starknet_chainId"
2025-01-01T05:51:47.377285Z DEBUG server: method="starknet_getClassHashAt"
2025-01-01T05:51:47.975383Z DEBUG server: method="starknet_getClass"
2025-01-01T05:51:47.976854Z DEBUG server: method="starknet_getNonce"
2025-01-01T05:51:48.063896Z DEBUG server: method="starknet_estimateFee"
2025-01-01T05:51:48.652324Z DEBUG server: method="starknet_addDeclareTransaction"
2025-01-01T05:51:48.752908Z  INFO pool: Transaction received. hash="0x29b190ab72220560f53e82e9b78d5f5720c0bf5ad62bb5a73997adc2fcb14aa"
2025-01-01T05:51:49.514750Z TRACE executor: Transaction resource usage. usage="steps: 3387 | memory holes: 32 | ec_op_builtin: 3 | pedersen_builtin: 16 | range_check_builtin: 65"
2025-01-01T05:51:49.893860Z  INFO katana::core::backend: Block mined. block_number=1 tx_count=1
2025-01-01T05:51:51.632321Z DEBUG server: method="starknet_getTransactionStatus"
2025-01-01T05:51:51.633337Z DEBUG server: method="starknet_getTransactionReceipt"
2025-01-01T05:51:51.635310Z DEBUG server: method="starknet_getClassHashAt"
2025-01-01T05:51:51.635892Z DEBUG server: method="starknet_getNonce"
2025-01-01T05:51:51.636646Z DEBUG server: method="starknet_estimateFee"
2025-01-01T05:51:51.660177Z DEBUG server: method="starknet_addInvokeTransaction"
2025-01-01T05:51:51.660336Z  INFO pool: Transaction received. hash="0x718cf01e9cb909a75e71057b001839a3fa300faf6127bb6e78345d9e8b872d"
2025-01-01T05:51:51.682489Z TRACE executor: Transaction resource usage. usage="steps: 8924 | memory holes: 56 | ec_op_builtin: 3 | pedersen_builtin: 37 | poseidon_builtin: 7 | range_check_builtin: 200"
2025-01-01T05:51:51.684674Z  INFO katana::core::backend: Block mined. block_number=2 tx_count=1
2025-01-01T05:51:54.164907Z DEBUG server: method="starknet_getTransactionStatus"
2025-01-01T05:51:54.165787Z DEBUG server: method="starknet_getTransactionReceipt"
2025-01-01T05:51:54.428801Z DEBUG server: method="dev_predeployedAccounts"
2025-01-01T05:51:54.429350Z DEBUG server: method="starknet_chainId"
2025-01-01T05:51:54.960783Z DEBUG server: method="starknet_getClass"
2025-01-01T05:51:54.960839Z DEBUG server: method="starknet_getClass"
2025-01-01T05:51:54.960939Z DEBUG server: method="starknet_getClass"
2025-01-01T05:51:54.960966Z DEBUG server: method="starknet_getClass"
2025-01-01T05:51:54.960985Z DEBUG server: method="starknet_getClass"
2025-01-01T05:51:54.961344Z DEBUG server: method="starknet_getNonce"
2025-01-01T05:51:54.961370Z DEBUG server: method="starknet_getNonce"
2025-01-01T05:51:54.961411Z DEBUG server: method="starknet_getNonce"
2025-01-01T05:51:54.961429Z DEBUG server: method="starknet_getNonce"
2025-01-01T05:51:54.961443Z DEBUG server: method="starknet_getNonce"
2025-01-01T05:51:54.967989Z DEBUG server: method="starknet_estimateFee"
2025-01-01T05:51:54.973595Z DEBUG server: method="starknet_estimateFee"
2025-01-01T05:51:54.978649Z DEBUG server: method="starknet_estimateFee"
2025-01-01T05:51:54.983303Z DEBUG server: method="starknet_estimateFee"
2025-01-01T05:51:54.997847Z DEBUG server: method="starknet_estimateFee"
2025-01-01T05:51:55.007605Z DEBUG server: method="starknet_addDeclareTransaction"
2025-01-01T05:51:55.013196Z DEBUG server: method="starknet_addDeclareTransaction"
2025-01-01T05:51:55.014823Z  INFO pool: Transaction received. hash="0x3496ed8396568366ba1e09e387f6a0fb8816d1878ff7e54377394d54de7a54c"
```

## 5. migrate 部署游戏

### 报错

```bash
Code/starknet-code/dojo-starter via 🅒 base 
➜ sozo migrate
2025-01-01T05:47:47.173185Z ERROR Subcommand{name="Migrate"}: sozo::cli: Provider health check failed during sozo migrate.
error: Unhealthy provider JsonRpcClient { transport: HttpTransport { client: Client { accepts: Accepts { gzip: true, brotli: true, deflate: true }, proxies: [Proxy(System({"http": http://127.0.0.1:33210, "https": http://127.0.0.1:33210}), None)], referer: true, default_headers: {"accept": "*/*"}, timeout: 30s }, url: Url { scheme: "http", cannot_be_a_base: false, username: "", password: None, host: Some(Domain("localhost")), port: Some(5050), path: "/", query: None, fragment: None }, headers: [] } }, please check your configuration.

```

### 解决

关闭客户端与命令行代理

```bash
Code/starknet-code/dojo-starter via 🅒 base took 3.5s 
➜ unset https_proxy                  
unset http_proxy

```

### 成功执行

```bash
Code/starknet-code/dojo-starter via 🅒 base took 3.5s 
➜ sozo migrate

 profile | chain_id | rpc_url                
---------+----------+------------------------
 dev     | KATANA   | http://localhost:5050/ 

                                 
🌍 World deployed at block 2 with txn hash: 0x00718cf01e9cb909a75e71057b001839a3fa300faf6127bb6e78345d9e8b872d
🗡️  Initializing 1 contracts...                  
IPFS credentials not found. Metadata upload skipped. To upload metadata, configure IPFS credentials in your profile config or environment variables: https://book.dojoengine.org/framework/world/metadata.
⛩️  Migration successful with world at address 0x0525177c8afe8680d7ad1da30ca183e482cfcd6404c1e09d83fd3fa2994fd4b8

```

## 6. 修改 world_address

dojo_dev.toml

```toml
world_address = "0x0525177c8afe8680d7ad1da30ca183e482cfcd6404c1e09d83fd3fa2994fd4b8"

```

## 7. 运行 Torii 索引器

```bash
Code/starknet-code/dojo-starter via 🅒 base 
➜ torii --world 0x0525177c8afe8680d7ad1da30ca183e482cfcd6404c1e09d83fd3fa2994fd4b8
2025-01-01T06:17:33.769805Z  INFO torii::relay::server: Relay peer id. peer_id=12D3KooWPu983NMc4J8jiRLxNNEcdodE8GSn65ckJ5MDvUNvspb1
2025-01-01T06:17:33.779795Z  INFO libp2p_swarm: local_peer_id=12D3KooWPu983NMc4J8jiRLxNNEcdodE8GSn65ckJ5MDvUNvspb1
2025-01-01T06:17:33.783130Z  INFO torii::cli: Starting torii endpoint. endpoint=127.0.0.1:8080
2025-01-01T06:17:33.783147Z  INFO torii::cli: Serving Graphql playground. endpoint=127.0.0.1:8080/graphql
2025-01-01T06:17:33.783150Z  INFO torii::cli: Serving World Explorer. url=https://worlds.dev/torii?url=127.0.0.1%3A8080%2Fgraphql
2025-01-01T06:17:33.783152Z  INFO torii::cli: Serving ERC artifacts at path path=/var/folders/6y/p7tl9yfj1p3cq9hv5z1fpfqh0000gn/T/.tmphAkzH2
2025-01-01T06:17:33.783865Z  INFO torii::relay::server: New listen address. address=/ip4/127.0.0.1/tcp/9090
2025-01-01T06:17:33.783945Z  INFO torii::relay::server: New listen address. address=/ip4/192.168.101.130/tcp/9090
2025-01-01T06:17:33.784000Z  INFO torii::relay::server: New listen address. address=/ip4/127.0.0.1/udp/9090/quic-v1
2025-01-01T06:17:33.784032Z  INFO torii::relay::server: New listen address. address=/ip4/192.168.101.130/udp/9090/quic-v1
2025-01-01T06:17:33.784681Z  INFO torii::relay::server: New listen address. address=/ip4/127.0.0.1/udp/9091/webrtc-direct/certhash/uEiBytYTBO8iWyiAJGgU0pHeQw7ECfH-udD9w4IgEJ9Kp4w
2025-01-01T06:17:33.784722Z  INFO torii::relay::server: New listen address. address=/ip4/192.168.101.130/udp/9091/webrtc-direct/certhash/uEiBytYTBO8iWyiAJGgU0pHeQw7ECfH-udD9w4IgEJ9Kp4w
2025-01-01T06:17:33.784801Z  INFO torii::relay::server: New listen address. address=/ip4/127.0.0.1/tcp/9092/ws
2025-01-01T06:17:33.784813Z  INFO torii::relay::server: New listen address. address=/ip4/192.168.101.130/tcp/9092/ws
2025-01-01T06:17:33.817216Z  INFO torii_core::engine: Processed block. block_number=2
2025-01-01T06:17:33.856743Z  INFO torii_core::processors::register_model: Registered model. namespace=dojo_starter name=Moves
2025-01-01T06:17:33.876042Z  INFO torii_core::processors::register_event: Registered event. namespace=dojo_starter name=Moved
2025-01-01T06:17:33.895447Z  INFO torii_core::processors::register_model: Registered model. namespace=dojo_starter name=Position
2025-01-01T06:17:33.915862Z  INFO torii_core::processors::register_model: Registered model. namespace=dojo_starter name=DirectionsAvailable
2025-01-01T06:17:33.915948Z  INFO torii_core::engine: Processed block. block_number=6
2025-01-01T06:17:33.915956Z  INFO torii_core::engine: Processed block. block_number=7
2025-01-01T06:17:33.915960Z  INFO torii_core::engine: Processed block. block_number=8

```

## 8. 请求 127.0.0.1:8080/graphql 查看

### DojoStarterMovesModels

```graphql
query DojoStarterMovesModels {
  dojoStarterMovesModels {
    totalCount
    edges {
      node {
        player
        remaining
        last_direction
        can_move
      }
    }
  }
}
```

![DojoStarterMovesModels](/images/dojo_graphql_models.png)

### DojoStarterPositionModels

```graphql
query DojoStarterPositionModels {
  dojoStarterPositionModels {
    totalCount
    edges {
      node {
        player
        vec {
          x
          y
        }
      }
    }
  }
}
```

![DojoStarterPositionModels](/images/dojo_graphql_positions.png)

## 9. 执行 spawn 方法

```bash
Code/starknet-code/dojo-starter via 🅒 base took 24.5s 
➜ sozo execute dojo_starter-actions spawn
Transaction hash: 0x07525e3d017399b4ed14a71cd710b510a0ebce22a78688f6b95abcc2c75c7aa1

```

### graphql 查看

#### DojoStarterPositionModels 查看

![DojoStarterPositionModels](/images/dojo_spawn_pos.png)

#### DojoStarterMovesModels 查看

![DojoStarterModels](/images/dojo_spawn_modules.png)

## 10. 再次执行 spawn 方法

```bash
Code/starknet-code/dojo-starter via 🅒 base 
➜ sozo execute dojo_starter-actions spawn
Transaction hash: 0x0424f539c3b84e22a612a59c3bfbdebffc76322c634b36a76fbf356a6a435518

```

### 第二次执行 spawn 方法后 graphql 查看

#### 执行 spawn 方法后 DojoStarterPositionModels 查看

![DojoStarterPositionModels](/images/dojo_spawn_pos2.png)
注意：此时可以看到 x、y 由 10 变为 20

## 11. 执行 Move 方法

```bash
Code/starknet-code/dojo-starter via 🅒 base 
➜ sozo execute dojo_starter-actions move -c 0
Transaction hash: 0x03581ca2445eca52223d4710b3e6b95deb6dcd7fe705d49200eec3db49af330a

```

### 执行 move 方法后 DojoStarterMovesModels 查看可知100 变为 99

![DojoStarterPositionModels](/images/dojo_move_models.png)

## 12. 再次执行 Move 方法

```bash
Code/starknet-code/dojo-starter via 🅒 base 
➜ sozo execute dojo_starter-actions move -c 1
Transaction hash: 0x033499b65f90bd88df5df59af256a276c58e67b28a7a1d595c0175afb4dc6065

```

### 执行 move 方法后 DojoStarterPositionModels 查看可知 x 减 1 变为 19

![DojoStarterPositionModels](/images/dojo_move_pos.png)

### 执行 move 方法后 DojoStarterMovesModels 查看可知 remaining 由 99 变为 98，last_direction 变为 Left

![DojoStarterPositionModels](/images/dojo_move_models2.png)

## 13. 测试

```bash
Code/starknet-code/dojo-starter via 🅒 base took 3.6s 
➜ sozo test                                  
testing test(dojo_starter_unittest) dojo_starter v1.0.9 (/Users/qiaopengjun/Code/starknet-code/dojo-starter/Scarb.toml)
running 4 tests
test dojo_starter::models::tests::test_vec_is_equal ... ok (gas usage est.: 1300)
test dojo_starter::models::tests::test_vec_is_zero ... ok (gas usage est.: 1000)
test dojo_starter::tests::test_world::tests::test_world_test_set ... ok (gas usage est.: 12532285)
test dojo_starter::tests::test_world::tests::test_move ... ok (gas usage est.: 22057502)
test result: ok. 4 passed; 0 failed; 0 ignored; 0 filtered out;

```

## 14. 增加测试用例并运行测试

### test_world.cairo 添加测试

```rust
 #[test]
    fn test_spawn() {
        let caller = starknet::contract_address_const::<0x0>();
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"actions").unwrap();
        let actions_system = IActionsDispatcher {contract_address};

        actions_system.spawn();

        let moves: Moves = world.read_model(caller);
        assert(moves.remaining == 100, 'initial moves wrong');
        assert(moves.last_direction == Direction::None, 'initial direction wrong');

        let position: Position = world.read_model(caller);
        assert(position.vec.x == 10 && position.vec.y == 10, 'initial position wrong');

        actions_system.spawn();
        let position: Position = world.read_model(caller);
        assert(position.vec.x == 20 && position.vec.y == 20, 'x y coordinate not updated');
    }
```

### 执行测试用例

```bash
Code/starknet-code/dojo-starter via 🅒 base 
➜ sozo test                                  
testing test(dojo_starter_unittest) dojo_starter v1.0.9 (/Users/qiaopengjun/Code/starknet-code/dojo-starter/Scarb.toml)
running 5 tests
test dojo_starter::models::tests::test_vec_is_zero ... ok (gas usage est.: 1000)
test dojo_starter::models::tests::test_vec_is_equal ... ok (gas usage est.: 1300)
test dojo_starter::tests::test_world::tests::test_world_test_set ... ok (gas usage est.: 12532285)
test dojo_starter::tests::test_world::tests::test_spawn ... ok (gas usage est.: 18893689)
test dojo_starter::tests::test_world::tests::test_move ... ok (gas usage est.: 22057502)
test result: ok. 5 passed; 0 failed; 0 ignored; 0 filtered out;

```

建议：面向测试开发并编写测试用例来保证 Dojo 合约的正确性。

## 知识点

- 在 Dojo 项目中，使用哪个装饰器来定义模型？ #[dojo::model]
- 如何初始化一个新的 Dojo 项目? sozo init
- 哪个命令用于构建和迁移你的 Dojo 合约？ sozo build && sozo migrate
- 在 Dojo 的系统实现中，使用什么属性来标记合约实现？ #[dojo::contract]
- 在 Dojo 中如何定义事件？ #[dojo::event]
- 在 Dojo 系统中，正确读取模型的方法是什么 world.read_model()
- 在 Dojo 的模型定义中，使用什么属性来标记键字段？  #[key]
- 哪个命令用于启动本地 Katana 开发网络？ katana --dev
- 在 Dojo 项目中如何指定依赖？ 在 Scarb.toml 中
- 在 Dojo 中，如何正确地向世界状态写入新的模型数据？ world.write_model(@new_data)

## 源码参考

- <https://github.com/qiaopengjun5162/hello_starknet/tree/main/dojo-starter>

## 参考

- <https://github.com/dojoengine/asdf-dojo>
- <https://www.dojoengine.org/>
- <https://www.starknet.io/blog/dojo-on-starknet/>
- <https://www.starknet.io/blog/dojo-1-0-and-starknet-gaming/>
