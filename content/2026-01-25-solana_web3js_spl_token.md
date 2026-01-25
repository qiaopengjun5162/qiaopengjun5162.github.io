+++
title = "Solana 开发实战：使用 @solana/web3.js 与 Bun 铸造首个 SPL 代币"
description = "Solana 开发实战：使用 @solana/web3.js 与 Bun 铸造首个 SPL 代币"
date = 2026-01-25T15:28:55Z
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana", "Bun", "TypeScript", "CLI"]
+++

<!-- more -->

# Solana 开发实战：使用 @solana/web3.js 与 Bun 铸造首个 SPL 代币

在 Solana 的世界里，发行代币（Mint Token）往往是开发者迈向 DeFi 开发的第一步，也是理解链上账户模型的最佳实践。

很多人习惯使用图形化界面发币，但作为开发者，**掌握如何通过代码与脚本来控制这一过程才是核心竞争力。** 如何在代码中创建一个“铸币厂”？什么是 Mint 账户与 ATA 账户的绑定关系？如何确保创建和铸造在同一个交易块中原子化完成？

本文将抛开复杂的理论概念，直接进入**代码实操**。我们将基于本地开发环境，使用 TypeScript 和 `@solana/web3.js`，编写一个自动化的脚本，体验从“一无所有”到“千万资产”到账的完整开发流程。并且使用 Bun 不仅启动速度极快，而且原生支持 TypeScript，省去了复杂的编译配置。

打开你的终端，让我们开始铸造。

本文提供一份 Solana 开发实操指南。我们将使用经典的 `@solana/web3.js` 库结合高性能运行时 Bun，在本地测试网中从零构建代币铸造脚本。文章详细演示了如何通过单笔原子交易完成 Mint 账户创建、权限初始化及代币发行，并使用 CLI 和脚本双重验证资产上链状态，帮助开发者掌握 SPL Token 核心交互逻辑。

## 实操

使用 @solana/web3.js 铸造 SPL Token

### 创建并切换到项目目录

```bash
mcd solana_forge # mkdir solana_forge && cd solana_forge
/Users/qiaopengjun/Code/Solana/solana_forge
```

### 项目初始化

```bash
bun init

✓ Select a project template: Blank

 + .gitignore
 + .cursor/rules/use-bun-instead-of-node-vite-npm-pnpm.mdc
 + index.ts
 + tsconfig.json (for editor autocomplete)
 + README.md

To get started, run:

    bun run index.ts

bun install v1.2.17 (282dda62)

+ typescript@5.9.3
+ @types/bun@1.3.6

5 packages installed [5.64s]

```

### 安装依赖

```bash
bun add @solana/web3.js
bun add @solana/spl-token
```

### 铸造 SPL Token 脚本实现

使用 web3.js 铸造一个 SPL Token

