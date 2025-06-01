+++
title = "从零到 Web3：使用 @solana/kit 快速查询 Solana 账户余额"
description = "从零到 Web3：使用 @solana/kit 快速查询 Solana 账户余额"
date = 2025-06-01T05:59:35Z
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# 从零到 Web3：使用 @solana/kit 快速查询 Solana 账户余额

Web3 浪潮席卷全球，Solana 凭借其高速、低成本的区块链网络成为 Web3 开发者的热门选择。本文将带你从零开始，通过一个简单实操教程，使用 `@solana/kit` 快速搭建项目并查询 Solana 账户余额。无论你是 Web3 新手还是希望深入 Solana 开发的开发者，这篇指南都将助你轻松迈入 Web3 世界，掌握与 Solana 区块链交互的核心技能！

本文详细讲解如何基于 `@solana/kit` 构建一个 Solana 项目，从项目初始化、依赖安装到代码实现，逐步展示如何在本地节点和 Devnet 上查询账户余额。通过简洁的代码示例和运行结果，你将快速学会使用 `@solana/kit` 连接 Solana 网络，获取账户余额信息。本教程适合 Web3 初学者和希望提升 Solana 开发技能的开发者，为你的 Web3 开发之旅打下坚实基础。

## 实操

### 创建项目

```bash
mkdir sol-get-balance
cd sol-get-balance
```

### 初始化项目

```bash
pnpm init
tsc --init
```

### 安装依赖

```bash
pnpm add @solana/kit tsx
pnpm add dotenv
```

### 查看项目目录

```bash
solana-sandbox/get_wallet_account on  main [!?] is 📦 1.0.0 via ⬢ v23.11.0 
➜ tree . -L 6 -I "target|test-ledger|.vscode|node_modules"
.
├── package.json
├── pnpm-lock.yaml
├── src
│   ├── client.ts
│   ├── fetch_account.ts
│   ├── get_balance.ts
│   └── index.ts
└── tsconfig.json

2 directories, 7 files

```

### client.ts 文件

```ts
import { createSolanaRpc, createSolanaRpcSubscriptions } from "@solana/kit";
import { Rpc, RpcSubscriptions, SolanaRpcApi, SolanaRpcSubscriptionsApi } from "@solana/kit";
import 'dotenv/config';
// 或
// import dotenv from 'dotenv';
// dotenv.config();

const rpcUrl = process.env.SOLANA_RPC_URL || "http://localhost:8899";

export type Client = {
    rpc: Rpc<SolanaRpcApi>;
    rpcSubscriptions: RpcSubscriptions<SolanaRpcSubscriptionsApi>;
};

let client: Client | undefined;
export function createClient(): Client {
    if (!client) {
        client = {
            rpc: createSolanaRpc(rpcUrl),
            // rpc: createSolanaRpc("http://127.0.0.1:8899"),
            rpcSubscriptions: createSolanaRpcSubscriptions("ws://127.0.0.1:8900"),
        };
    }
    return client;
}
```

### get_balance.ts 文件

```ts
import { address, Address, Lamports, } from "@solana/kit";
import { createClient } from "./client";



async function getBalance(account: Address): Promise<Lamports> {
    const client = createClient();

    const { value: balance } = await client.rpc.getBalance(account).send();
    console.log(`Balance of ${account}: ${balance}`);
    return balance;

}

export default getBalance;
```

### index.ts 文件

```ts
import GetBalance from './get_balance';
import { address } from "@solana/kit";


const main = async () => {
    const account = address("6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd");
    const balance = await GetBalance(account);
    console.log(`Balance: ${balance} lamports.`);
}

main().catch(err => {
    console.error(err);
})
```

### 本地节点运行

```bash
solana-sandbox/get_wallet_account on  main [!?] is 📦 1.0.0 via ⬢ v23.11.0 
➜ solana-test-validator -r    
Ledger location: test-ledger
Log: test-ledger/validator.log
⠓ Initializing...                                                                                                Waiting for fees to stabilize 1...
Identity: 5cohQrcQrRNos8XCwyU33rLt24qHZKBkh8sNziBNKdv6
Genesis Hash: 6rL1VKjKTuwRdRcLtZRQvs3m1EnPT8ZthSaxpPGdCfTR
Version: 2.1.21
Shred Version: 61775
Gossip Address: 127.0.0.1:1024
TPU Address: 127.0.0.1:1027
JSON RPC URL: http://127.0.0.1:8899
WebSocket PubSub URL: ws://127.0.0.1:8900
⠤ 00:07:31 | Processed Slot: 913 | Confirmed Slot: 913 | Finalized Slot: 882 | Full Snapshot Slot: 800 | Incrementa
```

### 运行脚本获取本地余额

```bash
solana-sandbox/get_wallet_account on  main [!?] is 📦 1.0.0 via ⬢ v23.11.0 
➜ pnpm start    

> get_wallet_account@1.0.0 start /Users/qiaopengjun/Code/Solana/solana-sandbox/get_wallet_account
> tsx src/index.ts

Balance of 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd: 500000000000000000
Balance: 500000000000000000 lamports.

```

### 运行脚本查看Devnet 余额

```bash
solana-sandbox/get_wallet_account on  main [!?] is 📦 1.0.0 via ⬢ v23.11.0 
➜ pnpm start

> get_wallet_account@1.0.0 start /Users/qiaopengjun/Code/Solana/solana-sandbox/get_wallet_account
> tsx src/index.ts

Balance of 6MZDRo5v8K2NfdohdD76QNpSgk3GH3Aup53BeMaRAEpd: 257060117736
Balance: 257060117736 lamports.

solana-sandbox/get_wallet_account on  main [!?] is 📦 1.0.0 via ⬢ v23.11.0 took 2.4s 
➜ solana balance
257.060117736 SOL
```

## 总结

通过本教程，你已成功从零起步，使用 `@solana/kit` 实现了一个查询 Solana 账户余额的 Web3 项目。`@solana/kit` 的强大功能让你轻松与 Solana 区块链交互，开启了 Web3 开发的无限可能。接下来，你可以进一步探索 Solana 的代币创建、智能合约开发等高级功能，加速迈向 Web3 世界的核心舞台！快来动手实践，加入 Web3 开发的热潮吧！

## 参考

- <https://solana-kit-docs.vercel.app/docs/getting-started/setup>
- <https://github.com/anza-xyz/kit>
- <https://www.anchor-lang.com/docs/tokens/basics/create-token-account>
- <https://attractive-spade-1e3.notion.site/Solana-fca856aad4e5441f80f28cc4e015ca98>
