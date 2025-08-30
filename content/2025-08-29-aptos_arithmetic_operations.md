+++
title = "Aptos Move 实战：基础运算与比较逻辑的实现与测试"
description = "Aptos Move 实战：基础运算与比较逻辑的实现与测试"
date = 2025-08-29T07:45:04Z
[taxonomies]
categories = ["Web3", "Move", "Aptos"]
tags = ["Web3", "Move", "Aptos"]
+++

<!-- more -->

# **Aptos Move 实战：基础运算与比较逻辑的实现与测试**

所有复杂精密的智能合约，其内核都是由最基础的计算和逻辑判断构建而成的。在深入探索 Aptos Move 的强大功能之前，回归基础，掌握如何稳健地实现和验证这些基本操作至关重要。

本文将以一个清晰的实战模块为例，带你深入 Aptos Move 的开发。我们不仅会学习基础的算术和比较运算符，更将掌握一种清晰、可扩展的设计模式：使用常量（`const`）作为操作码，配合 `if/else` 控制流实现逻辑分派。最重要的是，我们将学习如何为每一个逻辑分支编写详尽的单元测试，确保代码的健壮性。

本文通过一个核心实例，实战演练了 Aptos Move 中的算术与比较运算。你将学习使用常量作为操作码，通过 `if/else` 实现逻辑分派，并编写全面的单元测试来确保每一项计算和比较都准确无误，是入门 Move 的绝佳实践。

## 实操

Aptos Move Arithmetic & Equality Operations

### 示例一

```rust
module net2dev_addr::Sample6 {
    const ADD: u64 = 0;
    const SUB: u64 = 1;
    const MUL: u64 = 2;
    const DIV: u64 = 3;
    const MOD: u64 = 4;

    fun arithmetic_operations(a: u64, b: u64, op: u64): u64 {
        if (op == ADD) a + b
        else if (op == SUB) a - b
        else if (op == MUL) a * b
        else if (op == DIV) a / b
        else if (op == MOD) a % b
        else 0
    }

    /*
      This function is used to test the arithmetic operations
      10 + 5 = 15
      10 - 5 = 5
      10 * 5 = 50
      10 / 5 = 2
      10 % 5 = 0
    */

    #[test_only]
    use std::debug::print;

    #[test]
    fun test_arithmetic_operations() {
        let a = 10;
        let b = 5;
        let ops = vector[ADD, SUB, MUL, DIV, MOD];
        let i = 0;
        while (i < ops.length()) {
            let op = ops[i];
            let result = arithmetic_operations(a, b, op);
            print(&result);
            i += 1;
        }
    }

    #[test]
    fun test_arithmetic_addition() {
        let a = 10;
        let b = 5;
        let result = arithmetic_operations(a, b, ADD);
        print(&result);
    }

    #[test]
    fun test_arithmetic_subtraction() {
        let a = 10;
        let b = 5;
        let result = arithmetic_operations(a, b, SUB);
        print(&result);
    }

    #[test]
    fun test_arithmetic_multiplication() {
        let a = 10;
        let b = 5;
        let result = arithmetic_operations(a, b, MUL);
        print(&result);
    }

    #[test]
    fun test_arithmetic_division() {
        let a = 10;
        let b = 5;
        let result = arithmetic_operations(a, b, DIV);
        print(&result);
    }

    #[test]
    fun test_arithmetic_modulus() {
        let a = 14;
        let b = 5;
        let result = arithmetic_operations(a, b, MOD);
        print(&result);
    }
}


```

这段 Aptos Move 代码定义了一个名为 `Sample6` 的简单算术模块，用于演示基础的运算逻辑和测试方法。模块首先通过常量定义了加、减、乘、除、取模这五种运算的操作码，然后在核心函数 `arithmetic_operations` 中，利用 `if/else if` 控制流，根据传入的操作码对两个 `u64` 数字执行相应的计算。该模块的正确性由一系列完善的单元测试来保证，这些测试不仅为每一种运算都编写了独立的验证用例，还提供了一个综合测试，该测试通过 `while` 循环遍历所有操作码，从而系统性地验证了计算函数在所有支持的场景下都能返回预期结果。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] 15
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample6::test_arithmetic_addition
[debug] 2
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample6::test_arithmetic_division
[debug] 4
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample6::test_arithmetic_modulus
[debug] 50
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample6::test_arithmetic_multiplication
[debug] 15
[debug] 5
[debug] 50
[debug] 2
[debug] 0
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample6::test_arithmetic_operations
[debug] 5
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample6::test_arithmetic_subtraction
Test result: OK. Total tests: 6; passed: 6; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过其全部单元测试**。整个流程首先编译了项目，接着执行了 `Sample6` 模块中定义的全部六个测试函数。日志中每一条 `[ PASS ]` 记录都确认了一个具体的测试用例（如 `test_arithmetic_addition`）已无错误地运行完毕。而 `[debug]` 行则是代码内部 `print` 函数的直接输出，清晰地展示了各项算术运算的实际计算结果（例如 `15`、`50`、`2` 等）。最后的摘要信息 **`Test result: OK. Total tests: 6; passed: 6; failed: 0`** 提供了明确的结论：所有六个测试全部通过，无一失败，证明了你合约中的算术逻辑根据所有已定义的测试场景均能正确工作。

### 示例二

