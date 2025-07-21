+++
title = "Solana 投票 DApp 开发实战：从合约到部署的完整指南"
description = "Solana 投票 DApp 开发实战：从合约到部署的完整指南"
date = 2025-07-21T00:56:45Z
[taxonomies]
categories = ["Web3", "Solana", "Anchor", "DApp"]
tags = ["Web3", "Solana", "Anchor", "DApp"]
+++

<!-- more -->

# Solana 投票 DApp 开发实战：从合约到部署的完整指南

Solana 以其高性能和低成本的特点，正吸引着越来越多的开发者进入其生态。而 Anchor 框架的出现，更是极大地降低了 Solana 智能合约的开发门槛。但对于许多初学者来说，如何将零散的知识点串联起来，完成一个从无到有的完整项目，仍然是一个挑战。

在本文中，我们将一起从零开始，以一个经典的“链上投票”应用为目标，使用强大的 Anchor 框架来完成这个任务。我们将依次经历以下几个阶段：

1. **环境准备与项目初始化**
2. **智能合约（程序）的详细实现与讲解**
3. **编写并运行覆盖正反场景的全面测试脚本**
4. **编译、部署合约到 Solana 开发网络并进行链上验证**

最终，你将拥有一个部署在公链上、可以通过区块浏览器验证的 DApp。无论你是希望转型的 Web2 开发者，还是对 Web3 充满好奇的学习者，相信这篇详尽的实战文章都能为你点亮 Solana 开发的技能树。

本文以一个链上投票 DApp 为例，完整演示了 Solana 开发全流程。你将跟随本指南，使用 Anchor 框架亲手完成项目创建、合约编写、单元测试与最终的链上部署。文章详尽记录了每一步操作与关键代码，是入门 Solana 不可错过的端到端实战教程。

## 实操

### 创建项目

```bash
anchor init voting
yarn install v1.22.22
info No lockfile found.
[1/4] 🔍  Resolving packages...
info There appears to be trouble with your network connection. Retrying...
info There appears to be trouble with your network connection. Retrying...
warning mocha > glob@7.2.0: Glob versions prior to v9 are no longer supported
warning mocha > glob > inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
[2/4] 🚚  Fetching packages...
[3/4] 🔗  Linking dependencies...
[4/4] 🔨  Building fresh packages...
success Saved lockfile.
✨  Done in 29.40s.
Failed to install node modules
提示： 使用 'master' 作为初始分支的名称。这个默认分支名称可能会更改。要在新仓库中
提示： 配置使用初始分支名，并消除这条警告，请执行：
提示：
提示：  git config --global init.defaultBranch <名称>
提示：
提示： 除了 'master' 之外，通常选定的名字有 'main'、'trunk' 和 'development'。
提示： 可以通过以下命令重命名刚创建的分支：
提示：
提示：  git branch -m <name>
提示：
提示： Disable this message with "git config set advice.defaultBranchName false"
已初始化空的 Git 仓库于 /Users/qiaopengjun/Code/Solana/voting/.git/
voting initialized
```

### 切换到项目目录并用`cursor` 打开项目

```bash
cd voting
cc # open -a cursor .
```

### 查看项目目录结构

```bash
voting on  master [!?] via ⬢ v23.11.0 via 🦀 1.88.0 
➜ tree . -L 6 -I "migrations|mochawesome-report|.anchor|docs|target|node_modules"
.
├── Anchor.toml
├── app
├── Cargo.lock
├── Cargo.toml
├── cliff.toml
├── idls
│   └── voting
│       └── voting-2025-07-18-093219.json
├── Makefile
├── package.json
├── pnpm-lock.yaml
├── programs
│   └── voting
│       ├── Cargo.toml
│       ├── src
│       │   └── lib.rs
│       └── Xargo.toml
├── tests
│   └── voting.ts
├── tsconfig.json

18 directories, 37 files

```

### 实现程序（合约） `lib.rs`

