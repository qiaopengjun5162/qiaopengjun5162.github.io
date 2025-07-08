+++
title = "【硬核实操】从零到一：最新 OP Stack 本地启动全流程完整指南"
description = "本文是一篇详尽的 OP Stack 本地部署实战教程。内容涵盖环境依赖检查、钱包生成、环境变量配置、L1 合约部署、创世文件生成，直至启动 `op-geth`, `op-node`, `op-batcher`, `op-proposer` 全套节点组件。通过17个清晰步骤和详实的命令行实操记录，手把手教你从零开始搭建一个完整的 OP Stack 开发网络，是开发者入门和实践 L2 技术的必备指南。"
date = 2025-07-07T08:54:08Z
[taxonomies]
categories = ["Web3", "区块链", "OP Stack", "OpStack", "以太坊", "L2"]
tags = ["Web3", "区块链", "OP Stack", "OpStack", "以太坊", "L2"]
+++

<!-- more -->

# 【硬核实操】从零到一：最新 OP Stack 本地启动全流程完整指南

🚀 想要深入了解 Layer 2 的世界吗？OP Stack 作为以太坊 L2 扩容的主流方案之一，吸引了无数开发者。理论知识千千万，不如亲手跑一遍！搭建一个本地的 OP Stack 开发网络，是学习其底层原理、测试合约、探索 L2 新功能的最佳途径。

然而，官方文档步骤繁多，细节复杂，常常让初学者望而却步。别担心！本文将为你提供一份 **最新、最完整** 的 OP Stack 本地启动全流程实操指南。我们将从环境准备开始，一步步带你克隆代码、配置钱包、部署合约，最终成功启动包括 `op-geth`、`op-node`、`op-batcher` 和 `op-proposer` 在内的所有核心组件。

无论你是 L2 的初学者还是资深开发者，跟随本指南的脚步，你都能顺利搭建起属于自己的 OP Stack 开发链。让我们开始吧！

## 实操

### 前提

- git
- make
- jq
- just
- go
- node
- nvm
- pnpm
- foundry
- direnv

**确认以上已全部安装成功**。

### 第一步：克隆仓库并切换到 release 分支

```bash
git clone https://github.com/ethereum-optimism/optimism.git
```

#### 实操

```bash
git clone https://github.com/ethereum-optimism/optimism.git
Cloning into 'optimism'...
remote: Enumerating objects: 241914, done.
remote: Counting objects: 100% (1469/1469), done.
remote: Compressing objects: 100% (651/651), done.
Receiving objects: 100% (241914/241914), 366.58 MiB | 1019.00 KiB/s, done.
remote: Total 241914 (delta 1175), reused 821 (delta 816), pack-reused 240445 (from 4)
Resolving deltas: 100% (165969/165969), done.
cd optimism

git remote -v
origin git@github.com:qiaopengjun5162/optimism.git (fetch)
origin git@github.com:qiaopengjun5162/optimism.git (push)
git fetch --tag --all


git branch
                                                                                                                                   
git checkout v4.0.0-rc.6
error: pathspec 'v4.0.0-rc.6' did not match any file(s) known to git
git checkout v1.13.1
Note: switching to 'v1.13.1'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -c with the switch command. Example:

  git switch -c <new-branch-name>

Or undo this operation with:

  git switch -

Turn off this advice by setting config variable advice.detachedHead to false

HEAD is now at b2a5bc202 go: update op-geth@v1.101503.3-rc.1 to fix Worldchain configs (#15319)
git fetch --tags

git checkout -b dev-v1.13.1 v1.13.1  # 从 v1.13.1 创建分支 dev-v1.13.1
Switched to a new branch 'dev-v1.13.1'
```

### 第二步：环境依赖检查

用于验证本地开发环境是否符合 Optimism 项目的工具链版本要求。

```bash
optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ ./packages/contracts-bedrock/scripts/getting-started/versions.sh
Dependency                               | Minimum         | Actual
git (https://git-scm.com)                  2                2.50.0
go (https://go.dev)                        1.21             1.24.4
node (https://nodejs.org)                  20               23.11.0
foundry (https://getfoundry.sh)            0.2.0 (a5efe4f)  1.2.3-stable (a813a2ce)
make (https://www.gnu.org/software/make)   3                3.81
jq (https://jqlang.github.io/jq)           1.6              1.7.1
direnv (https://direnv.net/)               2                2.36.0
just (https://github.com/casey/just)       1.34.0           1.40.0

```

如果版本可以相一致当然最好，否则可能会有版本不兼容的问题。

如果 Foundry 版本验证不通过，可以修改 `versions.sh` 脚本如下：

```sh
#versionFoundry() {
#  local string="$1"
#  local version_regex='forge ([0-9]+\.[0-9]+\.[0-9]+)'
#  local commit_hash_regex='\(([a-fA-F0-9]+)'
#  local full_regex="${version_regex} ${commit_hash_regex}"
#
#  if [[ $string =~ $full_regex ]]; then
#    echo "${BASH_REMATCH[1]} (${BASH_REMATCH[2]})"
#  else
#    echo "No version, commit hash, and timestamp found."
#  fi
#}

versionFoundry() {
    # 尝试获取forge版本信息
    local forge_output
    forge_output=$(forge --version 2>&1)

    # 提取版本号
    local version=""
    if [[ $forge_output =~ [0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z]+)? ]]; then
        version=${BASH_REMATCH[0]}
    fi

    # 提取提交哈希
    local commit_hash=""
    if [[ $forge_output =~ [0-9a-f]{8,} ]]; then
        commit_hash=${BASH_REMATCH[0]}
    fi

    # 组合输出
    if [[ -n "$version" && -n "$commit_hash" ]]; then
#        echo "$version ($commit_hash)"
         echo "$version (${commit_hash:0:8})"  # 只显示前8位哈希

    elif [[ -n "$version" ]]; then
        echo "$version"
    elif [[ -n "$commit_hash" ]]; then
        echo "$commit_hash"
    else
        echo "No version or commit hash found"
    fi
}
```

### 第三步：执行 `wallets.sh`脚本生成新的地址

该 Shell 脚本使用 `cast` 工具生成 5 个以太坊钱包，并提取每个钱包的地址和私钥，最后输出对应的环境变量配置信息，供用户复制到 `.envrc` 文件中使用。  

具体功能如下：  

1. 生成 5 个新钱包。  
2. 使用 `awk` 提取每个钱包的地址和私钥。  
3. 输出标准的 `export` 命令格式，方便设置环境变量。

```bash
./packages/contracts-bedrock/scripts/getting-started/wallets.sh
```

#### 实操

```bash
optimism on  dev-v1.13.1 [!] via 🐹 v1.24.3 
➜ ./packages/contracts-bedrock/scripts/getting-started/wallets.sh
# Copy the following into your .envrc file:

# Admin account
export GS_ADMIN_ADDRESS=0x2905be7987612B54855B646F0729220C569edAd8
export GS_ADMIN_PRIVATE_KEY=0x5f63ae52773dedb13d6e722e82b2d1fd5a3edc66f401c57ac5f445b38aba7f

# Batcher account
export GS_BATCHER_ADDRESS=0x9A4f1E3D6207E89fe386e94F1849866b369a4FBC
export GS_BATCHER_PRIVATE_KEY=0x913f60cd5d886e17d537f3a107aa7d7738eed6b6f2e374851c0600dca6b92

# Proposer account
export GS_PROPOSER_ADDRESS=0x97F8C8Ab6983e936E7F4840B9d4273C99B63f9E4
export GS_PROPOSER_PRIVATE_KEY=0xf8780c87b968ef21983a5173a319dd73b2b4df18a2f7c724d38499c8eb709e

# Sequencer account
export GS_SEQUENCER_ADDRESS=0x38e30E0Bd10F5c30C767cB1F3CA0183A5458B269
export GS_SEQUENCER_PRIVATE_KEY=0x8910273e10653bae3b013021ea446c6b1729343642924f8f61f0a9917c8b8

# Challenger account
export GS_CHALLENGER_ADDRESS=0x79da95a1B7fBedAc953f8E59b1f4FB707DCb9714
export GS_CHALLENGER_PRIVATE_KEY=0x87b6314d70a11f97fa86b9af8
```

建议：该操作仅用于本地测试，生产环境请使用硬件钱包或其它更安全的措施。

### 第四步：创建环境变量文件并把上一步的输出拷贝到`.envrc`文件

```bash
optimism on  develop via 🐹 v1.24.3 
➜ touch .envrc.example               

optimism on  develop [?] via 🐹 v1.24.3 
➜ touch .envrc        

```

#### `.envrc`文件

