+++
title = "Web3 数据索引新利器：用 The Graph 打造 NFT 市场子图全攻略"
description = "Web3 数据索引新利器：用 The Graph 打造 NFT 市场子图全攻略"
date = 2025-04-27T02:45:17Z
[taxonomies]
categories = ["Web3", "The Graph", "Solidity", "Ethereum"]
tags = ["Web3", "The Graph", "Solidity", "Ethereum"]

+++

<!-- more -->

# Web3 数据索引新利器：用 The Graph 打造 NFT 市场子图全攻略

Web3 浪潮席卷而来，区块链数据的查询与索引成为去中心化应用（dApp）开发的核心挑战。The Graph 作为 Web3 数据索引的“新利器”，以其去中心化协议和高效查询能力，彻底简化了 NFT 市场等场景下的数据处理流程。无论是追踪交易事件还是分析市场动态，The Graph 都能让开发者事半功倍。本文将为您献上一份从零到部署的 NFT 市场子图全攻略，涵盖环境搭建、子图配置、映射编写及部署实战，助您快速掌握 The Graph，解锁 Web3 数据索引的无限可能！

本文深入剖析 The Graph 在 Web3 数据索引中的强大功能，以 NFT 市场为例，详细讲解如何利用 The Graph 构建高效子图。通过清晰的步骤指南，您将学会安装 Graph CLI、初始化子图、配置 NFT 市场合约事件、定义 schema、编写映射逻辑，并最终部署到 The Graph Studio。文章还提供部署失败的解决方案（如使用 Alchemy）和丰富的学习资源，适合 Web3 开发者快速上手。无论是初学者还是资深开发者，都能通过这篇全攻略掌握 The Graph 的核心技能，轻松应对区块链数据挑战。

The Graph是一个强大的去中心化协议，可以无缝地查询区块链数据并将其索引。 它简化了查询区块链数据的复杂过程，使开发dapp 更快和更容易。

