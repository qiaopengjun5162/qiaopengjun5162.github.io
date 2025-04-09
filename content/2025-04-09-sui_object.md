+++
title = "探索 Web3 新星：Sui 的 Object 架构与 Move 语言实践"
description = "探索 Web3 新星：Sui 的 Object 架构与 Move 语言实践"
date = 2025-04-09 19:02:59+08:00
[taxonomies]
categories = ["Web3", "Sui", "Move"]
tags = ["Web3", "Sui", "Move"]
+++

<!-- more -->

# 探索 Web3 新星：Sui 的 Object 架构与 Move 语言实践

Web3 的热潮席卷而来，而 Sui 区块链正以其独特的以 Object 为中心的架构和高性能交易能力崭露头角，成为 Web3 领域的新星。作为一款专为资产管理打造的区块链，Sui 结合 Move 语言的安全与灵活性，为开发者开启了全新可能。本文将带你深入探索 Sui 的创新设计，并通过实操案例展示如何快速上手这一 Web3 黑马，助你在区块链浪潮中占得先机。

本文聚焦 Web3 新贵 Sui 区块链，详解其以 Object 为中心的架构，包括 Object 的定义、所有权分类及高效资产转移机制。同时介绍 Move 语言的起源与资产管理优势。通过 Sui CLI 的实战演示，从账户创建到代币分割、合约部署，读者将全面掌握 Sui 的核心操作。这是一份专为 Web3 爱好者与开发者打造的入门指南，带你解锁 Sui 的无限潜力。

## Move on Sui

Sui 是以 Object 为中心的架构

什么是 Object？什么是所有权？ 为何 Sui 与其它链如此不同？

## 以 Object 为中心的架构

在 Sui 上任何资产都是 Object

Object 的 Metadata 包含

1. 具有唯一性的ID（32-bytes）
2. 所有权（32-bytes）- 谁拥有这个 object
3. 类型 (package_id::module::name::TypeName)

权限也可以抽象为一个object，也可以是资产，也是可以被转移的。

### 根据 object 所有权分类

- Owner Object
- Immutable Object
- Shared Object

Owner Object

- 被某账户所拥有
- 只有所有者账户能在链上读取或修改删除

Immutable Object

- 不被任何账户拥有
- 任何账户都只能读取

Share Object

- 不被任何账户拥有
- 任何账户都能在链上读取或修改删除（根据规则）

### 如何在 Sui 上转移资产？

- 转移资产 = 转移 Object
- 转移的方式就是修改 Object 的所有者 Owner
- 资产转移是无需排序的交易也就不需要经过共识层
- 只有涉及 Share Object 的交易才需要排序
- 简单的交易是可以同时进行不会造成拥塞
- Sui的交易是高度平行化的，一方拥堵是不会影响另一方的交易的

### 同质化代币的转移

- 同质化代币它也是一个一个 object 的形式存在的
- 同质化代币可以 Merge 和 Split

例如：小米有12个 coin，它要转移 6 个 给小龙，首先它要把 12 个 coin Split 为 6个，然后修改 Owner 为 小龙即可。

## Move 语言简介

什么是资产导向的编程语言？如何实现资产的安全性？

### Move 历史发展与语言特性

- Facebook 在开发 Diem(Libra) 时发明了编程语言——Move
- Move 语言资产管理的特性
  - 强类型 - 资产被封装为类型而不是单纯的数字
  - 模块化 - 只有在定义资产的模块内部才能获取到模块中的资产
  - 隔离性 - 外部模块只能通过公开的方法才能去操作内部的资产
  - 组合性 - 资产可以被封装在另一个资产内
- Move on Sui 基于 Diem 版本的 Move 语言和以对象为中心的架构设计。

智能合约其实就是在管理数字资产。

### Move 项目架构

```bash
package 0x...
 module a
  public struct A
  fun hello()
  public fun say_hello()
 module b
  public struct B
  fun sorry()
  public fun echo()
```

项目目录

```bash
sources/
 a.move
 b.move
 ...
tests/
 ...
examples/
 using_my_module.move
Move.toml
Move.lock
```

### 代码实操

```rust
module example_1::a;

use std::string::{Self, String};

public struct A has store, copy, drop {
  last_words: String,
}

public fun say(a: &mut A, words: String) {
  a.last_words = words;
}

public fun say_hello(a: &mut A) {
  a.say(hello())
}

public fun last_words(a: &A): String {
  a.last_words
}

fun hello(): String {
  string::utf8(b"hello")
}
```

## Sui CLI 实操

查看版本

```bash
sui --version
sui 1.46.1-homebrew

sui -V
sui 1.46.1-homebrew
```

### 导入私钥

```bash
sui keytool import private_key
```

### 创建账号

```bash
sui keytool generate ed25519
```

### 建立网络

```bash
sui client new-env --alias devnet --rpc https://fullnode.devnet.sui.io:443
sui client new-env --alias 'mainnet' --rpc 'https://fullnode.mainnet.sui.io:443'
```

### 切换账号

```bash
sui client switch --address address --env alias
```

### 切换环境

```bash
sui client switch --env testnet 
```

### 查看账号

