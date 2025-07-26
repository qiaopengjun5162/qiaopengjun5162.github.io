+++
title = "Web3 金融区块链 Injective：从核心原理到命令行实战指南"
description = "本文深度剖析专为Web3金融打造的Layer-1区块链Injective。内容涵盖其核心技术、INJ代币经济及生态系统。并通过详细的injectived命令行实操指南，从创建钱包、发送交易到设置和使用多签钱包，带领读者全面掌握Injective的核心原理与链上交互实践。"
date = 2025-07-26T06:24:35Z
[taxonomies]
categories = ["Web3", "区块链", "Injective"]
tags = ["Web3", "区块链", "Injective"]
+++

<!-- more -->

# **Web3 金融区块链 Injective：从核心原理到命令行实战指南**

Injective 作为一个专为金融领域构建的 Web3 区块链，凭借其高性能、低成本和独特的链上订单簿基础设施，在去中心化金融世界中占据了重要地位。理解其核心技术和经济模型是进入其生态的第一步，但真正的掌握源于实践。本文旨在提供一个全面的 Injective 指南，不仅深入剖析其从底层技术到生态发展的核心概念，还将通过`injectived`命令行工具，手把手地带领读者完成从环境配置、钱包创建、代币交易到设置企业级多签钱包的全流程实战操作，帮助您从理论和实践两个维度彻底驾驭 Injective。

**Injective (INJ)** 是一个专为 Web3 金融应用量身打造的高速、可互操作的第一层（Layer-1）区块链。它致力于通过提供先进的去中心化金融（DeFi）基础设施，打破传统金融壁垒，构建一个更公平、更自由的金融新范式。

Injective 由斯坦福大学校友 Eric Chen 和 Albert Chon 于 2018 年创立，并获得了币安（Binance）、Pantera Capital 和知名投资人马克·库班（Mark Cuban）等众多顶级机构和个人的投资。

### **核心技术与优势**

Injective 建立在 Cosmos SDK 之上，并采用基于 Tendermint 的权益证明（Proof-of-Stake, PoS）共识机制。其独特的技术架构赋予了它多项核心优势：

- **高速与低成本：** Injective 拥有极高的交易处理速度（TPS 可达 25,000 以上）和即时交易最终性，同时交易费用（Gas Fee）极低甚至为零，为高频交易和复杂金融应用提供了可能。
- **高度互操作性：** 通过 Cosmos 的跨链通信协议（IBC），Injective 可以与 Cosmos 生态内的其他区块链无缝交互。同时，它通过内置的跨链桥（如与以太坊的 Gravity Bridge），实现了与以太坊、Solana 等主流公链的资产和数据互通。
- **抗抢先交易（Front-running）机制：** Injective 采用了创新的“频繁批量拍卖”（Frequent Batch Auction, FBA）模式来处理订单，有效杜绝了困扰许多去中心化交易所的抢先交易问题，保证了交易的公平性。
- **专为金融优化的基础设施：** Injective 在链上集成了去中心化的订单簿，这与大多数采用自动做市商（AMM）模型的去中心化交易所（DEX）不同。链上订单簿使其能够支持更复杂的金融产品，如现货、永续合约、期货和期权等衍生品交易。
- **开发者友好：** Injective 支持以太坊虚拟机（EVM）和 CosmWasm，这意味着开发者可以轻松地将以太坊等其他链上的智能合约和 dApp 迁移至 Injective，并使用熟悉的开发工具和语言进行构建。

### **INJ 代币：生态系统的核心**

INJ 是 Injective 生态系统的原生功能型代币，扮演着至关重要的角色：

- **治理：** INJ 持有者可以参与协议的去中心化治理，对网络升级、新功能提案等进行投票。
- **权益证明（PoS）安全：** 用户可以通过质押（Staking）INJ 代币来保护网络安全，并获得相应的质押奖励。
- **交易手续费：** Injective 生态内的应用和服务，其交易费用需要使用 INJ 支付。
- **通缩机制：** Injective 拥有一项独特的通缩机制。协议每周会将其从 dApp 中获得的部分手续费进行拍卖，用于回购并销毁 INJ 代币，从而减少了 INJ 的总供应量。
- **衍生品抵押：** 在 Injective 的衍生品市场中，INJ 可以作为抵押品和保证金。

### **蓬勃发展的生态系统**

Injective 的生态系统正在快速扩张，吸引了众多开发者和项目在其上构建应用。其生态版图涵盖了 DeFi、NFT、游戏金融（GameFi）和现实世界资产（RWA）等多个领域。

主要生态项目包括：

- **Helix：** Injective 官方推出的旗舰级去中心化衍生品交易所，提供现货和永续合约交易。
- **Hydro Protocol：** Injective 上的主流流动性质押协议，用户可以质押 INJ 获得流动性代币 hINJ。
- **Mito：** 一个集启动平台（Launchpad）和自动化做市商（AMM）金库于一体的协议。
- **DojoSwap：** Injective 生态系统中的第一个原生自动做市商（AMM）去中心化交易所。

随着“Volan”等重大主网升级的推出，Injective 正不断提升其网络性能、互操作性和对现实世界资产（RWA）的支持，致力于成为 Web3 世界中不可或缺的金融基础设施层。

