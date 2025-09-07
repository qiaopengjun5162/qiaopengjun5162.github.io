+++
title = "Aptos Move 深度实践：用嵌套数据结构构建链上金银储备系统"
description = "Aptos Move 深度实践：用嵌套数据结构构建链上金银储备系统"
date = 2025-09-07T10:13:01Z
[taxonomies]
categories = ["Web3", "Move", "Aptos"]
tags = ["Web3", "Move", "Aptos"]
+++

<!-- more -->

# **Aptos Move 深度实践：用嵌套数据结构构建链上金银储备系统**

随着区块链技术的快速发展，Aptos 作为新一代高性能公链，以其 **Move 编程语言**为开发者提供了安全、高效的智能合约开发环境。本文通过一个 **`metal_vault`** 模块的案例，展示如何利用 Aptos Move 的**嵌套数据结构**在区块链上实现多维度的金银储备管理，涵盖初始化、查询和更新功能，为开发者提供实操参考。

本文通过 **`metal_vault`** 模块示例，展示 Aptos Move 如何在区块链上管理金银储备。代码利用嵌套的 **`MetalReserves`** 和 **`MetalVault`** 结构体，按国家和重量（28g、57g、114g）存储余额，包含初始化、查询和更新功能。测试验证了模块的正确性，适合学习 Move 语言的开发者参考。

## 实操

Aptos Move Storing Data on the Blockchain

### 示例一

```rust
module net2dev_addr::metal_vault {
    use std::string::{String, utf8};
    use std::simple_map::{SimpleMap, Self};
    use std::debug::print;

    const GOLD: u64 = 0;
    const SILVER: u64 = 1;

    struct MetalReserves has store, copy, drop {
        g28: SimpleMap<String, u64>,
        g57: SimpleMap<String, u64>,
        g114: SimpleMap<String, u64>
    }

    struct MetalVault has key, copy, drop {
        gold: MetalReserves,
        silver: MetalReserves
    }

    fun init_client(account: &signer) {
        let metal_vault: SimpleMap<String, u64> = simple_map::create();
        metal_vault.add(utf8(b"UAE"), 0);
        metal_vault.add(utf8(b"MEX"), 0);
        metal_vault.add(utf8(b"COL"), 0);
        let init_balance = MetalReserves {
            g28: metal_vault,
            g57: metal_vault,
            g114: metal_vault
        };
        let vault = MetalVault { gold: init_balance, silver: init_balance };
        move_to(account, vault);
    }

    fun get_vault(account: address): (MetalReserves, MetalReserves) acquires MetalVault {
        (
            borrow_global<MetalVault>(account).gold,
            borrow_global<MetalVault>(account).silver
        )
    }

    #[test_only]
    use std::signer;

    #[test(client1 = @0x123)]
    fun test_function(client1: signer) acquires MetalVault {
        init_client(&client1);
        assert!(
            exists<MetalVault>(signer::address_of(&client1)) == true,
            0
        );

        let (gold, silver) = get_vault(signer::address_of(&client1));
        assert!(*gold.g28.borrow(&utf8(b"UAE")) == 0, 1);
        assert!(*silver.g28.borrow(&utf8(b"UAE")) == 0, 2);
        assert!(*gold.g57.borrow(&utf8(b"UAE")) == 0, 3);
        assert!(*silver.g57.borrow(&utf8(b"UAE")) == 0, 4);
        assert!(*gold.g114.borrow(&utf8(b"UAE")) == 0, 5);
        assert!(*silver.g114.borrow(&utf8(b"UAE")) == 0, 6);
        print(gold.g28.borrow(&utf8(b"UAE")));
        print(silver.g28.borrow(&utf8(b"UAE")));
    }
}

```

这段 Aptos Move 代码定义了一个用于管理名为 `MetalVault` 的、复杂的**链上嵌套数据结构**的系统。这个 `MetalVault` 被定义为一个**资源**（拥有 `key` 能力），使其可以直接存储在用户账户下。代码通过将 `SimpleMap` 嵌套在 `MetalReserves` 结构体中，再将 `MetalReserves` 嵌套在顶层的 `MetalVault` 结构体中，来演示**数据组合**的用法。`init_client` 函数展示了如何创建这个复杂结构体的实例，用默认值填充，并使用 `move_to` 将其发布到区块链上。随后的 `get_vault` 函数及对应的单元测试则演示了如何从链上存储中读取这些嵌套数据并验证其内容。

