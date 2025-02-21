+++
title = "Web3 新玩法：Solana Nonce Account 让你交易无忧"
description = "Web3 新玩法：Solana Nonce Account 让你交易无忧"
date = 2025-02-17 21:53:55+08:00
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]

+++

<!-- more -->

# Web3 新玩法：Solana Nonce Account 让你交易无忧

想在 Web3 世界玩出新花样？Solana 的交易速度快到飞起，但你有没有遇到过这样的烦恼：交易刚签名，转眼就因区块哈希过期失效？别急，Solana Nonce Account 来了！它就像一个“交易时间胶囊”，让你随时签名、随时提交，再也不用担心时间限制。本文将带你揭开这个 Web3 新玩法的面纱，手把手教你如何用它让交易无忧，轻松迈入 Solana 开发前沿！

在 Solana 区块链中，Nonce Account 是一个隐藏的“交易神器”。**Nonce Account（nonce 账户）** 是一种特殊的账户类型，用于支持 **Durable Nonce（持久化 nonce）** 机制。它用一个持久化的 nonce 值替代短命的区块哈希，让你的交易签名可以“长寿”无忧，随时提交不失效。本文不仅深入讲解了 Nonce Account 的原理和特性，还通过代码实战演示了如何创建、签名和发送持久化交易。对比传统方式，你会发现它的妙处：离线签名、定时转账，统统不在话下。无论你是 Web3 新手还是 Solana 开发者，这篇指南都能让你快速上手，玩转交易新姿势！

## Nonce Account

### 什么是 Nonce Account？

Nonce Account 是 Solana 系统程序（System Program）拥有的一种账户，用于存储一个 **nonce 值**（一个唯一的标识符，通常是一个 32 字节的哈希值）。这个 nonce 值可以替代常规交易中的 **recent blockhash（最近区块哈希）**，从而实现 **持久化交易（Durable Transactions）**，也就是允许交易在签名后延迟提交而不失效。

- **普通交易的限制**: 在 Solana 中，常规交易需要包含一个最近的区块哈希（recent blockhash），这个哈希的有效期大约是 150 个区块（约 1-2 分钟）。如果交易未能在有效期内提交到网络，就会被拒绝。
- **Nonce Account 的作用**: 通过使用 Nonce Account 存储的 nonce 值，交易可以预先签名并存储，之后在任意时间提交，而无需担心区块哈希过期。

### Nonce Account 的关键特性

1. 存储内容：

   - **Nonce 值**: 一个唯一的哈希值，替代交易中的 recent blockhash。

   - **Authority（授权者）**: 一个公钥，负责管理该 Nonce Account（例如推进 nonce 或提取资金）。

   - **状态**: 表示账户是否已初始化。

2. 租免（Rent-Exempt）：

- Nonce Account 需要维持一个最低余额（大约 0.0015 SOL），以保持租免状态，确保数据在链上持久存储。

3. 控制权：

- 创建 Nonce Account 的账户默认是其 **Nonce Authority（nonce 授权者）**，但可以通过指令将授权转移给其他账户。
- Nonce Authority 可以执行以下操作：
  - **Advance Nonce（推进 nonce）**: 更新 nonce 值。
  - **Withdraw（提取资金）**: 从账户提取 SOL。
  - **Authorize（更改授权）**: 将控制权转移给其他公钥。

4. 交易要求

- 使用 Durable Nonce 的交易必须以 **AdvanceNonceAccount 指令** 开头，这会更新 Nonce Account 中的 nonce 值，确保每个交易的 nonce 是唯一的，防止重放攻击。

## 实操 Solana 创建 NonceAccount

## 并发送交易

### 第一步：实现 `prepareAccount` 代码

```ts
export function prepareAccount(params: any) {
    const {
        authorAddress,
        nonceAccountAddress,
        recentBlockhash,
        minBalanceForRentExemption,
        privs,
    } = params;

    const authorPrivateKey = privs?.find(
        (ele: { address: any }) => ele.address === authorAddress
    )?.key;
    if (!authorPrivateKey) throw new Error("authorPrivateKey 为空");

    const nonceAcctPrivateKey = privs?.find(
        (ele: { address: any }) => ele.address === nonceAccountAddress
    )?.key;
    if (!nonceAcctPrivateKey) throw new Error("nonceAcctPrivateKey 为空");

    const author = Keypair.fromSecretKey(
        new Uint8Array(Buffer.from(authorPrivateKey, "hex"))
    );
    const nonceAccount = Keypair.fromSecretKey(
        new Uint8Array(Buffer.from(nonceAcctPrivateKey, "hex"))
    );

    const tx = new Transaction();
    tx.add(
        SystemProgram.createAccount({
            fromPubkey: author.publicKey,
            newAccountPubkey: nonceAccount.publicKey,
            lamports: minBalanceForRentExemption,
            space: NONCE_ACCOUNT_LENGTH,
            programId: SystemProgram.programId,
        }),

        SystemProgram.nonceInitialize({
            noncePubkey: nonceAccount.publicKey,
            authorizedPubkey: author.publicKey,
        })
    );
    tx.recentBlockhash = recentBlockhash;

    tx.sign(author, nonceAccount);
    return tx.serialize().toString("base64");
}
```