## 实操

### 安装 **injectived**

**injectived** - Injective 区块链进行直接交互的 CLI 工具

```bash
mcd Injective

git clone git@github.com:InjectiveFoundation/injective-core.git

cd injective-core

make install
```

### 查看是否安装成功

```bash
injectived version
Version v1.16.0 (daf90f4)
Compiled at 20250725-0726 using Go go1.24.5 (arm64)
```

### 查看帮助信息

```bash
injectived -h
Injective Daemon

Usage:
  injectived [command]

Available Commands:
  add-genesis-account Add a genesis account to genesis.json
  bootstrap-devnet    Bootstrap Devnet state from existing state. To invoke this on new binary version, provide --trigger-devnet-upgrade flag. Custom overrides are provided via --custom-overrides in YAML format.
  comet               CometBFT subcommands
  completion          Generate the autocompletion script for the specified shell
  config              Utilities for managing application configuration
  debug               Tool for helping with debugging your application
  export              Export state to JSON
  genesis             Application's genesis-related subcommands
  help                Help about any command
  init                Initialize private validator, p2p, genesis, and application configuration files
  keys                Manage your application's keys
  prune               Prune app history states by keeping the recent heights and deleting old heights
  query               Querying subcommands
  rollback            rollback Cosmos SDK and CometBFT state by one height
  snapshots           Manage local snapshots
  start               Run the full node
  status              Query remote node for status
  tx                  Transactions subcommands
  version             Print the application binary version information

Flags:
  -h, --help                help for injectived
      --home string         directory for config and data (default "/Users/qiaopengjun/.injectived")
      --log-color           Enable log output coloring (default true)
      --log-format string   The logging format (json|plain) (default "plain")
      --log-level string    The logging level (trace|debug|info|warn|error|fatal|panic) (default "info")
      --trace               print out full stack trace on errors

Use "injectived [command] --help" for more information about a command.
```

### **网络连接设置**

**https://docs.injective.network/developers/network-information**

#### 测试网节点

```bash
injectived config set client node https://testnet.sentry.tm.injective.network:443
injectived config set client chain-id injective-888

```

### 查看配置信息

```bash
injectived config get client node
"https://testnet.sentry.tm.injective.network:443"

injectived config get client chain-id
"injective-888"
```

### 创建钱包

```bash
injectived keys add mykey
Enter keyring passphrase (attempt 1/3):
password must be at least 8 characters
Enter keyring passphrase (attempt 2/3):
password must be at least 8 characters
Enter keyring passphrase (attempt 3/3):
Re-enter keyring passphrase:

- address: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
  name: mykey
  pubkey: '{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"Ao5ZUWUYYbMqmJbhIRBJwLtlCUsxTWiAsRAudvhMZ+4b"}'
  type: local


**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

worry maximum security reduce train detail observe chase swift rubber comfort toast meat phone mercy pair upper ginger coyote siege modify spider infant cluster

```

这个交互过程是在 Injective 区块链上使用 `injectived` 命令行工具创建一个新的加密钱包密钥对。让我逐步解释：

1. **命令**：`injectived keys add mykey`
   - 这是创建一个名为 "mykey" 的新密钥对
   - `injectived` 是 Injective 区块链的节点软件
2. **密码设置过程**：
   - 系统要求输入密码（共 3 次尝试机会）
   - 密码必须至少 8 个字符
   - 第三次尝试时成功设置了密码并确认
3. **生成的密钥信息**：
   - **地址**：`inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j` (Injective 区块链地址)
   - **名称**：mykey
   - **公钥**：以特定格式显示的加密公钥
   - **类型**：local (本地存储的密钥)
4. **重要助记词**：
   - 系统生成了 24 个单词的助记短语
   - 这是恢复账户的唯一方式，必须安全保管
   - 显示的助记词是：`worry worry worry reduce worry worry worry chase worry rubber worry toast worry worry worry worry upper worry worry worry worry spider worry worry`

**安全注意事项**：

1. 助记词等同于账户控制权，任何人获取这些词都能控制账户
2. 建议将助记词写在纸上并存放在安全的地方
3. 切勿将助记词存储在联网设备或发送给他人
4. 此密钥将存储在本地，使用您设置的密码加密

这个密钥可以用于与 Injective 区块链交互，如发送交易、质押代币等操作。

### 查看所有钱包

接下来，我们可以使用 `injectived keys list` 命令来列出所有本地存储的钱包。执行后，输出会显示每个钱包的名称、地址和公钥等信息...

```bash
injectived keys list
Enter keyring passphrase (attempt 1/3):
- address: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
  name: mykey
  pubkey: '{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"Ao5ZUWUYYbMqmJbhIRBJwLtlCUsxTWiAsRAudvhMZ+4b"}'
  type: local

```

从你的输出来看，目前只有一个名为 **`mykey`** 的密钥对。

- **`address`**: `inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j`
  - 这是你的 Injective 区块链地址，用于接收和发送代币（如 INJ）。
- **`name`**: `mykey`
  - 这是你创建密钥对时指定的名称，方便后续使用（如签名交易时引用）。
