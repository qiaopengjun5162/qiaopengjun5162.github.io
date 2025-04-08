+++
title = "Web3 实践：Sui 区块链交易全流程解析与实战指南"
description = "Web3 实践：Sui 区块链交易全流程解析与实战指南"
date = 2025-04-07 22:52:52+08:00
[taxonomies]
categories = ["Web3", "Sui", "区块链", "Move"]
tags = ["Web3", "Sui", "区块链", "Move", "交易"]
+++

<!-- more -->

# Web3 实践：Sui 区块链交易全流程解析与实战指南

在 Web3 浪潮席卷全球的今天，Sui 作为一个高性能的 Layer 1 区块链，以其创新的对象模型和高效的交易处理能力，成为开发者关注的焦点。如何在 Sui 上完成一笔交易？从环境配置到签名执行，每一步都隐藏着 Web3 开发的奥秘。本文将通过一个实战案例，带你完整解析 Sui 区块链交易的全流程。无论你是 Web3 新手，还是希望深入探索区块链技术的开发者，这份指南都将为你打开 Sui 的大门，助你在 Web3 世界中更进一步！

本文以 Web3 实践为视角，基于 Sui 测试网，系统展示了区块链交易的全流程：从配置客户端环境、查询钱包对象，到获取 Gas 价格、估算 Budget，再到签名并执行交易，每一步都配有详细代码和 API 调用示例（如 suix_getOwnedObjects、sui_dryRunTransactionBlock 等）。通过这一过程，读者不仅能掌握 Sui 交易的核心机制，还能理解 Gas 管理的精妙设计。此外，文章还介绍了如何通过浏览器和命令行验证交易结果，为 Web3 开发者提供了一份实用且可操作的参考指南。

## 实操

### **列出当前配置的所有 Sui 客户端环境**

```bash
➜ sui client envs          
╭─────────┬─────────────────────────────────────┬────────╮
│ alias   │ url                                 │ active │
├─────────┼─────────────────────────────────────┼────────┤
│ devnet  │ https://fullnode.devnet.sui.io:443  │        │
│ mainnet │ https://fullnode.mainnet.sui.io:443 │        │
│ testnet │ https://fullnode.testnet.sui.io:443 │ *      │
╰─────────┴─────────────────────────────────────┴────────╯
```

### **查看当前活跃的 Sui 钱包地址**

```bash
➜ sui client active-address
0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73
```

### 第一步：获取地址拥有的对象列表 `suix_getOwnedObjects`

<https://docs.sui.io/sui-api-ref#suix_getownedobjects>

Request：

```curl
curl --location 'https://fullnode.testnet.sui.io:443' \
--header 'Content-Type: application/json' \
--data '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "suix_getOwnedObjects",
    "params": [
        "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
    ]
}'


{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "suix_getOwnedObjects",
    "params": [
        "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
        {
            "filter": {
                "MatchAll": [
                    {
                        "StructType": "0x2::coin::Coin<0x2::sui::SUI>"
                    }
                ]
            },
            "options": {
                "showType": true,
                "showOwner": true,
                "showPreviousTransaction": true,
                "showDisplay": false,
                "showContent": false,
                "showBcs": false,
                "showStorageRebate": false
            }
        }
    ]
}
```

Response：

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "data": [
            {
                "data": {
                    "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                    "version": "370791516",
                    "digest": "2iVkTf7XpjF6XJDAh5ztZdTmm1sKDGtTLjZoo8VJJ1HT",
                    "type": "0x2::coin::Coin<0x2::sui::SUI>",
                    "owner": {
                        "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                    },
                    "previousTransaction": "9k7z6BYe1pckcqcf4Mnpt3HsBmdNEAMW6vdUpP1YEiPT"
                }
            }
        ],
        "nextCursor": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
        "hasNextPage": false
    }
}
```

### 第二步：获取网络的参考气体价格 `suix_getReferenceGasPrice`

<https://docs.sui.io/sui-api-ref#suix_getreferencegasprice>

Request：

```curl
curl --location 'https://fullnode.testnet.sui.io:443' \
--header 'Content-Type: application/json' \
--data '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "suix_getReferenceGasPrice",
    "params": []
}'
```

Response：

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": "1000"
}
```

### 第三步：通过`sui_dryRunTransactionBlock`接口获取`gasBudget`

#### 通过`signSuiDryRunTransaction`方法获取请求参数

```ts
export const signSuiDryRunTransaction = async (requestParams: SignDryRequestParams): Promise<string> => {
    const { gasPrice, privateKey, coinRefs, network, recipients } = requestParams;
    const keypair = Ed25519Keypair.fromSecretKey(privateKey);
    const tx = new Transaction();
    tx.setGasPayment(coinRefs);
    tx.setGasPrice(gasPrice);
    tx.setSender(keypair.toSuiAddress());

    const coins = tx.splitCoins(
        tx.gas,
        recipients.map((transfer) => transfer.amount),
    );
    recipients.forEach((transfer, index) => {
        tx.transferObjects([coins[index]], transfer.to);
    });

    const client = new SuiClient({ url: getFullnodeUrl(network) });
    const bytes = await tx.build({ client });

    const { signature } = await keypair.signTransaction(bytes);

    await verifyTransactionSignature(bytes, signature, {
        address: keypair.getPublicKey().toSuiAddress(),
    });

    return JSON.stringify([
        toBase64(bytes),
        signature
    ]);
}
```

测试获取响应结果

注意：这里的 `gasPrice` 参数是通过`suix_getReferenceGasPrice`接口获取的！

```ts
test('signSuiDryRunTransaction', async () => {
    const requestParams: SignDryRequestParams = {
        "network": 'testnet',
        "gasPrice": 1000,
        "privateKey": config.privateKey,
        "coinRefs": [
            {
                "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                "version": "370791516",
                "digest": "2iVkTf7XpjF6XJDAh5ztZdTmm1sKDGtTLjZoo8VJJ1HT"
            }
        ],
        "recipients": [
            {

                "to": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0",
                "amount": 1000000000
            },
            {

                "to": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "amount": 1000000000
            }
        ],
    }
    const result = await signSuiDryRunTransaction(requestParams);

    console.log("signSuiDryRunTransaction result", result);
    expect(result).toBeDefined();
    expect(result).toBeTruthy();
})
```

