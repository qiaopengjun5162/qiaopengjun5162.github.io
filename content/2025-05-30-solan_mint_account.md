+++
title = "Web3 开发实操：用 Anchor 在 Solana 创建代币 Mint Account"
description = "Web3 开发实操：用 Anchor 在 Solana 创建代币 Mint Account"
date = 2025-05-30T09:33:29Z
[taxonomies]
categories = ["Web3", "Rust", "Solana"]
tags = ["Web3", "Rust", "Solana"]
+++

<!-- more -->

# Web3 开发实操：用 Anchor 在 Solana 创建代币 Mint Account

Web3 浪潮席卷全球，Solana 凭借其高吞吐量和低成本成为区块链开发者的首选平台。在 Solana 生态中，代币（Token）是构建去中心化应用（dApp）的核心，而 Mint Account 则是代币创建的起点。本文将带你走进 Web3 开发的世界，通过 Anchor 框架，手把手教你如何在 Solana 上创建和初始化代币 Mint Account。无论你是想快速上手 Solana 开发的初学者，还是希望深入探索 Web3 技术的开发者，这篇实操指南都将为你提供清晰的代码示例和详细解析，助你从零到一打造属于自己的代币！

本文通过一个完整的实操流程，详细讲解如何使用 Anchor 框架在 Solana 区块链上创建代币 Mint Account。内容涵盖项目初始化、依赖安装、Rust 智能合约开发（包括密钥对和 PDA 两种 Mint Account 创建方式）、TypeScript 测试脚本编写，以及本地测试验证。文章深入解析了 lib.rs 和 create-mint-account.ts 的代码逻辑，阐明账户结构和权限设置的原理。测试结果展示了程序的成功运行，适合 Web3 开发者快速掌握 Solana 代币开发的核心技能，为构建 dApp 奠定基础。

## Create a Token Mint

学习如何使用 Anchor 在 Solana 程序中创建和初始化代币 Mint Account。本指南将介绍如何使用生成的密钥对或 PDA 创建 Mint Account，并提供代码示例。

Mint Account 是 Solana 代币程序中的一种账户类型，它唯一地代表网络上的代币并存储有关该代币的全局元数据信息。

Solana 上的每个代币 Token 都由一个 Mint Account 表示，其中 Mint Account 的地址作为网络上的唯一标识符。

## 实操

### 创建项目并初始化

```bash
anchor init create-mint-account
yarn install v1.22.22
info No lockfile found.
[1/4] 🔍  Resolving packages...
warning mocha > glob@7.2.0: Glob versions prior to v9 are no longer supported
warning mocha > glob > inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
[2/4] 🚚  Fetching packages...
[3/4] 🔗  Linking dependencies...
[4/4] 🔨  Building fresh packages...
success Saved lockfile.
✨  Done in 2.99s.
Failed to install node modules
Initialized empty Git repository in /Users/qiaopengjun/Code/Solana/solana-sandbox/create-mint-account/.git/
create-mint-account initialized
```

### 切换到项目目录

```bash
cd create-mint-account

```

### **显示当前目录下所有文件和文件夹的详细信息**（包括隐藏文件）

`ls -la` 是 Linux/Unix/macOS 终端中的命令，用于**显示当前目录下所有文件和文件夹的详细信息**（包括隐藏文件）。

```bash
ls -la
total 152
drwxr-xr-x@  16 qiaopengjun  staff    512 May 30 11:38 .
drwxr-xr-x@  19 qiaopengjun  staff    608 May 30 11:38 ..
drwxr-xr-x@   9 qiaopengjun  staff    288 May 30 11:38 .git
-rw-r--r--@   1 qiaopengjun  staff     67 May 30 11:38 .gitignore
-rw-r--r--@   1 qiaopengjun  staff     61 May 30 11:38 .prettierignore
-rw-r--r--@   1 qiaopengjun  staff    365 May 30 11:38 Anchor.toml
-rw-r--r--@   1 qiaopengjun  staff    215 May 30 11:38 Cargo.toml
drwxr-xr-x@   2 qiaopengjun  staff     64 May 30 11:38 app
drwxr-xr-x@   3 qiaopengjun  staff     96 May 30 11:38 migrations
drwxr-xr-x@ 150 qiaopengjun  staff   4800 May 30 11:38 node_modules
-rw-r--r--@   1 qiaopengjun  staff    461 May 30 11:38 package.json
drwxr-xr-x@   3 qiaopengjun  staff     96 May 30 11:38 programs
drwxr-xr-x@   3 qiaopengjun  staff     96 May 30 11:38 target
drwxr-xr-x@   3 qiaopengjun  staff     96 May 30 11:38 tests
-rw-r--r--@   1 qiaopengjun  staff    205 May 30 11:38 tsconfig.json
-rw-r--r--@   1 qiaopengjun  staff  52284 May 30 11:38 yarn.lock
```

