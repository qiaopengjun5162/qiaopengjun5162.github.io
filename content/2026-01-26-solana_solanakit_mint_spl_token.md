+++
title = "Solana 开发实战：使用 @solana/kit (v2) 发行 SPL 代币全流程"
description = "Solana 开发实战：使用 @solana/kit (v2) 发行 SPL 代币全流程"
date = 2026-01-25T16:15:05Z
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# Solana 开发实战：使用 @solana/kit (v2) 发行 SPL 代币全流程

**Solana 的开发工具正在经历一次重要的进化。**

随着 `@solana/web3.js` 2.x 版本正式更名为 `@solana/kit`，官方 SDK 迎来了更轻量、更模块化、且全面拥抱函数式编程的新时代。对于开发者而言，这意味着代码将变得更具可组合性，同时能更好地利用 Tree-shaking 优化包体积。

但新技术总需要一段适应期。**新版的 `Rpc` 怎么建？交易流水线 `pipe` 怎么写？如何像以前一样轻松地发币？**

本文将抛开繁杂的理论，直接进入**代码实操模式**。我们将基于本地测试网络（Surfnet），手把手带你跑通从环境初始化、加载签名者、到完成一笔“原子化铸币”交易的全过程，最后教你如何读取并验证链上数据。

准备好了吗？让我们开始构建。

本文是 Solana Kit (@solana/kit) 的实操指南。作为 Web3.js v2 的新面貌，Kit 带来了函数式编程的全新体验。文章通过详细的代码示例，演示了如何构建单例客户端、加载本地钱包、利用流水线模式原子化铸造 2100 万枚 SPL 代币，并最终验证链上数据。适合开发者快速上手新版 SDK，掌握核心交互逻辑。

## 实操

使用 @solana/kit 铸造一个 SPL Token

Solana Kit 这是用于构建适用于 Node、Web 和 React Native 的 Solana 应用程序的 JavaScript SDK。@solana/web3.js 的 2.x 版本重命名为 @solana/kit。

### 安装依赖

```bash
pnpm install --save @solana/kit

bun add @solana-program/system \
  @solana-program/memo \
  @solana-program/token \
  @solana-program/compute-budget
```

### 初始化 Solana 交互客户端 (Context)

#### `connect.ts` 文件

```ts
import {
    createSolanaRpc,
    createSolanaRpcSubscriptions,
    sendAndConfirmTransactionFactory,
} from '@solana/kit'

// 1. 设置 RPC 连接（指向你的本地 Surfpool）
const rpc = createSolanaRpc('http://127.0.0.1:8899') //

// 2. 设置订阅服务（用于实时确认交易）
const rpcSubscriptions = createSolanaRpcSubscriptions('ws://127.0.0.1:8900') //

// 3. 创建发送并确认交易的工具函数
const sendAndConfirmTransaction = sendAndConfirmTransactionFactory({ rpc, rpcSubscriptions }) //

console.log("🚀 Solana Kit 已就绪，连接至本地 Surfnet！")

// 快速测试：获取当前 Slot
const slot = await rpc.getSlot().send()
console.log(`当前本地 Slot: ${slot}`)

/**
 * Code/Solana/solana_forge via 🍞 v1.2.17
➜ bun run src/solanakit/connect.ts
🚀 Solana Kit 已就绪，连接至本地 Surfnet！
当前本地 Slot: 395783430
 */
```

这段代码使用 **Solana Kit** 初始化了与本地开发环境（如 Surfpool 或本地验证器）的通信链路：首先通过 `createSolanaRpc` 建立 HTTP 连接以执行基础查询，接着利用 `createSolanaRpcSubscriptions` 开启 WebSocket 监听以实时获取交易状态，最后通过 `sendAndConfirmTransactionFactory` 将两者整合为一个能够自动发送并等待网络确认的工具函数，从而实现对链上数据（如 Slot 高度）的异步交互。

### 执行客户端连接脚本

```bash
Code/Solana/solana_forge via 🍞 v1.2.17
➜ bun run src/solanakit/connect.ts
🚀 Solana Kit 已就绪，连接至本地 Surfnet！
当前本地 Slot: 395783430
```

