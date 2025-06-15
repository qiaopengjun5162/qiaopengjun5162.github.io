+++
title = "Solana 开发实战：Rust 客户端调用链上程序全流程"
description = "Solana 开发实战：Rust 客户端调用链上程序全流程"
date = 2025-06-15T03:23:33Z
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# Solana 开发实战：Rust 客户端调用链上程序全流程

继《探索 Solana SDK 实战：Web3 开发的双路径与轻量模块化》带您了解 Solana 开发的基础后，本篇将深入实战，聚焦如何使用 Rust 客户端与 Solana 链上程序交互。无论您是想快速上手区块链开发，还是希望掌握 Solana 的高性能潜力，本文都为您提供清晰的步骤和可复现的代码。从项目配置到程序部署，再到交易调用，我们将一步步揭开 Rust 在 Solana 开发中的强大魅力，助您加速迈向 Web3 开发前沿！

本文通过详细的 Rust 客户端开发流程，展示了如何在 Solana 区块链上调用链上程序。内容涵盖项目环境搭建、依赖配置、客户端脚本实现、本地验证节点运行、程序部署及关闭等全流程。基于 solana-client 库，通过创建 keypair、请求空投、构造交易等操作，读者可以轻松复现一个完整的 Solana 交互示例。本文适合对 Solana 和 Rust 开发感兴趣的开发者，提供实用代码和操作指引，是进阶 Web3 开发的理想参考。

## 实操

### 查看当前项目目录

```bash
solana-sandbox/sol-program on  main [?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ tree . -L 6 -I "coverage_report|lib|.vscode|out|test-ledger|target|node_modules"
.
├── Cargo.lock
├── Cargo.toml
└── src
    ├── lib.rs
    └── lib2.rs

2 directories, 4 files
```

### 创建一个 `examples` 目录和一个 `client.rs` 文件

```bash
solana-sandbox/sol-program on  main [?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ mkdir -p examples
touch examples/client.rs

```

### 将以下内容添加到 `Cargo.toml`

```bash
[[example]]
name = "client"
path = "examples/client.rs"
```

### 添加相关依赖项

```bash
solana-sandbox/sol-program on  main [?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo add solana-client --dev        
    Updating crates.io index
      Adding solana-client v2.2.7 to dev-dependencies

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 2.6s 
➜ cargo add solana-native-token@2.2.1 --dev
    Updating crates.io index
      Adding solana-native-token v2.2.1 to dev-dependencies
      
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo add anyhow                         
    Updating crates.io index
      Adding anyhow v1.0.98 to dependencies
             Features:
             + std
             - backtrace

```

### 查看 Cargo.toml

```toml
cargo-features = ["edition2024"]

[package]
name = "sol-program"
version = "0.1.0"
edition = "2024"

[lib]
crate-type = ["cdylib", "lib"]

[[example]]
name = "client"
path = "examples/client.rs"

[dependencies]
solana-account-info = "2.2.1"
solana-msg = "2.2.1"
solana-program-entrypoint = "2.2.1"
solana-program-error = "2.2.2"
solana-pubkey = "2.2.1"

# solana-program = "2.2.1"

[dev-dependencies]
solana-client = "2.2.7"
solana-program-test = "2.2.7"
solana-sdk = "2.2.2"
tokio = "1.45.1"

```

### 实现 examples/client.rs

```rust
use anyhow::Result;
use solana_client::rpc_client::RpcClient;
use solana_native_token::LAMPORTS_PER_SOL;
use solana_sdk::{
    commitment_config::CommitmentConfig,
    instruction::Instruction,
    pubkey::Pubkey,
    signature::{Keypair, Signer},
    transaction::Transaction,
};
use std::str::FromStr;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let program_id = Pubkey::from_str("GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA")?;

    let rpc_url = String::from("http://127.0.0.1:8899");
    let commitment_config = CommitmentConfig::confirmed();
    let rpc_client = RpcClient::new_with_commitment(rpc_url, commitment_config);

    let keypair = Keypair::new();
    println!("Keypair: {}", keypair.pubkey());

    println!("Requesting airdrop...");
    let signature = rpc_client
        .request_airdrop(&keypair.pubkey(), 2 * LAMPORTS_PER_SOL)
        .expect("Failed to request airdrop");
    loop {
        let confirmed =
            rpc_client.confirm_transaction_with_commitment(&signature, commitment_config)?;
        if confirmed.value {
            break;
        }
    }

    let instruction = Instruction::new_with_borsh(program_id, &(), vec![]);

    let mut transaction = Transaction::new_with_payer(&[instruction], Some(&keypair.pubkey()));
    transaction.sign(&[&keypair], rpc_client.get_latest_blockhash()?);

    match rpc_client.send_and_confirm_transaction(&transaction) {
        Ok(signature) => println!("Transaction Signature: {}", signature),
        Err(err) => eprintln!("Error sending transaction: {}", err),
    }
    Ok(())
}

```

