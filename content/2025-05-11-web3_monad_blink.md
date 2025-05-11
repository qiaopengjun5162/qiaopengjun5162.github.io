+++
title = "Web3 新体验：Blink 一键解锁 Monad 未来"
description = "Web3 新体验：Blink 一键解锁 Monad 未来"
date = 2025-05-11T11:53:00Z
[taxonomies]
categories = ["Web3", "Monad", "Blink"]
tags = ["Web3", "Monad", "Blink"]
+++

<!-- more -->

# Web3 新体验：Blink 一键解锁 Monad 未来

Web3 时代，区块链交互正在变得前所未有的简单！Blink 作为一种“一键式”操作神器，让用户无需复杂步骤，就能轻松体验转账、捐赠等链上操作。结合高性能区块链 Monad，这款技术组合正开启 Web3 的无限可能。本文将带你从零开始，通过 Next.js 打造一个 Blink 驱动的 Monad 应用，解锁 Web3 的未来玩法！无论你是开发者还是区块链爱好者，这里都有你想要的新体验！

本文以 Monad 区块链为背景，详细讲解如何利用 Blink 技术构建一个“一键式” Web3 应用。Blink 通过后端 Provider 和前端 Client 解耦区块链操作与用户界面，实现无缝交互体验。我们从项目搭建、依赖安装、核心代码实现，到优化功能（如实时余额显示、交互反馈、记录保存）进行了全流程解析，并展示实际运行效果。无论你是想快速上手 Web3 开发的程序员，还是对 Monad 生态感兴趣的爱好者，本文都将为你揭开 Blink 的魅力，点亮 Web3 的未来！

### 什么是 Blink

Blink 是一种允许用户“一键”执行区块链操作（如捐赠、转账等）的交互式组件。它通常由两部分组成：

1. **Blink Provider**：后端接口，定义了 Blink 的元数据、UI 配置和实际要执行的区块链操作（如发起交易）。  
2. **Blink Client**：前端组件，负责展示 UI 并与用户交互，最终触发 Blink Provider 上定义的操作。

区块链链接，又称为Blinks，是获取链上体验并使其可在任何地方分发和可操作的最快方法。这项技术使应用程序能够将其产品体验从应用和网站中解耦，允许用户在任何地方即时执行无重定向的操作。

## 实操

### 创建项目

`npx create-next-app@14 blink-starter-monad && cd blink-starter-monad`快速创建一个 Next.js 项目并进入项目目录的复合命令

可以拆解为两部分：

1. **`npx create-next-app@14 blink-starter-monad`**
   - 使用 `npx` 临时安装并执行 `create-next-app`（Next.js 官方脚手架工具）。
   - `@14` 指定使用 **Next.js 14** 的最新版本。
   - `blink-starter-monad` 是自定义的项目名称（会生成同名文件夹）。
2. **`&& cd blink-starter-monad`**
   - `&&` 表示前一条命令成功后，执行后续操作。
   - `cd blink-starter-monad` 进入刚创建的项目目录。

#### **关键细节说明**

|         部分          |                            作用                            |
| :-------------------: | :--------------------------------------------------------: |
|         `npx`         |  Node.js 自带的包执行工具，无需全局安装即可运行临时依赖。  |
| `create-next-app@14`  | 明确指定使用 Next.js 14 版本的脚手架（避免默认安装旧版）。 |
| `blink-starter-monad` |     项目文件夹名称（可替换为其他名称，如 `my-app`）。      |
|      `&& cd ...`      |         自动化进入项目目录，节省手动 `cd` 的时间。         |