```bash
##################################################
#                 Getting Started                #
##################################################

# Admin account
export GS_ADMIN_ADDRESS=
export GS_ADMIN_PRIVATE_KEY=

# Batcher account
export GS_BATCHER_ADDRESS=
export GS_BATCHER_PRIVATE_KEY=

# Proposer account
export GS_PROPOSER_ADDRESS=
export GS_PROPOSER_PRIVATE_KEY=

# Sequencer account
export GS_SEQUENCER_ADDRESS=
export GS_SEQUENCER_PRIVATE_KEY=

##################################################
#              op-node Configuration             #
##################################################

# The kind of RPC provider, used to inform optimal transactions receipts
# fetching. Valid options: alchemy, quicknode, infura, parity, nethermind,
# debug_geth, erigon, basic, any.
export L1_RPC_KIND=

##################################################
#               Contract Deployment              #
##################################################

# RPC URL for the L1 network to interact with
export L1_RPC_URL=

# Salt used via CREATE2 to determine implementation addresses
# NOTE: If you want to deploy contracts from scratch you MUST reload this
#       variable to ensure the salt is regenerated and the contracts are
#       deployed to new addresses (otherwise deployment will fail)
export IMPL_SALT=$(openssl rand -hex 32)

# Name for the deployed network
export DEPLOYMENT_CONTEXT=getting-started

# Optional Tenderly details for simulation link during deployment
export TENDERLY_PROJECT=
export TENDERLY_USERNAME=

# Optional Etherscan API key for contract verification
export ETHERSCAN_API_KEY=

# Private key to use for contract deployments, you don't need to worry about
# this for the Getting Started guide.
export PRIVATE_KEY=

```

### 第五步：安装 `direnv`并加载环境变量

```bash
brew install direnv
```

`direnv allow` 是 direnv 工具的一个命令，用于**手动授权**当前目录下的 `.envrc` 文件，使其生效。

#### 加载环境变量

```bash
optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.3 
➜ cd packages/contracts-bedrock 

optimism/packages/contracts-bedrock on  dev-v1.13.1 [!?] via 🐹 v1.24.3 
➜ direnv allow
direnv: loading ~/Code/Web3/optimism/.envrc                                                                                                                                                                
direnv: export +DEPLOYMENT_CONTEXT +ETHERSCAN_API_KEY +GS_ADMIN_ADDRESS +GS_ADMIN_PRIVATE_KEY +GS_BATCHER_ADDRESS +GS_BATCHER_PRIVATE_KEY +GS_CHALLENGER_ADDRESS +GS_CHALLENGER_PRIVATE_KEY +GS_PROPOSER_ADDRESS +GS_PROPOSER_PRIVATE_KEY +GS_SEQUENCER_ADDRESS +GS_SEQUENCER_PRIVATE_KEY +IMPL_SALT +L1_BLOCK_TIME +L1_CHAIN_ID +L1_RPC_KIND +L1_RPC_URL +L2_BLOCK_TIME +L2_CHAIN_ID +PRIVATE_KEY +TENDERLY_PROJECT +TENDERLY_USERNAME

```

### 第六步：充值

你需要至少发送如下数量的 ETH 给相关地址充值以保证后续操作成功。

- `Admin` — 0.5 Sepolia ETH
- `Batcher` — 0.1 Sepolia ETH
- `Proposer` — 0.2 Sepolia ETH

### 第七步：生成`getting-started.json`配置文件

运行以下脚本以在 `deploy-config` 目录中生成 `getting-started.json` 配置文件。

```bash
./scripts/getting-started/config.sh
```

#### 实操生成 getting-started.json` 配置文件

```bash
optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ cd packages/contracts-bedrock                                  

optimism/packages/contracts-bedrock on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ ls   
README.md               book                    deploy-config           deployments             foundry.toml            justfile                scripts                 src
artifacts               cache                   deploy-config-periphery forge-artifacts         interfaces              lib                     snapshots               test

optimism/packages/contracts-bedrock on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ forge install                      

optimism/packages/contracts-bedrock on  dev-v1.13.1 [!?] via 🐹 v1.24.3 
➜ ./scripts/getting-started/config.sh

```

#### 验证 JSON 文件格式是否正确

```bash
optimism/packages/contracts-bedrock on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ jq . deploy-config/getting-started.json 
{
  "l1StartingBlockTag": "0xc6d77e4c46fda7233cf37401199223c2aca97773168be83376fb4907e62e2125",
  "l1ChainID": 11155111,
  "l2ChainID": 701762,
  "l2BlockTime": 2,
  "l1BlockTime": 12,
  "maxSequencerDrift": 600,
  "sequencerWindowSize": 3600,
  "channelTimeout": 300,
  "p2pSequencerAddress": "0x38e30E0Bd10F5c30C767cB1F3CA0183A5458B269",
  "batchInboxAddress": "0xff00000000000000000000000000000000042069",
  "batchSenderAddress": "0x9A4f1E3D6207E89fe386e94F1849866b369a4FBC",
  "l2OutputOracleSubmissionInterval": 120,
  "l2OutputOracleStartingBlockNumber": 0,
  "l2OutputOracleStartingTimestamp": 1751509164,
  "l2OutputOracleProposer": "0x97F8C8Ab6983e936E7F4840B9d4273C99B63f9E4",
  "l2OutputOracleChallenger": "0x2905be7987612B54855B646F0729220C569edAd8",
  "finalizationPeriodSeconds": 12,
  "proxyAdminOwner": "0x2905be7987612B54855B646F0729220C569edAd8",
  "baseFeeVaultRecipient": "0x2905be7987612B54855B646F0729220C569edAd8",
  "l1FeeVaultRecipient": "0x2905be7987612B54855B646F0729220C569edAd8",
  "sequencerFeeVaultRecipient": "0x2905be7987612B54855B646F0729220C569edAd8",
  "finalSystemOwner": "0x2905be7987612B54855B646F0729220C569edAd8",
  "superchainConfigGuardian": "0x2905be7987612B54855B646F0729220C569edAd8",
  "baseFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
  "l1FeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
  "sequencerFeeVaultMinimumWithdrawalAmount": "0x8ac7230489e80000",
  "baseFeeVaultWithdrawalNetwork": 0,
  "l1FeeVaultWithdrawalNetwork": 0,
  "sequencerFeeVaultWithdrawalNetwork": 0,
  "gasPriceOracleOverhead": 0,
  "gasPriceOracleScalar": 1000000,
  "enableGovernance": true,
  "governanceTokenSymbol": "OP",
  "governanceTokenName": "Optimism",
  "governanceTokenOwner": "0x2905be7987612B54855B646F0729220C569edAd8",
  "l2GenesisBlockGasLimit": "0x1c9c380",
  "l2GenesisBlockBaseFeePerGas": "0x3b9aca00",
  "eip1559Denominator": 50,
  "eip1559DenominatorCanyon": 250,
  "eip1559Elasticity": 6,
  "l2GenesisFjordTimeOffset": "0x0",
  "l2GenesisRegolithTimeOffset": "0x0",
  "l2GenesisEcotoneTimeOffset": "0x0",
  "l2GenesisDeltaTimeOffset": "0x0",
  "l2GenesisCanyonTimeOffset": "0x0",
  "systemConfigStartBlock": 0,
  "requiredProtocolVersion": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "recommendedProtocolVersion": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "faultGameAbsolutePrestate": "0x03c7ae758795765c6664a5d39bf63841c71ff191e9189522bad8ebff5d4eca98",
  "faultGameMaxDepth": 44,
  "faultGameClockExtension": 0,
  "faultGameMaxClockDuration": 1200,
  "faultGameGenesisBlock": 0,
  "faultGameGenesisOutputRoot": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "faultGameSplitDepth": 14,
  "faultGameWithdrawalDelay": 600,
  "preimageOracleMinProposalSize": 1800000,
  "preimageOracleChallengePeriod": 300
}

```

### 第八步：部署 Create2 工厂合约 (可选)

如果您要将 OP Stack 链部署到 Sepolia 以外的网络，则可能需要将 Create2 工厂合约部署到 L1 链。

#### 检查工厂合约是否存在

Create2 工厂合约将部署在地址 0x4e59b44847b379578588920cA78FbF26c0B4956C。您可以使用区块浏览器或运行以下命令来检查此合约是否已部署到您的 Layer1 网络：

```bash
cast codesize 0x4e59b44847b379578588920cA78FbF26c0B4956C --rpc-url $L1_RPC_URL
```

<https://sepolia.etherscan.io/address/0x4e59b44847b379578588920ca78fbf26c0b4956c#code>

```bash
optimism/packages/contracts-bedrock on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ cast codesize 0x4e59b44847b379578588920cA78FbF26c0B4956C --rpc-url $L1_RPC_URL      
69

```

如果命令返回 0，则表示合约尚未部署。如果命令返回 69，则表示合约已部署，您可以放心跳过本步骤。

### 给工厂合约部署者转账 1 ETH

您将需要将一些ETH发送到将用于部署工厂合约的地址 `0x3FAB184622DC19B6109349B94811493BF2A45362`。该地址只能用于部署工厂合约，并且不会用于其他任何东西。将至少1个ETH发送到您的L1链上的此地址。

#### 部署工厂合约

<https://github.com/Arachnid/deterministic-deployment-proxy>

```bash
cast publish --rpc-url $L1_RPC_URL 0xf8a58085174876e800830186a08080b853604580600e600039806000f350fe7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03601600081602082378035828234f58015156039578182fd5b8082525050506014600cf31ba02222222222222222222222222222222222222222222222222222222222222222a02222222222222222222222222222222222222222222222222222222222222222 

```

#### 验证工厂合约是否已部署

