+++
title = "Aptos Move 实战：用 `signer` 实现合约所有权与访问控制"
description = "Aptos Move 实战：用 `signer` 实现合约所有权与访问控制"
date = 2025-09-02T14:43:20Z
[taxonomies]
categories = ["Web3", "Move", "Aptos"]
tags = ["Web3", "Move", "Aptos"]
+++

<!-- more -->

# Aptos Move 实战：用 `signer` 实现合约所有权与访问控制

在智能合约的世界里，最基础也是最核心的安全问题莫过于：“谁有权执行此操作？”。无论是转账、修改状态还是管理合约，我们都必须先验证调用者的身份。Aptos Move 为此提供了一个强大而独特的类型——`signer`。

`signer` 不仅仅是一个地址，它是交易发送者身份的密码学证明，是链上权威的唯一代表。这篇实战教程将为你彻底揭开 `signer` 的面纱。我们将通过编写一个最常见的“仅限所有者 (owner-only)”函数，手把手教你如何利用 `signer` 构建坚不可摧的访问控制防线，并向你展示如何使用 Move 测试框架的强大功能，来确保这道防线真正固若金汤。

本文通过实战案例讲解 Aptos Move 的 `signer` 类型。你将学会如何利用 `signer` 实现合约中最常见的“所有者”访问控制，并掌握使用 `#[test(account = @...)]` 属性编写单元测试，以验证权限逻辑的正确性。

## 实操

### Aptos Move Signer

```rust
module net2dev_addr::SignerDemo {
    use std::signer;
    use std::debug::print;
    use std::string::utf8;

    /// Error code for not being the owner
    const NOT_OWNER: u64 = 0;
    const OWNER: address = @net2dev_addr;

    fun check_owner(account: signer) {
        let address_val = signer::borrow_address(&account);
        assert!(address_val == &OWNER, NOT_OWNER);
        assert!(signer::address_of(&account) == OWNER, NOT_OWNER);
        print(&utf8(b"Owner Confirmed"));
        print(&signer::address_of(&account));
        print(address_val);
    }

    #[test(account = @net2dev_addr)]
    fun test_check_owner(account: signer) {
        check_owner(account);
    }
}


```

这段 Aptos Move 代码通过一个名为 `SignerDemo` 的模块，清晰地演示了如何使用核心的 **`signer`** 类型来实现**访问控制**。模块中的 `check_owner` 函数接收一个 `signer` 参数（代表交易的签名者），并通过 `assert!` 断言来严格验证该签名者的地址是否与预先定义的 `OWNER` 地址常量相匹配。这种模式确保了只有合约的“所有者”才能成功执行该函数，任何其他地址的调用都会导致交易中止并报错。附带的单元测试则巧妙地利用了 `#[test(account = @net2dev_addr)]` 属性，**模拟了一笔由指定所有者地址签名的交易**，从而验证了在授权用户调用时，这个所有权检查逻辑能够正确通过。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] "Owner Confirmed"
[debug] @0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3
[debug] @0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::SignerDemo::test_check_owner
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过其单元测试**。在成功编译项目后，测试框架执行了 `SignerDemo` 模块中定义的 `test_check_owner` 测试函数。日志中的 `[debug]` 输出，包括 "Owner Confirmed" 消息和打印出的账户地址，清晰地表明代码中的所有权检查逻辑已被成功触发。最终的 `[ PASS ]` 状态确认了该测试用例顺利完成，意味着其内部的 `assert!` 断言全部为真，证明了由测试框架模拟的调用者地址与预设的 `OWNER` 地址完全匹配，从而成功验证了你的访问控制机制在授权用户调用时能够正确工作。

## 总结

恭喜你！通过本篇实操，你已经掌握了 Aptos Move 中最核心的安全原语之一 `signer` 的用法。我们学习了 `signer` 代表着用户的链上授权，以及如何通过 `signer::address_of` 结合 `assert!` 来实现健壮、可靠的访问控制逻辑。

但本次学习最有价值的收获，是掌握了 `#[test(account = @...)]` 这个强大的测试属性。它让我们能够轻松地模拟来自特定账户（如合约所有者）的调用，从而对至关重要的安全模块进行严格、全面的验证。

现在，你已经具备了为你的 Move 合约设定清晰权限的能力，为构建更复杂、更安全的多用户应用打下了坚实的基础。

## 参考

- <https://aptos.dev/>
- <https://dorahacks.io/hackathon/aptos-ctrlmove-hackathon/detail>
- <https://www.encodeclub.com/my-programmes/aptos-ctrlmove-educate>
