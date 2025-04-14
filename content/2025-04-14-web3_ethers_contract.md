+++
title = "Web3 开发入门：用 Ethers.js 玩转以太坊交易与合约"
description = "Web3 开发入门：用 Ethers.js 玩转以太坊交易与合约"
date = 2025-04-14 10:59:17+08:00
[taxonomies]
categories = ["Web3", "Ethers.js", "以太坊"]
tags = ["Web3", "Ethers.js", "以太坊"]
+++

<!-- more -->

# Web3 开发入门：用 Ethers.js 玩转以太坊交易与合约

Web3 浪潮席卷而来，以太坊作为去中心化世界的核心，吸引了无数开发者跃跃欲试。想快速上手 Web3 开发，却不知从何开始？别担心！本文通过一个简单的 Ethers.js 示例，带你从零开始，手把手教你如何连接以太坊节点、发送交易、部署智能合约，轻松玩转 Web3 开发。无论你是新手还是有一定基础的开发者，这篇教程都将是你迈向 Web3 世界的第一步！

本文通过一个清晰的 TypeScript 示例，展示了如何使用 Ethers.js 实现 Web3 开发的基础操作：连接本地以太坊节点、查询账户信息、发送 0.1 ETH 交易、部署一个简单的 Storage 智能合约，并通过合约的 store 和 retrieve 方法读写数据。代码逐步解析，运行结果一目了然，还附带完整合约代码。零基础也能快速上手，助你轻松开启以太坊交易与合约开发的 Web3 之旅！

## 实操

```ts
import { Contract, ethers, Wallet } from 'ethers';

import config from '../config';
import { ABI, BYTECODE } from "../abi/storage";

console.log(config.localRpcUrl); // Outputs: localhost

async function main() {
    const provider = new ethers.JsonRpcProvider(config.localRpcUrl);
    const blockNumber = await provider.getBlockNumber();
    console.log(`blockNumber: ${blockNumber}`);
    // const wallet = new ethers.Wallet(config.privateKey, provider);
    const wallet = new Wallet(config.privateKey, provider);
    const walletAddress = await wallet.getAddress();
    console.log("wallet address: ", wallet.address);
    console.log("wallet address: ", walletAddress);
    const balance = await provider.getBalance(walletAddress);
    console.log("balance: ", balance.toString());
    const nonce = await provider.getTransactionCount(walletAddress);
    console.log("nonce: ", nonce);
    const tx = await wallet.sendTransaction({
        to: config.accountAddress2,
        value: ethers.parseEther('0.1'),
        nonce: nonce,
    })
    await tx.wait();
    const txHash = tx.hash;
    console.log("tx hash: ", txHash);
    const txReceipt = await provider.getTransactionReceipt(txHash);
    console.log("tx receipt: ", txReceipt);


    const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet);
    const contract = await factory.deploy()
    await contract.waitForDeployment();
    const contractAddress1 = await contract.getAddress();
    console.log("contract address1: ", contractAddress1);
    const contractAddress = contract.target.toString();
    console.log("contract address: ", contractAddress);

    const deployedContract = new Contract(contractAddress, ABI, provider)
    const retrieve = await deployedContract.retrieve()
    console.log("retrieve: ", retrieve.toString());

    const walletContract = new Contract(contractAddress, ABI, wallet)
    const storeTx = await walletContract.store(100);
    await storeTx.wait();
    const retrieve2 = await deployedContract.retrieve()
    console.log("retrieve2: ", retrieve2.toString());

    const receipt = await provider.getTransactionReceipt(storeTx.hash)
    const data = receipt?.fee ? ethers.formatEther(receipt.fee) : "0"

    console.log(`result is ${data} `)

}

main().catch((error) => {
    console.error("Error:", error);
    process.exit(1);
});

```

这段代码是一个使用 ethers.js 库与以太坊区块链交互的脚本，主要功能包括连接本地节点、查询账户信息、发送交易、部署智能合约以及与合约交互。以下是对代码的逐步解释：

------

**1. 导入模块和配置**

```javascript
import { Contract, ethers, Wallet } from 'ethers';
import config from '../config';
import { ABI, BYTECODE } from "../abi/storage";
```

