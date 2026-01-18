+++
title = "Polkadot 开发实战：EVM 兼容环境搭建与账号体系解析"
description = "Polkadot 开发实战：EVM 兼容环境搭建与账号体系解析"
date = 2026-01-18T09:16:17Z
[taxonomies]
categories = ["Web3", "Polkadot", "Solidity", "EVM"]
tags = ["Web3", "Polkadot", "Solidity", "EVM"]
+++

<!-- more -->

# **Polkadot 开发实战：EVM 兼容环境搭建与账号体系解析**

对于习惯了以太坊开发的 Solidity 工程师来说，进入 Polkadot 生态不仅是语言的迁移，更是对底层架构认知的更新。Polkadot 通过 Revive 模块提供了对 EVM 的兼容支持，但这并不意味着完全照搬。

本文将从最基础的“克隆代码”开始，带你一步步完成 Polkadot SDK 的编译和 RPC 服务的启动，跑通本地测试节点。在实操之外，我们将重点探讨 Polkadot 独特的 SS58 账号体系、签名算法的区别，以及在 Revive 环境下计算 Gas 的三个关键维度。这是一份旨在解决“环境怎么搭”和“概念怎么懂”的实务笔记。

本文记录了 Polkadot 上 Solidity 开发者的入门实操路径。内容涵盖 Polkadot SDK 源码编译、RPC 服务与节点启动的完整流程。同时深入解析 SS58 账号体系、多种签名算法及 Revive 环境下的多维 Gas 计算机制，并通过习题帮助开发者理清 EVM 与 PVM 的异同。

## 实操

Polkadot 上的 Solidity 与 EVM 开发者路径

### 克隆下载项目

```bash
git clone git@github.com:qiaopengjun5162/polkadot-sdk.git
```

### 切换到项目目录

```bash
cd polkadot-sdk/
```

### 编译 rpc 服务

```bash
cargo build --release -p pallet-revive-eth-rpc
```

#### 实操

```bash
polkadot-sdk on  master [?] via 🦀 1.92.0
➜ cargo build --release -p pallet-revive-eth-rpc
warning: unused import: `vec`
   --> substrate/frame/message-queue/src/lib.rs:208:13
    |
208 | use alloc::{vec, vec::Vec};
    |             ^^^
    |
    = note: `#[warn(unused_imports)]` (part of `#[warn(unused)]`) on by default

warning: `pallet-message-queue` (lib) generated 1 warning (run `cargo fix --lib -p pallet-message-queue` to apply 1 suggestion)
warning: unused import: `vec`
  --> polkadot/runtime/common/src/crowdloan/mod.rs:58:13
   |
58 | use alloc::{vec, vec::Vec};
   |             ^^^
   |
   = note: `#[warn(unused_imports)]` (part of `#[warn(unused)]`) on by default

warning: unused import: `vec`
  --> polkadot/runtime/common/src/paras_registrar/mod.rs:22:13
   |
22 | use alloc::{vec, vec::Vec};
   |             ^^^

warning: unused import: `vec`
  --> polkadot/runtime/common/src/slots/mod.rs:28:13
   |
28 | use alloc::{vec, vec::Vec};
   |             ^^^

warning: `polkadot-runtime-common` (lib) generated 3 warnings (run `cargo fix --lib -p polkadot-runtime-common` to apply 3 suggestions)
   Compiling libz-sys v1.1.12
warning: revive-dev-runtime@0.1.0: You are building WASM runtime using `wasm32-unknown-unknown` target, although Rust >= 1.84 supports `wasm32v1-none` target!
warning: revive-dev-runtime@0.1.0: You can install it with `rustup target add wasm32v1-none --toolchain stable-aarch64-apple-darwin` if you're using `rustup`.
warning: revive-dev-runtime@0.1.0: After installing `wasm32v1-none` target, you must rebuild WASM runtime from scratch, use `cargo clean` before building.
   Compiling libgit2-sys v0.18.0+1.9.0
   Compiling git2 v0.20.0
   Compiling pallet-revive-eth-rpc v0.1.0 (/Users/qiaopengjun/Code/Polkadot/polkadot-sdk/substrate/frame/revive/rpc)
    Finished `release` profile [optimized] target(s) in 32.26s
