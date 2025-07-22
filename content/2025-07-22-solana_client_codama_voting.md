+++
title = "Solana 开发进阶：Codama 客户端代码生成与合约交互实战"
description = "本文是《Solana 投票 DApp 开发实战》的进阶篇。在合约部署后，我们将聚焦于如何高效地与链上程序交互。文章将实战演示如何使用 Codama 工具，从 Anchor IDL 一键生成类型安全的 TypeScript 客户端代码，并编写从创建、交互到验证的完整测试脚本，助您显著提升 Solana DApp 的开发效率与健壮性。"
date = 2025-07-22T00:39:04Z
[taxonomies]
categories = ["Web3", "Solana", "Rust", "DApp"]
tags = ["Solana", "Anchor", "Codama", "DApp", "Web3", "Rust", "TypeScript"]
+++

<!-- more -->

# Solana 开发进阶：Codama 客户端代码生成与合约交互实战

在上一篇《Solana 投票 DApp 开发实战》中，我们成功部署了链上合约，但这仅仅是万里长征的第一步。一个真正可用的 DApp，离不开与合约安全、高效交互的客户端。手动编写这部分代码不仅繁琐，而且极易因数据序列化错误导致难以排查的问题。本文将聚焦于如何解决这一痛点，作为上一篇教程的完美续篇，我们将引入强大的客户端生成工具 Codama，手把手带您走过从 Anchor IDL 一键生成类型安全的 TypeScript 客户端，到编写、调试、并最终整合成一套完整的自动化测试脚本的全过程。这不仅是关于一个工具的教程，更是一次提升您 Solana 开发流程健壮性与效率的实战演练。

## 使用 Codama 生成客户端代码

Codama 是一种以标准化格式（称为 Codama IDL）描述任何 Solana 程序的工具。

### 编写`generateAndTest.ts`脚本

```ts
import { createFromRoot, ProgramUpdates, updateProgramsVisitor } from "codama";
import { rootNodeFromAnchor } from "@codama/nodes-from-anchor";
import { renderJavaScriptVisitor, renderRustVisitor } from "@codama/renderers";
import * as fs from "fs";
import * as path from "path";

/**
 * 为单个程序生成所有客户端代码的通用函数
 * @param programName - 要处理的程序名
 */
async function generateClientsForProgram(programName: string) {
  console.log(`\n🚀 开始为程序 [${programName}] 生成客户端...`);

  try {
    // --- 1. 根据程序名动态定义所有路径 ---
    const projectRoot = path.join(__dirname, "..");
    const anchorIdlPath = path.join(
      projectRoot,
      "target",
      "idl",
      `${programName}.json`
    );

    // 为了更好地组织，我们将每个程序的生成代码放在独立的子目录中
    const outputTsPath = path.join(projectRoot, "generated", "ts", programName);
    const outputRsPath = path.join(projectRoot, "generated", "rs", programName);
    const outputCodamaIdlDir = path.join(projectRoot, "codama");
    const outputCodamaIdlPath = path.join(
      outputCodamaIdlDir,
      `${programName}.codama.json`
    );

    console.log(`  - 读取 IDL 从: ${anchorIdlPath}`);

    // --- 2. 读取并转换 IDL ---
    if (!fs.existsSync(anchorIdlPath)) {
      console.warn(
        `  - ⚠️ 警告: 找不到 ${programName} 的 IDL 文件，跳过此程序。`
      );
      return;
    }
    const anchorIdl = JSON.parse(fs.readFileSync(anchorIdlPath, "utf-8"));
    const codama = createFromRoot(rootNodeFromAnchor(anchorIdl));
    console.log(`  - ✅ Anchor IDL 已成功转换为 Codama 格式。`);

    // --- 3. 保存 Codama 中间格式的 IDL 文件 ---
    if (!fs.existsSync(outputCodamaIdlDir)) {
      fs.mkdirSync(outputCodamaIdlDir, { recursive: true });
    }
    fs.writeFileSync(outputCodamaIdlPath, codama.getJson());
    console.log(`  - ✅ Codama 格式的 IDL 已保存到: ${outputCodamaIdlPath}`);

    // --- 4. 生成最终的客户端代码 ---
    codama.accept(renderJavaScriptVisitor(outputTsPath, {}));
    console.log(`  - ✅ TypeScript 客户端已成功生成到: ${outputTsPath}`);

    codama.accept(renderRustVisitor(outputRsPath, {}));
    console.log(`  - ✅ Rust 客户端辅助代码已成功生成到: ${outputRsPath}`);
  } catch (error) {
    console.error(`  - ❌ 处理程序 [${programName}] 时发生错误:`, error);
  }
}

/**
 * 主执行函数
 */
async function main() {
  // --- 在这里列出你所有需要生成客户端的程序 ---
  const programsToGenerate = [
    "voting",
    // 未来有新程序，只需在这里添加名字即可
  ];

  console.log(`--- 开始为 ${programsToGenerate.length} 个程序生成客户端 ---`);

  for (const programName of programsToGenerate) {
    await generateClientsForProgram(programName);
  }
}

// --- 脚本入口 ---
main()
  .then(() => console.log("\n--- 所有脚本执行完毕 ---"))
  .catch(console.error);

/**
voting on  master [!?] via ⬢ v23.11.0 via 🦀 1.88.0 
➜ bun run scripts/generateAndTest.ts 
--- 开始为 1 个程序生成客户端 ---

🚀 开始为程序 [voting] 生成客户端...
  - 读取 IDL 从: /Users/qiaopengjun/Code/Solana/voting/target/idl/voting.json
  - ✅ Anchor IDL 已成功转换为 Codama 格式。
  - ✅ Codama 格式的 IDL 已保存到: /Users/qiaopengjun/Code/Solana/voting/codama/voting.codama.json
  - ✅ TypeScript 客户端已成功生成到: /Users/qiaopengjun/Code/Solana/voting/generated/ts/voting
  - ✅ Rust 客户端辅助代码已成功生成到: /Users/qiaopengjun/Code/Solana/voting/generated/rs/voting

--- 所有脚本执行完毕 ---

*/

```

### 运行脚本

```bash
voting on  master [!?] via ⬢ v23.11.0 via 🦀 1.88.0 
➜ bun run scripts/generateAndTest.ts 
--- 开始为 1 个程序生成客户端 ---

🚀 开始为程序 [voting] 生成客户端...
  - 读取 IDL 从: /Users/qiaopengjun/Code/Solana/voting/target/idl/voting.json
  - ✅ Anchor IDL 已成功转换为 Codama 格式。
  - ✅ Codama 格式的 IDL 已保存到: /Users/qiaopengjun/Code/Solana/voting/codama/voting.codama.json
  - ✅ TypeScript 客户端已成功生成到: /Users/qiaopengjun/Code/Solana/voting/generated/ts/voting
  - ✅ Rust 客户端辅助代码已成功生成到: /Users/qiaopengjun/Code/Solana/voting/generated/rs/voting

--- 所有脚本执行完毕 ---
```

