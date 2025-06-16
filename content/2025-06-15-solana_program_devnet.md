+++
title = "Solana 开发进阶：在 Devnet 上实现链上程序部署、调用与更新"
description = "Solana 开发进阶：在 Devnet 上实现链上程序部署、调用与更新"
date = 2025-06-15T12:04:54Z
[taxonomies]
categories = ["Solana", "Web3"]
tags = ["Solana", "Web3"]
+++

<!-- more -->

# Solana 开发进阶：在 Devnet 上实现链上程序部署、调用与更新

Solana 以其高性能和低成本的特性，成为 Web3 开发的热门选择。本文是 Solana 开发系列的延续，基于前两篇《探索 Solana SDK 实战：Web3 开发的双路径与轻量模块化》和《Solana 开发实战：Rust 客户端调用链上程序全流程》的内容，带领读者迈向更贴近生产环境的实践——在 Solana 的 Devnet 网络中部署、调用和更新链上程序。通过详细的代码示例和操作步骤，本文将帮助开发者从本地开发过渡到 Devnet 实战，掌握 Solana 链上开发的完整流程。

继本地开发实践后，本文通过 Solana 的 Devnet 网络，深入展示链上程序开发的进阶流程，涵盖密钥对生成、程序部署、客户端调用、程序更新及测试优化。开发者将学习如何使用 solana-keygen grind 创建特定前缀的钱包地址，部署 Rust 程序到 Devnet，利用 Rust 客户端实现链上交互，并更新程序以添加日志和事件功能。文章还对比了 start_with_context 与 start、以及 process_transaction 与 process_transaction_with_metadata 的使用场景，为优化测试提供指导。结合代码、命令行和 Solana 浏览器验证，本文为开发者提供从本地到 Devnet 的实用进阶指南。

## 实操

### 生成指定**Solana 密钥对**

使用 `solana-keygen grind` 生成一个以指定前缀 `SS` 开头的 Solana 钱包地址，并将私钥保存到当前目录的 `.json` 文件中。

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 10.6s 
➜ mkdir keys    

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ cd keys     

solana-sandbox/sol-program/keys on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ solana-keygen grind --starts-with SS:1 
Searching with 12 threads for:
        1 pubkey that starts with 'SS' and ends with ''
Wrote keypair to SSoyAkBN9E3CjbWpr2SdgLa6Ejbqqdvasuxd8j1YsmN.json
```

### 查看目录结构

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ tree . -L 6 -I "coverage_report|lib|.vscode|out|test-ledger|target|node_modules"
.
├── Cargo.lock
├── Cargo.toml
├── examples
│   └── client.rs
├── keys
│   └── SSoyAkBN9E3CjbWpr2SdgLa6Ejbqqdvasuxd8j1YsmN.json
└── src
    ├── lib.rs
    └── lib2.rs

4 directories, 6 files
```

### lib.rs 文件

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

### 部署程序

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ solana config get                                                                                                               
Config File: /Users/qiaopengjun/.config/solana/cli/config.yml
RPC URL: http://localhost:8899 
WebSocket URL: ws://localhost:8900/ (computed)
Keypair Path: /Users/qiaopengjun/.config/solana/id.json 
Commitment: confirmed 

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ solana config set -ud
Config File: /Users/qiaopengjun/.config/solana/cli/config.yml
RPC URL: https://api.devnet.solana.com 
WebSocket URL: wss://api.devnet.solana.com/ (computed)
Keypair Path: /Users/qiaopengjun/.config/solana/id.json 
Commitment: confirmed 

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo build-sbf                                            
    Updating crates.io index
  Downloaded dotenvy v0.15.7
  Downloaded 1 crate (20.3 KB) in 0.47s
   Compiling dotenvy v0.15.7
   Compiling sol-program v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/sol-program)
    Finished `release` profile [optimized] target(s) in 2.44s

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 3.6s 
➜ cargo test-sbf 
    Finished `release` profile [optimized] target(s) in 0.38s
warning: the cargo feature `edition2024` has been stabilized in the 1.85 release and is no longer necessary to be listed in the manifest
  See https://doc.rust-lang.org/cargo/reference/manifest.html#the-edition-field for more information about using this feature.
   Compiling dotenvy v0.15.7
   Compiling sol-program v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/sol-program)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 3.32s
     Running unittests src/lib.rs (target/debug/deps/sol_program-f9b148b856b1f087)