### 第二步：获取最新区块哈希（getLatestBlockhash）

#### Request

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

#### Response

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "context": {
            "apiVersion": "2.1.11",
            "slot": 361716547
        },
        "value": {
            "blockhash": "7kcpQ8Hfpi35gTKtmkVW5XBdYH5Zrw4e9Pg27YyCxkcP",
            "lastValidBlockHeight": 349703424
        }
    }
}
```

### 第三步：编写测试代码并执行测试

```ts
 test('prepareAccount test', async () => {
        const params = {
            authorAddress: from,
            nonceAccountAddress: nonce_account_addr,
            recentBlockhash: "7kcpQ8Hfpi35gTKtmkVW5XBdYH5Zrw4e9Pg27YyCxkcP",
            minBalanceForRentExemption: 1647680,
            privs: [
                {
                    address: from,
                    key: fromPrivateKey
                },
                {
                    address: nonce_account_addr,
                    key: noncePrivateKey
                }
            ]
        }
        let tx_msg = await prepareAccount(params)
        console.log("prepareAccount-tx_msg===", tx_msg)
    });
```

#### 测试输出

```bash
 console.log
    prepareAccount-tx_msg=== AovVQR0MBuqhv9g/Z13s7ZxLGWUJJT3Oo93lbpmuv9f/liETgjOJVoJyRGRnwp3lo+rb45SCPzcoubMn4we/mwNNRDoya6WDYE9FkcZOGZAgLHSJ8+e0+H5D8pDxHAEnHgDCqWPguVrIyTulfaDxplezPdql6xQHFT9ggyzc9EgPAgADBVDS9aJBo99CnaEp9zsUQTrBn951FTSzXyb0W7DUWub2xEp9ziCqAhF18Ho7eXUKwhKbLjja+jESCZydfVfC/UsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAan1RcZLFaO4IqEX3PSl4jPA1wxRbIas0TYBi6pQAAABqfVFxksXFEhjMlMPUrxf1ja7gibof1E49vZigAAAABkUphSZcxpdk94aUysDsPylqN3s1PWrP/RYWsLIxSGGAICAgABNAAAAABAJBkAAAAAAFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAwEDBCQGAAAAUNL1okGj30KdoSn3OxRBOsGf3nUVNLNfJvRbsNRa5vY=
```

### 第四步：发送交易（sendTransaction）

#### Request

```json
{
    "method": "sendTransaction",
    "params": [
        "AovVQR0MBuqhv9g/Z13s7ZxLGWUJJT3Oo93lbpmuv9f/liETgjOJVoJyRGRnwp3lo+rb45SCPzcoubMn4we/mwNNRDoya6WDYE9FkcZOGZAgLHSJ8+e0+H5D8pDxHAEnHgDCqWPguVrIyTulfaDxplezPdql6xQHFT9ggyzc9EgPAgADBVDS9aJBo99CnaEp9zsUQTrBn951FTSzXyb0W7DUWub2xEp9ziCqAhF18Ho7eXUKwhKbLjja+jESCZydfVfC/UsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAan1RcZLFaO4IqEX3PSl4jPA1wxRbIas0TYBi6pQAAABqfVFxksXFEhjMlMPUrxf1ja7gibof1E49vZigAAAABkUphSZcxpdk94aUysDsPylqN3s1PWrP/RYWsLIxSGGAICAgABNAAAAABAJBkAAAAAAFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAwEDBCQGAAAAUNL1okGj30KdoSn3OxRBOsGf3nUVNLNfJvRbsNRa5vY=",
        {
            "encoding": "base64"
        }
    ],
    "id": 1,
    "jsonrpc": "2.0"
}
```

#### Response

```json
{
    "jsonrpc": "2.0",
    "result": "3o9maYQjBDV3vSignLouQwpzZTpKckTPo72cyW5PmtRRHs2JP8osVq9BscGeX3LdE2WjY6ydU52v2DqCnXH3SzNv",
    "id": 1
}
```

### 第五步：查看交易

<https://solscan.io/tx/3o9maYQjBDV3vSignLouQwpzZTpKckTPo72cyW5PmtRRHs2JP8osVq9BscGeX3LdE2WjY6ydU52v2DqCnXH3SzNv?cluster=devnet>

![image-20250218094728180](/images/image-20250218094728180.png)
**Solana Nonce Account** 是一个存储持久化 nonce 的账户，用于支持延迟提交的交易。它通过替代 recent blockhash，解决了常规交易的短寿命问题（约 1-2 分钟），非常适合需要离线签名或定时提交的场景。简单来说，它就像一个“私人区块哈希队列”，让你的交易签名可以长期有效。

### 第六步：获取永久 Nonce

```ts
  test('get nonce test', async () => {
        var connection = new Connection(sol_dev_rpc_url, "confirmed");
        const nonce = await connection.getNonce(new PublicKey("EDEnnPuvJMsVij4QWza2mrujsqyytAAK3qcRAvFuY84A"));
        console.log("nonce===", nonce)
    });