```

### 启动RPC服务

```bash
polkadot-sdk on  master [?] via 🦀 1.92.0 took 3.1s
➜ target/release/eth-rpc
2026-01-16 20:45:32 🌐 Connecting to node at: ws://127.0.0.1:9944 ...
2026-01-16 20:45:32 🌟 Connected to node at: ws://127.0.0.1:9944
2026-01-16 20:45:32 💾 Using in-memory database, keeping only 256 blocks in memory
2026-01-16 20:45:32 Node does not have getAutomine RPC. Defaulting to automine=false. error: User(UserError { code: -32601, message: "Method not found", data: None })
2026-01-16 20:45:32 〽️ Prometheus exporter started at 127.0.0.1:9616
2026-01-16 20:45:32 Running JSON-RPC server: addr=127.0.0.1:8545,[::1]:8545
2026-01-16 20:45:32 🔌 Subscribing to new blocks (BestBlocks)
2026-01-16 20:45:32 🔌 Subscribing to new blocks (FinalizedBlocks)

```

![image-20260116205847441](/images/image-20260116205847441.png)

### 编译Node节点服务

```bash
cargo build --release --bin substrate-node

## 实操
polkadot-sdk on  master [?] via 🦀 1.92.0
➜ cargo build --release --bin substrate-node
warning: unused import: `vec`
   --> substrate/frame/message-queue/src/lib.rs:208:13
    |
208 | use alloc::{vec, vec::Vec};
    |             ^^^
    |
    = note: `#[warn(unused_imports)]` (part of `#[warn(unused)]`) on by default

warning: `pallet-message-queue` (lib) generated 1 warning (run `cargo fix --lib -p pallet-message-queue` to apply 1 suggestion)
warning: unused import: `vec`
  --> polkadot/runtime/common/src/crowdloan/mod.rs:58:13
   |
58 | use alloc::{vec, vec::Vec};
   |             ^^^
   |
   = note: `#[warn(unused_imports)]` (part of `#[warn(unused)]`) on by default

warning: unused import: `vec`
  --> polkadot/runtime/common/src/paras_registrar/mod.rs:22:13
   |
22 | use alloc::{vec, vec::Vec};
   |             ^^^

warning: unused import: `vec`
  --> polkadot/runtime/common/src/slots/mod.rs:28:13
   |
28 | use alloc::{vec, vec::Vec};
   |             ^^^