```rust
#![allow(unexpected_cfgs, deprecated)]

use anchor_lang::prelude::*;

declare_id!("Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz");

#[program]
pub mod voting {
    use super::*;

    // 初始化投票活动
    pub fn initialize_poll(
        ctx: Context<InitializePoll>,
        name: String,
        description: String,
        start_time: u64,
        end_time: u64,
    ) -> Result<()> {
        let poll_account = &mut ctx.accounts.poll_account;
        poll_account.name = name;
        poll_account.description = description;
        poll_account.start_time = start_time;
        poll_account.end_time = end_time;
        poll_account.authority = ctx.accounts.signer.key();
        poll_account.candidates = Vec::new();

        // 关键修复：使用专门的计数器，避免 Vec.len() 的解释错误
        poll_account.candidate_count = 0;

        Ok(())
    }

    // 添加候选人
    pub fn add_candidate(ctx: Context<AddCandidate>, candidate_name: String) -> Result<()> {
        require_keys_eq!(
            ctx.accounts.poll_account.authority,
            ctx.accounts.signer.key(),
            ErrorCode::Unauthorized
        );

        let poll_account = &mut ctx.accounts.poll_account;
        let candidate_account = &mut ctx.accounts.candidate_account;

        // 检查专门的计数器，而不是 Vec.len()
        require!(
            poll_account.candidate_count < 15,
            ErrorCode::MaxCandidatesReached
        );

        candidate_account.name = candidate_name;
        candidate_account.poll = poll_account.key();
        candidate_account.votes = 0;

        poll_account.candidates.push(candidate_account.key());
        // 在成功添加后，手动增加计数器
        poll_account.candidate_count += 1;

        Ok(())
    }

    // 投票
    pub fn vote(ctx: Context<Vote>) -> Result<()> {
        let clock = Clock::get()?;
        let poll_account = &ctx.accounts.poll_account;
        let candidate_account = &mut ctx.accounts.candidate_account;

        if clock.unix_timestamp < poll_account.start_time as i64 {
            return err!(ErrorCode::PollNotStarted);
        }

        if clock.unix_timestamp > poll_account.end_time as i64 {
            return err!(ErrorCode::PollEnded);
        }

        require_keys_eq!(
            candidate_account.poll,
            poll_account.key(),
            ErrorCode::InvalidCandidateForPoll
        );

        candidate_account.votes += 1;

        let receipt = &mut ctx.accounts.voter_receipt;
        receipt.voter = ctx.accounts.signer.key();
        receipt.poll = poll_account.key();

        Ok(())
    }
}

#[derive(Accounts)]
pub struct InitializePoll<'info> {
    #[account(mut)]
    pub signer: Signer<'info>,
    #[account(init, payer = signer, space = 8 + PollAccount::INIT_SPACE)]
    pub poll_account: Account<'info, PollAccount>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct AddCandidate<'info> {
    #[account(mut)]
    pub signer: Signer<'info>,
    #[account(mut)]
    pub poll_account: Account<'info, PollAccount>,
    #[account(
        init,
        payer = signer,
        space = 8 + CandidateAccount::INIT_SPACE,
        // seeds 现在使用更可靠的计数器
        seeds = [b"candidate", poll_account.key().as_ref(), poll_account.candidate_count.to_le_bytes().as_ref()],
        bump
    )]
    pub candidate_account: Account<'info, CandidateAccount>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Vote<'info> {
    #[account(mut)]
    pub signer: Signer<'info>,
    #[account(mut)]
    pub poll_account: Account<'info, PollAccount>,
    #[account(
        mut,
        constraint = candidate_account.poll == poll_account.key() @ ErrorCode::InvalidCandidateForPoll
    )]
    pub candidate_account: Account<'info, CandidateAccount>,
    #[account(
        init,
        payer = signer,
        space = 8 + VoterReceipt::INIT_SPACE,
        seeds = [b"receipt", poll_account.key().as_ref(), signer.key().as_ref()],
        bump
    )]
    pub voter_receipt: Account<'info, VoterReceipt>,
    pub system_program: Program<'info, System>,
}

#[account]
#[derive(InitSpace)]
pub struct PollAccount {
    pub authority: Pubkey,
    #[max_len(32)]
    pub name: String,
    #[max_len(280)]
    pub description: String,
    pub start_time: u64,
    pub end_time: u64,
    // 增加专门的计数器
    pub candidate_count: u8,
    #[max_len(15, 32)]
    pub candidates: Vec<Pubkey>,
}

#[account]
#[derive(InitSpace)]
pub struct CandidateAccount {
    pub poll: Pubkey,
    #[max_len(32)]
    pub name: String,
    pub votes: u64,
}

#[account]
#[derive(InitSpace)]
pub struct VoterReceipt {
    pub voter: Pubkey,
    pub poll: Pubkey,
}

#[error_code]
pub enum ErrorCode {
    #[msg("Poll not started yet")]
    PollNotStarted,
    #[msg("Poll ended")]
    PollEnded,
    #[msg("Unauthorized: Only the poll authority can perform this action.")]
    Unauthorized,
    #[msg("Maximum number of candidates reached.")]
    MaxCandidatesReached,
    #[msg("This candidate is not valid for this poll.")]
    InvalidCandidateForPoll,
}

```

