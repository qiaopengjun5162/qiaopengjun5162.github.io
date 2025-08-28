+++
title = "Aptos Move 编程：`for`、`while` 与 `loop` 循环的实战详解"
description = "Aptos Move 编程：`for`、`while` 与 `loop` 循环的实战详解"
date = 2025-08-27T07:36:04Z
[taxonomies]
categories = ["Web3", "Aptos", "Move"]
tags = ["Web3", "Aptos", "Move"]
+++

<!-- more -->

# **Aptos Move 编程：`for`、`while` 与 `loop` 循环的实战详解**

在任何编程语言中，循环都是处理重复任务不可或缺的基础结构。对于构建高性能智能合约的 Aptos Move 语言而言，熟练掌握其循环机制更是每一位开发者的必修课。本文将摒弃复杂的理论，采用最直接的代码实战方式，逐一为你展示 Move 语言中 `for`、`while` 和 `loop` 这三种核心循环的使用方法。我们将通过编写功能完全相同的求和函数，对比它们的语法差异和实现逻辑，并通过单元测试来验证其正确性，确保你能在阅读后，清晰地理解并自如地在项目中运用这些关键的控制流语句。

本文通过代码实战，详细解析了 Aptos Move 语言中 `for`、`while` 和 `loop` 三种循环结构。文章使用统一的求和函数示例，清晰地对比了三种循环在语法和实现逻辑上的差异。每个示例都配有完整的单元测试及结果分析，旨在帮助开发者直观地理解并掌握 Move 智能合约开发中循环控制流的正确用法，为编写更复杂的合约逻辑打下坚实基础。

### 本文内容

- For Loop
- While Loop
- Loop

## 实操

### 示例一

```rust
module net2dev_addr::Sample4 {

    fun sample_for_loop(count: u64): u64 {
        let value = 0;
        for (i in 0..count) {
            value += i;
        };
        value
    }

    /*
    value = 0
    i = 0

    0 = 0 + 0
    0 = 0 + 1
    1 = 1 + 2
    3 = 3 + 3
    6 = 6 + 4
    10 = 10 + 5
    15 = 15 + 6
    21 = 21 + 7
    28 = 28 + 8
    36 = 36 + 9
    45 = 45 + 10
    */

    #[test_only]
    use std::debug::print;

    #[test]
    fun test_for_loop() {
        let value = sample_for_loop(10);
        print(&value);
    }
}


```

这段 Aptos Move 代码定义了一个名为 `sample_for_loop` 的函数，它接受一个数字 `count` 作为输入，并通过一个 `for` 循环计算从 0 到 `count-1` 所有整数的总和。代码中还包含一个名为 `test_for_loop` 的测试函数，它调用 `sample_for_loop` 并传入参数 10，然后将计算出的总和（即 0 到 9 的和，结果为 45）打印出来，以此来验证循环求和逻辑的正确性。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 45
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample4::test_for_loop
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这个测试结果显示名为 `test_for_loop` 的单元测试已成功通过。测试过程中，`sample_for_loop(10)` 函数被调用，并正确地计算出从 0 到 9 的总和。日志中的 `[debug] 45` 明确地打印出了这个预期的计算结果，随后的 `[ PASS ]` 状态和 `passed: 1; failed: 0` 的总结确认了函数的逻辑无误，整个测试成功完成。

### 示例二

```rust
module net2dev_addr::Sample4 {

    fun sample_for_loop(count: u64): u64 {
        let value = 0;
        for (i in 0..count) {
            value += i;
        };
        value
    }

    fun sample_while_loop(count: u64): u64 {
        let value = 0;
        let i = 0;
        while (i < count) {
            value += i;
            i += 1;
        };
        value
    }

    #[test_only]
    use std::debug::print;

    #[test]
    fun test_for_loop() {
        let value = sample_for_loop(10);
        print(&value);
    }

    #[test]
    fun test_while_loop() {
        let value = sample_while_loop(10);
        print(&value);
    }
}


```

