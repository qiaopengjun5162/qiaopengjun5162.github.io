+++
title = "从零开始：用 Rust 和 Axum 打造高效 Web 服务"
description = "从零开始：用 Rust 和 Axum 打造高效 Web 服务"
date = 2025-05-14T02:39:38Z
[taxonomies]
categories = ["Rust", "Web", "Axum"]
tags = ["Rust", "Web", "Axum"]
+++

<!-- more -->

# 从零开始：用 Rust 和 Axum 打造高效 Web 服务

Rust 以其卓越的性能和内存安全性席卷编程世界，成为现代 Web 开发的热门选择。Axum 作为 Rust 生态中的轻量级 Web 框架，结合 Tokio 异步运行时的强大能力，让开发者能轻松构建高效、可靠的 Web 服务。无论你是 Rust 新手，还是希望快速上手 Web 开发，这篇手把手教程将带你通过 rust-axum-intro 项目，从零开始搭建一个简单的 Web 服务器，并通过测试验证其功能。只需几行代码，你就能解锁 Rust 在 Web 开发中的无限可能！快来跟随我们，开启这场高效开发之旅吧！

本文通过 rust-axum-intro 项目，详细演示如何使用 Rust 和 Axum 框架快速构建一个监听 <http://localhost:8080> 的 Web 服务器，处理 /hello?name=xxx 端点的 GET 请求，动态生成个性化 HTML 问候页面。从项目初始化、依赖配置、核心代码实现到异步测试，文章完整呈现了开发全流程。核心代码利用 Axum 的路由和查询参数处理功能，结合 Tokio 异步运行时实现高效请求处理；测试代码通过 httpc-test 验证服务功能；cargo-watch 工具则优化了开发体验。适合 Rust 初学者和 Web 开发爱好者，本文提供清晰的实践指南，助你快速上手高性能 Web 服务开发！

## 实操

rust-axum-intro 项目实操

### 实操步骤

```bash
 2311  cd Code/rust
 2312  cargo new rust-axum-intro
 2313  cd rust-axum-intro
 2314  c
 2315* cargo add tokio --features full
 2316* cargo add axum
 2317* cargo run
 2318* touch tests/quick_dev.rs
 2319* mkdir tests
 2320* touch tests/quick_dev.rs
 2321  cargo watch -q -c -w src -x run
 2322  cargo install cargo-watch
 2323  cargo watch --version\n
 2324  cargo watch -q -c -w src -x run
 2325  cargo watch -q -c -w tests -x "test -q quick_dev -- --nocapture"
 2326* git add .
 2327* git commit -m "first commit"
 2328  cargo watch -q -c -w tests -x "test -q quick_dev -- --nocapture"
 2329* cd blog/qiaoblog
```

### `Cargo.toml` 文件

```rust
[package]
name = "rust-axum-intro"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
axum = "0.6.20"
tokio = { version = "1.31.0", features = ["full"] }
serde ={ version =  "1.0.183", features = ["derive"]}
serde_json = "1.0.104"

[dev-dependencies]
anyhow = "1.0.73"
httpc-test = "0.1.5" # Uses reqwest & cookie store.

```

### `main.rs` 代码实现

```rust
#![allow(unused)] // For beginning only.

use std::net::SocketAddr;

use axum::{
    extract::Query,
    response::{Html, IntoResponse},
    routing::get,
    Router,
};
use serde::Deserialize;

#[tokio::main]
async fn main() {
    let routes_hello = Router::new().route(
        "/hello",
        // get(|| async { Html("Hello <strong>World!!!</strong>") }),
        get(handler_hello),
    );

    // region:  --- Start Server
    let addr = SocketAddr::from(([127, 0, 0, 1], 8080));
    println!("->> LISTENING on {addr}\n");
    axum::Server::bind(&addr)
        .serve(routes_hello.into_make_service())
        .await
        .unwrap();
    // endregion:  --- Start Server
}

// region: --- Handler Hello
#[derive(Debug, Deserialize)]
struct HelloParams {
    name: Option<String>,
}

// e.g., `/hello?name=Qiao`
async fn handler_hello(Query(params): Query<HelloParams>) -> impl IntoResponse {
    println!("->> {:<12} - handler_hello - {params:?}", "HANDLER");

    let name = params.name.as_deref().unwrap_or("World");

    // Html("Hello <strong>World!!!</strong>")
    Html(format!("Hello <strong>{name}!!!</strong>"))
}
// endregion: --- Handler Hello

```

这段 Rust 代码使用 axum 框架构建了一个简单的 Web 服务器，监听 <http://localhost:8080> 并处理 /hello 端点的 GET 请求。#![allow(unused)] 忽略未使用代码的警告，便于开发初期。代码通过 use 语句引入必要模块，包括 std::net::SocketAddr 用于网络地址、axum 的路由和响应功能，以及 serde 的反序列化功能。在 main 函数中，使用 tokio::main 宏创建异步运行时，定义一个路由 /hello，绑定到 handler_hello 处理函数，并启动服务器监听 127.0.0.1:8080。handler_hello 函数处理 /hello?name=xxx 格式的请求，通过 Query<HelloParams> 提取查询参数 name，若无参数则默认使用 "World"，返回格式化的 HTML 响应，如 Hello <strong>Qiao!!!</strong>。此代码实现了一个简单的 Web 服务，用于动态生成带有用户指定或默认名称的问候页面。

### 测试代码实现

```rust
#![allow(unused)] // For beginning only.

use anyhow::Result;

#[tokio::test]
async fn quick_dev() -> Result<()> {
    let hc = httpc_test::new_client("http://localhost:8080")?;

    hc.do_get("/hello?name=Qiao").await?.print().await?;

    Ok(())
}

```

这段 Rust 代码是一个使用 tokio 框架编写的异步测试用例，用于验证 HTTP 客户端与本地服务器的交互。#![allow(unused)] 忽略未使用代码的警告，便于开发初期。use anyhow::Result 引入错误处理类型。#[tokio::test] 标记异步测试函数 quick_dev，它创建一个连接到 <http://localhost:8080> 的 HTTP 客户端（通过 httpc_test::new_client），向 /hello?name=Qiao 发送 GET 请求，异步等待响应并打印结果，最后返回 Ok(()) 表示成功。此代码用于快速测试本地服务器的 /hello 端点功能。

### 安装依赖并运行

```bash
cargo install cargo-watch
cargo watch -x run
cargo watch -q -c -x 'run -q'
cargo watch -q -c -x 'run -q --example hello'
```

## 总结

通过 rust-axum-intro 项目，我们从零开始搭建了一个高效的 Web 服务器，展示了 Rust 和 Axum 框架在 Web 开发中的强大能力。项目通过简洁的代码实现了动态路由处理，利用 Tokio 的异步运行时确保高效性能，并通过 httpc-test 测试验证了 /hello 端点的功能。Cargo.toml 配置了必要依赖，main.rs 和 quick_dev.rs 分别实现了服务逻辑和测试用例，而 cargo-watch 工具极大提升了开发效率。本教程为 Rust Web 开发的入门提供了实用模板，开发者可在此基础上扩展更多功能，如添加复杂路由或集成数据库。借助文中提供的参考资源，欢迎继续探索 Rust 的高性能世界，打造属于你的下一款 Web 应用！

## 参考

- <https://docs.rs/axum/latest/axum/extract/ws/index.html>
- <https://docs.rs/crate/cargo-watch/8.4.0>
- <https://www.rust-lang.org/zh-CN>
- <https://course.rs/about-book.html>
- <https://users.rust-lang.org/>
