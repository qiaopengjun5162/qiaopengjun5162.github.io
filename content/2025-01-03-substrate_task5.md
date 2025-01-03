+++
title = "Substrate 区块链开发实战：构建与测试 PoE Pallet"
description = "在区块链技术的发展中，Substrate作为一个模块化、可定制化的区块链开发框架，为开发者提供了强大的功能支持。本文通过实操案例，带领读者学习如何在Substrate上开发一个Proof of Existence（PoE）模块。PoE是数字内容存证的有效方式，应用场景包括版权保护、司法证据保存、供应链追溯等。"
date = 2025-01-03 13:17:53+08:00
[taxonomies]
categories = ["Substrate"]
tags = ["Substrate"]
+++

<!-- more -->

# Substrate 区块链开发实战：构建与测试 PoE Pallet

在区块链技术的发展中，Substrate作为一个模块化、可定制化的区块链开发框架，为开发者提供了强大的功能支持。本文通过实操案例，带领读者学习如何在Substrate上开发一个Proof of Existence（PoE）模块。PoE是数字内容存证的有效方式，应用场景包括版权保护、司法证据保存、供应链追溯等。

本文介绍了如何使用Substrate框架开发一个Proof of Existence（PoE）模块，包括从环境搭建到模块实现的全过程。通过该模块，用户可以创建、撤销和转移数字文件的存证信息。文章详细介绍了从代码克隆、编译、开发到测试的每一步骤，并展示了如何在Polkadot JS应用中进行操作测试。最终，通过本项目，读者将掌握Substrate框架在实际应用中的使用技巧。

Build a Blockchain with Substrate

Substrate overview

- 定制化、模块化
- 升级容易
- Runtime 开发基于宏 macro ，标准化、节省开发时间
rust 宏
链上存储

Introduction to On-chain PoE
Proof of existence is an online service that can be used to verify the existence of a digital file at a certain point in time. It was originally implemented through transactions with timestamps on the Bitcoin network. The use cases includes

Proof of existence 是一种在线服务，可以用来验证某个数字文件在某个特定时间点的存在。它最初是通过比特币网络上的带时间戳的交易来实现的。

- copyright of digital contents  数字内容的版权
- judicial evidence preservation 司法证据保存
- supply chain traceability 供应链可追溯性
- digital invoicing 数字发票

Homework

1. Continue unimplemented parts for PoE pallet
2. Implement a function to transfer a claim, which contains two parameters, one is the hash of the content, and the other is the receiving account id for the transfer.
3. Implement the unit tests for all extrinsics, verify all events and errors.
4. Update the runtime, start the chain in dev mode, test PoE via Polkadot JS App

## 实操

### 第一步：克隆代码

```bash
git clone https://github.com/papermoonio/polkadot-sdk-solo-template-dev-courses.git
```

### 第二步：进入目录

```bash
cd polkadot-sdk-solo-template-dev-courses                                    
```

### 第三步：编译

```bash
cargo build --release
# check
cargo check
```

### 第四步：进入**pallets**目录将 template 目录复制到 poe 目录

```bash
# 切换到当前工作目录中的 pallets 目录
cd pallets
# 将 template 目录（及其内容）复制到当前工作目录下的新目录 poe 中。如果 poe 目录不存在，cp -r 会自动创建它并将内容复制进去。
cp -r template poe
```

### 第五步：查看目录结构

