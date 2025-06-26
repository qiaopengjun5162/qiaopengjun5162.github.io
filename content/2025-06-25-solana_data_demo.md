+++
title = "从零开始：用 Rust 开发 Solana 链上 Token 元数据查询工具"
description = "从零开始：用 Rust 开发 Solana 链上 Token 元数据查询工具"
date = 2025-06-25T14:24:24Z
[taxonomies]
categories = ["Web3", "Solana", "Rust"]
tags = ["Web3", "Solana", "Rust"]
+++

<!-- more -->

# 从零开始：用 Rust 开发 Solana 链上 Token 元数据查询工具

在 Web3 时代，Solana 以其高性能和低成本成为区块链开发的热门选择。本文将带你通过 Rust 编程语言，结合 Anchor 框架，开发一个查询 SPL Token 2022 元数据的实用工具。无论是初学者还是资深开发者，都能通过这篇教程快速上手 Solana 开发，解锁链上数据的秘密！

本文详细介绍了如何使用 Rust 和 Anchor 框架创建一个 Solana 项目，用于查询 SPL Token 2022 的 Mint 账户信息和元数据（Metadata）。通过配置环境、编写代码、解析链上数据，我们实现了一个轻量级工具，能够提取 Token 的名称、符号、URI 等关键信息。代码示例清晰，步骤分解详尽，适合 Solana 开发新手和需要调试 Token 元数据的开发者参考。

## 实操

### 创建项目

```bash
cargo new solana-data-demo
    Creating binary (application) `solana-data-demo` package
note: see more `Cargo.toml` keys and their definitions at *******************************************************
```

### 切换到项目目录

```bash
cd solana-data-demo

```

### cursor 打开项目

```bash
cc # open -a cursor .
```

### 查看项目目录

```bash
solana-sandbox/solana-data-demo on  main [?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ tree . -L 6 -I "coverage_report|lib|.vscode|out|test-ledger|target|node_modules"
.
├── Cargo.lock
├── Cargo.toml
├── idls
│   └── red_packet.json
└── src
    └── main.rs

3 directories, 4 files
```

### Cargo.toml 文件

```toml
[package]
name = "solana-data-demo"
version = "0.1.0"
edition = "2024"

[dependencies]
spl-token-2022 = { version = "9.0.0", features = [
    "no-entrypoint",
    "serde-traits",
] }
solana-client = "2.2.7"
solana-program = "2"
solana-transaction-status-client-types = "2.2.7"
solana-sdk = "2.2.2"
anchor-client = { version = "0.31.1", features = ["async"] }
anchor-lang = "0.31.1"
spl-token-metadata-interface = "0.7.0"
spl-token = "8.0.0"
tokio = { version = "1", features = ["full", "rt-multi-thread"] }
anyhow = "1.0"
futures-util = "0.3.31"
mpl-token-metadata = "5.1.0"
borsh = "1.5.7"
dotenvy = "0.15.7"

```

### main.rs 文件

```rust
use anchor_client::{
    Cluster,
    solana_client::rpc_client::RpcClient,
    solana_sdk::{commitment_config::CommitmentConfig, pubkey::Pubkey},
};
use anchor_lang::declare_program;
use anyhow::Context;
use borsh::BorshDeserialize;
use spl_token_2022::extension::metadata_pointer::MetadataPointer;
use spl_token_2022::extension::{BaseStateWithExtensions, StateWithExtensions};
use spl_token_2022::state::Mint;
use spl_token_metadata_interface::state::TokenMetadata;
use std::str::FromStr;

declare_program!(red_packet);

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenvy::dotenv()?;
    let mint_address =
        dotenvy::var("MINT_ADDRESS_2022").context("请在 .env 文件中设置 MINT_ADDRESS_2022")?;

    // let rpc_url = "https://api.mainnet-beta.solana.com"; // 主网
    let rpc_url = dotenvy::var("RPC_URL").unwrap_or_else(|_| Cluster::Devnet.url().to_string());
    let safe_url = rpc_url.split('?').next().unwrap_or("");
    println!("使用的 RPC URL: {}", safe_url);
    let rpc_client = RpcClient::new_with_commitment(&rpc_url, CommitmentConfig::confirmed());

    let pubkey = Pubkey::from_str(&mint_address).context("MINT_ADDRESS_2022 不是合法的公钥")?;
    let account = rpc_client
        .get_account(&pubkey)
        .context("获取账户失败，请检查地址和网络")?;
    println!("Account data: {:?}", account);
    let state = StateWithExtensions::<Mint>::unpack(&account.data)?;

    println!("=== Mint === {:?}", state);
    // 解析 MetadataPointer
    match state.get_extension::<MetadataPointer>() {
        Ok(pointer) => {
            println!("\n=== MetadataPointer ===");
            println!("元数据权限: {:?}", pointer.authority);
            println!("元数据地址: {:?}", pointer.metadata_address);
        }
        Err(_) => println!("\nMetadataPointer 扩展不存在"),
    }

    // 解析 TokenMetadata
    // --- 这里是修复的关键部分 ---
    // 解析 TokenMetadata (非 Pod 类型)
    // 1. 使用 get_extension_bytes 获取原始字节
    // 2. 使用 TokenMetadata::unpack 手动解析字节
    match state.get_extension_bytes::<TokenMetadata>() {
        Ok(bytes) => {
            let metadata = TokenMetadata::try_from_slice(bytes)?;
            println!("\n=== TokenMetadata (使用 get_extension_bytes + from_bytes) ===");
            println!("更新权限: {:?}", metadata.update_authority);
            println!("Mint: {:?}", metadata.mint);
            println!("名称: {}", metadata.name);
            println!("符号: {}", metadata.symbol);
            println!("URI: {}", metadata.uri);
            println!("额外元数据:");
            for (key, value) in &metadata.additional_metadata {
                println!("  - {}: {}", key, value);
            }
            println!("额外元数据数量: {}", metadata.additional_metadata.len());
        }
        Err(_) => println!("\nTokenMetadata 扩展不存在"),
    }

    Ok(())
}

```

