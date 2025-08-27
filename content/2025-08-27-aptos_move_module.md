+++
title = "深入 Aptos Move：从`public`到`friend`，函数可见性详解"
description = "深入 Aptos Move：从`public`到`friend`，函数可见性详解"
date = 2025-08-27T03:00:00Z
[taxonomies]
categories = ["Web3", "Aptos", "Move"]
tags = ["Web3", "Move", "Aptos"]
+++

<!-- more -->

# 深入 Aptos Move：从`public`到`friend`，函数可见性详解

在 Aptos Move 智能合约开发中，精准控制函数的可见性是保障安全与效率的基石。然而，`public`、`public(friend)` 与 `#[view]` 之间的细微差别，以及它们对权限和 Gas 消耗的影响，常常让开发者感到困惑。本文将通过四个层层递进的代码实战和详尽的测试结果，带你从最基础的 `public` 函数出发，逐步深入 `friend` 机制的私有访问控制，并最终解析 `#[view]` 函数在零 Gas 查询中的应用。通过本教程，你将清晰地掌握 Move 语言的访问权限体系，为构建更健壮的智能合约打下坚实基础。

想搞懂Aptos Move函数的权限控制？本文用四个实战代码示例，带你逐一攻克 `public`、`public(friend)` 和 `#[view]` 可见性。你将学会如何用 `friend` 实现模块间私有调用，并理解 `#[view]` 在零 Gas 查询中的关键作用。这篇教程旨在助你编写出更安全、高效的Aptos智能合约，精准掌握安全边界。

## 实操

![image-20250826175002879](/images/image-20250826175002879.png)

### 示例一

```rust
address net2dev_addr {
module one {
    public fun get_value(): u64 {
        return 100
    }
}
module two {

    #[test_only]
    use std::debug::print;

    #[test]
    fun test_function() {
        let result = net2dev_addr::one::get_value();
        print(&result);
        assert!(result == 100, 0);
    }
}
module three {
    #[test_only]
    use std::debug::print;

    #[test]
    fun test_function() {
        let result = net2dev_addr::one::get_value();
        print(&result);
        assert!(result == 100, 0);
    }
}
}


```

这段 Aptos Move 代码在 `net2dev_addr` 地址下定义了三个独立的模块。**`one` 模块**提供了一个简单的公共函数 `get_value`，它总是返回数值 100。**`two` 模块**和 **`three` 模块**是两个完全相同的测试模块，它们唯一的目的就是调用 `one` 模块的 `get_value` 函数，然后使用 `assert!` 断言来验证返回的结果是否确实等于 100。这整体上展示了在同一个地址空间内，不同模块之间如何进行函数调用，并通过单元测试来确保代码逻辑的正确性。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 100
[debug] 100
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::three::test_function
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::two::test_function
Test result: OK. Total tests: 2; passed: 2; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明你的 Aptos Move 代码已经成功通过了所有的单元测试。测试框架首先编译了名为 `my-dapp` 的项目，然后分别执行了 `three` 模块和 `two` 模块中的 `test_function` 测试函数。日志中的两条 `[debug] 100` 信息证明了这两个测试都成功调用了 `one` 模块的函数并获取到了返回值 100。最终，`[ PASS ]` 状态和 `passed: 2; failed: 0` 的总结明确地显示，这两个测试函数中的 `assert` 断言都得到了满足，整个测试套件（包含两个测试用例）成功执行完毕，没有任何失败。

### 示例二

```rust
address net2dev_addr {
module one {
    friend net2dev_addr::two;

    public(friend) fun get_value(): u64 {
        return 100
    }
}
module two {

    #[test_only]
    use std::debug::print;

    #[test]
    fun test_function() {
        let result = net2dev_addr::one::get_value();
        print(&result);
        assert!(result == 100, 0);
    }
}
module three {
    #[test_only]
    use std::debug::print;

    #[test]
    fun test_function() {
        let result = net2dev_addr::one::get_value();
        print(&result);
        assert!(result == 100, 0);
    }
}
}


```

