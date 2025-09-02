+++
title = "Aptos Move DeFi 实战：从零构建流动性池兑换逻辑"
description = "Aptos Move DeFi 实战：从零构建流动性池兑换逻辑"
date = 2025-09-02T03:36:11Z
[taxonomies]
categories = ["Web3", "Move", "Aptos"]
tags = ["Web3", "Move", "Aptos"]
+++

<!-- more -->

# Aptos Move DeFi 实战：从零构建流动性池兑换逻辑

去中心化交易所（DEX）是 DeFi 生态的基石，而其核心正是流动性池背后的自动做市商（AMM）算法。对于有志于在 Aptos 上构建 DeFi 应用的开发者来说，亲手实现并验证一个兑换（Swap）功能，是理解其底层机制的最佳路径。

本文将摒弃复杂的理论，以最“实事求是”的方式，带你深入 Aptos Move 的开发实践。我们将从一个最基础的恒定乘积公式入手，一步步构建一个包含手续费的兑换计算函数，然后将其扩展为一个可管理多个交易对的模块化结构，并最终分析交易对价格产生的冲击。每一步，我们都将通过严格的单元测试来验证代码的准确性。

本文是一篇 Aptos Move DeFi 实战教程。你将从零开始，学习用常量和 `if/else` 实现一个包含手续费的 AMM 兑换算法，并逐步扩展到多池管理和价格影响分析，通过完整单元测试确保逻辑无误。

## 实操

Aptos Move Liquidity Pool Calculator

### 示例一

```rust
module net2dev_addr::Sample9 {
    /// Error code indicating that the provided amount is not enough for the swap.
    const E_NOT_ENOUGH: u64 = 0;

    const Pool1_n2dr: u64 = 312;
    const Pool1_usdt: u64 = 3201;

    fun calculate_swap(coin1: u64, coin2: u64, coin1_amount: u64): u64 {
        assert!(coin1_amount > 0, E_NOT_ENOUGH);

        let fee = coin1_amount * 5 / 100;
        let mix_supply = coin1 * coin2;
        let new_usdt = coin1 + coin1_amount;
        let new_n2dr = mix_supply / (new_usdt - fee);
        let receive = coin2 - new_n2dr;
        receive
    }

    #[test_only]
    use std::debug::print;

    #[test]
    fun test_function() {
        let swap_amount = 495; // USDT to swap
        let receive = calculate_swap(Pool1_usdt, Pool1_n2dr, swap_amount);
        print(&receive);
        assert!(receive == 41, 1);
    }

    /*

    Liquidity Pool

    Coin1 = 3201 USDT
    Coin2 = 312 N2DR

    495 USDT -> N2DR

    FORMULA with 5% fee

    Value1 = Apply a 5% fee to the USDT amount to be swapped.
    Fee: 495 * 5 / 100 = 24.75

    Value2 = Multiply both USDT and N2DR Supply.
    MixSupply: Coin1 * Coin2 = 998,712

    Value3 = Determine the new supply of USDT after the swap.
    NewUSDT = Coin1 + 495 = 3201 + 495 = 3696

    Value4 = Determine the new supply of N2DR after the swap.
    NewN2DR = MixSupply / (NewUSDT - fee) = 998,712 / (3696 - 24.75) = 271.5879458

    Value5 = Determine the amount of N2DRs to transfer to the user.
    Transfer = Coin2 - NewN2DR = 312 - 271.5879458 = 40.4120542

    */
}

```

这段 Aptos Move 代码通过一个名为 `Sample9` 的模块，演示了一个简化的去中心化交易所（DEX）中**流动性池的兑换计算**逻辑。其核心功能 `calculate_swap` 函数实现了一种**自动做市商（AMM）**的定价公式：它采用恒定乘积模型（`x * y = k`），在计算中扣除了 5% 的手续费，并最终算出用户用一种代币能够换取另一种代币的数量。该模块使用常量来模拟一个 USDT/N2DR 交易对的初始流动性状态，并通过一个单元测试来验证整个兑换算法，该测试模拟了一笔 495 USDT 的交易，并用 `assert!` 断言其兑换结果是否等于预期的 41 N2DR。

