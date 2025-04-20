+++
title = "Web3 开发入门：Solana CLI 配置与本地验证器实战"
description = "Web3 开发入门：Solana CLI 配置与本地验证器实战"
date = 2025-04-20T02:36:21Z
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# Web3 开发入门：Solana CLI 配置与本地验证器实战
想快速踏入 Web3 开发的潮流？Solana 作为高性能区块链的代表，以其极速交易和低成本吸引了无数开发者。而 Solana CLI（命令行界面）是你与 Solana 网络交互的起点！本文通过简单易懂的实操步骤，带你从零掌握 Solana CLI 的配置、钱包创建、空投 SOL 代币到运行本地验证器。无论你是区块链新手还是 Web3 爱好者，这篇教程将是你开启 Solana 开发之旅的完美指南！

本文是 Web3 开发者的 Solana CLI 入门实战教程，涵盖从环境检查到运行本地验证器的全流程。内容包括：检查 CLI 工具版本、配置 Devnet 网络、生成密钥对管理钱包、空投测试 SOL 代币、查询余额，以及搭建和运行本地验证器。每一步均配有详细命令、输出示例和关键参数说明，助你快速上手 Solana 开发，迈出 Web3 实践第一步。
## 实操

### 前提

```bash
anchor --version
anchor-cli 0.31.0

avm --version
avm 0.31.0

solana --version
solana-cli 2.1.21 (src:8a085eeb; feat:1416569292, client:Agave)

rustc --version
rustc 1.86.0 (05f9846f8 2025-03-31)
```

### 查看您当前的配置：

```bash
solana config get
Config File: /Users/qiaopengjun/.config/solana/cli/config.yml
RPC URL: https://api.mainnet-beta.solana.com 
WebSocket URL: wss://api.mainnet-beta.solana.com/ (computed)
Keypair Path: /Users/qiaopengjun/.config/solana/id.json 
Commitment: confirmed 
```

The RPC URL and Websocket URL specify the Solana cluster the CLI makes requests to.

### 设置网络环境为 `Devnet`

```bash
# solana config set -ud    # For devnet
solana config set --url devnet

Config File: /Users/qiaopengjun/.config/solana/cli/config.yml
RPC URL: https://api.devnet.solana.com 
WebSocket URL: wss://api.devnet.solana.com/ (computed)
Keypair Path: /Users/qiaopengjun/.config/solana/id.json 
Commitment: confirmed 

# 查看
solana config get
Config File: /Users/qiaopengjun/.config/solana/cli/config.yml
RPC URL: https://api.devnet.solana.com 
WebSocket URL: wss://api.devnet.solana.com/ (computed)
Keypair Path: /Users/qiaopengjun/.config/solana/id.json 
Commitment: confirmed 
```

The Keypair Path points to the default Solana wallet (keypair) used by the Solana CLI to pay transaction fees and deploy programs. By default, this file is stored at `~/.config/solana/id.json`.

### 创建钱包 - 生成新的 **Solana 密钥对**（用于钱包地址和交易签名）

```bash
solana-keygen new
Generating a new keypair

For added security, enter a BIP39 passphrase

NOTE! This passphrase improves security of the recovery seed phrase NOT the
keypair file itself, which is stored as insecure plain text

BIP39 Passphrase (empty for none): 

Wrote new keypair to /Users/qiaopengjun/.config/solana/id.json
===============================================================================
pubkey: 6MZDRo5v8K2NfdohdD76QNGH3Aup53BeMaRAxxx
===============================================================================
Save this seed phrase and your BIP39 passphrase to recover your new keypair:
zzzz xxxx aaaa lend xx xx xxxx xxxx xx xxx xxx xxxx
===============================================================================
```

#### **关键参数**

|       参数        |             作用             |                      示例                       |
| :---------------: | :--------------------------: | :---------------------------------------------: |
|     `--force`     |       强制覆盖现有文件       |           `solana-keygen new --force`           |
| `--no-passphrase` |   不加密密钥文件（不安全）   |       `solana-keygen new --no-passphrase`       |
|     `--seed`      |      从种子短语生成密钥      | `solana-keygen new --seed "wolf lamp prize..."` |
|  `--word-count`   | 设置种子短语单词数（默认12） |       `solana-keygen new --word-count 24`       |

### 显示当前配置的默认 **Solana 钱包地址**（即公钥）

```bash
solana address
6MZDRo5v8K2NfdohdD76QNpSgk3GHssssssss
```

### [Airdrop SOL 空投 SOL](https://solana.com/zh/docs/intro/installation#airdrop-sol)

```bash
solana airdrop 5
Requesting airdrop of 5 SOL

Signature: 5kFPstTYyPKybJevoLBbbPTEnf4BBp5s6WQDyjtZCT23vFXHWT5B8Tgx2VA8qHi2SWPN8ZpBrP7aFk9ims1KkXeL

5 SOL
```

### 查看钱包余额

```bash
solana balance
5 SOL
```

### [Run Local Validator 运行本地验证器](https://solana.com/zh/docs/intro/installation#run-local-validator)

设置本地 localhost 

```bash
solana config set -ul
Config File: /Users/qiaopengjun/.config/solana/cli/config.yml
RPC URL: http://localhost:8899 
WebSocket URL: ws://localhost:8900/ (computed)
Keypair Path: /Users/qiaopengjun/.config/solana/id.json 
Commitment: confirmed 
```

Run local validator

```bash
solana-test-validator
--faucet-sol argument ignored, ledger already exists
Ledger location: test-ledger
Log: test-ledger/validator.log
⠚ Initializing...                                                                                                                  Waiting for fees to stabilize 1...
Identity: 47mfd1CWkN1vXy1wTWgcdsWjvTmX9ytjoosTCPS8N2JT
Genesis Hash: 8K2Uq4go7arvo6qVcDptJy83A9z5ZNgQUrSozCCN5TZA
Version: 2.1.21
Shred Version: 34132
Gossip Address: 127.0.0.1:1024
TPU Address: 127.0.0.1:1027
JSON RPC URL: http://127.0.0.1:8899
WebSocket PubSub URL: ws://127.0.0.1:8900
⠈ 00:00:41 | Processed Slot: 160 | Confirmed Slot: 160 | Finalized Slot: 129 | Full Snapshot Slot: 101 | Incremental Snapshot Slot: -
```



## 总结
通过本文的实战教程，你已掌握 Solana CLI 的核心技能：从配置网络环境、创建钱包、获取测试 SOL，到运行本地验证器，这些步骤为你打开了 Web3 开发的大门。Solana 的高性能区块链生态正等待你探索！建议继续结合官方文档和实践，深入学习智能合约开发或 DApp 构建，加速成为 Web3 领域的佼佼者。立即动手，开启你的 Solana 开发之旅吧！



## 参考

- https://solana.com/zh/docs/intro/installation
- https://www.anchor-lang.com/docs