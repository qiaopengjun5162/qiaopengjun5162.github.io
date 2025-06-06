+++
title = "Web3实战：使用Anchor与Rust开发和调用Solana智能合约"
description = "Web3实战：使用Anchor与Rust开发和调用Solana智能合约"
date = 2025-06-05T07:10:50Z
[taxonomies]
categories = ["Web3", "Solana", "Anchor", "Rust"]
tags = ["Web3", "Solana", "Anchor", "Rust"]
+++

<!-- more -->

# Web3实战：使用Anchor与Rust开发和调用Solana智能合约

Web3时代正在重塑数字世界，Solana以其超高吞吐量和低交易成本成为区块链开发的明星平台。想快速上手Web3开发？本文通过一个简单的计数器智能合约，带你一步步掌握使用Anchor框架和Rust语言在Solana上开发、部署智能合约，以及编写Rust客户端与合约交互的完整流程。无论你是区块链新手还是寻求实战经验的开发者，这篇教程都将为你打开Web3开发的大门！

本文是一篇面向Web3开发者的实战教程，基于Solana区块链和Anchor框架，完整展示如何从零开始构建和调用智能合约。内容分为两部分：一、**Anchor开发Solana智能合约**，涵盖项目初始化、Rust合约编写、编译、启动本地节点和部署合约的全流程；二、**Rust客户端调用合约**，通过anchor-client库实现初始化和递增计数器功能。教程提供详细代码、运行结果及参考资源，适合希望快速上手Solana开发的初学者和进阶开发者。

## Anchor开发Solana智能合约全流程实操

### 创建并初始化项目

```bash
anchor init counter
yarn install v1.22.22
info No lockfile found.
[1/4] 🔍  Resolving packages...
warning mocha > glob@7.2.0: Glob versions prior to v9 are no longer supported
warning mocha > glob > inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
[2/4] 🚚  Fetching packages...
[3/4] 🔗  Linking dependencies...
[4/4] 🔨  Building fresh packages...
success Saved lockfile.
✨  Done in 17.91s.
Failed to install node modules
Initialized empty Git repository in /Users/qiaopengjun/Code/Solana/solana-sandbox/counter/.git/
counter initialized
```

若遇到安装失败，可尝试更新Node.js版本或使用npm install替代。

### 切换到项目目录并用 cursor 打开

```bash
cd counter
cc
```

### 查看项目目录

```bash
counter on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 
➜ tree . -L 6 -I "target|test-ledger|.vscode|node_modules"
.
├── Anchor.toml
├── app
│   └── counter-rs
│       ├── Cargo.lock
│       ├── Cargo.toml
│       ├── idls
│       │   └── counter.json
│       └── src
│           └── main.rs
├── Cargo.lock
├── Cargo.toml
├── migrations
│   └── deploy.ts
├── package.json
├── programs
│   └── counter
│       ├── Cargo.toml
│       ├── src
│       │   └── lib.rs
│       └── Xargo.toml
├── tests
│   └── counter.ts
├── tsconfig.json
└── yarn.lock

10 directories, 15 files

```

### lib.rs 文件

```rust
#![allow(unexpected_cfgs)]

use anchor_lang::prelude::*;

declare_id!("8KYmW4jDPnzXRCFR2c5b1VLRdFBsaEJk1RjUgqn7F35V");

#[program]
pub mod counter {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        let counter = &ctx.accounts.counter;
        msg!("Counter account created! Current count: {}", counter.count);
        Ok(())
    }

    pub fn increment(ctx: Context<Increment>) -> Result<()> {
        let counter = &mut ctx.accounts.counter;
        msg!("Previous counter: {}", counter.count);

        counter.count += 1;
        msg!("Counter incremented! Current count: {}", counter.count);
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(mut)]
    pub payer: Signer<'info>,

    #[account(
        init,
        payer = payer,
        space = 8 + 8
    )]
    pub counter: Account<'info, Counter>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Increment<'info> {
    #[account(mut)]
    pub counter: Account<'info, Counter>,
}

#[account]
pub struct Counter {
    pub count: u64,
}

```

此代码定义了计数器合约的initialize和increment指令，分别用于创建计数器账户和递增计数。