### 测试

```bash
 ➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 41
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample9::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}

```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过了其单元测试**。在成功编译项目后，测试框架执行了 `Sample9` 模块中定义的唯一一个测试函数 `test_function`。日志中的 `[debug] 41` 是 `calculate_swap` 函数在接收到测试参数后实际计算并返回的**最终兑换数量**。紧随其后的 `[ PASS ]` 状态确认了该测试用例顺利完成，这意味着代码中的 `assert!` 断言成功地验证了计算结果 `41` 与预期值完全一致。最后的 `Test result: OK` 总结陈述为这次测试画上了圆满的句号，证明了你合约中的兑换算法逻辑根据该测试场景是正确无误的。

### 示例二

```rust
module net2dev_addr::Sample9 {

    /// Error code indicating that the provided amount is not enough for the swap.
    const E_NOT_ENOUGH: u64 = 0;

    const N2DR: u64 = 1;
    const APT: u64 = 2;
    const WETH: u64 = 3;

    const Pool1_n2dr: u64 = 312;
    const Pool1_usdt: u64 = 3201;
    const N2DR_name: vector<u8> = b"N2DR Rewards";

    const Pool2_apt: u64 = 21500;
    const Pool2_usdt: u64 = 124700;
    const APT_name: vector<u8> = b"Aptos";

    const Pool3_weth: u64 = 1310;
    const Pool3_usdt: u64 = 2750000;
    const WETH_name: vector<u8> = b"Wrapped Ether";

    fun get_supply(coin_symbol: u64): (u64, u64, vector<u8>) {
        if (coin_symbol == N2DR) {
            (Pool1_usdt, Pool1_n2dr, N2DR_name)
        } else if (coin_symbol == APT) {
            (Pool2_usdt, Pool2_apt, APT_name)
        } else {
            (Pool3_usdt, Pool3_weth, WETH_name)
        }
    }

    // This applies a 5% fee to each swap tx.
    fun calculate_swap(coin1: u64, coin2: u64, coin1_amount: u64): u64 {
        assert!(coin1_amount > 0, E_NOT_ENOUGH);

        let fee = coin1_amount * 5 / 100;
        let mix_supply = coin1 * coin2;
        let new_usdt = coin1 + coin1_amount;
        let new_n2dr = mix_supply / (new_usdt - fee);
        let receive = coin2 - new_n2dr;
        receive
    }

    #[test_only]
    use std::debug::print;
    use std::string::utf8;

    #[test]
    fun test_function() {
        let swap_amount = 495; // USDT to swap
        let receive = calculate_swap(Pool1_usdt, Pool1_n2dr, swap_amount);
        print(&receive);
        assert!(receive == 41, 1);

        let (coin1, coin2, name) = get_supply(N2DR);
        print(&coin1);
        print(&coin2);

        assert!(coin1 == Pool1_usdt, 2);
        assert!(coin2 == Pool1_n2dr, 3);
        assert!(name == N2DR_name, 4);
        print(&utf8(b"Swap USDT for:"));
        print(&utf8(name));
        let result = calculate_swap(coin1, coin2, swap_amount);
        print(&result);
        assert!(result == receive, 5);

        let (coin1, coin2, name) = get_supply(APT);
        print(&coin1);
        print(&coin2);

        assert!(coin1 == Pool2_usdt, 6);
        assert!(coin2 == Pool2_apt, 7);
        assert!(name == APT_name, 8);
        print(&utf8(b"Swap USDT for:"));
        print(&utf8(name));
        let result = calculate_swap(coin1, coin2, swap_amount);
        print(&result);
        assert!(result == 81, 9);

        let (coin1, coin2, name) = get_supply(WETH);
        print(&coin1);
        print(&coin2);

        assert!(coin1 == Pool3_usdt, 10);
        assert!(coin2 == Pool3_weth, 11);
        assert!(name == WETH_name, 12);
        print(&utf8(b"Swap USDT for:"));
        print(&utf8(name));
        let result = calculate_swap(coin1, coin2, swap_amount);
        print(&result);
        assert!(result == 1, 13);
    }

    /*

    Liquidity Pool

    Coin1 = 3201 USDT
    Coin2 = 312 N2DR

    495 USDT -> N2DR

    FORMULA with 5% fee

    Value1 = Apply a 5% fee to the USDT amount to be swapped.
    Fee: 495 * 5 / 100 = 24.75

    Value2 = Multiply both USDT and N2DR Supply.
    MixSupply: Coin1 * Coin2 = 998,712

    Value3 = Determine the new supply of USDT after the swap.
    NewUSDT = Coin1 + 495 = 3201 + 495 = 3696

    Value4 = Determine the new supply of N2DR after the swap.
    NewN2DR = MixSupply / (NewUSDT - fee) = 998,712 / (3696 - 24.75) = 271.5879458

    Value5 = Determine the amount of N2DRs to transfer to the user.
    Transfer = Coin2 - NewN2DR = 312 - 271.5879458 = 40.4120542

    */
}

```