命令解析

| 部分 |                        作用                        |
| :--: | :------------------------------------------------: |
| `ls` |                列出目录内容（list）                |
| `-l` | 以**列表形式**显示详细信息（权限、所有者、大小等） |
| `-a` |   显示**所有文件**（包括以 `.` 开头的隐藏文件）    |

### 安装项目依赖

```bash
cargo add anchor-spl
     
 create-mint-account on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 on 🐳 v27.5.1 (orbstack) 
➜ yarn add @solana/kit

create-mint-account on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 on 🐳 v27.5.1 (orbstack) 
➜ yarn add @solana/spl-token      
```

### 查看项目目录

```bash
create-mint-account on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 on 🐳 v27.5.1 (orbstack) took 8.2s 
➜ tree . -L 6 -I "target|test-ledger|.vscode|node_modules"
.
├── Anchor.toml
├── app
├── Cargo.lock
├── Cargo.toml
├── migrations
│   └── deploy.ts
├── package.json
├── programs
│   └── create-mint-account
│       ├── Cargo.toml
│       ├── src
│       │   └── lib.rs
│       └── Xargo.toml
├── tests
│   └── create-mint-account.ts
├── tsconfig.json
└── yarn.lock

7 directories, 11 files

```

### lib.rs 文件

```rust
#![allow(unexpected_cfgs)]

use anchor_lang::prelude::*;
use anchor_spl::token_interface::{Mint, TokenInterface};

declare_id!("imZB6kiVRXTgBaH2HyyWhFTLy5pRgZBwp9zLzSVFrKK");

#[program]
pub mod create_mint_account {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        msg!("Greetings from: {:?}", ctx.program_id);
        Ok(())
    }

    // Create a new mint account in using a generated Keypair.
    pub fn create_mint(ctx: Context<CreateMint>) -> Result<()> {
        msg!("Creating mint: {:?}", ctx.accounts.mint.key());
        Ok(())
    }

    // Create a new mint account using a Program Derived Address (PDA) as the address of the mint account.
     pub fn create_mint2(ctx: Context<CreateMint2>) -> Result<()> {
        msg!("Created Mint Account: {:?}", ctx.accounts.mint.key());
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize {}

#[derive(Accounts)]
pub struct CreateMint<'info> {
    #[account(mut)]
    pub signer: Signer<'info>,
    #[account(
        init,
        payer = signer,
        mint::decimals = 6,
        mint::authority = signer.key(),
        mint::freeze_authority = signer.key(),
    )]
    pub mint: InterfaceAccount<'info, Mint>,
    pub token_program: Interface<'info, TokenInterface>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct CreateMint2<'info> {
    #[account(mut)]
    pub signer: Signer<'info>,
    #[account(
        init,
        payer = signer,
        mint::decimals = 6,
        mint::authority = mint.key(),
        mint::freeze_authority = mint.key(),
        seeds = [b"mint"],
        bump
    )]
    pub mint: InterfaceAccount<'info, Mint>,
    pub token_program: Interface<'info, TokenInterface>,
    pub system_program: Program<'info, System>,
}
```

这段代码是一个使用 **Rust** 语言和 **Anchor 框架** 编写的 **Solana 智能合约（程序）**，用于在 Solana 区块链上创建和管理代币铸造账户（Mint Account）。以下是对代码的详细解释：

- 该程序旨在创建和初始化代币铸造账户，用于在 Solana 区块链上定义新的代币（例如类似加密货币的可互换代币）。
- 它使用 **Anchor 框架**，该框架为 Solana 程序开发提供了便利，包括账户验证、序列化和与 Solana 程序库（SPL）的代币操作集成。
- 程序包含三个主要函数：initialize、create_mint 和 create_mint2，每个函数在铸造账户创建中担任不同角色。
- 代码通过 **SPL 代币程序**（SPL Token Program）与代币铸造账户进行交互。

