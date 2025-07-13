+++
title = "用 Rust 实现 HTTPie：一个现代 CLI 工具的构建过程"
description = "本文记录了使用 Rust 从零开始构建一个现代化 HTTP 客户端 HTTPie 的完整技术过程。文章以功能实现为导向，详细阐述了如何集成 clap 库进行命令行解析，如何运用 reqwest 与 tokio 实现异步 HTTP 通信，以及如何通过 syntect 等库美化终端输出。通过约 155 行核心代码，本文展示了 Rust 在开发高效、可靠的命令行工具方面的强大能力与工程实践。"
date = 2025-07-13T02:49:02Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust", "HTTPie", "CLI"]
+++

<!-- more -->

# 用 Rust 实现 HTTPie：一个现代 CLI 工具的构建过程

命令行工具（CLI）是开发者工具箱中不可或缺的一部分。在众多用于 HTTP 测试的工具中，cURL 功能强大，而 HTTPie 则以其出色的用户体验和易用性备受青睐。后者正是一个优秀的现代 CLI 工具范例。

本文将完整记录使用 Rust 语言构建一个类 HTTPie 工具的全过程。我们将从功能需求分析出发，逐步探讨如何利用 Rust 的生态系统来处理命令行参数解析、执行异步网络请求，以及如何对响应结果进行格式化与高亮输出，最终呈现一个功能完备的 CLI 应用。

## 需求分析与项目初始化

实现 HTTPie 为例，看看用 Rust 怎么做 CLI。HTTPie 是用 Python 开发的，一个类似 cURL 但对用户更加友善的命令行工具，它可以帮助我们更好地诊断 HTTP 服务。

功能分析要做一个 HTTPie 这样的工具，我们先梳理一下要实现哪些主要功能：

- 首先是做命令行解析，处理子命令和各种参数，验证用户的输入，并且将这些输入转换成我们内部能理解的参数；
- 之后根据解析好的参数，发送一个 HTTP 请求，获得响应；
- 最后用对用户友好的方式输出响应。

### 创建项目

```bash
~ via 🅒 base
➜ cd Code/rust

~/Code/rust via 🅒 base
➜ cargo new httpie
     Created binary (application) `httpie` package

~/Code/rust via 🅒 base
➜ cd httpie

httpie on  master [?] via 🦀 1.88.0 via 🅒 base
➜ c

httpie on  master [?] via 🦀 1.88.0 via 🅒 base
➜

```

### Cargo.toml

```toml
[package]
name = "httpie"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
anyhow = "1.0.71"                                      # 错误处理
clap = { version = "4.3.9", features = ["derive"] }
colored = "2.0.0"                                      # 命令终端多彩显示
jsonxf = "1.1.1"                                       # JSON pretty print 格式化
mime = "0.3.17"                                        # 处理 mime 类型
reqwest = { version = "0.11.18", features = ["json"] } # HTTP 客户端
tokio = { version = "1.29.0", features = ["full"] }    # 异步处理库

```

### main.rs

```rust
use clap::Parser;

// 定义 HTTPie 的 CLI 的主入口，它包含若干个子命令
// 下面 /// 的注释是文档，clap 会将其作为 CLI 的帮助

/// A naive httpie implementation with Rust, can you imagine how easy it is?
#[derive(Parser, Debug)]
#[clap(version = "1.0", author = "Tyr Chen <tyr@chen.com>")]
struct Opts {
    #[clap(subcommand)]
    subcmd: SubCommand,
}

// 子命令分别对应不同的 HTTP 方法，目前只支持 get / post
#[derive(Parser, Debug)]
enum SubCommand {
    Get(Get),
    Post(Post),
    // 我们暂且不支持其它 HTTP 方法
}

// get 子命令

/// feed get with an url and we will retrieve the response for you
#[derive(Parser, Debug)]
struct Get {
    /// HTTP 请求的 URL
    url: String,
}

// post 子命令。需要输入一个 URL，和若干个可选的 key=value，用于提供 json body

/// feed post with an url and optional key=value pairs. We will post the data
/// as JSON, and retrieve the response for you
#[derive(Parser, Debug)]
struct Post {
    /// HTTP 请求的 URL
    url: String,
    /// HTTP 请求的 body
    body: Vec<String>,
}

fn main() {
    let opts: Opts = Opts::parse();
    println!("{:?}", opts);
}

```

