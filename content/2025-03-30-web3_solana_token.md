+++
title = "玩转 Web3 Solana：从零到代币开发"
description = "玩转 Web3 Solana：从零到代币开发"
date = 2025-03-30 18:42:58+08:00
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# 玩转 Web3 Solana：从零到代币开发

Web3 浪潮席卷而来，Solana 凭借超高性能和低成本，成为开发者探索去中心化世界的热门选择。想从零开始玩转 Solana，打造属于自己的代币项目吗？这篇文章将带你一步步走进 Solana 开发的世界，从工具安装到代币创建，手把手带你体验 Web3 的魅力。不管你是小白还是老手，这里都有你需要的干货，快来一起解锁 Solana 的无限可能吧！

本文带你玩转 Web3 Solana 开发，从零基础起步，覆盖 Solana CLI 工具安装、Rust 和 Anchor 环境配置，到钱包管理、智能合约编译，再到 SPL 代币的创建与操作。通过详细的命令示例和链上结果展示，你将快速掌握代币开发的实战技能。无论是查询余额、生成密钥，还是在测试网空投 SOL，这篇指南都为你准备了清晰的操作路径，助你在 Solana 生态中轻松起飞！

## 实操

### 安装与查看 Solana 相关工具

#### 更新Solana CLI 工具链

```bash
agave-install update
  ✨ Update successful to stable commit f07a1e8
```

#### **检查当前安装的 Solana CLI 版本号**

```bash
solana --version

solana-cli 2.1.17 (src:f07a1e80; feat:3271415109, client:Agave)
solana -V
solana-cli 2.1.17 (src:f07a1e80; feat:3271415109, client:Agave)
```

#### **检查当前安装的 SBF（Solana 区块链程序框架）工具链版本**

```bash
cargo build-sbf -V
solana-cargo-build-sbf 2.1.17
platform-tools v1.43
rustc 1.79.0
```

#### **查看当前安装的 Rust 编译器（rustc）的版本号**

```bash
rustc -V
rustc 1.85.1 (4eb161250 2025-03-15)
```

#### **检查当前安装的 Anchor CLI 工具版本**

```bash
anchor --version
anchor-cli 0.31.0
anchor -V
anchor-cli 0.31.0
```

### 查看**当前默认地址**

```bash
solana address
6SWBzQWZndeaCKg3AzbY3zkvapCu9bHFZv12iiRoGvCD

buy-restrictor/client on  master [?] is 📦 1.0.0 via ⬢ v22.1.0 via 🦀 1.85.1 on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ solana address                                                                        
6SWBzQWZndeaCKg3AzbY3zkvapCu9bHFZv12iiRoGvCD
```

### 查看 Solana 默认钱包密钥文件的详细信息

```bash
ll ~/.config/solana/id.json 
-rw-------  1 qiaopengjun  staff   226B Feb 20  2024 /Users/qiaopengjun/.config/solana/id.json
```

### **查询当前默认钱包地址的 SOL 余额**

```bash
solana balance
100.18518034 SOL
```

### **查看当前 Solana 配置的详细信息**

`solana config get` 是 Solana CLI 中的一个命令，**用于查看当前 Solana 配置的详细信息**，包括默认的 RPC 节点、钱包路径和网络设置。

```bash
solana config get
Config File: /Users/qiaopengjun/.config/solana/cli/config.yml
RPC URL: https://api.devnet.solana.com 
WebSocket URL: wss://api.devnet.solana.com/ (computed)
Keypair Path: /Users/qiaopengjun/.config/solana/id.json 
Commitment: confirmed 
```

### **获取智能合约的 Program ID（程序地址）**

```bash
buy-restrictor on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 via 🅒 base 
➜ solana address -k target/deploy/buy_restrictor-keypair.json 
6ySTWR3Yf278usLzZRPXswdBcHrfyY6seb24Etxwph4f
```

### **查看 Solana 智能合约的密钥对文件内容**

```bash
buy-restrictor on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 via 🅒 base 
➜ cat target/deploy/buy_restrictor-keypair.json              
[155,71,21,122,135,204,91,244,135,51,144,142,136,90,129,188,150,237,4,203,65,17,8,6,207,110,23,76,79,62,57,184,88,191,190,137,101,105,152,191,142,81,72,155,71,134,244,193,182,104,228,166,172,180,153,50,49,7,194,50,74,141,54,204]%      
```

