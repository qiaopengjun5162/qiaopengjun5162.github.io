+++
title = "Rust 并发编程：详解线程间数据共享的几种核心方法"
description = "本文深入探讨了 Rust 中多线程数据共享的三种核心技术：static 变量、Box::leak() 和原子引用计数 Arc<T>。通过实际代码示例，我们展示了每种方法的应用场景、具体实现以及注意事项，特别是 static mut 存在的线程安全风险，帮助你掌握 Rust 并发编程的关键。"
date = 2025-08-20T12:03:16Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust 并发编程：详解线程间数据共享的几种核心方法

在现代计算中，多线程编程是提升应用性能、实现高并发的关键。然而，线程间的数据共享向来是并发编程中的一大挑战，充满了数据竞争和死锁等陷阱。Rust 语言以其独特的所有权系统和严格的编译时检查，为我们提供了“无畏并发”的能力。

本文将通过具体的代码实践，深入探讨在 Rust 中实现多线程数据共享的几种核心方式，包括 `static` 变量、`Box::leak()` 技巧以及原子引用计数 `Arc<T>`。无论你是 Rust 新手还是有经验的开发者，相信本文都能帮助你更深刻地理解和运用 Rust 的并发能力。

## Rust：多线程共享数据的几种方式

Rust - 线程间共享数据

Rust 多线程

方式：

- 使用 move 转移所有权
- 使用限定作用域的线程（Scoped Threads）从生命周期更长的父线程借用数据
- Static
- Box::leak()
- Arc<T>

## 实操

### 创建项目并进入项目目录

```bash
cargo new share-data
    Creating binary (application) `share-data` package
note: see more `Cargo.toml` keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

cd share-data

```

## Static

- Static 变量的值在整个程序运行期间都有效
- 拥有 `'static` 生命周期
- 只能用常量值来初始化
- 代表一个内存地址，可以进行引用
- 在程序结束的时候不会调用 drop
- 既可以是 `mut` 的，也可以是非`mut`

### 使用 `static` 在多线程环境共享数据

```rust
use std::thread;

static DATA: [i32; 5] = [1, 2, 3, 4, 5];

fn main() {
    let mut handles = Vec::new();

    for _ in 0..6 {
        let h = thread::spawn(|| {
            println!("Data: {DATA:#?}");
        });
        handles.push(h);
    }

    handles.into_iter().for_each(|h| h.join().unwrap());
}

```

### 运行

```bash
RustJourney/share-data on  main [?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
   Compiling share-data v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/share-data)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.30s
     Running `target/debug/share-data`
Data: [
    1,
    2,
    3,
    4,
    5,
]
Data: [
    1,
    2,
    3,
    4,
    5,
]
Data: [
    1,
    2,
    3,
    4,
    5,
]
Data: [
    1,
    2,
    3,
    4,
    5,
]
Data: [
    1,
    2,
    3,
    4,
    5,
]
Data: [
    1,
    2,
    3,
    4,
    5,
]
```

### 在多线程环境中修改 `mut static` 变量

```rust
use std::thread;

static mut COUNTER: u32 = 0;

fn main() {
    let mut handles = Vec::new();

    for _ in 0..10000 {
        let h = thread::spawn(|| unsafe {
            COUNTER += 1;
        });
        handles.push(h);
    }

    handles.into_iter().for_each(|h| h.join().unwrap());
    println!("Counter: {}", unsafe { COUNTER });
}
```

### 运行

```bash
RustJourney/share-data on  main [?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
   Compiling share-data v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/share-data)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.58s
     Running `target/debug/share-data`
Counter: 9990

RustJourney/share-data on  main [?] is 📦 0.1.0 via 🦀 1.89.0 took 3.1s
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/share-data`
Counter: 9987

