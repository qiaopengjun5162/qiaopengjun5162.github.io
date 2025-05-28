+++
title = "Web3 实战：用 Anchor 打造 Solana 智能合约全流程"
description = "Web3 实战：用 Anchor 打造 Solana 智能合约全流程"
date = 2025-05-28T00:37:37Z
[taxonomies]
categories = ["Web3", "Solana", "Anchor"]
tags = ["Web3", "Solana", "Anchor"]
+++

<!-- more -->

# Web3 实战：用 Anchor 打造 Solana 智能合约全流程

Web3 热潮席卷而来，Solana 以超高性能和低成本成为区块链开发的热门舞台。Anchor 框架让 Solana 智能合约开发变得简单而高效。本文通过 hello_anchor 项目，带你实战从项目初始化到部署的全流程，快速上手 Solana 开发，释放你的 Web3 创造力！

本文以 hello_anchor 项目为案例，详细展示如何用 Anchor 框架在 Solana 上开发智能合约。内容涵盖项目初始化、代码编写、测试验证、本地验证器运行及部署全过程，并提供部署失败的实用解决方案。适合 Web3 开发者通过实战快速掌握 Solana 智能合约开发的核心技能。

## 实操

### 创建并初始化项目

```bash
anchor init hello_anchor
yarn install v1.22.22
info No lockfile found.
[1/4] 🔍  Resolving packages...
warning mocha > glob@7.2.0: Glob versions prior to v9 are no longer supported
warning mocha > glob > inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
[2/4] 🚚  Fetching packages...
[3/4] 🔗  Linking dependencies...
[4/4] 🔨  Building fresh packages...
success Saved lockfile.
✨  Done in 3.15s.
Failed to install node modules
Initialized empty Git repository in /Users/qiaopengjun/Code/Solana/solana-sandbox/hello_anchor/.git/
hello_anchor initialized
```

### 切换到项目目录并用cursor 打开项目

```bash
cd hello_anchor/

cc
```

### 查看项目目录

```bash
hello_anchor on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 
➜ tree . -L 6 -I "target|.anchor|.vscode|node_modules"
.
├── Anchor.toml
├── app
├── Cargo.lock
├── Cargo.toml
├── migrations
│   └── deploy.ts
├── package.json
├── programs
│   └── hello_anchor
│       ├── Cargo.toml
│       ├── src
│       │   └── lib.rs
│       └── Xargo.toml
├── tests
│   └── hello_anchor.ts
├── tsconfig.json
└── yarn.lock

7 directories, 11 files

```

### lib.rs 文件

```rust
#![allow(unexpected_cfgs)]

use anchor_lang::prelude::*;

declare_id!("9yzSjhfTdHX6bz5BBd7WCKgDZGXGEFksMWpryGKTFt7X");

#[program]
pub mod hello_anchor {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>, data: u64) -> Result<()> {
        msg!("Greetings from: {:?}", ctx.program_id);
        ctx.accounts.new_account.data = data;
        msg!("Changed data to: {:?}!", data);
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(init, payer = signer, space = 8 + 8)]
    pub new_account: Account<'info, NewAccount>,
    #[account(mut)]
    pub signer: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[account]
pub struct NewAccount {
    data: u64,
}

```

这段代码是一个基于 Anchor 框架的 Solana 智能合约（Program），主要实现了一个简单的账户初始化和数据存储功能。下面逐步解释每一部分的作用：

---

#### 1. 基础导入和声明

```rust
#![allow(unexpected_cfgs)]

use anchor_lang::prelude::*;

declare_id!("9yzSjhfTdHX6bz5BBd7WCKgDZGXGEFksMWpryGKTFt7X");
```

- `#![allow(unexpected_cfgs)]`：允许一些编译器配置警告，通常可以忽略。
- `use anchor_lang::prelude::*;`：导入 Anchor 框架的常用内容，方便后续使用。
- `declare_id!`：声明当前合约（Program）的唯一ID（公钥），部署到链上后用于识别该合约。

