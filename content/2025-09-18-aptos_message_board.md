+++
title = "Move 智能合约实战：在 Aptos 上构建你的首个 Web3 应用"
description = "Move 智能合约实战：在 Aptos 上构建你的首个 Web3 应用"
date = 2025-09-18T14:32:19Z
[taxonomies]
categories = ["Web3", "Move", "Aptos"]
tags = ["Web3", "Move", "Aptos"]
+++

<!-- more -->

# Move 智能合约实战：在 Aptos 上构建你的首个 Web3 应用

Aptos 作为一条高性能、高可扩展性的公链，正迅速成为 Web3 开发者的热门选择。其核心语言 Move 以其安全、高效的特性，为链上资产管理和智能合约开发提供了强大保障。但对于初学者而言，如何从零开始，编写并部署第一个 Move 智能合约，往往是一个巨大的挑战。本文将通过一个简单的“链上留言板”实战项目，为你提供一个清晰、完整的实践路径，让你真正理解 Move 语言的魅力，并迈出成为 Aptos 开发者坚实的第一步。

本文以一个完整的“链上留言板”项目为起点，全面解析 Aptos Move 智能合约的开发流程。你将亲历从项目初始化、核心模块编写、单元测试到最终部署与交互的全过程，深入理解 `entry`、`view` 函数、资源管理等关键概念。通过本次实战，你将掌握 Aptos 智能合约开发的精髓，为进阶学习 Web3 应用开发打下坚实基础。

## 实操

### 创建项目

```bash
mcd message_board # mkdir message_board & cd message_board
```

### 初始化

```bash
aptos move init --name message_board
{
  "Result": "Success"
}

aptos init
Configuring for profile default
Choose network from [devnet, testnet, mainnet, local, custom | defaults to devnet]
testnet
Enter your private key as a hex literal (0x...) [Current: None | No input: Generate new key (or keep one if present)]

No key given, generating key...

---
Aptos CLI is now set up for account 0xf416c7c5f004503fd9aca140ec17ad421b874537075f87616600404d413f138a as profile default!
---

The account has not been funded on chain yet. To fund the account and get APT on testnet you must visit https://aptos.dev/network/faucet?address=0xf416c7c5f004503fd9aca140ec17ad421b874537075f87616600404d413f138a
Press [Enter] to go there now >
{
  "Result": "Success"
}
```

### 项目目录

```bash
➜ tree . -L 6 -I "docs|target|node_modules|build"
.
├── Move.toml
├── scripts
├── sources
│   └── message.move
└── tests
    └── message_tests.move

4 directories, 3 files
```

### 实现合约 `message.move`

```rust
module message_board::message {
    use std::string::{String, utf8};
    use std::signer;
    use std::debug::print;

    /// Error message not found
    const ERR_MESSAGE_NOT_FOUND: u64 = 0;

    struct MessageHolder has key, store, drop {
        message: String
    }

    public entry fun set_message(account: &signer, message: String) acquires MessageHolder {
        let account_address = signer::address_of(account);
        print(&message);

        if (exists<MessageHolder>(account_address)) {
            print(&utf8(b"Updating existing message"));
            move_from<MessageHolder>(account_address);
        } else {
            print(&utf8(b"Creating new message"));
        };

        move_to(account, MessageHolder { message });
    }

    #[view]
    public fun get_message(account_address: address): String acquires MessageHolder {
        assert!(exists<MessageHolder>(account_address), ERR_MESSAGE_NOT_FOUND);

        let message_holder = borrow_global<MessageHolder>(account_address);
        print(&message_holder.message);
        message_holder.message
    }
}


```

这段 Aptos Move 代码定义了一个名为 `message` 的模块，其核心功能是允许 Aptos 账户在链上存储和查询一条文本消息。它通过 `MessageHolder` 结构体实现，该结构体包含一个 `message` 字段，并被声明为具有 `key` 属性，使其可以作为资源存储在账户下。`set_message` 是一个 `entry` 函数，用于将消息写入或更新到调用者的账户上，它会先检查是否已存在消息，若有则移除旧消息再存入新消息，确保每个账户只保留一条最新消息。`get_message` 是一个 `view` 函数，允许任何人在不发起交易的情况下免费查询特定账户上存储的消息。该函数通过 `exists` 检查确保消息存在，然后使用 `borrow_global` 安全地读取并返回消息内容。这整个模块展示了 Aptos Move 中资源管理、状态读写和只读查询的基本模式。

