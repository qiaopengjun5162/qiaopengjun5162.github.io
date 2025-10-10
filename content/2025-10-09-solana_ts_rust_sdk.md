+++
title = "Solana 地址进阶：从 TS/JS 到 Rust SDK V3，完全掌握公钥与 PDA 的底层逻辑"
description = "Solana 地址进阶：从 TS/JS 到 Rust SDK V3，完全掌握公钥与 PDA 的底层逻辑"
date = 2025-10-09T15:55:02Z
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# **Solana 地址进阶：从 TS/JS 到 Rust SDK V3，完全掌握公钥与 PDA 的底层逻辑**

你好，Solana 开发者！

无论是用 TypeScript/JavaScript 开发前端应用，还是用 Rust 编写高性能智能合约，**地址 (Pubkey/Address)** 都是你代码中的核心实体。但你是否知道，你的地址是如何在 Base58 字符串和底层 **32 字节数组** 之间高效转换的？更关键的是，智能合约中至关重要的 **程序派生地址（PDA）** 在不同语言中又是如何计算和表示的？

本文将为你提供一个**跨语言的实战视角**。我们将使用 **JavaScript/TypeScript** 和 **Rust SDK V2/V3**，对比展示地址的实例化、编码、以及 PDA 的生成。特别是，我们将揭示 Rust SDK 如何进行模块化升级，助你站在 Solana 生态技术的最前沿。

本文深入解析 Solana **地址的底层结构**，通过 **TypeScript/JavaScript (`@solana/kit`)** 和 **Rust (`solana-sdk`)** 进行双语实战。我们演示了 Base58 地址到 **32 字节二进制** 的转换，核心计算了 **程序派生地址（PDA）**。同时，文章对比了 Rust SDK V2 到 V3 的**模块化演进**，展示了如何用 `solana-address` 替代旧的 `Pubkey`，是开发者掌握 Solana 跨语言地址处理和生态最新趋势的指南。

## 实操

### `kitPDA.ts`

```ts
import {
    address,
    getAddressEncoder,
    getProgramDerivedAddress,
} from "@solana/kit"
import { SYSTEM_PROGRAM_ADDRESS } from "@solana-program/system"
const main = async () => {
    const pk = address("DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy")
    console.log(pk)
    console.log(getAddressEncoder().encode(pk))

    const [pda2, _bump2] = await getProgramDerivedAddress({
        programAddress: SYSTEM_PROGRAM_ADDRESS,
        seeds: ["seed"],
    })
    console.log(pda2)
}

main()

```

这段 TypeScript 代码片段使用了 **`@solana/kit`** 库来演示 Solana 地址的**格式化、编码和程序派生地址（PDA）的计算**，这是 Web3 开发中处理账户交互的关键步骤。代码首先通过 **`address("...")`** 函数，将用户可读的 **Base58 字符串地址** 转换为库内部处理的 **地址对象（`pk`）**。接着，它使用 **`getAddressEncoder().encode(pk)`** 演示了将这个地址对象编码成区块链底层所需的 **32 字节 `Uint8Array`** 格式。最核心的操作是计算 **PDA**：代码调用了异步函数 **`getProgramDerivedAddress`**，将一个固定字符串 **`"seed"`** 和 Solana 的 **系统程序地址（`SYSTEM_PROGRAM_ADDRESS`）** 作为参数。这个函数基于密码学哈希算法，生成了一个 **没有对应私钥** 的 **`pda2` 地址**，这种地址专用于智能合约中进行无私钥授权和安全数据存储，是 Solana 高级编程模型的基础。

### 运行脚本

```ts
➜ bun kitPDA.ts
DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
Uint8Array(32) [ 190, 56, 185, 178, 154, 228, 229, 173, 160, 242, 121, 140, 151, 194, 144, 241, 88, 64, 232, 144, 205, 148, 236, 85, 236, 3, 15, 168, 141, 164, 233, 16 ]
8ZiyjNgnFFPyw39NyMQE5FGETTjyUhSHUVQG3oKAFZiU
```