```bash
sui keytool list
╭────────────────────────────────────────────────────────────────────────────────────────────╮
│ ╭─────────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ alias           │  dazzling-chrysoprase                                                │ │
│ │ suiAddress      │  0x35370841d2e00b054e0ee2a45a73  │ │
│ │ publicBase64Key │  ALVl+oZraNWeV6Bk+0C                        │ │
│ │ keyScheme       │  ed25519                                                             │ │
│ │ flag            │  0                                                                   │ │
│ │ peerId          │  b565fa877bb1a356795e8193ed02    │ │
│ ╰─────────────────┴──────────────────────────────────────────────────────────────────────╯ │
╰────────────────────────────────────────────────────────────────────────────────────────────╯
```

### 查看当前活跃地址

```bash
sui client active-address
0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73
```

### 查看 Sui coins

```bash
sui client gas
╭────────────────────────────────────────────────────────────────────┬────────────────────┬──────────────────╮
│ gasCoinId                                                          │ mistBalance (MIST) │ suiBalance (SUI) │
├────────────────────────────────────────────────────────────────────┼────────────────────┼──────────────────┤
│ 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed │ 12814915708        │ 12.81            │
│ 0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a │ 1000000000         │ 1.00             │
│ 0xd9000c558ce3e08f3fa3a0f342d93aa33df08525f98dc5babc2dccd619b76274 │ 20000000000        │ 20.00            │
╰────────────────────────────────────────────────────────────────────┴────────────────────┴──────────────────╯
```

### 查看所有Object