```rust
/** Mint an SPL Token
 *
 *
 * Goal:
 *   Mint an SPL token in a single transaction using Web3.js and the SPL Token library.
 *
 * Objectives:
 *   1. Create an SPL mint account.
 *   2. Initialize the mint with 6 decimals and your public key (feePayer) as the mint and freeze authorities.
 *   3. Create an associated token account for your public key (feePayer) to hold the minted tokens.
 *   4. Mint 21,000,000 tokens to your associated token account.
 *   5. Sign and send the transaction.
 */

import {
    Keypair,
    Connection,
    sendAndConfirmTransaction,
    SystemProgram,
    Transaction,
} from "@solana/web3.js"

import {
    createAssociatedTokenAccountInstruction,
    createInitializeMint2Instruction,
    createMintToCheckedInstruction,
    MINT_SIZE,
    getMinimumBalanceForRentExemptMint,
    TOKEN_PROGRAM_ID,
    getAssociatedTokenAddressSync,
    ASSOCIATED_TOKEN_PROGRAM_ID
} from "@solana/spl-token"


import { readFileSync } from "node:fs"

// 1. 定义路径（可以从环境变量读取，或者直接写死）
const WALLET_PATH = process.env.WALLET_PATH || "/Users/qiaopengjun/.config/solana/id.json"

// 2. 读取并解析 JSON 文件
// Solana 的 id.json 格式是一个包含 64 个数字的数组 [12, 43, ...]
const secretKeyString = readFileSync(WALLET_PATH, "utf-8")
const secretKey = Uint8Array.from(JSON.parse(secretKeyString))

// 3. 生成 Keypair
// Import our keypair from the wallet file
const feePayer = Keypair.fromSecretKey(secretKey)

console.log(`✅ 已从路径加载钱包: ${feePayer.publicKey.toBase58()}`)

const endpoint = process.env.RPC_ENDPOINT || "https://api.devnet.solana.com"

//Create a connection to the RPC endpoint
const connection = new Connection(
    endpoint,
    "confirmed"
)

// Entry point of your TypeScript code (we will call this)
async function main() {
    try {

        // Generate a new keypair for the mint account
        const mint = Keypair.generate()

        const mintRent = await getMinimumBalanceForRentExemptMint(connection)

        // START HERE

        // Create the mint account
        const createAccountIx = SystemProgram.createAccount({
            fromPubkey: feePayer.publicKey,
            newAccountPubkey: mint.publicKey,
            space: MINT_SIZE,
            lamports: mintRent,
            programId: TOKEN_PROGRAM_ID
        })


        // Initialize the mint account
        // Set decimals to 6, and the mint and freeze authorities to the fee payer (you).
        const decimals = 6
        const initializeMintIx = createInitializeMint2Instruction(
            mint.publicKey,
            decimals, // decimals
            feePayer.publicKey, // mint authority
            feePayer.publicKey, // freeze authority
            TOKEN_PROGRAM_ID
        )


        // Create the associated token account
        const associatedTokenAccount = getAssociatedTokenAddressSync(
            mint.publicKey,
            feePayer.publicKey,
            false,
            TOKEN_PROGRAM_ID,
            ASSOCIATED_TOKEN_PROGRAM_ID
        )
        const createAssociatedTokenAccountIx = createAssociatedTokenAccountInstruction(
            feePayer.publicKey, // payer
            associatedTokenAccount, // ATA
            feePayer.publicKey, // owner
            mint.publicKey,
            TOKEN_PROGRAM_ID,
            ASSOCIATED_TOKEN_PROGRAM_ID
        )


        // Mint 21,000,000 tokens to the associated token account
        const mintAmount = BigInt(21_000_000) * BigInt(10 ** decimals)
        const mintToCheckedIx = createMintToCheckedInstruction(
            mint.publicKey,
            associatedTokenAccount,
            feePayer.publicKey, // mint authority
            mintAmount,
            decimals,
            [],
            TOKEN_PROGRAM_ID
        )


        const recentBlockhash = await connection.getLatestBlockhash()

        const transaction = new Transaction({
            feePayer: feePayer.publicKey,
            blockhash: recentBlockhash.blockhash,
            lastValidBlockHeight: recentBlockhash.lastValidBlockHeight
        }).add(
            createAccountIx,
            initializeMintIx,
            createAssociatedTokenAccountIx,
            mintToCheckedIx
        )

        const transactionSignature = await sendAndConfirmTransaction(
            connection,
            transaction,
            [
                feePayer, // 付费 + mint authority
                mint      // 新创建的 mint account
            ]  // This is the list of signers. Who should be signing this transaction?
        )

        console.log("Mint Address:", mint.publicKey.toBase58())
        console.log("Transaction Signature:", transactionSignature)
    } catch (error) {
        console.error(`Oops, something went wrong: ${error}`)
    }
}

await main()
console.log("✨ 脚本执行完毕")

```

这段代码是一个功能完备的**“代币铸造工厂”**，它利用 Solana 的原子性交易特性，将从身份加载到代币分发的全过程浓缩在了一起：脚本首先安全地从本地路径读取 `id.json` 钱包作为付费与管理主体，随后在单一交易包中同步执行了四项核心指令——创建 Mint 账户空间、初始化 6 位精度的代币权限、为你的地址建立专属的“保险箱”（关联代币账户 ATA），并最终向该账户注入 **21,000,000** 枚代币，确保了整个代币体系在链上实现“要么全部成功，要么完全不发生”的一致性部署。

