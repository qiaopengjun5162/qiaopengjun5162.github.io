+++
title = "解锁Web3未来：Rust与Solidity智能合约实战"
description = "解锁Web3未来：Rust与Solidity智能合约实战"
date = 2025-05-08T13:55:23Z
[taxonomies]
categories = ["Web3", "Rust", "Solidity"]
tags = ["Web3", "Rust", "Solidity"]
+++

<!-- more -->

# 解锁Web3未来：Rust与Solidity智能合约实战

Web3正在重塑互联网的未来，而Rust与Solidity的强强联合为开发者提供了打造高效、安全区块链应用的利器。本文通过“rust-chain”项目，带你走进Web3开发的实战前沿。从智能合约的编写到部署Holesky测试网，再到Rust后端与区块链的交互，这份教程将解锁Rust和Solidity的无限可能，助你快速掌握2025年Web3开发的核心技能。无论你是区块链新手还是资深开发者，都能在这里找到灵感与干货！

本文详细展示了基于Rust和Solidity的Web3区块链项目“rust-chain”的开发全流程。项目涵盖Rust项目初始化、Solidity智能合约（Counter）开发与部署、Rust后端API构建，以及与Holesky测试网的交互。文章通过清晰的代码示例和运行结果，演示了如何使用Foundry工具链和ethers-rs库实现合约部署与查询，并通过Axum框架提供高效API服务。读者将掌握Rust与Solidity结合的实战技巧，解锁Web3开发的前沿技能，适合希望快速上手区块链应用开发的从业者。

## 实操

### 创建项目

创建一个新的 Rust 项目，项目名称为 rust-chain

```bash
cargo new rust-chain  

    Creating binary (application) `rust-chain` package
note: see more `Cargo.toml` keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html
```

### 构建与运行Rust项目：rust-chain

```bash
cd rust-chain

ls
Cargo.toml src
cargo run
   Compiling rust-chain v0.1.0 (/Users/qiaopengjun/Code/Rust/rust-chain)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.63s
     Running `target/debug/rust-chain`
Hello, world!
```

### 创建合约项目目录

```bash
mkdir contracts
```

### 切换到合约项目目录并初始化

```bash
cd contracts && forge init
```

### 查看合约项目目录

```bash
rust-chain/contracts on  master [+?] is 📦 0.1.0 via 🦀 1.86.0 
➜ tree . -L 6 -I "out|lib|cache|broadcast"
.
├── foundry.toml
├── note.md
├── README.md
├── remappings.txt
├── script
│   └── Counter.s.sol
├── src
│   └── Counter.sol
└── test
    └── Counter.t.sol

4 directories, 7 files

```

### 合约代码 Counter.sol

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Counter {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}

```

### 部署脚本 Counter.s.sol

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

contract CounterScript is Script {
    Counter public counter;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        counter = new Counter();

        console2.log("Counter address: ", address(counter));
        counter.setNumber(69420);
        console2.log("Counter number: ", counter.number());
        vm.stopBroadcast();
    }
}

```

### 安装项目所需的依赖库

```bash
rust-chain/contracts on  master [+?] is 📦 0.1.0 via 🦀 1.86.0 
➜ forge install                                 
Updating dependencies in /Users/qiaopengjun/Code/Rust/rust-chain/contracts/lib
```

### 项目依赖映射生成并保存到 remappings.txt 文件

```bash
rust-chain/contracts on  master [+?] is 📦 0.1.0 via 🦀 1.86.0 
➜ forge remappings > remappings.txt
```

### 编译构建合约

`forge build` 就是 Foundry 用来将你的 Solidity 代码转换成计算机（以太坊虚拟机 EVM）可以理解和执行的格式的命令。

```bash
rust-chain/contracts on  master [+?] is 📦 0.1.0 via 🦀 1.86.0 
➜ forge build                      
[⠊] Compiling...
No files changed, compilation skipped
```

### 部署并验证合约