### 运行

```bash
httpie on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base took 8.7s 
➜ cargo build --quiet && target/debug/httpie post httpbin.org/post a=1 b=2

Opts { subcmd: Post(Post { url: "httpbin.org/post", body: ["a=1", "b=2"] }) }

httpie on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ cargo build --quiet && target/debug/httpie post a=1 b=2
Opts { subcmd: Post(Post { url: "a=1", body: ["b=2"] }) }

httpie on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base took 2.9s 
➜ 
```

### Git 代码提交

```bash
ttpie on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base
➜ echo "# httpie" >> README.md

httpie on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base
➜ git add .

httpie on  master [+] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base
➜ git commit -m "first commit"
[master（根提交） fe158bb] first commit
 5 files changed, 1434 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 Cargo.lock
 create mode 100644 Cargo.toml
 create mode 100644 README.md
 create mode 100644 src/main.rs

httpie on  master is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base
➜ git branch -M main

httpie on  main is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base
➜ git remote add origin git@github.com:qiaopengjun5162/httpie.git

httpie on  main is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base
➜ git push -u origin main
枚举对象中: 8, 完成.
对象计数中: 100% (8/8), 完成.
使用 12 个线程进行压缩
压缩对象中: 100% (5/5), 完成.
写入对象中: 100% (8/8), 10.50 KiB | 5.25 MiB/s, 完成.
总共 8（差异 0），复用 0（差异 0），包复用 0
To github.com:qiaopengjun5162/httpie.git
 * [new branch]      main -> main
分支 'main' 设置为跟踪 'origin/main'。

httpie on  main is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base took 4.3s
➜
```

### 完整代码

#### 项目目录

```bash
httpie on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ tree -a -I "target|.git"                  
.
├── .gitignore
├── Cargo.lock
├── Cargo.toml
├── README.md
└── src
    └── main.rs

2 directories, 5 files

httpie on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ 
```

#### main.rs

