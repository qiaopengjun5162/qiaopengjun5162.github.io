+++
title = "Rust 编程：零基础入门高性能开发"
description = "Rust 编程：零基础入门高性能开发"
date = 2025-05-04T02:42:40Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust 编程：零基础入门高性能开发

想掌握一门兼具 C++ 性能与现代安全性的编程语言？Rust 正是你的理想选择！作为席卷系统编程和高性能开发领域的“新星”，Rust 不仅被 Firefox 和 Google Fuschia 等大厂采用，还因其零基础友好的学习路径受到开发者追捧。本文将带你从安装 Rust 到编写第一个程序，零基础也能快速上手，解锁高性能开发的无限可能！快来跟随这篇入门指南，开启你的 Rust 编程之旅吧！

本文全面介绍 Rust 编程语言的入门知识，涵盖其高性能、内存安全和并发处理的独特优势，以及与 C/C++、Java 等语言的对比。Rust 广泛应用于系统编程、WebAssembly 和高性能 Web 服务，深受 Firefox、Google Fuschia 等项目青睐。文章详细讲解了 Rust 的安装步骤、开发环境配置、第一个“Hello World”程序的编写，以及使用 Cargo 工具进行项目管理。尽管 Rust 学习曲线稍陡，但其强大的性能和安全性使其成为零基础开发者迈向高性能开发的理想起点。

## Rust简介

### 为什么要用Rust？

- Rust是一种令人兴奋的新编程语言，它可以让每个人编写可靠且高效的软件。
- 它可以用来替换C/C++，Rust和他们具有同样的性能，但是很多常见的bug在编译时就可以被消灭。
- Rust是一种通用的编程语言，但是它更善于以下场景：
  - 需要运行时的速度
  - 需要内存安全
  - 更好的利用多处理器

### 与其他语言比较

- C/C++性能非常好，但类型系统和内存都不太安全。
- Java/C#，拥有GC，能保证内存安全，也有很多优秀特性，但是性能不行。
- Rust：
  - 安全
  - 无需GC（性能好速度快）
  - 易于维护、调试、代码安全高效

### Rust特别擅长的领域

- 高性能 Web Service (Web API)
- WebAssembly
- 命令行工具
- 网络编程
- 嵌入式设备
- 系统编程

### Rust与Firefox

- Rust最初是Mazilla公司的一个研究性项目。Firefox是Rust产品应用的一个重要的例子。
- Mazilla 一直以来都在用Rust创建一个名为Servo的实验性浏览器引擎，其中的所有内容都是并行执行的。
  - 目前Servo的部分功能已经被集成到Firefox里面了
- Firefox原来的量子版就包含了Servo的CSS渲染引擎
  - Rust使得Firefox在这方面得到了巨大的性能改进

### Rust的用户和案例

- Google：新操作系统Fuschia，其中Rust代码量大约占30%
- Amazon：基于Linux开发的直接可以在裸机、虚机上运行容器的操作系统
- System76、百度、华为、蚂蚁金服...

### Rust的优点

- 性能
- 安全性
- 无所畏惧的并发

### Rust的缺点

- 学习曲线高 ”难学“

### 注意

- Rust有很多独有的概念，要一步一步学习

## Rust 安装

官网：<https://www.rust-lang.org/zh-CN/learn/get-started>

Windows：按官网指示操作

Mac 安装：

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

```

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img/202302181555079.png)

### 更新与卸载Rust

- 更新Rust

```rust
rustup update
```

- 卸载Rust

```rust
rustup self uninstall
```

### 安装验证

- `rustc --version`
  - 结构格式：rustc x.y.z(abcdbcdbc yyyy-mm-dd)
  - 会现实最新稳定版：版本号、commit hash、commit日期

### 本地文档

- 安装Rust的时候，会在本地安装文档，可离线浏览
- 运行`rustup doc`可在浏览器打开本地文档

```bash
➜ cargo --version
cargo 1.67.1 (8ecd4f20a 2023-01-10)

~
➜ rustc --version
rustc 1.67.1 (d5a82bbd2 2023-02-07)

~
➜ rustup doc
```

### 开发工具

- Visual Studio Code
  - Rust 插件
- Pycharm（Intellij Idea 系列）
  - Rust插件

### Hello World 例子

编写Rust程序

- 程序文件后缀名：rs
- 文件命名规范：hello_world.rs

```bash
➜ mkdir rust

~
➜ cd rust

~/rust
➜ mkdir hello_world

~/rust
➜ cd hello_world

~/rust/hello_world
➜ code .

~/rust/hello_world
➜ pwd
/Users/qiaopengjun/rust/hello_world

~/rust/hello_world via 🦀 1.67.1
➜ mv hello_world.rs main.rs

~/rust/hello_world via 🦀 1.67.1
➜ rustc main.rs

~/rust/hello_world via 🦀 1.67.1
➜ ls
main    main.rs

➜ ./main
Hello World!
```

main.rs`文件

```rust
fn main() {
    println!("Hello World!");
}
```

### Rust 程序解剖

- 定义函数：`fn main(){}`
  - 没有参数，没有返回
