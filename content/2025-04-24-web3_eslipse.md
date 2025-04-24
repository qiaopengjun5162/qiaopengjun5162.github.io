+++
title = "Web3 Eclipse 开发环境搭建与资产跨链桥接实战指南"
description = "Web3 Eclipse 开发环境搭建与资产跨链桥接实战指南"
date = 2025-04-24T07:03:37Z
[taxonomies]
categories = ["Web3", "Eclipse"]
tags = ["Web3", "Eclipse"]
+++

<!-- more -->

# Web3 Eclipse 开发环境搭建与资产跨链桥接实战指南

Eclipse 区块链凭借高性能和 Solana 虚拟机（SVM）兼容性，成为 2025 年 Web3 生态的耀眼新星。本文详细介绍如何搭建 Eclipse 开发环境，包括安装 Rust、Solana、Anchor，创建账户，配置 Salmon 钱包，以及将 Sepolia 测试网 ETH 桥接到 Eclipse 测试网的完整流程。无论你是新手还是资深开发者，这篇教程都能让你快速掌握 Eclipse 开发要领，轻松开启 Web3 应用探索！

本文通过一步步实操教程，展示如何搭建 Eclipse 开发环境，包括安装 Rust、Solana CLI 和 Anchor CLI，生成并管理账户密钥，配置 Salmon 钱包，以及使用 Eclipse Deposit CLI 实现 Sepolia ETH 到 Eclipse 测试网的跨链桥接。教程还解析了派生路径含义、交易查询方法，并阐述 Eclipse 与 Solana 的兼容优势。代码示例、截图和参考链接一应俱全，助你快速融入 Eclipse 生态！

## 实操

### 安装`rust`、 `solana`、 `anchor`

<https://solana.com/zh/docs/intro/installation>

```bash
rustc --version
rustc 1.86.0 (05f9846f8 2025-03-31)
solana --version
solana-cli 2.1.21 (src:8a085eeb; feat:1416569292, client:Agave)
anchor --version
anchor-cli 0.31.0
```

### 创建账户

生成新密钥并保存到自定义路径

```bash
solana-keygen new --derivation-path m/44'/501'/0'/0' --outfile ~/.config/solana/eclipse_key.json
Generating a new keypair

For added security, enter a BIP39 passphrase

NOTE! This passphrase improves security of the recovery seed phrase NOT the
keypair file itself, which is stored as insecure plain text

BIP39 Passphrase (empty for none): 

Wrote new keypair to /Users/qiaopengjun/.config/solana/eclipse_key.json
========================================================================
pubkey: 3222xcxCTrST9VX111111MjmcXcK8TnyabZSAJD
========================================================================
Save this seed phrase and your BIP39 passphrase to recover your new keypair:
new new new new new new new new keypair keypair keypair keypair
========================================================================
```

#### 派生路径含义

派生路径 `m/44'/501'/0'/0'` 各部分的含义如下：

- **`m`**：表示根密钥或“主”密钥。
- **`44'`**：（必需）使用 BIP44 标准。BIP44 是一种用于分层确定性钱包的标准，它定义了一种通用的钱包结构和派生路径，使得不同的加密货币可以在同一个钱包中管理。
- **`501'`**：（必需）Solana 区块链硬币类型的标识符。每个加密货币都有一个唯一的硬币类型标识符，用于区分不同的区块链。
- **`0'`**：（可选）定义要派生的帐户 ID。这是浏览器钱包（如 Phantom 和 Solflare）将更改的值，以使用户能够动态生成新的公共地址，同时仍然使用单个助记词短语。
- **`0'`**：（可选）一个附加数字，对于公开的地址基本上始终设置为 0。

### 安装 Salmon 钱包

<https://docs.eclipse.xyz/developers/wallet/testnet-and-devnet-wallets>

<https://salmonwallet.io/>

![image-20250424135646209](/images/image-20250424135646209.png)

Eclipse 使用 ETH 作为支付代币，但是它需要用户通过跨链桥把以太坊主网或 Sepolia 测试网的 ETH 存入到 Eclipse 中，而不是直接使用以太坊的 ETH.

### 安装 Eclipse Deposit CLI

<https://github.com/Eclipse-Laboratories-Inc/eclipse-deposit.git>

Clone this repository:

```bash
git clone https://github.com/Eclipse-Laboratories-Inc/eclipse-deposit.git
cd eclipse-deposit


git clone https://github.com/Eclipse-Laboratories-Inc/eclipse-deposit.git
cd eclipse-deposit
Cloning into 'eclipse-deposit'...
remote: Enumerating objects: 150, done.
remote: Counting objects: 100% (12/12), done.
remote: Compressing objects: 100% (11/11), done.
remote: Total 150 (delta 6), reused 1 (delta 1), pack-reused 138 (from 3)
Receiving objects: 100% (150/150), 629.89 KiB | 543.00 KiB/s, done.
Resolving deltas: 100% (48/48), done.
```