这是一个 Rust 客户端脚本，用于为新的 keypair 提供资金以支付交易费用，然后调用 sol_program 程序。

### 启动本地验证节点

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ solana-test-validator -r                            
Ledger location: test-ledger
Log: test-ledger/validator.log
⠈ Initializing...                                                                                                                                                          Waiting for fees to stabilize 1...
Identity: nTSnjt8VZY9M74QaeAWi7oW6gChLKwRGUgATpw5qMU7
Genesis Hash: EzBss1P6qHe74g8WcZGmeu1MfEtxZiE48c7ogQEtWfXu
Version: 2.1.22
Shred Version: 9856
Gossip Address: 127.0.0.1:1024
TPU Address: 127.0.0.1:1027
JSON RPC URL: http://127.0.0.1:8899
WebSocket PubSub URL: ws://127.0.0.1:8900
⠉ 00:00:11 | Processed Slot: 23 | Confirmed Slot: 23 | Finalized Slot: 0 | Full Snapshot Slot: - | Incremental Snapshot Slot: - | Transactions: 22 | ◎499.999890000        
```

### 编译测试部署

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 2.7s 
➜ cargo build-sbf
    Finished `release` profile [optimized] target(s) in 0.20s

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo test-sbf 
    Finished `release` profile [optimized] target(s) in 0.15s
warning: the cargo feature `edition2024` has been stabilized in the 1.85 release and is no longer necessary to be listed in the manifest
  See https://doc.rust-lang.org/cargo/reference/manifest.html#the-edition-field for more information about using this feature.
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.50s
     Running unittests src/lib.rs (target/debug/deps/sol_program-08f16897dcbb8ceb)

running 1 test
[2025-06-14T14:09:00.591057000Z INFO  solana_program_test] "sol_program" SBF program from /Users/qiaopengjun/Code/Solana/solana-sandbox/sol-program/target/deploy/sol_program.so, modified 2 minutes, 57 seconds, 791 ms, 306 µs and 863 ns ago
[2025-06-14T14:09:00.688000000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM invoke [1]
[2025-06-14T14:09:00.688713000Z DEBUG solana_runtime::message_processor::stable_log] Program log: Hello, Solana!
[2025-06-14T14:09:00.690443000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM consumed 137 of 200000 compute units
[2025-06-14T14:09:00.690471000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM success
test test::test_sol_program ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.22s

   Doc-tests sol_program

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s


solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ solana config set -ul
Config File: /Users/qiaopengjun/.config/solana/cli/config.yml
RPC URL: http://localhost:8899 
WebSocket URL: ws://localhost:8900/ (computed)
Keypair Path: /Users/qiaopengjun/.config/solana/id.json 
Commitment: confirmed 

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ solana program deploy ./target/deploy/sol_program.so
Program Id: GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA

Signature: 2khrNAScTpLBJjwQvV4Z5EgVbbZME12QyAtsHrz4gKNzqDcJaXr5P2kDopWCnQBCsmDA7ycq8P2nbsurA1Fu9AqW

```

### 查询程序ID

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ solana address -k ./target/deploy/sol_program-keypair.json
GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA

```

### 运行客户端脚本

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo run --example client                               
warning: the cargo feature `edition2024` has been stabilized in the 1.85 release and is no longer necessary to be listed in the manifest
  See https://doc.rust-lang.org/cargo/reference/manifest.html#the-edition-field for more information about using this feature.
   Compiling sol-program v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/sol-program)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 3.10s
     Running `target/debug/examples/client`
Keypair: 5NkBWXrxkFy6B5r4X9NMcA3edN8CRvJqjz2jFpcJDBKg
Requesting airdrop...
Transaction Signature: 2Ya4oev7cgGKvLMTq4zcVyjSbz72iuxhDdXf6iBfJQDQv4WFoLfG3RnYv31AnkmBxNYBYM4ZNn9xTbux6KGuRfUx

```

### 关闭程序

关闭 Solana 程序以回收分配给账户的 SOL。关闭程序是不可逆的操作，因此应谨慎进行。

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 2.3s 
➜ solana program close GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA --bypass-warning

Closed Program Id GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA, 0.12492504 SOL reclaimed

```

## 总结

通过本文的实战演练，您已掌握使用 Rust 客户端调用 Solana 链上程序的核心技能，从环境配置到交易执行，再到安全关闭程序回收 SOL，完整流程一气呵成。Solana 的高吞吐量与 Rust 的安全性为区块链开发提供了无限可能，结合我们之前的《探索 Solana SDK 实战》，您已具备从基础到进阶的开发能力。期待您将这些知识应用于实际项目，打造属于自己的 Web3 应用！请继续关注我们的系列文章，更多 Solana 开发干货即将上线！

## 参考

- <https://spl.solana.com/token#example-transferring-tokens-to-an-explicit-recipient-token-account>
- <https://docs.rs/solana-native-token/latest/solana_native_token/>
- <https://crates.io/crates/solana-native-token>
- <https://explorer.solana.com/>
- <https://solscan.io/?cluster=devnet>
