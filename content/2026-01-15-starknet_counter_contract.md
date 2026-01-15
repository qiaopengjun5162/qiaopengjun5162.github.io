+++
title = "Starknet 智能合约开发实战：Counter 合约编写、测试与部署全流程"
description = "Starknet 智能合约开发实战：Counter 合约编写、测试与部署全流程"
date = 2026-01-15T09:22:22Z
[taxonomies]
categories = ["Web3", "Cairo", "Starknet"]
tags = ["Web3", "Cairo", "Starknet"]
+++

<!-- more -->

# **Starknet 智能合约开发实战：Counter 合约编写、测试与部署全流程**

在 Starknet 生态中，掌握从代码编写到链上部署的完整闭环是开发者的必经之路。

本文将通过一个经典的 **Counter（计数器）合约**，带大家走一遍完整的智能合约开发全流程。我们将使用 **Scarb** 进行项目管理，利用 **Starknet Foundry (snforge)** 编写严谨的测试用例，并最终通过 **sncast** 完成合约的声明与部署。无论你是 Cairo 初学者，还是希望熟悉最新工具链的开发者，本文都将为你提供一份详尽的实战参考。

本文演示了如何在 Starknet 网络上开发一个标准的 Counter 计数器智能合约。内容涵盖环境检查、项目创建、Cairo 合约编写、单元测试、以及使用 sncast 进行合约声明、部署和链上交互的全流程。适合开发者快速上手 Starknet 生态开发工具链。

## 实操

### 前提

```bash
scarb --version
snforge --version && sncast --version
starknet-devnet --version
scarb 2.15.0 (56d7d30fb 2025-12-19)
cairo: 2.15.0 (https://crates.io/crates/cairo-lang-compiler/2.15.0)
sierra: 1.7.0
arch: aarch64-apple-darwin
snforge 0.54.1
sncast 0.54.1
starknet-devnet 0.7.1
```

### 创建项目

```bash
scarb new counter
✔ Which test runner do you want to set up? · Starknet Foundry (default)
 Downloading snforge_scarb_plugin v0.54.1
 Downloading snforge_std v0.54.1
Created `counter` package.
```

### 切换到项目目录

```bash
cd counter
```

### 查看项目目录结构

```bash
tree . -L 6 -I "docs|target|node_modules|build"
.
├── Scarb.lock
├── Scarb.toml
├── snfoundry.toml
├── src
│   ├── counter.cairo
│   ├── hello_starknet.cairo
│   └── lib.cairo
└── tests
    └── test_contract.cairo

3 directories, 7 files
```

### 实现合约

#### `counter.cairo`文件

```rust
#[starknet::interface]
pub trait ICounter<TContractState> {
    fn increment(ref self: TContractState);
    fn get_count(self: @TContractState) -> u32;
}

#[starknet::contract]
mod Counter {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        count: u32,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_count: u32) {
        self.count.write(initial_count);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        CountIncremented: CountIncremented,
    }

    #[derive(Drop, starknet::Event)]
    pub struct CountIncremented {
        count: u32,
    }

    #[abi(embed_v0)]
    impl CounterImpl of super::ICounter<ContractState> {
        fn increment(ref self: ContractState) {
            let new_count = self.count.read() + 1;
            self.count.write(new_count);

            self.emit(CountIncremented { count: new_count });
            // self.emit(X) 只要 X 能被“提升”为合约的 Event，就等价于 self.emit(Event::X(...))
            // self.emit(Event::CountIncremented(CountIncremented { count: new_count }));
        }

        fn get_count(self: @ContractState) -> u32 {
            self.count.read()
        }
    }
}
```

#### `hello_starknet.cairo`文件

```rust
/// Interface representing `HelloContract`.
/// This interface allows modification and retrieval of the contract balance.
#[starknet::interface]
pub trait IHelloStarknet<TContractState> {
    /// Increase contract balance.
    fn increase_balance(ref self: TContractState, amount: felt252);
    /// Retrieve contract balance.
    fn get_balance(self: @TContractState) -> felt252;
}

/// Simple contract for managing balance.
#[starknet::contract]
mod HelloStarknet {
    use starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        balance: felt252,
    }

    #[abi(embed_v0)]
    impl HelloStarknetImpl of super::IHelloStarknet<ContractState> {
        fn increase_balance(ref self: ContractState, amount: felt252) {
            assert(amount != 0, 'Amount cannot be 0');
            self.balance.write(self.balance.read() + amount);
        }

        fn get_balance(self: @ContractState) -> felt252 {
            self.balance.read()
        }
    }
}

```

#### `lib.cairo`文件

```rust
pub mod hello_starknet;
pub mod counter;
```

### 编写测试

#### `test_contract.cairo`文件

