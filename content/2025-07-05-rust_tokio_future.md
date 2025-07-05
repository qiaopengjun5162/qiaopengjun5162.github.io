+++
title = "Rust 异步编程实践：从 Tokio 基础到阻塞任务处理模式"
description = "Rust 异步编程实践：从 Tokio 基础到阻塞任务处理模式"
date = 2025-07-05T09:44:17Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust", "Tokio", "异步编程"]
+++

<!-- more -->

# Rust 异步编程实践：从 Tokio 基础到阻塞任务处理模式

在 Rust 异步编程的实践中，许多开发者在熟练使用 `#[tokio::main]` 后，会遇到一个典型挑战：当异步任务中混入耗时的阻塞操作（如同步文件IO、CPU密集计算）时，整个 Tokio 运行时的性能会急剧下降，甚至完全卡死。

异步世界追求的是高效与非阻塞，但现实中的任务却往往包含无法避免的同步与阻塞。如何在优雅的 Tokio 异步模型中，安放这些“不和谐”的阻塞代码，是每一位 Rust Coder 从入门到进阶的必经之路。

本文将通过 9 个层层递进的代码示例，带你从 Tokio 的基本运行时（Runtime）出发，亲历 `std::thread` 的并发世界，直面在异步环境中执行阻塞代码的“性能灾难”，并最终掌握使用 MPSC 通道将阻塞任务外包给专用工作者线程（Worker）的最佳实践。让我们一同揭开 Tokio 背后线程调度的神秘面纱，构建真正高效、健壮的 Rust 并发应用！

本文深入探讨了 Rust Tokio 异步编程框架的核心概念与实践，重点聚焦于如何正确处理异步环境中的阻塞任务。文章从 `#[tokio::main]` 宏的背后机制出发，通过对比 `std::thread`，逐步揭示了直接在 Tokio 运行时上执行同步阻塞代码（如 `thread::sleep`）所导致的性能陷阱。核心内容详细阐述并演示了业界标准的解决方案：**通过 `tokio::sync::mpsc` 通道，将耗时的阻塞任务从 Tokio 的异步任务中剥离，并委派给一个或多个专用的同步工作者线程进行处理**。此外，文章还分析了在此模式下因不当使用 `join()` 可能导致的程序死锁问题，为开发者在实践中构建高响应性、高吞吐量的 Rust 并发程序提供了清晰的路线图和避坑指南。

## 深入引擎室：Tokio 如何

## “运行”一个 Future？

Tokio 的其中一个核心组成部分就是 runtime。当有一个 Future 进来的时候， Future 会包裹成一个 task，放到 Tokio 的 **run queue** 里面，Tokio 的 Executor 会把 run queue 里面的任务拿出来**执行一次 poll**，**poll 的结果**要么是得到一个结果 (Ready)，要么是 pending。如果是 pending 的状态，**任务会确保一个 Waker 被注册到它所等待的资源上**，并等待这个**Waker 发出信号**来唤醒自己。

Tokio 的核心是它的 **`Runtime`**。当一个 `Future` 通过 `tokio::spawn` 提交时，它会被包装成一个**任务 (Task)** 并交给 `Runtime` 的**调度器 (Scheduler)**。

调度器会将这个任务放入一个**可运行队列 (run queue)** 中。`Runtime` 的**工作线程 (Worker Thread)** 会从队列里取出任务并调用其 **`poll`** 方法。一次 `poll` 会产生两种结果：

1. **`Poll::Ready(结果)`**: 表示任务已经执行完毕，可以从中获取最终结果。
2. **`Poll::Pending`**: 表示任务此刻无法完成（例如，正在等待网络数据）。此时，任务会确保将一个 **`Waker`** 对象注册到底层的资源上，然后任务会暂停执行，等待被唤醒。

当该资源就绪后（例如，数据已到达），它会调用 `Waker` 的 **`wake()`** 方法来通知调度器。调度器随即将这个任务重新放回可运行队列，等待下一次被 `poll`。

runtime 是 Tokio 下一个很重要的部分。block_on 是 runtime 一个非常重要的功能。

## 实操

### 示例1：基础Tokio运行时

```rust
#[tokio::main]
async fn main() {
    let a = 10;
    let b = 20;
    println!("{} + {} = {}", a, b, a + b);
}

```

