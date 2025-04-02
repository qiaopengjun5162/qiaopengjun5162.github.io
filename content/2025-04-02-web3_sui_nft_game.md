+++
title = "Web3 新玩法：用 Sui Move 打造 NFT 抽奖游戏"
description = "Web3 新玩法：用 Sui Move 打造 NFT 抽奖游戏"
date = 2025-04-02 19:58:44+08:00
[taxonomies]
categories = ["Web3", "Sui", "NFT", "Game"]
tags = ["Web3", "Sui", "NFT", "Game"]
+++

<!-- more -->

# Web3 新玩法：用 Sui Move 打造 NFT 抽奖游戏

Web3 浪潮席卷而来，区块链游戏正在重新定义我们的娱乐方式！想象一下：用 NFT 当门票，参与一场公平透明的抽奖，赢家还能抱走全部奖池。这不是科幻，而是基于 Sui 区块链和 Move 语言打造的 NFTicketDraw 项目。本文将带你走进这个 Web3 新玩法，从代码到实战，一步步揭秘如何用 Sui Move 创建一个去中心化抽奖游戏。无论你是区块链爱好者还是开发者，准备好一起探索这场 NFT 抽奖的奇妙旅程吧！

NFTicketDraw 是 Web3 世界里的一次有趣尝试：用户用 FAUCET_COIN 购买 NFT 门票参与抽奖，游戏结束后，系统通过随机算法选出幸运儿，赢家独享奖池所有代币。本文将带你了解这个项目的核心：创建游戏、购买门票、确定赢家、兑换奖励四大步骤。我们不仅解析了 Sui Move 的智能合约代码，还提供了从项目搭建到部署的全程实操指南。通过 Sui 客户端的调用示例，你将看到如何在测试网上实现这一 Web3 抽奖游戏，轻松上手属于你的区块链实验！

## 游戏说明

 • create: 创建游戏。

 • buy_ticket: 用户购买门票。

 • determine_winner: 在游戏结束时确定赢家。

 • redeem: 赢家兑换奖励。

这是一个简单的流程，通过创建、购买、确定赢家和奖励兑换完成整个游戏逻辑。

## 实操

### 创建项目

```bash
➜ sui move new NFTicketDraw                                    
```

### 查看项目目录

```bash
letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [!] on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ ls                                                
Move.lock Move.toml build     sources   tests

letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [!] on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ tree . -L 6 -I 'target|cache|lib|out|build'       


.
├── Move.lock
├── Move.toml
├── sources
│   └── nfticketdraw.move
└── tests
    └── nfticketdraw_tests.move

3 directories, 4 files
```

### `nfticketdraw.move` 文件

```rust
/// Module: nfticketdraw
module nfticketdraw::nfticketdraw {
    use sui::balance::{Self, Balance};
    use sui::clock::Clock;
    use sui::coin::{Self, Coin};
    use sui::event::emit;
    use sui::random::{Random, new_generator};
    use faucet_coin::faucet_coin::FAUCET_COIN;

    const EGameInProgress: u64 = 0;
    const EGameAlreadyCompleted: u64 = 1;
    const EInvalidAmount: u64 = 2;
    const EGameMismatch: u64 = 3;
    const ENotWinner: u64 = 4;
    const ENoParticipants: u64 = 5;

    public struct Game has key {
        id: UID,
        cost_in_coin: u64,
        participants: u32,
        end_time: u64,
        winner: Option<u32>,
        balance: Balance<FAUCET_COIN>,
    }

    public struct Ticket has key {
        id: UID,
        game_id: ID,
        participant_index: u32,
    }

    // Events
    public struct GameCreated  has copy, drop {
        game_id: ID,
        end_time: u64,
        cost_in_coin: u64,
    }

    public struct TicketPurchased has copy, drop {
        game_id: ID,
        participant_index: u32,
        ticket_id: ID,
    }

    public struct WinnerDetermined has copy, drop {
        game_id: ID,
        winner_index: u32,
    }

    public struct RewardRedeemed has copy, drop {
        game_id: ID,
        participant_index: u32,
        amount: u64,
    }


    public fun create(end_time: u64, cost_in_coin: u64, ctx: &mut TxContext) {
        let game = Game {
            id: object::new(ctx),
            cost_in_coin,
            participants: 0,
            end_time,
            winner: option::none(),
            balance: balance::zero(),
        };

        emit<GameCreated>(GameCreated {
            game_id: object::id(&game),
            end_time,
            cost_in_coin,
        });

        transfer::share_object(game);
    }

    entry fun determine_winner(game: &mut Game, r: &Random, clock: &Clock, ctx: &mut TxContext) {
        assert!(game.end_time <= clock.timestamp_ms(), EGameInProgress);
        assert!(game.winner.is_none(), EGameAlreadyCompleted);
        assert!(game.participants > 0, ENoParticipants);
        let mut generator = r.new_generator(ctx);
        let winner = generator.generate_u32_in_range(1, game.participants);
        game.winner = option::some(winner);

        emit<WinnerDetermined>(WinnerDetermined {
            game_id: object::id(game),
            winner_index: winner,
        });
    }

    public fun buy_ticket(game: &mut Game, coin: Coin<FAUCET_COIN>, clock: &Clock, ctx: &mut TxContext): Ticket {
        assert!(game.end_time > clock.timestamp_ms(), EGameAlreadyCompleted);
        assert!(coin.value() == game.cost_in_coin, EInvalidAmount);

        game.participants = game.participants + 1;
        coin::put(&mut game.balance, coin);

        let ticket = Ticket {
            id: object::new(ctx),
            game_id: object::id(game),
            participant_index: game.participants,
        };

        emit<TicketPurchased>(TicketPurchased {
            game_id: object::id(game),
            participant_index: ticket.participant_index,
            ticket_id: object::id(&ticket),
        });
        ticket
    }

    public fun redeem(ticket: Ticket, game: Game, ctx: &mut TxContext): Coin<FAUCET_COIN> {
        assert!(object::id(&game) == ticket.game_id, EGameMismatch);
        assert!(game.winner.contains(&ticket.participant_index), ENotWinner);
        // 保存信息，以便在事件中使用
        let game_id = object::id(&game);
        let participant_index = ticket.participant_index;
        let reward_amount = game.balance.value();
        destroy_ticket(ticket);

        let Game { id, cost_in_coin: _, participants: _, end_time: _, winner: _, balance } = game;
        object::delete(id);
        let reward = balance.into_coin(ctx);

        emit<RewardRedeemed>(RewardRedeemed {
            game_id,
            participant_index,
            amount: reward_amount,
        });

        reward
    }

    public fun destroy_ticket(ticket: Ticket) {
        let Ticket { id, game_id: _, participant_index: _ } = ticket;
        object::delete(id);
    }

    #[test_only]
    public fun cost_in_coin(game: &Game): u64 {
        game.cost_in_coin
    }

    #[test_only]
    public fun end_time(game: &Game): u64 {
        game.end_time
    }

    #[test_only]
    public fun participants(game: &Game): u32 {
        game.participants
    }

    #[test_only]
    public fun winner(game: &Game): Option<u32> {
        game.winner
    }

    #[test_only]
    public fun balance(game: &Game): u64 {
        game.balance.value()
    }
}


```

