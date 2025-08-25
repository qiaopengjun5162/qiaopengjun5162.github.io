+++
title = "煮咖啡里的大学问：用 Rust Async/Await 告诉你如何边烧水边磨豆"
description = "煮咖啡里的大学问：用 Rust Async/Await 告诉你如何边烧水边磨豆"
date = 2025-08-24T14:32:00Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# **煮咖啡里的大学问：用 Rust Async/Await 告诉你如何边烧水边磨豆**

你是否曾经想过，为什么有些程序在处理多个任务时会“卡住”？就像煮咖啡时，必须等水完全烧开才能去磨豆子一样，传统的同步代码一步步执行，效率低下。在追求高性能的今天，这显然无法满足我们的需求。本文将带你走进 Rust 的异步世界，通过三个由浅入深的实战示例，从最基础的同步逻辑，到 `async/await` 语法，再到利用 `tokio::join!` 实现真正的并发，让你亲手揭开 Rust 高性能并发编程的神秘面纱。

本文通过一个“煮咖啡”的生动比喻，循序渐进地讲解了 Rust 的异步编程。文章从传统的同步代码出发，展示了其顺序执行的局限性；接着引入 `async/await` 关键字，解释了异步编程的基本语法；最后通过 `tokio::join!` 宏实现任务并发执行，直观地对比了异步并发带来的效率提升，是初学者掌握 Rust 异步核心概念的绝佳实战指南。

## 实操

### 创建项目

```bash
cargo new async_await_demo
    Creating binary (application) `async_await_demo` package
note: see more `Cargo.toml` keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html
```

### 切换到项目目录

```bash
cd async_await_demo
```

### `Cursor`编辑器打开项目

```bash
cc # open -a cursor .
```

### 示例一

```rust
#![allow(unused)]

// Async / await

fn g1() -> u32 {
    1
}

fn g2() -> u32 {
    2
}

fn g3() -> u32 {
    3
}

// Make coffee
fn f() {
    // Boil water
    let a = g1();
    // Grind coffee beans
    let b = g2();
    // Pour hot water on coffee grinds
    let c = g3();
}

fn main() {
    f();
}

```

这段代码展示了一个基本的 **同步** 执行流程。程序从 `main` 函数开始，调用了 `f` 函数。在 `f` 函数内部，它模拟了“制作咖啡”的三个步骤：它首先调用 `g1` 函数（如同“烧水”），然后调用 `g2` 函数（如同“磨咖啡豆”），最后调用 `g3` 函数（如同“冲泡”）。最关键的一点是，这些函数调用是 **按顺序依次执行** 的：`g2` 必须等到 `g1` 完成后才能开始，而 `g3` 必须等到 `g2` 完成。整个过程就像一条单行道，所有任务排队等待，一个接一个地完成。

### 示例二

```bash
#![allow(unused)]

// Async / await

async fn g1() -> u32 {
    println!("g1 function called");
    1
}

async fn g2() -> u32 {
    println!("g2 function called");
    2
}

async fn g3() -> u32 {
    println!("g3 function called");
    3
}

// Make coffee
async fn f() -> (u32, u32, u32) {
    println!("f function called");
    // Boil water - returns Future
    let a = g1().await;
    // Grind coffee beans
    let b = g2().await;
    // Pour hot water on coffee grinds
    let c = g3().await;

    (a, b, c)
}

#[tokio::main]
async fn main() {
    let (a, b, c) = f().await;
    println!("Coffee is ready: {} {} {}", a, b, c);
}

```

这段代码展示了 **异步 (asynchronous)** 编程的基本用法。通过在函数前加上 `async` 关键字，这些函数（如 `g1`, `g2`, `f`）不再直接返回值，而是返回一个“未来” (`Future`)，代表一个将在未来完成的计算。`await` 关键字的作用是暂停当前函数的执行，直到它等待的那个“未来”完成并交出结果。

具体到这段代码，虽然它使用了异步语法，但执行流程仍然是 **顺序的**：在 `f` 函数中，程序会 `await g1()`，即一直等到 `g1` 执行完毕；然后才会开始执行并 `await g2()`；最后再 `await g3()`。因此，你看到的输出结果将和同步代码一样，是按 `g1`、`g2`、`g3` 的顺序依次执行的。这段代码主要是为了演示 `async/await` 的基本语法，而不是并发执行任务。

### 运行

```bash
➜ cargo run
   Compiling pin-project-lite v0.2.16
   Compiling tokio v1.47.1
   Compiling async_await_demo v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/async_await_demo)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.28s
     Running `target/debug/async_await_demo`
f function called
g1 function called
g2 function called
g3 function called
Coffee is ready: 1 2 3
```

### 示例三

```rust
#![allow(unused)]

// Async / await

async fn g1() -> u32 {
    println!("g1 function called");
    1
}

async fn g2() -> u32 {
    println!("g2 function called");
    2
}

async fn g3() -> u32 {
    println!("g3 function called");
    3
}

// Make coffee
async fn f() -> (u32, u32, u32) {
    println!("f function called");

    // Boil water - returns Future
    // let a = g1().await;
    // Grind coffee beans
    // let b = g2().await;

    // Boil water and grind coffee beans simultaneously
    let (a, b) = tokio::join!(g1(), g2());

    // Pour hot water on coffee grinds
    let c = g3().await;

    (a, b, c)
}

#[tokio::main]
async fn main() {
    let (a, b, c) = f().await;
    println!("Coffee is ready: {} {} {}", a, b, c);
}

```

这段代码引入了 **并发 (concurrency)** 的概念。与之前按顺序 `await` 每个函数不同，这里的 `tokio::join!(g1(), g2())` 会 **同时启动** `g1` 和 `g2` 两个任务，并等待它们 **全部完成**。

这就好比在制作咖啡时，你不再是先等水完全烧开再开始磨豆子，而是在烧水的同时就开始磨豆子，两件事一起进行，从而节省了时间。一旦水烧好、豆子也磨好了（即 `join!` 完成），程序才会继续执行下一步，调用 `g3` 来冲泡咖啡。因此，`g1` 和 `g2` 的打印输出顺序是不确定的，因为它们是并发执行的，但它们都会在 `g3` 开始之前完成。

### 运行

```bash
➜ cargo run
   Compiling async_await_demo v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/async_await_demo)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.53s
     Running `target/debug/async_await_demo`
f function called
g1 function called
g2 function called
g3 function called
Coffee is ready: 1 2 3

```

## 总结

通过本文的三个步骤，我们清晰地看到了从 **同步** 到 **异步**，再到 **并发** 的演进过程。首先，我们理解了同步代码按部就班的执行模式；然后，我们学习了如何使用 `async/await` 语法将代码改造为异步形式，虽然语法上实现了异步，但执行流依然是顺序的；最后，我们借助 `tokio::join!` 这个强大的工具，真正实现了多个任务的并发执行，就像同时烧水和磨豆一样，极大地提升了程序效率。希望这次的“煮咖啡之旅”能让你对 Rust 的异步编程有一个更具体、更深刻的理解。掌握它，你将能编写出更高效、更强大的 Rust 应用。

## 参考

- <https://www.rust-lang.org/>
- <https://course.rs/about-book.html>
- <https://rsproxy.cn/>
- <https://embarkstudios.github.io/cargo-deny/index.html>
