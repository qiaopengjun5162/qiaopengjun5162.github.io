+++
title = "Uniswap V2 合约部署全攻略：Web3 实践指南"
description = "Uniswap V2 合约部署全攻略：Web3 实践指南"
date = 2025-06-26T00:35:39Z
[taxonomies]
categories = ["Web3", "DeFi", "Uniswap"]
tags = ["Web3", "DeFi", "Uniswap"]
+++

<!-- more -->

# Uniswap V2 合约部署全攻略：Web3 实践指南

去中心化金融（DeFi）浪潮席卷全球，Uniswap V2 作为顶尖的自动化做市商（AMM）协议，是 Web3 开发的必学核心。本教程基于 Solidity 0.8.30，带你一步步在 Hoodi 测试网部署 Uniswap V2 核心合约（Factory、Router02、WETH9 等）及自定义代币，并实现流动性添加。无论你是区块链新手还是资深开发者，本文提供清晰的实操步骤和源码，助你快速上手 DeFi 合约开发，开启 Web3 创新之旅！

本教程详细指导如何基于 Solidity 0.8.30 在 Hoodi 测试网部署 Uniswap V2 核心合约（Factory、Router02、WETH9 等）及 AToken、BToken，涵盖合约编译、部署、验证及流动性添加全流程。所有步骤均经过实操验证，配有完整源码（GitHub: <https://github.com/qiaopengjun5162/Uniswap-v2-08），助你快速掌握> DeFi 合约开发。适合 Web3 开发者实践，轻松构建去中心化交易所！

## 实操

### 前提准备

- 路由合约(**UniswapV2Router02**)：<https://etherscan.io/address/0x7a250d5630b4cf539739df2c5dacb4c659f2488d#code>
- WETH9 合约：<https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code>
- 工厂合约(**UniswapV2Factory**)：<https://etherscan.io/address/0x5c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f#code>

### 编译合约

```bash
Uniswap-v2-08 on  main [?] on 🐳 v28.2.2 (orbstack) 
➜ forge build
[⠒] Compiling...
[⠒] Compiling 87 files with Solc 0.8.30
[⠒] Solc 0.8.30 finished in 11.92s
Compiler run successful!
```

### 第一步：部署 UniswapV2Factory 合约

