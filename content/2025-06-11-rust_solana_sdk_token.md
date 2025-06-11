+++
title = "用 Rust 在 Solana 上打造你的专属代币：从零到一的 Web3 实践"
description = "用 Rust 在 Solana 上打造你的专属代币：从零到一的 Web3 实践"
date = 2025-06-11T05:11:25Z
[taxonomies]
categories = ["Web3", "Solana", "Rust"]
tags = ["Web3", "Solana", "Rust"]
+++

<!-- more -->

# 用 Rust 在 Solana 上打造你的专属代币：从零到一的 Web3 实践

在 Web3 时代，Solana 以其高吞吐量和低成本成为区块链开发的热门选择。想知道如何用 Rust 在 Solana 上创建自己的代币吗？这篇文章将手把手带你从项目初始化到代币铸造，解锁 Solana Web3 开发的无限可能！无论你是区块链新手还是 Rust 爱好者，这篇实操指南都将为你打开一扇通往去中心化世界的大门。

本文通过一个完整的 Rust 示例程序，详细讲解了在 Solana 区块链上创建和管理 SPL 代币的全过程。内容涵盖项目初始化、密钥对生成、SOL 空投、代币铸造（Mint）及关联代币账户（ATA）创建等关键步骤，并提供了代码解析和运行结果展示。适合对 Solana 开发、Rust 编程或 Web3 应用感兴趣的开发者参考。

## 实操

### 创建并初始化项目

```bash
cargo init solana-sdk-demo
    Creating binary (application) package
note: see more `Cargo.toml` keys and their definitions at *******************************************************
```

### 切换到项目目录

```bash
cd solana-sdk-demo/

```

### *列出当前目录可见文件和文件夹*

```bash
ls
Cargo.toml src
```

#### `ls` 常用参数说明

| 参数 |        作用        |
| :--: | :----------------: |
| `-l` |     长格式显示     |
| `-a` |    显示隐藏文件    |
| `-h` | 人性化显示文件大小 |
| `-t` |   按修改时间排序   |
| `-S` |   按文件大小排序   |

### 编译运行

```bash
cargo run
   Compiling solana-sdk-demo v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/solana-sdk-demo)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.68s
     Running `target/debug/solana-sdk-demo`
Hello, world!
```

### 安装依赖

```bash
cargo add solana-sdk
cargo add solana-client
```

### 创建 keys 目录并切换到该目录

```bash
solana-sandbox/solana-sdk-demo on  main [?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) took 4.3s 
➜ mcd keys # mkdir keys && cd keys             
/Users/qiaopengjun/Code/Solana/solana-sandbox/solana-sdk-demo/keys
```

### 使用 `solana-keygen grind` 命令生成以特定前缀开头的 Solana 密钥对

```bash
solana-sandbox/solana-sdk-demo/keys on  main [?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ solana-keygen grind --starts-with SDK:1 --ignore-case     
Searching with 12 threads for:
        1 pubkey that starts with 'sdk' and ends with ''
Wrote keypair to SDkZ1GXNPseV2RL46QigxZPy23qSGmb4NBnM53GyNUB.json

solana-sandbox/solana-sdk-demo/keys on  main [?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ solana-keygen grind --starts-with SDK:1 --ignore-case    
Searching with 12 threads for:
        1 pubkey that starts with 'sdk' and ends with ''
Wrote keypair to SdkcwrahL9q1wm7qB8wQwNBKxZJ4Ck7A413tWDkSBjo.json

```

- `--starts-with SDK:1`：生成以 "SDK" 开头且长度为1个前缀的地址
- `--ignore-case`：忽略大小写（所以 "sdk" 也能匹配）
- 默认使用12线程搜索

### 空投 2 SOL 测试币

