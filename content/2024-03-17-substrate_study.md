+++
title = "Substrate 区块链开发之本地网络启动"
date = 2024-03-17T10:38:21+08:00
[taxonomies]
tags = ["Substrate"]
categories = ["Substrate"]
+++

# Substrate 区块链开发之本地网络启动

## What is Substrate?

Substrate 是一个软件开发工具包 (SDK)，它使用基于 Rust 的库和工具，使您能够从模块化和可扩展的组件构建特定于应用程序的区块链。使用 Substrate 构建的特定于应用程序的区块链可以作为独立服务运行，也可以与其他链并行运行，以利用 Polkadot 生态系统提供的共享安全性。Substrate 包含区块链基础设施核心组件的默认实现，让您能够专注于应用程序逻辑。

## 安装

- <https://docs.substrate.io/install/macos/>

## 本地网络启动实操

- <https://docs.substrate.io/tutorials/build-a-blockchain/build-local-blockchain/>
- <https://github.com/substrate-developer-hub/substrate-node-template>

1. 克隆仓库

```bash
git clone git@github.com:substrate-developer-hub/substrate-node-template.git
```

2. 切换目录

```bash
cd substrate-node-template
```

3. 创建一个新分支

```bash
git switch -c my-learning-branch-2024-03-16
```

4. 编译

```bash
cargo build --release
```

![image-20240317132227730](/images/image-20240317132227730.png)

1. 启动本地 Substrate 节点

```bash
./target/release/node-template --dev --tmp
```

![image-20240317132601014](/images/image-20240317132601014.png)

1. 启动第一个区块链节点 `alice`

```bash
./target/release/node-template --chain local --alice --tmp
```

![image-20240317132921988](/images/image-20240317132921988.png)

1. 启动第二个区块链节点 `bob`

```bash
./target/release/node-template --chain local --bob --tmp
```

![image-20240317133119154](/images/image-20240317133119154.png)

1. 将链规范转换为原始格式 Convert the chain specification to raw format

- <https://docs.substrate.io/tutorials/build-a-blockchain/add-trusted-nodes/>

```bash
./target/release/node-template build-spec --chain=local --raw > spec.json
```

9. 读取`spec.json`文件的内容，搜索包含“boot”的行，并显示这些行以及它们前后各两行的内容

```bash
cat spec.json | grep boot -C 2
```

![image-20240317133833261](/images/image-20240317133833261.png)

1. 启动第二个区块链节点，此命令包含`--bootnodes`选项并指定单个引导节点，即由 启动的节点`alice`

```bash
./target/release/node-template --chain local --bob --tmp --bootnodes /ip4/127.0.0.1/tcp/30333/p2p/12D3KooWBGJ3YcEgqt2BjFmWDv2fkqWPkKrDreWiGyreA7z72UnW
```

![image-20240317134112277](/images/image-20240317134112277.png)

1. polkadot.js. 查看

- <https://polkadot.js.org/apps/#/explorer>

![image-20240317135302695](/images/image-20240317135302695.png)

1. polkadot.js 查看出块信息

![image-20240317135434959](/images/image-20240317135434959.png)

1. 交易之前查询

![image-20240317140040289](/images/image-20240317140040289.png)

14. 交易

![image-20240317140349593](/images/image-20240317140349593.png)

15. 提交交易

![image-20240317140445595](/images/image-20240317140445595.png)

1. 交易之后

![image-20240317140659491](/images/image-20240317140659491.png)

1. 查询交易后的值

![image-20240317140813312](/images/image-20240317140813312.png)
