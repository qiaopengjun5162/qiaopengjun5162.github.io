+++
title = "Rust 异步实战：从0到1，用 Tokio 打造一个高性能并发聊天室"
description = "从0到1实战Rust异步编程！本文手把手带你用Tokio构建一个高性能并发聊天室，并深入tokio-console调试与loom并发测试，助你贯通从开发到验证的完整链路。硬核教程，不容错过！"
date = 2025-07-13T12:09:24Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust", "Tokio", "异步编程", "聊天室", "并发测试", "tokio-console", "loom"]
+++

<!-- more -->

# Rust 异步实战：从0到1，用 Tokio 打造一个高性能并发聊天室

你是否曾对 Discord、Slack 这类高并发即时通讯应用的底层技术感到好奇？或者在学习 Rust 时，面对强大的 Tokio 异步运行时，感觉理论知识丰富，却不知如何下手实践？

别担心！本文将是一篇极致的实战指南，我们将告别枯燥的理论。通过从零开始、一步步构建一个功能完善的 TCP 聊天服务器，你不仅能深入理解 Tokio 的核心工作模式，还将学会如何利用 `tokio-console` 对异步任务进行可视化调试，甚至使用 `loom` 这一并发测试神器来验证代码的线程安全性。

准备好了吗？让我们一起动手，用代码真正“看见”并征服 Rust 异步世界！

## 🚀 本文将带你解锁

- tokio_util
- tokio_stream
- 写一个简单的 TCP Chat Server
  - client 连接：添加到全局状态
    - 创建 peer
    - 通知所有小伙伴
  - client 断连：从全局状态删除
    - 通知所有小伙伴
  - client 发消息
    - 广播
- tokio-console

## 实操

### Chat.rs 文件

