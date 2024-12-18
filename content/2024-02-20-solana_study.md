+++
title = "Solana 开发学习之Solana 基础知识"
date = 2024-02-20T14:28:01+08:00
[taxonomies]
tags = ["Solana"]
categories = ["Solana"]
+++

# Solana 开发学习之Solana 基础知识

## Install the Solana CLI

### 相关链接

- <https://docs.solanalabs.com/cli/install>
- <https://solanacookbook.com/zh/getting-started/installation.html#%E5%AE%89%E8%A3%85%E5%91%BD%E4%BB%A4%E8%A1%8C%E5%B7%A5%E5%85%B7>
- <https://www.solanazh.com/course/1-4>
- <https://solana.com/zh/developers/guides/getstarted/setup-local-development>

### 实操

- 安装

```bash
sh -c "$(curl -sSfL https://release.solana.com/v1.18.2/install)"

downloading v1.18.2 installer
  ✨ 1.18.2 initialized
Adding
export PATH="/Users/qiaopengjun/.local/share/solana/install/active_release/bin:$PATH" to /Users/qiaopengjun/.profile
Adding
export PATH="/Users/qiaopengjun/.local/share/solana/install/active_release/bin:$PATH" to /Users/qiaopengjun/.zprofile
Adding
export PATH="/Users/qiaopengjun/.local/share/solana/install/active_release/bin:$PATH" to /Users/qiaopengjun/.bash_profile

Close and reopen your terminal to apply the PATH changes or run the following in your existing bash:

export PATH="/Users/qiaopengjun/.local/share/solana/install/active_release/bin:$PATH"

```

- 配置环境变量

```bash
vim .zshrc

# 复制并粘贴下面命令以更新 PATH
export PATH="/Users/qiaopengjun/.local/share/solana/install/active_release/bin:$PATH"
```

- 通过运行以下命令确认您已安装了所需的 Solana 版本：

```bash
solana --version

# 实操
solana --version
solana-cli 1.18.2 (src:13656e30; feat:3352961542, client:SolanaLabs)
```

- 切换版本

```bash
solana-install init 1.16.4
```

## 设置网络环境

官方RPC地址分别是：

