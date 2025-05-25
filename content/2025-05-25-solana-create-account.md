+++
title = "Web3开发入门：Solana账户创建与Rust实践全攻略"
description = "Web3开发入门：Solana账户创建与Rust实践全攻略"
date = 2025-05-25T14:21:21Z
[taxonomies]
categories = ["Web3", "Solana", "Rust"]
tags = ["Web3", "Solana", "Rust"]
+++

<!-- more -->

# Web3开发入门：Solana账户创建与Rust实践全攻略

Web3时代正在席卷全球，Solana以其高吞吐量和低交易成本成为区块链开发的明星平台。想要快速入门Web3开发？从Solana账户创建开始！本文将带你走进Solana的Rust编程世界，详细解析如何通过System Program创建账户、构造交易并运行本地测试节点。无论你是区块链小白还是Rust开发者，这篇全攻略将为你提供从理论到实践的完整指引，助你轻松迈向Web3开发之路！快来一起探索Solana的无限可能吧！

本文深入讲解了在Solana区块链上使用Rust语言创建账户的完整流程，涵盖System Program的核心功能、createAccount指令的调用方法，以及账户所有权与数据初始化的机制。通过清晰的Rust代码示例和详细的操作步骤，展示了如何在本地测试节点上完成账户创建、密钥对生成、空投请求及交易签名。此外，文章还提供了项目依赖配置、常用Cargo命令和本地测试环境搭建的实用指南，适合Web3开发新手和希望深入Solana生态的开发者快速上手。

## Solana 如何创建账户

在Solana上创建账户的第一步是调用System Program中的`createAccount`指令。`System Program`是Solana的核心程序之一，负责账户管理。

在调用`createAccount`指令时，需要指定新账户所需的字节数（空间），并用lamports为分配的字节提供资金（即支付租金）。在区块链中，lamports是Solana的基本单位，就像以太坊中的wei。创建账户需要消耗资源，因此需要使用lamports来支付费用。

新创建账户的所有者程序是根据`createAccount`指令中指定的程序设定的。这意味着在创建账户时，可以将特定的程序绑定为账户的所有者。

Solana运行时确保只有设定的所有者程序能够修改账户的数据或从中转移lamports。这一机制确保了账户的安全性，防止未经授权的访问或更改。

在Solana区块链中，只有系统程序（System Program）具备创建新账户的权限。当需要为其他程序创建账户时，需调用“createAccount”指令。这一指令会生成一个全新的账户，并将其所有者设定为指定的目标程序。

新创建的账户初始状态是空的，其数据部分并未包含任何有效信息。此时，该账户的所有者——即目标程序，可以通过其自定义的指令来初始化账户的数据。这意味着，目标程序有权决定如何配置和使用这个新账户，包括存储何种数据以及执行哪些操作。

在 Solana 上，只有系统程序（System Program）能够创建新账户。若要创建由其他程序拥有的账户，需调用 createAccount 指令来创建一个新账户，并将所有者程序设置为所需的程序。随后，新的程序所有者可以通过其自身的指令对账户数据进行初始化。

简言之，Solana的系统程序负责创建账户，而其他程序则通过获得的所有权来初始化并管理这些账户的具体内容和功能。这种设计确保了账户创建的统一性和安全性，同时赋予了各个程序灵活管理自身账户的权力。

## 实操

### 创建项目

```bash
cargo new solana-create-account
    Creating binary (application) `solana-create-account` package
note: see more `Cargo.toml` keys and their definitions at *******************************************************
```

### 切换到项目目录

```bash
cd solana-create-account

```

### **列出当前目录内容**

```bash
ls
Cargo.toml src
```

### 常见 `ls` 参数（Linux/macOS）

|     参数     |              作用              |       示例        |
| :----------: | :----------------------------: | :---------------: |
|   `ls -l`    |  显示详细信息（权限、大小等）  |      `ls -l`      |
|   `ls -a`    |   显示隐藏文件（如 `.git/`）   |      `ls -a`      |
|   `ls -lh`   | 人类可读的文件大小（如 KB/MB） |     `ls -lh`      |
| `ls --color` |   彩色输出（Linux 默认启用）   | `ls --color=auto` |

### 编译运行当前项目

```bash
cargo run
   Compiling solana-create-account v0.1.0 (/Users/qiaopengjun/Code/Solana/SolanaSandbox/solana-create-account)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.60s
     Running `target/debug/solana-create-account`
Hello, world!
```

### **常用Cargo命令**

|        命令         |               作用                |
| :-----------------: | :-------------------------------: |
|    `cargo build`    | 编译项目（输出在`target/debug/`） |
|     `cargo run`     |          编译并运行项目           |
|    `cargo check`    |   快速检查语法（不生成二进制）    |
|    `cargo test`     |             运行测试              |
| `cargo add <crate>` |  添加依赖（需安装`cargo-edit`）   |

### 添加项目依赖

