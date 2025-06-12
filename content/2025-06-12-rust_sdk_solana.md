+++
title = "探索Solana SDK实战：Web3开发的双路径与轻量模块化"
description = "探索Solana SDK实战：Web3开发的双路径与轻量模块化"
date = 2025-06-12T00:44:17Z
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# 探索Solana SDK实战：Web3开发的双路径与轻量模块化

Web3的热潮席卷全球，Solana以其高吞吐量和低成本成为开发者构建去中心化应用的首选平台，而Solana SDK则是释放其潜力的核心工具。你是否知道，除了常见的开发方式，还有一种鲜为人知的轻量模块化路径，能让智能合约开发更高效？本文通过实战，带你探索Solana SDK的两种开发路径：稳健的单一依赖方式和依赖更轻、灵活性更高的模块化方式。从环境搭建到代码编写、测试再到本地部署，这篇干货教程将助你快速掌握Web3 Solana开发的精髓，开启区块链创新之旅！

本文以Rust语言为工具，通过实战方式深入探索Solana SDK在Web3智能合约开发中的两种路径：单一依赖方式（基于solana-program）和鲜为人知的轻量模块化方式（基于solana-account-info等精简模块）。轻量模块化方式以更少的依赖提升开发效率，却鲜为开发者所知。文章详细覆盖环境配置、项目初始化、代码实现、测试用例编写及本地Solana集群部署，通过清晰的代码示例和命令操作，帮助开发者快速上手Web3 Solana开发全流程，解锁区块链应用新可能。

## 实操

### 前提

```bash
anchor --version
anchor-cli 0.31.1

rustc --version
rustc 1.89.0-nightly (d13a431a6 2025-06-09)

solana --version
solana-cli 2.1.22 (src:26944979; feat:1416569292, client:Agave)
```

### 创建并切换到项目目录

```bash
mcd sol-program # mkdir sol-program && cd sol-program
```

### 初始化项目

```bash
cargo init --lib
```

### 安装依赖

```bash
cargo add solana-program
```

### 查看项目目录

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ tree . -L 6 -I "coverage_report|lib|.vscode|out|lcov.info|target|node_modules"
.
├── Cargo.lock
├── Cargo.toml
└── src
    └── lib.rs

2 directories, 3 files

```

### 第一种方式 使用 solana_program 单一依赖方式

#### lib1.rs 文件

```rust
#![allow(unexpected_cfgs)]

use solana_program::entrypoint;
use solana_program::{account_info::AccountInfo, entrypoint::ProgramResult, msg, pubkey::Pubkey};

entrypoint!(process_instruction);

pub fn process_instruction(
    _program_id: &Pubkey,
    _accounts: &[AccountInfo],
    _instruction_data: &[u8],
) -> ProgramResult {
    msg!("Hello, world!");
    Ok(())
}

```

### Cargo1.toml 文件

```toml
cargo-features = ["edition2024"]

[package]
name = "sol-program"
version = "0.1.0"
edition = "2024"

[lib]
crate-type = ["cdylib", "lib"]

[dependencies]
solana-program = "2.3.0"

```

### 第二种方式 模块化依赖方式

#### lib2.rs 文件

```rust
#![allow(unexpected_cfgs)]

use solana_account_info::AccountInfo;
use solana_msg::msg;
use solana_program_entrypoint::entrypoint;
use solana_program_error::ProgramResult;
use solana_pubkey::Pubkey;

entrypoint!(process_instruction);

pub fn process_instruction(
    _program_id: &Pubkey,
    _accounts: &[AccountInfo],
    _instruction_data: &[u8],
) -> ProgramResult {
    msg!("Hello, world!");
    Ok(())
}

```

#### Cargo2.toml 文件

```bash
cargo-features = ["edition2024"]

[package]
name = "sol-program"
version = "0.1.0"
edition = "2024"

[lib]
crate-type = ["cdylib", "lib"]

[dependencies]
solana-account-info = "2.3.0"
solana-msg = "2.2.1"
solana-program-entrypoint = "2.3.0"
solana-program-error = "2.2.2"
solana-pubkey = "2.4.0"

```

### 编译构建

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 2.9s 
➜ cargo build-sbf
    Finished `release` profile [optimized] target(s) in 0.04s
```

### 查看程序ID

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ solana address -k ./target/deploy/sol_program-keypair.json
GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA

```

## 第一种方式测试

#### 安装相关依赖

```bash
cargo add solana-sdk@2.2.2 --dev  
cargo add solana-program-test@2.2.7 --dev  
cargo add tokio --dev
```

#### 查看 Cargo.toml 文件

```toml
cargo-features = ["edition2024"]

