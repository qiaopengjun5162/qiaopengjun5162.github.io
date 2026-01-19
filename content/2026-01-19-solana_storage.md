+++
title = "拒绝“版本代差”：基于 Solana SDK V3 的「链上动态存储器」工业级实现"
description = "拒绝“版本代差”：基于 Solana SDK V3 的「链上动态存储器」工业级实现"
date = 2026-01-19T12:31:37Z
[taxonomies]
categories = ["Web3", "Solana", "Rust"]
tags = ["Web3", "Solana", "Rust"]
+++

<!-- more -->

# **拒绝“版本代差”：基于 Solana SDK V3 的「链上动态存储器」工业级实现**

在 Solana 生态快速更迭的今天，开发者面临最大的技术风险在于“代码版本代差”。目前中文社区多数教程仍停留在 SDK v1.x 阶段，导致开发者在处理账户扩容与指针逻辑时，往往采用过时且高风险的实现方式。

本文将跳过基础的静态示例，直接切入**工业级动态存储方案**。我们将利用 SDK V3 提供的 `AccountInfo::resize` 与标准 CPI 接口，构建一个能够随数据量变化而自动调整空间及租金的智能合约，这才是适配现代 Solana 应用（如游戏存档、动态元数据存储）的标准实践。

本文深入探讨了 Solana SDK V3 标准下的链上数据管理方案。通过引入 **PDA（程序派生账户）权限隔离**、**V3 原生 Resize 动态扩容**以及**租金自动平衡（Auto-Refunder）**机制，实现了一个可变长度、按需付费、安全可靠的「链上数据存储器」。方案不仅展示了最新的 Rust 合约编写规范，还结合 `pxsol` 工具演示了现代化的分片部署流程，旨在帮助开发者彻底清理基于 SDK v1.x 的历史技术债。

假设你正在开发一个去中心化应用，需要让用户在链上存储数据——可能是游戏存档、用户配置、文档哈希或任何需要持久化的信息。这个数据应该：

- **属于用户本人**：其他人无法覆盖或篡改。
- **支持随时更新**：数据长度可以变化（字符串变长或变短）。
- **按需付费**：不浪费存储空间和租金。

我们要构建的「**链上数据存储器**」正是为了满足这些需求。每个用户拥有一个专属的数据账户，可以自由地写入和更新数据。

## 功能设计

程序提供两个核心功能（指令）：

### 1. 初始化数据账户 (Initialize)

用户首次使用时，程序会为其创建一个 **PDA (Program Derived Address)** 作为数据存储账户。

- **寻址**：使用 `[User_PublicKey, "storage"]` 作为种子，确保每个用户有且仅有一个对应的存储账户。
- **租金**：系统根据初始数据的长度，自动计算所需的 Lamports，并从用户钱包扣除，存入该 PDA 以达成租赁豁免。

### 2. 更新数据内容 (Update)

- 这是 SDK V3 的精髓所在。程序利用 `resize` 功能动态调整账户大小：
  - **扩容 (Resize)**：新数据更长，程序计算差额并要求用户补交租金。
  - **缩容 (Refund)**：新数据更短，程序释放空间并将多余租金退还用户。

> **原理提示：**
>
> - **扩容补钱**：必须通过 `System Program Transfer`（需要用户签名）。
>
> - **缩容退钱**：可直接修改 `lamports` 余额（因为 PDA 的所有者是本程序）。

## 实操

### 初始化 Rust 项目

```bash
cargo new --lib solana-storage
cd solana-storage

# 实操
cargo new --lib solana-storage
    Creating library `solana-storage` package
note: see more `Cargo.toml` keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

cd solana-storage

```

### 查看项目目录结构

```bash
solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0
➜ tree . -L 6 -I "docs|target|node_modules|build"
.
├── Cargo.lock
├── Cargo.toml
├── rust-toolchain.toml
└── src
    └── lib.rs

2 directories, 4 files
```

## 🛠 开发环境与配置

### `Cargo.toml` 文件

### 现代化的 Cargo.toml

注意：我们启用了 `edition = "2024"` 以及 **Solana SDK 3.0** 系列组件。

```toml
cargo-features = ["edition2024"]

[package]
name = "solana-storage"
version = "0.1.0"
edition = "2024"

[lib]
crate-type = ["cdylib", "lib"]

[dependencies]
solana-cpi = "3.1.0"
solana-program = "3.0.0"
solana-system-interface = { version = "3.0", features = ["bincode"] }

# 允许 Solana 特定的 cfg 值，避免编译警告
[lints.rust]
unexpected_cfgs = { level = "allow" }

```

### 关键配置说明

- **crate-type = ["cdylib", "lib"]**:
  - **cdylib**: 生成 C 兼容的动态库（`.so` 文件）。这是部署到 Solana BPF 虚拟机所**必需**的格式。
  - **lib**: 生成标准的 Rust 库（`.rlib` 文件）。这方便你在本地编写单元测试和集成测试，无需每次都部署到链上。
- **solana-program**: 这是 Solana 开发的核心标准库，提供了账户信息、公钥、程序结果等基础类型的定义。

## 💻 核心逻辑实现 (lib.rs)

### `lib.rs` 文件

这份代码展示了 V3 标准下处理账户伸缩的最佳实践：