这段代码使用了 `#[tokio::main]` 宏，它将一个异步的 `main` 函数转化为标准的同步 `main` 函数，并自动为你启动和管理 Tokio 这个业界流行的异步运行时（runtime）。`async fn main()` 定义了一个异步的主函数入口，虽然其中的代码本身是同步的（定义了两个整数 a 和 b，然后打印它们的和），但 `#[tokio::main]` 的存在意味着这个程序是在 Tokio 异步环境的支持下运行的，这为后续在 `main` 函数中添加真正的异步操作（如网络请求或文件读写）提供了必要的基础。

### 运行输出1

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 4.6s 
➜ cargo expand --example tokio1
    Checking rust-ecosystem-learning v0.1.0 (/Users/qiaopengjun/Code/Rust/rust-ecosystem-learning)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.33s

#![feature(prelude_import)]
#[prelude_import]
use std::prelude::rust_2024::*;
#[macro_use]
extern crate std;
fn main() {
    let body = async {
        let a = 10;
        let b = 20;
        {
            ::std::io::_print(format_args!("{0} + {1} = {2}\n", a, b, a + b));
        };
    };
    #[allow(
        clippy::expect_used,
        clippy::diverging_sub_expression,
        clippy::needless_return
    )]
    {
        return tokio::runtime::Builder::new_multi_thread()
            .enable_all()
            .build()
            .expect("Failed building the Runtime")
            .block_on(body);
    }
}
```

block_on 会运行一个 Future ，直到这个 Future 返回一个值。

### 示例 2：线程阻塞操作

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("hi number {} from the first thread", i);
        }
    });

    for i in 1..5 {
        println!("hi number {} from the main thread", i);
    }

    handle.join().unwrap();
}

```

这段代码通过 `use std::thread;` 引入了 Rust 的标准线程库，并在 `main` 函数中创建了一个新的子线程来并发执行任务。`thread::spawn` 启动了一个新线程，该线程负责打印从1到9的数字；与此同时，主线程继续执行自己的循环，打印从1到4的数字。由于两个线程是并发运行的，它们的输出会交错在一起，顺序不固定。最后，`handle.join().unwrap()` 会使主线程等待，直到 `spawn` 创建的子线程执行完毕后，整个程序才会结束，以此确保子线程的任务能够完整执行。

### 运行输出2

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ cargo run --example tokio1
   Compiling rust-ecosystem-learning v0.1.0 (/Users/qiaopengjun/Code/Rust/rust-ecosystem-learning)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.88s
     Running `target/debug/examples/tokio1`
hi number 1 from the main thread
hi number 2 from the main thread
hi number 3 from the main thread
hi number 4 from the main thread
hi number 1 from the first thread
hi number 2 from the first thread
hi number 3 from the first thread
hi number 4 from the first thread
hi number 5 from the first thread
hi number 6 from the first thread
hi number 7 from the first thread
hi number 8 from the first thread
hi number 9 from the first thread
```

### 示例3

```bash
use std::thread;

fn main() {
    let handle = thread::spawn(|| println!("hello from the thread"));

    handle.join().unwrap();
}
```

这段代码演示了 Rust 中一个最基础的多线程操作：它通过 `thread::spawn` 创建并启动了一个新的子线程，该子线程唯一的任务就是打印出 "hello from the thread" 这条消息。与此同时，主线程会执行到 `handle.join().unwrap()` 这一行，这个方法会暂停主线程的执行，并等待子线程运行结束后，整个程序才会最终退出，以此确保子线程的消息能够被成功打印出来。

### 运行输出3

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ cargo run --example tokio1
   Compiling rust-ecosystem-learning v0.1.0 (/Users/qiaopengjun/Code/Rust/rust-ecosystem-learning)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.68s
     Running `target/debug/examples/tokio1`
hello from the thread
```

### 示例4

```rust
use std::thread;

use tokio::runtime::Builder;

fn main() {
    let handle = thread::spawn(|| {
        // execute future ?
        let rt = Builder::new_current_thread().enable_all().build().unwrap();
        rt.block_on(async {
            println!("Hello, world!");
        });
    });

    handle.join().unwrap();
}

```