[package]
name = "sol-program"
version = "0.1.0"
edition = "2024"

[lib]
crate-type = ["cdylib", "lib"]

[dependencies]
# solana-account-info = "2.3.0"
# solana-msg = "2.2.1"
# solana-program-entrypoint = "2.3.0"
# solana-program-error = "2.2.2"
# solana-pubkey = "2.4.0"

solana-program = "2.2.1"

[dev-dependencies]
solana-program-test = "2.2.7"
solana-sdk = "2.2.2"
tokio = "1.45.1"

```

#### 编写测试 lib1.rs

```rust
#![allow(unexpected_cfgs)]

use solana_program::entrypoint;
use solana_program::{account_info::AccountInfo, entrypoint::ProgramResult, msg, pubkey::Pubkey};

entrypoint!(process_instruction);

pub fn process_instruction(
    _program_id: &Pubkey,
    _accounts: &[AccountInfo],
    _instruction_data: &[u8],
) -> ProgramResult {
    msg!("Hello, world!");
    Ok(())
}

#[cfg(test)]
mod test {
    use solana_program_test::*;
    use solana_sdk::{
        instruction::Instruction, pubkey::Pubkey, signature::Signer, transaction::Transaction,
    };

    #[tokio::test]
    async fn test_sol_program() {
        let program_id = Pubkey::new_unique();
        let mut program_test = ProgramTest::default();
        program_test.add_program("sol_program", program_id, None);
        let (banks_client, payer, recent_blockhash) = program_test.start().await;
        // Create instruction
        let instruction = Instruction {
            program_id,
            accounts: vec![],
            data: vec![],
        };
        // Create transaction with instruction
        let mut transaction = Transaction::new_with_payer(&[instruction], Some(&payer.pubkey()));

        // Sign transaction
        transaction.sign(&[&payer], recent_blockhash);

        let transaction_result = banks_client.process_transaction(transaction).await;
        assert!(transaction_result.is_ok());
    }
}

```

#### 运行测试

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo test-sbf 
    Finished `release` profile [optimized] target(s) in 0.28s
warning: the cargo feature `edition2024` has been stabilized in the 1.85 release and is no longer necessary to be listed in the manifest
  See https://doc.rust-lang.org/nightly/cargo/reference/manifest.html#the-edition-field for more information about using this feature.
   Compiling sol-program v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/sol-program)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 2.50s
     Running unittests src/lib.rs (target/debug/deps/sol_program-122e9aa47c8c7013)

running 1 test
[2025-06-11T14:33:48.804957000Z INFO  solana_program_test] "sol_program" SBF program from /Users/qiaopengjun/Code/Solana/solana-sandbox/sol-program/target/deploy/sol_program.so, modified 7 seconds, 33 ms, 291 µs and 468 ns ago
[2025-06-11T14:33:48.924752000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM invoke [1]
[2025-06-11T14:33:48.925299000Z DEBUG solana_runtime::message_processor::stable_log] Program log: Hello, world!
[2025-06-11T14:33:48.925316000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM consumed 137 of 200000 compute units
[2025-06-11T14:33:48.925329000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM success
test test::test_sol_program ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.23s

   Doc-tests sol_program

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

**测试成功**！

## 第二种方式测试

### lib2.rs 文件

```rust
#![allow(unexpected_cfgs)]

use solana_account_info::AccountInfo;
use solana_msg::msg;
use solana_program_entrypoint::entrypoint;
use solana_program_error::ProgramResult;
use solana_pubkey::Pubkey;

entrypoint!(process_instruction);

pub fn process_instruction(
    _program_id: &Pubkey,
    _accounts: &[AccountInfo],
    _instruction_data: &[u8],
) -> ProgramResult {
    msg!("Hello, world!");
    Ok(())
}

#[cfg(test)]
mod test {
    use solana_program_test::*;
    use solana_sdk::{
        instruction::Instruction, pubkey::Pubkey, signature::Signer, transaction::Transaction,
    };

    #[tokio::test]
    async fn test_sol_program() {
        let program_id = Pubkey::new_unique();
        let mut program_test = ProgramTest::default();
        program_test.add_program("sol_program", program_id, None);
        let (banks_client, payer, recent_blockhash) = program_test.start().await;
        // Create instruction
        let instruction = Instruction {
            program_id,
            accounts: vec![],
            data: vec![],
        };
        // Create transaction with instruction
        let mut transaction = Transaction::new_with_payer(&[instruction], Some(&payer.pubkey()));

        // Sign transaction
        transaction.sign(&[&payer], recent_blockhash);

        let transaction_result = banks_client.process_transaction(transaction).await;
        assert!(transaction_result.is_ok());
    }
}

