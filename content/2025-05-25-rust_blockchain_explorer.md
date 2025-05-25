+++
title = "用 Rust 打造 Web3 区块链浏览器：从零开始的实战指南"
description = "用 Rust 打造 Web3 区块链浏览器：从零开始的实战指南"
date = 2025-05-25T10:15:09Z
[taxonomies]
categories = ["Web3", "Rust"]
tags = ["Web3", "Rust"]
+++

<!-- more -->

# 用 Rust 打造 Web3 区块链浏览器：从零开始的实战指南

在 Web3 浪潮席卷全球的今天，区块链浏览器作为探索去中心化网络的窗口，扮演着连接用户与链上数据的关键角色。无论是查询交易、监控智能合约，还是分析区块动态，区块链浏览器都是 Web3 开发者的必备工具。本文通过一个基于 Rust 的实战项目，带你从零开始构建一个实时连接以太坊网络的区块链浏览器。借助 Rust 的高性能和安全性，你将学会如何使用 Alloy 库订阅区块数据，迈出 Web3 开发的第一步。无论你是 Rust 新手还是 Web3 爱好者，这篇指南都将为你提供清晰的代码示例和实践经验，助你快速上手！

本文详细介绍如何使用 Rust 开发一个 Web3 区块链浏览器，涵盖项目创建、模块化代码设计、Alloy 库的 WebSocket 连接实现，以及实时订阅以太坊 Sepolia 测试网的区块数据。文章包括完整的代码示例、Cargo.toml 依赖配置、环境变量设置，以及使用 cargo watch 实现代码热重载的技巧。通过本教程，开发者可以快速掌握 Rust 在 Web3 开发中的应用，构建一个高效的区块链数据监控工具，适合 Rust 初学者和 Web3 开发爱好者参考。

## 实操

### 创建项目

```bash
cargo new blockchain_explorer
```

### 查看项目目录

```bash
blockchain_explorer on  master [?] is 📦 0.1.0 via 🦀 1.87.0 
➜ tree . -L 6 -I "target"      
.
├── Cargo.lock
├── Cargo.toml
├── docs
│   └── note.md
└── src
    ├── app.rs
    ├── chains
    │   ├── chain_provider.rs
    │   ├── constants.rs
    │   └── mod.rs
    ├── eth_connection_example.rs
    └── main.rs

4 directories, 9 files
```

### main.rs 文件

```rust
mod app;
mod eth_connection_example;
mod chains;

#[tokio::main(flavor = "multi_thread", worker_threads = 10)]
async fn main() {
    dotenvy::dotenv().expect("Failed to load .env file");
    env_logger::init();

    match app::start().await {
        Ok(_) => log::info!("Server stopped"),
        Err(e) => log::error!("Server stopped with error: {}", e),
    }
}

```

### app.rs 文件

```bash
use crate::eth_connection_example::eth_connection_example;

pub async fn start() -> anyhow::Result<()> {
    log::warn!("Blockchain explorer application starting...");

    match eth_connection_example().await {
        Ok(_) => log::warn!("Blockchain explorer application started successfully."),
        Err(err) => log::error!("Error starting blockchain explorer application: {}", err),
    }

    Ok(())
}

```

### eth_connection_example.rs 文件

```rust
use alloy::providers::{Provider, ProviderBuilder, WsConnect};
use futures_util::StreamExt;

use crate::chains::{
    chain_provider::{self, ChainProvider, ConnectionType},
    constants::alchemy,
};

pub async fn eth_connection_example() -> anyhow::Result<()> {
    let chain_provider = ChainProvider::new()
        .with_name("sepolia".to_string())
        .with_connection_type(ConnectionType::Ws)
        .with_is_mainnet(false)
        .with_rpc_url(alchemy::ethereum::MAINNET.to_string())
        .with_provider_service(chain_provider::ProviderService::Alchemy)
        .with_api_key(std::env::var("ALCHEMY_API_KEY").expect("ALCHEMY_API_KEY must be set"));

    log::info!("Generated URL: {}", chain_provider.to_string());
    // Create the provider.
    let ws = WsConnect::new(chain_provider.to_string());
    let provider = ProviderBuilder::new().connect_ws(ws).await?;

    // Subscribe to new blocks.
    let sub = provider.subscribe_blocks().await?;

    // Wait and take the next 4 blocks.
    let mut stream = sub.into_stream().take(4);
    // let mut stream = sub.into_stream();

    println!("Awaiting block headers...");

    // Take the stream and print the block number upon receiving a new block.
    let handle = tokio::spawn(async move {
        while let Some(header) = stream.next().await {
            println!("Latest block number: {}", header.number);
        }
    });

    handle.await?;

    Ok(())
}

```

### chains/mod.rs 文件

```rust
pub mod constants;
pub mod chain_provider;
```

### chains/constants.rs 文件

```rust
#[allow(dead_code)]
pub mod alchemy {
    pub mod ethereum {
        pub const MAINNET: &str = "eth-mainnet.g.alchemy.com/v2";
        pub const SEPOLIA: &str = "eth-sepolia.g.alchemy.com/v2";
        pub const HOLESKY: &str = "eth-holesky.g.alchemy.com/v2";
        pub const HOODI: &str = "eth-hoodi.g.alchemy.com/v2";
                               
    }

    pub mod polygon {
        pub const MAINNET: &str = "polygon-mainnet.g.alchemy.com/v2";
        pub const AMOY: &str = "polygon-amoy.g.alchemy.com/v2";
    }

    pub mod zksync {
        pub const MAINNET: &str = "zksync-mainnet.g.alchemy.com/v2";
        pub const SEPOLIA: &str = "zksync-sepolia.g.alchemy.com/v2";
    }
}
```