这段代码实现了一个基于 NFT 的抽奖系统，用户可以购买门票参与抽奖，系统在指定时间结束后随机选出获胜者，获胜者可以兑换奖励。也就是说，实现一个抽奖游戏，用户支付一定数量的 FAUCET_COIN 购买门票（Ticket），游戏结束后随机抽取获胜者，获胜者可领取奖池中的所有代币。

1. 创建游戏: 调用 create 函数，设置结束时间和门票费用。

2. 购买门票: 用户调用 buy_ticket，支付代币并获得 Ticket。

3. 确定获胜者: 游戏结束后，调用 determine_winner 随机选择获胜者。

4. 兑换奖励: 获胜者使用 redeem 函数提交门票，领取奖池中的所有代币。

### `Move.toml` 文件

```ts
[package]
name = "NFTicketDraw"
edition = "2024.beta" # edition = "legacy" to use legacy (pre-2024) Move
# license = ""           # e.g., "MIT", "GPL", "Apache 2.0"
# authors = ["..."]      # e.g., ["Joe Smith (joesmith@noemail.com)", "John Snow (johnsnow@noemail.com)"]

[dependencies]
Sui = { git = "https://github.com/MystenLabs/sui.git", subdir = "crates/sui-framework/packages/sui-framework", rev = "framework/testnet" }
faucet_coin = {local = "../../task2/faucet_coin"}

# For remote import, use the `{ git = "...", subdir = "...", rev = "..." }`.
# Revision can be a branch, a tag, and a commit hash.
# MyRemotePackage = { git = "https://some.remote/host.git", subdir = "remote/path", rev = "main" }

# For local dependencies use `local = path`. Path is relative to the package root
# Local = { local = "../path/to" }

# To resolve a version conflict and force a specific version for dependency
# override use `override = true`
# Override = { local = "../conflicting/version", override = true }

[addresses]
nfticketdraw = "0x0"

# Named addresses will be accessible in Move as `@name`. They're also exported:
# for example, `std = "0x1"` is exported by the Standard Library.
# alice = "0xA11CE"

[dev-dependencies]
# The dev-dependencies section allows overriding dependencies for `--test` and
# `--dev` modes. You can introduce test-only dependencies here.
# Local = { local = "../path/to/dev-build" }

[dev-addresses]
# The dev-addresses section allows overwriting named addresses for the `--test`
# and `--dev` modes.
# alice = "0xB0B"


```

### 构建项目

```bash
➜ sui move build                                               
```

### 发布合约