- **`pubkey`**:
  - 这是你的公钥，采用 `ethsecp256k1` 椭圆曲线加密（与以太坊相同）。
  - 格式：`{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"Ao5ZUWUYYbMqmJbhIRBJwLtlCUsxTWiAsRAudvhMZ+4b"}`
  - 其中 `key` 是 Base64 编码的公钥。
- **`type`**: `local`
  - 表示密钥存储在本地文件系统中（默认路径通常是 `~/.injectived/keyring-file/`）。

### 查询余额

```bash
injectived query bank balances inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
balances: []
pagination: {}
```

### 领水

https://testnet.faucet.injective.network/

```bash
injectived query bank balances inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
balances:
- amount: "1000000000000000000"
  denom: inj
- amount: "10000000"
  denom: peggy0x87aB3B4C8661e07D6372361211B96ed4Dc36B1B5
pagination:
  total: "2"
```

### 添加网络

https://chainlist.org/?search=injective&testnets=true

https://docs.injective.network/developers/network-information

### 创建 alice 钱包

```bash
injectived keys add alice --home ~/.injective
Enter keyring passphrase (attempt 1/3):
Re-enter keyring passphrase:

- address: inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj
  name: alice
  pubkey: '{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"A7/xUnEV1+8OcU6ymzs82Q/6T9wd++l7KXyOAQqxbrx1"}'
  type: local


**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

dinner dinner dinner dinner dinner phdinnerysical range dinner dinner dinner dinner dinner dinner dinner dinner dinner dinner dinner dinner elbow pair dinner gym dinner

```

### 查看本地安装钱包列表

```bash
injectived keys list
Enter keyring passphrase (attempt 1/3):
- address: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
  name: mykey
  pubkey: '{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"Ao5ZUWUYYbMqmJbhIRBJwLtlCUsxTWiAsRAudvhMZ+4b"}'
  type: local


injectived keys list --home ~/.injective
Enter keyring passphrase (attempt 1/3):
- address: inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj
  name: alice
  pubkey: '{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"A7/xUnEV1+8OcU6ymzs82Q/6T9wd++l7KXyOAQqxbrx1"}'
  type: local

```

### 发送代币

我们来试着在 Injective 测试网上从 **mykey** 向 **Alice** 发送 **1000 inj**。

```bash
injectived tx bank send mykey inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj 1000inj --from mykey --node https://testnet.sentry.tm.injective.network:443 --chain-id injective-888 --gas-prices 500000000inj
Enter keyring passphrase (attempt 1/3):
auth_info:
  fee:
    amount:
    - amount: "100000000000000"
      denom: inj
    gas_limit: "200000"
    granter: ""
    payer: ""
  signer_infos: []
  tip: null
body:
  extension_options: []
  memo: ""
  messages:
  - '@type': /cosmos.bank.v1beta1.MsgSend
    amount:
    - amount: "1000"
      denom: inj
    from_address: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
    to_address: inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj
  non_critical_extension_options: []
  timeout_height: "0"
signatures: []
confirm transaction before signing and broadcasting [y/N]: y
code: 0
codespace: ""
data: ""
events: []
gas_used: "0"
gas_wanted: "0"
height: "0"
info: ""
logs: []
raw_log: ""
timestamp: ""
tx: null
txhash: 262F6E3F84DC22B9C31A6BB63917E9C74AD7DCA49D3A0B0FD20A0DA51979EB0A
```

### **验证交易结果**

当交易完成后，终端会返回一个 txhash。可以用它来查询交易状态：

