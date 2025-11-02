+++
title = "Rust 异步编程陷阱：Tokio 的 `tokio::sleep` 和 `thread::sleep` 到底有何天壤之别？"
description = "Rust 异步编程陷阱：Tokio 的 `tokio::sleep` 和 `thread::sleep` 到底有何天壤之别？"
date = 2025-11-02T12:42:34Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust 异步编程陷阱：Tokio 的 `tokio::sleep` 和 `thread::sleep` 到底有何天壤之别？

Rust 的异步编程（Async Rust）以其高性能和零成本抽象而闻名，而 **Tokio** 则是其中最受欢迎的运行时。许多初学者在尝试并发执行任务时，习惯性地在异步函数中使用标准库的 **`thread::sleep`** 来进行延迟，却发现程序运行起来仍然是**串行**的。本篇文章将通过一系列实操代码示例，深入剖析这个常见的陷阱：**为什么同步阻塞的 `thread::sleep` 会彻底破坏你的异步并发，以及如何使用 `tokio::time::sleep` 实现真正的非阻塞高效并发。** 理解这一点，是你迈向高性能 Rust 异步开发的必经之路。

本文通过 Rust 和 Tokio 的代码示例，揭示了异步编程中的一个常见误区：在 `async` 函数中使用 **`thread::sleep`** 会阻塞 **整个** Tokio 执行器线程，导致并发任务退化为**串行**执行。正确的做法是使用 **`tokio::time::sleep`**，它能非阻塞地暂停当前任务，让出线程控制权给其他任务，从而实现高效的**异步并发**。实操证明了使用后者才能真正实现多任务的交错执行。

## Async Rust - Async Sleep （Tokio）

Tokio `tokio::time::sleep(...)` Async Rust

### 高 CPU 占用会阻塞任务

- 在执行计算时会阻塞线程池，只有当你让出控制权时（yield，await 或等待一个 I/O 任务结束时）才能运行

## 实操

### 示例一

使用 **Tokio** 运行时进行**并发**操作

```rust
use std::{thread, time::Duration};

async fn hello(task: u64, time: u64) {
    println!("Task {task} started.");
    thread::sleep(Duration::from_millis(time));
    println!("Task {task} finished.");
}

#[tokio::main]
async fn main() {
    tokio::join!(
        hello(1, 1000),
        hello(2, 500),
        hello(3, 2000),
        hello(4, 1000),
        hello(5, 500),
        hello(6, 2000),
    );
}

```

### 💻 代码解释

- **`use std::{thread, time::Duration};`**: 导入了标准库中的 `thread` 模块（用于线程操作）和 `time::Duration`（用于表示时间长度）。
- **`async fn hello(task: u64, time: u64)`**: 定义了一个 **异步函数** `hello`，它接受任务编号 (`task`) 和延迟时间（毫秒，`time`）作为参数。
  - 函数首先打印任务开始信息。
  - **`thread::sleep(Duration::from_millis(time));`**: **这是代码中的一个关键点和潜在的** **“陷阱”**。它使用了**标准库的同步线程阻塞函数**来暂停执行。在 **Tokio 的异步任务**中，使用 `thread::sleep` 会阻塞 **整个异步执行器线程**，而不是只阻塞当前这个异步任务。在实际的异步编程中，**应该使用 `tokio::time::sleep`** 来进行非阻塞的等待。尽管如此，在这个例子中它仍然能工作，但会以**阻塞**的方式运行，这与异步编程的初衷相悖。
  - 函数最后打印任务完成信息。
- **`#[tokio::main]`**: 这是一个宏，它将 `main` 函数标记为 **Tokio 运行时**的入口点，负责设置并启动异步执行器。
- **`async fn main()`**: 主函数是一个异步函数。
- **`tokio::join!(...)`**: 这是一个 **Tokio 宏**，用于**并发地**执行它所包含的多个 **Future** (即这里的 `hello(...)` 调用)。它会等待所有这些异步操作**全部完成**后才返回。

### 运行

```bash
➜ cargo run
   Compiling rust_os_threads v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rust_os_threads)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.82s
     Running `target/debug/rust_os_threads`
Task 1 started.
Task 1 finished.
Task 2 started.
Task 2 finished.
Task 3 started.
Task 3 finished.
Task 4 started.
Task 4 finished.
Task 5 started.
Task 5 finished.
Task 6 started.
Task 6 finished.

```