```bash
sui client objects

╭───────────────────────────────────────────────────────────────────────────────────────╮
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x03898d2ba03016baa223fa0c9fa4a2fe23faad7a73365aa555f872d0a0019cad  │ │
│ │ version    │  12675221                                                            │ │
│ │ digest     │  1W4efBuLxP6BPjpo/hG/ph1VTHQSYmPYKp5XmKcU/Q0=                        │ │
│ │ objectType │  0x0000..0002::display::Display                                      │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed  │ │
│ │ version    │  370791517                                                           │ │
│ │ digest     │  GvkEYhvvUJAE/gcXIZkE/QXnWoPRtoZIr5iqQj+SYwU=                        │ │
│ │ objectType │  0x0000..0002::coin::Coin                                            │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x268741126992f825a47e9bb2f00f4293a52ce0212dd2f8f9f1e2ec25601593a3  │ │
│ │ version    │  12675221                                                            │ │
│ │ digest     │  tNgJTXwt1XOZKm4BhAs6ItfICWpBcLqL5fLQeYJ0UKQ=                        │ │
│ │ objectType │  0x0000..0002::package::Publisher                                    │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x2833ecba998c8bafd65bf68ea892b7a92f342e2e7d026489388d7b69b64553ab  │ │
│ │ version    │  12675217                                                            │ │
│ │ digest     │  7D1yudXWeiA54ZxJBX1n8TbV0UPuIttr3XH833V5qu0=                        │ │
│ │ objectType │  0x0000..0002::display::Display                                      │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a  │ │
│ │ version    │  370791517                                                           │ │
│ │ digest     │  1kiEBlJA/uxixdV9fiqtSyYnPHT3QOWmkePXDUjSGxA=                        │ │
│ │ objectType │  0x0000..0002::coin::Coin                                            │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x3af87cf967e806ecd3ddf47f9ecd06752a7760a02eb4f2e31d2207286a10bf9e  │ │
│ │ version    │  12675219                                                            │ │
│ │ digest     │  cDimrccFz0Uzo9SW9lkQRsKTrMeR83qvJ89J9PU+3E4=                        │ │
│ │ objectType │  0x0000..0002::package::UpgradeCap                                   │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x41ad82e4a4d7e737afc6cd0d1043c3e8b560f9102a31f883f96ebe6b3677220c  │ │
│ │ version    │  12675221                                                            │ │
│ │ digest     │  xLO9M661FpcloQ5SXAKLMFF9Sdgju8ynI0KfEU+HScU=                        │ │
│ │ objectType │  0x0000..0002::display::Display                                      │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x5b9b522def4878d8f53e7ba76687d03cadb49a67329f1349df109fed0b50cf33  │ │
│ │ version    │  12675217                                                            │ │
│ │ digest     │  rgZqKdknvko9dG7qOhBoHJ0aFiLrqufLOkpQWyV4ROk=                        │ │
│ │ objectType │  0x0000..0002::package::UpgradeCap                                   │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x5ed2c21b29722081a8a9e03e2034f741675cb60f705775f631c24e766669c6dd  │ │
│ │ version    │  12675219                                                            │ │
│ │ digest     │  eAiovtB4WwJuDf0E3MsqdO4HpyniuF+Jq5JpTSKLch4=                        │ │
│ │ objectType │  0x0000..0002::display::Display                                      │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x60b91385a64ed5850a323be36c495b85d49b8fed3a654ff0d26022817145c815  │ │
│ │ version    │  18128026                                                            │ │
│ │ digest     │  PpPx0r4a02p2JEP9NYDHWgluv3EapvArfPtrT37ChMU=                        │ │
│ │ objectType │  0x0000..0002::package::UpgradeCap                                   │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x620ebcad42f04a4cbb313ad61d189517dbfc92c5f3190ee66e818ef9dcc46006  │ │
│ │ version    │  12675218                                                            │ │
│ │ digest     │  otZNlz+QwpBypCdJyV2GZr7/B7MeuRDKaocElHYEF9c=                        │ │
│ │ objectType │  0x6201..2f2e::my_nft::MyNFT                                         │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x685c3019d1c7c4c2e3b254ca659aa29e38ab68c1c8bf7f506247d27086e7cf80  │ │
│ │ version    │  12675220                                                            │ │
│ │ digest     │  ft4LkN1kOqB5xLZdj0dbZCitnEmepSIint1IcvfZylc=                        │ │
│ │ objectType │  0xb17a..a988::nft::MyNFT                                            │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x72e45ae428034bbe8f46d7069fde0203cc3301e65f4e9a7126d623cbf6571754  │ │
│ │ version    │  12675219                                                            │ │
│ │ digest     │  QnoifxXABXy2BK1zEC8IYmh20aQ7QPm0F2nvEVSjor4=                        │ │
│ │ objectType │  0x0000..0002::display::Display                                      │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x85611c9f3250eab8208bb1cf4939f5c8ccda71092421aa7945e56e66d43bb8d6  │ │
│ │ version    │  12675223                                                            │ │
│ │ digest     │  pB144XTJY7FEJAU2N71sPharaF/MNZiJZwpTCd0L2Ec=                        │ │
│ │ objectType │  0xa1ba..1bb0::nft::MyNFT                                            │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x88184dc8564e33af87146dadf4f38a756044c0e1c51b35dfd8b5e211f500f3a0  │ │
│ │ version    │  1072214                                                             │ │
│ │ digest     │  WdgaWsLNPGLyEx7k1Pvm52TT+RgMgh2uXNRI2vdT7Os=                        │ │
│ │ objectType │  0x0000..0002::coin::TreasuryCap                                     │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x9231db1356e00b045d8bac55ab0c77d6cf81e9307ae62684184dd8cc02f91762  │ │
│ │ version    │  12675217                                                            │ │
│ │ digest     │  s5qVVQSytkGlvdf9/cD15Fu+Se2V2HDjGJy4BGoyaHM=                        │ │
│ │ objectType │  0x0000..0002::package::Publisher                                    │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x977a3793712678b8b96fe4f9cac29748bf9cc71233a180b6b0fab037be18f0c4  │ │
│ │ version    │  370791512                                                           │ │
│ │ digest     │  CSREGTb9yB8eM83g1x3z0pyHhyjZAg3Fx55SEj6BkOs=                        │ │
│ │ objectType │  0x795d..f88b::staked_wal::StakedWal                                 │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0x9d049515152a144171b4037eb8b5b24c2f811474321c121872e56c6273c99a20  │ │
│ │ version    │  370791514                                                           │ │
│ │ digest     │  9gM0f3lRBFhmBrxmo4ucD71wgD1g6ItMKMzN8bAq6Cs=                        │ │
│ │ objectType │  0x0000..0002::package::UpgradeCap                                   │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0xaa38fb2f838a9bda199c292a8f523c99e13ec447c32018bf2df25666a2f66d85  │ │
│ │ version    │  12675224                                                            │ │
│ │ digest     │  FhxEA+vzNgsvKQy6abFOP1vFtgVbnIxnFBoruM8e1Ao=                        │ │
│ │ objectType │  0x0000..0002::package::UpgradeCap                                   │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0xaecb48e905296f995121cafcfcd28ea8a1ee89780c97c42fa9836cbb1f551e98  │ │
│ │ version    │  12675219                                                            │ │
│ │ digest     │  Nnh2Tc5Zls/e4zX2UixnUGlTSjNLKmAAjEc3eV7j5Wc=                        │ │
│ │ objectType │  0x0000..0002::package::Publisher                                    │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0xb544bb8f4fe3c56a760387a4805be2c6c3ff1bda415d942665682f73bece11c1  │ │
│ │ version    │  370791512                                                           │ │
│ │ digest     │  OYncM2ZErlfIfcP1k3CQ5JqolXWbhxo0Z3KXWJStVJU=                        │ │
│ │ objectType │  0x0000..0002::coin::Coin                                            │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0xb62acebb083643c3cfff38bc6eabaf45f15d1af15a0960044ad42c5fc5d770c7  │ │
│ │ version    │  1072214                                                             │ │
│ │ digest     │  wgL2QVfRydWgogebTmGOWve7rJqO3TTElYmoH6IZxjU=                        │ │
│ │ objectType │  0x0000..0002::package::UpgradeCap                                   │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0xc07cbb2261205f3eba6cd6f235042010fb1991d0dc7c553a3238b1e1575a9895  │ │
│ │ version    │  837424                                                              │ │
│ │ digest     │  kg0LlKjUiWWLJRLfqgKgMC9exJHUyLoNzKKxNvJDaSM=                        │ │
│ │ objectType │  0x0000..0002::coin::TreasuryCap                                     │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0xc33281bdceeda81c367d3eaa9c1b1e1d0e641b67d85f9169bd365b6949dc4cc4  │ │
│ │ version    │  370791513                                                           │ │
│ │ digest     │  b7XmKyFnJFqniZgpEzFBkwdgwi/y5hRw3I2Vpq54eOU=                        │ │
│ │ objectType │  0x4cb6..4575::flatland::Flatlander                                  │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0xd37f76cf61c2e8e1e0929925c0640fa8b62a53e8bbeb40dd1993d040de9d6a4b  │ │
│ │ version    │  12675221                                                            │ │
│ │ digest     │  GceZBykudCBpzV1qdoEpOkq3z+Pj/pZp0vHDkGxURp4=                        │ │
│ │ objectType │  0x0000..0002::package::Publisher                                    │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0xd9000c558ce3e08f3fa3a0f342d93aa33df08525f98dc5babc2dccd619b76274  │ │
│ │ version    │  399111039                                                           │ │
│ │ digest     │  9tHIZWdtmuZKqq6W1is4wTS1FZwt5UNdtWeWocayp3M=                        │ │
│ │ objectType │  0x0000..0002::coin::Coin                                            │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0xe04f93855dbda0a47ae90f4137a470d959ea6f363aa3645fb9cd198bc88d18d9  │ │
│ │ version    │  18128026                                                            │ │
│ │ digest     │  JAsKJkDSDAIK1IQ9CAnuom52TSgwMnrg7AD/ZKrSdfE=                        │ │
│ │ objectType │  0x7b3b..9af3::hello_move::Hello                                     │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0xfc68199bb0462b5b4e428b8e377e7b6580ab35279e36189ffb9f7773d6f71c35  │ │
│ │ version    │  837424                                                              │ │
│ │ digest     │  WLiszzOFizCF2zw9cC98cp01tj3iXffmDZWfAuri9A4=                        │ │
│ │ objectType │  0x0000..0002::package::UpgradeCap                                   │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0xfcbba6fa3db9cc1ebcdcb80650370063ff28258166368ca95b4828c55e9fdae8  │ │
│ │ version    │  12675221                                                            │ │
│ │ digest     │  hCRqYYPDfdAXOOis8ZniyHSO5vnAda/PkgpwfR2Pn5E=                        │ │
│ │ objectType │  0x0000..0002::package::UpgradeCap                                   │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0xff205b3cc2b46c9c9fa29e3c0f6fc8548f6858f9456fd5f935594fd37c68ce9e  │ │
│ │ version    │  236314046                                                           │ │
│ │ digest     │  85UGa9ybGnV3Y3oe4FNC9qGzO1zIEoWxFbXph+XcNkk=                        │ │
│ │ objectType │  0x0000..0002::package::UpgradeCap                                   │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
│ ╭────────────┬──────────────────────────────────────────────────────────────────────╮ │
│ │ objectId   │  0xffa312de38e37bf742aa695e1d38a4e247846fad894f8e4f2bb73a29ecb81349  │ │
│ │ version    │  12675219                                                            │ │
│ │ digest     │  zAUEEMEIGLqqwfU2XJw6BUILlyHV5BvsO8YAWHgdsLI=                        │ │
│ │ objectType │  0x0000..0002::package::Publisher                                    │ │
│ ╰────────────┴──────────────────────────────────────────────────────────────────────╯ │
╰───────────────────────────────────────────────────────────────────────────────────────╯
```