- **ethers**: 以太坊 JavaScript 库，用于与以太坊网络交互。
- **Contract**: 用于创建和与智能合约交互的类。
- **Wallet**: 用于管理私钥和签名交易的类。
- **config**: 从外部文件导入配置（如本地 RPC 地址、私钥等）。
- **ABI, BYTECODE**: 智能合约的接口（ABI）和编译后的字节码（BYTECODE），从 ../abi/storage 导入。
- `console.log(config.localRpcUrl);`: 输出本地节点的 RPC URL（localhost），确认配置。

------

**2. 主函数 main**

```javascript
async function main() {
    const provider = new ethers.JsonRpcProvider(config.localRpcUrl);
```

- 创建一个 JSON-RPC 提供者，连接到本地以太坊节点（如 Ganache 或 Hardhat）。
- config.localRpcUrl 是本地节点的地址（如 <http://127.0.0.1:8545）。>

------

**3. 查询区块链信息**

```javascript
const blockNumber = await provider.getBlockNumber();
console.log(`blockNumber: ${blockNumber}`);
```

- 调用 getBlockNumber 获取当前区块链的最新区块高度，并打印。

------

**4. 创建钱包**

```javascript
const wallet = new Wallet(config.privateKey, provider);
const walletAddress = await wallet.getAddress();
console.log("wallet address: ", wallet.address);
console.log("wallet address: ", walletAddress);
```

- 使用 config.privateKey（私钥）和 provider 创建一个 Wallet 实例，用于签名交易。
- wallet.getAddress() 获取钱包的公钥地址。
- 打印 wallet.address 和 walletAddress，两者是等价的（wallet.address 是属性，getAddress 是方法）。

------

**5. 查询账户余额和 nonce**

```javascript
const balance = await provider.getBalance(walletAddress);
console.log("balance: ", balance.toString());
const nonce = await provider.getTransactionCount(walletAddress);
console.log("nonce: ", nonce);
```

- getBalance(walletAddress): 查询钱包地址的余额（以 wei 为单位）。
- balance.toString(): 将余额转换为字符串输出（避免 BigInt 格式问题）。
- getTransactionCount(walletAddress): 获取钱包的 nonce（交易计数，用于确保交易顺序）。

------

**6. 发送交易**

```javascript
const tx = await wallet.sendTransaction({
    to: config.accountAddress2,
    value: ethers.parseEther('0.1'),
    nonce: nonce,
});
await tx.wait();
const txHash = tx.hash;
console.log("tx hash: ", txHash);
const txReceipt = await provider.getTransactionReceipt(txHash);
console.log("tx receipt: ", txReceipt);
```

- sendTransaction: 发送一笔交易，将 0.1 ETH（通过 ethers.parseEther 转换为 wei）转账到 config.accountAddress2。
- nonce: 使用之前查询的 nonce，确保交易顺序正确。
- tx.wait(): 等待交易被确认（写入区块链）。
- tx.hash: 获取交易哈希。
- getTransactionReceipt(txHash): 获取交易的收据，包含交易的状态、Gas 使用情况等信息。

------

**7. 部署智能合约**

```javascript
const factory = new ethers.ContractFactory(ABI, BYTECODE, wallet);
const contract = await factory.deploy();
await contract.waitForDeployment();
const contractAddress1 = await contract.getAddress();
console.log("contract address1: ", contractAddress1);
const contractAddress = contract.target.toString();
console.log("contract address: ", contractAddress);
```

- ContractFactory: 使用合约的 ABI、字节码和钱包创建工厂实例，用于部署合约。
- factory.deploy(): 部署智能合约（调用构造函数，如果有参数需传入）。
- waitForDeployment(): 等待合约部署完成。
- contract.getAddress() 和 contract.target: 获取部署后的合约地址（两者等价，target 是新版 ethers 的属性）。
- 打印合约地址。

------

**8. 与合约交互（读取数据）**

```javascript
const deployedContract = new Contract(contractAddress, ABI, provider);
const retrieve = await deployedContract.retrieve();
console.log("retrieve: ", retrieve.toString());
```

- 创建一个 Contract 实例，连接到已部署的合约地址，使用 ABI 和 provider（只读模式）。
- 调用合约的 retrieve 方法（假设是 storage 合约的读取函数，返回存储的值）。
- retrieve.toString(): 将返回值转换为字符串输出。