这段代码的核心是演示了如何在 Rust 中将**原生线程**与**异步编程**进行结合：它首先通过 `std::thread::spawn` 创建了一个完全独立的操作系统线程，然后在这个新线程的内部，又手动构建并启动了一个 Tokio 的单线程异步运行时（runtime），并命令这个运行时通过 `block_on` 方法去执行一个打印 "Hello, world!" 的异步任务。最后，程序的主线程会调用 `handle.join()` 来暂停并等待，直到那个新创建的线程完成了它内部所有的工作（包括搭建和运行异步环境）之后，整个程序才会最终结束。

### 运行输出4

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ cargo run --example tokio1
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.08s
     Running `target/debug/examples/tokio1`
Hello, world!

```

### 示例5

```rust
use std::thread;
use std::time::Duration;
use tokio::fs;
use tokio::runtime::Builder;

fn main() {
    let handle = thread::spawn(|| {
        // execute future ?
        let rt = Builder::new_current_thread().enable_all().build().unwrap();

        rt.spawn(async {
            println!("Future 1 executed on thread");
            let content = fs::read_to_string("Cargo.toml").await.unwrap();
            println!("Content length: {}", content.len());
        });

        rt.spawn(async {
            println!("Future 2 executed on thread");
            let ret = expensive_blocking_task("Future 2".to_string());
            println!("Result: {}", ret);
        });

        rt.block_on(async {
            println!("Hello, world!");
        });
    });

    handle.join().unwrap();
}

fn expensive_blocking_task(s: String) -> String {
    thread::sleep(Duration::from_millis(800));
    blake3::hash(s.as_bytes()).to_string()
}
```

这段代码在一个新创建的独立操作系统线程中，构建并运行了一个单线程的 Tokio 异步运行时，旨在演示异步任务与阻塞代码的交互。它通过 `rt.spawn` 向该运行时提交了两个任务：一个是使用 `await` 执行真正的**非阻塞**文件读取，能在等待时让出执行权；而另一个则调用了包含 `thread::sleep` 的普通同步函数，这是一个**阻塞**操作。此代码的关键点在于，当第二个任务执行阻塞函数时，它会冻结整个单线程运行时，导致第一个非阻塞任务也无法取得进展，这清晰地展示了在异步环境中执行阻塞代码会破坏其并发优势的核心问题。最后，`rt.block_on` 负责启动运行时并驱动所有被提交的任务执行，而主线程则通过 `handle.join` 等待这个子线程完成全部工作。

### 运行输出 5

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ cargo run --example tokio1
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.08s
     Running `target/debug/examples/tokio1`
Hello, world!
```

### 示例 6

```rust
use std::thread;
use std::time::Duration;

use tokio::{fs, runtime::Builder, time::sleep};

fn main() {
    let handle = thread::spawn(|| {
        // execute future ?
        let rt = Builder::new_current_thread().enable_all().build().unwrap();

        rt.spawn(async {
            println!("Future 1 executed on thread");
            let content = fs::read_to_string("Cargo.toml").await.unwrap();
            println!("Content length: {}", content.len());
        });

        rt.spawn(async {
            println!("Future 2 executed on thread");
            let ret = expensive_blocking_task("Future 2".to_string());
            println!("Result: {}", ret);
        });

        rt.block_on(async {
            sleep(Duration::from_millis(900)).await;
        });
    });

    handle.join().unwrap();
}

fn expensive_blocking_task(s: String) -> String {
    thread::sleep(Duration::from_millis(800));
    blake3::hash(s.as_bytes()).to_string()
}
```

这段代码在一个独立的操作系统线程中构建了一个单线程 Tokio 异步运行时，用以鲜明地对比 **异步操作** 与 **阻塞操作** 的根本区别。代码向运行时提交了两个任务：一个是通过 `.await` 执行的非阻塞文件读取，另一个是调用了包含 `thread::sleep` 的同步阻塞函数。其核心在于，当第二个任务执行并调用阻塞的 `thread::sleep` 时，它会彻底**冻结**当前唯一的执行线程，导致运行时上的所有其他异步任务（包括文件读取和 `block_on` 中等待的异步计时器）都无法取得任何进展，这清晰地揭示了在异步环境中一个微小的阻塞调用便足以瘫痪整个事件循环的并发能力，强调了在异步代码中必须始终使用非阻塞 API 的重要性。

### 运行输出 6

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ cargo run --example tokio1
   Compiling rust-ecosystem-learning v0.1.0 (/Users/qiaopengjun/Code/Rust/rust-ecosystem-learning)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.66s
     Running `target/debug/examples/tokio1`
