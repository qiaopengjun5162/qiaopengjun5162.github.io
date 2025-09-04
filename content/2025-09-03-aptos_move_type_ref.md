+++
title = "Aptos Move 核心安全：`&` 与 `&mut` 引用机制详解"
description = "Aptos Move 核心安全：`&` 与 `&mut` 引用机制详解"
date = 2025-09-03T12:29:41Z
[taxonomies]
categories = ["Aptos", "Move", "Web3"]
tags = ["Web3", "Move", "Aptos"]
+++

<!-- more -->

# **Aptos Move 核心安全：`&` 与 `&mut` 引用机制详解**

Aptos Move 之所以被誉为最安全的智能合约语言之一，其根基就在于它独特的**所有权和引用模型**。理解这个模型，是掌握 Move 安全编程的重中之重。在开发中，我们常常需要访问或修改数据，却又不希望转移其所有权，这该如何实现呢？

答案就是 Move 语言的**引用 (`&`) 与借用 (`&mut`)** 机制。这是一种“临时访问许可”系统，也是 Aptos Move 的核心安全特性。

这篇实战教程将通过三个由浅入深的场景，带你彻底掌握这套机制的运作规则，让你真正理解 Move 是如何从语言层面杜绝各类常见的内存安全漏洞，构筑起坚实的安全壁垒。

这篇教程深入剖析 Aptos Move 的核心安全机制：引用与借用。通过三个实战案例，你将掌握不可变（&）与可变（&mut）引用的规则，理解如何在不转移所有权的情况下，安全、高效地访问和修改链上数据。

## 实操

Aptos Move Type References

### 示例一

```rust
module net2dev_addr::RefDemo {
    use std::debug::print;

    /*
    Immutable - Can't change value
    Mutable - Can change value

    */

    fun scenario_1() {
        let value_a = 10;
        let imm_ref: &u64 = &value_a;
        print(imm_ref);
    }

    #[test]
    fun test_function() {
        scenario_1();
    }
}

```

这段 Aptos Move 代码通过一个 `RefDemo` 模块，演示了**不可变引用 (immutable reference)** 的基本概念。模块中的 `scenario_1` 函数首先创建了一个值为 10 的局部变量 `value_a`，然后创建了一个指向它的不可变引用 `imm_ref` (`&u64`)。这个引用允许程序在不转移所有权的情况下，对原始数据进行**只读访问**——这一点通过成功地使用该引用打印出数值 `10` 得到了证明。整个演示被包裹在一个单元测试中执行，验证了这种基础的“借用”操作是 Move 中一个完全有效且正确的模式。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 10
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::RefDemo::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过了其单元测试**。在成功编译项目后，测试框架执行了 `RefDemo` 模块中定义的唯一一个测试函数 `test_function`。日志中的 `[debug] 10` 是 `scenario_1` 函数通过**不可变引用**成功读取并打印出的原始数值。随后的 `[ PASS ]` 状态确认了该测试用例顺利完成，没有任何错误发生。最后的 `Test result: OK` 总结陈述为这次测试画上了圆满的句号，证明了你代码中创建和使用不可变引用的逻辑是完全正确且有效的。

### 示例二

```rust
module net2dev_addr::RefDemo {
    use std::debug::print;

    /*
    Immutable - Can't change value
    Mutable - Can change value

    */

    // Non-Ref Type to Immutable Reference
    fun scenario_1() {
        let value_a = 10;
        let imm_ref: &u64 = &value_a;
        print(imm_ref);
    }

    // Non-Ref Type to Mutable Reference
    fun scenario_2() {
        let value_a = 10;
        let mut_ref: &mut u64 = &mut value_a;
        print(mut_ref);
        let imm_ref: &u64 = mut_ref;
        print(imm_ref);
        *mut_ref = 20;
        print(mut_ref);
    }

    #[test]
    fun test_scenario_1() {
        scenario_1();
    }

    #[test]
    fun test_scenario_2() {
        scenario_2();
    }
}


```