这段运行结果展示了通过 Bun 运行时成功执行了连接脚本，证实了 **Solana Kit 客户端** 已与本地 Surfnet 节点建立双向通信：它不仅完成了 RPC 实例的初始化，还通过成功获取并打印当前的 **Slot（插槽高度）**，验证了程序具备从链上读取实时数据以及发送指令的能力。

### **加载本地文件系统签名者 (Signer)**

#### `signer.ts` 文件

```ts
import {
    createKeyPairFromBytes,
    createSignerFromKeyPair,
    address
} from '@solana/kit'
import { readFileSync } from 'node:fs'

export async function getLocalSigner() {
    // 1. 读取 64 字节的 id.json
    const WALLET_PATH = "/Users/qiaopengjun/.config/solana/id.json"
    const secretKeyArray = JSON.parse(readFileSync(WALLET_PATH, 'utf-8'))
    const secretKeyBytes = new Uint8Array(secretKeyArray)

    // 2. 将字节转为 CryptoKeyPair
    const keyPair = await createKeyPairFromBytes(secretKeyBytes)

    // 3. 关键一步：将 KeyPair 包装成 Signer
    const signer = createSignerFromKeyPair(keyPair)

    // 现在 signer.address 就有值了！
    return signer
}

// 执行并打印
const signer = await getLocalSigner()
console.log(`✅ Kit 签名者已就绪: ${signer.address}`)

```

这段代码通过 `node:fs` 读取本地 Solana CLI 默认生成的 `id.json` 私钥文件，并利用 **Solana Kit** 的 `createKeyPairFromBytes` 将原始字节数组转换为非对称加密密钥对，最后通过 `createSignerFromKeyPair` 将其封装为具备自动签名能力的 **Signer 对象**，从而实现将本地开发钱包安全地导入到 Web3 应用中以进行交易授权。

### **加载本地钱包身份验证**

```bash
Code/Solana/solana_forge via 🍞 v1.2.17
➜ bun run src/solanakit/signer.ts
✅ Kit 签名者已就绪: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd

```

该运行结果表明脚本已成功通过 Bun 运行时解析并加载了本地文件系统中的私钥，利用 **Solana Kit** 将其转换为合法的加密签名者对象，并正确派生出了对应的公共地址（`6MZD...`），这意味着该身份已准备就绪，可以代表该钱包在后续的流水线中对任何链上交易进行授权签名。

### **构建单例模式的 Solana 交互客户端 (Client Singleton)**

#### `client.ts` 文件

```ts
import {
    createSolanaRpc,
    createSolanaRpcSubscriptions,
} from '@solana/kit'
import type {
    Rpc,
    RpcSubscriptions,
    SolanaRpcApi,
    SolanaRpcSubscriptionsApi,
    TransactionSigner,
    MessageSigner
} from '@solana/kit'
import { getLocalSigner } from './signer'

// 定义 Client 类型
export type Client = {
    rpc: Rpc<SolanaRpcApi>
    rpcSubscriptions: RpcSubscriptions<SolanaRpcSubscriptionsApi>
    wallet: TransactionSigner & MessageSigner
}

let client: Client | undefined


export async function getClient(): Promise<Client> {
    if (!client) {
        const rpc = createSolanaRpc('http://127.0.0.1:8899')
        const rpcSubscriptions = createSolanaRpcSubscriptions('ws://127.0.0.1:8900')

        const wallet = await getLocalSigner()

        client = { rpc, rpcSubscriptions, wallet }
    }
    return client
}
```

这段代码采用 **单例模式** 封装了 Solana 客户端的初始化逻辑，通过定义 `Client` 类型将远程过程调用（RPC）、WebSocket 订阅服务以及本地签名钱包（Wallet）整合在一起，并利用 `getClient` 异步函数确保在整个应用程序生命周期内只创建一次连接实例，从而为其他模块提供了一个高效、统一且类型安全的链上交互入口。

### **使用 Solana Kit 实现原子化铸造代币 (Atomic SPL Token Minting)**