这段代码使用 Solana 的 Anchor 框架实现了一个功能完整的链上投票智能合约。它清晰地展示了如何定义程序逻辑、管理链上数据状态以及处理权限验证。合约的核心功能可以分解为以下几个部分：

### **核心功能 (Instructions)**

合约定义了三个主要的公开指令（Instructions），对应用户可以执行的操作：

1. `initialize_poll(..)`: **初始化投票**。此函数用于创建一个新的投票活动。调用者（`signer`）支付交易费用，并成为该投票的**管理员（`authority`）**。函数会创建一个新的 `PollAccount` 账户，用来存储投票的名称、描述、起止时间以及管理员公钥等元数据。
2. `add_candidate(..)`: **添加候选人**。只有投票的管理员才有权限调用此函数。它会为投票活动创建一个新的 `CandidateAccount` 账户来代表一位候选人。代码中有一个重要的安全设计：它使用一个独立的 `candidate_count` 字段来生成新候选人账户的地址（PDA），并限制最多只能添加 15 位候选人。
3. `vote(..)`: **投票**。任何用户都可以调用此函数为特定候选人投票。合约会首先验证投票是否在有效时间范围内，然后为投票者创建一个 `VoterReceipt` 账户。这个回执账户的存在可以有效**防止同一用户在同一次投票中重复投票**。

### **链上数据结构 (Accounts)**

为了支持上述功能，合约定义了三种类型的账户（Account）来存储状态：

- `PollAccount`: **投票账户**，存储单个投票活动的所有核心信息，是整个应用状态的中心。
- `CandidateAccount`: **候选人账户**，存储每个候选人的姓名和得票数，并关联到特定的 `PollAccount`。
- `VoterReceipt`: **投票回执账户**，作为一个标记，记录一个用户（`voter`）是否已参与了某次投票（`poll`）。

### **关键设计与安全亮点**

这段代码一个值得注意的实现细节是使用了 `candidate_count` 字段来辅助创建候选人账户。在 `add_candidate` 指令中，新的 `CandidateAccount` 是一个程序派生地址（PDA），其 `seeds` 包含了这个计数器。

这种设计模式比直接使用 `poll_account.candidates.len()`（即候选人列表的长度）作为 `seed` 更加**安全和健壮**。因为账户数据（如 `Vec` 的长度）在交易处理前可能被外部操纵，而使用一个在逻辑中**手动递增的独立计数器**，可以确保 PDA 地址的生成是确定且无法被恶意利用的，这是 Solana 开发中一个重要的安全实践。

### Build 编译程序（合约）

