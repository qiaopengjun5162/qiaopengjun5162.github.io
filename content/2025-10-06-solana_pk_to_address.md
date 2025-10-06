+++
title = "【Solana实操】64字节私钥文件解析难题：用三种姿势安全获取钱包地址"
description = "【Solana实操】64字节私钥文件解析难题：用三种姿势安全获取钱包地址"
date = 2025-10-06T05:38:55Z
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# **【Solana实操】64字节私钥文件解析难题：用三种姿势安全获取钱包地址**

你好，Solana 开发者！

在 Solana 开发中，我们习惯于使用 **`solana address -k keys/id.json`** 命令一键查看钱包地址。但你是否想过，这背后发生了什么？为什么一个 **64 字节**的原始数据，能直接变成一个可读的钱包地址？

当你尝试在 **TypeScript** 代码中直接处理这个 64 字节的 JSON 数组时，你会发现一个巨大的障碍：**地址解码器不买账！**

本文将通过一个完整的实操案例，从生成密钥对开始，深入底层代码，教你如何使用 **`@solana/kit` 结合 Web Crypto API**，安全、规范地将 64 字节密钥数据转换为 Solana 地址。我们不仅解决问题，更要搞清楚原理，提供三种官方推荐的解码方法，让你在任何应用场景都能应对自如。

Solana 密钥文件（`id.json`）是 64 字节的原始数据，但地址解码器只认 32 字节公钥。本文通过生成密钥对的实操，详细演示了如何在 **TypeScript 环境**中，利用 `@solana/kit` 和 Web Crypto API **安全提取 32 字节公钥**。我们对比了三种官方解码方式，验证了其与 `solana-cli` 的结果一致性，助你搭建最规范的密钥处理流程。

## 实操

#### 生成密钥对

```bash
➜ solana-keygen new -o keys/id.json --force
Generating a new keypair

For added security, enter a BIP39 passphrase

NOTE! This passphrase improves security of the recovery seed phrase NOT the
keypair file itself, which is stored as insecure plain text

BIP39 Passphrase (empty for none):

Wrote new keypair to keys/id.json
==========================================================================
pubkey: DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
==========================================================================
Save this seed phrase and your BIP39 passphrase to recover your new keypair:
myself kiss alcohol burden twist answer dress noise clap crisp group ozone
==========================================================================

```

这条命令是用于生成 Solana 区块链网络的密钥对（公钥和私钥），并保存到指定文件中。

- solana-keygen：Solana 官方提供的密钥生成工具，用于创建钱包密钥。
- new：表示生成新的密钥对。
- -o keys/id.json：将生成的密钥对保存到 `keys` 目录下的 `id.json` 文件中（包含私钥和公钥信息）。
- --force：如果 `id.json` 已存在，则强制覆盖，不提示确认。

执行后，会在 `keys/id.json` 中存储一个 Solana 钱包的密钥对，可用于签名交易或访问对应地址的资金。私钥需妥善保管，丢失则无法恢复资产。

### 查看密钥对文件

```bash
➜ cat keys/id.json
[152,88,131,150,62,99,225,136,141,126,164,180,43,60,5,14,144,247,23,221,72,57,58,75,109,8,72,4,223,8,52,120,190,56,185,178,154,228,229,173,160,242,121,140,151,194,144,241,88,64,232,144,205,148,236,85,236,3,15,168,141,164,233,16]%
```

### `pkToAddress.ts` 文件

在 **Solana TypeScript 环境**中，如何从密钥文件（私钥）中**安全且规范地提取并转换**出可读的钱包地址。

