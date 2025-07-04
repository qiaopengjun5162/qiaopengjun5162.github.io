+++
title = "告别竞态条件：基于 Axum 和 Serde 的 Rust 并发状态管理最佳实践"
description = "告别竞态条件：基于 Axum 和 Serde 的 Rust 并发状态管理最佳实践"
date = 2025-07-03T14:12:22Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust", "Axum"]
+++

<!-- more -->

# 告别竞态条件：基于 Axum 和 Serde 的 Rust 并发状态管理最佳实践

在现代 Web 开发中，如何在高并发场景下安全、高效地管理共享状态，始终是一个核心挑战。无论是用户会话、应用缓存还是全局配置，一旦涉及到多请求（多线程）的“读”和“写”，数据不一致、**竞态条件 (Race Condition)** 等“并发幽灵”便会悄然而至。

幸运的是，Rust 语言凭借其独特的所有权系统和强大的并发原语，为我们提供了“编译时即保证安全”的利器。

本文将通过一个真实、可运行的例子，带你深入探索如何使用高性能异步框架 **Axum**，结合并发编程的基石 **`Arc<Mutex<T>>`**，从零开始构建一个支持获取和更新用户信息的 RESTful API，亲手揭开 Rust 并发安全的神秘面纱。这篇实战指南，对每一位希望将 Rust 应用于 Web 后端的开发者都极具参考价值。

## 实操

万事俱备，代码为证：用 `Arc<Mutex>` 守护我们的共享状态。

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

### 代码详解

这段 Rust 代码创建了一个简单的异步 Web 服务器，它使用 `axum` 框架来提供一个基本的 API，用于获取和更新一个用户的信息。

核心功能是**安全地在多个并发请求之间共享和修改数据**。

现在，我们来逐一拆解这段代码，看看它是如何工作的。

#### 1. 整体结构和依赖项

这段代码使用了几个关键的库（crates）：

- **`std::sync::{Arc, Mutex}`**: 这是 Rust 标准库中用于并发编程的核心工具。
  - `Arc` (Atomically Referenced Counter): 允许多个所有者安全地共享同一份数据。它会追踪有多少个引用指向数据，当最后一个引用消失时，数据才会被清理。这对于在多线程/多任务（如 web 请求）之间共享状态至关重要。
  - `Mutex` (Mutual Exclusion): 确保在任何时候只有一个线程可以访问被它保护的数据。要想访问数据，必须先“锁定”（lock）它，用完后“解锁”（unlock）。这可以防止多个请求同时修改数据而导致的数据损坏（即“竞态条件”）。
- **`axum`**: 一个现代、符合人体工程学的 Rust Web 框架，用于构建 Web 服务。
- **`tokio`**: Rust 的异步运行时，提供了执行异步代码、处理网络事件等功能。`#[tokio::main]` 是一个宏，它会将 `main` 函数转换为一个异步的入口点。
- **`serde`**: 用于在 Rust 数据结构和 JSON 等格式之间进行序列化和反序列化。
- **`tracing`**: 用于记录日志和应用性能追踪。
- **`anyhow`**: 提供了更方便的错误处理机制。

------

#### 2.  数据结构

代码定义了两个主要的数据结构：

```rust
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
```

- **`User`**: 代表用户数据。
  - `#[derive(..., Serialize)]`: 这个属性来自 `serde`，它让 `User` 结构体可以被自动转换成 JSON 格式，以便在 API 响应中发送给客户端。
- **`UserUpdate`**: 代表用于更新用户的信息。
  - 字段被 `Option<>` 包裹：这意味着客户端在发送 `PATCH` 请求时，可以只提供 `age`，或者只提供 `skills`，或者两者都提供。服务器会根据 `Some(...)` 或 `None` 来判断哪些字段需要更新。
  - `#[derive(..., Deserialize)]`: 这个属性让 `axum` 可以自动将请求体中的 JSON 数据解析（反序列化）成一个 `UserUpdate` 实例。

------

### `3. main` 函数：服务器的启动和配置

`main` 函数是整个程序的入口，负责设置和启动服务器。