```rust
use solana_program::{
    account_info::{AccountInfo, next_account_info},
    entrypoint,
    entrypoint::ProgramResult,
    msg,
    program_error::ProgramError,
    pubkey::Pubkey,
    rent::Rent,
    sysvar::Sysvar,
};

use solana_cpi::{invoke, invoke_signed};
use solana_system_interface::instruction::{create_account, transfer};

// 1. 定义程序入口点
entrypoint!(process_instruction);

#[allow(unused_variables)]
// 2. 处理指令的核心逻辑
pub fn process_instruction(
    program_id: &Pubkey,      // 这个程序自己的 ID
    accounts: &[AccountInfo], // 交易涉及的所有账户
    data: &[u8],              // 传递给程序的参数（字节数组）
) -> ProgramResult {
    msg!("Hello Solana! program_id: {:?}", program_id);

    // 1. 账户提取
    let accounts_iter = &mut accounts.iter(); // 钱包
    // 1.1 付款人 (必须签名)
    let account_user = next_account_info(accounts_iter)?;
    if !account_user.is_signer {
        return Err(ProgramError::MissingRequiredSignature);
    }

    // 1.2. 数据账户 (PDA)
    let account_data = next_account_info(accounts_iter)?; // PDA 数据账户

    // 1.3. 系统程序
    let system_program = next_account_info(accounts_iter)?; // 系统程序

    // 2. 准备工作：计算租金和 PDA 种子
    // 计算租金
    let rent_exemption = Rent::get()?.minimum_balance(data.len());

    // 派生 PDA
    let (pda_key, bump_seed) =
        Pubkey::find_program_address(&[account_user.key.as_ref()], program_id);
    if pda_key != *account_data.key {
        msg!("错误: PDA 地址不匹配");
        return Err(ProgramError::InvalidAccountData);
    }

    // 3. 分支逻辑 A：如果账户不存在 (余额为0)，则创建
    // 只有当账户为空时才创建
    if account_data.lamports() == 0 {
        msg!("分支 A: 创建新 PDA 账户");
        // CPI 调用
       // 这是因为付款人是用户（非程序所能控制），所以必须通过 System Program 进行正式转账；而“退钱”可以直接修改 Lamports 是因为 PDA 的所有权属于本程序。
        invoke_signed(
            &create_account(
                account_user.key,
                account_data.key,
                rent_exemption,    // 初始租金
                data.len() as u64, // 初始空间
                program_id,
            ),
            &[
                account_user.clone(),
                account_data.clone(),
                system_program.clone(),
            ],
            &[&[account_user.key.as_ref(), &[bump_seed]]], // 签名种子：证明我是 PDA 的主人
        )?;
    } else {
        msg!("分支 B: 更新现有账户并调整空间");

        // 安全检查：只有该程序拥有的账户才能 resize
        if account_data.owner != program_id {
            return Err(ProgramError::IllegalOwner);
        }

        // 步骤 1: 物理扩容/缩容 (SDK v3 重要操作)
        account_data.resize(data.len())?;

        // 步骤 2: 租金平衡
        // 4. 分支逻辑 B：如果账户已存在，则更新
        let current_lamports = account_data.lamports();
        // 情况 B1: 新数据更长 -> 补交租金
        if rent_exemption > current_lamports {
            // 补钱：必须通过 System Program Transfer
            let diff = rent_exemption - current_lamports;
            invoke(
                &transfer(account_user.key, account_data.key, diff),
                &[
                    account_user.clone(),
                    account_data.clone(),
                    system_program.clone(),
                ],
            )?;
            // 情况 B2: 新数据更短 -> 退还租金
        } else if rent_exemption < current_lamports {
            // 退钱：手动调整（因为 PDA 归本程序管）
            let diff = current_lamports - rent_exemption;
            **account_data.try_borrow_mut_lamports()? -= diff;
            **account_user.try_borrow_mut_lamports()? += diff;
        }
    }

    // 5. 写入数据
    // 此时 resize 已经保证了空间足够，rent 平衡保证了免租金
    account_data.data.borrow_mut().copy_from_slice(data);
    msg!("数据写入成功，长度: {}", data.len());

    Ok(())
}

```

## 🚀 编译与部署全链路

### 编译构建

```bash
solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0
➜ cargo update blake3 --precise 1.8.2
    Updating crates.io index
 Downgrading blake3 v1.8.3 -> v1.8.2
 Downgrading constant_time_eq v0.4.2 -> v0.3.1
note: pass `--verbose` to see 2 unchanged dependencies behind latest


solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0
➜ cargo build-sbf
   Compiling solana-storage v0.1.0 (/Users/qiaopengjun/Code/Solana/solana-storage)
    Finished `release` profile [optimized] target(s) in 0.76s

```

### 核心区别对比

| **特性**       | **cargo build-sbf**      | **cargo build-sbf -- -Znext-lockfile-bump**                  |
| -------------- | ------------------------ | ------------------------------------------------------------ |
| **功能稳定性** | **Stable (稳定)**        | **Experimental (实验性)**                                    |
| **依赖处理**   | 遵循现有的依赖更新机制。 | 使用实验性的依赖版本提升（bump）逻辑。                       |
| **适用人群**   | 绝大多数开发者。         | 需要测试 Cargo 新特性或解决特定依赖锁定问题的核心开发者。    |
| **风险**       | 低。                     | 中（由于是 `-Z` 参数，可能在未来的 Cargo 版本中改变或消失）。 |

简单来说：除非你遇到了特定的依赖锁定问题，否则没必要加后面那一串。

**正式编译**：

```bash
solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0
➜ cargo build-sbf -- -Znext-lockfile-bump
    Finished `release` profile [optimized] target(s) in 0.28s
```

**查看合约大小**（Solana 合约越小，部署成本越低）：

```bash
solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0
➜ ls -lh target/deploy/*.so

-rwxr-xr-x@ 1 qiaopengjun  staff    79K Jan 17 20:12 target/deploy/solana_storage.so

solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0
➜ wc -c < ./target/deploy/solana_storage.so
   81176
```

计算此大小（字节）所需的 SOL：

```bash
solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0
➜ solana rent 81176
Rent-exempt minimum: 0.56587584 SOL

```

## 部署程序

### 方案 A：Solana CLI (传统部署)

#### 第一步：配置 Solana CLI 以使用本地 Solana 集群

