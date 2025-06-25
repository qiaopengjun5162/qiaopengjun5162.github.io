+++
title = "从零打造Solana空投工具库：Rust开发实战指南"
description = "从零打造Solana空投工具库：Rust开发实战指南"
date = 2025-06-25T00:50:30Z
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# 从零打造Solana空投工具库：Rust开发实战指南

Solana作为高性能区块链的代表，其开发生态正迅速崛起。无论是测试代币分发还是激励用户，空投（Airdrop）都是区块链项目中不可或缺的功能。本文将手把手带你用Rust从零开始构建一个Solana空投工具库，覆盖项目初始化、核心代码实现、测试与部署全流程。无论你是区块链新手还是资深开发者，这篇实战指南都能让你快速上手Solana空投开发，解锁更多Web3创新可能！

本文详细介绍了如何使用Rust语言开发一个Solana链上的Lamports空投工具库。通过创建项目、添加依赖、实现核心功能、编写测试用例及运行示例，读者可以掌握Solana空投工具的完整开发流程。文章涵盖了本地测试网和Devnet的支持，提供了健壮的错误处理机制，并通过示例代码展示了如何在实际场景中应用该工具库。无论是学习Solana开发还是构建去中心化应用（DApp），本教程都为你提供了实用且高效的参考。

## 实操

### 创建项目并切换到项目目录

```bash
# 创建Rust库项目
cargo new solana-airdrop-utils --lib
cd solana-airdrop-utils

# 实操
cargo new solana-airdrop-utils --lib
    Creating library `solana-airdrop-utils` package
note: see more `Cargo.toml` keys and their definitions at *******************************************************

cd solana-airdrop-utils
```

### 列出当前目录下的文件和文件夹

```bash
ls # 列出当前目录下的文件和文件夹（不包括隐藏文件）
Cargo.toml src
```

### 编译当前 Rust 项目

```bash
cargo build
   Compiling solana-airdrop-utils v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/solana-airdrop-utils)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.30s

```

### 测试项目

```bash
cargo test
   Compiling solana-airdrop-utils v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/solana-airdrop-utils)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.41s
     Running unittests src/lib.rs (target/debug/deps/solana_airdrop_utils-9fbda4e96fd2755a)

running 1 test
test tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

   Doc-tests solana_airdrop_utils

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

```

### 安装依赖

```bash
➜ cargo add reqwest --features json

➜ cargo add serde --features derive      

➜ cargo add serde_json --features default

➜ cargo add tokio --features full    

➜ cargo add thiserror  

➜ cargo add solana-sdk@2.2.2    

➜ cargo add solana-client  
➜ cargo add solana_keypair@2.2.1
```

### 查看项目目录

```bash
Code/Solana/solana-airdrop-utils is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ tree . -L 6 -I "coverage_report|lib|.vscode|out|test-ledger|target|node_modules"
.
├── Cargo.lock
├── Cargo.toml
├── examples
│   └── basic.rs
├── README.md
├── src
│   └── lib.rs
└── tests
    └── integration_test.rs

4 directories, 6 files
```

### **Cargo.toml**文件

```toml
[package]
name = "solana-airdrop-utils"
version = "0.1.0"
edition = "2024"
description = "Solana链上Lamports空投工具包"
license = "MIT"
repository = "https://github.com/qiaopengjun5162/solana-airdrop-utils"

[dependencies]
anyhow = "1.0.98"
log = "0.4.27"
rand = "0.9.1"
reqwest = { version = "0.12.20", features = ["json"] }
serde = { version = "1.0.219", features = ["derive"] }
serde_json = { version = "1.0.140", features = ["default"] }
solana-client = "2.2.7"
solana-faucet = "2.2.7"
solana-keypair = "2.2.1"
solana-sdk = "2.2.2"
thiserror = "2.0.12"
tokio = { version = "1.45.1", features = ["time", "rt-multi-thread"] }
url = "2.5.4"

[dev-dependencies]
env_logger = "0.11.8"
mockito = "1.7.0"

```

### 实现核心代码 (`src/lib.rs`)**

