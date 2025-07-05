+++
title = "Rust 网络编程实战：用 Tokio 手写一个迷你 TCP 反向代理 (minginx)"
description = "Rust 网络编程实战：用 Tokio 手写一个迷你 TCP 反向代理 (minginx)"
date = 2025-07-05T12:55:06Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust", "Tokio", "TCP", "反向代理"]
+++

<!-- more -->

# **Rust 网络编程实战：用 Tokio 手写一个迷你 TCP 反向代理 (minginx)**

Nginx 作为强大的反向代理服务器，是我们日常开发中的得力助手。但你是否想过，它的核心原理——TCP流量转发，究竟是如何实现的？我们能否用 Rust 和 Tokio 亲手构建一个迷你版的 Nginx 呢？

本文旨在通过一个名为 `minginx` 的实战项目，带领读者从零开始，用不到100行代码实现一个功能完备的异步TCP反向代理。我们将深入探讨如何利用 `tokio::spawn` 处理并发连接，以及如何通过 `tokio::io::copy` 高效地在客户端和上游服务器之间建立双向数据流。为了验证我们的代理，我们还会搭建一个基于 `axum` 的后端Web服务。

读完本文，你不仅能理解TCP反向代理的本质，还能掌握一套使用Rust构建高性能网络服务的实用技能。

## 一、核心组件：TCP代理 (minginx.rs)

### 🗼 TCP代理 minginx.rs 文件

```rust
use std::sync::Arc;

use anyhow::Result;
use serde::{Deserialize, Serialize};
use tokio::{
    io,
    net::{TcpListener, TcpStream},
};
use tracing::{info, level_filters::LevelFilter, warn};
use tracing_subscriber::{Layer as _, fmt::Layer, layer::SubscriberExt, util::SubscriberInitExt};

#[derive(Debug, Deserialize, Serialize)]
struct Config {
    listen_addr: String,
    upstream_addr: String,
}

#[tokio::main]
async fn main() -> Result<()> {
    // proxy client traffic to upstream
    let layer = Layer::new().pretty().with_filter(LevelFilter::INFO);
    tracing_subscriber::registry().with(layer).init();

    let config = resolve_config();
    let config = Arc::new(config);
    info!("Upstream: {}", config.upstream_addr);
    info!("Listen: {}", config.listen_addr);

    let listener = TcpListener::bind(&config.listen_addr).await?;
    loop {
        let (client, addr) = listener.accept().await?;
        // let cloned_config = config.clone(); 阅读代码 方便使用 Arc::clone
        let cloned_config = Arc::clone(&config);
        info!("Accept connection from {}", addr);
        tokio::spawn(async move {
            let upstream = TcpStream::connect(&cloned_config.upstream_addr).await?;
            proxy(client, upstream).await?;
            Ok::<(), anyhow::Error>(())
        });
    }
}

async fn proxy(mut client: TcpStream, mut upstream: TcpStream) -> Result<()> {
    let (mut client_rd, mut client_wr) = client.split();
    let (mut upstream_rd, mut upstream_wr) = upstream.split();

    let client_to_upstream = io::copy(&mut client_rd, &mut upstream_wr);

    let upstream_to_client = io::copy(&mut upstream_rd, &mut client_wr);

    if let Err(e) = tokio::try_join!(client_to_upstream, upstream_to_client) {
        warn!("Error in proxy: {}", e)
    }
    Ok(())
}

fn resolve_config() -> Config {
    Config {
        listen_addr: "127.0.0.1:8081".to_string(),
        upstream_addr: "127.0.0.1:8080".to_string(),
    }
}

```

这段 Rust 代码实现了一个简单的 TCP **代理服务器** (TCP proxy)。

程序首先在本地 `127.0.0.1:8081` 地址上监听传入的 TCP 连接，当接收到一个新的客户端连接后，它会立即为该连接创建一个新的异步任务（`tokio::spawn`）。在这个新任务中，程序会连接到预设的上游服务器地址（`127.0.0.1:8081`），然后调用 `proxy` 函数。`proxy` 函数的核心功能是使用 `io::copy` 在客户端和上游服务器之间建立一个**双向数据流**，将从客户端收到的数据**原封不动地转发**给上游服务器，同时也将上游服务器返回的数据转发给客户端，从而完成代理的功能。

### 运行

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 2m 4.9s 
➜ cargo run --example minginx
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.17s
     Running `target/debug/examples/minginx`
  2025-07-03T15:02:50.964166Z  INFO minginx: Upstream: 0.0.0.0:8080
    at examples/minginx.rs:26

  2025-07-03T15:02:50.964204Z  INFO minginx: Listen: 0.0.0.0:8081
    at examples/minginx.rs:27


```

## 二、后端验证：Web API 服务 (axum_serde.rs)

### ⚙️ 后端服务 axum_serde.rs 文件

```rust
use std::sync::{Arc, Mutex};

use anyhow::Result;
use axum::{
    Json, Router,
    extract::State,
    routing::{get, patch},
};
use serde::{Deserialize, Serialize};
use tokio::net::TcpListener;
use tracing::{info, instrument, level_filters::LevelFilter};
use tracing_subscriber::{
    Layer as _,
    fmt::{self, format::FmtSpan},
    layer::SubscriberExt,
    util::SubscriberInitExt,
};

#[derive(Debug, Clone, PartialEq, Serialize)]
struct User {
    name: String,
    age: u8,
    skills: Vec<String>,
}

#[derive(Debug, Clone, Deserialize)]
struct UserUpdate {
    age: Option<u8>,
    skills: Option<Vec<String>>,
}