```bash
cast codesize 0x4e59b44847b379578588920cA78FbF26c0B4956C --rpc-url $L1_RPC_URL
```

#### 参考

<https://github.com/foundry-rs/forge-std/blob/6853b9ec7df5dc0c213b05ae67785ad4f4baa0ea/src/StdConstants.sol>

```solidity
/// @dev Used when deploying with create2.
/// Taken from https://github.com/Arachnid/deterministic-deployment-proxy.
address internal constant CREATE2_FACTORY = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
```

### 第九步：部署 L1 合约

#### 1 初始化链配置

```bash
cd op-deployer

./bin/op-deployer init --l1-chain-id <YOUR_L1_CHAIN_ID> --l2-chain-ids <YOUR_L2_CHAIN_ID> --workdir .deployer
```

这条命令的作用是，根据你指定的L1和L2链ID，来初始化OP Stack部署器并创建后续部署所需的配置文件到`.deployer`工作目录中。

实操

```bash
optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ op-deployer init \
  --l1-chain-id 11155111 \
  --l2-chain-ids 701762 \
  --workdir .deployer  
Successfully initialized op-deployer intent in directory: .deployer

```

#### 2 修改 `.deployer/intent.toml` 配置文件

**注意：以下地址均为示例，实际操作时应替换为您在第三步中生成的地址。**

```ts
configType = "custom"
l1ChainID = 11155111
fundDevAccounts = false
useInterop = false
l1ContractsLocator = "tag://op-contracts/v3.0.0-rc.2"
l2ContractsLocator = "tag://op-contracts/v3.0.0-rc.2"

[superchainRoles]
  proxyAdminOwner = "0x1eb2ffc903729a0f03966b917003800b145f56e2"
  protocolVersionsOwner = "0xfd1d2e729ae8eee2e146c033bf4400fe75284301"
  guardian = "0x7a50f00e8d05b95f98fe38d8bee366a7324dcf7e"

[[chains]]
  id = "0x00000000000000000000000000000000000000000000000000000000000ab542"
  baseFeeVaultRecipient = "0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5"
  l1FeeVaultRecipient = "0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5"
  sequencerFeeVaultRecipient = "0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5"
  eip1559DenominatorCanyon = 250
  eip1559Denominator = 50
  eip1559Elasticity = 6
  operatorFeeScalar = 0
  operatorFeeConstant = 0
  [chains.roles]
    l1ProxyAdminOwner = "0x1eb2ffc903729a0f03966b917003800b145f56e2"
    l2ProxyAdminOwner = "0x2fc3ffc903729a0f03966b917003800b145f67f3"
    systemConfigOwner = "0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5"
    unsafeBlockSigner = "0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5"
    batcher = "0x9A4f1E3D6207E89fe386e94F1849866b369a4FBC"
    proposer = "0x97F8C8Ab6983e936E7F4840B9d4273C99B63f9E4"
    challenger = "0xfd1d2e729ae8eee2e146c033bf4400fe75284301"


```

#### 3 部署 L1 合约

```bash
./bin/op-deployer apply --workdir .deployer \
  --l1-rpc-url <RPC_URL_FOR_L1> \
  --private-key <DEPLOYER_PRIVATE_KEY_HEX>
```

实操部署 L1 合约