#### 通过`sui_dryRunTransactionBlock`接口获取`gasBudget`

<https://docs.sui.io/sui-api-ref#sui_dryruntransactionblock>

##### Request

```curl
curl --location 'https://fullnode.testnet.sui.io:443' \
--header 'Content-Type: application/json' \
--data '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "sui_dryRunTransactionBlock",
    "params": ["AAAEAAgAypo7AAAAAAAIAMqaOwAAAAAAIGUYz8SFTrixdcQG4l4W5QQs+EpskcbuqUhe6+sY303wACA1NwhB0uabSVseL5RKMIfkJC8xTlA2kaALBU4O4qRacwMCAAIBAAABAQABAQMAAAAAAQIAAQEDAAABAAEDADU3CEHS5ptJWx4vlEowh+QkLzFOUDaRoAsFTg7ipFpzAQmuEH+LA+Ape9hBnZq6nMM1jdY4yjqNfPfGDePA61HtXNQZFgAAAAAgGX0BzViCn52t/baPoqxteNOtkuCoKxjlR40X/Gm6+LI1NwhB0uabSVseL5RKMIfkJC8xTlA2kaALBU4O4qRac+gDAAAAAAAAoL5LAAAAAAAA","AKFt8+9hwQhlJn6FIu9RaiIah+u2Kq2zYSkgnrmK75BxSa+kGz/m8QFVDZkM8xIPhzDvk/MoVtBdAYqMoMeW/Am1ZfqGa5xKV6y2LkYtlTyrg+f09ewHe7GjVnlegZPtAg=="]
}'


{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "sui_dryRunTransactionBlock",
    "params": ["AAAEAAgAypo7AAAAAAAIAMqaOwAAAAAAIGUYz8SFTrixdcQG4l4W5QQs+EpskcbuqUhe6+sY303wACA1NwhB0uabSVseL5RKMIfkJC8xTlA2kaALBU4O4qRacwMCAAIBAAABAQABAQMAAAAAAQIAAQEDAAABAAEDADU3CEHS5ptJWx4vlEowh+QkLzFOUDaRoAsFTg7ipFpzAQmuEH+LA+Ape9hBnZq6nMM1jdY4yjqNfPfGDePA61HtXNQZFgAAAAAgGX0BzViCn52t/baPoqxteNOtkuCoKxjlR40X/Gm6+LI1NwhB0uabSVseL5RKMIfkJC8xTlA2kaALBU4O4qRac+gDAAAAAAAAoL5LAAAAAAAA","AKFt8+9hwQhlJn6FIu9RaiIah+u2Kq2zYSkgnrmK75BxSa+kGz/m8QFVDZkM8xIPhzDvk/MoVtBdAYqMoMeW/Am1ZfqGa5xKV6y2LkYtlTyrg+f09ewHe7GjVnlegZPtAg=="]
}
```