```ts
import { createKeyPairFromBytes } from '@solana/kit'
import { getAddressCodec, getAddressDecoder, getAddressFromPublicKey } from '@solana/addresses'

const addressBytes = new Uint8Array([152, 88, 131, 150, 62, 99, 225, 136, 141, 126, 164, 180, 43, 60, 5, 14, 144, 247, 23, 221, 72, 57, 58, 75, 109, 8, 72, 4, 223, 8, 52, 120, 190, 56, 185, 178, 154, 228, 229, 173, 160, 242, 121, 140, 151, 194, 144, 241, 88, 64, 232, 144, 205, 148, 236, 85, 236, 3, 15, 168, 141, 164, 233, 16])

const keyPair = await createKeyPairFromBytes(
    addressBytes
)

// 方式一
const address = await getAddressFromPublicKey(keyPair.publicKey)
console.log(address)

const publicKeyBytes = new Uint8Array(await crypto.subtle.exportKey('raw', keyPair.publicKey))

// 方式二
const addressDecoder = getAddressDecoder()
const address2 = addressDecoder.decode(publicKeyBytes)
console.log(address2)

// 方式三
const address3 = getAddressCodec().decode(publicKeyBytes)
console.log(address3)

```

## 💻 示例代码解读：从密钥字节到 Solana 地址

这段代码的核心目的是解决一个关键问题：**Solana 密钥文件是 64 字节的原始数据，而钱包地址是 32 字节公钥的 Base58 编码，如何进行正确的转换？**

### 1. 密钥导入与 KeyPair 创建 (数据准备)

| 代码行                                                       | 说明                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `import { createKeyPairFromBytes } from '@solana/kit'`       | 导入用于解析密钥对字节的工具。                               |
| `const addressBytes = new Uint8Array([ ... ])`               | **输入数据**：模拟从 `keys/id.json` 文件中读取的 **64 字节**数组。这 64 字节包含了 **32 字节私钥**和 **32 字节公钥**。 |
| `const keyPair = await createKeyPairFromBytes(addressBytes)` | **创建 KeyPair**：使用 `@solana/kit` 库将 64 字节的原始数据解析为一个 **`CryptoKeyPair`** 对象。这是所有后续操作的基础。 |

### 2. 公钥字节提取 (核心安全步骤)

在 Web3 开发中，公钥（Public Key）通常以复杂的 **`CryptoKey`** 对象的抽象形式存在，无法直接访问其原始字节。这是为了安全考虑。

| 代码行                                                       | 说明                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `const publicKeyBytes = new Uint8Array(await crypto.subtle.exportKey('raw', keyPair.publicKey))` | **公钥导出**：**这是实现转换的关键！**我们使用浏览器或 Node.js 环境内置的 Web Crypto API 的 **`crypto.subtle.exportKey`** 方法，指定以 `'raw'` 格式导出 `keyPair.publicKey` 对象。 |
| **结果：**                                                   | 这一步将抽象的 `CryptoKey` 转换为一个仅包含 **32 字节**原始公钥数据的 `Uint8Array` (`publicKeyBytes`)。此时，数据已准备好进行 Base58 编码。 |

### 3. 三种地址解码方式 (验证与应用)

一旦我们获得了正确的 **32 字节**公钥 (`publicKeyBytes`)，就可以使用多种方式将其编码为人类可读的 **Base58 格式的 Solana 地址**。

#### 方式一：高级封装（最推荐）

```ts
const address = await getAddressFromPublicKey(keyPair.publicKey)
console.log(address)
```

- **原理：** `@solana/addresses` 库提供的 **`getAddressFromPublicKey`** 是一个高级辅助函数。它内部自动完成了“导出 32 字节公钥”和“Base58 编码”的两个步骤。
- **优势：** **代码最简洁、可读性最高**，是生产环境中获取地址的首选方式。

#### 方式二：使用 Decoder（底层验证）

```ts
const addressDecoder = getAddressDecoder()
const address2 = addressDecoder.decode(publicKeyBytes)
console.log(address2)
```

- **原理：** **`getAddressDecoder()`** 专门负责将 **32 字节**的原始字节数组转换为 Base58 编码的地址字符串。
- **意义：** 这验证了我们通过 `exportKey` 获得的 `publicKeyBytes` **确实是**解码器期望的 32 字节数据。

