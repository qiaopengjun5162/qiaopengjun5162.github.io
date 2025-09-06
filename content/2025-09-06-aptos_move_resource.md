+++
title = "Aptos Move 入门：掌握链上资源（Resource）的增删改查"
description = "Aptos Move 入门：掌握链上资源（Resource）的增删改查"
date = 2025-09-06T02:25:15Z
[taxonomies]
categories = ["Web3", "Move", "Aptos"]
tags = ["Web3", "Move", "Aptos"]
+++

<!-- more -->

# Aptos Move 入门：掌握链上资源（Resource）的增删改查

智能合约的终极目的，是管理那些永久存在于区块链上的状态（State）。在 Aptos Move 中，这种链上状态是通过其独一无二的**资源（Resource）模型**来管理的。所谓资源，就是被赋予了 `key` 能力的结构体，它们像真实的物理资产一样，被直接、安全地存放在用户的账户地址之下。

那么，我们如何创建、读取、更新和销毁这些珍贵的链上资产呢？

这篇实战教程将带你走完一次链上资源的完整生命周期之旅。我们将从零开始，学习如何使用 `move_to` 创建一个资源，用 `borrow_global` 和 `borrow_global_mut` 读取和修改它，并最终用 `move_from` 将其安全地移除。掌握这套“增删改查”（CRUD）流程，是每一位 Aptos Move 开发者的核心基本功。

本文是 Aptos Move 链上存储的终极实战指南。通过一个 Staking 示例，你将掌握 `key` 资源从创建、读取、更新到销毁的完整生命周期，全面学会 `move_to`, `borrow_global` 和 `move_from` 等核心指令。

## 实操

Aptos Move Storage Operations

### 示例一

```rust
module net2dev_addr::StorageDemo {
    struct StakePool has key {
        amount: u64
    }

    fun add_user(account: &signer) {
        let amount: u64 = 0;
        move_to(account, StakePool { amount })
    }

    fun read_pool(account: address): u64 acquires StakePool {
        borrow_global<StakePool>(account).amount
    }

    #[test_only]
    use std::debug::print;

    #[test_only]
    use std::signer;

    #[test_only]
    use std::string::utf8;

    #[test(user = @0x123)]
    fun test_function(user: signer) acquires StakePool {
        add_user(&user);
        assert!(borrow_global<StakePool>(@0x123).amount == 0, 0);
        assert!(read_pool(@0x123) == 0, 1);
        assert!(read_pool(signer::address_of(&user)) == 0, 2);
        print(&borrow_global<StakePool>(@0x123).amount);
        print(&read_pool(@0x123));
        print(&utf8(b"User Added Successfully!"));
    }
}


```

这段 Aptos Move 代码通过一个名为 `StorageDemo` 的模块，演示了使用**资源（resources）\**进行\**链上数据存储**的基础模式。它定义了一个带有 **`key`\**能力的 `StakePool` 结构体，使其可以直接存储在用户的账户地址下。该模块展示了与这种资源交互的两种主要操作：`add_user` 函数使用 \*\*`move_to`\*\* 指令为一个交易签名者\**创建并存储**一个新的、空的 `StakePool`；而 `read_pool` 函数则使用 **`borrow_global`** 从任意指定地址**读取**已存在的 `StakePool` 中的数据。整个流程由一个单元测试进行验证，该测试模拟了一个用户（`@0x123`）先存储资源，然后读取数据以确认写入成功的完整过程。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 0
[debug] 0
[debug] "User Added Successfully!"
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::StorageDemo::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过其全部单元测试**。在成功编译项目后，测试框架执行了 `StorageDemo` 模块中定义的唯一一个测试函数 `test_function`。日志中的 `[debug]` 输出清晰地展示了测试过程：两个 `0` 分别是通过直接 `borrow_global` 和调用 `read_pool` 函数从链上存储中**成功读取**回来的初始质押数量，而 "User Added Successfully!" 消息则标志着测试逻辑的顺利执行。最终的 `[ PASS ]` 状态，结合 `Test result: OK` 的总结陈述，共同确认了该测试用例顺利完成，证明了你代码中通过 `move_to` **写入**数据到链上存储，再读取出来的整个流程是完全正确的。

### 示例二

