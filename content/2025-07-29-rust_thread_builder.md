+++
title = "Rust `Thread::Builder` 用法详解：线程命名与栈大小设置"
description = "本篇详解 Rust 中 Thread::Builder 的核心用法。文章将带你深入学习如何通过 Builder 为线程进行命名，从而极大地方便调试工作；同时，你也将掌握如何设置线程的栈大小，以应对内存要求更高的任务。本文通过清晰的代码示例，助你精准控制线程创建，编写更健壮的并发程序。"
date = 2025-07-29T07:45:50Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust `Thread::Builder` 用法详解：线程命名与栈大小设置

在 Rust 多线程编程中，`thread::spawn` 是我们创建线程最直接的方式。但当默认配置无法满足需求时——例如，我们需要在复杂的调试中识别特定线程，或者某个任务需要更大的栈空间时——`spawn` 函数就显得力不从心了。

为此，Rust 提供了更为强大的 `std::thread::Builder`。本篇指南将详细解析 `Thread::Builder` 的使用方法，重点讲解如何利用它实现 **线程命名** 与 **自定义栈大小** 这两个核心功能，帮助你更精准地掌控线程。

## 实操

### 方式一：使用 `thread::spawn` 快速创建（基础方式）

在 Rust 中，创建线程最直接的方法是调用 `std::thread::spawn` 函数。它接受一个闭包（closure）作为参数，并在一个新的线程上执行这个闭包里的代码。这种方式非常适合快速启动一些简单的后台任务。

**优点：**

- **简单快捷**：一行代码即可启动一个线程，语法非常简洁。

**局限性：**

- **无法配置**：通过 `thread::spawn` 创建的线程使用的是系统的默认配置。我们无法为其指定名称，也无法调整其栈空间大小。在大型项目中，当数十个无名线程同时运行时，一旦出现 panic，调试起来会非常困难。

**实操代码：** 下面的代码演示了如何使用 `spawn` 创建一个子线程，同时主线程也在运行。

```rust
use std::thread;
use std::time::Duration;

fn main() {
  // 使用 spawn 创建一个匿名线程
  thread::spawn(|| {
    for i in 1..10 {
      println!("hi number {i} from the spawned thread!");
      thread::sleep(Duration::from_millis(1));
    }
  });

  // 主线程继续执行自己的任务
  for i in 1..5 {
    println!("hi number {i} from the main thread!");
    thread::sleep(Duration::from_millis(1));
  }
  // 注意：主线程结束后，spawned 线程可能会被直接终止
}
```

**注意**：运行上面的代码，您可能会发现子线程的消息没有打印完程序就退出了。这是因为主线程执行完毕后会直接退出，而不会等待子线程结束。为了解决这个问题，我们需要一种方法来等待子线程完成，这就要用到 `JoinHandle`，它也正是 `Thread::Builder` 创建线程后的返回值之一。

### 方式二：使用 `Thread::Builder` 精准构建（推荐方式）

Rust 多线程 - 线程建造者（Thread Builder) 创建线程

为了弥补 `thread::spawn` 在可配置性上的不足，Rust 提供了 `std::thread::Builder`。它是一个典型的“建造者模式”实现，允许我们在创建线程前，链式地调用各种配置方法，实现对线程的精细化控制。

### 线程命名

可以使用 `std::thread::Builder` 来构建一个带名字的线程

- 如果一个命名线程发生 panic，Rust 会在 panic 报错信息中打印出该线程的名字，方便你快速定位问题。
- 在线程运行时，它的名字也会被提供给操作系统，比如在类 Unix 系统中会使用 pthread_setname_np 设置线程名。
- Builder::name()

### 线程栈大小（Stack Size）

Rust 中每个线程都会有一个默认的栈空间大小，这个大小是平台相关的。

- 当前默认设置：目前在所有 Tier-1 平台（Rust 官方支持的主平台）上，默认线程栈大小是 2 MiB（约 2 兆字节）

### 设置线程栈的大小

- Builder::stack_size()
- 设置环境变量 RUST_MIN_STACK
  - 例如：RUST_MIN_STACK=4194304./your_program
  - ⚠️注意：如果你在代码中同时使用了 Builder::stack_size，那么它会覆盖 RUST_MIN_STACK 的设置
- 主线程（main 函数所在的线程）的栈大小不是由 Rust 决定的，而是由操作系统或者启动器控制的。

### 完整项目实战

下面的例子展示了如何使用 `Builder` 创建一个名为 "Thread 1"，且拥有 4MB 栈空间的线程。

#### 第一步：创建项目

```bash
cargo new thread_builder
    Creating binary (application) `thread_builder` package
note: see more `Cargo.toml` keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html
```

### 第二步：切换到项目目录

```bash
cd thread_builder
```

### 第三步：查看项目目录

```bash
RustJourney/thread_builder on  main [?] is 📦 0.1.0 via 🦀 1.88.0 on 🐳 v28.2.2 (orbstack)
➜ tree . -L 6 -I "target"
.
├── Cargo.lock
├── Cargo.toml
└── src
    └── main.rs

2 directories, 3 files

```

### 第四步：编写代码

### `src/main.rs` 文件内容如下

```rust
use std::thread;

fn main() {
    let handle = thread::Builder::new()
        .name("Thread 1".into())
        .stack_size(1024 * 1024 * 4)
        .spawn(another_thread)
        .unwrap();

    handle.join().unwrap();
}

fn another_thread() {
    println!(
        "Hello from another thread, my name is {}",
        thread::current().name().unwrap()
    );
}

```

### 第五步：编译并运行

```bash
RustJourney/thread_builder on  main [?] is 📦 0.1.0 via 🦀 1.88.0 on 🐳 v28.2.2 (orbstack)
➜ cargo build
   Compiling thread_builder v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/thread_builder)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.63s

RustJourney/thread_builder on  main [?] is 📦 0.1.0 via 🦀 1.88.0 on 🐳 v28.2.2 (orbstack)
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/thread_builder`
Hello from another thread, my name is Thread 1
```

通过这种方式，我们创建的线程不仅功能明确，而且更易于管理和维护，是构建健壮并发程序的首选。

## 总结

通过本篇指南的详细解析，我们深入了解了 `Thread::Builder` 相比 `thread::spawn` 所提供的强大控制力。现在，我们来回顾一下两个核心配置的要点：

1. **线程命名 (`Builder::name`)**: 为线程赋予有意义的名称是调试复杂并发程序的关键一步。它能在 panic 发生时提供清晰的上下文，帮助我们快速定位问题。
2. **栈大小设置 (`Builder::stack_size`)**: 允许我们为特定任务分配充足的栈内存，有效避免因默认值不足而导致的栈溢出风险，增强了程序的稳定性。

总之，熟练运用 `Thread::Builder` 进行线程命名和栈大小设置，是编写专业、健壮的 Rust 并发应用的重要技能。希望本文的详解能帮助你在实际项目中更好地管理和控制线程。

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://course.rs/about-book.html>
- <https://lab.cs.tsinghua.edu.cn/rust/>
- <https://www.rust-lang.org/>