```

### Cargo2.toml 文件

```toml
cargo-features = ["edition2024"]

[package]
name = "sol-program"
version = "0.1.0"
edition = "2024"

[lib]
crate-type = ["cdylib", "lib"]

[dependencies]
solana-account-info = "2.2.1"
solana-msg = "2.2.1"
solana-program-entrypoint = "2.2.1"
solana-program-error = "2.2.2"
solana-pubkey = "2.2.1"

# solana-program = "2.2.1"

[dev-dependencies]
solana-program-test = "2.2.7"
solana-sdk = "2.2.2"
tokio = "1.45.1"

```

### 执行测试

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 14.4s 
➜ cargo build-sbf
    Finished `release` profile [optimized] target(s) in 0.31s

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo test-sbf 
    Finished `release` profile [optimized] target(s) in 0.13s
warning: the cargo feature `edition2024` has been stabilized in the 1.85 release and is no longer necessary to be listed in the manifest
  See https://doc.rust-lang.org/nightly/cargo/reference/manifest.html#the-edition-field for more information about using this feature.
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.42s
     Running unittests src/lib.rs (target/debug/deps/sol_program-13ec2ee4753dc858)

running 1 test
[2025-06-11T14:39:08.159327000Z INFO  solana_program_test] "sol_program" SBF program from /Users/qiaopengjun/Code/Solana/solana-sandbox/sol-program/target/deploy/sol_program.so, modified 30 seconds, 215 ms, 820 µs and 195 ns ago
[2025-06-11T14:39:08.260645000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM invoke [1]
[2025-06-11T14:39:08.260985000Z DEBUG solana_runtime::message_processor::stable_log] Program log: Hello, world!
[2025-06-11T14:39:08.261011000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM consumed 137 of 200000 compute units
[2025-06-11T14:39:08.261026000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM success
test test::test_sol_program ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.22s

   Doc-tests sol_program

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s
```

**测试成功啦！**

## 部署程序

### 配置 Solana CLI 以使用本地 Solana 集群

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ solana config set -ul
Config File: /Users/qiaopengjun/.config/solana/cli/config.yml
RPC URL: http://localhost:8899 
WebSocket URL: ws://localhost:8900/ (computed)
Keypair Path: /Users/qiaopengjun/.config/solana/id.json 
Commitment: confirmed 

```

### 启动本地节点

运行 `solana-test-validators` 命令以启动本地 validator。

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ solana-test-validator -r                            
Ledger location: test-ledger
Log: test-ledger/validator.log
⠖ Initializing...                                                                                                                                                           Waiting for fees to stabilize 1...
Identity: GRmwToAoYuAVYgZfk31fyfB66NHXRX1Qg7ttQ6ay7L2L
Genesis Hash: B8RESDBPtkvs2TNx4J7eWJXFjJcEEBizC59BF49cjzzA
Version: 2.1.22
Shred Version: 721
Gossip Address: 127.0.0.1:1024
TPU Address: 127.0.0.1:1027
JSON RPC URL: http://127.0.0.1:8899
WebSocket PubSub URL: ws://127.0.0.1:8900
⠐ 00:02:27 | Processed Slot: 309 | Confirmed Slot: 309 | Finalized Slot: 278 | Full Snapshot Slot: 200 | Incremental Snapshot Slot: - | Transactions: 328 | ◎499.998515000  

```

### 部署程序

将程序部署到本地 validator。

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ solana program deploy ./target/deploy/sol_program.so
Program Id: GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA

Signature: 4SVw5ERKsa2VkRfXxhBxzk7fobzWtHBQY9z6p84u5AVXfFjDacuPr19AUCorck3jiBxK1Qk1Pv5Bb18WiGsSTeWT

```

## 总结

通过本次实战探索，你已全面掌握Solana SDK的两种Web3开发路径！单一依赖方式稳健可靠，轻量模块化方式则以高效灵活脱颖而出，尤其适合追求极致效率的开发者。从环境搭建到本地部署，每一步都为你铺就Web3开发的坚实道路。Solana的超高性能结合Rust的强大功能，未来可期。立即动手实践，用轻量模块化方式开发更复杂的智能合约，或结合Anchor框架探索零拷贝特性，打造属于你的Web3创新传奇！

## 参考

- <https://solana.com/zh/docs/clients/rust>
- <https://docs.rs/solana-program/latest/solana_program/>
- <https://docs.rs/solana-sdk/latest/solana_sdk/>
- <https://github.com/anza-xyz/solana-sdk>
- <https://solana.com/zh/docs/rpc>
- <https://solana.com/zh/docs/programs/rust>
- <https://www.anchor-lang.com/docs/features/zero-copy>
