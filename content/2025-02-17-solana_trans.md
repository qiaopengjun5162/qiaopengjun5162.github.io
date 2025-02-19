+++
title = "solana_trans"
description = ""
date = 2025-02-17 21:53:55+08:00
[taxonomies]
categories = ["Web3", "Solana"]
tags = ["Web3", "Solana"]
+++

<!-- more -->

# Web3 Solana

## 实操

## Solana 创建 NonceAccount

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

#### Request：

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

#### Response：

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

#### Request：

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

#### Response：

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

### 第六步：获取账户详情（getAccountInfo）

#### Request：

```json
{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "getAccountInfo",
    "params": [
        "EDEnnPuvJMsVij4QWza2mrujsqyytAAK3qcRAvFuY84A",
        {
            "encoding": "base58"
        }
    ]
}
```

#### Response：

```json
{
    "jsonrpc": "2.0",
    "result": {
        "context": {
            "apiVersion": "2.1.11",
            "slot": 361718202
        },
        "value": {
            "data": [
                "df8aQUMTjG9Shy5dk7Ln9wjha4EdiBzGqofSTU5W4Z5GkqmShZFHW5gUtG3AnsA7jcG7Q92quu3qPxAK4ZF3skwp4GzcHxVi87eH8L2ZtoHH",
                "base58"
            ],
            "executable": false,
            "lamports": 1647680,
            "owner": "11111111111111111111111111111111",
            "rentEpoch": 18446744073709551615,
            "space": 80
        }
    },
    "id": 1
}
```

### 第七步：解析data 数据

```ts
 test('decode nonce', async () => {
        // const connection = new Connection('https://api.mainnet-beta.solana.com', 'confirmed');
        // connection.getNonce()
        const base58Data = "df8aQUMTjG9Shy5dk7Ln9wjha4EdiBzGqofSTU5W4Z5GkqmShZFHW5gUtG3AnsA7jcG7Q92quu3qPxAK4ZF3skwp4GzcHxVi87eH8L2ZtoHH"
        const nonceInfo = NonceAccount.fromAccountData(Buffer.from(base58Data))
        console.log("nonceInfo===", nonceInfo)
    });
```

#### 测试输出：

```bash
 console.log
    nonceInfo=== NonceAccount {
      authorizedPubkey: PublicKey [PublicKey(89sCzZdXZFJ2Vh5eBQxwwmFv6hyerurx8fbYrimJxSDt)] {
        _bn: <BN: 6a473953687935646b374c6e39776a686134456469427a47716f665354553557>
      },
      nonce: '4XMytRTbpWk3SaNXYWaVnUk1qCoW1s5petnd3UbYYL9n',
      feeCalculator: { lamportsPerSignature: 5422747713222702000 }
    }

```

## 测试交易

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

```bash
 console.log
    signSolTransaction mintAddress-tx_msg===:  AXGC+/AByHznnU8A7RRRZ05S0HCy1IyLrDl2eupbJ4ZxI/oRFZn16gK1Dd3IrsIP0xrQGnIrUzBp42YacoDsEQ0BAAEDUNL1okGj30KdoSn3OxRBOsGf3nUVNLNfJvRbsNRa5vbvIC2rJj+e1ff/N80tt7MMsc0ZrmpoZnC+r34F75y6nwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEmn+gHRn9+6fhkPtGiR7satZ98KcS8o9Qdgxhnh3yW4BAgIAAQwCAAAAQEIPAAAAAAA=

```

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

```json
{
    "jsonrpc": "2.0",
    "result": "3GdUC2Q5RzTW8NaooqR5vT9CbCJwC59AL6edFg8fzuSGVwXPWnHUxt6r4Mv6vL3qn5knQrxYSWHsSP9UtBpLh492",
    "id": 1
}
```

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

## 参考

- <https://solana.com/zh/developers/guides/advanced/introduction-to-durable-nonces>