```bash
# 1. 准备环境和执行部署命令
optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ direnv allow                                                                             
direnv: loading ~/Code/Web3/optimism/.envrc                                                                                                                                                                
direnv: export +DEPLOYMENT_CONTEXT +ETHERSCAN_API_KEY +GS_ADMIN_ADDRESS +GS_ADMIN_PRIVATE_KEY +GS_BATCHER_ADDRESS +GS_BATCHER_PRIVATE_KEY +GS_CHALLENGER_ADDRESS +GS_CHALLENGER_PRIVATE_KEY +GS_PROPOSER_ADDRESS +GS_PROPOSER_PRIVATE_KEY +GS_SEQUENCER_ADDRESS +GS_SEQUENCER_PRIVATE_KEY +IMPL_SALT +L1_BLOCK_TIME +L1_CHAIN_ID +L1_RPC_KIND +L1_RPC_URL +L2_BLOCK_TIME +L2_CHAIN_ID +PRIVATE_KEY +TENDERLY_PROJECT +TENDERLY_USERNAME

optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ op-deployer apply --workdir .deployer --l1-rpc-url $L1_RPC_URL --private-key $PRIVATE_KEY
 100% |█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| (62/62 MB, 6.3 MB/s)        
INFO [07-03|11:31:40.373] Initialized path database                readonly=true cache=0.00B buffer=0.00B history=0
INFO [07-03|11:31:40.374] initializing pipeline                    stage=init strategy=live
# # 2. 阶段一：部署 Superchain 相关合约
INFO [07-03|11:31:40.859] deploying superchain                     stage=deploy-superchain
INFO [07-03|11:31:53.203] transaction broadcasted                  id=511d6f..dd987b nonce=350
INFO [07-03|11:31:53.204] Publishing transaction                   service=transactor tx=06dd0c..53660d nonce=350 gasTipCap=1,000,000,000 gasFeeCap=26,658,996,078 gasLimit=2,967,074
INFO [07-03|11:31:53.452] Transaction successfully published       service=transactor tx=06dd0c..53660d nonce=350 gasTipCap=1,000,000,000 gasFeeCap=26,658,996,078 gasLimit=2,967,074 tx=06dd0c..53660d
INFO [07-03|11:31:53.943] transaction broadcasted                  id=9d816e..1750a7 nonce=351
INFO [07-03|11:31:53.943] Publishing transaction                   service=transactor tx=d64d82..a9c1ba nonce=351 gasTipCap=1,000,000,000 gasFeeCap=26,658,996,078 gasLimit=1,049,464
INFO [07-03|11:31:54.188] Transaction successfully published       service=transactor tx=d64d82..a9c1ba nonce=351 gasTipCap=1,000,000,000 gasFeeCap=26,658,996,078 gasLimit=1,049,464 tx=d64d82..a9c1ba
INFO [07-03|11:31:54.690] transaction broadcasted                  id=5bb9ee..98a0ca nonce=352
INFO [07-03|11:31:54.690] Publishing transaction                   service=transactor tx=ce9c69..508996 nonce=352 gasTipCap=1,000,000,000 gasFeeCap=26,658,996,078 gasLimit=219,234
INFO [07-03|11:31:54.938] Transaction successfully published       service=transactor tx=ce9c69..508996 nonce=352 gasTipCap=1,000,000,000 gasFeeCap=26,658,996,078 gasLimit=219,234 tx=ce9c69..508996
INFO [07-03|11:31:55.431] transaction broadcasted                  id=7b6b48..fc1715 nonce=353
INFO [07-03|11:31:55.431] Publishing transaction                   service=transactor tx=3417bd..f6f6ed nonce=353 gasTipCap=1,000,000,000 gasFeeCap=26,658,996,078 gasLimit=1,049,464
INFO [07-03|11:31:55.678] Transaction successfully published       service=transactor tx=3417bd..f6f6ed nonce=353 gasTipCap=1,000,000,000 gasFeeCap=26,658,996,078 gasLimit=1,049,464 tx=3417bd..f6f6ed
INFO [07-03|11:31:56.170] transaction broadcasted                  id=f2c49b..e735f2 nonce=354
INFO [07-03|11:31:56.170] Publishing transaction                   service=transactor tx=fc0fe0..4d1d9b nonce=354 gasTipCap=1,000,000,000 gasFeeCap=26,658,996,078 gasLimit=322,444
INFO [07-03|11:31:56.414] Transaction successfully published       service=transactor tx=fc0fe0..4d1d9b nonce=354 gasTipCap=1,000,000,000 gasFeeCap=26,658,996,078 gasLimit=322,444 tx=fc0fe0..4d1d9b
INFO [07-03|11:31:56.906] transaction broadcasted                  id=e26459..72a923 nonce=355
INFO [07-03|11:31:56.906] Publishing transaction                   service=transactor tx=bc7e5f..929f84 nonce=355 gasTipCap=1,000,000,000 gasFeeCap=26,658,996,078 gasLimit=57124
INFO [07-03|11:31:57.154] Transaction successfully published       service=transactor tx=bc7e5f..929f84 nonce=355 gasTipCap=1,000,000,000 gasFeeCap=26,658,996,078 gasLimit=57124 tx=bc7e5f..929f84
INFO [07-03|11:32:01.158] Transaction confirmed                    service=transactor tx=fc0fe0..4d1d9b block=1acdbe..255ed7:8680580 effectiveGasPrice=9,244,565,324
INFO [07-03|11:32:01.390] Transaction confirmed                    service=transactor tx=3417bd..f6f6ed block=1acdbe..255ed7:8680580 effectiveGasPrice=9,244,565,324
INFO [07-03|11:32:01.390] Transaction confirmed                    service=transactor tx=06dd0c..53660d block=1acdbe..255ed7:8680580 effectiveGasPrice=9,244,565,324
INFO [07-03|11:32:01.390] transaction confirmed                    id=511d6f..dd987b completed=1 total=6 hash=0x06dd0c50d00eaa473855432756f8fc1f8daa1ec5a0da611451d9c428e053660d nonce=350 creation=0xed0557F8489BACC829B4F2D9E42F21a6A92A0b04
INFO [07-03|11:32:01.634] Transaction confirmed                    service=transactor tx=ce9c69..508996 block=1acdbe..255ed7:8680580 effectiveGasPrice=9,244,565,324
INFO [07-03|11:32:01.658] Transaction confirmed                    service=transactor tx=bc7e5f..929f84 block=1acdbe..255ed7:8680580 effectiveGasPrice=9,244,565,324
INFO [07-03|11:32:01.873] Transaction confirmed                    service=transactor tx=d64d82..a9c1ba block=1acdbe..255ed7:8680580 effectiveGasPrice=9,244,565,324
INFO [07-03|11:32:01.873] transaction confirmed                    id=9d816e..1750a7 completed=2 total=6 hash=0xd64d825408e14a3319472e8127e94ed48f93d82a628f707d8925d13bd0a9c1ba nonce=351 creation=0xE00aaA74D3eaEB1D7E51acEdcc1C44855b653179
INFO [07-03|11:32:01.873] transaction confirmed                    id=5bb9ee..98a0ca completed=3 total=6 hash=0xce9c6918d5539dd7696092fb48cf20b69d9183791266d95ea54a01fe9a508996 nonce=352 creation=0x0000000000000000000000000000000000000000
INFO [07-03|11:32:01.873] transaction confirmed                    id=7b6b48..fc1715 completed=4 total=6 hash=0x3417bd590adeec4d248cdf60ed3068ff227a60d32ef91cb4e6eb53f66bf6f6ed nonce=353 creation=0x71F745AB1da4CbEAaeAD81aB22e777cfd0887288
INFO [07-03|11:32:01.873] transaction confirmed                    id=f2c49b..e735f2 completed=5 total=6 hash=0xfc0fe041c6ab12b5ae17ccfda0421489976f79419ebc055e0056d55f354d1d9b nonce=354 creation=0x0000000000000000000000000000000000000000
INFO [07-03|11:32:01.873] transaction confirmed                    id=e26459..72a923 completed=6 total=6 hash=0xbc7e5fcd4103c0f379e05b0868d5673a1d4b3ae261017e930c74082942929f84 nonce=355 creation=0x0000000000000000000000000000000000000000
# 3. 阶段二：部署合约实现（Implementations）
INFO [07-03|11:32:01.874] deploying implementations                stage=deploy-implementations
INFO [07-03|11:32:24.499] transaction broadcasted                  id=69ecb4..9ab007 nonce=0
INFO [07-03|11:32:24.499] Publishing transaction                   service=transactor tx=5a81de..fdc37e nonce=356 gasTipCap=1,000,000,000 gasFeeCap=26,399,394,654 gasLimit=3,730,410
INFO [07-03|11:32:24.807] Transaction successfully published       service=transactor tx=5a81de..fdc37e nonce=356 gasTipCap=1,000,000,000 gasFeeCap=26,399,394,654 gasLimit=3,730,410 tx=5a81de..fdc37e
INFO [07-03|11:32:38.291] Transaction confirmed                    service=transactor tx=5a81de..fdc37e block=7f8910..2610fd:8680583 effectiveGasPrice=9,287,895,886
INFO [07-03|11:32:38.292] transaction confirmed                    id=69ecb4..9ab007 completed=1 total=1 hash=0x5a81ded97567783a5e80f886c37a4d986f6f5477924a6d426e9dae7d54fdc37e nonce=0   creation=0x0000000000000000000000000000000000000000
# 4. 阶段三：部署 OP Chain
INFO [07-03|11:32:38.293] deploying OP chain using local allocs    stage=deploy-opchain id=0x00000000000000000000000000000000000000000000000000000000000ab542
INFO [07-03|11:33:22.152] transaction broadcasted                  id=94ca70..8a99d7 nonce=357
INFO [07-03|11:33:22.152] Publishing transaction                   service=transactor tx=cd35a5..a49604 nonce=357 gasTipCap=1,000,000,000 gasFeeCap=25,445,661,244 gasLimit=24,927,200
INFO [07-03|11:33:22.391] Transaction successfully published       service=transactor tx=cd35a5..a49604 nonce=357 gasTipCap=1,000,000,000 gasFeeCap=25,445,661,244 gasLimit=24,927,200 tx=cd35a5..a49604
INFO [07-03|11:33:25.943] Transaction confirmed                    service=transactor tx=cd35a5..a49604 block=4504a0..a5af32:8680587 effectiveGasPrice=9,109,933,878
INFO [07-03|11:33:25.943] transaction confirmed                    id=94ca70..8a99d7 completed=1 total=1 hash=0xcd35a5af2a9fcaa2a7657b5b1843ff84e7ed303ecb758561543cf5f3eea49604 nonce=357 creation=0x0000000000000000000000000000000000000000
INFO [07-03|11:33:25.946] alt-da deployment not needed             stage=deploy-alt-da
INFO [07-03|11:33:25.947] additional dispute games deployment not needed stage=deploy-additional-dispute-games
# 5. 阶段四：生成 L2 创世文件
INFO [07-03|11:33:25.948] generating L2 genesis                    stage=generate-l2-genesis id=0x00000000000000000000000000000000000000000000000000000000000ab542
WARN [07-03|11:33:25.948] RequiredProtocolVersion is empty         "!BADKEY"=&{} config=SuperchainL1DeployConfig
WARN [07-03|11:33:25.948] RecommendedProtocolVersion is empty      "!BADKEY"=&{} config=SuperchainL1DeployConfig
WARN [07-03|11:33:25.948] L2OutputOracleStartingBlockNumber is 0, should only be 0 for fresh chains "!BADKEY"=&{} config=OutputOracleDeployConfig
INFO [07-03|11:33:25.973] L2Genesis: outputMode: none, fork: holocene sender=0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
INFO [07-03|11:33:25.973] Setting precompile 1 wei balances        sender=0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
INFO [07-03|11:33:25.975] Setting Predeploy proxies                sender=0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
INFO [07-03|11:33:25.978] Setting proxy deployed bytecode for addresses in range 0x4200000000000000000000000000000000000000 through 0x42000000000000000000000000000000000007fF sender=0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
INFO [07-03|11:33:25.978] Setting proxy 0x4200000000000000000000000000000000000000 implementation: 0xc0D3C0d3C0d3C0D3c0d3C0d3c0D3C0d3c0d30000 sender=0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
INFO [07-03|11:33:25.978] Setting proxy 0x4200000000000000000000000000000000000002 implementation: 0xc0d3c0d3C0d3c0D3c0d3C0D3c0d3C0d3c0D30002 sender=0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
INFO [07-03|11:33:25.978] Skipping proxy at 0x4200000000000000000000000000000000000006 sender=0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
```

### 第十步：生成相关配置文件

```bash
# 导出L2的创世（Genesis）文件
op-deployer inspect genesis --workdir .deployer "$L2_CHAIN_ID" > .deployer/genesis.json
# 导出L2的Rollup节点配置文件
op-deployer inspect rollup --workdir .deployer "$L2_CHAIN_ID" > .deployer/rollup.json
# 导出已部署在L1上的核心合约地址
# outputs all L1 contract addresses for an L2 chain
op-deployer inspect l1 --workdir .deployer "$L2_CHAIN_ID" > .deployer/l1-contracts.json
# 导出本次部署所使用的完整L2链配置
# outputs the deploy config for an L2 chain
op-deployer inspect deploy-config --workdir .deployer "$L2_CHAIN_ID" > .deployer/l2-chain-config.json
# 导出L2组件的语义化版本（Semantic Versions）
# outputs the semvers for all L2 chains
op-deployer inspect l2-semvers --workdir .deployer "$L2_CHAIN_ID" > .deployer/semvers.txt
```

#### 实操

```bash
optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.4 took 2m 1.4s 
➜ direnv allow
direnv: loading ~/Code/Web3/optimism/.envrc                                                                                                                                                                
direnv: export +DEPLOYMENT_CONTEXT +ETHERSCAN_API_KEY +GS_ADMIN_ADDRESS +GS_ADMIN_PRIVATE_KEY +GS_BATCHER_ADDRESS +GS_BATCHER_PRIVATE_KEY +GS_CHALLENGER_ADDRESS +GS_CHALLENGER_PRIVATE_KEY +GS_PROPOSER_ADDRESS +GS_PROPOSER_PRIVATE_KEY +GS_SEQUENCER_ADDRESS +GS_SEQUENCER_PRIVATE_KEY +IMPL_SALT +L1_BLOCK_TIME +L1_CHAIN_ID +L1_RPC_KIND +L1_RPC_URL +L2_BLOCK_TIME +L2_CHAIN_ID +PRIVATE_KEY +TENDERLY_PROJECT +TENDERLY_USERNAME

optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ op-deployer inspect genesis --workdir .deployer $L2_CHAIN_ID > .deployer/genesis.json 

optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ op-deployer inspect rollup --workdir .deployer $L2_CHAIN_ID > .deployer/rollup.json 

optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ op-deployer inspect l1 --workdir .deployer $L2_CHAIN_ID > .deployer/l1-contracts.json

optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ op-deployer inspect deploy-config --workdir .deployer "$L2_CHAIN_ID" > .deployer/l2-chain-config.json

optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ op-deployer inspect l2-semvers --workdir .deployer "$L2_CHAIN_ID" > .deployer/semvers.txt

```