### 编译

```bash
counter on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 
➜ anchor build    
   Compiling counter v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/counter/programs/counter)
    Finished `release` profile [optimized] target(s) in 1.45s
   Compiling counter v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-sandbox/counter/programs/counter)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 1.46s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/solana-sandbox/counter/target/debug/deps/counter-c2859c9ce41300ce)

```

### 启动本地节点

```bash
counter on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 
➜ anchor localnet 
    Finished `release` profile [optimized] target(s) in 0.25s
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.42s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/solana-sandbox/counter/target/debug/deps/counter-c2859c9ce41300ce)
Ledger location: .anchor/test-ledger
Log: .anchor/test-ledger/validator.log
⠁ Initializing...                                                                                                Waiting for fees to stabilize 1...
Identity: HtjDDGXEmbtGmnTZS3ZKRQhRyiZuU3ca8qJGP8LFwqF1
Genesis Hash: FzJe5U98Kht3h7Vwfy4f4qnU2uMZkrwMZq8RakWmzd8t
Version: 2.1.21
Shred Version: 37242
Gossip Address: 127.0.0.1:1024
TPU Address: 127.0.0.1:1027
JSON RPC URL: http://127.0.0.1:8899
WebSocket PubSub URL: ws://127.0.0.1:8900
⠒ 00:04:04 | Processed Slot: 512 | Confirmed Slot: 512 | Finalized Slot: 481 | Full Snapshot Slot: 400 | Incrementa
```

### 部署合约

```bash
counter on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 took 4.0s 
➜ anchor deploy
Deploying cluster: http://127.0.0.1:8899
Upgrade authority: /Users/qiaopengjun/.config/solana/id.json
Deploying program "counter"...
Program path: /Users/qiaopengjun/Code/Solana/solana-sandbox/counter/target/deploy/counter.so...
Program Id: 8KYmW4jDPnzXRCFR2c5b1VLRdFBsaEJk1RjUgqn7F35V

Signature: 4dT2ohhVS9Jv14juxV44F112Z5Zh2fEQSx9fzakn6ADomo2TP4qFRSJeFv9eAYZDTUbWj2Uwj39cApDKzKR3Lv7V

Deploy success
```

## Rust客户端调用合约实战

### 复制 IDL 到客户端目录

```bash
counter on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 took 4.6s 
➜ cp -a target/idl/counter.json app/counter-rs/idls
```

### counter-rs/src/main.rs 文件

```rust
use anchor_client::{
    Client, Cluster,
    solana_client::rpc_client::RpcClient,
    solana_sdk::{
        commitment_config::CommitmentConfig, native_token::LAMPORTS_PER_SOL, signature::Keypair,
        signer::Signer, system_program,
    },
};
use anchor_lang::prelude::*;
use std::rc::Rc;

declare_program!(counter);
use counter::{accounts::Counter, client::accounts, client::args};

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    let connection = RpcClient::new_with_commitment(
        "http://127.0.0.1:8899", // Local validator URL
        CommitmentConfig::confirmed(),
    );

    // Generate Keypairs and request airdrop
    let payer = Keypair::new();
    let counter = Keypair::new();
    let counter_pubkey: Pubkey = counter.pubkey(); // 保存公钥

    println!("Generated Keypairs:");
    println!("   Payer: {}", payer.pubkey());
    println!("   Counter: {}", counter_pubkey);

    println!("\nRequesting 1 SOL airdrop to payer");
    let airdrop_signature = connection.request_airdrop(&payer.pubkey(), LAMPORTS_PER_SOL)?;

    // Wait for airdrop confirmation
    while !connection.confirm_transaction(&airdrop_signature)? {
        std::thread::sleep(std::time::Duration::from_millis(100));
    }
    println!("   Airdrop confirmed!");

    // Create program client
    let provider = Client::new_with_options(
        Cluster::Localnet,
        Rc::new(payer),
        CommitmentConfig::confirmed(),
    );
    let program = provider.program(counter::ID)?;

    // Build and send instructions
    println!("\nSend transaction with initialize and increment instructions");
    let initialize_ix = program
        .request()
        .accounts(accounts::Initialize {
            counter: counter.pubkey(),
            payer: program.payer(),
            system_program: system_program::ID,
        })
        .args(args::Initialize)
        .instructions()?
        .remove(0);

    let increment_ix = program
        .request()
        .accounts(accounts::Increment {
            counter: counter.pubkey(),
        })
        .args(args::Increment)
        .instructions()?
        .remove(0);

    let signature = program
        .request()
        .instruction(initialize_ix)
        .instruction(increment_ix)
        .signer(counter)
        .send()
        .await?;
    println!("   Transaction confirmed: {}", signature);

    println!("\nFetch counter account data");
    let counter_account: Counter = program.account::<Counter>(counter_pubkey).await?;
    println!("   Counter value: {}", counter_account.count);
    Ok(())
}

```

