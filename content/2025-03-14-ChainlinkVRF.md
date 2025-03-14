+++
title = "Web3 抽奖指南：用 Chainlink VRF 选出 100 Token 幸运儿"
description = "Web3 抽奖指南：用 Chainlink VRF 选出 100 Token 幸运儿"
date = 2025-03-14 16:07:33+08:00
[taxonomies]
categories = ["Web3", "Chainlink", "Solidity", "Contract"]
tags = ["Web3", "Chainlink", "Solidity", "Contract"]
+++

<!-- more -->

# Web3 抽奖指南：用 Chainlink VRF 选出 100 Token 幸运儿

利用[Chainlink VRF](https://docs.chain.link/vrf#overview) 实现100 Token抽奖：从名单中随机选出幸运得主的完整指南

在区块链应用中，公平和不可预测的随机性是实现透明抽奖和激励机制的关键。Chainlink VRF（可验证随机函数）为智能合约提供了一个可验证且公正的随机数生成方案，使得合约能够在不牺牲安全性的前提下进行随机值的生成和验证。

本文将展示如何利用 Chainlink VRF 实现一个简单的抽奖合约，该合约从预设的抽奖名单中随机选出一名幸运地址，并为其颁发100 Token。我们将详细介绍 Chainlink VRF 的工作原理、相关函数和实现步骤。

## Chainlink VRF概述

**Chainlink VRF (Verifiable Random Function)** is a provably fair and verifiable random number generator (RNG) that enables smart contracts to access random values without compromising security or usability. For each request, Chainlink VRF generates one or more random values and cryptographic proof of how those values were determined. The proof is published and verified onchain before any consuming applications can use it. This process ensures that results cannot be tampered with or manipulated by any single entity including oracle operators, miners, users, or smart contract developers.

Chainlink VRF（可验证随机函数）是一种可证明公平且可验证的随机数生成器（RNG），它使智能合约能够在不影响安全性或可用性的情况下访问随机值。对于每个请求， Chainlink VRF 生成一个或多个随机值以及如何确定这些值的加密证明。在任何 consumer 应用程序可以使用该证明之前，该证明将在链上发布和验证。此过程确保结果不会被任何单个实体篡改或操纵，包括预言机运营商、矿工、用户或智能合约开发者。

使用Chainlink VRF来建立可靠的智能合约，用于任何依赖不可预测结果的应用：

- 建立区块链游戏和NFT。
- 随机分配职责和资源。例如，随机分配法官到案件。
- 为共识机制选择一个具有代表性的样本。

## [Two methods to request randomness](https://docs.chain.link/vrf#two-methods-to-request-randomness)

Similarly to VRF v2, VRF v2.5 will offer two methods for requesting randomness:

- [Subscription](https://docs.chain.link/vrf/v2-5/overview/subscription): Create a subscription account and fund its balance with either native tokens or LINK. You can then connect multiple consuming contracts to the subscription account. When the consuming contracts request randomness, the transaction costs are calculated after the randomness requests are fulfilled and the subscription balance is deducted accordingly. This method allows you to fund requests for multiple consumer contracts from a single subscription.
- [Direct funding](https://docs.chain.link/vrf/v2-5/overview/direct-funding): Consuming contracts directly pay with either native tokens or LINK when they request random values. You must directly fund your consumer contracts and ensure that there are enough funds to pay for randomness requests.

### 参考

- <https://docs.chain.link/vrf>
- <https://docs.chain.link/vrf/v2-5/overview/subscription>
- <https://docs.chain.link/vrf/v2-5/overview/direct-funding>
- <https://docs.chain.link/vrf#two-methods-to-request-randomness>

**Chainlink VRF (Verifiable Random Function)** 。生成的随机数是密码学中的伪随机数。

产品具有以下特点：

- 解决了智能合约获取不可操纵的随机数的问题
- 针对每个请求，可生成1或多个随机数以及这些随机数的相关证明
- 以上证明会上链，这将确保生成的随机数无法被矿工、Oracle 运营商或者Dapp 合约的 owner 操纵

证明的作用：在数学上可证明得到的随机数是不可预测的

### VRF 中重要的函数

- 公私钥生成函数：G(r) -> (PrivateKey, PublicKey)
- 随机数生成函数：G(PrivateKey, Seed) -> (RondomNumber, Proof)
- 验证函数：V(Proof, RondomNumber, PrivateKey, Seed) -> (bool)

## 工作流程

![subscription-architecture-diagram](https://docs.chain.link/images/vrf/v2-5/subscription-architecture-diagram.png)

- 预言机节点网络中，每个节点都生成一个公私钥对
- 需求方使用合约发送VRF 请求
- 预言机节点监听网络的 event，发现请求后生成随机数及证明
- 进行回调
- VRF Coordinator  合约（Chainlink部署）可以通过以上证明验证以上生成的随机数是否合法
- 会生成两笔gas 费用， 第一笔请求时支付， 第二笔通过预存余额来支付

## 与其他随机数生成方案比较

### 传统的链上随机数生成方案

```ts
uint private _counter = 0;

function getRandomWithTen() external returns (uint) {
 ++_counter;
 return uint(keccak256(abi.encode(
  blockhash(1),
  gasleft(),
  block.number,
  _counter
  ))) % 10;
}
```

#### 存在哪些问题？

- 易受矿工操控。

- 随机性依赖于可预测的区块链参数。

### 传统的链下随机数生成方案

大家信任一个地址，这个地址可以是一个合约，也可以是一个EOA地址。信誉保证我取得的每一个随机数都是链下取得真实的随机数。取到之后每隔半个小时、每隔十分钟发送到链上，如有需要直接去读取链上某个合约的地址即可。也可以多个人发送取平均值等等

#### 存在的问题

如果三个地址都是一个人发送

依赖可信源生成随机数并定期将其发布到链上。

多个源由单一实体控制时可能会出现问题。

## 基于 Chainlink [VRF](https://docs.chain.link/vrf/v2-5/best-practices#overview)  实现抽奖合约

<https://docs.chain.link/vrf/v2-5/best-practices#overview>

我们将展示如何基于 Chainlink VRF 构建一个简单的抽奖合约。该合约将从提供的抽奖名单中随机选择一名地址，并奖励其100 Token。

### 安装 chainlink

```bash
forge install smartcontractkit/chainlink --no-commit
```

### `QiaoToken` 合约代码

```ts
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";

contract QiaoToken is ERC20, ERC20Permit, VRFConsumerBaseV2Plus {
    uint256 private constant ROLL_IN_PROGRESS = 42;
    address[] list;
    uint256 s_subscriptionId;
    address vrfCoordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 s_keyHash = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint32 callbackGasLimit = 2_500_000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    mapping(uint256 => address) private s_rollers;
    mapping(address => uint256) private s_results;

    // events
    event DiceRolled(uint256 indexed requestId, address indexed roller);
    event DiceLanded(uint256 indexed requestId, uint256 indexed result);

    constructor(uint256 subscriptionId)
        ERC20("QiaoToken", "QTK")
        ERC20Permit("QiaoToken")
        VRFConsumerBaseV2Plus(vrfCoordinator)
    {
        s_subscriptionId = subscriptionId;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // rollDice function
    function rollDice(address roller, address[] memory newLists) public onlyOwner returns (uint256 requestId) {
        require(s_results[roller] == 0, "Already rolled");
        // Will revert if subscription is not set and funded.
        list = newLists;

        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );

        s_rollers[requestId] = roller;
        s_results[roller] = ROLL_IN_PROGRESS;
        emit DiceRolled(requestId, roller);
    }

    // fulfillRandomWords function
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        uint256 random = randomWords[0] % list.length;
        _mint(list[random], 100 * 10 ** decimals());
        // assign the transformed value to the address in the s_results mapping variable
        s_results[s_rollers[requestId]] = random;

        // emitting event to signal that dice landed
        emit DiceLanded(requestId, random);
    }
}

```

这段Solidity代码实现了一个名为QiaoToken的ERC20代币合约，它继承了OpenZeppelin的ERC20、ERC20Permit和VRFConsumerBaseV2Plus合约。这个合约的主要功能是允许合约所有者铸造代币，并允许用户掷骰子来获得代币。

1. 导入所需的库和接口：
   - ERC20.sol：实现ERC20标准。
   - Ownable.sol：实现合约所有权的管理。
   - ERC20Permit.sol：实现ERC20Permit标准，用于简化ERC20代币的权限管理。
   - VRFConsumerBaseV2Plus.sol：实现Chainlink VRF（可验证随机函数）的消费者合约。
   - VRFV2PlusClient.sol：实现Chainlink VRF的客户端库。
   - IVRFCoordinatorV2Plus.sol：实现Chainlink VRF的协调器接口。

2. 定义合约及构造函数：
   - QiaoToken：定义合约名为QiaoToken，代币符号为QTK。
   - constructor(uint256 subscriptionId)：构造函数，接收一个uint256类型的参数subscriptionId。

3. 定义合约的变量：
   - list：定义一个地址数组，用于存储掷骰子的用户地址。
   - s_subscriptionId：定义一个uint256类型的变量，用于存储VRF订阅ID。
   - vrfCoordinator：定义一个地址类型的变量，用于存储VRF协调器的地址。
   - s_keyHash：定义一个bytes32类型的变量，用于存储VRF的keyHash。
   - callbackGasLimit：定义一个uint32类型的变量，用于存储VRF回调的gas限制。
   - requestConfirmations：定义一个uint16类型的变量，用于存储VRF请求的确认次数。
   - numWords：定义一个uint32类型的变量，用于存储VRF请求的单词数量。
   - s_rollers：定义一个mapping，用于存储掷骰子的用户地址和请求ID的映射关系。
   - s_results：定义一个mapping，用于存储掷骰子的用户地址和结果的映射关系。

4. 定义合约的事件：
   - DiceRolled：定义一个事件，用于记录掷骰子的请求ID和用户地址。
   - DiceLanded：定义一个事件，用于记录掷骰子的结果。

5. 实现合约的方法：
   - mint(address to, uint256 amount)：实现ERC20标准的mint方法，用于合约所有者铸造代币。
   - rollDice(address roller, address[] memory newLists)：实现掷骰子的方法，接收一个用户地址和一个地址数组作为参数。
   - fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords)：实现Chainlink VRF的回调方法，用于处理掷骰子的结果。

注意：这个合约使用了Chainlink VRF服务来生成随机数，需要预先设置VRF订阅并支付相应的费用。

## Chainlink [VRF](https://docs.chain.link/vrf/v2-5/best-practices#overview) 订阅实操

### 第一步：查看网络配置

<https://docs.chain.link/vrf/v2-5/supported-networks#sepolia-testnet>

![image-20240810093729349](/images/image-20240810093729349.png)

### 第二步：打开 Chainlink Verifiable Randomness Function 网站

<https://vrf.chain.link/sepolia>

![image-20240810093823694](/images/image-20240810093823694.png)

### 第三步：Create subscription

![image-20240810093851321](/images/image-20240810093851321.png)

### 第四步：Receive confirmation

![image-20240810093948152](/images/image-20240810093948152.png)

### 第五步：Sign message

![image-20240810094040952](/images/image-20240810094040952.png)

### 第六步：Subscription created

![image-20240810094204451](/images/image-20240810094204451.png)

### 第七步：Add 10 LINK  funds

![image-20240810094234558](/images/image-20240810094234558.png)

### 第八步：Receive add funds confirmation

![image-20240810094329132](/images/image-20240810094329132.png)

### 第九步：Funds added

![image-20240810094508581](/images/image-20240810094508581.png)

### 第十步：点击 Add consumers

![image-20240810094644195](/images/image-20240810094644195.png)

### 第十一步：部署 Consumer address

#### 部署脚本

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {QiaoToken} from "../src/QiaoToken.sol";

contract QiaoTokenScript is Script {
    QiaoToken public qiaotoken;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 subscriptionId = vm.envUint("SUBSCRIPTION_ID");
        vm.startBroadcast(deployerPrivateKey);

        qiaotoken = new QiaoToken(subscriptionId);
        console.log("QiaoToken deployed to:", address(qiaotoken));

        vm.stopBroadcast();
    }
}

```

#### 部署实操

```bash
DynamicNFT on  main [!+?] via 🅒 base 
➜ source .env     

DynamicNFT on  main [!+?] via 🅒 base 
➜ forge script --chain sepolia QiaoTokenScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv  

[⠊] Compiling...
[⠒] Compiling 2 files with Solc 0.8.20
[⠑] Solc 0.8.20 finished in 1.50s
Compiler run successful!
Traces:
  [1555073] QiaoTokenScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::envUint("SUBSCRIPTION_ID") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return] 
    ├─ [1508576] → new QiaoToken@0xC668D79A54694C4AA212dE50178A7c3b265b6373
    │   └─ ← [Return] 6638 bytes of code
    ├─ [0] console::log("QiaoToken deployed to:", QiaoToken: [0xC668D79A54694C4AA212dE50178A7c3b265b6373]) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    └─ ← [Stop] 


Script ran successfully.

== Logs ==
  QiaoToken deployed to: 0xC668D79A54694C4AA212dE50178A7c3b265b6373

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [1508576] → new QiaoToken@0xC668D79A54694C4AA212dE50178A7c3b265b6373
    └─ ← [Return] 6638 bytes of code


==========================

Chain 11155111

Estimated gas price: 4.309264446 gwei

Estimated total gas used for script: 2195060

Estimated amount required: 0.00945909401483676 ETH

==========================

##### sepolia
✅  [Success]Hash: 0x9e67b83b715dfac3d2a2a7f550e643656e580744b06a5a6fc6aa049093c909a0
Contract Address: 0xC668D79A54694C4AA212dE50178A7c3b265b6373
Block: 6470414
Paid: 0.004397538979531588 ETH (1689028 gas * 2.603591521 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.004397538979531588 ETH (1689028 gas * avg 2.603591521 gwei)
                                                                                                                    

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (1) contracts
Start verifying contract `0xC668D79A54694C4AA212dE50178A7c3b265b6373` deployed on sepolia

Submitting verification for [src/QiaoToken.sol:QiaoToken] 0xC668D79A54694C4AA212dE50178A7c3b265b6373.
Submitted contract for verification:
        Response: `OK`
        GUID: `7waicaa49l6cgbaa91qp76itveixtvnfarsnegnztweig9u554`
        URL: https://sepolia.etherscan.io/address/0xc668d79a54694c4aa212de50178a7c3b265b6373
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (1) contracts were verified!

Transactions saved to: /Users/qiaopengjun/Code/solidity-code/DynamicNFT/broadcast/QiaoToken.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/solidity-code/DynamicNFT/cache/QiaoToken.s.sol/11155111/run-latest.json


DynamicNFT on  main [!+?] via 🅒 base took 1m 1.4s 
➜ 
```

#### 部署成功

<https://sepolia.etherscan.io/address/0xc668d79a54694c4aa212de50178a7c3b265b6373#code>

![image-20240810100049112](/images/image-20240810100049112.png)

### 第十二步：Add consumers

![image-20240810100131888](/images/image-20240810100131888.png)

### 第十三步：Consumer added

![image-20240810100330747](/images/image-20240810100330747.png)

### 第十四步：查看交易详情

<https://sepolia.etherscan.io/tx/0xbfb07f08edb17ce6a79a49d162b9ea4217c8f2458c29bbd318c3f2bdefe5bd45>

![image-20240810100252053](/images/image-20240810100252053.png)

### 第十五步：View subscription

<https://vrf.chain.link/sepolia/20706299126585294390866835777988499780843478407105517934508556694810173553544>

![image-20240810100607095](/images/image-20240810100607095.png)

### 第十六步：在浏览器中调用 rollDice 方法

newLists 为三个地址

<https://sepolia.etherscan.io/address/0xc668d79a54694c4aa212de50178a7c3b265b6373#writeContract>

![image-20240810101434667](/images/image-20240810101434667.png)

### 第十七步：查看 Transaction Details

<https://sepolia.etherscan.io/tx/0x6ced5cf21944ed315c5a06c4c34c4429452949977de72ef15e80eb93da844b1a>

![image-20240810101647243](/images/image-20240810101647243.png)

### 第十八步：查看 Chainlink Recent fulfillments 可以看到状态是成功的

<https://vrf.chain.link/sepolia/20706299126585294390866835777988499780843478407105517934508556694810173553544>

![image-20240810101907411](/images/image-20240810101907411.png)

### 第十九步： 查看 Transaction Details 可以看到向随机地址 F27 的 Mint 了 100 个 Token

<https://sepolia.etherscan.io/tx/0xebf4f77bb14e11c61d82a4c3cfc6d957415ee785574e6a9a9cb5c75b2d32ab88>

![image-20240810102252538](/images/image-20240810102252538.png)

### 第二十步：import Token

![image-20240810102107509](/images/image-20240810102107509.png)

### 第二十一步：MetaMask 查看 Token

![image-20240810102148330](/images/image-20240810102148330.png)

### 第二十二步：查看日志 DiceLanded 事件，可以看到完成 vrf 的链上请求及回调响应

<https://sepolia.etherscan.io/tx/0xebf4f77bb14e11c61d82a4c3cfc6d957415ee785574e6a9a9cb5c75b2d32ab88#eventlog>

![image-20240810103004218](/images/image-20240810103004218.png)

### 第二十三步：查看余额

![image-20240810103206696](/images/image-20240810103206696.png)

#### 注意：生产中需要及时查看余额，如果余额不足需要及时添加，否则会影响请求，结果会失败

## 参考

- <https://medium.com/coinmonks/building-randomness-with-chainlink-vrf-1e3990e05193>
- <https://github.com/SupaMega24/fantasy-team-vrf/blob/main/src/RandomTeamSelector.sol>
- <https://vrf.chain.link/arbitrum-sepolia>
- <https://github.com/smartcontractkit/chainlink>