### 查看指定 Object 详情

```bash
sui client object 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed
╭───────────────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮
│ objectId      │  0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed                                                 │
│ version       │  370791517                                                                                                          │
│ digest        │  2pHqGLqnMXNKp5DbaiJo1ztAtGGHshkW3XbqaMwuq9br                                                                       │
│ objType       │  0x2::coin::Coin<0x2::sui::SUI>                                                                                     │
│ owner         │ ╭──────────────┬──────────────────────────────────────────────────────────────────────╮                             │
│               │ │ AddressOwner │  0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73  │                             │
│               │ ╰──────────────┴──────────────────────────────────────────────────────────────────────╯                             │
│ prevTx        │  3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD                                                                       │
│ storageRebate │  988000                                                                                                             │
│ content       │ ╭───────────────────┬─────────────────────────────────────────────────────────────────────────────────────────────╮ │
│               │ │ dataType          │  moveObject                                                                                 │ │
│               │ │ type              │  0x2::coin::Coin<0x2::sui::SUI>                                                             │ │
│               │ │ hasPublicTransfer │  true                                                                                       │ │
│               │ │ fields            │ ╭─────────┬───────────────────────────────────────────────────────────────────────────────╮ │ │
│               │ │                   │ │ balance │  12814915708                                                                  │ │ │
│               │ │                   │ │ id      │ ╭────┬──────────────────────────────────────────────────────────────────────╮ │ │ │
│               │ │                   │ │         │ │ id │  0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed  │ │ │ │
│               │ │                   │ │         │ ╰────┴──────────────────────────────────────────────────────────────────────╯ │ │ │
│               │ │                   │ ╰─────────┴───────────────────────────────────────────────────────────────────────────────╯ │ │
│               │ ╰───────────────────┴─────────────────────────────────────────────────────────────────────────────────────────────╯ │
╰───────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯
```

### Split Coin

