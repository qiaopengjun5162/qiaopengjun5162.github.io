+++
title = "从零开始用 Rust 和 Alloy 构建钱包核心（一）：离线功能与统一接口设计"
description = "从零开始用 Rust 和 Alloy 构建钱包核心（一）：离线功能与统一接口设计"
date = 2025-08-12T03:40:58Z
[taxonomies]
categories = ["Rust", "Web3"]
tags = ["Rust", "Web3", "Alloy"]
+++

<!-- more -->

# 从零开始用 Rust 和 Alloy 构建钱包核心（一）：离线功能与统一接口设计

在 Web3 世界中，为多条区块链开发应用往往意味着需要学习和适配风格迥异的 SDK，这大大增加了开发的复杂性。为了解决这个问题，我们构思了 `Aegis-Wallet` 项目：一个旨在提供统一、简洁、跨链的钱包核心工具库。

本文是这个系列的第一篇，我们将聚焦于打下坚实的基础。我们将选用以安全和性能著称的 Rust 语言，以及由 `ethers-rs` 核心团队打造的下一代以太坊工具库 `Alloy`，从零开始构建钱包的核心。你将学到如何通过“适配器模式”设计一个可扩展的统一接口 `WalletAdapter`，并为 EVM 链实现一个功能完备的、经过严格单元测试的**离线**钱包适配器，它将支持从助记词、私钥和加密 Keystore 文件三种标准方式创建钱包。

本文是一篇 Rust Web3 实战教程，带领读者使用新一代以太坊工具库 Alloy，从零构建钱包核心。文章重点阐述了如何通过适配器模式设计统一、可扩展的钱包接口 `WalletAdapter`，并实现了支持助记词、私钥和 Keystore 三种方式创建 EVM 钱包的离线功能。所有代码均经过严格的单元测试验证，为后续开发奠定了坚实基础。

## 实操

### 查看项目目录

```bash
aegis-wallet-rs on  master [?] is 📦 0.1.0 via 🦀 1.89.0
➜ pwd
/Users/xxx/Code/Web3/aegis-wallet/rust/aegis-wallet-rs

aegis-wallet-rs on  master [?] is 📦 0.1.0 via 🦀 1.89.0
➜ tree . -L 6 -I "docs|target"
.
├── Cargo.lock
├── Cargo.toml
├── examples
│   └── create_evm_wallet.rs
└── src
    ├── chains
    │   ├── evm.rs
    │   └── mod.rs
    ├── core
    │   ├── interface.rs
    │   └── mod.rs
    ├── error.rs
    └── lib.rs

5 directories, 9 files
```

### `Cargo.toml` 文件

```rust
[package]
name = "aegis-wallet-rs"
version = "0.1.0"
edition = "2024"

[dependencies]
alloy-pubsub = "1.0.24"
anyhow = "1.0.99"
dotenvy = "0.15.7"
thiserror = "2.0.14"
tokio = { version = "1.47.1", features = ["rt", "rt-multi-thread", "macros"] }
alloy = { version = "1.0.24", features = [
    "signer-mnemonic",
    "signer-local",
    "provider-http",
    "signer-keystore",
] }

[dev-dependencies]
tempfile = "3.20.0"
rand = "0.8.5"

```

### `src/lib.rs` 文件

```rust
pub mod chains;
pub mod core;
pub mod error;

pub use chains::evm::EvmAdapter;
pub use core::interface::WalletAdapter;
pub use error::AegisError;

```

### `src/error.rs` 文件

```rust
use alloy::signers::local::LocalSignerError;
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AegisError {
    // 这个变体专门用来包装来自 Alloy 的 LocalSignerError
    // `#[from]` 宏会自动为我们实现 From<LocalSignerError> for AegisError
    #[error("Local signer error: {0}")]
    LocalSigner(#[from] LocalSignerError),

    #[error("Wallet operation failed: {0}")]
    WalletError(String),
}

```

### `src/core/mod.rs` 文件

```rust
pub mod interface;
```

### `src/core/interface.rs` 文件

```rust
use std::path::Path;

use crate::error::AegisError;

pub trait WalletAdapter {
    fn from_mnemonic(phrase: &str, index: u32) -> Result<Self, AegisError>
    where
        Self: Sized;

    fn from_private_key(key: &str) -> Result<Self, AegisError>
    where
        Self: Sized;

    fn from_keystore(path: &Path, password: &str) -> Result<Self, AegisError>
    where
        Self: Sized;

    fn address(&self) -> String;
}