running 1 test
[2025-06-15T04:17:33.483947000Z INFO  solana_program_test] "sol_program" SBF program from /Users/qiaopengjun/Code/Solana/solana-sandbox/sol-program/target/deploy/sol_program.so, modified 23 seconds, 153 ms, 687 µs and 422 ns ago
[2025-06-15T04:17:33.615883000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM invoke [1]
[2025-06-15T04:17:33.616384000Z DEBUG solana_runtime::message_processor::stable_log] Program log: Hello, Solana!
[2025-06-15T04:17:33.618020000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM consumed 137 of 200000 compute units
[2025-06-15T04:17:33.618034000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM success
test test::test_sol_program ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.24s

   Doc-tests sol_program

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 6.1s 
➜ solana airdrop 5                                          
Requesting airdrop of 5 SOL

Signature: 2z2Z9J9swicDcbLHeajCkwwM9C2BXZypLFpk9Fh4pQxQutnRqiuTuxAGuVTJz2qWF6hV5WjjTNC8ScF3PLtiuDqj

319.523949256 SOL

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 6.1s 
➜ solana airdrop 5                                          
Requesting airdrop of 5 SOL

Signature: 2z2Z9J9swicDcbLHeajCkwwM9C2BXZypLFpk9Fh4pQxQutnRqiuTuxAGuVTJz2qWF6hV5WjjTNC8ScF3PLtiuDqj

319.523949256 SOL

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 3.2s 
➜ du -h ./target/deploy/sol_program.so 
 20K    ./target/deploy/sol_program.so

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ solana balance                                             
319.523949256 SOL

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ source .env        

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 9.4s 
➜ solana program deploy \
  --program-id ./target/deploy/sol_program-keypair.json \
  ./target/deploy/sol_program.so \
  -u $RPC_URL
Program Id: GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA

Signature: pwhfRtnXwc8kwFfkda1h7ZCRx3H4sGKEHrUbC9MhP4kPeGB8C7y24wcMCi6GMk56z78xQEYNADVpJVViCqXCEZa


```

### 浏览器查看程序

- <https://solscan.io/account/GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA?cluster=devnet>

![image-20250615124222771](/images/image-20250615124222771.png)

- <https://explorer.solana.com/address/GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA?cluster=devnet&customUrl=http%3A%2F%2F127.0.0.1%3A8899>

![image-20250615124304554](/images/image-20250615124304554.png)

### client.rs 文件

```rust
use anyhow::Result;
use dotenvy::dotenv;
use solana_client::rpc_client::RpcClient;
use solana_native_token::LAMPORTS_PER_SOL;
use solana_sdk::{
    commitment_config::CommitmentConfig,
    instruction::Instruction,
    pubkey::Pubkey,
    signature::{Keypair, Signer, read_keypair_file},
    transaction::Transaction,
};
use std::{env, path::Path, str::FromStr};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    dotenv().ok();

    let program_id = Pubkey::from_str("GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA")?;

    // let rpc_url = String::from("http://127.0.0.1:8899");
    let rpc_url =
        env::var("SOLANA_RPC_URL").unwrap_or_else(|_| "http://127.0.0.1:8899".to_string());
    let commitment_config = CommitmentConfig::confirmed();
    let rpc_client = RpcClient::new_with_commitment(rpc_url, commitment_config);

    // let keypair = Keypair::new();
    let keypair = load_keypair("./keys/SSoyAkBN9E3CjbWpr2SdgLa6Ejbqqdvasuxd8j1YsmN.json")?;
    println!("Keypair: {}", keypair.pubkey());

    let balance = rpc_client.get_balance(&keypair.pubkey())?;
    println!("Balance: {} SOL", balance as f64 / LAMPORTS_PER_SOL as f64);
    if balance < LAMPORTS_PER_SOL {
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

        println!("Airdrop received");
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

fn load_keypair(path: &str) -> anyhow::Result<Keypair> {
    if !Path::new(path).exists() {
        anyhow::bail!("Keypair file does not exist: {}", path);
    }
    read_keypair_file(path).map_err(|e| anyhow::anyhow!("Failed to read keypair: {}", e))
}

```

### 调用程序

#### 第一次调用

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo run --example client
warning: the cargo feature `edition2024` has been stabilized in the 1.85 release and is no longer necessary to be listed in the manifest
  See https://doc.rust-lang.org/cargo/reference/manifest.html#the-edition-field for more information about using this feature.
   Compiling sol-program v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/sol-program)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 2.64s
     Running `target/debug/examples/client`
Keypair: SSoyAkBN9E3CjbWpr2SdgLa6Ejbqqdvasuxd8j1YsmN
Balance: 0 SOL
Requesting airdrop...

thread 'main' panicked at examples/client.rs:36:14:
Failed to request airdrop: Error { request: None, kind: RpcError(ForUser("airdrop request failed. This can happen when the rate limit is reached.")) }
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

#### 转账 2 SOl

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ solana transfer SSoyAkBN9E3CjbWpr2SdgLa6Ejbqqdvasuxd8j1YsmN 2 --allow-unfunded-recipient

Signature: rYcjrkJEqfaVBL1d3iYRcHk5hYeYEp2HajsGmKwcpm1MmeVfUSZp7NmMtcrMd2gJdSgrruxXeA2ksXxJmoALHNz


solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 3.5s 
➜ solana balance SSoyAkBN9E3CjbWpr2SdgLa6Ejbqqdvasuxd8j1YsmN                                            
2 SOL

```

#### 再次调用程序

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo run --example client                                                              
warning: the cargo feature `edition2024` has been stabilized in the 1.85 release and is no longer necessary to be listed in the manifest
  See https://doc.rust-lang.org/cargo/reference/manifest.html#the-edition-field for more information about using this feature.
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.82s
     Running `target/debug/examples/client`
Keypair: SSoyAkBN9E3CjbWpr2SdgLa6Ejbqqdvasuxd8j1YsmN
Balance: 2 SOL
Transaction Signature: 5dBVgq32h17BdCX7CMFBZ8xsSDXZSKaEUs5xtL3q3rN6e1qG5v5CUe44BtGvqrcwjE8Bq91YvRA6AtEdJJf7rCm1

```

### 浏览器查看交易详情

- <https://explorer.solana.com/tx/5dBVgq32h17BdCX7CMFBZ8xsSDXZSKaEUs5xtL3q3rN6e1qG5v5CUe44BtGvqrcwjE8Bq91YvRA6AtEdJJf7rCm1?cluster=devnet&customUrl=http%3A%2F%2F127.0.0.1%3A8899>

![image-20250615125705405](/images/image-20250615125705405.png)

- <https://solscan.io/tx/5dBVgq32h17BdCX7CMFBZ8xsSDXZSKaEUs5xtL3q3rN6e1qG5v5CUe44BtGvqrcwjE8Bq91YvRA6AtEdJJf7rCm1?cluster=devnet>

![image-20250615125644674](/images/image-20250615125644674.png)

可以在程序日志中看到 "Hello, Solana!"。

### `src/lib.rs` 更新程序

我们对程序添加日志和事件来进行更新测试。

```rust
#![allow(unexpected_cfgs)]

use borsh_derive::{BorshDeserialize, BorshSerialize};
use solana_account_info::AccountInfo;
use solana_msg::msg;
use solana_program_entrypoint::entrypoint;
use solana_program_error::{ProgramError, ProgramResult};
use solana_pubkey::Pubkey;

// 定义事件结构体
#[derive(BorshDeserialize, BorshSerialize, Debug)]
pub struct GreetingEvent {
    pub message: String, // Greeting message contained in the event
}

// 自定义事件触发函数
fn emit_event(event: &GreetingEvent) -> ProgramResult {
    let event_data = borsh::to_vec(event).map_err(|_| ProgramError::Custom(1))?; // Serialize to byte array
    msg!("EVENT:GREETING:{:?}", event_data); // Output event log
    Ok(())
}

entrypoint!(process_instruction);

pub fn process_instruction(
    _program_id: &Pubkey,
    _accounts: &[AccountInfo],
    _instruction_data: &[u8],
) -> ProgramResult {
    msg!("Hello, Solana!");

    let event = GreetingEvent {
        message: "Hello from Solana program!".to_string(),
    };
    emit_event(&event)?;

    msg!("Program executed successfully with greeting event!");

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
        // let program_id = Pubkey::from_str("GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA").unwrap();
        let program_id = Pubkey::new_unique();
        let mut program_test = ProgramTest::default();
        program_test.add_program("sol_program", program_id, None);
        let mut context = program_test.start_with_context().await;
        let (banks_client, payer, recent_blockhash) = (
            &mut context.banks_client,
            &context.payer,
            context.last_blockhash,
        );
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

        let transaction_result = banks_client
            .process_transaction_with_metadata(transaction)
            .await
           .expect("Failed to process transaction");

        assert!(transaction_result.result.is_ok());

        let logs = transaction_result.metadata.unwrap().log_messages;
        assert!(logs.iter().any(|log| log.contains("Hello, Solana!")));
        assert!(logs.iter().any(|log| log.contains("EVENT:GREETING:")));
    }
}

```

### `start_with_context` 和 `start` 主要区别

| 特性       | start_with_context                      | start                            |
| ---------- | --------------------------------------- | -------------------------------- |
| 返回类型   | ProgramTestContext                      | (BanksClient, Keypair, Hash)     |
| 灵活性     | 高，提供完整上下文，适合复杂测试        | 低，仅提供基本组件，适合简单测试 |
| 代码简洁性 | 稍复杂，需手动解构上下文                | 更简洁，直接返回元组             |
| 上下文控制 | 保留 ProgramTestContext，可进行高级操作 | 无上下文对象，限制高级操作       |
| 适用场景   | 复杂测试（如时间推进、多交易）          | 简单测试（如单次交易验证）       |

### 处理交易的方式：process_transaction 和 process_transaction_with_metadata  两个方法的区别

| 特性           | process_transaction                                          | process_transaction_with_metadata                            |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 方法签名       | async fn process_transaction(&mut self, transaction: Transaction) -> Result<(), BanksClientError> | async fn process_transaction_with_metadata(&mut self, transaction: Transaction) -> Result<TransactionExecutionDetails, BanksClientError> |
| 返回值         | Result<(), BanksClientError>                                 | Result<TransactionExecutionDetails, BanksClientError>        |
| 返回值内容     | - 成功：Ok(()) - 失败：Err(BanksClientError)                 | - 成功：TransactionExecutionDetails 包含：  - result: Result<(), TransactionError>  - logs: Vec<String>  - units_consumed: u64  - return_data: Option<ProgramReturnData> - 失败：Err(BanksClientError) |
| 元数据访问     | 无（不提供日志、计算单元或返回数据）                         | 有（提供日志、计算单元消耗、程序返回数据）                   |
| 错误类型       | 单一错误：BanksClientError                                   | 两层错误： - BanksClientError（客户端错误） - TransactionError（交易执行错误） |
| 错误处理       | 简单，单一错误类型，信息较通用                               | 复杂，需处理嵌套 result 字段，日志可辅助调试                 |
| 代码示例       | rust<br>let transaction_result = banks_client.process_transaction(transaction).await;<br>assert!(transaction_result.is_ok());<br> | rust<br>let transaction_result = banks_client.process_transaction_with_metadata(transaction).await.expect("Failed");<br>assert!(transaction_result.result.is_ok());<br> |
| 代码简洁性     | 更简洁，适合快速验证                                         | 稍复杂，需解构 TransactionExecutionDetails                   |
| 安全性         | 简单错误处理，无需担心嵌套错误                               | 使用 unwrap() 不安全，建议用 expect 或 match                 |
| 适用场景       | - 简单测试：只需确认交易成功 - 快速原型：不关心日志或细节    | - 复杂测试：需验证日志、事件、计算单元或返回数据 - 调试：检查程序输出或错误 |
| 你的场景适用性 | 适合当前简单测试（仅验证交易成功）                           | 更适合验证 GreetingEvent 日志，确保事件正确输出              |
| 日志验证       | 无法直接访问日志，需额外配置（如自定义日志处理器）           | 可直接访问 logs 字段，验证 EVENT:GREETING 等日志             |
| 推荐改进       | 保持简洁，适合基本测试                                       | 切换到此方法以验证日志，避免 unwrap()，使用 expect 或 match  |

选择建议：若需验证事件或日志，process_transaction_with_metadata 是更好的选择；若仅需确认交易成功，process_transaction 更简洁。

### 编译构建测试程序

```bash
solana-sandbox/sol-program on  main [!] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 5.0s 
➜ cargo build-sbf
   Compiling sol-program v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/sol-program)
    Finished `release` profile [optimized] target(s) in 0.88s

solana-sandbox/sol-program on  main [!] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 2.0s 
➜ cargo test-sbf 
    Finished `release` profile [optimized] target(s) in 0.13s
warning: the cargo feature `edition2024` has been stabilized in the 1.85 release and is no longer necessary to be listed in the manifest
  See https://doc.rust-lang.org/cargo/reference/manifest.html#the-edition-field for more information about using this feature.
   Compiling sol-program v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/sol-program)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 2.60s
     Running unittests src/lib.rs (target/debug/deps/sol_program-525371d62f45d448)

running 1 test
[2025-06-15T07:55:18.734968000Z INFO  solana_program_test] "sol_program" SBF program from /Users/qiaopengjun/Code/Solana/solana-sandbox/sol-program/target/deploy/sol_program.so, modified 6 seconds, 475 ms, 649 µs and 321 ns ago
[2025-06-15T07:55:18.851542000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM invoke [1]
[2025-06-15T07:55:18.852074000Z DEBUG solana_runtime::message_processor::stable_log] Program log: Hello, Solana!
[2025-06-15T07:55:18.853240000Z DEBUG solana_runtime::message_processor::stable_log] Program log: EVENT:GREETING:[26, 0, 0, 0, 72, 101, 108, 108, 111, 32, 102, 114, 111, 109, 32, 83, 111, 108, 97, 110, 97, 32, 112, 114, 111, 103, 114, 97, 109, 33]
[2025-06-15T07:55:18.853249000Z DEBUG solana_runtime::message_processor::stable_log] Program log: Program executed successfully with greeting event!
[2025-06-15T07:55:18.854872000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM consumed 7280 of 200000 compute units
[2025-06-15T07:55:18.854891000Z DEBUG solana_runtime::message_processor::stable_log] Program 1111111QLbz7JHiBTspS962RLKV8GndWFwiEaqKM success
test test::test_sol_program ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.23s

   Doc-tests sol_program

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

```

### 更新程序

```bash
solana-sandbox/sol-program on  main [!] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 4.4s 
➜ solana program deploy \                                   
  --program-id ./target/deploy/sol_program-keypair.json \
  ./target/deploy/sol_program.so \
  -u $RPC_URL
Program Id: GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA

Signature: 4PgkQvWY9CCLuU1yoHC5bHtBQcBncUtuRNPXnzddLkrn8soSNrzkSDCLYU55uJtLhWcDKruYA5rcGaRXGPZoRjsq

```

### 运行客户端程序

```bash
solana-sandbox/sol-program on  main [!] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 21.1s 
➜ cargo run --example client
warning: the cargo feature `edition2024` has been stabilized in the 1.85 release and is no longer necessary to be listed in the manifest
  See https://doc.rust-lang.org/cargo/reference/manifest.html#the-edition-field for more information about using this feature.
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.85s
     Running `target/debug/examples/client`
Keypair: SSoyAkBN9E3CjbWpr2SdgLa6Ejbqqdvasuxd8j1YsmN
Balance: 1.999995 SOL
Transaction Signature: 4DFyj2xgVddy4inaaSbCJ6UeVMSM3u65LavC6tjVSsaw3A8PWLMz6jnuJ39o3A6WHhJV36UF5rYcVhnbgrkwEcqv

```

### 浏览器查看

- <https://explorer.solana.com/tx/4DFyj2xgVddy4inaaSbCJ6UeVMSM3u65LavC6tjVSsaw3A8PWLMz6jnuJ39o3A6WHhJV36UF5rYcVhnbgrkwEcqv?cluster=devnet&customUrl=http%3A%2F%2F127.0.0.1%3A8899>

![image-20250615160627873](/images/image-20250615160627873.png)

- <https://solscan.io/tx/4DFyj2xgVddy4inaaSbCJ6UeVMSM3u65LavC6tjVSsaw3A8PWLMz6jnuJ39o3A6WHhJV36UF5rYcVhnbgrkwEcqv?cluster=devnet>

![image-20250615160728136](/images/image-20250615160728136.png)

## 总结

通过在 Solana Devnet 上的实践，本文展示了从密钥对生成到链上程序更新与调用的完整开发流程，助力开发者从本地测试迈向更贴近生产环境的开发。核心内容包括：使用 solana-keygen grind 生成定制钱包地址；通过 solana program deploy 部署 Rust 程序并验证；利用 Rust 客户端调用链上程序并处理空投；通过添加日志和事件更新程序并确认效果；对比 start_with_context 与 start、以及 process_transaction 与 process_transaction_with_metadata，优化测试与调试效率。本文为开发者提供了从本地到 Devnet 的进阶路径，未来可进一步探索 Anchor 框架或复杂链上逻辑，敬请关注系列后续内容！

## 参考

- <https://solana.com/zh/docs/programs/deploying>
- <https://solana.com/zh/docs/intro/installation>
- <https://docs.rs/borsh/latest/borsh/>
- <https://www.solanazh.com/course/5-4>
- <https://www.anchor-lang.com/docs>
- <https://explorer.solana.com/tx/4DFyj2xgVddy4inaaSbCJ6UeVMSM3u65LavC6tjVSsaw3A8PWLMz6jnuJ39o3A6WHhJV36UF5rYcVhnbgrkwEcqv?cluster=devnet&customUrl=http%3A%2F%2F127.0.0.1%3A8899>
- <https://solscan.io/tx/4DFyj2xgVddy4inaaSbCJ6UeVMSM3u65LavC6tjVSsaw3A8PWLMz6jnuJ39o3A6WHhJV36UF5rYcVhnbgrkwEcqv?cluster=devnet>