```bash
rust-chain/contracts on  master [+?] is 📦 0.1.0 via 🦀 1.86.0 
➜ source .env           

rust-chain/contracts on  master [+?] is 📦 0.1.0 via 🦀 1.86.0 
➜ forge script CounterScript --rpc-url $HOLESKY_RPC_URL --broadcast --verify -vvvvv 
[⠊] Compiling...
No files changed, compilation skipped
Traces:
  [121] CounterScript::setUp()
    └─ ← [Stop]

  [167052] CounterScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [96345] → new Counter@0x5A31b9407095dd9A295139c4F0183c076051632D
    │   └─ ← [Return] 481 bytes of code
    ├─ [0] console::log("Counter address: ", Counter: [0x5A31b9407095dd9A295139c4F0183c076051632D]) [staticcall]
    │   └─ ← [Stop]
    ├─ [22492] Counter::setNumber(69420 [6.942e4])
    │   └─ ← [Stop]
    ├─ [424] Counter::number() [staticcall]
    │   └─ ← [Return] 69420 [6.942e4]
    ├─ [0] console::log("Counter number: ", 69420 [6.942e4]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Stop]


Script ran successfully.

== Logs ==
  Counter address:  0x5A31b9407095dd9A295139c4F0183c076051632D
  Counter number:  69420

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [96345] → new Counter@0x5A31b9407095dd9A295139c4F0183c076051632D
    └─ ← [Return] 481 bytes of code

  [22492] Counter::setNumber(69420 [6.942e4])
    └─ ← [Stop]


==========================

Chain 17000

Estimated gas price: 0.00349614 gwei

Estimated total gas used for script: 264249

Estimated amount required: 0.00000092385149886 ETH

==========================

##### holesky
✅  [Success] Hash: 0xc29b0a07ed4e464222824cf483c5fcb49d2be8a6d4b7928e69f3e322cf045c5d
Contract Address: 0x5A31b9407095dd9A295139c4F0183c076051632D
Block: 3787922
Paid: 0.000000548248384151 ETH (156817 gas * 0.003496103 gwei)


##### holesky
✅  [Success] Hash: 0x6bff519cb35a59975c8c7984d459e3651f7376fe33c68d15cecffd233e9489a4
Block: 3787922
Paid: 0.00000015284962316 ETH (43720 gas * 0.003496103 gwei)

✅ Sequence #1 on holesky | Total Paid: 0.000000701098007311 ETH (200537 gas * avg 0.003496103 gwei)
                                                                                                                                                                                                              

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (1) contracts
Start verifying contract `0x5A31b9407095dd9A295139c4F0183c076051632D` deployed on holesky
EVM version: shanghai
Compiler version: 0.8.20

Submitting verification for [src/Counter.sol:Counter] 0x5A31b9407095dd9A295139c4F0183c076051632D.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (4 tries remaining)

Submitting verification for [src/Counter.sol:Counter] 0x5A31b9407095dd9A295139c4F0183c076051632D.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (3 tries remaining)

Submitting verification for [src/Counter.sol:Counter] 0x5A31b9407095dd9A295139c4F0183c076051632D.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (2 tries remaining)

Submitting verification for [src/Counter.sol:Counter] 0x5A31b9407095dd9A295139c4F0183c076051632D.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (1 tries remaining)

Submitting verification for [src/Counter.sol:Counter] 0x5A31b9407095dd9A295139c4F0183c076051632D.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (0 tries remaining)

Submitting verification for [src/Counter.sol:Counter] 0x5A31b9407095dd9A295139c4F0183c076051632D.
Submitted contract for verification:
        Response: `OK`
        GUID: `fgkwdamvcuihvdydrfaxyfwwnmwuwcncpri6ljnjtbwgaxajaw`
        URL: https://holesky.etherscan.io/address/0x5a31b9407095dd9a295139c4f0183c076051632d
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Warning: Verification is still pending...; waiting 15 seconds before trying again (7 tries remaining)
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (1) contracts were verified!

Transactions saved to: /Users/qiaopengjun/Code/Rust/rust-chain/contracts/broadcast/Counter.s.sol/17000/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/Rust/rust-chain/contracts/cache/Counter.s.sol/17000/run-latest.json


```

