+++
title = "快速上手 Web3：用 @solana/kit 在 Solana 上创建钱包并查询余额"
description = "快速上手 Web3：用 @solana/kit 在 Solana 上创建钱包并查询余额"
date = 2025-06-03T00:32:30Z
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# 快速上手 Web3：用 @solana/kit 在 Solana 上创建钱包并查询余额

Web3 的浪潮正在席卷全球，Solana 作为高性能区块链的代表，以其低延迟和高吞吐量成为开发者构建去中心化应用（DApp）的首选平台。本文通过一个简单实用的项目，展示如何利用 @solana/kit 库在 Solana 本地节点上创建钱包、执行空投并查询余额。无论您是 Web3 开发的初学者，还是希望快速掌握 Solana 开发技能的开发者，本教程都将为您提供清晰的指引，助您迈出 Web3 开发的第一步。

本文详细介绍了一个基于 Solana 区块链的 Web3 开发入门项目，通过 @solana/kit 库实现钱包创建和余额查询。教程涵盖了项目初始化、依赖安装、TypeScript 代码编写、启动本地 Solana 节点以及运行程序的完整流程。核心代码通过 createClient 函数连接本地节点，生成新钱包并自动空投 1 SOL（10亿 lamports），随后查询并输出钱包余额。文章还展示了项目目录结构、代码解析及运行结果，为 Web3 开发者提供了一个简单易懂的实践范例，适合快速上手 Solana 和 Web3 开发。

## 实操

### 创建项目并切换到项目目录

```bash
mcd generate_a_signer
/Users/qiaopengjun/Code/Solana/solana-sandbox/generate_a_signer
```

### 项目初始化

```bash
pnpm init
Wrote to /Users/qiaopengjun/Code/Solana/solana-sandbox/generate_a_signer/package.json

{
  "name": "generate_a_signer",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "packageManager": "pnpm@10.9.0"
}

tsc --init 

Created a new tsconfig.json with:                                                                                       
                                                                                                                     TS 
  target: es2016
  module: commonjs
  strict: true
  esModuleInterop: true
  skipLibCheck: true
  forceConsistentCasingInFileNames: true


You can learn more at ***********************
```

### 安装依赖

```bash
solana-sandbox/generate_a_signer on  main [!?] is 📦 1.0.0 via ⬢ v23.11.0 
➜ pnpm add @solana/kit tsx
```

### 查看项目目录

```bash
solana-sandbox/generate_a_signer on  main [!?] is 📦 1.0.0 via ⬢ v23.11.0 
➜ tree . -L 6 -I "target|test-ledger|.vscode|node_modules"
.
├── package.json
├── pnpm-lock.yaml
├── src
│   ├── client.ts
│   └── index.ts
└── tsconfig.json

2 directories, 5 files

```

### Client 文件

```ts
import {
  airdropFactory,
  generateKeyPairSigner,
  lamports,
  MessageSigner,
  SolanaRpcApi,
  Rpc,
  TransactionSigner,
  RpcSubscriptions,
  SolanaRpcSubscriptionsApi,
  createSolanaRpc,
  createSolanaRpcSubscriptions,
} from "@solana/kit";

export type Client = {
  rpc: Rpc<SolanaRpcApi>;
  rpcSubscriptions: RpcSubscriptions<SolanaRpcSubscriptionsApi>;
  wallet: TransactionSigner & MessageSigner;
};

let client: Client | undefined;
export async function createClient(): Promise<Client> {
  if (!client) {
    // Create RPC objects and airdrop function.
    const rpc = createSolanaRpc("http://127.0.0.1:8899");
    const rpcSubscriptions = createSolanaRpcSubscriptions(
      "ws://127.0.0.1:8900"
    );
    const airdrop = airdropFactory({ rpc, rpcSubscriptions });

    // Create a wallet with lamports.
    const wallet = await generateKeyPairSigner();
    await airdrop({
      recipientAddress: wallet.address,
      lamports: lamports(1_000_000_000n),
      commitment: "confirmed",
    });

    // Store the client.
    client = { rpc, rpcSubscriptions, wallet };
  }
  return client;
}

```