```bash
solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0
➜ solana address
6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd

solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0
➜ solana config get
Config File: /Users/qiaopengjun/.config/solana/cli/config.yml
RPC URL: https://api.devnet.solana.com
WebSocket URL: wss://api.devnet.solana.com/ (computed)
Keypair Path: /Users/qiaopengjun/.config/solana/id.json
Commitment: confirmed

solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0
➜ solana config set -ul
Config File: /Users/qiaopengjun/.config/solana/cli/config.yml
RPC URL: http://localhost:8899
WebSocket URL: ws://localhost:8900/ (computed)
Keypair Path: /Users/qiaopengjun/.config/solana/id.json
Commitment: confirmed
```

#### 第二步：启动 **Solana 本地测试节点**

```bash
solana-test-validator -r
Ledger location: test-ledger
Log: test-ledger/validator.log
⠂ Initializing...                                                                                                                                          Waiting for fees to stabilize 1...
⠴ Initializing...                                                                                                                                          Waiting for fees to stabilize 2...
Identity: 6SuxsNGUsCnYahf5fi9u8n1tS6Ma924FXShcc2CQVaGU
Genesis Hash: DkFxoK6EBR4s7za1Pqbqfx8UrstxN9smJGMbFLB5m7T3
Version: 3.0.13
Shred Version: 36009
Gossip Address: 127.0.0.1:8000
TPU Address: 127.0.0.1:8003
JSON RPC URL: http://127.0.0.1:8899
WebSocket PubSub URL: ws://127.0.0.1:8900
⠈ 00:00:09 | Processed Slot: 20 | Confirmed Slot: 20 | Finalized Slot: 0 | Full Snapshot Slot: - | Incremental Snapshot Slot: - | Transactions: 19 | ◎499.9
```

#### 第三步：执行本地部署

```bash
solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0
➜ solana program deploy ./target/deploy/solana_storage.so
Program Id: jNPVTP8iNmbJnXAa1KgLKwLxBkdcVvKLaMYaahiWxFU

Signature: qgWcQX1STrmH3C7yZ6yhUAKEEd7Z3E6PvMqUMdhvdR9K5utjFnjpBVnJwv16Q6maPoguc9ActhUUUehqKW4DbRY

```

![image-20260117230633975](/images/image-20260117230633975.png)

#### 第四步：查看部署程序详细信息

```bash
solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0 took 3.1s
➜ solana program show jNPVTP8iNmbJnXAa1KgLKwLxBkdcVvKLaMYaahiWxFU

Program Id: jNPVTP8iNmbJnXAa1KgLKwLxBkdcVvKLaMYaahiWxFU
Owner: BPFLoaderUpgradeab1e11111111111111111111111
ProgramData Address: 58rFQHe9roeHWUxNdnX3X7LuQymki3re1hXMEpdySbRP
Authority: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
Last Deployed In Slot: 394123044
Data Length: 81176 (0x13d18) bytes
Balance: 0.56618904 SOL
```

### 方案 B：pxsol 分片部署 (推荐)

使用 Python 库 `pxsol` 的部署方式

#### 第一步：实现部署脚本

```python
# /// script
# dependencies = [
#   "pxsol",
# ]
# ///

import json
import pathlib
import pxsol

# 1. 基础配置：显式切换到开发网并指定本地 RPC 地址
pxsol.config.current = pxsol.config.develop
pxsol.config.current.rpc_url = "http://127.0.0.1:8899"
# 开启日志以便观察分片上传过程
pxsol.config.current.log = 1

# 2. 钱包加载
# 加载部署者的钱包 (需要有足够的 SOL 支付租金)
# 0x01 是示例私钥，实际请使用你的密钥文件
# ada = pxsol.wallet.Wallet(pxsol.core.PriKey.int_decode(0x01))

# 1. 准确定位路径
wallet_path = pathlib.Path.home() / ".config/solana/id.json"

# 2. 读取文件并转换
if not wallet_path.exists():
    raise FileNotFoundError(
        f"找不到钱包文件: {wallet_path}，请手动运行 solana-keygen new"
    )

with open(wallet_path, "r") as f:
    keypair_data = json.load(f)

# id.json 是 [私钥+公钥]，pxsol 的 PriKey 构造函数只需要前 32 字节
raw_prikey = bytearray(keypair_data[:32])
ada = pxsol.wallet.Wallet(pxsol.core.PriKey(raw_prikey))

print(f"🔑 钱包已准备就绪: {ada.pubkey}")

# 读取编译好的二进制文件
# program_data = pathlib.Path("target/deploy/solana_storage.so").read_bytes()

# 获取脚本所在目录的上一级，即项目根目录
base_path = pathlib.Path(__file__).parent.parent
so_path = base_path / "target/deploy" / "solana_storage.so"

# 读取数据
print(f"📦 正在读取合约: {so_path}")
program_data = so_path.read_bytes()


# 执行部署
# 这会在后台自动处理：创建Buffer -> 分片写入 -> Finalize
print("🚀 正在发起分片部署交易（这可能需要几十秒）...")
try:
    program_pubkey = ada.program_deploy(bytearray(program_data))
    print("\n" + "=" * 30)
    print("✅ 部署成功！")
    print(f"📜 Program ID: {program_pubkey}")
    print("=" * 30)
except Exception as e:
    print(f"❌ 部署失败: {e}")
    print("💡 提示：请检查本地 solana-test-validator 是否在运行，且钱包余额是否充足。")

```

#### 第二步：执行部署

