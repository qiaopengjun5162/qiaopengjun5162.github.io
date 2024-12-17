+++
title = "Solana 开发学习之通过RPC与Solana交互"
date = 2024-02-22T12:42:01+08:00
[taxonomies]
tags = ["Solana"]
categories = ["Solana"]
+++

# Solana 开发学习之通过RPC与Solana交互

### 相关链接

- <https://solana.com/docs/rpc/http>
- <https://www.jsonrpc.org/specification>
- <https://www.json.org/json-en.html>

## JSON-RPC 2.0 规范

JSON-RPC 是一种无状态、轻量级远程过程调用 (RPC) 协议。该规范主要定义了几种数据结构及其处理规则。它与传输无关，因为这些概念可以在同一进程中、通过套接字、通过 http 或在许多不同的消息传递环境中使用。它使用[JSON](http://www.json.org/) ( [RFC 4627](http://www.ietf.org/rfc/rfc4627.txt) ) 作为数据格式。

## 接口RPC

### 节点相关接口

#### 获取集群节点信息

通过getClusterNodes方法可以获得当前网络内，集群节点的相关信息，比如验证者的key，节点IP，节点版本等。

```shell
curl https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
    {
        "jsonrpc": "2.0", "id": 1,
        "method": "getClusterNodes"
    }
    '
    
{"jsonrpc":"2.0","result":[{"featureSet":3580551090,"gossip":"67.209.54.90:8001","pubkey":"7pbH563fFai2Gm8aXGi27Toj1i7x55rGp7QQ8ZQt6C7i","pubsub":null,"rpc":null,"shredVersion":503,"tpu":"67.209.54.90:8004","tpuQuic":"67.209.54.90:8010","version":"1.17.21"},{"featureSet":3580551090,"gossip":"37.27.61.250:8000","pubkey":"HPpYXZ944SXpJB3Tb7Zzy2K7YD45zGREsGqPtEP43xBx","pubsub":null,"rpc":null,"shredVersion":503,"tpu":"37.27.61.250:8003","tpuQuic":"37.27.61.250:8009","version":"1.17.22"},

......
{"featureSet":3011420684,"gossip":"69.197.5.60:8001","pubkey":"FKizb2faoz57ym1bTWcZhei3aUZu7eU5AiY1EYoZsok6","pubsub":null,"rpc":null,"shredVersion":503,"tpu":null,"tpuQuic":null,"version":"1.17.5"}],"id":1}
```

### 区块相关接口

#### 获取当前区块高度

通过getBlockHeight可以获取当前的区块高度

- <https://solana.com/docs/rpc/http/getblockheight>

```shell
curl https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
    {
        "jsonrpc":"2.0","id":1,
        "method":"getBlockHeight"
    }
    '
{"jsonrpc":"2.0","result":268621259,"id":1}
```

#### 获取最近的Block Hash

- <https://solana.com/docs/rpc/http/getlatestblockhash>

```shell
curl https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
    {
        "id":1,
        "jsonrpc":"2.0",
        "method":"getLatestBlockhash",
        "params":[
        {
            "commitment":"processed"
        }
        ]
    }
    '
{"jsonrpc":"2.0","result":{"context":{"apiVersion":"1.17.21","slot":280325472},"value":{"blockhash":"9ebRPaCY2pcKAPhWzjDtmLArbSzAH1Mb5n8PZzXKbW8X","lastValidBlockHeight":268622097}},"id":1}
```

#### 获取指定高度block的信息

- <https://solana.com/docs/rpc/http/getblock>

```shell
curl https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
    {
        "jsonrpc": "2.0","id":1,
        "method":"getBlock",
        "params": [
            174302734,
            {
                "encoding": "jsonParsed",
                "maxSupportedTransactionVersion":0,
                "transactionDetails":"full",
                "rewards":false
            }
        ]
    }
    '
```

#### 获取指定block的确认状态

- <https://solana.com/docs/rpc/http/getblockcommitment>

```shell
curl https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
    {
        "jsonrpc": "2.0", "id": 1,
        "method": "getBlockCommitment",
        "params":[174302734]
    }
    '
{"jsonrpc":"2.0","result":{"commitment":null,"totalStake":158091345604635247},"id":1}
```

#### 一次性获取多个Block的信息

- <https://solana.com/docs/rpc/http/getblocks>

```shell
curl https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
    {
        "jsonrpc": "2.0", "id": 1,
        "method": "getBlocks",
        "params": [
            174302734, 174302735
        ]
    }
    '
{"jsonrpc":"2.0","result":[174302734,174302735],"id":1}
```

#### 分页获取Block

- <https://solana.com/docs/rpc/http/getblockswithlimit>

```shell
curl https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
  {
    "jsonrpc": "2.0",
    "id":1,
    "method":"getBlocksWithLimit",
    "params":[174302734, 3]
  }
'
{"jsonrpc":"2.0","result":[174302734,174302735,174302736],"id":1}
```

### Slot和Epoch相关接口

#### 获取当前Epoch信息

epoch在一般POS中比较常见，表示这个周期内，一些参与验证的节点信息是固定的，如果有新 节点或者节点权重变更，将在下一个epoch中生效。

- <https://solana.com/docs/rpc/http/getepochinfo>

```shell
curl https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
    {"jsonrpc":"2.0","id":1, "method":"getEpochInfo"}
    '
{"jsonrpc":"2.0","result":{"absoluteSlot":280331471,"blockHeight":268627796,"epoch":648,"slotIndex":395471,"slotsInEpoch":432000,"transactionCount":13011134475},"id":1}
```

#### 获取Epoch的调度信息

- <https://solana.com/docs/rpc/http/getepochschedule>

```shell
curl https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
    {
        "jsonrpc":"2.0","id":1,
        "method":"getEpochSchedule"
    }
    '
{"jsonrpc":"2.0","result":{"firstNormalEpoch":0,"firstNormalSlot":0,"leaderScheduleSlotOffset":432000,"slotsPerEpoch":432000,"warmup":false},"id":1}
```

#### 获取最新Slot

- <https://solana.com/docs/rpc/http/getslot>

```shell
curl https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
        {"jsonrpc":"2.0","id":1, "method":"getSlot"}
    '
{"jsonrpc":"2.0","result":280333661,"id":1}
```

### 账号相关接口

#### 获取Account信息

- <https://solana.com/docs/rpc/http/getaccountinfo>

```shell
curl https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
    {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "getAccountInfo",
        "params": [
            "6SWBzQWZndeaCKg3AzbY3zkvapCu9bHFZv12iiRoGvCD",
            {
                "encoding": "base58",
                "commitment": "finalized"
            }
        ]
    }
    '
{"jsonrpc":"2.0","result":{"context":{"apiVersion":"1.17.21","slot":280334128},"value":{"data":["","base58"],"executable":false,"lamports":1984429840,"owner":"11111111111111111111111111111111","rentEpoch":18446744073709551615,"space":0}},"id":1}
```

"executable"表示 是否为可执行合约

"lamports"表示余额，这里精度*10^9

所有普通账号的Owner都是系统根账号： "11111111111111111111111111111111"

#### 获取账号余额

- <https://solana.com/docs/rpc/http/getbalance>

```shell
curl https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
    {
        "jsonrpc": "2.0", "id": 1,
        "method": "getBalance",
        "params": [
            "6SWBzQWZndeaCKg3AzbY3zkvapCu9bHFZv12iiRoGvCD"
        ]
    }
    '
{"jsonrpc":"2.0","result":{"context":{"apiVersion":"1.17.21","slot":280334989},"value":1984429840},"id":1}
```

#### 获取某个合约管理的所有Account

- <https://solana.com/docs/rpc/http/getprogramaccounts>

```shell
curl  https://api.devnet.solana.com  -X POST -H "Content-Type: application/json" -d '
        {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "getProgramAccounts",
            "params": [
            "namesLPneVptA9Z5rqUDD9tMTWEJwofgaYwp8cawRkX",
            {
                "encoding": "jsonParsed",
                "filters": [
                {
                    "dataSize": 128
                }
                ]
            }
            ]
        }
    '
```

### SPL-Token相关接口

#### 获取某个Token Account账号的余额

```shell
curl  https://api.devnet.solana.com  -X POST -H "Content-Type: application/json" -d '
        {
            "jsonrpc": "2.0", "id": 1,
            "method": "getTokenAccountBalance",
            "params": [
                "HDv1RgdHjrjSdnTFJsMqQGPcKTiuF7zLjhNaSd7ihbKh"
            ]
        }
    '
{"jsonrpc":"2.0","result":{"context":{"apiVersion":"1.17.21","slot":280346391},"value":{"amount":"90000000000","decimals":9,"uiAmount":90.0,"uiAmountString":"90"}},"id":1}
```

### 交易相关接口

#### 返回分类账中的当前交易计数

- <https://solana.com/docs/rpc/http/gettransactioncount>

```shell
curl https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
  {"jsonrpc":"2.0","id":1, "method":"getTransactionCount"}
'
{"jsonrpc":"2.0","result":13011550533,"id":1}
```

#### 返回已确认交易的交易详细信息

- <https://solana.com/docs/rpc/http/gettransaction>

```shell
curl https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
  {
    "jsonrpc": "2.0",
    "id": 1,
    "method": "getTransaction",
    "params": [
      "4jbcoJYS6ZGPcUmHpqTnxeLHfQxvUqQQnzgoJCgWWA1LpKkKWRA5y2FZ7rDQ2v4NBBcuUJqh37A9p92mvbTmS6iY",
      "json"
    ]
  }
'
{"jsonrpc":"2.0","result":{"blockTime":1708498774,"meta":{"computeUnitsConsumed":26670,"err":null,"fee":5000,"innerInstructions":[{"index":0,"instructions":[{"accounts":[6],"data":"84eT","programIdIndex":4,"stackHeight":2},{"accounts":[0,2],"data":"11119os1e9qSs2u7TsThXqkBSRVFxhmYaFKFZ1waB2X7armDmvK3p5GmLdUxYdg3h7QSrL","programIdIndex":3,"stackHeight":2},{"accounts":[2],"data":"P","programIdIndex":4,"stackHeight":2},{"accounts":[2,6],"data":"6dE9a3kQ4bw3BRvx61TGMGrZBgsnwYEPx2MMEsN75K3Ui","programIdIndex":4,"stackHeight":2}]}],"loadedAddresses":{"readonly":[],"writable":[]},"logMessages":["Program ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL invoke [1]","Program log: CreateIdempotent","Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA invoke [2]","Program log: Instruction: GetAccountDataSize","Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA consumed 1595 of 394517 compute units","Program return: TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA pQAAAAAAAAA=","Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA success","Program 11111111111111111111111111111111 invoke [2]","Program 11111111111111111111111111111111 success","Program log: Initialize the associated token account","Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA invoke [2]","Program log: Instruction: InitializeImmutableOwner","Program log: Please upgrade to SPL Token 2022 for immutable owner support","Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA consumed 1405 of 387904 compute units","Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA success","Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA invoke [2]","Program log: Instruction: InitializeAccount3","Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA consumed 4214 of 384020 compute units","Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA success","Program ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL consumed 20498 of 400000 compute units","Program ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL success","Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA invoke [1]","Program log: Instruction: TransferChecked","Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA consumed 6172 of 379502 compute units","Program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA success"],"postBalances":[1984429840,2039280,2039280,1,934087680,731913600,1461600,10000000],"postTokenBalances":[{"accountIndex":1,"mint":"E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx","owner":"6SWBzQWZndeaCKg3AzbY3zkvapCu9bHFZv12iiRoGvCD","programId":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","uiTokenAmount":{"amount":"90000000000","decimals":9,"uiAmount":90.0,"uiAmountString":"90"}},{"accountIndex":2,"mint":"E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx","owner":"H6Su7YsGK5mMASrZvJ51nt7oBzD88V8FKSBPNnRG1u3k","programId":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","uiTokenAmount":{"amount":"10000000000","decimals":9,"uiAmount":10.0,"uiAmountString":"10"}}],"preBalances":[1986474120,2039280,0,1,934087680,731913600,1461600,10000000],"preTokenBalances":[{"accountIndex":1,"mint":"E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx","owner":"6SWBzQWZndeaCKg3AzbY3zkvapCu9bHFZv12iiRoGvCD","programId":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","uiTokenAmount":{"amount":"100000000000","decimals":9,"uiAmount":100.0,"uiAmountString":"100"}}],"rewards":[],"status":{"Ok":null}},"slot":280114248,"transaction":{"message":{"accountKeys":["6SWBzQWZndeaCKg3AzbY3zkvapCu9bHFZv12iiRoGvCD","HDv1RgdHjrjSdnTFJsMqQGPcKTiuF7zLjhNaSd7ihbKh","HY1GfCQabyUMFRGpDu3eFoVW3ny8ifHKVZ8LbvzbDPsK","11111111111111111111111111111111","TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL","E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx","H6Su7YsGK5mMASrZvJ51nt7oBzD88V8FKSBPNnRG1u3k"],"header":{"numReadonlySignedAccounts":0,"numReadonlyUnsignedAccounts":5,"numRequiredSignatures":1},"instructions":[{"accounts":[0,2,7,6,3,4],"data":"2","programIdIndex":5,"stackHeight":null},{"accounts":[1,6,2,0],"data":"g7c6qhYoikLGp","programIdIndex":4,"stackHeight":null}],"recentBlockhash":"4Y34ks76nadvQXmcbFAX1XmkegHHsQMA1sM4cA3CqYL9"},"signatures":["4jbcoJYS6ZGPcUmHpqTnxeLHfQxvUqQQnzgoJCgWWA1LpKkKWRA5y2FZ7rDQ2v4NBBcuUJqh37A9p92mvbTmS6iY"]}},"id":1}
```

## 推送RPC

- accountSubscribe : 订阅Account的变化，比如lamports
- logsSubscribe : 订阅交易的日志
- programSubscribe ： 订阅合约Account的变化
- signatureSubscribe : 订阅签名状态变化
- slotSubscribe : 订阅slot的变化

每个事件，还有对应的Unsubscribe动作，取消订阅。将上面的Subscribe替换成Unsubscribe即可。

安装wscat

```shell
npm install -g ws wscat
```

建立连接

```shell
wscat -c wss://api.devnet.solana.com
```

- <https://websocketking.com/>
- <https://solana.com/docs/rpc/websocket>

### 订阅合约所属于Account事件

```shell
{
        "jsonrpc": "2.0",
        "id": 1,
        "method": "programSubscribe",
        "params": [
            "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
            {
            "encoding": "jsonParsed"
            }
        ]
    }
```

![image-20240222154944082](assets/image-20240222154944082.png)

## 练习

通过curl和wscat命令行来模拟一个监视钱包动作

### 创建账号

- SOL账号： 6SWBzQWZndeaCKg3AzbY3zkvapCu9bHFZv12iiRoGvCD
- SPL-Token(Mint Account): E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx
- Token Account: HDv1RgdHjrjSdnTFJsMqQGPcKTiuF7zLjhNaSd7ihbKh

### 实时展示余额变化（订阅SOL余额变化）

- <https://solana.com/docs/rpc/websocket/accountsubscribe>

#### 获取1sol

```shell
solana airdrop 1
Requesting airdrop of 1 SOL

Signature: 4ZWQHwNYVWcs6THZ5A3C6ccHfovJi3HVgZ55LV8NAcZA95iLjyX9Ey6cUnGV7T4JnZnv97443kQ94pKkDG4x7K7Y

2.98442984 SOL
```

#### 订阅Account变化

```shell
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "accountSubscribe",
  "params": [
    "6SWBzQWZndeaCKg3AzbY3zkvapCu9bHFZv12iiRoGvCD",
    {
      "encoding": "jsonParsed",
      "commitment": "finalized"
    }
  ]
}
```

![image-20240222160607354](assets/image-20240222160607354.png)

### 列出已知SPL-Token的余额

```shell
spl-token balance E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx
90
```

获取SPL-Token下有多少 Token Account:

```shell
curl  https://api.devnet.solana.com -X POST -H "Content-Type: application/json" -d '
        {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "getTokenAccountsByOwner",
            "params": [
            "6SWBzQWZndeaCKg3AzbY3zkvapCu9bHFZv12iiRoGvCD",
            {
                "mint": "E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx"
            },
            {
                "encoding": "jsonParsed"
            }
            ]
        }
    '
{"jsonrpc":"2.0","result":{"context":{"apiVersion":"1.17.21","slot":280355742},"value":[{"account":{"data":{"parsed":{"info":{"isNative":false,"mint":"E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx","owner":"6SWBzQWZndeaCKg3AzbY3zkvapCu9bHFZv12iiRoGvCD","state":"initialized","tokenAmount":{"amount":"90000000000","decimals":9,"uiAmount":90.0,"uiAmountString":"90"}},"type":"account"},"program":"spl-token","space":165},"executable":false,"lamports":2039280,"owner":"TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA","rentEpoch":18446744073709551615,"space":165},"pubkey":"HDv1RgdHjrjSdnTFJsMqQGPcKTiuF7zLjhNaSd7ihbKh"}]},"id":1}
```

### 实时展示SPL-Token余额变化

```shell
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "accountSubscribe",
  "params": [
    "HDv1RgdHjrjSdnTFJsMqQGPcKTiuF7zLjhNaSd7ihbKh",
    {
      "encoding": "jsonParsed",
      "commitment": "finalized"
    }
  ]
}
```

#### 转账交易

```shell
spl-token transfer --fund-recipient E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx 1 H6Su7YsGK5mMASrZvJ51nt7oBzD88V8FKSBPNnRG1u3k
Transfer 1 tokens
  Sender: HDv1RgdHjrjSdnTFJsMqQGPcKTiuF7zLjhNaSd7ihbKh
  Recipient: H6Su7YsGK5mMASrZvJ51nt7oBzD88V8FKSBPNnRG1u3k
  Recipient associated token account: HY1GfCQabyUMFRGpDu3eFoVW3ny8ifHKVZ8LbvzbDPsK

Signature: 4WeFPgn7VGbXVqgmtspeKYm38PE9NqxjFfXxZg9QAiy8f5Um7Q3n8hWgiGnzV3SBXdQ7SHGVF22X2pTxpQbwTwGU


spl-token transfer --fund-recipient E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx 1 H6Su7YsGK5mMASrZvJ51nt7oBzD88V8FKSBPNnRG1u3k
Transfer 1 tokens
  Sender: HDv1RgdHjrjSdnTFJsMqQGPcKTiuF7zLjhNaSd7ihbKh
  Recipient: H6Su7YsGK5mMASrZvJ51nt7oBzD88V8FKSBPNnRG1u3k
  Recipient associated token account: HY1GfCQabyUMFRGpDu3eFoVW3ny8ifHKVZ8LbvzbDPsK

Signature: 5gamUZFLAiXraD3DCQ9XEyaqodDX6iQuvLqapyeLokbdot4HAQEqUvBndXgr1uXa6owcR5YaG7BT5i5d6bEQUMwv

```

***注意：转账2次，第一次监听连接断开故没有监控到。***

#### 查询余额

```shell
spl-token balance E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx
88
```

#### websocket 监控收到

```shell
{
  "jsonrpc": "2.0",
  "method": "accountNotification",
  "params": {
    "result": {
      "context": {
        "slot": 280357854
      },
      "value": {
        "lamports": 2039280,
        "data": {
          "program": "spl-token",
          "parsed": {
            "info": {
              "isNative": false,
              "mint": "E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx",
              "owner": "6SWBzQWZndeaCKg3AzbY3zkvapCu9bHFZv12iiRoGvCD",
              "state": "initialized",
              "tokenAmount": {
                "amount": "88000000000",
                "decimals": 9,
                "uiAmount": 88,
                "uiAmountString": "88"
              }
            },
            "type": "account"
          },
          "space": 165
        },
        "owner": "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA",
        "executable": false,
        "rentEpoch": 18446744073709552000,
        "space": 165
      }
    },
    "subscription": 601464
  }
}
```

![image-20240222162859547](assets/image-20240222162859547.png)