- DevNet: [https://api.devnet.solana.com](https://api.devnet.solana.com/)
- TestNet: [https://api.testnet.solana.com](https://api.testnet.solana.com/)
- MainNet: [https://api.mainnet-beta.solana.com](https://api.mainnet-beta.solana.com/)

### 相关链接

- <https://solana.com/zh/rpc>

### 实操

```bash
solana config set --url https://api.devnet.solana.com

Config File: /Users/qiaopengjun/.config/solana/cli/config.yml
RPC URL: https://api.devnet.solana.com
WebSocket URL: wss://api.devnet.solana.com/ (computed)
Keypair Path: /Users/qiaopengjun/.config/solana/id.json
Commitment: confirmed
```

## 创建账号

### 相关链接

- <https://docs.solanalabs.com/cli/wallets/paper>

### Check your installation

运行以下命令检查 solana-keygen 是否安装正确:

```bash
solana-keygen --version

# 实操
solana-keygen --version
solana-keygen 1.18.2 (src:13656e30; feat:3352961542, client:SolanaLabs)
```

使用 solana-keygen 工具，可以生成新的种子短语，以及从现有的种子短语和(可选的)密码短语派生一个密钥对。

种子短语和口令短语可以作为纸钱包一起使用。只要您保持您的种子短语和密码存储安全，您可以使用它们访问您的帐户。

For full usage details, run:

```bash
solana-keygen new --help

solana-keygen-new
Generate new keypair file from a random seed phrase and optional BIP39 passphrase

USAGE:
    solana-keygen new [OPTIONS]

OPTIONS:
    -C, --config <FILEPATH>
            Configuration file to use [default: /Users/qiaopengjun/.config/solana/cli/config.yml]

        --derivation-path [<DERIVATION_PATH>...]
            Derivation path. All indexes will be promoted to hardened. If arg is not presented then
            derivation path will not be used. If arg is presented with empty DERIVATION_PATH value
            then m/44'/501'/0'/0' will be used.

    -f, --force
            Overwrite the output file if it exists

    -h, --help
            Print help information

        --language <LANGUAGE>
            Specify the mnemonic language that will be present in the generated seed phrase
            [default: english] [possible values: english, chinese-simplified, chinese-traditional,
            japanese, spanish, korean, french, italian]

        --no-bip39-passphrase
            Do not prompt for a BIP39 passphrase

        --no-outfile
            Only print a seed phrase and pubkey. Do not output a keypair file

    -o, --outfile <FILEPATH>
            Path to generated file

    -s, --silent
            Do not display seed phrase. Useful when piping output to other programs that prompt for
            user input, like gpg

        --word-count <NUMBER>
            Specify the number of words that will be present in the generated seed phrase [default:
            12] [possible values: 12, 15, 18, 21, 24]
```

### 实操

```bash
sosolana-keygen new --force

Generating a new keypair

For added security, enter a BIP39 passphrase

NOTE! This passphrase improves security of the recovery seed phrase NOT the
keypair file itself, which is stored as insecure plain text

BIP39 Passphrase (empty for none):

Wrote new keypair to /Users/qiaopengjun/.config/solana/id.json
=================================================================================
pubkey: 账号的地址
=================================================================================
Save this seed phrase and your BIP39 passphrase to recover your new keypair:
对应的BIP39的助记词
=================================================================================
```

查看当前账号的地址，Keypair文件的中的公钥：

```bash
solana-keygen pubkey
```

## 申请水龙头

```bash
solana airdrop 1

Requesting airdrop of 1 SOL

Signature: GTVSLYa9Vm1FfjBSDVxf8cBL6D47caXHuETRbdD3eQ5C36ZA261MLJXBxzWU2HoiaedAAmBdiy17YFnSaiWsvW3

1 SOL
```

### [Solana CLI Reference and Usage](https://docs.solanalabs.com/cli/usage)

### 查看当前账号的余额

```bash
solana balance
1 SOL
```

- <https://solscan.io/tx/GTVSLYa9Vm1FfjBSDVxf8cBL6D47caXHuETRbdD3eQ5C36ZA261MLJXBxzWU2HoiaedAAmBdiy17YFnSaiWsvW3?cluster=devnet>
- <https://explorer.solana.com/tx/GTVSLYa9Vm1FfjBSDVxf8cBL6D47caXHuETRbdD3eQ5C36ZA261MLJXBxzWU2HoiaedAAmBdiy17YFnSaiWsvW3?cluster=devnet>

### 查看 config

```bash
cat .config/solana/cli/config.yml
---
json_rpc_url: https://api.devnet.solana.com
websocket_url: ''
keypair_path: /Users/qiaopengjun/.config/solana/id.json
address_labels:
  '11111111111111111111111111111111': System Program
commitment: confirmed
```

## 转账

```bash
solana transfer --allow-unfunded-recipient H6Su7YsGK5mMASrZvJ51nt7oBzD88V8FKSBPNnRG1u3k 0.01

Signature: 5t9ysYELu2Gv1jc7SDXzmZotLUDhkUwuSd48tH2QSqJy8iTYkXD7Sf9fNVxXhkcUZsCy7s7WvsddRbxrfK3tKmEg

```

- <https://explorer.solana.com/tx/5t9ysYELu2Gv1jc7SDXzmZotLUDhkUwuSd48tH2QSqJy8iTYkXD7Sf9fNVxXhkcUZsCy7s7WvsddRbxrfK3tKmEg?cluster=devnet>

![image-20240220211328531](/images/image-20240220211328531.png)

- <https://solscan.io/tx/5t9ysYELu2Gv1jc7SDXzmZotLUDhkUwuSd48tH2QSqJy8iTYkXD7Sf9fNVxXhkcUZsCy7s7WvsddRbxrfK3tKmEg?cluster=devnet>

![image-20240220211135148](/images/image-20240220211135148.png)

## 练习

通过命令行，发行一个代币。并给自己账号mint一定数量的代币。 并通过插件钱包或者命令行的方式给其他同学空投该代币

1. 设置环境为开发环境

2. 创建账号
3. 申请水龙头
4. 创建Token

```bash
spl-token create-token
Creating token E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx under program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA

Address:  E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx
Decimals:  9

Signature: 51yuJ91agCKxYWEbLgMfEq5BWBTaFZoezxfnKVoTmrGi59S44q7nKkfVjsCpMJNVLwW8AKuiNbNKb4JSUzLHQy9d

```

- <https://solscan.io/token/E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx?cluster=devnet>
- <https://solscan.io/tx/51yuJ91agCKxYWEbLgMfEq5BWBTaFZoezxfnKVoTmrGi59S44q7nKkfVjsCpMJNVLwW8AKuiNbNKb4JSUzLHQy9d?cluster=devnet>

5. 创建Token Account

```bash
spl-token create-account E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx
Creating account HDv1RgdHjrjSdnTFJsMqQGPcKTiuF7zLjhNaSd7ihbKh

Signature: 3shwWeUAiFYTE2qfARofhyPRtHvtGBRNf2oB8AoxsAX11mEbUsxk2q35YSmWBcBQEnhS2t2LsBnQ9bjt4m2WR3qt

```

- <https://solscan.io/tx/3shwWeUAiFYTE2qfARofhyPRtHvtGBRNf2oB8AoxsAX11mEbUsxk2q35YSmWBcBQEnhS2t2LsBnQ9bjt4m2WR3qt?cluster=devnet>

6. Token Account Mint

```bash
spl-token mint E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx 100 HDv1RgdHjrjSdnTFJsMqQGPcKTiuF7zLjhNaSd7ihbKh
Minting 100 tokens
  Token: E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx
  Recipient: HDv1RgdHjrjSdnTFJsMqQGPcKTiuF7zLjhNaSd7ihbKh

Signature: 4XdNt4yotJdcKN1JGSqm4CL8tQ8vELzGLNGT8ChucQWmofSBpSz2jU8gHmET18PBu2Z3ZGt9RkzRAwuZ5DdBEzba

```

- <https://solscan.io/tx/4XdNt4yotJdcKN1JGSqm4CL8tQ8vELzGLNGT8ChucQWmofSBpSz2jU8gHmET18PBu2Z3ZGt9RkzRAwuZ5DdBEzba?cluster=devnet>

7. 查询余额

```bash
spl-token balance E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx
100
```

8. 转账

```bash
spl-token transfer --fund-recipient E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx 10 H6Su7YsGK5mMASrZvJ51nt7oBzD88V8FKSBPNnRG1u3k
Transfer 10 tokens
  Sender: HDv1RgdHjrjSdnTFJsMqQGPcKTiuF7zLjhNaSd7ihbKh
  Recipient: H6Su7YsGK5mMASrZvJ51nt7oBzD88V8FKSBPNnRG1u3k
  Recipient associated token account: HY1GfCQabyUMFRGpDu3eFoVW3ny8ifHKVZ8LbvzbDPsK
  Funding recipient: HY1GfCQabyUMFRGpDu3eFoVW3ny8ifHKVZ8LbvzbDPsK

Signature: 4jbcoJYS6ZGPcUmHpqTnxeLHfQxvUqQQnzgoJCgWWA1LpKkKWRA5y2FZ7rDQ2v4NBBcuUJqh37A9p92mvbTmS6iY

```

- <https://solscan.io/tx/4jbcoJYS6ZGPcUmHpqTnxeLHfQxvUqQQnzgoJCgWWA1LpKkKWRA5y2FZ7rDQ2v4NBBcuUJqh37A9p92mvbTmS6iY?cluster=devnet>

9. 查询余额

```bash
spl-token balance E7eHC3g4QsFXuaBe3X2wVr54yEvHK8K8fq6qrgB64djx
90
```

![image-20240221150547872](/images/image-20240221150547872.png)