warning: `polkadot-runtime-common` (lib) generated 3 warnings (run `cargo fix --lib -p polkadot-runtime-common` to apply 3 suggestions)
warning: `pallet-message-queue` (lib) generated 1 warning (1 duplicate)
⚡ Found 4 strongly connected components which includes at least one cycle each
cycle(001) ∈ α: DisputeCoordinator ~~{"DisputeDistributionMessage"}~~> DisputeDistribution ~~{"DisputeCoordinatorMessage"}~~>  *
cycle(002) ∈ β: ApprovalVoting ~~{"ApprovalDistributionMessage"}~~> ApprovalDistribution ~~{"ApprovalVotingMessage"}~~>  *
cycle(003) ∈ γ: CandidateBacking ~~{"CollatorProtocolMessage"}~~> CollatorProtocol ~~{"CandidateBackingMessage"}~~>  *
cycle(004) ∈ δ: NetworkBridgeRx ~~{"GossipSupportMessage"}~~> GossipSupport ~~{"NetworkBridgeRxMessage"}~~>  *
⚡ Found 4 strongly connected components which includes at least one cycle each
cycle(001) ∈ α: DisputeCoordinator ~~{"DisputeDistributionMessage"}~~> DisputeDistribution ~~{"DisputeCoordinatorMessage"}~~>  *
cycle(002) ∈ β: ApprovalVoting ~~{"ApprovalDistributionMessage"}~~> ApprovalDistribution ~~{"ApprovalVotingMessage"}~~>  *
cycle(003) ∈ γ: CandidateBacking ~~{"CollatorProtocolMessage"}~~> CollatorProtocol ~~{"CandidateBackingMessage"}~~>  *
cycle(004) ∈ δ: NetworkBridgeRx ~~{"GossipSupportMessage"}~~> GossipSupport ~~{"NetworkBridgeRxMessage"}~~>  *
warning: frame-storage-access-test-runtime@0.1.0: You are building WASM runtime using `wasm32-unknown-unknown` target, although Rust >= 1.84 supports `wasm32v1-none` target!
warning: frame-storage-access-test-runtime@0.1.0: You can install it with `rustup target add wasm32v1-none --toolchain stable-aarch64-apple-darwin` if you're using `rustup`.
warning: frame-storage-access-test-runtime@0.1.0: After installing `wasm32v1-none` target, you must rebuild WASM runtime from scratch, use `cargo clean` before building.
warning: frame-storage-access-test-runtime@0.1.0: You are building WASM runtime using `wasm32-unknown-unknown` target, although Rust >= 1.84 supports `wasm32v1-none` target!
warning: frame-storage-access-test-runtime@0.1.0: You can install it with `rustup target add wasm32v1-none --toolchain stable-aarch64-apple-darwin` if you're using `rustup`.
warning: frame-storage-access-test-runtime@0.1.0: After installing `wasm32v1-none` target, you must rebuild WASM runtime from scratch, use `cargo clean` before building.
warning: unused import: `crate::log`
  --> substrate/frame/nomination-pools/src/migration.rs:19:5
   |
19 | use crate::log;
   |     ^^^^^^^^^^
   |
   = note: `#[warn(unused_imports)]` (part of `#[warn(unused)]`) on by default

warning: `pallet-nomination-pools` (lib) generated 1 warning (run `cargo fix --lib -p pallet-nomination-pools` to apply 1 suggestion)
warning: unused import: `vec`
  --> substrate/frame/state-trie-migration/src/lib.rs:80:14
   |
80 |     use alloc::{vec, vec::Vec};
   |                 ^^^
   |
   = note: `#[warn(unused_imports)]` (part of `#[warn(unused)]`) on by default

warning: `pallet-state-trie-migration` (lib) generated 1 warning (run `cargo fix --lib -p pallet-state-trie-migration` to apply 1 suggestion)
warning: value assigned to `i` is never read
  --> substrate/frame/examples/tasks/src/lib.rs:59:32
   |