```bash
solana-sandbox/solana-sdk-demo/keys on  main [?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ solana airdrop 2 SdkcwrahL9q1wm7qB8wQwNBKxZJ4Ck7A413tWDkSBjo     
Requesting airdrop of 2 SOL

Signature: 5E6ZVGS8vEwg86jQtnT9nVJLiSX4LbmM436hqUSLxQLKhkbsqREKW66zH1zuQ5VMPCCaUNqneAwtmUjyHyJNUH3h

2 SOL

solana-sandbox/solana-sdk-demo on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 3.6s 
➜ solana airdrop 2 SDkZ1GXNPseV2RL46QigxZPy23qSGmb4NBnM53GyNUB                                           
Requesting airdrop of 2 SOL

Signature: 5xoMPsurgpV2dQDPrBipUa2pzjyUmQAkRkWupib1VdwpC3rC54TSCYYNcLrxbht8Xk8nvyT4MnhBGPBEka99tUXv

2 SOL
```

### 查看余额

```bash
solana-sandbox/solana-sdk-demo/keys on  main [?] is 📦 0.1.0 via 🦀 1.87.0 on 🐳 v28.2.2 (orbstack) 
➜ solana balance SdkcwrahL9q1wm7qB8wQwNBKxZJ4Ck7A413tWDkSBjo                                                 
2 SOL
```

### 查看项目目录

```bash
solana-sandbox/solana-sdk-demo on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ tree . -L 6 -I "coverage_report|lib|.vscode|out|lcov.info|target|node_modules"
.
├── Cargo.lock
├── Cargo.toml
├── keys
│   ├── SdkcwrahL9q1wm7qB8wQwNBKxZJ4Ck7A413tWDkSBjo.json
│   └── SDkZ1GXNPseV2RL46QigxZPy23qSGmb4NBnM53GyNUB.json
└── src
    └── main.rs

3 directories, 5 files
```

### Cargo.toml 文件

```toml
[package]
name = "solana-sdk-demo"
version = "0.1.0"
edition = "2024"

[dependencies]
anyhow = "1.0.98"
solana-sdk = "2.2.2"
tokio = { version = "1.45.1", features = ["full"] }
solana-client = "2.2.7"
dotenvy = "0.15.7"
spl-token = "8.0.0"
spl-token-2022 = "9.0.0"
spl-associated-token-account = "7.0.0"

```

### main.rs 文件