### 测试

```bash
➜ aptos move test --skip-fetch-latest-git-deps
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 0
[debug] 0
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::metal_vault::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这段测试结果显示，你运行了 `aptos move test` 命令来测试你的智能合约代码。测试框架首先加载了必要的依赖库（AptosFramework, AptosStdlib, MoveStdlib），然后编译了你的项目。在执行单元测试时，`test_function` 这个测试用例成功通过，它属于 `metal_vault` 模块。整个测试套件共包含1个测试，其中1个通过，0个失败，最终结果显示“成功”（Test result: OK.），表明你的代码在功能上符合预期。

### 示例二

```rust
module net2dev_addr::metal_vault {
    use std::string::{String, utf8};
    use std::simple_map::{SimpleMap, Self};
    use std::debug::print;

    const GOLD: u64 = 0;
    const SILVER: u64 = 1;

    struct MetalReserves has store, copy, drop {
        g28: SimpleMap<String, u64>,
        g57: SimpleMap<String, u64>,
        g114: SimpleMap<String, u64>
    }

    struct MetalVault has key, copy, drop {
        gold: MetalReserves,
        silver: MetalReserves
    }

    fun init_client(account: &signer) {
        let metal_vault: SimpleMap<String, u64> = simple_map::create();
        metal_vault.add(utf8(b"UAE"), 0);
        metal_vault.add(utf8(b"MEX"), 0);
        metal_vault.add(utf8(b"COL"), 0);
        let init_balance = MetalReserves {
            g28: metal_vault,
            g57: metal_vault,
            g114: metal_vault
        };
        let vault = MetalVault { gold: init_balance, silver: init_balance };
        move_to(account, vault);
    }

    fun get_vault(account: address): (MetalReserves, MetalReserves) acquires MetalVault {
        (
            borrow_global<MetalVault>(account).gold,
            borrow_global<MetalVault>(account).silver
        )
    }

    fun read_balances(asset_bal: SimpleMap<String, u64>, grams: String) {
        print(&grams);
        print(&utf8(b"UAE"));
        print(asset_bal.borrow(&utf8(b"UAE")));

        print(&utf8(b"MEX"));
        print(asset_bal.borrow(&utf8(b"MEX")));

        print(&utf8(b"COL"));
        print(asset_bal.borrow(&utf8(b"COL")));
    }

    fun get_client_balance(account: address, asset: u64) acquires MetalVault {
        let (gold, silver) = get_vault(account);
        if (asset == GOLD) {
            read_balances(gold.g28, utf8(b"28 Grams"));
            read_balances(gold.g57, utf8(b"57 Grams"));
            read_balances(gold.g114, utf8(b"114 Grams"));
        } else {
            read_balances(silver.g28, utf8(b"28 Grams"));
            read_balances(silver.g57, utf8(b"57 Grams"));
            read_balances(silver.g114, utf8(b"114 Grams"));
        }
    }

    #[test_only]
    use std::signer;

    #[test(client1 = @0x123)]
    fun test_function(client1: signer) acquires MetalVault {
        init_client(&client1);
        assert!(
            exists<MetalVault>(signer::address_of(&client1)) == true,
            0
        );

        let (gold, silver) = get_vault(signer::address_of(&client1));
        assert!(*gold.g28.borrow(&utf8(b"UAE")) == 0, 1);
        assert!(*silver.g28.borrow(&utf8(b"UAE")) == 0, 2);
        assert!(*gold.g57.borrow(&utf8(b"UAE")) == 0, 3);
        assert!(*silver.g57.borrow(&utf8(b"UAE")) == 0, 4);
        assert!(*gold.g114.borrow(&utf8(b"UAE")) == 0, 5);
        assert!(*silver.g114.borrow(&utf8(b"UAE")) == 0, 6);
        print(gold.g28.borrow(&utf8(b"UAE")));
        print(silver.g28.borrow(&utf8(b"UAE")));

        get_client_balance(signer::address_of(&client1), GOLD);
    }
}