```rust
use std::{fmt, net::SocketAddr, sync::Arc};

use anyhow::Result;
use dashmap::DashMap;
use futures::{SinkExt, StreamExt, stream::SplitStream};
use tokio::{
    net::{TcpListener, TcpStream},
    sync::mpsc,
};
use tokio_util::codec::{Framed, LinesCodec};
use tracing::{info, level_filters::LevelFilter, warn};
use tracing_subscriber::{Layer as _, fmt::Layer, layer::SubscriberExt, util::SubscriberInitExt};

const MAX_MESSAGES: usize = 128;

#[derive(Debug, Default)]
struct State {
    peers: DashMap<SocketAddr, mpsc::Sender<Arc<Message>>>,
}

#[derive(Debug)]
struct Peer {
    username: String,
    stream: SplitStream<Framed<TcpStream, LinesCodec>>,
}

#[derive(Debug)]
enum Message {
    UserJoined(String),
    UserLeft(String),
    Chat { sender: String, content: String },
}

#[tokio::main]
async fn main() -> Result<()> {
    let layer = Layer::new().with_filter(LevelFilter::INFO);
    tracing_subscriber::registry().with(layer).init();

    let addr = "0.0.0.0:8080";
    let listener = TcpListener::bind(addr).await?;
    info!("Listening on {}", addr);

    let state = Arc::new(State::default());

    loop {
        let (stream, addr) = listener.accept().await?;
        info!("Accepted connection from {}", addr);
        let state_cloned = state.clone();
        tokio::spawn(async move {
            if let Err(e) = handle_client(state_cloned, addr, stream).await {
                warn!("Failed to handle client {}: {}", addr, e);
            }
        });
    }
}

async fn handle_client(state: Arc<State>, addr: SocketAddr, stream: TcpStream) -> Result<()> {
    let mut stream = Framed::new(stream, LinesCodec::new());
    // 按帧发送的， LinesCodec 会在每行末尾加上 \n
    stream
        .send("Welcome to the chat! Please enter your username:")
        .await?;

    let username = match stream.next().await {
        Some(Ok(username)) => username,
        Some(Err(e)) => {
            warn!("Failed to receive username from {}: {}", addr, e);
            return Err(e.into());
        }
        None => {
            warn!("Client {} disconnected before sending username", addr);
            return Ok(());
        }
    };

    let mut peer = state.add(addr, username, stream).await;

    // notify others that a new peer has joined
    let message = Arc::new(Message::user_joined(&peer.username));
    state.broadcast(addr, message).await;

    while let Some(line) = peer.stream.next().await {
        let line = match line {
            Ok(line) => line,
            Err(err) => {
                warn!("Failed to receive message from {}: {}", addr, err);
                break;
            }
        };

        let message = Arc::new(Message::chat(&peer.username, line));
        state.broadcast(addr, message).await;
    }

    // when while loop exit, peer has left the chat or line reading failed
    // remove peer from state
    state.peers.remove(&addr);

    // notify others that peer has left the chat
    let message = Arc::new(Message::user_left(&peer.username));
    state.broadcast(addr, message).await;

    Ok(())
}

impl State {
    async fn broadcast(&self, addr: SocketAddr, message: Arc<Message>) {
        for peer in self.peers.iter() {
            if peer.key() == &addr {
                continue;
            }
            if let Err(e) = peer.value().send(message.clone()).await {
                warn!("Failed to send message to {}: {}", peer.key(), e);
                // Remove the peer from the state if it's no longer reachable
                self.peers.remove(peer.key());
            }
        }
    }

    async fn add(
        &self,
        addr: SocketAddr,
        username: String,
        stream: Framed<TcpStream, LinesCodec>,
    ) -> Peer {
        let (tx, mut rx) = mpsc::channel(MAX_MESSAGES);
        self.peers.insert(addr, tx);

        // split the stream into a sender and a receiver
        let (mut stream_sender, stream_receiver) = stream.split();

        // receive messages from others, and send them to the client
        tokio::spawn(async move {
            while let Some(message) = rx.recv().await {
                if let Err(e) = stream_sender.send(message.to_string()).await {
                    warn!("Failed to send message to {}: {}", addr, e);
                    break;
                }
            }
        });

        // return peer
        Peer {
            username,
            stream: stream_receiver,
        }
    }
}

impl Message {
    fn user_joined(username: &str) -> Self {
        let content = format!("{} has joined the chat", username);
        Self::UserJoined(content)
    }

    fn user_left(username: &str) -> Self {
        let content = format!("{} has left the chat", username);
        Self::UserLeft(content)
    }

    fn chat(sender: impl Into<String>, content: impl Into<String>) -> Self {
        Self::Chat {
            sender: sender.into(),
            content: content.into(),
        }
    }
}

impl fmt::Display for Message {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Message::UserJoined(content) => write!(f, "Server: {}", content),
            Message::UserLeft(content) => write!(f, "Server: {}", content),
            Message::Chat { sender, content } => write!(f, "{}: {}", sender, content),
        }
    }
}

```

这段 **Rust** 代码实现了一个基于 **Tokio** 的异步 **TCP 聊天服务器**。

它的核心逻辑是：

1. 在 `main` 函数中，服务器启动并监听 `8080` 端口，等待客户端连接。
2. 每当有新客户端连接，服务器会为其创建一个独立的异步任务 (`tokio::spawn`) 进行处理，这样可以高效地并发管理多个客户端。
3. `handle_client` 函数负责与单个客户端的完整交互：首先提示客户端输入用户名，然后将其信息（地址和消息发送通道）存入一个全局共享的、线程安全的 `State` (使用 `DashMap`) 中。
4. 服务器通过 `broadcast` 方法将新用户加入和离开的通知以及聊天消息广播给所有其他连接的客户端。
5. `State` 结构中的 `add` 方法巧妙地利用 `mpsc` channel（多生产者，单消费者通道）和 `stream.split()`，将读写操作分离：一个任务负责从客户端接收消息，另一个任务负责将广播消息发送给该客户端。当客户端断开连接时，服务器会清理其状态并通知其他用户。

#### 安装 Telnet

```bash
brew install telnet
```

### 运行与客户端调用测试

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 2m 42.4s 
➜ cargo run --example chat
   Compiling rust-ecosystem-learning v0.1.0 (/Users/qiaopengjun/Code/Rust/rust-ecosystem-learning)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.21s
     Running `target/debug/examples/chat`