### 第十一步：创建 JWT secret 并复制（拷贝）到`op-geth`

```bash
optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ cd op-node/   

optimism/op-node on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ openssl rand -hex 32 > jwt.txt                                                 

optimism/op-node on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ cp jwt.txt ../../op-geth 
```

### 第十二步：复制（拷贝）配置文件到`op-geth、op-node`

```bash
optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ cp -a .deployer/genesis.json ../op-geth 

optimism on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ cp -a .deployer/rollup.json op-node 
```

### 第十三步：初始化 `op-geth`

```bash
cd ~/op-geth
mkdir datadir
make geth
build/bin/geth init --state.scheme=hash --datadir=datadir genesis.json
```

#### 实操初始化 `op-geth`

```bash
# 在 op-geth 目录 
op-geth on  tags/v1.101511.0 [?] via 🐹 v1.24.4 
➜ mkdir datadir

op-geth on  tags/v1.101511.0 [?] via 🐹 v1.24.4 
➜ build/bin/geth init --state.scheme=hash --datadir=datadir genesis.json 
INFO [07-03|13:25:57.685] Maximum peer count                       ETH=50 total=50
INFO [07-03|13:25:57.690] Set global gas cap                       cap=50,000,000
INFO [07-03|13:25:57.691] Initializing the KZG library             backend=gokzg
INFO [07-03|13:25:57.692] Defaulting to pebble as the backing database
INFO [07-03|13:25:57.692] Allocated cache and file handles         database=/Users/qiaopengjun/Code/Web3/op-geth/datadir/geth/chaindata cache=16.00MiB handles=16
INFO [07-03|13:25:57.801] Opened ancient database                  database=/Users/qiaopengjun/Code/Web3/op-geth/datadir/geth/chaindata/ancient/chain readonly=false
INFO [07-03|13:25:57.801] State scheme set by user                 scheme=hash
ERROR[07-03|13:25:57.801] Head block is not reachable
INFO [07-03|13:25:57.801] Writing custom genesis block
INFO [07-03|13:25:57.906] Persisted trie from memory database      nodes=3146 size=454.59KiB time=40.595083ms gcnodes=0 gcsize=0.00B gctime=0s livenodes=0 livesize=0.00B
INFO [07-03|13:25:57.978] Successfully wrote genesis state         database=chaindata hash=ffa048..d0113d

op-geth on  tags/v1.101511.0 [?] via 🐹 v1.24.4 
➜ build/bin/geth init --state.scheme=hash --datadir=datadir genesis.json 
INFO [07-03|13:29:46.808] Maximum peer count                       ETH=50 total=50
INFO [07-03|13:29:46.814] Set global gas cap                       cap=50,000,000
INFO [07-03|13:29:46.815] Initializing the KZG library             backend=gokzg
INFO [07-03|13:29:46.816] Using pebble as the backing database
INFO [07-03|13:29:46.816] Allocated cache and file handles         database=/Users/qiaopengjun/Code/Web3/op-geth/datadir/geth/chaindata cache=16.00MiB handles=16
INFO [07-03|13:29:46.898] Opened ancient database                  database=/Users/qiaopengjun/Code/Web3/op-geth/datadir/geth/chaindata/ancient/chain readonly=false
INFO [07-03|13:29:46.898] State scheme set by user                 scheme=hash
INFO [07-03|13:29:46.898] Genesis hash                             hash=ffa048..d0113d
INFO [07-03|13:29:46.945] Checking compatibility                   height=0 time=1,751,513,604 error=<nil>
INFO [07-03|13:29:46.945] Configured chain config matches existing chain config in storage.
INFO [07-03|13:29:46.945] Successfully wrote genesis state         database=chaindata hash=ffa048..d0113d

op-geth on  tags/v1.101511.0 [?] via 🐹 v1.24.4 
➜ build/bin/geth init --state.scheme=hash --datadir=datadir genesis.json 
INFO [07-03|13:29:52.930] Maximum peer count                       ETH=50 total=50
INFO [07-03|13:29:52.933] Set global gas cap                       cap=50,000,000
INFO [07-03|13:29:52.934] Initializing the KZG library             backend=gokzg
INFO [07-03|13:29:52.935] Using pebble as the backing database
INFO [07-03|13:29:52.936] Allocated cache and file handles         database=/Users/qiaopengjun/Code/Web3/op-geth/datadir/geth/chaindata cache=16.00MiB handles=16
INFO [07-03|13:29:52.988] Opened ancient database                  database=/Users/qiaopengjun/Code/Web3/op-geth/datadir/geth/chaindata/ancient/chain readonly=false
INFO [07-03|13:29:52.988] State scheme set by user                 scheme=hash
INFO [07-03|13:29:52.988] Genesis hash                             hash=ffa048..d0113d
INFO [07-03|13:29:53.030] Checking compatibility                   height=0 time=1,751,513,604 error=<nil>
INFO [07-03|13:29:53.030] Configured chain config matches existing chain config in storage.
INFO [07-03|13:29:53.030] Successfully wrote genesis state         database=chaindata hash=ffa048..d0113d

```

#### **初始化结果分析**

##### ✅ **首次执行**（正常初始化）

- **`Head block is not reachable`**
  这是预期行为（新链无历史区块），不影响创世区块写入。
- **成功生成**：
  `chaindata`、`ancient` 目录及数据库文件（`.log`/`.sst`）均正常创建，哈希值 `ffa048..d0113d` 一致。

##### ✅ **后续重复执行**（验证状态）

- **无报错**：直接识别到已有创世区块（`Genesis hash` 一致）。
- **配置匹配**：
  `Configured chain config matches existing chain config in storage` 表明无需重复初始化。

### 第十四步：启动 op-geth

```bash
./build/bin/geth \
  --datadir ./datadir \
  --http \
  --http.corsdomain="*" \
  --http.vhosts="*" \
  --http.addr=0.0.0.0 \
  --http.api=web3,debug,eth,txpool,net,engine,miner \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port=8546 \
  --ws.origins="*" \
  --ws.api=debug,eth,txpool,net,engine,miner \
  --syncmode=full \
  --gcmode=archive \
  --nodiscover \
  --maxpeers=0 \
  --networkid=$L2_CHAIN_ID \
  --authrpc.vhosts="*" \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port=8551 \
  --authrpc.jwtsecret=./jwt.txt \
  --rollup.disabletxpoolgossip=true
```

#### 实操启动 `op-geth`

创建环境变量文件 `.envrc`

```bash
# L2 chain information
export L2_CHAIN_ID=701762
```

启动 `op-geth`