```bash
sui client split-coin --coin-id 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed --count 2 --gas 0xd9000c558ce3e08f3fa3a0f342d93aa33df08525f98dc5babc2dccd619b76274 --gas-budget 1000000000
Transaction Digest: 6F5zBcuML2G6f5TS71yRiCK5guDXd1VY8NvJkNkqgt7p
╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Data                                                                                │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                      │
│ Gas Owner: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                   │
│ Gas Budget: 1000000000 MIST                                                                     │
│ Gas Price: 1000 MIST                                                                            │
│ Gas Payment:                                                                                    │
│  ┌──                                                                                            │
│  │ ID: 0xd9000c558ce3e08f3fa3a0f342d93aa33df08525f98dc5babc2dccd619b76274                       │
│  │ Version: 399111039                                                                           │
│  │ Digest: HcUpwkDsfTXRHLc9uAwGNTsozkjeDVy6bfBA24Uxb2eE                                         │
│  └──                                                                                            │
│                                                                                                 │
│ Transaction Kind: Programmable                                                                  │
│ ╭─────────────────────────────────────────────────────────────────────────────────────────────╮ │
│ │ Input Objects                                                                               │ │
│ ├─────────────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ 0   Imm/Owned Object ID: 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed │ │
│ │ 1   Pure Arg: Type: u64, Value: "2"                                                         │ │
│ ╰─────────────────────────────────────────────────────────────────────────────────────────────╯ │
│ ╭──────────────────────────────────────────────────────────────────────────────────╮            │
│ │ Commands                                                                         │            │
│ ├──────────────────────────────────────────────────────────────────────────────────┤            │
│ │ 0  MoveCall:                                                                     │            │
│ │  ┌                                                                               │            │
│ │  │ Function:  divide_and_keep                                                    │            │
│ │  │ Module:    pay                                                                │            │
│ │  │ Package:   0x0000000000000000000000000000000000000000000000000000000000000002 │            │
│ │  │ Type Arguments:                                                               │            │
│ │  │   0x2::sui::SUI                                                               │            │
│ │  │ Arguments:                                                                    │            │
│ │  │   Input  0                                                                    │            │
│ │  │   Input  1                                                                    │            │
│ │  └                                                                               │            │
│ ╰──────────────────────────────────────────────────────────────────────────────────╯            │
│                                                                                                 │
│ Signatures:                                                                                     │
│    3kEJFaE4+U2TSGPcP33t1XbZI3GPEfS8FOlbsmh2BTfAOr7bw4zg+zuwUBgeSdBfeJeziSpscziqCqJnW42+Cg==     │
│                                                                                                 │
╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Effects                                                                               │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Digest: 6F5zBcuML2G6f5TS71yRiCK5guDXd1VY8NvJkNkqgt7p                                              │
│ Status: Success                                                                                   │
│ Executed Epoch: 699                                                                               │
│                                                                                                   │
│ Created Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0xf6752241209517536c265ee3d1b49b1b290e26bc36589eafbec0e68fb0893aff                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 399111040                                                                             │
│  │ Digest: FZiuR44s9ZG5pGpGwGvm6RU4nushgXsTS4cKbpUwyuN5                                           │
│  └──                                                                                              │
│ Mutated Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 399111040                                                                             │
│  │ Digest: 8DF963wJe8EFNZNdcGCcpr52G2jxVwiMNPewUsypz8gV                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0xd9000c558ce3e08f3fa3a0f342d93aa33df08525f98dc5babc2dccd619b76274                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 399111040                                                                             │
│  │ Digest: 5QkyjcFVgPwQ7ptTtueBLQ2AQoNUbRcxWoLkNj6Jmu5y                                           │
│  └──                                                                                              │
│ Gas Object:                                                                                       │
│  ┌──                                                                                              │
│  │ ID: 0xd9000c558ce3e08f3fa3a0f342d93aa33df08525f98dc5babc2dccd619b76274                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 399111040                                                                             │
│  │ Digest: 5QkyjcFVgPwQ7ptTtueBLQ2AQoNUbRcxWoLkNj6Jmu5y                                           │
│  └──                                                                                              │
│ Gas Cost Summary:                                                                                 │
│    Storage Cost: 2964000 MIST                                                                     │
│    Computation Cost: 1000000 MIST                                                                 │
│    Storage Rebate: 1956240 MIST                                                                   │
│    Non-refundable Storage Fee: 19760 MIST                                                         │
│                                                                                                   │
│ Transaction Dependencies:                                                                         │
│    2KKFDYfXCwBWaS1e3i4gLnjW1DsQoWqYQMb4SVBZFQR2                                                   │
│    3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD                                                   │
│    6MQz7eaiqZps58rfE3cpnQR9RbvbDNQXYVgL56wsrVj6                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─────────────────────────────╮
│ No transaction block events │
╰─────────────────────────────╯

╭──────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                   │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0xf6752241209517536c265ee3d1b49b1b290e26bc36589eafbec0e68fb0893aff                  │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                    │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 399111040                                                                            │
│  │ Digest: FZiuR44s9ZG5pGpGwGvm6RU4nushgXsTS4cKbpUwyuN5                                          │
│  └──                                                                                             │
│ Mutated Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed                  │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                    │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 399111040                                                                            │
│  │ Digest: 8DF963wJe8EFNZNdcGCcpr52G2jxVwiMNPewUsypz8gV                                          │
│  └──                                                                                             │
│  ┌──                                                                                             │
│  │ ObjectID: 0xd9000c558ce3e08f3fa3a0f342d93aa33df08525f98dc5babc2dccd619b76274                  │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                    │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 399111040                                                                            │
│  │ Digest: 5QkyjcFVgPwQ7ptTtueBLQ2AQoNUbRcxWoLkNj6Jmu5y                                          │
│  └──                                                                                             │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Balance Changes                                                                                   │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                              │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ CoinType: 0x2::sui::SUI                                                                        │
│  │ Amount: -2007760                                                                               │
│  └──                                                                                              │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯
```

查看 Split 之后的 coins

```bash
sui client gas
╭────────────────────────────────────────────────────────────────────┬────────────────────┬──────────────────╮
│ gasCoinId                                                          │ mistBalance (MIST) │ suiBalance (SUI) │
├────────────────────────────────────────────────────────────────────┼────────────────────┼──────────────────┤
│ 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed │ 6407457854         │ 6.40             │
│ 0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a │ 1000000000         │ 1.00             │
│ 0xd9000c558ce3e08f3fa3a0f342d93aa33df08525f98dc5babc2dccd619b76274 │ 19997992240        │ 19.99            │
│ 0xf6752241209517536c265ee3d1b49b1b290e26bc36589eafbec0e68fb0893aff │ 6407457854         │ 6.40             │
╰────────────────────────────────────────────────────────────────────┴────────────────────┴──────────────────╯
```