这段 Aptos Move 代码在前一个兑换计算示例的基础上进行了扩展，用于模拟一个**拥有多个流动性池的去中心化交易所 (DEX)**。该模块通过常量定义了三个独立的流动性池（分别是 USDT 与 N2DR、APT 和 WETH 的交易对），并引入了一个新的分派函数 `get_supply`，该函数能根据传入的代币标识返回对应池子的储备金数据。原有的 `calculate_swap` 函数被复用，以处理所有这些池子的兑-换计算。整个系统的正确性由一个全面的单元测试来验证，该测试**依次获取并验证每个池子的数据，然后对每个池子执行兑换计算并断言其输出结果的正确性**，从而展示了一种更模块化和可扩展的多交易对处理方法。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 41
[debug] 3201
[debug] 312
[debug] "Swap USDT for:"
[debug] "N2DR Rewards"
[debug] 41
[debug] 124700
[debug] 21500
[debug] "Swap USDT for:"
[debug] "Aptos"
[debug] 81
[debug] 2750000
[debug] 1310
[debug] "Swap USDT for:"
[debug] "Wrapped Ether"
[debug] 1
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample9::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过了其全面的单元测试**。在成功编译项目后，测试框架执行了 `Sample9` 模块中定义的唯一但包含了多个步骤的测试函数 `test_function`。日志中详细的 `[debug]` 输出，依次展示了针对 N2DR、Aptos 和 Wrapped Ether 这**三个不同流动性池**的验证过程：它首先打印出池子的储备金数据，然后打印出模拟兑换后计算出的结果（分别为 `41`、`81` 和 `1`）。最终的 `[ PASS ]` 状态确认了该测试函数顺利完成，意味着其内部所有 `assert!` 断言均已满足，既验证了 `get_supply` 函数能为每个池子返回正确数据，也验证了 `calculate_swap` 函数对每个池子的计算结果都准确无误。

### 示例三