```bash
direnv: loading ~/Code/Web3/op-geth/.envrc
direnv: export +L2_CHAIN_ID

op-geth on  tags/v1.101511.0 [?] via 🐹 v1.24.4 
➜ ./build/bin/geth \
  --datadir ./datadir \
  --http \
  --http.corsdomain="*" \
  --http.vhosts="*" \
  --http.addr=0.0.0.0 \
  --http.api=web3,debug,eth,txpool,net,engine,miner \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port=8546 \
  --ws.origins="*" \
  --ws.api=debug,eth,txpool,net,engine,miner \
  --syncmode=full \
  --gcmode=archive \
  --nodiscover \
  --maxpeers=0 \
  --networkid=$L2_CHAIN_ID \
  --authrpc.vhosts="*" \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port=8551 \
  --authrpc.jwtsecret=./jwt.txt \
  --rollup.disabletxpoolgossip=true
INFO [07-07|14:16:38.292] Maximum peer count                       ETH=0 total=0
INFO [07-07|14:16:38.295] Enabling recording of key preimages since archive mode is used
WARN [07-07|14:16:38.296] Disabled transaction unindexing for archive node
WARN [07-07|14:16:38.296] Forcing hash state-scheme for archive mode
INFO [07-07|14:16:38.296] Set global gas cap                       cap=50,000,000
INFO [07-07|14:16:38.296] Initializing the KZG library             backend=gokzg
INFO [07-07|14:16:38.298] Allocated trie memory caches             clean=307.00MiB dirty=0.00B
INFO [07-07|14:16:38.298] Using pebble as the backing database
INFO [07-07|14:16:38.298] Allocated cache and file handles         database=/Users/qiaopengjun/Code/Web3/op-geth/datadir/geth/chaindata cache=512.00MiB handles=5120
INFO [07-07|14:16:38.405] Opened ancient database                  database=/Users/qiaopengjun/Code/Web3/op-geth/datadir/geth/chaindata/ancient/chain readonly=false
INFO [07-07|14:16:38.406] State scheme set by user                 scheme=hash
INFO [07-07|14:16:38.409] Genesis hash                             hash=ffa048..d0113d
WARN [07-07|14:16:38.409] failed to load chain config from superchain-registry, skipping override err="unknown chain ID: 701762" chain_id=701,762
WARN [07-07|14:16:38.409] failed to load chain config from superchain-registry, skipping override err="unknown chain ID: 701762" chain_id=701,762
INFO [07-07|14:16:38.409] Checking compatibility                   height=0 time=1,751,513,604 error=<nil>
INFO [07-07|14:16:38.409] Configured chain config matches existing chain config in storage.
INFO [07-07|14:16:38.409] 
INFO [07-07|14:16:38.409] ---------------------------------------------------------------------------------------------------------------------------------------------------------
INFO [07-07|14:16:38.409] Chain ID:  701762 (unknown)
INFO [07-07|14:16:38.409] Consensus: Optimism
INFO [07-07|14:16:38.409] 
INFO [07-07|14:16:38.409] Pre-Merge hard forks (block based):
INFO [07-07|14:16:38.409]  - Homestead:                   #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/homestead.md)
INFO [07-07|14:16:38.409]  - Tangerine Whistle (EIP 150): #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/tangerine-whistle.md)
INFO [07-07|14:16:38.409]  - Spurious Dragon/1 (EIP 155): #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/spurious-dragon.md)
INFO [07-07|14:16:38.409]  - Spurious Dragon/2 (EIP 158): #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/spurious-dragon.md)
INFO [07-07|14:16:38.409]  - Byzantium:                   #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/byzantium.md)
INFO [07-07|14:16:38.409]  - Constantinople:              #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/constantinople.md)
INFO [07-07|14:16:38.409]  - Petersburg:                  #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/petersburg.md)
INFO [07-07|14:16:38.409]  - Istanbul:                    #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/istanbul.md)
INFO [07-07|14:16:38.409]  - Muir Glacier:                #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/muir-glacier.md)
INFO [07-07|14:16:38.409]  - Berlin:                      #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/berlin.md)
INFO [07-07|14:16:38.409]  - London:                      #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/london.md)
INFO [07-07|14:16:38.409]  - Arrow Glacier:               #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/arrow-glacier.md)
INFO [07-07|14:16:38.409]  - Gray Glacier:                #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/gray-glacier.md)
INFO [07-07|14:16:38.409] 
INFO [07-07|14:16:38.409] Merge configured:
INFO [07-07|14:16:38.409]  - Hard-fork specification:    https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/paris.md
INFO [07-07|14:16:38.409]  - Network known to be merged
INFO [07-07|14:16:38.409]  - Total terminal difficulty:  0
INFO [07-07|14:16:38.409]  - Merge netsplit block:       #0       
INFO [07-07|14:16:38.409] 
INFO [07-07|14:16:38.409] Post-Merge hard forks (timestamp based):
INFO [07-07|14:16:38.409]  - Shanghai:                    @0          (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/shanghai.md)
INFO [07-07|14:16:38.409]  - Cancun:                      @0          (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/cancun.md)
INFO [07-07|14:16:38.409]  - Regolith:                    @0         
INFO [07-07|14:16:38.409]  - Canyon:                      @0         
INFO [07-07|14:16:38.409]  - Ecotone:                     @0         
INFO [07-07|14:16:38.410]  - Fjord:                       @0         
INFO [07-07|14:16:38.410]  - Granite:                     @0         
INFO [07-07|14:16:38.410]  - Holocene:                    @0         
INFO [07-07|14:16:38.410] 
INFO [07-07|14:16:38.410] ---------------------------------------------------------------------------------------------------------------------------------------------------------
INFO [07-07|14:16:38.410] 
INFO [07-07|14:16:38.412] Loaded most recent local block           number=0 hash=ffa048..d0113d age=4d2h43m
WARN [07-07|14:16:38.413] Loaded snapshot journal                  diffs=missing
INFO [07-07|14:16:38.413] Initialized transaction indexer          range="entire chain"
INFO [07-07|14:16:38.413] Initialising Ethereum protocol           network=701,762 dbversion=9
WARN [07-07|14:16:38.413] Invalid log index database version; resetting log index
INFO [07-07|14:16:38.417] Gasprice oracle is ignoring threshold set threshold=2
WARN [07-07|14:16:38.423] Unclean shutdown detected                booted=2025-07-03T15:12:48+0800 age=3d23h3m
WARN [07-07|14:16:38.424] Engine API enabled                       protocol=eth
INFO [07-07|14:16:38.424] Starting peer-to-peer node               instance=Geth/v1.101511.0-rc.1-68075997-20250515/darwin-arm64/go1.24.4
INFO [07-07|14:16:38.453] New local node record                    seq=1,751,526,468,437 id=44c4640efe9533ab ip=127.0.0.1 udp=0 tcp=30303
INFO [07-07|14:16:38.453] Started P2P networking                   self="enode://c14f3c59c4966bbd48ee25694619a5761140daeafbb897e19f08a300b22c922f02d72caea59f04c002b39e0060792e366d14bfb5b26e9ca35b8cc6e3737109ef@127.0.0.1:30303?discport=0"
INFO [07-07|14:16:38.454] IPC endpoint opened                      url=/Users/qiaopengjun/Code/Web3/op-geth/datadir/geth.ipc
INFO [07-07|14:16:38.455] Loaded JWT secret file                   path=jwt.txt crc32=0x1e6e5e0e
INFO [07-07|14:16:38.455] HTTP server started                      endpoint=[::]:8545 auth=false prefix= cors=* vhosts=*
INFO [07-07|14:16:38.455] WebSocket enabled                        url=ws://[::]:8546
INFO [07-07|14:16:38.455] WebSocket enabled                        url=ws://[::]:8551
INFO [07-07|14:16:38.455] HTTP server started                      endpoint=[::]:8551 auth=true  prefix= cors=localhost vhosts=*
INFO [07-07|14:16:38.456] Started log indexer


```

![image-20250707145508586](/images/image-20250707145508586.png)

### 第十五步：启动 op-node

```bash
./bin/op-node \
  --l2=http://localhost:8551 \
  --l2.jwt-secret=./jwt.txt \
  --sequencer.enabled \
  --sequencer.l1-confs=5 \
  --verifier.l1-confs=4 \
  --rollup.config=./rollup.json \
  --rpc.addr=0.0.0.0 \
  --p2p.disable \
  --rpc.enable-admin \
  --p2p.sequencer.key=$GS_SEQUENCER_PRIVATE_KEY \
  --l1=$L1_RPC_URL \
  --l1.rpckind=$L1_RPC_KIND \
  --l1.beacon=$L1_BEACON_URL
```

#### 实操启动 op-node

```bash
optimism/op-node on  dev-v1.13.1 [!?] via 🐹 v1.24.4 took 48.1s 
➜ direnv allow   
direnv: loading ~/Code/Web3/optimism/.envrc                                                                                                                                                                
direnv: export +DEPLOYMENT_CONTEXT +ETHERSCAN_API_KEY +GS_ADMIN_ADDRESS +GS_ADMIN_PRIVATE_KEY +GS_BATCHER_ADDRESS +GS_BATCHER_PRIVATE_KEY +GS_CHALLENGER_ADDRESS +GS_CHALLENGER_PRIVATE_KEY +GS_PROPOSER_ADDRESS +GS_PROPOSER_PRIVATE_KEY +GS_SEQUENCER_ADDRESS +GS_SEQUENCER_PRIVATE_KEY +IMPL_SALT +L1_BEACON_URL +L1_BLOCK_TIME +L1_CHAIN_ID +L1_RPC_KIND +L1_RPC_URL +L2_BLOCK_TIME +L2_CHAIN_ID +PRIVATE_KEY +TENDERLY_PROJECT +TENDERLY_USERNAME

optimism/op-node on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ ./bin/op-node \
  --l2=http://localhost:8551 \
  --l2.jwt-secret=./jwt.txt \
  --sequencer.enabled \
  --sequencer.l1-confs=5 \
  --verifier.l1-confs=4 \
  --rollup.config=./rollup.json \
  --rpc.addr=0.0.0.0 \
  --p2p.disable \
  --rpc.enable-admin \
  --p2p.sequencer.key=$GS_SEQUENCER_PRIVATE_KEY \
  --l1=$L1_RPC_URL \
  --l1.rpckind=$L1_RPC_KIND \
  --l1.beacon=$L1_BEACON_URL
INFO [07-07|14:36:30.209] Not opted in to ProtocolVersions signal loading, disabling ProtocolVersions contract now.
INFO [07-07|14:36:30.219] No persisted sequencer state loaded
INFO [07-07|14:36:30.220] Rollup Config                            l2_chain_id=701,762 l2_network="unknown L2" l1_chain_id=11,155,111 l1_network=sepolia l2_start_time=1,751,513,604 l2_block_hash=0xffa048e14c24e8a00c278ce46a6cedceaacbf28db84d938d430aa24f26d0113d l2_block_number=0 l1_block_hash=0x4504a027d73ea857fc855898b99c8e07d921fdb34aaaa356ed60b09c01a5af32 l1_block_number=8,680,587 regolith_time="@ genesis" canyon_time="@ genesis" delta_time="@ genesis" ecotone_time="@ genesis" fjord_time="@ genesis" granite_time="@ genesis" holocene_time="@ genesis" isthmus_time="(not configured)" interop_time="(not configured)" alt_da=false
INFO [07-07|14:36:30.220] Initializing rollup node                 version=untagged-1c8b9690-1746453533
INFO [07-07|14:36:33.416] Connected to L1 Beacon API, ready for EIP-4844 blobs retrieval. version=teku/v25.4.1/linux-x86_64/-ubuntu-openjdk64bitservervm-java-21
INFO [07-07|14:36:35.005] loaded new runtime config values!        p2p_seq_address=0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
INFO [07-07|14:36:35.005] Admin RPC enabled
INFO [07-07|14:36:35.005] Starting JSON-RPC server
INFO [07-07|14:36:35.017] Started JSON-RPC server                  addr=[::]:9545
INFO [07-07|14:36:35.017] metrics disabled
INFO [07-07|14:36:35.017] Starting execution engine driver
INFO [07-07|14:36:35.018] Starting driver                          sequencerEnabled=true sequencerStopped=false
INFO [07-07|14:36:35.018] Starting sequencing, without known pre-state
INFO [07-07|14:36:35.018] Sequencer has been started               "next action"=2025-07-07T14:36:35+0800
INFO [07-07|14:36:35.018] Rollup node started
INFO [07-07|14:36:35.018] State loop started
INFO [07-07|14:36:35.019] Scheduled sequencer action               delta="-585.791µs"
WARN [07-07|14:36:35.020] Deriver system is resetting              err="reset: cannot continue derivation until Engine has been reset"
ERROR[07-07|14:36:35.020] Sequencer encountered reset signal, aborting work err="reset: cannot continue derivation until Engine has been reset"
INFO [07-07|14:36:35.029] Loaded current L2 heads                  unsafe=ffa048..d0113d:0 safe=ffa048..d0113d:0 finalized=ffa048..d0113d:0 unsafe_origin=4504a0..a5af32:8680587 safe_origin=4504a0..a5af32:8680587
INFO [07-07|14:36:35.687] Walking back L1Block by number           curr=4504a0..a5af32:8680587 next=4504a0..a5af32:8680587 l2block=ffa048..d0113d:0
INFO [07-07|14:36:35.687] Hit finalized L2 head, returning immediately unsafe=ffa048..d0113d:0 safe=ffa048..d0113d:0 finalized=ffa048..d0113d:0 unsafe_origin=4504a0..a5af32:8680587 safe_origin=4504a0..a5af32:8680587
INFO [07-07|14:36:35.687] Current hardfork version detected        forkName=holocene
INFO [07-07|14:36:35.689] Reset of Engine is completed             local_unsafe=ffa048..d0113d:0 cross_unsafe=ffa048..d0113d:0 local_safe=ffa048..d0113d:0 cross_safe=ffa048..d0113d:0 finalized=ffa048..d0113d:0

```