### 代码整体功能

**本程序用于：**

- 读取环境变量中的 SPL Token 2022 Mint 地址和 Solana RPC 节点地址
- 连接到指定的 Solana 节点（默认 Devnet）
- 获取该 Mint 账户的链上数据
- 解析并打印 Mint 的基本信息、MetadataPointer 扩展和 TokenMetadata 扩展（包括名称、符号、URI、额外元数据等）

### 主要流程分解

##### 1. 依赖和导入

```rust
use anchor_client::{...};
use anchor_lang::declare_program;
use anyhow::Context;
use borsh::BorshDeserialize;
use spl_token_2022::extension::metadata_pointer::MetadataPointer;
use spl_token_2022::extension::{BaseStateWithExtensions, StateWithExtensions};
use spl_token_2022::state::Mint;
use spl_token_metadata_interface::state::TokenMetadata;
use std::str::FromStr;
```

- 引入了 Anchor、Solana、SPL Token 2022、Token Metadata、Borsh 反序列化等相关库。

---

##### 2. 读取环境变量

```rust
dotenvy::dotenv()?;
let mint_address = dotenvy::var("MINT_ADDRESS_2022").context("请在 .env 文件中设置 MINT_ADDRESS_2022")?;
let rpc_url = dotenvy::var("RPC_URL").unwrap_or_else(|_| Cluster::Devnet.url().to_string());
let safe_url = rpc_url.split('?').next().unwrap_or("");
println!("使用的 RPC URL: {}", safe_url);
```

- 读取 `.env` 文件，获取 Mint 地址和 RPC 节点地址。
- 如果没有设置 RPC_URL，则默认使用 Devnet。
- 打印时只显示问号 `?` 前面的 URL，防止泄露 API Key 等敏感参数。

---

##### 3. 连接 Solana 节点

```rust
let rpc_client = RpcClient::new_with_commitment(&rpc_url, CommitmentConfig::confirmed());
```

- 创建 RPC 客户端，连接到指定的 Solana 节点。

---

##### 4. 获取 Mint 账户数据

```rust
let pubkey = Pubkey::from_str(&mint_address).context("MINT_ADDRESS_2022 不是合法的公钥")?;
let account = rpc_client.get_account(&pubkey).context("获取账户失败，请检查地址和网络")?;
println!("Account data: {:?}", account);
let state = StateWithExtensions::<Mint>::unpack(&account.data)?;
println!("=== Mint === {:?}", state);
```

- 将 Mint 地址字符串转为公钥类型。
- 获取该账户的链上数据。
- 解析为带扩展的 Mint 账户结构体。

---

##### 5. 解析 MetadataPointer 扩展

```rust
match state.get_extension::<MetadataPointer>() {
    Ok(pointer) => {
        println!("\n=== MetadataPointer ===");
        println!("元数据权限: {:?}", pointer.authority);
        println!("元数据地址: {:?}", pointer.metadata_address);
    }
    Err(_) => println!("\nMetadataPointer 扩展不存在"),
}
```

- 尝试解析 Mint 账户的 MetadataPointer 扩展（如果有）。
- 打印元数据权限和元数据地址。

---

##### 6. 解析 TokenMetadata 扩展

```rust
match state.get_extension_bytes::<TokenMetadata>() {
    Ok(bytes) => {
        let metadata = TokenMetadata::try_from_slice(bytes)?;
        println!("\n=== TokenMetadata (使用 get_extension_bytes + from_bytes) ===");
        println!("更新权限: {:?}", metadata.update_authority);
        println!("Mint: {:?}", metadata.mint);
        println!("名称: {}", metadata.name);
        println!("符号: {}", metadata.symbol);
        println!("URI: {}", metadata.uri);
        println!("额外元数据:");
        for (key, value) in &metadata.additional_metadata {
            println!("  - {}: {}", key, value);
        }
        println!("额外元数据数量: {}", metadata.additional_metadata.len());
    }
    Err(_) => println!("\nTokenMetadata 扩展不存在"),
}
```