```rust
use std::env;
use std::path::Path;

use dotenvy::dotenv;
use solana_client::rpc_client::RpcClient;
use solana_sdk::commitment_config::CommitmentConfig;
use solana_sdk::native_token::LAMPORTS_PER_SOL;
use solana_sdk::program_pack::Pack;
use solana_sdk::pubkey::Pubkey;
use solana_sdk::signature::Keypair;
use solana_sdk::signature::Signer;
use solana_sdk::signature::read_keypair_file;
use solana_sdk::system_instruction::create_account;
use solana_sdk::transaction::Transaction;
use spl_associated_token_account::get_associated_token_address;
use spl_associated_token_account::instruction::create_associated_token_account_idempotent;
use spl_token::ID as TOKEN_PROGRAM_ID;
use spl_token::instruction::initialize_mint2;
use spl_token_2022::extension::BaseStateWithExtensions;
use spl_token_2022::extension::StateWithExtensions;
use spl_token_2022::state::Account as TokenAccount;
use spl_token_2022::state::Mint;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // 1. 加载环境变量
    dotenv().ok();

    // 2. 初始化RPC客户端
    let rpc_url = env::var("SOLANA_RPC_URL").unwrap_or_else(|_| "http://127.0.0.1:8899".into());
    let client = RpcClient::new_with_commitment(rpc_url, CommitmentConfig::confirmed());

    // 3. 加载支付账户
    let authority_key_path = "./keys/SdkcwrahL9q1wm7qB8wQwNBKxZJ4Ck7A413tWDkSBjo.json";
    let authority_keypair = load_keypair(authority_key_path)?;

    // 4. 检查并充值测试SOL
    let balance = client.get_balance(&authority_keypair.pubkey())?;
    println!("当前余额: {} SOL", balance as f64 / LAMPORTS_PER_SOL as f64);

    if balance < 1_000_000_000 {
        // 如果余额小于1 SOL
        airdrop(&client, &authority_keypair.pubkey(), 1)?; // 空投1 SOL
    }

    // 4. 生成全新的密钥对（专门用于Mint）
    let mint_keypair = Keypair::new();
    let mint_pubkey = mint_keypair.pubkey();

    // 6. 构建交易指令
    let mint_account_len = Mint::LEN;
    let rent = client.get_minimum_balance_for_rent_exemption(mint_account_len)?;

    let instructions = vec![
        // 创建账户指令
        create_account(
            &authority_keypair.pubkey(),
            &mint_pubkey,
            rent,
            mint_account_len as u64,
            &TOKEN_PROGRAM_ID,
        ),
        // 初始化Mint指令
        initialize_mint2(
            &TOKEN_PROGRAM_ID,
            &mint_pubkey,
            &authority_keypair.pubkey(),       // Mint权限
            Some(&authority_keypair.pubkey()), // 冻结权限（设为同一地址）
            9,                                 // 代币小数位
        )?,
        // 创建Token账户 create_ata_ix
        create_associated_token_account_idempotent(
            &authority_keypair.pubkey(), // payer
            &authority_keypair.pubkey(),
            &mint_pubkey,
            &TOKEN_PROGRAM_ID,
        ),
    ];

    // 7. 发送交易
    let mut tx = Transaction::new_with_payer(&instructions, Some(&authority_keypair.pubkey()));

    tx.sign(
        &[&authority_keypair, &mint_keypair],
        client.get_latest_blockhash()?,
    );

    match client.send_and_confirm_transaction(&tx) {
        Ok(signature) => println!("Transaction Signature: {}", signature),
        Err(err) => eprintln!("Error sending transaction: {}", err),
    }

    let mint_data = client.get_account_data(&mint_pubkey)?;
    let mint = StateWithExtensions::<Mint>::unpack(&mint_data).unwrap();
    let extension_types = mint.get_extension_types().unwrap();

    println!("Mint pubkey: {}", mint_pubkey);
    println!("Mint: {:#?}", mint);
    println!("Extension types: {:#?}", extension_types);

    let token_account_address = get_associated_token_address(
        &authority_keypair.pubkey(), // 当前用户
        &mint_pubkey,                // 刚创建的Mint
    );
    let token_account_data = client.get_token_account(&token_account_address)?;
    println!("token_account_data: {token_account_data:#?}");

    let account_data = client.get_account_data(&token_account_address)?;
    let token_account_data = TokenAccount::unpack(&account_data)?;
    println!("Token Account Data: {token_account_data:#?}");

    let balance = client.get_token_account_balance(&token_account_address)?;
    println!("Token Account Balance: {:#?}", balance);

    Ok(())
}

// 辅助函数：加载密钥对
fn load_keypair(path: &str) -> anyhow::Result<Keypair> {
    if !Path::new(path).exists() {
        anyhow::bail!("密钥文件不存在: {}", path);
    }
    read_keypair_file(path).map_err(|e| anyhow::anyhow!("读取密钥失败: {}", e))
}

// 辅助函数：请求空投
fn airdrop(client: &RpcClient, address: &Pubkey, sol: u64) -> anyhow::Result<()> {
    let signature = client.request_airdrop(address, sol * LAMPORTS_PER_SOL)?;

    // 等待确认
    loop {
        if client.confirm_transaction(&signature)? {
            println!("🪂 成功空投 {} SOL", sol);
            break;
        }
    }
    Ok(())
}

```

这个 Rust 程序是一个 Solana 链上的代币（SPL Token）操作示例。它演示了如何：

1. 加载密钥对。
2. 检查并请求空投 SOL。
3. 创建一个新的 Token Mint（代币铸币厂）。
4. 为 Mint 创建一个关联代币账户（Associated Token Account, ATA）。
5. 查询 Mint 和 ATA 的数据及余额。

下面是详细的解释：

#### 1. 依赖 (Dependencies)

代码开头的 `use` 语句导入了所需的各种库和模块：