```rust
module net2dev_addr::Sample9 {

    /// Error code indicating that the provided amount is not enough for the swap.
    const E_NOT_ENOUGH: u64 = 0;

    const N2DR: u64 = 1;
    const APT: u64 = 2;
    const WETH: u64 = 3;

    const Pool1_n2dr: u64 = 312;
    const Pool1_usdt: u64 = 3201;
    const N2DR_name: vector<u8> = b"N2DR Rewards";

    const Pool2_apt: u64 = 21500;
    const Pool2_usdt: u64 = 124700;
    const APT_name: vector<u8> = b"Aptos";

    const Pool3_weth: u64 = 1310;
    const Pool3_usdt: u64 = 2750000;
    const WETH_name: vector<u8> = b"Wrapped Ether";

    fun get_supply(coin_symbol: u64): (u64, u64, vector<u8>) {
        if (coin_symbol == N2DR) {
            (Pool1_usdt, Pool1_n2dr, N2DR_name)
        } else if (coin_symbol == APT) {
            (Pool2_usdt, Pool2_apt, APT_name)
        } else {
            (Pool3_usdt, Pool3_weth, WETH_name)
        }
    }

    fun token_price(coin1: u64, coin2: u64): u64 {
        assert!(coin1 > 0, E_NOT_ENOUGH);
        assert!(coin2 > 0, E_NOT_ENOUGH);
        coin1 / coin2
    }

    // This applies a 5% fee to each swap tx.
    fun calculate_swap(coin1: u64, coin2: u64, coin1_amount: u64): u64 {
        assert!(coin1_amount > 0, E_NOT_ENOUGH);

        let fee = coin1_amount * 5 / 100;
        let mix_supply = coin1 * coin2;
        let new_usdt = coin1 + coin1_amount;
        let new_n2dr = mix_supply / (new_usdt - fee);
        let receive = coin2 - new_n2dr;
        receive
    }

    #[test_only]
    use std::debug::print;
    #[test_only]
    use std::string::utf8;

    #[test]
    fun test_function() {
        let swap_amount = 495; // USDT to swap
        let receive = calculate_swap(Pool1_usdt, Pool1_n2dr, swap_amount);
        print(&receive);
        assert!(receive == 41, 1);

        let (coin1, coin2, name) = get_supply(N2DR);
        print(&coin1);
        print(&coin2);

        assert!(coin1 == Pool1_usdt, 2);
        assert!(coin2 == Pool1_n2dr, 3);
        assert!(name == N2DR_name, 4);
        print(&utf8(b"Swap USDT for:"));
        print(&utf8(name));
        let result = calculate_swap(coin1, coin2, swap_amount);
        print(&result);
        assert!(result == receive, 5);

        let (coin1, coin2, name) = get_supply(APT);
        print(&coin1);
        print(&coin2);

        assert!(coin1 == Pool2_usdt, 6);
        assert!(coin2 == Pool2_apt, 7);
        assert!(name == APT_name, 8);
        print(&utf8(b"Swap USDT for:"));
        print(&utf8(name));
        let result = calculate_swap(coin1, coin2, swap_amount);
        print(&result);
        assert!(result == 81, 9);

        let (coin1, coin2, name) = get_supply(WETH);
        print(&coin1);
        print(&coin2);

        assert!(coin1 == Pool3_usdt, 10);
        assert!(coin2 == Pool3_weth, 11);
        assert!(name == WETH_name, 12);
        print(&utf8(b"Swap USDT for:"));
        print(&utf8(name));
        let result = calculate_swap(coin1, coin2, swap_amount);
        print(&result);
        assert!(result == 1, 13);
    }

    #[test]
    fun test_function2() {
        let (coin1, coin2, name) = get_supply(N2DR);
        let swap_amount = 512; // USDT to swap
        print(&utf8(b"Swap USDT for:"));
        print(&utf8(name));

        print(&utf8(b"Token Price Before Swap:"));
        let price_before = token_price(coin1, coin2);
        print(&price_before);

        let result = calculate_swap(coin1, coin2, swap_amount);
        print(&result);

        print(&utf8(b"Token Price After Swap:"));
        let coin1_after = coin1 + swap_amount;
        let coin2_after = coin2 - result;
        let price_after = token_price(coin1_after, coin2_after);
        print(&price_after);

        assert!(price_after > price_before, 13);

        let (coin1, coin2, name) = get_supply(APT);
        let swap_amount = 2340; // USDT to swap
        print(&utf8(b"Swap USDT for:"));
        print(&utf8(name));

        print(&utf8(b"Token Price Before Swap:"));
        let price_before = token_price(coin1, coin2);
        print(&price_before);

        let result = calculate_swap(coin1, coin2, swap_amount);
        print(&utf8(b"Swap Result:"));
        print(&result);

        print(&utf8(b"Token Price After Swap:"));
        let coin1_after = coin1 + swap_amount;
        let coin2_after = coin2 - result;
        let price_after = token_price(coin1_after, coin2_after);
        print(&price_after);
    }

    /*

    Liquidity Pool

    Coin1 = 3201 USDT
    Coin2 = 312 N2DR

    495 USDT -> N2DR

    FORMULA with 5% fee

    Value1 = Apply a 5% fee to the USDT amount to be swapped.
    Fee: 495 * 5 / 100 = 24.75

    Value2 = Multiply both USDT and N2DR Supply.
    MixSupply: Coin1 * Coin2 = 998,712

    Value3 = Determine the new supply of USDT after the swap.
    NewUSDT = Coin1 + 495 = 3201 + 495 = 3696

    Value4 = Determine the new supply of N2DR after the swap.
    NewN2DR = MixSupply / (NewUSDT - fee) = 998,712 / (3696 - 24.75) = 271.5879458

    Value5 = Determine the amount of N2DRs to transfer to the user.
    Transfer = Coin2 - NewN2DR = 312 - 271.5879458 = 40.4120542

    */
}


```