此客户端代码通过anchor-client库与合约交互，执行初始化和递增操作。

### 查看客户端目录

```bash
counter/app/counter-rs on  main [?] is 📦 0.1.0 via ⬢ v23.11.0 via 🦀 1.87.0 
➜ tree . -L 6 -I "target|test-ledger|.vscode|node_modules"
.
├── Cargo.lock
├── Cargo.toml
├── idls
│   └── counter.json
└── src
    └── main.rs

3 directories, 4 files

```

### 编译构建

```bash
counter/app/counter-rs on  main [?] is 📦 0.1.0 via ⬢ v23.11.0 via 🦀 1.87.0 
➜ cargo build
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.76s
```

### 运行

```bash
counter/app/counter-rs on  main [?] is 📦 0.1.0 via ⬢ v23.11.0 via 🦀 1.87.0 
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.71s
     Running `target/debug/counter-rs`
Generated Keypairs:
   Payer: 2yGfFA4PePJrxvzsyRsdJowTZU6wQicJXGytEZLK7gfU
   Counter: Cm1Z47iBmTw9vvd6as4mHx8wjw2Bdhxc3DLC1ySsmxdM

Requesting 1 SOL airdrop to payer
   Airdrop confirmed!

Send transaction with initialize and increment instructions
   Transaction confirmed: nixZo67eWi8KqQ2i9gJie44Ed9hpNNpLMrHujDg7vNHP9NTnJPTHQDZCMKhww9Xym8gW3JoVjxiuLPddBFmxDHV

Fetch counter account data
   Counter value: 1
   
counter/app/counter-rs on  main [?] is 📦 0.1.0 via ⬢ v23.11.0 via 🦀 1.87.0 took 2.3s 
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.63s
     Running `target/debug/counter-rs`
Generated Keypairs:
   Payer: 7H8VyPGELkE8A3Z4dPbRNHWmT17wXoNFg392qcKFnkXL
   Counter: FGUy5G7mH7PGr6RNrzdzVd249DV7pSTreHa8G8YkQGQN

Requesting 1 SOL airdrop to payer
   Airdrop confirmed!

Send transaction with initialize and increment instructions
   Transaction confirmed: W6ECp3DF3PYm6rMxn69LKPe86vNRvKwaB1iKBNJoLsgopkgkKxuDhfFyJT2gKtpPVYykf3yg6jT49bWw8UFLCTg

Fetch counter account data
   Counter value: 1

```

## 总结

通过本教程，你已掌握使用Anchor框架在Solana区块链上开发和部署计数器智能合约的核心技能，并学会如何用Rust客户端与合约交互。从项目初始化到合约调用，这篇实战指南展示了Solana生态的高效与Rust语言的强大。Web3的未来充满无限可能，立即动手实践，构建你的第一个去中心化应用（DApp）！

**想深入探索Solana开发？扫描下方二维码，关注我们获取更多Web3实战教程！**
二维码
**在评论区分享你的Solana开发经验，或留言你的问题，我们一起探讨！**

## 参考

- <https://www.anchor-lang.com/docs/clients/rust>
- <https://www.rust-lang.org/zh-CN>
- <https://course.rs/about-book.html>
- <https://lab.cs.tsinghua.edu.cn/rust/>
- <https://rustwasm.github.io/book/>
- <https://solana.com/zh/docs>
- <https://solanacookbook.com/zh/>
- <https://www.solanazh.com/>