### 浏览器查看合约

<https://holesky.etherscan.io/address/0x5a31b9407095dd9a295139c4f0183c076051632d#code>

![image-20250507202835619](/images/image-20250507202835619.png)

### 查看项目目录结构

```bash
rust-chain on  master [+?] is 📦 0.1.0 via 🦀 1.86.0 
➜ tree . -L 6 -I "out|lib|cache|broadcast|target"
.
├── Cargo.lock
├── Cargo.toml
├── contracts
│   ├── foundry.toml
│   ├── note.md
│   ├── README.md
│   ├── remappings.txt
│   ├── script
│   │   └── Counter.s.sol
│   ├── src
│   │   └── Counter.sol
│   └── test
│       └── Counter.t.sol
├── src
│   ├── counter.json
│   ├── counter.rs
│   ├── lib.rs
│   ├── main.rs
│   └── routes.rs
└── test.http

6 directories, 15 files
```

### ABI 文件 counter.json

```json
[
  {
    "inputs": [],
    "name": "increment",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "number",
    "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "uint256", "name": "newNumber", "type": "uint256" }
    ],
    "name": "setNumber",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]

```

### counter.rs 文件

```rust
use std::sync::Arc;

use ethers::{
    contract::{ContractError, abigen},
    providers::{Http, Provider},
    types::{Address, U256},
};

abigen!(CounterContract, "./src/counter.json");

#[derive(Debug, Clone)]
pub struct Counter {
    pub client: Arc<Provider<Http>>,
    pub contract: CounterContract<Provider<Http>>,
}

impl Counter {
    pub fn new(provider: Arc<Provider<Http>>, address: Address) -> Self {
        let contract = CounterContract::new(address, provider.clone());
        Self {
            client: provider,
            contract,
        }
    }

    pub async fn get_number(&self) -> Result<U256, ContractError<Provider<Http>>> {
        let number = self.contract.number().call().await?;
        Ok(number)
    }
}

```

### routes.rs 文件

```rust
use axum::{
    Extension, Json,
    http::StatusCode,
    response::{IntoResponse, Response},
};
use ethers::{
    contract::ContractError,
    providers::{Http, Middleware, Provider, ProviderError},
};
use thiserror::Error;
use tracing::info;

use crate::counter::Counter;

#[derive(Debug, Error)]
pub enum ApiError {
    #[error(": ContractError {0}")]
    ContractError(#[from] ContractError<Provider<Http>>),
    #[error(": ProviderError {0}")]
    ProviderError(#[from] ProviderError),
}

impl IntoResponse for ApiError {
    fn into_response(self) -> Response {
        let body = match self {
            Self::ContractError(e) => format!("Contract Error: {}", e),
            Self::ProviderError(e) => format!("Provider Error: {}", e),
        };
        (StatusCode::INTERNAL_SERVER_ERROR, body).into_response()
    }
}

pub async fn handle_number(
    Extension(counter): Extension<Counter>,
) -> Result<Json<String>, ApiError> {
    info!("Getting number");

    let number = counter.get_number().await?;
    Ok(Json(number.to_string()))
}

pub async fn handle_block_number(
    Extension(counter): Extension<Counter>,
) -> Result<Json<String>, ApiError> {
    info!("Getting block number");
    let block_number: u64 = counter.client.get_block_number().await?.as_u64();

    Ok(Json(block_number.to_string()))
}

```

### lib.rs 文件

```rust
pub mod counter;
pub mod routes;
```

### Cargo.toml 文件

```toml
[package]
name = "rust-chain"
version = "0.1.0"
edition = "2024"

[dependencies]
anyhow = "1.0.98"
dotenv = "0.15.0"
ethers = { version = "2.0.14", default-features = false, features = ["rustls"] }
tokio = { version = "1.45.0", features = ["full"] }
tracing = "0.1.41"
tracing-subscriber = "0.3.19"
axum = { version = "0.8.4", features = ["json"] }
thiserror = "2.0.12"
eyre = "0.6.12"
axum-macros = "0.5.0"

```

### 构建项目