这段代码的运行结果表面上看似使用了 **Tokio 的并发机制**，但实际上是**串行执行**的。原因在于 `hello` 函数内部调用了同步的 `thread::sleep`，它会阻塞整个 Tokio 运行线程，而不是仅暂停当前异步任务。
 因此，当程序运行时，每个任务都会依次启动、休眠、结束，**前一个任务完全结束后，才会开始下一个任务**。这就是为什么输出结果中所有任务都是按顺序执行（Task 1 → Task 2 → Task 3 …），而没有并发交错的打印信息。
 换句话说，虽然程序结构上看似“异步并发”，但由于使用了同步阻塞函数，实际效果与普通的同步顺序执行没有区别。若将 `thread::sleep` 替换为 `tokio::time::sleep`，就能真正实现并发执行，每个任务会独立等待、交错输出，从而体现出 Tokio 异步运行时的并发特性。

### 示例二

```rust
use std::{thread, time::Duration};

async fn hello(task: u64, time: u64) {
    println!(
        "Task {task} started on thread {:?}.",
        thread::current().id()
    );
    thread::sleep(Duration::from_millis(time));
    println!("Task {task} finished.");
}

#[tokio::main]
async fn main() {
    tokio::join!(
        hello(1, 1000),
        hello(2, 500),
        hello(3, 2000),
        hello(4, 1000),
        hello(5, 500),
        hello(6, 2000),
    );
}

```

这段代码演示了在 **Tokio 异步运行时**中使用 **同步阻塞操作**（`thread::sleep`）的效果。程序定义了一个异步函数 `hello`，接收任务编号与延迟时间参数，在运行时打印当前任务编号及其所在线程的 ID，然后调用 `thread::sleep` 让当前线程暂停指定时间。由于 `thread::sleep` 是**同步阻塞函数**，它会阻塞整个线程，而非仅暂停该异步任务，从而导致所有任务被顺序执行。尽管 `main` 函数使用了 `tokio::join!` 来并发运行多个异步任务，但因为阻塞调用的存在，这些任务仍然依次在同一个线程上执行。最终输出中可看到所有任务的线程 ID 相同，说明没有真正的并发执行。如果改用 `tokio::time::sleep`，则能实现真正的异步并发，每个任务会在不同时间交错完成。

### 运行

```bash
➜ cargo run
   Compiling rust_os_threads v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rust_os_threads)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.68s
     Running `target/debug/rust_os_threads`
Task 1 started on thread ThreadId(1).
Task 1 finished.
Task 2 started on thread ThreadId(1).
Task 2 finished.
Task 3 started on thread ThreadId(1).
Task 3 finished.
Task 4 started on thread ThreadId(1).
Task 4 finished.
Task 5 started on thread ThreadId(1).
Task 5 finished.
Task 6 started on thread ThreadId(1).
Task 6 finished.
```

从运行结果可以看出，所有任务都在同一个线程（`ThreadId(1)`）上依次执行，说明程序并没有真正实现并发，而是**串行**运行的。虽然代码使用了 Tokio 的异步运行时和 `tokio::join!` 宏来尝试同时执行多个异步任务，但由于 `hello` 函数内部调用了**同步阻塞函数** `thread::sleep`，它会阻塞整个线程的执行，导致其他任务无法同时运行。因此，输出结果显示每个任务都是先开始、再结束，然后下一个任务才启动，所有任务共享同一个线程 ID。如果将 `thread::sleep` 改为 `tokio::time::sleep`，任务就能在不同时间点交错执行，真正体现异步并发的效果。

### 示例三

```rust
use std::{thread, time::Duration};

use tokio::runtime::Builder;

async fn hello(task: u64, time: u64) {
    println!(
        "Task {task} started on thread {:?}.",
        thread::current().id()
    );
    thread::sleep(Duration::from_millis(time));
    println!("Task {task} finished.");
}

fn main() {
    let rt = Builder::new_multi_thread()
        .worker_threads(4)
        .enable_all()
        .build()
        .unwrap();
    rt.block_on(async {
        tokio::join!(
            hello(1, 1000),
            hello(2, 500),
            hello(3, 2000),
            hello(4, 1000),
            hello(5, 500),
            hello(6, 2000),
        )
    });
}

```