```bash
injectived query tx 262F6E3F84DC22B9C31A6BB63917E9C74AD7DCA49D3A0B0FD20A0DA51979EB0A
code: 0
codespace: ""
data: 12260A242F636F736D6F732E62616E6B2E763162657461312E4D736753656E64526573706F6E7365
events:
- attributes:
  - index: true
    key: spender
    value: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
  - index: true
    key: amount
    value: 100000000000000inj
  type: coin_spent
- attributes:
  - index: true
    key: receiver
    value: inj17xpfvakm2amg962yls6f84z3kell8c5l6s5ye9
  - index: true
    key: amount
    value: 100000000000000inj
  type: coin_received
- attributes:
  - index: true
    key: recipient
    value: inj17xpfvakm2amg962yls6f84z3kell8c5l6s5ye9
  - index: true
    key: sender
    value: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
  - index: true
    key: amount
    value: 100000000000000inj
  type: transfer
- attributes:
  - index: true
    key: sender
    value: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
  type: message
- attributes:
  - index: true
    key: fee
    value: 100000000000000inj
  - index: true
    key: fee_payer
    value: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
  type: tx
- attributes:
  - index: true
    key: acc_seq
    value: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j/0
  type: tx
- attributes:
  - index: true
    key: signature
    value: FT8IdpNMD7WgTm/DR05qQ3fjnoYEu81h8NG9hhlgpic6crDkzYHqzW/bimutQT3GihvcolN30zmWoxvm/9FrgwA=
  type: tx
- attributes:
  - index: true
    key: action
    value: /cosmos.bank.v1beta1.MsgSend
  - index: true
    key: sender
    value: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
  - index: true
    key: module
    value: bank
  - index: true
    key: msg_index
    value: "0"
  type: message
- attributes:
  - index: true
    key: spender
    value: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
  - index: true
    key: amount
    value: 1000inj
  - index: true
    key: msg_index
    value: "0"
  type: coin_spent
- attributes:
  - index: true
    key: receiver
    value: inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj
  - index: true
    key: amount
    value: 1000inj
  - index: true
    key: msg_index
    value: "0"
  type: coin_received
- attributes:
  - index: true
    key: recipient
    value: inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj
  - index: true
    key: sender
    value: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
  - index: true
    key: amount
    value: 1000inj
  - index: true
    key: msg_index
    value: "0"
  type: transfer
- attributes:
  - index: true
    key: sender
    value: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
  - index: true
    key: msg_index
    value: "0"
  type: message
gas_used: "141580"
gas_wanted: "200000"
height: "85776734"
info: ""
logs: []
raw_log: ""
timestamp: "2025-07-26T02:29:02Z"
tx:
  '@type': /cosmos.tx.v1beta1.Tx
  auth_info:
    fee:
      amount:
      - amount: "100000000000000"
        denom: inj
      gas_limit: "200000"
      granter: ""
      payer: ""
    signer_infos:
    - mode_info:
        single:
          mode: SIGN_MODE_DIRECT
      public_key:
        '@type': /injective.crypto.v1beta1.ethsecp256k1.PubKey
        key: Ao5ZUWUYYbMqmJbhIRBJwLtlCUsxTWiAsRAudvhMZ+4b
      sequence: "0"
    tip: null
  body:
    extension_options: []
    memo: ""
    messages:
    - '@type': /cosmos.bank.v1beta1.MsgSend
      amount:
      - amount: "1000"
        denom: inj
      from_address: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
      to_address: inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj
    non_critical_extension_options: []
    timeout_height: "0"
  signatures:
  - FT8IdpNMD7WgTm/DR05qQ3fjnoYEu81h8NG9hhlgpic6crDkzYHqzW/bimutQT3GihvcolN30zmWoxvm/9FrgwA=
txhash: 262F6E3F84DC22B9C31A6BB63917E9C74AD7DCA49D3A0B0FD20A0DA51979EB0A
```

### 查询 `mykey` 余额

```bash
injectived query bank balances inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
balances:
- amount: "999899999999999000"
  denom: inj
- amount: "10000000"
  denom: peggy0x87aB3B4C8661e07D6372361211B96ed4Dc36B1B5
pagination:
  total: "2"
```

### 查询 `Alice` 余额

```bash
injectived query bank balances inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj
balances:
- amount: "1000"
  denom: inj
pagination:
  total: "1"
```

多签钱包（Multisig Wallet）是需要多个私钥共同签名才能完成交易的钱包，增强安全性和团队资金管理。

## 多签交易流程

### 步骤 1：创建多签成员钱包

#### 添加 `bob` 钱包

```bash
injectived keys add bob
Enter keyring passphrase (attempt 1/3):

- address: inj1mu80tq6xg69xlzf0clxrc0zawpm46azapqwsks
  name: bob
  pubkey: '{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"A4F4zNAfWbXuJzOStCLbjGqDmKKNwutQHI5l4nhEp949"}'
  type: local


**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

come ... ocean # 24 个助记词

```

#### 添加`carol`钱包

```bash
injectived keys add carol
Enter keyring passphrase (attempt 1/3):

- address: inj12yh6ax3hzzsdtea60wwtz5d562qfwxe6uc2kll
  name: carol
  pubkey: '{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"Au18OuGGFpT4ggT9h6FKzJ5GdmyEVdq6vIJV7kTtWfuy"}'
  type: local


**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

analyst ... depend

```

#### 查看钱包列表

```bash
injectived keys list
Enter keyring passphrase (attempt 1/3):
- address: inj1mu80tq6xg69xlzf0clxrc0zawpm46azapqwsks
  name: bob
  pubkey: '{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"A4F4zNAfWbXuJzOStCLbjGqDmKKNwutQHI5l4nhEp949"}'
  type: local
- address: inj12yh6ax3hzzsdtea60wwtz5d562qfwxe6uc2kll
  name: carol
  pubkey: '{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"Au18OuGGFpT4ggT9h6FKzJ5GdmyEVdq6vIJV7kTtWfuy"}'
  type: local
- address: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
  name: mykey
  pubkey: '{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"Ao5ZUWUYYbMqmJbhIRBJwLtlCUsxTWiAsRAudvhMZ+4b"}'
  type: local

```

### 步骤 2：创建多签账户

#### **创建多签密钥**

多签密钥是通过 -multisig 和 -multisig-threshold 参数创建的

创建一个 **2-of-3** 的多签钱包：

```bash
injectived keys add project-safe --multisig carol,bob,mykey --multisig-threshold 2
Enter keyring passphrase (attempt 1/3):

- address: inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d
  name: project-safe
  pubkey: '{"@type":"/cosmos.crypto.multisig.LegacyAminoPubKey","threshold":2,"public_keys":[{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"Au18OuGGFpT4ggT9h6FKzJ5GdmyEVdq6vIJV7kTtWfuy"},{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"Ao5ZUWUYYbMqmJbhIRBJwLtlCUsxTWiAsRAudvhMZ+4b"},{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"A4F4zNAfWbXuJzOStCLbjGqDmKKNwutQHI5l4nhEp949"}]}'
  type: multi

```

