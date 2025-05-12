+++
title = "Alloy 赋能 Web3：Rust 区块链实战"
description = "Alloy 赋能 Web3：Rust 区块链实战"
date = 2025-05-12T13:16:44Z
[taxonomies]
categories = ["Rust", "Web3", "Alloy", "区块链", "Ethereum"]
tags = ["Rust", "Web3", "Alloy", "区块链", "Ethereum"]
+++

<!-- more -->

# Alloy 赋能 Web3：Rust 区块链实战

想用 Rust 玩转 Web3？Alloy 高性能工具包为你助力！凭借 60% 更快的 U256 操作和 10 倍 ABI 编码速度，Alloy 让以太坊开发更高效、直观。结合 Rust 的安全与性能，本文带你实战区块链开发，从搭建项目到实现 ETH 转账，再到追踪交易全流程。无论你是初学者还是资深开发者，这篇实操指南将帮你快速上手 Web3，开启区块链开发新征程！

本文通过 Rust 和 Alloy 工具包，展示如何快速构建 Web3 区块链应用。内容涵盖项目初始化、代码实现、ETH 转账发送与余额追踪的全流程。Alloy 提供 60% 更快的 U256 操作和 10 倍 ABI 编码速度，结合 Rust 的高性能，打造直观高效的开发体验。借助 dotenv 和 tracing 库，代码实现安全灵活，适合初学者和专业开发者。通过 Holesky 测试网验证，本项目成功完成 1 ETH 转账，助你迈向智能合约与 DApp 开发！

## 实操

### 创建项目

```bash
cargo new alloy-forge
    Creating binary (application) `alloy-forge` package
note: see more `Cargo.toml` keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

cd alloy-forge

ls
Cargo.toml src

cargo run
   Compiling alloy-forge v0.1.0 (/Users/qiaopengjun/Code/Rust/alloy-forge)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.58s
     Running `target/debug/alloy-forge`
Hello, world!
```

### 查看项目目录结构

```bash
alloy-forge on  master [?] is 📦 0.1.0 via 🦀 1.86.0 
➜ tree . -L 6 -I "target"
.
├── Cargo.lock
├── Cargo.toml
├── contracts
├── crates
│   └── exercises
│       └── lesson-01-send-eth
│           ├── Cargo.toml
│           └── src
│               └── main.rs
└── src
    └── main.rs

7 directories, 5 files
```

### 代码实现

```rust
use alloy::{
    network::TransactionBuilder,
    primitives::{
        Address, U256, address,
        utils::{Unit, format_ether},
    },
    providers::{Provider, ProviderBuilder},
    rpc::types::TransactionRequest,
    signers::local::PrivateKeySigner,
};
use dotenv::dotenv;
use std::error::Error;
use tracing::info;
use tracing_subscriber::EnvFilter;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    dotenv().ok();

    // tracing_subscriber::fmt::init();
    tracing_subscriber::fmt()
        .with_env_filter(EnvFilter::from_default_env())
        .init();

    let private_key = std::env::var("PRIVATE_KEY").expect("PRIVATE_KEY must be set");
    let rpc_url = std::env::var("RPC_URL").expect("RPC_URL must be set");
    let recipient_address =
        std::env::var("RECIPIENT_ADDRESS").expect("RECIPIENT_ADDRESS must be set");
    let recipient_address: Address = recipient_address.parse()?;
    info!("Recipient address: {}", recipient_address);

    let signer: PrivateKeySigner = private_key.parse()?;
    let sender_address = signer.address();
    info!("Sender address: {}", sender_address);

    let provider = ProviderBuilder::new()
        .wallet(signer)
        .connect(&rpc_url)
        .await?;

    let recipient_address = address!("0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5");

    let before_balance = provider.get_balance(sender_address).await?;
    info!("Before balance: {}", format_ether(before_balance));

    let recipient_balance = provider.get_balance(recipient_address).await?;
    info!("Recipient balance: {}", format_ether(recipient_balance));

    let value = Unit::ETHER.wei().saturating_mul(U256::from(1));

    let tx = TransactionRequest::default()
        .with_from(sender_address)
        .with_to(recipient_address)
        .with_value(value);

    // let tx_hash = provider.send_transaction(tx.clone()).await?.watch().await?;
    // println!("Sent transaction: {tx_hash}");

    let pending_tx = provider.send_transaction(tx).await?;
    println!("Pending transaction... {}", pending_tx.tx_hash());

    let receipt = pending_tx.get_receipt().await?;
    println!(
        "Transaction included in block {}",
        receipt.block_number.expect("Failed to get block number")
    );

    println!(
        "Transferred {:.5} ETH to {recipient_address}",
        format_ether(value)
    );

    let after_balance = provider.get_balance(sender_address).await?;
    info!("After balance: {}", format_ether(after_balance));

    let after_recipient_balance = provider.get_balance(recipient_address).await?;
    info!("After recipient balance: {}", format_ether(after_recipient_balance));

    Ok(())
}

```