这段代码展示了如何使用 **Tokio 多线程运行时** 来执行异步任务。程序首先通过 `tokio::runtime::Builder::new_multi_thread()` 创建了一个具有 **4 个工作线程** 的异步运行时，然后在其中并发执行多个 `hello` 异步任务。每个 `hello` 函数会打印当前任务编号及其运行的线程 ID，并调用 `thread::sleep` 进行同步阻塞。虽然运行时是多线程的，但由于 `thread::sleep` 会阻塞整个执行线程，因此任务只能在可用的线程之间被分配执行，**最多 4 个任务可同时运行**，其他任务会等待空闲线程后再执行。这意味着程序会表现出**部分并发、部分阻塞**的特征，不同任务可能在不同的线程上执行（线程 ID 不同），但仍未充分发挥 Tokio 的异步优势。若改为 `tokio::time::sleep`，则能完全实现非阻塞的异步并发执行。

### 运行

```bash
➜ cargo run
   Compiling rust_os_threads v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rust_os_threads)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.73s
     Running `target/debug/rust_os_threads`
Task 1 started on thread ThreadId(1).
Task 1 finished.
Task 2 started on thread ThreadId(1).
Task 2 finished.
Task 3 started on thread ThreadId(1).
Task 3 finished.
Task 4 started on thread ThreadId(1).
Task 4 finished.
Task 5 started on thread ThreadId(1).
Task 5 finished.
Task 6 started on thread ThreadId(1).
Task 6 finished.
```

从运行结果可以看出，所有任务都在同一个线程（`ThreadId(1)`）上顺序执行，没有出现多线程并发的情况。虽然代码中使用了 `tokio::runtime::Builder::new_multi_thread()` 创建了一个包含 4 个工作线程的多线程运行时，但由于异步函数内部仍使用了同步阻塞调用 `thread::sleep`，Tokio 无法将这些任务真正分配到多个线程上并发运行，导致执行过程退化为单线程串行执行。每个任务都完整执行完毕后，下一个任务才开始，因此输出结果中任务编号严格递增、线程 ID 不变。若将 `thread::sleep` 替换为异步的 `tokio::time::sleep`，则运行时能真正利用多线程并发，输出中会出现多个不同的线程 ID，任务执行顺序也会交错。