**代码详解**

**1. 文件头和导入**

```rust
#![allow(unexpected_cfgs)]
use anchor_lang::prelude::*;
use anchor_spl::token_interface::{Mint, TokenInterface};
```

- **#![allow(unexpected_cfgs)]**: Rust 属性，用于抑制关于意外配置标志的警告。在 Solana 程序中常用于处理与不同 Solana 运行时环境的兼容性问题。
- **use anchor_lang::prelude::\***: 导入 Anchor 框架的核心工具，包括账户、上下文和错误处理相关的类型。
- **use anchor_spl::token_interface::{Mint, TokenInterface}**: 导入 Anchor 提供的 SPL 代币接口，包含代币铸造账户（Mint）和 SPL 代币程序（TokenInterface）的抽象。

**2. 程序 ID 声明**

```rust
declare_id!("imZB6kiVRXTgBaH2HyyWhFTLy5pRgZBwp9zLzSVFrKK");
```

- **declare_id!**: 定义该 Solana 程序的唯一程序 ID（公钥）。此 ID 用于在 Solana 区块链上标识该程序。提供的 ID（imZB6...）是程序的唯一地址。

**3. 程序模块**

```rust
#[program]
pub mod create_mint_account {
    use super::*;
    ...
}
```

- **#[program]**: Anchor 宏，表示这是一个 Solana 程序模块，包含程序的入口函数。
- **pub mod create_mint_account**: 定义程序模块，命名为 create_mint_account，包含程序的逻辑。

**4. 程序函数**

程序定义了三个函数，用于不同的初始化和铸造账户创建场景：

**4.1 initialize 函数**

```rust
pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
    msg!("Greetings from: {:?}", ctx.program_id);
    Ok(())
}
```

- **功能**: 一个简单的初始化函数，记录程序 ID 并返回成功。
- **参数**: ctx: Context<Initialize>，使用 Initialize 账户结构（定义在下方）。
- **输出**: 使用 msg! 宏记录日志，输出程序 ID，并返回 Result<()>（Ok(())） 表示成功。
- **用途**: 这是一个占位函数，可能用于测试或初始化程序状态，但目前仅打印日志。

**4.2 create_mint 函数**

```rust
pub fn create_mint(ctx: Context<CreateMint>) -> Result<()> {
    msg!("Creating mint: {:?}", ctx.accounts.mint.key());
    Ok(())
}
```

- **功能**: 创建一个新的代币铸造账户，使用生成的密钥对（Keypair）作为铸造账户的地址。
- **参数**: ctx: Context<CreateMint>，使用 CreateMint 账户结构（定义在下方）。
- **输出**: 记录铸造账户的公钥并返回成功。
- **用途**: 用于创建一个标准的代币铸造账户，指定代币的精度（decimals）、铸造权限和冻结权限。

**4.3 create_mint2 函数**

```rust
pub fn create_mint2(ctx: Context<CreateMint2>) -> Result<()> {
    msg!("Created Mint Account: {:?}", ctx.accounts.mint.key());
    Ok(())
}
```

- **功能**: 创建一个新的代币铸造账户，使用 **程序派生地址（PDA，Program Derived Address）** 作为铸造账户的地址。
- **参数**: ctx: Context<CreateMint2>，使用 CreateMint2 账户结构（定义在下方）。
- **输出**: 记录创建的铸造账户公钥并返回成功。
- **用途**: 与 create_mint 类似，但使用 PDA 作为铸造账户地址，PDA 通常用于程序控制的账户，增强安全性和可预测性。

**5. 账户结构**

Anchor 使用 #[derive(Accounts)] 宏定义每个函数部分函数所需的账户结构，自动验证账户的正确性。

**5.1 Initialize 结构**

```rust
#[derive(Accounts)]
pub struct Initialize {}
```

- **说明**: 空账户结构，仅用于 initialize 函数。由于该函数没有实际操作，结构为空。
- **用途**: 占位结构，可能为未来扩展预留。

**5.2 CreateMint 结构**