#[tokio::main]
async fn main() -> Result<()> {
    let console = fmt::Layer::new()
        .with_span_events(FmtSpan::CLOSE)
        .pretty()
        .with_filter(LevelFilter::DEBUG);

    tracing_subscriber::registry().with(console).init();

    let user = User {
        name: "Alice".to_string(),
        age: 30,
        skills: vec!["Rust".to_string(), "Python".to_string()],
    };

    let user = Arc::new(Mutex::new(user));

    let addr = "0.0.0.0:8080";
    let listener = TcpListener::bind(addr).await?;
    info!("Listening on {}", addr);

    let app = Router::new()
        .route("/", get(user_handler))
        .route("/", patch(update_handler))
        .with_state(user);

    axum::serve(listener, app.into_make_service()).await?;

    Ok(())
}

#[instrument]
async fn user_handler(State(user): State<Arc<Mutex<User>>>) -> Json<User> {
    (*user.lock().unwrap()).clone().into()
}

#[instrument]
async fn update_handler(
    State(user): State<Arc<Mutex<User>>>,
    Json(user_update): Json<UserUpdate>,
) -> Json<User> {
    let mut user = user.lock().unwrap();
    if let Some(age) = user_update.age {
        user.age = age;
    }

    if let Some(skills) = user_update.skills {
        user.skills = skills;
    }
    (*user).clone().into()
}

```

这段 Rust 代码使用 **axum** 框架创建了一个简单的 Web API，用于查看和更新单个用户的个人资料。为了在多个并发请求之间安全地共享用户数据，它将用户状态包裹在 `Arc<Mutex<User>>` 中：`Arc` 允许多个任务共享数据所有权，而 `Mutex` 则确保同一时间只有一个任务能修改数据，从而防止数据竞争。该服务器运行在 **tokio** 异步运行时上，并开放了两个根路径 (`/`) 的 HTTP 接口：一个 `GET` 请求用于获取当前用户信息，另一个 `PATCH` 请求用于通过 JSON 数据更新用户的年龄或技能。此外，代码还配置了 **tracing** 库，以便为服务器事件和请求提供结构化的日志输出。

## 三、联调测试：验证代理功能

### 🚀 联调测试

Request：

```http
### update_handler
PATCH http://localhost:8081/ HTTP/1.1
Content-Type: application/json

{
    "skills": ["Go", "Python", "Java"]
}

```

Response：

```bash
HTTP/1.1 200 OK
content-type: application/json
content-length: 57
connection: close
date: Thu, 03 Jul 2025 15:04:15 GMT

{
  "name": "Alice",
  "age": 30,
  "skills": [
    "Go",
    "Python",
    "Java"
  ]
}

```

### minginx 运行详情

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 2m 4.9s 
➜ cargo run --example minginx
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.17s
     Running `target/debug/examples/minginx`
  2025-07-03T15:02:50.964166Z  INFO minginx: Upstream: 0.0.0.0:8080
    at examples/minginx.rs:26

  2025-07-03T15:02:50.964204Z  INFO minginx: Listen: 0.0.0.0:8081
    at examples/minginx.rs:27

  2025-07-03T15:03:25.513586Z  INFO minginx: Accept connection from 127.0.0.1:60605
    at examples/minginx.rs:34

  2025-07-03T15:04:15.831749Z  INFO minginx: Accept connection from 127.0.0.1:60821
    at examples/minginx.rs:34


```

### axum_serde 运行详情

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 3m 7.4s 
➜ cargo run --example axum_serde
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.26s
     Running `target/debug/examples/axum_serde`
  2025-07-03T15:02:43.690337Z  INFO axum_serde: Listening on 0.0.0.0:8080
    at examples/axum_serde.rs:51

  2025-07-03T15:03:25.516468Z  INFO axum_serde: close, time.busy: 31.6µs, time.idle: 24.0µs
    at examples/axum_serde.rs:68
    in axum_serde::update_handler with user: Mutex { data: User { name: "Alice", age: 30, skills: ["Rust", "Python"] }, poisoned: false, .. }, user_update: UserUpdate { age: None, skills: Some(["Go"]) }

  2025-07-03T15:04:15.836860Z  INFO axum_serde: close, time.busy: 8.62µs, time.idle: 12.9µs
    at examples/axum_serde.rs:68
    in axum_serde::update_handler with user: Mutex { data: User { name: "Alice", age: 30, skills: ["Go"] }, poisoned: false, .. }, user_update: UserUpdate { age: None, skills: Some(["Go", "Python", "Java"]) }


```

## 总结

通过 `minginx` 这个项目，我们从零开始，用短短几十行代码就实现了一个功能完备的 TCP 反向代理的核心。这不仅展示了 Rust 语言的强大表达力和安全性，更凸显了 Tokio 生态在构建高性能网络服务方面的巨大优势。我们看到，`tokio::spawn` 提供了简单的并发模型，而 `io::copy` 则优雅地处理了底层复杂的数据拷贝和流控制。

本文的 `minginx` 虽然简单，但它抓住了反向代理的精髓。在此基础上，可以进一步扩展，例如实现负载均衡、SSL/TLS卸载、健康检查等高级功能，最终构建出企业级的网络中间件。

希望这个小项目能为你打开一扇通往 Rust 网络编程世界的大门，激发你探索更多可能性的热情。

## 参考

- <https://docs.rs/tokio/latest/tokio/>
- <https://www.rust-lang.org/zh-CN>
