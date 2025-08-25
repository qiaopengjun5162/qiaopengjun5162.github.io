+++
title = "Aptos Move 入门：从零到一的合约开发与测试实战"
description = "本文是一篇详尽的 Aptos Move 入门指南，手把手带你走完从环境搭建到合约测试的全流程。内容涵盖安装 Aptos CLI、初始化项目与账户、编写简单合约，并使用命令行工具成功进行编译与单元测试，助你迈出第一步。"
date = 2025-08-25T06:17:19Z
[taxonomies]
categories = ["Web3", "Move", "Aptos"]
tags = ["Web3", "Move", "Aptos"]
+++

<!-- more -->

# Aptos Move 入门：从零到一的合约开发与测试实战

Aptos 作为备受瞩目的高性能公链，其核心的 Move 语言以其安全、可靠的特性吸引了无数开发者的目光。但对于许多初学者来说，如何搭建一个顺畅的本地开发环境，并跑通第一个完整的“编码-编译-测试”流程，往往是入门的第一道门槛。

别担心，这篇文章就是为你准备的“零到一”保姆级实战指南。我们不谈高深的理论，只专注于最核心的动手操作。本文将带你一步步完成 Aptos CLI 的安装，初始化你的第一个 Move 项目和开发网账户，编写一个简单的智能合约，并最终使用官方工具链成功完成编译和单元测试。

读完本文，你将拥有一个功能完备的开发环境和一个清晰的开发流程概念，为你后续探索更复杂的 Move 世界打下最坚实的基础。

本文是一篇详尽的 Aptos Move 入门指南，手把手带你走完从环境搭建到合约测试的全流程。内容涵盖安装 Aptos CLI、初始化项目与账户、编写简单合约，并使用命令行工具成功进行编译与单元测试，助你迈出第一步。

## 实操

### 安装 Aptos CLI

```bash
# 方式一
brew update
brew install aptos

# 方式二
curl -fsSL "https://aptos.dev/scripts/install_cli.sh" | sh
```

更多详情请参考：<https://aptos.dev/zh/build/cli/install-cli/install-cli-mac>

### 验证安装

```bash
aptos --version
aptos 7.7.0
```

### 创建并切换到项目目录

```bash
mcd move-tut # mkdir move-tut && cd move-tut
/Users/qiaopengjun/Code/Aptos/move-tut
```

### 初始化项目

```bash
aptos move init --name my-dapp
{
  "Result": "Success"
}
```

### 查看项目目录

```bash
➜ tree . -L 6 -I "docs|target|node_modules|build"
.
├── Move.toml
├── scripts
├── sources
│   └── sample1.move
└── tests

4 directories, 2 files

```

### 初始化账户信息

```bash
aptos init --network devnet
Configuring for profile default
Configuring for network Devnet
Enter your private key as a hex literal (0x...) [Current: None | No input: Generate new key (or keep one if present)]

No key given, generating key...
Account 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3 is not funded, funding it with 100000000 Octas
Account 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3 funded successfully

---
Aptos CLI is now set up for account 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3 as profile default!
---

{
  "Result": "Success"
}
```

`aptos init` 命令用于初始化与 Aptos 交互所需的本地开发环境。它的核心作用是**初始化账户信息**，这包括在本地创建一对新的密钥（公钥和私钥）以及一个指向特定网络（如 Devnet）的配置文件。在开发网或测试网上，该命令还会自动调用水龙头（Faucet），为这个新生成的地址充值，从而完成在区块链上的账户创建与激活。

### **查看默认账户地址**

```bash
➜ aptos account lookup-address
{
  "Result": "48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3"
}
```

### 查询余额

```bash
➜ aptos account balance
{
  "Result": [
    {
      "asset_type": "coin",
      "coin_type": "0x1::aptos_coin::AptosCoin",
      "balance": 100000000
    }
  ]
}
```

### 安装`movefmt`

```bash
➜ cargo install --git https://github.com/movebit/movefmt.git
```

### 验证`movefmt`安装

查看版本信息

```bash
➜ movefmt --version
movefmt v1.3.0
```

### `sources/sample1.move` 文件

```rust
module net2dev_addr::Sample1 {
    use std::debug;
    use std::string::{String, utf8};

    const ID: u64 = 100;

    public fun set_value(): u64 {
        let value_id: u64 = 200;
        let string_value: String = utf8(b"Hello, world!");
        let string_byte: vector<u8> = b"This is a byte string";

        debug::print(&value_id);
        debug::print(&string_value);
        debug::print(&utf8(string_byte));

        ID
    }

    #[test]
    fun test_sample1() {
        let id_value = set_value();
        debug::print(&id_value);

        // 验证返回值是否正确
        assert!(id_value == ID, 1);
        assert!(id_value == 100, 2);
    }

    #[test]
    fun test_id_constant() {
        // 测试常量值
        assert!(ID == 100, 3);
    }

    #[test]
    fun test_string_operations() {
        // 测试字符串操作
        let test_string = utf8(b"Test string");
        let test_bytes = b"Test bytes";

        // 验证字符串创建
        assert!(test_string.length() == 11, 4);

        // 验证字节向量长度
        assert!(test_bytes.length() == 10, 5);
    }
}


```

这是一个基础的 Aptos Move 演示模块，主要用于展示和测试 Move 语言的几个核心概念。该模块定义了一个名为 `set_value` 的公共函数，此函数虽然在内部创建并打印了几个局部变量（一个数字、一个字符串和一个字节向量），但其最终的返回值被硬编码为模块顶层定义的常量 `ID`（值为100）。模块还包含了多个独立的单元测试函数（`#[test]`），它们分别验证了 `set_value` 函数的返回值确实是100、常量 `ID` 的值是正确的，以及字符串和字节向量的基本操作（如长度检查）符合预期，从而确保了整个模块的逻辑正确性。

### 编译

```bash
➜ aptos move compile --skip-fetch-latest-git-deps
Compiling, may take a little while to download git dependencies...
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
{
  "Result": [
    "48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample1"
  ]
}
```

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample1::test_id_constant
[debug] 200
[debug] "Hello, world!"
[debug] "This is a byte string"
[debug] 100
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample1::test_sample1
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample1::test_string_operations
Test result: OK. Total tests: 3; passed: 3; failed: 0
{
  "Result": "Success"
}
```

## 总结

恭喜你！跟随本篇指南，你已经成功地搭建了完整的 Aptos Move 本地开发环境，拥有了一个已激活并充值的开发网账户，并且亲手完成了一个智能合约从编写、编译到单元测试的全过程。

虽然我们今天实现的合约功能很简单，但更重要的是，你已经掌握了 Aptos Move 开发最基础、也是最重要的工作流：`init` -> `compile` -> `test`。这个流程是你未来构建任何复杂应用（无论是 DeFi、NFT 还是你的 Hongbao 项目）的基石。

你已经成功迈出了最关键的第一步。现在，有了这个坚实的基础，你已经准备好去探索 Move 语言更深层次的魅力，比如资源、对象和跨合约调用。继续前进吧！

## 参考

- <https://aptos.dev/zh/build/smart-contracts/book>
- <https://aptos.dev/zh/build/cli>
- <https://github.com/aptos-labs/aptos-core/tree/main/aptos-move/move-examples>