2025-07-13T04:33:58.059142Z  INFO chat: Listening on 0.0.0.0:8080
2025-07-13T04:39:47.784622Z  INFO chat: Accepted connection from 127.0.0.1:58259
2025-07-13T04:40:19.174428Z  INFO chat: Accepted connection from 127.0.0.1:58394
2025-07-13T04:42:32.433305Z  INFO chat: Accepted connection from 127.0.0.1:58959


# client qiao
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ telnet 127.0.0.1 8080
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Welcome to the chat! Please enter your username:
qiao
Server: li has joined the chat
hello world
li: hi qiao
Server: Alice has joined the chat

## li
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ telnet 127.0.0.1 8080
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Welcome to the chat! Please enter your username:
li
qiao: hello world
hi qiao
Server: Alice has joined the chat

# Alice
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ telnet 127.0.0.1 8080
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Welcome to the chat! Please enter your username:
Alice

```

这段运行结果表明，你成功启动了 Rust 聊天服务器，并且它能够正确处理多个客户端的并发连接和消息交互。

测试中，三个客户端（用户名为 **qiao**、**li** 和 **Alice**）通过 `telnet` 命令连接到了在 `8080` 端口上监听的服务器。交互日志显示，服务器的核心功能运行正常：

1. **消息广播**：一个用户（如 qiao）发送的消息能被其他所有在线用户（如 li）接收到。
2. **状态通知**：当有新用户（如 li 或 Alice）加入聊天室时，服务器会向所有已在线的用户广播一条系统通知。

这证明了该聊天程序成功实现了基本的多人实时通信功能。

## 💅 体验升级：让日志和界面更出色

```rust
use std::{fmt, net::SocketAddr, sync::Arc};

use anyhow::Result;
use dashmap::DashMap;
use futures::{SinkExt, StreamExt, stream::SplitStream};
use tokio::{
    net::{TcpListener, TcpStream},
    sync::mpsc,
};
use tokio_util::codec::{Framed, LinesCodec};
use tracing::{info, level_filters::LevelFilter, warn};
use tracing_subscriber::{Layer as _, fmt::Layer, layer::SubscriberExt, util::SubscriberInitExt};

const MAX_MESSAGES: usize = 128;

#[derive(Debug, Default)]
struct State {
    peers: DashMap<SocketAddr, mpsc::Sender<Arc<Message>>>,
}

#[derive(Debug)]
struct Peer {
    username: String,
    stream: SplitStream<Framed<TcpStream, LinesCodec>>,
}

#[derive(Debug)]
enum Message {
    UserJoined(String),
    UserLeft(String),
    Chat { sender: String, content: String },
}

#[tokio::main]
async fn main() -> Result<()> {
    let layer = Layer::new().with_filter(LevelFilter::INFO);
    tracing_subscriber::registry().with(layer).init();

    let addr = "0.0.0.0:8080";
    let listener = TcpListener::bind(addr).await?;
    info!("Listening on {}", addr);

    let state = Arc::new(State::default());

    loop {
        let (stream, addr) = listener.accept().await?;
        info!("Accepted connection from {}", addr);
        let state_cloned = state.clone();
        tokio::spawn(async move {
            if let Err(e) = handle_client(state_cloned, addr, stream).await {
                warn!("Failed to handle client {}: {}", addr, e);
            }
        });
    }
}

async fn handle_client(state: Arc<State>, addr: SocketAddr, stream: TcpStream) -> Result<()> {
    let mut stream = Framed::new(stream, LinesCodec::new());
    // 按帧发送的， LinesCodec 会在每行末尾加上 \n
    stream
        .send("Welcome to the chat! Please enter your username:")
        .await?;

    let username = match stream.next().await {
        Some(Ok(username)) => username,
        Some(Err(e)) => {
            warn!("Failed to receive username from {}: {}", addr, e);
            return Err(e.into());
        }
        None => {
            warn!("Client {} disconnected before sending username", addr);
            return Ok(());
        }
    };

    let mut peer = state.add(addr, username, stream).await;

    // notify others that a new peer has joined
    let message = Arc::new(Message::user_joined(&peer.username));
    info!("\x1b[32m🟢 用户加入: {:?}\x1b[0m", message);
    state.broadcast(addr, message).await;

    while let Some(line) = peer.stream.next().await {
        let line = match line {
            Ok(line) => line,
            Err(err) => {
                warn!("Failed to receive message from {}: {}", addr, err);
                break;
            }
        };

        let message = Arc::new(Message::chat(&peer.username, line));
        info!("\x1b[34m💬 聊天消息: {:?}\x1b[0m", message);
        state.broadcast(addr, message).await;
    }

    // when while loop exit, peer has left the chat or line reading failed
    // remove peer from state
    state.peers.remove(&addr);

    // notify others that peer has left the chat
    let message = Arc::new(Message::user_left(&peer.username));
    info!("\x1b[31m🔴 用户离开: {:?}\x1b[0m", message);
    state.broadcast(addr, message).await;

    Ok(())
}