### **列出当前项目中所有程序的 Program ID（程序地址）**

```bash
buy-restrictor on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 via 🅒 base 
➜ anchor keys list
buy_restrictor: 6ySTWR3Yf278usLzZRPXswdBcHrfyY6seb24Etxwph4f

buy-restrictor/target/deploy on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 via 🅒 base 
➜ anchor keys list
buy_restrictor: H1tuY9Lwu2hkz8Bap6gbNAoj9GvQ23s9KgowiTWvYmtM
```

### **生成一个新的 Solana 钱包密钥对，并将其保存到指定文件**

```bash
buy-restrictor/target/deploy on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 via 🅒 base 
➜ solana-keygen new -o new.json
Generating a new keypair

For added security, enter a BIP39 passphrase

NOTE! This passphrase improves security of the recovery seed phrase NOT the
keypair file itself, which is stored as insecure plain text

BIP39 Passphrase (empty for none): 

Wrote new keypair to new.json
===============================================================================
pubkey: H1tuY9Lwu2hkz8Bap6gbNAoj9GvQ23s9KgowiTWvYmtM
===============================================================================
Save this seed phrase and your BIP39 passphrase to recover your new keypair:
usual daughter question found arch absent term spawn runway sphere spin despair
===============================================================================

buy-restrictor/target/deploy on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 via 🅒 base took 9.1s 
➜ ls
buy_restrictor-keypair.json buy_restrictor.so           new.json

buy-restrictor/target/deploy on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 via 🅒 base 
➜ mv new.json buy_restrictor-keypair.json 

buy-restrictor/target/deploy on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 via 🅒 base 
➜ ls
buy_restrictor-keypair.json buy_restrictor.so
```

### **获取指定密钥对文件（`.json`）对应的 Solana 公钥地址**

```bash
buy-restrictor/target/deploy on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 via 🅒 base 
➜ solana address -k buy_restrictor-keypair.json              
H1tuY9Lwu2hkz8Bap6gbNAoj9GvQ23s9KgowiTWvYmtM
```

### **自动同步项目中所有程序的 Program ID（程序地址）**

```bash
buy-restrictor on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 via 🅒 base 
➜ anchor keys sync                                 
Found incorrect program id declaration in "/Users/qiaopengjun/Code/solana-code/2025/buy-restrictor/programs/buy-restrictor/src/lib.rs"
Updated to H1tuY9Lwu2hkz8Bap6gbNAoj9GvQ23s9KgowiTWvYmtM

Found incorrect program id declaration in Anchor.toml for the program `buy_restrictor`
Updated to H1tuY9Lwu2hkz8Bap6gbNAoj9GvQ23s9KgowiTWvYmtM

All program id declarations are synced.
Please rebuild the program to update the generated artifacts.

```

### **编译 Solana 智能合约项目，生成部署所需的程序密钥和二进制文件**

```bash
buy-restrictor on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 via 🅒 base took 14.9s 
➜ anchor build
    Finished `release` profile [optimized] target(s) in 0.39s
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.46s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/solana-code/2025/buy-restrictor/target/debug/deps/buy_restrictor-6b544dadb31b7c3c)
```

### **详细列出 Solana 项目编译后生成的部署文件**

```bash
ll target/deploy
# 等效于：
ls -l target/deploy

buy-restrictor on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 via 🅒 base 
➜ ll target/deploy            
total 464
-rw-------  1 qiaopengjun  staff   233B Mar 26 20:33 buy_restrictor-keypair.json
-rwxr-xr-x  1 qiaopengjun  staff   225K Mar 26 22:25 buy_restrictor.so

```

### **检测 `buy_restrictor.so` 文件的类型和格式**

`file target/deploy/buy_restrictor.so` 是 Linux/Unix 系统命令，用于**检测 `buy_restrictor.so` 文件的类型和格式**。对于 Solana 智能合约编译后的 `.so` 文件，输出结果会揭示其底层二进制结构。

```bash
buy-restrictor on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 via 🅒 base 
➜ file target/deploy/buy_restrictor.so 
target/deploy/buy_restrictor.so: ELF 64-bit LSB shared object, eBPF, version 1 (SYSV), dynamically linked, stripped
```