### 步骤 3：构建并离线签署交易

#### **构建交易（尚未签名）**

现在 project-safe 钱包要向某个地址发送 **1000inj**。

我们先使用 --generate-only 标志生成未签名交易文件：

```bash
injectived tx bank send project-safe inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj 1000inj --node https://testnet.sentry.tm.injective.network:443 --chain-id injective-888 --gas-prices 500000000inj --generate-only > unsigned_tx.json


injectived tx bank send project-safe inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj 1000inj --node https://testnet.sentry.tm.injective.network:443 --chain-id injective-888 --gas-prices 500000000inj --generate-only > unsigned_tx.json
Enter keyring passphrase (attempt 1/3):
password must be at least 8 characters
Enter keyring passphrase (attempt 2/3):


cat unsigned_tx.json
{"body":{"messages":[{"@type":"/cosmos.bank.v1beta1.MsgSend","from_address":"inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d","to_address":"inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj","amount":[{"denom":"inj","amount":"1000"}]}],"memo":"","timeout_height":"0","extension_options":[],"non_critical_extension_options":[]},"auth_info":{"signer_infos":[],"fee":{"amount":[{"denom":"inj","amount":"100000000000000"}],"gas_limit":"200000","payer":"","granter":""},"tip":null},"signatures":[]}
```

### **检查多签账户余额**

```bash
injectived query bank balances inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d
balances: []
pagination: {}
```

#### 向多签账户转账 10 INJ**发送一笔交易激活**

```bash
injectived tx bank send mykey inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d 10inj --from mykey --node https://testnet.sentry.tm.injective.network:443 --chain-id injective-888 --gas-prices 500000000inj
Enter keyring passphrase (attempt 1/3):
auth_info:
  fee:
    amount:
    - amount: "100000000000000"
      denom: inj
    gas_limit: "200000"
    granter: ""
    payer: ""
  signer_infos: []
  tip: null
body:
  extension_options: []
  memo: ""
  messages:
  - '@type': /cosmos.bank.v1beta1.MsgSend
    amount:
    - amount: "10"
      denom: inj
    from_address: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
    to_address: inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d
  non_critical_extension_options: []
  timeout_height: "0"
signatures: []
confirm transaction before signing and broadcasting [y/N]: y
code: 0
codespace: ""
data: ""
events: []
gas_used: "0"
gas_wanted: "0"
height: "0"
info: ""
logs: []
raw_log: ""
timestamp: ""
tx: null
txhash: E010F009DBB18BE0370C9A46363CFD52C930DE5F31BD0F038C52FD837CCC1F27
```

#### 再次多签账户查询余额

```bash
injectived query bank balances inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d
balances:
- amount: "10"
  denom: inj
pagination:
  total: "1"
```

#### **获取多签账户信息**

离线签名时你需要两项关键信息：

●account_number

●sequence

```bash
injectived query auth account-info inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d
info:
  account_number: "9195664"
  address: inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d
```

多签地址 `inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d` 已经成功激活（因为返回了 `account_number: "9195664"`），但缺少 `sequence` 字段。这是 **正常现象**

#### **为什么多签地址没有 `sequence`？**

1. **`sequence` 的作用**
   - 在 Cosmos SDK（Injective 底层）中，`sequence` 用于防止交易重放攻击（Replay Attack）。
   - 每发送一笔交易，`sequence` 会 +1（类似以太坊的 `nonce`）。
2. **多签地址的 `sequence` 规则**
   - **普通地址**（如 `alice`, `bob`）：每次发起交易后，`sequence` 会自动递增。
   - 多签地址：
     - **`sequence` 不存储在账户信息中**，而是在 **交易签名时动态计算**。
     - 每次多签交易需要手动指定 `sequence`（通过查询最新状态获取）。
3. **为什么查询不到？**
   - `injectived query auth account-info`默认不返回多签地址的`sequence`，因为：
     - 多签交易可能由不同参与者发起，`sequence` 需要在签名时协调一致。
     - 实际使用的 `sequence` 由 **链的最新状态** 决定，需通过其他方式获取。

如果没有发生交易，`sequence` 默认为 0。

**首次交易 `sequence=0`**
如果多签地址从未发起交易，`sequence` 一定从 `0` 开始。

#### **`carol` 进行签名**

**签名本身不需要账户有余额**，因为签名是离线操作。

每位签名者需要按照特定顺序追加签名

`tx multi-sign` 是基于**已签名文件**继续构建的，而不是原始的未签名交易

永远**不要覆盖未签名文件**，签名和合并都应基于上一份已签名版本进行操作

```bash
injectived tx sign unsigned_tx.json \
  --from carol \
  --multisig project-safe \
  --chain-id injective-888 \
  --sign-mode amino-json \
  --offline \
  --account-number 9195664 \
  --sequence 0 \
  > sig_carol.json


injectived tx sign unsigned_tx.json \
  --from carol \                  # 使用 carol 的私钥签名
  --multisig project-safe \       # 目标多签地址
  --chain-id injective-888 \      # 链 ID
  --sign-mode amino-json \        # 签名模式（兼容旧版）
  --offline \                     # 离线签名
  --account-number 9195664 \      # 多签地址的 account-number
  --sequence 0 \                  # 当前 sequence（首次交易用 0）
  > sig_carol.json                # 保存签名结果


## 实操
injectived tx sign unsigned_tx.json \
  --from carol \
  --multisig project-safe \
  --chain-id injective-888 \
  --sign-mode amino-json \
  --offline \
  --account-number 9195664 \
  --sequence 0 \
  > sig_carol.json
Enter keyring passphrase (attempt 1/3):
```