### 代码说明：发送 ETH 并追踪余额变化

这段代码演示了如何使用 Rust 生态中的 alloy、dotenv 和 tracing 等库，通过以太坊私钥签名并发送一笔 ETH 转账，同时记录转账前后账户余额的变化。

#### 主要流程如下

1. **环境变量加载**  
   使用 `dotenv` 加载 `.env` 文件中的私钥、RPC 节点地址和收款地址等敏感信息，保证安全性和灵活性。

2. **日志初始化**  
   通过 `tracing_subscriber` 初始化日志系统，并支持通过 `RUST_LOG` 环境变量动态调整日志级别，方便调试和生产环境切换。

3. **账户与提供者初始化**  
   - 解析私钥，生成本地签名器 `PrivateKeySigner`，并自动获取发送方地址。
   - 构建以太坊 RPC 提供者 `Provider`，用于后续链上交互。

4. **余额查询与日志输出**  
   - 查询并输出发送方和接收方的初始余额，便于后续对比。

5. **构造并发送交易**  
   - 构造一笔 1 ETH 的转账交易，指定发送方、接收方和金额。
   - 发送交易并输出交易哈希、区块号等信息。

6. **转账后余额查询**  
   - 再次查询并输出双方余额，验证转账是否成功。

### 运行

```bash
lesson-01-send-eth on  master [?] is 📦 0.1.0 via 🦀 1.86.0 took 25.8s 
➜ cargo run
   Compiling lesson-01-send-eth v0.1.0 (/Users/qiaopengjun/Code/Rust/alloy-forge/crates/exercises/lesson-01-send-eth)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 2.04s
     Running `/Users/qiaopengjun/Code/Rust/alloy-forge/target/debug/lesson-01-send-eth`
2025-05-11T15:12:07.752500Z  INFO lesson_01_send_eth: Recipient address: 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5
2025-05-11T15:12:07.754317Z  INFO lesson_01_send_eth: Sender address: 0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
2025-05-11T15:12:08.426904Z  INFO lesson_01_send_eth: Before balance: 75.807701170784260737
2025-05-11T15:12:08.763769Z  INFO lesson_01_send_eth: Recipient balance: 9.900000000000000000
Pending transaction... 0xf89e2a7f2f75e0d8eb6bc791ae4eb81c3dcf8af245fa14414bda09692f9df093
Transaction included in block 3819726
Transferred 1.000 ETH to 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5
2025-05-11T15:12:52.790353Z  INFO lesson_01_send_eth: After balance: 74.807701097366685737
2025-05-11T15:12:53.124568Z  INFO lesson_01_send_eth: After recipient balance: 10.900000000000000000
```

### 浏览器查看交易详情

<https://holesky.etherscan.io/tx/0xf89e2a7f2f75e0d8eb6bc791ae4eb81c3dcf8af245fa14414bda09692f9df093>

![image-20250511231600240](/images/image-20250511231600240.png)

## 总结

通过本次实战，我们用 Rust 和 Alloy 工具包快速实现了一个以太坊 ETH 转账应用，验证了 Alloy 在 Web3 开发中的强大能力。其 60% 更快的 U256 操作、10 倍 ABI 编码速度以及链无关架构，让区块链开发更高效、更灵活。结合 Rust 的安全性和 dotenv、tracing 的辅助，项目从搭建到交易追踪一气呵成。本教程为你打开 Web3 大门，无论是初探以太坊还是进阶智能合约与 DApp 开发，Alloy 和 Rust 都将是你的得力助手！

## 参考

- <https://alloy.rs/introduction/getting-started>
- <https://alloy.rs/transactions/using-the-transaction-builder/>
- <https://holesky.etherscan.io/tx/0xf89e2a7f2f75e0d8eb6bc791ae4eb81c3dcf8af245fa14414bda09692f9df093>
- <https://github.com/alloy-rs/examples/blob/main/examples/providers/examples/ws.rs>
- <https://alloy.rs/>
- <https://mirrors.tuna.tsinghua.edu.cn/help/crates.io-index.git/>
- <https://doc.rust-lang.org/stable/rust-by-example/>
