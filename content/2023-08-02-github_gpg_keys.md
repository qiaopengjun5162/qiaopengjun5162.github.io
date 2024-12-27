+++
title = "Github 配置 GPG 密钥"
description = "Github 配置 GPG 密钥"
date = 2023-08-02T15:16:35+08:00
[taxonomies]
categories = ["Github"]
tags = ["Github"]
+++

# Github 配置 GPG 密钥

## Github 配置 GPG 密钥实操

配置：MacBook Pro 16

### 一、安装 GPG 命令行工具

<https://www.gnupg.org/download/>

```bash
brew install gpg
```

#### 查看版本

```bash
~ via 🅒 base took 4.4s
➜ gpg --version
gpg (GnuPG) 2.4.3
libgcrypt 1.10.2
Copyright (C) 2023 g10 Code GmbH
License GNU GPL-3.0-or-later <https://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Home: /Users/qiaopengjun/.gnupg
支持的算法：
公钥： RSA, ELG, DSA, ECDH, ECDSA, EDDSA
密文： IDEA, 3DES, CAST5, BLOWFISH, AES, AES192, AES256, TWOFISH,
    CAMELLIA128, CAMELLIA192, CAMELLIA256
散列： SHA1, RIPEMD160, SHA256, SHA384, SHA512, SHA224
压缩：  不压缩, ZIP, ZLIB, BZIP2

```

### 二、检查现有 GPG 密钥

1. 打开终端。
2. 使用 `gpg --list-secret-keys --keyid-format=long` 命令列出你拥有其公钥和私钥的长形式 GPG 密钥。 签名提交或标记需要私钥。
3. 检查命令输出以查看是否有 GPG 密钥对。

```bash
~ via 🅒 base took 1m 16.6s
➜ gpg --list-secret-keys --keyid-format=long
gpg: 目录‘/Users/qiaopengjun/.gnupg’已创建
gpg: /Users/qiaopengjun/.gnupg/trustdb.gpg：建立了信任度数据库

```

### 三、生成新 GPG 密钥

#### 1 生成新 GPG 密钥

```bash
~ via 🅒 base
➜ gpg --full-generate-key

gpg (GnuPG) 2.4.3; Copyright (C) 2023 g10 Code GmbH
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

请选择您要使用的密钥类型：
   (1) RSA 和 RSA
   (2) DSA 和 Elgamal
   (3) DSA（仅用于签名）
   (4) RSA（仅用于签名）
   (9) ECC（签名和加密） *默认*
  (10) ECC（仅用于签名）
 （14）卡中现有密钥
您的选择是？
请选择您想要使用的椭圆曲线：
   (1) Curve 25519 *默认*
   (4) NIST P-384
   (6) Brainpool P-256
您的选择是？
请设定这个密钥的有效期限。
         0 = 密钥永不过期
      <n>  = 密钥在 n 天后过期
      <n>w = 密钥在 n 周后过期
      <n>m = 密钥在 n 月后过期
      <n>y = 密钥在 n 年后过期
密钥的有效期限是？(0)
密钥永远不会过期
这些内容正确吗？ (y/N) y

GnuPG 需要构建用户标识以辨认您的密钥。

真实姓名： qiaopengjun4812@gmail.com
电子邮件地址： qiaopengjun4812@gmail.com
注释： qiao4812
您选定了此用户标识：
    “qiaopengjun4812@gmail.com (qiao4812) <qiaopengjun4812@gmail.com>”

更改姓名（N）、注释（C）、电子邮件地址（E）或确定（O）/退出（Q）？ o
我们需要生成大量的随机字节。在质数生成期间做些其他操作（敲打键盘
、移动鼠标、读写硬盘之类的）将会是一个不错的主意；这会让随机数
发生器有更好的机会获得足够的熵。
我们需要生成大量的随机字节。在质数生成期间做些其他操作（敲打键盘
、移动鼠标、读写硬盘之类的）将会是一个不错的主意；这会让随机数
发生器有更好的机会获得足够的熵。
gpg: 目录‘/Users/qiaopengjun/.gnupg/openpgp-revocs.d’已创建
gpg: 吊销证书已被存储为‘/Users/qiaopengjun/.gnupg/openpgp-revocs.d/AAD244FF0564DDDFA3FE1D0F1234567891234567.rev’
公钥和私钥已经生成并被签名。

pub   ed25519 2023-07-31 [SC]
      AAD244FF0564DDDFA3FE1D0F1234567891234567
uid                      qiaopengjun4812@gmail.com (qiao4812) <qiaopengjun4812@gmail.com>
sub   cv25519 2023-07-31 [E]

```