---

### 2. 主程序模块

```rust
#[program]
pub mod hello_anchor {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>, data: u64) -> Result<()> {
        msg!("Greetings from: {:?}", ctx.program_id);
        ctx.accounts.new_account.data = data;
        msg!("Changed data to: {:?}!", data);
        Ok(())
    }
}
```

- `#[program]`：Anchor 的宏，标记这是合约的主入口模块。
- `initialize` 方法：
  - 参数 `ctx: Context<Initialize>`：上下文对象，包含所有与本次调用相关的账户信息。
  - 参数 `data: u64`：用户传入的数据，将被存储到新账户中。
  - `msg!`：在链上打印日志，便于调试。
  - `ctx.accounts.new_account.data = data;`：将传入的数据写入新账户的 `data` 字段。
  - `Ok(())`：返回成功。

---

#### 3. 账户结构体定义

```rust
#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(init, payer = signer, space = 8 + 8)]
    pub new_account: Account<'info, NewAccount>,
    #[account(mut)]
    pub signer: Signer<'info>,
    pub system_program: Program<'info, System>,
}
```

- `#[derive(Accounts)]`：Anchor 宏，自动为结构体生成账户校验逻辑。
- `new_account`：
  - `#[account(init, payer = signer, space = 8 + 8)]`：表示这是一个新建账户，由 `signer` 支付租金，分配空间为 16 字节（8 字节账户头 + 8 字节数据）。
- `signer`：调用者的钱包账户，必须是可变的（`mut`），因为要支付租金。
- `system_program`：系统程序账户，创建新账户时必须提供。

---

#### 4. 数据账户结构体

```rust
#[account]
pub struct NewAccount {
    data: u64,
}
```

- `#[account]`：Anchor 宏，标记这是一个可序列化的链上账户结构体。
- `data: u64`：实际存储的数据字段。

---

#### 总结

- 该合约允许用户调用 `initialize` 方法，创建一个新的链上账户，并将传入的 `u64` 数据存储到该账户中。
- 账户的创建由调用者（`signer`）支付租金。
- 这是 Anchor 合约的典型入门示例，演示了账户初始化和数据写入的基本流程。

### hello_anchor.ts 文件

```ts
import * as anchor from "@coral-xyz/anchor";
import { BN, Program } from "@coral-xyz/anchor";
import { HelloAnchor } from "../target/types/hello_anchor";
import { Keypair } from "@solana/web3.js";
import assert  from "assert";

describe("hello_anchor", () => {
  // Configure the client to use the local cluster.
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const wallet = provider.wallet as anchor.Wallet;

  const program = anchor.workspace.helloAnchor as Program<HelloAnchor>;

  it("Is initialized!", async () => {
    const newAccountKp = new Keypair();

    const data = new BN(42);
    const tx = await program.methods.initialize(data)
      .accounts({
        newAccount: newAccountKp.publicKey,
        signer: wallet.publicKey,
      })
      .signers([newAccountKp])
      .rpc();
    console.log("Your transaction signature", tx);

    const newAccount = await program.account.newAccount.fetch(newAccountKp.publicKey);
    assert.ok(newAccount.data.eq(data));
    console.log("New account data:", newAccount.data.toString());
    assert(data.eq(newAccount.data));
  });
});

```

这段代码是一个使用 `@coral-xyz/anchor` 框架编写的 TypeScript 测试文件，用于测试 Solana `hello_anchor` 智能合约。它通过调用合约的 `initialize` 指令，验证合约是否按预期工作。

下面逐步解释每一部分：

---

#### 1. 导入必要的库

```typescript
import * as anchor from "@coral-xyz/anchor";
import { BN, Program } from "@coral-xyz/anchor";
import { HelloAnchor } from "../target/types/hello_anchor";
import { Keypair } from "@solana/web3.js";
import assert  from "assert";
```