```

这段 Aptos Move 代码定义了一个名为 **`MetalVault`** 的资源，用于在用户的链上账户中管理不同国家（阿联酋、墨西哥、哥伦比亚）的黄金和白银储备。该资源由两个 **`MetalReserves`** 结构体（分别代表黄金和白银）组成，每个结构体又嵌套了三个 **`SimpleMap`**，用来追踪不同重量（28克、57克、114克）的金属在不同国家的数量。`init_client` 函数负责为新用户账户初始化并发布这个复杂的资源，`get_vault` 和 `get_client_balance` 函数则提供了读取这些嵌套数据的方法。总的来说，这段代码通过嵌套数据结构展示了如何在 Aptos 链上高效地管理多维度的资产数据。

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
[debug] "28 Grams"
[debug] "UAE"
[debug] 0
[debug] "MEX"
[debug] 0
[debug] "COL"
[debug] 0
[debug] "57 Grams"
[debug] "UAE"
[debug] 0
[debug] "MEX"
[debug] 0
[debug] "COL"
[debug] 0
[debug] "114 Grams"
[debug] "UAE"
[debug] 0
[debug] "MEX"
[debug] 0
[debug] "COL"
[debug] 0
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::metal_vault::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这段 Aptos Move 测试结果表明，你的智能合约代码已成功通过了所有单元测试。结果中，`aptos move test` 命令首先编译了项目及其所有依赖项，然后执行了 `test_function` 这个测试用例。测试过程中，一系列的 **`[debug]`** 输出展示了合约内部的 `print` 函数被调用，它按顺序打印了不同克重（28g、57g、114g）的黄金储备在不同国家（阿联酋、墨西哥、哥伦比亚）的初始值为0。最终，测试用例成功通过（**`[ PASS ]`**），并且整个测试套件报告总共1个测试，通过了1个，失败了0个，确认了代码功能符合预期。

### 示例三

```rust
module net2dev_addr::metal_vault {
    use std::string::{String, utf8};
    use std::simple_map::{SimpleMap, Self};
    use std::debug::print;

    const GOLD: u64 = 0;
    const SILVER: u64 = 1;

    struct MetalReserves has store, copy, drop {
        g28: SimpleMap<String, u64>,
        g57: SimpleMap<String, u64>,
        g114: SimpleMap<String, u64>
    }

    struct MetalVault has key, copy, drop {
        gold: MetalReserves,
        silver: MetalReserves
    }

    fun init_client(account: &signer) {
        let metal_vault: SimpleMap<String, u64> = simple_map::create();
        metal_vault.add(utf8(b"UAE"), 0);
        metal_vault.add(utf8(b"MEX"), 0);
        metal_vault.add(utf8(b"COL"), 0);
        let init_balance = MetalReserves {
            g28: metal_vault,
            g57: metal_vault,
            g114: metal_vault
        };
        let vault = MetalVault { gold: init_balance, silver: init_balance };
        move_to(account, vault);
    }

    fun get_vault(account: address): (MetalReserves, MetalReserves) acquires MetalVault {
        (
            borrow_global<MetalVault>(account).gold,
            borrow_global<MetalVault>(account).silver
        )
    }

    fun read_balances(asset_bal: SimpleMap<String, u64>, grams: String) {
        print(&grams);
        print(&utf8(b"UAE"));
        print(asset_bal.borrow(&utf8(b"UAE")));

        print(&utf8(b"MEX"));
        print(asset_bal.borrow(&utf8(b"MEX")));

        print(&utf8(b"COL"));
        print(asset_bal.borrow(&utf8(b"COL")));
    }

    fun get_client_balance(account: address, asset: u64) acquires MetalVault {
        let (gold, silver) = get_vault(account);
        if (asset == GOLD) {
            read_balances(gold.g28, utf8(b"28 Grams"));
            read_balances(gold.g57, utf8(b"57 Grams"));
            read_balances(gold.g114, utf8(b"114 Grams"));
        } else {
            read_balances(silver.g28, utf8(b"28 Grams"));
            read_balances(silver.g57, utf8(b"57 Grams"));
            read_balances(silver.g114, utf8(b"114 Grams"));
        }
    }

