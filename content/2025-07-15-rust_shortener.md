+++
title = "Rust 生产级后端实战：用 Axum + `sqlx` 打造高性能短链接服务"
description = "一篇 Rust 生产级后端实战指南。本文以打造高性能短链接服务为例，用 Axum 和 sqlx 呈现项目从零到一的开发全过程，助你掌握处理数据冲突、规避框架陷阱等生产级开发经验，构建一个健壮、高效的 Rust 应用。"
date = 2025-07-15T08:00:42Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust", "Axum", "slx"]
+++

<!-- more -->

# **Rust 生产级后端实战：用 Axum + `sqlx` 打造高性能短链接服务**

当我们在谈论后端开发时，“高性能”和“高可靠”是永恒的追求。正因如此，以安全和并发著称的 Rust 成为了越来越多开发者构建下一代服务的首选。但是，如何将 Rust 的语言优势，真正转化为一个健壮、高效、可维护的**生产级**应用呢？

理论千遍，不如上手一战。

本文将摒弃空谈，通过一个最经典的后端项目——**URL 短链接服务**——来向您完整展示一个 **Rust 生产级后端项目**的诞生全过程。我们将使用当前最受欢迎的技术栈：`Axum` 作为 Web 框架，`sqlx` 作为数据库交互工具，从零开始，一步步“打造”我们的高性能服务。

跟随本文，您不仅能收获一个完整的项目，更将深入掌握：

- **生产级的数据库交互**：如何用 `sqlx` 优雅地处理数据冲突，实现原子性操作。
- **生产级的代码模式**：如何正确管理应用状态、处理错误，并理解框架（Axum）的那些“潜规则”。
- **生产级的开发思维**：从遇到问题、分析问题到最终解决问题，体验一个工程师在真实开发中的完整心路历程。

这篇文章是为所有渴望用 Rust 构建真实、可靠应用的开发者准备的。让我们即刻启程，探索 Rust 在生产环境中的真正实力！

## 技术选型：ORM 还是 `sqlx`？

### Rust 数据库处理

- ORM
  - Diesel
  - Sea-ORM
- SQL toolkit：sqlx

### 为什么不推荐使用 ORM

- 性能
- 不太需要的额外抽象
- SQL injection
- 过于中庸，限制太多
- 语言绑定，平台绑定

因此，在本次实战中，我们选择 `sqlx` 作为数据库工具，它能让我们在享受类型安全的同时，发挥出原生 SQL 的最大威力。

使用 sqlx 不使用 orm ，但是得到了orm的好处。

建议阅读 sqlx 文档和 GitHub 下的 example 学习。

构建高效且复杂的 SQL 是每个工程师的基本功
构建一个 URL shortener

- Tokio
- axum
- sqlx
- nanoid

## 实操

### 安装依赖

```bash
➜ cargo add sqlx --features postgres --features runtime-tokio --features tls-rustls
```

### 代码实现 `shortener.rs`