### 查看生成的代码的目录结构

```bash
voting/generated on  master [!?] via ⬢ v23.11.0 via 🦀 1.88.0 
➜ tree . -L 6 -I "migrations|mochawesome-report|.anchor|docs|target|node_modules"
.
├── rs
│   └── voting
│       ├── accounts
│       │   ├── candidate_account.rs
│       │   ├── mod.rs
│       │   ├── poll_account.rs
│       │   └── voter_receipt.rs
│       ├── errors
│       │   ├── mod.rs
│       │   └── voting.rs
│       ├── instructions
│       │   ├── add_candidate.rs
│       │   ├── initialize_poll.rs
│       │   ├── mod.rs
│       │   └── vote.rs
│       ├── mod.rs
│       ├── programs.rs
│       └── shared.rs
└── ts
    └── voting
        ├── accounts
        │   ├── candidateAccount.ts
        │   ├── index.ts
        │   ├── pollAccount.ts
        │   └── voterReceipt.ts
        ├── errors
        │   ├── index.ts
        │   └── voting.ts
        ├── index.ts
        ├── instructions
        │   ├── addCandidate.ts
        │   ├── index.ts
        │   ├── initializePoll.ts
        │   └── vote.ts
        ├── programs
        │   ├── index.ts
        │   └── voting.ts
        └── shared
            └── index.ts

13 directories, 27 files
```

## 第一步：创建投票

## `initialize_poll`

我们创建了一个“投票档案盒”，用来存放这次投票活动的所有信息。

### 编写调用合约脚本 `step1_initialize_poll.ts`

```ts
import {
  Connection,
  Keypair,
  PublicKey,
  SystemProgram,
  Transaction,
  TransactionInstruction,
  sendAndConfirmTransaction,
} from "@solana/web3.js";
import * as fs from "fs";
import * as dotenv from "dotenv";

// Import ONLY the instruction data encoder. This is the most reliable method.
import { getInitializePollInstructionDataEncoder } from "../generated/ts/voting/instructions";

// Load .env file
dotenv.config();

// --- Script Configuration ---
const CONFIG = {
  rpcUrl: process.env.RPC_URL || "https://api.devnet.solana.com",
  walletPath: process.env.WALLET_PATH,
  // Your program's public key
  programId: new PublicKey("Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz"),
};

/**
 * Loads a Keypair from a file.
 */
function loadWallet(path: string): Keypair {
  try {
    if (!path || !fs.existsSync(path)) {
      throw new Error(
        `Wallet file not found. Check WALLET_PATH in .env: ${path}`
      );
    }
    const fileContent = fs.readFileSync(path, { encoding: "utf8" });
    const secretKey = Uint8Array.from(JSON.parse(fileContent));
    return Keypair.fromSecretKey(secretKey);
  } catch (error) {
    console.error("❌ Failed to load wallet:", error);
    process.exit(1);
  }
}

async function main() {
  console.log(
    "--- 🚀 Starting [Step 1: Initialize Poll] Script (Final Version) ---"
  );

  try {
    // 1. Initialize connection and wallets
    const connection = new Connection(CONFIG.rpcUrl, "confirmed");
    const signer = loadWallet(CONFIG.walletPath!);
    const pollAccount = Keypair.generate();

    console.log(`🔑 Signer (Authority): ${signer.publicKey.toBase58()}`);
    console.log(
      `📝 New Poll Account Address: ${pollAccount.publicKey.toBase58()}`
    );

    // 2. Get the instruction data using the low-level encoder
    const instructionData = getInitializePollInstructionDataEncoder().encode({
      name: "Final Poll Test",
      description:
        "This test uses the data encoder directly for max compatibility.",
      startTime: BigInt(Math.floor(Date.now() / 1000) - 60),
      endTime: BigInt(Math.floor(Date.now() / 1000) + 3600),
    });

    // 3. Manually define the accounts in the format @solana/web3.js expects.
    // The order MUST match the `InitializePoll` struct in your Rust code.
    const keys = [
      { pubkey: signer.publicKey, isSigner: true, isWritable: true },
      { pubkey: pollAccount.publicKey, isSigner: true, isWritable: true },
      { pubkey: SystemProgram.programId, isSigner: false, isWritable: false },
    ];

    // 4. Create a standard TransactionInstruction
    const instruction = new TransactionInstruction({
      keys: keys,
      programId: CONFIG.programId,
      data: instructionData,
    });

    // 5. Create and send the transaction
    const transaction = new Transaction().add(instruction);
    console.log("\n⏳ Sending transaction...");

    const signature = await sendAndConfirmTransaction(
      connection,
      transaction,
      [signer, pollAccount] // Both must sign
    );

    console.log("\n✅ Success! The transaction was confirmed.");
    console.log(`   - Transaction Signature: ${signature}`);
    console.log(`   - New Poll Account: ${pollAccount.publicKey.toBase58()}`);
    console.log(
      `   - Review on Explorer: https://explorer.solana.com/tx/${signature}?cluster=devnet`
    );
  } catch (error) {
    console.error("\n❌ Script failed:", error);
  }
}

main();

// --- End of Script ---
/*
voting on  master [!?] via ⬢ v23.11.0 via 🍞 v1.2.17 via 🦀 1.88.0 
➜ bun run scripts/step1_initialize_poll.ts
[dotenv@17.2.0] injecting env (0) from .env (tip: ⚙️  enable debug logging with { debug: true })
--- 🚀 Starting [Step 1: Initialize Poll] Script (Final Version) ---
🔑 Signer (Authority): 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
📝 New Poll Account Address: 2R3tUpUfQhTjMVowcd8wKhGKzJbQ1HpKc9HPeC5xXLyq

⏳ Sending transaction...

✅ Success! The transaction was confirmed.
   - Transaction Signature: 2L9HDswXc9MdxoTXoYUt7KBcHtaAgwvoLoRHkMM4Cv17oxE3PzHM7tJgQWLEDvm1qdsUrWx9XseiYp6ng42Z6RcL
   - New Poll Account: 2R3tUpUfQhTjMVowcd8wKhGKzJbQ1HpKc9HPeC5xXLyq
   - Review on Explorer: https://explorer.solana.com/tx/2L9HDswXc9MdxoTXoYUt7KBcHtaAgwvoLoRHkMM4Cv17oxE3PzHM7tJgQWLEDvm1qdsUrWx9XseiYp6ng42Z6RcL?cluster=devnet
*/