```rust
letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [⇣!?] via 🅒 base took 5.2s 
➜ sui client publish --gas-budget 100000000 --skip-fetch-latest-git-deps --skip-dependency-verification  
[warn] Client/Server api version mismatch, client api version : 1.32.0, server api version : 1.36.2
INCLUDING DEPENDENCY faucet_coin
INCLUDING DEPENDENCY Sui
INCLUDING DEPENDENCY MoveStdlib
BUILDING NFTicketDraw
Skipping dependency verification
Transaction Digest: GorLrz7Kk8JH55ANCxLaUNcWCeimTJm1qpBecuWRf85H
╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Data                                                                                             │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                                   │
│ Gas Owner: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                                │
│ Gas Budget: 100000000 MIST                                                                                   │
│ Gas Price: 750 MIST                                                                                          │
│ Gas Payment:                                                                                                 │
│  ┌──                                                                                                         │
│  │ ID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                                    │
│  │ Version: 315156592                                                                                        │
│  │ Digest: f7KBAZSKxmYDvmu5uzApmMf4pSawZeeFS16qQjYLWqP                                                       │
│  └──                                                                                                         │
│                                                                                                              │
│ Transaction Kind: Programmable                                                                               │
│ ╭──────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │
│ │ Input Objects                                                                                            │ │
│ ├──────────────────────────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ 0   Pure Arg: Type: address, Value: "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73" │ │
│ ╰──────────────────────────────────────────────────────────────────────────────────────────────────────────╯ │
│ ╭─────────────────────────────────────────────────────────────────────────╮                                  │
│ │ Commands                                                                │                                  │
│ ├─────────────────────────────────────────────────────────────────────────┤                                  │
│ │ 0  Publish:                                                             │                                  │
│ │  ┌                                                                      │                                  │
│ │  │ Dependencies:                                                        │                                  │
│ │  │   0x0000000000000000000000000000000000000000000000000000000000000001 │                                  │
│ │  │   0x0000000000000000000000000000000000000000000000000000000000000002 │                                  │
│ │  │   0x3bd35a5bf5f3649d37a9eff58403950b99b135667be45fd776515b2d2316e63a │                                  │
│ │  └                                                                      │                                  │
│ │                                                                         │                                  │
│ │ 1  TransferObjects:                                                     │                                  │
│ │  ┌                                                                      │                                  │
│ │  │ Arguments:                                                           │                                  │
│ │  │   Result 0                                                           │                                  │
│ │  │ Address: Input  0                                                    │                                  │
│ │  └                                                                      │                                  │
│ ╰─────────────────────────────────────────────────────────────────────────╯                                  │
│                                                                                                              │
│ Signatures:                                                                                                  │
│    eH0M8wVgFBpd7bddp0/G2Y7/ea9PZ19d3D2iFeuR6kxVfT2Jl72HqZJK2D9NDOBl6u/p6WCFCGmfFCuVQj0LCw==                  │
│                                                                                                              │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Effects                                                                               │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Digest: GorLrz7Kk8JH55ANCxLaUNcWCeimTJm1qpBecuWRf85H                                              │
│ Status: Success                                                                                   │
│ Executed Epoch: 575                                                                               │
│                                                                                                   │
│ Created Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0x496748d4d94c241583d915fb6e81f52601dc2c813af3d5e9584d5643d69f1afd                         │
│  │ Owner: Immutable                                                                               │
│  │ Version: 1                                                                                     │
│  │ Digest: FmkXfa3FmDp4GMBZ9m6A3qE2KnwKQWaParSascMAyQqD                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0xcf45b8cafcc50b47db08e1f1d32604bc0f568d27d1d240f6b7a26357f9a56586                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 315156593                                                                             │
│  │ Digest: 9KDX5QEkVc3Pno9K1YcupWLnBY5a1RJtJo8Ci76mnqaW                                           │
│  └──                                                                                              │
│ Mutated Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 315156593                                                                             │
│  │ Digest: 3zg1TxSMcUg8VJWkZ6CXS9XqJs57fsfh4oyrRpfph6XV                                           │
│  └──                                                                                              │
│ Gas Object:                                                                                       │
│  ┌──                                                                                              │
│  │ ID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 315156593                                                                             │
│  │ Digest: 3zg1TxSMcUg8VJWkZ6CXS9XqJs57fsfh4oyrRpfph6XV                                           │
│  └──                                                                                              │
│ Gas Cost Summary:                                                                                 │
│    Storage Cost: 20558000 MIST                                                                    │
│    Computation Cost: 750000 MIST                                                                  │
│    Storage Rebate: 978120 MIST                                                                    │
│    Non-refundable Storage Fee: 9880 MIST                                                          │
│                                                                                                   │
│ Transaction Dependencies:                                                                         │
│    49puDQZwHRnu7zYoARCjco1dFKMiK7LVSS8B5Si1yVdh                                                   │
│    8MkMyu5cseLwqyWDwg947q7U2d7ipSoGu9LZQh744JRJ                                                   │
│    GpZPCRjYwezkdC2PGVFrJDdTzkN6KVJwarqB7roPDWKE                                                   │
│    GvbJ8ia1HfavuccAmi8EJJAaCGShtdv4NWrs1B13vvom                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─────────────────────────────╮
│ No transaction block events │
╰─────────────────────────────╯

╭──────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                   │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0xcf45b8cafcc50b47db08e1f1d32604bc0f568d27d1d240f6b7a26357f9a56586                  │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                    │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 ) │
│  │ ObjectType: 0x2::package::UpgradeCap                                                          │
│  │ Version: 315156593                                                                            │
│  │ Digest: 9KDX5QEkVc3Pno9K1YcupWLnBY5a1RJtJo8Ci76mnqaW                                          │
│  └──                                                                                             │
│ Mutated Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                  │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                    │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 315156593                                                                            │
│  │ Digest: 3zg1TxSMcUg8VJWkZ6CXS9XqJs57fsfh4oyrRpfph6XV                                          │
│  └──                                                                                             │
│ Published Objects:                                                                               │
│  ┌──                                                                                             │
│  │ PackageID: 0x496748d4d94c241583d915fb6e81f52601dc2c813af3d5e9584d5643d69f1afd                 │
│  │ Version: 1                                                                                    │
│  │ Digest: FmkXfa3FmDp4GMBZ9m6A3qE2KnwKQWaParSascMAyQqD                                          │
│  │ Modules: nfticketdraw                                                                         │
│  └──                                                                                             │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Balance Changes                                                                                   │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                              │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ CoinType: 0x2::sui::SUI                                                                        │
│  │ Amount: -20329880                                                                              │
│  └──                                                                                              │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯

letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [⇣!?] via 🅒 base took 10.5s 
➜ 

```