```rust
use anyhow::Result;
use axum::{
    Json, Router,
    extract::{Path, State},
    http::HeaderMap,
    response::IntoResponse,
    routing::{get, post},
};
use nanoid::nanoid;
use reqwest::{StatusCode, header::LOCATION};
use serde::{Deserialize, Serialize};
use sqlx::PgPool;
use tokio::net::TcpListener;
use tracing::{info, level_filters::LevelFilter, warn};
use tracing_subscriber::{Layer as _, fmt::Layer, layer::SubscriberExt, util::SubscriberInitExt};

#[derive(Debug, Deserialize)]
struct ShortenReq {
    url: String,
}

#[derive(Debug, Serialize)]
struct ShortenRes {
    url: String,
}

#[derive(Debug, Clone)]
struct AppState {
    db: PgPool,
}

const LISTEN_ADDR: &str = "localhost:9876";

#[tokio::main]
async fn main() -> Result<()> {
    dotenvy::dotenv()?;

    let layer = Layer::new().with_filter(LevelFilter::INFO);
    tracing_subscriber::registry().with(layer).init();

    let url = std::env::var("DATABASE_URL")?;
    // 一般情况下，AppState 都需要使用 Arc 来包裹，因为每一次 state 被使用的时候，都会被 clone 出一个新的 AppState
    // 这里不使用 Arc 是因为 PgPool 内部已经使用了 Arc，所以 AppState 内部不需要再包裹一层 Arc， #[derive(Debug, Clone)] 也会自动生成
    // 如果内部没有使用 Arc，那么一定不要使用 Clone
    // let state = Arc::new(AppState::try_new(&url).await?);
    let state = AppState::try_new(&url).await?;
    info!("Connected to database: {url}");

    let listener = TcpListener::bind(LISTEN_ADDR).await?;
    info!("listening on {}", LISTEN_ADDR);

    let app = Router::new()
        .route("/", post(shorten))
        .route("/{id}", get(redirect))
        .with_state(state);

    axum::serve(listener, app.into_make_service()).await?;

    Ok(())
}

async fn shorten(
    State(state): State<AppState>, // 注意：这里如果 State(state) 在 Json 之后会导致编译错误 body extractor 只能有一个并且要放在最后
    Json(data): Json<ShortenReq>,
) -> Result<impl IntoResponse, StatusCode> {
    let id = state.shorten(&data.url).await.map_err(|e| {
        warn!("Failed to shorten URL: {e}");
        StatusCode::UNPROCESSABLE_ENTITY
    })?;

    let body = Json(ShortenRes {
        url: format!("http://{}/{}", LISTEN_ADDR, id),
    });
    Ok((StatusCode::CREATED, body))
}

async fn redirect(
    Path(id): Path<String>,
    State(state): State<AppState>,
) -> Result<impl IntoResponse, StatusCode> {
    let url = state
        .get_url(&id)
        .await
        .map_err(|_| StatusCode::NOT_FOUND)?;

    let mut headers = HeaderMap::new();
    headers.insert(LOCATION, url.parse().unwrap());

    Ok((StatusCode::FOUND, headers))
}

impl AppState {
    async fn try_new(url: &str) -> Result<Self> {
        let pool = PgPool::connect(url).await?;
        // create tables if not exists
        sqlx::query(
            r#"CREATE TABLE IF NOT EXISTS urls (
                id CHAR(6) PRIMARY KEY,
                url TEXT NOT NULL UNIQUE,
                created_at TIMESTAMP NOT NULL DEFAULT NOW()
            )"#,
        )
        .execute(&pool)
        .await?;

        Ok(Self { db: pool })
    }

    async fn shorten(&self, url: &str) -> Result<String> {
        let id = nanoid!(6);
        sqlx::query("INSERT INTO urls (id, url) VALUES ($1, $2)")
            .bind(&id)
            .bind(url)
            .execute(&self.db)
            .await?;

        Ok(id)
    }

    async fn get_url(&self, id: &str) -> Result<String> {
        let record: (String,) = sqlx::query_as("SELECT url FROM urls WHERE id = $1")
            .bind(id)
            .fetch_one(&self.db)
            .await?;

        Ok(record.0)
    }
}

```

这段代码是一个使用 Rust 语言和 Axum Web 框架构建的高性能URL短链接服务。它的核心功能有两个：

1) 通过 `POST` 请求接收一个原始的长 URL，为其生成一个唯一的6位短 ID，存入 PostgreSQL 数据库，并返回完整的短链接地址。
2) 通过 `GET` 请求访问这个短链接（使用短 ID），服务器会从数据库中查询到对应的原始长 URL，并返回一个 HTTP 302 重定向响应，让浏览器跳转到原始地址。整个服务是异步的，利用 `tokio` 作为运行时，并使用 `sqlx` 库与数据库进行异步交互，`nanoid` 用于生成简短的唯一ID，`tracing` 用于日志记录。

### 特别注意

#### 一、位于 `main` 函数中，关于 `AppState` 是否需要 `Arc` 包装

```rust
// 这里不使用 Arc 是因为 PgPool 内部已经使用了 Arc，所以 AppState 内部不需要再包裹一层 Arc， #[derive(Debug, Clone)] 也会自动生成
// 如果内部没有使用 Arc，那么一定不要使用 Clone
// let state = Arc::new(AppState::try_new(&url).await?);
let state = AppState::try_new(&url).await?;
```

一般情况下，AppState 都需要使用 Arc 来包裹，因为每一次 state 被使用的时候，都会被 clone 出一个新的 AppState。

这里不使用 Arc 是因为 PgPool 内部已经使用了 Arc，所以 AppState 内部不需要再包裹一层 Arc。

这是在 Axum (以及其他 Rust Web 框架) 中关于状态管理的重要设计模式。通常，当多个请求需要并发访问共享数据（如此处的数据库连接池 `PgPool`）时，需要将这个共享状态 `AppState` 包装在 `Arc` (Atomically Reference Counted, 原子引用计数指针) 中。`Arc` 允许多个所有者安全地共享数据而不会产生数据竞争。每次请求处理时克隆 `Arc` 的成本非常低，因为它只增加一个引用计数，而不是复制整个数据。

```rust
/// An alias for [`Pool`][crate::pool::Pool], specialized for Postgres.
pub type PgPool = crate::pool::Pool<Postgres>;

pub struct Pool<DB: Database>(pub(crate) Arc<PoolInner<DB>>);
```