```bash
npx create-next-app@14 blink-starter-monad && cd blink-starter-monad
✔ Would you like to use TypeScript? … No / Yes
✔ Would you like to use ESLint? … No / Yes
✔ Would you like to use Tailwind CSS? … No / Yes
✔ Would you like to use `src/` directory? … No / Yes
✔ Would you like to use App Router? (recommended) … No / Yes
✔ Would you like to customize the default import alias (@/*)? … No / Yes
✔ What import alias would you like configured? … @/*
Creating a new Next.js app in /Users/qiaopengjun/Code/Monad/blink-starter-monad.

Using npm.

Initializing project with template: app-tw 


Installing dependencies:
- react
- react-dom
- next

Installing devDependencies:
- typescript
- @types/node
- @types/react
- @types/react-dom
- postcss
- tailwindcss
- eslint
- eslint-config-next

npm warn deprecated inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
npm warn deprecated @humanwhocodes/config-array@0.13.0: Use @eslint/config-array instead
npm warn deprecated rimraf@3.0.2: Rimraf versions prior to v4 are no longer supported
npm warn deprecated @humanwhocodes/object-schema@2.0.3: Use @eslint/object-schema instead
npm warn deprecated glob@7.2.3: Glob versions prior to v9 are no longer supported
npm warn deprecated eslint@8.57.1: This version is no longer supported. Please see https://eslint.org/version-support for other options.

added 372 packages in 16s

145 packages are looking for funding
  run `npm fund` for details
Initialized a git repository.

Success! Created blink-starter-monad at /Users/qiaopengjun/Code/Monad/blink-starter-monad

A new version of `create-next-app` is available!
You can update by running: npm i -g create-next-app

```

### 安装依赖

```bash
npm install @solana/actions wagmi viem@2.x


ls
README.md          next.config.mjs    package-lock.json  postcss.config.mjs tailwind.config.ts
next-env.d.ts      node_modules       package.json       src                tsconfig.json

rm -rf package-lock.json

pnpm install @solana/actions wagmi viem@2.x
 WARN  Moving typescript that was installed by a different package manager to "node_modules/.ignored"
 WARN  Moving @types/node that was installed by a different package manager to "node_modules/.ignored"
 WARN  Moving @types/react-dom that was installed by a different package manager to "node_modules/.ignored"
 WARN  Moving @types/react that was installed by a different package manager to "node_modules/.ignored"
 WARN  Moving postcss that was installed by a different package manager to "node_modules/.ignored"
 WARN  6 other warnings
 WARN  deprecated eslint@8.57.1: This version is no longer supported. Please see https://eslint.org/version-support for other options.
 WARN  6 deprecated subdependencies found: @humanwhocodes/config-array@0.13.0, @humanwhocodes/object-schema@2.0.3, @paulmillr/qr@0.2.1, glob@7.2.3, inflight@1.0.6, rimraf@3.0.2
Packages: +651
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Progress: resolved 679, reused 655, downloaded 0, added 651, done

dependencies:
+ @solana/actions 1.6.6
+ next 14.2.28 (15.3.2 is available)
+ react 18.3.1 (19.1.0 is available)
+ react-dom 18.3.1 (19.1.0 is available)
+ viem 2.29.1
+ wagmi 2.15.2

devDependencies:
+ @types/node 20.17.46 (22.15.17 is available) already in devDependencies, was not moved to dependencies.
+ @types/react 18.3.21 (19.1.3 is available) already in devDependencies, was not moved to dependencies.
+ @types/react-dom 18.3.7 (19.1.3 is available) already in devDependencies, was not moved to dependencies.
+ eslint 8.57.1 (9.26.0 is available) deprecated already in devDependencies, was not moved to dependencies.
+ eslint-config-next 14.2.28 (15.3.2 is available) already in devDependencies, was not moved to dependencies.
+ postcss 8.5.3 already in devDependencies, was not moved to dependencies.
+ tailwindcss 3.4.17 (4.1.6 is available) already in devDependencies, was not moved to dependencies.
+ typescript 5.8.3 already in devDependencies, was not moved to dependencies.

╭ Warning ───────────────────────────────────────────────────────────────────────────────────╮
│                                                                                            │
│   Ignored build scripts: bufferutil, keccak, unrs-resolver, utf-8-validate.                │
│   Run "pnpm approve-builds" to pick which dependencies should be allowed to run scripts.   │
│                                                                                            │
╰────────────────────────────────────────────────────────────────────────────────────────────╯

Done in 10.7s using pnpm v10.9.0

pnpm i
Lockfile is up to date, resolution step is skipped
Already up to date

╭ Warning ───────────────────────────────────────────────────────────────────────────────────╮
│                                                                                            │
│   Ignored build scripts: bufferutil, keccak, unrs-resolver, utf-8-validate.                │
│   Run "pnpm approve-builds" to pick which dependencies should be allowed to run scripts.   │
│                                                                                            │
╰────────────────────────────────────────────────────────────────────────────────────────────╯

Done in 362ms using pnpm v10.9.0
```