```bash
Uniswap-v2-08 on  main [✘!?] on 🐳 v28.2.2 (orbstack) took 11.5s 
➜ forge build                                                                              
[⠒] Compiling...
No files changed, compilation skipped

Uniswap-v2-08 on  main [✘!?] on 🐳 v28.2.2 (orbstack) 
➜ source .env                                                                              

Uniswap-v2-08 on  main [✘!?] on 🐳 v28.2.2 (orbstack) 
➜ forge script UniswapV2FactoryScript --rpc-url $HOODI_RPC_URL --broadcast --verify -vvvvv 
[⠒] Compiling...
No files changed, compilation skipped
Traces:
  [132] UniswapV2FactoryScript::setUp()
    └─ ← [Stop]

  [2130098] UniswapV2FactoryScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5
    ├─ [0] console::log("Deploying contracts with the account:", 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [2078726] → new UniswapV2Factory@0x79D86a83bFe89eC1dc5F65021f8F66A50Cc443CC
    │   └─ ← [Return] 10271 bytes of code
    ├─ [0] console::log("UniswapV2Factory deployed to:") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log(UniswapV2Factory: [0x79D86a83bFe89eC1dc5F65021f8F66A50Cc443CC]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::toString(0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5) [staticcall]
    │   └─ ← [Return] "0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5"
    ├─ [0] VM::toString(UniswapV2Factory: [0x79D86a83bFe89eC1dc5F65021f8F66A50Cc443CC]) [staticcall]
    │   └─ ← [Return] "0x79D86a83bFe89eC1dc5F65021f8F66A50Cc443CC"
    ├─ [0] VM::writeJson("{\"deployerAddress\": \"0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5\", \"uniswapv2factory\": \"0x79D86a83bFe89eC1dc5F65021f8F66A50Cc443CC\"}", "deployed_addresses.json")
    │   └─ ← [Return]
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Return]


Script ran successfully.

== Logs ==
  Deploying contracts with the account: 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5
  UniswapV2Factory deployed to:
  0x79D86a83bFe89eC1dc5F65021f8F66A50Cc443CC

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [2078726] → new UniswapV2Factory@0x79D86a83bFe89eC1dc5F65021f8F66A50Cc443CC
    └─ ← [Return] 10271 bytes of code


==========================

Chain 560048

Estimated gas price: 1.896721648 gwei

Estimated total gas used for script: 2987623

Estimated amount required: 0.005666689220162704 ETH

==========================

##### hoodi
✅  [Success] Hash: 0x4dc741cbbce957709ca3e19da0369440eeb1ba1290156535575da00677fff723
Contract Address: 0x79D86a83bFe89eC1dc5F65021f8F66A50Cc443CC
Block: 586921
Paid: 0.002541952143867928 ETH (2298172 gas * 1.106075674 gwei)

✅ Sequence #1 on hoodi | Total Paid: 0.002541952143867928 ETH (2298172 gas * avg 1.106075674 gwei)
                                                                                                                                         

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (1) contracts
Start verifying contract `0x79D86a83bFe89eC1dc5F65021f8F66A50Cc443CC` deployed on hoodi
EVM version: cancun
Compiler version: 0.8.30
Optimizations:    200
Constructor args: 000000000000000000000000e91e2df7ce50bca5310b7238f6b1dfcd15566be5

Submitting verification for [src/UniswapV2Factory.sol:UniswapV2Factory] 0x79D86a83bFe89eC1dc5F65021f8F66A50Cc443CC.
Submitted contract for verification:
        Response: `OK`
        GUID: `uiqh5lvi61sd2jqc7iq3swuivgwdj3j4pmjyyz35nmkdgc4vva`
        URL: https://hoodi.etherscan.io/address/0x79d86a83bfe89ec1dc5f65021f8f66a50cc443cc
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Warning: Verification is still pending...; waiting 15 seconds before trying again (7 tries remaining)
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (1) contracts were verified!

Transactions saved to: /Users/qiaopengjun/Code/Solidity/Uniswap-v2-08/broadcast/UniswapV2Factory.s.sol/560048/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/Solidity/Uniswap-v2-08/cache/UniswapV2Factory.s.sol/560048/run-latest.json
```

**UniswapV2Factory 合约地址：0x79D86a83bFe89eC1dc5F65021f8F66A50Cc443CC**

<https://hoodi.etherscan.io/address/0x79d86a83bfe89ec1dc5f65021f8f66a50cc443cc>

### 第二步：部署 WETH 合约