```rust
#[tokio::main]
async fn main() -> Result<()> {
    // 1. 设置日志记录
    let console = fmt::Layer::new()...;
    tracing_subscriber::registry().with(console).init();

    // 2. 创建初始数据
    let user = User { ... };

    // 3. 将数据包装在 Arc<Mutex<>> 中以实现共享
    let user = Arc::new(Mutex::new(user));

    // 4. 设置服务器地址和路由
    let addr = "0.0.0.0:8080";
    let listener = TcpListener::bind(addr).await?;
    info!("Listening on {}", addr);

    let app = Router::new()
        .route("/", get(user_handler))
        .route("/", patch(update_handler))
        .with_state(user); // 将共享状态附加到路由

    // 5. 启动服务器
    axum::serve(listener, app.into_make_service()).await?;

    Ok(())
}
```

1. **日志设置**: 初始化 `tracing` 库，以便在控制台打印出格式优美的、带有调试信息的日志。
2. **创建数据**: 创建一个名为 "Alice" 的初始 `User` 实例。
3. **创建共享状态**: 这是最关键的一步。`user` 被 `Mutex` 包裹，然后再被 `Arc` 包裹。
   - `Mutex::new(user)`: 创建一个互斥锁来保护用户数据。
   - `Arc::new(...)`: 创建一个原子引用计数器，这样 `Mutex` 连同它里面的数据就可以被安全地在多个处理器之间共享。最终我们得到的 `Arc<Mutex<User>>` 就是我们的“共享状态”。
4. **路由配置**:
   - 创建一个 `axum` 的 `Router`。
   - `.route("/", get(user_handler))`: 定义当收到对根路径 `/` 的 `GET` 请求时，调用 `user_handler` 函数。
   - `.route("/", patch(update_handler))`: 定义当收到对根路径 `/` 的 `PATCH` 请求时，调用 `update_handler` 函数。
   - `.with_state(user)`: 将我们刚刚创建的共享状态 `Arc<Mutex<User>>` 附加到路由器上。`axum` 会确保所有处理器都能访问到这个状态。
5. **启动服务**: 监听 `0.0.0.0:8080` 地址，并使用我们配置好的 `app` (路由器) 来处理所有传入的请求。

------

#### 4. Handler 函数：处理 API 请求

Handler 是处理具体 HTTP 请求的函数。

##### 获取用户 (`user_handler`)

```rust
#[instrument]
async fn user_handler(State(user): State<Arc<Mutex<User>>>) -> Json<User> {
    (*user.lock().unwrap()).clone().into()
}
```

- **`State(user): State<Arc<Mutex<User>>>`**: 这是一个 `axum` 的“提取器”（Extractor）。它会自动从路由器的状态中提取出我们之前设置的 `Arc<Mutex<User>>`。
- **`user.lock().unwrap()`**:
  - `user.lock()`: 尝试获取 `Mutex` 的锁。在获得锁之前，当前任务可能会被挂起。
  - `.unwrap()`: 如果成功获取锁，就返回一个指向内部数据的“锁守卫”（MutexGuard）。如果锁已经被“污染”（poisoned，即持有锁的另一个线程崩溃了），则会 panic。在实际项目中，这里通常会做更稳健的错误处理。
- **`(*...).clone()`**: 我们不能直接移出被 `Mutex` 保护的数据。所以，我们通过 `clone()` 创建一个 `User` 数据的副本。当这一行代码结束时，“锁守卫”会被自动丢弃，从而**释放锁**，让其他请求可以访问数据。
- **`.into()`**: 将克隆出来的 `User` 对象转换成 `Json<User>` 类型，`axum` 会自动将其序列化为 JSON 字符串并作为 HTTP 响应体发送。

##### 更新用户 (`update_handler`)

```rust
#[instrument]
async fn update_handler(
    State(user): State<Arc<Mutex<User>>>,
    Json(user_update): Json<UserUpdate>,
) -> Json<User> {
    let mut user = user.lock().unwrap(); // 获取一个可变的锁
    if let Some(age) = user_update.age {
        user.age = age;
    }

    if let Some(skills) = user_update.skills {
        user.skills = skills;
    }
    (*user).clone().into() // 返回更新后的用户数据
}
```

