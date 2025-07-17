+++
title = "Go-ethereum实战笔记：从源码构建一个功能完备的私有测试网络"
description = "本笔记旨在提供一份Geth私有链搭建的终极操作手册。内容涵盖从源码编译Go-ethereum，到配置genesis创世文件、初始化并启动节点的完整流程。跟随本指南，开发者可快速构建一个零成本、功能强大的本地测试环境，高效进行合约调试与链上行为模拟。"
date = 2025-07-17T00:46:58Z
[taxonomies]
categories = ["Web3", "Go", "Ethereum"]
tags = ["Web3", "Go", "Ethereum"]
+++

<!-- more -->

# **Go-ethereum实战笔记：从源码构建一个功能完备的私有测试网络**

与其在时常拥堵、水龙头枯竭的公共测试网上“看天吃饭”，不如在自己的机器上开辟一片绝对掌控的试验田。这篇实战笔记，便是我从零开始，亲手将官方Go-ethereum源码编译成一个功能完备的私有测试网络的完整记录。这里没有晦涩的理论，只有一条清晰、可被任何人复现的路径，让你最终能拥有一个零成本、高效率、且配置强大的专属“兵器库”，去应对未来智能合约开发中的一切挑战。

## 实操

### 第一步：克隆代码

```bash
git clone https://github.com/ethereum/go-ethereum/
```

#### 实操

```bash
git clone git@github.com:qiaopengjun5162/go-ethereum.git
正克隆到 'go-ethereum'...
remote: Enumerating objects: 126681, done.
remote: Counting objects: 100% (3/3), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 126681 (delta 0), reused 0 (delta 0), pack-reused 126678 (from 1)
接收对象中: 100% (126681/126681), 198.13 MiB | 1.01 MiB/s, 完成.
处理 delta 中: 100% (80641/80641), 完成.
```

### 第二步：切换到项目目录

```bash
cd go-ethereum
```

### 第三步：**列出当前目录下的文件和文件夹**

```bash
ls
AUTHORS             SECURITY.md         common              ethclient           interfaces.go       p2p                 triedb
COPYING             accounts            consensus           ethdb               internal            params              version
COPYING.LESSER      appveyor.yml        console             ethstats            log                 rlp
Dockerfile          beacon              core                event               metrics             rpc
Dockerfile.alltools build               crypto              go.mod              miner               signer
Makefile            circle.yml          docs                go.sum              node                tests
README.md           cmd                 eth                 graphql             oss-fuzz.sh         trie
```

`ls` 是一个 **Linux/Unix 命令**（在 Windows 的 Git Bash、WSL 或 macOS 终端中也可用），用于 **列出当前目录下的文件和文件夹**。

### 常见用法

|       命令        |                            作用                            |
| :---------------: | :--------------------------------------------------------: |
|       `ls`        |            列出当前目录的内容（不包括隐藏文件）            |
|      `ls -a`      |    列出 **所有文件**（包括隐藏文件，如 `.git`、`.env`）    |
|      `ls -l`      | 以 **详细列表** 形式显示（权限、所有者、大小、修改时间等） |
|     `ls -la`      |         组合 `-a` 和 `-l`，显示所有文件的详细信息          |
| `ls /path/to/dir` |             列出指定目录的内容（如 `ls /etc`）             |

### 第四步：用 Goland 编辑器打开项目

```bash
open -a Goland .
```

### 第五步：创建并切换到新分支

```bash
go-ethereum on  master via 🐹 v1.24.5 
➜ git checkout -b dev                                                                                                 
切换到一个新分支 'dev'

```

### 第六步：Build geth

```bash
go-ethereum on  dev via 🐹 v1.24.5 
➜ make geth 
go run build/ci.go install ./cmd/geth
go: downloading golang.org/x/crypto v0.36.0
go: downloading golang.org/x/net v0.38.0
go: downloading golang.org/x/text v0.23.0
>>> /opt/homebrew/opt/go/libexec/bin/go build -ldflags "--buildid=none -X github.com/ethereum/go-ethereum/internal/version.gitCommit=e94123acc2bc8283764b26f3423f5e026515c0f4 -X github.com/ethereum/go-ethereum/internal/version.gitDate=20250715 -s" -tags urfave_cli_no_docs,ckzg -trimpath -v -o /Users/qiaopengjun/Code/go/go-ethereum/build/bin/geth ./cmd/geth
go: downloading github.com/dop251/goja v0.0.0-20230605162241-28ee0ee714f3
go: downloading golang.org/x/sys v0.31.0
go: downloading github.com/ferranbt/fastssz v0.1.4
... ...
github.com/ethereum/go-ethereum/eth
github.com/ethereum/go-ethereum/eth/catalyst
github.com/ethereum/go-ethereum/cmd/utils
github.com/ethereum/go-ethereum/cmd/geth
Done building.
Run "./build/bin/geth" to launch geth.

```

