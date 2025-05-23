+++
title = "Web3 开发实战：用 Foundry 高效探索以太坊区块链"
description = "Web3 开发实战：用 Foundry 高效探索以太坊区块链"
date = 2025-05-20T01:02:28Z
[taxonomies]
categories = ["Web3", "Foundry", "Solidity"]
tags = ["Web3", "Foundry", "Solidity"]
+++

<!-- more -->

# Web3 开发实战：用 Foundry 高效探索以太坊区块链

Web3 时代的到来，让以太坊区块链开发成为开发者关注的热点。Foundry 作为一款强大的 Solidity 开发工具集，凭借其命令行工具 cast，为开发者提供了查询区块链数据、调试交易和分析智能合约的高效途径。本文通过一系列实操案例，带你走进 Web3 开发的实战场景，探索如何用 Foundry 查询以太坊区块、交易详情、事件日志，并进行交易模拟，助力你在 Web3 开发中游刃有余！

本文详细介绍了 Foundry 的 cast 命令在以太坊开发中的多种应用，包括查询最新区块高度、区块详情、交易收据、Gas 单价，以及解析合约调用数据、事件签名和函数选择器等功能。通过具体案例，展示了从环境变量配置到 JSON 数据格式化，再到交易模拟执行的完整流程。文章还介绍了如何通过 cast run 调试交易调用栈，为 Web3 开发者提供实用参考，助力开发高效的去中心化应用。

## 实操

### 查询最新区块号（十六进制）

**通过 `export ETH_RPC_URL` 设置环境变量，让后续的 `cast` 命令自动使用该 RPC 节点，无需重复指定 `--rpc-url`。**

```bash
export ETH_RPC_URL="**************************************************************
echo $ETH_RPC_URL
*************************************************************
cast rpc eth_blockNumber
"0x7f93c9"

cast rpc eth_blockNumber
"0x95075b"
```

### 查询当前以太坊网络的最新区块高度（十进制格式）

```bash
cast block-number
8360917

# cast block-number
cast block-number

21914148
```

### 查询以太坊区块链上指定高度的区块详情

```bash
cast block 8360917


cast block 9766752


baseFeePerGas        7
difficulty           2
extraData            0x010000753003f85c47000c8eaa00000000000000000000000000000000000000c11e60141cf73be3d65bddbb95688e2465691424b881a7cd71c8560c2200d5480f35bcad7d1bd50a0ecac7ba68d7ff26bf6f059fde74dfd159a542faf39edc4600
gasLimit             2000000000
gasUsed              21000
hash                 0x09d4ff5bcf56f63f8fdd6b15b1f33f187ff7b1d9df6ff4bb6e6e294a7830328f
logsBloom            0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
miner                0x0000000000000000000000000000000000000000
mixHash              0x0000000000000000000000000000000000000000000000000000000000000000
nonce                0x0000000000000000
number               9766752
parentHash           0xaff11e9fd37dcc9ff6e3799f307ea81d6ed308e7ef29aa41ca40301ed485e38a
parentBeaconRoot     
transactionsRoot     0x27cecda093398159176bb88196189432b283fa6f75494ed72d6aa4af9e7319a6
receiptsRoot         0x056b23fbba480696b65fe5a59b8f2148a1299103c4f57df839233af2cf4ca2d2
sha3Uncles           0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347
size                 721
stateRoot            0x7e231fb86f75067ee6b5db48d60fb13585461aba09ee7fae9201484a8578f0aa
timestamp            1740373647 (Mon, 24 Feb 2025 05:07:27 +0000)
withdrawalsRoot      
totalDifficulty      19533505
blobGasUsed          
excessBlobGas        
requestsHash         
transactions:        [
 0xa2797bab1ce8307072cff59ac03c3aef8614e0b9df491d253ea3de954df5f913
]
```

### 查询以太坊区块链上指定交易哈希的完整详细信息

```bash
# cast tx
cast tx 0xa2797bab1ce8307072cff59ac03c3aef8614e0b9df491d253ea3de954df5f913

blockHash            0x09d4ff5bcf56f63f8fdd6b15b1f33f187ff7b1d9df6ff4bb6e6e294a7830328f
blockNumber          9766752
from                 0x228466F2C715CbEC05dEAbfAc040ce3619d7CF0B
transactionIndex     0
effectiveGasPrice    1361240798

gas                  21000
gasPrice             1361240798
hash                 0xa2797bab1ce8307072cff59ac03c3aef8614e0b9df491d253ea3de954df5f913
input                0x
nonce                8584261
r                    0x43f3d959986d09dddff767cbfcc4a49641c04494533a78f40385106240de571a
s                    0x0cb55a2d14a186798c5f71432e66d6be8d1b9c3ce7ddb2ab8e30703147bb9850
to                   0x228466F2C715CbEC05dEAbfAc040ce3619d7CF0B
type                 0
v                    1
value                100
```

### 获取指定以太坊交易的 **收据（receipt）信息**