```bash
voting on  master [!?] via ⬢ v23.11.0 via 🦀 1.88.0 took 5.9s 
➜ make build-one PROGRAM=voting
Building single program: [voting]...
warning: profiles for the non root package will be ignored, specify profiles at the workspace root:
package:   /Users/qiaopengjun/Code/Solana/voting/voting-substreams/voting_substreams/Cargo.toml
workspace: /Users/qiaopengjun/Code/Solana/voting/Cargo.toml
    Finished `release` profile [optimized] target(s) in 0.38s
warning: profiles for the non root package will be ignored, specify profiles at the workspace root:
package:   /Users/qiaopengjun/Code/Solana/voting/voting-substreams/voting_substreams/Cargo.toml
workspace: /Users/qiaopengjun/Code/Solana/voting/Cargo.toml
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.38s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/voting/target/debug/deps/voting-8013a2dc526371b8)

```

### 编写测试 `voting.ts`

```ts
import * as anchor from "@coral-xyz/anchor";
import { Program, BN } from "@coral-xyz/anchor";
import { Voting } from "../target/types/voting";
import { assert } from "chai";
import { LAMPORTS_PER_SOL, PublicKey } from "@solana/web3.js";

describe("voting", () => {
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);
  const program = anchor.workspace.Voting as Program<Voting>;

  const pollAccount = anchor.web3.Keypair.generate();
  const authority = provider.wallet as anchor.Wallet;
  const voter1 = anchor.web3.Keypair.generate();
  const voter2 = anchor.web3.Keypair.generate();
  const unauthorizedUser = anchor.web3.Keypair.generate();

  const confirmTx = async (txSignature: string) => {
    const latestBlockhash = await provider.connection.getLatestBlockhash();
    await provider.connection.confirmTransaction(
      { signature: txSignature, ...latestBlockhash },
      "confirmed"
    );
  };

  const airdrop = async (account: anchor.web3.Keypair) => {
    const sig = await provider.connection.requestAirdrop(
      account.publicKey,
      2 * LAMPORTS_PER_SOL
    );
    await confirmTx(sig);
  };

  const getCandidatePda = (
    pollKey: PublicKey,
    index: number
  ): [PublicKey, number] => {
    return anchor.web3.PublicKey.findProgramAddressSync(
      [
        Buffer.from("candidate"),
        pollKey.toBuffer(),
        // 关键修复：合约中的 candidate_count 是 u8 (1字节)，这里必须匹配
        new BN(index).toArrayLike(Buffer, "le", 1),
      ],
      program.programId
    );
  };

  const getReceiptPda = (
    pollKey: PublicKey,
    voterKey: PublicKey
  ): [PublicKey, number] => {
    return anchor.web3.PublicKey.findProgramAddressSync(
      [Buffer.from("receipt"), pollKey.toBuffer(), voterKey.toBuffer()],
      program.programId
    );
  };

  before(async () => {
    await airdrop(voter1);
    await airdrop(voter2);
    await airdrop(unauthorizedUser);
  });

  it("✅ Successfully initializes a poll", async () => {
    const name = "Favorite Framework";
    const description = "Which framework do you prefer?";
    const startTime = new BN(Math.floor(Date.now() / 1000));
    const endTime = new BN(startTime.toNumber() + 3600);

    const tx = await program.methods
      .initializePoll(name, description, startTime, endTime)
      .accounts({
        pollAccount: pollAccount.publicKey,
        signer: authority.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .signers([pollAccount])
      .rpc();
    await confirmTx(tx);

    const fetchedPoll = await program.account.pollAccount.fetch(
      pollAccount.publicKey
    );
    assert.strictEqual(fetchedPoll.name, name, "Poll name does not match");
    assert.strictEqual(
      fetchedPoll.authority.toBase58(),
      authority.publicKey.toBase58()
    );
    assert.ok(fetchedPoll.startTime.eq(startTime), "Start time does not match");
    assert.ok(fetchedPoll.endTime.eq(endTime), "End time does not match");
  });

  it("✅ Successfully adds two candidates", async () => {
    const [candidatePda1] = getCandidatePda(pollAccount.publicKey, 0);
    const tx1 = await program.methods
      .addCandidate("React")
      .accounts({
        pollAccount: pollAccount.publicKey,
        candidateAccount: candidatePda1,
        signer: authority.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .rpc();
    await confirmTx(tx1);

    const [candidatePda2] = getCandidatePda(pollAccount.publicKey, 1);
    const tx2 = await program.methods
      .addCandidate("Vue")
      .accounts({
        pollAccount: pollAccount.publicKey,
        candidateAccount: candidatePda2,
        signer: authority.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .rpc();
    await confirmTx(tx2);

    const fetchedPoll = await program.account.pollAccount.fetch(
      pollAccount.publicKey
    );
    assert.strictEqual(
      fetchedPoll.candidates.length,
      2,
      "Candidate count should be 2"
    );
    assert.strictEqual(
      fetchedPoll.candidateCount,
      2,
      "Candidate counter should be 2"
    );
  });

  it("✅ Two users vote successfully", async () => {
    const [candidatePda1] = getCandidatePda(pollAccount.publicKey, 0);
    const [candidatePda2] = getCandidatePda(pollAccount.publicKey, 1);
    const [receiptPda1] = getReceiptPda(
      pollAccount.publicKey,
      voter1.publicKey
    );

    const tx1 = await program.methods
      .vote()
      .accounts({
        pollAccount: pollAccount.publicKey,
        candidateAccount: candidatePda1,
        voterReceipt: receiptPda1,
        signer: voter1.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .signers([voter1])
      .rpc();
    await confirmTx(tx1);

    const [receiptPda2] = getReceiptPda(
      pollAccount.publicKey,
      voter2.publicKey
    );
    const tx2 = await program.methods
      .vote()
      .accounts({
        pollAccount: pollAccount.publicKey,
        candidateAccount: candidatePda1,
        voterReceipt: receiptPda2,
        signer: voter2.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .signers([voter2])
      .rpc();
    await confirmTx(tx2);

    const candidate1 = await program.account.candidateAccount.fetch(
      candidatePda1
    );
    const candidate2 = await program.account.candidateAccount.fetch(
      candidatePda2
    );
    assert.strictEqual(
      candidate1.votes.toNumber(),
      2,
      "React should have 2 votes"
    );
    assert.strictEqual(
      candidate2.votes.toNumber(),
      0,
      "Vue should have 0 votes"
    );
  });

  it("❌ Fails to vote twice (expected failure)", async () => {
    try {
      const [candidatePda1] = getCandidatePda(pollAccount.publicKey, 0);
      const [receiptPda1] = getReceiptPda(
        pollAccount.publicKey,
        voter1.publicKey
      );
      await program.methods
        .vote()
        .accounts({
          pollAccount: pollAccount.publicKey,
          candidateAccount: candidatePda1,
          voterReceipt: receiptPda1,
          signer: voter1.publicKey,
          systemProgram: anchor.web3.SystemProgram.programId,
        })
        .signers([voter1])
        .rpc();
      assert.fail("Double voting should have failed but succeeded");
    } catch (err) {
      assert.include(
        err.toString(),
        "already in use",
        "Expected error for already initialized account"
      );
    }
  });

  it("❌ Unauthorized user fails to add candidate (expected failure)", async () => {
    try {
      const [candidatePda] = getCandidatePda(pollAccount.publicKey, 2);
      await program.methods
        .addCandidate("Svelte")
        .accounts({
          pollAccount: pollAccount.publicKey,
          candidateAccount: candidatePda,
          signer: unauthorizedUser.publicKey,
          systemProgram: anchor.web3.SystemProgram.programId,
        })
        .signers([unauthorizedUser])
        .rpc();
      assert.fail("Unauthorized candidate addition should have failed");
    } catch (err) {
      assert.equal(err.error.errorCode.code, "Unauthorized");
    }
  });

  it("❌ Fails to vote before poll starts (expected failure)", async () => {
    const futurePoll = anchor.web3.Keypair.generate();
    const startTime = new BN(Date.now() / 1000 + 3600);
    const endTime = new BN(startTime.toNumber() + 3600);

    const tx1 = await program.methods
      .initializePoll("Future", "", startTime, endTime)
      .accounts({
        pollAccount: futurePoll.publicKey,
        signer: authority.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .signers([futurePoll])
      .rpc();
    await confirmTx(tx1);

    const [candidatePda] = getCandidatePda(futurePoll.publicKey, 0);
    const tx2 = await program.methods
      .addCandidate("Future Cand")
      .accounts({
        pollAccount: futurePoll.publicKey,
        candidateAccount: candidatePda,
        signer: authority.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .rpc();
    await confirmTx(tx2);

    try {
      const [receiptPda] = getReceiptPda(
        futurePoll.publicKey,
        voter1.publicKey
      );
      await program.methods
        .vote()
        .accounts({
          pollAccount: futurePoll.publicKey,
          candidateAccount: candidatePda,
          voterReceipt: receiptPda,
          signer: voter1.publicKey,
          systemProgram: anchor.web3.SystemProgram.programId,
        })
        .signers([voter1])
        .rpc();
      assert.fail("Voting before poll start should have failed");
    } catch (err) {
      assert.equal(err.error.errorCode.code, "PollNotStarted");
    }
  });

  it("❌ Fails to vote after poll ends (expected failure)", async () => {
    const pastPoll = anchor.web3.Keypair.generate();
    const startTime = new BN(Math.floor(Date.now() / 1000) - 7200);
    const endTime = new BN(Math.floor(Date.now() / 1000) - 3600);

    const tx1 = await program.methods
      .initializePoll("Past", "", startTime, endTime)
      .accounts({
        pollAccount: pastPoll.publicKey,
        signer: authority.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .signers([pastPoll])
      .rpc();
    await confirmTx(tx1);

    const [candidatePda] = getCandidatePda(pastPoll.publicKey, 0);
    const tx2 = await program.methods
      .addCandidate("Past Cand")
      .accounts({
        pollAccount: pastPoll.publicKey,
        candidateAccount: candidatePda,
        signer: authority.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .rpc();
    await confirmTx(tx2);

    try {
      const [receiptPda] = getReceiptPda(pastPoll.publicKey, voter1.publicKey);
      await program.methods
        .vote()
        .accounts({
          pollAccount: pastPoll.publicKey,
          candidateAccount: candidatePda,
          voterReceipt: receiptPda,
          signer: voter1.publicKey,
          systemProgram: anchor.web3.SystemProgram.programId,
        })
        .signers([voter1])
        .rpc();
      assert.fail("Voting after poll end should have failed");
    } catch (err) {
      assert.equal(err.error.errorCode.code, "PollEnded");
    }
  });

  it("❌ Fails to add more than 15 candidates (expected failure)", async () => {
    for (let i = 2; i < 15; i++) {
      const [candidatePda] = getCandidatePda(pollAccount.publicKey, i);
      const tx = await program.methods
        .addCandidate(`Cand ${i}`)
        .accounts({
          pollAccount: pollAccount.publicKey,
          candidateAccount: candidatePda,
          signer: authority.publicKey,
          systemProgram: anchor.web3.SystemProgram.programId,
        })
        .rpc();
      await confirmTx(tx);
    }

    try {
      const [candidatePda] = getCandidatePda(pollAccount.publicKey, 15);
      await program.methods
        .addCandidate("Cand 15")
        .accounts({
          pollAccount: pollAccount.publicKey,
          candidateAccount: candidatePda,
          signer: authority.publicKey,
          systemProgram: anchor.web3.SystemProgram.programId,
        })
        .rpc();
      assert.fail("Adding more than 15 candidates should have failed");
    } catch (err) {
      assert.equal(err.error.errorCode.code, "MaxCandidatesReached");
    }
  });
});

```