```ts
/** Mint an SPL Token
 *
 *
 * Goal:
 *   Mint an SPL token in a single transaction using @solana/kit library.
 *
 * Objectives:
 *   1. Create an SPL mint account.
 *   2. Initialize the mint with 6 decimals and your public key (feePayer) as the mint and freeze authorities.
 *   3. Create an associated token account for your public key (feePayer) to hold the minted tokens.
 *   4. Mint 21,000,000 tokens to your associated token account.
 *   5. Sign and send the transaction.
 */
import {
    appendTransactionMessageInstructions,
    assertIsSendableTransaction,
    assertIsTransactionWithBlockhashLifetime,
    createTransactionMessage,
    generateKeyPairSigner,
    getSignatureFromTransaction,
    pipe,
    sendAndConfirmTransactionFactory,
    setTransactionMessageFeePayerSigner,
    setTransactionMessageLifetimeUsingBlockhash,
    signTransactionMessageWithSigners
} from '@solana/kit'
import {
    findAssociatedTokenPda,
    getCreateAssociatedTokenInstruction,
    getCreateAssociatedTokenInstructionAsync,
    getInitializeMintInstruction,
    getMintSize,
    getMintToInstruction,
    TOKEN_PROGRAM_ADDRESS
} from '@solana-program/token'
import { getCreateAccountInstruction } from '@solana-program/system'
import { getClient } from "./client"

async function main() {
    try {
        const { rpc, rpcSubscriptions, wallet } = await getClient()
        const sendAndConfirm = sendAndConfirmTransactionFactory({ rpc, rpcSubscriptions })

        // --- 准备阶段 ---
        const decimals = 6
        const mintAmount = 21_000_000n * (10n ** BigInt(decimals))
        const mintSize = getMintSize()

        const [mintSigner, { value: latestBlockhash }, mintRent] = await Promise.all([
            generateKeyPairSigner(),
            rpc.getLatestBlockhash().send(),
            rpc.getMinimumBalanceForRentExemption(BigInt(mintSize)).send(),
        ])

        // 计算 ATA 地址 (PDA)
        const [ataAddress] = await findAssociatedTokenPda({
            mint: mintSigner.address,
            owner: wallet.address,
            tokenProgram: TOKEN_PROGRAM_ADDRESS,
        })

        console.log(`✅ 加载钱包: ${wallet.address}`)
        console.log(`🛠️ 创建 Mint: ${mintSigner.address}`)
        console.log(`📦 ATA 地址: ${ataAddress}`)

        const createAtaIx = await getCreateAssociatedTokenInstructionAsync({
            payer: wallet,
            mint: mintSigner.address,
            owner: wallet.address,
            tokenProgram: TOKEN_PROGRAM_ADDRESS,
        })

        // --- 构建流水线交易 (Objective 1-5) ---
        const transactionMessage = pipe(
            createTransactionMessage({ version: 'legacy' }),
            (tx) => setTransactionMessageFeePayerSigner(wallet, tx),
            (tx) => setTransactionMessageLifetimeUsingBlockhash(latestBlockhash, tx),
            (tx) =>
                appendTransactionMessageInstructions(

                    [
                        // 1. 创建账户 (System Program)
                        getCreateAccountInstruction({
                            payer: wallet,
                            newAccount: mintSigner,
                            space: mintSize,
                            lamports: mintRent,
                            programAddress: TOKEN_PROGRAM_ADDRESS,
                        }),


                        // 2. 初始化 Mint (Token Program)
                        getInitializeMintInstruction({
                            mint: mintSigner.address,
                            decimals,
                            mintAuthority: wallet.address,
                            freezeAuthority: wallet.address,
                        }),


                        // 3. 创建 ATA
                        createAtaIx,

                        // 4. Mint 21,000,000 代币
                        getMintToInstruction({
                            mint: mintSigner.address,
                            token: ataAddress,
                            mintAuthority: wallet, // 传入 Signer 自动签名
                            amount: mintAmount,
                        }),
                    ],
                    tx
                )
        )


        // --- 签名并发送 ---
        const signedTx = await signTransactionMessageWithSigners(transactionMessage)
        assertIsSendableTransaction(signedTx) // 确保大小合规且已完全签名
        assertIsTransactionWithBlockhashLifetime(signedTx) // 确保它是 Blockhash 模式，解决你的报错
        const signature = getSignatureFromTransaction(signedTx)

        console.log("🚀 正在发送交易...")
        await sendAndConfirm(signedTx, { commitment: "confirmed" })

        console.log("✨ 脚本执行完毕!")
        console.log("Mint Address:", mintSigner.address)
        console.log("Transaction Signature:", signature)
    } catch (error) {
        console.error(`Oops, something went wrong: ${error}`)
    }
}

await main()
console.log("✨ 脚本执行完毕")

```