```bash
solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0
➜ solana balance
10000 SOL

solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0
➜ uv run scripts/deploy.py
🔑 钱包已准备就绪: "6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd"
📦 正在读取合约: /Users/qiaopengjun/Code/Solana/solana-storage/target/deploy/solana_storage.so
🚀 正在发起分片部署交易（这可能需要几十秒）...
2026/01/18 20:45:39 pxsol: program buffer prikey="ERahdGytsuNzvuZQEpaiPGc4GNR3vPAimjcVBZEJUEfi"
2026/01/18 20:45:39 pxsol: program buffer pubkey="E49NDkrcQk1h6KzHYYFPSsASiVVKWo8ryERCWawfQ8Qv"
2026/01/18 20:45:39 pxsol: transaction send signature=5JYW1jKhc9pkuhpuz5RqkbKNGfFdApaKU5tKv3sh2U1LCegjtMWx2mmnx8VHN2So4tKAGjcYX9JyQChBmLeEVtDT
2026/01/18 20:45:39 pxsol: transaction wait unconfirmed=1
2026/01/18 20:45:40 pxsol: transaction wait unconfirmed=0
2026/01/18 20:45:40 pxsol: transaction send signature=2Jt19TbkVpUeScZB4okgJB4AF2EjgXD9q98cB27GiLnzZh6mvMefV62N7EToJZqYadqLS6665AdNt3oLyH36PHtu
2026/01/18 20:45:40 pxsol: transaction send signature=2cJmZXp5K89t8yiBHQGgPJEzLzbzf8WZnerRoxfQAMumseXnhoLfssGFqC85nTKU7FH2mFfp8mjVfST8UAkUgL9X
2026/01/18 20:45:40 pxsol: transaction send signature=FpzFmf1Q71JcArWNHDgPyWYoJhmH1r5jcQauvqs2V5f9YpW3brNKui4Ttkw3MCfPvDVBsqDfpHbLHE6sR2euKwt
2026/01/18 20:45:41 pxsol: transaction send signature=3GDmjo7KSfDdPHMJUo4Z8ecFi6r4fcoLAepukEDt48bSmcye6fWVqyDYwMKDPJyp5xApBPepXten945ty9hYJB9v
2026/01/18 20:45:41 pxsol: transaction send signature=3V35XGKJDPmFTYbQi8bsL46cos1knapJtB5S7q5bGm34qcEEQxf1CXrPb8Uk1zwEQnTc12ZC5TocuQSJkPnJ4kZP
2026/01/18 20:45:41 pxsol: transaction send signature=wGMgtBdMCgfLnkw1BsH8XwCkMkz7kfehKt5bM5CPRzhgTdCKkT212AeHkwgCQymD6fUyXPmRN8aSZG5aAAQpPu1
2026/01/18 20:45:41 pxsol: transaction send signature=Gj2Wn9ZnicwBj6279dVBQedEFeLUnMfRr1BC3NJL3jHyjNKSUfQNju19eRTSdLKehnUedMvFvWV6jvogDZyyJbn
2026/01/18 20:45:41 pxsol: transaction send signature=4vodzrEn34cXZSmVeowSZgxzkuRZLrSVXGk5gfcwW5bYxrEHWswD6cLkp6bKwEBHw5zvVM216A7Ba44HJhmyTfPk
2026/01/18 20:45:41 pxsol: transaction send signature=4uq6n42LZH6JRGQCF8QSECdehScBFw5miQ4j7xXguTrVPowZF5xPdHNXj7fYbja6vQC7khcpUv5thdpfkrq2SCfb
2026/01/18 20:45:41 pxsol: transaction send signature=2r5idPttCU7WJ7wepaRNEE2yvjgEtXCcWF9RFkZUijr2ZXFa5nGhQyWkcQBjyaHkrxbQeZrVqorFp3UiTsWp56Pg
2026/01/18 20:45:41 pxsol: transaction send signature=5BaJmcqYSgvQMJ1KrETUUgJb35hHYEZgsNLcASszjvnbMbSGuyMLp2wh9WTPV95kv1EXpvMMxmx39mipwEMfX3F
2026/01/18 20:45:41 pxsol: transaction send signature=4X9LMGNiJQQTp32C6SBNVwq9xrQ9LcV7cyGxz4PooqvGzhdxWfACEzQ1vqm8CrS3gnYQGDuw1bpb1177qG1Nz9JH
2026/01/18 20:45:41 pxsol: transaction send signature=1LxtBvWfmBpu1WG24jo7UNZgWERNvskURWJ9eZW7G6ZZQtJqqJkrXdxWq1gfgi2R8Us8jHZwqtr3SXZZ3oEYqQn
2026/01/18 20:45:41 pxsol: transaction send signature=54GCC2ohPKWNmJj8xuqZhSN5NoeD84MKHVREUCayYNxmNdp2wVjMZLJcZa76KytZ15ESFFAU5Pyhp2gzkuQzs1fj
2026/01/18 20:45:41 pxsol: transaction send signature=64zhUPTvA2mUe1pSdnFz7y7wMy5PvNEGbAsgRPpYQf2tybHRMPc3kd6pd9WqfhdykB5pprRafBdPqxF5EcdEmtsV
2026/01/18 20:45:41 pxsol: transaction send signature=dWomeDWF7AgMk6ePKeBacz8MyXTdyEB2bqZuWVYJyngrec3CLeb5SnJNfYbjzxJiGdJfkrxD6MDuwrnoVFjhn1U
2026/01/18 20:45:41 pxsol: transaction send signature=2PMkcmdKdiCHH8FRUZtk2cZCL1AcjgeJgqAnmRQBkokSDV1Z9BkXDiSwftCNy74uZkmabAfiwCswJAGQvfkCq7cm
2026/01/18 20:45:41 pxsol: transaction send signature=58mXestA25LgxcdsdAbndtADKAfw9icytpPKquaxQ4T4rREQMVnuu1iBHwxxcPH6AHoRkXphEE2QFaGmcaQqyKMR
2026/01/18 20:45:41 pxsol: transaction send signature=4TYiarqoEgGUdcPwsbzbg6JTRZQ8ePVbGkEpMsBk7yYiUwsWK3D8orf58bCTzYgiQmPNqgVo3NH3Mphn3eAEhMro
2026/01/18 20:45:41 pxsol: transaction send signature=5CD3RBNTnSu9fW8RC7TDmi2FSxPd1fkZdJGAYKpyJorXozjGKGGVQ2nT16pvUfJoUJ4U2QNne4xPri8HT4wB9jHc
2026/01/18 20:45:42 pxsol: transaction send signature=zV8byzR7bjSSEREM2WH8c8JZV6HmRWN3B8em4QgpRMk5GR7QAJMLydZmpt24o95Qd4r3rL5vV3j6XYCbSqtbdn2
2026/01/18 20:45:42 pxsol: transaction send signature=5MbmxdQsCPP5g72GQPDRqJoc2SE22bPqmi1oz1smcUaLWxh5WJMcguHCZwyxmGWr2LR1DswTtur82n2r6NBP8B1m
2026/01/18 20:45:42 pxsol: transaction send signature=4d5L7E9FJ3dLRCiZZ2sdXbqewLfYMt3bmdo4ppZFTTAzmHBUjwHdws78LWgxyD3gsHGUmwxPP6HkABz7eZJETrAa
2026/01/18 20:45:42 pxsol: transaction send signature=2PJAPG6FB75c4uXzS4oMGbVkbDoQWgDzjFEDUW1RhWBnDytVjaQEva68rBoJpoPffXxSaBi8qCCd3v5sBX26zype
2026/01/18 20:45:42 pxsol: transaction send signature=5CfaA2bRniZWubrK2rVzUE1Uo5hw4tuPJosqiRfhDH2dDJ7tUZH2wsDAFzYmHvgfvLvQZyEe8XZty86ynu3xaL12
2026/01/18 20:45:42 pxsol: transaction send signature=5sRhrhECbPV734qDzZaM5oUGgQupKmZHwxuVfzp1aJKrCoKk3DmtBgSw3Xin1C15mC4pyjCNS95SS2Z8i4ovjz1d
2026/01/18 20:45:42 pxsol: transaction send signature=54jH66zcwTSThyE3ti2XSJbHP9RS6xvoMXo4HVucjgquVsKWMgGJ248YzhjTdzfMvFeECfe5Qv5znUKL4CMuMmMr
2026/01/18 20:45:42 pxsol: transaction send signature=4Do7vaSdLDt4nZyhmZUi2Hu89KM8aQ1WQgziDvxCNYHxgDXx5FizBrc5Q1xmPZYDnEYoLhChm5FFjDckae3FJtnY
2026/01/18 20:45:42 pxsol: transaction send signature=2e7K52hJdVgRmHVPWBULtYGMAsyA3269cHMT9TPFvLRDoQ4y3WzWeBFJ1AxWV3Rkjb6pzm5noBZQjt2wHgBmRbpU
2026/01/18 20:45:42 pxsol: transaction send signature=4hbUWEdcrXpTQY2VNsMFgeBWKaHeEDPzykeFpKFqieXV9AUq4bynpvKZYgU19MnwVSFME7HqMx8RpiEH8jRPHhRT
2026/01/18 20:45:42 pxsol: transaction send signature=rYjjrENwCT7E5MGbJkTi9dRbkG2r9bzeY3dzE9bBM5QSmqEzLAcBUZ4GwMBAr6v57qw3MkqkNQhwSSorD82xuYh
2026/01/18 20:45:42 pxsol: transaction send signature=28w3VX7KCHuDLVuFJXECAD4eBXDg2CfaVvg4q8fc3Me3VVZ5S1xkcAkhwh81XnmXr89pzGTK88WVDNdyYouKRMHt
2026/01/18 20:45:42 pxsol: transaction send signature=5LtS4qN1F9htKuerYQ9XJwt8h6dZtmAchEyYLbjce3nBCyPDn4EGK1bFsZ7avzAwhrWJxEgwsD8n8SNvrtiCJ3ee
2026/01/18 20:45:42 pxsol: transaction send signature=33h2PAkZ4PcwQmbvNPAvasDLoEqurDqBP3iPgtX1e7uKmWC1mUFVtnrv7v9VjCbFGF8hKrVdwhp5srjgfaBwryWD
2026/01/18 20:45:42 pxsol: transaction send signature=4Fgz5JewxksqXbHby9batXQinePDV84JTMwqJ4zarwarm6HNDAgHwANESKS5k3GpAz7AVnfWEqziaPDCZt4Ena56
2026/01/18 20:45:42 pxsol: transaction send signature=3ScC4X5ow64gw3PhrYTtXN8JrDwrwd21MHvX8jHjkeo2qksuBEJj8vsgEtApw2nDkiZP6rZ2jybGyKDm5ePXny6Q
2026/01/18 20:45:43 pxsol: transaction send signature=5r8PyoCtzYr37Ddu8NpkFjZZRCjnseNcFiPQynNpnNTLcdRS31nc8e5hetV7W7GogXMJQUdtageDa4jj2fMiDbdd
2026/01/18 20:45:43 pxsol: transaction send signature=4ice76gcTvbY2JxnrU6yhrmftNt7GcYXdWzoNV2dMQdKBmfTgBWimGDBTWzrcY4NNUdZTQGRyVQWbqa5zWVmKbGA
2026/01/18 20:45:43 pxsol: transaction send signature=3oanX3fm5GAyK53w8VPnmNk41Bf3wb3S5Vnb1JUBoHJTDWq2tjs5399Bvpdo9GiBXTVSCLzrhjKpQdVpBjBNkiiy
2026/01/18 20:45:43 pxsol: transaction send signature=ertuDpoV55xQ19Lef3kuxj4sTeZeE1MBKQv6HKnMhp82vFyLfh1nMnt5KjLhu9ALh3dyCrBq3P44rXbgfwLgxnR
2026/01/18 20:45:43 pxsol: transaction send signature=3kj4iMdpW1NeS7SdDZPKRoje9Ecv4BToRF9GFmPYLHbRocGYEiimHvPMQmHyKF5FW4gfgworjmftMP8V6iiALs5w
2026/01/18 20:45:43 pxsol: transaction send signature=59hJ251RM1BFnnf5TQuf3Vdc1hmd5kRURyyh2iDKJunmm9CXbF4R4C8nacrmj4g7FFFPtuFK4qf4QX6oEXrJjx1C
2026/01/18 20:45:43 pxsol: transaction send signature=5hMegqrxX6dXN89UqizKMZuhthKpv2pZn9irmNrbiHYMwcKEzM4D4m2gk7D9LJ9jJPFDq8VGEVpX7TxVfKS6EKTf
2026/01/18 20:45:43 pxsol: transaction send signature=7XqMrnmukSNRzRC97SaNYqDbAVkkMNsA1xY3M2jQvzYo3Jc5TwePYYauJFR8GX97D9R8DWqjve41LPc4BYi8xFK
2026/01/18 20:45:43 pxsol: transaction send signature=3h7L2QGEHqYmGGaKjFaEJ87roiR4s5j3SQTB4wMwALfd9cA797eP1n9TKbBmcG9N8JRYYqkpJscJm6tHw7HFWchj
2026/01/18 20:45:43 pxsol: transaction send signature=5iCVo6zDfWHTfKu5Loc4f67YdmPNC1QcwDuon15ovH1yzPMiLwN1DTkCwLYcUVFJEiGm8exgxK71PCyKYSGaEYR5
2026/01/18 20:45:43 pxsol: transaction send signature=579659KvDJsYTfhgW9SFy7X3icjF1KC9kQkpiHDWUzhiBRSyjBNjEnJZ5zDTzAK2Yu5PquCLWK6edN1WpNxs7ua9
2026/01/18 20:45:43 pxsol: transaction send signature=43xkudFL3afBsNFRuDvzdqhFxfkn12pAFHpaqCGYzcHfyNMXfPKhT5jNDi69DxnKqax3hqMDAtJSVUgikBHH1gxR
2026/01/18 20:45:43 pxsol: transaction send signature=5c5EDDwHiaS6PEZsXsuexA13cFE3xLbUwipfDKyteGJgK7nD4z6uoujHEMGcAT3ANsApULv8txQw6mhNMYHP8eMN
2026/01/18 20:45:43 pxsol: transaction send signature=2M6mBsV9pmL7wRk99FTuqJ8fzvt3rnCnn62Zg38M3NsBiTfscxrKahAHcRLZ5pnqikMeuguLTFDGrj183KoMzRra
2026/01/18 20:45:43 pxsol: transaction send signature=4X9J34kk8Px6KLMXoJ35HbU3JEZt3X14Y7h37zpeWuhicyE3MSvZh4pd4JF8YwHqyZrNBrbTeAfC8UU999wvMwYw
2026/01/18 20:45:43 pxsol: transaction send signature=5kKihStnKFAQDWwZZvMC29DzWmYTvFVcTBL5KeMB32mVDbfKKnQG6T7xnrHrx4F8hEoSQ3eVH3MHj9DA5e3ZJbcm
2026/01/18 20:45:43 pxsol: transaction send signature=cazMSwfZ2yfuQNJMj45sxY9Cy7PmaoMWX9qbr38LzkPAbwaHwNBZEzbdTNhVHi9rHczDt7DC9ScK7pC78QitYmE
2026/01/18 20:45:44 pxsol: transaction send signature=4qqBer5N5LaJjCV2z1bcQD8Ep7nsqKET788b2Qg9LjSqEWCtrukp4B3WDi7YuAA1UB4LgUd45ifgWNJceUv3gPFs
2026/01/18 20:45:44 pxsol: transaction send signature=5yNzr8G35iYXkhKm7Aau8v4mPiTW1FFXgZ1aijopcUveApGc4n4ftf9RLB4ArM2RBDZN8C9yEcP6ZfMjJ9ALCDZH
2026/01/18 20:45:44 pxsol: transaction send signature=2LY1kzSzY5L45CyoUvYy4nZ9m6xrfkUD58unxtvnzmXtoNM8iXxvc5q9cUNJUGf8Z4Gnxv4x4XkEX1EB4mnpDY25
2026/01/18 20:45:44 pxsol: transaction send signature=3BomSX9tzsSahZMaA1JAGxXS32FdrVFvc9r1hMdDWxGib5SRmh1RLYgnhvewwzsJ49WRPbDCk4T67BQcrziMSoEQ
2026/01/18 20:45:44 pxsol: transaction send signature=65cX3PetimzKLBdzS3d3hDyvZv3C2QQ4QsWy8kAxiZCGfFbX9cfB37LF2fFaY4ML9tifm5SHYP44rRFpLR384THK
2026/01/18 20:45:44 pxsol: transaction send signature=4sjV3UEmH8UtjVWxCmdC1HJnqH7H5hpNkL8K5SQvEQNSxSkPSUUZa6Rt7MHdDe5uXZRcPgeYyjFLQoenDNkvc9cB
2026/01/18 20:45:44 pxsol: transaction send signature=4T6vWLg6FianZj989PGbR71aQF7Fq57mVpsTX47tMo6SuLGP9HeKEFG5BR1Hs9vkCSSoxuesTF1UjAwimCYjUvW5
2026/01/18 20:45:44 pxsol: transaction send signature=2HvjR42XLy9FfuuAzfmgSZ6uaWbgzyMtT51XJ8ovQXLSuVLy8Qh4Kr9pqj6YcQBbBMB5bEUroWx58qm2ji4JNaTD
2026/01/18 20:45:44 pxsol: transaction send signature=5FiZcnsLwKX9rMwwb9kGUqPTrnGNuLjbGe4NecmJYSRS4hn15V777srbHZp36wvpVhCrKTYtaWQTXYKJtjwAScuQ
2026/01/18 20:45:44 pxsol: transaction send signature=NcGm8ih5cTKeoE2kpv6sVeXj9RET8nzYaYDdp4opMqzLwqH9MPAAFjwmPEmeEKadwemqgyZBH46ozjD5ALaezqs
2026/01/18 20:45:44 pxsol: transaction send signature=4yDsrt7ZNH7qN79jfSpxzW6SKx7wZKkonSR5kpeFbS99aGKSiVtu2tqQsBn5HGJVwAGpoiDxXKfmsMkynzgZYhR3
2026/01/18 20:45:44 pxsol: transaction send signature=4WTX4APstZkeRBLEhKR8M44vFBGKPGMbht956vkiX5vJoFDLQV62KHZ3Z3kdUqp6pYNh7wEvNDjUgAgWymDeZfSp
2026/01/18 20:45:44 pxsol: transaction send signature=cZBBg8thPoo3sdb5ycYDZcAeMKVCRyS8n6MHNkN3gAsZkzTJqKv51QWPjVnX7tERvet46qgDafMLwFW8s28PRzw
2026/01/18 20:45:44 pxsol: transaction send signature=5T8SEHPr92AbM26fzgqPYuyjkxrqMS57NCxacDkGqfMB4r3JgFcBRW5NRe5wPEfyqMUdcDhmRqqFJkeFxmXhHrJB
2026/01/18 20:45:44 pxsol: transaction send signature=6137beF1Uds8gFdbtpd51uLrf9hZCBqdB8NWbP4ZG1EVenWpA7F8ByP3SzDfxX3ppw9jMqDBr5tRhoWXuJ9sBdEH
2026/01/18 20:45:44 pxsol: transaction send signature=4PsthhB4TGRiG8AN7h7m18gQmsgMvDuxGqwJwaYyC1U8GA2zrSzsxyB9NShh2JSsWANDXi1EnsWS3AhkHk1MGNHZ
2026/01/18 20:45:45 pxsol: transaction send signature=3oy3PnkNKxBNAhwiCAKthTc4BUfSEEwYUCFctwQTC2gjCnrf6M7rTVfk6CN4hR5DQ63zM68be4je9j2QLVoFoqqV
2026/01/18 20:45:45 pxsol: transaction send signature=PS4E15qbcKRCQRFDTTfxj54c7XbnPPU242Rc3XR4Rvz7nhWz5wLzip1qhvXu91sY5RBBkxN2zFfMsdjhwNrqgQk
2026/01/18 20:45:45 pxsol: transaction send signature=3PC4KZzi1LbL6AigkhTyNK6sq8RR3BXXjZPV5yBpP1nxyDF92m6Egh7dre9zardiQ8d8RofHNDZnsyv6P8stXdvQ
2026/01/18 20:45:45 pxsol: transaction send signature=aazRuc8fUfY63uP4d8dVwtF4cRiuS5yxhKJBYTYQ7DdbamBDbUhs26FW6YqcEqYH5Yk2N4FcAx5iH5mtw66HKCP
2026/01/18 20:45:45 pxsol: transaction send signature=514vtsZn7P1w9BFrJh9DNrtPJTfYMMXR9dNktMHFZVKu61mNCEozZiNbGYdWf8SZSGnoXTKYFabVaE7cocVQpV1P
2026/01/18 20:45:45 pxsol: transaction send signature=xDFCic72P1bGBqk8atJqSijGxah74gddyUZvKHQYCoJaT7A9jbLtm5tM9piV4Ppw9TEkZVfZRwJQojaCmcqWtga
2026/01/18 20:45:45 pxsol: transaction send signature=KQMpjB8dtzA7uYBEqDj6zXTB3nn85LdnT2ZAdfvQrRfruzmy1f4GvxHankJXtiyZKNzASbvNJd65opPbSWAL6o1
2026/01/18 20:45:45 pxsol: transaction send signature=4TwDffQdfYmpEPLSTreYySgQUhwgZx6yvpf3dp5gprp7vpEPey2an4rJ5kTJBAwCMJ4ad4twPxR2o5NovTUTM7Gh
2026/01/18 20:45:45 pxsol: transaction send signature=3FJmHFCxLt3AwVhPQiqy6hAYgUH4NzveH6jre7Ng8RpXokwfGTvH2ZcH2N12W3YrLTf9Bbaftai6XpD1s3DQUaCx
2026/01/18 20:45:45 pxsol: transaction send signature=62wRdsN1nWkeTXWsVSPMncc7pCp21dMcdcANXpfNukkBbUw8pCV6cdNuA9tnfja1zFkPyyj4zFk1GEfpuNgfNB6z
2026/01/18 20:45:45 pxsol: transaction send signature=LAoX95iqnHLK46hjAzUwFZhKomi2B1ymos8wrFED4PnUTkaQVQVA6pfkvVKeEvW45hixUZrwujHkQWo8uxEU6G8
2026/01/18 20:45:45 pxsol: transaction send signature=4b2kVBtQDRrApyxqZ3NWKgDYw67inJbKWYY9ggCJkuzBcdn38bqgLyxkjGT5wBdQomm8n6yCUALcLx1WmQEAjkNx
2026/01/18 20:45:45 pxsol: transaction wait unconfirmed=81
2026/01/18 20:45:46 pxsol: transaction wait unconfirmed=0
2026/01/18 20:45:46 pxsol: program prikey="4S3ndHFBQJAk5dzq2Y3jTmCte5ybXxiiJLgcxwxpdkDs"
2026/01/18 20:45:46 pxsol: program pubkey="5dF7QGY32nA8rjLtcja8cXDMAx3JaqKqgVxQEgDrvJG4"
2026/01/18 20:45:46 pxsol: transaction send signature=3akwsUW317jfK7MYmGT97TWEYWS7VNkDqm5CbKPbE9nhojTECNpapUsmCNdZ3tfRyHP6Kgk8JikUSDyybeBCx5tb
2026/01/18 20:45:47 pxsol: transaction wait unconfirmed=1
2026/01/18 20:45:47 pxsol: transaction wait unconfirmed=0

==============================
✅ 部署成功！
📜 Program ID: "5dF7QGY32nA8rjLtcja8cXDMAx3JaqKqgVxQEgDrvJG4"
==============================
```

