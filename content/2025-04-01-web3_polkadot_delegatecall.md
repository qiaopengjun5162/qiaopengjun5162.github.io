+++
title = "Web3 实践：在 Polkadot 上用 Solidity 玩转 Delegatecall"
description = "Web3 实践：在 Polkadot 上用 Solidity 玩转 Delegatecall"
date = 2025-04-01 22:29:25+08:00
[taxonomies]
categories = ["Web3", "Solidity", "Polkadot"]
tags = ["Web3", "Solidity", "Polkadot", "Delegatecall"]
+++

<!-- more -->

# Web3 实践：在 Polkadot 上用 Solidity 玩转 Delegatecall

Web3 浪潮席卷而来，智能合约作为区块链世界的核心驱动力，正变得越来越灵活和强大。在 Polkadot 这个多链生态中，Solidity 依然是开发者的得力工具，而 delegatecall 则像是合约设计中的“魔法钥匙”，让代码分离与状态管理变得游刃有余。本文将带你走进一场 Web3 实践之旅，通过一个简单的计数器案例，展示如何在 Polkadot 上用 Solidity 玩转 delegatecall。从代码编写到测试验证，再到实际部署，我们一步步揭秘这个技术的魅力，助你在 Web3 世界中更进一步！

本文献上的是一场 Web3 开发的实战演练：在 Polkadot 环境下，我们用 Solidity 打造了一个基于 delegatecall 的智能合约系统。核心由两部分组成：逻辑合约 LogicContract 定义了一个简单的计数器功能，代理合约 ProxyContract 通过 delegatecall 借用它的代码逻辑并更新自身状态。借助 Foundry 框架，我们完成了从项目搭建到全面测试的全流程，确保功能的稳健性。更酷的是，我们还在 Remix 上将合约部署到 Westend 网络，实打实地验证了效果。这不仅是一次技术探索，更是 Web3 开发者进阶的实用指南！

## call 和 Delegatecall

`call` 修改目标合约的存储，`delegatecall` 修改调用者合约的存储，前者适合普通调用，后者用于代理合约和可升级合约模式。

`call`: 你喊别人做事，活儿在别人家干，改的是别人家的东西。比如你给朋友打电话让他记账，账本是他自己的，跟你没关系。适合普通聊天或者转账这种简单活儿。