Install the necessary dependencies:

```bash
yarn install

# 实操
npm install --global yarn

added 1 package in 2s

yarn install
yarn install v1.22.22
[1/4] 🔍  Resolving packages...
[2/4] 🚚  Fetching packages...
[3/4] 🔗  Linking dependencies...
[4/4] 🔨  Building fresh packages...
✨  Done in 13.59s.
```

### **导入私钥到 Cast**

```bash
cast wallet import MetaMask --private-key xxx
Enter password: 
`MetaMask` keystore was saved successfully. Address: 0xe91e2df7ce50bca5310b7238f6b1dfcd15566be5
```

### 查看 wallet list

```bash
cast wallet list
MetaMask (Local)
```

### 查看 keystores

```bash
cat ~/.foundry/keystores/Metamask
{"crypto":{"cipher":"aes-128-ctr","cipherparams":{"iv":"11111"},"ciphertext":"xxxxx","kdf":"scrypt","kdfparams":{"dklen":32,"n":8192,"p":1,"r":8,"salt":"xxxx"},"mac":"xxxxx"},"id":"655b5140-c0d9-41f4-ab1b-b2661eb572ee","version":3}%                                                                                       
```

### 创建私钥文件

```bash
touch private-key.txt

```

### Sepolia ETH 桥接至 Eclipse 测试网

```bash
node bin/cli.js -k private-key.txt -d 3Fx6GxcxCTrST9VXH2z8enQXjvMjmcXcK8TnyabZSAJD -a 0.002 --sepolia
Transaction hash: 0x57c776fa0aecb7de2ea3a28ebb81f33898b6d2e72522213193628df858268371
```

### 查看交易详情

<https://sepolia.etherscan.io/tx/0x57c776fa0aecb7de2ea3a28ebb81f33898b6d2e72522213193628df858268371>

![image-20250422214439100](/images/image-20250422214439100.png)

<https://explorer.dev.eclipsenetwork.xyz/address/3Fx6GxcxCTrST9VXH2z8enQXjvMjmcXcK8TnyabZSAJD?cluster=testnet>

![image-20250422220028278](/images/image-20250422220028278.png)

### 查看钱包余额

![image-20250424135605900](/images/image-20250424135605900.png)

**Mainnet RPC：**<https://mainnetbeta-rpc.eclipse.xyz>

**区块链浏览器**：<https://eclipsescan.xyz/>

**Testnet RPC**: <https://testnet.dev2.eclipsenetwork.xyz>

**Eclipse Devnet2 RPC：**<https://staging-rpc.dev2.eclipsenetwork.xyz>

**区块链浏览器**：

<https://eclipsescan.xyz/?cluster=testnet>

<https://solscan.io/?cluster=custom&customUrl=https%3A%2F%2Fstaging-rpc.dev2.eclipsenetwork.xyz>

<https://solscan.io/?cluster=custom&customUrl=https%3A%2F%2Ftestnet.dev2.eclipsenetwork.xyz>

**Solana 和 Eclipse 区块链共享相同的执行环境（SVM，即 Solana Virtual Machine），因此它们的智能合约开发具有高度的兼容性**。

在 SVM 链（如 Solana）上发代币无需自写智能合约，直接调用系统内置的「Token Program」即可（类似标准库），而 EVM 链（如以太坊）则需为每个代币单独部署合约。

## 总结

通过这篇教程，你已掌握 Eclipse 开发环境搭建、账户创建、钱包管理及跨链桥接的核心技能。Eclipse 与 Solana 共享 SVM 环境，让开发者能轻松迁移经验，利用内置 Token Program 高效开发代币。立即跟随教程实践，开启 Eclipse 的 Web3 无限可能！欢迎在评论区分享你的搭建心得，或关注寻月隐君

## 参考

- <https://classic.yarnpkg.com/lang/en/docs/install/#mac-stable>
- <https://github.com/Eclipse-Laboratories-Inc/eclipse-deposit>
- <https://sepolia.etherscan.io/tx/0x57c776fa0aecb7de2ea3a28ebb81f33898b6d2e72522213193628df858268371>
- <https://www.hackquest.io/zh-cn/learn/17693a59-0105-4962-b630-c864722f1b11/6626f6fe-6e4b-48ed-b802-c0fa7246a506>
- <https://docs.eclipse.xyz/developers/rpc-and-block-explorers>
- <https://github.com/Eclipse-Laboratories-Inc>
- <https://www.eclipse.xyz/>