这段代码是一个使用 Anchor 框架和 TypeScript 编写的**综合性测试套件**，旨在全面验证 `voting` 智能合约的正确性、安全性和健壮性。

它通过模拟真实世界中的各种交互场景，系统性地覆盖了合约的**“正常路径”**和**“异常路径”**：

- **正常流程测试 (✅)**: 验证核心功能是否按预期工作，例如成功初始化投票、由管理员添加候选人、以及用户正常投票并使票数正确增加。
- **异常与边界条件测试 (❌)**: 这是确保合约安全的关键。测试脚本故意尝试了多种会失败的操作，以确保合约的约束条件有效。这包括：
  - 防止同一用户**重复投票**。
  - 阻止**未经授权**的用户添加候选人。
  - 禁止在投票开始前或结束后进行投票。
  - 确保无法添加超过数量上限（15个）的候选人。

通过这种方式，该测试确保了合约不仅能在理想情况下运行，还能在面对错误操作或恶意攻击时表现出预期的、安全可靠的行为。

### 测试程序（合约）

```bash
voting on  master [!?] via ⬢ v23.11.0 via 🦀 1.88.0 
➜ make test-program PROGRAM=voting      
Testing program [voting]...
warning: profiles for the non root package will be ignored, specify profiles at the workspace root:
package:   /Users/qiaopengjun/Code/Solana/voting/voting-substreams/voting_substreams/Cargo.toml
workspace: /Users/qiaopengjun/Code/Solana/voting/Cargo.toml
    Finished `release` profile [optimized] target(s) in 0.45s
warning: profiles for the non root package will be ignored, specify profiles at the workspace root:
package:   /Users/qiaopengjun/Code/Solana/voting/voting-substreams/voting_substreams/Cargo.toml
workspace: /Users/qiaopengjun/Code/Solana/voting/Cargo.toml
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.47s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/voting/target/debug/deps/voting-8013a2dc526371b8)

Running tests of program `voting`!

Running test suite: "/Users/qiaopengjun/Code/Solana/voting/Anchor.toml"

(node:89327) ExperimentalWarning: Type Stripping is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)


  voting
    ✔ ✅ Successfully initializes a poll (487ms)
    ✔ ✅ Successfully adds two candidates (980ms)
    ✔ ✅ Two users vote successfully (942ms)
    ✔ ❌ Fails to vote twice (expected failure)
    ✔ ❌ Unauthorized user fails to add candidate (expected failure)
    ✔ ❌ Fails to vote before poll starts (expected failure) (928ms)
    ✔ ❌ Fails to vote after poll ends (expected failure) (932ms)
    ✔ ❌ Fails to add more than 15 candidates (expected failure) (6211ms)


  8 passing (12s)

[mochawesome] Report JSON saved to /Users/qiaopengjun/Code/Solana/voting/mochawesome-report/mochawesome.json

[mochawesome] Report HTML saved to /Users/qiaopengjun/Code/Solana/voting/mochawesome-report/mochawesome.html

```