这段代码利用 **Solana Kit (v2)** 的函数式流水线（`pipe`）模式，在单笔交易中实现了从零到一的代币发行全过程：它首先异步准备好 Mint 账户签名者、租金与 Blockhash 等基础数据，随后在一个原子交易中按序打包了**创建账户**、**初始化代币精度与权限**、**派生并创建关联代币账户 (ATA)** 以及**注资铸币**这四个核心指令，并通过严格的类型断言确保交易符合发送标准，最终实现了 21,000,000 枚自定义代币的快速发行与到账。

### **执行代币铸造脚本 (Token Minting Execution)**

```bash
Code/Solana/solana_forge via 🍞 v1.2.17
➜ bun forge:kit
$ bun src/solanakit/mint.ts
✅ Kit 签名者已就绪: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
✅ 加载钱包: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
🛠️ 创建 Mint: D7euWubJ72TqwATMkuaaQHAuWCRiFdNVQf6zeEH7FhPS
📦 ATA 地址: 65PEmoisnPgzgwkYyQdRs4do5TbQxLmi7ew6Jb2D1g9M
🚀 正在发送交易...
✨ 脚本执行完毕!
Mint Address: D7euWubJ72TqwATMkuaaQHAuWCRiFdNVQf6zeEH7FhPS
Transaction Signature: 5ZTx3zZ7yFA33mBtc9fJdhPVRChKTE5zBVSrw6dJRw8wAj4AA4LuijDEF4vnb52sy8i7h49qj4BeUYVNG7RDQxgY
✨ 脚本执行完毕

```

这段运行结果展示了通过 Bun 顺利执行了 **Solana Kit** 铸币脚本的完整生命周期：脚本首先成功加载了本地签名者并实时派生出唯一的 **Mint 地址**与**关联代币账户 (ATA)**，随后将所有构建指令打包发送至网络，最终在链上成功确认并输出了代表资产创建成功的**交易签名 (Transaction Signature)**，标志着 21,000,000 枚自定义代币已正式发行并注入到指定的链上仓库中。

![image-20260125170011561](/images/image-20260125170011561.png)

### **验证代币余额账目 (Token Balance Verification)**

```bash
Code/Solana/solana_forge via 🍞 v1.2.17
➜ spl-token balance D7euWubJ72TqwATMkuaaQHAuWCRiFdNVQf6zeEH7FhPS --url http://127.0.0.1:8899
21000000
```

这段运行结果通过 Solana 官方命令行工具 `spl-token` 成功查询并证实了代币铸造任务的最终状态：输出结果 `21000000` 表明系统已正确处理了精度换算逻辑，确认在本地网络中，指定的 Mint 账户已按照指令成功发行并持有了 2100 万枚代币，这标志着从代码逻辑到链上账本数据的最终一致性校验已顺利通过。

### **查询并解码代币元数据 (Fetching & Decoding Mint Metadata)**

#### `fetch-mint.ts` 文件