这段 Aptos Move 代码通过 `RefDemo` 模块，清晰地对比了**不可变引用 (`&`)** 与**可变引用 (`&mut`)** 的核心区别。`scenario_1` 函数演示了如何创建一个只读的不可变引用，它只能用来访问数据而不能修改。相比之下，`scenario_2` 函数则展示了可变引用的强大功能：它不仅可以被用来通过解引用（`*`）**修改原始变量的值**（从10变为20），还能在需要时被“降级”为一个临时的不可变引用。该模块通过两个独立的单元测试分别执行这两个场景，验证了这两种引用和借用模式在 Move 中的正确用法。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 10
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::RefDemo::test_scenario_1
[debug] 10
[debug] 10
[debug] 20
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::RefDemo::test_scenario_2
Test result: OK. Total tests: 2; passed: 2; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过其全部单元测试**。在成功编译项目后，测试框架执行了 `RefDemo` 模块中定义的 `test_scenario_1` 和 `test_scenario_2` 两个测试函数。日志中的 `[debug]` 输出清晰地展示了两个场景的执行过程：第一个 `[debug] 10` 对应 `scenario_1` 中通过不可变引用的成功读取；而 `10, 10, 20` 的序列则对应 `scenario_2`，它依次展示了通过可变引用读取初始值、再借用为不可变引用读取、以及最终成功修改值为20的全过程。两个测试均获得 `[ PASS ]` 状态，并且最终的摘要信息也确认了所有测试全部通过，证明了你代码中关于不可变和可变引用的操作逻辑是完全正确的。

### 示例三

```rust
module net2dev_addr::RefDemo {
    use std::debug::print;

    /*
    Immutable - Can't change value
    Mutable - Can change value

    */

    // Non-Ref Type to Immutable Reference
    fun scenario_1() {
        let value_a = 10;
        let imm_ref: &u64 = &value_a;
        print(imm_ref);
    }

    // Non-Ref Type to Mutable Reference
    fun scenario_2() {
        let value_a = 10;
        let mut_ref: &mut u64 = &mut value_a;
        print(mut_ref);
        let imm_ref: &u64 = mut_ref;
        print(imm_ref);
        *mut_ref = 20;
        print(mut_ref);
    }

    fun re_assign(value_a: &mut u64, value_b: &u64) {
        *value_a = *value_b;
        print(value_a);
    }

    fun scenario_3() {
        let value_a: &mut u64 = &mut 10;
        let value_b: &u64 = &20;
        re_assign(value_a, value_b);
    }

    #[test]
    fun test_scenario_1() {
        scenario_1();
    }

    #[test]
    fun test_scenario_2() {
        scenario_2();
    }

    #[test]
    fun test_scenario_3() {
        scenario_3();
    }
}


```

这段 Aptos Move 代码通过一个 `RefDemo` 模块，系统性地演示并对比了**不可变引用 (`&`)** 与**可变引用 (`&mut`)** 的多种用法。代码中的 `scenario_1` 展示了基础的只读引用；`scenario_2` 演示了如何利用可变引用修改数据，并从中再借用出不可变引用；而 `scenario_3` 则通过 `re_assign` 函数，展示了如何读取一个不可变引用的值并将其赋给一个可变引用指向的地址。该模块通过三个独立的单元测试分别执行并验证了这三种不同场景下的引用和借用操作，清晰地阐述了 Move 语言中安全、灵活的内存访问机制。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 10
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::RefDemo::test_scenario_1
[debug] 10
[debug] 10
[debug] 20
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::RefDemo::test_scenario_2
[debug] 20
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::RefDemo::test_scenario_3
Test result: OK. Total tests: 3; passed: 3; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过其全部单元测试**。在成功编译项目后，测试框架依次执行了 `RefDemo` 模块中定义的 `test_scenario_1`、`test_scenario_2` 和 `test_scenario_3` 三个测试函数。日志中的 `[debug]` 输出清晰地展示了每个场景的执行过程和结果：`scenario_1` 成功打印了 `10`，`scenario_2` 打印了 `10`、`10`、`20` 的变化过程，而 `scenario_3` 也成功打印出了最终被修改的 `20`。所有测试均获得 `[ PASS ]` 状态，并且最后的摘要信息也确认了全部三个测试都已通过，这证明了你代码中演示的关于不可变引用、可变引用以及跨引用赋值的各种操作都是完全正确且符合 Move 语言规范的。

## 总结

恭喜你！通过本篇三个场景的实战演练，你已经掌握了 **Aptos Move 的核心安全机制**之一：引用与借用。我们不仅理解了如何使用只读的不可变引用（`&`）和拥有独占修改权的可变引用（`&mut`），更重要的是，我们理解了其背后由编译器强制执行的严格规则。

这套严格的借用检查系统，正是 Move 语言安全性的基石。它在编译阶段就消除了数据竞争等重大安全隐患，让开发者能更有信心地构建可靠的应用。熟练运用引用，编写出既安全又高效（节省 Gas）的代码，是每一位专业 Aptos Move 开发者的必备技能。

## 参考

- <https://dorahacks.io/hackathon/aptos-ctrlmove-hackathon/detail>
- <https://learn.aptoslabs.com/en>
- <https://github.com/aptos-labs>