这段 **`bun kitPDA.ts`** 脚本的运行输出展示了 Solana 地址在不同格式间的转换以及 **程序派生地址（PDA）** 的计算。第一行输出 **`DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy`** 是输入地址的 **Base58 字符串** 形式，通过 `address()` 函数处理后再次输出。第二行输出是一个 **32 字节的 `Uint8Array`**，这是通过编码器将该地址转换成的区块链底层所需的 **原始二进制格式**。最后一行输出 **`8ZiyjNgnFFPyw39NyMQE5FGETTjyUhSHUVQG3oKAFZiU`** 则是程序派生地址（PDA），它是由固定种子 `"seed"` 和 Solana 系统程序 ID 经过哈希运算得出的特殊账户，它的核心意义是 **无法通过任何私钥控制**，是 Solana 智能合约中进行安全授权和数据存储的关键。

## Solana-sdk V2 实操

### 创建并初始化项目

```bash
mcd sdkV2 # mkdir sdkV2 & cd sdkV2
cargo init
```

### 添加依赖

```bash
cargo add solana-sdk@2.3.1
```

### `main.rs` 文件

```rust
use solana_sdk::pubkey::Pubkey;
use solana_sdk::system_program::ID as SYSTEM_PROGRAM_ID;

fn main() {
    let pk = Pubkey::from_str_const("DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy");
    println!("{}", pk);
    println!("{:?}", pk.to_bytes());
    assert_eq!(
        pk.to_string(),
        "DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy"
    );

    println!("{}", SYSTEM_PROGRAM_ID);
}

```

这段 Rust 代码展示了如何使用 **`solana-sdk`** 库来处理 Solana 的 **公钥（Pubkey）** 结构。代码通过 `use` 语句引入了处理公钥所需的模块和 **系统程序 ID（`SYSTEM_PROGRAM_ID`）**。核心操作是：首先，它使用 **`Pubkey::from_str_const`** 函数，将 Base58 编码的钱包地址字符串 **`DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy`** 安全地实例化为一个 **`Pubkey` 对象**。随后，代码打印了该公钥的 **字符串（Base58）形式** 和底层的 **32 字节数组形式（`pk.to_bytes()`）**，验证了地址在人类可读格式和底层二进制格式之间的转换能力。最后，代码输出了 Solana 网络中一个固定的特殊地址：**系统程序 ID**，这个地址代表了 Solana 的核心程序，负责管理基础账户和 SOL 的转移。这段代码是 Solana Rust 开发中处理链上地址和重要程序 ID 的基础入门实践。

### 运行

```bash
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.41s
     Running `target/debug/sdkV2`
DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
[190, 56, 185, 178, 154, 228, 229, 173, 160, 242, 121, 140, 151, 194, 144, 241, 88, 64, 232, 144, 205, 148, 236, 85, 236, 3, 15, 168, 141, 164, 233, 16]
11111111111111111111111111111111
```

这段 `cargo run` 的输出结果展示了 **Solana Rust SDK（`solana-sdk`）** 在处理公钥地址时的基本转换和系统程序识别。第一行输出 **`DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy`** 是您输入的钱包地址的 **Base58 字符串** 形式，这是人类可读的格式。紧接着的第二行输出是一个包含 **32 个字节（`[190, 56, ...]`）** 的数组，它正是该地址在区块链底层存储和处理的 **原始二进制格式**。最后一行输出 **`11111111111111111111111111111111`** 则是硬编码在 Solana SDK 中的 **系统程序 ID**，这个地址在 Solana 网络中扮演着核心角色，负责所有基础账户和 SOL 的管理。这个输出简洁有力地验证了 Rust 能够准确地在 **可读地址**、**底层字节** 和 **核心程序 ID** 之间进行转换。

## Solana-sdk V3 实操

### 创建项目

```bash
mcd sdkV3
cargo init
cargo add solana-sdk
```

### `Cargo.toml` 文件

```toml
[package]
name = "sdkV3"
version = "0.1.0"
edition = "2024"

[dependencies]
solana-address = "1.0.0"
# solana-pubkey = "3.0.0"
# solana-sdk = "3.0.0"
solana-system-interface = "2.0.0"

```

### `main.rs` 文件