然而，**此处的代码是个特例**。`sqlx` 的 `PgPool` 类型在内部已经实现为 `Arc` 包装的连接池。因此，`PgPool` 本身就是可以被安全且廉价地克隆的。在这种情况下，再用 `Arc<AppState>` 进行包装就显得多余了 (`Arc<Arc<...>>`)。直接在 `AppState` 结构体上派生 `#[derive(Clone)]` 就足够了，其克隆操作实际上就是在高效地克隆内部的 `PgPool`。

开发者在开发时，要了解你所使用的库的内部实现，以避免不必要的封装和复杂性。

#### **二、位于 `shorten` 函数签名中，关于参数顺序的注释。**

```rust
async fn shorten(
    Json(data): Json<ShortenReq>,
    State(state): State<AppState>,
) -> Result<impl IntoResponse, StatusCode> {
```

State(state) 在 Json 之后会导致编译错误。

#### 运行编译报错

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 25m 25.0s 
➜ cargo run --example shortener
   Compiling rust-ecosystem-learning v0.1.0 (/Users/qiaopengjun/Code/Rust/rust-ecosystem-learning)

error[E0277]: the trait bound `fn(Json<...>, ...) -> ... {shorten}: Handler<_, _>` is not satisfied
   --> examples/shortener.rs:49:26
    |
49  |         .route("/", post(shorten))
    |                     ---- ^^^^^^^ the trait `Handler<_, _>` is not implemented for fn item `fn(Json<ShortenReq>, State<AppState>) -> ... {shorten}`
    |                     |
    |                     required by a bound introduced by this call
    |
    = note: Consider using `#[axum::debug_handler]` to improve the error message
    = help: the following other types implement trait `Handler<T, S>`:
              `MethodRouter<S>` implements `Handler<(), S>`
              `axum::handler::Layered<L, H, T, S>` implements `Handler<T, S>`
note: required by a bound in `post`
   --> /Users/qiaopengjun/.cargo/registry/src/index.crates.io-1949cf8c6b5b557f/axum-0.8.4/src/routing/method_routing.rs:445:1
    |
445 | top_level_handler_fn!(post, POST);
    | ^^^^^^^^^^^^^^^^^^^^^^----^^^^^^^
    | |                     |
    | |                     required by a bound in this function
    | required by this bound in `post`
    = note: the full name for the type has been written to '/Users/qiaopengjun/Code/Rust/rust-ecosystem-learning/target/debug/examples/shortener-8b2d0ea2a3cea3c5.long-type-16073425591754131837.txt'
    = note: consider using `--verbose` to print the full type name to the console
    = note: this error originates in the macro `top_level_handler_fn` (in Nightly builds, run with -Z macro-backtrace for more info)