```rust
use anyhow::{anyhow, Result};
use clap::Parser;
use colored::Colorize;
use mime::Mime;
use reqwest::{header, Client, Response, Url};
use std::{collections::HashMap, str::FromStr};
use syntect::{
    easy::HighlightLines,
    highlighting::{Style, ThemeSet},
    parsing::SyntaxSet,
    util::{as_24_bit_terminal_escaped, LinesWithEndings},
};

// 以下部分用于处理 CLI

// 定义 HTTPie 的 CLI 的主入口，它包含若干个子命令
// 下面 /// 的注释是文档，clap 会将其作为 CLI 的帮助

/// A naive httpie implementation with Rust, can you imagine how easy it is?
/// 一个用 Rust 实现的简易版 httpie，简单到你无法想象
#[derive(Parser, Debug)]
#[clap(version = "1.0", author = "Tyr Chen <tyr@chen.com>")]
struct Opts {
    #[clap(subcommand)]
    subcmd: SubCommand,
}

// 子命令分别对应不同的 HTTP 方法，目前只支持 get / post
#[derive(Parser, Debug)]
enum SubCommand {
    Get(Get),
    Post(Post),
    // 我们暂且不支持其它 HTTP 方法
}

// get 子命令

/// feed get with an url and we will retrieve the response for you
/// 发送一个 GET 请求，获取服务端响应
#[derive(Parser, Debug)]
struct Get {
    /// HTTP 请求的 URL
    #[arg(value_parser=parse_url)]
    url: String,
}

// post 子命令。需要输入一个 URL，和若干个可选的 key=value，用于提供 json body

/// feed post with an url and optional key=value pairs. We will post the data
/// as JSON, and retrieve the response for you
#[derive(Parser, Debug)]
struct Post {
    /// HTTP 请求的 URL
    #[arg(value_parser=parse_url)]
    url: String,
    /// HTTP 请求的 body
    #[arg(value_parser=parse_kv_pair)]
    body: Vec<KvPair>,
}

/// 命令行中的 key=value 可以通过 parse_kv_pair 解析成 KvPair 结构
#[derive(Debug, Clone, PartialEq)]
struct KvPair {
    k: String,
    v: String,
}

/// 当我们实现 FromStr trait 后，可以用 str.parse() 方法将字符串解析成 KvPair
impl FromStr for KvPair {
    type Err = anyhow::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        // 使用 = 进行 split，这会得到一个迭代器
        let mut split = s.split("=");
        let err = || anyhow!(format!("Failed to parse {}", s));
        Ok(Self {
            // 从迭代器中取第一个结果作为 key，迭代器返回 Some(T)/None
            // 我们将其转换成 Ok(T)/Err(E)，然后用 ? 处理错误
            k: (split.next().ok_or_else(err)?).to_string(),
            // 从迭代器中取第二个结果作为 value
            v: (split.next().ok_or_else(err)?).to_string(),
        })
    }
}

/// 因为我们为 KvPair 实现了 FromStr，这里可以直接 s.parse() 得到 KvPair
fn parse_kv_pair(s: &str) -> Result<KvPair> {
    Ok(s.parse()?)
}

fn parse_url(s: &str) -> Result<String> {
    // 这里我们仅仅检查一下 URL 是否合法
    let _url: Url = s.parse()?;
    Ok(s.into())
}

/// 处理 get 子命令
async fn get(client: Client, args: &Get) -> Result<()> {
    let resp = client.get(&args.url).send().await?;
    Ok(print_resp(resp).await?)
}

/// 处理 post 子命令
async fn post(client: Client, args: &Post) -> Result<()> {
    let mut body = HashMap::new();
    for pair in args.body.iter() {
        body.insert(&pair.k, &pair.v);
    }
    let resp = client.post(&args.url).json(&body).send().await?;
    Ok(print_resp(resp).await?)
}

// 打印服务器版本号 + 状态码
fn print_status(resp: &Response) {
    let status = format!("{:?} {}", resp.version(), resp.status()).blue();
    println!("{}\n", status);
}

// 打印服务器返回的 HTTP header
fn print_headers(resp: &Response) {
    for (name, value) in resp.headers() {
        println!("{}: {:?}", name.to_string().green(), value);
    }

    println!();
}

/// 打印服务器返回的 HTTP body
fn print_body(m: Option<Mime>, body: &str) {
    match m {
        // 对于 "application/json" 我们 pretty print
        Some(v) if v == mime::APPLICATION_JSON => print_syntect(body, "json"),
        Some(v) if v == mime::TEXT_HTML => print_syntect(body, "html"),

        // 其它 mime type，我们就直接输出
        _ => println!("{}", body),
    }
}

/// 打印整个响应
async fn print_resp(resp: Response) -> Result<()> {
    print_status(&resp);
    print_headers(&resp);
    let mime = get_content_type(&resp);
    let body = resp.text().await?;
    print_body(mime, &body);
    Ok(())
}

/// 将服务器返回的 content-type 解析成 Mime 类型
fn get_content_type(resp: &Response) -> Option<Mime> {
    resp.headers()
        .get(header::CONTENT_TYPE)
        .map(|v| v.to_str().unwrap().parse().unwrap())
}

/// 程序的入口函数，因为在 HTTP 请求时我们使用了异步处理，所以这里引入 tokio
#[tokio::main]
async fn main() -> Result<()> {
    let opts: Opts = Opts::parse();
    let mut headers = header::HeaderMap::new();
    // 为我们的 http 客户端添加一些缺省的 HTTP 头
    headers.insert("X-POWERED-BY", "Rust".parse()?);
    headers.insert(header::USER_AGENT, "Rust Httpie".parse()?);
    let client = reqwest::Client::builder()
        .default_headers(headers)
        .build()?;
    let result = match opts.subcmd {
        SubCommand::Get(ref args) => get(client, args).await?,
        SubCommand::Post(ref args) => post(client, args).await?,
    };

    Ok(result)
}

fn print_syntect(s: &str, ext: &str) {
    // 将字符串按照指定语法进行高亮并打印的功能。
    // Load these once at the start of your program
    let ps = SyntaxSet::load_defaults_newlines();
    let ts = ThemeSet::load_defaults();
    let syntax = ps.find_syntax_by_extension(ext).unwrap();
    let mut h = HighlightLines::new(syntax, &ts.themes["base16-ocean.dark"]);
    for line in LinesWithEndings::from(s) {
        let ranges_result: Result<Vec<(Style, &str)>, _> = h.highlight_line(line, &ps);
        let ranges = ranges_result.unwrap(); // 或者使用 expect() 方法处理错误
        let escaped = as_24_bit_terminal_escaped(&ranges[..], true);
        print!("{}", escaped);
    }
}

// 仅在 cargo test 时才编译
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_url_works() {
        assert!(parse_url("abc").is_err());
        assert!(parse_url("http://abc.xyz").is_ok());
        assert!(parse_url("https://httpbin.org/post").is_ok());
    }

    #[test]
    fn parse_kv_pair_works() {
        assert!(parse_kv_pair("a").is_err());
        assert_eq!(
            parse_kv_pair("a=1").unwrap(),
            KvPair {
                k: "a".into(),
                v: "1".into()
            }
        );

        assert_eq!(
            parse_kv_pair("b=").unwrap(),
            KvPair {
                k: "b".into(),
                v: "".into()
            }
        );
    }
}

```