### 查看项目目录结构

```bash
blink-starter-monad on  main [✘!?] via ⬢ v23.11.0 
➜ tree . -L 6 -I "node_modules"                        
.
├── next-env.d.ts
├── next.config.mjs
├── package.json
├── pnpm-lock.yaml
├── postcss.config.mjs
├── public
│   └── donate-mon.png
├── README.md
├── src
│   ├── app
│   │   ├── actions.json
│   │   │   └── route.ts
│   │   ├── api
│   │   │   └── actions
│   │   │       └── donate-mon
│   │   │           └── route.ts
│   │   ├── favicon.ico
│   │   ├── fonts
│   │   │   ├── GeistMonoVF.woff
│   │   │   └── GeistVF.woff
│   │   ├── globals.css
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── config.ts
│   └── provider.tsx
├── tailwind.config.ts
└── tsconfig.json

9 directories, 19 files
```

### `src/app/api/actions/donate-mon/route.ts` 文件

```ts
// src/app/api/actions/donate-mon/route.ts

import { ActionGetResponse, ActionPostResponse } from "@solana/actions";
import { serialize } from "wagmi";
import { parseEther } from "viem";

// CAIP-2 format for Monad
const blockchain = `eip155:10143`;

// Create headers with CAIP blockchain ID
const headers = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers":
        "Content-Type, x-blockchain-ids, x-action-version",
    "Content-Type": "application/json",
    "x-blockchain-ids": blockchain,
    "x-action-version": "2.0",
};

// OPTIONS endpoint is required for CORS preflight requests
// Your Blink won't render if you don't add this
export const OPTIONS = async () => {
    return new Response(null, { headers });
};



// GET endpoint returns the Blink metadata (JSON) and UI configuration
export const GET = async (req: Request) => {
    // This JSON is used to render the Blink UI
    const response: ActionGetResponse = {
        type: "action",
        icon: `${new URL("/donate-mon.png", req.url).toString()}`,
        label: "1 MON",
        title: "Donate MON",
        description:
            "This Blink demonstrates how to donate MON on the Monad blockchain. It is a part of the official Blink Starter Guides by Dialect Labs.  \n\nLearn how to build this Blink: https://dialect.to/docs/guides/donate-mon",
        // Links is used if you have multiple actions or if you need more than one params
        links: {
            actions: [
                {
                    // Defines this as a blockchain transaction
                    type: "transaction",
                    label: "0.01 MON",
                    // This is the endpoint for the POST request
                    href: `/api/actions/donate-mon?amount=0.01`,
                },
                {
                    type: "transaction",
                    label: "0.05 MON",
                    href: `/api/actions/donate-mon?amount=0.05`,
                },
                {
                    type: "transaction",
                    label: "0.1 MON",
                    href: `/api/actions/donate-mon?amount=0.1`,
                },
                {
                    // Example for a custom input field
                    type: "transaction",
                    href: `/api/actions/donate-mon?amount={amount}`,
                    label: "Donate",
                    parameters: [
                        {
                            name: "amount",
                            label: "Enter a custom MON amount",
                            type: "number",
                        },
                    ],
                },
            ],
        },
    };

    // Return the response with proper headers
    return new Response(JSON.stringify(response), {
        status: 200,
        headers,
    });
};

// Wallet address that will receive the donations
const donationWallet = `0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5`;

// POST endpoint handles the actual transaction creation
export const POST = async (req: Request) => {
    try {
        // Extract amount from URL
        const url = new URL(req.url);
        const amount = url.searchParams.get("amount");

        if (!amount) {
            throw new Error("Amount is required");
        }

        // Build the transaction
        const transaction = {
            to: donationWallet,
            value: parseEther(amount).toString(),
            chainId: 10143,
        };

        const transactionJson = serialize(transaction);

        // Build ActionPostResponse
        const response: ActionPostResponse = {
            type: "transaction",
            transaction: transactionJson,
            message: "Donate MON",
        };

        // Return the response with proper headers
        return new Response(JSON.stringify(response), {
            status: 200,
            headers,
        });

    } catch (error) {
        // Log and return an error response
        console.error("Error processing request:", error);
        return new Response(JSON.stringify({ error: "Internal server error" }), {
            status: 500,
            headers,
        });
    }
};
```