这段代码定义了一个 `createClient` 异步函数，用于连接本地 Solana 节点，生成一个新钱包，并自动空投一定数量的 SOL（lamports），最终返回包含 RPC 客户端、订阅对象和钱包的 `client` 实例，方便后续进行区块链交互。

### Index 文件

```ts
import { createClient } from "./client";

const main = async () => {
  const client = await createClient();
  const { value: balance } = await client.rpc
    .getBalance(client.wallet.address)
    .send();
  console.log(`Balance: ${balance} lamports.`);
};

main().catch(console.error);

```

这段代码是一个简单的 TypeScript/JavaScript 脚本，用于在 Solana 区块链本地节点上获取并打印一个钱包地址的余额。下面是详细解释：

```ts
import { createClient } from "./client";
```

- 从本地的 `client.ts` 文件导入 `createClient` 函数。这个函数负责初始化与 Solana 节点的连接和钱包。

---

```ts
const main = async () => {
  const client = await createClient();
  const { value: balance } = await client.rpc
    .getBalance(client.wallet.address)
    .send();
  console.log(`Balance: ${balance} lamports.`);
};
```

- 定义了一个异步的 `main` 函数。
- `const client = await createClient();`  
  调用 `createClient`，返回一个包含 RPC 客户端、订阅对象和钱包的 `client` 实例。
- `const { value: balance } = await client.rpc.getBalance(client.wallet.address).send();`
  通过 RPC 客户端查询钱包地址的余额。  
  - `client.wallet.address` 是钱包的地址。
  - `client.rpc.getBalance(...)` 构造一个查询余额的请求。
  - `.send()` 发送请求到 Solana 节点，返回余额信息。
  - 通过解构赋值获取 `value` 字段（即余额，单位为 lamports）。
- `console.log(...)`  打印余额到控制台。

---

```ts
main().catch(console.error);
```

调用 `main` 函数，并捕获可能的异常，打印错误信息。
总结：该脚本会自动创建一个钱包（或使用已存在的钱包），连接到本地 Solana 节点，查询该钱包的余额，并将余额（以 lamports 为单位）输出到控制台。

### 启动本地节点

```bash
solana-sandbox/generate_a_signer on  main [!?] is 📦 1.0.0 via ⬢ v23.11.0 
➜ solana-test-validator -r
Ledger location: test-ledger
Log: test-ledger/validator.log
⠂ Initializing...                                                                                                Waiting for fees to stabilize 1...
Identity: DGM7ZXUtyuebxhSTcWQ31SnqXyAWQzRMWF52oUibJzd8
Genesis Hash: 8noaWTDs3HMwFkREMkg76BvuT8AVS4Xk8wCwadb9PnXF
Version: 2.1.21
Shred Version: 58648
Gossip Address: 127.0.0.1:1024
TPU Address: 127.0.0.1:1027
JSON RPC URL: http://127.0.0.1:8899
WebSocket PubSub URL: ws://127.0.0.1:8900
⠦ 00:01:26 | Processed Slot: 182 | Confirmed Slot: 182 | Finalized Slot: 151 | Full Snapshot Slot: 100 | Incrementa
```

### 运行

```bash
solana-sandbox/generate_a_signer on  main [!?] is 📦 1.0.0 via ⬢ v23.11.0 
➜ pnpm start                                               

> generate_a_signer@1.0.0 start /Users/qiaopengjun/Code/Solana/solana-sandbox/generate_a_signer
> tsx src/index.ts

Balance: 1000000000 lamports.
```

## 总结

通过本教程，我们展示了如何利用 @solana/kit 在 Solana 区块链上快速构建一个 Web3 项目，实现钱包创建、空投和余额查询的核心功能。这个简单高效的流程不仅体现了 Solana 在 Web3 开发中的强大性能，也为开发者提供了进入去中心化应用开发领域的便捷起点。基于本文的基础，您可以进一步探索 Solana 的智能合约、交易签名等高级功能，通过参考文档和开源资源，加速在 Web3 生态中的创新与实践。

## 参考

- <https://solana-kit-docs.vercel.app/docs/getting-started/signers>
- <https://github.com/anza-xyz/kit>
- <https://www.anchor-lang.com/docs/tokens/basics/create-token-account>