------

**9. 与合约交互（写入数据）**

```javascript
const walletContract = new Contract(contractAddress, ABI, wallet);
const storeTx = await walletContract.store(100);
await storeTx.wait();
const retrieve2 = await deployedContract.retrieve();
console.log("retrieve2: ", retrieve2.toString());
```

- 创建另一个 Contract 实例，使用 wallet（可签名，允许写入操作）。
- 调用合约的 store 方法，传入参数 100（假设是将值存储到合约的状态变量）。
- storeTx.wait(): 等待交易确认。
- 再次调用 retrieve 方法，读取更新后的值并打印。

------

**10. 获取交易收据和费用**

```javascript
const receipt = await provider.getTransactionReceipt(storeTx.hash);
const data = receipt?.fee ? ethers.formatEther(receipt.fee) : "0";
console.log(`result is ${data}`);
```

- 获取 store 交易的收据。
- 检查 receipt.fee（交易费用，EIP-1559 引入的字段），若存在则转换为 ETH 单位（formatEther），否则返回 "0"。
- 打印交易费用。

------

**11. 错误处理**

```javascript
main().catch((error) => {
    console.error("Error:", error);
    process.exit(1);
});
```

- 使用 try-catch 捕获 main 函数中的错误，打印错误信息并退出程序（退出码 1 表示异常）。

------

**代码功能总结**

1. **连接本地节点**: 通过 ethers.JsonRpcProvider 连接到本地以太坊节点。
2. **查询链上信息**: 获取区块高度、账户余额和 nonce。
3. **发送交易**: 向指定地址转账 0.1 ETH。
4. **部署合约**: 部署一个智能合约。
5. **合约交互**:
   - 读取合约的初始状态（retrieve）。
   - 更新合约状态（store(100)）。
   - 再次读取确认更新。
6. **交易费用**: 获取并格式化交易的 Gas 费用。

### 运行

```bash
➜ ts-node src/ethers/index.ts                                          
http://127.0.0.1:8545
blockNumber: 0
wallet address:  0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
wallet address:  0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
balance:  10000000000000000000000
nonce:  0
tx hash:  0x1f4b6e1c13d6374c8fabce903e1b3cc947d75be53a8c49b555a63e21b2388d16
tx receipt:  TransactionReceipt {
  provider: JsonRpcProvider {},
  to: '0x70997970C51812dc3A010C7d01b50e0d17dc79C8',
  from: '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266',
  contractAddress: null,
  hash: '0x1f4b6e1c13d6374c8fabce903e1b3cc947d75be53a8c49b555a63e21b2388d16',
  index: 0,
  blockHash: '0x4de33f22cea97627a9d2a75ef53502ef7103ec0400a5ba41a8d5fa396c34dc5a',
  blockNumber: 1,
  logsBloom: '0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',
  gasUsed: 21000n,
  blobGasUsed: null,
  cumulativeGasUsed: 21000n,
  gasPrice: 2000000000n,
  blobGasPrice: 1n,
  type: 2,
  status: 1,
  root: undefined
}
contract address1:  0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
contract address:  0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
retrieve:  0
retrieve2:  100
result is 0.000077235507093088 
```

### 合约代码

```ts
// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Storage {
    uint256 number;

    /**
     * @dev Store value in variable
     * @param num value to store
     */
    function store(uint256 num) public {
        number = num;
    }

    /**
     * @dev Return value
     * @return value of 'number'
     */
    function retrieve() public view returns (uint256) {
        return number;
    }
}

```

## 总结

通过这个 Ethers.js 实战教程，你已经掌握了 Web3 开发的核心技能：从连接以太坊节点到发送交易，再到部署和交互智能合约，每一步都简单明了。Storage 合约的案例展示了区块链状态管理的魅力，而 Ethers.js 的强大功能让开发变得高效又有趣。不管你是想打造自己的 DApp，还是探索 Web3 的无限可能，这个教程都是你迈向去中心化世界的坚实起点。快动手试试，下一位 Web3 大牛就是你！

## 参考

- <https://www.typescriptlang.org/>
- <https://etherscan.io/>
- <https://typestrong.org/ts-node/docs/installation/>
- <https://docs.ethers.org/v6/>
- <https://web3js.readthedocs.io/en/v1.10.0/>