这段 Aptos Move 代码定义了一个名为 `Sample9` 的模块，它模拟了一个功能有所增强的多池去中心化交易所（DEX）。在原有的 `calculate_swap` 和 `get_supply` 函数基础上，该模块**新增了一个简单的 `token_price` 价格计算函数**，用于通过基础除法来估算池中两种代币的相对价格。其单元测试也扩展为了两个独立的函数：第一个 `test_function` 负责验证在所有三个预定义流动性池（USDT 分别与 N2DR、APT 和 WETH 配对）中的兑换计算是否准确；而新增的 `test_function2` 则演示了更完整的兑换分析，它通过在模拟交易**前后分别调用 `token_price` 函数，来展示单笔交易对流动性池价格产生的冲击**，并断言价格如预期般发生了变化。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 41
[debug] 3201
[debug] 312
[debug] "Swap USDT for:"
[debug] "N2DR Rewards"
[debug] 41
[debug] 124700
[debug] 21500
[debug] "Swap USDT for:"
[debug] "Aptos"
[debug] 81
[debug] 2750000
[debug] 1310
[debug] "Swap USDT for:"
[debug] "Wrapped Ether"
[debug] 1
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample9::test_function
[debug] "Swap USDT for:"
[debug] "N2DR Rewards"
[debug] "Token Price Before Swap:"
[debug] 10
[debug] 42
[debug] "Token Price After Swap:"
[debug] 13
[debug] "Swap USDT for:"
[debug] "Aptos"
[debug] "Token Price Before Swap:"
[debug] 5
[debug] "Swap Result:"
[debug] 377
[debug] "Token Price After Swap:"
[debug] 6
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample9::test_function2
Test result: OK. Total tests: 2; passed: 2; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**完美地通过了其全部单元测试**。在成功编译项目后，测试框架执行了 `Sample9` 模块中定义的 `test_function` 和 `test_function2` 两个测试函数。日志中的 `[debug]` 输出清晰地展示了两个测试的详细过程：第一个 `test_function` 的输出验证了在三个不同流动性池中的**基础兑换计算**结果（`41`, `81`, `1`）均准确无误；而第二个 `test_function2` 的输出则更进一步，它打印出了在两次不同交易中，代币价格**交易前**（如 `10` 和 `5`）和**交易后**（如 `13` 和 `6`）的变化，其 `[ PASS ]` 状态证明了 `assert!` 断言成功确认了交易对池子价格产生了预期的冲击。最终 `Test result: OK` 的总结陈述，证明了你合约中所有的兑换和价格影响逻辑都已通过验证。

## 总结

恭喜你！通过本篇详尽的实战教程，你不仅成功地在 Aptos Move 中实现了一个功能完备的流动性池兑换逻辑，更重要的是，你掌握了从单一功能到模块化、可扩展系统演进的设计思路。

我们从一个基础的 AMM 公式出发，逐步构建了一个能够处理多个交易对的灵活模块，并学会了如何分析和测试交易行为对池子价格产生的具体影响。最终，测试日志中每一条 `[ PASS ]` 记录，都是对我们严谨逻辑的最好肯定。

现在，你已经具备了构建 DEX 核心算法的能力，并为在 Aptos DeFi 生态中创造更复杂的金融应用打下了坚实的基础。

## 参考

- <https://dorahacks.io/hackathon/aptos-ctrlmove-hackathon/detail>

- <https://github.com/aptos-labs/create-aptos-dapp/>

- <https://aptos.dev/>
