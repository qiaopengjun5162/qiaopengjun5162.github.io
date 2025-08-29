+++
title = "Aptos Move 安全编程：`abort` 与 `assert!` 错误处理实战"
description = "Aptos Move 安全编程：`abort` 与 `assert!` 错误处理实战"
date = 2025-08-28T07:21:25Z
[taxonomies]
categories = ["Web3", "Move", "Aptos"]
tags = ["Web3", "Move", "Aptos"]
+++

<!-- more -->

# **Aptos Move 安全编程：`abort` 与 `assert!` 错误处理实战**

在 Aptos Move 的世界里，编写出功能只是第一步，构建能**在异常情况下“正确地失败”**的程序，才是安全编程的重中之重。Move 语言为此提供了强大的 `abort` 和 `assert!` 指令，它们是保障合约资产安全的“守门员”。

但是，我们如何能用代码证明这些“守门员”确实在岗？如何测试一段注定会失败的逻辑，却不让整个测试套件报告为“失败”？

这篇实战教程将通过四个层层递进的示例，带你走完一条从入门到精通的學習路徑。你不仅会掌握错误处理的语法，更将领会 Aptos Move 测试框架的精髓，学会如何自信地证明你的合约在各种情况下都表现得无可挑剔。

这篇 Aptos Move 实战教程深入讲解 `abort` 与 `assert!` 错误处理机制。你将掌握如何利用 `#[expected_failure]` 编写单元测试，正确验证合约的失败路径，确保代码行为符合预期，是安全编程的必修课。

## 实操

Aptos Move Error Handling

### 示例一

```rust
module net2dev_addr::Sample5 {
    use std::debug::print;
    use std::string::{String, utf8};

    fun sample_abort_error(value: String) {
        if (value == utf8(b"net2dev")) {
            print(&utf8(b"Correct"))
        } else {
            abort 123
        }
    }

    #[test]
    fun sample_abort_error_test() {
        sample_abort_error(utf8(b"net2dev"))
    }
}

```

这段 Aptos Move 代码定义了一个名为 `Sample5` 的模块，其核心目的是演示 Move 语言中至关重要的错误处理机制——`abort`指令。模块中的 `sample_abort_error` 函数实现了一个简单的检查逻辑：它接收一个字符串，只有当输入值完全等于 "net2dev" 时才打印成功信息；对于任何其他输入，它都会执行 `abort 123`。`abort` 是一个强制性操作，会立即终止当前交易的执行，撤销所有已发生的状态更改，并返回指定的错误码（这里是123），以此来防止无效或恶意的操作破坏合约状态。附带的单元测试 `sample_abort_error_test` 则通过提供正确的输入 "net2dev" 来专门验证函数的成功路径，确保其在正常情况下能够顺利通过。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] "Correct"
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5::sample_abort_error_test
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这个测试结果清晰地表明 `my-dapp` 项目成功通过了其单元测试。首先，命令行工具成功编译了项目，随后执行了 `Sample5` 模块中定义的唯一一个测试函数 `sample_abort_error_test`。日志中的 `[debug] "Correct"` 输出是关键证据，它证实在测试过程中代码成功进入了正确的 `if` 判断分支，意味着 `abort` 指令并未被触发。紧随其后的 `[ PASS ]` 状态确认了该测试用例顺利完成。最后的摘要 `Test result: OK. Total tests: 1; passed: 1; failed: 0` 做了最终总结，明确指出总共一个测试全部通过，无一失败，验证了 `sample_abort_error` 函数在接收到预期输入时的行为是正确的。

### 示例二

```rust
module net2dev_addr::Sample5 {
    use std::debug::print;
    use std::string::{String, utf8};

    fun sample_abort_error(value: String) {
        if (value == utf8(b"net2dev")) {
            print(&utf8(b"Correct"))
        } else {
            abort 123
        }
    }

    #[test]
    fun sample_abort_error_test() {
        sample_abort_error(utf8(b"net2dev"))
    }

    #[test]
    fun sample_abort_error_test_fail() {
        sample_abort_error(utf8(b"net2dev2"))
    }
}


```