### 在 Solana 区块链上创建新的 SPL 代币

`spl-token create-token` 是 Solana 的 SPL Token 命令行工具中的命令，**用于在 Solana 区块链上创建新的 SPL 代币（同质化代币，如 USDC 这类可互换代币）**。

```bash
buy-restrictor/client on  master [?] is 📦 1.0.0 via ⬢ v22.1.0 via 🦀 1.85.1 on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ spl-token create-token                                               
Creating token Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe under program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA

Address:  Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe
Decimals:  9

Signature: tgV38oEFfEyoupbxXTHsjbp7wjivuYCJaEexN8eE84Cf1ss2QStvYfitNwnYHFUgWVENpiyAyfDJuUbK4mNXEDy
```

<https://solscan.io/token/Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe?cluster=devnet>

<https://solscan.io/tx/tgV38oEFfEyoupbxXTHsjbp7wjivuYCJaEexN8eE84Cf1ss2QStvYfitNwnYHFUgWVENpiyAyfDJuUbK4mNXEDy?cluster=devnet>

### **为指定的 SPL 代币（Token Mint）创建关联账户（Associated Token Account, ATA）**

|          术语          |                        说明                        |
| :--------------------: | :------------------------------------------------: |
|   **代币 Mint 地址**   | 代币的唯一标识（由 `spl-token create-token` 创建） |
| **关联代币账户 (ATA)** | 每个钱包对每个代币有唯一的存储账户，格式为派生地址 |
|      **原生账户**      |           必须存在才能接收/持有对应代币            |

```bash
solana-code/2025/client is 📦 1.0.0 via ⬢ v22.1.0 on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ spl-token create-account Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe
Creating account 8yno4sSTn1Reh3uRdNiEWmRJ17zZ7Y4W1Ace1bJarYr1

Signature: 3Y1pMZUybRk59fXGKrxhDJmGhK2PFPGnXcxBuUyV5wYfZRcC9BfWcrTpPYwVjRBSDTFeNNxUhstzpuUAQThrV88A


ATA 地址 = 钱包地址 + 代币 Mint 地址 + 固定种子（"associated-token-account"）
```

`钱包地址` → 关联 → `ATA 地址` → 绑定 → `Token Mint 地址`。

### **向指定代币（Token Mint）铸造新代币并存入目标账户**

```bash
solana-code/2025/client is 📦 1.0.0 via ⬢ v22.1.0 on 🐳 v27.5.1 (orbstack) via 🅒 base took 3.2s 
➜ spl-token mint Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe 100 8yno4sSTn1Reh3uRdNiEWmRJ17zZ7Y4W1Ace1bJarYr1                                            
Minting 100 tokens
  Token: Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe
  Recipient: 8yno4sSTn1Reh3uRdNiEWmRJ17zZ7Y4W1Ace1bJarYr1

Signature: 34r7ne14yr8H6FJtUkRkS9dEbifJcMPcHUScRTqFBa8xeJCpx8VYgua1nXbxjv1dbUkjGzdEhVjZXjALgzvupS5V


secure_token_sale on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ spl-token mint Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe 100 7zzrX4Wn3ovnyMmZ8tXutHrJobvTTWkUutfAb7mPBFiq                                            
Minting 100 tokens
  Token: Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe
  Recipient: 7zzrX4Wn3ovnyMmZ8tXutHrJobvTTWkUutfAb7mPBFiq

Signature: 4oBteNo6DNHRdPB1tWyjhiuLDDnZHUw3vyxGPZZocZ1Minbz6V3tmKJoXyRz379Tr1JH58voouBGG6FvLvpAqb5d

```

### **列出当前钱包持有的所有 SPL 代币账户及其余额**

```bash
solana-code/2025/client is 📦 1.0.0 via ⬢ v22.1.0 on 🐳 v27.5.1 (orbstack) via 🅒 base took 3.4s 
➜ spl-token accounts
Token                                         Balance
-----------------------------------------------------
SNumWwVm1XCYZhupdHGYhG3MSfXTq1PJLm24nZVqTLk   1  
3jT7QdVfPh3isZA9Qfu6hcPRd1ATTkSbzaTs1qf3bxPG  1  
4zMMC9srt5Ri5X14GAgXhaHii3GnPAEERYPJgZJDncDU  20 
8BQHSWLd2vNJbiqd2DciWgrsyfG8AiL3T1Fc1hreXMsq  1  
E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx  88 
Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe  100
Fmt6FhmA9QQxkhgDBZJvSgZNH44VaQL9uecr9B7Zwufj  1  

```