```rust
#[derive(Accounts)]
pub struct CreateMint<'info> {
    #[account(mut)]
    pub signer: Signer<'info>,
    #[account(
        init,
        payer = signer,
        mint::decimals = 6,
        mint::authority = signer.key(),
        mint::freeze_authority = signer.key(),
    )]
    pub mint: InterfaceAccount<'info, Mint>,
    pub token_program: Interface<'info, TokenInterface>,
    pub system_program: Program<'info, System>,
}
```

- **说明**: 定义 create_mint 函数所需的账户：
  - **signer**: 调用者的账户，必须是签名者（mut 表示可修改，因为需要支付创建费用）。
  - **mint**: 要创建的代币铸造账户，带有以下约束：
    - init: 初始化新账户。
    - payer = signer: 由签名者支付账户创建费用。
    - mint::decimals = 6: 代币精度为 6 位小数。
    - mint::authority = signer.key(): 签名者是铸造权限持有者（可发行代币）。
    - mint::freeze_authority = signer.key(): 签名者是冻结权限持有者（可冻结代币）。
  - **token_program**: SPL 代币程序，用于处理代币相关操作。
  - **system_program**: Solana 系统程序，用于创建新账户。
- **用途**: 定义创建标准铸造账户所需的账户和参数。

**5.3 CreateMint2 结构**

```rust
#[derive(Accounts)]
pub struct CreateMint2<'info> {
    #[account(mut)]
    pub signer: Signer<'info>,
    #[account(
        init,
        payer = signer,
        mint::decimals = 6,
        mint::authority = mint.key(),
        mint::freeze_authority = mint.key(),
        seeds = [b"mint"],
        bump
    )]
    pub mint: InterfaceAccount<'info, Mint>,
    pub token_program: Interface<'info, TokenInterface>,
    pub system_program: Program<'info, System>,
}
```

- **说明**: 定义 create_mint2 函数所需的账户，与 CreateMint 类似，但有以下不同：
  - **mint::authority = mint.key()**: 铸造权限设置为铸造账户自身的公钥（PDA）。
  - **mint::freeze_authority = mint.key()**: 冻结权限也设置为铸造账户自身的公钥。
  - **seeds = [b"mint"]**: 使用种子 "mint" 生成 PDA。
  - **bump**: PDA 的“碰撞”值，用于确保地址唯一。
- **用途**: 定义使用 PDA 创建铸造账户所需的账户，PDA 由程序控制，增加安全性和可预测性。

**代码功能总结**

1. **initialize**: 简单的初始化函数，记录程序 ID，可能用于测试或未来扩展。
2. **create_mint**: 创建一个代币铸造账户，使用常规密钥对，签名者控制铸造和冻结权限。
3. **create_mint2**: 创建一个代币铸造账户，使用 PDA 地址，铸造和冻结权限由铸造账户自身控制，适合程序管理的场景。

### 编译构建项目

```bash
create-mint-account on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 on 🐳 v27.5.1 (orbstack) 
➜ anchor build 
    Finished `release` profile [optimized] target(s) in 0.36s
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.34s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/solana-sandbox/create-mint-account/target/debug/deps/create_mint_account-bd9e7827d57db214)
```

### create-mint-account.ts 文件

```ts
import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { CreateMintAccount } from "../target/types/create_mint_account";
import { TOKEN_2022_PROGRAM_ID, getMint } from "@solana/spl-token";

describe("create-mint-account", () => {
  // Configure the client to use the local cluster.
  anchor.setProvider(anchor.AnchorProvider.env());

  const program = anchor.workspace
    .createMintAccount as Program<CreateMintAccount>;
  const mint = anchor.web3.Keypair.generate();
  const [mint2, bump] = anchor.web3.PublicKey.findProgramAddressSync(
    [Buffer.from("mint")],
    program.programId,
  );

  it("Is initialized!", async () => {
    // Add your test here.
    const tx = await program.methods.initialize().rpc();
    console.log("Your transaction signature", tx);
  });

  it("Create mint", async () => {
    const create_mint_tx = await program.methods
      .createMint()
      .accounts({
        mint: mint.publicKey,
        tokenProgram: TOKEN_2022_PROGRAM_ID,
      })
      .signers([mint])
      .rpc({ commitment: "confirmed" });
    console.log("Your transaction signature", create_mint_tx);

    const mintAccount = await getMint(
      program.provider.connection,
      mint.publicKey,
      "confirmed",
      TOKEN_2022_PROGRAM_ID
    );

    console.log("Mint Account", mintAccount);
  });

  it("Create Mint By PDA!", async () => {
    const tx = await program.methods
      .createMint2()
      .accounts({
        tokenProgram: TOKEN_2022_PROGRAM_ID,
      })
      .rpc({ commitment: "confirmed" });
    console.log("Your createMint transaction signature", tx);

    const mintAccount = await getMint(
      program.provider.connection,
      mint2,
      "confirmed",
      TOKEN_2022_PROGRAM_ID,
    );

    console.log("Mint Account", mintAccount);
  });
});

```

