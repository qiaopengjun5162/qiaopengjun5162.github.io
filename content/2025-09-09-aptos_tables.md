+++
title = "Aptos Move 实操：如何用 Tables 构建一个链上房产管理系统"
description = "Aptos Move 实操：如何用 Tables 构建一个链上房产管理系统"
date = 2025-09-09T02:49:22Z
[taxonomies]
categories = ["Web3", "Aptos", "Move"]
tags = ["Web3", "Aptos", "Move"]
+++

<!-- more -->

# **Aptos Move 实操：如何用 Tables 构建一个链上房产管理系统**

Aptos 独特的数据存储模型为其生态应用提供了坚实基础，而 **`Table`** 功能正是其中高效管理链上数据的关键。本文将通过一个完整的链上房产管理系统，深入探讨如何在 Aptos Move 中利用 **`Table`** 实现去中心化应用的增、查、改、删核心功能。

本文通过一个链上房产管理系统的示例，详细展示了如何使用 Aptos Move 的 **`Table`** 功能。我们创建了一个智能合约，让房产卖家能注册、发布房产，并对信息进行更新和删除。**`Table`** 结构作为去中心化数据库，确保了房产数据的安全透明和可扩展性，并通过单元测试验证了功能的可靠性。

## 实操

Aptos Move Tables

### 示例一

```rust
module net2dev_addr::tables_demo {
    use aptos_framework::table::{Self, Table};
    use std::signer;
    use std::string::String;

    struct Property has store, copy, drop {
        baths: u16,
        beds: u16,
        sqm: u16,
        phy_address: String,
        price: u64,
        available: bool
    }

    struct PropList has key {
        info: Table<u64, Property>,
        prop_id: u64
    }

    fun register_seller(account: &signer) {
        let init_property = PropList { info: table::new(), prop_id: 0 };
        move_to(account, init_property);
    }

    fun list_property(account: &signer, prop_info: Property) acquires PropList {
        let account_addr = signer::address_of(account);
        assert!(exists<PropList>(account_addr) == true, 101);
        let prop_list = borrow_global_mut<PropList>(account_addr);
        let new_id = prop_list.prop_id + 1;
        prop_list.info.upsert(new_id, prop_info);
        prop_list.prop_id = new_id;
    }

    fun read_property(
        account: &signer, prop_id: u64
    ): (u16, u16, u16, String, u64, bool) acquires PropList {
        let account_addr = signer::address_of(account);
        assert!(exists<PropList>(account_addr) == true, 101);
        let prop_list = borrow_global<PropList>(account_addr);
        let info = prop_list.info.borrow(prop_id);
        (info.baths, info.beds, info.sqm, info.phy_address, info.price, info.available)
    }

    #[test_only]
    use std::debug::print;

    #[test_only]
    use std::string::utf8;

    #[test(seller1 = @0x123, seller2 = @0x124)]
    fun test_function(seller1: signer, seller2: signer) acquires PropList {
        register_seller(&seller1);
        let prop_info = Property {
            baths: 2,
            beds: 3,
            sqm: 110,
            phy_address: utf8(b"Santa Marta, Colombia"),
            price: 120000,
            available: true
        };
        list_property(&seller1, prop_info);
        let (_, _, _, location, price, available) = read_property(&seller1, 1);
        assert!(location == utf8(b"Santa Marta, Colombia"));
        assert!(price == 120000);
        assert!(available);
        print(&location);
        print(&price);
        print(&available);

        register_seller(&seller2);
        let prop_info = Property {
            baths: 2,
            beds: 2,
            sqm: 150,
            phy_address: utf8(b"Dubai, UAE"),
            price: 350000,
            available: true
        };
        list_property(&seller2, prop_info);
        let (baths, beds, sqm, location, price, available) = read_property(&seller2, 1);
        assert!(baths == 2);
        assert!(beds == 2);
        assert!(sqm == 150);
        assert!(location == utf8(b"Dubai, UAE"));
        assert!(price == 350000);
        assert!(available);
        print(&baths);
        print(&beds);
        print(&sqm);
        print(&location);
        print(&price);
        print(&available);
    }
}


```

这段代码是一个 Aptos Move 智能合约，它的作用是让**房产卖家**能在区块链上登记和管理房产信息。你可以把它理解为一个简单的**链上房产列表应用**。

它主要做了三件事：

1. **注册卖家：** 任何想卖房的人都可以调用 `register_seller` 函数，在自己的账户下创建一个“房产清单” ( `PropList` )。
2. **发布房产：** 卖家可以调用 `list_property` 函数，将一套房子的详细信息（比如几卧几卫、面积、价格等）登记到自己的清单里，每套房产都会得到一个独一无二的 ID。
3. **查询房产：** 任何人都可以调用 `read_property` 函数，通过房产 ID 查看房子的具体信息。