```bash
Uniswap-v2-08 on  main [✘!?] on 🐳 v28.2.2 (orbstack) took 10.8s 
➜ mkdir -p ./deployments

Uniswap-v2-08 on  main [✘!?] on 🐳 v28.2.2 (orbstack) 
➜ forge build           
[⠒] Compiling...
No files changed, compilation skipped

Uniswap-v2-08 on  main [✘!?] on 🐳 v28.2.2 (orbstack) 
➜ source .env           

Uniswap-v2-08 on  main [✘!?] on 🐳 v28.2.2 (orbstack) 
➜ forge script WETH9Script --rpc-url $HOODI_RPC_URL --broadcast --verify -vvvvv            
[⠒] Compiling...
No files changed, compilation skipped
Traces:
  [132] WETH9Script::setUp()
    └─ ← [Stop]

  [507780] WETH9Script::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5
    ├─ [0] console::log("Deploying contracts with the account:", 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [458671] → new WETH9@0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17
    │   └─ ← [Return] 1958 bytes of code
    ├─ [0] console::log("WETH9 deployed to:") [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log(WETH9: [0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::toString(0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5) [staticcall]
    │   └─ ← [Return] "0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5"
    ├─ [0] VM::toString(WETH9: [0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17]) [staticcall]
    │   └─ ← [Return] "0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17"
    ├─ [0] VM::writeJson("{\"deployerAddress\": \"0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5\", \"WETH9\": \"0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17\"}", "./deployments/WETH9.json")
    │   └─ ← [Return]
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Return]


Script ran successfully.

== Logs ==
  Deploying contracts with the account: 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5
  WETH9 deployed to:
  0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [458671] → new WETH9@0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17
    └─ ← [Return] 1958 bytes of code


==========================

Chain 560048

Estimated gas price: 1.807610766 gwei

Estimated total gas used for script: 711925

Estimated amount required: 0.00128688329458455 ETH

==========================

##### hoodi
✅  [Success] Hash: 0x9550621e7c393f9aace08ff55bbf350729cd8093937c7f883ab7fc5090601ca6
Contract Address: 0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17
Block: 587169
Paid: 0.00057881956577445 ETH (547635 gas * 1.05694407 gwei)

✅ Sequence #1 on hoodi | Total Paid: 0.00057881956577445 ETH (547635 gas * avg 1.05694407 gwei)
                                                                                                                                         

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (1) contracts
Start verifying contract `0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17` deployed on hoodi
EVM version: cancun
Compiler version: 0.8.30
Optimizations:    200

Submitting verification for [src/WETH9.sol:WETH9] 0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (4 tries remaining)

Submitting verification for [src/WETH9.sol:WETH9] 0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (3 tries remaining)

Submitting verification for [src/WETH9.sol:WETH9] 0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17.
Submitted contract for verification:
        Response: `OK`
        GUID: `ihurcwptizd4fatmqmexdbngsfnp44sn394vl3lxgxqjkdjcq3`
        URL: https://hoodi.etherscan.io/address/0x55ab36d5ba138478445d31d4d1a316e5d3662f17
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Warning: Verification is still pending...; waiting 15 seconds before trying again (7 tries remaining)
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Warning: Verification is still pending...; waiting 15 seconds before trying again (6 tries remaining)
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (1) contracts were verified!

Transactions saved to: /Users/qiaopengjun/Code/Solidity/Uniswap-v2-08/broadcast/WETH9.s.sol/560048/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/Solidity/Uniswap-v2-08/cache/WETH9.s.sol/560048/run-latest.json

```

**WETH 合约地址：0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17**

<https://hoodi.etherscan.io/address/0x55ab36d5ba138478445d31d4d1a316e5d3662f17#code>

### 第三步：部署 UniswapV2Router02 合约