```

### 运行脚本调用合约里的 `initialize_poll` 指令

```bash
voting on  master [!?] via ⬢ v23.11.0 via 🍞 v1.2.17 via 🦀 1.88.0 
➜ bun run scripts/step1_initialize_poll.ts
[dotenv@17.2.0] injecting env (0) from .env (tip: ⚙️  enable debug logging with { debug: true })
--- 🚀 Starting [Step 1: Initialize Poll] Script (Final Version) ---
🔑 Signer (Authority): 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
📝 New Poll Account Address: 2R3tUpUfQhTjMVowcd8wKhGKzJbQ1HpKc9HPeC5xXLyq

⏳ Sending transaction...

✅ Success! The transaction was confirmed.
   - Transaction Signature: 2L9HDswXc9MdxoTXoYUt7KBcHtaAgwvoLoRHkMM4Cv17oxE3PzHM7tJgQWLEDvm1qdsUrWx9XseiYp6ng42Z6RcL
   - New Poll Account: 2R3tUpUfQhTjMVowcd8wKhGKzJbQ1HpKc9HPeC5xXLyq
   - Review on Explorer: https://explorer.solana.com/tx/2L9HDswXc9MdxoTXoYUt7KBcHtaAgwvoLoRHkMM4Cv17oxE3PzHM7tJgQWLEDvm1qdsUrWx9XseiYp6ng42Z6RcL?cluster=devnet

```

**完全成功了！** 🎉

恭喜您，第一步已经顺利完成。

#### 为什么说成功了？

您看到的日志是成功的明确标志：

- **`✅ Success! The transaction was confirmed.`**: 这条消息表示您的交易已经被 Solana 网络确认。
- **`Transaction Signature: ...`**: 您获得了一个唯一的交易签名，这是交易上链的凭证。
- **`New Poll Account: 2R3tUpUfQhTjMVowcd8wKhGKzJbQ1HpKc9HPeC5xXLyq`**: 程序成功创建了一个新的账户来存储您的投票信息。
- **`Review on Explorer: ...`**: 您可以通过这个链接在区块链浏览器上查看这笔交易的所有细节。

***<https://explorer.solana.com/tx/2L9HDswXc9MdxoTXoYUt7KBcHtaAgwvoLoRHkMM4Cv17oxE3PzHM7tJgQWLEDvm1qdsUrWx9XseiYp6ng42Z6RcL?cluster=devnet>***

![image-20250721215456054](/images/image-20250721215456054.png)

### 这个脚本做了什么？

这个脚本第一步成功调用了您合约里的 `initialize_poll` 指令。

它的核心作用是：在 Solana 上**创建了一个全新的“投票总账户”**。您可以把这个账户想象成一个专门为这次投票活动准备的“档案盒”。

- **档案盒地址（公钥）**: `2R3tUpUfQhTjMVowcd8wKhGKzJbQ1HpKc9HPeC5xXLyq`
- **档案盒里的内容**: 这次投票的名称、描述、开始/结束时间，以及一个**初始为 0 的候选人计数器 (`candidate_count`)**。

之后所有与这次投票相关的操作（比如添加候选人、用户投票）都需要用到这个“档案盒”的地址。

## 第二步：添加候选人

## `add_candidate`

我们向这个“档案盒”里添加了一份“候选人文件”。

```ts
import {
  Connection,
  Keypair,
  PublicKey,
  SystemProgram,
  Transaction,
  TransactionInstruction,
  sendAndConfirmTransaction,
} from "@solana/web3.js";
import * as fs from "fs";
import * as dotenv from "dotenv";
import { Buffer } from "buffer";

// 导入需要的 codama 生成的函数
import { getAddCandidateInstructionDataEncoder } from "../generated/ts/voting/instructions";
import { getPollAccountDecoder } from "../generated/ts/voting/accounts";

dotenv.config();

// --- 脚本配置 ---
const CONFIG = {
  rpcUrl: process.env.RPC_URL || "https://api.devnet.solana.com",
  walletPath: process.env.WALLET_PATH,
  programId: new PublicKey("Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz"),
  // 使用您在第一步中成功创建的投票账户地址
  pollAccountPubkey: new PublicKey(
    "2R3tUpUfQhTjMVowcd8wKhGKzJbQ1HpKc9HPeC5xXLyq"
  ),
};

function loadWallet(path: string): Keypair {
  try {
    if (!path || !fs.existsSync(path)) {
      throw new Error(
        `Wallet file not found. Check WALLET_PATH in .env: ${path}`
      );
    }
    const fileContent = fs.readFileSync(path, { encoding: "utf8" });
    const secretKey = Uint8Array.from(JSON.parse(fileContent));
    return Keypair.fromSecretKey(secretKey);
  } catch (error) {
    console.error("❌ Failed to load wallet:", error);
    process.exit(1);
  }
}

async function main() {
  console.log(
    "--- 🚀 Starting [Step 2: Add a Candidate] Script (Corrected Decoder) ---"
  );

  try {
    const connection = new Connection(CONFIG.rpcUrl, "confirmed");
    const signer = loadWallet(CONFIG.walletPath!);

    console.log(`🔑 Signer (Authority): ${signer.publicKey.toBase58()}`);
    console.log(
      `📝 Using Poll Account: ${CONFIG.pollAccountPubkey.toBase58()}`
    );

    console.log("\n⏳ Fetching poll account data...");
    const pollAccountInfo = await connection.getAccountInfo(
      CONFIG.pollAccountPubkey
    );
    if (!pollAccountInfo) {
      throw new Error("Poll account not found.");
    }

    const decodedPoll = getPollAccountDecoder().decode(pollAccountInfo.data);
    const currentCandidateCount = decodedPoll.candidateCount;
    console.log(`✅ Current candidate count is: ${currentCandidateCount}`);

    const [candidatePda] = PublicKey.findProgramAddressSync(
      [
        Buffer.from("candidate"),
        CONFIG.pollAccountPubkey.toBuffer(),
        Buffer.from([currentCandidateCount]),
      ],
      CONFIG.programId
    );
    console.log(`🌱 New Candidate PDA: ${candidatePda.toBase58()}`);

    const candidateName = "Candidate #" + (currentCandidateCount + 1);
    console.log(`➕ Adding candidate with name: "${candidateName}"`);

    const instructionData = getAddCandidateInstructionDataEncoder().encode({
      candidateName: candidateName,
    });

    const keys = [
      { pubkey: signer.publicKey, isSigner: true, isWritable: true },
      { pubkey: CONFIG.pollAccountPubkey, isSigner: false, isWritable: true },
      { pubkey: candidatePda, isSigner: false, isWritable: true },
      { pubkey: SystemProgram.programId, isSigner: false, isWritable: false },
    ];

    const instruction = new TransactionInstruction({
      keys: keys,
      programId: CONFIG.programId,
      data: Buffer.from(instructionData),
    });

    const transaction = new Transaction().add(instruction);
    console.log("\n⏳ Sending transaction to add candidate...");

    const signature = await sendAndConfirmTransaction(connection, transaction, [
      signer,
    ]);

    console.log("\n✅ Success! Candidate has been added.");
    console.log(`   - Transaction Signature: ${signature}`);
    console.log(
      `   - Review on Explorer: https://explorer.solana.com/tx/${signature}?cluster=devnet`
    );
  } catch (error) {
    console.error("\n❌ Script failed:", error);
  }
}