- `import * as anchor from "@coral-xyz/anchor";`：导入 Anchor 框架的 TypeScript/JavaScript SDK。
- `import { BN, Program } from "@coral-xyz/anchor";`：从 Anchor 导入 `BN` (大数) 类（用于处理 `u64` 等大整数类型）和 `Program` 类（用于与链上程序交互）。
- `import { HelloAnchor } from "../target/types/hello_anchor";`：导入 Anchor 自动生成的程序类型定义。`../target/types/hello_anchor.ts` 文件包含了程序 ID、指令、账户结构等的 TypeScript 接口，使得与程序交互更加类型安全。
- `import { Keypair } from "@solana/web3.js";`：从 Solana Web3 库导入 `Keypair` 类，用于生成和管理账户的密钥对。
- `import assert from "assert";`：导入 Node.js 的 `assert` 模块，用于断言测试结果是否符合预期。

---

#### 2. 测试套件定义

```typescript
describe("hello_anchor", () => {
  // Configure the client to use the local cluster.
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const wallet = provider.wallet as anchor.Wallet;

  const program = anchor.workspace.helloAnchor as Program<HelloAnchor>;

  // ... 测试用例 ...
});
```

- `describe("hello_anchor", () => { ... });`：定义一个测试套件，通常对应于要测试的程序或功能模块。这里是对 `hello_anchor` 程序进行测试。
- `const provider = anchor.AnchorProvider.env();`：创建一个 Anchor Provider。`AnchorProvider.env()` 会尝试从环境变量中获取网络连接信息（如 RPC URL 和钱包），通常用于连接到本地的 Solana 验证器 (`solana-test-validator`)。
- `anchor.setProvider(provider);`：设置全局的 Anchor Provider，以便后续的 Anchor 调用使用这个配置。
- `const wallet = provider.wallet as anchor.Wallet;`：获取当前 Provider 关联的钱包对象，用于签名交易。
- `const program = anchor.workspace.helloAnchor as Program<HelloAnchor>;`：从 Anchor 工作空间加载 `hello_anchor` 程序。`anchor.workspace` 是一个方便的属性，可以在测试中访问 `Anchor.toml` 中定义的所有程序。`<HelloAnchor>` 是类型断言，提供了类型安全。

---

#### 3. 单个测试用例

```typescript
it("Is initialized!", async () => {
  const newAccountKp = new Keypair();

  const data = new BN(42);
  const tx = await program.methods.initialize(data)
    .accounts({
      newAccount: newAccountKp.publicKey,
      signer: wallet.publicKey,
    })
    .signers([newAccountKp])
    .rpc();
  console.log("Your transaction signature", tx);

  const newAccount = await program.account.newAccount.fetch(newAccountKp.publicKey);
  assert.ok(newAccount.data.eq(data));
  console.log("New account data:", newAccount.data.toString());
  assert(data.eq(newAccount.data));
});
```

- `it("Is initialized!", async () => { ... });`：定义一个独立的测试用例，描述了要测试的具体行为。这里的描述是 "Is initialized!"，表示测试程序是否能成功初始化账户。
- `const newAccountKp = new Keypair();`：生成一个新的密钥对，这将用于创建新的 `NewAccount` 账户。新账户的公钥是 `newAccountKp.publicKey`。
- `const data = new BN(42);`：创建一个 `BN` 类型的变量 `data`，值为 42，这将是我们要存储到新账户的数据。使用 `BN` 是因为 `u64` 在 JavaScript 中可能超出原生 Number 的范围。
- `await program.methods.initialize(data)`：调用 `hello_anchor` 程序的 `initialize` 指令，并传入 `data` 作为参数。Anchor SDK 会自动根据 IDL（接口定义语言）构建调用。
- `.accounts({ ... })`：指定指令需要交互的账户。
  - `newAccount: newAccountKp.publicKey`：指定要创建的新账户的公钥。
  - `signer: wallet.publicKey`：指定支付租金和签名的账户（测试时通常使用 Provider 的钱包账户）。
  - 注意：`system_program` 账户在这里没有显式列出，Anchor SDK 通常会根据上下文自动填充，因为它是创建新账户的必需账户。