这段代码是一个使用 **Mocha 测试框架** 和 **Anchor 框架** 编写的 **JavaScript/TypeScript 测试脚本**，用于测试 Solana 智能合约（create_mint_account 程序）。它测试了程序的三个功能：初始化、创建代币铸造账户（Mint Account）和使用程序派生地址（PDA）创建代币铸造账户。以下是对代码的详细解释：

**代码概述**

- **测试框架**: 使用 Mocha 进行测试，describe 和 it 用于组织测试用例。
- **Anchor 框架**: 用于与 Solana 程序交互，简化账户管理和程序调用。
- **SPL 代币程序**: 使用 @solana/spl-token 库中的 TOKEN_2022_PROGRAM_ID 和 getMint 来创建和验证代币铸造账户。
- **测试目标**: 验证 create_mint_account 程序的三个指令（initialize、createMint 和 createMint2）是否按预期工作。

**代码详解**

**1. 导入和初始化**

```javascript
import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { CreateMintAccount } from "../target/types/create_mint_account";
import { TOKEN_2022_PROGRAM_ID, getMint } from "@solana/spl-token";
```

- **anchor**: 导入 Anchor 框架，用于与 Solana 程序交互。
- **CreateMintAccount**: 导入程序的类型定义（由 Anchor 自动生成，位于 ../target/types/create_mint_account），用于类型安全的程序调用。
- **TOKEN_2022_PROGRAM_ID, getMint**: 导入 SPL 代币程序的 ID 和 getMint 函数，用于创建和查询代币铸造账户。

**2. 测试套件定义**

```javascript
describe("create-mint-account", () => {
  ...
});
```

- **describe**: Mocha 的测试套件，命名为 create-mint-account，包含多个测试用例（it 块）。

**3. 初始化设置**

```javascript
anchor.setProvider(anchor.AnchorProvider.env());
const program = anchor.workspace.createMintAccount as Program<CreateMintAccount>;
const mint = anchor.web3.Keypair.generate();
const [mint2, bump] = anchor.web3.PublicKey.findProgramAddressSync(
  [Buffer.from("mint")],
  program.programId,
);
```

- **anchor.setProvider(anchor.AnchorProvider.env())**: 配置 Anchor 使用环境提供者（通常是本地 Solana 集群或其他配置的网络，如 devnet）。提供者包括连接和钱包信息。
- **program**: 从工作空间加载 create_mint_account 程序，类型为 Program<CreateMintAccount>，用于调用程序指令。
- **mint**: 使用 anchor.web3.Keypair.generate() 生成一个新的密钥对，用于 createMint 函数的铸造账户地址。
- **[mint2, bump]**: 使用 findProgramAddressSync 计算程序派生地址（PDA），种子为 Buffer.from("mint")，与程序的 createMint2 函数中的 seeds = [b"mint"] 一致。bump 是确保 PDA 唯一性的偏移值。

**4. 测试用例**

**4.1 初始化测试**

```javascript
it("Is initialized!", async () => {
  const tx = await program.methods.initialize().rpc();
  console.log("Your transaction signature", tx);
});
```

- **功能**: 测试程序的 initialize 指令。
- **调用**: 使用 program.methods.initialize().rpc() 调用 initialize 指令，发送交易到 Solana 集群。
- **输出**: 记录交易签名（tx），用于调试和验证。
- **验证**: 仅验证交易是否成功执行（通过 rpc() 的返回），没有额外的账户验证（因为 Initialize 结构为空）。

**4.2 创建铸造账户测试**