### Merge coin

```bash
sui client merge-coin --primary-coin 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed --coin-to-merge 0xf6752241209517536c265ee3d1b49b1b290e26bc36589eafbec0e68fb0893aff --gas-budget 1000000000
Transaction Digest: AFkG2UQqbzwE1oGh2FadRrgbSzhSUDPirtu2UbMwFsN6
╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Data                                                                                │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                      │
│ Gas Owner: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                   │
│ Gas Budget: 1000000000 MIST                                                                     │
│ Gas Price: 1000 MIST                                                                            │
│ Gas Payment:                                                                                    │
│  ┌──                                                                                            │
│  │ ID: 0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a                       │
│  │ Version: 370791517                                                                           │
│  │ Digest: FRUP5KBKXGBZe19zCnBe2dc8rvD9fHks6VvCzJRHmxtf                                         │
│  └──                                                                                            │
│                                                                                                 │
│ Transaction Kind: Programmable                                                                  │
│ ╭─────────────────────────────────────────────────────────────────────────────────────────────╮ │
│ │ Input Objects                                                                               │ │
│ ├─────────────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ 0   Imm/Owned Object ID: 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed │ │
│ │ 1   Imm/Owned Object ID: 0xf6752241209517536c265ee3d1b49b1b290e26bc36589eafbec0e68fb0893aff │ │
│ ╰─────────────────────────────────────────────────────────────────────────────────────────────╯ │
│ ╭──────────────────────────────────────────────────────────────────────────────────╮            │
│ │ Commands                                                                         │            │
│ ├──────────────────────────────────────────────────────────────────────────────────┤            │
│ │ 0  MoveCall:                                                                     │            │
│ │  ┌                                                                               │            │
│ │  │ Function:  join                                                               │            │
│ │  │ Module:    pay                                                                │            │
│ │  │ Package:   0x0000000000000000000000000000000000000000000000000000000000000002 │            │
│ │  │ Type Arguments:                                                               │            │
│ │  │   0x2::sui::SUI                                                               │            │
│ │  │ Arguments:                                                                    │            │
│ │  │   Input  0                                                                    │            │
│ │  │   Input  1                                                                    │            │
│ │  └                                                                               │            │
│ ╰──────────────────────────────────────────────────────────────────────────────────╯            │
│                                                                                                 │
│ Signatures:                                                                                     │
│    fWBTfwWo9pPdx32RwkUpItrt3opKh4xTjv2jsH/twtDv/7kmqcSoeZPiVrnXXI4wi0jt5HP/fIRE8PefpUa9Bw==     │
│                                                                                                 │
╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Effects                                                                               │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Digest: AFkG2UQqbzwE1oGh2FadRrgbSzhSUDPirtu2UbMwFsN6                                              │
│ Status: Success                                                                                   │
│ Executed Epoch: 699                                                                               │
│ Mutated Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 399111041                                                                             │
│  │ Digest: CXSmGR9nwcqXNzztJqPM31RjaXunh33E2gegafkc1L7w                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 399111041                                                                             │
│  │ Digest: 5k6pcJvChZf6WDirTMWA5jwDdDWpAo3uAaQj6Rqtuvzx                                           │
│  └──                                                                                              │
│ Deleted Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0xf6752241209517536c265ee3d1b49b1b290e26bc36589eafbec0e68fb0893aff                         │
│  │ Version: 399111041                                                                             │
│  │ Digest: 7gyGAp71YXQRoxmFBaHxofQXAipvgHyBKPyxmdSJxyvz                                           │
│  └──                                                                                              │
│ Gas Object:                                                                                       │
│  ┌──                                                                                              │
│  │ ID: 0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 399111041                                                                             │
│  │ Digest: 5k6pcJvChZf6WDirTMWA5jwDdDWpAo3uAaQj6Rqtuvzx                                           │
│  └──                                                                                              │
│ Gas Cost Summary:                                                                                 │
│    Storage Cost: 1976000 MIST                                                                     │
│    Computation Cost: 1000000 MIST                                                                 │
│    Storage Rebate: 2934360 MIST                                                                   │
│    Non-refundable Storage Fee: 29640 MIST                                                         │
│                                                                                                   │
│ Transaction Dependencies:                                                                         │
│    2KKFDYfXCwBWaS1e3i4gLnjW1DsQoWqYQMb4SVBZFQR2                                                   │
│    3FopuDy5qzKm1kLRFZCdi8Lynadym9j15NaVxzUH6nYD                                                   │
│    6F5zBcuML2G6f5TS71yRiCK5guDXd1VY8NvJkNkqgt7p                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─────────────────────────────╮
│ No transaction block events │
╰─────────────────────────────╯

╭──────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                   │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Mutated Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed                  │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                    │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 399111041                                                                            │
│  │ Digest: CXSmGR9nwcqXNzztJqPM31RjaXunh33E2gegafkc1L7w                                          │
│  └──                                                                                             │
│  ┌──                                                                                             │
│  │ ObjectID: 0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a                  │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                    │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 399111041                                                                            │
│  │ Digest: 5k6pcJvChZf6WDirTMWA5jwDdDWpAo3uAaQj6Rqtuvzx                                          │
│  └──                                                                                             │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Balance Changes                                                                                   │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                              │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ CoinType: 0x2::sui::SUI                                                                        │
│  │ Amount: -41640                                                                                 │
│  └──                                                                                              │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯
```