main();

/*
voting on  master [!?] via ⬢ v23.11.0 via 🍞 v1.2.17 via 🦀 1.88.0 took 3.5s 
➜ bun run scripts/step2_add_candidate.ts
[dotenv@17.2.0] injecting env (0) from .env (tip: ⚙️  write to custom object with { processEnv: myObject })
--- 🚀 Starting [Step 2: Add a Candidate] Script (Corrected Decoder) ---
🔑 Signer (Authority): 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
📝 Using Poll Account: 2R3tUpUfQhTjMVowcd8wKhGKzJbQ1HpKc9HPeC5xXLyq

⏳ Fetching poll account data...
✅ Current candidate count is: 0
🌱 New Candidate PDA: GZzVP862HEb4dW8VJ5Loixju4dnAFDkApzVbsu2jh6x5
➕ Adding candidate with name: "Candidate #1"

⏳ Sending transaction to add candidate...

✅ Success! Candidate has been added.
   - Transaction Signature: 4sso6XXXyLuubVRGvTTYKEiyRHTizzyvPbKkghFj5mFzCAn6D7bQtGUQwTF7uw3fw2DSSPJXrDY9hhUtCPeii5ZV
   - Review on Explorer: https://explorer.solana.com/tx/4sso6XXXyLuubVRGvTTYKEiyRHTizzyvPbKkghFj5mFzCAn6D7bQtGUQwTF7uw3fw2DSSPJXrDY9hhUtCPeii5ZV?cluster=devnet
*/

```

### 运行`step2_add_candidate`脚本

```bash
voting on  master [!?] via ⬢ v23.11.0 via 🍞 v1.2.17 via 🦀 1.88.0 took 3.5s 
➜ bun run scripts/step2_add_candidate.ts
[dotenv@17.2.0] injecting env (0) from .env (tip: ⚙️  write to custom object with { processEnv: myObject })
--- 🚀 Starting [Step 2: Add a Candidate] Script (Corrected Decoder) ---
🔑 Signer (Authority): 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
📝 Using Poll Account: 2R3tUpUfQhTjMVowcd8wKhGKzJbQ1HpKc9HPeC5xXLyq

⏳ Fetching poll account data...
✅ Current candidate count is: 0
🌱 New Candidate PDA: GZzVP862HEb4dW8VJ5Loixju4dnAFDkApzVbsu2jh6x5
➕ Adding candidate with name: "Candidate #1"

⏳ Sending transaction to add candidate...

✅ Success! Candidate has been added.
   - Transaction Signature: 4sso6XXXyLuubVRGvTTYKEiyRHTizzyvPbKkghFj5mFzCAn6D7bQtGUQwTF7uw3fw2DSSPJXrDY9hhUtCPeii5ZV
   - Review on Explorer: https://explorer.solana.com/tx/4sso6XXXyLuubVRGvTTYKEiyRHTizzyvPbKkghFj5mFzCAn6D7bQtGUQwTF7uw3fw2DSSPJXrDY9hhUtCPeii5ZV?cluster=devnet

```

您已经成功地为您的投票活动添加了第一个候选人。日志中的 `✅ Success! Candidate has been added.` 和生成的交易签名都证明了这一点。

***<https://explorer.solana.com/tx/4sso6XXXyLuubVRGvTTYKEiyRHTizzyvPbKkghFj5mFzCAn6D7bQtGUQwTF7uw3fw2DSSPJXrDY9hhUtCPeii5ZV?cluster=devnet>***

![image-20250721215407850](/images/image-20250721215407850.png)

## 第三步：投票 (`vote`)

我们在那份“候选人文件”上画了一个“正”字，记录了一票。

### 文件: `scripts/step3_vote.ts`

```ts
import {
  Connection,
  Keypair,
  PublicKey,
  SystemProgram,
  Transaction,
  TransactionInstruction,
  sendAndConfirmTransaction,
} from "@solana/web3.js";
import * as fs from "fs";
import * as dotenv from "dotenv";
import { Buffer } from "buffer";

// 导入需要的 codama 生成的函数
import { getVoteInstructionDataEncoder } from "../generated/ts/voting/instructions";

dotenv.config();

// --- 脚本配置 ---
const CONFIG = {
  rpcUrl: process.env.RPC_URL || "https://api.devnet.solana.com",
  walletPath: process.env.WALLET_PATH,
  programId: new PublicKey("Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz"),
  // 使用之前步骤中创建的账户地址
  pollAccountPubkey: new PublicKey(
    "2R3tUpUfQhTjMVowcd8wKhGKzJbQ1HpKc9HPeC5xXLyq"
  ),
  candidateAccountPubkey: new PublicKey(
    "GZzVP862HEb4dW8VJ5Loixju4dnAFDkApzVbsu2jh6x5"
  ),
};

function loadWallet(path: string): Keypair {
  try {
    if (!path || !fs.existsSync(path)) {
      throw new Error(
        `Wallet file not found. Check WALLET_PATH in .env: ${path}`
      );
    }
    const fileContent = fs.readFileSync(path, { encoding: "utf8" });
    const secretKey = Uint8Array.from(JSON.parse(fileContent));
    return Keypair.fromSecretKey(secretKey);
  } catch (error) {
    console.error("❌ Failed to load wallet:", error);
    process.exit(1);
  }
}