```bash
➜ tree . -L 6 -I 'target|coverage|coverage_report|node_modules'                   


.
├── Cargo.lock
├── Cargo.toml
├── LICENSE
├── README.md
├── docs
│   └── rust-setup.md
├── env-setup
│   ├── README.md
│   ├── flake.lock
│   ├── flake.nix
│   └── rust-toolchain.toml
├── localSpec.json
├── node
│   ├── Cargo.toml
│   ├── build.rs
│   └── src
│       ├── benchmarking.rs
│       ├── chain_spec.rs
│       ├── cli.rs
│       ├── command.rs
│       ├── main.rs
│       ├── rpc.rs
│       └── service.rs
├── pallets
│   ├── poe
│   │   ├── Cargo.toml
│   │   ├── README.md
│   │   └── src
│   │       ├── benchmarking.rs
│   │       ├── lib.rs
│   │       ├── mock.rs
│   │       ├── tests.rs
│   │       └── weights.rs
│   └── template
│       ├── Cargo.toml
│       ├── README.md
│       └── src
│           ├── benchmarking.rs
│           ├── lib.rs
│           ├── mock.rs
│           ├── tests.rs
│           └── weights.rs
├── runtime
│   ├── Cargo.toml
│   ├── build.rs
│   └── src
│       └── lib.rs
└── rust-toolchain.toml

12 directories, 37 files

```

### 第六步：在项目根目录下的 Cargo.toml 文件中的 members 项，添加 pallets/poe 到列表中，如下所示

```toml
members = ["node", "pallets/template", "pallets/poe", "runtime"]
```

### 第七步：在 pallets/poe/Cargo.toml 文件中，将 pallet-template 替换为 pallet-poe，如下所示

```toml
[package]
name = "pallet-poe"
```

### 第八步：在 pallets/poe/src/lib.rs 文件中，添加以下代码

```rust
#![cfg_attr(not(feature = "std"), no_std)]

use frame_support::pallet_prelude::*;
use frame_system::pallet_prelude::*;
pub use pallet::*;

#[cfg(test)]
mod mock;


#[cfg(test)]
mod tests;

#[frame_support::pallet]
pub mod pallet {
    use super::*;

    #[pallet::pallet]
    pub struct Pallet<T>(_);

    #[pallet::config]
    pub trait Config: frame_system::Config {
        #[pallet::constant]
        type MaxClaimLength: Get<u32>;
        type RuntimeEvent: From<Event<Self>> + IsType<<Self as frame_system::Config>::RuntimeEvent>;
    }

    #[pallet::storage]
    pub type Proofs<T: Config> = StorageMap<
        _,
        Blake2_128Concat,
        BoundedVec<u8, T::MaxClaimLength>,
        (T::AccountId, BlockNumberFor<T>),
    >;

    #[pallet::event]
    #[pallet::generate_deposit(pub(super) fn deposit_event)]
    pub enum Event<T: Config> {
        ClaimCreated(T::AccountId, BoundedVec<u8, T::MaxClaimLength>),
        ClaimRevoked(T::AccountId, BoundedVec<u8, T::MaxClaimLength>),
    }

    #[pallet::error]
    pub enum Error<T> {
        ProofAlreadyExists,
        ClaimTooLong,
        ClaimNotExist,
        NotClaimOwner,
        NewOwnerIsCurrentOwner,
    }

    #[pallet::call]
    impl<T: Config> Pallet<T> {
        #[pallet::call_index(0)]
        #[pallet::weight(0)]
        // #[pallet::weight(T::WeightInfo::create_claim(claim.len() as u32))]
        pub fn create_claim(
            origin: OriginFor<T>,
            claim: BoundedVec<u8, T::MaxClaimLength>,
        ) -> DispatchResult {
            // Check that the extrinsic was signed and get the signer.
            let sender = ensure_signed(origin)?;
            ensure!(
                !Proofs::<T>::contains_key(&claim),
                Error::<T>::ProofAlreadyExists
            );

            Proofs::<T>::insert(
                &claim,
                (sender.clone(), frame_system::Pallet::<T>::block_number()),
            );

            // Emit an event.
            Self::deposit_event(Event::ClaimCreated(sender, claim));

            // Return a successful `DispatchResult`
            Ok(())
        }

        #[pallet::call_index(1)]
        #[pallet::weight(0)]
        // #[pallet::weight(T::WeightInfo::revoke_claim(claim.len() as u32))]
        pub fn revoke_claim(
            origin: OriginFor<T>,
            claim: BoundedVec<u8, T::MaxClaimLength>,
        ) -> DispatchResultWithPostInfo {
            let sender = ensure_signed(origin)?;

            let (owner, _) = Proofs::<T>::get(&claim).ok_or(Error::<T>::ClaimNotExist)?;

            ensure!(owner == sender, Error::<T>::NotClaimOwner);

            Proofs::<T>::remove(&claim);

            Self::deposit_event(Event::ClaimRevoked(sender, claim));

            Ok(().into()) // 撤销存证功能完成
        }

        #[pallet::call_index(2)]
        #[pallet::weight(0)]
        // #[pallet::weight(T::WeightInfo::transfer_claim(claim.len() as u32))]
        pub fn transfer_claim(
            origin: OriginFor<T>,
            claim: BoundedVec<u8, T::MaxClaimLength>,
            new_owner: T::AccountId,
        ) -> DispatchResult {
            let sender = ensure_signed(origin)?;

            let (owner, _) = Proofs::<T>::get(&claim).ok_or(Error::<T>::ClaimNotExist)?;

            ensure!(owner == sender, Error::<T>::NotClaimOwner);
            ensure!(new_owner != owner, Error::<T>::NewOwnerIsCurrentOwner);

            Proofs::<T>::insert(
                &claim,
                (new_owner.clone(), frame_system::Pallet::<T>::block_number()),
            );

            Self::deposit_event(Event::ClaimCreated(new_owner, claim));

            Ok(())
        }
    }
}

```