### 运行脚本

```bash
Code/Solana/solana_forge via 🍞 v1.2.17
➜ bun forge:raw
$ bun src/web3js-raw/mint.ts
✅ 已从路径加载钱包: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
Mint Address: 5MWt4GNdrXFtuwxHnr2ffy7PJYSgQr1PpNobgYmszKNS
Transaction Signature: 3tjHqX3B4Dj7qAAJ7DxzdvWetnFVcqaB93c1nfEyvHFXAmSCgJkmAAjJRSmyL6PQQFQkQPLQRgLHg4X68Y7aKZaj
✨ 脚本执行完毕
```

这段运行结果表明你已成功在本地 **Surfpool** 环境下完成了 SPL Token 的全流程铸造：脚本通过 Bun 运行时高效加载了本地文件系统中的密钥对（地址以 `6MZDRo` 开头），并在本地验证节点上发起了一笔原子化交易（签名以 `3tjHqX` 开头），该交易一口气完成了创建代币 Mint 账户（地址为 `5MWt4GN...`）、初始化参数、创建关联代币账户（ATA）以及向该账户注资 2100 万枚代币的所有底层指令。

------

![image-20260124235452288](/images/image-20260124235452288.png)

#### 💡 深度解析（基于你的 Surfpool 截图）

- **本地确认**：交易签名 `3tjHqX...` 与你 TUI 界面底部的 `Processed tx` 完全一致，说明交易已在你本地区块链的 Slot 中永久上链。
- **零成本测试**：由于是在本地环境，这次铸造没有消耗任何真实的 SOL，且响应速度（微秒级）远快于公网 Devnet。
- **状态已更新**：你的钱包 `6MZDRo...` 现在在本地账本中不仅拥有 1000 SOL 的“燃料”，还额外拥有了这 2100 万枚新铸造的代币。

## 查看余额

### 命令行方式查看余额

```bash
Code/Solana/solana_forge via 🍞 v1.2.17
➜ spl-token balance 5MWt4GNdrXFtuwxHnr2ffy7PJYSgQr1PpNobgYmszKNS

21000000
```

这一运行结果通过 Solana 官方命令行工具（SPL-Token CLI）证实了脚本执行非常精准：它直接从本地账本中读取并确认了代币地址为 `5MWt4GN...` 的资产状态，显示你的钱包当前确实持有 **21,000,000** 枚完整代币，这说明从底层的账户创建、精度（Decimals）设置到最后的铸造指令已全部在本地 Surfpool 节点上校验通过并生效。

### 脚本方式查看余额

#### 编写查看余额脚本

`src/utils/check-balance.ts` 文件

```ts
import { Connection, PublicKey } from "@solana/web3.js"
import { getAssociatedTokenAddressSync, getAccount } from "@solana/spl-token"

async function check() {
    // const connection = new Connection("https://api.devnet.solana.com", "confirmed")
    const connection = new Connection("http://127.0.0.1:8899", "confirmed")
    const mint = new PublicKey("5MWt4GNdrXFtuwxHnr2ffy7PJYSgQr1PpNobgYmszKNS")
    const owner = new PublicKey("6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd")

    // 计算你的关联代币账户地址
    const ata = getAssociatedTokenAddressSync(mint, owner)

    try {
        const tokenAccount = await getAccount(connection, ata)
        console.log(`代币账户地址: ${ata.toBase58()}`)
        console.log(`你的余额: ${Number(tokenAccount.amount) / (10 ** 6)}`)
    } catch (e) {
        console.error("未找到账户，可能铸造失败了。")
    }
}

check()

```

这段代码是一个基于 **Solana Web3.js** 的查询脚本，其核心逻辑是通过连接本地开发节点（`http://127.0.0.1:8899`），利用代币地址（Mint）和钱包地址（Owner）在本地离线计算出对应的**关联代币账户（ATA）**地址，随后尝试从链上抓取该账户的实时数据，并根据代币设定的 6 位精度（$10^6$）对原始大整数余额进行换算，从而直观地验证资产是否已成功铸造到你的本地钱包中。