```bash
Uniswap-v2-08 on  main [✘!?] on 🐳 v28.2.2 (orbstack) took 3.0s 
➜ forge build 
[⠒] Compiling...
No files changed, compilation skipped

Uniswap-v2-08 on  main [✘!?] on 🐳 v28.2.2 (orbstack) 
➜ source .env

Uniswap-v2-08 on  main [✘!?] on 🐳 v28.2.2 (orbstack) 
➜ forge script UniswapV2Router02Script --rpc-url $HOODI_RPC_URL --broadcast --verify -vvvvv        
[⠒] Compiling...
No files changed, compilation skipped
Traces:
  [132] UniswapV2Router02Script::setUp()
    └─ ← [Stop]

  [4317533] UniswapV2Router02Script::run()
    ├─ [0] VM::envAddress("UNISWAPV2FACTORY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::envAddress("WETH9") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5
    ├─ [0] console::log("Deploying contracts with the account:", 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [4259571] → new UniswapV2Router02@0x9aB453917cfaEee2B9020537703D30B14f0FDfBa
    │   └─ ← [Return] 21269 bytes of code
    ├─ [0] console::log("UniswapV2Router02 deployed to: ", UniswapV2Router02: [0x9aB453917cfaEee2B9020537703D30B14f0FDfBa]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] console::log(UniswapV2Router02: [0x9aB453917cfaEee2B9020537703D30B14f0FDfBa]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::toString(0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5) [staticcall]
    │   └─ ← [Return] "0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5"
    ├─ [0] VM::toString(UniswapV2Router02: [0x9aB453917cfaEee2B9020537703D30B14f0FDfBa]) [staticcall]
    │   └─ ← [Return] "0x9aB453917cfaEee2B9020537703D30B14f0FDfBa"
    ├─ [0] VM::toString(0x79D86a83bFe89eC1dc5F65021f8F66A50Cc443CC) [staticcall]
    │   └─ ← [Return] "0x79D86a83bFe89eC1dc5F65021f8F66A50Cc443CC"
    ├─ [0] VM::toString(0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17) [staticcall]
    │   └─ ← [Return] "0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17"
    ├─ [0] VM::writeJson("{\"deployerAddress\": \"0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5\", \"UniswapV2Router02\": \"0x9aB453917cfaEee2B9020537703D30B14f0FDfBa\", \"UniswapV2Factory\": \"0x79D86a83bFe89eC1dc5F65021f8F66A50Cc443CC\", \"WETH9\": \"0x55Ab36d5Ba138478445D31D4d1A316E5D3662F17\"}", "./deployments/UniswapV2Router02.json")
    │   └─ ← [Return]
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Return]


Script ran successfully.

== Logs ==
  Deploying contracts with the account: 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5
  UniswapV2Router02 deployed to:  0x9aB453917cfaEee2B9020537703D30B14f0FDfBa
  0x9aB453917cfaEee2B9020537703D30B14f0FDfBa

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [4259571] → new UniswapV2Router02@0x9aB453917cfaEee2B9020537703D30B14f0FDfBa
    └─ ← [Return] 21269 bytes of code


==========================

Chain 560048

Estimated gas price: 1.954785257 gwei

Estimated total gas used for script: 6041694

Estimated amount required: 0.011810214358505358 ETH

==========================

##### hoodi
✅  [Success] Hash: 0x932e42cc2f7e8d3ac913c1f2b0742a4e7462da7705c4c08bfcc75e2da2dc890b
Contract Address: 0x9aB453917cfaEee2B9020537703D30B14f0FDfBa
Block: 587280
Paid: 0.005271399471257286 ETH (4647457 gas * 1.134254598 gwei)

✅ Sequence #1 on hoodi | Total Paid: 0.005271399471257286 ETH (4647457 gas * avg 1.134254598 gwei)
                                                                                                                                                                           

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (1) contracts
Start verifying contract `0x9aB453917cfaEee2B9020537703D30B14f0FDfBa` deployed on hoodi
EVM version: cancun
Compiler version: 0.8.30
Optimizations:    200
Constructor args: 00000000000000000000000079d86a83bfe89ec1dc5f65021f8f66a50cc443cc00000000000000000000000055ab36d5ba138478445d31d4d1a316e5d3662f17

Submitting verification for [src/UniswapV2Router02.sol:UniswapV2Router02] 0x9aB453917cfaEee2B9020537703D30B14f0FDfBa.
Submitted contract for verification:
        Response: `OK`
        GUID: `bxgxe8jezxazpf8p17vxbn1ghfk3wfwlr2tkyxwwcx4pph8bcv`
        URL: https://hoodi.etherscan.io/address/0x9ab453917cfaeee2b9020537703d30b14f0fdfba
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Warning: Verification is still pending...; waiting 15 seconds before trying again (7 tries remaining)
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (1) contracts were verified!

Transactions saved to: /Users/qiaopengjun/Code/Solidity/Uniswap-v2-08/broadcast/UniswapV2Router02.s.sol/560048/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/Solidity/Uniswap-v2-08/cache/UniswapV2Router02.s.sol/560048/run-latest.json

```