async function main() {
  console.log("--- 🚀 Starting [Step 3: Vote] Script ---");

  try {
    const connection = new Connection(CONFIG.rpcUrl, "confirmed");
    // 在这个测试中，我们让授权方自己作为投票者
    const voter = loadWallet(CONFIG.walletPath!);

    console.log(`🔑 Voter: ${voter.publicKey.toBase58()}`);
    console.log(`📝 Voting in Poll: ${CONFIG.pollAccountPubkey.toBase58()}`);
    console.log(
      `👍 Voting for Candidate: ${CONFIG.candidateAccountPubkey.toBase58()}`
    );

    // 1. 计算投票回执账户的 PDA (Voter Receipt PDA)
    // 这是为了防止同一个人重复投票
    // seeds 必须与合约匹配: [b"receipt", poll_key, voter_key]
    const [voterReceiptPda] = PublicKey.findProgramAddressSync(
      [
        Buffer.from("receipt"),
        CONFIG.pollAccountPubkey.toBuffer(),
        voter.publicKey.toBuffer(),
      ],
      CONFIG.programId
    );
    console.log(`🧾 Voter Receipt PDA: ${voterReceiptPda.toBase58()}`);

    // 2. 获取指令数据 (vote 指令没有参数)
    const instructionData = getVoteInstructionDataEncoder().encode({});

    // 3. 手动定义账户列表
    const keys = [
      { pubkey: voter.publicKey, isSigner: true, isWritable: true },
      { pubkey: CONFIG.pollAccountPubkey, isSigner: false, isWritable: true },
      {
        pubkey: CONFIG.candidateAccountPubkey,
        isSigner: false,
        isWritable: true,
      },
      { pubkey: voterReceiptPda, isSigner: false, isWritable: true },
      { pubkey: SystemProgram.programId, isSigner: false, isWritable: false },
    ];

    // 4. 创建标准指令
    const instruction = new TransactionInstruction({
      keys: keys,
      programId: CONFIG.programId,
      data: Buffer.from(instructionData),
    });

    // 5. 创建并发送交易
    const transaction = new Transaction().add(instruction);
    console.log("\n⏳ Sending vote transaction...");

    const signature = await sendAndConfirmTransaction(
      connection,
      transaction,
      [voter] // 只有投票者需要签名
    );

    console.log("\n✅ Success! Your vote has been cast.");
    console.log(`   - Transaction Signature: ${signature}`);
    console.log(
      `   - Review on Explorer: https://explorer.solana.com/tx/${signature}?cluster=devnet`
    );
    console.log("\n🎉 All steps completed successfully! Your contract works.");
  } catch (error) {
    console.error("\n❌ Script failed:", error);
  }
}

main();

/*
voting on  master [!?] via ⬢ v23.11.0 via 🍞 v1.2.17 via 🦀 1.88.0 took 3.9s 
➜ bun run scripts/step3_vote.ts
[dotenv@17.2.0] injecting env (0) from .env (tip: 🛠️  run anywhere with `dotenvx run -- yourcommand`)
--- 🚀 Starting [Step 3: Vote] Script ---
🔑 Voter: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
📝 Voting in Poll: 2R3tUpUfQhTjMVowcd8wKhGKzJbQ1HpKc9HPeC5xXLyq
👍 Voting for Candidate: GZzVP862HEb4dW8VJ5Loixju4dnAFDkApzVbsu2jh6x5
🧾 Voter Receipt PDA: DAnY27Ei9wyzkwJpTM2Aq29cTxwGHxbCKfoY64C9hdRg

⏳ Sending vote transaction...

✅ Success! Your vote has been cast.
   - Transaction Signature: 6kaULdcvbgwovJLKULXQgpS3Mfihfj4VKY7ruE3kqiggMjqci8RZWcpSs2AF9EawF4wxbVC8HjKJryPFmqPd3pN
   - Review on Explorer: https://explorer.solana.com/tx/6kaULdcvbgwovJLKULXQgpS3Mfihfj4VKY7ruE3kqiggMjqci8RZWcpSs2AF9EawF4wxbVC8HjKJryPFmqPd3pN?cluster=devnet

🎉 All steps completed successfully! Your contract works.
*/

```

这个脚本将会为我们刚刚添加的候选人投上一票。

- **投票账户地址**: `2R3tUpUfQhTjMVowcd8wKhGKzJbQ1HpKc9HPeC5xXLyq` (来自第一步)
- **候选人账户地址**: `GZzVP862HEb4dW8VJ5Loixju4dnAFDkApzVbsu2jh6x5` (来自第二步成功的日志)

### 执行投票脚本

```bash
voting on  master [!?] via ⬢ v23.11.0 via 🍞 v1.2.17 via 🦀 1.88.0 took 3.9s 
➜ bun run scripts/step3_vote.ts
[dotenv@17.2.0] injecting env (0) from .env (tip: 🛠️  run anywhere with `dotenvx run -- yourcommand`)
--- 🚀 Starting [Step 3: Vote] Script ---
🔑 Voter: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
📝 Voting in Poll: 2R3tUpUfQhTjMVowcd8wKhGKzJbQ1HpKc9HPeC5xXLyq
👍 Voting for Candidate: GZzVP862HEb4dW8VJ5Loixju4dnAFDkApzVbsu2jh6x5
🧾 Voter Receipt PDA: DAnY27Ei9wyzkwJpTM2Aq29cTxwGHxbCKfoY64C9hdRg

⏳ Sending vote transaction...

✅ Success! Your vote has been cast.
   - Transaction Signature: 6kaULdcvbgwovJLKULXQgpS3Mfihfj4VKY7ruE3kqiggMjqci8RZWcpSs2AF9EawF4wxbVC8HjKJryPFmqPd3pN
   - Review on Explorer: https://explorer.solana.com/tx/6kaULdcvbgwovJLKULXQgpS3Mfihfj4VKY7ruE3kqiggMjqci8RZWcpSs2AF9EawF4wxbVC8HjKJryPFmqPd3pN?cluster=devnet

🎉 All steps completed successfully! Your contract works.

```

**第三步也完全成功了！**

🎉 **祝贺您！您已经成功地完成了整个合约的核心流程测试：`创建投票 -> 添加候选人 -> 投票`。**

您的日志输出非常清晰地表明了这一点：

- `✅ Success! Your vote has been cast.` 表示投票交易已成功。
- `🎉 All steps completed successfully! Your contract works.` 这句总结性的日志说明我们共同编写的三个脚本已经完整地验证了您合约的功能。

现在，就让我们来编写最后一步的脚本，去打开那个“档案盒”，拿出“候选人文件”，看看上面是不是真的有我们画的那个“正”字。

**<https://explorer.solana.com/tx/6kaULdcvbgwovJLKULXQgpS3Mfihfj4VKY7ruE3kqiggMjqci8RZWcpSs2AF9EawF4wxbVC8HjKJryPFmqPd3pN?cluster=devnet>**

![image-20250721222154860](/images/image-20250721222154860.png)

## 第四步：验证投票结果

这个脚本会连接到 Solana Devnet，获取我们投票的那个候选人账户的数据，然后解析这些数据来检查它的 `votes` 字段。

### 文件: `scripts/verify_vote.ts`

```ts
import { Connection, PublicKey } from "@solana/web3.js";
import * as dotenv from "dotenv";

// 导入我们需要的候选人账户解码器
import { getCandidateAccountDecoder } from "../generated/ts/voting/accounts";

dotenv.config();

// --- 脚本配置 ---
const CONFIG = {
  rpcUrl: process.env.RPC_URL || "https://api.devnet.solana.com",
  // 这是我们在第二步中添加并为其投票的候选人账户地址
  candidateAccountPubkey: new PublicKey(
    "GZzVP862HEb4dW8VJ5Loixju4dnAFDkApzVbsu2jh6x5"
  ),
};