### `src/app/actions.json/route.ts` 文件

```ts
// src/app/actions.json/route.ts

import { ACTIONS_CORS_HEADERS, ActionsJson } from "@solana/actions";

export const GET = async () => {
    const payload: ActionsJson = {
        rules: [
            // map all root level routes to an action
            {
                pathPattern: "/*",
                apiPath: "/api/actions/*",
            },
            // idempotent rule as the fallback
            {
                pathPattern: "/api/actions/**",
                apiPath: "/api/actions/**",
            },
        ],
    };

    return Response.json(payload, {
        headers: ACTIONS_CORS_HEADERS,
    });
};

// DO NOT FORGET TO INCLUDE THE `OPTIONS` HTTP METHOD
// THIS WILL ENSURE CORS WORKS FOR BLINKS
export const OPTIONS = GET;
```

### `src/config.ts` 文件

```ts
// src/config.ts

import { http, createConfig } from "wagmi";
import { monadTestnet } from "wagmi/chains";

export const config = createConfig({
    chains: [monadTestnet],
    transports: {
        [monadTestnet.id]: http(),
    },
});
```

### `src/provider.tsx` 文件

```ts
// src/provider.tsx

"use client";

import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ConnectKitProvider } from "connectkit";
import { type PropsWithChildren } from "react";
import { WagmiProvider } from "wagmi";
import { config } from "@/config";

const queryClient = new QueryClient();

export const Providers = ({ children }: PropsWithChildren) => {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <ConnectKitProvider>{children}</ConnectKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
};

```

### `src/app/layout.tsx` 文件

```ts
import type { Metadata } from "next";
import localFont from "next/font/local";
import "./globals.css";
import { Providers } from "@/provider";

const geistSans = localFont({
  src: "./fonts/GeistVF.woff",
  variable: "--font-geist-sans",
  weight: "100 900",
});
const geistMono = localFont({
  src: "./fonts/GeistMonoVF.woff",
  variable: "--font-geist-mono",
  weight: "100 900",
});

export const metadata: Metadata = {
  title: "Create Next App",
  description: "Generated by create next app",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}

```

### `src/app/page.tsx` 文件

```ts
// src/app/page.tsx

"use client";

import {
  Blink,
  useBlink,
  useActionsRegistryInterval,
} from "@dialectlabs/blinks";

import "@dialectlabs/blinks/index.css";

import { useEvmWagmiAdapter } from "@dialectlabs/blinks/hooks/evm";

import { ConnectKitButton, useModal } from "connectkit";

export default function Home() {
  // Actions registry interval
  useActionsRegistryInterval();

  // ConnectKit modal
  const { setOpen } = useModal();

  // Wagmi adapter, used to connect to the wallet
  const { adapter } = useEvmWagmiAdapter({
    onConnectWalletRequest: async () => {
      setOpen(true);
    },
  });

  // Action we want to execute in the Blink
  const { blink, isLoading } = useBlink({
    url: "evm-action:http://localhost:3000/api/actions/donate-mon",
  });

  return (
    <main className="flex flex-col items-center justify-center">
      <ConnectKitButton />
      <div className="w-1/2 lg:px-4 lg:p-8">
        {isLoading || !blink ? (
          <span>Loading</span>
        ) : (
          // Blink component, used to execute the action
          <Blink blink={blink} adapter={adapter} securityLevel="all" />
        )}
      </div>
    </main>
  );
}

```