    fun update_balance(
        metal: &mut MetalReserves,
        country: String,
        amount: u64,
        weight: u64
    ): bool {
        if (weight == 28) {
            let current = metal.g28.borrow_mut(&country);
            *current += amount;
            true
        } else if (weight == 57) {
            let current = metal.g57.borrow_mut(&country);
            *current += amount;
            true
        } else {
            let current = metal.g114.borrow_mut(&country);
            *current += amount;
            true
        }
    }

    fun add_metal(
        account: address,
        country: String,
        type: u64,
        amount: u64,
        weight: u64
    ): bool acquires MetalVault {
        if (type == GOLD) {
            let metal = &mut borrow_global_mut<MetalVault>(account).gold;
            update_balance(metal, country, amount, weight)
        } else {
            let metal = &mut borrow_global_mut<MetalVault>(account).silver;
            update_balance(metal, country, amount, weight)
        }
    }

    #[test_only]
    use std::signer;

    #[test(client1 = @0x123)]
    fun test_function(client1: signer) acquires MetalVault {
        init_client(&client1);
        assert!(
            exists<MetalVault>(signer::address_of(&client1)) == true,
            0
        );

        let (gold, silver) = get_vault(signer::address_of(&client1));
        assert!(*gold.g28.borrow(&utf8(b"UAE")) == 0, 1);
        assert!(*silver.g28.borrow(&utf8(b"UAE")) == 0, 2);
        assert!(*gold.g57.borrow(&utf8(b"UAE")) == 0, 3);
        assert!(*silver.g57.borrow(&utf8(b"UAE")) == 0, 4);
        assert!(*gold.g114.borrow(&utf8(b"UAE")) == 0, 5);
        assert!(*silver.g114.borrow(&utf8(b"UAE")) == 0, 6);
        print(gold.g28.borrow(&utf8(b"UAE")));
        print(silver.g28.borrow(&utf8(b"UAE")));

        add_metal(
            signer::address_of(&client1),
            utf8(b"UAE"),
            GOLD,
            100,
            28
        );
        add_metal(
            signer::address_of(&client1),
            utf8(b"COL"),
            GOLD,
            5,
            57
        );
        add_metal(
            signer::address_of(&client1),
            utf8(b"MEX"),
            GOLD,
            42,
            114
        );

        get_client_balance(signer::address_of(&client1), GOLD);

        add_metal(
            signer::address_of(&client1),
            utf8(b"MEX"),
            SILVER,
            88,
            28
        );
        add_metal(
            signer::address_of(&client1),
            utf8(b"UAE"),
            SILVER,
            66,
            57
        );
        add_metal(
            signer::address_of(&client1),
            utf8(b"COL"),
            SILVER,
            33,
            114
        );
        get_client_balance(signer::address_of(&client1), SILVER);
    }
}