这段 Aptos Move 代码核心展示了 **`friend` (友元)可见性机制**，用于在模块间实现受控的私有访问。`one` 模块中的 `get_value` 函数被声明为 `public(friend)`，这意味着它不再对所有模块公开，而是**仅对被 `one` 模块明确声明为 `friend` 的模块可见**。代码中，`one` 模块只将 `two` 模块指定为其友元，因此 `two` 模块的测试函数可以合法地调用 `get_value`。然而，`three` 模块并未被声明为友元，所以它尝试调用 `get_value` 的行为是不被允许的，**这将导致编译时发生可见性错误**。这整体上演示了如何使用 `friend` 功能来创建更严格的模块边界，只在必要时向特定的、受信任的模块暴露内部函数。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
error: function `0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::one::get_value` cannot be called from function `0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::three::test_function` because module `0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::three` is not a `friend` of `0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::one`
   ┌─ /Users/qiaopengjun/Code/Aptos/move-tut/sources/sample3.move:5:24
   │
 5 │     public(friend) fun get_value(): u64 {
   │                        ^^^^^^^^^ callee
   ·
27 │         let result = net2dev_addr::one::get_value();
   │                      ------------------------------ called here

{
  "Error": "Unexpected error: Failed to run tests: exiting with env checking errors"
}

```

这个测试结果显示**编译失败**，而不是测试运行后的失败。错误信息明确指出，`three` 模块中的 `test_function` 尝试调用 `one` 模块的 `get_value` 函数，但这个调用被**拒绝**了。原因是 `get_value` 函数被声明为 `public(friend)`，只对 `one` 模块的友元（friend）可见，而 `three` 模块并**没有被声明为友元**。因此，由于违反了 `friend` 可见性规则，代码在静态检查阶段就无法通过，导致整个测试流程因编译环境检查错误而提前中止，没有任何一个测试被实际运行。

### 示例三

```rust
address net2dev_addr {
module one {
    friend net2dev_addr::two;
    friend net2dev_addr::three;

    public(friend) fun get_value(): u64 {
        return 100
    }
}
module two {

    #[test_only]
    use std::debug::print;

    #[test]
    fun test_function() {
        let result = net2dev_addr::one::get_value();
        print(&result);
        assert!(result == 100, 0);
    }
}
module three {
    #[test_only]
    use std::debug::print;

    #[test]
    fun test_function() {
        let result = net2dev_addr::one::get_value();
        print(&result);
        assert!(result == 100, 0);
    }
}
}


```

这段 Aptos Move 代码是对之前版本的修正，核心变化在于 `one` 模块现在**同时将 `two` 模块和 `three` 模块都声明为了自己的 `friend` (友元)**。这个改动使得 `one` 模块中 `public(friend)` 可见性的 `get_value` 函数，现在对 `two` 和 `three` 模块均开放了访问权限。因此，之前会导致编译错误的 `three` 模块调用 `get_value` 的行为现在变得完全合法。最终，这段代码将能够**成功编译**，并且其包含的两个单元测试都会**顺利运行并通过**，展示了如何通过友元列表向多个特定的、受信任的模块安全地开放内部功能。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 100
[debug] 100
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::three::test_function
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::two::test_function
Test result: OK. Total tests: 2; passed: 2; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，在你将 `three` 模块也添加为 `one` 模块的友元（friend）后，代码已能**成功编译并通过所有测试**。测试框架运行了 `two` 模块和 `three` 模块中的测试函数，两条 `[debug] 100` 日志证明了**现在这两个模块都可以合法地**调用 `get_value` 函数并正确获取到返回值 100。最终 `[ PASS ]` 的状态和 `passed: 2; failed: 0` 的总结确认了两个测试用例中的 `assert` 断言均已满足，从而验证了 `friend` 机制的修改已按预期生效。

### 示例四

```rust
address net2dev_addr {
module one {
    friend net2dev_addr::two;
    friend net2dev_addr::three;

    public(friend) fun get_value(): u64 {
        return 100
    }

    #[view]
    public fun get_price(): u64 {
        return 42
    }
}
module two {

    #[test_only]
    use std::debug::print;

    #[test]
    fun test_function() {
        let result = net2dev_addr::one::get_value();
        print(&result);
        assert!(result == 100, 0);
    }

    #[test]
    fun test_view() {
        let result = net2dev_addr::one::get_price();
        print(&result);
        assert!(result == 42, 0);
    }
}
module three {
    #[test_only]
    use std::debug::print;

    #[test]
    fun test_function() {
        let result = net2dev_addr::one::get_value();
        print(&result);
        assert!(result == 100, 0);
    }

    #[test]
    fun test_view() {
        let result = net2dev_addr::one::get_price();
        print(&result);
        assert!(result == 42, 0);
    }
}
}


```

这段 Aptos Move 代码在 `one` 模块中新增了一个带有 `#[view]` 属性的公共函数 `get_price`，它返回数值 42。`#[view]` 属性表明这是一个**只读函数**，调用它**不会产生链上交易或消耗 Gas 费**，因此可以被任何外部客户端或模块安全地用来查询数据。与此同时，`get_value` 函数仍然保持 `public(friend)` 的私有可见性，仅对友元模块 `two` 和 `three` 开放。因此，`two` 和 `three` 模块现在都新增了一个名为 `test_view` 的测试，用于验证它们既能调用私有的友元函数 `get_value`，也能调用完全公开的视图函数 `get_price`，展示了 Move 语言中不同函数可见性和功能的组合使用。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 100
[debug] 100
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::two::test_function
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::three::test_function
[debug] 42
[debug] 42
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::three::test_view
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::two::test_view
Test result: OK. Total tests: 4; passed: 4; failed: 0
{
  "Result": "Success"
}
```

这个测试结果显示你的项目已成功通过全部四个单元测试。测试框架首先运行了验证友元函数 `get_value` 的两个测试 (`test_function`)，从 `[debug] 100` 日志可以看出它们都成功获取了返回值 100。接着，框架又运行了验证视图函数 `get_price` 的两个新测试 (`test_view`)，`[debug] 42` 的日志证明了它们也正确获取了返回值 42。最终 `passed: 4; failed: 0` 的总结表明，无论是受限访问的友元函数还是公开的视图函数，其功能都已按预期通过了验证。

## 总结

通过这四个实战示例的演进，我们完整地探索了 Aptos Move 中函数可见性的核心机制。我们从最简单的 `public` 函数出发，理解了模块间的基础通信；接着，通过引入 `public(friend)`，我们掌握了如何在受信任的模块之间建立私有的“朋友圈”，并亲眼见证了非友元模块访问失败的编译时保护，这对于构建安全的内部逻辑至关重要；最后，我们引入了 `#[view]` 函数，明确了它作为“官方只读”声明在实现零 Gas 外部查询中的关键作用。

掌握这些可见性规则，不仅仅是学会了 Move 的语法，更是掌握了构建安全、高效、低成本智能合约的基石。希望这次的实操讲解能为你扫清障碍，让你在 Aptos 生态的开发之路上走得更稳、更远。

## 参考

- <https://dorahacks.io/hackathon/aptos-ctrlmove-hackathon/detail>
- <https://github.com/aptos-labs>
- <https://learn.aptoslabs.com/en/code-examples>