![image-20250707145406302](/images/image-20250707145406302.png)

### 第十六步：启动 op-batcher

```bash
./bin/op-batcher \
  --l2-eth-rpc=http://localhost:8545 \
  --rollup-rpc=http://localhost:9545 \
  --poll-interval=1s \
  --sub-safety-margin=6 \
  --num-confirmations=1 \
  --safe-abort-nonce-too-low-count=3 \
  --resubmission-timeout=30s \
  --rpc.addr=0.0.0.0 \
  --rpc.port=8548 \
  --rpc.enable-admin \
  --max-channel-duration=25 \
  --l1-eth-rpc=$L1_RPC_URL \
  --private-key=$GS_BATCHER_PRIVATE_KEY
```

#### 实操启动 op-batcher

```bash
optimism/op-batcher on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ direnv allow 
direnv: loading ~/Code/Web3/optimism/.envrc                                                                                                                                                                
direnv: export +DEPLOYMENT_CONTEXT +ETHERSCAN_API_KEY +GS_ADMIN_ADDRESS +GS_ADMIN_PRIVATE_KEY +GS_BATCHER_ADDRESS +GS_BATCHER_PRIVATE_KEY +GS_CHALLENGER_ADDRESS +GS_CHALLENGER_PRIVATE_KEY +GS_PROPOSER_ADDRESS +GS_PROPOSER_PRIVATE_KEY +GS_SEQUENCER_ADDRESS +GS_SEQUENCER_PRIVATE_KEY +IMPL_SALT +L1_BEACON_URL +L1_BLOCK_TIME +L1_CHAIN_ID +L1_RPC_KIND +L1_RPC_URL +L2_BLOCK_TIME +L2_CHAIN_ID +PRIVATE_KEY +TENDERLY_PROJECT +TENDERLY_USERNAME

optimism/op-batcher on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ ./bin/op-batcher \
  --l2-eth-rpc=http://localhost:8545 \
  --rollup-rpc=http://localhost:9545 \
  --poll-interval=1s \
  --sub-safety-margin=6 \
  --num-confirmations=1 \
  --safe-abort-nonce-too-low-count=3 \
  --resubmission-timeout=30s \
  --rpc.addr=0.0.0.0 \
  --rpc.port=8548 \
  --rpc.enable-admin \
  --max-channel-duration=25 \
  --l1-eth-rpc=$L1_RPC_URL \
  --private-key=$GS_BATCHER_PRIVATE_KEY
INFO [07-07|14:40:21.335] Initializing Batch Submitter
INFO [07-07|14:40:21.520] Rollup Config                            l2_chain_id=701,762 l2_network="unknown L2" l1_chain_id=11,155,111 l1_network=sepolia l2_start_time=1,751,513,604 l2_block_hash=0xffa048e14c24e8a00c278ce46a6cedceaacbf28db84d938d430aa24f26d0113d l2_block_number=0 l1_block_hash=0x4504a027d73ea857fc855898b99c8e07d921fdb34aaaa356ed60b09c01a5af32 l1_block_number=8,680,587 regolith_time="@ genesis" canyon_time="@ genesis" delta_time="@ genesis" ecotone_time="@ genesis" fjord_time="@ genesis" granite_time="@ genesis" holocene_time="@ genesis" isthmus_time="(not configured)" jovian_time="(not configured)" interop_time="(not configured)"
WARN [07-07|14:40:22.342] Ecotone upgrade is active, but batcher is not configured to use Blobs!
INFO [07-07|14:40:22.342] Initialized channel-config               da_type=calldata use_alt_da=false max_frame_size=119,999 target_num_frames=1 compressor=shadow compression_algo=zlib batch_type=0 max_channel_duration=25 channel_timeout=50 sub_safety_margin=6
INFO [07-07|14:40:22.342] Metrics disabled
INFO [07-07|14:40:22.342] registered API                           route= namespace=admin
INFO [07-07|14:40:22.342] registered API                           route= namespace=txmgr
INFO [07-07|14:40:22.342] Admin RPC enabled
INFO [07-07|14:40:22.342] Starting JSON-RPC server
INFO [07-07|14:40:22.353] Started RPC server                       endpoint=http://[::]:8548
INFO [07-07|14:40:22.353] Starting batcher                         notSubmittingOnStart=false
INFO [07-07|14:40:22.353] Starting Batch Submitter
INFO [07-07|14:40:22.353] Clearing state
INFO [07-07|14:40:22.356] Clearing state with safe L1 origin       origin=4504a0..a5af32:8680587
INFO [07-07|14:40:22.356] State cleared
INFO [07-07|14:40:22.356] Batch Submitter started
INFO [07-07|14:40:22.356] Starting DA throttling loop
INFO [07-07|14:40:22.356] Starting receipts processing loop
INFO [07-07|14:40:23.358] no blocks in state                       syncStatus.headL1=bd3757..f8cfbe:8710270 syncStatus.currentL1=d722a1..7efeaf:8680678 syncStatus.localSafeL2=ffa048..d0113d:0 syncStatus.safeL2=ffa048..d0113d:0 syncStatus.unsafeL2=71b885..0a26af:22 syncActions="SyncActions{blocksToPrune: 0, channelsToPrune: 0, clearState: nil, blocksToLoad: [1, 22]}"
INFO [07-07|14:40:23.358] Loading range of multiple blocks into state start=1 end=22
INFO [07-07|14:40:23.362] Added L2 block to local state            block=ce5d07..3a2412:1 tx_count=1 time=1,751,513,606
INFO [07-07|14:40:23.364] Added L2 block to local state            block=c93073..4851c4:2 tx_count=1 time=1,751,513,608
INFO [07-07|14:40:23.365] Added L2 block to local state            block=0a094f..51d7a5:3 tx_count=1 time=1,751,513,610
INFO [07-07|14:40:23.367] Added L2 block to local state            block=fa2704..2528df:4 tx_count=1 time=1,751,513,612
INFO [07-07|14:40:23.368] Added L2 block to local state            block=431d17..1e2010:5 tx_count=1 time=1,751,513,614
INFO [07-07|14:40:23.369] Added L2 block to local state            block=a5775c..c87eb1:6 tx_count=1 time=1,751,513,616
INFO [07-07|14:40:23.370] Added L2 block to local state            block=6cec0d..88a39e:7 tx_count=1 time=1,751,513,618
INFO [07-07|14:40:23.371] Added L2 block to local state            block=6ea6d3..5a980f:8 tx_count=1 time=1,751,513,620
INFO [07-07|14:40:23.371] Added L2 block to local state            block=abac21..3c8b0a:9 tx_count=1 time=1,751,513,622
INFO [07-07|14:40:23.372] Added L2 block to local state            block=ce933c..9d947f:10 tx_count=1 time=1,751,513,624

```