### 调用`mint`函数

```bash
export PACKAGE_ID=0x0c303dc81a35841a80e40462b6f96d9b1a9e519e1b01ddfc94be00061127fa0c
export TREASURYCAP_ID=0x3f2b8b45d2e7c655026dec24c15e220d18a23ed624e9caa0ccac4814aad554f2  
sui client call --function mint --module mycoin --package $PACKAGE_ID --args $TREASURYCAP_ID 100 0x7b8e0864967427679b4e129f79dc332a885c6087ec9e187b53451a9006ee15f2 --gas-budget 10000000  


letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [⇣!?] via 🅒 base took 10.5s 
➜ export PACKAGE_ID=0x3bd35a5bf5f3649d37a9eff58403950b99b135667be45fd776515b2d2316e63a                                                                  

letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [⇣!?] via 🅒 base 
➜ export MySupply=0xbca89418717ee5dd5c1f63c46fd8e0d7ee57e1f1f80de39f5cfd4599b19a838c          

letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [⇣!?] via 🅒 base 
➜ sui client call --function mint --module faucet_coin --package $PACKAGE_ID --args $MySupply 100 --gas-budget 10000000                                                                                                                                                                               
[warn] Client/Server api version mismatch, client api version : 1.32.0, server api version : 1.36.2
Transaction Digest: F8V1rPcLYR7QijakrbkZkzPEMfJeanUaPAidLnUTj9C7
╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Data                                                                                │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                      │
│ Gas Owner: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                   │
│ Gas Budget: 10000000 MIST                                                                       │
│ Gas Price: 750 MIST                                                                             │
│ Gas Payment:                                                                                    │
│  ┌──                                                                                            │
│  │ ID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                       │
│  │ Version: 315156593                                                                           │
│  │ Digest: 3zg1TxSMcUg8VJWkZ6CXS9XqJs57fsfh4oyrRpfph6XV                                         │
│  └──                                                                                            │
│                                                                                                 │
│ Transaction Kind: Programmable                                                                  │
│ ╭─────────────────────────────────────────────────────────────────────────────────────────────╮ │
│ │ Input Objects                                                                               │ │
│ ├─────────────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ 0   Imm/Owned Object ID: 0xbca89418717ee5dd5c1f63c46fd8e0d7ee57e1f1f80de39f5cfd4599b19a838c │ │
│ │ 1   Pure Arg: Type: u64, Value: "100"                                                       │ │
│ ╰─────────────────────────────────────────────────────────────────────────────────────────────╯ │
│ ╭──────────────────────────────────────────────────────────────────────────────────╮            │
│ │ Commands                                                                         │            │
│ ├──────────────────────────────────────────────────────────────────────────────────┤            │
│ │ 0  MoveCall:                                                                     │            │
│ │  ┌                                                                               │            │
│ │  │ Function:  mint                                                               │            │
│ │  │ Module:    faucet_coin                                                        │            │
│ │  │ Package:   0x3bd35a5bf5f3649d37a9eff58403950b99b135667be45fd776515b2d2316e63a │            │
│ │  │ Arguments:                                                                    │            │
│ │  │   Input  0                                                                    │            │
│ │  │   Input  1                                                                    │            │
│ │  └                                                                               │            │
│ ╰──────────────────────────────────────────────────────────────────────────────────╯            │
│                                                                                                 │
│ Signatures:                                                                                     │
│    n+6assbsM2KmMWFAgbTPE2xMGvlmXov1EByhHtRx7i3iv2TxHglVCWLkjmIEPZCzYKciq81kzNNBc/5PZP9DBA==     │
│                                                                                                 │
╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Effects                                                                               │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Digest: F8V1rPcLYR7QijakrbkZkzPEMfJeanUaPAidLnUTj9C7                                              │
│ Status: Success                                                                                   │
│ Executed Epoch: 575                                                                               │
│                                                                                                   │
│ Created Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0xd9823fcb352a8b61ae290f8aba32ca5af406b85f32f01efd620a53596fbb3760                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 315156594                                                                             │
│  │ Digest: 8rhB1mDAUph9JwwLMr8kKsokwmmRXKsJ13ehHFco9igM                                           │
│  └──                                                                                              │
│ Mutated Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 315156594                                                                             │
│  │ Digest: GoYBWwEuVTgfcKgkKn5qyXx9KFtUNdYW4CfCDpCsqNMk                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0xbca89418717ee5dd5c1f63c46fd8e0d7ee57e1f1f80de39f5cfd4599b19a838c                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 315156594                                                                             │
│  │ Digest: DWG5H6EtqrCRwrCCn4woVcSuvKTsabzbwQQXV32FjkNe                                           │
│  └──                                                                                              │
│ Gas Object:                                                                                       │
│  ┌──                                                                                              │
│  │ ID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 315156594                                                                             │
│  │ Digest: GoYBWwEuVTgfcKgkKn5qyXx9KFtUNdYW4CfCDpCsqNMk                                           │
│  └──                                                                                              │
│ Gas Cost Summary:                                                                                 │
│    Storage Cost: 3815200 MIST                                                                     │
│    Computation Cost: 750000 MIST                                                                  │
│    Storage Rebate: 2362536 MIST                                                                   │
│    Non-refundable Storage Fee: 23864 MIST                                                         │
│                                                                                                   │
│ Transaction Dependencies:                                                                         │
│    GorLrz7Kk8JH55ANCxLaUNcWCeimTJm1qpBecuWRf85H                                                   │
│    GvbJ8ia1HfavuccAmi8EJJAaCGShtdv4NWrs1B13vvom                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─────────────────────────────╮
│ No transaction block events │
╰─────────────────────────────╯

╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                                                │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                                              │
│  ┌──                                                                                                                          │
│  │ ObjectID: 0xd9823fcb352a8b61ae290f8aba32ca5af406b85f32f01efd620a53596fbb3760                                               │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                                                 │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )                              │
│  │ ObjectType: 0x2::coin::Coin<0x3bd35a5bf5f3649d37a9eff58403950b99b135667be45fd776515b2d2316e63a::faucet_coin::FAUCET_COIN>  │
│  │ Version: 315156594                                                                                                         │
│  │ Digest: 8rhB1mDAUph9JwwLMr8kKsokwmmRXKsJ13ehHFco9igM                                                                       │
│  └──                                                                                                                          │
│ Mutated Objects:                                                                                                              │
│  ┌──                                                                                                                          │
│  │ ObjectID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                                               │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                                                 │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )                              │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                                 │
│  │ Version: 315156594                                                                                                         │
│  │ Digest: GoYBWwEuVTgfcKgkKn5qyXx9KFtUNdYW4CfCDpCsqNMk                                                                       │
│  └──                                                                                                                          │
│  ┌──                                                                                                                          │
│  │ ObjectID: 0xbca89418717ee5dd5c1f63c46fd8e0d7ee57e1f1f80de39f5cfd4599b19a838c                                               │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                                                 │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )                              │
│  │ ObjectType: 0x3bd35a5bf5f3649d37a9eff58403950b99b135667be45fd776515b2d2316e63a::faucet_coin::MySupply                      │
│  │ Version: 315156594                                                                                                         │
│  │ Digest: DWG5H6EtqrCRwrCCn4woVcSuvKTsabzbwQQXV32FjkNe                                                                       │
│  └──                                                                                                                          │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
╭────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Balance Changes                                                                                            │
├────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                       │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )           │
│  │ CoinType: 0x2::sui::SUI                                                                                 │
│  │ Amount: -2202664                                                                                        │
│  └──                                                                                                       │
│  ┌──                                                                                                       │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )           │
│  │ CoinType: 0x3bd35a5bf5f3649d37a9eff58403950b99b135667be45fd776515b2d2316e63a::faucet_coin::FAUCET_COIN  │
│  │ Amount: 100                                                                                             │
│  └──                                                                                                       │

letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [⇣!?] via 🅒 base took 5.3s 
➜ 

letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [⇣!?] via 🅒 base took 10.5s 
➜ export PACKAGE_ID=0x3bd35a5bf5f3649d37a9eff58403950b99b135667be45fd776515b2d2316e63a                                                                  

letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [⇣!?] via 🅒 base 
➜ export MySupply=0xbca89418717ee5dd5c1f63c46fd8e0d7ee57e1f1f80de39f5cfd4599b19a838c          

letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [⇣!?] via 🅒 base 
➜ sui client call --function mint --module faucet_coin --package $PACKAGE_ID --args $MySupply 100 --gas-budget 10000000                                                                                                                                                                               
[warn] Client/Server api version mismatch, client api version : 1.32.0, server api version : 1.36.2
Transaction Digest: F8V1rPcLYR7QijakrbkZkzPEMfJeanUaPAidLnUTj9C7
╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Data                                                                                │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                      │
│ Gas Owner: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                   │
│ Gas Budget: 10000000 MIST                                                                       │
│ Gas Price: 750 MIST                                                                             │
│ Gas Payment:                                                                                    │
│  ┌──                                                                                            │
│  │ ID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                       │
│  │ Version: 315156593                                                                           │
│  │ Digest: 3zg1TxSMcUg8VJWkZ6CXS9XqJs57fsfh4oyrRpfph6XV                                         │
│  └──                                                                                            │
│                                                                                                 │
│ Transaction Kind: Programmable                                                                  │
│ ╭─────────────────────────────────────────────────────────────────────────────────────────────╮ │
│ │ Input Objects                                                                               │ │
│ ├─────────────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ 0   Imm/Owned Object ID: 0xbca89418717ee5dd5c1f63c46fd8e0d7ee57e1f1f80de39f5cfd4599b19a838c │ │
│ │ 1   Pure Arg: Type: u64, Value: "100"                                                       │ │
│ ╰─────────────────────────────────────────────────────────────────────────────────────────────╯ │
│ ╭──────────────────────────────────────────────────────────────────────────────────╮            │
│ │ Commands                                                                         │            │
│ ├──────────────────────────────────────────────────────────────────────────────────┤            │
│ │ 0  MoveCall:                                                                     │            │
│ │  ┌                                                                               │            │
│ │  │ Function:  mint                                                               │            │
│ │  │ Module:    faucet_coin                                                        │            │
│ │  │ Package:   0x3bd35a5bf5f3649d37a9eff58403950b99b135667be45fd776515b2d2316e63a │            │
│ │  │ Arguments:                                                                    │            │
│ │  │   Input  0                                                                    │            │
│ │  │   Input  1                                                                    │            │
│ │  └                                                                               │            │
│ ╰──────────────────────────────────────────────────────────────────────────────────╯            │
│                                                                                                 │
│ Signatures:                                                                                     │
│    n+6assbsM2KmMWFAgbTPE2xMGvlmXov1EByhHtRx7i3iv2TxHglVCWLkjmIEPZCzYKciq81kzNNBc/5PZP9DBA==     │
│                                                                                                 │
╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Effects                                                                               │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Digest: F8V1rPcLYR7QijakrbkZkzPEMfJeanUaPAidLnUTj9C7                                              │
│ Status: Success                                                                                   │
│ Executed Epoch: 575                                                                               │
│                                                                                                   │
│ Created Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0xd9823fcb352a8b61ae290f8aba32ca5af406b85f32f01efd620a53596fbb3760                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 315156594                                                                             │
│  │ Digest: 8rhB1mDAUph9JwwLMr8kKsokwmmRXKsJ13ehHFco9igM                                           │
│  └──                                                                                              │
│ Mutated Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 315156594                                                                             │
│  │ Digest: GoYBWwEuVTgfcKgkKn5qyXx9KFtUNdYW4CfCDpCsqNMk                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0xbca89418717ee5dd5c1f63c46fd8e0d7ee57e1f1f80de39f5cfd4599b19a838c                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 315156594                                                                             │
│  │ Digest: DWG5H6EtqrCRwrCCn4woVcSuvKTsabzbwQQXV32FjkNe                                           │
│  └──                                                                                              │
│ Gas Object:                                                                                       │
│  ┌──                                                                                              │
│  │ ID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 315156594                                                                             │
│  │ Digest: GoYBWwEuVTgfcKgkKn5qyXx9KFtUNdYW4CfCDpCsqNMk                                           │
│  └──                                                                                              │
│ Gas Cost Summary:                                                                                 │
│    Storage Cost: 3815200 MIST                                                                     │
│    Computation Cost: 750000 MIST                                                                  │
│    Storage Rebate: 2362536 MIST                                                                   │
│    Non-refundable Storage Fee: 23864 MIST                                                         │
│                                                                                                   │
│ Transaction Dependencies:                                                                         │
│    GorLrz7Kk8JH55ANCxLaUNcWCeimTJm1qpBecuWRf85H                                                   │
│    GvbJ8ia1HfavuccAmi8EJJAaCGShtdv4NWrs1B13vvom                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─────────────────────────────╮
│ No transaction block events │
╰─────────────────────────────╯

╭───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                                                │
├───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                                              │
│  ┌──                                                                                                                          │
│  │ ObjectID: 0xd9823fcb352a8b61ae290f8aba32ca5af406b85f32f01efd620a53596fbb3760                                               │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                                                 │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )                              │
│  │ ObjectType: 0x2::coin::Coin<0x3bd35a5bf5f3649d37a9eff58403950b99b135667be45fd776515b2d2316e63a::faucet_coin::FAUCET_COIN>  │
│  │ Version: 315156594                                                                                                         │
│  │ Digest: 8rhB1mDAUph9JwwLMr8kKsokwmmRXKsJ13ehHFco9igM                                                                       │
│  └──                                                                                                                          │
│ Mutated Objects:                                                                                                              │
│  ┌──                                                                                                                          │
│  │ ObjectID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                                               │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                                                 │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )                              │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                                                 │
│  │ Version: 315156594                                                                                                         │
│  │ Digest: GoYBWwEuVTgfcKgkKn5qyXx9KFtUNdYW4CfCDpCsqNMk                                                                       │
│  └──                                                                                                                          │
│  ┌──                                                                                                                          │
│  │ ObjectID: 0xbca89418717ee5dd5c1f63c46fd8e0d7ee57e1f1f80de39f5cfd4599b19a838c                                               │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                                                 │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )                              │
│  │ ObjectType: 0x3bd35a5bf5f3649d37a9eff58403950b99b135667be45fd776515b2d2316e63a::faucet_coin::MySupply                      │
│  │ Version: 315156594                                                                                                         │
│  │ Digest: DWG5H6EtqrCRwrCCn4woVcSuvKTsabzbwQQXV32FjkNe                                                                       │
│  └──                                                                                                                          │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
╭────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Balance Changes                                                                                            │
├────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                       │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )           │
│  │ CoinType: 0x2::sui::SUI                                                                                 │
│  │ Amount: -2202664                                                                                        │
│  └──                                                                                                       │
│  ┌──                                                                                                       │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )           │
│  │ CoinType: 0x3bd35a5bf5f3649d37a9eff58403950b99b135667be45fd776515b2d2316e63a::faucet_coin::FAUCET_COIN  │
│  │ Amount: 100                                                                                             │
│  └──                                                                                                       │

letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [⇣!?] via 🅒 base took 5.3s 
➜ 

```