- 由于 TokenMetadata 不是 POD 类型，先获取原始字节，再用 Borsh 反序列化。
- 打印 Token 的 update authority、mint、公链名称、符号、URI 以及额外元数据（如有）。

---

##### 7. 错误处理

- 代码大量使用了 `anyhow::Context`，在出错时能给出更友好的提示，方便定位问题。

#### 适用场景

- 查询和调试 SPL Token 2022 的 Mint 账户扩展信息
- 检查链上 Token 的元数据内容
- 开发和测试 SPL Token 2022 相关功能

#### 你可以自定义的地方

- `.env` 文件中配置不同的 Mint 地址和 RPC 节点
- 代码结构可以进一步封装成函数，便于复用
- 可以扩展支持命令行参数、更多扩展类型等

### 编译构建项目

```bash
solana-sandbox/solana-data-demo on  main [?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo build
   Compiling solana-data-demo v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/solana-data-demo)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 4.28s
```

### 运行项目

```bash
solana-sandbox/solana-data-demo on  main [?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 4.4s 
➜ cargo run  
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.71s
     Running `target/debug/solana-data-demo`
使用的 RPC URL: https://devnet.helius-rpc.com/
Account data: Account { lamports: 3695760, data.len: 403, owner: TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb, executable: false, rent_epoch: 18446744073709551615, data: 010000004f8e79c1003c7aa7f93a5cf37105d0c9cd65d9f50b561eb445e66e337f08cba600f81b1d000100000901000000000000000000000000000000000000 }
=== Mint === StateWithExtensions { base: Mint { mint_authority: Some(6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd), supply: 1100000000000, decimals: 9, is_initialized: true, freeze_authority: None }, tlv_data: [18, 0, 64, 0, 79, 142, 121, 193, 0, 60, 122, 167, 249, 58, 92, 243, 113, 5, 208, 201, 205, 101, 217, 245, 11, 86, 30, 180, 69, 230, 110, 51, 127, 8, 203, 166, 35, 216, 95, 95, 172, 228, 202, 235, 242, 199, 79, 217, 234, 240, 244, 99, 194, 200, 105, 242, 200, 164, 112, 193, 136, 199, 235, 171, 57, 39, 97, 208, 19, 0, 165, 0, 79, 142, 121, 193, 0, 60, 122, 167, 249, 58, 92, 243, 113, 5, 208, 201, 205, 101, 217, 245, 11, 86, 30, 180, 69, 230, 110, 51, 127, 8, 203, 166, 35, 216, 95, 95, 172, 228, 202, 235, 242, 199, 79, 217, 234, 240, 244, 99, 194, 200, 105, 242, 200, 164, 112, 193, 136, 199, 235, 171, 57, 39, 97, 208, 10, 0, 0, 0, 80, 97, 120, 111, 110, 84, 111, 107, 101, 110, 3, 0, 0, 0, 80, 84, 75, 72, 0, 0, 0, 104, 116, 116, 112, 115, 58, 47, 47, 103, 105, 115, 116, 46, 103, 105, 116, 104, 117, 98, 46, 99, 111, 109, 47, 113, 105, 97, 111, 112, 101, 110, 103, 106, 117, 110, 53, 49, 54, 50, 47, 48, 55, 99, 97, 48, 102, 97, 51, 50, 52, 54, 57, 55, 101, 48, 98, 100, 102, 53, 98, 50, 49, 100, 100, 50, 49, 100, 52, 51, 49, 48, 49, 0, 0, 0, 0] }

=== MetadataPointer ===
元数据权限: OptionalNonZeroPubkey(6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd)
元数据地址: OptionalNonZeroPubkey(3QvdZgaBcoqeDrPWVGFaHmo2KCyQfKVQc5J3ygnt3C9M)

=== TokenMetadata (使用 get_extension_bytes + from_bytes) ===
更新权限: OptionalNonZeroPubkey(6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd)
Mint: 3QvdZgaBcoqeDrPWVGFaHmo2KCyQfKVQc5J3ygnt3C9M
名称: PaxonToken
符号: PTK
URI: https://gist.github.com/qiaopengjun5162/07ca0fa324697e0bdf5b21dd21d43101
额外元数据:
额外元数据数量: 0
```

![7b8fd4c77198554fe556efe92e89f8f1](/images/7b8fd4c77198554fe556efe92e89f8f1.png)

## 总结

通过本教程，我们成功搭建并运行了一个基于 Rust 的 Solana 程序，用于查询 SPL Token 2022 的链上元数据。这个项目展示了 Solana 生态的强大功能，以及 Rust 和 Anchor 在区块链开发中的高效应用。你可以基于此进一步扩展功能，例如添加命令行参数、支持更多扩展类型，或集成到更大的 Web3 项目中。快来动手实践，探索 Solana 的无限可能吧！

## 参考

- <https://www.anchor-lang.com/docs/tokens/basics/transfer-tokens>
- <https://solana.com/zh/docs>
- <https://soldev.cn/>
- <https://solscan.io/>
- <https://www.anchor-lang.com/>