```javascript
it("Create mint", async () => {
  const create_mint_tx = await program.methods
    .createMint()
    .accounts({
      mint: mint.publicKey,
      tokenProgram: TOKEN_2022_PROGRAM_ID,
    })
    .signers([mint])
    .rpc({ commitment: "confirmed" });
  console.log("Your transaction signature", create_mint_tx);

  const mintAccount = await getMint(
    program.provider.connection,
    mint.publicKey,
    "confirmed",
    TOKEN_2022_PROGRAM_ID
  );

  console.log("Mint Account", mintAccount);
});
```

- **功能**: 测试 createMint 指令，创建代币铸造账户。
- **调用**:
  - 使用 program.methods.createMint() 调用 createMint 指令。
  - **accounts**: 指定所需的账户：
    - mint: 使用生成的密钥对的公钥（mint.publicKey）。
    - tokenProgram: 使用 TOKENsony_2022_PROGRAM_ID（SPL 代币程序 ID）。
    - 其他账户（如 signer 和 systemProgram）由 Anchor 自动填充。
  - **signers([mint])**: 提供 mint 密钥对，用于签名交易（因为 signer 是交易的支付者和权限持有者）。
  - **rpc({ commitment: "confirmed" })**: 发送交易并等待确认。
- **验证**:
  - 使用 getMint 查询创建的铸造账户信息（如精度、铸造权限等）。
  - 输出交易签名和铸造账户信息，用于调试和验证。
- **预期行为**: 创建一个精度为 6 的代币铸造账户，签名者拥有铸造和冻结权限。

**4.3 使用 PDA 创建铸造账户测试**

```javascript
it("Create Mint By PDA!", async () => {
  const tx = await program.methods
    .createMint2()
    .accounts({
      tokenProgram: TOKEN_2022_PROGRAM_ID,
    })
    .rpc({ commitment: "confirmed" });
  console.log("Your createMint transaction signature", tx);

  const mintAccount = await getMint(
    program.provider.connection,
    mint2,
    "confirmed",
    TOKEN_2022_PROGRAM_ID,
  );

  console.log("Mint Account", mintAccount);
});
```

- **功能**: 测试 createMint2 指令，使用 PDA 创建代币铸造账户。
- **调用**:
  - 使用 program.methods.createMint2() 调用 createMint2 指令。
  - **accounts**: 仅需显式指定 tokenProgram，其他账户（如 mint 使用 PDA，由 Anchor 自动处理）。
  - **rpc({ commitment: "confirmed" })**: 发送交易并等待确认。
- **验证**:
  - 使用 getMint 查询 PDA 地址（mint2）的铸造账户信息。
  - 输出交易签名和铸造账户信息。
- **预期行为**: 创建一个精度为 6 的代币铸造账户，铸造和冻结权限由 PDA 自身控制。

**代码功能总结**

1. **初始化测试**: 调用 initialize 指令，验证程序是否能成功初始化（仅记录日志）。
2. **创建铸造账户测试**: 调用 createMint 指令，创建一个由签名者控制的代币铸造账户，并验证其属性。
3. **使用 PDA 创建铸造账户测试**: 调用 createMint2 指令，创建一个由程序控制（PDA）的代币铸造账户，并验证其属性。

### 测试项目