### 调用`create`函数

```bash
letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [⇣!?] via 🅒 base 
➜ export PACKAGE_ID=0x496748d4d94c241583d915fb6e81f52601dc2c813af3d5e9584d5643d69f1afd                                                                  

letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [⇣!?] via 🅒 base 
➜ echo $PACKAGE_ID                                                                    
0x496748d4d94c241583d915fb6e81f52601dc2c813af3d5e9584d5643d69f1afd

letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [⇣!?] via 🅒 base 
➜ sui client call --function create --module nfticketdraw --package $PACKAGE_ID --args 1731133219000 10 --gas-budget 10000000 
[warn] Client/Server api version mismatch, client api version : 1.32.0, server api version : 1.36.2
Transaction Digest: 3ZymeB9CVZdkwQBuaP1NJtPZU5hT2tkmVRqUGJYJbPeG
╭─────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Data                                                                            │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                  │
│ Gas Owner: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73               │
│ Gas Budget: 10000000 MIST                                                                   │
│ Gas Price: 750 MIST                                                                         │
│ Gas Payment:                                                                                │
│  ┌──                                                                                        │
│  │ ID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                   │
│  │ Version: 315156594                                                                       │
│  │ Digest: GoYBWwEuVTgfcKgkKn5qyXx9KFtUNdYW4CfCDpCsqNMk                                     │
│  └──                                                                                        │
│                                                                                             │
│ Transaction Kind: Programmable                                                              │
│ ╭─────────────────────────────────────────────────╮                                         │
│ │ Input Objects                                   │                                         │
│ ├─────────────────────────────────────────────────┤                                         │
│ │ 0   Pure Arg: Type: u64, Value: "1731133219000" │                                         │
│ │ 1   Pure Arg: Type: u64, Value: "10"            │                                         │
│ ╰─────────────────────────────────────────────────╯                                         │
│ ╭──────────────────────────────────────────────────────────────────────────────────╮        │
│ │ Commands                                                                         │        │
│ ├──────────────────────────────────────────────────────────────────────────────────┤        │
│ │ 0  MoveCall:                                                                     │        │
│ │  ┌                                                                               │        │
│ │  │ Function:  create                                                             │        │
│ │  │ Module:    nfticketdraw                                                       │        │
│ │  │ Package:   0x496748d4d94c241583d915fb6e81f52601dc2c813af3d5e9584d5643d69f1afd │        │
│ │  │ Arguments:                                                                    │        │
│ │  │   Input  0                                                                    │        │
│ │  │   Input  1                                                                    │        │
│ │  └                                                                               │        │
│ ╰──────────────────────────────────────────────────────────────────────────────────╯        │
│                                                                                             │
│ Signatures:                                                                                 │
│    ZVSiXxelLzzMFN04k78EWpFytHO/7xIiux22skcH1+lc+sVSKOK34Mvb2SXhgkpGZai4SV/amek21gKwhg91Ag== │
│                                                                                             │
╰─────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Effects                                                                               │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Digest: 3ZymeB9CVZdkwQBuaP1NJtPZU5hT2tkmVRqUGJYJbPeG                                              │
│ Status: Success                                                                                   │
│ Executed Epoch: 576                                                                               │
│                                                                                                   │
│ Created Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0x4cb5381be46a8246721a0a7f843b89a617056286d473881cce087e4b706d3ca9                         │
│  │ Owner: Shared( 315156595 )                                                                     │
│  │ Version: 315156595                                                                             │
│  │ Digest: 77KJVZk8kqfdPEshi2RwEKenD3PmpNHHXV9JUJbNwszr                                           │
│  └──                                                                                              │
│ Mutated Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 315156595                                                                             │
│  │ Digest: AXJif6s2989Jo6EA2XuS1emhoNLh2cEuHhg5T2BZozAS                                           │
│  └──                                                                                              │
│ Gas Object:                                                                                       │
│  ┌──                                                                                              │
│  │ ID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 315156595                                                                             │
│  │ Digest: AXJif6s2989Jo6EA2XuS1emhoNLh2cEuHhg5T2BZozAS                                           │
│  └──                                                                                              │
│ Gas Cost Summary:                                                                                 │
│    Storage Cost: 2523200 MIST                                                                     │
│    Computation Cost: 750000 MIST                                                                  │
│    Storage Rebate: 978120 MIST                                                                    │
│    Non-refundable Storage Fee: 9880 MIST                                                          │
│                                                                                                   │
│ Transaction Dependencies:                                                                         │
│    F8V1rPcLYR7QijakrbkZkzPEMfJeanUaPAidLnUTj9C7                                                   │
│    GorLrz7Kk8JH55ANCxLaUNcWCeimTJm1qpBecuWRf85H                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Block Events                                                                                    │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                                        │
│  │ EventID: 3ZymeB9CVZdkwQBuaP1NJtPZU5hT2tkmVRqUGJYJbPeG:0                                                  │
│  │ PackageID: 0x496748d4d94c241583d915fb6e81f52601dc2c813af3d5e9584d5643d69f1afd                            │
│  │ Transaction Module: nfticketdraw                                                                         │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                               │
│  │ EventType: 0x496748d4d94c241583d915fb6e81f52601dc2c813af3d5e9584d5643d69f1afd::nfticketdraw::GameCreated │
│  │ ParsedJSON:                                                                                              │
│  │   ┌──────────────┬────────────────────────────────────────────────────────────────────┐                  │
│  │   │ cost_in_coin │ 10                                                                 │                  │
│  │   ├──────────────┼────────────────────────────────────────────────────────────────────┤                  │
│  │   │ end_time     │ 1731133219000                                                      │                  │
│  │   ├──────────────┼────────────────────────────────────────────────────────────────────┤                  │
│  │   │ game_id      │ 0x4cb5381be46a8246721a0a7f843b89a617056286d473881cce087e4b706d3ca9 │                  │
│  │   └──────────────┴────────────────────────────────────────────────────────────────────┘                  │
│  └──                                                                                                        │
╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
╭────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                         │
├────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                       │
│  ┌──                                                                                                   │
│  │ ObjectID: 0x4cb5381be46a8246721a0a7f843b89a617056286d473881cce087e4b706d3ca9                        │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                          │
│  │ Owner: Shared( 315156595 )                                                                          │
│  │ ObjectType: 0x496748d4d94c241583d915fb6e81f52601dc2c813af3d5e9584d5643d69f1afd::nfticketdraw::Game  │
│  │ Version: 315156595                                                                                  │
│  │ Digest: 77KJVZk8kqfdPEshi2RwEKenD3PmpNHHXV9JUJbNwszr                                                │
│  └──                                                                                                   │
│ Mutated Objects:                                                                                       │
│  ┌──                                                                                                   │
│  │ ObjectID: 0xb2a2ed6532874381998c171774c9411200033c3f7c4fa4899c28627ae2857f29                        │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                          │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )       │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                          │
│  │ Version: 315156595                                                                                  │
│  │ Digest: AXJif6s2989Jo6EA2XuS1emhoNLh2cEuHhg5T2BZozAS                                                │
│  └──                                                                                                   │
╰────────────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Balance Changes                                                                                   │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                              │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ CoinType: 0x2::sui::SUI                                                                        │
│  │ Amount: -2295080                                                                               │
│  └──                                                                                              │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯

letsmove/mover/qiaopengjun5162/code/task4/NFTicketDraw on  main [⇣!?] via 🅒 base took 5.2s 
➜ 

```