代码中用到的 `Table` 就像一个高效的**数据库**，它能安全地存储多套房产信息。这确保了每套房产数据都只属于对应的卖家，并且这些信息都公开透明、不可篡改。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] "Santa Marta, Colombia"
[debug] 120000
[debug] true
[debug] 2
[debug] 2
[debug] 150
[debug] "Dubai, UAE"
[debug] 350000
[debug] true
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::tables_demo::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这段测试结果表明，你的 Aptos Move 智能合约代码在所有单元测试中**运行正常，没有发现任何问题**。

具体来说：

- **`Running Move unit tests`**: 启动单元测试。
- **`[debug]` 输出**: 打印出你代码中用于调试的变量值，比如 `"Santa Marta, Colombia"`, `120000`, `true` 等，这些都是你 `test_function` 中设置和读取的房产信息，说明数据读写都正确无误。
- **`[ PASS ] ...tables_demo::test_function`**: 表示你编写的 `test_function` 这个测试用例**通过了**。
- **`Test result: OK. Total tests: 1; passed: 1; failed: 0`**: 总结测试结果，显示总共运行了1个测试，1个通过，0个失败。这代表你的代码在测试覆盖范围内是**可靠的**。
- **`{ "Result": "Success" }`**: 最终结果为成功。

### 示例二

```rust
module net2dev_addr::tables_demo {
    use aptos_framework::table::{Self, Table};
    use std::signer;
    use std::string::String;
    use std::option::Option;

    /// PropertyList 资源
    const E_RESOURCE_NOT_FOUND: u64 = 101; // PropList资源不存在
    /// 房产ID不存在
    const E_PROPERTY_NOT_FOUND: u64 = 102; // 房产ID不存在

    struct Property has store, copy, drop {
        baths: u16,
        beds: u16,
        sqm: u16,
        phy_address: String,
        price: u64,
        available: bool
    }

    struct PropList has key {
        info: Table<u64, Property>,
        prop_id: u64
    }

    fun register_seller(account: &signer) {
        let init_property = PropList { info: table::new(), prop_id: 0 };
        move_to(account, init_property);
    }

    fun list_property(account: &signer, prop_info: Property) acquires PropList {
        let account_addr = signer::address_of(account);
        assert!(exists<PropList>(account_addr) == true, 101);
        let prop_list = borrow_global_mut<PropList>(account_addr);
        let new_id = prop_list.prop_id + 1;
        prop_list.info.upsert(new_id, prop_info);
        prop_list.prop_id = new_id;
    }

    fun read_property(
        account: &signer, prop_id: u64
    ): (u16, u16, u16, String, u64, bool) acquires PropList {
        let account_addr = signer::address_of(account);
        assert!(exists<PropList>(account_addr) == true, 101);
        let prop_list = borrow_global<PropList>(account_addr);
        let info = prop_list.info.borrow(prop_id);
        (info.baths, info.beds, info.sqm, info.phy_address, info.price, info.available)
    }

    fun update_property(
        account: &signer,
        prop_id: u64,
        baths: Option<u16>,
        beds: Option<u16>,
        sqm: Option<u16>,
        phy_address: Option<String>,
        price: Option<u64>,
        available: Option<bool>
    ) acquires PropList {
        let account_addr = signer::address_of(account);
        assert!(exists<PropList>(account_addr), E_RESOURCE_NOT_FOUND);
        let prop_list = borrow_global_mut<PropList>(account_addr);
        assert!(prop_list.info.contains(prop_id), E_PROPERTY_NOT_FOUND);
        let info = prop_list.info.borrow_mut(prop_id);

        if (baths.is_some()) {
            info.baths = baths.destroy_some()
        };

        if (beds.is_some()) {
            info.beds = beds.destroy_some()
        };

        if (sqm.is_some()) {
            info.sqm = sqm.destroy_some()
        };

        if (phy_address.is_some()) {
            info.phy_address = phy_address.destroy_some()
        };

        if (price.is_some()) {
            info.price = price.destroy_some()
        };

        if (available.is_some()) {
            info.available = available.destroy_some()
        };
    }

    fun delete_property(account: &signer, prop_id: u64) acquires PropList {
        let account_addr = signer::address_of(account);
        assert!(exists<PropList>(account_addr), E_RESOURCE_NOT_FOUND);
        let prop_list = borrow_global_mut<PropList>(account_addr);
        assert!(prop_list.info.contains(prop_id), E_PROPERTY_NOT_FOUND);
        prop_list.info.remove(prop_id);
    }

    #[test_only]
    use std::debug::print;

    #[test_only]
    use std::string::utf8;
    use std::option;

    #[test(seller1 = @0x123, seller2 = @0x124)]
    fun test_function(seller1: signer, seller2: signer) acquires PropList {
        // Test list_property and read_property for seller1
        register_seller(&seller1);
        let prop_info_s1 = Property {
            baths: 2,
            beds: 3,
            sqm: 110,
            phy_address: utf8(b"Santa Marta, Colombia"),
            price: 120000,
            available: true
        };
        list_property(&seller1, prop_info_s1);
        let (baths, beds, sqm, location, price, available) = read_property(&seller1, 1);
        assert!(baths == 2);
        assert!(beds == 3);
        assert!(sqm == 110);
        assert!(location == utf8(b"Santa Marta, Colombia"));
        assert!(price == 120000);
        assert!(available);
        print(&location);
        print(&price);
        print(&available);

        register_seller(&seller2);
        let prop_info = Property {
            baths: 2,
            beds: 2,
            sqm: 150,
            phy_address: utf8(b"Dubai, UAE"),
            price: 350000,
            available: true
        };
        list_property(&seller2, prop_info);
        let (baths, beds, sqm, location, price, available) = read_property(&seller2, 1);
        assert!(baths == 2);
        assert!(beds == 2);
        assert!(sqm == 150);
        assert!(location == utf8(b"Dubai, UAE"));
        assert!(price == 350000);
        assert!(available);
        print(&baths);
        print(&beds);
        print(&sqm);
        print(&location);
        print(&price);
        print(&available);

        // Test update_property for seller1
        update_property(
            &seller1,
            1,
            option::some(3),
            option::some(4),
            option::none(),
            option::none(),
            option::some(150000),
            option::some(false)
        );
        let (
            baths_updated,
            beds_updated,
            sqm_updated,
            location_updated,
            price_updated,
            available_updated
        ) = read_property(&seller1, 1);
        assert!(baths_updated == 3);
        assert!(beds_updated == 4);
        assert!(sqm_updated == 110); // Should remain unchanged
        assert!(location_updated == utf8(b"Santa Marta, Colombia")); // Should remain unchanged
        assert!(price_updated == 150000);
        assert!(available_updated == false);
        print(&baths_updated);
        print(&beds_updated);
        print(&price_updated);
        print(&available_updated);

        // Test delete_property for seller1
        delete_property(&seller1, 1);
        let prop_list = borrow_global<PropList>(signer::address_of(&seller1));
        assert!(prop_list.info.contains(1) == false, 102); // The property should no longer exist

    }
}

```