```bash
create-mint-account on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 on 🐳 v27.5.1 (orbstack) 
➜ anchor test                                             
    Finished `release` profile [optimized] target(s) in 0.46s
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.39s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/solana-sandbox/create-mint-account/target/debug/deps/create_mint_account-bd9e7827d57db214)

Found a 'test' script in the Anchor.toml. Running it as a test suite!

Running test suite: "/Users/qiaopengjun/Code/Solana/solana-sandbox/create-mint-account/Anchor.toml"

yarn run v1.22.22
$ /Users/qiaopengjun/Code/Solana/solana-sandbox/create-mint-account/node_modules/.bin/ts-mocha -p ./tsconfig.json -t 1000000 'tests/**/*.ts'
(node:85466) ExperimentalWarning: Type Stripping is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)


  create-mint-account
Your transaction signature 9ovgCj4bb19r4BwC3ArzDvNVeE9mDSvu7Cx3uVamjYn2xiugxFjYa1HKHy3zw2u7MBzp1jss2CYoetBr9cm44zQ
    ✔ Is initialized! (179ms)
Your transaction signature 2fBN7TbfZddU8c1XrakLw4MQ8GvWAQyE5nKkVVNgqsSvBfhQCZUizj3AWeqf6cXQUUBgAARq2m7CfuyRU2sB3W13
Mint Account {
  address: PublicKey [PublicKey(D21KKqjsqz3HaR2kMW2qq6LkXgaifot9Z3rMxXaS4sy4)] {
    _bn: <BN: b28e2e60e3939202172ae8f57ccb9d56f803152187edc7d7f5c3e4dddad08f63>
  },
  mintAuthority: PublicKey [PublicKey(6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd)] {
    _bn: <BN: 4f8e79c1003c7aa7f93a5cf37105d0c9cd65d9f50b561eb445e66e337f08cba6>
  },
  supply: 0n,
  decimals: 6,
  isInitialized: true,
  freezeAuthority: PublicKey [PublicKey(6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd)] {
    _bn: <BN: 4f8e79c1003c7aa7f93a5cf37105d0c9cd65d9f50b561eb445e66e337f08cba6>
  },
  tlvData: <Buffer >
}
    ✔ Create mint (484ms)
Your createMint transaction signature 35Mm6HdV3eKKqWUrpUduNVoHDcxCwp311qD6zsZfXzczCkWZimpoy5rESU9fmt3abkXmTkmpdDgA3SetJhZ9eBDR
Mint Account {
  address: PublicKey [PublicKey(FsWBzdtMASX63bFunnvwoecwTvX1vg31VnNmBCrbKx9b)] {
    _bn: <BN: dcf3a98292e047a29457ab3bad8e0bbf517348d486e1948cd422d0921a645afe>
  },
  mintAuthority: PublicKey [PublicKey(FsWBzdtMASX63bFunnvwoecwTvX1vg31VnNmBCrbKx9b)] {
    _bn: <BN: dcf3a98292e047a29457ab3bad8e0bbf517348d486e1948cd422d0921a645afe>
  },
  supply: 0n,
  decimals: 6,
  isInitialized: true,
  freezeAuthority: PublicKey [PublicKey(FsWBzdtMASX63bFunnvwoecwTvX1vg31VnNmBCrbKx9b)] {
    _bn: <BN: dcf3a98292e047a29457ab3bad8e0bbf517348d486e1948cd422d0921a645afe>
  },
  tlvData: <Buffer >
}
    ✔ Create Mint By PDA! (448ms)


  3 passing (1s)

✨  Done in 2.59s.

create-mint-account on  main [?] via ⬢ v23.11.0 via 🦀 1.87.0 on 🐳 v27.5.1 (orbstack) took 5.2s 
➜ anchor test 
    Finished `release` profile [optimized] target(s) in 0.36s
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.35s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/solana-sandbox/create-mint-account/target/debug/deps/create_mint_account-bd9e7827d57db214)

Found a 'test' script in the Anchor.toml. Running it as a test suite!

Running test suite: "/Users/qiaopengjun/Code/Solana/solana-sandbox/create-mint-account/Anchor.toml"

yarn run v1.22.22
$ /Users/qiaopengjun/Code/Solana/solana-sandbox/create-mint-account/node_modules/.bin/ts-mocha -p ./tsconfig.json -t 1000000 'tests/**/*.ts'
(node:88117) ExperimentalWarning: Type Stripping is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)


  create-mint-account
Your transaction signature 4zrX9b4PSt8FksCfVPk1S4hET94pBo5YU5XJzu6z4m3YF1rjjGsHxsqqe3pGuRLXErMDNY38N6AKsBBYJjDPHWW8
    ✔ Is initialized! (161ms)
Your transaction signature 5iP6o99P4knkY6aXNrbPsvbJWxAkKeuwQELde15z9x6JZDXxNquTqHyXEBMmbCMz3wiLsitqBvVSQNmyhqaZ42X1
Mint Account {
  address: PublicKey [PublicKey(38kN6CqjLCfSdjPEt9sBPSKgXrMe77gKxwuaHMj37NJ4)] {
    _bn: <BN: 1fb3788dc343c76867eb9cd9eab92cd7619723b872dd93f07087e121e23a7921>
  },
  mintAuthority: PublicKey [PublicKey(6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd)] {
    _bn: <BN: 4f8e79c1003c7aa7f93a5cf37105d0c9cd65d9f50b561eb445e66e337f08cba6>
  },
  supply: 0n,
  decimals: 6,
  isInitialized: true,
  freezeAuthority: PublicKey [PublicKey(6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd)] {
    _bn: <BN: 4f8e79c1003c7aa7f93a5cf37105d0c9cd65d9f50b561eb445e66e337f08cba6>
  },
  tlvData: <Buffer >
}
    ✔ Create mint (486ms)
Your createMint transaction signature 3zDXJee9Gjuks4aQYiqvp5etRgMdqQhtuP5xp1DMpkYjeNuAY6pKJXvhy9iysEZxVfpnPJVCNsjXTQsH8qKbhhZ2
Mint Account {
  address: PublicKey [PublicKey(FsWBzdtMASX63bFunnvwoecwTvX1vg31VnNmBCrbKx9b)] {
    _bn: <BN: dcf3a98292e047a29457ab3bad8e0bbf517348d486e1948cd422d0921a645afe>
  },
  mintAuthority: PublicKey [PublicKey(FsWBzdtMASX63bFunnvwoecwTvX1vg31VnNmBCrbKx9b)] {
    _bn: <BN: dcf3a98292e047a29457ab3bad8e0bbf517348d486e1948cd422d0921a645afe>
  },
  supply: 0n,
  decimals: 6,
  isInitialized: true,
  freezeAuthority: PublicKey [PublicKey(FsWBzdtMASX63bFunnvwoecwTvX1vg31VnNmBCrbKx9b)] {
    _bn: <BN: dcf3a98292e047a29457ab3bad8e0bbf517348d486e1948cd422d0921a645afe>
  },
  tlvData: <Buffer >
}
    ✔ Create Mint By PDA! (471ms)


  3 passing (1s)

✨  Done in 2.61s.

```

