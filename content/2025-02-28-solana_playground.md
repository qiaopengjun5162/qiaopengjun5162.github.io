+++
title = "Web3 快上手：Solana 造你的链上名片"
description = "Web3 快上手：Solana 造你的链上名片"
date = 2025-02-28 11:07:37+08:00
[taxonomies]
categories = ["Solana", "Web3"]
tags = ["Solana", "Web3"]

+++

<!-- more -->

# Web3 快上手：Solana 造你的链上名片

想在 Web3 世界留下你的专属印记吗？用 Solana，几分钟就能打造一张“链上名片”！借助 Solana Playground 这个神器，我们将带你从零开始，快速上手区块链开发。无论是喜欢的数字、颜色，还是兴趣爱好，都能轻松上链，马上开启你的 Web3 冒险吧！

本文手把手教你如何用 Solana Playground 在 Solana 链上打造一张属于你的“名片”。通过五个简单步骤——创建项目、编写代码、构建、部署和测试，你将快速掌握基于 Anchor 框架的 Web3 开发技巧。程序能存储你的喜好数据（数字、颜色、爱好），并用 PDA 确保独一无二。适合 Web3 新手，五分钟入门区块链！

在开始实操前，我们先来搞懂一个 Solana 的核心概念：PDA（程序派生地址）。简单来说，PDA 是 Solana 程序生成的一种特殊地址，它不是由私钥控制，而是通过程序 ID 和一些“种子”（比如用户公钥）计算出来的。换句话说，PDA 就是 Solana 区块链上的一种“神奇地址”。它不像你钱包里那种普通地址（有私钥能自己控制），而是程序按照一定规则算出来的一个地址。比如说，它是用程序的 ID 加上一些“种子”（比如你的公钥）混在一起生成的，有点像给你的数据盖了个独一无二的戳。

想象一下，PDA 就像是你家门口的一个智能快递柜。快递员（程序）能打开它放东西，但你自己没有钥匙，只能通过程序去存取里面的东西。这样既安全（别人偷不了），又专属（每个人的柜子都不一样）。在咱们这个教程里，PDA 就是用来存你的“链上名片”数据的，保证你的喜好信息既不会丢，也不会被乱改！也就是说，我们会用 PDA 来存储你的“链上名片”数据，确保它既独一无二，又只能由程序管理。它的妙处在于：安全性高（没人能直接用私钥篡改），而且每个用户的 PDA 都不同，就像给你的喜好数据分配了一个专属的“链上保险箱”。在下面的实操中，你会看到 PDA 如何帮我们把喜欢的数字、颜色和爱好安全地存到 Solana 区块链上！

## 使用 Solana Playground 工具 实操

### 第一步：打开<https://beta.solpg.io/> 网站，单击创建一个新项目

![image-20250228111106626](/images/image-20250228111106626.png)

### 第二步：实现 `src/lib.rs` 代码

```rust
use anchor_lang::prelude::*;

declare_id!("ALuosANfx2rg9YDbBB5JnvtwNyvnLTVUntXDXhyiEzE");

pub const ANCHOR_DISCRIMINATOR_SIZE: usize = 8;

#[program]
pub mod favorites {
    use super::*;

    pub fn set_favorites(
        context: Context<SetFavorites>,
        number: u64,
        color: String,
        hobbies: Vec<String>,
    ) -> Result<()> {
        let user_public_key = context.accounts.user.key();
        msg!("Greetings from {}", context.program_id);
        msg!("User {user_public_key}'s favorite number is {number}, favorite color is: {color}");
        msg!("User's hobbies are: {:?}", hobbies);

        context.accounts.favorites.set_inner(Favorites {
            number,
            color,
            hobbies,
        });
        Ok(())
    }
}

#[account]
#[derive(InitSpace)]
pub struct Favorites {
    pub number: u64,

    #[max_len(50)]
    pub color: String,

    #[max_len(5, 50)]
    pub hobbies: Vec<String>,
}

#[derive(Accounts)]
pub struct SetFavorites<'info> {
    #[account(mut)]
    pub user: Signer<'info>,

    #[account(
        init_if_needed, 
        payer = user, 
        space = ANCHOR_DISCRIMINATOR_SIZE + Favorites::INIT_SPACE,
        seeds = [b"favorites", user.key().as_ref()],
        bump
    )]
    pub favorites: Account<'info, Favorites>,

    pub system_program: Program<'info, System>,
}

```

这是一个使用 Anchor 框架编写的 Solana 程序，用于存储用户的喜好数据（喜欢的数字、颜色和爱好列表）。

#### 代码结构概览

1. **导入和基础声明**

```rust
use anchor_lang::prelude::*;
declare_id!("ALuosANfx2rg9YDbBB5JnvtwNyvnLTVUntXDXhyiEzE");
pub const ANCHOR_DISCRIMINATOR_SIZE: usize = 8;
```

- `use anchor_lang::prelude::*`: 导入 Anchor 框架的基础模块。
- `declare_id!`: 定义程序的唯一 ID，这是部署到 Solana 网络时程序的地址。
- `ANCHOR_DISCRIMINATOR_SIZE`: 定义 Anchor 账户的鉴别器大小（8 字节），用于区分不同账户类型。

2. **程序模块**

```rust
#[program]
pub mod favorites {
    use super::*;
    // ... 函数定义 ...
}
```

- `#[program]`: Anchor 宏，表示这是一个 Solana 程序模块。
- 包含一个 `set_favorites` 函数，用于设置用户的喜好。

3. **数据结构**

```rust
#[account]
#[derive(InitSpace)]
pub struct Favorites {
    pub number: u64,
    #[max_len(50)]
    pub color: String,
    #[max_len(5, 50)]
    pub hobbies: Vec<String>,
}
```