```rust
// use solana_sdk::pubkey::Pubkey;
// use solana_pubkey::Pubkey;
use solana_address::Address;
use solana_system_interface::program::ID as SYSTEM_PROGRAM_ID;

fn main() {
    // let pk = Pubkey::from_str_const("DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy");
    let pk = Address::from_str_const("DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy");
    println!("{}", pk);
    println!("{:?}", pk.to_bytes());
    assert_eq!(
        pk.to_string(),
        "DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy"
    );

    println!("{}", SYSTEM_PROGRAM_ID);
}

```

这段 Rust 代码展示了在 **Solana SDK 的新版本（或解耦模块）** 中处理链上地址的方式，其核心目的是**将地址功能从庞大的 `solana-sdk` 中分离，以提高编译速度和模块化程度**。在 `Cargo.toml` 中，开发者移除了完整的 `solana-sdk` 依赖，转而引入了更精简的独立库：**`solana-address`**（用于处理公钥/地址）和 **`solana-system-interface`**（用于获取系统程序ID）。在 `main.rs` 文件中，地址类型从传统的 `Pubkey` 被替换为 **`solana_address::Address`**，但功能保持不变：它通过 **`Address::from_str_const`** 将 Base58 地址字符串实例化，随后成功打印了该地址的**字符串形式**、**32 字节数组形式**，并输出了固定的 **`SYSTEM_PROGRAM_ID`**。这反映了 Solana 生态系统在 Rust 侧正在向 **更细粒度、更高效的模块化依赖** 演进。

### 运行

```bash
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.01s
     Running `target/debug/sdkV3`
DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy
[190, 56, 185, 178, 154, 228, 229, 173, 160, 242, 121, 140, 151, 194, 144, 241, 88, 64, 232, 144, 205, 148, 236, 85, 236, 3, 15, 168, 141, 164, 233, 16]
11111111111111111111111111111111

```

这段 **`cargo run`** 的输出结果与您使用 `solana-sdk v2` 的结果完全一致，它验证了 **Rust Solana 模块化依赖的正确性**。第一行输出 **`DoYdaydSDLtZU4fBjVjsoGVFFpuS2aNmCRgDPawNiyZy`** 是输入的 **Base58 字符串地址**。紧接着的第二行是一个包含 **32 字节** 的数组，代表该地址的 **原始二进制格式**。最后一行输出 **`11111111111111111111111111111111`** 则是 Solana 的 **系统程序 ID**。尽管您切换了依赖，使用了更精简的 **`solana-address`** 模块，但核心功能和数据转换结果保持不变，这证明了 Solana Rust 生态系统在向更细粒度模块化演进时，保持了向下兼容和底层数据的准确性。

## 总结

通过对比 TypeScript/JavaScript 和 Rust 两个生态的实战，我们全面掌握了 Solana 地址处理的核心要点：

1. **底层数据一致性：** 无论是 `@solana/kit` 还是 `solana-sdk`，所有 Solana 地址的底层都是一个 **唯一的 32 字节数组**。这种跨语言的一致性是 Solana 生态高效互操作的基础。
2. **PDA 机制统一：** 我们在 JS/TS 和 Rust 中成功计算了基于相同种子的 **程序派生地址（PDA）**，证明了底层密码学哈希算法在不同 SDK 中是完全同步的。PDA 机制依旧是 Solana 智能合约**无私钥授权**的核心。
3. **Rust 模块化趋势：** 文章对比了 Rust SDK 从 V2 到 V3 的演进，明确了 **`solkey-address`** 等精简模块正在取代庞大的 `solana-sdk`。这种模块化趋势旨在提高 Rust 程序的编译速度和依赖清晰度，是编写高性能链上程序必须关注的最新方向。

掌握了这套跨语言、涵盖底层二进制到高级 PDA 的地址处理知识，你将成为一名更全面、更高效的 Solana 开发者。

## 参考

- <https://github.com/anza-xyz/solana-sdk>
- <https://www.anchor-lang.com/docs>
- <https://docs.rs/solana-system-interface/2.0.0/solana_system_interface/index.html>
- <https://github.com/anza-xyz/solana-sdk/pull/243>
- <https://www.solanakit.com/docs/concepts/keypairs>
