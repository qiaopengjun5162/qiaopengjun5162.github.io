+++
title = "Move 语言核心：布尔逻辑与地址类型的实战精解"
description = "Move 语言核心：布尔逻辑与地址类型的实战精解"
date = 2025-08-25T15:47:12Z
[taxonomies]
categories = ["Web3", "Move", "Aptos"]
tags = ["Web3", "Move", "Aptos"]
+++

<!-- more -->

# Move 语言核心：布尔逻辑与地址类型的实战精解

在掌握了 Aptos Move 项目的基本搭建流程后，下一步便是深入理解语言的核心——数据类型。在所有类型中，布尔（`bool`）和地址（`address`）无疑是构建智能合约逻辑的基石：前者构成了所有条件判断、权限检查的骨架，而后者则是区块链世界中识别用户与合约的唯一身份。

本文将通过一个完整且可测试的 `Sample2` 模块，带你深入实战。我们不仅会学习 `bool` 和 `address` 的基本用法，还将探索如何编写返回多个值的函数、如何使用常量，以及 Move 语言中至关重要的部分——如何通过单元测试（`#[test]`）来确保每一行逻辑都如你所愿地精确运行。

本文通过一个 Move 实例，深入讲解布尔（bool）与地址（address）核心类型。内容涵盖条件逻辑、多返回值处理（元组），并展示如何通过编写单元测试来验证函数行为，是初学者掌握 Move 编程基础的绝佳实战。

## 实操

```rust
module net2dev_addr::Sample2 {
    const MY_ADDR: address = @net2dev_addr;

    fun confirm_value(number: u64): bool {
        number > 0
    }

    fun confirm_value2(choice: bool): u64 {
        if (choice) { 1 }
        else { 0 }
    }

    fun confirm_value3(choice: bool): (u64, bool) {
        if (choice) {
            (1, choice)
        } else {
            (0, choice)
        }
    }

    #[test_only]
    use std::debug::print;

    #[test]
    fun test_function() {
        let std_addr: address = @std;
        print(&std_addr);
        let my_addr: address = MY_ADDR;
        print(&my_addr);
    }

    #[test]
    fun test_confirm_value() {
        print(&confirm_value(1));
        print(&confirm_value(0));

        assert!(confirm_value(1), 1);
        assert!(!confirm_value(0), 2);
    }

    #[test]
    fun test_confirm_value2() {
        print(&confirm_value2(true));
        print(&confirm_value2(false));

        assert!(confirm_value2(true) == 1, 1);
        assert!(confirm_value2(false) == 0, 2);
    }

    #[test]
    fun test_confirm_value3() {
        let (a, b) = confirm_value3(true);
        print(&a);
        print(&b);
        let (c, d) = confirm_value3(false);
        print(&c);
        print(&d);

        assert!(a == 1, 1);
        assert!(b, 2);
        assert!(c == 0, 3);
        assert!(!d, 4);
    }
}


```

这段 Move 代码定义了一个名为 `Sample2` 的简单模块，其主要目的是用于功能演示和单元测试。模块内包含了几个内部辅助函数，用于执行基础的条件逻辑：`confirm_value` 函数检查一个数字是否为正数，`confirm_value2` 函数将一个布尔值转换为 `u64` 类型的整数（1 或 0），而 `confirm_value3` 函数则根据输入的布尔值返回一个包含多个值的元组（tuple）。该模块的全部功能都通过一系列全面的单元测试（`#[test]`）来进行验证，这些测试不仅确保了辅助函数的逻辑正确性，同时也展示了 Move 语言的一些基本概念，例如如何使用地址常量以及如何对元组返回值进行解构赋值。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] true
[debug] false
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample2::test_confirm_value
[debug] 1
[debug] 0
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample2::test_confirm_value2
[debug] 1
[debug] true
[debug] 0
[debug] false
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample2::test_confirm_value3
[debug] @0x1
[debug] @0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample2::test_function
Test result: OK. Total tests: 4; passed: 4; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，`my-dapp` 项目已成功通过了其所有的单元测试。整个流程首先自动完成了项目的编译，然后执行了 `Sample2` 模块中定义的全部四个测试函数。每一条带有 `[ PASS ]` 标记的记录都确认了一个测试用例的成功通过，意味着其内部所有的 `assert!` 断言都得到了满足。日志中穿插的 `[debug]` 行是在测试执行过程中由代码里的 `print` 函数输出的调试信息，它们清晰地展示了每个测试函数内部验证的实际值（如 `true`, `false`, `1`, `0` 以及账户地址）。最后，`Test result: OK. Total tests: 4; passed: 4; failed: 0` 的总结明确指出，所有四个测试全部通过，无一失败，证明了合约当前的功能逻辑符合预期。

## 总结

恭喜你，通过本篇文章的实战演练，你不仅掌握了 `bool` 和 `address` 两种 Move 核心数据类型的用法，更重要的是，你亲身体验了 Move 语言以安全为本的设计哲学。

我们学习了如何构建返回条件结果、转换类型乃至返回多个值（元组）的函数。但最有价值的收获，是理解了通过编写单元测试（`#[test]`）来验证代码行为的重要性。日志中清晰的 `[ PASS ]` 记录，就是我们代码正确性的最佳证明。这种“测试驱动”的思维，是编写可靠智能合约的关键。

现在，你已经打下了坚实的基础，下一步就可以将这些基础类型组合起来，构建更复杂的数据结构（`struct`），从而开启创造真正应用的大门。

## 参考

- <https://github.com/aptos-labs>
- <https://aptos.dev/zh/network/faucet>
- <https://aptos.dev/zh/build/get-started>