impl State {
    async fn broadcast(&self, addr: SocketAddr, message: Arc<Message>) {
        for peer in self.peers.iter() {
            if peer.key() == &addr {
                continue;
            }
            if let Err(e) = peer.value().send(message.clone()).await {
                warn!("Failed to send message to {}: {}", peer.key(), e);
                // Remove the peer from the state if it's no longer reachable
                self.peers.remove(peer.key());
            }
        }
    }

    async fn add(
        &self,
        addr: SocketAddr,
        username: String,
        stream: Framed<TcpStream, LinesCodec>,
    ) -> Peer {
        let (tx, mut rx) = mpsc::channel(MAX_MESSAGES);
        self.peers.insert(addr, tx);

        // split the stream into a sender and a receiver
        let (mut stream_sender, stream_receiver) = stream.split();

        // receive messages from others, and send them to the client
        tokio::spawn(async move {
            while let Some(message) = rx.recv().await {
                if let Err(e) = stream_sender.send(message.to_string()).await {
                    warn!("Failed to send message to {}: {}", addr, e);
                    break;
                }
            }
        });

        // return peer
        Peer {
            username,
            stream: stream_receiver,
        }
    }
}

impl Message {
    fn user_joined(username: &str) -> Self {
        let content = format!("{} has joined the chat", username);
        Self::UserJoined(content)
    }

    fn user_left(username: &str) -> Self {
        let content = format!("{} has left the chat", username);
        Self::UserLeft(content)
    }

    fn chat(sender: impl Into<String>, content: impl Into<String>) -> Self {
        Self::Chat {
            sender: sender.into(),
            content: content.into(),
        }
    }
}

impl fmt::Display for Message {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Message::UserJoined(content) => write!(f, "\x1b[32m🟢 [系统] {}\x1b[0m", content),
            Message::UserLeft(content) => write!(f, "\x1b[31m🔴 [系统] {}\x1b[0m", content),
            Message::Chat { sender, content } => {
                write!(f, "\x1b[34m[{}]\x1b[0m {}", sender, content)
            }
        }
    }
}

```

这项优化主要集中在提升程序的**可观察性（Observability）和终端用户体验（UX）**，而非性能。

它通过两方面的修改实现：

1. **服务器端日志增强**：在 `handle_client` 函数中，针对用户加入、离开和发送消息等关键事件，增加了带有 **ANSI 颜色代码和表情符号**的 `info!` 日志。这使得在监控服务器后台时，不同类型的事件一目了然，极大地提升了调试和监控的效率。
2. **客户端显示美化**：修改了 `Message` 类型的 `Display` trait 实现，将颜色和格式化信息（如 `[系统]` 标签）直接编码到发送给客户端的字符串中。这样，用户在自己的终端（如 `telnet`）里看到的聊天内容不再是单调的文本，而是**色彩分明、重点突出**的富文本信息，显著改善了可读性和交互体验。

### 运行结果

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 9m 11.7s 
➜ cargo run --example chat
   Compiling rust-ecosystem-learning v0.1.0 (/Users/qiaopengjun/Code/Rust/rust-ecosystem-learning)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.32s
     Running `target/debug/examples/chat`
2025-07-13T05:27:16.563493Z  INFO chat: Listening on 0.0.0.0:8080
2025-07-13T05:27:20.761150Z  INFO chat: Accepted connection from 127.0.0.1:53856
2025-07-13T05:27:24.280270Z  INFO chat: 🟢 用户加入: UserJoined("qiao has joined the chat")
2025-07-13T05:27:41.581466Z  INFO chat: Accepted connection from 127.0.0.1:53946
2025-07-13T05:27:44.969750Z  INFO chat: 🟢 用户加入: UserJoined("Alice has joined the chat")
2025-07-13T05:27:49.629633Z  INFO chat: Accepted connection from 127.0.0.1:53975
2025-07-13T05:27:52.534169Z  INFO chat: 🟢 用户加入: UserJoined("Bob has joined the chat")
2025-07-13T05:27:57.729499Z  INFO chat: 💬 聊天消息: Chat { sender: "Bob", content: "hello world" }
2025-07-13T05:28:30.574583Z  WARN chat: Failed to receive message from 127.0.0.1:53975: Unable to decode input as UTF8
2025-07-13T05:28:30.574810Z  INFO chat: 🔴 用户离开: UserLeft("Bob has left the chat")

```