### 第九步：在 runtime/Cargo.toml 文件中，添加 pallets-poe 相关依赖，如下所示

```toml
[dependencies]
pallet-poe = { path = "../pallets/poe", default-features = false }
[features]
default = ["std"]
std = ["pallet-poe/std",]
```

### 第十步：在 runtime/src/lib.rs 文件中，添加以下代码

```rust
pub use pallet_poe;

impl pallet_poe::Config for Runtime {
    type MaxClaimLength = ConstU32<100>;
    type RuntimeEvent = RuntimeEvent;
}

#[frame_support::runtime]
mod runtime {
    ...
    #[runtime::pallet_index(8)]
    pub type PoeModule = pallet_poe;
}
```

**注意**：在开发过程中，代码更新后要及时在相关目录下运行 `cargo build --release`，以确保代码没有问题。例如，在 `pallets/poe` 目录下运行 `cargo build --release`，在 `runtime` 目录下也要运行 `cargo build --release`。如果编译速度过慢，可以尝试使用 `cargo check` 来进行快速检查

### 第十一步：编写测试代码

#### `pallets/poe/src/mock.rs` 文件

```rust
use crate as pallet_poe;
use frame_support::{
    derive_impl,
    traits::{ConstU16, ConstU32, ConstU64},
};
use sp_core::H256;
use sp_runtime::{
    traits::{BlakeTwo256, IdentityLookup},
    BuildStorage,
};

type Block = frame_system::mocking::MockBlock<Test>;

// Configure a mock runtime to test the pallet.
frame_support::construct_runtime!(
    pub enum Test
    {
        System: frame_system,
        PoeModule: pallet_poe,
    }
);

#[derive_impl(frame_system::config_preludes::TestDefaultConfig)]
impl frame_system::Config for Test {
    type BaseCallFilter = frame_support::traits::Everything;
    type BlockWeights = ();
    type BlockLength = ();
    type DbWeight = ();
    type RuntimeOrigin = RuntimeOrigin;
    type RuntimeCall = RuntimeCall;
    type Nonce = u64;
    type Hash = H256;
    type Hashing = BlakeTwo256;
    type AccountId = u64;
    type Lookup = IdentityLookup<Self::AccountId>;
    type Block = Block;
    type RuntimeEvent = RuntimeEvent;
    type BlockHashCount = ConstU64<250>;
    type Version = ();
    type PalletInfo = PalletInfo;
    type AccountData = ();
    type OnNewAccount = ();
    type OnKilledAccount = ();
    type SystemWeightInfo = ();
    type SS58Prefix = ConstU16<42>;
    type OnSetCode = ();
    type MaxConsumers = frame_support::traits::ConstU32<16>;
}

impl pallet_poe::Config for Test {
    type MaxClaimLength = ConstU32<100>;
    type RuntimeEvent = RuntimeEvent;
}

// Build genesis storage according to the mock runtime.
pub fn new_test_ext() -> sp_io::TestExternalities {
    frame_system::GenesisConfig::<Test>::default()
        .build_storage()
        .unwrap()
        .into()
}

```