```bash
SolanaSandbox/solana-create-account on  main [?] is 📦 0.1.0 via 🦀 1.87.0 
➜ cargo add anyhow  

SolanaSandbox/solana-create-account on  main [?] is 📦 0.1.0 via 🦀 1.87.0 
➜ cargo add tokio --features full

SolanaSandbox/solana-create-account on  main [?] is 📦 0.1.0 via 🦀 1.87.0 
➜ cargo add solana-client  

SolanaSandbox/solana-create-account on  main [?] is 📦 0.1.0 via 🦀 1.87.0 
➜ cargo add solana-sdk  
```

### 查看项目目录结构

```bash
SolanaSandbox/solana-create-account on  main [?] is 📦 0.1.0 via 🦀 1.87.0 took 4.8s 
➜ tree . -L 6 -I "target"
.
├── Cargo.lock
├── Cargo.toml
└── src
    └── main.rs

2 directories, 3 files

```

### main.rs 文件

```rust
use solana_client::nonblocking::rpc_client::RpcClient;
use solana_sdk::{
    commitment_config::CommitmentConfig, native_token::LAMPORTS_PER_SOL, signature::Keypair,
    signer::Signer, system_instruction::create_account as create_account_ix,
    system_program::ID as SYSTEM_PROGRAM_ID, transaction::Transaction,
};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let client = RpcClient::new_with_commitment(
        String::from("http://127.0.0.1:8899"),
        CommitmentConfig::confirmed(),
    );

    let from_keypair = Keypair::new(); // payer
    let new_account_keypair = Keypair::new();
    let data_len = 0;
    let rent_exemption_amount = client
        .get_minimum_balance_for_rent_exemption(data_len)
        .await?;

    let create_acc_ix = create_account_ix(
        &from_keypair.pubkey(),        // payer
        &new_account_keypair.pubkey(), // new account
        rent_exemption_amount,         // rent exemption fee
        data_len as u64,               // space reserved for new account
        &SYSTEM_PROGRAM_ID,            //assigned program address
    );


    let transaction_signature = client
        .request_airdrop(&from_keypair.pubkey(), 1 * LAMPORTS_PER_SOL)
        .await?;
    loop {
        if client.confirm_transaction(&transaction_signature).await? {
            break;
        }
    }

    let mut transaction =
        Transaction::new_with_payer(&[create_acc_ix], Some(&from_keypair.pubkey()));
    transaction.sign(
        &[&from_keypair, &new_account_keypair],
        client.get_latest_blockhash().await?,
    );

    match client.send_and_confirm_transaction(&transaction).await {
        Ok(signature) => println!("Transaction Signature: {}", signature),
        Err(err) => eprintln!("Error sending transaction: {}", err),
    }

    Ok(())
}
```

这段代码是一个用 Rust 编写的 Solana 区块链示例程序，主要功能是在本地 Solana 测试节点（localhost:8899）上创建一个新账户。下面是详细解释：

#### 1. 引入依赖

```rust
use solana_client::nonblocking::rpc_client::RpcClient;
use solana_sdk::{
    commitment_config::CommitmentConfig, native_token::LAMPORTS_PER_SOL, signature::Keypair,
    signer::Signer, system_instruction::create_account as create_account_ix,
    system_program::ID as SYSTEM_PROGRAM_ID, transaction::Transaction,
};
```

- 这些是 Solana Rust SDK 的常用模块，提供了与链交互、签名、系统指令、交易等功能。

#### 2. 主函数入口

```rust
#[tokio::main]
async fn main() -> anyhow::Result<()> {
```

- 使用 `tokio` 异步运行时，主函数是异步的。

#### 3. 创建 RPC 客户端

```rust
let client = RpcClient::new_with_commitment(
    String::from("http://127.0.0.1:8899"),
    CommitmentConfig::confirmed(),
);
```

- 连接到本地 Solana 节点，使用“confirmed”确认级别。

#### 4. 生成密钥对

```rust
let from_keypair = Keypair::new(); // payer
let new_account_keypair = Keypair::new();
```

- `from_keypair`：付款人（payer），负责支付新账户创建费用。
- `new_account_keypair`：新账户的密钥对。

#### 5. 计算租金豁免金额

```rust
let data_len = 0;
let rent_exemption_amount = client
    .get_minimum_balance_for_rent_exemption(data_len)
    .await?;
```

- Solana 账户需要一定的 lamports（SOL 的最小单位）来免除租金。这里新账户数据长度为 0，所以只需最小金额。

#### 6. 构造创建账户指令

```rust
let create_acc_ix = create_account_ix(
    &from_keypair.pubkey(),        // payer
    &new_account_keypair.pubkey(), // new account
    rent_exemption_amount,         // rent exemption fee
    data_len as u64,               // space reserved for new account
    &SYSTEM_PROGRAM_ID,            //assigned program address
);
```

- 生成一个“创建账户”指令，指定付款人、新账户、公费、空间、分配给哪个程序（这里是系统程序）。