### 编译

```bash
➜ aptos move compile --named-addresses message_board=default
Compiling, may take a little while to download git dependencies...
UPDATING GIT DEPENDENCY https://github.com/aptos-labs/aptos-framework.git
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING message_board
{
  "Result": [
    "f416c7c5f004503fd9aca140ec17ad421b874537075f87616600404d413f138a::message"
  ]
}

```

### 测试文件 `message_tests.move`

```rust
#[test_only]
module message_board::message_tests {
    use std::string::utf8;
    use std::signer;
    use message_board::message;

    #[test(sender = @message_board)]
    fun test_set_and_get_message(sender: &signer) {
        // Test setting a message
        message::set_message(sender, utf8(b"Hello World"));

        // Verify the message was set correctly
        let stored_message = message::get_message(signer::address_of(sender));
        assert!(stored_message == utf8(b"Hello World"), 0)
    }

    #[test(sender = @message_board)]
    fun test_update_message(sender: &signer) {
        // Test setting a message
        message::set_message(sender, utf8(b"Hello World"));
        // Test updating a message
        message::set_message(sender, utf8(b"Goodbye World"));

        // Verify the message was updated correctly
        let stored_message = message::get_message(signer::address_of(sender));
        assert!(stored_message == utf8(b"Goodbye World"), 0);
    }
}

```

这段 Aptos Move 代码是一个名为 `message_tests` 的测试模块，它用于验证 `message` 模块的功能是否按预期工作。它被 `#[test_only]` 标记，意味着这段代码只在测试时编译和运行，不会被部署到链上。该模块包含两个测试函数，每个函数都被 `#[test]` 属性标记，并模拟一个名为 `sender` 的账户来执行操作。`test_set_and_get_message` 函数首先调用 `set_message` 存储一条“Hello World”消息，然后调用 `get_message` 检索该消息，并使用 `assert` 验证其内容是否正确。`test_update_message` 函数则测试了更新功能，它先设置一条消息，再用另一条新消息覆盖它，最后断言链上的消息已被成功更新为“Goodbye World”。这段代码通过在本地虚拟机中运行，高效且安全地验证了 `message` 模块的核心功能。

### 测试

```bash
➜ aptos move test --named-addresses message_board=default
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING message_board
Running Move unit tests
[debug] "Hello World"
[debug] "Creating new message"
[debug] "Hello World"
[ PASS    ] 0xf416c7c5f004503fd9aca140ec17ad421b874537075f87616600404d413f138a::message_tests::test_set_and_get_message
[debug] "Hello World"
[debug] "Creating new message"
[debug] "Goodbye World"
[debug] "Updating existing message"
[debug] "Goodbye World"
[ PASS    ] 0xf416c7c5f004503fd9aca140ec17ad421b874537075f87616600404d413f138a::message_tests::test_update_message
Test result: OK. Total tests: 2; passed: 2; failed: 0
{
  "Result": "Success"
}
```

### 部署发布

