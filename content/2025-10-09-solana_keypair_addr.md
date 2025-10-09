+++
title = "Solana 密钥实战：一文搞懂私钥、公钥、PDA 的底层关系与 CLI 操作"
description = "Solana 密钥实战：一文搞懂私钥、公钥、PDA 的底层关系与 CLI 操作"
date = 2025-10-09T15:35:06Z
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# **Solana 密钥实战：一文搞懂私钥、公钥、PDA 的底层关系与 CLI 操作**

你好，Solana 开发者！

在 Solana 上构建应用，一切都始于对 **密钥（Keypair）** 和 **账户（Account）** 的深刻理解。你的钱包地址是如何生成的？为什么只用 **32 字节的私钥** 就能控制整个账户？以及，智能合约中至关重要的 **程序派生地址（PDA）** 又是如何计算出来的？

本文将带你跳过理论，直接进入 **代码实战**。我们将用 Node.js 脚本和官方 CLI 命令，一步步解构密钥对的底层字节结构，验证私钥的绝对控制权，并完成从 **测试代币领取** 到 **PDA 计算** 的全流程。掌握这些基础，你才能在 Solana 的世界里安全、高效地构建去中心化应用。

本文通过 **Node.js/Bun 脚本**和 **Solana CLI** 实战操作，深度解析 Solana 密钥和账户的底层逻辑。我们验证了 **32 字节私钥** 即可派生出唯一的公钥地址，并演示了如何使用 `@solana/kit` 进行密钥对操作。同时，文章涵盖了测试代币领取、账户余额查询，以及 Solana 独有的 **程序派生地址（PDA）** 计算，是开发者快速掌握 Solana 基础架构的实用指南。

## 实操

### `privateToPK.ts` 文件

如何利用 **`@solana/kit`** 工具库在 Solana 链上进行**密钥对（KeyPair）的创建、派生（Derivation）和地址提取**。

**从一个包含私钥和公钥字节的 `Uint8Array` 中，分离出私钥，并验证其能正确派生出原始地址。**

```ts
import { createKeyPairFromBytes, createKeyPairFromPrivateKeyBytes, createKeyPairSignerFromPrivateKeyBytes, getAddressFromPublicKey } from '@solana/kit'

const main = async () => {
    const addressBytes = new Uint8Array([152, 88, 131, 150, 62, 99, 225, 136, 141, 126, 164, 180, 43, 60, 5, 14, 144, 247, 23, 221, 72, 57, 58, 75, 109, 8, 72, 4, 223, 8, 52, 120, 190, 56, 185, 178, 154, 228, 229, 173, 160, 242, 121, 140, 151, 194, 144, 241, 88, 64, 232, 144, 205, 148, 236, 85, 236, 3, 15, 168, 141, 164, 233, 16])

    const privateKeyBytes = addressBytes.slice(0, 32)

    const derivedSigner = await createKeyPairSignerFromPrivateKeyBytes(privateKeyBytes)
    const publicKey = derivedSigner.address
    console.log(`派生地址: ${publicKey}`)

    const keyPair = await createKeyPairFromBytes(
        addressBytes
    )

    const originalAddress = await getAddressFromPublicKey(keyPair.publicKey)
    console.log(`原始地址: ${originalAddress}`)
}

main()

```

## 💻 代码详细解释与功能解析

### 1. 密钥字节定义

代码首先定义了一个包含 **64 个字节** 的 `addressBytes` 数组：

```ts
const addressBytes = new Uint8Array([152, 88, 131, ..., 164, 233, 16])
```

在 Solana 的标准密钥对结构中：

- **前 32 个字节** 是 **私钥（Private Key）**。
- **后 32 个字节** 是 **公钥（Public Key）**。

### 2. 派生签名者（Signer Derivation）

```ts
const privateKeyBytes = addressBytes.slice(0, 32)
const derivedSigner = await createKeyPairSignerFromPrivateKeyBytes(privateKeyBytes)
const publicKey = derivedSigner.address
console.log(`派生地址: ${publicKey}`)
```

- **提取私钥：** `addressBytes.slice(0, 32)` 截取了前 32 个字节，明确地将其作为 **私钥**。
- **创建签名者：** 调用 `createKeyPairSignerFromPrivateKeyBytes`，基于这 32 字节私钥创建了一个 **`Signer`（签名者）** 对象。在 Solana/Web3 语境中，签名者是能够签署交易的实体。
- **派生地址：** `derivedSigner.address` 提取了由该私钥派生出的 **公钥地址**。由于公钥是由私钥通过密码学算法唯一确定的，这里验证了私钥的有效性并输出了对应的地址。

### 3. 创建密钥对与原始地址验证

```ts
const keyPair = await createKeyPairFromBytes(addressBytes)
const originalAddress = await getAddressFromPublicKey(keyPair.publicKey)
console.log(`原始地址: ${originalAddress}`)
```