Future 1 executed on thread
Future 2 executed on thread
Result: 13502a29bf9ed92c70e938e1398d835d414a4f89812bb147bf76c22bd7b78b7e
Content length: 691
```

### 示例 7

```rust
// tokio async task send message to worker for expensive blocking task

use std::{thread, time::Duration};

use anyhow::Result;
use tokio::sync::mpsc;

#[tokio::main]
async fn main() -> Result<()> {
    let (tx, rx) = mpsc::channel(32);
    worker(rx);

    tokio::spawn(async move {
        loop {
            tx.send("Future 1".to_string()).await?;
        }
        #[allow(unreachable_code)]
        Ok::<(), anyhow::Error>(())
    });

    Ok(())
}

fn worker(mut rx: mpsc::Receiver<String>) -> thread::JoinHandle<()> {
    thread::spawn(move || {
        while let Some(s) = rx.blocking_recv() {
            let ret = expensive_blocking_task(s);
            println!("Worker got result: {}", ret);
        }
    })
}

fn expensive_blocking_task(s: String) -> String {
    thread::sleep(Duration::from_millis(800));
    blake3::hash(s.as_bytes()).to_string()
}

```

这段代码演示了在 Tokio 异步程序中处理耗时阻塞任务的核心模式：**将阻塞工作外包给一个专用的同步线程**。它首先创建一个 `mpsc` 异步通道作为**通信桥梁** 🌉，接着一个 `tokio::spawn` 启动的异步任务不断地将工作消息发送到通道中。与此同时，一个通过 `std::thread::spawn` 创建的独立**同步工作者线程 (worker)**，则使用 `blocking_recv` 方法**阻塞地**等待并接收这些消息。一旦收到任务，该工作者线程就会在自己的线程里执行包含大量计算和 `thread::sleep` 的阻塞函数，这个过程完全不会冻结或影响主程序的 Tokio 异步运行时，从而实现了异步与同步代码的高效隔离与协作，确保了异步应用的高响应性。

### 运行输出 7

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ cargo run --example tokio2
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.08s
     Running `target/debug/examples/tokio2`

```

### 示例 8

```rust
// tokio async task send message to worker for expensive blocking task

use std::{thread, time::Duration};

use anyhow::Result;
use tokio::sync::mpsc;

#[tokio::main]
async fn main() -> Result<()> {
    let (tx, rx) = mpsc::channel(32);
    let handler = worker(rx);

    tokio::spawn(async move {
        loop {
            tx.send("Future 1".to_string()).await?;
        }
        #[allow(unreachable_code)]
        Ok::<(), anyhow::Error>(())
    });

    handler.join().unwrap();

    Ok(())
}

fn worker(mut rx: mpsc::Receiver<String>) -> thread::JoinHandle<()> {
    thread::spawn(move || {
        while let Some(s) = rx.blocking_recv() {
            let ret = expensive_blocking_task(s);
            println!("Worker got result: {}", ret);
        }
    })
}

fn expensive_blocking_task(s: String) -> String {
    thread::sleep(Duration::from_millis(800));
    blake3::hash(s.as_bytes()).to_string()
}

```

这段代码展示了将阻塞任务外包给专用同步线程的模式，但引入了一个会**导致程序永远无法结束**的逻辑。与之前的版本类似，它创建了一个 `mpsc` 通道，让一个 Tokio 异步任务不停地发送消息，同时一个独立的同步工作者线程（worker）通过 `blocking_recv` 接收并处理这些阻塞任务。关键的不同在于 `main` 函数末尾的 `handler.join().unwrap()`，它会使主线程**等待**工作者线程执行完毕，然而工作者线程的 `while` 循环只有在发送端 `tx` 被销毁后才会结束，但异步任务中的 `tx` 处在一个无限循环里永远不会被销毁，这就造成了主线程和工作者线程相互永久等待的**死锁** 🔒，程序因此会一直挂起。

### 运行输出 8

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ cargo run --example tokio2
   Compiling rust-ecosystem-learning v0.1.0 (/Users/qiaopengjun/Code/Rust/rust-ecosystem-learning)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.11s
     Running `target/debug/examples/tokio2`
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
Worker got result: 4a3d72dbb01bfdec032bb3fc7ca8d9e7d1c7583fce147a0cfe1b92d3199bb57f
^C
```

两个线程之间是如何同步数据的

### 示例 9

```rust
// tokio async task send message to worker for expensive blocking task