### **查询特定 SPL 代币（Token Mint）当前总供应量**

```bash
solana-code/2025/client is 📦 1.0.0 via ⬢ v22.1.0 on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ spl-token supply Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe      
100
```

### **查询当前默认钱包中特定 SPL 代币余额**

```bash
spl-token balance <代币Mint地址>
# 示例：
spl-token balance Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe

solana-code/2025/client is 📦 1.0.0 via ⬢ v22.1.0 on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ spl-token balance Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe
100
```

### **查询 SPL 代币账户（Token Account）的完整链上信息**

```bash
solana-code/2025/client is 📦 1.0.0 via ⬢ v22.1.0 on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ spl-token account-info Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe

SPL Token Account
  Address: 8yno4sSTn1Reh3uRdNiEWmRJ17zZ7Y4W1Ace1bJarYr1
  Program: TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA
  Balance: 100
  Decimals: 9
  Mint: Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe
  Owner: 6SWBzQWZndeaCKg3AzbY3zkvapCu9bHFZv12iiRoGvCD
  State: Initialized
  Delegation: (not set)
  Close authority: (not set)
```

### 创建一个精度为 0 的 SPL 代币（每个代币不可分割，适合 NFT 或整数型代币）

```bash
➜ spl-token create-token --decimals 0  
```

### 创建一个默认启用冻结功能的SPL代币

```bash
➜ spl-token create-token --enable-freeze                               
```

### 生成一个不关联助记词的ED25519密钥对文件

```bash
buy-restrictor on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ solana-keygen new --no-bip39-passphrase --outfile token_pool_keypair.json
Generating a new keypair
Wrote new keypair to token_pool_keypair.json
===============================================================================
pubkey: 8gi14E6ZJmth6mhauwmPHDTT8LeAZgMsYAwryjgUU9y9
===============================================================================
Save this seed phrase to recover your new keypair:
clarify slice lucky trouble coil believe caution debate wall pass north abandon
===============================================================================
```

#### **参数深度解析**

|          参数           |       作用       |    使用场景    |
| :---------------------: | :--------------: | :------------: |
| `--no-bip39-passphrase` |  禁用助记词生成  |   自动化部署   |
|       `--outfile`       | 指定密钥保存路径 | 自定义密钥目录 |
|    `--force` (可选)     |  覆盖已存在文件  | 密钥轮换时使用 |

### 向指定地址空投 SOL（测试网代币）

```bash
buy-restrictor on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ solana airdrop 0.01 8gi14E6ZJmth6mhauwmPHDTT8LeAZgMsYAwryjgUU9y9 --url devnet
Requesting airdrop of 0.01 SOL

Signature: 2DbiptsJVSy37y3DmTnqxfC84Am2LZ1ES6Mdc9uKLUW7TZeJvnFkuPST92Bpav8qmjavz9wq2s5S14ru2WsiycSa

0.01 SOL

buy-restrictor on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 on 🐳 v27.5.1 (orbstack) via 🅒 base took 11.3s 
➜ solana airdrop 1 8gi14E6ZJmth6mhauwmPHDTT8LeAZgMsYAwryjgUU9y9 --url devnet   
Requesting airdrop of 1 SOL

Signature: 514cVcKnxiQo6tA57kgLxFG4iJ93dRgt8V3HFKn16Ydi2yeaMA3Ax5FLNv5Gxc86vm83reMRdg4oZKU99Po36p6a

1.01 SOL
```

### **在Solana的Devnet测试网络上，为指定代币创建一个新的关联账户（Associated Token Account, ATA）**

