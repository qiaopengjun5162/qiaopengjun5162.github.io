+++
title = "Surfpool：Solana 上的 Anvil，本地开发闪电般⚡️"
description = "Surfpool：Solana 上的 Anvil，本地开发闪电般⚡️"
date = 2025-08-06T13:46:52Z
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# Surfpool：Solana 上的 Anvil，本地开发闪电般⚡️

对于以太坊开发者来说，Anvil 无疑是本地开发调试的利器。现在，Solana 生态也迎来了它的“Anvil”—— Surfpool！还在为搭建复杂的本地测试环境、等待缓慢的交易确认而烦恼吗？Surfpool 提供了一个速度飞快、对开发者极其友好的 Solana 主网模拟环境，它能像变魔术一样立即分叉主网，让你的开发、调试和学习体验提升到一个全新的水平。

Surfpool是Solana的闪电般快速的内存测试网堪比以太坊的Anvil它能即时分叉主网提供一个无需高性能硬件的无缝本地模拟环境并能动态获取主网账户数据极大地简化了开发调试和学习流程让开发者专注于构建

## 什么是 Surfpool

surfpool 之于 Solana 就像 anvil 之于以太坊：一个速度极快的⚡️内存测试网，能够立即分叉 Solana 主网。

Surfpool 提供了一个速度极快、开发者友好的 Solana 主网模拟环境，可在您的本地计算机上无缝运行。它无需高性能硬件，同时保持了真实的测试环境。

无论您是在开发、调试还是学习 Solana，Surfpool 都能为您提供一个即时、独立的网络，可以根据需要动态获取缺失的主网数据 - 无需再手动设置帐户。

### 特点

- 快速且轻量——可在任何机器上顺利运行，无需繁重的系统要求。
- 动态账户获取——在交易执行期间自动检索必要的主网账户。
- Anchor 集成 – 检测 Anchor 项目并自动部署程序。
- 教育和调试友好 - 对交易执行和状态变更提供明确的见解。
- 易于安装 - 可通过Homebrew，Snap和Direct Binaries获得。

## 实操

### 安装 surfpool

```bash
brew install txtx/taps/surfpool
```

更多详情请查看：<https://docs.surfpool.run/install>

### 验证安装

```bash
surfpool --version
surfpool 0.9.6
```

### 查看帮助信息

```bash
surfpool --help
Where you train before surfing Solana

Usage: surfpool <COMMAND>

Commands:
  start        Start Simnet
  completions  Generate shell completions scripts
  run          Run, runbook, run!
  ls           List runbooks present in the current direcoty
  cloud        Txtx cloud commands
  mcp          Start MCP server
  help         Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version

```

### 启动本地 Solana 网络

```bash
surfpool start
```

![image-20250730110116125](/images/image-20250730110116125.png)

#### `surfpool start`解释说明示意图

![surfpool](https://docs.surfpool.run/assets/terminal.svg)

### 部署程序（合约）

```bash
shenqi-box on  master [?] via 🦀 1.88.0 on 🐳 v28.2.2 (orbstack) took 42.4s
➜ make deploy PROGRAM=metaplex_nft CLUSTER=localnet
Verifying program configurations...
All programs verified.
Building all programs: ...
    Finished `release` profile [optimized] target(s) in 0.34s
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.33s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/shenqi-box/target/debug/deps/metaplex_nft-0247b4c2bcc257db)
    Finished `release` profile [optimized] target(s) in 0.12s
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.12s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/Solana/shenqi-box/target/debug/deps/shenqi_box-d4eb7a1fecd4c1d5)
Deploying program [metaplex_nft] to cluster: localnet...
Deploying cluster: http://localhost:8899
Upgrade authority: /Users/qiaopengjun/.config/solana/id.json
Deploying program "metaplex_nft"...
Program path: /Users/qiaopengjun/Code/Solana/shenqi-box/target/deploy/metaplex_nft.so...
Program Id: DZSHuLMpZhofLsUebMrAPPEe5vh6vmtFnLUWmszmcvtL

Signature: 3GMumfjyC4Cv5cZm1xuAFz4qLc7swjetAL6As4DmRC5TiVADhMVEGoKXPMN6NYeAUsfdBFLziNCnE6ktsV65HGzX

Deploy success

```

![image-20250805193314504](/images/image-20250805193314504.png)

> 部署成功后，Surfpool 会返回清晰的日志记录。如图所示，其中的**交易签名**（`3GMum...HGzX`）是此次部署在链上的唯一凭证，让开发者可以轻松追踪和排查问题，整个过程一目了然。

## 总结

总而言之，Surfpool 是一个为 Solana 开发者量身打造的强大工具。它通过提供一个轻量级、速度极快且功能强大的内存测试网，完美解决了传统本地测试环境搭建困难、运行缓慢的痛点。其动态账户获取、与 Anchor 的无缝集成以及清晰的交易洞察等特性，使得无论是开发新应用、调试复杂合约还是学习 Solana 内部机制，都变得前所未有的高效和简单。如果你是一名 Solana 开发者，Surfpool 绝对是你的工具箱中不可或缺的神器。

## 参考

- <https://github.com/txtx/surfpool>
- <https://docs.surfpool.run/>
- <https://docs.surfpool.run/install>