**UniswapV2Router02 合约地址：0x9aB453917cfaEee2B9020537703D30B14f0FDfBa**

<https://hoodi.etherscan.io/address/0x9ab453917cfaeee2b9020537703d30b14f0fdfba#code>

### 第四步：部署 Multicall 合约

```bash
Uniswap-v2-08 on  main [!] on 🐳 v28.2.2 (orbstack) took 6.1s 
➜ forge build                                                 
[⠒] Compiling...
[⠃] Compiling 3 files with Solc 0.8.30
[⠊] Solc 0.8.30 finished in 743.59ms
Compiler run successful!

Uniswap-v2-08 on  main [!?] on 🐳 v28.2.2 (orbstack) 
➜ source .env       

Uniswap-v2-08 on  main [!?] on 🐳 v28.2.2 (orbstack) 
➜ forge script MulticallScript --rpc-url $HOODI_RPC_URL --broadcast --verify -vvvvv        
[⠒] Compiling...
No files changed, compilation skipped
Traces:
  [132] MulticallScript::setUp()
    └─ ← [Stop]

  [285769] MulticallScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5
    ├─ [0] console::log("Deploying contracts with the account:", 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [237082] → new Multicall@0x40a973af60308BEd36964D554A5c644173bc3CbA
    │   └─ ← [Return] 1184 bytes of code
    ├─ [0] console::log("Multicall deployed to:", Multicall: [0x40a973af60308BEd36964D554A5c644173bc3CbA]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::toString(0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5) [staticcall]
    │   └─ ← [Return] "0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5"
    ├─ [0] VM::toString(Multicall: [0x40a973af60308BEd36964D554A5c644173bc3CbA]) [staticcall]
    │   └─ ← [Return] "0x40a973af60308BEd36964D554A5c644173bc3CbA"
    ├─ [0] VM::writeJson("{\"deployerAddress\": \"0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5\", \"Multicall\": \"0x40a973af60308BEd36964D554A5c644173bc3CbA\"}", "./deployments/Multicall.json")
    │   └─ ← [Return]
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Return]


Script ran successfully.

== Logs ==
  Deploying contracts with the account: 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5
  Multicall deployed to: 0x40a973af60308BEd36964D554A5c644173bc3CbA

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [237082] → new Multicall@0x40a973af60308BEd36964D554A5c644173bc3CbA
    └─ ← [Return] 1184 bytes of code


==========================

Chain 560048

Estimated gas price: 2.231091742 gwei

Estimated total gas used for script: 401811

Estimated amount required: 0.000896477203944762 ETH

==========================

##### hoodi
✅  [Success] Hash: 0x0f9bc647032f267e3c54ab2ae154e509bc6054bf2986388ad4d8ca9c4fe3d33a
Contract Address: 0x40a973af60308BEd36964D554A5c644173bc3CbA
Block: 626316
Paid: 0.000349097648801688 ETH (309086 gas * 1.129451508 gwei)

✅ Sequence #1 on hoodi | Total Paid: 0.000349097648801688 ETH (309086 gas * avg 1.129451508 gwei)
                                                                                                                                              

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (1) contracts
Start verifying contract `0x40a973af60308BEd36964D554A5c644173bc3CbA` deployed on hoodi
EVM version: cancun
Compiler version: 0.8.30
Optimizations:    200

Submitting verification for [src/Multicall.sol:Multicall] 0x40a973af60308BEd36964D554A5c644173bc3CbA.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (4 tries remaining)

Submitting verification for [src/Multicall.sol:Multicall] 0x40a973af60308BEd36964D554A5c644173bc3CbA.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (3 tries remaining)

Submitting verification for [src/Multicall.sol:Multicall] 0x40a973af60308BEd36964D554A5c644173bc3CbA.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (2 tries remaining)

Submitting verification for [src/Multicall.sol:Multicall] 0x40a973af60308BEd36964D554A5c644173bc3CbA.
Submitted contract for verification:
        Response: `OK`
        GUID: `ytfkfh78ub4tjl1csntxnu3b93gqjyyfk3fudh8s4ni7r6r6fb`
        URL: https://hoodi.etherscan.io/address/0x40a973af60308bed36964d554a5c644173bc3cba
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Warning: Verification is still pending...; waiting 15 seconds before trying again (7 tries remaining)
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (1) contracts were verified!

Transactions saved to: /Users/qiaopengjun/Code/Solidity/Uniswap-v2-08/broadcast/Multicall.s.sol/560048/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/Solidity/Uniswap-v2-08/cache/Multicall.s.sol/560048/run-latest.json

```

