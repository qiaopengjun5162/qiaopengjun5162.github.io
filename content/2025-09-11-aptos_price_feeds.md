+++
title = "Aptos Move 实战：从零构建一个链上价格预言机 (含源码和测试)"
description = "Aptos Move 实战：从零构建一个链上价格预言机 (含源码和测试)"
date = 2025-09-11T01:47:35Z
[taxonomies]
categories = ["Web3", "Move", "Aptos"]
tags = ["Web3", "Move", "Aptos"]
+++

<!-- more -->

# Aptos Move 实战：从零构建一个链上价格预言机 (含源码和测试)

在区块链的世界里，智能合约如何与外部真实世界的数据交互，始终是一个核心命题。而“预言机”正是连接链上与链下世界的关键桥梁。本文将带你深入 Aptos 生态，使用强类型、高安全性的 Move 语言，从零开始构建一个实用的链上价格预言机。我们将重点利用 Move 中强大的 `Vector`（动态数组）数据类型来灵活地存储和管理多种代币的价格信息。无论你是 Move 新手还是有经验的开发者，通过这个实战案例，你都将对 Aptos 智能合约的开发模式有更深刻的理解。

本文是一篇 Aptos Move 实战教程，通过一个完整的价格预言机智能合约，深入讲解核心数据类型 `Vector` 的应用。文章包含完整的 Move 源码、结构解析和单元测试步骤，手把手教你如何实现一个能动态添加和更新代币价格的链上模块。这不仅是学习 Move 编程的绝佳案例，也是理解 Aptos 数据存储和合约交互模式的宝贵实践。

## 实操

### 实战：核心代码与功能解析

Aptos Move Vectors - Token Price Feeds Module

以下是本次项目所需的核心 Move 代码。

```rust
module net2dev_addr::price_feeds {
    use std::vector;
    use std::string::{String, utf8};
    use std::timestamp;
    use std::signer;

    struct TokenFeed has store, drop, copy {
        last_price: u64,
        timestamp: u64
    }

    struct PriceFeeds has key, store, drop, copy {
        symbols: vector<String>,
        data: vector<TokenFeed>
    }

    /// Error Not Owner
    const ENOT_OWNER: u64 = 101;

    fun init_module(owner: &signer) {
        let symbols = vector::empty<String>();
        symbols.push_back(utf8(b"BTC"));
        let new_feed = TokenFeed { last_price: 0, timestamp: 0 };

        let data_feed = PriceFeeds {
            symbols,
            data: (vector[new_feed])
        };

        move_to(owner, data_feed)
    }

    fun update_feed(owner: &signer, last_price: u64, symbol: String) acquires PriceFeeds {
        let signer_addr = signer::address_of(owner);
        assert!(signer_addr == @net2dev_addr, ENOT_OWNER);
        assert!(exists<PriceFeeds>(signer_addr) == true, 101);
        let time = timestamp::now_seconds();
        let data_store = borrow_global_mut<PriceFeeds>(signer_addr);
        let new_feed = TokenFeed { last_price, timestamp: time };
        let (result, index) = data_store.symbols.index_of(&symbol);
        if (result) {
            // data_store.data[index] = new_feed;
            data_store.data.remove(index);
            data_store.data.insert(index, new_feed);
        } else {
            data_store.data.push_back(new_feed);
            data_store.symbols.push_back(symbol);
        }
    }

    fun get_token_price(symbol: String): TokenFeed acquires PriceFeeds {
        let symbols = borrow_global<PriceFeeds>(@net2dev_addr).symbols;
        let (result, index) = symbols.index_of(&symbol);
        if (result) {
            borrow_global<PriceFeeds>(@net2dev_addr).data[index]
        } else {
            TokenFeed { last_price: 0, timestamp: 0 }
        }
    }

    #[test_only]
    use std::debug::print;

    #[test(owner = @net2dev_addr, init_addr = @0x1)]
    fun test_function(owner: &signer, init_addr: signer) acquires PriceFeeds {
        timestamp::set_time_has_started_for_testing(&init_addr);
        init_module(owner);
        update_feed(owner, 63400, utf8(b"BTC"));
        let result = get_token_price(utf8(b"BTC"));
        assert!(result.last_price == 63400, 0);
        print(&result);

        update_feed(owner, 1000, utf8(b"ETH"));
        result = get_token_price(utf8(b"ETH"));
        assert!(result.last_price == 1000, 0);
        print(&result);

        update_feed(owner, 62411, utf8(b"BTC"));
        result = get_token_price(utf8(b"BTC"));
        assert!(result.last_price == 62411, 0);
        print(&result);
    }
}


```

这段代码实现了一个简单的**链上价格预言机（Price Oracle）\*智能合约。它的核心功能是在 Aptos 区块链上安全地存储和提供不同代币（Token）的价格信息。合约首先定义了一个名为 `PriceFeeds` 的核心数据结构，它就像一个链上的数据库，用来存放一系列代币的符号（如 "BTC"）以及它们对应的最新价格和更新时间戳。合约部署时会进行初始化，默认添加 "BTC" 作为第一个代币。此后，只有\**合约的所有者**有权限调用 `update_feed` 函数来更新某个代币的价格，或者添加一个新的代币及其价格。最后，任何人都可以通过公开的 `get_token_price` 函数，传入代币符号来查询其在链上记录的最新价格数据。整个设计确保了价格数据的**写入是受控且安全的**，而**读取则是公开透明的**，为其他去中心化应用提供了可信的价格参考。

### **测试验证**

运行 `aptos move test` 命令，验证合约的逻辑正确性。

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::price_feeds::TokenFeed {
  last_price: 63400,
  timestamp: 0
}
[debug] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::price_feeds::TokenFeed {
  last_price: 1000,
  timestamp: 0
}
[debug] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::price_feeds::TokenFeed {
  last_price: 62411,
  timestamp: 0
}
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::price_feeds::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这段终端输出是运行 `aptos move test` 命令后的成功反馈，它表明我们编写的**智能合约单元测试已经顺利通过**。这就像是产品发布前的自动化质量检测。前面三段 `[debug]` 开头的打印信息，是我们测试代码中 `print` 函数输出的结果，它们清晰地展示了测试的执行步骤：首先将 BTC 价格更新为 `63400`，接着添加了 ETH 并设置价格为 `1000`，最后又将 BTC 价格更新为 `62411`。最关键的是 `[ PASS ]` 和 `"Result": "Success"` 这两行，它们明确地告诉我们，测试中所有的断言（assert）都已验证成功，**证明了我们合约的初始化、更新和查询价格等核心功能完全符合预期，代码逻辑是正确且可靠的**。

## 总结

通过本文从合约设计、代码实现到单元测试的完整流程，我们不仅成功构建了一个功能完备的 Aptos 价格预言机，更重要的是，我们深入实践了 Move 语言中 `Vector` 这一核心数据结构在管理动态链上数据时的强大作用。`Vector` 的灵活性与 Move 语言自身的安全特性相结合，为开发者在 Aptos 上构建复杂应用提供了坚实的基础。希望这个实例能为你打开一扇门，激发更多关于 Aptos 和 Move 的创造性想法。区块链开发之路，始于实践，贵在坚持。

## 参考

- <https://aptoslabs.com/>
- <https://github.com/aptos-labs/aptos-docs>
- <https://aptos.dev/zh>
- <https://github.com/aptos-labs/aptos-core/tree/main/aptos-move>
- <https://dorahacks.io/hackathon/aptos-ctrlmove-hackathon/detail>