```bash
secure_token_sale on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ spl-token create-account Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe --owner H6Su7YsGK5mMASrZvJ51nt7oBzD88V8FKSBPNnRG1u3k --url devnet --fee-payer ~/.config/solana/id.json  
Creating account 8QPaQ6AiLqyNuCL69PCQoUbfDNE7r9agiNnvdXzhmMRJ

Signature: 59nvJc67zJRXKz6w6WyzqrdsKbaJhgXz1oRTLhxvMNkMgCNPCr4QE5q814BKsey2PgqTxgEBY4GW1W49D5AaxonQ


secure_token_sale on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ spl-token create-account Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe --owner CwuRGwa3wQbzSVJdKVjLs3Ygf54BXuNqtm45Pw1ajjN2 --url devnet --fee-payer ~/.config/solana/id.json 
Creating account 7zzrX4Wn3ovnyMmZ8tXutHrJobvTTWkUutfAb7mPBFiq

Signature: K4PR1fKtCshoNZBpx69X7YRqYc2KJnwSUbyBQYdTWsM2x4oGLTznZ4YNLwSi9B1hrFVs1bs6i7RT7SF5kHpz2nY

```

#### **参数说明**

|      参数      |       作用       |         备注         |
| :------------: | :--------------: | :------------------: |
| `Fgxp6...4GEe` |  代币的Mint地址  | 要创建关联账户的代币 |
|   `--owner`    |  指定账户所有者  |     目标钱包地址     |
| `--url devnet` | 在Devnet网络操作 |  也可用完整RPC URL   |
| `--fee-payer`  | 支付交易费的密钥 |  默认使用config设置  |

### **查询指定钱包地址持有的特定代币余额**

```bash
secure_token_sale on  master [?] via ⬢ v22.1.0 via 🦀 1.85.1 on 🐳 v27.5.1 (orbstack) via 🅒 base took 2.0s 
➜ spl-token balance Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe --owner CwuRGwa3wQbzSVJdKVjLs3Ygf54BXuNqtm45Pw1ajjN2                                            
101

```

## Token-2022 实操

### 创建代币并启用关闭 Mint 账户的能力

```bash
spl-token --program-id TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb create-token --enable-close
Creating token Eoy68rekZ22g3kucXXPLoPJgaoqv5B2KJN7AJCWNYpCJ under program TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb

Address:  Eoy68rekZ22g3kucXXPLoPJgaoqv5B2KJN7AJCWNYpCJ
Decimals:  9

Signature: 4RKTy9BAyXh4PGgxttziZveAZFH3zxBCUYQvLxgW3nmsmcxx1PQC9NnJ4qB6ktxfhHVdFTQpp4EsxFe84ujy6hnh

```

<https://solscan.io/tx/4RKTy9BAyXh4PGgxttziZveAZFH3zxBCUYQvLxgW3nmsmcxx1PQC9NnJ4qB6ktxfhHVdFTQpp4EsxFe84ujy6hnh?cluster=devnet>

### 关闭 Mint 账户

**Note**: The supply on the mint must be 0.

```bash
spl-token close-mint Eoy68rekZ22g3kucXXPLoPJgaoqv5B2KJN7AJCWNYpCJ

Signature: 3i36vhAAq2sjPfVYzo3xtYdt5naFYCuKe6TsDzwqJSj1AD4WqAyotYKrPVM851J2hKwraCMjBL2fCoyDeCiVzNCM

```

<https://solscan.io/tx/3i36vhAAq2sjPfVYzo3xtYdt5naFYCuKe6TsDzwqJSj1AD4WqAyotYKrPVM851J2hKwraCMjBL2fCoyDeCiVzNCM?cluster=devnet>

### 查看 PayPal USD mintCloseAuthority

<https://solscan.io/token/2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo#extensions>

## 总结

通过这篇实战指南，我们从零开始玩转了 Web3 Solana 开发的全流程：从工具链配置到密钥生成，再到智能合约部署和代币创建，每一步都清晰可见。Solana 的高性能和灵活的代币功能为 Web3 创新提供了广阔舞台，而掌握这些技能，你就能在去中心化世界中大展身手。文章不仅提供了操作细节，还附上链上链接和参考资源，随时助你进阶。接下来，不妨试试更复杂的 Solana 项目，开启你的 Web3 冒险吧！

## 参考

