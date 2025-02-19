+++
title = "Web3与Solana实操指南：如何签名与发送交易"
description = "Web3与Solana实操指南：如何签名与发送交易"
date = 2025-02-18 22:26:25+08:00
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# Web3与Solana实操指南：如何签名与发送交易

Web3技术作为新一代互联网的核心架构，正在快速改变着传统的网络生态。而Solana作为一种高效、快速的区块链平台，已经成为众多开发者的首选。在这篇文章中，我们将通过实际操作，带你深入了解如何在Solana网络上进行Web3交易。我们将介绍如何生成和签名Solana交易，以及如何发送交易并查看其状态，为你的Solana开发之旅提供实用的参考。

本文将详细阐述如何在Solana网络上进行交易操作，涵盖以下几个方面：

1. Solana交易签名：介绍如何通过编程签名Solana交易，包括如何使用私钥和交易参数生成交易。
2. 获取最新区块哈希：通过API获取Solana的最新区块哈希，作为交易的有效性验证。
3. 执行交易发送：通过sendTransaction方法发送已签名的交易，并返回交易结果。
4. 交易查看与确认：介绍如何通过Solana区块浏览器查看交易的状态，确认交易是否成功。

通过这些步骤，你将能够更好地理解Solana的交易流程，并将这些知识应用于实际开发中，提升Web3应用的开发效率。

## 实操

### 第一步：实现`signSolTransaction` 代码

```ts
export async function signSolTransaction(params: any) {
    const {
        txObj: { from, amount, to, nonce, decimal },
        privateKey,
    } = params;
    if (!privateKey) throw new Error("privateKey 为空");
    const fromAccount = Keypair.fromSecretKey(new Uint8Array(Buffer.from(privateKey, "hex")));

    const calcAmount = new BigNumber(amount).times(new BigNumber(10).pow(decimal)).toNumber();
    if (calcAmount.toString().indexOf(".") !== -1) throw new Error("decimal 无效");

    let tx = new Transaction();

    const toPubkey = new PublicKey(to);

    tx.add(
        SystemProgram.transfer({
            fromPubkey: fromAccount.publicKey,
            toPubkey: toPubkey,
            lamports: calcAmount,
        })
    );

    tx.recentBlockhash = nonce;
    tx.sign(fromAccount);
    return tx.serialize().toString("base64");
}

```

该异步函数用于签署Solana区块链交易，主要流程分为四个步骤：

- 首先通过十六进制私钥生成发送方密钥对；
- 接着将代币金额根据小数位数转换为lamports（Solana最小单位），验证数值有效性；
- 然后构建交易对象，添加包含转账指令的系统程序，设置发送/接收方公钥和金额；
- 最后通过区块哈希（nonce）确定交易时效性，使用发送方私钥签名，最终返回Base64编码的序列化交易数据。
- 该实现使用Solana的Web3.js库处理核心区块链操作，特别要注意金额转换时必须确保整型数值，避免因精度问题导致交易失败。

### 第二步：获取最新区块哈希 getLatestBlockhash

#### 请求参数

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "getLatestBlockhash",
    "params": [
        {
            "commitment": "processed"
        }
    ]
}
```

#### 响应参数

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "context": {
            "apiVersion": "2.1.11",
            "slot": 361707784
        },
        "value": {
            "blockhash": "4XjkJqEMZ3Cif4xuY87cxwyMHxSP9bFARD3QnSEzf9v3",
            "lastValidBlockHeight": 349694665
        }
    }
}
```

### 第三步：编写测试代码并执行测试生成交易签名信息

```ts
  test('signSolTransaction', async () => {
        // 访问环境变量
        const from = process.env.SOL_ADDRESS1;
        const to = process.env.SOL_ADDRESS2;
        const params = {
            txObj: {
                from: from,
                amount: "0.001",
                to: to,
                nonce: "4XjkJqEMZ3Cif4xuY87cxwyMHxSP9bFARD3QnSEzf9v3",
                decimal: 9,
            },
            privateKey: fromPrivateKey
        }
        let tx_msg = await signSolTransaction1(params)
        console.log("signSolTransaction-tx_msg===: ", tx_msg)
    //   signSolTransaction1-tx_msg===:  ATKaFNAVXhBfUCnCrQkLo8IeKs2CI+gQ8TNEM+myO5+FqA8/xyorj60bBaXYlmn3Lb95AKAGhMtdf6cRj4UILQ8BAAEDUNL1okGj30KdoSn3OxRBOsGf3nUVNLNfJvRbsNRa5vbvIC2rJj+e1ff/N80tt7MMsc0ZrmpoZnC+r34F75y6nwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANHLRoeO0B/Lkn3X/Zdo9yN1Xj1W2aoHEocgucnQtOIQBAgIAAQwCAAAAQEIPAAAAAAA=
    });
```

### 第四步：发送交易 sendTransaction

#### 请求参数

```json
{
    "method": "sendTransaction",
    "params": [
        "ATKaFNAVXhBfUCnCrQkLo8IeKs2CI+gQ8TNEM+myO5+FqA8/xyorj60bBaXYlmn3Lb95AKAGhMtdf6cRj4UILQ8BAAEDUNL1okGj30KdoSn3OxRBOsGf3nUVNLNfJvRbsNRa5vbvIC2rJj+e1ff/N80tt7MMsc0ZrmpoZnC+r34F75y6nwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANHLRoeO0B/Lkn3X/Zdo9yN1Xj1W2aoHEocgucnQtOIQBAgIAAQwCAAAAQEIPAAAAAAA=",
        {
            "encoding": "base64"
        }
    ],
    "id": 1,
    "jsonrpc": "2.0"
}
```

#### 响应结果

```json
{
    "jsonrpc": "2.0",
    "result": "21gLaErWv5waGchsX4JHhuMWpjyM84UkhGCNX6fUMt5YaRu2mdaKAXTQPctsZEWqULFDFfnvZWGZJSm7ewg5yHBk",
    "id": 1
}
```

### 第五步：查看交易

<https://solscan.io/tx/21gLaErWv5waGchsX4JHhuMWpjyM84UkhGCNX6fUMt5YaRu2mdaKAXTQPctsZEWqULFDFfnvZWGZJSm7ewg5yHBk?cluster=devnet>

![image-20250218094837210](/images/image-20250218094837210.png)

## 总结

通过本文的讲解，你已经掌握了如何在Solana网络上进行Web3交易的基础操作，从交易签名到发送和确认，每一步都非常重要。Solana凭借其高效的处理能力和低廉的交易费用，已经成为开发者在Web3项目中不可忽视的选择。希望本文为你提供了有价值的指导，帮助你在Solana区块链平台上构建更加高效和稳定的Web3应用。随着Solana生态的不断发展，未来将会有更多的机会与挑战等待着开发者。

## 参考

- <https://solscan.io/tx/21gLaErWv5waGchsX4JHhuMWpjyM84UkhGCNX6fUMt5YaRu2mdaKAXTQPctsZEWqULFDFfnvZWGZJSm7ewg5yHBk?cluster=devnet>
- <https://solscan.io/>
- <https://explorer.solana.com/>
- <https://solanacookbook.com/zh/>
- <https://websocketking.com/>
- <https://beta.solpg.io/>
- <https://solana.com/zh/docs>
- <https://www.solanazh.com/>