```ts
import { address } from '@solana/kit'
import { fetchMint } from '@solana-program/token' // 专门用于解码 Mint 账户的工具
import { getClient } from './client'

async function checkMintStatus(mintAddressString: string) {
    const { rpc } = await getClient()

    // 1. 将字符串转为 Address 类型
    const mintAddress = address(mintAddressString)

    console.log(`🔍 正在查询代币信息: ${mintAddress}...`)

    try {
        // 2. 使用 fetchMint 一步到位：获取数据并自动解码
        // 它会根据 Token Program 的布局解析二进制数据
        const mintAccount = await fetchMint(rpc, mintAddress)

        // 3. 打印解码后的结构化数据
        console.log("✅ 代币信息获取成功:")
        console.log(`   - 精度 (Decimals): ${mintAccount.data.decimals}`)
        console.log(`   - 总供应量 (Supply): ${mintAccount.data.supply.toString()}`)
        const mintAuth = mintAccount.data.mintAuthority.__option === 'Some'
            ? mintAccount.data.mintAuthority.value
            : 'None'

        const freezeAuth = mintAccount.data.freezeAuthority.__option === 'Some'
            ? mintAccount.data.freezeAuthority.value
            : 'None'

        console.log(`   - 铸币权限 (Mint Authority): ${mintAuth}`)
        console.log(`   - 冻结权限 (Freeze Authority): ${freezeAuth}`)

    } catch (error) {
        console.error("❌ 查询失败，请检查地址是否正确或是否在正确的网络上:", error)
    }
}

// 传入你刚才生成的地址
const MY_MINT = "D7euWubJ72TqwATMkuaaQHAuWCRiFdNVQf6zeEH7FhPS"
checkMintStatus(MY_MINT)
```

这段代码展示了如何利用 **Solana Kit** 中的 `fetchMint` 高级辅助函数来检索代币的核心定义信息：它首先将字符串格式的 Mint 地址转换为类型安全的 `Address` 对象，随后通过 RPC 自动抓取链上二进制数据并根据 SPL Token 标准协议进行**结构化解码**，从而以可读的方式提取出代币精度、总供应量以及铸币与冻结权限的持有情况，实现了从原始链上存储到业务逻辑层数据的无缝转换。

### **执行代币状态查询脚本 (Fetching Mint Account Data)**

```bash
Code/Solana/solana_forge via 🍞 v1.2.17
➜ bun run src/solanakit/fetch-mint.ts
✅ Kit 签名者已就绪: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
🔍 正在查询代币信息: D7euWubJ72TqwATMkuaaQHAuWCRiFdNVQf6zeEH7FhPS...
✅ 代币信息获取成功:
   - 精度 (Decimals): 6
   - 总供应量 (Supply): 21000000000000
   - 铸币权限 (Mint Authority): 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
   - 冻结权限 (Freeze Authority): 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd

```

该运行结果记录了通过 Bun 成功执行链上数据检索的过程，证实了脚本已准确从 Solana 网络抓取并解码了指定 Mint 账户的二进制数据：输出清晰地还原了代币的**精度（6）\**与包含零位在内的\**原始总供应量（21,000,000,000,000）**，并确认了当前钱包地址对该代币拥有最高管理权限（铸币与冻结权），完整验证了此前铸造逻辑在链上生效的详细状态。

### **查询关联代币账户详情 (Token Account Inspection)**

```bash
Code/Solana/solana_forge via 🍞 v1.2.17
➜ spl-token account-info D7euWubJ72TqwATMkuaaQHAuWCRiFdNVQf6zeEH7FhPS

SPL Token Account
  Address: 65PEmoisnPgzgwkYyQdRs4do5TbQxLmi7ew6Jb2D1g9M
  Program: TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA
  Balance: 21000000
  Decimals: 6
  Mint: D7euWubJ72TqwATMkuaaQHAuWCRiFdNVQf6zeEH7FhPS
  Owner: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
  State: Initialized
  Delegation: (not set)
  Close authority: (not set)
```

这段运行结果通过命令行工具展示了特定代币账户（ATA）的完整链上快照：它详细列出了该账户的唯一地址（`65PE...`）、所属的代币程序（Token Program）以及所持有的**实际余额（2100万）**，并清晰地展示了该账户与“代币工厂”（Mint: `D7eu...`）及其合法所有者（Owner: `6MZD...`）之间的绑定关系，证明了该账户已初始化完毕并处于可正常交易的活跃状态。

### **查询代币账户余额与持仓详情 (Fetching Token Account Balance)**

#### `fetch-balance.ts` 文件