![image-20250713132910092](/images/image-20250713132910092.png)

## 🔍 调试利器：使用 tokio-console

## 洞察应用内部

### 添加依赖

```bash
cargo add console_subscriber --dev   
```

#### build

```bash
RUSTFLAGS="--cfg tokio_unstable" cargo build
```

### 安装 tokio-console

```bash
cargo install --locked tokio-console
```

### 查看版本信息

```bash
tokio-console --version
tokio-console 0.1.13
```

#### 查看帮助信息

```bash
tokio-console -h
The Tokio console: a debugger for async Rust.

Usage: tokio-console [OPTIONS] [TARGET_ADDR] [COMMAND]

Commands:
  gen-config      Generate a `console.toml` config file with the default configuration values, overridden by any provided command-line arguments
  gen-completion  Generate shell completions
  help            Print this message or the help of the given subcommand(s)

Arguments:
  [TARGET_ADDR]  The address of a console-enabled process to connect to

Options:
      --log <LOG_FILTER>                         Log level filter for the console's internal diagnostics [env: RUST_LOG=]
  -W, --warn <WARNINGS>...                       Enable lint warnings [default: self-wakes lost-waker never-yielded auto-boxed-future large-future]
                                                 [possible values: self-wakes, lost-waker, never-yielded, auto-boxed-future, large-future]
  -A, --allow <ALLOW_WARNINGS>...                Allow lint warnings
      --log-dir <LOG_DIRECTORY>                  Path to a directory to write the console's internal logs to
      --lang <LANG>                              Overrides the terminal's default language [env: LANG=]
      --ascii-only <ASCII_ONLY>                  Explicitly use only ASCII characters [possible values: true, false]
      --no-colors                                Disable ANSI colors entirely
      --colorterm <truecolor>                    Overrides the value of the `COLORTERM` environment variable [env: COLORTERM=truecolor] [possible values:
                                                 24bit, truecolor]
      --palette <PALETTE>                        Explicitly set which color palette to use [possible values: 8, 16, 256, all, off]
      --no-duration-colors <COLOR_DURATIONS>     Disable color-coding for duration units [possible values: true, false]
      --no-terminated-colors <COLOR_TERMINATED>  Disable color-coding for terminated tasks [possible values: true, false]
      --retain-for <RETAIN_FOR>                  How long to continue displaying completed tasks and dropped resources after they have been closed
  -h, --help                                     Print help (see more with '--help')
  -V, --version                                  Print version
```

注意：只能设置一次全局 subscriber。

```rust
// let layer = Layer::new().with_filter(LevelFilter::INFO);
// tracing_subscriber::registry().with(layer).init();
console_subscriber::init();
```

### 运行 chat

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 12.3s 
➜ RUSTFLAGS="--cfg tokio_unstable" cargo build
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.10s

rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ target/debug/examples/chat

thread 'main' panicked at /Users/qiaopengjun/.cargo/registry/src/index.crates.io-1949cf8c6b5b557f/tracing-subscriber-0.3.19/src/util.rs:91:14:
failed to set global default subscriber: SetGlobalDefaultError("a global default trace dispatcher has already been set")
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace

rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ RUSTFLAGS="--cfg tokio_unstable" cargo run --example chat
   Compiling rust-ecosystem-learning v0.1.0 (/Users/qiaopengjun/Code/Rust/rust-ecosystem-learning)
warning: unused import: `level_filters::LevelFilter`
  --> examples/chat.rs:11:21
   |
11 | use tracing::{info, level_filters::LevelFilter, warn};
   |                     ^^^^^^^^^^^^^^^^^^^^^^^^^^
   |
   = note: `#[warn(unused_imports)]` on by default

warning: unused imports: `fmt::Layer`, `layer::SubscriberExt`, and `util::SubscriberInitExt`
  --> examples/chat.rs:12:38
   |
12 | ...::{Layer as _, fmt::Layer, layer::SubscriberExt, util::SubscriberInitExt};
   |                   ^^^^^^^^^^  ^^^^^^^^^^^^^^^^^^^^  ^^^^^^^^^^^^^^^^^^^^^^^

warning: unused import: `Layer`
  --> examples/chat.rs:12:26
   |
12 | use tracing_subscriber::{Layer as _, fmt::Layer, layer::SubscriberExt, util::SubscriberInit...
   |                          ^^^^^

warning: `rust-ecosystem-learning` (example "chat") generated 3 warnings (run `cargo fix --example "chat"` to apply 2 suggestions)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.46s
     Running `target/debug/examples/chat`
```

#### client 运行交互

![image-20250713140652642](/images/image-20250713140652642.png)

#### tokio-console

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ tokio-console
```

![image-20250713140727146](/images/image-20250713140727146.png)

查看 task 详情

![image-20250713140517785](/images/image-20250713140517785.png)

### 完整代码

```rust
use std::{fmt, net::SocketAddr, sync::Arc};

use anyhow::Result;
use dashmap::DashMap;
use futures::{SinkExt, StreamExt, stream::SplitStream};
use tokio::{
    net::{TcpListener, TcpStream},
    sync::mpsc,
};
use tokio_util::codec::{Framed, LinesCodec};
use tracing::{info, level_filters::LevelFilter, warn};
use tracing_subscriber::{Layer as _, fmt::Layer, layer::SubscriberExt, util::SubscriberInitExt};

const MAX_MESSAGES: usize = 128;

#[derive(Debug, Default)]
struct State {
    peers: DashMap<SocketAddr, mpsc::Sender<Arc<Message>>>,
}

#[derive(Debug)]
struct Peer {
    username: String,
    stream: SplitStream<Framed<TcpStream, LinesCodec>>,
}

#[derive(Debug)]
enum Message {
    UserJoined(String),
    UserLeft(String),
    Chat { sender: String, content: String },
}

#[tokio::main]
async fn main() -> Result<()> {
    let layer = Layer::new().with_filter(LevelFilter::INFO);
    tracing_subscriber::registry().with(layer).init();
    // console_subscriber::init();

    let addr = "0.0.0.0:8080";
    let listener = TcpListener::bind(addr).await?;
    info!("Listening on {}", addr);

    let state = Arc::new(State::default());

    loop {
        let (stream, addr) = listener.accept().await?;
        info!("Accepted connection from {}", addr);
        let state_cloned = state.clone();
        tokio::spawn(async move {
            if let Err(e) = handle_client(state_cloned, addr, stream).await {
                warn!("Failed to handle client {}: {}", addr, e);
            }
        });
    }
}

async fn handle_client(state: Arc<State>, addr: SocketAddr, stream: TcpStream) -> Result<()> {
    let mut stream = Framed::new(stream, LinesCodec::new());
    // 按帧发送的， LinesCodec 会在每行末尾加上 \n
    stream
        .send("Welcome to the chat! Please enter your username:")
        .await?;

    let username = match stream.next().await {
        Some(Ok(username)) => username,
        Some(Err(e)) => {
            warn!("Failed to receive username from {}: {}", addr, e);
            return Err(e.into());
        }
        None => {
            warn!("Client {} disconnected before sending username", addr);
            return Ok(());
        }
    };

    let mut peer = state.add(addr, username, stream).await;

    // notify others that a new peer has joined
    let message = Arc::new(Message::user_joined(&peer.username));
    info!("\x1b[32m🟢 用户加入: {:?}\x1b[0m", message);
    state.broadcast(addr, message).await;

    while let Some(line) = peer.stream.next().await {
        let line = match line {
            Ok(line) => line,
            Err(err) => {
                warn!("Failed to receive message from {}: {}", addr, err);
                break;
            }
        };

        let message = Arc::new(Message::chat(&peer.username, line));
        info!("\x1b[34m💬 聊天消息: {:?}\x1b[0m", message);
        state.broadcast(addr, message).await;
    }

    // when while loop exit, peer has left the chat or line reading failed
    // remove peer from state
    state.peers.remove(&addr);

    // notify others that peer has left the chat
    let message = Arc::new(Message::user_left(&peer.username));
    info!("\x1b[31m🔴 用户离开: {:?}\x1b[0m", message);
    state.broadcast(addr, message).await;

    Ok(())
}

impl State {
    async fn broadcast(&self, addr: SocketAddr, message: Arc<Message>) {
        for peer in self.peers.iter() {
            if peer.key() == &addr {
                continue;
            }
            if let Err(e) = peer.value().send(message.clone()).await {
                warn!("Failed to send message to {}: {}", peer.key(), e);
                // Remove the peer from the state if it's no longer reachable
                self.peers.remove(peer.key());
            }
        }
    }

    async fn add(
        &self,
        addr: SocketAddr,
        username: String,
        stream: Framed<TcpStream, LinesCodec>,
    ) -> Peer {
        let (tx, mut rx) = mpsc::channel(MAX_MESSAGES);
        self.peers.insert(addr, tx);

        // split the stream into a sender and a receiver
        let (mut stream_sender, stream_receiver) = stream.split();

        // receive messages from others, and send them to the client
        tokio::spawn(async move {
            while let Some(message) = rx.recv().await {
                if let Err(e) = stream_sender.send(message.to_string()).await {
                    warn!("Failed to send message to {}: {}", addr, e);
                    break;
                }
            }
        });

        // return peer
        Peer {
            username,
            stream: stream_receiver,
        }
    }
}

impl Message {
    fn user_joined(username: &str) -> Self {
        let content = format!("{username} has joined the chat");
        Self::UserJoined(content)
    }

    fn user_left(username: &str) -> Self {
        let content = format!("{username} has left the chat");
        Self::UserLeft(content)
    }

    fn chat(sender: impl Into<String>, content: impl Into<String>) -> Self {
        Self::Chat {
            sender: sender.into(),
            content: content.into(),
        }
    }
}

impl fmt::Display for Message {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Message::UserJoined(content) => write!(f, "\x1b[32m🟢 [系统] {content}\x1b[0m"),
            Message::UserLeft(content) => write!(f, "\x1b[31m🔴 [系统] {content}\x1b[0m"),
            Message::Chat { sender, content } => {
                write!(f, "\x1b[34m[{sender}]\x1b[0m {content}")
            }
        }
    }
}

```

## 🔬 并发“照妖镜”：用 Loom

## 捕捉看不见的竞态条件

Loom 是一款用于并发 Rust 代码的测试工具。它会多次运行同一个测试，并在 C11 内存模型下排列该测试可能出现的并发执行情况。它使用状态缩减技术来避免组合爆炸。

```rust
use loom::sync::Arc;
use loom::sync::atomic::AtomicUsize;
use loom::sync::atomic::Ordering::{Acquire, Relaxed, Release};
use loom::thread;

#[test]
#[should_panic]
fn buggy_concurrent_inc() {
    loom::model(|| {
        let num = Arc::new(AtomicUsize::new(0));

        let ths: Vec<_> = (0..2)
            .map(|_| {
                let num = num.clone();
                thread::spawn(move || {
                    let curr = num.load(Acquire);
                    // This is a bug! this is an not atomic operation
                    // 这是一个竞态条件的例子：
                    // 假设 num 初始为 0
                    // 线程1: curr1 = num.load()  // curr1 = 0
                    // 线程2: curr2 = num.load()  // curr2 = 0
                    // 线程1: num.store(curr1 + 1)  // num = 1
                    // 线程2: num.store(curr2 + 1)  // num = 1（覆盖了线程1的结果）
                    // 最终 num 的值是 1，而不是 2
                    num.store(curr + 1, Release);

                    // fix
                    // num.fetch_add(1, Release);
                })
            })
            .collect();

        for th in ths {
            th.join().unwrap();
        }

        assert_eq!(2, num.load(Relaxed));
    });
}

```

### 测试

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ cargo test buggy_concurrent_inc 
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.33s
     Running unittests src/lib.rs (target/debug/deps/rust_ecosystem_learning-63956b71f8669a63)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 1 filtered out; finished in 0.00s

     Running tests/loom.rs (target/debug/deps/loom-428b6b7681434b7f)

running 1 test
test buggy_concurrent_inc - should panic ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.01s


rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ cargo test -- buggy_concurrent_inc
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.21s
     Running unittests src/lib.rs (target/debug/deps/rust_ecosystem_learning-63956b71f8669a63)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 1 filtered out; finished in 0.00s

     Running tests/loom.rs (target/debug/deps/loom-428b6b7681434b7f)

running 1 test
test buggy_concurrent_inc - should panic ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

   Doc-tests rust_ecosystem_learning

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s


rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ cargo nextest run buggy_concurrent_inc
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.14s
────────────
 Nextest run ID aa7d6164-b455-4b08-97da-6e6ad7b5ab46 with nextest profile: default
    Starting 1 test across 2 binaries (1 test skipped)
        PASS [   0.012s] rust-ecosystem-learning::loom buggy_concurrent_inc
────────────
     Summary [   0.012s] 1 test run: 1 passed, 1 skipped

rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ cargo nextest run -- buggy_concurrent_inc
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.14s
────────────
 Nextest run ID 368148d9-f7bc-48de-9953-0933de5d3a66 with nextest profile: default
    Starting 1 test across 2 binaries (1 test skipped)
        PASS [   0.012s] rust-ecosystem-learning::loom buggy_concurrent_inc
────────────
     Summary [   0.012s] 1 test run: 1 passed, 1 skipped

```

## 🏁 全文总结与未来展望

恭喜你坚持到了最后！通过本次实战，我们不仅成功构建了一个基于 Tokio 的异步 TCP 聊天服务器，更重要的是，我们深入探索了 Rust 强大的异步生态系统。

回顾一下，我们掌握了：

1. **核心构建**：使用 `tokio` 创建异步任务，处理网络流，并通过 `mpsc` channel 和 `dashmap` 实现多客户端间的状态同步与通信。
2. **体验优化**：利用 `tracing` 和 ANSI 颜色代码，为服务器和客户端提供了直观、美观的日志与信息展示。
3. **高级调试**：学会了如何集成 `tokio-console`，实时监控应用的异步任务、资源使用情况，极大地提升了调试效率。
4. **并发测试**：初识了 `loom` 的威力，它能帮助我们在开发阶段就发现并修复复杂的并发 bug 和数据竞争问题。

从一个简单的聊天程序出发，我们触及了网络编程、并发管理、应用可观察性和正确性验证等多个关键领域。希望这篇文章能成为你深入 Rust 异步世界的坚实一步。接下来，不妨尝试为这个项目增加更多功能，比如私聊、房间、持久化存储等，继续你的 Rust 生态探索之旅吧！

## 参考

- <https://docs.rs/tokio-util/latest/tokio_util/>
- <https://crates.io/crates/tokio-util>
- <https://docs.rs/tokio-util/latest/tokio_util/codec/struct.LinesCodec.html>
- <https://docs.rs/futures/latest/futures/>
- <https://docs.rs/tokio-stream/latest/tokio_stream/>
- <https://tokio.rs/>
- <https://github.com/tokio-rs/console>
- <https://crates.io/crates/tokio-console>
- <https://github.com/tokio-rs/console/tree/main/console-subscriber>
- <https://doc.rust-lang.org/cargo/reference/config.html>
- <https://github.com/tokio-rs/loom>