<https://hoodi.etherscan.io/address/0x40a973af60308bed36964d554a5c644173bc3cba>

<https://hoodi.etherscan.io/address/0x40a973af60308bed36964d554a5c644173bc3cba#code>

**Multicall 合约地址：0x40a973af60308BEd36964D554A5c644173bc3CbA**

### 第五步：部署 AToken 合约

```bash
Uniswap-v2-08 on  main [!?] on 🐳 v28.2.2 (orbstack) took 10.2s 
➜ forge build
[⠒] Compiling...
No files changed, compilation skipped

Uniswap-v2-08 on  main [!?] on 🐳 v28.2.2 (orbstack) 
➜ source .env

Uniswap-v2-08 on  main [!?] on 🐳 v28.2.2 (orbstack) 
➜ forge script ATokenScript --rpc-url $HOODI_RPC_URL --broadcast --verify -vvvvv                   
[⠒] Compiling...
No files changed, compilation skipped
Traces:
  [132] ATokenScript::setUp()
    └─ ← [Stop]

  [1152221] ATokenScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5
    ├─ [0] console::log("Deploying contracts with the account:", 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [1101942] → new AToken@0x5371f1c3410971A4551EbC9F04Fa0210eBCcF620
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5)
    │   └─ ← [Return] 5153 bytes of code
    ├─ [0] console::log("AToken deployed to:", AToken: [0x5371f1c3410971A4551EbC9F04Fa0210eBCcF620]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::toString(0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5) [staticcall]
    │   └─ ← [Return] "0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5"
    ├─ [0] VM::toString(AToken: [0x5371f1c3410971A4551EbC9F04Fa0210eBCcF620]) [staticcall]
    │   └─ ← [Return] "0x5371f1c3410971A4551EbC9F04Fa0210eBCcF620"
    ├─ [0] VM::writeJson("{\"deployerAddress\": \"0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5\", \"AToken\": \"0x5371f1c3410971A4551EbC9F04Fa0210eBCcF620\"}", "./deployments/AToken.json")
    │   └─ ← [Return]
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Return]


Script ran successfully.

== Logs ==
  Deploying contracts with the account: 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5
  AToken deployed to: 0x5371f1c3410971A4551EbC9F04Fa0210eBCcF620

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [1101942] → new AToken@0x5371f1c3410971A4551EbC9F04Fa0210eBCcF620
    ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5)
    └─ ← [Return] 5153 bytes of code


==========================

Chain 560048

Estimated gas price: 1.903985052 gwei

Estimated total gas used for script: 1646221

Estimated amount required: 0.003134380176288492 ETH

==========================

##### hoodi
✅  [Success] Hash: 0x4516ac0c913dcf4a008a4806adfc0887f397a7e2164387aa69c34669f4b01c5b
Contract Address: 0x5371f1c3410971A4551EbC9F04Fa0210eBCcF620
Block: 593259
Paid: 0.001398408954341412 ETH (1266324 gas * 1.104305813 gwei)

✅ Sequence #1 on hoodi | Total Paid: 0.001398408954341412 ETH (1266324 gas * avg 1.104305813 gwei)
                                                                                                                                                                           

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (1) contracts
Start verifying contract `0x5371f1c3410971A4551EbC9F04Fa0210eBCcF620` deployed on hoodi
EVM version: cancun
Compiler version: 0.8.30
Optimizations:    200
Constructor args: 000000000000000000000000e91e2df7ce50bca5310b7238f6b1dfcd15566be5

Submitting verification for [src/AToken.sol:AToken] 0x5371f1c3410971A4551EbC9F04Fa0210eBCcF620.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (4 tries remaining)

Submitting verification for [src/AToken.sol:AToken] 0x5371f1c3410971A4551EbC9F04Fa0210eBCcF620.
Warning: Could not detect the deployment.; waiting 5 seconds before trying again (3 tries remaining)

Submitting verification for [src/AToken.sol:AToken] 0x5371f1c3410971A4551EbC9F04Fa0210eBCcF620.
Submitted contract for verification:
        Response: `OK`
        GUID: `tv1qdrzmphul1ftp9qdx2ievw3vufekvshvtsnw6byfaqnwhaf`
        URL: https://hoodi.etherscan.io/address/0x5371f1c3410971a4551ebc9f04fa0210ebccf620
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Warning: Verification is still pending...; waiting 15 seconds before trying again (7 tries remaining)
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (1) contracts were verified!

Transactions saved to: /Users/qiaopengjun/Code/Solidity/Uniswap-v2-08/broadcast/AToken.s.sol/560048/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/Solidity/Uniswap-v2-08/cache/AToken.s.sol/560048/run-latest.json

```