```rust
module net2dev_addr::StorageDemo {
    struct StakePool has key {
        amount: u64
    }

    fun add_user(account: &signer) {
        let amount: u64 = 0;
        move_to(account, StakePool { amount })
    }

    fun read_pool(account: address): u64 acquires StakePool {
        borrow_global<StakePool>(account).amount
    }

    fun stake(account: address) acquires StakePool {
        let entry = &mut borrow_global_mut<StakePool>(account).amount;
        *entry += 100;
    }

    #[test_only]
    use std::debug::print;

    #[test_only]
    use std::signer;

    #[test_only]
    use std::string::utf8;

    #[test(user = @0x123)]
    fun test_function(user: signer) acquires StakePool {
        add_user(&user);
        assert!(borrow_global<StakePool>(@0x123).amount == 0, 0);
        assert!(read_pool(@0x123) == 0, 1);
        assert!(read_pool(signer::address_of(&user)) == 0, 2);
        print(&borrow_global<StakePool>(@0x123).amount);
        print(&read_pool(@0x123));
        print(&utf8(b"User Added Successfully!"));

        stake(@0x123);
        assert!(read_pool(@0x123) == 100, 3);
        stake(signer::address_of(&user));
        assert!(read_pool(signer::address_of(&user)) == 200, 4);
        print(&utf8(b"User Staked Successfully!"));
    }
}
```

这段 Aptos Move 代码扩展了 `StorageDemo` 模块，以演示一个链上资源的完整生命周期：**创建、读取和修改**。在原有的创建 (`add_user` 函数) 和读取 (`read_pool` 函数) `StakePool` 资源的功能之上，新增了一个 `stake` 函数。该函数的核心是使用 **`borrow_global_mut`** 来获取一个指向链上数据的**可变引用**，从而能够直接修改已存储的 `amount` 字段。其单元测试完整地验证了这一流程：首先创建并读取初始状态（金额 `0`），然后调用两次 `stake` 函数，并在每次调用后都进行断言，确认存储的金额被正确地依次更新为 `100` 和 `200`。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 0
[debug] 0
[debug] "User Added Successfully!"
[debug] "User Staked Successfully!"
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::StorageDemo::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过其全部单元测试**。在成功编译项目后，测试框架执行了 `StorageDemo` 模块中定义的唯一一个测试函数 `test_function`。日志中的 `[debug]` 输出清晰地展示了测试的完整流程：先是打印出初始状态 `0` 和 "User Added Successfully!" 消息，确认了**数据创建**的成功；随后打印出 "User Staked Successfully!" 消息，标志着后续的**数据修改**（stake）步骤也已执行。最终的 `[ PASS ]` 状态，结合 `Test result: OK` 的总结陈述，共同确认了该测试用例顺利完成，证明了你代码中对链上资源进行**创建、读取和多次修改**的完整逻辑流是完全正确的。

### 示例三

```rust
module net2dev_addr::StorageDemo {
    struct StakePool has key {
        amount: u64
    }

    fun add_user(account: &signer) {
        let amount: u64 = 0;
        move_to(account, StakePool { amount })
    }

    fun read_pool(account: address): u64 acquires StakePool {
        borrow_global<StakePool>(account).amount
    }

    fun stake(account: address) acquires StakePool {
        let entry = &mut borrow_global_mut<StakePool>(account).amount;
        *entry += 100;
    }

    fun unstake(account: address) acquires StakePool {
        let entry = &mut borrow_global_mut<StakePool>(account).amount;
        *entry = 0;
    }

    #[test_only]
    use std::debug::print;

    #[test_only]
    use std::signer;

    #[test_only]
    use std::string::utf8;

    #[test(user = @0x123)]
    fun test_function(user: signer) acquires StakePool {
        add_user(&user);
        assert!(borrow_global<StakePool>(@0x123).amount == 0, 0);
        assert!(read_pool(@0x123) == 0, 1);
        assert!(read_pool(signer::address_of(&user)) == 0, 2);
        print(&borrow_global<StakePool>(@0x123).amount);
        print(&read_pool(@0x123));
        print(&utf8(b"User Added Successfully!"));

        stake(@0x123);
        assert!(read_pool(@0x123) == 100, 3);
        stake(signer::address_of(&user));
        assert!(read_pool(signer::address_of(&user)) == 200, 4);
        print(&utf8(b"User Staked Successfully!"));

        unstake(@0x123);
        assert!(read_pool(@0x123) == 0, 5);
        unstake(signer::address_of(&user));
        assert!(read_pool(signer::address_of(&user)) == 0, 6);
        print(&utf8(b"User Unstaked Successfully!"));
    }
}


```