#### `pallets/poe/src/tests.rs` 文件

```rust
use super::*;
use crate as pallet_poe;
use crate::{mock::*, Error};
use frame_support::{assert_noop, assert_ok, BoundedVec};
// use sp_runtime::BoundedVec;

// 测试 create_claim
#[test]
fn it_works_for_create_claim() {
    new_test_ext().execute_with(|| {
        System::set_block_number(1);
        let claim = BoundedVec::try_from(vec![1, 2, 3]).unwrap();
        assert_ok!(PoeModule::create_claim(
            RuntimeOrigin::signed(1),
            claim.clone()
        ));

        assert_eq!(pallet_poe::Proofs::<Test>::get(&claim), Some((1, 1)));
        assert_eq!(
            pallet_poe::Proofs::<Test>::get(&claim),
            Some((1_u64, 1_u64))
        );
        // Go past genesis block so events get deposited
        System::set_block_number(1);
    });
}

#[test]
fn create_claim_works() {
    new_test_ext().execute_with(|| {
        let claim = BoundedVec::try_from(vec![1, 1]).unwrap();
        assert_ok!(PoeModule::create_claim(
            RuntimeOrigin::signed(2),
            claim.clone()
        ));

        assert_eq!(
            Proofs::<Test>::get(&claim),
            Some((2, frame_system::Pallet::<Test>::block_number()))
        );
        assert_eq!(<<Test as Config>::MaxClaimLength as Get<u32>>::get(), 100);
    })
}

#[test]
fn create_claim_failed_when_claim_already_exist() {
    new_test_ext().execute_with(|| {
        let claim = BoundedVec::try_from(vec![1, 1]).unwrap();
        let _ = PoeModule::create_claim(RuntimeOrigin::signed(1), claim.clone());

        assert_noop!(
            PoeModule::create_claim(RuntimeOrigin::signed(1), claim.clone()),
            Error::<Test>::ProofAlreadyExists
        );
    })
}

#[test]
fn revoke_claim_works() {
    new_test_ext().execute_with(|| {
        let claim = BoundedVec::try_from(vec![1, 1]).unwrap();
        let _ = PoeModule::create_claim(RuntimeOrigin::signed(1), claim.clone());

        assert_ok!(PoeModule::revoke_claim(
            RuntimeOrigin::signed(1),
            claim.clone()
        ));
    })
}

#[test]
fn revoke_claim_failed_when_claim_is_not_exist() {
    new_test_ext().execute_with(|| {
        let claim = BoundedVec::try_from(vec![1, 1]).unwrap();

        assert_noop!(
            PoeModule::revoke_claim(RuntimeOrigin::signed(1), claim.clone()),
            Error::<Test>::ClaimNotExist
        );
    })
}

#[test]
fn revoke_claim_failed_with_wrong_owner() {
    new_test_ext().execute_with(|| {
        let claim = BoundedVec::try_from(vec![1, 1]).unwrap();
        let _ = PoeModule::create_claim(RuntimeOrigin::signed(1), claim.clone());

        assert_noop!(
            PoeModule::revoke_claim(RuntimeOrigin::signed(2), claim.clone()),
            Error::<Test>::NotClaimOwner
        );
    })
}

#[test]
fn transfer_claim_works() {
    new_test_ext().execute_with(|| {
        let claim = BoundedVec::try_from(vec![1, 1]).unwrap();
        let _ = PoeModule::create_claim(RuntimeOrigin::signed(1), claim.clone());

        assert_ok!(PoeModule::transfer_claim(
            RuntimeOrigin::signed(1),
            claim.clone(),
            2
        ));

        let bounded_claim =
            BoundedVec::<u8, <Test as Config>::MaxClaimLength>::try_from(claim.clone()).unwrap();
        assert_eq!(
            Proofs::<Test>::get(&bounded_claim),
            Some((2, frame_system::Pallet::<Test>::block_number()))
        );
    })
}

#[test]
fn transfer_claim_failed_when_claim_is_not_exist() {
    new_test_ext().execute_with(|| {
        let claim = BoundedVec::try_from(vec![1, 1]).unwrap();

        assert_noop!(
            PoeModule::transfer_claim(RuntimeOrigin::signed(1), claim.clone(), 2),
            Error::<Test>::ClaimNotExist
        );
    })
}

#[test]
fn transfer_claim_failed_with_wrong_owner() {
    new_test_ext().execute_with(|| {
        let claim = BoundedVec::try_from(vec![1, 1]).unwrap();
        let _ = PoeModule::create_claim(RuntimeOrigin::signed(1), claim.clone());

        assert_noop!(
            PoeModule::transfer_claim(RuntimeOrigin::signed(2), claim.clone(), 3),
            Error::<Test>::NotClaimOwner
        );
    })
}

#[test]
fn transfer_claim_failed_with_same_owner() {
    new_test_ext().execute_with(|| {
        let claim = BoundedVec::try_from(vec![1, 1]).unwrap();
        let _ = PoeModule::create_claim(RuntimeOrigin::signed(1), claim.clone());

        assert_noop!(
            PoeModule::transfer_claim(RuntimeOrigin::signed(1), claim.clone(), 1),
            Error::<Test>::NewOwnerIsCurrentOwner
        );
    })
}

```