- `std::env`, `std::path::Path`: 用于处理环境变量和文件路径。
- `dotenvy::dotenv`: 从 `.env` 文件加载环境变量。
- `solana_client::rpc_client::RpcClient`: Solana RPC 客户端，用于与 Solana 集群交互。
- `solana_sdk::commitment_config::CommitmentConfig`: 配置 RPC 请求的确认级别。
- `solana_sdk::native_token::LAMPORTS_PER_SOL`: SOL 代币的单位转换常量。
- `solana_sdk::program_pack::Pack`: 用于序列化/反序列化链上数据结构。
- `solana_sdk::pubkey::Pubkey`: Solana 公钥类型。
- `solana_sdk::signature::{Keypair, Signer, read_keypair_file}`: 用于密钥对的生成、签名和从文件读取。
- `solana_sdk::system_instruction::create_account`: 创建系统账户的指令。
- `solana_sdk::transaction::Transaction`: 构建和发送 Solana 交易。
- `spl_associated_token_account::get_associated_token_address`: 获取关联代币账户地址的辅助函数。
- `spl_associated_token_account::instruction::create_associated_token_account_idempotent`: 创建关联代币账户的指令（幂等性，即重复调用不会出错）。
- `spl_token::ID as TOKEN_PROGRAM_ID`: SPL Token 程序的公钥 ID。
- `spl_token::instruction::initialize_mint2`: 初始化 Token Mint 的指令。
- `spl_token_2022::extension::BaseStateWithExtensions`, `spl_token_2022::extension::StateWithExtensions`: 用于处理 Token Extensions (Token 2022 标准)。
- `spl_token_2022::state::Account as TokenAccount`, `spl_token_2022::state::Mint`: Token 账户和 Mint 账户的链上状态结构。

#### 2. `main` 函数

`#[tokio::main] async fn main() -> anyhow::Result<()>`:

- `#[tokio::main]`: 这是一个宏，将 `main` 函数标记为异步入口点，并设置 Tokio 运行时。
- `async fn main()`: 表明 `main` 函数是异步的，允许在其中使用 `await`（尽管当前代码中 `RpcClient` 的方法是同步阻塞的）。
- `anyhow::Result<()>`: 表示函数可能返回错误，并且使用 `anyhow` 库来简化错误处理。

##### 2.1 初始化和加载密钥对

```rust
    // 1. 加载环境变量
    dotenv().ok();

    // 2. 初始化RPC客户端
    let rpc_url = env::var("SOLANA_RPC_URL").unwrap_or_else(|_| "http://127.0.0.1:8899".into());
    let client = RpcClient::new_with_commitment(rpc_url, CommitmentConfig::confirmed());

    // 3. 加载支付账户
    let authority_key_path = "./keys/SdkcwrahL9q1wm7qB8wQwNBKxZJ4Ck7A413tWDkSBjo.json";
    let authority_keypair = load_keypair(authority_key_path)?;
```

- `dotenv().ok()`: 尝试加载项目根目录下的 `.env` 文件中的环境变量。
- `RpcClient::new_with_commitment(...)`: 创建一个 Solana RPC 客户端实例，连接到指定的 RPC URL（默认是本地 `http://127.0.0.1:8899`），并设置提交级别为 `confirmed()`。
- `load_keypair(authority_key_path)?`: 调用辅助函数 `load_keypair` 从指定路径加载支付账户（`authority_keypair`）。这个账户将用于支付交易费用和作为 Mint 的权限账户。

##### 2.2 检查并充值测试 SOL

```rust
    // 4. 检查并充值测试SOL
    let balance = client.get_balance(&authority_keypair.pubkey())?;
    println!("当前余额: {} SOL", balance as f64 / LAMPORTS_PER_SOL as f64);

    if balance < 1_000_000_000 {
        // 如果余额小于1 SOL
        airdrop(&client, &authority_keypair.pubkey(), 1)?; // 空投1 SOL
    }
```

- `client.get_balance(...)`: 查询 `authority_keypair` 公钥对应的 SOL 余额。
- 如果余额小于 1 SOL（即 `1_000_000_000` lamports），则调用辅助函数 `airdrop` 向该地址空投 1 SOL。

##### 2.3 生成 Mint 密钥对

```rust
    // 4. 生成全新的密钥对（专门用于Mint）
    let mint_keypair = Keypair::new();
    let mint_pubkey = mint_keypair.pubkey();
```