### 第七步：创建 datadir 目录并配置 创世（Genesis）文件

#### 创建 datadir 目录

```bash
mkdir datadir
```

#### 配置 创世（Genesis）文件

```json
{
  "config": {
    "chainId": 20250716,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "muirGlacierBlock": 0,
    "berlinBlock": 0,
    "londonBlock": 0,
    "shanghaiTime": 0,
    "cancunTime": 0,
    "pragueTime": 0,
    "verkleTime": 0,
    "blobSchedule": {
      "cancun": {
        "target": 3,
        "max": 6,
        "baseFeeUpdateFraction": 3338477
      },
      "prague": {
        "target": 3,
        "max": 6,
        "baseFeeUpdateFraction": 3338477
      }
    },
    "terminalTotalDifficulty": 1700000010
  },
  "difficulty": "0x170000000",
  "gasLimit": "0x47b760",
  "alloc": {
    "0xf95D00fEE2E22829b298E49a4f7CDEc384cF9e62": {
      "balance": "0xffffffffffffffde0b6b3a7640000"
    }
  }
}
```

### 第八步：初始化 geth

```bash
go-ethereum on  dev [?] via 🐹 v1.24.5 
➜ build/bin/geth init --state.scheme=hash --datadir=datadir genesis.json 
INFO [07-16|21:38:28.500] Maximum peer count                       ETH=50 total=50
INFO [07-16|21:38:28.505] Set global gas cap                       cap=50,000,000
INFO [07-16|21:38:28.506] Initializing the KZG library             backend=gokzg
INFO [07-16|21:38:28.507] Defaulting to pebble as the backing database
INFO [07-16|21:38:28.508] Allocated cache and file handles         database=/Users/qiaopengjun/Code/go/go-ethereum/datadir/geth/chaindata cache=512.00MiB handles=5120
INFO [07-16|21:38:28.605] Opened ancient database                  database=/Users/qiaopengjun/Code/go/go-ethereum/datadir/geth/chaindata/ancient/chain readonly=false
INFO [07-16|21:38:28.606] Opened Era store                         datadir=/Users/qiaopengjun/Code/go/go-ethereum/datadir/geth/chaindata/ancient/chain/era
INFO [07-16|21:38:28.607] State scheme set by user                 scheme=hash
ERROR[07-16|21:38:28.608] Head block is not reachable
INFO [07-16|21:38:28.608] Writing custom genesis block
INFO [07-16|21:38:28.614] Persisted trie from memory database      nodes=1 size=155.00B time="4.416µs" gcnodes=0 gcsize=0.00B gctime=0s livenodes=0 livesize=0.00B
INFO [07-16|21:38:28.614] Successfully wrote genesis state         database=chaindata hash=cca79b..bd26ea


```

### 第九步：启动 geth 节点

```bash
./build/bin/geth \
  --datadir ./datadir \
  --networkid=$CHAIN_ID \
  --http \
  --http.addr=0.0.0.0 \
  --http.port 8545 \
  --http.corsdomain="*" \
  --http.vhosts="*" \
  --http.api "eth,web3,net,txpool,debug,personal" \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port=8546 \
  --ws.origins="*" \
  --ws.api "eth,web3,net,txpool,debug" \
  --syncmode=full \
  --gcmode=archive \
  --nodiscover \
  --maxpeers=0 \
  --verbosity 3 \
  --log.format=json 
```

#### 实操