### chains/chain_provider.rs 文件

```rust
use std::fmt::Display;

#[allow(dead_code)]
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub enum ConnectionType {
    #[default]
    Ws,
    Https,
    Ipc,
}

#[allow(dead_code)]
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub enum ProviderService {
    #[default]
    Alchemy,
    Infura,
    Other,
}

#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct ChainProvider {
    pub name: String,
    pub connection_type: ConnectionType,
    pub is_mainnet: bool,
    pub rpc_url: String,
    pub provider_service: ProviderService, // Alchemy, Infura, or other
    pub api_key: String,
}

impl ChainProvider {
    pub fn new() -> Self {
        Self {
            ..Default::default()
        }
    }

    pub fn with_name(mut self, name: String) -> Self {
        self.name = name;
        self
    }

    pub fn with_connection_type(mut self, connection_type: ConnectionType) -> Self {
        self.connection_type = connection_type;
        self
    }

    pub fn with_is_mainnet(mut self, is_mainnet: bool) -> Self {
        self.is_mainnet = is_mainnet;
        self
    }

    pub fn with_rpc_url(mut self, rpc_url: String) -> Self {
        self.rpc_url = rpc_url;
        self
    }

    pub fn with_provider_service(mut self, provider_service: ProviderService) -> Self {
        self.provider_service = provider_service;
        self
    }

    pub fn with_api_key(mut self, api_key: String) -> Self {
        self.api_key = api_key;
        self
    }
}

impl Display for ChainProvider {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let conn_type = match self.connection_type {
            ConnectionType::Ws => "wss",
            ConnectionType::Https => "https",
            ConnectionType::Ipc => "https",
        };

   
        write!(
            f,
            "{}://{}/{}", conn_type, self.rpc_url, self.api_key
        )
    }
}

```

### Cargo.toml 文件

```rust
[package]
name = "blockchain_explorer"
version = "0.1.0"
edition = "2024"

[dependencies]
alloy = { version = "1.0.6", features = ["full"] }
anyhow = "1.0.98"
clap = "4.5.38"
dotenvy = "0.15.7"
env_logger = "0.11.8"
futures-util = "0.3.31"
log = "0.4.27"
parking_lot = "0.12.3"
rand = "0.9.1"
serde = { version = "1.0.219", features = ["derive"] }
serde_derive = "1.0.219"
serde_json = { version = "1.0.140", features = ["default"] }
tokio = { version = "1.45.0", features = ["full"] }

```

### .env 环境变量文件

```rust
RUST_LOG=info

ALCHEMY_API_KEY=
```

### 编译构建项目

```bash
blockchain_explorer on  master [?] is 📦 0.1.0 via 🦀 1.87.0 
➜ cargo build
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.53s

```

### 运行项目

```bash
blockchain_explorer on  master [?] is 📦 0.1.0 via 🦀 1.87.0 
➜ cargo run  
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.38s
     Running `target/debug/blockchain_explorer`
[2025-05-23T13:02:29Z WARN  blockchain_explorer::app] Blockchain explorer application starting...
[2025-05-23T13:02:29Z INFO  blockchain_explorer::eth_connection_example] Generated URL: wss://eth-mainnet.g.alchemy.com/v2/xxx
Awaiting block headers...
Latest block number: 22545736
Latest block number: 22545737
Latest block number: 22545738
Latest block number: 22545739
[2025-05-23T13:03:13Z WARN  blockchain_explorer::app] Blockchain explorer application started successfully.
[2025-05-23T13:03:13Z INFO  blockchain_explorer] Server stopped

# 监控 src 目录的代码变化，并在检测到变化时自动运行 cargo run 以编译和执行程序。
blockchain_explorer on  main is 📦 0.1.0 via 🦀 1.87.0 took 4.0s 
➜ cargo watch -w src -x run
[Running 'cargo run']
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.45s
     Running `target/debug/blockchain_explorer`
[2025-05-23T13:15:34Z WARN  blockchain_explorer::app] Blockchain explorer application starting...
[2025-05-23T13:15:34Z INFO  blockchain_explorer::eth_connection_example] Generated URL: wss://eth-mainnet.g.alchemy.com/v2
Awaiting block headers...
Latest block number: 22545800
Latest block number: 22545801
```

## 总结

通过本教程，我们成功用 Rust 搭建了一个 Web3 区块链浏览器原型，实现了与以太坊网络的实时连接，并通过 Alloy 库订阅和展示最新区块数据。这个项目展示了 Rust 在 Web3 开发中的强大潜力，结合 Tokio 异步运行时和模块化设计，提供了高效且安全的开发体验。开发者可以基于此原型扩展功能，例如支持多链网络、查询交易详情或集成智能合约交互，为 Web3 应用开发奠定基础。希望这篇实战指南能激发你在 Rust 和 Web3 领域的探索热情！快来动手实践，加入 Web3 开发者的行列吧！

## 参考

- <https://github.com/alloy-rs/examples/blob/main/examples/providers/examples/ws.rs>
- <https://github.com/watchexec/cargo-watch>
- <https://github.com/qiaopengjun5162/blockchain_explorer>
- <https://www.rust-lang.org/zh-CN>
- <https://course.rs/about-book.html>
- <https://doc.rust-lang.org/nomicon/>