- `Keypair::new()`: 生成一个新的 Solana 密钥对，这个密钥对将作为新创建的 Token Mint 账户的地址。

##### 2.4 构建交易指令

```rust
    // 6. 构建交易指令
    let mint_account_len = Mint::LEN;
    let rent = client.get_minimum_balance_for_rent_exemption(mint_account_len)?;

    let instructions = vec![
        // 创建账户指令
        create_account(
            &authority_keypair.pubkey(),
            &mint_pubkey,
            rent,
            mint_account_len as u64,
            &TOKEN_PROGRAM_ID,
        ),
        // 初始化Mint指令
        initialize_mint2(
            &TOKEN_PROGRAM_ID,
            &mint_pubkey,
            &authority_keypair.pubkey(),       // Mint权限
            Some(&authority_keypair.pubkey()), // 冻结权限（设为同一地址）
            9,                                 // 代币小数位
        )?,
        // 创建Token账户 create_ata_ix
        create_associated_token_account_idempotent(
            &authority_keypair.pubkey(), // payer
            &authority_keypair.pubkey(),
            &mint_pubkey,
            &TOKEN_PROGRAM_ID,
        ),
    ];
```

- `Mint::LEN`: 获取 Token Mint 账户在链上存储所需的字节长度。
- `client.get_minimum_balance_for_rent_exemption(...)`: 获取创建 Mint 账户所需的租金免除余额。
- `instructions` 向量包含了三个关键指令：
  - `create_account`: 创建一个通用的 Solana 账户，用于存放 Mint 数据。
    - `authority_keypair.pubkey()`: 支付账户。
    - `mint_pubkey`: 新 Mint 账户的公钥。
    - `rent`: 租金。
    - `mint_account_len as u64`: 账户长度。
    - `TOKEN_PROGRAM_ID`: 账户的拥有者（Token Program）。
  - `initialize_mint2`: 初始化 Mint 账户。
    - `TOKEN_PROGRAM_ID`: Token 程序的 ID。
    - `mint_pubkey`: 要初始化的 Mint 账户。
    - `authority_keypair.pubkey()`: Mint 权限（谁可以铸造/销毁代币）。
    - `Some(&authority_keypair.pubkey())`: 冻结权限（谁可以冻结代币账户），这里设置为与 Mint 权限相同。
    - `9`: 代币的小数位数。
  - `create_associated_token_account_idempotent`: 创建一个关联代币账户（ATA）。ATA 是一个由 SPL Token 程序派生出来的确定性地址，用于存放特定用户（`authority_keypair.pubkey()`）的特定 Mint（`mint_pubkey`）的代币。`idempotent` 意味着如果账户已经存在，该指令不会失败。

##### 2.5 发送交易

```rust
    // 7. 发送交易
    let mut tx = Transaction::new_with_payer(&instructions, Some(&authority_keypair.pubkey()));

    tx.sign(
        &[&authority_keypair, &mint_keypair],
        client.get_latest_blockhash()?,
    );

    match client.send_and_confirm_transaction(&tx) {
        Ok(signature) => println!("Transaction Signature: {}", signature),
        Err(err) => eprintln!("Error sending transaction: {}", err),
    }
```

- `Transaction::new_with_payer(...)`: 创建一个新的交易，包含之前定义的指令，并指定 `authority_keypair` 为支付交易费用的账户。
- `tx.sign(...)`: 对交易进行签名。需要 `authority_keypair` 和 `mint_keypair` 的签名，因为 `authority_keypair` 是支付者且是 Mint 权限，`mint_keypair` 是新创建的 Mint 账户的拥有者，需要在 `create_account` 交易中签名。
- `client.get_latest_blockhash()?`: 获取最新的区块哈希，用于交易的签名和有效期。
- `client.send_and_confirm_transaction(&tx)`: 发送交易并等待其确认。
- `match` 语句处理交易发送的结果，打印签名或错误信息。

##### 2.6 查询 Mint 和 Token 账户数据