- <https://spl.solana.com/token-2022/extensions>
- <https://solscan.io/tx/4RKTy9BAyXh4PGgxttziZveAZFH3zxBCUYQvLxgW3nmsmcxx1PQC9NnJ4qB6ktxfhHVdFTQpp4EsxFe84ujy6hnh?cluster=devnet>
- <https://solscan.io/token/Eoy68rekZ22g3kucXXPLoPJgaoqv5B2KJN7AJCWNYpCJ?cluster=devnet#extensions>
- <https://spl.solana.com/token-2022>
- <https://github.com/solana-program/token-2022/blob/main/README.md>
- <https://github.com/solana-developers/program-examples/tree/main/tokens/token-2022>
- <https://github.com/solana-developers/program-examples/blob/main/tokens/token-2022/transfer-hook/whitelist/anchor/tests/transfer-hook.ts>
- <https://www.anchor-lang.com/docs/tokens/extensions>
- <https://github.com/solana-developers/program-examples/tree/main/tokens/token-2022>
- <https://github.com/coral-xyz/anchor/tree/0e5285aecdf410fa0779b7cd09a47f235882c156/spl/src/token_2022_extensions>
- <https://www.anchor-lang.com/docs/references/account-types>
- <https://github.com/firechiang/solana-study>
- <https://github.com/Ellipsis-Labs/solana-verifiable-build?tab=readme-ov-file>
- <https://soldev.cn/topics/14>

- <https://www.npmjs.com/package/@solana/spl-token>
- <https://beta.solpg.io/>
- <https://github.com/Ellipsis-Labs/solana-verifiable-build>
- <https://solscan.io/token/Fgxp6CWJnUfmt66vaHzjNf4SFPoG23PmFEb1MXcr4GEe?cluster=devnet>
- <https://explorer.solana.com/tx/5Wcez6qMnY8nTyUnwaTUXoF59qWHcrAVK8usJhjnQurc6po6uupeoRt7hg1gXCoEsJL18LTNoiM599VYZLkyB49Q?cluster=devnet>
- <https://explorer.solana.com/tx/5Det5VGmkQY67R9qL8JxAhurBXa17nvBDtZqdcuh98C97GNP93LSMrQdkHa71qQoEcm3Y7AX94ScJWrop3wF6dW6?cluster=devnet>
- <https://explorer.solana.com/tx/675ARR4Riro9uaKNwVWMT4XAJiyAyjbN9A1gMGa29tBZsc2HpZvB4cnMcBJqh8epmLWuHP9o7XGEgrPkR1R94MFP?cluster=devnet>
- <https://explorer.solana.com/tx/3GeEiTkbwmT5TcyBZiu2EwFEuSG86Qr7XS9ffPcTvMay9By1VcJddeK6UTv6puPD4s4cZM735ViV5RN2VYuxkhJf?cluster=devnet>
- <https://explorer.solana.com/tx/2JPm1XkCG6iER2vVp4EP4nNbo5LQPWsc9GDTuvuMgyMSCgbR4LMiqoZiprh67vAyTsas65Vuk6ugY6UAkamPqnCM?cluster=devnet>
- <https://explorer.solana.com/tx/J6dgGPkC37LVYbxYxPEUr83h9QWqzd7jYPXaxqSuncA9VL2UC3rftnU7GspDjPqTnuk71T2MQVA5aFykv4osmM3?cluster=devnet>
- <https://explorer.solana.com/tx/4vCBKAXy1T8FF2bPJ4U7tHAYs7ThwSpdSaMyB1EbEfZcX3SPhNDdWpnr6h8ptVjmzEXcMyS8UGXDKVtr1nx4uBxx?cluster=devnet>
- <https://explorer.solana.com/tx/3HSUApzJdqEvFJCkZovUSGGEV7Y1caYgpzEzK1WjVQpfoZLEDr7kB3a6gKp3mUTGreHRFL8XVG2HBmCVreqkXK7C?cluster=devnet>
- <https://explorer.solana.com/tx/247bZYoAbYWMrMh9C98jGV4JRFg75kp6zbRdV4xAQmfBs6CAh1vR2YQ3DfN3tDegLCWUT8e7rUuHSYWVqmRQ1GeQ?cluster=devnet>
- <https://explorer.solana.com/tx/5eZxozWgr26gQQCX5YZjVXkUQEFbGaG9N84KA8qm4J5AvMzk9QkRNurDaRHg66K2sbYSfqBTfACNaWXRefrFiNmw?cluster=devnet>
- <https://explorer.solana.com/tx/5UZAabRXQSeHntYdCxapziKD4dCAbSGDaQMumXSdXJfS9eYrV5R6saffx7Z6m1WuqotYRV1sNFM5dL7emyjSAEm3?cluster=devnet>
- <https://explorer.solana.com/tx/2bPcHPHxCXCvu7C97QbRfuBGKmYCcMpmewpypCVpgHBTgMthetJtE3j9iQgq1yiJvKbJAi993PjZY7nsDWjk14iX?cluster=devnet>