```rust
use log::{debug, error};
use reqwest::Url;
use solana_client::{client_error::ClientError, rpc_client::RpcClient};
use solana_faucet::faucet::{FAUCET_PORT, request_airdrop_transaction};
use solana_sdk::{
    pubkey::Pubkey,
    signature::{Keypair, Signer},
};
use std::{net::SocketAddr, time::Duration};
use thiserror::Error;
use url::ParseError;

#[derive(Error, Debug)]
pub enum AirdropError {
    #[error("RPC request failed: {0}")]
    RpcError(#[from] ClientError),
    #[error("HTTP request failed: {0}")]
    HttpError(#[from] reqwest::Error),
    #[error("Faucet error: {0}")]
    FaucetError(String),
    #[error("Insufficient balance: current {current}, needed {needed}")]
    InsufficientBalance { current: u64, needed: u64 },
    #[error("Max retries exceeded: {max_retries}")]
    MaxRetriesExceeded { max_retries: usize },
}

impl From<ParseError> for AirdropError {
    fn from(e: ParseError) -> Self {
        AirdropError::FaucetError(format!("Failed to parse faucet URL: {}", e))
    }
}

/// Supported blockchain networks
#[derive(Debug, Clone, Copy)]
pub enum Network {
    LocalTestnet,
    Devnet,
}

impl Network {
    /// Returns the RPC URL for the network
    pub fn rpc_url(&self) -> &'static str {
        match self {
            Self::LocalTestnet => "http://localhost:8899",
            Self::Devnet => "https://api.devnet.solana.com",
        }
    }

    /// Returns the faucet URL for LocalTestnet, None for Devnet
    fn faucet_url(&self) -> Option<Url> {
        match self {
            Self::LocalTestnet => Some(Url::parse("http://localhost:8899").unwrap()),
            Self::Devnet => None,
        }
    }

    /// Returns the faucet address for LocalTestnet, None for Devnet
    pub fn faucet_addr(&self) -> Option<SocketAddr> {
        match self {
            Self::LocalTestnet => Some(SocketAddr::new(
                std::net::IpAddr::V4(std::net::Ipv4Addr::new(127, 0, 0, 1)),
                FAUCET_PORT,
            )),
            Self::Devnet => None,
        }
    }
}

/// Asynchronously airdrops lamports to the specified address
pub async fn airdrop(
    network: Network,
    recipient: &Pubkey,
    lamports: u64,
    max_retries: usize,
) -> Result<(), AirdropError> {
    let client = RpcClient::new(network.rpc_url());

    // Check current balance
    let current_balance = client.get_balance(recipient)?;
    debug!(
        "Network: {:?}, Recipient: {}, Current balance: {}, Requested: {}",
        network, recipient, current_balance, lamports
    );
    if current_balance >= lamports {
        debug!(
            "Sufficient balance, skipping airdrop for recipient: {}",
            recipient
        );
        return Ok(());
    }

    // Handle airdrop based on network
    match network {
        Network::Devnet => {
            debug!("Attempting RPC airdrop for recipient: {}", recipient);
            request_airdrop_rpc(&client, recipient, lamports, max_retries).await
        }
        Network::LocalTestnet => match network.faucet_url() {
            Some(faucet_url) => {
                debug!(
                    "Attempting faucet airdrop via: {}, recipient: {}",
                    faucet_url, recipient
                );
                request_airdrop_http(faucet_url, recipient, lamports, max_retries).await
            }
            None => {
                debug!("Faucet not supported for network: {:?}", network);
                Err(AirdropError::InsufficientBalance {
                    current: current_balance,
                    needed: lamports,
                })
            }
        },
    }
}

/// Synchronously airdrops lamports to a keypair using the network's faucet
pub fn airdrop_lamports(
    network: Network,
    client: &RpcClient,
    id: &Keypair,
    desired_balance: u64,
    max_retries: usize,
) -> Result<(), AirdropError> {
    let recipient = id.pubkey();
    let starting_balance = client.get_balance(&recipient)?;
    debug!(
        "Initial balance: {} for keypair: {}",
        starting_balance, recipient
    );

    if starting_balance >= desired_balance {
        debug!("Sufficient balance for keypair: {}", recipient);
        return Ok(());
    }

    let airdrop_amount = desired_balance - starting_balance;
    let faucet_addr = network.faucet_addr().ok_or_else(|| {
        AirdropError::FaucetError(format!("Faucet not supported for network: {:?}", network))
    })?;
    debug!(
        "Requesting {} lamports from faucet: {} for keypair: {}",
        airdrop_amount, faucet_addr, recipient
    );

    for attempt in 0..max_retries {
        debug!(
            "Airdrop attempt {}/{} for keypair: {}",
            attempt + 1,
            max_retries,
            recipient
        );
        let blockhash = client.get_latest_blockhash()?;
        match request_airdrop_transaction(&faucet_addr, &recipient, airdrop_amount, blockhash) {
            Ok(transaction) => {
                if client.send_and_confirm_transaction(&transaction).is_ok() {
                    debug!("Airdrop successful for keypair: {}", recipient);
                    let current_balance = client.get_balance(&recipient)?;
                    if current_balance >= desired_balance {
                        return Ok(());
                    } else {
                        error!(
                            "Airdrop failed: expected at least {}, got {}",
                            desired_balance, current_balance
                        );
                        return Err(AirdropError::FaucetError(format!(
                            "Insufficient airdrop amount: got {}",
                            current_balance
                        )));
                    }
                }
            }
            Err(e) => {
                error!("Airdrop transaction failed: {}", e);
                if attempt == max_retries - 1 {
                    return Err(AirdropError::FaucetError(format!(
                        "Failed to request airdrop: {}",
                        e
                    )));
                }
            }
        }
        std::thread::sleep(Duration::from_secs(1));
    }

    debug!("Max retries exceeded for keypair: {}", recipient);
    Err(AirdropError::MaxRetriesExceeded { max_retries })
}

async fn request_airdrop_rpc(
    client: &RpcClient,
    recipient: &Pubkey,
    lamports: u64,
    max_retries: usize,
) -> Result<(), AirdropError> {
    for attempt in 0..max_retries {
        debug!(
            "RPC airdrop attempt {}/{} for recipient: {}",
            attempt + 1,
            max_retries,
            recipient
        );
        match client.request_airdrop(recipient, lamports) {
            Ok(_) => {
                debug!("RPC airdrop successful for recipient: {}", recipient);
                return Ok(());
            }
            Err(e) => {
                error!("RPC airdrop failed: {}", e);
                if attempt == max_retries - 1 {
                    return Err(AirdropError::RpcError(e));
                }
            }
        }
        tokio::time::sleep(Duration::from_secs(1)).await;
    }
    debug!("Max retries exceeded for recipient: {}", recipient);
    Err(AirdropError::MaxRetriesExceeded { max_retries })
}

async fn request_airdrop_http(
    faucet_url: Url,
    recipient: &Pubkey,
    lamports: u64,
    max_retries: usize,
) -> Result<(), AirdropError> {
    let http_client = reqwest::Client::builder()
        .timeout(Duration::from_secs(10))
        .build()?;

    for attempt in 0..max_retries {
        debug!(
            "HTTP airdrop attempt {}/{} for recipient: {}",
            attempt + 1,
            max_retries,
            recipient
        );
        let request_body = serde_json::json!({
            "jsonrpc": "2.0",
            "id": 1,
            "method": "requestAirdrop",
            "params": [recipient.to_string(), lamports],
        });

        debug!("Sending request to faucet: {}", faucet_url);

        let response = http_client
            .post(faucet_url.clone())
            .header("Content-Type", "application/json")
            .json(&request_body)
            .send()
            .await?;

        let status = response.status();
        let response_text = response.text().await.unwrap_or_default();
        debug!("Faucet response: status={}, body={}", status, response_text);

        if !status.is_success() {
            error!(
                "Faucet request failed, status {}: {}",
                status, response_text
            );
            return Err(AirdropError::FaucetError(format!(
                "Faucet returned status {}: {}",
                status, response_text
            )));
        }

        match serde_json::from_str::<serde_json::Value>(&response_text) {
            Ok(json) => {
                if json.get("error").is_none() {
                    debug!("HTTP airdrop successful for recipient: {}", recipient);
                    return Ok(());
                } else {
                    error!("Faucet returned error: {}", json);
                    return Err(AirdropError::FaucetError(json.to_string()));
                }
            }
            Err(e) => {
                error!("Failed to parse faucet response as JSON: {}", e);
                return Err(AirdropError::FaucetError(format!(
                    "Invalid JSON response: {}",
                    response_text
                )));
            }
        }
    }

    debug!("Max retries exceeded for recipient: {}", recipient);
    Err(AirdropError::MaxRetriesExceeded { max_retries })
}

```