```

这段 Aptos Move 代码定义了一个名为 **`MetalVault`** 的资源，用于在链上账户中管理黄金和白银储备。这个资源是一个复杂的嵌套数据结构：它包含两个 **`MetalReserves`** 结构体（分别代表黄金和白银），每个结构体又包含三个 **`SimpleMap`**，用来追踪不同重量（28g、57g、114g）的金属在不同国家（阿联酋、墨西哥、哥伦比亚）的存量。`init_client` 函数用于为新账户初始化这个资源，`add_metal` 函数则通过调用 `update_balance` 来安全地增加指定国家、类型和克重金属的储备，而 `get_client_balance` 等函数用于读取并验证这些数据。这段代码展示了如何利用 Move 语言的数据封装和模块化能力，在区块链上实现一个可交互的、多维度的资产管理系统。

以下是代码功能和结构的简要说明：

1. **数据结构**：

- `MetalReserves` 结构体存储三种重量的金或银储备（g28、g57、g114），每种重量使用 `SimpleMap<String, u64>` 记录不同国家的余额。
- `MetalVault` 结构体包含金（`gold`）和银（`silver`）的 `MetalReserves`，用于表示用户的金银储备总账。

2. **初始化 (`init_client`)**：

- 为用户账户初始化一个 `MetalVault`，为每个国家（UAE、MEX、COL）在金银的三个重量类别中设置初始余额为 0，并将 `MetalVault` 存储到用户地址。

3. **查询余额 (`get_vault`, `get_client_balance`, `read_balances`)**：

- `get_vault` 获取用户地址的 `MetalVault`，返回金银储备。
- `read_balances` 打印指定重量类别的余额（针对 UAE、MEX、COL）。
- `get_client_balance` 根据资产类型（金或银）打印所有重量类别的余额。

4. **更新余额 (`update_balance`, `add_metal`)**：

- `update_balance` 更新指定国家、重量类别的金或银余额，增加指定数量。
- `add_metal` 根据资产类型（金或银）调用 `update_balance` 更新对应储备。

5. **测试函数 (`test_function`)**：

- 测试初始化用户储备，验证初始余额为 0。
- 测试添加金银（例如，UAE 28克黄金增加100，MEX 28克白银增加88等），并通过 `get_client_balance` 打印结果。

整体而言，这段代码提供了一个简洁的去中心化金银储备管理系统，支持按国家和重量分类的余额查询和更新，适用于 Aptos 区块链环境。

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
[debug] "28 Grams"
[debug] "UAE"
[debug] 100
[debug] "MEX"
[debug] 0
[debug] "COL"
[debug] 0
[debug] "57 Grams"
[debug] "UAE"
[debug] 0
[debug] "MEX"
[debug] 0
[debug] "COL"
[debug] 5
[debug] "114 Grams"
[debug] "UAE"
[debug] 0
[debug] "MEX"
[debug] 42
[debug] "COL"
[debug] 0
[debug] "28 Grams"
[debug] "UAE"
[debug] 0
[debug] "MEX"
[debug] 88
[debug] "COL"
[debug] 0
[debug] "57 Grams"
[debug] "UAE"
[debug] 66
[debug] "MEX"
[debug] 0
[debug] "COL"
[debug] 0
[debug] "114 Grams"
[debug] "UAE"
[debug] 0
[debug] "MEX"
[debug] 0
[debug] "COL"
[debug] 33
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::metal_vault::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这段 Aptos Move 测试结果清晰地展示了你的智能合约代码已成功通过所有单元测试。结果中，`aptos move test` 命令首先编译并加载了项目依赖项，然后执行了 `test_function` 这个测试用例。测试过程中，一系列的 **`[debug]`** 输出详细记录了资产余额的变化，首先是黄金的初始值（0），接着是三次 `add_metal` 操作后黄金在不同国家（阿联酋、哥伦比亚、墨西哥）的克重（28g、57g、114g）对应的余额变化（100、5、42），然后是白银的初始值和更新后的余额（88、66、33）。最终，测试用例成功通过（**`[ PASS ]`**），并且整个测试套件报告总共有1个测试，通过了1个，失败了0个，这确认了你的代码逻辑（包括初始化和更新余额功能）都按预期正确执行。

### 示例四

```rust
module net2dev_addr::metal_vault {
    use std::string::{String, utf8};
    use std::simple_map::{SimpleMap, Self};
    use std::debug::print;

    const GOLD: u64 = 0;
    const SILVER: u64 = 1;

    struct MetalReserves has store, copy, drop {
        g28: SimpleMap<String, u64>,
        g57: SimpleMap<String, u64>,
        g114: SimpleMap<String, u64>
    }

    struct MetalVault has key, copy, drop {
        gold: MetalReserves,
        silver: MetalReserves
    }

    fun init_client(account: &signer) {
        let metal_vault: SimpleMap<String, u64> = simple_map::create();
        metal_vault.add(utf8(b"UAE"), 0);
        metal_vault.add(utf8(b"MEX"), 0);
        metal_vault.add(utf8(b"COL"), 0);
        let init_balance = MetalReserves {
            g28: metal_vault,
            g57: metal_vault,
            g114: metal_vault
        };
        let vault = MetalVault { gold: init_balance, silver: init_balance };
        move_to(account, vault);
    }

    fun get_vault(account: address): (MetalReserves, MetalReserves) acquires MetalVault {
        (
            borrow_global<MetalVault>(account).gold,
            borrow_global<MetalVault>(account).silver
        )
    }