#### Cargo.toml

```rust
[package]
name = "httpie"
version = "0.1.0"
edition = "2024"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
anyhow = "1.0.71"                                      # 错误处理
clap = { version = "4.3.9", features = ["derive"] }    # 命令行解析
colored = "2.0.0"                                      # 命令终端多彩显示
jsonxf = "1.1.1"                                       # JSON pretty print 格式化
mime = "0.3.17"                                        # 处理 mime 类型
reqwest = { version = "0.11.18", features = ["json"] } # HTTP 客户端
tokio = { version = "1.29.0", features = ["full"] }    # 异步处理库
syntect = "5.0.0"

```

### 使用代码行数统计工具 tokei 可以看到

```bash
httpie on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base took 24.7s 
➜ tokei src/main.rs 
===============================================================================
 Language            Files        Lines         Code     Comments       Blanks
===============================================================================
 Rust                    1          204          155           20           29
 |- Markdown             1           16            0           16            0
 (Total)                            220          155           36           29
===============================================================================
 Total                   1          204          155           20           29
===============================================================================

httpie on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ 
```

### 运行

```bash
httpie on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ cargo build --quiet

httpie on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base took 3.5s 
➜ target/debug/httpie post https://httpbin.org/post a=1 b
error: invalid value 'b' for '[BODY]...': Failed to parse b

For more information, try '--help'.

httpie on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ target/debug/httpie post abc a=1                       
error: invalid value 'abc' for '<URL>': relative URL without a base

For more information, try '--help'.

httpie on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ target/debug/httpie post https://httpbin.org/post a=1 b=2
HTTP/1.1 200 OK

date: "Fri, 30 Jun 2025 02:56:38 GMT"
content-type: "application/json"
content-length: "472"
connection: "keep-alive"
server: "gunicorn/19.9.0"
access-control-allow-origin: "*"
access-control-allow-credentials: "true"

{
  "args": {}, 
  "data": "{\"a\":\"1\",\"b\":\"2\"}", 
  "files": {}, 
  "form": {}, 
  "headers": {
    "Accept": "*/*", 
    "Content-Length": "17", 
    "Content-Type": "application/json", 
    "Host": "httpbin.org", 
    "User-Agent": "Rust Httpie", 
    "X-Amzn-Trace-Id": "Root=1-649e4444-7a2f12631acc444061bfc41c", 
    "X-Powered-By": "Rust"
  }, 
  "json": {
    "a": "1", 
    "b": "2"
  }, 
  "origin": "222.128.44.77", 
  "url": "https://httpbin.org/post"
}

httpie on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base took 38.3s 
➜ 
```

### 测试

```bash
httpie on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base took 38.3s 
➜ cargo test         
   Compiling httpie v0.1.0 (/Users/qiaopengjun/Code/rust/httpie)
    Finished test [unoptimized + debuginfo] target(s) in 1.23s
     Running unittests src/main.rs (target/debug/deps/httpie-0758ccd2852d828e)

running 2 tests
test tests::parse_kv_pair_works ... ok
test tests::parse_url_works ... ok

test result: ok. 2 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s


httpie on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ 
```