### 添加测试代码 (`tests/integration_test.rs`)

```rust
use rand::Rng;
use solana_airdrop_utils::{AirdropError, Network, airdrop, airdrop_lamports};
use solana_client::rpc_client::RpcClient;
use solana_sdk::{pubkey::Pubkey, signature::Keypair};

#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn test_devnet_airdrop() {
    let mut rng = rand::rng();
    let recipient = Pubkey::from(rng.random::<[u8; 32]>());
    let lamports = 1_000_000; // 0.001 SOL
    let network = Network::Devnet;

    let result = airdrop(network, &recipient, lamports, 3).await;
    if let Err(AirdropError::RpcError(e)) = &result {
        eprintln!("RPC error: {}", e);
    }
    assert!(
        result.is_ok() || matches!(result, Err(AirdropError::RpcError(_))),
        "Devnet airdrop failed: {:?}",
        result.err()
    );

    if result.is_ok() {
        let client = RpcClient::new(network.rpc_url());
        let balance = client
            .get_balance(&recipient)
            .expect("Failed to get balance");
        assert!(
            balance >= lamports,
            "Balance {} is less than requested {} lamports",
            balance,
            lamports
        );
    }
}

#[test]
fn test_airdrop_lamports_local_fails_without_validator() {
    let network = Network::LocalTestnet;
    let client = RpcClient::new(network.rpc_url());
    let keypair = Keypair::new();
    let lamports = 1_000_000;

    let result = airdrop_lamports(network, &client, &keypair, lamports, 3);
    assert!(
        result.is_err(),
        "Local airdrop should fail without validator: {:?}",
        result
    );
}

#[test]
fn test_airdrop_lamports_devnet_fails() {
    let network = Network::Devnet;
    let client = RpcClient::new(network.rpc_url());
    let keypair = Keypair::new();
    let lamports = 1_000_000;

    let result = airdrop_lamports(network, &client, &keypair, lamports, 3);
    assert!(
        matches!(result, Err(AirdropError::FaucetError(_))),
        "Devnet does not support faucet airdrop: {:?}",
        result
    );
}

```