![image-20260118205027193](/images/image-20260118205027193.png)

这段运行结果表明，你成功使用 `pxsol` 库将编译好的 Solana 智能合约（`solana_storage.so`）分片上传并部署到了本地开发网，最终生成了唯一的程序地址（Program ID）`5dF7QGY32nA8rjLtcja8cXDMAx3JaqKqgVxQEgDrvJG4`。

#### 详细说明

- **分片上传**：由于 Solana 单笔交易大小限制（1232 字节），脚本自动将较大的合约文件切分成约 **81 个数据包**，通过一系列交易分批写入链上的 Buffer 账户。
- **Finalize（完成部署）**：在所有代码片段上传完毕后，通过最后一笔关键交易（Signature `3akws...`）将中转 Buffer 账户正式激活为可执行的 Program。
- **账户成本**：整个过程消耗了你 10000 SOL 中的一小部分，用于支付存储合约代码所需的**租金（Rent）**和交易手续费。

#### 查看你的程序账户信息

```bash
solana-storage on  master [?] is 📦 0.1.0 via 🦀 1.94.0 took 9.6s
➜ solana program show 5dF7QGY32nA8rjLtcja8cXDMAx3JaqKqgVxQEgDrvJG4

Program Id: 5dF7QGY32nA8rjLtcja8cXDMAx3JaqKqgVxQEgDrvJG4
Owner: BPFLoaderUpgradeab1e11111111111111111111111
ProgramData Address: 8a2QGgCCapvanMm3KsDtTHg7akCRMiTDKBctzfCJV5Xy
Authority: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
Last Deployed In Slot: 394320391
Data Length: 81176 (0x13d18) bytes
Balance: 0.56618904 SOL

```