```rust
    let mint_data = client.get_account_data(&mint_pubkey)?;
    let mint = StateWithExtensions::<Mint>::unpack(&mint_data).unwrap();
    let extension_types = mint.get_extension_types().unwrap();

    println!("Mint pubkey: {}", mint_pubkey);
    println!("Mint: {:#?}", mint);
    println!("Extension types: {:#?}", extension_types);

    let token_account_address = get_associated_token_address(
        &authority_keypair.pubkey(), // 当前用户
        &mint_pubkey,                // 刚创建的Mint
    );
    let token_account_data = client.get_token_account(&token_account_address)?;
    println!("token_account_data: {token_account_data:#?}");

    let account_data = client.get_account_data(&token_account_address)?;
    let token_account_data = TokenAccount::unpack(&account_data)?;
    println!("Token Account Data: {token_account_data:#?}");

    let balance = client.get_token_account_balance(&token_account_address)?;
    println!("Token Account Balance: {:#?}", balance);
```

- `client.get_account_data(&mint_pubkey)?`: 获取 Mint 账户的原始字节数据。
- `StateWithExtensions::<Mint>::unpack(&mint_data).unwrap()`: 将原始数据反序列化为 `Mint` 结构，并处理 Token Extensions。
- `mint.get_extension_types().unwrap()`: 获取 Mint 启用的扩展类型。
- 打印 Mint 的公钥、详细信息和扩展类型。
- `get_associated_token_address(...)`: 根据用户公钥和 Mint 公钥计算关联代币账户的地址。
- `client.get_token_account(&token_account_address)?`: 获取关联代币账户的通用账户信息。
- `client.get_account_data(&token_account_address)?` 和 `TokenAccount::unpack(&account_data)?`: 获取关联代币账户的原始数据并反序列化为 `TokenAccount` 结构。
- `client.get_token_account_balance(&token_account_address)?`: 获取关联代币账户的代币余额。
- 打印相关数据和余额。

#### 3. 辅助函数 (Helper Functions)

##### 3.1 `load_keypair`

```rust
// 辅助函数：加载密钥对
fn load_keypair(path: &str) -> anyhow::Result<Keypair> {
    if !Path::new(path).exists() {
        anyhow::bail!("密钥文件不存在: {}", path);
    }
    read_keypair_file(path).map_err(|e| anyhow::anyhow!("读取密钥失败: {}", e))
}
```

- 这个函数负责从指定路径加载一个 Solana 密钥对。
- 它首先检查文件是否存在，如果不存在则返回错误。
- 然后调用 `read_keypair_file` 读取文件，并使用 `map_err` 将其错误转换为 `anyhow::Error` 类型。

##### 3.2 `airdrop`

```rust
// 辅助函数：请求空投
fn airdrop(client: &RpcClient, address: &Pubkey, sol: u64) -> anyhow::Result<()> {
    let signature = client.request_airdrop(address, sol * LAMPORTS_PER_SOL)?;

    // 等待确认
    loop {
        if client.confirm_transaction(&signature)? {
            println!("🪂 成功空投 {} SOL", sol);
            break;
        }
    }
    Ok(())
}
```

- 这个函数用于向指定的 `address` 请求 `sol` 数量的 SOL 空投。
- `client.request_airdrop(...)`: 发起空投请求，返回交易签名。
- `loop { ... if client.confirm_transaction(...) { break; } }`: 这是一个循环，持续调用 `confirm_transaction` 直到空投交易被确认。
- 成功空投后打印一条消息。

总的来说，这段代码提供了一个全面的示例，展示了如何在 Solana 上使用 Rust `solana-sdk` 和 `spl-token` 库来创建和管理 SPL Token。

### 编译构建

```bash
solana-sandbox/solana-sdk-demo on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 5.8s 
➜ cargo build
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.71s
```

### 运行

