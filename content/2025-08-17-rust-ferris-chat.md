+++
title = "硬核实战：从零到一，用 Rust 和 Axum 构建高性能聊天服务后端"
description = "硬核实战：从零到一，用 Rust 和 Axum 构建高性能聊天服务后端"
date = 2025-08-17T12:14:34Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# **硬核实战：从零到一，用 Rust 和 Axum 构建高性能聊天服务后端**

你是否曾好奇 Slack 或微信这类聊天应用背后强大的技术支撑？想不想亲手打造一个属于自己的高性能网络服务？🚀

在追求极致性能和安全性的今天，Rust 已成为后端开发领域的闪亮新星。本文将作为你的向导，带你从零开始，使用 Rust 语言及其强大的 Axum 框架，一步步构建一个功能完备的聊天服务后端。我们将深入探讨从项目设计、技术选型到代码实现的全过程，让你在实践中感受 Rust 的魅力！

本文是一篇使用 Rust 构建高性能网络服务的实战教程。我们将从零开始，借助 Axum 框架和 Tokio 异步运行时，一步步搭建一个功能丰富的聊天服务后端。内容涵盖项目设计、协议选择、代码实现与测试，助你掌握 Rust 在网络编程中的核心应用。

## 需求分析

构建一个类似 slack/wechat 的聊天服务

- 用户认证
- 点对点聊天
- 多人聊天
- 群组（channel）聊天
- 文件共享

### 界面思考

- Sidebar
- Chat Group List
- Chat Group
- Chat
- Message List
- Message
- Send
- Chat web app 启动时 ，所有用户信息加载进来
- Constraint （限制）
- Trade-off （权衡）
- Convention over Configuration（约定）
- 网络协议
  - HTTP/1.1 HTTP/2
  - 客户端和服务器的通知机制
    - WebSocket
    - SSE (Service-Side Event)
- API
- 数据结构
- trait
- rfcs

## 实操

### 安装依赖

```bash
➜ cargo add tokio --features rt --features rt-multi-thread --features macros
➜ cargo add axum --features http2 --features query --features tracing --features multipart
➜ cargo add anyhow
➜ cargo add thiserror
➜ cargo add sqlx --features postgres --features runtime-tokio --features tls-rustls --features runtime-tokio-rustls
➜ cargo add serde --features derive                                                             ➜ cargo add serde_yaml
➜ cargo add tracing-subscriber --features env-filter
```

### 查看项目目录

```bash
ferris-chat on  main is 📦 0.1.0 via 🦀 1.89.0
➜ tree . -L 6 -I "docs|target"
.
├── _typos.toml
├── app.yml
├── Cargo.lock
├── Cargo.toml
├── CHANGELOG.md
├── cliff.toml
├── CONTRIBUTING.md
├── deny.toml
├── LICENSE
├── Makefile
├── README.md
├── sql
│   └── init.sql
├── src
│   ├── config.rs
│   ├── error.rs
│   ├── handlers
│   │   ├── auth.rs
│   │   ├── chat.rs
│   │   ├── messages.rs
│   │   └── mod.rs
│   ├── lib.rs
│   └── main.rs
└── test.rest

4 directories, 21 files

```

### `main.rs` 文件

```rust
use anyhow::Result;
use ferris_chat::{AppConfig, get_router};
use tokio::net::TcpListener;
use tracing::{info, level_filters::LevelFilter};
use tracing_subscriber::{Layer as _, fmt::Layer, layer::SubscriberExt, util::SubscriberInitExt};

#[tokio::main]
async fn main() -> Result<()> {
    let layer = Layer::new().with_filter(LevelFilter::INFO);
    tracing_subscriber::registry().with(layer).init();

    let config = AppConfig::load()?;
    let addr = format!("0.0.0.0:{}", config.server.port);

    let app = get_router(config);
    let listener = TcpListener::bind(&addr).await?;
    info!("Listening on {}", addr);

    axum::serve(listener, app.into_make_service()).await?;

    Ok(())
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}

```

### `lib.rs` 文件

```rust
mod config;
pub mod error;
mod handlers;

use handlers::*;
use std::{ops::Deref, sync::Arc};

use axum::{
    Router,
    routing::{get, patch, post},
};

pub use config::AppConfig;

#[derive(Debug, Clone)]
pub(crate) struct AppState {
    inner: Arc<AppStateInner>,
}

#[allow(unused)]
#[derive(Debug)]
pub(crate) struct AppStateInner {
    pub(crate) config: AppConfig,
}

pub fn get_router(config: AppConfig) -> Router {
    let state = AppState::new(config);

    let api = Router::new()
        .route("/signin", post(signin_handler))
        .route("/signup", post(signup_handler))
        .route("/chat", get(list_chat_handler).post(create_chat_handler))
        .route(
            "/chat/{id}",
            patch(update_chat_handler)
                .delete(delete_chat_handler)
                .post(send_message_handler),
        )
        .route("/chat/{id}/messages", get(list_message_handler));

    Router::new().route("/", get(index_handler)).nest("/api", api).with_state(state)
}

// 当我调用 state.config => state.inner.config
impl Deref for AppState {
    type Target = AppStateInner;

    fn deref(&self) -> &Self::Target {
        &self.inner
    }
}

impl AppState {
    pub fn new(config: AppConfig) -> Self {
        Self {
            inner: Arc::new(AppStateInner { config }),
        }
    }
}

```

### `config.rs` 文件