```bash
go-ethereum on  dev [?] via 🐹 v1.24.5 
➜ export CHAIN_ID=20250716

go-ethereum on  dev [?] via 🐹 v1.24.5 
➜ echo $CHAIN_ID          
20250716

go-ethereum on  dev [?] via 🐹 v1.24.5 took 3m 41.9s 
➜ ./build/bin/geth \
  --datadir ./datadir \
  --networkid=$CHAIN_ID \
  --http \
  --http.addr=0.0.0.0 \
  --http.port 8545 \
  --http.corsdomain="*" \
  --http.vhosts="*" \
  --http.api "eth,web3,net,txpool,debug,personal" \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port=8546 \
  --ws.origins="*" \
  --ws.api "eth,web3,net,txpool,debug" \
  --syncmode=full \
  --gcmode=archive \
  --nodiscover \
  --maxpeers=0 \
  --verbosity 3 \
  --log.format=json
{"t":"2025-07-16T21:53:08.012133+08:00","lvl":"info","msg":"Maximum peer count","ETH":0,"total":0}
{"t":"2025-07-16T21:53:08.014819+08:00","lvl":"info","msg":"Enabling recording of key preimages since archive mode is used"}
{"t":"2025-07-16T21:53:08.014898+08:00","lvl":"warn","msg":"Disabled transaction unindexing for archive node"}
{"t":"2025-07-16T21:53:08.01509+08:00","lvl":"info","msg":"Set global gas cap","cap":50000000}
{"t":"2025-07-16T21:53:08.01558+08:00","lvl":"info","msg":"Initializing the KZG library","backend":"gokzg"}
{"t":"2025-07-16T21:53:08.017443+08:00","lvl":"info","msg":"Allocated trie memory caches","clean":"154.00 MiB","dirty":"256.00 MiB"}
{"t":"2025-07-16T21:53:08.01777+08:00","lvl":"info","msg":"Using pebble as the backing database"}
{"t":"2025-07-16T21:53:08.017999+08:00","lvl":"info","msg":"Allocated cache and file handles","database":"/Users/qiaopengjun/Code/go/go-ethereum/datadir/geth/chaindata","cache":"512.00 MiB","handles":5120}
{"t":"2025-07-16T21:53:08.091712+08:00","lvl":"info","msg":"Opened ancient database","database":"/Users/qiaopengjun/Code/go/go-ethereum/datadir/geth/chaindata/ancient/chain","readonly":false}
{"t":"2025-07-16T21:53:08.091738+08:00","lvl":"info","msg":"Opened Era store","datadir":"/Users/qiaopengjun/Code/go/go-ethereum/datadir/geth/chaindata/ancient/chain/era"}
{"t":"2025-07-16T21:53:08.092551+08:00","lvl":"info","msg":"State scheme set to already existing","scheme":"hash"}
{"t":"2025-07-16T21:53:08.093573+08:00","lvl":"info","msg":"Initialising Ethereum protocol","network":20250716,"dbversion":"9"}
{"t":"2025-07-16T21:53:08.094012+08:00","lvl":"info","msg":""}
{"t":"2025-07-16T21:53:08.094016+08:00","lvl":"info","msg":"---------------------------------------------------------------------------------------------------------------------------------------------------------"}
{"t":"2025-07-16T21:53:08.094032+08:00","lvl":"info","msg":"Chain ID:  20250716 (unknown)"}
{"t":"2025-07-16T21:53:08.094034+08:00","lvl":"info","msg":"Consensus: unknown"}
{"t":"2025-07-16T21:53:08.094035+08:00","lvl":"info","msg":""}
{"t":"2025-07-16T21:53:08.094036+08:00","lvl":"info","msg":"Pre-Merge hard forks (block based):"}
{"t":"2025-07-16T21:53:08.094037+08:00","lvl":"info","msg":" - Homestead:                   #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/homestead.md)"}
{"t":"2025-07-16T21:53:08.094039+08:00","lvl":"info","msg":" - Tangerine Whistle (EIP 150): #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/tangerine-whistle.md)"}
{"t":"2025-07-16T21:53:08.094041+08:00","lvl":"info","msg":" - Spurious Dragon/1 (EIP 155): #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/spurious-dragon.md)"}
{"t":"2025-07-16T21:53:08.094042+08:00","lvl":"info","msg":" - Spurious Dragon/2 (EIP 158): #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/spurious-dragon.md)"}
{"t":"2025-07-16T21:53:08.094074+08:00","lvl":"info","msg":" - Byzantium:                   #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/byzantium.md)"}
{"t":"2025-07-16T21:53:08.094076+08:00","lvl":"info","msg":" - Constantinople:              #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/constantinople.md)"}
{"t":"2025-07-16T21:53:08.094078+08:00","lvl":"info","msg":" - Petersburg:                  #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/petersburg.md)"}
{"t":"2025-07-16T21:53:08.094079+08:00","lvl":"info","msg":" - Istanbul:                    #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/istanbul.md)"}
{"t":"2025-07-16T21:53:08.09408+08:00","lvl":"info","msg":" - Muir Glacier:                #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/muir-glacier.md)"}
{"t":"2025-07-16T21:53:08.094167+08:00","lvl":"info","msg":" - Berlin:                      #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/berlin.md)"}
{"t":"2025-07-16T21:53:08.094179+08:00","lvl":"info","msg":" - London:                      #0        (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/london.md)"}
{"t":"2025-07-16T21:53:08.094182+08:00","lvl":"info","msg":""}
{"t":"2025-07-16T21:53:08.094183+08:00","lvl":"info","msg":"Merge configured:"}
{"t":"2025-07-16T21:53:08.094187+08:00","lvl":"info","msg":" - Hard-fork specification:    https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/paris.md"}
{"t":"2025-07-16T21:53:08.094188+08:00","lvl":"info","msg":" - Network known to be merged"}
{"t":"2025-07-16T21:53:08.094235+08:00","lvl":"info","msg":" - Total terminal difficulty:  1700000010"}
{"t":"2025-07-16T21:53:08.094239+08:00","lvl":"info","msg":""}
{"t":"2025-07-16T21:53:08.09424+08:00","lvl":"info","msg":"Post-Merge hard forks (timestamp based):"}
{"t":"2025-07-16T21:53:08.094242+08:00","lvl":"info","msg":" - Shanghai:                    @0          (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/shanghai.md)"}
{"t":"2025-07-16T21:53:08.094243+08:00","lvl":"info","msg":" - Cancun:                      @0          (https://github.com/ethereum/execution-specs/blob/master/network-upgrades/mainnet-upgrades/cancun.md)"}
{"t":"2025-07-16T21:53:08.094245+08:00","lvl":"info","msg":" - Prague:                      @0         "}
{"t":"2025-07-16T21:53:08.094246+08:00","lvl":"info","msg":" - Verkle:                      @0         "}
{"t":"2025-07-16T21:53:08.094247+08:00","lvl":"info","msg":""}
{"t":"2025-07-16T21:53:08.094249+08:00","lvl":"info","msg":"---------------------------------------------------------------------------------------------------------------------------------------------------------"}
{"t":"2025-07-16T21:53:08.094328+08:00","lvl":"info","msg":""}
{"t":"2025-07-16T21:53:08.094724+08:00","lvl":"info","msg":"Loaded most recent local block","number":"0","hash":"0xcca79b7adddebaa5b9da7621a85b1f8b5d73eb4d85e0d4ef6cad8e628cbd26ea","age":"56y4mo5d"}
{"t":"2025-07-16T21:53:08.095199+08:00","lvl":"info","msg":"Initialized transaction indexer","range":"entire chain"}
{"t":"2025-07-16T21:53:08.104398+08:00","lvl":"info","msg":"Gasprice oracle is ignoring threshold set","threshold":"2"}
{"t":"2025-07-16T21:53:08.105066+08:00","lvl":"warn","msg":"Engine API enabled","protocol":"eth"}
{"t":"2025-07-16T21:53:08.105075+08:00","lvl":"info","msg":"Starting peer-to-peer node","instance":"Geth/v1.16.2-unstable-e94123ac-20250715/darwin-arm64/go1.24.5"}
{"t":"2025-07-16T21:53:08.129402+08:00","lvl":"info","msg":"New local node record","seq":1752673658160,"id":"aec44688d5c05093beba7a1673126d855a7827ecc887ef1f9b5c9ae20fad4631","ip":"127.0.0.1","udp":0,"tcp":30303}
{"t":"2025-07-16T21:53:08.129427+08:00","lvl":"info","msg":"Started P2P networking","self":"enode://b255bca56f04c02faa64d9634c5dce6e4c9206f7d4a1a189064a9d202f932fa74daa1c54e50ea2cf28d803a844bb4fb54f29a1a9ab978bd6b9bd9d747f08f88e@127.0.0.1:30303?discport=0"}
{"t":"2025-07-16T21:53:08.129631+08:00","lvl":"info","msg":"IPC endpoint opened","url":"/Users/qiaopengjun/Code/go/go-ethereum/datadir/geth.ipc"}
{"t":"2025-07-16T21:53:08.129658+08:00","lvl":"error","msg":"Unavailable modules in HTTP API list","unavailable":["personal"],"available":["admin","debug","web3","eth","txpool","miner","net"]}
{"t":"2025-07-16T21:53:08.129944+08:00","lvl":"info","msg":"Loaded JWT secret file","path":"/Users/qiaopengjun/Code/go/go-ethereum/datadir/geth/jwtsecret","crc32":"0xd04caa91"}
{"t":"2025-07-16T21:53:08.130146+08:00","lvl":"info","msg":"HTTP server started","endpoint":"[::]:8545","auth":false,"prefix":"","cors":"*","vhosts":"*"}
{"t":"2025-07-16T21:53:08.130174+08:00","lvl":"info","msg":"WebSocket enabled","url":"ws://[::]:8546"}
{"t":"2025-07-16T21:53:08.132456+08:00","lvl":"info","msg":"WebSocket enabled","url":"ws://127.0.0.1:8551"}
{"t":"2025-07-16T21:53:08.132463+08:00","lvl":"info","msg":"HTTP server started","endpoint":"127.0.0.1:8551","auth":true,"prefix":"","cors":"localhost","vhosts":"localhost"}
{"t":"2025-07-16T21:53:08.132996+08:00","lvl":"info","msg":"Started log indexer"}


```