    fun read_balances(asset_bal: SimpleMap<String, u64>, grams: String) {
        print(&grams);
        print(&utf8(b"UAE"));
        print(asset_bal.borrow(&utf8(b"UAE")));

        print(&utf8(b"MEX"));
        print(asset_bal.borrow(&utf8(b"MEX")));

        print(&utf8(b"COL"));
        print(asset_bal.borrow(&utf8(b"COL")));
    }

    fun get_client_balance(account: address, asset: u64) acquires MetalVault {
        let (gold, silver) = get_vault(account);
        if (asset == GOLD) {
            read_balances(gold.g28, utf8(b"28 Grams"));
            read_balances(gold.g57, utf8(b"57 Grams"));
            read_balances(gold.g114, utf8(b"114 Grams"));
        } else {
            read_balances(silver.g28, utf8(b"28 Grams"));
            read_balances(silver.g57, utf8(b"57 Grams"));
            read_balances(silver.g114, utf8(b"114 Grams"));
        }
    }

    fun update_balance(
        metal: &mut MetalReserves,
        country: String,
        amount: u64,
        weight: u64
    ): bool {
        if (weight == 28) {
            let current = metal.g28.borrow_mut(&country);
            *current += amount;
            true
        } else if (weight == 57) {
            let current = metal.g57.borrow_mut(&country);
            *current += amount;
            true
        } else {
            let current = metal.g114.borrow_mut(&country);
            *current += amount;
            true
        }
    }

    fun add_metal(
        account: address,
        country: String,
        type: u64,
        amount: u64,
        weight: u64
    ): bool acquires MetalVault {
        if (type == GOLD) {
            let metal = &mut borrow_global_mut<MetalVault>(account).gold;
            update_balance(metal, country, amount, weight)
        } else {
            let metal = &mut borrow_global_mut<MetalVault>(account).silver;
            update_balance(metal, country, amount, weight)
        }
    }

    #[test_only]
    use std::signer;

    #[test(client1 = @0x123, client2 = @0x456)]
    fun test_function(client1: signer, client2: signer) acquires MetalVault {
        init_client(&client1);
        init_client(&client2);
        assert!(
            exists<MetalVault>(signer::address_of(&client1)) == true,
            0
        );
        assert!(
            exists<MetalVault>(signer::address_of(&client2)) == true,
            0
        );

        let (gold, silver) = get_vault(signer::address_of(&client1));
        assert!(*gold.g28.borrow(&utf8(b"UAE")) == 0, 1);
        assert!(*silver.g28.borrow(&utf8(b"UAE")) == 0, 2);
        assert!(*gold.g57.borrow(&utf8(b"UAE")) == 0, 3);
        assert!(*silver.g57.borrow(&utf8(b"UAE")) == 0, 4);
        assert!(*gold.g114.borrow(&utf8(b"UAE")) == 0, 5);
        assert!(*silver.g114.borrow(&utf8(b"UAE")) == 0, 6);
        print(gold.g28.borrow(&utf8(b"UAE")));
        print(silver.g28.borrow(&utf8(b"UAE")));

        add_metal(
            signer::address_of(&client1),
            utf8(b"UAE"),
            GOLD,
            100,
            28
        );
        add_metal(
            signer::address_of(&client1),
            utf8(b"COL"),
            GOLD,
            5,
            57
        );
        add_metal(
            signer::address_of(&client1),
            utf8(b"MEX"),
            GOLD,
            42,
            114
        );

        get_client_balance(signer::address_of(&client1), GOLD);

        add_metal(
            signer::address_of(&client1),
            utf8(b"MEX"),
            SILVER,
            88,
            28
        );
        add_metal(
            signer::address_of(&client1),
            utf8(b"UAE"),
            SILVER,
            66,
            57
        );
        add_metal(
            signer::address_of(&client1),
            utf8(b"COL"),
            SILVER,
            33,
            114
        );
        get_client_balance(signer::address_of(&client1), SILVER);

        add_metal(
            signer::address_of(&client2),
            utf8(b"UAE"),
            SILVER,
            6,
            57
        );
        get_client_balance(signer::address_of(&client2), SILVER);
    }
}