```

#### 测试输出

```bash
 console.log
    nonce=== NonceAccount {
      authorizedPubkey: PublicKey [PublicKey(6SWBzQWZndeaCKg3AzbY3zkvapCu9bHFZv12iiRoGvCD)] {
        _bn: <BN: 50d2f5a241a3df429da129f73b14413ac19fde751534b35f26f45bb0d45ae6f6>
      },
      nonce: '3rK6Qgj2hVhp1pnzxTNea7D3hUjLwgqr6r3Q12KmCks8',
      feeCalculator: { lamportsPerSignature: 5000 }
    }

```

### 第七步：签署交易

```ts
 test('signTransactionNonceAdvance', async () => {
        const authPrivateKey = fromPrivateKey
        let nonceAccountAddress = nonce_account_addr
        let authorAddress = from
        let mintAddress = "0x00";
        const params = {
            txObj: {
                from: from,
                amount: "0.001",
                to: to,
                nonce: "3rK6Qgj2hVhp1pnzxTNea7D3hUjLwgqr6r3Q12KmCks8",
                nonceAccountAddress: nonceAccountAddress,
                authorAddress: authorAddress,
                decimal: 9,
                mintAddress: mintAddress,
                // txType: "TRANSFER_TOKEN",
                hasCreatedTokenAddr: true
            },
            privs: [
                { address: from, key: fromPrivateKey },
                { address: authorAddress, key: authPrivateKey }
            ]
        }
        let tx_msg = await signTransactionNonceAdvance(params)
        console.log("signTransactionNonceAdvance-tx_msg===", tx_msg)
    });
```

测试输出

```bash
console.log
    signTransactionNonceAdvance-tx_msg=== AQ94ysKq0/FKQZxAlGDnFjd2rwTdqD10/e681Zd6qhGm+kp0i+0tEd0KJEf+0jVjBi7cDHA/Xb5swhcj6K1KQgwBAAIFUNL1okGj30KdoSn3OxRBOsGf3nUVNLNfJvRbsNRa5vbESn3OIKoCEXXwejt5dQrCEpsuONr6MRIJnJ19V8L9S+8gLasmP57V9/83zS23swyxzRmuamhmcL6vfgXvnLqfAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGp9UXGSxWjuCKhF9z0peIzwNcMUWyGrNE2AYuqUAAACpZSqYk5dPPmahjsCk9PKmCzJirdegCTuuVZIL77hFfAgMDAQQABAQAAAADAgACDAIAAABAQg8AAAAAAA==
```

### 第八步：发送交易

Request：

```json
{
 "method": "sendTransaction",
 "params": [
  "AQ94ysKq0/FKQZxAlGDnFjd2rwTdqD10/e681Zd6qhGm+kp0i+0tEd0KJEf+0jVjBi7cDHA/Xb5swhcj6K1KQgwBAAIFUNL1okGj30KdoSn3OxRBOsGf3nUVNLNfJvRbsNRa5vbESn3OIKoCEXXwejt5dQrCEpsuONr6MRIJnJ19V8L9S+8gLasmP57V9/83zS23swyxzRmuamhmcL6vfgXvnLqfAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAGp9UXGSxWjuCKhF9z0peIzwNcMUWyGrNE2AYuqUAAACpZSqYk5dPPmahjsCk9PKmCzJirdegCTuuVZIL77hFfAgMDAQQABAQAAAADAgACDAIAAABAQg8AAAAAAA==",
  {
   "encoding": "base64"
  }
 ],
 "id": 1,
 "jsonrpc": "2.0"
}
```

Response

```json
{
    "jsonrpc": "2.0",
    "result": "JwbL7ZHkzGADLHiT7yNr5Tp17bKW3EwupaS3deP8jkLMvcrDnej8RSFboWH1FxQGoWEWjuFt7EZT4XeMh3LDSFD",
    "id": 1
}
```

### 第九步：查看交易

<https://solscan.io/tx/JwbL7ZHkzGADLHiT7yNr5Tp17bKW3EwupaS3deP8jkLMvcrDnej8RSFboWH1FxQGoWEWjuFt7EZT4XeMh3LDSFD?cluster=devnet>

![image-20250221191800976](/images/image-20250221191800976.png)

## 使用 recent blockhash 发送交易

### 第一步：getLatestBlockhash

Request：

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

Response：

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "result": {
        "context": {
            "apiVersion": "2.1.11",
            "slot": 361853137
        },
        "value": {
            "blockhash": "2Et5fCcmfKLBLj8JFKNNP5HrBtid1LGDcJ2TjvhKTJ85",
            "lastValidBlockHeight": 349839702
        }
    }
}
```