#### **`Bob` 进行签名**

```bash
injectived tx sign unsigned_tx.json \
  --from bob \
  --multisig project-safe \
  --chain-id injective-888 \
  --sign-mode amino-json \
  --offline \
  --account-number 9195664 \
  --sequence 0 \
  > sig_bob.json


## 实操
injectived tx sign unsigned_tx.json \
  --from bob \
  --multisig project-safe \
  --chain-id injective-888 \
  --sign-mode amino-json \
  --offline \
  --account-number 9195664 \
  --sequence 0 \
  > sig_bob.json
Enter keyring passphrase (attempt 1/3):
```

### 步骤 4：合并签名并广播

### **合并签名**

```bash
injectived tx multi-sign unsigned_tx.json project-safe sig_carol.json sig_bob.json --node https://testnet.sentry.tm.injective.network:443 --chain-id injective-888 --skip-signature-verification > tx_signed.json

# 实操
injectived tx multi-sign unsigned_tx.json project-safe sig_carol.json sig_bob.json --node https://testnet.sentry.tm.injective.network:443 --chain-id injective-888 --skip-signature-verification > tx_signed.json
Enter keyring passphrase (attempt 1/3):
```

### **广播交易**

#### 第一次**广播交易**失败

```bash
injectived tx broadcast tx_signed.json \
  --chain-id injective-888 \
  --node https://testnet.sentry.tm.injective.network:443 \
  --broadcast-mode sync \
  --output json | jq
error in json rpc client, with http response metadata: (Status: 200 OK, Protocol HTTP/1.1). RPC error -32603 - Internal error: broadcast error on transaction validation: tx 647CD905025D20AD211D7F46A9B6411A3D52B13CA6AE598D772FA66186C5C621 is invalid: code=5, data=, log='spendable balance 10inj is smaller than 100000000000000inj: insufficient funds: insufficient funds', codespace='sdk'
```

原因：余额不足

#### 查询余额

```bash
injectived query bank balances inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d --output json | jq .balances
[
  {
    "denom": "inj",
    "amount": "10"
  }
]
```

### 转账 1000 INJ

```bash
injectived tx bank send mykey inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d 1000inj --from mykey --node https://testnet.sentry.tm.injective.network:443 --chain-id injective-888 --gas-prices 500000000inj
Enter keyring passphrase (attempt 1/3):
auth_info:
  fee:
    amount:
    - amount: "100000000000000"
      denom: inj
    gas_limit: "200000"
    granter: ""
    payer: ""
  signer_infos: []
  tip: null
body:
  extension_options: []
  memo: ""
  messages:
  - '@type': /cosmos.bank.v1beta1.MsgSend
    amount:
    - amount: "1000"
      denom: inj
    from_address: inj1mnqr8wq5enhnege39kfs2ecpvhl9xfn4h5lg8j
    to_address: inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d
  non_critical_extension_options: []
  timeout_height: "0"
signatures: []
confirm transaction before signing and broadcasting [y/N]: y
code: 0
codespace: ""
data: ""
events: []
gas_used: "0"
gas_wanted: "0"
height: "0"
info: ""
logs: []
raw_log: ""
timestamp: ""
tx: null
txhash: BB138850C657CE3754CAAA862E13FF0AB25363987182D0812B5C57534CF52420
```

### 查询多签余额

```bash
injectived query bank balances inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d --output json | jq .balances
[
  {
    "denom": "inj",
    "amount": "1010"
  }
]

injectived query bank balances inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d --output json | jq .balances
[
  {
    "denom": "inj",
    "amount": "100000000001010"
  }
]
```

#### 转账 100000000000000inj

```bash
injectived tx bank send mykey inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d 100000000000000inj --from mykey --node https://testnet.sentry.tm.injective.network:443 --chain-id injective-888 --gas-prices 500000000inj
```

#### 再次**广播交易**

```bash
injectived tx broadcast tx_signed.json \
  --chain-id injective-888 \
  --node https://testnet.sentry.tm.injective.network:443 \
  --broadcast-mode sync \
  --output json | jq


# 实操
injectived tx broadcast tx_signed.json \
  --chain-id injective-888 \
  --node https://testnet.sentry.tm.injective.network:443 \
  --broadcast-mode sync \
  --output json | jq
{
  "height": "0",
  "txhash": "647CD905025D20AD211D7F46A9B6411A3D52B13CA6AE598D772FA66186C5C621",
  "codespace": "",
  "code": 0,
  "data": "",
  "raw_log": "",
  "logs": [],
  "info": "",
  "gas_wanted": "0",
  "gas_used": "0",
  "tx": null,
  "timestamp": "",
  "events": []
}
```

### **查询交易结果**