```ts
import { address } from '@solana/kit'
import { fetchToken } from '@solana-program/token'
import { getClient } from './client'

async function checkTokenBalance(ataAddressString: string) {
    const { rpc } = await getClient()
    const ataAddress = address(ataAddressString)

    console.log(`🔍 正在查询账户余额: ${ataAddress}...`)

    try {
        // 使用 fetchToken 查询具体的代币持有账户
        const tokenAccount = await fetchToken(rpc, ataAddress)

        // 获取原始余额 (BigInt)
        const amount = tokenAccount.data.amount

        // 假设你知道精度是 6（或者先 fetchMint 动态获取）
        const decimals = 6
        const uiAmount = Number(amount) / Math.pow(10, decimals)

        console.log("✅ 账户信息获取成功:")
        console.log(`   - 原始余额 (Raw): ${amount.toString()}`)
        console.log(`   - 实际余额 (UI): ${uiAmount}`)
        console.log(`   - 所有人 (Owner): ${tokenAccount.data.owner}`)
        console.log(`   - 状态 (State): ${tokenAccount.data.state}`) // 1 通常代表 Initialized

    } catch (error) {
        console.error("❌ 查询失败:", error)
    }
}

// 传入你刚才 spl-token account-info 里的 Address
const MY_ATA = "65PEmoisnPgzgwkYyQdRs4do5TbQxLmi7ew6Jb2D1g9M"
checkTokenBalance(MY_ATA)
```

这段代码利用 **Solana Kit** 的 `fetchToken` 工具函数精准定位并读取特定的关联代币账户（ATA）数据：它通过 RPC 获取链上原始的 `BigInt` 余额，并结合预设的精度参数（Decimals）将其换算为用户友好的实际显示金额，同时解码出账户的**所有者（Owner）**身份及**初始化状态（State）**，实现了对单个持仓账户从二进制存储到结构化业务信息的完整提取。

### **执行代币余额查询脚本 (Token Balance Retrieval Execution)**

```bash
Code/Solana/solana_forge via 🍞 v1.2.17
➜ bun run src/solanakit/fetch-balance.ts
✅ Kit 签名者已就绪: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
🔍 正在查询账户余额: 65PEmoisnPgzgwkYyQdRs4do5TbQxLmi7ew6Jb2D1g9M...
✅ 账户信息获取成功:
   - 原始余额 (Raw): 21000000000000
   - 实际余额 (UI): 21000000
   - 所有人 (Owner): 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
   - 状态 (State): 1
```

该运行结果记录了通过 Bun 成功调用链上账户查询逻辑的过程，证实了脚本已准确抓取并解析了指定 ATA 账户的实时状态：它清晰展示了链上存储的**原始大整数（Raw Amount）\**与经精度换算后的\**实际流通余额（21,000,000）**，并确认了该账户的归属权及其处于已初始化的正常状态，完整验证了从底层数据读取到业务层面换算的逻辑准确性。

## 总结

通过本次实操，我们完整体验了 **Solana Kit** 的开发闭环：

1. **连接构建**：利用单例模式（Singleton）构建了集 RPC 查询与 WebSocket 订阅于一体的交互上下文。
2. **身份管理**：成功从本地文件系统加载私钥并转换为符合新标准的 Signer 对象。
3. **原子化交互**：这是 v2 最大的亮点——我们利用 `pipe` 流水线和 `sendAndConfirmTransactionFactory`，在一个原子交易中一气呵成地完成了“创建账户 + 初始化 Mint + 创建 ATA + 铸币”四个步骤。
4. **数据验证**：通过 `fetchMint` 和 `fetchToken` 等工具函数，精准地解析了链上的二进制数据，验证了资产的成功上链。

Solana Kit 的设计虽然在初期上手时需要适应其函数式的思维，但它带来的类型安全（Type Safety）和代码复用性是旧版无法比拟的。希望这篇实战能成为你探索 Solana 新版生态的起点。

## 参考

- <https://www.solanakit.com/>
- <https://github.com/anza-xyz/kit>
- <https://solana.com/docs/rpc/http>
- <https://github.com/solana-foundation/solana-web3.js>