这段 Aptos Move 代码在 `StorageDemo` 模块中进一步完善了链上资源（resource）的生命周期管理，在原有的创建、读取和质押（增加金额）功能之上，**新增了一个 `unstake` 函数**。该函数同样利用 `borrow_global_mut` 获取对链上 `StakePool` 资源的可变引用，但其操作是**将 `amount` 字段直接重置为 0**，以此来模拟用户取回所有质押资金的“解押”操作。扩展后的单元测试则完整地验证了这一整套流程：从创建资源（`amount`为0），到两次质押使其逐步增加到 `200`，再到最终调用 `unstake` 函数使其回归到 `0`，并通过 `assert!` 在每一步都确认了链上状态的正确性。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 0
[debug] 0
[debug] "User Added Successfully!"
[debug] "User Staked Successfully!"
[debug] "User Unstaked Successfully!"
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::StorageDemo::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过其全部单元测试**。在成功编译项目后，测试框架执行了 `StorageDemo` 模块中定义的唯一一个测试函数 `test_function`。日志中的 `[debug]` 输出清晰地展示了测试成功执行了**创建、质押、解押**的完整流程，这一点由 "User Added Successfully!"、"User Staked Successfully!" 和 "User Unstaked Successfully!" 这三条消息得到确认。最终的 `[ PASS ]` 状态，结合 `Test result: OK` 的总结陈述，证明了测试中的所有 `assert!` 断言均已满足，验证了你代码中对链上资源进行**创建、多次修改、再到最终重置**的完整生命周期管理逻辑是完全正确的。

### 示例四

```rust
module net2dev_addr::StorageDemo {
    use std::signer;

    struct StakePool has key {
        amount: u64
    }

    fun add_user(account: &signer) {
        let amount: u64 = 0;
        move_to(account, StakePool { amount })
    }

    fun read_pool(account: address): u64 acquires StakePool {
        borrow_global<StakePool>(account).amount
    }

    fun stake(account: address) acquires StakePool {
        let entry = &mut borrow_global_mut<StakePool>(account).amount;
        *entry += 100;
    }

    fun unstake(account: address) acquires StakePool {
        let entry = &mut borrow_global_mut<StakePool>(account).amount;
        *entry = 0;
    }

    fun remove_user(account: &signer): u64 acquires StakePool {
        let entry = move_from<StakePool>(signer::address_of(account));
        let StakePool { amount } = entry;
        amount
    }

    fun confirm_user(account: address): bool {
        exists<StakePool>(account)
    }

    #[test_only]
    use std::debug::print;

    #[test_only]
    use std::string::utf8;

    #[test(user = @0x123)]
    fun test_function(user: signer) acquires StakePool {
        add_user(&user);
        assert!(borrow_global<StakePool>(@0x123).amount == 0, 0);
        assert!(read_pool(@0x123) == 0, 1);
        assert!(read_pool(signer::address_of(&user)) == 0, 2);
        print(&borrow_global<StakePool>(@0x123).amount);
        print(&read_pool(@0x123));
        print(&utf8(b"User Added Successfully!"));

        stake(@0x123);
        assert!(read_pool(@0x123) == 100, 3);
        stake(signer::address_of(&user));
        assert!(read_pool(signer::address_of(&user)) == 200, 4);
        print(&utf8(b"User Staked Successfully!"));

        unstake(@0x123);
        assert!(read_pool(@0x123) == 0, 5);
        unstake(signer::address_of(&user));
        assert!(read_pool(signer::address_of(&user)) == 0, 6);
        print(&utf8(b"User Unstaked Successfully!"));

        let amount = remove_user(&user);
        assert!(amount == 0, 7);
        assert!(!confirm_user(@0x123), 8);
        assert!(confirm_user(signer::address_of(&user)) == false, 9);
        print(&amount);
        print(&utf8(b"User Removed Successfully!"));
    }
}

```

这段 Aptos Move 代码在 `StorageDemo` 模块中完整地演示了一个链上资源**从创建到销毁的全生命周期（CRUD）**。在之前创建 (`add_user`)、读取 (`read_pool`) 和更新 (`stake`/`unstake`) 的功能基础上，新增了两个关键函数：`confirm_user` 函数使用 **`exists`** 指令来检查指定地址下是否存在资源；而 `remove_user` 函数则使用 **`move_from`** 指令来将资源从链上存储中**彻底移除**。最终，单元测试 `test_function` 完整地串联了所有操作：它首先创建、质押、解押资源，并在最后调用 `remove_user` 将其销毁，再通过 `confirm_user` 函数断言该资源已不再存在，从而完整地验证了 Move 语言中关于链上资源**增、删、改、查**的所有核心操作。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 0
[debug] 0
[debug] "User Added Successfully!"
[debug] "User Staked Successfully!"
[debug] "User Unstaked Successfully!"
[debug] 0
[debug] "User Removed Successfully!"
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::StorageDemo::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过了其全部单元测试**。在成功编译项目后，测试框架执行了 `StorageDemo` 模块中定义的唯一一个测试函数 `test_function`。日志中的 `[debug]` 输出清晰地展示了测试成功执行了**创建、质押、解押、并最终移除**的完整流程，这一点由 "User Added Successfully!" 直到 "User Removed Successfully!" 的四条连续消息得到确认。最终的 `[ PASS ]` 状态，结合 `Test result: OK` 的总结陈述，证明了测试中的所有 `assert!` 断言均已满足，验证了你代码中对链上资源进行**创建、修改、重置和销毁**的完整生命周期管理逻辑是完全正确的。