#### 7. 请求空投

```rust
let transaction_signature = client
    .request_airdrop(&from_keypair.pubkey(), 1 * LAMPORTS_PER_SOL)
    .await?;
```

- 向本地节点请求给付款人账户空投 1 SOL（测试网专用）。

#### 8. 等待空投确认

```rust
loop {
    if client.confirm_transaction(&transaction_signature).await? {
        break;
    }
}
```

- 循环等待，直到空投交易被确认。

#### 9. 构造并签名交易

```rust
let mut transaction =
    Transaction::new_with_payer(&[create_acc_ix], Some(&from_keypair.pubkey()));
transaction.sign(
    &[&from_keypair, &new_account_keypair],
    client.get_latest_blockhash().await?,
);
```

- 创建一个包含“创建账户”指令的交易。
- 用付款人和新账户的密钥对签名（新账户也要签名，因为它是被创建的对象）。

#### 10. 发送并确认交易

```rust
match client.send_and_confirm_transaction(&transaction).await {
    Ok(signature) => println!("Transaction Signature: {}", signature),
    Err(err) => eprintln!("Error sending transaction: {}", err),
}
```

- 发送交易到链上，并等待确认。
- 成功则打印交易签名，否则打印错误。

#### 11. 结束

```rust
Ok(())
```

- 程序正常结束。

这段代码演示了如何用 Rust 在本地 Solana 测试节点上：

1. 生成密钥对
2. 请求空投
3. 创建新账户
4. 构造并发送交易

### 启动本地测试节点

```bash
SolanaSandbox/solana-create-account on  main [?] is 📦 0.1.0 via 🦀 1.87.0 
➜ solana-test-validator
Ledger location: test-ledger
Log: test-ledger/validator.log
⠠ Initializing...                                                                                                              Waiting for fees to stabilize 1...
Identity: HdaDeHA7BMDDMqCUDZ4NZTuFmFFBeXmZoEDQdnBe7K43
Genesis Hash: CtimLaGHfPmhYGXKGm98VLraQLztCPiUHj5PeGcHZMe4
Version: 2.1.21
Shred Version: 33789
Gossip Address: 127.0.0.1:1024
TPU Address: 127.0.0.1:1027
JSON RPC URL: http://127.0.0.1:8899
WebSocket PubSub URL: ws://127.0.0.1:8900
⠂ 00:00:50 | Processed Slot: 105 | Confirmed Slot: 105 | Finalized Slot: 74 | Full Snapshot Slot: - | Incremental Snapshot Slot:

```

### 编译构建项目

```bash
SolanaSandbox/solana-create-account on  main [?] is 📦 0.1.0 via 🦀 1.87.0 took 21.8s 
➜ cargo build
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.82s

```

### 编译运行项目

```bash
SolanaSandbox/solana-create-account on  main [?] is 📦 0.1.0 via 🦀 1.87.0 
➜ cargo run  
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.69s
     Running `target/debug/solana-create-account`
Transaction Signature: 3qnLmfXU9NCBNctG73Xwewpzs1yrzEU15W9i6CpXK7jKs7PJbxKDteomFoaHfdpBxMgw1aNRiDT3n9ao66Y7FUjB

SolanaSandbox/solana-create-account on  main [?] is 📦 0.1.0 via 🦀 1.87.0 took 2.1s 
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.65s
     Running `target/debug/solana-create-account`
Transaction Signature: 3riMfj3tHF3LASQwhXEzX9kKVuNautcMeEfbzwsJ12DwhhwNmPkg1GknqNEqu1YF7n1ooyHtwQ9NM1us1TvHXEgD

```

## 总结

通过这篇全攻略，你已掌握了Solana账户创建的核心技能：从调用System Program的createAccount指令，到使用Rust完成密钥对生成、空投请求和交易构造，再到本地测试节点的运行。Solana通过系统程序与程序所有权的分离设计，确保了账户管理的灵活性与安全性，为Web3开发提供了强大支持。不管你是初探Web3的开发者，还是希望深耕Solana生态的专业人士，这篇教程都为你打开了一扇通往去中心化世界的大门！赶快动手实践，解锁更多Solana开发的可能性吧！关注我们的公众号，获取更多Web3与Solana的开发干货！

## 参考

- <https://solana.com/zh/developers/cookbook/accounts/create-account>
- <https://solscan.io/>
- <https://explorer.solana.com/>
- <https://solanacookbook.com/zh/#%E8%B4%A1%E7%8C%AE%E4%BB%A3%E7%A0%81>
- <https://websocketking.com/>
- <https://attractive-spade-1e3.notion.site/Solana-fca856aad4e5441f80f28cc4e015ca98>
- <https://www.anchor-lang.com/docs>
- <https://solana.com/zh/developers/courses>
- <https://beta.solpg.io/>
- <https://www.anchor-lang.com/docs/installation>