### 第二步：sign Transaction

```ts
 test('signSolTransaction2', async () => {
        const params = {
            txObj: {
                from: from,
                amount: "0.001",
                to: to,
                nonce: "2Et5fCcmfKLBLj8JFKNNP5HrBtid1LGDcJ2TjvhKTJ85",
                decimal: 9,
                hasCreatedTokenAddr: true,
                mintAddress: "0x00"
            },
            privateKey: fromPrivateKey
        }
        let tx_msg = await signSolTransaction(params)
        console.log("signSolTransaction mintAddress-tx_msg===: ", tx_msg)
    });

```

测试输出

```bash
 console.log
    signSolTransaction mintAddress-tx_msg===:  AXGC+/AByHznnU8A7RRRZ05S0HCy1IyLrDl2eupbJ4ZxI/oRFZn16gK1Dd3IrsIP0xrQGnIrUzBp42YacoDsEQ0BAAEDUNL1okGj30KdoSn3OxRBOsGf3nUVNLNfJvRbsNRa5vbvIC2rJj+e1ff/N80tt7MMsc0ZrmpoZnC+r34F75y6nwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEmn+gHRn9+6fhkPtGiR7satZ98KcS8o9Qdgxhnh3yW4BAgIAAQwCAAAAQEIPAAAAAAA=

```

### 第三步：发送交易

#### Request

```json
{
    "method": "sendTransaction",
    "params": [
        "AXGC+/AByHznnU8A7RRRZ05S0HCy1IyLrDl2eupbJ4ZxI/oRFZn16gK1Dd3IrsIP0xrQGnIrUzBp42YacoDsEQ0BAAEDUNL1okGj30KdoSn3OxRBOsGf3nUVNLNfJvRbsNRa5vbvIC2rJj+e1ff/N80tt7MMsc0ZrmpoZnC+r34F75y6nwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEmn+gHRn9+6fhkPtGiR7satZ98KcS8o9Qdgxhnh3yW4BAgIAAQwCAAAAQEIPAAAAAAA=",
        {
            "encoding": "base64"
        }
    ],
    "id": 1,
    "jsonrpc": "2.0"
}
```

#### Response

```json
{
    "jsonrpc": "2.0",
    "result": "3GdUC2Q5RzTW8NaooqR5vT9CbCJwC59AL6edFg8fzuSGVwXPWnHUxt6r4Mv6vL3qn5knQrxYSWHsSP9UtBpLh492",
    "id": 1
}
```

### 第四步：查看交易

<https://solscan.io/tx/3GdUC2Q5RzTW8NaooqR5vT9CbCJwC59AL6edFg8fzuSGVwXPWnHUxt6r4Mv6vL3qn5knQrxYSWHsSP9UtBpLh492?cluster=devnet>

```bash
# 转账之前
solana balance
69.56672102 SOL
solana balance H6Su7YsGK5mMASrZvJ51nt7oBzD88V8FKSBPNnRG1u3k
26.55100002 SOL
# 转账之后
solana balance
69.56571602 SOL
solana balance H6Su7YsGK5mMASrZvJ51nt7oBzD88V8FKSBPNnRG1u3k
26.55200002 SOL
```

![image-20250219100328948](/images/image-20250219100328948.png)

## 总结

Solana Nonce Account 就像 Web3 交易的“万能钥匙”，解决了传统交易只能“短命”的痛点，让你签名无忧、提交随心。从离线操作到定时任务，它为 Solana 生态带来了无限可能。跟着本文的步骤，你不仅能理解它的奥秘，还能动手实践，轻松打造属于自己的 Web3 应用。在区块链的世界里，Nonce Account 是一个简单却强大的新玩法，准备好了吗？快用它解锁 Solana 的交易自由吧！

## 参考

- <https://solana.com/zh/developers/guides/advanced/introduction-to-durable-nonces>
- <https://solscan.io/>
- <https://solana.com/zh/docs>
- <https://www.anchor-lang.com/docs>
- <https://www.solanazh.com/>
- <https://github.com/solana-labs>
- <https://github.com/anza-xyz/agave>