#### 2 使用 `gpg --list-secret-keys --keyid-format=long` 命令列出你拥有其公钥和私钥的长形式 GPG 密钥。 签名提交或标记需要私钥

```bash
~ via 🅒 base took 4m 18.5s
➜ gpg --list-secret-keys --keyid-format=long

gpg: 正在检查信任度数据库
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: 深度：0  有效性：  1  已签名：  0  信任度：0-，0q，0n，0m，0f，1u
[keyboxd]
---------
sec   ed25519/1234567891234567 2023-07-31 [SC]
      AAD244FF0564DDDFA3FE1D0F1234567891234567
uid                   [ 绝对 ] qiaopengjun4812@gmail.com (qiao4812) <qiaopengjun4812@gmail.com>
ssb   cv25519/FF697C1FC8C55C9A 2023-07-31 [E]

```

#### 3 从 GPG 密钥列表中复制您想要使用的 GPG 密钥 ID 的长形式生成新的 GPG 密钥

```bash
~ via 🅒 base
➜ gpg --armor --export 1234567891234567
-----BEGIN PGP PUBLIC KEY BLOCK-----

mDMEZMcy/RYJ....密钥.../NFCNNVZSiVMBXoNJAP0XDOZjyBsDG+Ite6Pi3pPG
ePyiElhAZPAWHRRRpTIGBA==
=IdMP
-----END PGP PUBLIC KEY BLOCK-----

~ via 🅒 base
```

#### 4 复制以 `-----BEGIN PGP PUBLIC KEY BLOCK-----` 开头并以 `-----END PGP PUBLIC KEY BLOCK-----` 结尾的 GPG 密钥

#### 5 [将 GPG 密钥新增到 GitHub 帐户](https://docs.github.com/zh/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account)

### 四、将 GPG 密钥添加到 GitHub 帐户