```rust
use std::{env, fs::File};

use anyhow::{Result, bail};
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
pub struct AppConfig {
    pub server: ServerConfig,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct ServerConfig {
    pub port: u16,
}

impl AppConfig {
    pub fn load() -> Result<Self> {
        // read from ./app.yml, or /etc/config/app.yml, or from env CHAT_CONFIG
        let ret = match (
            File::open("./app.yml"),
            File::open("/etc/config/app.yml"),
            env::var("CHAT_CONFIG"),
        ) {
            (Ok(reader), _, _) => serde_yaml::from_reader(reader),
            (_, Ok(reader), _) => serde_yaml::from_reader(reader),
            (_, _, Ok(path)) => serde_yaml::from_reader(File::open(path)?),
            _ => bail!("failed to load config file"),
        };
        Ok(ret?)
    }
}

```

### `error.rs` 文件

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum MyError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Parse error: {0}")]
    Parse(#[from] std::num::ParseIntError),

    #[error("Error: {0:?}")]
    BigError(Box<BigError>),

    #[error("An error occurred: {0}")]
    Custom(String),
}

#[derive(Debug)]
pub struct BigError {
    pub a: String,
    pub b: Vec<String>,
    pub c: [u8; 64],
    pub d: u64,
}

```

### `src/handlers/mod.rs` 文件

```rust
mod auth;
mod chat;
mod messages;

use axum::response::IntoResponse;

pub(crate) use auth::*;
pub(crate) use chat::*;
pub(crate) use messages::*;

pub(crate) async fn index_handler() -> impl IntoResponse {
    "index"
}

```

### `src/handlers/auth.rs` 文件

```rust
use axum::response::IntoResponse;

pub(crate) async fn signin_handler() -> impl IntoResponse {
    "signin"
}

pub(crate) async fn signup_handler() -> impl IntoResponse {
    "signup"
}

```

### `src/handlers/chat.rs` 文件

```rust
use axum::response::IntoResponse;

pub(crate) async fn list_chat_handler() -> impl IntoResponse {
    "list_chat"
}

pub(crate) async fn create_chat_handler() -> impl IntoResponse {
    "create_chat"
}

pub(crate) async fn update_chat_handler() -> impl IntoResponse {
    "update_chat"
}

pub(crate) async fn delete_chat_handler() -> impl IntoResponse {
    "delete_chat"
}

```

### `src/handlers/messages.rs` 文件

```rust
use axum::response::IntoResponse;

pub(crate) async fn list_message_handler() -> impl IntoResponse {
    "list_message"
}

pub(crate) async fn send_message_handler() -> impl IntoResponse {
    "send_message"
}

```

### 运行

```bash
ferris-chat on  main is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.38s
     Running `target/debug/ferris-chat`
2025-08-15T08:35:03.767166Z  INFO ferris_chat: Listening on 0.0.0.0:6688

```

## 测试

### `test.rest` 文件

```rust
### chat api

GET http://localhost:6688/api/chat HTTP/1.1
Content-Type: application/json

### chat api

POST http://localhost:6688/api/chat HTTP/1.1
Content-Type: application/json

{
    "name": "John",
    "message": "Hello, World!"
}

```

### GET list_chat 请求

```bash
### chat api

GET http://localhost:6688/api/chat HTTP/1.1
Content-Type: application/json
```

#### GET list_chat 响应

```bash
HTTP/1.1 200 OK
content-type: text/plain; charset=utf-8
content-length: 9
connection: close
date: Fri, 15 Aug 2025 08:36:08 GMT

list_chat
```

### POST create_chat 请求

```bash
POST http://localhost:6688/api/chat HTTP/1.1
Content-Type: application/json

{
    "name": "John",
    "message": "Hello, World!"
}

```

### POST create_chat 响应

```bash
HTTP/1.1 200 OK
content-type: text/plain; charset=utf-8
content-length: 11
connection: close
date: Fri, 15 Aug 2025 08:37:34 GMT

create_chat

```

## 总结

通过本篇教程，我们成功地使用 Rust 和 Axum 搭建了一个聊天服务的后端基础框架。从项目初始化、依赖管理，到模块化的代码结构（配置 `config`、错误处理 `error`、路由处理 `handlers`），再到最终的 API 测试，我们完整地走了一遍现代 Rust Web 后端的开发流程。

这个项目清晰地展示了 **Rust 在构建高性能、类型安全和高并发网络应用方面的巨大优势**。Axum 框架的简洁和强大，也让路由和状态管理变得轻而易举。

虽然目前我们只实现了 API 的基本骨架，但这已经是一个坚实的起点。下一步，你可以尝试**集成数据库（如 `sqlx` 所示）**、**完善用户认证逻辑**，并**引入 WebSocket 来实现真正的实时双向通信**。希望这篇实战指南能为你打开 Rust 后端开发的大门！🚪

## 参考

- <https://datatracker.ietf.org/doc/rfc2616/>
- <https://www.rfc-editor.org/rfc/rfc2616.html#section-10.2.4>
- <https://developer.mozilla.org/zh-CN/docs/Web/HTTP>
- <https://developer.mozilla.org/en-US/docs/Web/HTTP>
- <https://webmachine.github.io/images/http-headers-status-v3.png>
- <https://axum.eu.org/>
- <https://github.com/tokio-rs/axum>
- <https://docs.rs/axum/latest/axum/>
- <https://docs.rs/matchit/latest/matchit/>