看到这个输出，说明你的合约已经**完美地落地**在 Solana 账本上了。

我们可以从这份“体检报告”中读出几个非常关键的信息：

1. **Program ID**: `5dF7...` 是你合约的入口地址。
2. **Owner**: `BPFLoaderUpgradeab1e...` 表明这是一个**可升级**的程序。这意味着如果你之后修改了 Rust 代码并重新部署，你可以覆盖这个地址上的逻辑，而不需要更换地址。
3. **Authority**: `6MZDR...` 正是你刚才在 `id.json` 里加载的钱包地址。这代表你拥有这个程序的“管理员权限”，只有你能更新或关闭它。
4. **Data Length**: `81176` 字节。这对应了你刚才看到的 81 次分片上传，你的合约逻辑占用空间约为 80KB。
5. **Balance**: `0.566... SOL`。这是最重要的一点——**租金（Rent）**。Solana 为了让你这个 80KB 的程序永久存在链上，会自动从你的钱包扣除约 0.56 SOL 作为存储押金。

## 知识拓展

- **UTXO 是「花旧钱、找新钱」；账户模型是「改余额」**。

- Lookup Table 用一次性存储成本，换取长期更小的交易体积和更低、更稳定的手续费；
  在实际系统中，整体成本是下降的。
- 在 Solana 中，使用 `SystemProgram.createAccount` 创建一个“非 PDA 的新账户”时，新账户本身必须签名。
- **用户 -> PDA**：必须走 System Program Transfer (需要用户签名)。
- **PDA -> 用户**：可以直接修改 Lamports (程序是 PDA 的主人)。
- 1232 字节是单次“快递包裹”的物理限重，而通过多次发送包裹（分批交易）并配合 `resize` 动态扩容，你可以在收件方的“仓库”（账户）里堆积出高达 10MB 的海量数据。