两次 anchor test 测试验证了 create-mint-account Solana 程序的功能，运行于本地集群，耗时约 2.6 秒。测试套件包含三个用例：

1) initialize 成功执行，输出交易签名，确认程序初始化；
2) createMint 创建由签名者控制的代币铸造账户，精度为 6，铸造和冻结权限归签名者，账户地址两次不同（因随机密钥对生成）；
3) createMint2 使用 PDA 创建程序控制的铸造账户，精度为 6，权限归 PDA 地址，第二次测试复用同一 PDA 地址。所有测试通过，交易签名和账户信息（如供应量 0、初始化状态 true）显示程序功能正常，无错误。

## 总结

通过本篇实操指南，你已掌握在 Solana 上使用 Anchor 框架创建代币 Mint Account 的核心技能。以下是关键收获：

1. 快速上手：通过 anchor init 和依赖配置，轻松搭建 Solana 开发环境。
2. 智能合约开发：lib.rs 实现 initialize、create_mint（密钥对方式）和 create_mint2（PDA 方式），覆盖代币创建的两种主流方法。
3. 测试与验证：create-mint-account.ts 脚本验证了程序功能，确保 Mint Account 正确创建，精度为 6，权限分配符合预期。
4. PDA 的优势：PDA 方式通过程序控制权限，提升了安全性和可预测性，适合 Web3 应用场景。
5. 测试结果：两次 anchor test 均通过，交易签名和账户信息（如供应量 0、初始化状态 true）确认程序在本地集群的稳定性。

下一步行动建议：

- 深入探索 Anchor 框架的高级功能，如账户验证和代币操作。
- 结合代币发行、转账等功能，开发完整的 Web3 代币经济系统。
- 部署到 Solana Devnet 或 Mainnet，体验真实区块链环境的运行效果。

立即动手实践，结合文末参考链接进一步学习 Solana 和 Web3 开发，开启你的去中心化应用创作之旅！

## 参考

- <https://www.anchor-lang.com/docs/tokens/basics/create-mint>
- <https://github.com/solana-program/token/blob/main/program/src/state.rs#L18-L32>
- <https://github.com/solana-program/token-2022/blob/main/program/src/state.rs#L30-L43>
- <https://explorer.solana.com/address/3emsAVdmGKERbHjmGfQ6oZ1e35dkf5iYcS6U4CPKFVaa>
- <https://github.com/solana-labs/solana-program-library>
- <https://github.com/solana-foundation/solana-web3.js>
- <https://solana-foundation.github.io/solana-web3.js/>
- <https://github.com/anza-xyz/kit>
- <https://solana-kit-docs.vercel.app/docs>