![thegraph](https://thegraph.com/docs/_next/static/media/graph-dataflow.4a0efacc.png)

## 为NFTMarket创建一个The Graph子图

### 学习资料

- 快速入门： <https://thegraph.com/docs/zh/quick-start/>
- 如何编写一个子图的详细介绍 <https://thegraph.com/docs/zh/developing/creating-a-subgraph/>
- 如何查询一个子图的详细介绍 <https://thegraph.com/docs/zh/querying/querying-from-an-application/>
- 中文相关资源列表： <https://www.notion.so/graphprotocolcn/The-Graph-49977afa44644ebf9052b9220f539396>
- The graph bounty中一个比较好的子图的例子： <https://github.com/Autosaida/Zircuit-Restaking-Subgraph/>
- The graph bounty中一个比较好的Usage of Subgraph的例子：<https://github.com/ttttonyhe/stader-graph-dashboard>

### 步骤

1. 安装Graph CLI 在本地环境中安装Graph CLI工具
2. 初始化子图 使用Graph CLI初始化一个新的子图
3. 配置子图（subgraph.yaml） 设置要索引的NFTMarket合约和List、Buy事件
4. 定义Schema（schema.graphql） 定义List和Buy实体
5. 编写映射（mapping.ts） 编写映射逻辑，以处理合约事件并更新子图的存储
6. 部署子图 使用Graph CLI工具部署子图到The Graph Studio。

## 实操

### 第一步：创建子图

![image-20240719152946198](/images/image-20240719152946198.png)

### 第二步：填写子图名称

![image-20240719153052059](/images/image-20240719153052059.png)

### 第三步：填写描述信息和源码链接（注意：描述信息必填否则不能保存）

![image-20240719153315148](/images/image-20240719153315148.png)

### 第四步：点击 Save 后即可根据右方的命令去执行对应的操作

![image-20240719153716869](/images/image-20240719153716869.png)

### 第五步：安装  GRAPH CLI

```bash
pnpm install -g @graphprotocol/graph-cli
```

### 第六步：初始化子图

```bash
graph init --studio nftmarkethub
```

![image-20240719155025236](/images/image-20240719155025236.png)

### 第七步：认证

```bash
graph auth --studio c982cd704d2e5525feae40467e1937db
```

![image-20240719155212470](/images/image-20240719155212470.png)

### 第八步：切换目录

```bash
cd nftmarkethub
```

![image-20240719155321324](/images/image-20240719155321324.png)

### 第九步：BUILD 子图

```bash
graph codegen && graph build
```

![image-20240719155441488](/images/image-20240719155441488.png)

### 第十步：部署子图

```bash
graph deploy --studio nftmarkethub
```

部署失败

![image-20240719161346275](/images/image-20240719161346275.png)

试图查询失败信息

![image-20240720105810386](/images/image-20240720105810386.png)

#### 方法一：使用 alchemy 问题解决，部署成功

![image-20240721113552746](/images/image-20240721113552746.png)

#### 方法二：重新初始化部署，部署成功

```bash
graph init --studio nftmarkethub
 ›   Warning: In next major version, this flag will be removed. By default we will deploy to the Graph Studio. Learn more about Sunrise of
 ›   Decentralized Data https://thegraph.com/blog/unveiling-updated-sunrise-decentralized-data/
 ›   Warning: In next major version, this flag will be removed. By default we will deploy to the Graph Studio. Learn more about Sunrise of
 ›   Decentralized Data https://thegraph.com/blog/unveiling-updated-sunrise-decentralized-data/
 ›   Warning: In next major version, this flag will be removed. By default we will stop initializing a Git repository.
? Protocol … (node:28795) [DEP0040] DeprecationWarning: The `punycode` module is deprecated. Please use a userland alternative instead.
(Use `node --trace-deprecation ...` to show where the warning was created)
✔ Protocol · ethereum
✔ Subgraph slug · nftmarkethub
✔ Directory to create the subgraph in · nftmarkethub
? Ethereum network …
? Ethereum network …
? Ethereum network …
✔ Ethereum network · sepolia
✔ Contract address · 0xbba4229cD53442D56E306379E99332687E1fb31f
✔ Fetching ABI from Etherscan
✖ Failed to fetch Start Block: Failed to fetch contract creation transaction hash
✔ Do you want to retry? (Y/n) · true
✔ Fetching Start Block
✖ Failed to fetch Contract Name: Failed to fetch contract source code
✔ Do you want to retry? (Y/n) · true
✖ Failed to fetch Contract Name: Failed to fetch contract source code
✔ Do you want to retry? (Y/n) · true
✖ Failed to fetch Contract Name: Failed to fetch contract source code
✔ Do you want to retry? (Y/n) · true
✔ Fetching Contract Name
✔ Start Block · 6356694
✔ Contract Name · NFTMarket
✔ Index contract events as entities (Y/n) · true
  Generate subgraph
  Write subgraph to directory
✔ Create subgraph scaffold
✔ Initialize networks config
✔ Initialize subgraph repository
✔ Install dependencies with yarn
✔ Generate ABI and schema types with yarn codegen
Add another contract? (y/n):
Subgraph nftmarkethub created in nftmarkethub

Next steps:

  1. Run `graph auth` to authenticate with your deploy key.

  2. Type `cd nftmarkethub` to enter the subgraph.

  3. Run `yarn deploy` to deploy the subgraph.

Make sure to visit the documentation on https://thegraph.com/docs/ for further information.

NFTMarketHub/thegraph/thegraph on  main [⇡?] via ⬢ v22.1.0 via 🅒 base took 2m 40.6s
➜
graph auth --studio c982cd704d2e5525feae40467e1937db
 ›   Warning: In next major version, this flag will be removed. By default we will deploy to the Graph Studio. Learn more about Sunrise of
 ›   Decentralized Data https://thegraph.com/blog/unveiling-updated-sunrise-decentralized-data/
Deploy key set for https://api.studio.thegraph.com/deploy/

NFTMarketHub/thegraph/thegraph on  main [⇡?] via ⬢ v22.1.0 via 🅒 base
➜
cd nftmarkethub

NFTMarketHub/thegraph/thegraph/nftmarkethub on  main [⇡?] via ⬢ v22.1.0 via 🅒 base
➜
graph codegen && graph build
  Skip migration: Bump mapping apiVersion from 0.0.1 to 0.0.2
  Skip migration: Bump mapping apiVersion from 0.0.2 to 0.0.3
  Skip migration: Bump mapping apiVersion from 0.0.3 to 0.0.4
  Skip migration: Bump mapping apiVersion from 0.0.4 to 0.0.5
  Skip migration: Bump mapping apiVersion from 0.0.5 to 0.0.6
  Skip migration: Bump manifest specVersion from 0.0.1 to 0.0.2
  Skip migration: Bump manifest specVersion from 0.0.2 to 0.0.4
✔ Apply migrations
✔ Load subgraph from subgraph.yaml
  Load contract ABI from abis/NFTMarket.json
✔ Load contract ABIs
  Generate types for contract ABI: NFTMarket (abis/NFTMarket.json)
  Write types to generated/NFTMarket/NFTMarket.ts
✔ Generate types for contract ABIs
✔ Generate types for data source templates
✔ Load data source template ABIs
✔ Generate types for data source template ABIs
✔ Load GraphQL schema from schema.graphql
  Write types to generated/schema.ts
✔ Generate types for GraphQL schema

Types generated successfully

  Skip migration: Bump mapping apiVersion from 0.0.1 to 0.0.2
  Skip migration: Bump mapping apiVersion from 0.0.2 to 0.0.3
  Skip migration: Bump mapping apiVersion from 0.0.3 to 0.0.4
  Skip migration: Bump mapping apiVersion from 0.0.4 to 0.0.5
  Skip migration: Bump mapping apiVersion from 0.0.5 to 0.0.6
  Skip migration: Bump manifest specVersion from 0.0.1 to 0.0.2
  Skip migration: Bump manifest specVersion from 0.0.2 to 0.0.4
✔ Apply migrations
✔ Load subgraph from subgraph.yaml
  Compile data source: NFTMarket => build/NFTMarket/NFTMarket.wasm
✔ Compile subgraph
  Copy schema file build/schema.graphql
  Write subgraph file build/NFTMarket/abis/NFTMarket.json
  Write subgraph manifest build/subgraph.yaml
✔ Write compiled subgraph to build/

Build completed: build/subgraph.yaml


NFTMarketHub/thegraph/thegraph/nftmarkethub on  main [⇡?] via ⬢ v22.1.0 via 🅒 base took 3.0s
➜
graph deploy --studio nftmarkethub
Which version label to use? (e.g. "v0.0.1"): v0.0.1
  Skip migration: Bump mapping apiVersion from 0.0.1 to 0.0.2
  Skip migration: Bump mapping apiVersion from 0.0.2 to 0.0.3
  Skip migration: Bump mapping apiVersion from 0.0.3 to 0.0.4
  Skip migration: Bump mapping apiVersion from 0.0.4 to 0.0.5
  Skip migration: Bump mapping apiVersion from 0.0.5 to 0.0.6
  Skip migration: Bump manifest specVersion from 0.0.1 to 0.0.2
  Skip migration: Bump manifest specVersion from 0.0.2 to 0.0.4
✔ Apply migrations
✔ Load subgraph from subgraph.yaml
  Compile data source: NFTMarket => build/NFTMarket/NFTMarket.wasm
✔ Compile subgraph
  Copy schema file build/schema.graphql
  Write subgraph file build/NFTMarket/abis/NFTMarket.json
  Write subgraph manifest build/subgraph.yaml
✔ Write compiled subgraph to build/
  Add file to IPFS build/schema.graphql
                .. QmbcFZtTRP4M1HL2ccYEWJWWgf3pUbddATr1YZfsFsGFtJ
  Add file to IPFS build/NFTMarket/abis/NFTMarket.json
                .. QmNdh74x1i5W8vxJ9mB3574ei7m32HMbpiAgfiNkdKfYnC
  Add file to IPFS build/NFTMarket/NFTMarket.wasm
                .. QmS9ZKowbSyKdG87qqDLsVq9BKdAY4LAbts5H1yAP3R7r3
✔ Upload subgraph to IPFS

Build completed: QmebNDDAaXBAfo2abeEajWimikjQL63BnXAmh2JyPn6XTr

Deployed to https://thegraph.com/studio/subgraph/nftmarkethub

Subgraph endpoints:
Queries (HTTP):     https://api.studio.thegraph.com/query/83263/nftmarkethub/v0.0.1

```

### 查看 subgraph

<https://subgraphs.alchemy.com/onboarding>

<https://subgraphs.alchemy.com/subgraphs/6888>

![image-20240721114437302](/images/image-20240721114437302.png)

### 查询信息

<https://subgraph.satsuma-prod.com/qiaos-team--238048/nftmarkethub/playground>

![image-20240721114500619](/images/image-20240721114500619.png)

## 总结

The Graph 作为 Web3 数据索引的利器，为 NFT 市场等 dApp 开发提供了高效、去中心化的数据查询方案。本文通过详细的实战教程，带您从安装 Graph CLI 到成功部署 NFT 市场子图，完整掌握子图开发的每一步。无论是配置合约事件、编写映射逻辑，还是解决部署中的常见问题，这篇全攻略都为您提供了清晰指引和实用资源。借助 The Graph 的强大功能，开发者可以轻松构建高效的数据索引，加速 Web3 应用的创新与落地。立即行动，用 The Graph 开启您的 Web3 数据之旅！

## 参考

- <https://subgraphs.alchemy.com/onboarding>
- <https://subgraphs.alchemy.com/subgraphs/6888>

- <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/mocks/EIP712Verifier.sol>
- <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/EIP712.sol>
- <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Permit.sol>
- <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/ERC20Permit.sol>
- <https://eips.ethereum.org/EIPS/eip-712>
- <https://eips.ethereum.org/EIPS/eip-2612>
- <https://www.openzeppelin.com/contracts>
- <https://github.com/AmazingAng/WTF-Solidity/blob/main/37_Signature/readme.md>
- <https://github.com/AmazingAng/WTF-Solidity/blob/main/52_EIP712/readme.md>
- <https://github.com/jesperkristensen58/ERC712-Permit-Example>
- <https://book.getfoundry.sh/tutorials/testing-eip712>
- <https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/interfaces/IERC2612.sol>
- <https://thegraph.com/docs/zh/subgraphs/quick-start/>