- `.signers([newAccountKp])`：指定需要额外签名的密钥对。由于 `initialize` 指令中 `new_account` 使用了 `init` 属性，表示要创建新账户，新账户的密钥对必须签名，以证明所有权并允许其被创建。
- `.rpc()`：发送交易到链上并等待其确认。成功后返回交易签名。
- `console.log("Your transaction signature", tx);`：打印交易签名，方便调试。
- `await program.account.newAccount.fetch(newAccountKp.publicKey);`：从链上获取刚刚创建的新账户的数据。`program.account` 提供了访问程序中定义的账户类型的方法，`newAccount` 对应于合约中的 `NewAccount` 结构体。`fetch` 方法根据账户公钥获取并反序列化账户数据。
- `assert.ok(newAccount.data.eq(data));`：使用 `assert.ok` 检查获取到的账户数据的 `data` 字段是否等于我们期望的值 `data`。`BN` 对象使用 `.eq()` 方法进行相等比较。
- `console.log("New account data:", newAccount.data.toString());`：打印从链上获取到的账户数据。
- `assert(data.eq(newAccount.data));`：再次使用 `assert` 检查数据是否匹配。

---

#### 总结

这段测试代码：

1. 设置了连接到本地 Solana 环境的 Provider 和钱包。
2. 加载了要测试的 `hello_anchor` 程序。
3. 定义了一个测试用例，模拟调用 `initialize` 指令。
4. 生成了一个新的账户密钥对，并指定要存储的数据 (42)。
5. 构建并发送交易，调用 `initialize` 指令，指定新账户和签名者。
6. 成功发送交易后，从链上读取新创建账户的数据。
7. 断言读取到的数据与发送时的数据 (42) 相同，验证指令是否正确执行。

这个测试文件是确保智能合约功能按预期工作的重要组成部分。

### 编译项目

```bash
hello_anchor on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 took 1m 5.6s 
➜ anchor build
    Finished `release` profile [optimized] target(s) in 0.36s
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.35s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/solana-sandbox/hello_anchor/target/debug/deps/hello_anchor-fb07825913b8db7c)

```

### **运行本地验证器**

```bash
hello_anchor on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 
➜ anchor localnet
    Finished `release` profile [optimized] target(s) in 0.33s
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.31s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/solana-sandbox/hello_anchor/target/debug/deps/hello_anchor-fb07825913b8db7c)
Ledger location: .anchor/test-ledger
Log: .anchor/test-ledger/validator.log
⠒ Initializing...                                                                                                                                                                         Waiting for fees to stabilize 1...
Identity: 9Kf8EJnvJuyDoxtzdPBZVmv4rDYcpnP9fNhYw1ZyCSTm
Genesis Hash: 7WQNftxjgGyyR81rPY6qTyWw68H926AdwyLb2HfGUBfg
Version: 2.1.21
Shred Version: 61187
Gossip Address: 127.0.0.1:1024
TPU Address: 127.0.0.1:1027
JSON RPC URL: http://127.0.0.1:8899
WebSocket PubSub URL: ws://127.0.0.1:8900
⠁ 00:00:44 | Processed Slot: 92 | Confirmed Slot: 92 | Finalized Slot: 61 | Full Snapshot Slot: - | Incremental Snapshot Slot: - | Transactions: 92 | ◎499.999545000                      
```

### 测试