- <https://explorer.solana.com/tx/4cG1aJjNgvx6vQMxazMjzaeFgvUEyUieajCken2ARajsYuRtSiYwSmENezs3rJ7mURvcYd1caeKr1gojzjWWiwYR?cluster=devnet>

- <https://explorer.solana.com/tx/5Aj2Bv4LT9Ga3PREz92ms15jBEU9JmGPbxz4hmUxSdqi4fNtGdfmgvkvPuSYziKir42ShVcbCK6EjEjfc2vfakM7?cluster=devnet>

- <https://explorer.solana.com/tx/4HyVbTLnAD76gXMWYnKHF7qfq6UKJbX4jCbFdg2JxEyeVX7jnnh5L1hbXuYZrefs6AC2HCuRCjq2HLCK6WdRnYgM?cluster=devnet>

- <https://explorer.solana.com/tx/4wcpV24tdGQAjaS6k46KMxLG44PiuS4xaaXvbLKkvVEMd5BSEFL14eTMLxRRZvwyW41vmjZBBqCDstXppBHtkXq4?cluster=devnet>
- <https://explorer.solana.com/tx/gqrVKtsqJ2tpiBWiEdfg8gc2T47TwsZpbAD31uwE4T4txqDYV9yATtws7F5ntyLRRQmyX8PSucBx6u1Q4bThJAz?cluster=devnet>
- <https://explorer.solana.com/tx/4QkhnajbDoPQY9Fw1KUvarmmM5uHYaAMaD5tAk8xmpeJ8qX17FEJ2yLojsVcSy8r43coLep1sVfbne8zPjkihjqB?cluster=devnet>
- <https://explorer.solana.com/tx/frFFqXHXMcX26UdJRkebHYzMEaZMWDubFB2un61XgitExSCKurnF4QDkxTd55G769CFAzrB7kpyWVNxxcg1w1gb?cluster=devnet>
- <https://explorer.solana.com/tx/2dg5ZrwK5qyZACnr7gKghQJmohAz7WpnMUFxY4hAa75FucfhvZ6FNWCypH7tF144f8B4jguboJ1WYyHYe2FwubQ7?cluster=devnet>
- <https://explorer.solana.com/tx/2XE41q1AuEgrPW97Z8fxEBU3fDQmZyQCj1Q83JfSbzmHSTBiQHLreCy56EAm7wBEKRVoSF4x8fyeqE8hdMDEbXdG?cluster=devnet>
- <https://explorer.solana.com/tx/3GDsPPyW5hSEXue3Aikdh4qSUP96cGAb4nYvbi49zUChrqE6hYZKD6HM4M4Nx76apQU5pVnhgiv6eb4pJPkUEEac?cluster=devnet>
- <https://explorer.solana.com/tx/4yX9JYT5BcyL3sB1pdhkZQ4JvGs9riwyFSWGNQYrPr8aY6fq7v4xXcxtdkEZUBq5hJjg16wvxhm6Si8r93gR23n6?cluster=devnet>
- <https://explorer.solana.com/tx/3AL9zTMVGbwu9t5QGTsY9xbdqd6MZqqSJsrD9S8aKak6VgEGpVKQSYc9yB9GKk7URVNPQtaC8nPKN7U3LgGEfdxT?cluster=devnet>

- <https://explorer.solana.com/tx/3DEiwc5eAuawbYu7AxEFdWNkyn2pXn2VFYsoDvtv57KeNRDKWMeuWdTx6KfyqZz6ahgSdWW63ypDmKfXPRH7jXT1?cluster=devnet>
- <https://explorer.solana.com/tx/G9GTsZzTmNzBcG2BoV5KNRom2DCAvmytpJBS1tX869iixHC3povQknTCdNso11cEwvecHZB6y27rfiD6fD7tY9C?cluster=devnet>
