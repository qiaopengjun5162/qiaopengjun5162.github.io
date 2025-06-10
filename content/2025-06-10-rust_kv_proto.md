+++
title = "Rust + Protobuf：从零打造高效键值存储项目"
description = "Rust + Protobuf：从零打造高效键值存储项目"
date = 2025-06-10T06:07:42Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust + Protobuf：从零打造高效键值存储项目

Rust 以其卓越的性能、内存安全和并发能力席卷开发圈，Protobuf 则以高效的序列化能力成为现代系统开发的利器。本文将带你通过一个简单却实用的键值存储（Key-Value Store）项目，结合 Rust 和 Protobuf，从零开始探索高效系统开发的魅力。无论你是 Rust 新手，还是想掌握 Protobuf 在实际项目中的应用，这篇教程都将为你提供清晰的步骤和实操经验，助你快速上手，解锁 Rust 开发的无限可能！

本文通过一个键值存储项目的完整开发流程，详细讲解如何使用 Rust 和 Protobuf 构建高效应用。从项目初始化、配置 Cargo 依赖、定义 Protobuf 协议文件，到编写构建脚本和核心逻辑，教程步步拆解，代码清晰易懂。借助 prost 库处理 Protobuf 序列化，我们展示了 Rust 的强大性能与 Protobuf 的高效数据传输能力。无论你是初学者还是进阶开发者，都能通过本文快速掌握 Rust 项目开发和 Protobuf 集成的核心技巧。

## 实操

### 创建项目

```bash
cargo new kv
```

### 切换到项目目录

```bash
cd kv
```

### 用 vscode 打开项目

```bash
c # code .
```

### 创建 build.rs 文件

```bash
touch build.rs
```

### 编译构建项目

```bash
cargo build
```

### 运行项目

```shell
cargo run
```

### 查看项目目录

```bash
kv on  master [?] is 📦 0.1.0 via 🦀 1.87.0 via 🅒 base 
➜ tree -a -I "target|.git"
.
├── .gitignore
├── .vscode
│   └── settings.json
├── Cargo.lock
├── Cargo.toml
├── abi.proto
├── build.rs
└── src
    ├── main.rs
    └── pb
        ├── abi.rs
        └── mod.rs

4 directories, 9 files

```

### Cargo.toml 文件

```toml
[package]
name = "kv"
version = "0.1.0"
edition = "2024"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
tokio = "1.29.1"
prost = "0.11.9"
# Only necessary if using Protobuf well-known types:
prost-types = "0.11.9"

[build-dependencies]
prost-build = "0.11.9"

```

### abi.proto 文件

```protobuf
syntax = "proto3";

package abi;

message Request {
    oneof message {
        RequestGet get = 1;
        RequestPut put = 2;
    }
}

message Response {
    uint32 code = 1;
    string Key = 2;
    string value = 3;
}

message RequestGet {
    string Key = 1;
}

message RequestPut {
    string Key = 1;
    bytes value = 2;
}

```

### build.rs 文件

```rust
fn main() {
    prost_build::Config::new()
        .out_dir("src/pb")
        .compile_protos(&["abi.proto"], &["."])
        .unwrap();
}

```

### src/pb/mod.rs 文件

```rust
mod abi;
pub use abi::*;

```

### src/main.rs 文件

```rust
mod pb;

use prost::Message;

use crate::pb::RequestGet;

fn main() {
    let request = RequestGet {
        key: "hello".to_string(),
    };
    let mut buf = Vec::new();
    request.encode(&mut buf).unwrap();
    println!("encoded: {:?}", buf);
}

```

### 编译运行项目

```shell
kv on  master [?] is 📦 0.1.0 via 🦀 1.71.0 via 🅒 base took 3.6s 
➜ cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 0.03s
     Running `target/debug/kv`
encoded: [10, 5, 104, 101, 108, 108, 111]

```

## 总结

通过本教程，你已成功用 Rust 和 Protobuf 打造了一个高效的键值存储项目。从 cargo new 初始化到 Protobuf 文件的定义，再到编码、编译和运行，我们完整走通了 Rust 开发的典型流程，体验了 Protobuf 在数据序列化中的便捷与高效。这个项目不仅让你熟悉了 Rust 的项目结构和生态工具，还为进一步探索异步编程、网络服务等高级主题打下坚实基础。赶快动手实践，结合文末参考资源，深入 Rust 和 Protobuf 的世界，开启你的高效开发之旅！

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://crates.io/>
- <https://course.rs/about-book.html>
- <https://lab.cs.tsinghua.edu.cn/rust/>
- <https://llever.com/exercism-rust-zh/index.html>
- <https://rustinblockchain.org/?ref=inboxreads>
- <https://crates.io/crates/cargo-risczero>
- <https://github.com/risc0>