<https://hoodi.etherscan.io/address/0x5371f1c3410971a4551ebc9f04fa0210ebccf620#code>

**AToken 合约地址：0x5371f1c3410971A4551EbC9F04Fa0210eBCcF620**

### 第六步：部署 BToken 合约

```bash
Uniswap-v2-08 on  main [!?] on 🐳 v28.2.2 (orbstack) took 58.7s 
➜ forge build                                                                           
[⠒] Compiling...
No files changed, compilation skipped

Uniswap-v2-08 on  main [!?] on 🐳 v28.2.2 (orbstack) 
➜ source .env                                                                           

Uniswap-v2-08 on  main [!?] on 🐳 v28.2.2 (orbstack) 
➜ forge script BTokenScript --rpc-url $HOODI_RPC_URL --broadcast --verify -vvvvv        
[⠒] Compiling...
No files changed, compilation skipped
Traces:
  [132] BTokenScript::setUp()
    └─ ← [Stop]

  [1152221] BTokenScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5
    ├─ [0] console::log("Deploying contracts with the account:", 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return]
    ├─ [1101942] → new BToken@0x7AD0921D80CeFC98889a84B960c74866A452Cc2A
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5)
    │   └─ ← [Return] 5153 bytes of code
    ├─ [0] console::log("BToken deployed to:", BToken: [0x7AD0921D80CeFC98889a84B960c74866A452Cc2A]) [staticcall]
    │   └─ ← [Stop]
    ├─ [0] VM::toString(0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5) [staticcall]
    │   └─ ← [Return] "0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5"
    ├─ [0] VM::toString(BToken: [0x7AD0921D80CeFC98889a84B960c74866A452Cc2A]) [staticcall]
    │   └─ ← [Return] "0x7AD0921D80CeFC98889a84B960c74866A452Cc2A"
    ├─ [0] VM::writeJson("{\"deployerAddress\": \"0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5\", \"BToken\": \"0x7AD0921D80CeFC98889a84B960c74866A452Cc2A\"}", "./deployments/BToken.json")
    │   └─ ← [Return]
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return]
    └─ ← [Return]


Script ran successfully.

== Logs ==
  Deploying contracts with the account: 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5
  BToken deployed to: 0x7AD0921D80CeFC98889a84B960c74866A452Cc2A

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [1101942] → new BToken@0x7AD0921D80CeFC98889a84B960c74866A452Cc2A
    ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0xE91e2DF7cE50BCA5310b7238F6B1Dfcd15566bE5)
    └─ ← [Return] 5153 bytes of code


==========================

Chain 560048

Estimated gas price: 2.046896987 gwei

Estimated total gas used for script: 1646221

Estimated amount required: 0.003369644804836127 ETH

==========================

##### hoodi
✅  [Success] Hash: 0x4fa2c222d775fc257ec948aa043c533a11bc15320337287d31abf1af75c5a1e8
Contract Address: 0x7AD0921D80CeFC98889a84B960c74866A452Cc2A
Block: 593309
Paid: 0.001443162207066036 ETH (1266324 gas * 1.139646889 gwei)

✅ Sequence #1 on hoodi | Total Paid: 0.001443162207066036 ETH (1266324 gas * avg 1.139646889 gwei)
                                                                                                                                                                           

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (1) contracts
Start verifying contract `0x7AD0921D80CeFC98889a84B960c74866A452Cc2A` deployed on hoodi
EVM version: cancun
Compiler version: 0.8.30
Optimizations:    200
Constructor args: 000000000000000000000000e91e2df7ce50bca5310b7238f6b1dfcd15566be5

Submitting verification for [src/BToken.sol:BToken] 0x7AD0921D80CeFC98889a84B960c74866A452Cc2A.
Submitted contract for verification:
        Response: `OK`
        GUID: `iuipdbhwuam6ykxxtikzxmtyk3d4fz7ejzkrn3ujcntnj6svds`
        URL: https://hoodi.etherscan.io/address/0x7ad0921d80cefc98889a84b960c74866a452cc2a
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Warning: Verification is still pending...; waiting 15 seconds before trying again (7 tries remaining)
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (1) contracts were verified!

Transactions saved to: /Users/qiaopengjun/Code/Solidity/Uniswap-v2-08/broadcast/BToken.s.sol/560048/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/Solidity/Uniswap-v2-08/cache/BToken.s.sol/560048/run-latest.json

```