use std::{thread, time::Duration};

use anyhow::Result;
use tokio::sync::mpsc;

#[tokio::main]
async fn main() -> Result<()> {
    let (tx, rx) = mpsc::channel(32);
    let handler = worker(rx);

    tokio::spawn(async move {
        let mut i = 0;
        loop {
            i += 1;
            println!("Send task {i}!");
            tx.send(format!("Task {i}")).await?;
        }
        #[allow(unreachable_code)]
        Ok::<(), anyhow::Error>(())
    });

    handler.join().unwrap();

    Ok(())
}

fn worker(mut rx: mpsc::Receiver<String>) -> thread::JoinHandle<()> {
    thread::spawn(move || {
        while let Some(s) = rx.blocking_recv() {
            let ret = expensive_blocking_task(s);
            println!("Worker got result: {}", ret);
        }
    })
}

fn expensive_blocking_task(s: String) -> String {
    thread::sleep(Duration::from_millis(800));
    blake3::hash(s.as_bytes()).to_string()
}

```

这段代码演示了将阻塞任务分发给专用工作者线程的模式，但其设计会导致程序无限运行而无法正常退出。代码中，一个 `tokio` 异步任务在一个无限循环里不断地生成并发送带编号的任务（如 "Task 1", "Task 2"）到一个`mpsc`通道中。另一个独立的同步工作者线程则通过 `blocking_recv` 循环接收这些任务，并调用耗时的阻塞函数进行处理。问题的关键在于 `main` 函数最后的 `handler.join()`，它会等待工作者线程结束，但由于异步任务的无限循环导致通道的发送端永远不会被关闭，工作者线程的接收循环也就永远不会终止，最终造成主线程和工作者线程相互永久等待的死锁局面，使程序挂起。

### 运行输出 9

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 16.2s 
➜ cargo run --example tokio2
   Compiling rust-ecosystem-learning v0.1.0 (/Users/qiaopengjun/Code/Rust/rust-ecosystem-learning)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.08s
     Running `target/debug/examples/tokio2`
Send task 1!
Send task 2!
Send task 3!
Send task 4!
Send task 5!
Send task 6!
Send task 7!
Send task 8!
Send task 9!
Send task 10!
Send task 11!
Send task 12!
Send task 13!
Send task 14!
Send task 15!
Send task 16!
Send task 17!
Send task 18!
Send task 19!
Send task 20!
Send task 21!
Send task 22!
Send task 23!
Send task 24!
Send task 25!
Send task 26!
Send task 27!
Send task 28!
Send task 29!
Send task 30!
Send task 31!
Send task 32!
Send task 33!
Send task 34!
Worker got result: 66347af93cba05a5a594e14076d30035a5120727eb5d1e71966abb838ad6ed91
Send task 35!
Worker got result: e48b0b2e002e548e19726702926579326fc749fa8b12ef3e9d26cfb53a6fd902
Send task 36!
Worker got result: 4480e5cfa8c479910cd4aaac45263c7a500e59fd03a2242fa05fe26d0333ec2e
Send task 37!
Worker got result: d132f14a7cb8de7b2c780fed2b4a5c4dc913cf7413b9345c334b54f44f3d31cf
Send task 38!
Worker got result: 438263e26b1c9f28cc4b183001d36832c8dc97f4c74ad82b82b3f3ef906f25ab
Send task 39!
Worker got result: 952c5458af7ec14e85d899fb4c837eb05edb67a0dabf35367eeb5bd790f729e1
Send task 40!
Worker got result: 97e9678bc2c2d18b1d68b829d82bec5968bccbf2a970c05ac1845e6bce933c85
Send task 41!
Worker got result: 2f44e7b5e58aaf277de810127b300fae005c365a8ec45b946f38a7a0f8af289f
Send task 42!
Worker got result: c4621e33ec4b607737a0793cd53c3449863f2e97cfdee3b887d35c31ea5a3f3f
Send task 43!
Worker got result: cd7b4fcb9140cf6d788384f3eda2f350dafe0e2b6586e46f58108807011f547f
Send task 44!
Worker got result: 51d75c60ceb29a1f73bfd6e076a8f7463e3048eede44003842d316f85938b098
Send task 45!
Worker got result: f36298d57904b4a8c74bf9efac2ad68af2f456f5c24391dc6502e782e3b7e457
Send task 46!
Worker got result: c89629f15f4b79909528e353681241e49fff7520aaef04603a04124cd46d761e
Send task 47!
Worker got result: ac107469d7ad50137e97bc385ff8706d92d01dad6fc19a9c9c4af0c4735b4f04
Send task 48!
Worker got result: 6f28f42a455169f08d573dc47ca57de074760e16a792e63ce85b653ad84c6396
Send task 49!
Worker got result: 7e1e1f5aa591659a57852f93d11ad2350a89a6c696b949f35f0c845eb50f055b
Send task 50!
Worker got result: 42adedd767a5995b492fa9aa5bb7054a3848c5d15965a016079294f398e9e383
Send task 51!
Worker got result: 375d536fff1cd46902ef62995f0098d903b650c1810b2f26915bcf817ab0387c
Send task 52!
Worker got result: 01fa88dab27534fe67ef79545cfd1ae19d0c539aada79d2f0778e5db218f219d
Send task 53!
Worker got result: 300ea6e1840feda0ad7b0caefdffe160e77dc12343c41bc41070cd73010af7cb
Send task 54!
Worker got result: fddc2693440c5a65012cf79329b36b079e88b51f4ecac24621d057124257439d
Send task 55!
Worker got result: 909ee1cecdcb8e2224f798b71726fb7aedef6f23e74d6dd041ecfe29037ad589
Send task 56!
Worker got result: 567addfdb07c7a56201f1ee3a681e4a675c7a9a24bdc5b35a568bf4a050888e6
Send task 57!
Worker got result: c6c978b2d44f15d9951f20f0e6d6ca2b44f1ee76173db460cf267fc7888bc80d
Send task 58!
Worker got result: 5f0e36ed8de475497d3a68d6bac76cb4edb8a3cd2486053a9dceb22b4b04d84c
Send task 59!
Worker got result: 412a319d413dd55cc8ce47e4e6642ea77c399c879c41797565a297c026c50848
Send task 60!
Worker got result: a7403d1c85ac8200f4d6b2294a7d664d14d027b2c45d6236b0dfa18374432b26
Send task 61!
Worker got result: e1882dfe65bd9e8e25bd55c30733b25c80613bd6771fead8772d33987113e8c9
Send task 62!
Worker got result: 01038302e6bd6a8e345da22690389150085771d0a9c1eedcd4e50c70f5e11052
Send task 63!
^C

```