这段 Aptos Move 代码定义了一个名为 `Sample5` 的模块，其核心目的是演示 Move 语言中用于强制错误处理的关键指令——`abort`。模块中的 `sample_abort_error` 函数实现了一个严格的输入验证，只接受字符串 "net2dev" 作为有效输入。如果输入匹配，它会打印成功信息；对于任何其他输入，它都会执行 `abort 123`，该指令会立即终止整个交易，回滚所有状态变更，并返回错误码 123，以此确保合约状态的完整性。该模块巧妙地提供了两个单元测试：`sample_abort_error_test` 用于验证正确输入下的成功路径，而 `sample_abort_error_test_fail` 则专门用于演示当接收到无效输入时，`abort` 机制是如何被触发的，从而完整地展示了函数的两种执行结果。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] "Correct"
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5::sample_abort_error_test
[ FAIL    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5::sample_abort_error_test_fail

Test failures:

Failures in 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5:

┌── sample_abort_error_test_fail ──────
│ error[E11001]: test failure
│   ┌─ /Users/qiaopengjun/Code/Aptos/move-tut/sources/sample5.move:9:13
│   │
│ 5 │     fun sample_abort_error(value: String) {
│   │         ------------------ In this function in 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5
│   ·
│ 9 │             abort 123
│   │             ^^^^^^^^^ Test was not expected to error, but it aborted with code 123 originating in the module 48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5 rooted here
│
│
│ stack trace
│       Sample5::sample_abort_error_test_fail(/Users/qiaopengjun/Code/Aptos/move-tut/sources/sample5.move:20)
│
└──────────────────

Test result: FAILED. Total tests: 2; passed: 1; failed: 1
{
  "Error": "Move unit tests failed"
}
```

这个测试结果表明，你的测试套件**并未完全通过**，但它**成功地验证了代码的两种执行路径**。在总共两个单元测试中，一个成功 (`PASS`)，一个失败 (`FAIL`)。成功通过的 `sample_abort_error_test` 验证了当函数接收到正确输入("net2dev")时的“成功路径”。而失败的 `sample_abort_error_test_fail` 则**如预期般地失败了**，因为它提供了错误输入("net2dev2")，正确地触发了代码中的 `abort 123` 指令。详细的错误报告指出了失败源于 `abort` 指令的执行，并明确提示“测试不期望出错，但它以代码123中止了”。因此，这个“失败”的测试结果，实际上是**成功地证明了你合约的错误处理机制正在按设计工作**。

### 示例三

```rust
module net2dev_addr::Sample5 {
    use std::debug::print;
    use std::string::{String, utf8};

    fun sample_abort_error(value: String) {
        if (value == utf8(b"net2dev")) {
            print(&utf8(b"Correct"))
        } else {
            abort 123
        }
    }

    #[test]
    fun sample_abort_error_test() {
        sample_abort_error(utf8(b"net2dev"))
    }

    #[test]
    fun sample_abort_error_test_fail() {
        sample_abort_error(utf8(b"net2dev2"))
    }

    #[test]
    #[expected_failure]
    fun sample_abort_error_test_fail_should_fail() {
        sample_abort_error(utf8(b"net2dev2"))
    }
}

```

这段 Aptos Move 代码通过引入 `#[expected_failure]` 注解，完整地展示了 Move 语言中如何对**成功和失败两种路径**进行全面的单元测试。模块核心的 `sample_abort_error` 函数逻辑不变，即只接受 "net2dev" 作为正确输入，否则就用错误码 `123` 中止交易。代码中包含了三个测试：第一个 `sample_abort_error_test` 验证了正确输入下的成功路径；第二个 `sample_abort_error_test_fail` 在没有特殊标记的情况下，会因为触发 `abort` 而被测试框架报告为失败；而新增的第三个测试 `sample_abort_error_test_fail_should_fail` 则是关键，它通过 `#[expected_failure]` 注解**明确告知测试框架，此测试预期会失败**。因此，当函数如期 `abort` 时，测试框架会判定这个“预期的失败”为测试**通过**，这才是测试合约错误处理逻辑的正确方式。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] "Correct"
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5::sample_abort_error_test
[ FAIL    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5::sample_abort_error_test_fail
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5::sample_abort_error_test_fail_should_fail

Test failures:

Failures in 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5:

┌── sample_abort_error_test_fail ──────
│ error[E11001]: test failure
│   ┌─ /Users/qiaopengjun/Code/Aptos/move-tut/sources/sample5.move:9:13
│   │
│ 5 │     fun sample_abort_error(value: String) {
│   │         ------------------ In this function in 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5
│   ·
│ 9 │             abort 123
│   │             ^^^^^^^^^ Test was not expected to error, but it aborted with code 123 originating in the module 48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5 rooted here
│
│
│ stack trace
│       Sample5::sample_abort_error_test_fail(/Users/qiaopengjun/Code/Aptos/move-tut/sources/sample5.move:20)
│
└──────────────────

Test result: FAILED. Total tests: 3; passed: 2; failed: 1
{
  "Error": "Move unit tests failed"
}
```

这个测试结果表明，你的测试套件因为一个**未按预期处理的失败**而整体失败了。在总共三个测试中，有两个通过（`PASS`），一个失败（`FAIL`）。具体来说，第一个测试 `sample_abort_error_test` 成功验证了代码的正确执行路径；第三个测试 `sample_abort_error_test_fail_should_fail` 因为标记了 `#[expected_failure]`，它成功地“捕获”了预期的 `abort` 错误，因此也被判定为通过。然而，第二个测试 `sample_abort_error_test_fail` 是导致整个流程失败的直接原因，详细的错误报告指出，这个测试**没有被标记为预期失败，但它却触发了错误码为 123 的 `abort`**，这与测试框架的默认期望（即测试应正常完成）不符，因此被判定为失败。

### 示例四

```rust
module net2dev_addr::Sample5 {
    use std::debug::print;
    use std::string::{String, utf8};

    fun sample_abort_error(value: String) {
        if (value == utf8(b"net2dev")) {
            print(&utf8(b"Correct"))
        } else {
            abort 123
        }
    }

    fun sample_assert_error(value: String) {
        assert!(value == utf8(b"net2dev"), 123);
        print(&utf8(b"Correct"))
    }

    #[test]
    fun sample_abort_error_test() {
        sample_abort_error(utf8(b"net2dev"))
    }

    #[test]
    #[expected_failure]
    fun sample_abort_error_test_fail() {
        sample_abort_error(utf8(b"net2dev2"))
    }

    #[test]
    #[expected_failure]
    fun sample_abort_error_test_fail_should_fail() {
        sample_abort_error(utf8(b"net2dev2"))
    }

    #[test]
    fun sample_assert_error_test() {
        sample_assert_error(utf8(b"net2dev"))
    }

    #[test]
    #[expected_failure]
    fun sample_assert_error_test_fail() {
        sample_assert_error(utf8(b"net2dev2"))
    }
}

```

这段 Aptos Move 代码通过一个名为 `Sample5` 的模块，对比并演示了 Move 语言中两种等效且核心的错误处理方式：`abort` 指令和 `assert!` 宏。模块中定义了两个功能完全相同的函数：`sample_abort_error` 使用 `if/else` 语句进行显式条件判断，并在条件不满足时调用 `abort 123` 来终止交易；而 `sample_assert_error` 则使用更简洁的 `assert!(condition, 123)` 宏，在条件为假时自动以相同的错误码 `123` 中止交易，展示了更常用和惯用的写法。该模块通过一系列完善的单元测试，分别为这两个函数验证了成功路径和失败路径，并正确地使用了 `#[expected_failure]` 注解来测试错误处理逻辑，从而证明了两种方式都能有效地保证合约安全。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] "Correct"
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5::sample_abort_error_test
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5::sample_abort_error_test_fail
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5::sample_abort_error_test_fail_should_fail
[debug] "Correct"
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5::sample_assert_error_test
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::Sample5::sample_assert_error_test_fail
Test result: OK. Total tests: 5; passed: 5; failed: 0
{
  "Result": "Success"
}

```

这个测试结果表明 `my-dapp` 项目的**所有单元测试都已成功通过**。日志显示，在成功编译项目后，测试框架执行了 `Sample5` 模块中定义的全部五个测试用例，并且每一个都获得了 `[ PASS ]` 状态。这尤其值得注意的是，那些旨在验证错误处理逻辑的测试（如 `sample_abort_error_test_fail` 和 `sample_assert_error_test_fail`），因为被正确地标记了 `#[expected_failure]` 注解，当它们如期触发 `abort` 时，也被测试框架判定为成功。最终 `Test result: OK. Total tests: 5; passed: 5; failed: 0` 的完美总结，证明了合约中两种错误处理方式（`abort` 和 `assert!`）的成功路径和失败路径均符合预期。

## 总结

恭喜你！走完这四个阶段，你不仅掌握了 `abort` 与 `assert!` 在 **Aptos Move 安全编程**中的应用，更重要的是，你亲身体验了 Move 语言以“测试驱动安全”的设计哲学。

我们从一个简单的函数开始，亲身经历了测试失败的场景，并最终找到了 `#[expected_failure]` 这个完美的解决方案。这趟旅程的核心收获是：一个专业的 Aptos Move 开发者，不仅要为“成功”编写代码，更要为“失败”编写测试。

将这种防御性编程和单元测试的思维融入日常开发，确保代码的每一种可能路径都在你的掌控之中，这是你在 Aptos 生态中构建可靠、安全应用的关键。

## 参考

- <https://dorahacks.io/hackathon/aptos-ctrlmove-hackathon/detail>
- <https://github.com/aptos-labs/aptos-rust-sdk>
- <https://github.com/aptos-labs/aptos-framework>
- <https://aptos.dev/zh>