```bash
solana-sandbox/solana-sdk-demo on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 4.4s 
➜ cargo run
   Compiling solana-sdk-demo v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/solana-sdk-demo)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 2.56s
     Running `target/debug/solana-sdk-demo`
当前余额: 1.99501752 SOL
Transaction Signature: 212pXowS9JhDRsZoQtZ6shtyxvx1RkrJDRstHF2zR6WF2RB4F2FnFjdBcNj4aXVvLFfzEi5WuENMtd4RnCfNs9pi
Mint pubkey: Ffq9sg15LefzCJttfh6rLAqyUhXwVLmJ2oLwQYR1zwoj
Mint: StateWithExtensions {
    base: Mint {
        mint_authority: Some(
            SdkcwrahL9q1wm7qB8wQwNBKxZJ4Ck7A413tWDkSBjo,
        ),
        supply: 0,
        decimals: 9,
        is_initialized: true,
        freeze_authority: Some(
            SdkcwrahL9q1wm7qB8wQwNBKxZJ4Ck7A413tWDkSBjo,
        ),
    },
    tlv_data: [],
}
Extension types: []
token_account_data: Some(
    UiTokenAccount {
        mint: "Ffq9sg15LefzCJttfh6rLAqyUhXwVLmJ2oLwQYR1zwoj",
        owner: "SdkcwrahL9q1wm7qB8wQwNBKxZJ4Ck7A413tWDkSBjo",
        token_amount: UiTokenAmount {
            ui_amount: Some(
                0.0,
            ),
            decimals: 9,
            amount: "0",
            ui_amount_string: "0",
        },
        delegate: None,
        state: Initialized,
        is_native: false,
        rent_exempt_reserve: None,
        delegated_amount: None,
        close_authority: None,
        extensions: [],
    },
)
Token Account Data: Account {
    mint: Ffq9sg15LefzCJttfh6rLAqyUhXwVLmJ2oLwQYR1zwoj,
    owner: SdkcwrahL9q1wm7qB8wQwNBKxZJ4Ck7A413tWDkSBjo,
    amount: 0,
    delegate: None,
    state: Initialized,
    is_native: None,
    delegated_amount: 0,
    close_authority: None,
}
Token Account Balance: UiTokenAmount {
    ui_amount: Some(
        0.0,
    ),
    decimals: 9,
    amount: "0",
    ui_amount_string: "0",
}
```

该运行结果展示了在 Solana 测试网上成功创建并初始化一个新的代币（Mint）及其关联代币账户（ATA）的过程。程序首先检查支付账户余额为 1.995 SOL，足以支付交易费用。随后，通过一笔交易（签名：212pXowS9JhDRsZoQtZ6shtyxvx1RkrJDRstHF2zR6WF2RB4F2FnFjdBcNj4aXVvLFfzEi5WuENMtd4RnCfNs9pi）创建了 Mint 账户（公钥：Ffq9sg15LefzCJttfh6rLAqyUhXwVLmJ2oLwQYR1zwoj），设置代币小数位为 9，权限账户为 SdkcwrahL9q1wm7qB8wQwNBKxZJ4Ck7A413tWDkSBjo，初始供应量为 0，无扩展功能（Extension types: []）。同时，创建了一个关联代币账户，归属同一权限账户，初始余额为 0（amount: "0"）。整个过程表明代码成功完成了代币创建和账户初始化，适合用于 Solana 开发中的代币测试场景。

## 总结

通过本文的实操指南，我们成功使用 Rust 在 Solana 测试网上创建了一个代币及其关联账户，涵盖了从环境搭建到交易发送的完整流程。Solana 的高性能和 Rust 的安全性为 Web3 开发提供了强大支持，而 SPL 代币的创建只是起点。无论是开发 DeFi 应用、NFT 项目还是其他去中心化场景，掌握这些技能都将让你在 Web3 世界中如鱼得水。快动手实践，打造属于你的区块链项目吧！

## 参考

- <https://solana.com/zh/docs/clients/rust>
- <https://docs.rs/solana-sdk/latest/solana_sdk/>
- <https://github.com/anza-xyz/solana-sdk>
- <https://docs.rs/solana-client/latest/solana_client/>
- <https://github.com/anza-xyz/agave>
- <https://github.com/anza-xyz/solana-sdk>
- <https://doc.rust-lang.org/nightly/cargo/reference/unstable.html#edition-2024>
- <https://solana.com/zh/developers/cookbook/tokens/create-token-account>