#### Merge 查看 coin 情况

没有指定gas 地址， 会随机选择一个地址来支付gas，这里它选择了 `0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a`这个地址。

```bash
sui client gas
╭────────────────────────────────────────────────────────────────────┬────────────────────┬──────────────────╮
│ gasCoinId                                                          │ mistBalance (MIST) │ suiBalance (SUI) │
├────────────────────────────────────────────────────────────────────┼────────────────────┼──────────────────┤
│ 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed │ 12814915708        │ 12.81            │
│ 0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a │ 999958360          │ 0.99             │
│ 0xd9000c558ce3e08f3fa3a0f342d93aa33df08525f98dc5babc2dccd619b76274 │ 19997992240        │ 19.99            │
╰────────────────────────────────────────────────────────────────────┴────────────────────┴──────────────────╯
```

### 创建一个新的 Sui Move 项目

```bash
sui move new package_name
```

### 构建项目

```bash
sui move build
```

### 测试项目

```bash
sui move test
```

### 部署合约

```bash
sui client publish --gas-budget 100000000 --skip-fetch-latest-git-deps 
```

### 调用合约

```bash
sui client call --function faucet_coin_to_mycoin --module move_swap --package $PACKAGE_ID --args $POOL $FAUCET_COIN --gas-budget 10000000

sui client call --package 0x09e14939fb34df6f3322aee8ccc6b11bf8f5a77b68e82a77b3edcf91515b74c5 --module sui_nft --function transfer --args 0x6f0da7613e0c334f2f28dabd9e48ed46fd57e5f0e94426dd03feed98ce11ab91 0x7b8e0864967427679b4e129f79dc332a885c6087ec9e187b53451a9006ee15f2 --gas-budget 10000000
```

### 调用合约方法来 Split coin

```bash
sui client call --package 0x2 --module pay --function split --type-args 0x2::sui::SUI --args 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed 2000000000
Transaction Digest: A6Fgx233bcF8GSckXe8YyFJ4UWLW1zjN4UiX61QwTsuP
╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Data                                                                                │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                      │
│ Gas Owner: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                   │
│ Gas Budget: 3985880 MIST                                                                        │
│ Gas Price: 1000 MIST                                                                            │
│ Gas Payment:                                                                                    │
│  ┌──                                                                                            │
│  │ ID: 0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a                       │
│  │ Version: 399111041                                                                           │
│  │ Digest: 5k6pcJvChZf6WDirTMWA5jwDdDWpAo3uAaQj6Rqtuvzx                                         │
│  └──                                                                                            │
│                                                                                                 │
│ Transaction Kind: Programmable                                                                  │
│ ╭─────────────────────────────────────────────────────────────────────────────────────────────╮ │
│ │ Input Objects                                                                               │ │
│ ├─────────────────────────────────────────────────────────────────────────────────────────────┤ │
│ │ 0   Imm/Owned Object ID: 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed │ │
│ │ 1   Pure Arg: Type: u64, Value: "2000000000"                                                │ │
│ ╰─────────────────────────────────────────────────────────────────────────────────────────────╯ │
│ ╭──────────────────────────────────────────────────────────────────────────────────╮            │
│ │ Commands                                                                         │            │
│ ├──────────────────────────────────────────────────────────────────────────────────┤            │
│ │ 0  MoveCall:                                                                     │            │
│ │  ┌                                                                               │            │
│ │  │ Function:  split                                                              │            │
│ │  │ Module:    pay                                                                │            │
│ │  │ Package:   0x0000000000000000000000000000000000000000000000000000000000000002 │            │
│ │  │ Type Arguments:                                                               │            │
│ │  │   0x2::sui::SUI                                                               │            │
│ │  │ Arguments:                                                                    │            │
│ │  │   Input  0                                                                    │            │
│ │  │   Input  1                                                                    │            │
│ │  └                                                                               │            │
│ ╰──────────────────────────────────────────────────────────────────────────────────╯            │
│                                                                                                 │
│ Signatures:                                                                                     │
│    MefytN3DueqiRl0kYRIQ9zZg7hBKocSxrLmbtt/WY30wY3lvLeB8w880SSbEPMcVKrZx+0+n1wMoIjdfkNi9Ag==     │
│                                                                                                 │
╰─────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Transaction Effects                                                                               │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Digest: A6Fgx233bcF8GSckXe8YyFJ4UWLW1zjN4UiX61QwTsuP                                              │
│ Status: Success                                                                                   │
│ Executed Epoch: 699                                                                               │
│                                                                                                   │
│ Created Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0xaf62ad2387b662cd4bb8849ca7d998930263af840b25ddce4215f1ce958819ad                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 399111042                                                                             │
│  │ Digest: 2Dog5wzECmtFavxgTo6hd8sJhH7V9q2vAGomeQz36EFa                                           │
│  └──                                                                                              │
│ Mutated Objects:                                                                                  │
│  ┌──                                                                                              │
│  │ ID: 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 399111042                                                                             │
│  │ Digest: 4EmL5Jt8VKX933zr8SBNxovzKeVzo2HZS1tK16hE9PWE                                           │
│  └──                                                                                              │
│  ┌──                                                                                              │
│  │ ID: 0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 399111042                                                                             │
│  │ Digest: 7RcdE61K81M4e6RKuXVD3o5oQUNqwdgywLADAwpVU6qu                                           │
│  └──                                                                                              │
│ Gas Object:                                                                                       │
│  ┌──                                                                                              │
│  │ ID: 0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a                         │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ Version: 399111042                                                                             │
│  │ Digest: 7RcdE61K81M4e6RKuXVD3o5oQUNqwdgywLADAwpVU6qu                                           │
│  └──                                                                                              │
│ Gas Cost Summary:                                                                                 │
│    Storage Cost: 2964000 MIST                                                                     │
│    Computation Cost: 1000000 MIST                                                                 │
│    Storage Rebate: 1956240 MIST                                                                   │
│    Non-refundable Storage Fee: 19760 MIST                                                         │
│                                                                                                   │
│ Transaction Dependencies:                                                                         │
│    2KKFDYfXCwBWaS1e3i4gLnjW1DsQoWqYQMb4SVBZFQR2                                                   │
│    AFkG2UQqbzwE1oGh2FadRrgbSzhSUDPirtu2UbMwFsN6                                                   │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯
╭─────────────────────────────╮
│ No transaction block events │
╰─────────────────────────────╯

╭──────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Object Changes                                                                                   │
├──────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0xaf62ad2387b662cd4bb8849ca7d998930263af840b25ddce4215f1ce958819ad                  │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                    │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 399111042                                                                            │
│  │ Digest: 2Dog5wzECmtFavxgTo6hd8sJhH7V9q2vAGomeQz36EFa                                          │
│  └──                                                                                             │
│ Mutated Objects:                                                                                 │
│  ┌──                                                                                             │
│  │ ObjectID: 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed                  │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                    │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 399111042                                                                            │
│  │ Digest: 4EmL5Jt8VKX933zr8SBNxovzKeVzo2HZS1tK16hE9PWE                                          │
│  └──                                                                                             │
│  ┌──                                                                                             │
│  │ ObjectID: 0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a                  │
│  │ Sender: 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73                    │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 ) │
│  │ ObjectType: 0x2::coin::Coin<0x2::sui::SUI>                                                    │
│  │ Version: 399111042                                                                            │
│  │ Digest: 7RcdE61K81M4e6RKuXVD3o5oQUNqwdgywLADAwpVU6qu                                          │
│  └──                                                                                             │
╰──────────────────────────────────────────────────────────────────────────────────────────────────╯
╭───────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Balance Changes                                                                                   │
├───────────────────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──                                                                                              │
│  │ Owner: Account Address ( 0x35370841d2e69b495b1e2f944a3087e4242f314e503691a00b054e0ee2a45a73 )  │
│  │ CoinType: 0x2::sui::SUI                                                                        │
│  │ Amount: -2007760                                                                               │
│  └──                                                                                              │
╰───────────────────────────────────────────────────────────────────────────────────────────────────╯
```