```bash
injectived query tx 647CD905025D20AD211D7F46A9B6411A3D52B13CA6AE598D772FA66186C5C621 \
  --node https://testnet.sentry.tm.injective.network:443 \
  --chain-id injective-888 \
  --output json | jq
{
  "height": "85787701",
  "txhash": "647CD905025D20AD211D7F46A9B6411A3D52B13CA6AE598D772FA66186C5C621",
  "codespace": "",
  "code": 0,
  "data": "12260A242F636F736D6F732E62616E6B2E763162657461312E4D736753656E64526573706F6E7365",
  "raw_log": "",
  "logs": [],
  "info": "",
  "gas_wanted": "200000",
  "gas_used": "165526",
  "tx": {
    "@type": "/cosmos.tx.v1beta1.Tx",
    "body": {
      "messages": [
        {
          "@type": "/cosmos.bank.v1beta1.MsgSend",
          "from_address": "inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d",
          "to_address": "inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj",
          "amount": [
            {
              "denom": "inj",
              "amount": "1000"
            }
          ]
        }
      ],
      "memo": "",
      "timeout_height": "0",
      "extension_options": [],
      "non_critical_extension_options": []
    },
    "auth_info": {
      "signer_infos": [
        {
          "public_key": {
            "@type": "/cosmos.crypto.multisig.LegacyAminoPubKey",
            "threshold": 2,
            "public_keys": [
              {
                "@type": "/injective.crypto.v1beta1.ethsecp256k1.PubKey",
                "key": "Au18OuGGFpT4ggT9h6FKzJ5GdmyEVdq6vIJV7kTtWfuy"
              },
              {
                "@type": "/injective.crypto.v1beta1.ethsecp256k1.PubKey",
                "key": "Ao5ZUWUYYbMqmJbhIRBJwLtlCUsxTWiAsRAudvhMZ+4b"
              },
              {
                "@type": "/injective.crypto.v1beta1.ethsecp256k1.PubKey",
                "key": "A4F4zNAfWbXuJzOStCLbjGqDmKKNwutQHI5l4nhEp949"
              }
            ]
          },
          "mode_info": {
            "multi": {
              "bitarray": {
                "extra_bits_stored": 3,
                "elems": "oA=="
              },
              "mode_infos": [
                {
                  "single": {
                    "mode": "SIGN_MODE_LEGACY_AMINO_JSON"
                  }
                },
                {
                  "single": {
                    "mode": "SIGN_MODE_LEGACY_AMINO_JSON"
                  }
                }
              ]
            }
          },
          "sequence": "0"
        }
      ],
      "fee": {
        "amount": [
          {
            "denom": "inj",
            "amount": "100000000000000"
          }
        ],
        "gas_limit": "200000",
        "payer": "",
        "granter": ""
      },
      "tip": null
    },
    "signatures": [
      "CkGS+VLwUADN95O12DARX/wT0z7GpuRZhSFUUcDJUREiCkCpVVfZh3t548qtCBH8Pkmgpiczhek9PUU4Non/9Ev3AApBSMs+f/S1AicuK0yOiYXlSTON2rMQQ3TIRdAqdBWF2Hg9u58NiGezTx4i3uMI03ggc81GXutM5ygoxcQL+gpLtAE="
    ]
  },
  "timestamp": "2025-07-26T04:14:02Z",
  "events": [
    {
      "type": "coin_spent",
      "attributes": [
        {
          "key": "spender",
          "value": "inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d",
          "index": true
        },
        {
          "key": "amount",
          "value": "100000000000000inj",
          "index": true
        }
      ]
    },
    {
      "type": "coin_received",
      "attributes": [
        {
          "key": "receiver",
          "value": "inj17xpfvakm2amg962yls6f84z3kell8c5l6s5ye9",
          "index": true
        },
        {
          "key": "amount",
          "value": "100000000000000inj",
          "index": true
        }
      ]
    },
    {
      "type": "transfer",
      "attributes": [
        {
          "key": "recipient",
          "value": "inj17xpfvakm2amg962yls6f84z3kell8c5l6s5ye9",
          "index": true
        },
        {
          "key": "sender",
          "value": "inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d",
          "index": true
        },
        {
          "key": "amount",
          "value": "100000000000000inj",
          "index": true
        }
      ]
    },
    {
      "type": "message",
      "attributes": [
        {
          "key": "sender",
          "value": "inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d",
          "index": true
        }
      ]
    },
    {
      "type": "tx",
      "attributes": [
        {
          "key": "fee",
          "value": "100000000000000inj",
          "index": true
        },
        {
          "key": "fee_payer",
          "value": "inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d",
          "index": true
        }
      ]
    },
    {
      "type": "tx",
      "attributes": [
        {
          "key": "acc_seq",
          "value": "inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d/0",
          "index": true
        }
      ]
    },
    {
      "type": "tx",
      "attributes": [
        {
          "key": "signature",
          "value": "kvlS8FAAzfeTtdgwEV/8E9M+xqbkWYUhVFHAyVERIgpAqVVX2Yd7eePKrQgR/D5JoKYnM4XpPT1FODaJ//RL9wA=",
          "index": true
        }
      ]
    },
    {
      "type": "tx",
      "attributes": [
        {
          "key": "signature",
          "value": "SMs+f/S1AicuK0yOiYXlSTON2rMQQ3TIRdAqdBWF2Hg9u58NiGezTx4i3uMI03ggc81GXutM5ygoxcQL+gpLtAE=",
          "index": true
        }
      ]
    },
    {
      "type": "tx",
      "attributes": [
        {
          "key": "signature",
          "value": "CkGS+VLwUADN95O12DARX/wT0z7GpuRZhSFUUcDJUREiCkCpVVfZh3t548qtCBH8Pkmgpiczhek9PUU4Non/9Ev3AApBSMs+f/S1AicuK0yOiYXlSTON2rMQQ3TIRdAqdBWF2Hg9u58NiGezTx4i3uMI03ggc81GXutM5ygoxcQL+gpLtAE=",
          "index": true
        }
      ]
    },
    {
      "type": "message",
      "attributes": [
        {
          "key": "action",
          "value": "/cosmos.bank.v1beta1.MsgSend",
          "index": true
        },
        {
          "key": "sender",
          "value": "inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d",
          "index": true
        },
        {
          "key": "module",
          "value": "bank",
          "index": true
        },
        {
          "key": "msg_index",
          "value": "0",
          "index": true
        }
      ]
    },
    {
      "type": "coin_spent",
      "attributes": [
        {
          "key": "spender",
          "value": "inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d",
          "index": true
        },
        {
          "key": "amount",
          "value": "1000inj",
          "index": true
        },
        {
          "key": "msg_index",
          "value": "0",
          "index": true
        }
      ]
    },
    {
      "type": "coin_received",
      "attributes": [
        {
          "key": "receiver",
          "value": "inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj",
          "index": true
        },
        {
          "key": "amount",
          "value": "1000inj",
          "index": true
        },
        {
          "key": "msg_index",
          "value": "0",
          "index": true
        }
      ]
    },
    {
      "type": "transfer",
      "attributes": [
        {
          "key": "recipient",
          "value": "inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj",
          "index": true
        },
        {
          "key": "sender",
          "value": "inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d",
          "index": true
        },
        {
          "key": "amount",
          "value": "1000inj",
          "index": true
        },
        {
          "key": "msg_index",
          "value": "0",
          "index": true
        }
      ]
    },
    {
      "type": "message",
      "attributes": [
        {
          "key": "sender",
          "value": "inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d",
          "index": true
        },
        {
          "key": "msg_index",
          "value": "0",
          "index": true
        }
      ]
    }
  ]
}
```