#### 方式三：使用 Codec（通用工具）

```ts
const address3 = getAddressCodec().decode(publicKeyBytes)
console.log(address3)
```

- **原理：** **`getAddressCodec()`** 是一个集成了编码（Encoder）和解码（Decoder）的通用工具。其 `decode` 方法与 `getAddressDecoder()` 的功能一致。
- **意义：** 证明了 `getAddressCodec` 同样是有效的解码路径。

## 💡 为什么需要 KeyPair 转换？

> "Solana CLI 工具（`solana address -k ...`）可以一键完成私钥文件的解析和地址生成。但在 TypeScript/JavaScript 环境中，我们需要手动执行两个关键步骤：首先，使用 **`createKeyPairFromBytes`** 将 64 字节的私钥文件解析为抽象的 **`CryptoKey`** 对象；其次，使用 **`crypto.subtle.exportKey`** 导出正确的 **32 字节公钥**，最终才能使用 **`getAddressDecoder`** 或 **`getAddressFromPublicKey`** 完成 Base58 编码，获得最终地址。"

这段代码完美展示了从文件数据到钱包地址的**安全且规范的完整流程。**

### 运行脚本

```bash
➜ bun pkToAddress.ts
DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy

➜ solana address -k keys/id.json
DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
```

## 🎯 脚本运行结果解释

### 1. 脚本输出（`bun pkToAddress.ts`）

```bash
DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
```

你的脚本成功地将输入的 **64 字节密钥数据**（来自 `keys/id.json`）解析为 Solana 地址。三个重复的地址分别对应于脚本中使用的 **三种不同的、但都正确的解码方法**：

- **第一行 (`address`)：** 使用高级封装函数 `getAddressFromPublicKey`。
- **第二行 (`address2`)：** 使用底层解码器 `getAddressDecoder`。
- **第三行 (`address3`)：** 使用编解码器 `getAddressCodec`。

这三次输出相同，表明你在脚本中对 **32 字节公钥的提取**（通过 `crypto.subtle.exportKey`）是**完全正确**的，成功解决了 64 字节私钥和 32 字节公钥之间的格式差异。

### 2. CLI 输出（`solana address -k keys/id.json`）

```
DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
```

这是 Solana 官方 CLI 工具从密钥文件 (`keys/id.json`) 中读取并计算得到的官方钱包地址。

### 3. 结论

**结果完全一致！** 这证明了你的 TypeScript 代码不仅是有效的，而且其执行逻辑（解析密钥对、导出公钥、Base58 编码）**与 Solana 官方工具的底层实现是高度兼容和匹配的**。你现在可以信任你的 TypeScript 脚本来安全地处理 Solana 密钥文件。

## 总结

通过这次深入的实战，我们成功地掌握了 Solana 开发中密钥处理的**核心规范**。

我们不仅学会了使用 **`solana-keygen`** 生成标准的 **64 字节密钥文件**，更重要的是，我们解决了 **TypeScript 环境**下处理密钥文件的最大难题：

1. 通过 **`createKeyPairFromBytes`** 将原始 64 字节数据解析为抽象的 `CryptoKey` 对象。
2. 通过 **`crypto.subtle.exportKey('raw', ...)`** 这一关键的安全步骤，**精确提取了 32 字节的原始公钥**。
3. 最终，我们通过 **`getAddressFromPublicKey`** 等三种方式，成功输出了与 `solana address` 命令**完全一致**的钱包地址。

这段代码（`pkToAddress.ts`）可以作为你在任何 Solana DApp 中导入和使用本地密钥文件的**最佳实践模板**，保证了代码的安全性、规范性和与 Solana 官方生态的兼容性。

## 参考

- <https://www.solanakit.com/api/functions/getAddressCodec>
- <https://soldev.cn/>
- <https://solscan.io/>
- <https://solanacookbook.com/>
- <https://www.anchor-lang.com/>
- <https://github.com/solana-foundation/anchor>