![image-20250707145344808](/images/image-20250707145344808.png)

### 第十七步：启动 op-proposer

```bash
./bin/op-proposer \
  --poll-interval=12s \
  --rpc.port=8560 \
  --rollup-rpc=http://localhost:9545 \
  --private-key=$GS_PROPOSER_PRIVATE_KEY \
  --l1-eth-rpc=$L1_RPC_URL
```

#### 实操启动 `op-proposer`

```bash
optimism/op-proposer on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ export OP_PROPOSER_GAME_FACTORY_ADDRESS=$(jq -r .opChainDeployment.disputeGameFactoryProxyAddress ../.deployer/l1-contracts.json)

optimism/op-proposer on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ echo $OP_PROPOSER_GAME_FACTORY_ADDRESS                                                                                           
0x26239d5ec55a9c4a3165fb501ea968f19b6a53d8

optimism/op-proposer on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ direnv allow
direnv: loading ~/Code/Web3/optimism/.envrc                                                                                                                                                                
direnv: export +DEPLOYMENT_CONTEXT +ETHERSCAN_API_KEY +GS_ADMIN_ADDRESS +GS_ADMIN_PRIVATE_KEY +GS_BATCHER_ADDRESS +GS_BATCHER_PRIVATE_KEY +GS_CHALLENGER_ADDRESS +GS_CHALLENGER_PRIVATE_KEY +GS_PROPOSER_ADDRESS +GS_PROPOSER_PRIVATE_KEY +GS_SEQUENCER_ADDRESS +GS_SEQUENCER_PRIVATE_KEY +IMPL_SALT +L1_BEACON_URL +L1_BLOCK_TIME +L1_CHAIN_ID +L1_RPC_KIND +L1_RPC_URL +L2_BLOCK_TIME +L2_CHAIN_ID +OP_PROPOSER_GAME_TYPE +OP_PROPOSER_PROPOSAL_INTERVAL +OP_PROPOSER_WAIT_NODE_SYNC +PRIVATE_KEY +TENDERLY_PROJECT +TENDERLY_USERNAME

optimism/op-proposer on  dev-v1.13.1 [!?] via 🐹 v1.24.4 
➜ ./bin/op-proposer \
  --poll-interval=12s \
  --rpc.port=8560 \
  --rollup-rpc=http://localhost:9545 \
  --private-key=$GS_PROPOSER_PRIVATE_KEY \
  --l1-eth-rpc=$L1_RPC_URL
INFO [07-07|14:48:23.108] Initializing L2Output Submitter
INFO [07-07|14:48:24.118] Metrics disabled
INFO [07-07|14:48:24.535] Connected to DisputeGameFactory          address=0x26239d5Ec55A9C4a3165FB501EA968f19B6a53D8 version=1.0.1
INFO [07-07|14:48:24.535] Starting JSON-RPC server
INFO [07-07|14:48:24.546] Started RPC server                       endpoint=http://[::]:8560
INFO [07-07|14:48:24.546] Starting Proposer
INFO [07-07|14:48:24.546] Starting Proposer
INFO [07-07|14:48:24.982] rollup current L1 block still behind target, retrying current_l1=5bdf2a..30fd10:8680854 target_l1=8,710,311
INFO [07-07|14:48:36.985] rollup current L1 block still behind target, retrying current_l1=f2956c..cf7f99:8680858 target_l1=8,710,311
INFO [07-07|14:48:48.989] rollup current L1 block still behind target, retrying current_l1=93bafd..852778:8680863 target_l1=8,710,311
INFO [07-07|14:49:00.994] rollup current L1 block still behind target, retrying current_l1=bb4b39..d58a55:8680868 target_l1=8,710,311
INFO [07-07|14:49:13.000] rollup current L1 block still behind target, retrying current_l1=f4dc0f..2786dd:8680871 target_l1=8,710,311
INFO [07-07|14:49:25.005] rollup current L1 block still behind target, retrying current_l1=85552b..a3f68b:8680874 target_l1=8,710,311
INFO [07-07|14:49:37.010] rollup current L1 block still behind target, retrying current_l1=9d9c2c..e86e58:8680878 target_l1=8,710,311

```

![image-20250707145320688](/images/image-20250707145320688.png)

### 环境变量文件参考

```bash
##################################################
#                 Getting Started                #
##################################################

# Copy the following into your .envrc file:

# Admin account
export GS_ADMIN_ADDRESS=
export GS_ADMIN_PRIVATE_KEY=

# Batcher account
export GS_BATCHER_ADDRESS=
export GS_BATCHER_PRIVATE_KEY=

# Proposer account
export GS_PROPOSER_ADDRESS=
export GS_PROPOSER_PRIVATE_KEY=

# Sequencer account
export GS_SEQUENCER_ADDRESS=
export GS_SEQUENCER_PRIVATE_KEY=

# Challenger account
export GS_CHALLENGER_ADDRESS=
export GS_CHALLENGER_PRIVATE_KEY=



##################################################
#                Chain Information               #
##################################################

# L1 chain information
export L1_CHAIN_ID=11155111
export L1_BLOCK_TIME=12

# L2 chain information
export L2_CHAIN_ID=
export L2_BLOCK_TIME=2

##################################################
#              op-node Configuration             #
##################################################

# The kind of RPC provider, used to inform optimal transactions receipts
# fetching. Valid options: alchemy, quicknode, infura, parity, nethermind,
# debug_geth, erigon, basic, any.
export L1_RPC_KIND=alchemy

##################################################
#               Contract Deployment              #
##################################################

# RPC URL for the L1 network to interact with
 export L1_RPC_URL="https://eth-sepolia.g.alchemy.com/v2"


# Salt used via CREATE2 to determine implementation addresses
# NOTE: If you want to deploy contracts from scratch you MUST reload this
#       variable to ensure the salt is regenerated and the contracts are
#       deployed to new addresses (otherwise deployment will fail)
# export IMPL_SALT=$(openssl rand -hex 32)
export IMPL_SALT=

# Name for the deployed network
export DEPLOYMENT_CONTEXT=getting-started

# Optional Tenderly details for simulation link during deployment
export TENDERLY_PROJECT=
export TENDERLY_USERNAME=

# Optional Etherscan API key for contract verification
export ETHERSCAN_API_KEY=

# Private key to use for contract deployments, you don't need to worry about
# this for the Getting Started guide.
export PRIVATE_KEY=

export L1_BEACON_URL=

export OP_PROPOSER_WAIT_NODE_SYNC=true
export OP_PROPOSER_PROPOSAL_INTERVAL=4m
export OP_PROPOSER_GAME_TYPE=1
export OP_PROPOSER_GAME_FACTORY_ADDRESS=

```

## 总结

> **恭喜！至此，我们已经成功启动了一个完整的 OP Stack 开发网络。**

恭喜你！如果能一步步跟到这里，你已经成功启动了一个功能完整的本地 OP Stack 开发网络。我们从最基础的环境准备开始，经历了 **配置生成、L1 合约部署、L2 创世、节点初始化**，并最终成功运行了 **执行客户端 (op-geth)、排序节点 (op-node)、批处理提交者 (op-batcher) 和 L2 产出提交者 (op-proposer)** 这四大核心组件。

这整个过程不仅让你拥有了一个可以自由测试和开发的 L2 环境，更重要的是，它让你对 OP Stack 的系统架构和模块间的协作关系有了更直观、更深入的理解。这是任何理论文章都无法替代的宝贵经验。

现在，你可以在这个本地网络上部署自己的 DApp、探索交易流程、或者尝试修改配置以观察网络变化。希望这篇详尽的指南能为你打开探索 Layer 2 世界的大门。

**如果觉得本文对你有帮助，欢迎点赞、在看、收藏和转发，你的支持是我们持续创作的最大动力！**

## 参考

- <https://docs.optimism.io/operators/chain-operators/tutorials/create-l2-rollup#start-op-geth>
- <https://github.com/ethereum-optimism/optimism>
- <https://github.com/Arachnid/deterministic-deployment-proxy>
- <https://github.com/foundry-rs/forge-std/blob/6853b9ec7df5dc0c213b05ae67785ad4f4baa0ea/src/StdConstants.sol>
- <https://docs.optimism.io/operators/chain-operators/tools/op-deployer>
- <https://console.optimism.io/?ref=blog.oplabs.co>
- <https://ethereum-sepolia-beacon-api.publicnode.com>
- <https://direnv.net/>
- <https://optimism.io/>
- <https://github.com/ethereum-optimism/optimism>
- <https://docs.optimism.io/app-developers/get-started>
- <https://docs.optimism.io/operators/chain-operators/tutorials/create-l2-rollup>
- <https://blog.ithuo.net/posts/building-l2-blockchain-based-on-op-stack/>
- <https://docs.availproject.org/docs/build-with-avail/deploy-rollup-on-avail/Optimium/op-stack/op-stack>
- <https://github.com/casey/just>
- <https://sepolia.etherscan.io/address/0x4e59b44847b379578588920ca78fbf26c0b4956c#code>
- <https://mise.jdx.dev/getting-started.html#_1-install-mise-cli>