```bash
cast receipt 0xa2797bab1ce8307072cff59ac03c3aef8614e0b9df491d253ea3de954df5f913

blockHash            0x09d4ff5bcf56f63f8fdd6b15b1f33f187ff7b1d9df6ff4bb6e6e294a7830328f
blockNumber          9766752
contractAddress      
cumulativeGasUsed    21000
effectiveGasPrice    1361240798
from                 0x228466F2C715CbEC05dEAbfAc040ce3619d7CF0B
gasUsed              21000
logs                 []
logsBloom            0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
root                 
status               1 (success)
transactionHash      0xa2797bab1ce8307072cff59ac03c3aef8614e0b9df491d253ea3de954df5f913
transactionIndex     0
type                 0
blobGasPrice         
blobGasUsed          
to                   0x228466F2C715CbEC05dEAbfAc040ce3619d7CF0B
```

### 查询特定以太坊交易的 `gasPrice`（Gas 单价）

```bash
cast tx 0xa2797bab1ce8307072cff59ac03c3aef8614e0b9df491d253ea3de954df5f913 gasPrice
1361240798
```

### 查询交易 **实际生效的 Gas 单价（effectiveGasPrice）**

```bash
cast receipt 0xa2797bab1ce8307072cff59ac03c3aef8614e0b9df491d253ea3de954df5f913 effectiveGasPrice
1361240798
```

### 获取交易 `0xa279` 的完整 JSON 格式数据

```bash
cast tx 0xa2797bab1ce8307072cff59ac03c3aef8614e0b9df491d253ea3de954df5f913 --json
{"type":"0x0","chainId":"0xe705","nonce":"0x82fc45","gasPrice":"0x5122e2de","gas":"0x5208","to":"0x228466f2c715cbec05deabfac040ce3619d7cf0b","value":"0x64","input":"0x","r":"0x43f3d959986d09dddff767cbfcc4a49641c04494533a78f40385106240de571a","s":"0xcb55a2d14a186798c5f71432e66d6be8d1b9c3ce7ddb2ab8e30703147bb9850","v":"0x1ce2e","hash":"0xa2797bab1ce8307072cff59ac03c3aef8614e0b9df491d253ea3de954df5f913","blockHash":"0x09d4ff5bcf56f63f8fdd6b15b1f33f187ff7b1d9df6ff4bb6e6e294a7830328f","blockNumber":"0x950760","transactionIndex":"0x0","from":"0x228466f2c715cbec05deabfac040ce3619d7cf0b"}
```

### 获取交易 `0x847e` 的完整 JSON 数据并使用 `jq` 格式化输出

```bash
cast tx 0x847ec42998f5b0fb603ff909b9c9dc575d6876a89c8f30ce9343ce8062d76e88 --json | jq
{
  "type": "0x2",
  "chainId": "0x1",
  "nonce": "0x51177",
  "gas": "0x3bd5a",
  "maxFeePerGas": "0x24ca2ff8",
  "maxPriorityFeePerGas": "0x1d3ed",
  "to": "0x68d3a973e7272eb388022a5c6518d9b2a2e66fbf",
  "value": "0x14e6235",
  "accessList": [],
  "input": "0xa00000000000000000000000000000006ac6b053a2858bea8ad758db680198c16e523184000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040ba76f00000000000000000000000000000000000000000000000cbf18a462d9f5c1d1000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48",
  "r": "0x7046b9d4144e7e031f14d1cf48e624ca082a647a1dff2a4b138946c5bf604813",
  "s": "0xe6de3584212a453feab79484cf04c4e7737b128c351e97febdfea7f28b91278",
  "yParity": "0x0",
  "v": "0x0",
  "hash": "0x847ec42998f5b0fb603ff909b9c9dc575d6876a89c8f30ce9343ce8062d76e88",
  "blockHash": "0xa742ebfe24abfe4b611a6d3152a15c7fd6e3eb5dbd85bf91d90ddc9579e17954",
  "blockNumber": "0x14e6235",
  "transactionIndex": "0xa5",
  "from": "0x448166a91e7bc50d0ac720c2fbed29e0963f5af8",
  "gasPrice": "0x24ca2ff8"
}
```

### 获取交易 `0x847e` 的 **input 数据**（即合约调用的原始 ABI 编码数据）

```bash
cast tx 0x847ec42998f5b0fb603ff909b9c9dc575d6876a89c8f30ce9343ce8062d76e88 input
0xa00000000000000000000000000000006ac6b053a2858bea8ad758db680198c16e523184000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040ba76f00000000000000000000000000000000000000000000000cbf18a462d9f5c1d1000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48
```

### 解析并美化显示给定的 calldata

```bash
cast pretty-calldata 0xa9059cbb0000000000000000000000005494befe3ce72a2ca0001fe0ed0c55b42f8c358f000000000000000000000000000000000000000000000000000000000836d54c

 Possible methods:
 - transfer(address,uint256)
 ------------
 [000]: 0000000000000000000000005494befe3ce72a2ca0001fe0ed0c55b42f8c358f
 [020]: 000000000000000000000000000000000000000000000000000000000836d54c
```

### 解码给定的 calldata