**`cargo build`**: Rust 的构建命令，默认会：

- 编译当前项目及其依赖。
- 生成 **未优化的调试版本**（适合开发阶段）。

```bash
rust-chain on  master [+?] is 📦 0.1.0 via 🦀 1.86.0 took 1h 21m 13.5s 
➜ cargo build
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.53s

```

### 基本检查（当前包）

`cargo check` 是 Rust 的 **快速静态检查命令**，它只进行语法和类型检查，**不生成可执行文件**，因此速度比 `cargo build` 快很多。

```bash
rust-chain on  master [+?] is 📦 0.1.0 via 🦀 1.86.0 
➜ cargo check
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.50s

```

### **编译并运行**项目

`cargo run` 是 Rust 项目中用于 **编译并运行** 可执行程序的命令。它会自动处理代码编译（如果需要）并执行生成的二进制文件。

```bash
rust-chain on  master [+?] is 📦 0.1.0 via 🦀 1.86.0 
➜ cargo run  
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.42s
     Running `target/debug/rust-chain`
2025-05-08T11:14:33.351987Z  INFO rust_chain: listening on 127.0.0.1:8080


rust-chain on  master [+?] is 📦 0.1.0 via 🦀 1.86.0 
➜ cargo run  
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.42s
     Running `target/debug/rust-chain`
2025-05-08T11:14:33.351987Z  INFO rust_chain: listening on 127.0.0.1:8080
2025-05-08T12:59:16.022041Z  INFO rust_chain::routes: Getting number
2025-05-08T12:59:27.234464Z  INFO rust_chain::routes: Getting block number

```

### 测试

#### test.http 文件

请求：

```http
### hello world

GET http://127.0.0.1:8080/
Accept: application/json
Content-Type: application/json

### rust chain number

GET http://127.0.0.1:8080/api/number
Accept: application/json
Content-Type: application/json


### handle_block_number

GET http://127.0.0.1:8080/api/block_number
Accept: application/json
Content-Type: application/json

```

响应：

```bash
HTTP/1.1 200 OK
content-type: text/html; charset=utf-8
content-length: 22
connection: close
date: Thu, 08 May 2025 12:57:59 GMT

<h1>Hello, World!</h1>

HTTP/1.1 200 OK
content-type: application/json
content-length: 7
connection: close
date: Thu, 08 May 2025 12:59:16 GMT

"69420"

HTTP/1.1 200 OK
content-type: application/json
content-length: 9
connection: close
date: Thu, 08 May 2025 12:59:27 GMT

"3803337"

```

## 总结

“rust-chain”项目展现了Rust与Solidity在Web3开发中的强大潜力。从项目搭建到Counter智能合约的部署，再到Rust后端与区块链的无缝交互，本文完整呈现了构建Web3应用的全流程。借助Foundry的高效工具链和ethers-rs的灵活性，开发者能够快速开发、部署并验证智能合约，同时通过Axum框架提供可靠的API服务。项目成功在Holesky测试网运行，验证了技术的可行性与前景。这份实战教程为Web3开发者提供了宝贵参考，助你解锁区块链未来的无限可能！

## 参考

- <https://holesky.etherscan.io/address/0x5a31b9407095dd9a295139c4f0183c076051632d#readContract>
- <https://github.com/alloy-rs>
- <https://alloy.rs/>
- <https://alloy.rs/introduction/getting-started/>
- <https://github.com/gakonst/ethers-rs>
- <https://medium.com/@chalex-eth/how-to-build-a-web3-backend-in-rust-part-1-a92b649d42ad>
- <https://github.com/tokio-rs/axum/blob/main/examples/hello-world/src/main.rs>
- <https://github.com/chalex-eth/web3_rust_backend>
- <https://www.gakonst.com/ethers-rs/>
- <https://github.com/tokio-rs/axum/blob/main/examples/handle-head-request/src/main.rs>
- <https://github.com/chalex-eth/awesome-ethers-rs>
- <https://github.com/qiaopengjun5162/rust-chain>
![hua](https://learnblockchain.cn/image/avatar/18602_big.jpg)