### 使用 cargo build --release，编译出 release 版本

```bash
httpie on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ cargo build --release
   Compiling libc v0.2.147
   Compiling autocfg v1.1.0
   Compiling proc-macro2 v1.0.63
   Compiling unicode-ident v1.0.9
   Compiling quote v1.0.29
   Compiling cfg-if v1.0.0
   Compiling bitflags v1.3.2
   Compiling io-lifetimes v1.0.11
   Compiling itoa v1.0.6
   Compiling rustix v0.37.20
   Compiling once_cell v1.18.0
   Compiling parking_lot_core v0.9.8
   Compiling pin-project-lite v0.2.9
   Compiling smallvec v1.10.0
   Compiling scopeguard v1.1.0
   Compiling futures-core v0.3.28
   Compiling bytes v1.4.0
   Compiling serde v1.0.164
   Compiling core-foundation-sys v0.8.4
   Compiling hashbrown v0.12.3
   Compiling lock_api v0.4.10
   Compiling indexmap v1.9.3
   Compiling tokio v1.29.0
   Compiling futures-task v0.3.28
   Compiling fnv v1.0.7
   Compiling tempfile v3.6.0
   Compiling slab v0.4.8
   Compiling tracing-core v0.1.31
   Compiling futures-util v0.3.28
   Compiling memchr v2.5.0
   Compiling lazy_static v1.4.0
   Compiling syn v2.0.22
   Compiling tracing v0.1.37
   Compiling errno v0.3.1
   Compiling signal-hook-registry v1.4.1
   Compiling socket2 v0.4.9
   Compiling mio v0.8.8
   Compiling num_cpus v1.16.0
   Compiling core-foundation v0.9.3
   Compiling security-framework-sys v2.9.0
   Compiling tokio-macros v2.1.0
   Compiling parking_lot v0.12.1
   Compiling http v0.2.9
   Compiling futures-channel v0.3.28
   Compiling httparse v1.8.0
   Compiling futures-sink v0.3.28
   Compiling pkg-config v0.3.27
   Compiling fastrand v1.9.0
   Compiling pin-utils v0.1.0
   Compiling tinyvec_macros v0.1.1
   Compiling cc v1.0.79
   Compiling native-tls v0.2.11
   Compiling tinyvec v1.6.0
   Compiling onig_sys v69.8.1
   Compiling security-framework v2.9.1
   Compiling try-lock v0.2.4
   Compiling crc32fast v1.3.2
   Compiling percent-encoding v2.3.0
   Compiling utf8parse v0.2.1
   Compiling serde_json v1.0.99
   Compiling ryu v1.0.13
   Compiling anstyle-parse v0.2.1
   Compiling form_urlencoded v1.2.0
   Compiling want v0.3.1
   Compiling unicode-normalization v0.1.22
   Compiling http-body v0.4.5
   Compiling is-terminal v0.4.7
   Compiling httpdate v1.0.2
   Compiling anstyle-query v1.0.0
   Compiling unicode-bidi v0.3.13
   Compiling thiserror v1.0.40
   Compiling colorchoice v1.0.0
   Compiling safemem v0.3.3
   Compiling base64 v0.21.2
   Compiling anstyle v1.0.1
   Compiling tower-service v0.3.2
   Compiling adler v1.0.2
   Compiling time-core v0.1.1
   Compiling anstream v0.3.2
   Compiling time v0.3.22
   Compiling miniz_oxide v0.7.1
   Compiling line-wrap v0.1.1
   Compiling idna v0.4.0
   Compiling quick-xml v0.28.2
   Compiling thiserror-impl v1.0.40
   Compiling strsim v0.10.0
   Compiling anyhow v1.0.71
   Compiling same-file v1.0.6
   Compiling heck v0.4.1
   Compiling clap_lex v0.5.0
   Compiling linked-hash-map v0.5.6
   Compiling unicode-width v0.1.10
   Compiling yaml-rust v0.4.5
   Compiling clap_builder v4.3.9
   Compiling clap_derive v4.3.2
   Compiling getopts v0.2.21
   Compiling walkdir v2.3.3
   Compiling tokio-util v0.7.8
   Compiling h2 v0.3.20
   Compiling tokio-native-tls v0.3.1
   Compiling flate2 v1.0.26
   Compiling plist v1.4.3
   Compiling url v2.4.0
   Compiling bincode v1.3.3
   Compiling serde_urlencoded v0.7.1
   Compiling serde_derive v1.0.164
   Compiling atty v0.2.14
   Compiling encoding_rs v0.8.32
   Compiling log v0.4.19
   Compiling mime v0.3.17
   Compiling ipnet v2.8.0
   Compiling regex-syntax v0.6.29
   Compiling hyper v0.14.27
   Compiling colored v2.0.0
   Compiling clap v4.3.9
   Compiling jsonxf v1.1.1
   Compiling hyper-tls v0.5.0
   Compiling reqwest v0.11.18
   Compiling onig v6.4.0
   Compiling syntect v5.0.0
   Compiling httpie v0.1.0 (/Users/qiaopengjun/Code/rust/httpie)
    Finished release [optimized] target(s) in 20.65s

httpie on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base took 20.7s 
➜ 
```