### 启动项目

**`pnpm dev` 就是启动项目的开发服务器**，用于本地开发和实时调试。

**`pnpm dev` = 让项目“活过来”，方便你边写代码边看效果。**

```bash
blink-starter-monad on  main [✘!?] via ⬢ v23.11.0 took 13.3s 
➜ pnpm dev    

> blink-starter-monad@0.1.0 dev /Users/qiaopengjun/Code/Monad/blink-starter-monad
> next dev

  ▲ Next.js 14.2.28
  - Local:        http://localhost:3000

 ✓ Starting...
 ✓ Ready in 3.1s
 ○ Compiling / ...
 ✓ Compiled / in 1815ms (548 modules)
 GET / 200 in 2078ms
 ✓ Compiled in 208ms (254 modules)
 ✓ Compiled /favicon.ico in 151ms (308 modules)
 GET /favicon.ico 200 in 199ms
 GET /favicon.ico 200 in 11ms

blink-starter-monad on  main [✘!?] via ⬢ v23.11.0 
➜ pnpm dev

> blink-starter-monad@0.1.0 dev /Users/qiaopengjun/Code/Monad/blink-starter-monad
> next dev


✘ node v23.11.0, and next.js v14.2.28 are not yet supported in the Community edition of Console Ninja.
We are working hard on it for you https://tinyurl.com/3h9mtwra.

Estimated release dates:
  - Community users: around 8th June, 2025 (subject to team availability)
  - PRO users:       priority access is available now


✘ node v23.11.0, and next.js v14.2.28 are not yet supported in the Community edition of Console Ninja.
We are working hard on it for you https://tinyurl.com/3h9mtwra.

Estimated release dates:
  - Community users: around 8th June, 2025 (subject to team availability)
  - PRO users:       priority access is available now

  ▲ Next.js 14.2.28
  - Local:        http://localhost:3000

 ✓ Starting...
 ✓ Ready in 3s
 ○ Compiling / ...
 ✓ Compiled / in 1438ms (548 modules)
 GET / 200 in 1584ms
 ✓ Compiled in 94ms (254 modules)
 ○ Compiling /favicon.ico ...
 ✓ Compiled /favicon.ico in 1129ms (308 modules)
 GET /favicon.ico 200 in 1169ms
 GET /favicon.ico 200 in 3ms

```

### 在浏览器打开 <http://localhost:3000/> 查看

![image-20250510121050939](/images/image-20250510121050939.png)

### 访问 <http://localhost:3000/donate-mon.png>

![image-20250510215240835](/images/image-20250510215240835.png)

访问 <http://localhost:3000/api/actions/donate-mon>

![image-20250510215833993](/images/image-20250510215833993.png)

### 浏览器访问：<http://localhost:3000/> 查看并调用

![image-20250510225644385](/images/image-20250510225644385.png)

### 查看交易详情

<https://monad-testnet.socialscan.io/tx/0x35013869db672a21f1ec5deb398fa8878c66d5515bd6aa0c36c5bd078b5b52eb>

![image-20250511132625705](/images/image-20250511132625705.png)

### 优化完善

- 实时显示钱包余额

- 捐赠后弹窗反馈（显示余额变化、时间、捐赠人、接收人）

- 最近一条捐赠记录本地保存与展示

