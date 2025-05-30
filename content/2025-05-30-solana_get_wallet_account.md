+++
title = "Solana Web3 快速入门：创建并获取钱包账户的完整指南"
description = "Solana Web3 快速入门：创建并获取钱包账户的完整指南"
date = 2025-05-30T00:37:19Z
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# Solana Web3 快速入门：创建并获取钱包账户的完整指南

在区块链技术的浪潮中，Solana 以其高性能和低成本的特性迅速崭露头角，成为 Web3 开发的热门选择。本文将带你走进 Solana 的世界，通过一个简单的实操案例，详细讲解如何创建 Solana 钱包账户、请求 SOL 空投并获取账户信息。无论你是区块链新手还是开发者，这篇教程都将为你提供清晰的指引，快速上手 Solana 开发！

本文基于 Solana 官方文档，结合实际操作，展示如何使用 @solana/web3.js 库生成密钥对、为新地址请求 SOL 空投，并查询账户信息。教程涵盖环境配置、项目初始化、代码实现和本地节点启动等步骤，适合初学者快速掌握 Solana 开发基础。最终，你将学会如何在 Solana 网络上创建并操作钱包账户，为进一步的 Web3 开发打下坚实基础。

## [获取钱包账户](https://solana.com/zh/docs/intro/quick-start/reading-from-network#获取钱包账户)

1. 生成一个新的密钥对（公钥/私钥对）。
2. 请求 SOL 空投以为新地址提供资金。
3. 检索已资助地址的账户数据。

## 实操

在 Solana 上，为新地址提供 SOL 资金会自动创建一个由系统程序拥有的账户。所有“钱包”账户只是由系统程序拥有的账户，这些账户持有 SOL 并可以签署交易。

### 前提

```bash
solana --version
solana-cli 2.1.21 (src:8a085eeb; feat:1416569292, client:Agave)

rustc --version
rustc 1.87.0 (17067e9ac 2025-05-09)

anchor --version
anchor-cli 0.31.1
```

### 创建项目并切换到项目目录

```bash
mcd get_wallet_account
/Users/qiaopengjun/Code/Solana/solana-sandbox/get_wallet_account
```

### 初始化项目

```bash
pnpm init
Wrote to /Users/qiaopengjun/Code/Solana/solana-sandbox/get_wallet_account/package.json

{
  "name": "get_wallet_account",
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
solana-sandbox/get_wallet_account on  main [?] is 📦 1.0.0 via ⬢ v23.11.0 on 🐳 v27.5.1 (orbstack) 
➜ pnpm install --save @solana/web3.js   

solana-sandbox/get_wallet_account on  main [?] is 📦 1.0.0 via ⬢ v23.11.0 on 🐳 v27.5.1 (orbstack) 
➜ pnpm install --save @solana/kit
```

### 查看项目目录

```bash
solana-sandbox/get_wallet_account on  main [?] is 📦 1.0.0 via ⬢ v23.11.0 on 🐳 v27.5.1 (orbstack) 
➜ tree . -L 6 -I "target|test-ledger|.vscode|node_modules"
.
├── package.json
├── pnpm-lock.yaml
├── src
│   └── fetch_account.ts
└── tsconfig.json

2 directories, 4 files

```

### fetch_account.ts 文件

```ts
import { Keypair, Connection, LAMPORTS_PER_SOL } from "@solana/web3.js";

(async () => {
    const keypair = Keypair.generate();
    console.log(`Public Key: ${keypair.publicKey}`);

    const connection = new Connection("http://localhost:8899", "confirmed");

    // Funding an address with SOL automatically creates an account
    const signature = await connection.requestAirdrop(
        keypair.publicKey,
        LAMPORTS_PER_SOL
    );
    await connection.confirmTransaction(signature, "confirmed");

    const accountInfo = await connection.getAccountInfo(keypair.publicKey);
    console.log(JSON.stringify(accountInfo, null, 2));
})();
```

### 启动本地节点

```bash
solana-sandbox/get_wallet_account on  main [?] is 📦 1.0.0 via ⬢ v23.11.0 on 🐳 v27.5.1 (orbstack) 
➜ solana-test-validator
Ledger location: test-ledger
Log: test-ledger/validator.log
⠈ Initializing...                                                                                                Waiting for fees to stabilize 1...
Identity: FFQCYjHdHYxfeAjTrTVu2pzeg8CYspy2GZTSNdwX8XMb
Genesis Hash: 54MLkuZMgbEfuVdTGg56XavmWVmao1Y63QK1wTgvoCpV
Version: 2.1.21
Shred Version: 39123
Gossip Address: 127.0.0.1:1024
TPU Address: 127.0.0.1:1027
JSON RPC URL: http://127.0.0.1:8899
WebSocket PubSub URL: ws://127.0.0.1:8900
⠴ 00:00:42 | Processed Slot: 89 | Confirmed Slot: 89 | Finalized Slot: 58 | Full Snapshot Slot: - | Incremental Sna



```

### 执行 TypeScript 文件

```bash
solana-sandbox/get_wallet_account on  main [?] is 📦 1.0.0 via ⬢ v23.11.0 on 🐳 v27.5.1 (orbstack) 
➜ ts-node src/fetch_account.ts
Public Key: B7fkF4vmjKZtzZkSqcoH5RZRmbQYzujjBWZSEbr5oibp
{
  "data": {
    "type": "Buffer",
    "data": []
  },
  "executable": false,
  "lamports": 1000000000,
  "owner": "11111111111111111111111111111111",
  "rentEpoch": 18446744073709552000,
  "space": 0
}
```

## 总结

通过本教程，我们完成了 Solana 钱包账户的创建与基本操作，包括生成密钥对、请求 SOL 空投以及获取账户信息。Solana 的高性能和简单易用的开发工具（如 @solana/web3.js）使其成为 Web3 开发的理想选择。希望这篇文章能帮助你快速上手 Solana，为探索更多区块链应用场景奠定基础！继续学习和实践，你将能够构建更复杂的去中心化应用。欢迎关注更多 Solana 开发教程，开启你的 Web3 之旅！

## 参考

- <https://solana.com/zh/docs/intro/quick-start>
- <https://www.anza.xyz/>
- <https://github.com/anza-xyz/agave>
- <https://github.com/solana-foundation/solana-web3.js>
- <https://github.com/anza-xyz/kit>