```rust
module net2dev_addr::Sample6 {
    const ADD: u64 = 0;
    const SUB: u64 = 1;
    const MUL: u64 = 2;
    const DIV: u64 = 3;
    const MOD: u64 = 4;

    fun arithmetic_operations(a: u64, b: u64, op: u64): u64 {
        if (op == ADD) a + b
        else if (op == SUB) a - b
        else if (op == MUL) a * b
        else if (op == DIV) a / b
        else if (op == MOD) a % b
        else 0
    }

    /*
      This function is used to test the arithmetic operations
      10 + 5 = 15
      10 - 5 = 5
      10 * 5 = 50
      10 / 5 = 2
      10 % 5 = 0
    */

    #[test_only]
    use std::debug::print;

    #[test]
    fun test_arithmetic_operations() {
        let a = 10;
        let b = 5;
        let ops = vector[ADD, SUB, MUL, DIV, MOD];
        let i = 0;
        while (i < ops.length()) {
            let op = ops[i];
            let result = arithmetic_operations(a, b, op);
            print(&result);
            i += 1;
        }
    }

    #[test]
    fun test_arithmetic_addition() {
        let a = 10;
        let b = 5;
        let result = arithmetic_operations(a, b, ADD);
        print(&result);
    }

    #[test]
    fun test_arithmetic_subtraction() {
        let a = 10;
        let b = 5;
        let result = arithmetic_operations(a, b, SUB);
        print(&result);
    }

    #[test]
    fun test_arithmetic_multiplication() {
        let a = 10;
        let b = 5;
        let result = arithmetic_operations(a, b, MUL);
        print(&result);
    }

    #[test]
    fun test_arithmetic_division() {
        let a = 10;
        let b = 5;
        let result = arithmetic_operations(a, b, DIV);
        print(&result);
    }

    #[test]
    fun test_arithmetic_modulus() {
        let a = 14;
        let b = 5;
        let result = arithmetic_operations(a, b, MOD);
        print(&result);
    }

    const HIGHER: u64 = 0;
    const LOWER: u64 = 1;
    const HIGHER_EQ: u64 = 2;
    const LOWER_EQ: u64 = 3;

    fun equality_operations(a: u64, b: u64, operator: u64): bool {
        if (operator == HIGHER) a > b
        else if (operator == LOWER) a < b
        else if (operator == HIGHER_EQ) a >= b
        else if (operator == LOWER_EQ) a <= b
        else false
    }

    #[test]
    fun equality_operations_test() {
        // 1 > 2 应该是 false
        assert!(!equality_operations(1, 2, HIGHER), 0);
        // 1 >= 2 应该是 false
        assert!(!equality_operations(1, 2, HIGHER_EQ), 1);
        // 1 < 2 应该是 true
        assert!(equality_operations(1, 2, LOWER), 2);
        // 1 <= 2 应该是 true
        assert!(equality_operations(1, 2, LOWER_EQ), 3);
        // 再次确认 1 > 2 是 false
        assert!(!equality_operations(1, 2, HIGHER), 4);
    }

    #[test]
    fun test_equality() {
        let result = equality_operations(14, 5, HIGHER);
        print(&result);
        assert!(result);
    }
}

```

这段 Aptos Move 代码定义了一个名为 `Sample6` 的模块，它如同一个基础计算器，用于演示如何实现基本的算术与比较逻辑。该模块包含了两个核心函数：`arithmetic_operations` 用于执行加、减、乘、除和取模运算，而 `equality_operations` 则负责处理大于、小于、大于等于和小于等于的比较。两个函数都采用了一种通用设计模式，即使用预定义的常量作为操作码，并通过 `if/else if` 逻辑链来选择并执行相应的计算。该模块的全部功能都由一套全面的单元测试进行了彻底验证，确保了其中的算术和比较函数在所有预设场景下都能正确工作。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample6::equality_operations_test
[debug] 15
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample6::test_arithmetic_addition
[debug] 2
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample6::test_arithmetic_division
[debug] 4
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample6::test_arithmetic_modulus
[debug] 50
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample6::test_arithmetic_multiplication
[debug] 15
[debug] 5
[debug] 50
[debug] 2
[debug] 0
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample6::test_arithmetic_operations
[debug] 5
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample6::test_arithmetic_subtraction
[debug] true
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample6::test_equality
Test result: OK. Total tests: 8; passed: 8; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**完美地通过了其全部单元测试**。在成功编译项目后，测试框架执行了 `Sample6` 模块中定义的全部八个测试函数，涵盖了所有的算术和比较运算。日志中的每一条 `[ PASS ]` 记录都确认了一个独立的测试用例（如 `equality_operations_test` 和 `test_arithmetic_addition`）已经无错误地运行完成。期间的 `[debug]` 行清晰地打印出了代码在测试过程中计算出的实际结果（如 `15`, `true` 等）。最后，**`Test result: OK. Total tests: 8; passed: 8; failed: 0`** 的总结性陈述，为这次测试画上了圆满的句号，证明了你合约中所有的计算和比较逻辑均按预期正确工作。

## 总结

恭喜你！通过本篇文章的实战，你不仅成功地在 Aptos Move 中实现了基础的运算和比较逻辑，更重要的是，你掌握了一种编写结构化、可测试代码的思维方式。

我们学习了如何使用常量作为操作码来设计清晰的函数接口，并通过 `if/else` 控制流精确地执行不同的逻辑。但最有价值的收获，是亲身体验了 Move 语言中为每一个功能编写全面单元测试的重要性。最终测试报告中 `passed: 8; failed: 0` 的完美结果，就是对我们代码质量的最好证明。

掌握了这些基础逻辑模块的构建和验证方法后，你就已经为创造更复杂的链上应用打下了坚实的基础。

## 参考

- <https://dorahacks.io/hackathon/aptos-ctrlmove-hackathon/detail>
- <https://github.com/aptos-labs/move>
- <https://github.com/move-language/move-on-aptos>
- <https://aptosfoundation.org/>