<https://hoodi.etherscan.io/address/0x7ad0921d80cefc98889a84b960c74866a452cc2a#code>

**BToken 合约地址：0x7AD0921D80CeFC98889a84B960c74866A452Cc2A**

### 第七步：添加流动性

#### 一、approve

AToken : <https://hoodi.etherscan.io/tx/0xd303f1ed4441fea65dc978edaf505c7b4c58354f8ee7fd28f9c4d47bebcc4753>

BToken: <https://hoodi.etherscan.io/tx/0x883ca598e6541e3bb02ff6866db907c8022d9b73454caa585060d28491f95b5c>

#### 二、添加流动性

<https://hoodi.etherscan.io/tx/0x779e949796640f8b916296d578c5772fd03e78dedaca8fa5a3718b3ac5a47fde>

<https://hoodi.etherscan.io/tx/0x82c3aa88fb8fed3765b39802f5298b049cf831baa786e631a24cd151c6cc1f30>

### 源码参考

***<https://github.com/qiaopengjun5162/Uniswap-v2-08>***

## 总结

本教程带你轻松在 Hoodi 测试网部署 Uniswap V2 核心合约（Factory、Router02、WETH9 等）及 AToken、BToken，基于 Solidity 0.8.30，全程验证通过！通过清晰步骤和源码（GitHub: **<https://github.com/qiaopengjun5162/Uniswap-v2-08**），你可快速复现流程，掌握> DeFi 合约开发技能。立即动手实践，加入 Web3 开发浪潮，打造你的去中心化交易所！

## 参考

- <https://etherscan.io/address/0x7a250d5630b4cf539739df2c5dacb4c659f2488d#code>
- <https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code>
- <https://etherscan.io/address/0x5c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f#code>
- <https://hoodi.etherscan.io/address/0x9ab453917cfaeee2b9020537703d30b14f0fdfba#code>
- <https://github.com/Uniswap/sdks/tree/main/sdks/sdk-core>
- <https://github.com/Uniswap/v2-core>