async function main() {
  console.log("--- 🚀 Starting [Step 4: Verify Vote Result] Script ---");

  try {
    const connection = new Connection(CONFIG.rpcUrl, "confirmed");

    console.log(
      `🔍 Checking candidate account: ${CONFIG.candidateAccountPubkey.toBase58()}`
    );

    // 1. 从区块链获取账户信息
    const accountInfo = await connection.getAccountInfo(
      CONFIG.candidateAccountPubkey
    );
    if (!accountInfo) {
      throw new Error("Candidate account not found on the blockchain.");
    }

    // 2. 使用生成的解码器来解析二进制数据
    const decodedCandidate = getCandidateAccountDecoder().decode(
      accountInfo.data
    );

    const candidateName = decodedCandidate.name;
    const voteCount = decodedCandidate.votes;

    // 3. 打印出验证结果
    console.log("\n✅ Verification Successful!");
    console.log(`   - Candidate Name: "${candidateName}"`);
    console.log(`   - Vote Count: ${voteCount}`);

    // 4. 最终确认
    if (voteCount > 0) {
      console.log(`\n🎉🎉 Great! The vote was correctly recorded on-chain.`);
    } else {
      console.log(
        `\n🤔 Hmm, the vote count is still 0. Something might be wrong.`
      );
    }
  } catch (error) {
    console.error("\n❌ Script failed:", error);
  }
}

main();

/*
voting on  master [!?] via ⬢ v23.11.0 via 🍞 v1.2.17 via 🦀 1.88.0 took 4.0s 
➜ bun run scripts/verify_vote.ts
[dotenv@17.2.0] injecting env (0) from .env (tip: 🔐 encrypt with dotenvx: https://dotenvx.com)
--- 🚀 Starting [Step 4: Verify Vote Result] Script ---
🔍 Checking candidate account: GZzVP862HEb4dW8VJ5Loixju4dnAFDkApzVbsu2jh6x5

✅ Verification Successful!
   - Candidate Name: "Candidate #1"
   - Vote Count: 1

🎉🎉 Great! The vote was correctly recorded on-chain.
*/

```

### 运行脚本

```bash
voting on  master [!?] via ⬢ v23.11.0 via 🍞 v1.2.17 via 🦀 1.88.0 took 4.0s 
➜ bun run scripts/verify_vote.ts
[dotenv@17.2.0] injecting env (0) from .env (tip: 🔐 encrypt with dotenvx: https://dotenvx.com)
--- 🚀 Starting [Step 4: Verify Vote Result] Script ---
🔍 Checking candidate account: GZzVP862HEb4dW8VJ5Loixju4dnAFDkApzVbsu2jh6x5

✅ Verification Successful!
   - Candidate Name: "Candidate #1"
   - Vote Count: 1

🎉🎉 Great! The vote was correctly recorded on-chain.
```

是的，巨大成功！🎉

这标志着您已经完成了对整个智能合约的**端到端（end-to-end）闭环测试**。

### 为什么这是最终的成功

- **写入数据：** 在前三步中，您成功地向区块链写入了数据（创建投票、添加候选人、投了一票）。
- **读取数据：** 在这第四步中，您成功地从区块链**读取**了数据，并**验证**了您之前写入的结果。
- **结果正确：** 日志明确显示 `Vote Count: 1`，这证明了第三步的投票操作确实被正确地记录在了链上。

### 您的完整成就回顾

通过我们共同努力，您已经完成了：

1. ✅ **创建投票：** 成功初始化了一个投票活动。
2. ✅ **添加候选人：** 成功为该活动添加了候选人。
3. ✅ **执行投票：** 成功为候选人投了一票。
4. ✅ **验证结果：** 成功读取链上数据，确认投票有效。

这套流程完整地证明了您智能合约的核心逻辑是正确且可用的。

## 再次运行 `step3_vote.ts` 脚本

这被称为“**负面测试**”或“**异常路径测试**”。它的目的不是看程序“成功”，而是看程序在我们预设的规则下**正确地“失败”**。

- **测试目的**: 验证您的“一人一票”防重复投票机制是否生效。
- **预期结果**: **交易应该会失败**。
- **为什么会失败**: 因为在您第一次成功投票时，合约已经创建了一个 `voter_receipt` 账户。当您第二次用同一个投票者身份投票时，程序会再次尝试创建**同一个地址**的 `voter_receipt` 账户，Solana 运行环境会阻止创建已经存在的账户，从而导致交易失败。这恰好证明了您的合约是安全的。

```bash
voting on  master [!?] via ⬢ v23.11.0 via 🍞 v1.2.17 via 🦀 1.88.0 
➜ bun run scripts/step3_vote.ts 
[dotenv@17.2.0] injecting env (0) from .env (tip: ⚙️  write to custom object with { processEnv: myObject })
--- 🚀 Starting [Step 3: Vote] Script ---
🔑 Voter: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd
📝 Voting in Poll: 2R3tUpUfQhTjMVowcd8wKhGKzJbQ1HpKc9HPeC5xXLyq
👍 Voting for Candidate: GZzVP862HEb4dW8VJ5Loixju4dnAFDkApzVbsu2jh6x5
🧾 Voter Receipt PDA: DAnY27Ei9wyzkwJpTM2Aq29cTxwGHxbCKfoY64C9hdRg

⏳ Sending vote transaction...

❌ Script failed: 2174 |       default:
2175 |         {
2176 |           message = `Unknown action '${(a => a)(action)}'`;
2177 |         }
2178 |     }
2179 |     super(message);
           ^
error: Simulation failed. 
Message: Transaction simulation failed: Error processing Instruction 0: custom program error: 0x0. 
Logs: 
[
  "Program Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz invoke [1]",
  "Program log: Instruction: Vote",
  "Program 11111111111111111111111111111111 invoke [2]",
  "Allocate: account Address { address: DAnY27Ei9wyzkwJpTM2Aq29cTxwGHxbCKfoY64C9hdRg, base: None } already in use",
  "Program 11111111111111111111111111111111 failed: custom program error: 0x0",
  "Program Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz consumed 8734 of 200000 compute units",
  "Program Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz failed: custom program error: 0x0"
]. 
Catch the `SendTransactionError` and call `getLogs()` on it for full details.
  signature: "",
 transactionMessage: "Transaction simulation failed: Error processing Instruction 0: custom program error: 0x0",
 transactionLogs: [
  "Program Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz invoke [1]", "Program log: Instruction: Vote",
  "Program 11111111111111111111111111111111 invoke [2]", "Allocate: account Address { address: DAnY27Ei9wyzkwJpTM2Aq29cTxwGHxbCKfoY64C9hdRg, base: None } already in use",
  "Program 11111111111111111111111111111111 failed: custom program error: 0x0", "Program Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz consumed 8734 of 200000 compute units",
  "Program Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz failed: custom program error: 0x0"
],

      at new SendTransactionError (/Users/qiaopengjun/Code/Solana/voting/node_modules/@solana/web3.js/lib/index.cjs.js:2179:5)
      at sendEncodedTransaction (/Users/qiaopengjun/Code/Solana/voting/node_modules/@solana/web3.js/lib/index.cjs.js:8206:13)