- `#[account]`: 表示这是一个账户数据结构。
- `#[derive(InitSpace)]`: 自动计算账户所需的存储空间。
- 定义了 `Favorites` 结构体：
  - `number`: 64 位无符号整数，表示喜欢的数字。
  - `color`: 字符串，最大长度 50 个字符。
  - `hobbies`: 字符串向量，最大 5 个元素，每个字符串最大 50 个字符。

4. **账户验证结构**

```rust
#[derive(Accounts)]
pub struct SetFavorites<'info> {
    #[account(mut)]
    pub user: Signer<'info>,
    #[account(
        init_if_needed, 
        payer = user, 
        space = ANCHOR_DISCRIMINATOR_SIZE + Favorites::INIT_SPACE,
        seeds = [b"favorites", user.key().as_ref()],
        bump
    )]
    pub favorites: Account<'info, Favorites>,
    pub system_program: Program<'info, System>,
}
```

- `#[derive(Accounts)]`: 定义函数需要的账户上下文。
- `user`: 调用者账户，必须是签名者（`Signer`）。
- `favorites`: 存储喜好数据的账户，具有以下属性：
  - `init_if_needed`: 如果账户不存在则初始化。
  - `payer = user`: 由用户支付账户创建费用。
  - `space`: 账户大小，包含鉴别器（8 字节）加上 `Favorites` 结构体的空间。
  - `seeds`: 使用 PDA（程序派生地址），基于 "favorites" 和用户公钥生成。
  - `bump`: 用于确保 PDA 的唯一性。
- `system_program`: Solana 的系统程序，用于账户创建。

5. **主函数 `set_favorites`**

```rust
pub fn set_favorites(
    context: Context<SetFavorites>,
    number: u64,
    color: String,
    hobbies: Vec<String>,
) -> Result<()> {
    let user_public_key = context.accounts.user.key();
    msg!("Greetings from {}", context.program_id);
    msg!("User {user_public_key}'s favorite number is {number}, favorite color is: {color}");
    msg!("User's hobbies are: {:?}", hobbies);

    context.accounts.favorites.set_inner(Favorites {
        number,
        color,
        hobbies,
    });
    Ok(())
}
```

- **参数**：
  - `context`: 包含账户信息的上下文。
  - `number`, `color`, `hobbies`: 用户传入的喜好数据。
- **逻辑**：
  1. 获取用户的公钥。
  2. 使用 `msg!` 输出日志信息，便于调试。
  3. 更新 `favorites` 账户的数据，使用 `set_inner` 方法将新数据写入。
  4. 返回 `Ok(())`，表示成功执行。

#### 工作原理

- **功能**：这个程序允许用户通过调用 `set_favorites` 函数来设置他们的喜好（喜欢的数字、颜色和爱好列表）。
- **账户管理**：
  - 数据存储在 `favorites` 账户中，这是一个 PDA（程序派生地址），与用户的公钥绑定。
  - 如果账户不存在，会自动创建；如果已存在，则更新其中的数据。
- **安全性**：
  - 只有签名者（`user`）可以调用此函数。
  - 使用 PDA 确保每个用户有唯一的存储空间。

#### 使用场景

1. 用户通过前端调用此程序，传入他们的喜好数据。
2. 程序在链上存储这些数据，后续可以通过查询 `favorites` 账户来读取。

#### 示例调用

假设用户 Alice 想要设置：

- 喜欢的数字：42
- 喜欢的颜色："blue"
- 爱好列表：["reading", "gaming"]

前端会构造一个交易，调用 `set_favorites(42, "blue", ["reading", "gaming"])`，程序会：

1. 创建或更新 Alice 的 `favorites` 账户。
2. 存储这些数据，并在链上记录日志。

#### 注意事项

- **空间限制**：`color` 最大 50 个字符，`hobbies` 最多 5 个条目，每个条目 50 个字符。
- **费用**：账户创建需要用户支付少量 SOL 作为租金。
- **日志**：`msg!` 用于调试，实际部署时可以选择移除。

### 第三步：Build

![image-20250228215722238](/images/image-20250228215722238.png)

### 第四步：Deploy

![image-20250301111612419](/images/image-20250301111612419.png)

<https://explorer.solana.com/tx/zV4B8N8X41LNNhY5woCNpoDQp3B9gMGf1usg1BAfejctmSDWxpFAR2tWDHkWutGQ2jJZsXiRzHpJEUQhsxkbXNp?cluster=devnet>

![image-20250301111650222](/images/image-20250301111650222.png)

<https://explorer.solana.com/address/ALuosANfx2rg9YDbBB5JnvtwNyvnLTVUntXDXhyiEzE?cluster=devnet>

![image-20250301132011757](/images/image-20250301132011757.png)

### 第五步：Test

![image-20250301134342506](/images/image-20250301134342506.png)

## 总结

通过这次实操，你已经用 Solana Playground 在 Web3 世界里打造了一张属于自己的“链上名片”！从 Rust 代码到链上部署，短短几步就解锁了 Solana 的高效开发体验。无论你是 Web3 小白还是想玩点新花样，这只是个开始——快去试试更多功能，造出更酷的链上作品吧！

## 参考

- <https://beta.solpg.io/>
- <https://explorer.solana.com/tx/5H4VV7RoiAb2PZ34A11DPJA3EANv7s32Yyrmn7Ez9YLUPDUeMTVCGGFzXPGApXaUrNuaNDScV6mZrh1bYYYWuwkZ?cluster=devnet>
- <https://solana.com/zh/docs>
- <https://solanacookbook.com/zh/>
- <https://github.com/anza-xyz/platform-tools>