```ts
// src/app/page.tsx

"use client";

import {
  Blink,
  useBlink,
  useActionsRegistryInterval,
} from "@dialectlabs/blinks";

import "@dialectlabs/blinks/index.css";

import { useEvmWagmiAdapter } from "@dialectlabs/blinks/hooks/evm";

import { ConnectKitButton, useModal } from "connectkit";
import { useAccount, useBalance } from "wagmi";
import { monadTestnet } from "wagmi/chains";
import { useState, useEffect, useRef } from "react";
import { formatUnits } from "viem";

const DONATION_WALLET =
  process.env.NEXT_PUBLIC_DONATION_WALLET || "你的捐赠钱包地址";

export default function Home() {
  // Actions registry interval
  useActionsRegistryInterval();

  // ConnectKit modal
  const { setOpen } = useModal();

  // Wagmi adapter, used to connect to the wallet
  const { adapter } = useEvmWagmiAdapter({
    onConnectWalletRequest: async () => {
      setOpen(true);
    },
  });

  // Action we want to execute in the Blink
  const { blink, isLoading } = useBlink({
    url: "evm-action:http://localhost:3000/api/actions/donate-mon",
  });

  const { address, isConnected } = useAccount();
  const { data: balance, isLoading: isBalanceLoading } = useBalance(
    address
      ? {
          address,
          chainId: monadTestnet.id,
        }
      : { address: undefined }
  );

  const [showModal, setShowModal] = useState(false);
  const [prevBalance, setPrevBalance] = useState<string | undefined>();
  const [lastDonation, setLastDonation] = useState<{
    from?: string;
    to?: string;
    prevBalance?: string;
    postBalance?: string;
    time?: string;
  } | null>(null);
  const lastAmountRef = useRef<string | undefined>(undefined);

  // 拦截 Blink 按钮点击，记录 prevBalance 到 pendingDonation
  useEffect(() => {
    if (!blink) return;
    const container = document.querySelector(".dialect-blink");
    if (!container) return;
    const handler = (e: Event) => {
      let target = e.target as HTMLElement;
      while (target && target.tagName !== "BUTTON" && target !== container) {
        target = target.parentElement as HTMLElement;
      }
      if (target && target.tagName === "BUTTON") {
        // 记录"待确认捐赠"，只存 prevBalance
        if (balance?.value) {
          const pending = {
            from: address,
            to: DONATION_WALLET,
            prevBalance: balance.value.toString(),
            time: new Date().toLocaleString(),
          };
          localStorage.setItem("pendingDonation", JSON.stringify(pending));
        }
      }
    };
    container.addEventListener("click", handler);
    return () => container.removeEventListener("click", handler);
  }, [blink, address, balance?.value]);

  // 页面加载时读取最近一条捐赠记录
  useEffect(() => {
    const record = localStorage.getItem("lastDonation");
    if (record) {
      setLastDonation(JSON.parse(record));
    }
  }, []);

  useEffect(() => {
    if (
      prevBalance &&
      balance?.value &&
      prevBalance !== balance.value.toString()
    ) {
      // 读取"待确认捐赠"
      const pending = localStorage.getItem("pendingDonation");
      let record;
      if (pending) {
        record = JSON.parse(pending);
        // 清理 pending
        localStorage.removeItem("pendingDonation");
        // 存 postBalance
        record.postBalance = balance.value.toString();
      } else {
        // 兜底
        record = {
          from: address,
          to: DONATION_WALLET,
          prevBalance,
          postBalance: balance.value.toString(),
          time: new Date().toLocaleString(),
        };
      }
      setLastDonation(record);
      setShowModal(true);
      // 保存到 localStorage
      localStorage.setItem("lastDonation", JSON.stringify(record));
    }
    if (balance?.value) {
      setPrevBalance(balance.value.toString());
    }
  }, [balance?.value]);

  return (
    <main className="flex flex-col items-center justify-center">
      {showModal && lastDonation && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-40 z-50">
          <div className="bg-white rounded-lg p-8 shadow-lg text-center">
            <div className="text-2xl font-bold mb-2">感谢您的捐赠！</div>
            <div className="text-left text-gray-700 text-sm">
              <div>时间：{lastDonation.time}</div>
              <div>捐赠人：{lastDonation.from}</div>
              <div>接收人：{lastDonation.to}</div>
              <div>
                余额变化：
                {balance && lastDonation.prevBalance
                  ? Number(
                      formatUnits(
                        BigInt(lastDonation.prevBalance),
                        balance.decimals
                      )
                    ).toFixed(4)
                  : "--"}
                {" → "}
                {balance && lastDonation.postBalance
                  ? Number(
                      formatUnits(
                        BigInt(lastDonation.postBalance),
                        balance.decimals
                      )
                    ).toFixed(4)
                  : "--"}{" "}
                MON
              </div>
            </div>
            <button
              className="mt-4 px-4 py-2 bg-blue-600 text-white rounded"
              onClick={() => setShowModal(false)}
            >
              关闭
            </button>
          </div>
        </div>
      )}
      <ConnectKitButton />
      {isConnected && (
        <div className="my-4 p-4 bg-white rounded-lg shadow text-center w-full max-w-md">
          <div className="text-gray-500 text-sm mb-1">钱包余额</div>
          <div className="text-2xl font-bold text-blue-600">
            {isBalanceLoading
              ? "加载中..."
              : balance?.value
              ? `${Number(formatUnits(balance.value, balance.decimals)).toFixed(
                  4
                )} MON`
              : "-- MON"}
          </div>
          {/* 最近一条捐赠记录 */}
          {lastDonation && (
            <div className="my-4 p-3 bg-gray-50 rounded shadow text-sm text-gray-700">
              <div className="font-bold mb-1">最近一条捐赠记录</div>
              <div>时间：{lastDonation.time}</div>
              <div>捐赠人：{lastDonation.from}</div>
              <div>接收人：{lastDonation.to}</div>
              <div>
                余额变化：
                {balance && lastDonation.prevBalance
                  ? Number(
                      formatUnits(
                        BigInt(lastDonation.prevBalance),
                        balance.decimals
                      )
                    ).toFixed(4)
                  : "--"}
                {" → "}
                {balance && lastDonation.postBalance
                  ? Number(
                      formatUnits(
                        BigInt(lastDonation.postBalance),
                        balance.decimals
                      )
                    ).toFixed(4)
                  : "--"}{" "}
                MON
              </div>
            </div>
          )}
        </div>
      )}
      <div className="w-1/2 lg:px-4 lg:p-8">
        {isLoading || !blink ? (
          <span>Loading</span>
        ) : (
          // Blink component, used to execute the action
          <Blink blink={blink} adapter={adapter} securityLevel="all" />
        )}
      </div>
    </main>
  );
}

```