By running all async expressions on the current task, the expressions are able to run **concurrently** but not in **parallel**. This means all expressions are run on the same thread and if one branch blocks the thread, all other expressions will be unable to continue. If parallelism is required, spawn each async expression using [`tokio::spawn`](https://docs.rs/tokio/latest/tokio/task/fn.spawn.html) and pass the join handle to `join!`.

### 示例四

```rust
use std::{thread, time::Duration};

async fn hello(task: u64, time: u64) {
    println!(
        "Task {task} started on thread {:?}.",
        thread::current().id()
    );
    thread::sleep(Duration::from_millis(time));
    println!("Task {task} finished.");
}

#[tokio::main]
async fn main() {
    let _ = tokio::join!(
        tokio::spawn(hello(1, 1000)),
        tokio::spawn(hello(2, 500)),
        tokio::spawn(hello(3, 2000)),
        tokio::spawn(hello(4, 1000)),
        tokio::spawn(hello(5, 500)),
        tokio::spawn(hello(6, 2000)),
    );
}

```

这段代码展示了在 **Tokio 异步运行时**中使用 **`tokio::spawn`** 来并发执行多个异步任务的例子。`tokio::spawn` 会为每个任务创建一个独立的异步执行单元（轻量级线程），让它们可以**真正并发运行**。在 `hello` 函数中，每个任务都会打印其编号与当前线程的 ID，然后调用 `thread::sleep` 进行阻塞等待。虽然 `tokio::spawn` 启动了多个任务，但由于使用了同步阻塞的 `thread::sleep`，这些任务会占用 Tokio 的工作线程，使线程在休眠期间无法执行其他任务。不过，相比之前的示例，这段代码确实能在**不同的线程上并行执行多个任务**，因此运行结果中可以看到不同的 `ThreadId`，说明多个任务被分配到了不同的线程中执行。如果改为使用 `tokio::time::sleep`，则可以避免线程阻塞，充分发挥 Tokio 异步调度的高并发性能。

### 运行

```bash
➜ cargo run
   Compiling rust_os_threads v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rust_os_threads)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.86s
     Running `target/debug/rust_os_threads`
Task 1 started on thread ThreadId(13).
Task 4 started on thread ThreadId(8).
Task 5 started on thread ThreadId(10).
Task 2 started on thread ThreadId(12).
Task 3 started on thread ThreadId(11).
Task 6 started on thread ThreadId(9).
Task 2 finished.
Task 5 finished.
Task 1 finished.
Task 4 finished.
Task 6 finished.
Task 3 finished.

```

从运行结果可以看出，这段程序实现了**真正的并发执行**。不同的任务（Task 1–6）在程序启动后几乎同时开始运行，并且分布在多个不同的线程上（如 `ThreadId(8)`、`ThreadId(9)`、`ThreadId(10)` 等），说明 `tokio::spawn` 成功地将异步任务分配到了 Tokio 运行时的多个工作线程中。由于每个任务内部使用的是同步阻塞的 `thread::sleep`，各任务在自己的线程上独立休眠，因此多个任务可以并行执行。任务的“完成”顺序与“开始”顺序不同（例如 Task 2 最先完成），体现了多线程执行的**并发特性**。不过，这种阻塞式的实现仍然占用了系统线程资源，若改用 `tokio::time::sleep`，则可以在不阻塞线程的情况下实现更高效的异步并发。

### 示例五

```rust
use std::{thread, time::Duration};

async fn hello(task: u64, time: u64) {
    println!(
        "Task {task} started on thread {:?}.",
        thread::current().id()
    );
    // thread::sleep(Duration::from_millis(time));
    tokio::time::sleep(Duration::from_millis(time)).await;
    println!("Task {task} finished.");
}

#[tokio::main]
async fn main() {
    tokio::join!(
        hello(1, 1000),
        hello(2, 500),
        hello(3, 2000),
        hello(4, 1000),
        hello(5, 500),
        hello(6, 2000),
    );
}

```

这段代码演示了在 **Tokio 异步运行时**中实现**真正的非阻塞并发执行**。程序定义了一个异步函数 `hello`，每个任务在启动时打印自己的编号和线程 ID，然后使用 `tokio::time::sleep(...).await` 进行异步延迟。与之前使用 `thread::sleep` 不同，`tokio::time::sleep` 不会阻塞线程，而是仅暂停当前任务的执行，让运行时可以在这段时间内调度其他任务继续运行。主函数通过 `tokio::join!` 并发地启动多个 `hello` 任务，Tokio 会在单个或多个线程上高效地交替执行这些异步任务。运行时，多个任务会几乎同时开始、在不同时间完成，输出结果中的“started”和“finished”信息交错出现，体现了**异步并发调度的真实效果**。

### 运行

```bash
➜ cargo run
   Compiling rust_os_threads v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rust_os_threads)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.69s
     Running `target/debug/rust_os_threads`
Task 1 started on thread ThreadId(1).
Task 2 started on thread ThreadId(1).
Task 3 started on thread ThreadId(1).
Task 4 started on thread ThreadId(1).
Task 5 started on thread ThreadId(1).
Task 6 started on thread ThreadId(1).
Task 2 finished.
Task 5 finished.
Task 4 finished.
Task 1 finished.
Task 6 finished.
Task 3 finished.

```

从运行结果可以看出，所有任务都在同一个线程（`ThreadId(1)`）上运行，但任务的开始与结束顺序交错，说明程序实现了**真正的异步并发**。虽然所有任务都共享同一个线程，但由于使用了 `tokio::time::sleep` 这一**非阻塞延迟**函数，Tokio 运行时可以在一个线程内高效地调度多个任务。当某个任务在等待计时器时，线程会自动切换去执行其他任务，从而实现了多任务并发执行的效果。因此，任务的“完成”顺序不同于启动顺序，体现出 **Tokio 的异步调度机制**：在单线程环境下也能实现类似多线程的并发执行，而不会造成线程阻塞或资源浪费。

## 💡 总结

通过五个不同的代码示例及运行结果对比，本文彻底阐明了 Rust 异步编程中的核心原理：**非阻塞**。在 Tokio 运行时中，一切阻塞式操作（如高 CPU 计算或 `thread::sleep`）都可能导致整个线程池停滞，从而破坏异步并发性。

- 使用 **`tokio::join!`** 结合 **`thread::sleep`** 导致单线程**串行执行**。
- 即使是多线程运行时，`thread::sleep` 仍会浪费工作线程。
- 使用 **`tokio::spawn`** 可以通过占用多个 OS 线程实现**阻塞并行**，但资源消耗高。
- **唯一正确且高效的解决方案** 是使用 **`tokio::time::sleep(...).await`**。它通过 Future 机制让出线程控制权，使得即使在单个线程上，多个任务也能在等待 I/O 或计时器时高效地**并发**运行，充分发挥了 Tokio 异步调度的优势。

## 参考

- <https://docs.rs/tokio/latest/tokio/>
- <https://docs.rs/tokio/latest/tokio/macro.join.html>
- <https://github.com/rust-lang>
