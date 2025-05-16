+++
title = "Web3开发：用Rust实现Solana SOL转账教程"
description = "Web3开发：用Rust实现Solana SOL转账教程"
date = 2025-05-14T14:15:11Z
[taxonomies]
categories = ["Web3", "Rust", "Solana"]
tags = ["Web3", "Rust", "Solana"]
+++

<!-- more -->

# Web3开发：用Rust实现Solana SOL转账教程

Web3浪潮席卷全球，Solana作为高性能区块链的代表，以其高效、低成本的交易能力深受开发者喜爱。本文通过一个Rust实现的SOL转账示例，带你一步步完成Solana区块链开发。从项目搭建到交易执行，手把手教你快速上手Web3开发，适合区块链新手和Rust爱好者！

本文基于Solana官方文档，展示了一个Rust实现的SOL转账项目。内容涵盖项目初始化、依赖配置、代码实现、测试节点启动及交易执行。代码使用solana-sdk和solana-client库，通过异步RPC客户端与本地Solana节点交互，实现账户空投和1 SOL转账。本教程步骤清晰、代码详尽，助你快速掌握Solana开发技能。

## 实操

[How to Send SOL](https://solana.com/zh/developers/cookbook/transactions/send-sol)

### 创建项目

```bash
cargo new send-sol-demo
    Creating binary (application) `send-sol-demo` package
note: see more `Cargo.toml` keys and their definitions at *******************************************************
cd send-sol-demo

cc

```

### 查看项目目录结构

```bash
SolanaSandbox/send-sol-demo on  main [?] is 📦 0.1.0 via 🦀 1.86.0 took 2.6s 
➜ tree . -L 6 -I "target|test-ledger"
.
├── Cargo.lock
├── Cargo.toml
└── src
    └── main.rs

2 directories, 3 files

```

### 安装依赖

```bash
SolanaSandbox/send-sol-demo on  main [?] is 📦 0.1.0 via 🦀 1.86.0 
➜ cargo add tokio --features full

SolanaSandbox/send-sol-demo on  main [?] is 📦 0.1.0 via 🦀 1.86.0 
➜ cargo add anyhow               

SolanaSandbox/send-sol-demo on  main [?] is 📦 0.1.0 via 🦀 1.86.0 took 2.9s 
➜ cargo add solana-client

SolanaSandbox/send-sol-demo on  main [?] is 📦 0.1.0 via 🦀 1.86.0 took 6.7s 
➜ cargo add solana-sdk
      
```

### 代码实现

```rust
use solana_client::nonblocking::rpc_client::RpcClient;
use solana_sdk::{
    commitment_config::CommitmentConfig, native_token::LAMPORTS_PER_SOL, signature::Keypair,
    signer::Signer, system_instruction::transfer, transaction::Transaction,
};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let client = RpcClient::new_with_commitment(
        String::from("http://127.0.0.1:8899"),
        CommitmentConfig::confirmed(),
    );

    let from_keypair = Keypair::new();
    let to_keypair = Keypair::new();

    let transfer_ix = transfer(
        &from_keypair.pubkey(),
        &to_keypair.pubkey(),
        LAMPORTS_PER_SOL,
    );


    let transaction_signature = client
        .request_airdrop(&from_keypair.pubkey(), 5 * LAMPORTS_PER_SOL)
        .await?;
    loop {
        if client.confirm_transaction(&transaction_signature).await? {
            break;
        }
    }

    let mut transaction = Transaction::new_with_payer(&[transfer_ix], Some(&from_keypair.pubkey()));
    transaction.sign(&[&from_keypair], client.get_latest_blockhash().await?);

    match client.send_and_confirm_transaction(&transaction).await {
        Ok(signature) => println!("Transaction Signature: {}", signature),
        Err(err) => eprintln!("Error sending transaction: {}", err),
    }

    Ok(())
}
```

这段代码是一个用 Rust 编写的 Solana 区块链转账示例，主要流程如下：

#### 1. 导入依赖

- `solana_client::nonblocking::rpc_client::RpcClient`：异步 RPC 客户端，用于与 Solana 节点通信。
- `solana_sdk` 相关模块：用于密钥对、签名、系统指令、交易等。

#### 2. 主函数入口

- 使用 `#[tokio::main]` 宏，表示主函数是异步的，基于 Tokio 异步运行时。

#### 3. 创建 RPC 客户端

```rust
let client = RpcClient::new_with_commitment(
    String::from("http://127.0.0.1:8899"),
    CommitmentConfig::confirmed(),
);
```

- 连接本地的 Solana 节点（假设本地已启动 solana-test-validator）。
- 使用“confirmed”确认级别。

#### 4. 生成密钥对

```rust
let from_keypair = Keypair::new();
let to_keypair = Keypair::new();
```

- 随机生成两个密钥对，分别作为转账的发送方和接收方。

#### 5. 构造转账指令

```rust
let transfer_ix = transfer(
    &from_keypair.pubkey(),
    &to_keypair.pubkey(),
    LAMPORTS_PER_SOL,
);
```

- 构造一个系统转账指令，从发送方向接收方转 1 SOL（1 SOL = 1_000_000_000 lamports）。

#### 6. 请求空投

```rust
let transaction_signature = client
    .request_airdrop(&from_keypair.pubkey(), 5 * LAMPORTS_PER_SOL)
    .await?;
```

- 向本地节点请求给发送方账户空投 5 SOL，便于后续转账。

#### 7. 等待空投确认

```rust
loop {
    if client.confirm_transaction(&transaction_signature).await? {
        break;
    }
}
```

- 循环等待，直到空投交易被确认。

#### 8. 构造并签名交易

```rust
let mut transaction = Transaction::new_with_payer(&[transfer_ix], Some(&from_keypair.pubkey()));
transaction.sign(&[&from_keypair], client.get_latest_blockhash().await?);
```

- 构造一个包含转账指令的交易，并由发送方签名。

#### 9. 发送并确认交易

```rust
match client.send_and_confirm_transaction(&transaction).await {
    Ok(signature) => println!("Transaction Signature: {}", signature),
    Err(err) => eprintln!("Error sending transaction: {}", err),
}
```

- 发送交易到链上，并等待确认。
- 成功则打印交易签名，失败则打印错误信息。

#### 10. 结束

```rust
Ok(())
```

- 程序正常结束。

---

**总结**：  
这段代码演示了如何用 Rust 通过 Solana RPC 客户端实现账户空投和转账的完整流程，适合本地测试和学习 Solana 开发。

### 构建项目

```bash
SolanaSandbox/send-sol-demo on  main [?] is 📦 0.1.0 via 🦀 1.86.0 took 25.9s 
➜ cargo build
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.64s
```

### 启动Solana 本地测试验证节点

```bash
SolanaSandbox/send-sol-demo on  main [?] is 📦 0.1.0 via 🦀 1.86.0 
➜ solana-test-validator                                                                           
Ledger location: test-ledger
Log: test-ledger/validator.log
⠠ Initializing...                                                                                             Waiting for fees to stabilize 1...
Identity: CJ33uerr1nx5XhjUyb2imjWtTvXHWiRgxYGf5a1geSrE
Genesis Hash: ECWYjSfSYx4j3RNPHke7UEjVi1TJeP81HqtgtzbKLSMZ
Version: 2.1.21
Shred Version: 57143
Gossip Address: 127.0.0.1:1024
TPU Address: 127.0.0.1:1027
JSON RPC URL: http://127.0.0.1:8899
WebSocket PubSub URL: ws://127.0.0.1:8900
⠤ 00:00:14 | Processed Slot: 29 | Confirmed Slot: 29 | Finalized Slot: 0 | Full Snapshot Slot: - | Incremental S

```

### 运行

```bash
SolanaSandbox/send-sol-demo on  main [?] is 📦 0.1.0 via 🦀 1.86.0 
➜ cargo run  
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.75s
     Running `target/debug/send-sol-demo`
Transaction Signature: 5vipgKKTHhN6RpZi65RLFHN31id3EfWpifxcMWic5DjCcWWP8DHg5y5hb8w5sCTwV2xsQR9M6CGJSQQfJkjhqgJy
```

## 总结

通过一个简洁的Rust示例，本文详细讲解了在Solana区块链上实现SOL转账的完整流程。代码利用solana-sdk和solana-client库，通过异步编程实现空投和转账操作，开发者可借助本地测试节点快速验证效果。本教程为Web3开发提供了实用入门指引，适合初学者学习Solana生态，也为进阶开发者提供可扩展的代码基础。想深入探索Web3？快来动手实践吧！

## 参考

- <https://github.com/solana-program/system>
- <https://solana.com/zh/developers/cookbook/transactions/send-sol>
- <https://docs.rs/solana-client/latest/solana_client/>
- <https://www.anza.xyz/>
- <https://crates.io/crates/solana-client>
- <https://crates.io/crates/solana-sdk>