#### **交易状态确认**

你的交易已成功上链！以下是关键信息：

|     字段     |     值     |           说明            |
| :----------: | :--------: | :-----------------------: |
|   `height`   | `85787701` | 交易已打包在区块 85787701 |
|    `code`    |    `0`     |       交易执行成功        |
| `gas_wanted` |  `200000`  |       预设 Gas 限制       |
|  `gas_used`  |  `165526`  |       实际消耗 Gas        |

---

### 查看多签账户余额

```bash
injectived query bank balances inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d --output json | jq .balances
[
  {
    "denom": "inj",
    "amount": "10"
  }
]

# 查询发送方余额
injectived query bank balances inj12jqyqqzrea2qea2lfz5vjwsp76qd4rerffgx0d \
  --node https://testnet.sentry.tm.injective.network:443
balances:
- amount: "10"
  denom: inj
pagination:
  total: "1"
```

### 查询 `Alice` 余额

```bash
injectived keys list --home ~/.injective
Enter keyring passphrase (attempt 1/3):
- address: inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj
  name: alice
  pubkey: '{"@type":"/injective.crypto.v1beta1.ethsecp256k1.PubKey","key":"A7/xUnEV1+8OcU6ymzs82Q/6T9wd++l7KXyOAQqxbrx1"}'
  type: local


injectived query bank balances inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj --output json | jq .balances
[
  {
    "denom": "inj",
    "amount": "2000"
  }
]

# 查询接收方余额
injectived query bank balances inj1smp73gj5afscqe40lqqc8s5hq73su3tzy94ycj \
  --node https://testnet.sentry.tm.injective.network:443
balances:
- amount: "2000"
  denom: inj
pagination:
  total: "1"
```

**多签交易完美成功！**

## 总结

本文从理论和实践两个层面，对 Injective 区块链进行了全面的介绍与演练。理论上，我们理解了 Injective 作为金融专用 L1 公链，其在高性能、抗抢先交易、开发者友好及 INJ 代币通缩模型等方面的核心优势。实践上，我们通过`injectived`命令行工具，完整地走过了从节点配置、创建个人钱包、获取测试币、执行转账，到最终成功设置并执行一笔 2/3 多签交易的全过程。

这次实操不仅验证了 Injective 网络的可用性和强大功能，更重要的是，它证明了通过命令行与区块链进行底层交互是完全可行的，尤其是多签钱包的成功演练，为团队资产管理和去中心化协作提供了安全可靠的技术方案。希望这篇结合了理论与实战的指南，能够帮助开发者和技术爱好者们更深入地理解并使用 Injective，为其生态的繁荣贡献一份力量。

## 参考

- https://github.com/InjectiveFoundation/injective-core#
- https://testnet.faucet.injective.network/
- https://docs.injective.network/
- https://docs.injective.network/developers/network-information