![image-20250718160122392](/images/image-20250718160122392.png)

### **重置并同步投票合约 Program ID**

```bash
voting on  master [?] via ⬢ v23.11.0 via 🦀 1.88.0 took 32.0s 
➜ rm target/deploy/voting-keypair.json 

voting on  master [?] via ⬢ v23.11.0 via 🦀 1.88.0 took 1m 5.9s 
➜ anchor keys sync
Found incorrect program id declaration in "/Users/qiaopengjun/Code/Solana/voting/programs/voting/src/lib.rs"
Updated to Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz

Found incorrect program id declaration in Anchor.toml for the program `voting`
Updated to Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz

All program id declarations are synced.
Please rebuild the program to update the generated artifacts.
```

### 部署程序（合约）

```bash
voting on  master [?] via ⬢ v23.11.0 via 🦀 1.88.0 
➜ make build-one PROGRAM=voting
Building single program: [voting]...
   Compiling voting v0.1.0 (/Users/qiaopengjun/Code/Solana/voting/programs/voting)
    Finished `release` profile [optimized] target(s) in 2.20s
   Compiling voting v0.1.0 (/Users/qiaopengjun/Code/Solana/voting/programs/voting)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 1.25s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/voting/target/debug/deps/voting-8013a2dc526371b8)

voting on  master [?] via ⬢ v23.11.0 via 🦀 1.88.0 took 4.9s 
➜ make deploy CLUSTER=devnet PROGRAM=voting
Building all programs: voting]...
    Finished `release` profile [optimized] target(s) in 0.32s
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.35s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/voting/target/debug/deps/voting-8013a2dc526371b8)
Deploying program [voting] to cluster: devnet...
Deploying cluster: https://devnet.helius-rpc.com/?api-key=a08565ed-9671-4cb4-8568-a014f810bfb2
Upgrade authority: /Users/qiaopengjun/.config/solana/id.json
Deploying program "voting"...
Program path: /Users/qiaopengjun/Code/Solana/voting/target/deploy/voting.so...
Program Id: Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz

Signature: f6YqqZ4qgd7VMhkP1VxCNxChRNKXjUaQgrNMG5Vju3Ko38WW2jsVCb4CRUZcX9DCTyXFiYv7pEuMFB86WgRkChM

Deploy success

```