## 总结

NFTicketDraw 用 Sui Move 点燃了 Web3 抽奖的新火花！这个项目不仅展示了 NFT 如何化身抽奖门票，还通过 Sui 区块链的高效和 Move 语言的安全性，打造了一个公平又好玩的去中心化游戏。本文从代码到部署，完整呈现了开发过程，让你不仅能看懂，还能动手试试。虽然目前只是个简单雏形，但它已经为 Web3 游戏打开了一扇窗。未来，加入多轮抽奖、动态奖池甚至炫酷界面，NFTicketDraw 的潜力无限。Web3 的舞台已经搭好，你准备好用 NFT 玩出新花样了吗？

## 参考

- <https://suiscan.xyz/mainnet/object/0x0c303dc81a35841a80e40462b6f96d9b1a9e519e1b01ddfc94be00061127fa0c/contracts>
- <https://suiscan.xyz/mainnet/object/0x0c303dc81a35841a80e40462b6f96d9b1a9e519e1b01ddfc94be00061127fa0c/txs>
- <https://suiscan.xyz/mainnet/object/0x3bd35a5bf5f3649d37a9eff58403950b99b135667be45fd776515b2d2316e63a/contracts>
- <https://suiscan.xyz/mainnet/object/0x496748d4d94c241583d915fb6e81f52601dc2c813af3d5e9584d5643d69f1afd/txs>
- <https://suiscan.xyz/mainnet/tx/3ZymeB9CVZdkwQBuaP1NJtPZU5hT2tkmVRqUGJYJbPeG>
- <https://suivision.xyz/>
- <https://docs.sui.io/sui-api-ref#suix_getallcoins>
- <https://sui.io/>
- <https://docs.suiwallet.com/>