```

这段 Rust 代码定义了一个名为 **`WalletAdapter`** 的 **`trait`**（特性），它就像一个为所有不同类型的钱包制定的“**行为标准**”或“**合约蓝图**”。这个“合约”规定，任何想要成为我们系统中的“钱包适配器”的结构体，都**必须**提供四种核心能力：三种创建自身的方式（通过**助记词**、**私钥**或加密的 **Keystore 文件**），以及一种获取自身**地址**的功能。这种设计的精妙之处在于，它通过“适配器模式”将不同区块链钱包（未来可能是 EVM、Solana 等）的复杂实现细节隐藏了起来，让上层代码可以用一套完全统一、简洁的方式来操作任何类型的钱包，从而使整个项目变得易于扩展和维护。

### `src/chains/mod.rs` 文件

```rust
pub mod evm;
```

### `src/chains/evm.rs` 文件

```rust
use std::{path::Path, str::FromStr};

use crate::core::interface::WalletAdapter;
use crate::error::AegisError;
use alloy::signers::local::{LocalSigner, MnemonicBuilder, PrivateKeySigner, coins_bip39::English};

pub struct EvmAdapter {
    signer: PrivateKeySigner,
}

impl WalletAdapter for EvmAdapter {
    fn from_mnemonic(phrase: &str, index: u32) -> Result<Self, AegisError> {
        let signer = MnemonicBuilder::<English>::default()
            .phrase(phrase)
            .index(index)?
            .build()?;

        Ok(Self { signer })
    }

    fn from_private_key(key: &str) -> Result<Self, AegisError> {
        let signer = PrivateKeySigner::from_str(key)?;
        Ok(Self { signer })
    }

    fn from_keystore(path: &Path, password: &str) -> Result<Self, AegisError> {
        let signer = LocalSigner::decrypt_keystore(path, password)?;
        Ok(Self { signer })
    }

    fn address(&self) -> String {
        format!("{:?}", self.signer.address())
    }
}

// ============== 单元测试模块 ==============
#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    // --- 测试用例 1: Anvil 默认账户 ---
    const ANVIL_PHRASE: &str = "test test test test test test test test test test test junk";
    const ANVIL_PRIVATE_KEY: &str =
        "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
    const ANVIL_EXPECTED_ADDRESS: &str = "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266";

    // --- 测试用例 2: 一个标准的 BIP39 助记词 ---
    const BIP39_PHRASE: &str =
        "work man father plunge mystery proud hollow address reunion sauce theory bonus";
    const BIP39_EXPECTED_ADDRESS_0: &str = "0xffdb339065c91c88e8a3cc6857359b6c2fb78cf5";

    #[test]
    fn test_from_anvil_mnemonic() {
        let wallet = EvmAdapter::from_mnemonic(ANVIL_PHRASE, 0).unwrap();
        assert_eq!(wallet.address().to_lowercase(), ANVIL_EXPECTED_ADDRESS);
    }

    #[test]
    fn test_from_anvil_private_key() {
        let wallet = EvmAdapter::from_private_key(ANVIL_PRIVATE_KEY).unwrap();
        assert_eq!(wallet.address().to_lowercase(), ANVIL_EXPECTED_ADDRESS);
    }

    #[test]
    fn test_from_bip39_mnemonic() {
        let wallet = EvmAdapter::from_mnemonic(BIP39_PHRASE, 0).unwrap();
        assert_eq!(wallet.address().to_lowercase(), BIP39_EXPECTED_ADDRESS_0);
    }

    #[test]
    fn test_from_keystore_works() {
        // 1. 准备环境
        let dir = tempdir().unwrap();
        let password = "my-secret-password";
        let mut rng = rand::thread_rng();

        // 2. 准备原始私钥的字节
        let original_pk_bytes = PrivateKeySigner::from_str(ANVIL_PRIVATE_KEY)
            .unwrap()
            .credential()
            .to_bytes();

        // 3. 使用关联函数创建 Keystore 文件
        let (signer_instance_from_encrypt, filename) =
            LocalSigner::encrypt_keystore(&dir, &mut rng, &original_pk_bytes, password, None)
                .unwrap();

        // 4. 手动将被创建的文件名和目录拼接成完整路径
        let full_path = dir.path().join(filename);
        println!("Keystore file created at: {:?}", full_path);

        // 5. 使用我们的 from_keystore 方法从完整路径来恢复钱包
        let wallet_from_keystore = EvmAdapter::from_keystore(&full_path, password).unwrap();

        // 6. 验证：
        // a) 恢复出的钱包地址应该和预期的地址一致
        assert_eq!(
            wallet_from_keystore.address().to_lowercase(),
            ANVIL_EXPECTED_ADDRESS
        );
        // b) 加密时直接返回的钱包实例，其地址也应该和预期一致
        assert_eq!(
            signer_instance_from_encrypt
                .address()
                .to_string()
                .to_lowercase(),
            ANVIL_EXPECTED_ADDRESS
        );

        println!("✅ test_from_keystore_works PASSED");
        // 清理临时目录
        dir.close().unwrap();
    }
}