#### 调用脚本查看余额

```bash
Code/Solana/solana_forge via 🍞 v1.2.17
➜ bun run src/utils/check-balance.ts
代币账户地址: 5fhHBQZuHbK27yf8dh2wmU1gxUEcwDeVSVqFCXsG3sSm
你的余额: 21000000
```

这段运行结果标志着你的查询脚本已成功与本地 **Surfpool** 节点建立通信，并通过逻辑运算与链上数据抓取双重验证了资产状态：脚本首先根据你的钱包地址和代币 Mint 地址，在本地准确计算出了对应的关联代币账户（ATA）地址 `5fhHBQ...`，随后实时调取了本地账本数据，证实该账户内确实存储着经过 6 位精度换算后、足额且真实的 **21,000,000** 枚代币余额。

### 查看账户详情

```bash
➜ spl-token account-info 5MWt4GNdrXFtuwxHnr2ffy7PJYSgQr1PpNobgYmszKNS

SPL Token Account
  Address: 5fhHBQZuHbK27yf8dh2wmU1gxUEcwDeVSVqFCXsG3sSm
  Program: TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA
  Balance: 21000000
  Decimals: 6
  Mint: 5MWt4GNdrXFtuwxHnr2ffy7PJYSgQr1PpNobgYmszKNS
  Owner: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
  State: Initialized
  Delegation: (not set)
  Close authority: (not set)
```

这段运行结果通过 Solana 官方命令行工具深度展示了你所铸造代币的底层账本状态：它证实了地址为 `5fhHBQ...` 的**关联代币账户（ATA）**已完全初始化（Initialized），该账户归属于你的钱包（Owner），不仅持有准确的 **21,000,000** 枚代币，还清晰地映射到了你创建的代币母体（Mint）及 6 位精度设置，且没有任何第三方委派（Delegation）或关闭权限设置，是一个状态极其干净、标准的 Solana 资产账户。

#### 关键数据深度解读

- **Address vs Mint**：`5fhHBQ...` 是存放代币的“保险箱”（账户），而 `5MWt4G...` 是代币的“模具”（Mint），两者是一对一绑定的关系。
- **Program**：显示由官方的 `Tokenkeg...`（即 SPL Token Program）托管，确保了资产的安全性和标准兼容性。
- **State: Initialized**：表示该账户在区块链上已激活，可以随时进行转账、收款或销毁操作。

## 总结

通过这段紧凑的实操代码，我们不仅成功发行了 2100 万枚自定义代币，更重要的是，我们通过代码深入理解了 Solana 代币模型的核心机制：

1. **原子性交易（Atomic Transaction）**：我们没有分步操作，而是将创建 Mint、初始化、创建 ATA 和铸币（MintTo）打包在**同一个 Transaction** 中。这意味着这四个步骤要么全部成功，要么全部失败，完美避免了中间状态的错误。
2. **账户模型关联**：通过脚本和 CLI 的验证，我们直观看到了 **Mint Account**（代币定义）与 **Associated Token Account**（代币持有容器）之间的一一对应关系。
3. **本地开发闭环**：利用 Bun 和本地验证节点（Surfpool），我们实现了零成本、毫秒级反馈的极速开发体验。

掌握了脚本铸币，你就拥有了构建水龙头（Faucet）、空投工具（Airdrop）甚至更复杂的 DeFi 协议的基础。接下来，你可以尝试将脚本中的 Mint Authority 权限移除，通过代码实现代币的“永不增发”。

## 参考

- <https://github.com/Solana-ZH/Solana-bootcamp-2026-s1>
- <https://github.com/anza-xyz/pinocchio>
- <https://solana.com/docs/clients/official/javascript>
- <https://github.com/solana-foundation/solana-web3.js>
- <https://www.npmjs.com/package/@solana/web3.js>
- <https://solana-foundation.github.io/solana-web3.js/>
- <https://solana.com/docs/rpc>
