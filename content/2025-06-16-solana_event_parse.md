+++
title = "Solana 开发进阶：链上事件到链下解析全攻略"
description = "Solana 开发进阶：链上事件到链下解析全攻略"
date = 2025-06-16T01:03:33Z
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# Solana 开发进阶：链上事件到链下解析全攻略

在之前我们已经写了三篇文章《探索 Solana SDK 实战：Web3 开发的双路径与轻量模块化》、《Solana 开发实战：Rust 客户端调用链上程序全流程》和《Solana 开发进阶：在 Devnet 上实现链上程序部署、调用与更新》完美实现开发、测试、部署、客户端调用、更新全流程。Solana 的高性能区块链为 Web3 开发打开了新视野，而链上事件是实现智能合约与链下交互的关键枢纽。本文将通过 Rust 实战案例，带你深入掌握链上事件定义、触发到链下解析的全流程，解锁 Solana 开发进阶技能，助你构建更高效的 Web3 应用！

本文延续 Solana 开发系列的实战风格，聚焦智能合约事件的开发与解析全流程。我们通过 Rust 实现一个 Solana 程序，定义并触发 GreetingEvent 事件，利用 JSON-RPC 接口从区块数据中提取日志并反序列化事件内容，完成链上到链下的无缝衔接。文章涵盖 Borsh 序列化、日志提取、RPC 配置等核心技术，配以详细代码解析和运行示例，为希望掌握 Solana 事件机制的开发者提供进阶指南。

## 实战

### 查看项目目录

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 4.0s 
➜ tree . -L 6 -I "coverage_report|lib|.vscode|out|test-ledger|target|node_modules"
.
├── Cargo.lock
├── Cargo.toml
├── examples
│   ├── client.rs
│   └── event.rs
├── keys
│   └── SSoyAkBN9E3CjbWpr2SdgLa6Ejbqqdvasuxd8j1YsmN.json
└── src
    ├── lib.rs
    └── lib2.rs

4 directories, 7 files
```

### 合约程序 src/lib.rs 文件

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

### 解析合约程序事件 examples/event.rs 文件

```rust
use anyhow::Result;
use anyhow::anyhow;
use borsh::{BorshDeserialize, BorshSerialize};
use serde_json::Value;
use std::error::Error;

// 定义与程序相同的 GreetingEvent 结构体
#[derive(BorshDeserialize, BorshSerialize, Debug)]
pub struct GreetingEvent {
    pub message: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let client = reqwest::Client::builder().build()?;

    let mut headers = reqwest::header::HeaderMap::new();
    headers.insert("Content-Type", "application/json".parse()?);

    let data = r#"
    {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "getBlock",
        "params": [
            387787294,
            {
                "encoding": "jsonParsed",
                "maxSupportedTransactionVersion": 0,
                "transactionDetails": "full",
                "rewards": false
            }
        ]
    }
    "#;

    let json: Value = serde_json::from_str(&data)?;
    let request = client
        .request(
            reqwest::Method::POST,
            "https://docs-demo.solana-devnet.quiknode.pro/",
        )
        .headers(headers)
        .json(&json);

    let response = request.send().await?;
    let status = response.status();
    let response_text = response.text().await?;
    println!("Status: {}", status);
    let body: Value = serde_json::from_str(&response_text)?;

    let target_program_id = "GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA";
    // 提取 logMessages
    let log_messages = extract_log_messages(&body, target_program_id)?;

    // 打印 logMessages
    println!("logMessages: {:#?}", log_messages);

    // 解析 EVENT:GREETING 日志
    for log in &log_messages {
        if log.contains("EVENT:GREETING") {
            let event = parse_greeting_event(log)?;
            println!("Parsed GreetingEvent: {:?}", event);
        }
    }

    Ok(())
}