- `main`函数很特别：它是每个Rust可执行程序最先运行的代码
- 打印文本：`printIn!("Hello, world!");`
  - Rust的缩进是4个空格而不是tab
  - printIn!是一个Rust macro（宏）
    - 如果是函数的话，就没有!
  - "Hello World" 是字符串，它是printIn!的参数
  - 这行代码以;结尾

## 编译和运行是单独的两步

- 运行Rust程序之前必须先编译，命令为：`rustc`源文件名
  - `rustc main.rs`
- 编译成功后，会生成一个二进制文件
  - 在Windows上还会生产一个`.pdb`文件，里面包含调试信息
- Rust是ahead-of-time编译的语言（预先编译）
  - 可以先编译程序，然后把可执行文件交给别人运行（无需安装Rust）
- Rustc 只适合简单的Rust程序...

### Hello Cargo

### Cargo

- Cargo 是Rust的构建系统和包管理工具
  - 构建代码、下载依赖的库、构建这些苦...
- 安装Rust的时候会安装Cargo
  - Cargo --version

```rust
~/rust/hello_world via 🦀 1.67.1
➜ cargo --version
cargo 1.67.1 (8ecd4f20a 2023-01-10)
```

### 使用Cargo创建项目

- 创建项目：`cargo new hello_cargo`
  - 项目名称也是`hello_cargo`
  - 会创建一个新的目录`hello_cargo`
    - Cargo.toml
    - src目录
      - `main.rs`
    - 初始化了一个新的Git仓库 `.gitignore`
      - 可以使用其它的VCS或不使用VCS：cargo new 的时候使用 --vcs 这个flag

```bash
~/rust
➜ cargo new hello_cargo
     Created binary (application) `hello_cargo` package

~/rust

➜ ls
hello_cargo hello_world

~/rust
➜ cd hello_cargo

hello_cargo on  master [?] via 🦀 1.67.1
➜ ls
Cargo.toml src

hello_cargo on  master [?] via 🦀 1.67.1
➜ ➜ ls
Cargo.toml src
```

#### `Cargo.toml`

- TOML（Tom's Obvious, Minimal Language）格式，是Cargo的配置格式
- [package]，是一个区域标题，表示下方内容是用来配置包（package）的
  - name 项目名
  - version 项目版本
  - authors 项目作者
  - edition 使用的Rust版本
- [dependencies] 另一个区域的开始，它会列出项目的依赖项
- 在Rust里面，代码的包称作crate

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img/202302162243199.png)

#### `src/main.rs`

- cargo 生成的main.rs在src目录下
- 而Cargo.toml在项目顶层下
- 源代码都应该在src目录下
- 顶层目录可以放置：README、许可信息、配置文件和其它与程序源码无关的文件
- 如果创建项目时没有使用cargo，也可以把项目转化为使用cargo：
  - 把源代码文件移动到src下
  - 创建Cargo.toml并填写相应的配置

### 构建Cargo项目 cargo build

- cargo build
  - 创建可执行文件：target/debug/hello_cargo或target\debug\hello_cargo.exe(Windows)
  - 运行可执行文件：`./target/debug/hello_cargo`或`.\target\debug\hello_cargo.exe(Windows)`
- 第一次运行`cargo build`会在顶层目录生成cargo.lock文件
  - 该文件负责追踪项目依赖的精确版本
  - 不需要手动修改该文件

### 构建和运行cargo项目 `cargo run`

- cargo run 编译代码 + 执行结果
  - 如果之前编译成功过，并且源码没有改变，那么就会直接运行二进制文件

```rust
hello_cargo on  master [?] is 📦 0.1.0 via 🦀 1.67.1
➜ cargo run
   Compiling hello_cargo v0.1.0 (/Users/qiaopengjun/rust/hello_cargo)
    Finished dev [unoptimized + debuginfo] target(s) in 0.38s
     Running `target/debug/hello_cargo`
Hello, world!

hello_cargo on  master [?] is 📦 0.1.0 via 🦀 1.67.1
➜
```

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img/202302162243594.png)

#### `cargo check`

- cargo check 检查代码，确保能通过编译，但是不产生任何可执行文件
- cargo chekc 要比 cargo build 快得多
  - 编写代码的时候可以连续反复的使用cargo chekc 检查代码，提高效率

### 为发布构建

- cargo build --release
  - 编译时会进行优化
    - 代码会运行的更快，但是编译时间更长
  - 会在target/release而不是target/debug生成可执行文件
- 两种配置
  - 开发
  - 正式发布

尽量用Cargo

## 总结

Rust 编程语言以其卓越的性能、内存安全性和现代并发能力，正在成为高性能开发领域的首选。从 Firefox 的 CSS 渲染引擎到 Google Fuschia 操作系统，Rust 的实际应用证明了其强大潜力。本文通过安装配置、Hello World 程序和 Cargo 工具的介绍，助你零基础迈出 Rust 学习第一步。尽管 Rust 的独特概念需要时间掌握，但其简洁的语法和强大的生态系统让每位开发者都能轻松上手。立即安装 Rust，编写你的第一个高性能程序，探索编程的未来！

## 参考

- <https://alloy.rs/introduction/getting-started/>
- <https://www.rust-lang.org/zh-CN>
- <https://crates.io/>
- <https://course.rs/about-book.html>
- <https://rustwiki.org/docs/>
- <https://rust-book.junmajinlong.com/ch1/00.html>