将其拷贝到某个在 $PATH下的目录，然后体验一下：

```bash
httpie on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base took 20.7s 
➜ mcd pub                 

httpie/pub on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ ls

httpie/pub on  main [!] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ cp ../target/release/httpie ./   

httpie/pub on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ ls
httpie

httpie/pub on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ ./httpie              
A naive httpie implementation with Rust, can you imagine how easy it is?

Usage: httpie <COMMAND>

Commands:
  get   feed get with an url and we will retrieve the response for you
  post  feed post with an url and optional key=value pairs. We will post the data as JSON, and retrieve the response for you
  help  Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version

httpie/pub on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ 
```

### 测试一下效果

```bash
httpie/pub on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ ./httpie post https://httpbin.org/post greeting=hola name=Tyr
HTTP/1.1 200 OK

date: "Fri, 30 Jun 2025 03:15:49 GMT"
content-type: "application/json"
content-length: "502"
connection: "keep-alive"
server: "gunicorn/19.9.0"
access-control-allow-origin: "*"
access-control-allow-credentials: "true"

{
  "args": {}, 
  "data": "{\"greeting\":\"hola\",\"name\":\"Tyr\"}", 
  "files": {}, 
  "form": {}, 
  "headers": {
    "Accept": "*/*", 
    "Content-Length": "32", 
    "Content-Type": "application/json", 
    "Host": "httpbin.org", 
    "User-Agent": "Rust Httpie", 
    "X-Amzn-Trace-Id": "Root=1-649e48e3-5fb585884394bb66433bf8a5", 
    "X-Powered-By": "Rust"
  }, 
  "json": {
    "greeting": "hola", 
    "name": "Tyr"
  }, 
  "origin": "222.128.44.77", 
  "url": "https://httpbin.org/post"
}

httpie/pub on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base took 6.6s 
➜ 
```

## 总结

通过对这个类 HTTPie 工具的完整构建，我们成功地展现了如何运用 Rust 及其生态系统，高效地完成一个功能强大且用户友好的 CLI 应用。

回顾整个构建过程，可以清晰地看到 Rust 在该领域的几大核心优势：

1. 现代化的包管理：Cargo 工具链让项目创建、依赖管理和编译发布流程化且高效。
2. 强大的生态系统：我们轻松集成了 clap、reqwest、tokio、syntect 等高质量的库，极大地加速了开发进程。
3. 安全与性能：Rust 的语言特性在编译期规避了大量潜在错误，同时保证了工具的运行时性能。
4. 出色的表达力：无论是 trait 的实现还是 async/await 异步语法，都让代码逻辑清晰，易于维护。

这个项目虽小，却完整覆盖了 CLI 应用的关键环节。它作为一个具体的实践案例，有力地证明了 Rust 是构建高性能、高可靠性系统工具的绝佳选择。

## 参考

- <https://time.geekbang.org/column/article/412883>
- <https://www.rust-lang.org/zh-CN>
- <https://course.rs/into-rust.html>
- <https://github.com/rust-lang/this-week-in-rust>