```

这正是我们期望看到的“成功失败”！🎉

这个错误日志表明您的**负面测试非常成功**。

### 为什么这个“失败”是好事？

这个测试的**目的**就是验证您的合约能否阻止同一个人重复投票。您看到的错误日志完美地证明了这一点。

让我们看一下日志中最关键的一行：

```bash
"Allocate: account Address { address: DAnY27Ei9wyzkwJpTM2Aq29cTxwGHxbCKfoY64C9hdRg, base: None } already in use"
```

这句日志的通俗解释是：

> “系统程序尝试为你创建投票回执账户 (`VoterReceipt`)，但发现这个地址的账户**已经存在了**！”

这恰恰证明了您的防重复投票机制**完美地生效了**。因为在您第一次成功投票时，这个回执账户就已经被创建。当您第二次尝试投票时，合约试图再次创建它，系统正确地拒绝了这个操作，导致交易失败。

### 总结

通过这次测试，您已经证明了您的合约不仅能在正常流程下工作，还能在异常情况下保护规则的正确执行。

您已经完整地验证了：

1. 可以成功**创建**投票。
2. 可以成功**添加**候选人。
3. 第一个用户可以成功**投票**。
4. 同一个用户被正确地**阻止**了第二次投票。

您的合约逻辑非常稳固。恭喜您，您已经可以充满信心地进入下一个阶段，比如为您这个功能完备的合约构建一个漂亮的前端界面了！

## 自动化集成测试

创建一个完整的、可重复的“集成测试”套件

**自动化**: 一键运行，自动完成从创建到验证的整个流程，无需任何手动操作。

**数据流清晰**: 上一步函数返回的地址，可以直接作为下一步函数的参数传入，无需复制粘贴。

**可重复性**: 非常适合做“回归测试”，即每次修改合约后，运行一遍总脚本，确保没有破坏原有的功能。

### **文件: `scripts/run_full_test.ts`**

```ts
import {
  Connection,
  Keypair,
  PublicKey,
  SystemProgram,
  Transaction,
  TransactionInstruction,
  sendAndConfirmTransaction,
} from "@solana/web3.js";
import * as fs from "fs";
import * as dotenv from "dotenv";
import { Buffer } from "buffer";

// 导入所有需要的生成代码
import {
  getInitializePollInstructionDataEncoder,
  getAddCandidateInstructionDataEncoder,
  getVoteInstructionDataEncoder,
} from "../generated/ts/voting/instructions";
import {
  getPollAccountDecoder,
  getCandidateAccountDecoder,
} from "../generated/ts/voting/accounts";

dotenv.config();

// --- 全局配置 ---
const CONFIG = {
  rpcUrl: process.env.RPC_URL || "https://api.devnet.solana.com",
  walletPath: process.env.WALLET_PATH,
  programId: new PublicKey("Doo2arLUifZbfqGVS5Uh7nexAMmsMzaQH5zcwZhSoijz"),
};

function loadWallet(path: string): Keypair {
  try {
    if (!path || !fs.existsSync(path)) {
      throw new Error(`Wallet file not found: ${path}`);
    }
    const secretKey = Uint8Array.from(
      JSON.parse(fs.readFileSync(path, { encoding: "utf8" }))
    );
    return Keypair.fromSecretKey(secretKey);
  } catch (error) {
    console.error("❌ Failed to load wallet:", error);
    process.exit(1);
  }
}

async function main() {
  console.log("--- 🚀 Starting Full Integration Test ---");
  const connection = new Connection(CONFIG.rpcUrl, "confirmed");
  const signer = loadWallet(CONFIG.walletPath!);
  console.log(`🔑 Signer Wallet: ${signer.publicKey.toBase58()}`);

  try {
    // === 步骤 1: 初始化投票 ===
    const pollAccount = Keypair.generate();
    const initData = getInitializePollInstructionDataEncoder().encode({
      name: "Full Test Poll",
      description: "A poll created from the integration test script.",
      startTime: BigInt(Math.floor(Date.now() / 1000) - 60),
      endTime: BigInt(Math.floor(Date.now() / 1000) + 3600),
    });
    const initInstruction = new TransactionInstruction({
      keys: [
        { pubkey: signer.publicKey, isSigner: true, isWritable: true },
        { pubkey: pollAccount.publicKey, isSigner: true, isWritable: true },
        { pubkey: SystemProgram.programId, isSigner: false, isWritable: false },
      ],
      programId: CONFIG.programId,
      data: Buffer.from(initData),
    });
    const initSig = await sendAndConfirmTransaction(
      connection,
      new Transaction().add(initInstruction),
      [signer, pollAccount]
    );
    console.log(
      `\n[✅ Step 1 SUCCESS] Poll initialized. Signature: ${initSig}`
    );
    console.log(`   Poll Account: ${pollAccount.publicKey.toBase58()}`);

    // === 步骤 2: 添加候选人 ===
    const pollInfo = await connection.getAccountInfo(pollAccount.publicKey);
    if (!pollInfo) throw new Error("Poll account not found after creation.");
    const decodedPoll = getPollAccountDecoder().decode(pollInfo.data);
    const [candidatePda] = PublicKey.findProgramAddressSync(
      [
        Buffer.from("candidate"),
        pollAccount.publicKey.toBuffer(),
        Buffer.from([decodedPoll.candidateCount]),
      ],
      CONFIG.programId
    );
    const addCandidateData = getAddCandidateInstructionDataEncoder().encode({
      candidateName: "Candidate A",
    });
    const addCandidateInstruction = new TransactionInstruction({
      keys: [
        { pubkey: signer.publicKey, isSigner: true, isWritable: true },
        { pubkey: pollAccount.publicKey, isSigner: false, isWritable: true },
        { pubkey: candidatePda, isSigner: false, isWritable: true },
        { pubkey: SystemProgram.programId, isSigner: false, isWritable: false },
      ],
      programId: CONFIG.programId,
      data: Buffer.from(addCandidateData),
    });
    const addCandSig = await sendAndConfirmTransaction(
      connection,
      new Transaction().add(addCandidateInstruction),
      [signer]
    );
    console.log(
      `\n[✅ Step 2 SUCCESS] Candidate added. Signature: ${addCandSig}`
    );
    console.log(`   Candidate Account: ${candidatePda.toBase58()}`);

    // === 步骤 3: 投票 ===
    const [receiptPda] = PublicKey.findProgramAddressSync(
      [
        Buffer.from("receipt"),
        pollAccount.publicKey.toBuffer(),
        signer.publicKey.toBuffer(),
      ],
      CONFIG.programId
    );
    const voteData = getVoteInstructionDataEncoder().encode({});
    const voteInstruction = new TransactionInstruction({
      keys: [
        { pubkey: signer.publicKey, isSigner: true, isWritable: true },
        { pubkey: pollAccount.publicKey, isSigner: false, isWritable: true },
        { pubkey: candidatePda, isSigner: false, isWritable: true },
        { pubkey: receiptPda, isSigner: false, isWritable: true },
        { pubkey: SystemProgram.programId, isSigner: false, isWritable: false },
      ],
      programId: CONFIG.programId,
      data: Buffer.from(voteData),
    });
    const voteSig = await sendAndConfirmTransaction(
      connection,
      new Transaction().add(voteInstruction),
      [signer]
    );
    console.log(`\n[✅ Step 3 SUCCESS] Vote cast. Signature: ${voteSig}`);

    // === 步骤 4: 验证结果 ===
    const candidateInfo = await connection.getAccountInfo(candidatePda);
    if (!candidateInfo)
      throw new Error("Candidate account not found after voting.");
    const decodedCandidate = getCandidateAccountDecoder().decode(
      candidateInfo.data
    );
    console.log(`\n[✅ Step 4 SUCCESS] Verification complete.`);
    console.log(
      `   Candidate "${decodedCandidate.name}" has ${decodedCandidate.votes} vote(s).`
    );

    if (decodedCandidate.votes === 1n) {
      console.log("\n🎉🎉🎉 INTEGRATION TEST PASSED! 🎉🎉🎉");
    } else {
      throw new Error(
        `Verification failed! Expected 1 vote, but found ${decodedCandidate.votes}.`
      );
    }
  } catch (error) {
    console.error("\n❌ INTEGRATION TEST FAILED:", error);
  }
}