这段 Aptos Move 代码是一个**链上房产管理系统**的精简版。它利用 Aptos 的核心特性 **`Table` (表)**，为每位房产卖家提供了一个私有的、可扩展的、类似数据库的房产清单。

这使得房产信息（如面积、卧室数、价格等）可以直接存储在区块链上，确保了数据的**公开透明**和**不可篡改**。买家可以随时调用函数来查询房产信息，而只有卖家本人才能发布、更新和删除自己名下的房产，从而实现了**安全、去中心化**的房产信息管理。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] "Santa Marta, Colombia"
[debug] 120000
[debug] true
[debug] 2
[debug] 2
[debug] 150
[debug] "Dubai, UAE"
[debug] 350000
[debug] true
[debug] 3
[debug] 4
[debug] 150000
[debug] false
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::tables_demo::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}

```

这段测试结果表明，你的 Aptos Move 智能合约代码在所有单元测试中**运行正常，没有发现任何问题**。

具体来说，`[debug]` 输出显示了房产数据的创建和更新都完全符合预期。最初登记的房产信息（如“Santa Marta, Colombia”和120000的价格）被正确读取，随后更新后的信息（如3个浴室、4个卧室和150000的新价格）也被成功验证。

最终的`Test result: OK. Total tests: 1; passed: 1; failed: 0`则明确告诉你：你编写的唯一一个测试用例**完全通过**了，这意味着你智能合约的核心功能——从房产登记、信息读取、更新到删除——都运行得非常可靠。

## 总结

通过这个完整的链上房产管理系统示例，我们全面展示了 Aptos Move 中 **`Table`** 的核心应用。从基础的资源定义，到核心的增、查、改、删函数实现，我们不仅掌握了 **`Table`** 的实操方法，更理解了其在链上数据管理中的重要性。实践证明，**`Table`** 是构建高效、安全且可扩展的去中心化应用的关键。希望本文能为你打开 Aptos Move 开发的大门，激发你创造更多有趣的链上应用。

## 参考

- <https://github.com/aptos-labs/aptos-docs>
- <https://aptos.dev/zh>
- <https://github.com/aptos-labs/aptos-core/tree/main/aptos-move>
- <https://dorahacks.io/hackathon/aptos-ctrlmove-hackathon/detail>