Geth 节点已**成功启动**。

**成功启动的标志 ✅**

- `"msg":"HTTP server started","endpoint":"[::]:8545"`
- `"msg":"WebSocket enabled","url":"ws://[::]:8546"`
- `"msg":"IPC endpoint opened"` 这些日志表明，你的节点已经可以通过 HTTP、WebSocket 和 IPC 三种方式进行连接和交互了。

### 核心要点：如何让你的私有链“动起来”？

按照上面的步骤启动后，节点虽然运行了，但因为它被配置为了PoS模式，所以不会自动出块。为了创建一个能持续出块的PoW开发链，我们需要对创世文件和启动命令做关键的调整。

### 第十步：测试验证

```bash
go-ethereum on  dev [?] via 🐹 v1.24.5 
➜ curl http://127.0.0.1:8545 \
  -X POST \
  -H "Content-Type: application/json" \
  --data '{"method":"eth_chainId","params":[],"id":1,"jsonrpc":"2.0"}'
{"jsonrpc":"2.0","id":1,"result":"0x135005c"}


```

这个结果说明你的 Geth 节点正在正常运行，并且它的 **Chain ID** (链ID) 是 **`20250716`**。

#### 结果解析 (Result Breakdown)

- `"result":"0x135005c"`: 节点返回的链ID是十六进制 (hex) 格式的。
- 将十六进制的 `0x135005c` 转换为我们熟悉的十进制，其结果就是 **`20250716`**。