```bash
➜ aptos move publish --named-addresses message_board=default
Compiling, may take a little while to download git dependencies...
UPDATING GIT DEPENDENCY https://github.com/aptos-labs/aptos-framework.git
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING message_board
package size 1479 bytes
Do you want to submit a transaction for a range of [200100 - 300100] Octas at a gas unit price of 100 Octas? [yes/no] >
yes
Transaction submitted: https://explorer.aptoslabs.com/txn/0x497798403b3367786a6fdc49006ba484f9d54582951e9d57999993922dd96a1b?network=testnet
{
  "Result": {
    "transaction_hash": "0x497798403b3367786a6fdc49006ba484f9d54582951e9d57999993922dd96a1b",
    "gas_used": 2001,
    "gas_unit_price": 100,
    "sender": "f416c7c5f004503fd9aca140ec17ad421b874537075f87616600404d413f138a",
    "sequence_number": 0,
    "replay_protector": {
      "SequenceNumber": 0
    },
    "success": true,
    "timestamp_us": 1758187652429622,
    "version": 6869435942,
    "vm_status": "Executed successfully"
  }
}



➜ aptos move publish --named-addresses message_board=default
Compiling, may take a little while to download git dependencies...
UPDATING GIT DEPENDENCY https://github.com/aptos-labs/aptos-framework.git
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING message_board
package size 1504 bytes
Do you want to submit a transaction for a range of [9200 - 13800] Octas at a gas unit price of 100 Octas? [yes/no] >
yes
Transaction submitted: https://explorer.aptoslabs.com/txn/0x1237b094654964277b45d4d54e8a57ab48ee976e4807053529780f5e795c5788?network=testnet
{
  "Result": {
    "transaction_hash": "0x1237b094654964277b45d4d54e8a57ab48ee976e4807053529780f5e795c5788",
    "gas_used": 92,
    "gas_unit_price": 100,
    "sender": "f416c7c5f004503fd9aca140ec17ad421b874537075f87616600404d413f138a",
    "sequence_number": 2,
    "replay_protector": {
      "SequenceNumber": 2
    },
    "success": true,
    "timestamp_us": 1758189020411917,
    "version": 6869459428,
    "vm_status": "Executed successfully"
  }
}
```

0x497798403b3367786a6fdc49006ba484f9d54582951e9d57999993922dd96a1b

<https://explorer.aptoslabs.com/txn/0x497798403b3367786a6fdc49006ba484f9d54582951e9d57999993922dd96a1b?network=testnet>

### 调用 `set_message`

```bash
➜ aptos move run --function-id 'default::message::set_message' --args 'string:Hello, Aptos!'
Do you want to submit a transaction for a range of [44500 - 66700] Octas at a gas unit price of 100 Octas? [yes/no] >
yes
Transaction submitted: https://explorer.aptoslabs.com/txn/0x75dbc551e642f6ed210ff1ed845e6bd07879af3b1b357d4de1b8f4a9653c8e05?network=testnet
{
  "Result": {
    "transaction_hash": "0x75dbc551e642f6ed210ff1ed845e6bd07879af3b1b357d4de1b8f4a9653c8e05",
    "gas_used": 445,
    "gas_unit_price": 100,
    "sender": "f416c7c5f004503fd9aca140ec17ad421b874537075f87616600404d413f138a",
    "sequence_number": 1,
    "replay_protector": {
      "SequenceNumber": 1
    },
    "success": true,
    "timestamp_us": 1758188642390049,
    "version": 6869453126,
    "vm_status": "Executed successfully"
  }
}
```

### 调用 `get_message`

```bash
➜ aptos move view --function-id 'default::message::get_message' --args 'address:0xf416c7c5f004503fd9aca140ec17ad421b874537075f87616600404d413f138a'
{
  "Result": [
    "Hello, Aptos!"
  ]
}
```

## 总结

通过本次实战，我们成功地完成了 Aptos Move 智能合约的整个开发闭环。从项目的初始化开始，我们定义了一个名为 `message_board` 的模块，并创建了核心数据结构 `MessageHolder`，它以资源的形式存储在用户账户下。我们编写了 `set_message` 作为入口函数来修改链上状态，实现了留言的创建和更新；同时，通过 `get_message` 这个只读函数，我们掌握了如何免费、高效地查询链上数据。单元测试环节确保了合约的逻辑正确性，最终的部署与调用验证了所有功能在真实链上运行无误。通过这个简单的项目，你不仅理解了 Aptos Move 的基本语法和核心概念，还掌握了完整的开发流程和常用的 CLI 命令，为未来构建更复杂的链上应用打下了坚实基础。

## 参考

- <https://aptos.dev/build/guides/first-move-module>
- <https://aptos.dev/zh/network/faucet?address=0xf416c7c5f004503fd9aca140ec17ad421b874537075f87616600404d413f138a>
- <https://explorer.aptoslabs.com/account/0xf416c7c5f004503fd9aca140ec17ad421b874537075f87616600404d413f138a/modules/packages/message_board?network=testnet>