### 添加文档和示例 (`examples/basic.rs`)

```rust
use solana_airdrop_utils::Network;
use solana_client::rpc_client::RpcClient;
use solana_keypair::Keypair;
use solana_sdk::{signature::Signer, system_instruction, transaction::Transaction};
use std::time::Duration;
use tokio::time::Instant;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    env_logger::init();

    let recipient_keypair = Keypair::new();
    let recipient = recipient_keypair.pubkey();
    println!("Airdrop target address: {}", recipient);

    let network = Network::LocalTestnet;
    let client = RpcClient::new(network.rpc_url());
    let lamports = 100_000;

    let initial_balance = client.get_balance(&recipient)?;
    println!("Initial balance: {} lamports", initial_balance);

    if initial_balance < lamports {
        // 使用 CLI 的默认密钥对初始化账户
        let payer_keypair =
            solana_keypair::read_keypair_file("/Users/qiaopengjun/.config/solana/id.json")
                .map_err(|e| anyhow::anyhow!("Failed to read keypair file: {}", e))?;
        let payer = payer_keypair.pubkey();

        // 计算租金
        let rent = client.get_minimum_balance_for_rent_exemption(0)?;
        println!("Minimum rent for account: {} lamports", rent);

        // 创建账户
        let create_account_ix = system_instruction::create_account(
            &payer,
            &recipient,
            rent,
            0,
            &solana_sdk::system_program::id(),
        );

        let recent_blockhash = client.get_latest_blockhash()?;
        let transaction = Transaction::new_signed_with_payer(
            &[create_account_ix],
            Some(&payer),
            &[&payer_keypair, &recipient_keypair],
            recent_blockhash,
        );

        client.send_and_confirm_transaction(&transaction)?;
        println!("Account {} created successfully", recipient);

        // 请求空投
        let signature = client.request_airdrop(&recipient, lamports)?;
        println!("Airdrop requested, tx signature: {}", signature);

        // 等待交易确认
        let start = Instant::now();
        loop {
            match client.get_signature_status(&signature)? {
                Some(Ok(_)) => {
                    println!("Transaction confirmed successfully");
                    break;
                }
                Some(Err(e)) => {
                    return Err(anyhow::anyhow!("Transaction failed: {}", e));
                }
                None => {
                    if start.elapsed().as_secs() > 30 {
                        return Err(anyhow::anyhow!("Transaction confirmation timeout"));
                    }
                    tokio::time::sleep(Duration::from_millis(500)).await;
                }
            }
        }

        tokio::time::sleep(Duration::from_secs(2)).await; // 等待余额更新
    }

    let final_balance = client.get_balance(&recipient)?;
    println!("Final balance: {} lamports", final_balance);

    if final_balance >= lamports {
        Ok(())
    } else {
        Err(anyhow::anyhow!("Airdrop validation failed"))
    }
}

```

### 编译构建项目

```bash
Code/Solana/solana-airdrop-utils is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo build
   Compiling solana-airdrop-utils v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-airdrop-utils)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.65s

```

### 构建和测试