```bash
hello_anchor on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 
➜ anchor test
    Finished `release` profile [optimized] target(s) in 0.30s
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.33s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/solana-sandbox/hello_anchor/target/debug/deps/hello_anchor-fb07825913b8db7c)

Found a 'test' script in the Anchor.toml. Running it as a test suite!

Running test suite: "/Users/qiaopengjun/Code/Solana/solana-sandbox/hello_anchor/Anchor.toml"

yarn run v1.22.22
$ /Users/qiaopengjun/Code/Solana/solana-sandbox/hello_anchor/node_modules/.bin/ts-mocha -p ./tsconfig.json -t 1000000 'tests/**/*.ts'
(node:65366) ExperimentalWarning: Type Stripping is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
(node:65366) [MODULE_TYPELESS_PACKAGE_JSON] Warning: Module type of file:///Users/qiaopengjun/Code/Solana/solana-sandbox/hello_anchor/tests/hello_anchor.ts is not specified and it doesn't parse as CommonJS.
Reparsing as ES module because module syntax was detected. This incurs a performance overhead.
To eliminate this warning, add "type": "module" to /Users/qiaopengjun/Code/Solana/solana-sandbox/hello_anchor/package.json.


  hello_anchor
Your transaction signature nN7Cpc4yLFQNmMTzw4RERehCJ5WXyNcG3rc7rhuoxmrrtf8P7oLsiWe85K3ELXXkn1trzFdZEtRbggmAXRBDPiZ
New account data: 42
    ✔ Is initialized! (198ms)


  1 passing (208ms)

✨  Done in 2.10s.
```

### 部署

#### 部署失败

```bash
hello_anchor on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 
➜ anchor deploy

Deploying cluster: http://127.0.0.1:8899
Upgrade authority: /Users/qiaopengjun/.config/solana/id.json
Deploying program "hello_anchor"...
Program path: /Users/qiaopengjun/Code/Solana/solana-sandbox/hello_anchor/target/deploy/hello_anchor.so...
Error: Program's authority Some(11111111111111111111111111111111) does not match authority provided 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
There was a problem deploying: Output { status: ExitStatus(unix_wait_status(256)), stdout: "", stderr: "" }.
```

这个部署错误表明你的程序 ID 配置与部署密钥不匹配。

#### 解决方案：重置程序ID

第一步：删除旧的程序ID文件：

```bash
hello_anchor on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 
➜ rm -f target/deploy/hello_anchor-keypair.json
```

第二步：重新生成程序ID：

```bash
hello_anchor on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 
➜ anchor keys sync
Found incorrect program id declaration in "/Users/qiaopengjun/Code/Solana/solana-sandbox/hello_anchor/programs/hello_anchor/src/lib.rs"
Updated to 9yzSjhfTdHX6bz5BBd7WCKgDZGXGEFksMWpryGKTFt7X

Found incorrect program id declaration in Anchor.toml for the program `hello_anchor`
Updated to 9yzSjhfTdHX6bz5BBd7WCKgDZGXGEFksMWpryGKTFt7X

All program id declarations are synced.
Please rebuild the program to update the generated artifacts.
```

第三步：重新部署：

```bash
hello_anchor on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 
➜ anchor deploy
Deploying cluster: http://127.0.0.1:8899
Upgrade authority: /Users/qiaopengjun/.config/solana/id.json
Deploying program "hello_anchor"...
Program path: /Users/qiaopengjun/Code/Solana/solana-sandbox/hello_anchor/target/deploy/hello_anchor.so...
Program Id: 9yzSjhfTdHX6bz5BBd7WCKgDZGXGEFksMWpryGKTFt7X

Signature: 5UckCcNf8142Tz9xAa9iAt5Jo6ttDEYGwVEE29YHyFExyWccXSqWKSwpJCzeLjZiATnEKUPstUU1weWw15mzjNLb

Deploy success

```

成功部署！

## 总结

通过 hello_anchor 项目的实战，我们从初始化、编写 lib.rs 和测试脚本，到运行本地验证器和成功部署，完整体验了 Anchor 在 Solana 开发中的高效与便捷。无论是解决程序 ID 不匹配的小技巧，还是流畅的测试部署流程，这篇实战指南为你铺平了 Web3 开发的道路。马上动手，在 Solana 生态中打造你的 Web3 应用！

## 参考

- <https://www.anchor-lang.com/docs/basics/idl>
- <https://soldev.cn/>
- <https://solana.com/zh/developers/cookbook#contributing>
- <https://solana.com/zh/docs>
- <https://solscan.io/>
- <https://www.solanazh.com/>