RustJourney/share-data on  main [?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/share-data`
Counter: 9987

RustJourney/share-data on  main [?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/share-data`
Counter: 9990

```

为什么不是 10000？因为每次`COUNTER += 1` 这个操作不是一个原子操作。

这个操作大概至少分为三步：

第一步：取出`COUNTER` 这个数

第二步：`COUNTER` 加 1

第三步：把它放回去

不是原子操作，最低也是三步。所以使用可变的静态变量，把它共享到多线程，然后对它进行修改的操作就可能引起数据竞争。因此它是 unsafe 的，我们不应该这样操作。

以上就是关于不可变的 Static 和 可变的 Static 在多线程共享数据的例子

## Box::leak()

本质是主动泄露内存分配

- 释放 Box 的所有权，并承诺永远不会 drop 它
- 从 leak 这一刻起，这个 Box 就一直存在
- 因为没有所有者，只要程序运行就可以被任何线程借用
- 注意：因为它是内存泄露，所以一个程序里面不要使用太多

### 使用 `Box::leak()` 在多个线程共享数据

```rust
use std::thread;

fn main() {
    let data: &'static [i32; 5] = Box::leak(Box::new([1, 2, 3, 4, 5]));

    let mut handles = Vec::new();

    for _ in 0..5 {
        let h = thread::spawn(move || {
            println!("Data: {data:?}");
        });
        handles.push(h);
    }

    handles.into_iter().for_each(|h| h.join().unwrap());
}
```

虽然使用了 `move` 关键字，但是它没有移动所有权。

### 运行

```bash
RustJourney/share-data on  main [?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
   Compiling share-data v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/share-data)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.50s
     Running `target/debug/share-data`
Data: [1, 2, 3, 4, 5]
Data: [1, 2, 3, 4, 5]
Data: [1, 2, 3, 4, 5]
Data: [1, 2, 3, 4, 5]
Data: [1, 2, 3, 4, 5]

```

## Arc<T>

原子引用计数（atomically reference counted)

- 与 `Rc<T>` 类似，但 Arc 保证对引用计数器的修改是不可分割的原子操作
- 在多线程环境中使用

### 使用 `Arc<T>` 在多个线程共享所有权

```rust
use std::{sync::Arc, thread};

fn main() {
    let data = Arc::new([1, 2, 3, 4, 5]);

    let mut handles = Vec::new();

    for _ in 0..4 {
        let local_data = data.clone();
        let h = thread::spawn(move || {
            println!("Data: {local_data:?}");
        });
        handles.push(h);
    }

    handles.into_iter().for_each(|h| h.join().unwrap());
}
```

### 运行

```bash
RustJourney/share-data on  main [?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
   Compiling share-data v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/share-data)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.58s
     Running `target/debug/share-data`
Data: [1, 2, 3, 4, 5]
Data: [1, 2, 3, 4, 5]
Data: [1, 2, 3, 4, 5]
Data: [1, 2, 3, 4, 5]
```

## 总结

本文我们一起探讨了 Rust 中实现线程间数据共享的三种主要方法：

1. **`static` 变量**：适用于程序整个生命周期都存在且不可变的数据共享。虽然 `static mut` 可以实现可变数据的共享，但它绕过了 Rust 的借用检查，需要 `unsafe` 代码块，并且极易引发数据竞争，在实践中应谨慎使用或搭配其他同步原语。
2. **`Box::leak()`**：一种通过主动“泄露”内存来获取 `'static` 生命周期的引用的技巧。它能让动态分配的数据在整个程序运行期间有效，从而被多个线程安全地借用。但这种方法本质上是内存泄露，不应被滥用。
3. **`Arc<T>` (原子引用计数)**：这是 Rust 中最常用、最灵活的线程安全共享所有权的方式。它通过原子操作来管理引用计数，确保数据在所有线程使用完毕后才被清理，是实现多线程数据共享的首选方案。

总而言之，Rust 提供了多样化且强大的工具来应对并发编程的挑战。理解并根据具体场景选择合适的数据共享方式，是编写高效、安全 Rust 并发程序的关键一步。希望通过本文的实践，你能对 Rust 的“无畏并发”有更深的体会。

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://course.rs/about-book.html>
- <https://lab.cs.tsinghua.edu.cn/rust/>