### 访问：<http://localhost:3000/> 调用查看

![image-20250511185826884](/images/image-20250511185826884.png)

#### 最近一条捐赠记录展示

![image-20250511185848589](/images/image-20250511185848589.png)
![image-20250511185855231](/images/image-20250511185855231.png)

## 总结

Blink 的出现，让 Web3 交互变得简单而高效，结合 Monad 的高性能区块链，开启了链上应用的新篇章。本文通过一个 Blink 驱动的 Monad 应用开发案例，展示了从搭建到优化的全过程，涵盖“一键”交互、实时反馈等实用功能。无论你是想探索 Web3 技术的前沿开发者，还是对区块链未来充满好奇的爱好者，Blink 和 Monad 都为你提供了一扇通往未来的大门。快来动手实践，解锁属于你的 Web3 新体验！

## 参考

- <https://docs.monad.xyz/guides/blinks-guide>
- <https://www.dialect.to/>
- <https://docs.dialect.to/>
- <https://github.com/dialectlabs>
- <https://dial.to/>
- <https://monad-testnet.socialscan.io/tx/0x35013869db672a21f1ec5deb398fa8878c66d5515bd6aa0c36c5bd078b5b52eb>
- <https://github.com/qiaopengjun5162/monad-donation-dapp>
- <https://gmonad.cc/>