```bash
# 运行单元测试
cargo test

# 运行集成测试
cargo test --test integration_test

# 运行示例
cargo run --example basic
```

#### 单元测试

```bash
Code/Solana/solana-airdrop-utils is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 5.1s 
➜ cargo test
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.72s
     Running unittests src/lib.rs (target/debug/deps/solana_airdrop_utils-6fb2a04d1246e263)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

     Running tests/integration_test.rs (target/debug/deps/integration_test-ed02882ea27c21ed)

running 3 tests
test test_airdrop_lamports_local_fails_without_validator ... ok
test test_airdrop_lamports_devnet_fails ... ok
test test_devnet_airdrop ... ok

test result: ok. 3 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 13.64s

   Doc-tests solana_airdrop_utils

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

Code/Solana/solana-airdrop-utils is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 4.0s 
➜ cargo nextest run
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.48s
────────────
 Nextest run ID 7cb3b874-8ba1-4545-a465-d8301c60df44 with nextest profile: default
    Starting 3 tests across 2 binaries
        PASS [   0.058s] solana-airdrop-utils::integration_test test_airdrop_lamports_local_fails_without_validator
        PASS [   1.191s] solana-airdrop-utils::integration_test test_airdrop_lamports_devnet_fails
        PASS [  13.815s] solana-airdrop-utils::integration_test test_devnet_airdrop
────────────
     Summary [  13.816s] 3 tests run: 3 passed, 0 skipped


```

#### 集成测试

```bash
Code/Solana/solana-airdrop-utils is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 15.0s 
➜ cargo test --test integration_test
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.75s
     Running tests/integration_test.rs (target/debug/deps/integration_test-ed02882ea27c21ed)

running 3 tests
test test_airdrop_lamports_local_fails_without_validator ... ok
test test_airdrop_lamports_devnet_fails ... ok
test test_devnet_airdrop ... ok

test result: ok. 3 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 13.23s

```

#### 启动本地节点

```bash
Code/Solana/solana-airdrop-utils is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 20m 36.3s 
➜ solana-test-validator -r                   
Ledger location: test-ledger
Log: test-ledger/validator.log
⠲ Initializing...                                                                                                                                                Waiting for fees to stabilize 1...
Identity: 7nMB1uYSDGCsxZTJTPjrkTkNMwwK9LZx4Xq6tRb5iKN
Genesis Hash: CXa941kaWJPYHq7cvM5vsJykrWqVLCmpBsbgmc8hGouc
Version: 2.2.17
Shred Version: 61066
Gossip Address: 127.0.0.1:1024
TPU Address: 127.0.0.1:1027
JSON RPC URL: http://127.0.0.1:8899
WebSocket PubSub URL: ws://127.0.0.1:8900
⠖ 00:20:50 | Processed Slot: 2599 | Confirmed Slot: 2599 | Finalized Slot: 2568 | Full Snapshot Slot: 2500 | Incremental Snapshot Slot: - | Transactions: 2607 | ◎499.987037500                                                                                                                                                   
```

### 示例运行

```bash
Code/Solana/solana-airdrop-utils is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 32.4s 
➜ cargo run --example basic               
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.74s
     Running `target/debug/examples/basic`
Airdrop target address: BSVsyQG7tmwceQbgdCHupiX3Diae1SvtSgLJeXF771NV
Initial balance: 0 lamports
Minimum rent for account: 890880 lamports
Account BSVsyQG7tmwceQbgdCHupiX3Diae1SvtSgLJeXF771NV created successfully
Airdrop requested, tx signature: 4UDJjeHWWMPEpWNdrSZCTU2ob253DVpRR47AjTYwgZMnwQ4w7MEjcgwmCSqMarErAGdf7sqSYQhEioJwMfv1PupA
Transaction confirmed successfully
Final balance: 990880 lamports
```

## 总结

通过本文，你已经掌握了如何从零开始构建一个功能完备的Solana空投工具库。从项目初始化到核心代码实现，再到测试与示例运行，每一步都为你在Solana生态中的开发提供了坚实的基础。这个工具库不仅支持本地测试网和Devnet的空投操作，还通过Rust的强大性能和安全性为你的区块链项目保驾护航。立即动手实践，将你的创意转化为Solana链上的现实应用，加入Web3开发的浪潮吧！

## 参考

- <https://github.com/anza-xyz/agave/blob/master/transaction-dos/src/main.rs>
- <https://solana.com/zh>
- <https://solana.com/zh/developers/cookbook>
- <https://github.com/solana-foundation/solana-com>
- <https://www.anchor-lang.com/docs/basics/idl>