这段 Aptos Move 代码在同一个模块中定义了两个功能完全相同的函数：`sample_for_loop` 和 `sample_while_loop`。它们都接受一个数字 `count` 作为输入，并计算从 0 到 `count-1` 所有整数的总和，唯一的区别在于前者使用了 `for` 循环，而后者使用了 `while` 循环来实现。代码还包含了两个对应的测试函数 `test_for_loop` 和 `test_while_loop`，它们分别调用上述函数并传入参数 10，以此来验证这两种不同循环写法的逻辑都能正确地计算出预期结果 45。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 45
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample4::test_for_loop
[debug] 45
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample4::test_while_loop
Test result: OK. Total tests: 2; passed: 2; failed: 0
{
  "Result": "Success"
}
```

这个测试结果显示项目中的两个单元测试均已成功通过。日志中的两条 `[debug] 45` 信息分别对应 `test_for_loop` 和 `test_while_loop` 的输出，证明了无论是使用 `for` 循环还是 `while` 循环，求和函数都正确地计算出了预期结果 45。最终 `passed: 2; failed: 0` 的总结确认了两种循环写法的逻辑都准确无误，整个测试套件成功执行。

### 示例三

```rust
module net2dev_addr::Sample4 {

    fun sample_for_loop(count: u64): u64 {
        let value = 0;
        for (i in 0..count) {
            value += i;
        };
        value
    }

    fun sample_while_loop(count: u64): u64 {
        let value = 0;
        let i = 0;
        while (i < count) {
            value += i;
            i += 1;
        };
        value
    }

    fun sample_loop(count: u64): u64 {
        let value = 0;
        let i = 0;
        loop {
            value += i;
            i += 1;
            if (i >= count) break;
        };
        value
    }

    #[test_only]
    use std::debug::print;

    #[test]
    fun test_for_loop() {
        let value = sample_for_loop(10);
        print(&value);
    }

    #[test]
    fun test_while_loop() {
        let value = sample_while_loop(10);
        print(&value);
    }

    #[test]
    fun test_loop() {
        let value = sample_loop(10);
        print(&value);
    }
}


```

这段 Aptos Move 代码在同一个模块中定义了三个功能完全相同的函数：`sample_for_loop`、`sample_while_loop` 和 `sample_loop`。它们都接受一个数字 `count` 作为输入，并计算从 0 到 `count-1` 所有整数的总和，唯一的区别在于它们分别使用了 **`for` 循环**、**`while` 循环**和**无限 `loop` 循环**加 `break` 条件这三种不同的语法来实现。代码还包含了三个对应的测试函数，用于分别调用这些循环函数并验证它们的计算逻辑都能正确得出预期结果。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 45
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample4::test_for_loop
[debug] 45
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample4::test_loop
[debug] 45
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample4::test_while_loop
Test result: OK. Total tests: 3; passed: 3; failed: 0
{
  "Result": "Success"
}
```

这个测试结果显示项目中的三个单元测试均已成功通过。日志中的三条 `[debug] 45` 信息分别对应 `for` 循环、无限 `loop` 循环和 `while` 循环的测试输出，证明了这三种不同的循环实现方式都正确地计算出了预期结果 45。最终 `passed: 3; failed: 0` 的总结确认了所有函数的逻辑都准确无误，整个测试套件成功执行。

## 总结

通过本文的三个逐步演进的示例，我们系统地学习并实践了 Aptos Move 语言提供的三种核心循环结构：简洁的 `for` 循环、经典的 `while` 循环，以及灵活的 `loop` 无限循环。每个示例都通过单元测试验证了其逻辑的正确性，证明了它们虽然语法不同，但都能完成相同的重复计算任务。掌握 `for`、`while` 和 `loop` 的适用场景与具体写法，是编写高效、可读性强的 Move 智能合约的基础。希望本次的实战讲解能帮助你彻底扫清在循环使用上的障碍，为未来构建更复杂的链上应用铺平道路。

## 参考

- <https://wgb5445.github.io/aptos-move-101/>
- <https://aptos-book.com/>
- <https://aptos.dev/zh/build/smart-contracts>
- <https://github.com/aptos-labs>