查看调用之后的 coin

```bash
sui client gas
╭────────────────────────────────────────────────────────────────────┬────────────────────┬──────────────────╮
│ gasCoinId                                                          │ mistBalance (MIST) │ suiBalance (SUI) │
├────────────────────────────────────────────────────────────────────┼────────────────────┼──────────────────┤
│ 0x09ae107f8b03e0297bd8419d9aba9cc3358dd638ca3a8d7cf7c60de3c0eb51ed │ 10814915708        │ 10.81            │
│ 0x3229652b63642e73ad6201462a2dd28af3b84580a7c7d5350ee460598fd5701a │ 997950600          │ 0.99             │
│ 0xaf62ad2387b662cd4bb8849ca7d998930263af840b25ddce4215f1ce958819ad │ 2000000000         │ 2.00             │
│ 0xd9000c558ce3e08f3fa3a0f342d93aa33df08525f98dc5babc2dccd619b76274 │ 19997992240        │ 19.99            │
╰────────────────────────────────────────────────────────────────────┴────────────────────┴──────────────────╯
```

### 查看余额

```bash
sui client balance
╭────────────────────────────────────────╮
│ Balance of coins owned by this address │
├────────────────────────────────────────┤
│ ╭──────────────────────────────────╮   │
│ │ coin  balance (raw)  balance     │   │
│ ├──────────────────────────────────┤   │
│ │ Sui   33810858548    33.81 SUI   │   │
│ │ WAL   0              0.00 WAL    │   │
│ ╰──────────────────────────────────╯   │
╰────────────────────────────────────────╯
```

## 总结

Sui 区块链凭借以 Object 为中心的架构和 Move 语言的强力加持，为 Web3 世界带来了高效、安全的资产管理新范式。其并行化交易设计和高性能表现，不仅突破了传统区块链的瓶颈，也为开发者提供了广阔的创新空间。通过本文的实操指引，你已迈出探索 Sui 的第一步。赶快动手实践，拥抱这一 Web3 新星，开启你的区块链开发之旅吧！

## 参考

- <https://github.com/SuiMover/Sui-Mover-2024-2/blob/main/Lesson1/Lesson1.pdf>
- <https://suivision.xyz/>
- <https://suiwallet.com/>
- <https://www.youtube.com/watch?v=ZQVI1Qap7Fk&list=PL6nlW1oaFlFCs0hXHnVUq5WbNJBlw78fI&index=2&t=16s>