### 示例五

```rust
module net2dev_addr::StorageDemo {
    use std::signer;

    struct StakePool has key, drop {
        amount: u64
    }

    fun add_user(account: &signer) {
        let amount: u64 = 0;
        move_to(account, StakePool { amount })
    }

    fun read_pool(account: address): u64 acquires StakePool {
        borrow_global<StakePool>(account).amount
    }

    fun stake(account: address) acquires StakePool {
        let entry = &mut borrow_global_mut<StakePool>(account).amount;
        *entry += 100;
    }

    fun unstake(account: address) acquires StakePool {
        let entry = &mut borrow_global_mut<StakePool>(account).amount;
        *entry = 0;
    }

    fun remove_user(account: &signer) acquires StakePool {
        move_from<StakePool>(signer::address_of(account));

    }

    fun confirm_user(account: address): bool {
        exists<StakePool>(account)
    }

    #[test_only]
    use std::debug::print;

    #[test_only]
    use std::string::utf8;

    #[test(user = @0x123)]
    fun test_function(user: signer) acquires StakePool {
        add_user(&user);
        assert!(borrow_global<StakePool>(@0x123).amount == 0, 0);
        assert!(read_pool(@0x123) == 0, 1);
        assert!(read_pool(signer::address_of(&user)) == 0, 2);
        print(&borrow_global<StakePool>(@0x123).amount);
        print(&read_pool(@0x123));
        print(&utf8(b"User Added Successfully!"));

        stake(@0x123);
        assert!(read_pool(@0x123) == 100, 3);
        stake(signer::address_of(&user));
        assert!(read_pool(signer::address_of(&user)) == 200, 4);
        print(&utf8(b"User Staked Successfully!"));

        unstake(@0x123);
        assert!(read_pool(@0x123) == 0, 5);
        unstake(signer::address_of(&user));
        assert!(read_pool(signer::address_of(&user)) == 0, 6);
        print(&utf8(b"User Unstaked Successfully!"));

        remove_user(&user);
        assert!(!confirm_user(@0x123), 8);
        assert!(confirm_user(signer::address_of(&user)) == false, 9);
        print(&utf8(b"User Removed Successfully!"));
    }
}

```

这段 Aptos Move 代码通过 `StorageDemo` 模块，完整地演示了一个链上资源从**创建、读取、更新到最终销毁**的全生命周期。此版本的一个关键改动是在 `StakePool` 结构体上新增了 **`drop`** 能力，这使得资源在被移除后可以被安全地丢弃。因此，`remove_user` 函数的实现得以简化，它现在仅需调用 **`move_from`** 指令将资源从账户存储中移除即可，而无需再手动解构并返回其内部数据。最终的单元测试 `test_function` 完整地串联了所有操作：从创建资源，到反复质押和解押，再到最终调用 `remove_user` 将其销毁，并通过 `confirm_user` 函数断言资源已不存在，从而全面验证了 Move 语言中关于链上资源增、删、改、查的所有核心操作。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 0
[debug] 0
[debug] "User Added Successfully!"
[debug] "User Staked Successfully!"
[debug] "User Unstaked Successfully!"
[debug] "User Removed Successfully!"
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::StorageDemo::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过其全部单元测试**。在成功编译项目后，测试框架执行了 `StorageDemo` 模块中定义的唯一一个测试函数 `test_function`。日志中的 `[debug]` 输出清晰地展示了测试成功执行了**创建、质押、解押、并最终移除**的完整流程，这一点由 "User Added Successfully!" 直到 "User Removed Successfully!" 的四条连续消息得到确认。最终的 `[ PASS ]` 状态，结合 `Test result: OK` 的总结陈述，证明了测试中的所有 `assert!` 断言均已满足，验证了你代码中对链上资源进行**创建、修改、重置和销毁**的完整生命周期管理逻辑是完全正确的。

## 总结

恭喜你！跟随本篇详尽的实战教程，你已经完整地掌握了 Aptos Move 中链上资源（Resource）的**全生命周期管理**。我们一起学习并实践了 Move 语言中最核心的几个全局存储指令：

- `move_to`：将资源**存入**账户。
- `borrow_global` / `borrow_global_mut`：**读取**和**修改**已存在的资源。
- `move_from`：将资源从账户中**移除**。
- `exists`：检查资源**是否存在**。

这套以“资源”为中心、直接与用户账户绑定的存储模型，正是 Move 语言安全性的根基所在。现在，你已经具备了在 Aptos 链上自信地管理状态的能力，真正准备好去构建安全、强大的去中心化应用了。

## 参考

- <https://aptos.dev/zh>
- <https://github.com/aptos-labs>
- <https://petra.app/>
- <https://aptosfoundation.org/>