fn extract_log_messages(body: &Value, target_program_id: &str) -> Result<Vec<String>> {
    // 获取 transactions 数组
    let transactions = body["result"]["transactions"]
        .as_array()
        .ok_or_else(|| anyhow!("结果中未找到 transactions"))?;

    // 遍历交易，找到调用目标程序的交易
    for tx in transactions {
        // 检查指令中是否包含目标 programId
        let instructions = tx["transaction"]["message"]["instructions"]
            .as_array()
            .ok_or_else(|| anyhow!("交易中未找到指令"))?;

        let has_target_program = instructions.iter().any(|instruction| {
            instruction["programId"]
                .as_str()
                .map_or(false, |pid| pid == target_program_id)
        });

        if has_target_program {
            // 提取 logMessages
            let log_messages = tx["meta"]["logMessages"]
                .as_array()
                .ok_or_else(|| anyhow!("meta 中未找到 logMessages"))?;
            // 过滤与目标程序相关的日志
            let filtered_logs: Vec<String> = log_messages
                .iter()
                .filter_map(|log| {
                    log.as_str()
                        .filter(|s| s.contains(target_program_id) || s.contains("Program log"))
                        .map(String::from)
                })
                .collect();

            if !filtered_logs.is_empty() {
                return Ok(filtered_logs);
            }
        }
    }

    Err(anyhow!("未找到调用程序 {} 的日志", target_program_id))
}

fn parse_greeting_event(log: &str) -> Result<GreetingEvent> {
    // 提取 [26, 0, 0, 4, ...] 部分
    let start = log
        .find('[')
        .ok_or_else(|| anyhow!("无效的事件日志格式：未找到 '['"))?;
    let end = log
        .find(']')
        .ok_or_else(|| anyhow!("无效的事件日志格式：未找到 ']'"))?;
    let bytes_str = &log[start + 1..end];

    // 将字符串中的数字转换为 Vec<u8>
    let bytes: Vec<u8> = bytes_str
        .split(',')
        .map(|s| s.trim())
        .filter(|s| !s.is_empty())
        .map(|s| s.parse::<u8>().map_err(|e| anyhow!("无法解析字节：{}", e)))
        .collect::<Result<Vec<u8>>>()?;

    // 使用 Borsh 解序列化
    let event =
        GreetingEvent::try_from_slice(&bytes).map_err(|e| anyhow!("Borsh 解序列化失败：{}", e))?;

    Ok(event)
}

```

在 Solana 开发中，程序（智能合约）可以通过日志（log）来发出事件（event），这些事件会被记录在交易的元数据中。本示例演示了如何通过 RPC 接口获取区块数据，并从中解析出特定程序发出的事件。

#### 代码解析

这段代码主要完成以下功能：

1. **依赖引入**：

   - `anyhow` 用于简化错误处理
   - `borsh` 用于序列化和反序列化事件数据
   - `serde_json` 用于处理 JSON 数据
   - `reqwest` 用于发送 HTTP 请求

2. **事件结构体定义**：

   ```
   #[derive(BorshDeserialize, BorshSerialize, Debug)]
   pub struct GreetingEvent {
       pub message: String,
   }
   ```

   必须与合约程序中定义的事件结构体完全一致，才能正确反序列化。

3. **主流程**：

   - 构建 HTTP 客户端并设置请求头
   - 准备 JSON-RPC 请求体，查询特定区块的交易数据
   - 发送请求并处理响应
   - 从响应中提取目标程序的日志消息
   - 解析包含 `EVENT:GREETING` 标记的日志

4. **关键函数**：

   - `extract_log_messages`: 从区块数据中筛选出目标程序的日志
   - `parse_greeting_event`: 解析日志中的事件数据

#### 工作原理

1. 合约程序通过 `msg!` 宏输出特定格式的日志（如 `EVENT:GREETING:[...]`）
2. 这些日志会被记录在交易的 `logMessages` 字段中
3. 客户端通过 JSON-RPC 接口获取区块数据
4. 从交易元数据中提取日志消息
5. 解析日志中的字节数组，还原出原始事件对象

#### 注意事项

1. 事件结构体必须使用 `Borsh` 序列化/反序列化
2. 日志格式需要约定明确的前缀（如 `EVENT:GREETING:`）
3. 区块查询需要正确的 RPC 节点和参数配置
4. 程序 ID 需要替换为实际部署的合约地址

### 运行

```bash
solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 3.7s 
➜ cargo run --example event
warning: the cargo feature `edition2024` has been stabilized in the 1.85 release and is no longer necessary to be listed in the manifest
  See https://doc.rust-lang.org/cargo/reference/manifest.html#the-edition-field for more information about using this feature.
   Compiling sol-program v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/sol-program)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.88s
     Running `target/debug/examples/event`