For more information about this error, try `rustc --explain E0277`.
warning: `rust-ecosystem-learning` (example "shortener") generated 6 warnings
error: could not compile `rust-ecosystem-learning` (example "shortener") due to 1 previous error; 6 warnings emitted
```

#### body extractor 只能有一个并且要放在最后

```rust
async fn shorten(
    State(state): State<AppState>, // 注意：这里如果 State(state) 在 Json 之后会导致编译错误 body extractor 只能有一个并且要放在最后
    Json(data): Json<ShortenReq>,
) -> Result<impl IntoResponse, StatusCode> {
```

这是 Axum 框架的一个关键规则：**处理请求体的提取器（Extractor）必须是处理函数参数列表中的最后一个参数。**

在 `shorten` 函数中，`Json<ShortenReq>` 是一个提取器，它会读取并解析 HTTP 请求的主体（body）到一个 `ShortenReq` 结构体中。请求体是一个数据流，一旦被读取消耗后就不能再次读取。Axum 框架为了保证逻辑的正确性和防止意外错误，在编译时就强制规定，任何消耗请求体的提取器（如 `Json`, `Form`, `Bytes`）都必须放在参数列表的末尾。`State(state)` 也是一个提取器，但它不消耗请求体，而是从应用的状态中提取共享数据。如果把 `State(state)` 放在 `Json(data)` 之后，就会违反这个规则，导致编译失败。

这里对于刚接触 Axum 的开发者来说是一个需要注意的点，要避免在参数顺序上犯错。

### 创建 `shortener` 数据库

```sql
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ psql                                           
psql (17.4 (Homebrew))
Type "help" for help.

qiaopengjun=# \l
                                                        List of databases
    Name     |    Owner    | Encoding | Locale Provider | Collate | Ctype | Locale | ICU Rules |        Access privileges        
-------------+-------------+----------+-----------------+---------+-------+--------+-----------+---------------------------------
 blockscout  | blockscout  | UTF8     | libc            | C       | C     |        |           | =Tc/blockscout                 +
             |             |          |                 |         |       |        |           | blockscout=CTc/blockscout
 edu_bazaar  | qiaopengjun | UTF8     | libc            | C       | C     |        |           | =Tc/qiaopengjun                +
             |             |          |                 |         |       |        |           | qiaopengjun=CTc/qiaopengjun    +
             |             |          |                 |         |       |        |           | edu_bazaar_user=CTc/qiaopengjun
 postgres    | qiaopengjun | UTF8     | libc            | C       | C     |        |           | 
 qiaopengjun | qiaopengjun | UTF8     | libc            | C       | C     |        |           | 
 template0   | qiaopengjun | UTF8     | libc            | C       | C     |        |           | =c/qiaopengjun                 +
             |             |          |                 |         |       |        |           | qiaopengjun=CTc/qiaopengjun
 template1   | qiaopengjun | UTF8     | libc            | C       | C     |        |           | =c/qiaopengjun                 +
             |             |          |                 |         |       |        |           | qiaopengjun=CTc/qiaopengjun
 vrf_service | qiaopengjun | UTF8     | libc            | C       | C     |        |           | 
(7 rows)

qiaopengjun=# create database shortener;
CREATE DATABASE
qiaopengjun=# \l
                                                        List of databases
    Name     |    Owner    | Encoding | Locale Provider | Collate | Ctype | Locale | ICU Rules |        Access privileges        
-------------+-------------+----------+-----------------+---------+-------+--------+-----------+---------------------------------
 blockscout  | blockscout  | UTF8     | libc            | C       | C     |        |           | =Tc/blockscout                 +
             |             |          |                 |         |       |        |           | blockscout=CTc/blockscout
 edu_bazaar  | qiaopengjun | UTF8     | libc            | C       | C     |        |           | =Tc/qiaopengjun                +
             |             |          |                 |         |       |        |           | qiaopengjun=CTc/qiaopengjun    +
             |             |          |                 |         |       |        |           | edu_bazaar_user=CTc/qiaopengjun
 postgres    | qiaopengjun | UTF8     | libc            | C       | C     |        |           | 
 qiaopengjun | qiaopengjun | UTF8     | libc            | C       | C     |        |           | 
 shortener   | qiaopengjun | UTF8     | libc            | C       | C     |        |           | 
 template0   | qiaopengjun | UTF8     | libc            | C       | C     |        |           | =c/qiaopengjun                 +
             |             |          |                 |         |       |        |           | qiaopengjun=CTc/qiaopengjun
 template1   | qiaopengjun | UTF8     | libc            | C       | C     |        |           | =c/qiaopengjun                 +
             |             |          |                 |         |       |        |           | qiaopengjun=CTc/qiaopengjun
 vrf_service | qiaopengjun | UTF8     | libc            | C       | C     |        |           | 
(8 rows)

qiaopengjun=# \c shortener;
You are now connected to database "shortener" as user "qiaopengjun".
shortener=# 
```

## 使用 Pgcli 进行数据库操作

如果和 `pg` 打交道的话，使用 `pgcli` 是最好的选择。

### 安装 pgcli

```bash
brew install pgcli
```

### 查看 pgcli 版本信息验证安装

```bash
pgcli --version
Version: 4.3.0
```

### 修改 `shortener` 数据库 owner  

```sql
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜    psql -U qiaopengjun -d postgres
psql (17.4 (Homebrew))
Type "help" for help.

postgres=#    ALTER DATABASE shortener OWNER TO postgres;
ALTER DATABASE
postgres=# \l
postgres=# 

```

### **运行示例**

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 16m 17.4s 
➜ cargo run --example shortener
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.40s
     Running `target/debug/examples/shortener`
2025-07-14T14:09:09.882836Z  INFO sqlx::postgres::notice: relation "urls" already exists, skipping
2025-07-14T14:09:09.882954Z  INFO shortener: Connected to database: postgres://postgres:postgres@localhost:5432/shortener
2025-07-14T14:09:09.883359Z  INFO shortener: listening on localhost:9876

```

### 第一次`shorten` POST 请求

```bash
### url shortener
POST http://localhost:9876/ HTTP/1.1
Content-Type: application/json

{
    "url": "https://www.google.com"
}
```

### 第一次`shorten` POST 响应

```bash
HTTP/1.1 201 Created
content-type: application/json
content-length: 38
connection: close
date: Mon, 14 Jul 2025 14:09:23 GMT

{
  "url": "http://localhost:9876/xIFHyu"
}

```

### 第一次`redirect` GET 请求

```bash
### url redirect
GET http://localhost:9876/xIFHyu HTTP/1.1
```

### 第一次`redirect` GET 响应

```bash
HTTP/1.1 200 OK
Date: Mon, 14 Jul 2025 13:49:18 GMT
Expires: -1
Cache-Control: private, max-age=0
Content-Type: text/html; charset=ISO-8859-1
Content-Security-Policy-Report-Only: object-src 'none';base-uri 'self';script-src 'nonce-01EF6ENpchT-zZpJzVoKXA' 'strict-dynamic' 'report-sample' 'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp
Accept-CH: Sec-CH-Prefers-Color-Scheme
Content-Encoding: gzip
Server: gws
X-XSS-Protection: 0
X-Frame-Options: SAMEORIGIN
Alt-Svc: h3=":443"; ma=2592000,h3-29=":443"; ma=2592000
Connection: close
Transfer-Encoding: chunked

<!doctype html><html itemscope="" itemtype="http://schema.org/WebPage" lang="zh-HK"><head><meta content="text/html; charset=UTF-8" http-equiv="Content-Type"><meta content="/images/branding/googleg/1x/googleg_standard_color_128dp.png" itemprop="image"><title>Google</title><script nonce="01EF6ENpchT-zZpJzVoKXA">(function(){var _g={kEI:'3gp1aIfcDNesur8PtO3Z-[]
... ...
EA\x22}}';google.pmc=JSON.parse(pmc);})();</script></body></html>

```

### 第二次`shorten` POST 请求

```bash
### url shortener
POST http://localhost:9876/ HTTP/1.1
Content-Type: application/json

{
    "url": "https://www.google.com"
}
```

### 第二次`shorten` POST 响应

```http
HTTP/1.1 422 Unprocessable Entity
connection: close
content-length: 0
date: Mon, 14 Jul 2025 13:47:27 GMT

```

### 运行日志

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 11m 48.3s 
➜ cargo run --example shortener
   Compiling rust-ecosystem-learning v0.1.0 (/Users/qiaopengjun/Code/Rust/rust-ecosystem-learning)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 2.26s
     Running `target/debug/examples/shortener`
2025-07-14T13:52:52.633414Z  INFO sqlx::postgres::notice: relation "urls" already exists, skipping
2025-07-14T13:52:52.633506Z  INFO shortener: Connected to database: postgres://postgres:postgres@localhost:5432/shortener
2025-07-14T13:52:52.633931Z  INFO shortener: listening on localhost:9876
2025-07-14T13:53:09.694743Z  WARN shortener: Failed to shorten URL: error returned from database: duplicate key value violates unique constraint "urls_url_key"

```

第二次使用完全相同的 URL (`https://www.google.com`) 请求缩短时，服务返回了 `422 Unprocessable Entity` 错误，这是**由数据库层面强制执行的数据唯一性约束所导致的**。

### 问题分析：重复 URL 导致 `422 Unprocessable Entity` 错误

这个问题的根源在于数据库表的设计和应用程序处理错误的方式。我们可以分步来看：

#### 1. 数据库表结构 (`UNIQUE` 约束)

在代码的 `AppState::try_new` 函数中，服务启动时会执行以下 SQL 语句来创建表（如果表不存在的话）：

```sql
CREATE TABLE IF NOT EXISTS urls (
    id CHAR(6) PRIMARY KEY,
    url TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
)
```

这里的关键部分是 `url TEXT NOT NULL UNIQUE`。

- `UNIQUE` 是一个数据库约束，它**保证了 `url` 这一列中的所有值都是唯一的**。
- 当您第一次请求缩短 `https://www.google.com` 时，数据库中还没有这个记录，所以 `INSERT` 操作成功。
- 当您第二次发送完全相同的 URL 时，应用程序尝试再次执行 `INSERT` 操作。PostgreSQL 数据库在执行插入前会检查 `url` 列，发现 `https://www.google.com` 这个值已经存在了，这违反了 `UNIQUE` 约束，因此数据库拒绝了这次插入，并向应用程序返回一个错误。

#### 2. 应用程序的执行流程和错误处理

我们来跟踪第二次请求在代码中的执行路径：

1. **接收请求**: `shorten` 函数接收到包含 `{ "url": "https://www.google.com" }` 的 `POST` 请求。

2. **调用 `shorten` 方法**: 代码执行 `state.shorten(&data.url).await`。

3. **尝试插入数据库**: 在 `AppState::shorten` 方法内部，代码首先生成一个新的、随机的 `id`（例如 `abc123`），然后执行 SQL 插入语句：

   ```rust
   sqlx::query("INSERT INTO urls (id, url) VALUES ($1, $2)")
       .bind(&id)       // $1 = "abc123" (新生成的ID)
       .bind(url)       // $2 = "https://www.google.com" (已存在的URL)
       .execute(&self.db)
       .await?; // <-- 这里会失败！
   ```

4. **捕获数据库错误**: 因为数据库返回了 "duplicate key" (重复键) 错误，`execute` 方法的结果是一个 `Err(...)`。这个错误被 `?` 操作符传递出 `AppState::shorten` 方法。

5. **映射为 HTTP 状态码**: 在 `shorten` 路由处理函数中，这个错误被 `.map_err()` 捕获：

   ```rust
   let id = state.shorten(&data.url).await.map_err(|e| {
       // e 包含了详细的数据库错误信息
       warn!("Failed to shorten URL: {e}"); // 这就是您在日志中看到的 WARN 信息
       StatusCode::UNPROCESSABLE_ENTITY    // 将内部错误转换为 HTTP 422 状态码
   })?;
   ```

   代码将这个内部数据库错误，转换成了一个对客户端更友好的 HTTP 错误 `422 Unprocessable Entity`。这个状态码的含义是“服务器理解请求的格式，但是无法处理请求中的指令”，在这里非常适用，因为无法处理的原因是 URL 重复了。

## 优化完善

```rust
use anyhow::Result;
use axum::{
    Json, Router,
    extract::{Path, State},
    http::HeaderMap,
    response::IntoResponse,
    routing::{get, post},
};
use nanoid::nanoid;
use reqwest::{StatusCode, header::LOCATION};
use serde::{Deserialize, Serialize};
use sqlx::{FromRow, PgPool};
use tokio::net::TcpListener;
use tracing::{info, level_filters::LevelFilter, warn};
use tracing_subscriber::{Layer as _, fmt::Layer, layer::SubscriberExt, util::SubscriberInitExt};

#[derive(Debug, Deserialize)]
struct ShortenReq {
    url: String,
}

#[derive(Debug, Serialize)]
struct ShortenRes {
    url: String,
}

#[derive(Debug, Clone)]
struct AppState {
    db: PgPool,
}

#[derive(Debug, FromRow)]
struct UrlRecord {
    #[sqlx(default)]
    id: String,
    #[sqlx(default)]
    url: String,
}

const LISTEN_ADDR: &str = "localhost:9876";

#[tokio::main]
async fn main() -> Result<()> {
    dotenvy::dotenv()?;

    let layer = Layer::new().with_filter(LevelFilter::INFO);
    tracing_subscriber::registry().with(layer).init();

    let url = std::env::var("DATABASE_URL")?;
    // 一般情况下，AppState 都需要使用 Arc 来包裹，因为每一次 state 被使用的时候，都会被 clone 出一个新的 AppState
    // 这里不使用 Arc 是因为 PgPool 内部已经使用了 Arc，所以 AppState 内部不需要再包裹一层 Arc， #[derive(Debug, Clone)] 也会自动生成
    // 如果内部没有使用 Arc，那么一定不要使用 Clone
    // let state = Arc::new(AppState::try_new(&url).await?);
    let state = AppState::try_new(&url).await?;
    info!("Connected to database: {url}");

    let listener = TcpListener::bind(LISTEN_ADDR).await?;
    info!("listening on {}", LISTEN_ADDR);

    let app = Router::new()
        .route("/", post(shorten))
        .route("/{id}", get(redirect))
        .with_state(state);

    axum::serve(listener, app.into_make_service()).await?;

    Ok(())
}

async fn shorten(
    State(state): State<AppState>, // 注意：这里如果 State(state) 在 Json 之后会导致编译错误 body extractor 只能有一个并且要放在最后
    Json(data): Json<ShortenReq>,
) -> Result<impl IntoResponse, StatusCode> {
    let id = state.shorten(&data.url).await.map_err(|e| {
        warn!("Failed to shorten URL: {e}");
        StatusCode::UNPROCESSABLE_ENTITY
    })?;

    let body = Json(ShortenRes {
        url: format!("http://{LISTEN_ADDR}/{id}"),
    });
    Ok((StatusCode::CREATED, body))
}

async fn redirect(
    Path(id): Path<String>,
    State(state): State<AppState>,
) -> Result<impl IntoResponse, StatusCode> {
    let url = state
        .get_url(&id)
        .await
        .map_err(|_| StatusCode::NOT_FOUND)?;

    let mut headers = HeaderMap::new();
    headers.insert(LOCATION, url.parse().unwrap());

    // Ok((StatusCode::FOUND, headers))
    Ok((StatusCode::PERMANENT_REDIRECT, headers))
}

impl AppState {
    async fn try_new(url: &str) -> Result<Self> {
        let pool = PgPool::connect(url).await?;
        // create tables if not exists
        sqlx::query(
            r#"CREATE TABLE IF NOT EXISTS urls (
                id CHAR(6) PRIMARY KEY,
                url TEXT NOT NULL UNIQUE,
                created_at TIMESTAMP NOT NULL DEFAULT NOW()
            )"#,
        )
        .execute(&pool)
        .await?;

        Ok(Self { db: pool })
    }

    async fn shorten(&self, url: &str) -> Result<String> {
        let id = nanoid!(6);
        let ret: UrlRecord = sqlx::query_as(
            "INSERT INTO urls (id, url) VALUES ($1, $2) ON CONFLICT (url) DO UPDATE SET url = EXCLUDED.url RETURNING id",
        )
        .bind(&id)
        .bind(url)
        .fetch_one(&self.db)
        .await?;

        Ok(ret.id)
    }

    async fn get_url(&self, id: &str) -> Result<String> {
        let ret: UrlRecord = sqlx::query_as("SELECT url FROM urls WHERE id = $1")
            .bind(id)
            .fetch_one(&self.db)
            .await?;

        Ok(ret.url)
    }
}

```

这是一段优化后的高性能 URL 短链接服务代码。它在之前版本的基础上，通过引入 PostgreSQL 特有的 `UPSERT` 功能，优雅地解决了重复提交相同 URL 会导致错误的问题，现在即使用户多次缩短同一个长链接，服务也能稳定返回对应的短链接ID。同时，代码将重定向的 HTTP 状态码从 `302 Found` 更改为 `308 Permanent Redirect`，这更符合永久链接的语义，对搜索引擎优化（SEO）和浏览器缓存更友好。此外，代码结构也得到了改善，通过引入派生自 `sqlx::FromRow` 的 `UrlRecord` 结构体，使得从数据库查询结果到 Rust 结构体的映射更加清晰和类型安全。

### 如何解决重复 URL 问题

解决重复 URL 问题是通过 PostgreSQL 特有的 **“UPSERT”** 功能（即 `INSERT ... ON CONFLICT`）来解决之前讨论的重复 URL 问题的。这种方式比“先查询再插入”的逻辑更简洁、更高效，并且能避免并发场景下的竞态条件。

具体的实现体现在 `AppState::shorten` 方法中的这段 SQL 查询：

```rust
let ret: UrlRecord = sqlx::query_as(
    "INSERT INTO urls (id, url) VALUES ($1, $2) ON CONFLICT (url) DO UPDATE SET url = EXCLUDED.url RETURNING id",
)
// ...
```

我们来分解这个 SQL 语句：

1. **`INSERT INTO urls (id, url) VALUES ($1, $2)`**
   - 这部分是常规的插入操作。代码尝试将新生成的 `id` 和用户提供的 `url` 插入到 `urls` 表中。
2. **`ON CONFLICT (url)`**
   - 这是核心。它告诉 PostgreSQL：“如果在插入时，发现 `url` 列的值与已存在的记录重复（即违反了 `url` 列的 `UNIQUE` 约束），**请不要报错**，而是执行接下来的指令。”
3. **`DO UPDATE SET url = EXCLUDED.url`**
   - 这是发生冲突时执行的指令。`EXCLUDED` 是一个特殊的表，代表了“本应插入但因冲突而失败的数据行”。`SET url = EXCLUDED.url` 实际上是把已存在的 URL 更新为它自己，这是一个保持行记录不变的巧妙方法，其主要目的是为了能够顺利执行 `RETURNING` 子句。
4. **`RETURNING id`**
   - 这是整个操作的点睛之笔。
     - **如果没有冲突**（即 `INSERT` 成功），它会返回新插入行的 `id`。
     - **如果发生了冲突**（即 `DO UPDATE` 被执行），它会返回那条**已存在的、导致冲突的行**的 `id`。

最终，这一个原子性的数据库操作，无论 URL 是否已经存在，都能保证返回一个有效的 `id`，从而完美地解决了重复 URL 的问题。

### 运行测试

```bash
rust-ecosystem-learning on  main is 📦 0.1.0 via 🦀 1.88.0 took 4.0s 
➜ cargo run --example shortener
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.05s
     Running `target/debug/examples/shortener`
2025-07-15T07:06:43.324439Z  INFO sqlx::postgres::notice: relation "urls" already exists, skipping
2025-07-15T07:06:43.324691Z  INFO shortener: Connected to database: postgres://postgres:postgres@localhost:5432/shortener
2025-07-15T07:06:43.325125Z  INFO shortener: listening on localhost:9876
```

### `shorten` POST 请求

```bash
### url shortener
POST http://localhost:9876/ HTTP/1.1
Content-Type: application/json

{
    "url": "https://www.baidu.com"
}
```

### `shorten` POST 响应

```bash
HTTP/1.1 201 Created
content-type: application/json
content-length: 38
connection: close
date: Mon, 14 Jul 2025 14:09:23 GMT

{
  "url": "http://localhost:9876/ojVYVT"
}

```

### `redirect` GET 请求

```bash
### url redirect
GET http://localhost:9876/ojVYVT HTTP/1.1
```

### `redirect` GET 响应

```bash
HTTP/1.1 200 OK
Cache-Control: no-cache
Content-Encoding: gzip
Content-Type: text/html
Date: Mon, 14 Jul 2025 14:11:16 GMT
P3p: CP=" OTI DSP COR IVA OUR IND COM ", CP=" OTI DSP COR IVA OUR IND COM "
Pragma: no-cache
Server: BWS/1.1
Set-Cookie: BAIDUID=D208C05364DA42CEE6CC58B0809BF509:FG=1; expires=Thu, 31-Dec-37 23:55:55 GMT; max-age=2147483647; path=/; domain=.baidu.com,BIDUPSID=D208C05364DA42CEE6CC58B0809BF509; expires=Thu, 31-Dec-37 23:55:55 GMT; max-age=2147483647; path=/; domain=.baidu.com,PSTM=1752502276; expires=Thu, 31-Dec-37 23:55:55 GMT; max-age=2147483647; path=/; domain=.baidu.com,BAIDUID=D208C05364DA42CEC355783B0157C189:FG=1; max-age=31536000; expires=Tue, 14-Jul-26 14:11:16 GMT; domain=.baidu.com; path=/; version=1; comment=bd
Traceid: 175250227634316720747379949211500434863
Vary: Accept-Encoding
X-Ua-Compatible: IE=Edge,chrome=1
X-Xss-Protection: 1;mode=block
Connection: close
Transfer-Encoding: chunked

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
    <meta content="always" name="referrer" />
    <meta
        name="description"
        content="全球领先的中文搜索引擎、致力于让网民更便捷地获取信息，找到所求。百度超过千亿的中文网页数据库，可以瞬间找到相关的搜索结果。"
    />
  ... ...

        document.getElementById('year').innerText = '©' + year + ' Baidu ';
    </script>
</body>
</html>

```

### 再次 `shorten` POST 请求

```bash
### url shortener
POST http://localhost:9876/ HTTP/1.1
Content-Type: application/json

{
    "url": "https://www.baidu.com"
}
```

### 再次 `shorten` POST 响应

```bash
HTTP/1.1 201 Created
content-type: application/json
content-length: 38
connection: close
date: Tue, 15 Jul 2025 07:08:59 GMT

{
  "url": "http://localhost:9876/ojVYVT"
}

```

如测试结果所示，服务不仅成功处理了初次创建和重定向的请求，更关键的是，当重复提交相同的长链接时，它能够稳定且幂等地返回之前创建的同一个短链接。这证明了优化方案已完美生效，系统达到了预期的健壮性和一致性。

## 总结

通过本次**生产级**的实战演练，我们不仅成功地用 Rust、Axum 和 `sqlx` 打造了一个高性能的 URL 短链接服务，更重要的是，我们完整体验了构建一个健壮应用的思考过程。

回顾全文，我们收获了几个关键的**生产级**开发要点：

1. **精准控制带来极致性能**：我们见证了 `sqlx` 如何让我们直接利用数据库（PostgreSQL）的原生特性。通过 `ON CONFLICT` (UPSERT) 这一原子操作，我们优雅且高效地解决了数据唯一性问题，这是追求极致性能和数据一致性的不二法门。
2. **现代工具赋能高效开发**：`sqlx` 在给予我们原生 SQL 控制力的同时，通过编译时检查和 `FromRow` 等特性，提供了现代化的开发体验和类型安全保障，让我们鱼与熊掌兼得。
3. **细节决定生产质量**：我们深入探讨了 Axum 框架中状态管理（`AppState` 与 `Arc`）和处理器参数顺序等关键细节。正是对这些细节的正确处理，才是一个应用能否称得上“健壮”和“生产级”的分水岭。

总而言之，一个真正的**生产级**应用，是由无数个正确的架构决策、稳健的代码模式和对细节的极致追求共同构成的。希望这次完整的实战旅程，能为您在未来的 Rust 后端开发道路上，提供一份坚实的参考和信心。

## 参考

- <https://github.com/diesel-rs/diesel>
- <https://diesel.rs/>
- <https://github.com/SeaQL/sea-orm>
- <https://github.com/launchbadge/sqlx>
- <https://docs.rs/sqlx/latest/sqlx/>
- <https://docs.rs/sqlx/latest/sqlx/fn.query_as.html>
- <https://docs.rs/sqlx/latest/sqlx/trait.FromRow.html>
- <https://www.pgcli.com/>
- <https://github.com/dbcli/pgcli>
- <https://docs.rs/dotenvy/latest/dotenvy/fn.dotenv.html#examples>
- <https://github.com/mrdimidium/nanoid>
- <https://neon.com/postgresql/postgresql-tutorial/postgresql-upsert>
- <https://www.postgresql.org/docs/current/sql-insert.html>