### *Anchor IDL 初始化：将合约接口发布到链*

```bash
voting on  master [?] via ⬢ v23.11.0 via 🦀 1.88.0 took 24.8s 
➜ make idl-init CLUSTER=devnet PROGRAM=voting PROGRAM_ID=Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz                                            
Initializing IDL for program [voting] with ID [Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz] on cluster: devnet...
Idl data length: 834 bytes
Step 0/834 
Step 600/834 
Idl account created: 2iKdnacc51zj5j3iQTRNiYPYB1tvuM6HBzQWr9h1akAm

```

### 归档并保存 Anchor 程序的 IDL 文件到本地

```bash
voting on  master [?] via ⬢ v23.11.0 via 🦀 1.88.0 took 17.8s 
➜ make archive-idl PROGRAM=voting                                                                    
Building all programs: voting]...
    Finished `release` profile [optimized] target(s) in 0.36s
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.36s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/voting/target/debug/deps/voting-8013a2dc526371b8)
Archiving IDL for [voting]...
IDL for voting successfully archived to idls/voting/voting-2025-07-18-093219.json
```

这段操作的作用是**将当前 Anchor 程序的 IDL 文件归档保存到本地**，并按时间戳进行版本管理。

#### 说明

- 该命令会将 `target/idl/$(PROGRAM).json` 文件复制到 `idls/$(PROGRAM)/` 目录下，并以时间戳命名，便于历史版本管理和回溯。
- 适用于需要保存每次构建生成的 IDL 文件，方便后续查阅或回滚。