59 |         pub fn add_number_into_total(i: u32) -> DispatchResult {
   |                                      ^
   |
   = help: maybe it is overwritten before being read?
   = note: `#[warn(unused_assignments)]` (part of `#[warn(unused)]`) on by default

warning: kitchensink-runtime@3.0.0-dev: You are building WASM runtime using `wasm32-unknown-unknown` target, although Rust >= 1.84 supports `wasm32v1-none` target!
warning: kitchensink-runtime@3.0.0-dev: You can install it with `rustup target add wasm32v1-none --toolchain stable-aarch64-apple-darwin` if you're using `rustup`.
warning: kitchensink-runtime@3.0.0-dev: After installing `wasm32v1-none` target, you must rebuild WASM runtime from scratch, use `cargo clean` before building.
warning: `pallet-example-tasks` (lib) generated 1 warning
    Finished `release` profile [optimized] target(s) in 2.71s

```

### 启动运行Node节点服务

```bash
target/release/substrate-node

target/release/substrate-node --dev --tmp

# 实操
polkadot-sdk on  master [?] via 🦀 1.92.0
➜ target/release/substrate-node --dev --tmp
2026-01-16 20:43:58 Substrate Node
2026-01-16 20:43:58 ✌️  version 3.0.0-dev-62fa27df30d
2026-01-16 20:43:58 ❤️  by Parity Technologies <admin@parity.io>, 2017-2026
2026-01-16 20:43:58 📋 Chain specification: Development
2026-01-16 20:43:58 🏷  Node name: disgusting-hobbies-0251
2026-01-16 20:43:58 👤 Role: AUTHORITY
2026-01-16 20:43:58 💾 Database: RocksDb at /var/folders/fw/s14m5tcs46j9t16ph766kc9h0000gn/T/substrateNaQTlJ/chains/dev/db/full
2026-01-16 20:44:04 🔨 Initializing Genesis block/state (state: 0xfe53…3782, header-hash: 0x6968…cef5)
2026-01-16 20:44:04 Creating transaction pool txpool_type=ForkAware ready=Limit { count: 8192, total_bytes: 20971520 } future=Limit { count: 819, total_bytes: 2097152 }
2026-01-16 20:44:04 👴 Loading GRANDPA authority set from genesis on what appears to be first startup.
2026-01-16 20:44:04 👶 Creating empty BABE epoch changes on what appears to be first startup.
2026-01-16 20:44:04 Using default protocol ID "sup" because none is configured in the chain specs
2026-01-16 20:44:04 Local node identity is: 12D3KooWQwWcZvzydNgcBxQYsxWBPiHLYMeTo1HbibDMX8X1HRRk
2026-01-16 20:44:04 Running litep2p network backend
2026-01-16 20:44:04 💻 Operating system: macos
2026-01-16 20:44:04 💻 CPU architecture: aarch64
2026-01-16 20:44:04 📦 Highest known block at #0
2026-01-16 20:44:04 〽️ Prometheus exporter started at 127.0.0.1:9615
2026-01-16 20:44:04 Running JSON-RPC server: addr=127.0.0.1:9944,[::1]:9944
2026-01-16 20:44:04 🏁 CPU single core score: 938.56 MiBs, parallelism score: 999.59 MiBs with expected cores: 8
2026-01-16 20:44:04 🏁 Memory score: 45.80 GiBs
2026-01-16 20:44:04 🏁 Disk score (seq. writes): 2.10 GiBs
2026-01-16 20:44:04 🏁 Disk score (rand. writes): 509.01 MiBs
2026-01-16 20:44:04 ⚠️  The hardware does not meet the minimal requirements Failed checks: BLAKE2-256(expected: 1000.00 MiBs, found: 938.56 MiBs),  for role 'Authority'.
2026-01-16 20:44:04 👶 Starting BABE Authorship worker
2026-01-16 20:44:04 Failed to load AddrCache from file, using empty instead: Failed to encode or decode AddrCache.
2026-01-16 20:44:04 Loaded persisted AddrCache with 0 authority ids.
2026-01-16 20:44:04 🥩 BEEFY gadget waiting for BEEFY pallet to become available...
2026-01-16 20:44:04 Successfully persisted AddrCache on disk
2026-01-16 20:44:06 🙌 Starting consensus session on top of parent 0x6968f8193a57adb417f80d9935b4dd94c43605e30e0b7740bef49625d7d3cef5 (#0)
2026-01-16 20:44:06 🎁 Prepared block for proposing at 1 (8 ms) hash: 0x5b825df258a4217a5cbccab9c0d77f8cf4511221f5f38fb4ede982edc22242d9; parent_hash: 0x6968…cef5; end: NoMoreTransactions; extrinsics_count: 2
2026-01-16 20:44:06 🔖 Pre-sealed block for proposal at 1. Hash now 0xf03f9d7315ef09b7933cf1c04861b7bf698be2f8a1b2906bc809d63dbc8adde1, previously 0x5b825df258a4217a5cbccab9c0d77f8cf4511221f5f38fb4ede982edc22242d9.
2026-01-16 20:44:06 👶 New epoch 0 launching at block 0xf03f…dde1 (block slot 589522482 >= start slot 589522482).
2026-01-16 20:44:06 👶 Next epoch starts at slot 589522682
2026-01-16 20:44:06 🏆 Imported #1 (0x6968…cef5 → 0xf03f…dde1)
2026-01-16 20:44:09 🙌 Starting consensus session on top of parent 0xf03f9d7315ef09b7933cf1c04861b7bf698be2f8a1b2906bc809d63dbc8adde1 (#1)
2026-01-16 20:44:09 🎁 Prepared block for proposing at 2 (6 ms) hash: 0x63e6683df8dd34b8a24e14ade1a5392373ddfd1e2ea421bf74815c102b0bca29; parent_hash: 0xf03f…dde1; end: NoMoreTransactions; extrinsics_count: 2
```

![image-20260116205821908](/images/image-20260116205821908.png)

## 波卡账号体系

- 公私钥体系与资产：区块链的基石，身份验证，签名交易和资产控制
- 什么是账号：通过对公钥的处理，得到一个方便记录和处理的字符串
- 什么是波卡的SS58账号：公钥加上前缀，再通过Base58进行编码

## 波卡签名算法

- Sr25519：Curve25519曲线，基于Schnorr签名算法，多签高效。Schnorr 是基于离散对数问题的签名算法，比 ECDSA 更简洁、更容易做多签和聚合。
- EDDSA：Curve25519曲线，EdDSA签名算法，签名和验证高效
- ECDSA：secp256k1曲线，和以太坊相同

## EVM 和 Hub 执行环境区别

- 三个维度来计算Gas
  - Ref_time 计算花费的时间
  - Proof_size 存贮数据大小
  - Storage_deposit 可以收回的状态存贮
- ED existential deposit 账号最小存贮，小于则会被回收
- Memory Limit for Contract

## 练习一

### 1. Solidity 和 EVM 的关系？

- Language and execution VM 编程语言和执行的虚拟机
- EVM can support other language EVM也可以执行其他的语言
- EVM depends on block status EVM依赖区块的状态

### 2. 波卡是否支持 Solidity？  Yes

### 3. 合约的 bytecode 是可修改的吗？IM（Immutable，不可修改）

### 4. 波卡虚拟机 PVM 可以执行 EVM 的 bytecode 吗？ No

### 5. 波卡出现过哪些智能合约平台？Frontier、 Ink

## 练习二

### 1. 波卡的SS58帐号在每条链上都一样吗？ 根据prefix不同

### 2. 波卡支持的签名算法？ sr25519、ed25519、ECDSA

### 3. 波卡Revive计算gas的维度？ref_time、proof_size、storage deposit

### 4. Revive precompile的地址分配？不同类型有自己的空间

### 5. Revive precompile应该如何调用？要根据每个precompile的定义，有的可以选择selector

## 总结

通过本次实操，我们成功从源码编译并启动了支持 Ethereum RPC 的 Polkadot 节点，验证了本地开发环境的可用性。

从技术路径上看，虽然 Solidity 依然是主要编程语言，但 Polkadot 在底层逻辑上展现了其独特性：

1. **账号更灵活**：SS58 格式与多种签名算法（Sr25519/EdDSA/ECDSA）的并存，为账户抽象提供了原生支持。
2. **资源模型更精细**：不同于以太坊单一的 Gas 计费，Polkadot Revive 引入了 `Ref_time`（计算时间）、`Proof_size`（存储数据）和 `Storage_deposit`（状态存储）三个维度，要求开发者对合约资源消耗有更精准的把控。
3. **虚拟机隔离**：明确了 PVM 与 EVM 的界限，虽然 PVM 不直接执行 EVM 字节码，但通过兼容层实现了逻辑互通。

掌握这些基础，是进一步在 Polkadot 上构建高性能 DApp 的前提。

## 参考

- <https://docs.polkadot.com/>
- <https://rust-lang.org/>
- <https://nodejs.org/en>
- <https://www.typescriptlang.org/>
- <https://hardhat.org/>
- <https://chromewebstore.google.com/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn?pli=1>
- <https://docs.polkadot.com/develop/smart-contracts/wallets/>
- <https://docs.polkadot.com/develop/smart-contracts/connect-to-polkadot/>
- <https://faucet.polkadot.io/?parachain=1111>
- <https://youtube.com/playlist?list=PLKgwQU2jh_H8zyq46XsUkAz10213HDL0i&si=UqonC3oL304_Mtrk>
- <https://github.com/paritytech/polkadot-sdk>
- <https://testnet-passet-hub-eth-rpc.polkadot.io>