## 第十二步：运行测试

![poe_run_test](/images/poe_test.png)

### 第十三步：运行项目

启动一个 Substrate 区块链节点，运行在开发模式下，并且使用临时存储。每次启动时都会从一个全新的状态开始，适用于本地开发和测试，不会影响到之前的数据或状态。

![poe_run](/images/poe_run.png)

### 第十四步：连接 polkadot.js 网站，通过 Polkadot JS 应用程序测试 PoE

![poe](/images/poe_js.png)

### 第十五步：测试 createClaim

![poe](/images/create_claim1.png)
![poe](/images/create_claim2.png)

### 第十六步：测试 revokeClaim

![poe](/images/revokeClaim1.png)
![poe](/images/revokeClaim2.png)

### 第十七步：测试 transferClaim

![poe](/images/transferClaim1.png)
![poe](/images/transferClaim2.png)

查看确认是否成功：
![poe](/images/bob1.png)
![poe](/images/bob2.png)

## 总结

通过本次实操，读者不仅学习了如何在Substrate框架上实现PoE模块，还了解了如何进行模块化开发、代码调试与单元测试。Substrate的灵活性和可扩展性为区块链应用开发提供了新的可能，特别是像PoE这样的创新应用，能够在多个行业领域中发挥重要作用。在未来的开发中，开发者可以根据需求定制更多功能模块，扩展Substrate的应用范围。

## 参考

- <https://github.com/papermoonio/polkadot-sdk-solo-template-dev-courses>
- <https://docs.substrate.io/>
- <https://learnblockchain.cn/docs/substrate/>
- <https://polkadot.js.org/extension/>
- <https://github.com/paritytech/polkadot-sdk>
- <https://wiki.polkadot.network/docs/getting-started>
- <https://faucet.polkadot.io/>