### 查看合约

- <https://solscan.io/account/Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz?cluster=devnet>

![image-20250720234720753](/images/image-20250720234720753.png)

## 总结

恭喜你！跟随本教程，我们已经成功地从一个空目录开始，完整地实现、测试并部署了一个功能齐全的 Solana 链上投票应用。我们不仅学习了 Anchor 框架从初始化、编码、测试到部署的完整工作流，更深入探讨了像**程序派生地址（PDA）的安全使用**、**编写覆盖多种边界条件的测试用例**等关键的实战技巧。

这整个过程清晰地展示了现代 Solana DApp 开发的标准化路径，证明了只要跟随正确的步骤，构建一个安全、健壮的链上应用并非遥不可及。

希望这次实战能为你打开 Solana 开发的大门。现在，你可以尝试基于这个项目进行扩展，比如增加计费功能、设置更复杂的投票规则，或者深入研究文末的参考资料，继续你的 Web3 探索之旅！

## 参考

- <https://docs.substreams.dev/reference-material/substreams-cli/installing-the-cli>
- <https://github.com/streamingfast/substreams-starter>
- <https://docs.substreams.dev/tutorials/intro-to-tutorials/on-solana/solana>
- <https://thegraph.com/docs/en/substreams/quick-start/>
- <https://github.com/enoldev/solana-voting-app-sps/tree/main>
- <https://docs.substreams.dev/how-to-guides/sinks/sql>
- <https://github.com/streamingfast/substreams-sink-sql>
- <https://buf.build/product/cli>
- <https://solscan.io/account/Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz?cluster=devnet>