```

这段代码是 `WalletAdapter` 接口针对 **EVM 兼容链的具体实现**。它定义了一个名为 `EvmAdapter` 的结构体，其核心是一个来自 `Alloy` 库的 `PrivateKeySigner`（私钥签名器）。代码巧妙地利用 `Alloy` 提供的强大功能，为 `EvmAdapter` 实现了三种核心的钱包创建方式：通过**助记词**、**原始私钥**和加密的 **Keystore 文件**。这部分代码最关键的亮点是其详尽的**单元测试模块**，它使用了多组经过验证的测试数据，严格确保了每一种创建方式都能准确无误地生成预期的钱包地址，从而为整个库的可靠性与正确性提供了坚实的保障。

---

### 格式化

```bash
aegis-wallet-rs on  master [?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo fmt
```

### 执行**构建**

```bash
aegis-wallet-rs on  master [?] is 📦 0.1.0 via 🦀 1.89.0 took 5.4s
➜ cargo build
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.32s
```

**成功编译了整个项目** (`cargo build`)

### 测试

```bash
aegis-wallet-rs on  master [?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo test
   Compiling aegis-wallet-rs v0.1.0 (/Users/qiaopengjun/Code/Web3/aegis-wallet/rust/aegis-wallet-rs)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 1.36s
     Running unittests src/lib.rs (target/debug/deps/aegis_wallet_rs-baeeb9bfc018dc87)

running 4 tests
test chains::evm::tests::test_from_anvil_private_key ... ok
test chains::evm::tests::test_from_bip39_mnemonic ... ok
test chains::evm::tests::test_from_anvil_mnemonic ... ok
test chains::evm::tests::test_from_keystore_works ... ok

test result: ok. 4 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 1.53s

   Doc-tests aegis_wallet_rs

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s


aegis-wallet-rs on  master [?] is 📦 0.1.0 via 🦀 1.89.0 took 3.7s
➜ cargo nextest run
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.19s
────────────
 Nextest run ID 998b863b-eac2-472d-8b5c-09546a4090d4 with nextest profile: default
    Starting 4 tests across 1 binary
        PASS [   0.008s] aegis-wallet-rs chains::evm::tests::test_from_anvil_private_key
        PASS [   0.036s] aegis-wallet-rs chains::evm::tests::test_from_bip39_mnemonic
        PASS [   0.036s] aegis-wallet-rs chains::evm::tests::test_from_anvil_mnemonic
        PASS [   1.536s] aegis-wallet-rs chains::evm::tests::test_from_keystore_works
────────────
     Summary [   1.536s] 4 tests run: 4 passed, 0 skipped
```

这段终端输出展示了 `aegis-wallet-rs` 项目的单元测试已全部成功通过，这有力地证明了你为 EVM 链编写的 `EvmAdapter` 核心功能是正确且可靠的。测试结果表明，无论是通过 Anvil 的默认助记词、标准的 BIP-39 助记词、原始私钥，还是加密的 Keystore 文件，你的代码都能准确无误地创建出钱包并生成预期的、正确的地址。你分别使用了标准的 `cargo test` 和更高效的 `cargo nextest` 两种工具来运行测试，并且都得到了一致的“全部通过”（`4 passed; 0 failed`）的结果，这标志着你已经为这个库的离线功能部分打下了坚实且经过验证的质量基础。

### `examples/create_evm_wallet.rs` 文件

```rust
// examples/create_evm_wallet.rs

use std::str::FromStr;

use aegis_wallet_rs::{EvmAdapter, WalletAdapter};
use alloy::signers::local::{LocalSigner, PrivateKeySigner};
use tempfile::tempdir;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    println!("--- [Example] Aegis-Wallet Offline Creation Showcase ---");

    // 使用与单元测试一致的、经过验证的常量
    let phrase = "test test test test test test test test test test test junk";
    let private_key = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
    let expected_address = "0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266";

    // --- 1. 从助记词创建 ---
    println!("\n[1] Creating from Mnemonic...");
    let wallet_from_mnemonic = EvmAdapter::from_mnemonic(phrase, 0)?;
    println!("   Address: {}", wallet_from_mnemonic.address());
    assert_eq!(
        wallet_from_mnemonic.address().to_lowercase(),
        expected_address
    );
    println!("   ✅ Verification successful!");

    println!("\n--- [Example] Create Wallet from Private Key ---");

    // --- 2. 从私钥创建 ---
    println!("\n[2] Creating from Private Key...");
    let wallet_from_pk = EvmAdapter::from_private_key(private_key)?;
    println!("   Address: {}", wallet_from_pk.address());
    assert_eq!(wallet_from_pk.address().to_lowercase(), expected_address);
    println!("   ✅ Verification successful!");

    // --- 3. 从 Keystore 创建 ---
    println!("\n[3] Creating and then loading from Keystore...");
    // 首先，我们需要动态创建一个临时的 Keystore 文件
    let dir = tempdir()?;
    let password = "example-password";
    let mut rng = rand::thread_rng(); // Keystore 加密需要随机数

    let original_pk_bytes = PrivateKeySigner::from_str(private_key)
        .unwrap()
        .credential()
        .to_bytes();
    let (signer_instance_from_encrypt, filename) =
        LocalSigner::encrypt_keystore(&dir, &mut rng, &original_pk_bytes, password, None).unwrap();
    let full_path = dir.path().join(filename);
    println!("Keystore file created at: {:?}", full_path);

    // 然后，使用我们库的函数从这个文件加载钱包
    let wallet_from_keystore = EvmAdapter::from_keystore(&full_path, password)?;
    println!(
        "   Address loaded from keystore: {}",
        wallet_from_keystore.address()
    );
    assert_eq!(
        wallet_from_keystore.address().to_lowercase(),
        expected_address
    );

    assert_eq!(
        signer_instance_from_encrypt
            .address()
            .to_string()
            .to_lowercase(),
        expected_address
    );

    println!("   ✅ Verification successful!");

    dir.close().unwrap();

    Ok(())
}

```

这段代码是一个功能完整的示例程序，它作为 `aegis-wallet-rs` 库的“最终用户”，全面展示了其核心的离线钱包创建功能。代码清晰地分三步演练了如何分别通过**助记词**、**私钥**以及**动态创建并加载 Keystore 文件**这三种标准方式来实例化钱包适配器。最关键的是，它通过 `assert_eq!` 断言，证明了所有不同途径创建的钱包最终都指向了同一个正确的地址，这不仅展示了库的用法，更有力地验证了其功能的一致性和可靠性。

### 运行示例

```bash
aegis-wallet-rs on  master [?] is 📦 0.1.0 via 🦀 1.89.0 took 2.3s
➜ cargo run --example create_evm_wallet
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.46s
     Running `target/debug/examples/create_evm_wallet`
--- [Example] Aegis-Wallet Offline Creation Showcase ---

[1] Creating from Mnemonic...
   Address: 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
   ✅ Verification successful!

--- [Example] Create Wallet from Private Key ---

[2] Creating from Private Key...
   Address: 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
   ✅ Verification successful!

[3] Creating and then loading from Keystore...
Keystore file created at: "/var/folders/fw/s14m5tcs46j9t16ph766kc9h0000gn/T/.tmpWw1MVp/77ea14b7-e68c-4ca8-bdf2-75c4dad95db1"
   Address loaded from keystore: 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266
   ✅ Verification successful!

```

这段输出结果表明，你已经**成功运行了示例代码 (`cargo run --example`)，并且输出结果完全正确，证明了你的库可以被外部调用**。这个示例程序作为一个“最终用户”，清晰地展示了 `Aegis-Wallet` 库的所有核心离线功能：它成功地调用了你的公共接口，分别通过**助记词**、**私钥**和**动态创建的 Keystore 文件**这三种方式创建了钱包。更重要的是，每一次创建后都进行了地址验证，并且所有方式生成的地址都精确地指向了同一个正确的结果 (`0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266`)，这完美地印证了你库的可靠性和一致性。这不仅是单元测试的通过，更是对你库**实际可用性**的一次成功演练。

## 总结

至此，我们已经成功地为 `Aegis-Wallet` 项目构建了第一个功能完备的核心组件：一个经过严格测试的 EVM 离线钱包适配器。通过精心设计的 `WalletAdapter` 接口，我们不仅实现了三种标准的钱包创建方式，更为未来支持 Solana、Sui 等其他公链打下了可扩展的架构基础。单元测试的加入，确保了我们每一步操作的正确性和代码的健壮性。

在 `Aegis-Wallet` 的下一篇文章中，我们将让这个钱包“活”起来。我们将为 `EvmAdapter` 添加**在线**功能，包括连接到区块链节点、查询账户余额以及发送真实的交易。敬请期待！

## 参考

- <https://alloy.rs/examples/wallets/mnemonic_signer>
- <https://github.com/alloy-rs/alloy>
- <https://github.com/alloy-rs/examples/blob/main/Cargo.toml>
- <https://github.com/alloy-rs/examples/blob/main/examples/wallets/examples/create_keystore.rs>
- <https://github.com/gakonst/ethers-rs/issues/2667>
- <https://crates.io/crates/alloy-pubsub>
