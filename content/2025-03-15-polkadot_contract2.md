+++
title = "探索 Polkadot 上的智能合约开发：从 Solidity 到部署实战"
description = "探索 Polkadot 上的智能合约开发：从 Solidity 到部署实战"
date = 2025-03-15 17:21:21+08:00
[taxonomies]
categories = ["Web3", "Polkadot", "Solidity"]
tags = ["Web3", "Polkadot", "Solidity"]
+++

<!-- more -->

# 探索 Polkadot 上的智能合约开发：从 Solidity 到部署实战

随着区块链技术的不断演进，Polkadot 作为一个跨链生态系统，为开发者提供了多样化的智能合约开发选择。本文将深入探讨 Polkadot 上基于 Solidity 的智能合约开发，剖析其与 EVM（以太坊虚拟机）的关系，介绍 Polkadot 虚拟机的语言支持，并通过实际操作展示如何利用 Remix 和 Westend 网络快速部署和调用智能合约。无论您是区块链新手还是经验丰富的开发者，本文都将为您提供清晰的指引和实践经验。

本文聚焦于 Polkadot 上的智能合约开发，介绍了 Solidity 与 EVM 的关联及其在 Polkadot 生态中的应用。文章指出，尽管 Polkadot 虚拟机无法直接执行 EVM bytecode，但它支持多种语言，包括 Solidity、Rust 和 Python 等。此外，通过 Westend 测试网的 faucet 获取 token，并结合 Remix 和 MetaMask，本文演示了智能合约的部署与调用流程，包括具体步骤、交易记录和合约地址。丰富的参考资料为进一步学习提供了支持。本文旨在帮助开发者快速上手 Polkadot 智能合约开发。

## Polkadot 上的智能合约

📖 区块链技术开发｜Polkadot 上的 Solidity 开发

- Solidity 和 EVM 的关系是编程语言和执行的虚拟机
- 波卡支持Solidity
- 合约的 bytecode 不可修改
- 波卡虚拟机不可以执行 EVM 的 bytecode
- 波卡虚拟机可以支持哪些语言？Solidity、Rust、Python...

## 领水

从 faucet 获取token。Only request once per day.

<https://faucet.polkadot.io/westend?parachain=1000>

![image-20250314145806139](/images/image-20250314145806139.png)

成功领水

![image-20250314145654079](/images/image-20250314145654079.png)

<https://westend.subscan.io/extrinsic/0x214627520f7476740bfd972d7a5cc2867dc64fd6a344ddd23ece425f7c9b7f81>

## 合约 快速上手：Remix + Polkadot

### 熟悉 polkadot remix 和与 metamask 的连接

![image-20250314152035177](/images/image-20250314152035177.png)

### 将存储智能合约部署到Westend hub，触发合约交易

![image-20250314152411101](/images/image-20250314152411101.png)

### 调用合约方法

![image-20250314152508453](/images/image-20250314152508453.png)

合约地址：0x4c44f1ec443f1379f85ab53081a98ed135e54103

<https://assethub-westend.subscan.io/account/0x4c44f1ec443f1379f85ab53081a98ed135e54103>

![image-20250314153636420](/images/image-20250314153636420.png)

## 总结

Polkadot 作为一个灵活的区块链平台，为智能合约开发提供了广阔的空间。尽管其虚拟机与 EVM bytecode 不直接兼容，但通过支持 Solidity 等语言，开发者依然可以在 Polkadot 生态中构建强大的去中心化应用。本文通过实际案例展示了如何在 Westend 网络上部署和调用智能合约，结合 Remix 和 Subscan 等工具，整个过程简单高效。对于希望深入 Polkadot 开发的开发者来说，这是一个值得尝试的起点。未来，随着 Polkadot 生态的扩展，更多创新工具和技术将进一步丰富其智能合约开发体验。

## 参考

- <https://ethereum.github.io/yellowpaper/paper.pdf>
- <https://github.com/polkadot-evm/frontier>
- <https://github.com/moonbeam-foundation/frontier>
- <https://github.com/paritytech/>
- <https://github.com/paritytech/polkadot-sdk/tree/master/substrate/frame/revive>
- <https://github.com/paritytech/polkavm>
- <https://github.com/paritytech/revive>
- <https://contracts.polkadot.io/tutorial/try>
- <https://faucet.polkadot.io/>
- <https://remix.polkadot.io/>
- <https://assethub-westend.subscan.io/extrinsic>
- <https://assethub-westend.subscan.io/>