1. 在任何页面的右上角，单击个人资料照片，然后单击“设置”。

   ![GitHub 帐户菜单的屏幕截图，其中显示了供用户查看和编辑其个人资料、内容和设置的选项。 菜单项“设置”用深橙色框出。](https://docs.github.com/assets/cb-65929/images/help/settings/userbar-account-settings.png)

2. 在边栏的“访问”部分中，单击 “SSH 和 GPG 密钥”。

3. 在“GPG 密钥”标头旁边，单击“新建 GPG 密钥”。

4. 在“标题”字段中键入 GPG 密钥的名称。

5. 在“密钥”字段中，粘贴[生成 GPG 密钥](https://docs.github.com/zh/authentication/managing-commit-signature-verification/generating-a-new-gpg-key)时复制的 GPG 密钥。

6. 单击“添加 GPG 密钥”

7. 若要确认操作，请向 GitHub 帐户进行身份验证。

### 五、将您的签名密钥告知 Git

1. 打开终端。

2. 如果之前已将 Git 配置为在使用 `--gpg-sign` 签名时使用不同的密钥格式，请取消设置此配置，以便使用默认 `openpgp` 格式。

   ```Shell
   git config --global --unset gpg.format
   ```

3. 使用 `gpg --list-secret-keys --keyid-format=long` 命令列出你拥有其公钥和私钥的长形式 GPG 密钥。 签名提交或标记需要私钥。

```bash
~ via 🅒 base
➜ gpg --list-secret-keys --keyid-format=long

[keyboxd]
---------
sec   ed25519/1234567891234567 2023-07-31 [SC]
      AAD244FF0564DDDFA3FE1D0F1234567891234567
uid                   [ 绝对 ] qiaopengjun4812@gmail.com (qiao4812) <qiaopengjun4812@gmail.com>
ssb   cv25519/FF697C1FC8C55C9A 2023-07-31 [E]

```

4. 从 GPG 密钥列表中复制您想要使用的 GPG 密钥 ID 的长形式。 在本例中，GPG 密钥 ID 为1234567891234567
5. 在 Git 中设置 GPG 签名主键

```bash
~ via 🅒 base
➜ git config --global user.signingkey  1234567891234567
```

6. 如果没有使用 GPG 套件，请在 `zsh` shell 中运行以下命令，将 GPG 密钥添加到 `.zshrc` 文件（如果存在）或 `.zprofile` 文件：

```bash
~ via 🅒 base
➜ if [ -r ~/.zshrc ]; then echo -e '\nexport GPG_TTY=\$(tty)' >> ~/.zshrc; \
  else echo -e '\nexport GPG_TTY=\$(tty)' >> ~/.zprofile; fi
```

或者，如果使用 `bash` shell，请运行以下命令：

```shell
$ if [ -r ~/.bash_profile ]; then echo -e '\nexport GPG_TTY=\$(tty)' >> ~/.bash_profile; \
  else echo -e '\nexport GPG_TTY=\$(tty)' >> ~/.profile; fi
```

### 六、将电子邮件与 GPG 密钥关联

1. 打开终端。
2. 使用 `gpg --list-secret-keys --keyid-format=long` 命令列出你拥有其公钥和私钥的长形式 GPG 密钥。 签名提交或标记需要私钥。

```shell
~ via 🅒 base
➜ gpg --list-secret-keys --keyid-format=long

[keyboxd]
---------
sec   ed25519/1234567891234567 2023-07-31 [SC]
      AAD244FF0564DDDFA3FE1D0F1234567891234567
uid                   [ 绝对 ] qiaopengjun4812@gmail.com (qiao4812) <qiaopengjun4812@gmail.com>
ssb   cv25519/FF697C1FC8C55C9A 2023-07-31 [E]
```

3. 从 GPG 密钥列表中复制您想要使用的 GPG 密钥 ID 的长形式。 在本例中，GPG 密钥 ID 为 1234567891234567

4. 输入 `gpg --edit-key GPG key ID`，替换为你想要使用的 GPG 密钥 ID。 在以下示例中，GPG 密钥 ID 为 `1234567891234567`：

   ```bash
   gpg --edit-key 1234567891234567
   ```

5. 输入 `gpg> adduid` 以添加用户 ID 详细信息。
6. 按照提示提供您的真实姓名、电子邮件地址和任何注释。 可以通过选择 `N`、`C` 或 `E` 来修改条目。 要将电子邮件地址保密，请使用 GitHub 提供的 `no-reply` 电子邮件地址。 有关详细信息，请参阅“[设置提交电子邮件地址](https://docs.github.com/zh/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address)”。
7. 输入 `O` 以确认你的选择。
8. 输入密钥的密码。
9. 输入 `gpg> save` 以保存更改
10. 输入 `gpg --armor --export GPG key ID`，替换为你想要使用的 GPG 密钥 ID。 在以下示例中，GPG 密钥 ID 为 `1234567891234567`：

```bash
~ via 🅒 base
➜ gpg --edit-key 1234567891234567
gpg (GnuPG) 2.4.3; Copyright (C) 2023 g10 Code GmbH
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

私钥可用。

sec  ed25519/1234567891234567
     创建于：2023-07-31  有效至：永不       可用于：SC
     信任度：绝对        有效性：绝对
ssb  cv25519/FF697C1FC8C55C9A
     创建于：2023-07-31  有效至：永不       可用于：E
[ 绝对 ] (1). qiaopengjun4812@gmail.com (qiao4812) <qiaopengjun4812@gmail.com>

gpg> adduid
真实姓名： qiao4812
电子邮件地址： qiaopengjun4812@gmail.com
注释： GITHUB-KEY qiao4812
您选定了此用户标识：
    “qiao4812 (GITHUB-KEY qiao4812) <qiaopengjun4812@gmail.com>”

更改姓名（N）、注释（C）、电子邮件地址（E）或确定（O）/退出（Q）？ o

sec  ed25519/1234567891234567
     创建于：2023-07-31  有效至：永不       可用于：SC
     信任度：绝对        有效性：绝对
ssb  cv25519/FF697C1FC8C55C9A
     创建于：2023-07-31  有效至：永不       可用于：E
[ 绝对 ] (1)  qiaopengjun4812@gmail.com (qiao4812) <qiaopengjun4812@gmail.com>
[ 未知 ] (2). qiao4812 (GITHUB-KEY qiao4812) <qiaopengjun4812@gmail.com>

gpg> save

~ via 🅒 base took 2m 29.2s
➜ gpg --armor --export 1234567891234567
-----BEGIN PGP PUBLIC KEY BLOCK-----

mDME......密钥........lMgYE
=zEPk
-----END PGP PUBLIC KEY BLOCK-----

~ via 🅒 base
```

通过[将 GPG 密钥添加到 GitHub 帐户](https://docs.github.com/zh/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account)来上传 GPG 密钥。

更多详情请查看[GitHub文档](https://docs.github.com/zh/authentication/managing-commit-signature-verification/checking-for-existing-gpg-keys)：<https://docs.github.com/zh/authentication/managing-commit-signature-verification/checking-for-existing-gpg-keys>