Status: 200 OK
logMessages: [
    "Program GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA invoke [1]",
    "Program log: Hello, Solana!",
    "Program log: EVENT:GREETING:[26, 0, 0, 0, 72, 101, 108, 108, 111, 32, 102, 114, 111, 109, 32, 83, 111, 108, 97, 110, 97, 32, 112, 114, 111, 103, 114, 97, 109, 33]",
    "Program log: Program executed successfully with greeting event!",
    "Program GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA consumed 7280 of 200000 compute units",
    "Program GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA success",
]
Parsed GreetingEvent: GreetingEvent { message: "Hello from Solana program!" }

solana-sandbox/sol-program on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 4.3s 
➜ cargo run --example event
warning: the cargo feature `edition2024` has been stabilized in the 1.85 release and is no longer necessary to be listed in the manifest
  See https://doc.rust-lang.org/cargo/reference/manifest.html#the-edition-field for more information about using this feature.
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.01s
     Running `target/debug/examples/event`
Status: 200 OK
logMessages: [
    "Program GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA invoke [1]",
    "Program log: Hello, Solana!",
    "Program log: EVENT:GREETING:[26, 0, 0, 0, 72, 101, 108, 108, 111, 32, 102, 114, 111, 109, 32, 83, 111, 108, 97, 110, 97, 32, 112, 114, 111, 103, 114, 97, 109, 33]",
    "Program log: Program executed successfully with greeting event!",
    "Program GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA consumed 7280 of 200000 compute units",
    "Program GGBjDqYdicSE6Qmtu6SAsueX1biM5LjbJ8R8vZvFfofA success",
]
Parsed GreetingEvent: GreetingEvent { message: "Hello from Solana program!" }
```

成功解析链上事件，输出“Hello from Solana program!”！

## 总结

本次实战完整呈现了 Solana 智能合约事件从链上定义到链下解析的全攻略。我们通过 Rust 定义 GreetingEvent、利用 msg! 触发日志，再通过 JSON-RPC 接口提取和反序列化事件数据，展示了链上链下交互的进阶技术。开发者需注意事件结构体一致性、日志格式规范和 RPC 配置的准确性。结合系列前文的开发、部署与调用经验，本文进一步丰富了你的 Solana 开发技能！继续关注我们的 Solana 开发系列，探索更多 Web3 实战技巧！

## 参考

- <https://explorer.solana.com/tx/4DFyj2xgVddy4inaaSbCJ6UeVMSM3u65LavC6tjVSsaw3A8PWLMz6jnuJ39o3A6WHhJV36UF5rYcVhnbgrkwEcqv?cluster=devnet&customUrl=http%3A%2F%2F127.0.0.1%3A8899>

- <https://solscan.io/tx/4DFyj2xgVddy4inaaSbCJ6UeVMSM3u65LavC6tjVSsaw3A8PWLMz6jnuJ39o3A6WHhJV36UF5rYcVhnbgrkwEcqv?cluster=devnet>
- <https://solana.com/zh/docs/programs/rust#%E6%9B%B4%E6%96%B0%E7%A8%8B%E5%BA%8F>
- <https://github.com/solana-program/token/blob/main/program/src/state.rs>