这与您之前在 `genesis.json` 文件和启动命令中设置的 `CHAIN_ID` 完全一致，表明您的节点已经成功加载了正确的私有链配置。

![image-20250716215457574](/images/image-20250716215457574.png)

## 总结

至此，这份关于搭建Geth私有链的**实战笔记**就告一段落了。跟随这些步骤，我们不仅收获了一个稳定、高效的本地测试节点，更重要的是，我们亲手触摸了以太坊客户端从代码到运行的每一个环节。

这个节点现在是你开发工具箱里一件趁手的“兵器”：你可以用它无限次地部署合约，模拟各种极端交易条件，甚至尝试复现一些经典的安全攻防案例，而这一切都无需任何成本。

希望这份笔记能实实在在地帮你解决问题。当然，技术的探索永无止境，下一步，我们或许可以一起研究如何搭建一个多节点的PoA网络，或者给这个Geth节点增加一个自定义的RPC接口。如果你有任何想法，欢迎在评论区交流。

## 参考

- <https://github.com/paradigmxyz/reth>
- <https://reth.rs/>
- <https://github.com/TangCYxy/Shares/tree/main/250622%20%E6%9C%AC%E5%9C%B0%E5%90%AF%E5%8A%A8%E7%A7%81%E6%9C%89geth%E8%8A%82%E7%82%B9%E7%94%A8%E4%BA%8E%E8%B0%83%E8%AF%95%E9%AA%8C%E8%AF%81%20after_prague_fork>
- <https://github.com/TangCYxy/Shares/blob/main/250622%20%E6%9C%AC%E5%9C%B0%E5%90%AF%E5%8A%A8%E7%A7%81%E6%9C%89geth%E8%8A%82%E7%82%B9%E7%94%A8%E4%BA%8E%E8%B0%83%E8%AF%95%E9%AA%8C%E8%AF%81%20after_prague_fork/src/genesis.json>
- <https://github.com/ethereum-optimism/op-geth>
- <https://github.com/ethereum/go-ethereum/>