main();

/*
voting on  master [!?] via ⬢ v23.11.0 via 🍞 v1.2.17 via 🦀 1.88.0 
➜ bun run scripts/run_full_test.ts
[dotenv@17.2.0] injecting env (0) from .env (tip: ⚙️  write to custom object with { processEnv: myObject })
--- 🚀 Starting Full Integration Test ---
🔑 Signer Wallet: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd

[✅ Step 1 SUCCESS] Poll initialized. Signature: yugFdjbtm4baF52JnmjAwYRFgFagSoppSAkpjM93ZZ68ciiZdxgGaVCEu3ARm8g4GwQJb2FwQoygjVHPjDZxEW4
   Poll Account: Gm2XV7wdVWRYJfKaJqCXTn4j76juLrLhWkn2zAmuuxc2

[✅ Step 2 SUCCESS] Candidate added. Signature: YEpJiUFViK7LNJSTSejYwmGjkNfpbxJFkKFN1cE6QhpvRn4LmsVkfyciUpAtLJqZnoDDhMeV9CT3MaE2Piv2C2b
   Candidate Account: 4usFkw3PgAMNbjvx7sSx8KszfjbgBNsNcqyvYBfhUCe6

[✅ Step 3 SUCCESS] Vote cast. Signature: 5gNoiWjGNCmdbHaLubmp8mgXPwZ7HaibXVNzAP584DATB9C1i5samSAUgc7CoHstLaR2N9EmwTwuzPPnR5U2BbbD

[✅ Step 4 SUCCESS] Verification complete.
   Candidate "Candidate A" has 1 vote(s).

🎉🎉🎉 INTEGRATION TEST PASSED! 🎉🎉🎉

*/

```

### 执行脚本

```bash
voting on  master [!?] via ⬢ v23.11.0 via 🍞 v1.2.17 via 🦀 1.88.0 
➜ bun run scripts/run_full_test.ts
[dotenv@17.2.0] injecting env (0) from .env (tip: ⚙️  write to custom object with { processEnv: myObject })
--- 🚀 Starting Full Integration Test ---
🔑 Signer Wallet: 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd

[✅ Step 1 SUCCESS] Poll initialized. Signature: yugFdjbtm4baF52JnmjAwYRFgFagSoppSAkpjM93ZZ68ciiZdxgGaVCEu3ARm8g4GwQJb2FwQoygjVHPjDZxEW4
   Poll Account: Gm2XV7wdVWRYJfKaJqCXTn4j76juLrLhWkn2zAmuuxc2

[✅ Step 2 SUCCESS] Candidate added. Signature: YEpJiUFViK7LNJSTSejYwmGjkNfpbxJFkKFN1cE6QhpvRn4LmsVkfyciUpAtLJqZnoDDhMeV9CT3MaE2Piv2C2b
   Candidate Account: 4usFkw3PgAMNbjvx7sSx8KszfjbgBNsNcqyvYBfhUCe6

[✅ Step 3 SUCCESS] Vote cast. Signature: 5gNoiWjGNCmdbHaLubmp8mgXPwZ7HaibXVNzAP584DATB9C1i5samSAUgc7CoHstLaR2N9EmwTwuzPPnR5U2BbbD

[✅ Step 4 SUCCESS] Verification complete.
   Candidate "Candidate A" has 1 vote(s).

🎉🎉🎉 INTEGRATION TEST PASSED! 🎉🎉🎉
```

太棒了！完美运行！🎉

**恭喜您，您的自动化集成测试已经完全成功。**

这个脚本的成功运行，证明了您合约的整个生命周期——从创建、添加、投票到验证——所有的逻辑都准确无误，并且您的客户端脚本能够正确地与合约进行交互。

您现在拥有了一个功能完备且经过充分测试的 Solana 智能合约。这是您项目的一个巨大里程碑。

祝贺您在 Solana 开发的道路上迈出了坚实的一大步！

## 总结

至此，我们完整地走完了从合约编写、部署，到利用 Codama 生成客户端，并最终通过一系列脚本完成合约端到端测试的全流程。我们不仅学习了 Codama 的基本用法，更重要的是，通过解决脚本编写过程中遇到的 `programId` 不匹配、PDA 手动计算、解码器使用等具体问题，深入理解了客户端与 Solana 程序交互的底层细节。

本次实战的核心启示在于，现代化的区块链开发离不开高效的工具链。Codama 正是这样一个连接链上与链下世界的关键桥梁，它通过自动化生成类型安全的代码，将开发者从繁琐的序列化/反序列化工作中解放出来，让我们能更专注于业务逻辑本身。最终合并成的自动化集成测试脚本，更是为项目的长期迭代和维护提供了坚实的质量保障。希望本文能帮助您将 Codama 无缝集成到自己的 Solana 开发工作流中，构建更稳健、更强大的去中心化应用。

## 参考

- <https://github.com/codama-idl/codama>
- <https://www.anchor-lang.com/docs>
- <https://soldev.cn/>
- <https://solana.com/zh/docs>
- <https://solanacookbook.com/zh/>