- **创建密钥对：** 调用 `createKeyPairFromBytes(addressBytes)`。该函数假设输入的 64 字节数组**完整包含了** 私钥和公钥，并将其封装成一个完整的 **`KeyPair`** 对象。
- **提取原始地址：** 调用 `getAddressFromPublicKey(keyPair.publicKey)`，从完整的 `KeyPair` 对象中提取并输出了**公钥地址**。

### 总结

这段代码通过对比 **“从私钥派生出的地址”** (`derivedSigner.address`) 和 **“从 64 字节密钥对中提取的公钥地址”** (`originalAddress`)，展示了 **Solana 密钥对是如何构建和验证的**。

**关键结论是：** 只要私钥（前 32 字节）是正确的，无论通过何种方式加载，它都能派生出唯一的公钥和地址。对于开发者来说，这证实了：**一个完整的密钥对本质上只需要存储私钥，公钥可以随时计算得出。** 这也是钱包私钥备份通常只包含私钥的原因。

### 运行脚本

```bash
➜ bun privateToPK.ts
派生地址: DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
原始地址: DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy

➜ solana address -k keys/id.json
DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
```

这段脚本运行结果有力地证明了 **Solana 密钥的底层密码学一致性**。它显示了三种不同的方法，都指向了同一个唯一的钱包地址：**`DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy`**。

## 结论：Solana 密钥的统一性验证

这段输出结果是上面代码的成功验证：

1. **派生地址：** **`DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy`**
   - 这是通过程序（`privateToPK.ts`）**仅使用 32 字节的私钥**，计算（派生）得出的公钥地址。
2. **原始地址：** **`DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy`**
   - 这是通过程序**使用完整的 64 字节密钥对**（包含私钥和公钥）直接提取的公钥地址。
3. **CLI 验证：** **`DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy`**
   - 这是通过 Solana 命令行工具（CLI）直接从存储在本地文件 **`keys/id.json`** 中的密钥对文件读取并显示的地址。

**核心结论是：** 这段结果证实了 Solana 钱包地址的**唯一性**和 **私钥的绝对决定权**。无论是您从密钥对文件中提取私钥后重新计算，还是直接使用完整的密钥对文件，或是通过 Solana 官方 CLI 工具读取，最终输出的地址都是一致的。这在密码学上意味着 **您的私钥是有效的，并且是该钱包账户的唯一控制权证明**。

### 领水

```bash
➜ solana airdrop 1 DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
Requesting airdrop of 1 SOL

Signature: 3HimJVVKUUboTBJV4RtudE3yNFZe8orKwLHrLE3DyH1z4dLudGSirK1m4kTJXgHZ5z78AexgGMrdJaVkRghjggvS

1 SOL
```

<https://solscan.io/tx/3HimJVVKUUboTBJV4RtudE3yNFZe8orKwLHrLE3DyH1z4dLudGSirK1m4kTJXgHZ5z78AexgGMrdJaVkRghjggvS?cluster=devnet>

这段操作展示了一个完整的 **Solana 测试代币（“水”）** 领取流程：通过命令行工具 **`solana airdrop`**，您成功地向 **`DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy`** 这个钱包地址请求了 **1 SOL** 的测试网络代币。系统立即处理了请求，并返回了一个**交易签名（Signature）**，证明这笔空投交易已经被 Solana 的测试网络（Devnet）接收并执行。最终的 **`1 SOL`** 确认了代币已成功转入您的账户余额。您可以使用返回的交易签名链接，在 **Solscan 区块浏览器**（并切换到 `devnet`）上进行查询，验证这笔空投交易的细节和最终状态，确保代币已安全到账。这个过程是 Solana 开发者在开始任何测试或部署智能合约之前，获取交易手续费（Gas Fee）所需测试代币的标准方法。

### 查询余额

```bash
➜ solana balance DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
1 SOL
```

这段操作展示了使用 **Solana 命令行工具（CLI）** 查询钱包余额的标准流程。您执行了 **`solana balance`** 命令，并传入了您的钱包地址 **`DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy`**。系统随后连接到当前配置的 Solana 网络（Devnet ），并查询该地址的最新余额，返回结果 **`1 SOL`**。这简洁地确认了您的账户中目前持有的 SOL 数量，通常用于验证前一步骤（如空投）的代币是否已成功到账，或在进行交易前检查是否有足够的 SOL 来支付网络费用。

### 查看账户信息

```bash
➜ solana account DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy

Public Key: DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
Balance: 1 SOL
Owner: 11111111111111111111111111111111
Executable: false
Rent Epoch: 18446744073709551615
```

这段操作展示了使用 **`solana account`** 命令查询您的钱包地址 **`DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy`** 在 Solana 链上的详细账户元数据。输出结果确认了该账户当前拥有 **`1 SOL`** 余额，且其 **Owner** 为 **`11111111111111111111111111111111`**（即 Solana 的 **系统程序**），表明它是一个标准的、用于持有 SOL 的钱包账户。**`Executable: false`** 进一步确认它不是一个可执行的智能合约程序。最重要的是，巨大的 **`Rent Epoch`** 值意味着该账户的余额已超过免租金门槛，因此它是一个 **“免租账户”**，数据会被永久安全地存储在链上，不会因为长期不活动或余额不足而被系统清除。