##### Response

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "effects": {
            "messageVersion": "v1",
            "status": {
                "status": "success"
            },
            "executedEpoch": "697",
            "gasUsed": {
                "computationCost": "1000000",
                "storageCost": "2964000",
                "storageRebate": "978120",
                "nonRefundableStorageFee": "9880"
            },
            "modifiedAtVersions": [
                {
                    "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                    "sequenceNumber": "370791516"
                }
            ],
            "transactionDigest": "3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD",
            "created": [
                {
                    "owner": {
                        "AddressOwner": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0"
                    },
                    "reference": {
                        "objectId": "0x2890a83af153402a01a98653ec13c3b0de02ab5e0beef72e43210a3f920625af",
                        "version": 370791517,
                        "digest": "4jCB7GNeeyjzyKu9U9CmfYxBkKkDP5mr17GAeUTkKTsx"
                    }
                },
                {
                    "owner": {
                        "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                    },
                    "reference": {
                        "objectId": "0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a",
                        "version": 370791517,
                        "digest": "FRUP5KBKXGBZe19zCnBe2dc8rvD9fHks6VvCzJRHmxtf"
                    }
                }
            ],
            "mutated": [
                {
                    "owner": {
                        "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                    },
                    "reference": {
                        "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                        "version": 370791517,
                        "digest": "2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br"
                    }
                }
            ],
            "gasObject": {
                "owner": {
                    "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                },
                "reference": {
                    "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                    "version": 370791517,
                    "digest": "2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br"
                }
            },
            "dependencies": [
                "9k7z6BYe1pckcqcf4Mnpt3HsBmdNEAMW6vdUpP1YEiPT"
            ]
        },
        "events": [],
        "objectChanges": [
            {
                "type": "mutated",
                "sender": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "owner": {
                    "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                },
                "objectType": "0x2::coin::Coin<0x2::sui::SUI>",
                "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                "version": "370791517",
                "previousVersion": "370791516",
                "digest": "2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br"
            },
            {
                "type": "created",
                "sender": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "owner": {
                    "AddressOwner": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0"
                },
                "objectType": "0x2::coin::Coin<0x2::sui::SUI>",
                "objectId": "0x2890a83af153402a01a98653ec13c3b0de02ab5e0beef72e43210a3f920625af",
                "version": "370791517",
                "digest": "4jCB7GNeeyjzyKu9U9CmfYxBkKkDP5mr17GAeUTkKTsx"
            },
            {
                "type": "created",
                "sender": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "owner": {
                    "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                },
                "objectType": "0x2::coin::Coin<0x2::sui::SUI>",
                "objectId": "0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a",
                "version": "370791517",
                "digest": "FRUP5KBKXGBZe19zCnBe2dc8rvD9fHks6VvCzJRHmxtf"
            }
        ],
        "balanceChanges": [
            {
                "owner": {
                    "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                },
                "coinType": "0x2::sui::SUI",
                "amount": "-1002985880"
            },
            {
                "owner": {
                    "AddressOwner": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0"
                },
                "coinType": "0x2::sui::SUI",
                "amount": "1000000000"
            }
        ],
        "input": {
            "messageVersion": "v1",
            "transaction": {
                "kind": "ProgrammableTransaction",
                "inputs": [
                    {
                        "type": "pure",
                        "valueType": "u64",
                        "value": "1000000000"
                    },
                    {
                        "type": "pure",
                        "valueType": "u64",
                        "value": "1000000000"
                    },
                    {
                        "type": "pure",
                        "valueType": "address",
                        "value": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0"
                    },
                    {
                        "type": "pure",
                        "valueType": "address",
                        "value": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                    }
                ],
                "transactions": [
                    {
                        "SplitCoins": [
                            "GasCoin",
                            [
                                {
                                    "Input": 0
                                },
                                {
                                    "Input": 1
                                }
                            ]
                        ]
                    },
                    {
                        "TransferObjects": [
                            [
                                {
                                    "NestedResult": [
                                        0,
                                        0
                                    ]
                                }
                            ],
                            {
                                "Input": 2
                            }
                        ]
                    },
                    {
                        "TransferObjects": [
                            [
                                {
                                    "NestedResult": [
                                        0,
                                        1
                                    ]
                                }
                            ],
                            {
                                "Input": 3
                            }
                        ]
                    }
                ]
            },
            "sender": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
            "gasData": {
                "payment": [
                    {
                        "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                        "version": 370791516,
                        "digest": "2iVkTf7XpjF6XJDAh5ztZdTmm1sKDGtTLjZoo8VJJ1HT"
                    }
                ],
                "owner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "price": "1000",
                "budget": "4964000"
            }
        },
        "executionErrorSource": null
    }
}
```

budget = 4964000

### 第四步：调用`signSuiTransaction`方法获取请求参数

```ts
const signSuiTransaction = async (requestParams: SignRequestParams): Promise<string> => {
    const { gasBudget, gasPrice, privateKey, coinRefs, network, recipients } = requestParams;
    // https://sdk.mystenlabs.com/typescript/cryptography/keypairs
    const keypair = Ed25519Keypair.fromSecretKey(privateKey);
    const secretKey = keypair.getSecretKey();
    console.log("secretKey: ", secretKey);

    const publicKey = keypair.getPublicKey();
    const address = publicKey.toSuiAddress();

    const tx = new Transaction();
    // https://sdk.mystenlabs.com/typescript/transaction-building/gas#gas-payment
    tx.setGasPayment(coinRefs);

    tx.setGasPrice(gasPrice);
    tx.setGasBudget(gasBudget);
    tx.setSender(keypair.toSuiAddress());

    // const [coin] = tx.splitCoins(tx.gas, [100]);
    // https://sdk.mystenlabs.com/typescript/transaction-building/basics
    const coins = tx.splitCoins(
        tx.gas,
        recipients.map((transfer) => transfer.amount),
    );
    // tx.transferObjects([coin], recipient);
    recipients.forEach((transfer, index) => {
        tx.transferObjects([coins[index]], transfer.to);
    });


    const client = new SuiClient({ url: getFullnodeUrl(network) });
    const bytes = await tx.build({ client });

    const { signature } = await keypair.signTransaction(bytes);

    await verifyTransactionSignature(bytes, signature, {
        // optionally verify that the signature is valid for a specific address
        address: keypair.getPublicKey().toSuiAddress(),
    });

    return JSON.stringify([
        toBase64(bytes),
        signature
    ]);
}
```

测试

注意：这里的 `gasPrice` 参数是通过`suix_getReferenceGasPrice`接口获取的！

注意：这里的 `gasBudget` 参数是通过`sui_dryRunTransactionBlock`接口获取的！

```ts
test('signSuiTransaction', async () => {
    const requestParams: SignRequestParams = {
        "network": 'testnet',
        "gasBudget": 4964000,
        "gasPrice": 1000,
        "privateKey": config.privateKey,
        "coinRefs": [
            {
                "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                "version": "370791516",
                "digest": "2iVkTf7XpjF6XJDAh5ztZdTmm1sKDGtTLjZoo8VJJ1HT"
            }
        ],
        "recipients": [
            {

                "to": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0",
                "amount": 1000000000
            },
            {

                "to": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "amount": 1000000000
            }
        ],
    }
    const result = await signSuiTransaction(requestParams);

    console.log("result", result);
    expect(result).toBeDefined();
    expect(result).toBeTruthy();
})
```

### 第五步：通过`sui_dryRunTransactionBlock`接口测试交易执行是否成功

sui_dryRunTransactionBlock 接口

<https://docs.sui.io/sui-api-ref#sui_dryruntransactionblock>

```curl
curl --location 'https://fullnode.testnet.sui.io:443' \
--header 'Content-Type: application/json' \
--data '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "sui_dryRunTransactionBlock",
    "params": ["AAAEAAgAypo7AAAAAAAIAMqaOwAAAAAAIGUYz8SFTrixdcQG4l4W5QQs+EpskcbuqUhe6+sY303wACA1NwhB0uabSVseL5RKMIfkJC8xTlA2kaALBU4O4qRacwMCAAIBAAABAQABAQMAAAAAAQIAAQEDAAABAAEDADU3CEHS5ptJWx4vlEowh+QkLzFOUDaRoAsFTg7ipFpzAQmuEH+LA+Ape9hBnZq6nMM1jdY4yjqNfPfGDePA61HtXNQZFgAAAAAgGX0BzViCn52t/baPoqxteNOtkuCoKxjlR40X/Gm6+LI1NwhB0uabSVseL5RKMIfkJC8xTlA2kaALBU4O4qRac+gDAAAAAAAAoL5LAAAAAAAA","AKFt8+9hwQhlJn6FIu9RaiIah+u2Kq2zYSkgnrmK75BxSa+kGz/m8QFVDZkM8xIPhzDvk/MoVtBdAYqMoMeW/Am1ZfqGa5xKV6y2LkYtlTyrg+f09ewHe7GjVnlegZPtAg=="]
}'
```

Request：

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "sui_dryRunTransactionBlock",
    "params": ["AAAEAAgAypo7AAAAAAAIAMqaOwAAAAAAIGUYz8SFTrixdcQG4l4W5QQs+EpskcbuqUhe6+sY303wACA1NwhB0uabSVseL5RKMIfkJC8xTlA2kaALBU4O4qRacwMCAAIBAAABAQABAQMAAAAAAQIAAQEDAAABAAEDADU3CEHS5ptJWx4vlEowh+QkLzFOUDaRoAsFTg7ipFpzAQmuEH+LA+Ape9hBnZq6nMM1jdY4yjqNfPfGDePA61HtXNQZFgAAAAAgGX0BzViCn52t/baPoqxteNOtkuCoKxjlR40X/Gm6+LI1NwhB0uabSVseL5RKMIfkJC8xTlA2kaALBU4O4qRac+gDAAAAAAAAoL5LAAAAAAAA","AKFt8+9hwQhlJn6FIu9RaiIah+u2Kq2zYSkgnrmK75BxSa+kGz/m8QFVDZkM8xIPhzDvk/MoVtBdAYqMoMeW/Am1ZfqGa5xKV6y2LkYtlTyrg+f09ewHe7GjVnlegZPtAg=="]
}
```

Response：

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "effects": {
            "messageVersion": "v1",
            "status": {
                "status": "success"
            },
            "executedEpoch": "697",
            "gasUsed": {
                "computationCost": "1000000",
                "storageCost": "2964000",
                "storageRebate": "978120",
                "nonRefundableStorageFee": "9880"
            },
            "modifiedAtVersions": [
                {
                    "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                    "sequenceNumber": "370791516"
                }
            ],
            "transactionDigest": "3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD",
            "created": [
                {
                    "owner": {
                        "AddressOwner": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0"
                    },
                    "reference": {
                        "objectId": "0x2890a83af153402a01a98653ec13c3b0de02ab5e0beef72e43210a3f920625af",
                        "version": 370791517,
                        "digest": "4jCB7GNeeyjzyKu9U9CmfYxBkKkDP5mr17GAeUTkKTsx"
                    }
                },
                {
                    "owner": {
                        "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                    },
                    "reference": {
                        "objectId": "0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a",
                        "version": 370791517,
                        "digest": "FRUP5KBKXGBZe19zCnBe2dc8rvD9fHks6VvCzJRHmxtf"
                    }
                }
            ],
            "mutated": [
                {
                    "owner": {
                        "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                    },
                    "reference": {
                        "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                        "version": 370791517,
                        "digest": "2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br"
                    }
                }
            ],
            "gasObject": {
                "owner": {
                    "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                },
                "reference": {
                    "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                    "version": 370791517,
                    "digest": "2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br"
                }
            },
            "dependencies": [
                "9k7z6BYe1pckcqcf4Mnpt3HsBmdNEAMW6vdUpP1YEiPT"
            ]
        },
        "events": [],
        "objectChanges": [
            {
                "type": "mutated",
                "sender": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "owner": {
                    "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                },
                "objectType": "0x2::coin::Coin<0x2::sui::SUI>",
                "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                "version": "370791517",
                "previousVersion": "370791516",
                "digest": "2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br"
            },
            {
                "type": "created",
                "sender": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "owner": {
                    "AddressOwner": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0"
                },
                "objectType": "0x2::coin::Coin<0x2::sui::SUI>",
                "objectId": "0x2890a83af153402a01a98653ec13c3b0de02ab5e0beef72e43210a3f920625af",
                "version": "370791517",
                "digest": "4jCB7GNeeyjzyKu9U9CmfYxBkKkDP5mr17GAeUTkKTsx"
            },
            {
                "type": "created",
                "sender": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "owner": {
                    "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                },
                "objectType": "0x2::coin::Coin<0x2::sui::SUI>",
                "objectId": "0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a",
                "version": "370791517",
                "digest": "FRUP5KBKXGBZe19zCnBe2dc8rvD9fHks6VvCzJRHmxtf"
            }
        ],
        "balanceChanges": [
            {
                "owner": {
                    "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                },
                "coinType": "0x2::sui::SUI",
                "amount": "-1002985880"
            },
            {
                "owner": {
                    "AddressOwner": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0"
                },
                "coinType": "0x2::sui::SUI",
                "amount": "1000000000"
            }
        ],
        "input": {
            "messageVersion": "v1",
            "transaction": {
                "kind": "ProgrammableTransaction",
                "inputs": [
                    {
                        "type": "pure",
                        "valueType": "u64",
                        "value": "1000000000"
                    },
                    {
                        "type": "pure",
                        "valueType": "u64",
                        "value": "1000000000"
                    },
                    {
                        "type": "pure",
                        "valueType": "address",
                        "value": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0"
                    },
                    {
                        "type": "pure",
                        "valueType": "address",
                        "value": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                    }
                ],
                "transactions": [
                    {
                        "SplitCoins": [
                            "GasCoin",
                            [
                                {
                                    "Input": 0
                                },
                                {
                                    "Input": 1
                                }
                            ]
                        ]
                    },
                    {
                        "TransferObjects": [
                            [
                                {
                                    "NestedResult": [
                                        0,
                                        0
                                    ]
                                }
                            ],
                            {
                                "Input": 2
                            }
                        ]
                    },
                    {
                        "TransferObjects": [
                            [
                                {
                                    "NestedResult": [
                                        0,
                                        1
                                    ]
                                }
                            ],
                            {
                                "Input": 3
                            }
                        ]
                    }
                ]
            },
            "sender": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
            "gasData": {
                "payment": [
                    {
                        "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                        "version": 370791516,
                        "digest": "2iVkTf7XpjF6XJDAh5ztZdTmm1sKDGtTLjZoo8VJJ1HT"
                    }
                ],
                "owner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "price": "1000",
                "budget": "4964000"
            }
        },
        "executionErrorSource": null
    }
}
```

### 第六步：通过`sui_executeTransactionBlock`接口发送执行交易

`sui_executeTransactionBlock`接口

<https://docs.sui.io/sui-api-ref#sui_executetransactionblock>

```curl
curl --location 'https://fullnode.testnet.sui.io:443' \
--header 'Content-Type: application/json' \
--data '{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "sui_executeTransactionBlock",
  "params": [
    "AAAEAAgAypo7AAAAAAAIAMqaOwAAAAAAIGUYz8SFTrixdcQG4l4W5QQs+EpskcbuqUhe6+sY303wACA1NwhB0uabSVseL5RKMIfkJC8xTlA2kaALBU4O4qRacwMCAAIBAAABAQABAQMAAAAAAQIAAQEDAAABAAEDADU3CEHS5ptJWx4vlEowh+QkLzFOUDaRoAsFTg7ipFpzAQmuEH+LA+Ape9hBnZq6nMM1jdY4yjqNfPfGDePA61HtXNQZFgAAAAAgGX0BzViCn52t/baPoqxteNOtkuCoKxjlR40X/Gm6+LI1NwhB0uabSVseL5RKMIfkJC8xTlA2kaALBU4O4qRac+gDAAAAAAAAoL5LAAAAAAAA",
    [
      "AKFt8+9hwQhlJn6FIu9RaiIah+u2Kq2zYSkgnrmK75BxSa+kGz/m8QFVDZkM8xIPhzDvk/MoVtBdAYqMoMeW/Am1ZfqGa5xKV6y2LkYtlTyrg+f09ewHe7GjVnlegZPtAg=="
    ],
    {
      "showInput": true,
      "showRawInput": true,
      "showEffects": true,
      "showEvents": true,
      "showObjectChanges": true,
      "showBalanceChanges": true,
      "showRawEffects": false
    },
    "WaitForLocalExecution"
  ]
}'
```

Request：

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "sui_executeTransactionBlock",
  "params": [
    "AAAEAAgAypo7AAAAAAAIAMqaOwAAAAAAIGUYz8SFTrixdcQG4l4W5QQs+EpskcbuqUhe6+sY303wACA1NwhB0uabSVseL5RKMIfkJC8xTlA2kaALBU4O4qRacwMCAAIBAAABAQABAQMAAAAAAQIAAQEDAAABAAEDADU3CEHS5ptJWx4vlEowh+QkLzFOUDaRoAsFTg7ipFpzAQmuEH+LA+Ape9hBnZq6nMM1jdY4yjqNfPfGDePA61HtXNQZFgAAAAAgGX0BzViCn52t/baPoqxteNOtkuCoKxjlR40X/Gm6+LI1NwhB0uabSVseL5RKMIfkJC8xTlA2kaALBU4O4qRac+gDAAAAAAAAoL5LAAAAAAAA",
    [
      "AKFt8+9hwQhlJn6FIu9RaiIah+u2Kq2zYSkgnrmK75BxSa+kGz/m8QFVDZkM8xIPhzDvk/MoVtBdAYqMoMeW/Am1ZfqGa5xKV6y2LkYtlTyrg+f09ewHe7GjVnlegZPtAg=="
    ],
    {
      "showInput": true,
      "showRawInput": true,
      "showEffects": true,
      "showEvents": true,
      "showObjectChanges": true,
      "showBalanceChanges": true,
      "showRawEffects": false
    },
    "WaitForLocalExecution"
  ]
}
```

Response：

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "digest": "3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD",
        "transaction": {
            "data": {
                "messageVersion": "v1",
                "transaction": {
                    "kind": "ProgrammableTransaction",
                    "inputs": [
                        {
                            "type": "pure",
                            "valueType": "u64",
                            "value": "1000000000"
                        },
                        {
                            "type": "pure",
                            "valueType": "u64",
                            "value": "1000000000"
                        },
                        {
                            "type": "pure",
                            "valueType": "address",
                            "value": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0"
                        },
                        {
                            "type": "pure",
                            "valueType": "address",
                            "value": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                        }
                    ],
                    "transactions": [
                        {
                            "SplitCoins": [
                                "GasCoin",
                                [
                                    {
                                        "Input": 0
                                    },
                                    {
                                        "Input": 1
                                    }
                                ]
                            ]
                        },
                        {
                            "TransferObjects": [
                                [
                                    {
                                        "NestedResult": [
                                            0,
                                            0
                                        ]
                                    }
                                ],
                                {
                                    "Input": 2
                                }
                            ]
                        },
                        {
                            "TransferObjects": [
                                [
                                    {
                                        "NestedResult": [
                                            0,
                                            1
                                        ]
                                    }
                                ],
                                {
                                    "Input": 3
                                }
                            ]
                        }
                    ]
                },
                "sender": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "gasData": {
                    "payment": [
                        {
                            "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                            "version": 370791516,
                            "digest": "2iVkTf7XpjF6XJDAh5ztZdTmm1sKDGtTLjZoo8VJJ1HT"
                        }
                    ],
                    "owner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                    "price": "1000",
                    "budget": "4964000"
                }
            },
            "txSignatures": [
                "AKFt8+9hwQhlJn6FIu9RaiIah+u2Kq2zYSkgnrmK75BxSa+kGz/m8QFVDZkM8xIPhzDvk/MoVtBdAYqMoMeW/Am1ZfqGa5xKV6y2LkYtlTyrg+f09ewHe7GjVnlegZPtAg=="
            ]
        },
        "rawTransaction": "AQAAAAAABAAIAMqaOwAAAAAACADKmjsAAAAAACBlGM/EhU64sXXEBuJeFuUELPhKbJHG7qlIXuvrGN9N8AAgNTcIQdLmm0lbHi+USjCH5CQvMU5QNpGgCwVODuKkWnMDAgACAQAAAQEAAQEDAAAAAAECAAEBAwAAAQABAwA1NwhB0uabSVseL5RKMIfkJC8xTlA2kaALBU4O4qRacwEJrhB/iwPgKXvYQZ2aupzDNY3WOMo6jXz3xg3jwOtR7VzUGRYAAAAAIBl9Ac1Ygp+drf22j6KsbXjTrZLgqCsY5UeNF/xpuviyNTcIQdLmm0lbHi+USjCH5CQvMU5QNpGgCwVODuKkWnPoAwAAAAAAAKC+SwAAAAAAAAFhAKFt8+9hwQhlJn6FIu9RaiIah+u2Kq2zYSkgnrmK75BxSa+kGz/m8QFVDZkM8xIPhzDvk/MoVtBdAYqMoMeW/Am1ZfqGa5xKV6y2LkYtlTyrg+f09ewHe7GjVnlegZPtAg==",
        "effects": {
            "messageVersion": "v1",
            "status": {
                "status": "success"
            },
            "executedEpoch": "697",
            "gasUsed": {
                "computationCost": "1000000",
                "storageCost": "2964000",
                "storageRebate": "978120",
                "nonRefundableStorageFee": "9880"
            },
            "modifiedAtVersions": [
                {
                    "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                    "sequenceNumber": "370791516"
                }
            ],
            "transactionDigest": "3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD",
            "created": [
                {
                    "owner": {
                        "AddressOwner": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0"
                    },
                    "reference": {
                        "objectId": "0x2890a83af153402a01a98653ec13c3b0de02ab5e0beef72e43210a3f920625af",
                        "version": 370791517,
                        "digest": "4jCB7GNeeyjzyKu9U9CmfYxBkKkDP5mr17GAeUTkKTsx"
                    }
                },
                {
                    "owner": {
                        "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                    },
                    "reference": {
                        "objectId": "0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a",
                        "version": 370791517,
                        "digest": "FRUP5KBKXGBZe19zCnBe2dc8rvD9fHks6VvCzJRHmxtf"
                    }
                }
            ],
            "mutated": [
                {
                    "owner": {
                        "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                    },
                    "reference": {
                        "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                        "version": 370791517,
                        "digest": "2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br"
                    }
                }
            ],
            "gasObject": {
                "owner": {
                    "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                },
                "reference": {
                    "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                    "version": 370791517,
                    "digest": "2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br"
                }
            },
            "dependencies": [
                "9k7z6BYe1pckcqcf4Mnpt3HsBmdNEAMW6vdUpP1YEiPT"
            ]
        },
        "events": [],
        "objectChanges": [
            {
                "type": "mutated",
                "sender": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "owner": {
                    "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                },
                "objectType": "0x2::coin::Coin<0x2::sui::SUI>",
                "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                "version": "370791517",
                "previousVersion": "370791516",
                "digest": "2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br"
            },
            {
                "type": "created",
                "sender": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "owner": {
                    "AddressOwner": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0"
                },
                "objectType": "0x2::coin::Coin<0x2::sui::SUI>",
                "objectId": "0x2890a83af153402a01a98653ec13c3b0de02ab5e0beef72e43210a3f920625af",
                "version": "370791517",
                "digest": "4jCB7GNeeyjzyKu9U9CmfYxBkKkDP5mr17GAeUTkKTsx"
            },
            {
                "type": "created",
                "sender": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "owner": {
                    "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                },
                "objectType": "0x2::coin::Coin<0x2::sui::SUI>",
                "objectId": "0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a",
                "version": "370791517",
                "digest": "FRUP5KBKXGBZe19zCnBe2dc8rvD9fHks6VvCzJRHmxtf"
            }
        ],
        "balanceChanges": [
            {
                "owner": {
                    "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                },
                "coinType": "0x2::sui::SUI",
                "amount": "-1002985880"
            },
            {
                "owner": {
                    "AddressOwner": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0"
                },
                "coinType": "0x2::sui::SUI",
                "amount": "1000000000"
            }
        ],
        "confirmedLocalExecution": true
    }
}
```

### 第七步：在浏览器查看交易详情

<https://testnet.suivision.xyz/txblock/3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD>

![image-20250407222607296](/images/image-20250407222607296.png)

### 第八步：根据`digest`通过`sui_getTransactionBlock`接口查看交易详情

`sui_getTransactionBlock`接口

<https://docs.sui.io/sui-api-ref#sui_gettransactionblock>

Request：

```curl
curl --location 'https://fullnode.testnet.sui.io:443' \
--header 'Content-Type: application/json' \
--data '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "sui_getTransactionBlock",
    "params": [
        "3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD",
        {
            "showInput": true,
            "showRawInput": false,
            "showEffects": true,
            "showEvents": true,
            "showObjectChanges": false,
            "showBalanceChanges": false,
            "showRawEffects": false
        }
    ]
}'


{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "sui_getTransactionBlock",
    "params": [
        "3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD",
        {
            "showInput": true,
            "showRawInput": false,
            "showEffects": true,
            "showEvents": true,
            "showObjectChanges": false,
            "showBalanceChanges": false,
            "showRawEffects": false
        }
    ]
}
```

Response:

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "digest": "3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD",
        "transaction": {
            "data": {
                "messageVersion": "v1",
                "transaction": {
                    "kind": "ProgrammableTransaction",
                    "inputs": [
                        {
                            "type": "pure",
                            "valueType": "u64",
                            "value": "1000000000"
                        },
                        {
                            "type": "pure",
                            "valueType": "u64",
                            "value": "1000000000"
                        },
                        {
                            "type": "pure",
                            "valueType": "address",
                            "value": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0"
                        },
                        {
                            "type": "pure",
                            "valueType": "address",
                            "value": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                        }
                    ],
                    "transactions": [
                        {
                            "SplitCoins": [
                                "GasCoin",
                                [
                                    {
                                        "Input": 0
                                    },
                                    {
                                        "Input": 1
                                    }
                                ]
                            ]
                        },
                        {
                            "TransferObjects": [
                                [
                                    {
                                        "NestedResult": [
                                            0,
                                            0
                                        ]
                                    }
                                ],
                                {
                                    "Input": 2
                                }
                            ]
                        },
                        {
                            "TransferObjects": [
                                [
                                    {
                                        "NestedResult": [
                                            0,
                                            1
                                        ]
                                    }
                                ],
                                {
                                    "Input": 3
                                }
                            ]
                        }
                    ]
                },
                "sender": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                "gasData": {
                    "payment": [
                        {
                            "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                            "version": 370791516,
                            "digest": "2iVkTf7XpjF6XJDAh5ztZdTmm1sKDGtTLjZoo8VJJ1HT"
                        }
                    ],
                    "owner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73",
                    "price": "1000",
                    "budget": "4964000"
                }
            },
            "txSignatures": [
                "AKFt8+9hwQhlJn6FIu9RaiIah+u2Kq2zYSkgnrmK75BxSa+kGz/m8QFVDZkM8xIPhzDvk/MoVtBdAYqMoMeW/Am1ZfqGa5xKV6y2LkYtlTyrg+f09ewHe7GjVnlegZPtAg=="
            ]
        },
        "effects": {
            "messageVersion": "v1",
            "status": {
                "status": "success"
            },
            "executedEpoch": "697",
            "gasUsed": {
                "computationCost": "1000000",
                "storageCost": "2964000",
                "storageRebate": "978120",
                "nonRefundableStorageFee": "9880"
            },
            "modifiedAtVersions": [
                {
                    "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                    "sequenceNumber": "370791516"
                }
            ],
            "transactionDigest": "3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD",
            "created": [
                {
                    "owner": {
                        "AddressOwner": "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0"
                    },
                    "reference": {
                        "objectId": "0x2890a83af153402a01a98653ec13c3b0de02ab5e0beef72e43210a3f920625af",
                        "version": 370791517,
                        "digest": "4jCB7GNeeyjzyKu9U9CmfYxBkKkDP5mr17GAeUTkKTsx"
                    }
                },
                {
                    "owner": {
                        "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                    },
                    "reference": {
                        "objectId": "0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a",
                        "version": 370791517,
                        "digest": "FRUP5KBKXGBZe19zCnBe2dc8rvD9fHks6VvCzJRHmxtf"
                    }
                }
            ],
            "mutated": [
                {
                    "owner": {
                        "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                    },
                    "reference": {
                        "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                        "version": 370791517,
                        "digest": "2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br"
                    }
                }
            ],
            "gasObject": {
                "owner": {
                    "AddressOwner": "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73"
                },
                "reference": {
                    "objectId": "0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed",
                    "version": 370791517,
                    "digest": "2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br"
                }
            },
            "dependencies": [
                "9k7z6BYe1pckcqcf4Mnpt3HsBmdNEAMW6vdUpP1YEiPT"
            ]
        },
        "events": [],
        "timestampMs": "1744010886528",
        "checkpoint": "181819976"
    }
}
```

这是一个 **Sui 区块链交易的完整 JSON 响应**，包含了交易的详细信息、执行效果和相关数据。以下是对该响应的逐层解析：

#### **1. 交易概览**

| 字段            | 值/说明                                                     |
| --------------- | ----------------------------------------------------------- |
| `jsonrpc`       | JSON-RPC 协议版本 (`"2.0"`)                                 |
| `id`            | 请求 ID (`1`)                                               |
| `result.digest` | 交易哈希 (`"3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD"`) |
| `timestampMs`   | 交易时间戳 (Unix 毫秒时间戳，`"1744010886528"`)             |
| `checkpoint`    | 交易所属的检查点高度 (`"181819976"`)                        |

#### **2. 交易内容 (`transaction`)**

#### **(1) 基础信息**

- **`messageVersion`**: 交易版本 (`"v1"`)。
- **`sender`**: 交易发送者地址 (`"0x3537...5a73"`)。
- **`gasData`**: 交易的 Gas 配置：
  - `payment`: 用于支付 Gas 的 Coin 对象（`objectId` + 版本 + 摘要）。
  - `owner`: Gas 费用的支付者（与 `sender` 相同）。
  - `price`: Gas 单价 (`"1000"` MIST)。
  - `budget`: Gas 预算 (`"4964000"` MIST)。

#### **(2) 交易类型 (`kind`)**

- **`ProgrammableTransaction`**: 可编程交易（复杂操作组合）。
- **`inputs`**: 输入参数列表：
  - 两个 `u64` 类型的值 (`"1000000000"`，即 1 SUI，因为 1 SUI = 10^9 MIST)。
  - 两个接收地址 (`0x6518...4df0` 和 `0x3537...5a73`)。

- **`transactions`**: 操作步骤：
  1. **`SplitCoins`**: 从 `GasCoin` 中拆分出两个 1 SUI 的 Coin。
     - 使用输入参数 `Input 0` 和 `Input 1`（即两个 `u64` 值）。
  2. **`TransferObjects`**:
     - 将第一个拆分出的 Coin 转账到 `Input 2`（地址 `0x6518...4df0`）。
     - 将第二个拆分出的 Coin 转账到 `Input 3`（地址 `0x3537...5a73`）。

#### **(3) 签名 (`txSignatures`)**

- 签名数据（Base64 编码），用于验证交易合法性。

#### **3. 交易执行效果 (`effects`)**

##### **(1) 状态**

- **`status`**: `"success"`（交易成功）。
- **`executedEpoch`**: 执行时的纪元号 (`"697"`)。

##### **(2) Gas 消耗**

| 字段                      | 值          | 说明                         |
| ------------------------- | ----------- | ---------------------------- |
| `computationCost`         | `"1000000"` | 计算成本（MIST）             |
| `storageCost`             | `"2964000"` | 存储成本（MIST）             |
| `storageRebate`           | `"978120"`  | 存储回扣（部分存储成本返还） |
| `nonRefundableStorageFee` | `"9880"`    | 不可退还的存储费用           |

##### **(3) 对象变更**

- **`modifiedAtVersions`**: 被修改的对象的版本信息（如 Gas Coin 的版本更新）。
- **`created`**: 新创建的 Coin 对象：
  - 分别归属到两个接收地址 (`0x6518...4df0` 和 `0x3537...5a73`)。
- **`mutated`**: 被修改的对象（如 Gas Coin 因支付费用而被更新）。
- **`gasObject`**: 更新后的 Gas Coin 信息。

##### **(4) 依赖项 (`dependencies`)**

- 交易依赖的其他交易哈希（此处为 `"9k7z6BYe..."`）。

#### **4. 关键操作总结**

1. **拆分 Coin**: 从 Gas Coin 中拆分出 2 个 1 SUI 的 Coin。
2. **转账**:
   - 1 SUI → 地址 `0x6518...4df0`。
   - 1 SUI → 地址 `0x3537...5a73`（发送者自己）。
3. **支付 Gas**: 消耗约 3.96 SUI（`gasUsed` 合计），其中部分存储成本被返还。

#### **5. 实用信息**

- **SUI 单位换算**: `1 SUI = 10^9 MIST`。
  - 输入值 `"1000000000"` = 1 SUI。
- **Gas 费用计算**:
  - 总成本 = `computationCost + storageCost - storageRebate` = `1000000 + 2964000 - 978120 = 2,985,880 MIST`（约 0.0029 SUI）。

### 第九步：通过命令行**查询指定交易哈希（digest）的详细信息**

```bash
sui client tx-block -- 3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD
Transaction Digest: 3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD
╭──────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Data                                                                                             │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                                   │
│ Gas Owner: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                                │
│ Gas Budget: 4964000 MIST                                                                                     │
│ Gas Price: 1000 MIST                                                                                         │
│ Gas Payment:                                                                                                 │
│  ┌──                                                                                                         │
│  │ ID: 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed                                    │
│  │ Version: 370791516                                                                                        │
│  │ Digest: 2iVkTf7XpjF6XJDAh5ztZdTmm1sKDGtTLjZoo8VJJ1HT                                                      │
│  └──                                                                                                         │
│                                                                                                              │
│ Transaction Kind: Programmable                                                                               │
│ ╭──────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │
│ │ Input Objects                                                                                            │ │
│ ├──────────────────────────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ 0   Pure Arg: Type: u64, Value: "1000000000"                                                             │ │
│ │ 1   Pure Arg: Type: u64, Value: "1000000000"                                                             │ │
│ │ 2   Pure Arg: Type: address, Value: "0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0" │ │
│ │ 3   Pure Arg: Type: address, Value: "0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73" │ │
│ ╰──────────────────────────────────────────────────────────────────────────────────────────────────────────╯ │
│ ╭─────────────────────────╮                                                                                  │
│ │ Commands                │                                                                                  │
│ ├─────────────────────────┤                                                                                  │
│ │ 0  SplitCoins:          │                                                                                  │
│ │  ┌                      │                                                                                  │
│ │  │ Coin: GasCoin        │                                                                                  │
│ │  │ Amounts:             │                                                                                  │
│ │  │   Input  0           │                                                                                  │
│ │  │   Input  1           │                                                                                  │
│ │  └                      │                                                                                  │
│ │                         │                                                                                  │
│ │ 1  TransferObjects:     │                                                                                  │
│ │  ┌                      │                                                                                  │
│ │  │ Arguments:           │                                                                                  │
│ │  │   Nested Result 0: 0 │                                                                                  │
│ │  │ Address: Input  2    │                                                                                  │
│ │  └                      │                                                                                  │
│ │                         │                                                                                  │
│ │ 2  TransferObjects:     │                                                                                  │
│ │  ┌                      │                                                                                  │
│ │  │ Arguments:           │                                                                                  │
│ │  │   Nested Result 0: 1 │                                                                                  │
│ │  │ Address: Input  3    │                                                                                  │
│ │  └                      │                                                                                  │
│ ╰─────────────────────────╯                                                                                  │
│                                                                                                              │
│ Signatures:                                                                                                  │
│    oW3z72HBCGUmfoUi71FqIhqH67YqrbNhKSCeuYrvkHFJr6QbP+bxAVUNmQzzEg+HMO+T8yhW0F0Bioygx5b8CQ==                  │
│                                                                                                              │
╰──────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Effects                                                                               │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Digest: 3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD                                              │
│ Status: Success                                                                                   │
│ Executed Epoch: 697                                                                               │
│                                                                                                   │
│ Created Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0x2890a83af153402a01a98653ec13c3b0de02ab5e0beef72e43210a3f920625af                         │
│  │ Owner: Account Address ( 0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0 )  │
│  │ Version: 370791517                                                                             │
│  │ Digest: 4jCB7GNeeyjzyKu9U9CmfYxBkKkDP5mr17GAeUTkKTsx                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 370791517                                                                             │
│  │ Digest: FRUP5KBKXGBZe19zCnBe2dc8rvD9fHks6VvCzJRHmxtf                                           │
│  └──                                                                                              │
│ Mutated Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 370791517                                                                             │
│  │ Digest: 2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br                                           │
│  └──                                                                                              │
│ Gas Object:                                                                                       │
│  ┌──                                                                                              │
│  │ ID: 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 370791517                                                                             │
│  │ Digest: 2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br                                           │
│  └──                                                                                              │
│ Gas Cost Summary:                                                                                 │
│    Storage Cost: 2964000 MIST                                                                     │
│    Computation Cost: 1000000 MIST                                                                 │
│    Storage Rebate: 978120 MIST                                                                    │
│    Non-refundable Storage Fee: 9880 MIST                                                          │
│                                                                                                   │
│ Transaction Dependencies:                                                                         │
│    9k7z6BYe1pckcqcf4Mnpt3HsBmdNEAMW6vdUpP1YEiPT                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─────────────────────────────╮
│ No transaction block events │
╰─────────────────────────────╯

╭──────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                   │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0x2890a83af153402a01a98653ec13c3b0de02ab5e0beef72e43210a3f920625af                  │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                    │
│  │ Owner: Account Address ( 0x6518cfc4854eb8b175c406e25e16e5042cf84a6c91c6eea9485eebeb18df4df0 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 370791517                                                                            │
│  │ Digest: 4jCB7GNeeyjzyKu9U9CmfYxBkKkDP5mr17GAeUTkKTsx                                          │
│  └──                                                                                             │
│  ┌──                                                                                             │
│  │ ObjectID: 0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a                  │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                    │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 370791517                                                                            │
│  │ Digest: FRUP5KBKXGBZe19zCnBe2dc8rvD9fHks6VvCzJRHmxtf                                          │
│  └──                                                                                             │
│ Mutated Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed                  │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                    │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 370791517                                                                            │
│  │ Digest: 2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br                                          │
│  └──                                                                                             │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
```

## 总结

通过这次 Web3 实践，我们在 Sui 测试网上完成了一笔交易的完整旅程：从环境搭建到对象查询，再到 Gas 估算、交易签名与执行，每一个环节都体现了 Sui 区块链的高效与灵活。交易成功后，我们借助 sui_executeTransactionBlock 确认结果，并在浏览器与命令行中验证了交易细节，充分展示了 Web3 技术开发的魅力。对于初探 Web3 的你，这不仅是一次技术的试炼，更是一次对 Sui 潜力的窥探。未来，基于此流程，你可以进一步解锁 Sui 的智能合约与去中心化应用开发，迈向 Web3 的更广阔舞台！

## 参考

- <https://docs.sui.io/sui-api-ref#suix_getallbalances>
- <https://medium.com/sui-network-cn/sui%E4%B8%BB%E7%BD%91%E5%85%AC%E7%94%A8rpc%E8%8A%82%E7%82%B9-d324ad0d563a>
- <https://suivision.xyz/>
- <https://docs.sui.io/references/framework/sui/sui>
- <https://docs.sui.io/concepts/tokenomics/staking-unstaking>
- <https://sdk.mystenlabs.com/typescript/hello-sui>
- <https://sdk.mystenlabs.com/typescript/transaction-building/basics>
- <https://docs.sui.io/sui-api-ref#suix_getownedobjects>
- <https://testnet.suivision.xyz/txblock/3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD>
- <https://sdk.mystenlabs.com/typescript/transaction-building/gas>
- <https://docs.sui.io/concepts/tokenomics/gas-in-sui>
- <https://testnet.suivision.xyz/txblock/9k7z6BYe1pckcqcf4Mnpt3HsBmdNEAMW6vdUpP1YEiPT>