```rust
use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use counter::hello_starknet::IHelloStarknetSafeDispatcher;
use counter::hello_starknet::IHelloStarknetSafeDispatcherTrait;
use counter::hello_starknet::IHelloStarknetDispatcher;
use counter::hello_starknet::IHelloStarknetDispatcherTrait;
use counter::counter::ICounterSafeDispatcher;
use counter::counter::ICounterSafeDispatcherTrait;
use counter::counter::ICounterDispatcher;
use counter::counter::ICounterDispatcherTrait;

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

fn deploy_contract_with_initial_count(name: ByteArray, initial_count: u32) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let constructor_calldata = array![initial_count.into()];
    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    contract_address
}

#[test]
fn test_increase_balance() {
    let contract_address = deploy_contract("HelloStarknet");

    let dispatcher = IHelloStarknetDispatcher { contract_address };

    let balance_before = dispatcher.get_balance();
    assert(balance_before == 0, 'Invalid balance');

    dispatcher.increase_balance(42);

    let balance_after = dispatcher.get_balance();
    assert(balance_after == 42, 'Invalid balance');
}

#[test]
#[feature("safe_dispatcher")]
fn test_cannot_increase_balance_with_zero_value() {
    let contract_address = deploy_contract("HelloStarknet");

    let safe_dispatcher = IHelloStarknetSafeDispatcher { contract_address };

    let balance_before = safe_dispatcher.get_balance().unwrap();
    assert(balance_before == 0, 'Invalid balance');

    match safe_dispatcher.increase_balance(0) {
        Result::Ok(_) => core::panic_with_felt252('Should have panicked'),
        Result::Err(panic_data) => {
            assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
        }
    };
}

#[test]
fn test_increment_count() {
    let contract_address = deploy_contract_with_initial_count("Counter", 10);

    let dispatcher = ICounterDispatcher { contract_address };

    let count_before = dispatcher.get_count();
    assert(count_before == 10, 'Invalid count');

    dispatcher.increment();

    let count_after = dispatcher.get_count();
    assert(count_after == 11, 'Invalid count');
}

#[test]
#[feature("safe_dispatcher")]
fn test_cannot_increment_count_with_zero_value() {
    let contract_address = deploy_contract_with_initial_count("Counter", 100);

    let safe_dispatcher = ICounterSafeDispatcher { contract_address };

    let count_before = safe_dispatcher.get_count().unwrap();
    assert(count_before == 100, 'Invalid count');

    match safe_dispatcher.increment() {
        Result::Ok(_) => {
            let count_after = safe_dispatcher.get_count().unwrap();
            assert(count_after == 101, 'Invalid count');
        },
        Result::Err(panic_data) => {
            assert(*panic_data.at(0) == 'Cannot increment count with 0', *panic_data.at(0));
        }
    };
}
```

### 编译构建合约

```bash
counter on  main [?]
➜ scarb build
   Compiling counter v0.1.0 (/Users/qiaopengjun/Code/Starknet/counter/Scarb.toml)
    Finished `dev` profile target(s) in 0 seconds

```

### 测试合约

```bash
counter on  main [?]
➜ scarb test
     Running test counter (snforge test)
   Compiling test(counter_unittest) counter v0.1.0 (/Users/qiaopengjun/Code/Starknet/counter/Scarb.toml)
   Compiling test(counter_integrationtest) counter_integrationtest v0.1.0 (/Users/qiaopengjun/Code/Starknet/counter/Scarb.toml)
    Finished `dev` profile target(s) in 0 seconds


Collected 4 test(s) from counter package
Running 0 test(s) from src/
Running 4 test(s) from tests/
[PASS] counter_integrationtest::test_contract::test_increase_balance (l1_gas: ~0, l1_data_gas: ~192, l2_gas: ~511980)
[PASS] counter_integrationtest::test_contract::test_increment_count (l1_gas: ~0, l1_data_gas: ~192, l2_gas: ~562370)
[PASS] counter_integrationtest::test_contract::test_cannot_increment_count_with_zero_value (l1_gas: ~0, l1_data_gas: ~192, l2_gas: ~562370)
[PASS] counter_integrationtest::test_contract::test_cannot_increase_balance_with_zero_value (l1_gas: ~0, l1_data_gas: ~96, l2_gas: ~406680)
Tests: 4 passed, 0 failed, 0 ignored, 0 filtered out

```

### 部署合约

#### 第一步：声明合约

```bash
counter on  main [?]
➜ sncast declare --contract-name Counter --network sepolia
   Compiling counter v0.1.0 (/Users/qiaopengjun/Code/Starknet/counter/Scarb.toml)
    Finished `release` profile target(s) in 1 second
Success: Declaration completed

Class Hash:       0x33474ce6b86ad00e0eae7491353f42fae2ffa11f56ccc5d38221f24525fe1a7
Transaction Hash: 0x6e75564ba6054750fe71ab0937adb0767ce37e98afc998f178d473fd8aaab0

To see declaration details, visit:
class: https://sepolia.starkscan.co/class/0x033474ce6b86ad00e0eae7491353f42fae2ffa11f56ccc5d38221f24525fe1a7
transaction: https://sepolia.starkscan.co/tx/0x006e75564ba6054750fe71ab0937adb0767ce37e98afc998f178d473fd8aaab0

To deploy a contract of this class, replace the placeholders in `--arguments` with your actual values, then run:
sncast --account account-braavos deploy --class-hash 0x33474ce6b86ad00e0eae7491353f42fae2ffa11f56ccc5d38221f24525fe1a7 --arguments '<initial_count: u32>' --network sepolia

```