```bash
cast 4byte-decode 0xa9059cbb0000000000000000000000005494befe3ce72a2ca0001fe0ed0c55b42f8c358f000000000000000000000000000000000000000000000000000000000836d54c
1) "transfer(address,uint256)"
0x5494befe3CE72A2CA0001fE0Ed0C55B42F8c358f
137811276 [1.378e8]
```

### 计算 `transferFrom(address,address,uint256)` 函数的 Keccak-256 哈希（即函数选择器）

```bash
cast keccak 'transferFrom(address,address,uint256)'
0x23b872dd7302113369cda2901243429419bec145408fa8b352b3dd92b66c680b
```

### 获取 `transferFrom(address,address,uint256)` 函数的 **4字节函数选择器**（function selector）

```bash
cast sig "transferFrom(address,address,uint256)"
0x23b872dd
```

### 查询交易 `0x2258` 的收据信息

```bash
cast receipt 0x225853c513c75a4276979841a480ad1856bc649c496c16765107cb5d62d1def7

blockHash            0x3da09c83e6beee5b50540a0fd330a1b3c5f7528bc8f5be43ef1c7fd6df6851fa
blockNumber          21915751
contractAddress      
cumulativeGasUsed    6566577
effectiveGasPrice    2679745233
from                 0x28C6c06298d514Db089934071355E5743bf21d60
gasUsed              62272
logs                 [{"address":"0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48","topics":["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef","0x00000000000000000000000028c6c06298d514db089934071355e5743bf21d60","0x000000000000000000000000c1af05a7a4f27cd1b61de823ea31ab5049b38ea8"],"data":"0x0000000000000000000000000000000000000000000000000000000de5eaacc5","blockHash":"0x3da09c83e6beee5b50540a0fd330a1b3c5f7528bc8f5be43ef1c7fd6df6851fa","blockNumber":"0x14e6867","blockTimestamp":"0x67bc518f","transactionHash":"0x225853c513c75a4276979841a480ad1856bc649c496c16765107cb5d62d1def7","transactionIndex":"0x15","logIndex":"0xc3","removed":false}]
logsBloom            0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000800000000000000a000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000010000000000000000000000000000000000000000000000000010008000000000000000000000000000000200000000000000000000000000000000000000000020000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
root                 
status               1 (success)
transactionHash      0x225853c513c75a4276979841a480ad1856bc649c496c16765107cb5d62d1def7
transactionIndex     21
type                 2
blobGasPrice         
blobGasUsed          
to                   0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
```

### 获取交易 `0x2258` 的事件日志（logs）

```bash
cast receipt 0x225853c513c75a4276979841a480ad1856bc649c496c16765107cb5d62d1def7 logs
[
 
 address: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
 blockHash: 0x3da09c83e6beee5b50540a0fd330a1b3c5f7528bc8f5be43ef1c7fd6df6851fa
 blockNumber: 21915751
 data: 0x0000000000000000000000000000000000000000000000000000000de5eaacc5
 logIndex: 195
 removed: false
 topics: [
  0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
  0x00000000000000000000000028c6c06298d514db089934071355e5743bf21d60
  0x000000000000000000000000c1af05a7a4f27cd1b61de823ea31ab5049b38ea8
 ]
 transactionHash: 0x225853c513c75a4276979841a480ad1856bc649c496c16765107cb5d62d1def7
 transactionIndex: 21
]
```

### 解码事件签名哈希

```bash
# cast 4byte-event
cast 4byte-event 0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef
Transfer(address,address,uint256)
```

### **调试/模拟执行**交易

```bash
# Run 调用栈 blocksec tenderly
cast run 0x225853c513c75a4276979841a480ad1856bc649c496c16765107cb5d62d1def7
Executing previous transactions from the block.
Traces:
  [40652] 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48::transfer(0xc1AF05a7A4F27Cd1b61De823EA31aB5049b38eA8, 59691936965 [5.969e10])
    ├─ [33363] 0x43506849D7C04F9138D1A2050bbF3A0c054402dd::transfer(0xc1AF05a7A4F27Cd1b61De823EA31aB5049b38eA8, 59691936965 [5.969e10]) [delegatecall]
    │   ├─ emit Transfer(param0: 0x28C6c06298d514Db089934071355E5743bf21d60, param1: 0xc1AF05a7A4F27Cd1b61De823EA31aB5049b38eA8, param2: 59691936965 [5.969e10])
    │   └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000000000000001
    └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000000000000001


Transaction successfully executed.
Gas used: 62272
```

## 总结

Foundry 的 cast 命令为 Web3 开发者提供了从查询到调试的全面工具支持，显著提升了以太坊区块链开发的效率。本文通过实战案例展示了其在区块查询、交易分析和事件日志解析中的实用功能，为开发者深入理解智能合约提供了清晰指引。在 Web3 开发的大潮中，掌握 Foundry 将助你事半功倍。快来结合参考资源动手实践，开启你的 Web3 开发新篇章！

## 参考

- <https://www.youtube.com/watch?v=EXYeltwvftw&t=212s>
- <https://soliditylang.org/>
- <https://solidity-by-example.org/>
- <https://docs.soliditylang.org/en/latest/>
- <https://book.getfoundry.sh/>