![call](https://www.wtf.academy/_next/image?url=https%3A%2F%2Fimages.mirror-media.xyz%2Fpublication-images%2FVgMR533pA8WYtE5Lr65mQ.png%3Fheight%3D698%26width%3D1860&w=3840&q=75)

`delegatecall`: 你请别人来你家干活，用的是你家的东西，改的是你家的账本。比如你叫个师傅修家具，工具和家具都是你的，他只是出力。适合代理干活或者升级家装这种高级操作。

一句话总结：

**call 是跑别人家折腾，delegatecall 是请人来你家折腾。一个动别人，一个动自己。**

![delegatecall](https://www.wtf.academy/_next/image?url=https%3A%2F%2Fimages.mirror-media.xyz%2Fpublication-images%2FJucQiWVixdlmJl6zHjCSI.png%3Fheight%3D702%26width%3D1862&w=3840&q=75)

## Solidity on Polkadot

实现一个简单的 Solidity 合约，展示如何使用 delegatecall 来执行一个逻辑合约的函数，同时确保调用者的状态被保留。

 要求：

- 创建两个合约，一个是逻辑合约，一个是代理合约。

- 逻辑合约应包含一个简单的函数，如每次调用增加 1。

- 代理合约使用 delegatecall 调用逻辑合约中的增加函数。

- 编写测试用例，验证通过代理合约调用后，状态持有者的数据被正确更新。

## 实操

### 创建并初始化项目

```bash
2025-17-solidity-on-polkadot/homework-3/1490/code on  main [?] on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ export FOUNDRY_DISABLE_NIGHTLY_WARNING=1

2025-17-solidity-on-polkadot/homework-3/1490/code on  main [?] on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ forge init delegatecall-example
cd delegatecall-example
Initializing /Users/qiaopengjun/Code/polkadot/2025-17-solidity-on-polkadot/homework-3/1490/code/delegatecall-example...
Installing forge-std in /Users/qiaopengjun/Code/polkadot/2025-17-solidity-on-polkadot/homework-3/1490/code/delegatecall-example/lib/forge-std (url: Some("https://github.com/foundry-rs/forge-std"), tag: None)
Cloning into '/Users/qiaopengjun/Code/polkadot/2025-17-solidity-on-polkadot/homework-3/1490/code/delegatecall-example/lib/forge-std'...
remote: Enumerating objects: 2090, done.
remote: Counting objects: 100% (1021/1021), done.
remote: Compressing objects: 100% (134/134), done.
remote: Total 2090 (delta 940), reused 896 (delta 887), pack-reused 1069 (from 1)
Receiving objects: 100% (2090/2090), 654.53 KiB | 1007.00 KiB/s, done.
Resolving deltas: 100% (1416/1416), done.
    Installed forge-std v1.9.6
    Initialized forge project

```

### 项目目录结构

```bash
2025-17-solidity-on-polkadot/homework-3/1490/code/delegatecall-example on  main [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base took 2.4s 
➜ tree . -L 6 -I 'target|cache|lib|out|build'


.
├── README.md
├── foundry.toml
├── remappings.txt
├── script
│   └── Counter.s.sol
├── src
│   ├── Counter.sol
│   ├── LogicContract.sol
│   └── ProxyContract.sol
└── test
    ├── Counter.t.sol
    └── ProxyTest.t.sol

4 directories, 9 files
```

### `LogicContract.sol` 文件

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract LogicContract {
    uint256 public counter;

    function increment() external returns (uint256) {
        counter = counter + 1;
        return counter;
    }
}

```

### `ProxyContract.sol` 文件

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract ProxyContract {
    uint256 public counter;
    address public logicContractAddress;

    constructor(address _logicContractAddress) {
        require(_logicContractAddress != address(0), "Zero address not allowed");

        logicContractAddress = _logicContractAddress;
    }

    function incrementViaDelegateCall() external returns (uint256) {
        (bool success, bytes memory data) = logicContractAddress.delegatecall(abi.encodeWithSignature("increment()"));
        require(success, "Delegatecall failed");
        return abi.decode(data, (uint256));
    }

    function updateLogicAddress(address _newLogicAddress) external {
        require(_newLogicAddress != address(0), "Zero address not allowed");
        logicContractAddress = _newLogicAddress;
    }
}

```

### `ProxyTest.t.sol` 文件

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {LogicContract} from "../src/LogicContract.sol";
import {ProxyContract} from "../src/ProxyContract.sol";

contract ProxyTest is Test {
    LogicContract logicContract;
    ProxyContract proxyContract;

    function setUp() public {
        // 部署逻辑合约
        logicContract = new LogicContract();
        // 部署代理合约并传入逻辑合约地址
        proxyContract = new ProxyContract(address(logicContract));
    }

    function test_IncrementViaDelegateCall() public {
        // 初始状态检查
        assertEq(proxyContract.counter(), 0, "Proxy counter should start at 0");
        assertEq(logicContract.counter(), 0, "Logic counter should start at 0");

        // 通过代理合约调用 increment
        uint256 newValue = proxyContract.incrementViaDelegateCall();

        // 验证返回值
        assertEq(newValue, 1, "Return value should be 1");
        // 验证代理合约状态更新
        assertEq(proxyContract.counter(), 1, "Proxy counter should be 1");
        // 验证逻辑合约状态未变
        assertEq(logicContract.counter(), 0, "Logic counter should still be 0");

        // 再次调用并验证
        newValue = proxyContract.incrementViaDelegateCall();
        assertEq(newValue, 2, "Return value should be 2");
        assertEq(proxyContract.counter(), 2, "Proxy counter should be 2");
        assertEq(logicContract.counter(), 0, "Logic counter should still be 0");
    }

    function test_UpdateLogicAddress() public {
        // 部署一个新的逻辑合约
        LogicContract newLogicContract = new LogicContract();
        address newLogicAddress = address(newLogicContract);

        // 更新逻辑合约地址
        proxyContract.updateLogicAddress(newLogicAddress);

        // 验证地址已更新
        assertEq(proxyContract.logicContractAddress(), newLogicAddress, "Logic address should be updated");

        // 调用 increment 并验证仍能正常工作
        uint256 newValue = proxyContract.incrementViaDelegateCall();
        assertEq(newValue, 1, "Return value should be 1 after address update");
        assertEq(proxyContract.counter(), 1, "Proxy counter should be 1");
    }
    
    function test_RevertWhen_DelegateCallToZeroAddress() public {
        // 设置零地址
        vm.expectRevert("Zero address not allowed");
        proxyContract.updateLogicAddress(address(0));

        proxyContract.incrementViaDelegateCall();
    }

    function test_RevertWhen_UpdateToZeroAddress() public {
        vm.expectRevert("Zero address not allowed");
        proxyContract.updateLogicAddress(address(0));
    }

    function testRevertWhen_DeployWithZeroAddress() public {
        vm.expectRevert("Zero address not allowed");
        new ProxyContract(address(0));
    }

    // 测试 delegatecall 调用不存在的函数
    function test_RevertWhen_DelegateCallToInvalidFunction() public {
        InvalidLogic invalidLogic = new InvalidLogic();
        proxyContract.updateLogicAddress(address(invalidLogic));

        vm.expectRevert("Delegatecall failed");
        proxyContract.incrementViaDelegateCall();
    }
}

// 用于测试的无效逻辑合约
contract InvalidLogic {
    uint256 public counter;
    // 故意不实现 increment 函数
}

```

### 构建项目

```bash
2025-17-solidity-on-polkadot/homework-3/1490/code/delegatecall-example on  main [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ forge build   
[⠒] Compiling...
No files changed, compilation skipped

```

### 格式化项目

```bash
2025-17-solidity-on-polkadot/homework-3/1490/code/delegatecall-example on  main [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base took 2.6s 
➜ forge fmt     
```

### 测试

```bash
2025-17-solidity-on-polkadot/homework-3/1490/code/delegatecall-example on  main [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ forge test --match-path test/ProxyTest.t.sol --show-progress -vv  
[⠊] Compiling...
[⠑] Compiling 2 files with Solc 0.8.28
[⠘] Solc 0.8.28 finished in 1.61s
Compiler run successful!
test/ProxyTest.t.sol:ProxyTest
  ↪ Suite result: ok. 6 passed; 0 failed; 0 skipped; finished in 8.40ms (10.78ms CPU time)

Ran 6 tests for test/ProxyTest.t.sol:ProxyTest
[PASS] testRevertWhen_DeployWithZeroAddress() (gas: 36118)
[PASS] test_IncrementViaDelegateCall() (gas: 51866)
[PASS] test_RevertWhen_DelegateCallToInvalidFunction() (gas: 70593)
[PASS] test_RevertWhen_DelegateCallToZeroAddress() (gas: 36917)
[PASS] test_RevertWhen_UpdateToZeroAddress() (gas: 8704)
[PASS] test_UpdateLogicAddress() (gas: 110779)
Suite result: ok. 6 passed; 0 failed; 0 skipped; finished in 8.40ms (10.78ms CPU time)

Ran 1 test suite in 190.86ms (8.40ms CPU time): 6 tests passed, 0 failed, 0 skipped (6 total tests)


```

### 查看测试覆盖率

```bash
2025-17-solidity-on-polkadot/homework-3/1490/code/delegatecall-example on  main [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base took 3.0s 
➜ forge coverage                                                  
Warning: optimizer settings and `viaIR` have been disabled for accurate coverage reports.
If you encounter "stack too deep" errors, consider using `--ir-minimum` which enables `viaIR` with minimum optimization resolving most of the errors
[⠊] Compiling...
[⠃] Compiling 25 files with Solc 0.8.28
[⠊] Solc 0.8.28 finished in 1.91s
Compiler run successful!
Analysing contracts...
Running tests...

Ran 6 tests for test/ProxyTest.t.sol:ProxyTest
[PASS] testRevertWhen_DeployWithZeroAddress() (gas: 36807)
[PASS] test_IncrementViaDelegateCall() (gas: 57869)
[PASS] test_RevertWhen_DelegateCallToInvalidFunction() (gas: 82584)
[PASS] test_RevertWhen_DelegateCallToZeroAddress() (gas: 38554)
[PASS] test_RevertWhen_UpdateToZeroAddress() (gas: 9228)
[PASS] test_UpdateLogicAddress() (gas: 145338)
Suite result: ok. 6 passed; 0 failed; 0 skipped; finished in 1.40ms (2.97ms CPU time)

Ran 2 tests for test/Counter.t.sol:CounterTest
[PASS] testFuzz_SetNumber(uint256) (runs: 256, μ: 32043, ~: 32354)
[PASS] test_Increment() (gas: 31851)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 9.26ms (8.98ms CPU time)

Ran 2 test suites in 173.78ms (10.66ms CPU time): 8 tests passed, 0 failed, 0 skipped (8 total tests)

╭-----------------------+-----------------+----------------+---------------+---------------╮
| File                  | % Lines         | % Statements   | % Branches    | % Funcs       |
+==========================================================================================+
| script/Counter.s.sol  | 0.00% (0/5)     | 0.00% (0/3)    | 100.00% (0/0) | 0.00% (0/2)   |
|-----------------------+-----------------+----------------+---------------+---------------|
| src/Counter.sol       | 100.00% (4/4)   | 100.00% (2/2)  | 100.00% (0/0) | 100.00% (2/2) |
|-----------------------+-----------------+----------------+---------------+---------------|
| src/LogicContract.sol | 100.00% (3/3)   | 100.00% (2/2)  | 100.00% (0/0) | 100.00% (1/1) |
|-----------------------+-----------------+----------------+---------------+---------------|
| src/ProxyContract.sol | 100.00% (10/10) | 100.00% (9/9)  | 100.00% (6/6) | 100.00% (3/3) |
|-----------------------+-----------------+----------------+---------------+---------------|
| Total                 | 77.27% (17/22)  | 81.25% (13/16) | 100.00% (6/6) | 75.00% (6/8)  |
╰-----------------------+-----------------+----------------+---------------+---------------╯

2025-17-solidity-on-polkadot/homework-3/1490/code/delegatecall-example on  main [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base took 2.4s 
➜ 
```

### 运行测试并生成测试覆盖率报告

```bash
2025-17-solidity-on-polkadot/homework-3/1490/code/delegatecall-example on  main [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ forge coverage > test-report.txt                        
Warning: This is a nightly build of Foundry. It is recommended to use the latest stable version. Visit https://book.getfoundry.sh/announcements for more information. 
To mute this warning set `FOUNDRY_DISABLE_NIGHTLY_WARNING` in your environment. 

Warning: optimizer settings and `viaIR` have been disabled for accurate coverage reports.
If you encounter "stack too deep" errors, consider using `--ir-minimum` which enables `viaIR` with minimum optimization resolving most of the errors

```

### `test-report.txt` 文件

```bash
Compiling 25 files with Solc 0.8.28
Solc 0.8.28 finished in 1.91s
Compiler run successful!
Analysing contracts...
Running tests...

Ran 6 tests for test/ProxyTest.t.sol:ProxyTest
[PASS] testRevertWhen_DeployWithZeroAddress() (gas: 36807)
[PASS] test_IncrementViaDelegateCall() (gas: 57869)
[PASS] test_RevertWhen_DelegateCallToInvalidFunction() (gas: 82584)
[PASS] test_RevertWhen_DelegateCallToZeroAddress() (gas: 38554)
[PASS] test_RevertWhen_UpdateToZeroAddress() (gas: 9228)
[PASS] test_UpdateLogicAddress() (gas: 145338)
Suite result: ok. 6 passed; 0 failed; 0 skipped; finished in 11.64ms (9.57ms CPU time)

Ran 2 tests for test/Counter.t.sol:CounterTest
[PASS] testFuzz_SetNumber(uint256) (runs: 256, μ: 32043, ~: 32354)
[PASS] test_Increment() (gas: 31851)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 19.73ms (11.51ms CPU time)

Ran 2 test suites in 201.57ms (31.37ms CPU time): 8 tests passed, 0 failed, 0 skipped (8 total tests)

╭-----------------------+-----------------+----------------+---------------+---------------╮
| File                  | % Lines         | % Statements   | % Branches    | % Funcs       |
+==========================================================================================+
| script/Counter.s.sol  | 0.00% (0/5)     | 0.00% (0/3)    | 100.00% (0/0) | 0.00% (0/2)   |
|-----------------------+-----------------+----------------+---------------+---------------|
| src/Counter.sol       | 100.00% (4/4)   | 100.00% (2/2)  | 100.00% (0/0) | 100.00% (2/2) |
|-----------------------+-----------------+----------------+---------------+---------------|
| src/LogicContract.sol | 100.00% (3/3)   | 100.00% (2/2)  | 100.00% (0/0) | 100.00% (1/1) |
|-----------------------+-----------------+----------------+---------------+---------------|
| src/ProxyContract.sol | 100.00% (10/10) | 100.00% (9/9)  | 100.00% (6/6) | 100.00% (3/3) |
|-----------------------+-----------------+----------------+---------------+---------------|
| Total                 | 77.27% (17/22)  | 81.25% (13/16) | 100.00% (6/6) | 75.00% (6/8)  |
╰-----------------------+-----------------+----------------+---------------+---------------╯

```

### 生成详细的HTML 测试覆盖率报告

#### 第一步：生成 LCOV 文件

```bash
2025-17-solidity-on-polkadot/homework-3/1490/code/delegatecall-example on  main [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base took 2.6s 
➜ forge coverage --report lcov --report-file coverage.lcov
Warning: This is a nightly build of Foundry. It is recommended to use the latest stable version. Visit https://book.getfoundry.sh/announcements for more information. 
To mute this warning set `FOUNDRY_DISABLE_NIGHTLY_WARNING` in your environment. 

Warning: optimizer settings and `viaIR` have been disabled for accurate coverage reports.
If you encounter "stack too deep" errors, consider using `--ir-minimum` which enables `viaIR` with minimum optimization resolving most of the errors
[⠊] Compiling...
[⠃] Compiling 25 files with Solc 0.8.28
[⠒] Solc 0.8.28 finished in 1.93s
Compiler run successful!
Analysing contracts...
Running tests...

Ran 6 tests for test/ProxyTest.t.sol:ProxyTest
[PASS] testRevertWhen_DeployWithZeroAddress() (gas: 36807)
[PASS] test_IncrementViaDelegateCall() (gas: 57869)
[PASS] test_RevertWhen_DelegateCallToInvalidFunction() (gas: 82584)
[PASS] test_RevertWhen_DelegateCallToZeroAddress() (gas: 38554)
[PASS] test_RevertWhen_UpdateToZeroAddress() (gas: 9228)
[PASS] test_UpdateLogicAddress() (gas: 145338)
Suite result: ok. 6 passed; 0 failed; 0 skipped; finished in 8.04ms (11.78ms CPU time)

Ran 2 tests for test/Counter.t.sol:CounterTest
[PASS] testFuzz_SetNumber(uint256) (runs: 256, μ: 32043, ~: 32354)
[PASS] test_Increment() (gas: 31851)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 15.54ms (11.54ms CPU time)

Ran 2 test suites in 187.19ms (23.58ms CPU time): 8 tests passed, 0 failed, 0 skipped (8 total tests)
Wrote LCOV report.
```

#### 第二步：将 LCOV 文件转换为 HTML 报告

```bash
2025-17-solidity-on-polkadot/homework-3/1490/code/delegatecall-example on  main [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base took 2.6s 
➜ genhtml coverage.lcov --output-directory coverage-report
Reading tracefile coverage.lcov.
Found 4 entries.
Found common filename prefix "/Users/qiaopengjun/Code/polkadot/2025-17-solidity-on-polkadot/homework-3/1490/code/delegatecall-example"
Generating output.
Processing file src/Counter.sol
  lines=4 hit=4 functions=2 hit=2
Processing file script/Counter.s.sol
  lines=5 hit=0 functions=2 hit=0
Processing file src/ProxyContract.sol
  lines=10 hit=10 functions=3 hit=3
Processing file src/LogicContract.sol
  lines=3 hit=3 functions=1 hit=1
Overall coverage rate:
  source files: 4
  lines.......: 77.3% (17 of 22 lines)
  functions...: 75.0% (6 of 8 functions)
Message summary:
  no messages were reported

```

#### 第三步：打开`coverage-report/index.html` 文件即可在浏览器中查看详细的测试覆盖率报告

![image-20250401203026375](/images/image-20250401203026375.png)

### 使用 `remix` 部署合约

打开该网站：<https://remix.polkadot.io/，创建一个新的`workspace`，并在该`workspace`下创建合约文件粘贴合约代码>

![image-20250401211623171](/images/image-20250401211623171.png)

#### 代码

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// 逻辑合约
contract LogicContract {
    // 状态变量 - 注意这个变量不会在逻辑合约中实际改变
    uint256 public counter;
    
    // 增加计数器的函数
    function increment() external returns (uint256) {
        counter = counter + 1;
        return counter;
    }
}

// 代理合约
contract ProxyContract {
    // 状态变量 - 这个变量会被实际修改
    uint256 public counter;
    
    // 逻辑合约的地址
    address public logicContractAddress;
    
    // 构造函数，初始化逻辑合约地址
    constructor(address _logicContractAddress) {
        require(_logicContractAddress != address(0), "Zero address not allowed");
        logicContractAddress = _logicContractAddress;
    }
    
    // 使用 delegatecall 调用逻辑合约的 increment 函数
    function incrementViaDelegateCall() external returns (uint256) {
        (bool success, bytes memory data) = logicContractAddress.delegatecall(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Delegatecall failed");
        
        // 解码返回数据
        return abi.decode(data, (uint256));
    }
    
    // 更新逻辑合约地址（可选）
    function updateLogicAddress(address _newLogicAddress) external {
        require(_newLogicAddress != address(0), "Zero address not allowed");
        logicContractAddress = _newLogicAddress;
    }
}
```

#### 部署逻辑合约

![image-20250401211802883](/images/image-20250401211802883.png)

#### 成功部署

![image-20250401211937646](/images/image-20250401211937646.png)

#### 浏览器查看合约

合约地址：0x00189cae228389b61f68b4e3520393941daad6e1

<https://assethub-westend.subscan.io/account/0x00189cae228389b61f68b4e3520393941daad6e1>

![image-20250401213038287](/images/image-20250401213038287.png)

#### 部署代理合约

合约地址：0xf711dcd0ffdcdd11ecbbdc4830aefb15d9bfa267

<https://assethub-westend.subscan.io/account/0xf711dcd0ffdcdd11ecbbdc4830aefb15d9bfa267>

![image-20250401213557888](/images/image-20250401213557888.png)

调用代理合约的`incrementViaDelegateCall`方法来调用实现合约的增加计数器的函数`increment`

<https://assethub-westend.subscan.io/tx/0x30079b7cc9684a7b4c5e46e25f5f44a40f00a3d07c3208fd708983d3abd315a2>

![image-20250401214137858](/images/image-20250401214137858.png)

## 总结

通过这场 Web3 实践，我们在 Polkadot 上用 Solidity 成功解锁了 delegatecall 的潜力。一个简单的计数器背后，是代理与逻辑分离的巧妙设计，以及状态管理的灵活实现。从代码到测试，再到 Westend 网络的部署，这套方案不仅跑通了全流程，还通过严谨的测试验证了可靠性。无论你是 Web3 新手还是老司机，这篇文章都为你打开了一扇窗：delegatecall 不只是技术名词，更是构建可升级、可扩展智能合约的利器。下一站，不妨试试更复杂的逻辑，把 Web3 的想象力发挥到极致！

## 参考

- <https://www.wtf.academy/zh/course/solidity102/Delegatecall>
- <https://remix.polkadot.io/>
- <https://assethub-westend.subscan.io/account/0x00189cae228389b61f68b4e3520393941daad6e1>
- <https://assethub-westend.subscan.io/tx/0xb4a795dc37ac69a3b1245946173d27a9c7a39db80025dab27f7bf63d559d9fdc?tab=xcm_transfer>
- <https://assethub-westend.subscan.io/account/0xf711dcd0ffdcdd11ecbbdc4830aefb15d9bfa267>