为什么会多发几个，是因为发的时候另一边已经在收了，所以多发几个是正常的。

**每当一个 `Worker got result` 出现，就意味着消费了一个任务，于是就允许一个新的 `Send task` 被成功发送**。这就形成了您看到的“发送一个，处理一个”的动态平衡状态，程序会一直这样运行下去，直到您手动停止。

## 总结

回顾全文，我们从一个简单的 `#[tokio::main]` 出发，经历了一场关于 Rust 并发编程的探索之旅。我们不仅看到了 `std::thread` 的基础用法，更关键的是，我们直面并解决了在 Tokio 异步世界中最棘手的问题之一：**如何与阻塞代码共存**。

本文的核心启示可以归结为一句话：**永远不要在异步运行时的工作线程上执行长时间的、CPU密集的或任何可能阻塞的同步操作**。这样做的后果是灾难性的，它会冻结整个运行时，使其丧失异步调度的所有优势。

正确的“解耦”之道，正如我们最后几个示例所展示的，是通过**通道（Channel）**机制，搭建起异步世界与同步世界之间的通信桥梁，将这些“脏活累活”**外包**给专用的同步工作者线程。这种模式不仅保证了 Tokio 运行时的绝对流畅和高响应性，也充分利用了现代多核CPU的并行处理能力。

希望本文的 9 个示例和层层递进的分析，能为您在 Rust 异步编程的道路上扫清一些障碍。真正的掌握源于实践，理解了这些模式背后的原理后，现在就动手，将它们应用到您的下一个项目中去吧！

## 参考

- <https://docs.rs/tokio/latest/tokio/runtime/index.html>
- <https://github.com/tokio-rs/tokio>
- <https://tokio.rs/>
- <https://github.com/mjovanc/awesome-tokio>