#### 第二步：部署合约

```bash
counter on  main [?] took 5.9s
➜ sncast --account account-braavos deploy --class-hash 0x33474ce6b86ad00e0eae7491353f42fae2ffa11f56ccc5d38221f24525fe1a7 --arguments 42 --network sepolia
Success: Deployment completed

Contract Address: 0x0619eddb1747d173318496d9450ad7b23d00526d7d2f06bde11c64aab86185da
Transaction Hash: 0x02c0a86b0aaa05baa0c6dda0f3d8fed8662cb0f2b01982f1d1c46edecb1e95cb

To see deployment details, visit:
contract: https://sepolia.starkscan.co/contract/0x0619eddb1747d173318496d9450ad7b23d00526d7d2f06bde11c64aab86185da
transaction: https://sepolia.starkscan.co/tx/0x02c0a86b0aaa05baa0c6dda0f3d8fed8662cb0f2b01982f1d1c46edecb1e95cb
```

合约地址：<https://sepolia.starkscan.co/contract/0x0619eddb1747d173318496d9450ad7b23d00526d7d2f06bde11c64aab86185da>

![image-20260114161134672](/images/image-20260114161134672.png)

### 调用合约`get_count`方法

在浏览器调用

![image-20260114161358735](/images/image-20260114161358735.png)

#### 命令行调用

```bash
counter on  main [?] took 5.2s
➜ sncast call --contract-address 0x0619eddb1747d173318496d9450ad7b23d00526d7d2f06bde11c64aab86185da --function get_count --network sepolia
Success: Call completed

Response:     42_u32
Response Raw: [0x2a]
```

### 调用`increment`方法

```bash
counter on  main [?]
➜ sncast invoke --contract-address 0x0619eddb1747d173318496d9450ad7b23d00526d7d2f06bde11c64aab86185da --function increment --network sepolia
Success: Invoke completed

Transaction Hash: 0x0366bff00b167234989708feac7fd1e778f49f604757c67cb2e2dc5406c1876e

To see invocation details, visit:
transaction: https://sepolia.starkscan.co/tx/0x0366bff00b167234989708feac7fd1e778f49f604757c67cb2e2dc5406c1876e
```

### 查看调用结果

#### 浏览器查看

![image-20260114162102647](/images/image-20260114162102647.png)

#### 查看事件信息

![image-20260114162256746](/images/image-20260114162256746.png)

#### 命令行再次调用查看结果

```bash
counter on  main [?] took 4.5s
➜ sncast call --contract-address 0x0619eddb1747d173318496d9450ad7b23d00526d7d2f06bde11c64aab86185da --function get_count --network sepolia
Success: Call completed

Response:     43_u32
Response Raw: [0x2b]

```

### 查看`Class Hash`

```bash
counter on  main [?]
➜ sncast utils class-hash --contract-name Counter
   Compiling counter v0.1.0 (/Users/qiaopengjun/Code/Starknet/counter/Scarb.toml)
    Finished `release` profile target(s) in 0 seconds
Class Hash: 0x033474ce6b86ad00e0eae7491353f42fae2ffa11f56ccc5d38221f24525fe1a7

```

注意：如果合约代码发生改变则 Class Hash 也会相应改变。

## 练习

1. Starknet 上的智能合约本质上是什么？运行在链上的 Cairo 程序，能够访问和修改持久状态
2. 一份 Cairo 智能合约在部署前，必须先经历哪一步？编译并在链上 declare 为合约类
3. 在 Cairo 中，一个智能合约在代码层面本质上是？一个 Cairo 模块
4. constructor 函数的正确描述是？只在合约部署时调用一次
5. Dispatcher 的主要用途是？实现跨合约调用

## 总结

通过本次实操，我们完整走通了 Starknet 智能合约开发的核心链路：

1. **环境构建**：确保了 Scarb 和 Starknet Foundry 工具链的协同工作。
2. **合约实现**：深入理解了 Cairo 状态读写、事件（Event）辐射以及构造函数的应用。
3. **工程化测试**：通过 `snforge` 验证了业务逻辑的正确性，并处理了异常情况下的 `SafeDispatcher` 调用。
4. **链上交互**：完成了从合约声明（Declare）到实例部署（Deploy），再到写操作（Invoke）与读操作（Call）的实操。

这一套“编写-测试-部署”的流程是 Starknet 开发的标准范式。掌握这些基础后，你已经具备了构建更复杂去中心化应用的基石。

## 参考

- <https://youtu.be/Gg6cvitJENA>
- <https://www.starknet-ecosystem.com/>
- <https://github.com/stark-land/cohort-5>
- <https://www.starknet.io/cairo-book/title-page.html>