### `web3PK.ts`

```ts
import { PublicKey, SystemProgram } from '@solana/web3.js'

const main = async () => {
    const publicKey = new PublicKey('DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy')

    console.log(publicKey.toBytes())

    console.log(publicKey.toBase58())

    const [pda, _bump] = PublicKey.findProgramAddressSync([Buffer.from('seed')], SystemProgram.programId)

    console.log(pda.toBase58())
}

main()
```

这段 Node.js 代码片段展示了在 **Solana 开发中处理公钥（PublicKey）的三个核心操作**，主要使用了官方 SDK **`@solana/web3.js`** 库。首先，代码将一个已知的 Base58 编码的钱包地址 `'DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy'` 实例化为 **`PublicKey` 对象**。接着，它演示了两个基本转换：通过 **`publicKey.toBytes()`** 获取公钥的 **原始 32 字节** 形式，以及通过 **`publicKey.toBase58()`** 将其转换回便于人类读取的 **Base58 字符串地址**。最后，代码展示了 Solana 独有的 **程序派生地址（Program Derived Address, PDA）** 机制：它利用 `PublicKey.findProgramAddressSync` 函数，结合一个固定 **种子（'seed'）** 和 **系统程序 ID (`SystemProgram.programId`)**，同步计算出一个 **PDA 地址**。这个 PDA 地址是一个**没有对应私钥**的特殊账户，常用于智能合约中安全地存储和控制数据，是 Solana 链上交互和权限控制的关键技术。

### 运行脚本

```bash
➜ bun web3PK.ts
Uint8Array(32) [ 190, 56, 185, 178, 154, 228, 229, 173, 160, 242, 121, 140, 151, 194, 144, 241, 88, 64, 232, 144, 205, 148, 236, 85, 236, 3, 15, 168, 141, 164, 233, 16 ]
DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
8ZiyjNgnFFPyw39NyMQE5FGETTjyUhSHUVQG3oKAFZiU
```

这段 `bun web3PK.ts` 脚本的运行结果清晰地展示了 **Solana 公钥在不同数据格式间的转换和程序派生地址（PDA）的计算**。第一行输出是钱包地址 **`DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy`** 对应的 **原始 32 字节（`Uint8Array`）** 二进制数据，这是区块链底层处理公钥的格式。第二行输出将这个 32 字节数据转换回了 **Base58 编码** 的字符串，这是人类可读的钱包地址。最后一行输出 **`8ZiyjNgnFFPyw39NyMQE5FGETTjyUhSHUVQG3oKAFZiU`** 则是程序派生地址（PDA），它是将固定字符串 `'seed'` 和 **系统程序 ID** 作为输入，通过哈希函数计算得出的一个特殊地址，它在密码学上保证了**无法通过私钥控制**，是 Solana 智能合约中实现安全授权和数据存储的关键机制。

## 总结

通过本次实战，我们构建了一个完整的 Solana **密钥和账户管理知识体系**：

1. **密钥一致性：** 我们用代码和 CLI 结果共同证明了 Solana 地址的 **唯一性**。无论从 32 字节私钥派生，还是从 64 字节密钥对提取，地址始终一致，证实了私钥的绝对控制权。
2. **开发基础：** 掌握了 **`solana airdrop`**、**`solana balance`** 和 **`solana account`** 等 CLI 命令，确保开发者能在 Devnet 上高效地进行账户初始化和状态查询，是部署合约前的必备技能。
3. **高级机制（PDA）：** 我们深入了解了 **程序派生地址（PDA）** 的计算，这是 Solana 智能合约（尤其是 Anchor 框架）中实现 **无私钥授权** 和 **安全状态存储** 的关键，为构建复杂的 DeFi 应用奠定了基础。

掌握了从底层密钥字节到上层 PDA 机制的这套流程，你已完全具备在 Solana 生态中进行安全、高效开发的能力。

## 参考

- <https://solscan.io/tx/3HimJVVKUUboTBJV4RtudE3yNFZe8orKwLHrLE3DyH1z4dLudGSirK1m4kTJXgHZ5z78AexgGMrdJaVkRghjggvS?cluster=devnet>
- <https://www.anchor-lang.com/docs>
- <https://www.solanakit.com/docs/concepts/keypairs>
- <https://explorer.solana.com/tx/3HimJVVKUUboTBJV4RtudE3yNFZe8orKwLHrLE3DyH1z4dLudGSirK1m4kTJXgHZ5z78AexgGMrdJaVkRghjggvS?cluster=devnet>
- <https://explorer.solana.com/address/DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy?cluster=devnet>
- <https://solana.fm/address/11111111111111111111111111111111/?cluster=mainnet-alpha>