```

这段 Aptos Move 代码实现了一个名为 `metal_vault` 的模块，用于在 Aptos 区块链上管理金银储备，按国家（UAE、MEX、COL）和重量（28克、57克、114克）分类存储。`MetalReserves` 结构体使用 `SimpleMap` 存储每个重量类别的余额，`MetalVault` 则包含金银的储备。`init_client` 初始化用户账户，为每个国家设置初始余额为 0。`get_vault` 和 `get_client_balance` 用于查询金银余额并打印，`read_balances` 辅助打印指定重量的国家余额。`update_balance` 和 `add_metal` 分别用于更新特定国家、重量和类型的余额。测试函数 `test_function` 初始化两个用户（client1 和 client2），验证初始余额为 0，为 client1 添加金银余额（如 UAE 28克黄金增加 100、MEX 28克白银增加 88），为 client2 添加 UAE 57克白银 6，并打印余额，验证模块功能正确执行。这段代码展示了如何利用 Move 语言的数据封装和模块化能力，在区块链上实现一个可交互的、多维度的资产管理系统。

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
[debug] "28 Grams"
[debug] "UAE"
[debug] 100
[debug] "MEX"
[debug] 0
[debug] "COL"
[debug] 0
[debug] "57 Grams"
[debug] "UAE"
[debug] 0
[debug] "MEX"
[debug] 0
[debug] "COL"
[debug] 5
[debug] "114 Grams"
[debug] "UAE"
[debug] 0
[debug] "MEX"
[debug] 42
[debug] "COL"
[debug] 0
[debug] "28 Grams"
[debug] "UAE"
[debug] 0
[debug] "MEX"
[debug] 88
[debug] "COL"
[debug] 0
[debug] "57 Grams"
[debug] "UAE"
[debug] 66
[debug] "MEX"
[debug] 0
[debug] "COL"
[debug] 0
[debug] "114 Grams"
[debug] "UAE"
[debug] 0
[debug] "MEX"
[debug] 0
[debug] "COL"
[debug] 33
[debug] "28 Grams"
[debug] "UAE"
[debug] 0
[debug] "MEX"
[debug] 0
[debug] "COL"
[debug] 0
[debug] "57 Grams"
[debug] "UAE"
[debug] 6
[debug] "MEX"
[debug] 0
[debug] "COL"
[debug] 0
[debug] "114 Grams"
[debug] "UAE"
[debug] 0
[debug] "MEX"
[debug] 0
[debug] "COL"
[debug] 0
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::metal_vault::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这段 Aptos Move 测试结果展示了 `metal_vault` 模块的 `test_function` 执行情况，测试成功通过（1 个测试，0 个失败）。测试初始化了两个用户（client1 和 client2），并验证其初始金银余额为 0（通过 `[debug] 0` 输出）。为 client1 添加金银余额，例如 UAE 28克黄金增 100、COL 57克黄金增 5、MEX 114克黄金增 42，以及 MEX 28克白银增 88、UAE 57克白银增 66、COL 114克白银增 33，`get_client_balance` 打印这些余额，显示为 `[debug] 100` 等。client2 仅添加 UAE 57克白银增 6，打印确认余额为 6，其他国家及重量类别为 0。测试验证了初始化、余额更新及查询功能正确，输出 `"Result": "Success"`。

## 总结

**`metal_vault`** 模块通过 Aptos Move 语言展示了区块链上复杂数据结构的设计与应用，实现了按国家（UAE、MEX、COL）和重量分类的金银储备管理。代码涵盖初始化 (**`init_client`**)、余额查询 (**`get_client_balance`**) 和更新 (**`add_metal`**) 功能，测试结果验证了其正确性。开发者可参考此案例，结合 Aptos 官方文档和社区资源，进一步探索 Move 语言在去中心化资产管理中的潜力。

## 参考

- <https://aptoslabs.com/blog>
- <https://dorahacks.io/hackathon/aptos-ctrlmove-hackathon/detail>
- <https://aptos.dev/zh>
- <https://github.com/aptos-labs>
- <https://aptoslabs.com/>