- **`Json(user_update): Json<UserUpdate>`**: 这是另一个提取器，它会自动将 HTTP 请求体中的 JSON 数据反序列化成一个 `UserUpdate` 结构体实例。
- **`let mut user = user.lock().unwrap()`**: 获取一个**可变**的锁守卫，这样我们就可以修改内部的 `User` 数据。
- **`if let Some(...)`**: 检查 `user_update` 中的字段是否包含值（`Some`）。如果包含，就用新值更新 `user` 对象中对应的字段。
- **`(*user).clone().into()`**: 更新完成后，同样克隆一份更新后的 `User` 数据，并将其作为 JSON 响应返回。锁在函数结束时自动释放。

## 运行与测试

### 运行日志

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ cargo run --example axum_serde
   Compiling rust-ecosystem-learning v0.1.0 (/Users/qiaopengjun/Code/Rust/rust-ecosystem-learning)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 2.44s
     Running `target/debug/examples/axum_serde`
  2025-07-03T13:09:01.607307Z  INFO axum_serde: Listening on 0.0.0.0:8080
    at examples/axum_serde.rs:51

  2025-07-03T13:11:38.715665Z  INFO axum_serde: close, time.busy: 58.0µs, time.idle: 14.1µs
    at examples/axum_serde.rs:63
    in axum_serde::user_handler with user: Mutex { data: User { name: "Alice", age: 30, skills: ["Rust", "Python"] }, poisoned: false, .. }

  2025-07-03T13:13:23.226969Z  INFO axum_serde: close, time.busy: 15.6µs, time.idle: 13.8µs
    at examples/axum_serde.rs:68
    in axum_serde::update_handler with user: Mutex { data: User { name: "Alice", age: 30, skills: ["Rust", "Python"] }, poisoned: false, .. }, user_update: UserUpdate { age: None, skills: Some(["Go"]) }


```

### API 调用示例

#### 调用 `user_handler` 函数

Request：

```bash
### user_handler
GET http://localhost:8080/ HTTP/1.1
```

Response：

```bash
HTTP/1.1 200 OK
content-type: application/json
content-length: 52
connection: close
date: Thu, 03 Jul 2025 13:11:38 GMT

{
  "name": "Alice",
  "age": 30,
  "skills": [
    "Rust",
    "Python"
  ]
}

```

#### 调用 `update_handler` 函数

Request：

```bash
### update_handler
PATCH http://localhost:8080/ HTTP/1.1
Content-Type: application/json

{
    "skills": ["Go"]
}
```

Response：

```bash
HTTP/1.1 200 OK
content-type: application/json
content-length: 41
connection: close
date: Thu, 03 Jul 2025 13:13:23 GMT

{
  "name": "Alice",
  "age": 30,
  "skills": [
    "Go"
  ]
}

```

## 总结 🚀

总结一下，通过本文的实践，我们不仅成功地用 Rust 和 Axum 构建了一个功能完备的异步 Web API，更重要的是，我们掌握了在 Rust 中处理共享可变状态的核心模式——`Arc<Mutex<T>>`。

这个看似简单的例子，实则蕴含了 Rust 并发设计的精髓：将并发问题在编译阶段就扼杀在摇篮里，而不是留到运行时去“祈祷”不出错。从 `State` 提取器的优雅，到 `lock()` 后自动释放的锁守卫，我们能深刻体会到 Rust 在打造健壮、可靠系统方面的强大能力。

以此为基石，您可以充满信心地去构建更复杂的生产级应用——无论是添加数据库连接池、集成更复杂的业务逻辑，还是扩展更多的 API 端点，这份关于并发安全的坚实基础，都将让您的 Rust 之旅走得更远、更稳。

## 参考

- <https://axum.eu.org/>
- <https://docs.rs/axum/latest/axum/>
- <https://docs.rs/serde/latest/serde/>
- <https://github.com/rust-lang>
- <https://github.com/jeremychone-channel/rust-axum-course/tree/main>
- <https://www.rust-lang.org/>
- <https://github.com/google/comprehensive-rust>