## 💡 总结

这份「链上数据存储器」的实现，标志着 Solana 开发规范从“手动补丁时代”跨入了“标准接口时代”。其核心价值体现在三个维度：

1. **安全性（Security）：** SDK V3 将 `realloc` 逻辑标准化，开发者无需再手动操作底层指针，从根源上杜绝了缓冲区溢出等安全隐患。
2. **经济性（Cost-Efficiency）：** 通过“补交-退还”的动态平衡逻辑，链上存储从“固定成本”变成了“动态支出”，极大提升了用户的资金利用率。
3. **标准化（Standardization）：** 结合 `solana-system-interface` 与现代部署工具，极大缩短了从开发到上线的链路。

在 Solana 极速演进的账本中，**“版本代差”就是最高的技术债**。全面转向 V3 标准不再是少数专家的选择，而是每一位追求系统稳定性的开发者的必然路径。

## 参考

- <https://www.soldevcamp.com/solana-technical-training-camp>
- <https://github.com/anza-xyz/pinocchio>
- <https://academy.soldevcamp.com/course/solana-program-dev/program-5/>
- <https://docs.rs/solana-program/latest/solana_program/>
- <https://github.com/anza-xyz/solana-sdk>
- <https://solana.com/docs/core/cpi>
- <https://docs.rs/solana-cpi/latest/solana_cpi/>
- <https://docs.rs/solana-account-info/latest/solana_account_info/struct.AccountInfo.html>
- <https://github.com/mohanson/pxsol>
- <https://github.com/astral-sh/uv>
- <https://pxsol.vercel.app/>
