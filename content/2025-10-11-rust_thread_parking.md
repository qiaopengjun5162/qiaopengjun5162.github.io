+++
title = "Rust 多线程的高效等待术：park() 与 unpark() 信号通信实战"
description = "Rust 多线程的高效等待术：park() 与 unpark() 信号通信实战"
date = 2025-10-11T05:20:08Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust 多线程的高效等待术：park() 与 unpark() 信号通信实战

在多线程编程中，等待某个条件或来自其他线程的信号是常见需求。传统的等待方式，如耗费资源的**忙等（Busy-Waiting）**，会白白浪费 CPU 周期。Rust 提供了更优雅、更高效的解决方案：**线程挂起（Thread Parking）**。

我们将深入研究代码，展示如何结合 **`std::thread::park()`** 和 **`unpark()`** 机制，以及用于安全状态共享的 **`Arc<AtomicBool>`**。这种机制允许一个线程在没有任务时**优雅地暂停**，不消耗资源，并由另一个线程在需要时**精确地将其唤醒**。理解并运用这一低级别信号机制，是构建高性能、高响应度并发应用的关键一步。

掌握 Rust **线程挂起与唤醒**技巧，告别 **CPU 浪费**！本文实操演示如何用 `park()`/`unpark()` 和 **原子布尔值**，实现多线程间精确、高效、**非忙等**（Non-Busy Waiting）的信号传递。

## Rust 多线程：Thread Parking 线程挂起

### Thread Parking

- 当数据被多个线程修改时，常常会遇到需要等待某个事件，或者是等待数据满足某个条件的情况，然后才能继续往下执行。针对这种需要等待其它线程通知的需求有一种方法叫做线程挂起（thread parking）。
- 线程本身可以将自己挂起的(park)。这会让线程进入休眠状态（阻塞），从而不再消耗 CPU 资源。之后，另一个线程可以“唤醒”被挂起的线程（unpark），让它从休眠中醒来。
- 线程挂起：`std::thread::park()`
- 唤醒线程：需要在表示目标线程的 Thread 对象上调用 unpark() 方法

### 概念模型

- 每个 Thread handle 都关联一个 Token， 初始状态下这个 Token 是不存在的。
- 调用 `thread::park` 会阻塞当前线程，一直到 Token 对该线程 handle 可用。一旦 Token 可用，park 会原子性地消耗这个令牌并返回。但是注意，park 也可能会虚假返回（spurious wakeup），就是没有消耗令牌也可能返回。
- `thread::park_timeout` 与 park 类似，但允许指定一个最大阻塞时间。
- Unpark 方法会原子性地让 Token 可用（如果之前 Token 不存在的话）。
- 由于 Token 初始时是缺失的，所以如果先调用 unpark，再调用 park，会使得 park 这个调用立即返回。

### 内存顺序（Memory Ordering）

- 调用 unpark 会与 park 调用同步（syncchronize-with)。这意味着在调用 unpark 之前完成的所有内存操作，都可以被消耗 Token 并从 park 返回的线程看到。
- 对于同一个线程的所有 park 与 unpark 操作，它们之间形成一个全序关系（total order），并且所有之前的 unpark 操作都与后续的 park 调用同步。

### 从原子操作的内存角度

- unpark 执行的是 Release 操作
- park 执行的是与之对应的 Acquire 操作
- 同一个线程上的连续 unpark 调用构成一个 Release 序列

## 实操

### 创建项目

```rust
cargo new park
cd park
ls
```

### `main.rs` 文件

```rust
use std::{
    sync::{
        Arc,
        atomic::{AtomicBool, Ordering},
    },
    thread,
    time::Duration,
};

fn main() {
    let flag = Arc::new(AtomicBool::new(false));
    let flag2 = Arc::clone(&flag);

    let parked_thread = thread::spawn(move || {
        while !flag2.load(Ordering::Relaxed) {
            println!("Parking thread");
            thread::park();
            println!("Thread unparked");
        }
        println!("Flag received");
    });
    thread::sleep(Duration::from_millis(100));
    flag.store(true, Ordering::Relaxed);

    parked_thread.thread().unpark();
    parked_thread.join().unwrap();
}

```

这段 Rust 代码展示了线程间**低级别、高效的信号通信机制**，其核心是使用 **`Arc<AtomicBool>`** 来安全地在多个线程间共享一个可变的原子布尔标志。程序首先创建一个子线程，该线程进入一个循环，通过**原子操作（`load`）**检查共享的 `flag` 是否为真。如果 `flag` 仍为假，它会调用 **`thread::park()`** 将自己置于**休眠（Parking）**状态，从而高效地释放 CPU 资源，避免了耗费资源的忙等（busy-waiting）。与此同时，主线程短暂休眠后，将 `flag` **原子地设置为（`store`）** `true`，随后关键性地调用 **`parked_thread.thread().unpark()`** 方法来**唤醒（unpark）**正在休眠的子线程。子线程被唤醒后会立即重新检查 `flag`。一旦 `flag` 为真，循环终止，子线程打印出接收到信号的消息后安全退出，从而实现了主线程向子线程发送唤醒信号的**精确、非忙等**控制。

### 运行

```bash
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.02s
     Running `target/debug/park`
Parking thread
Thread unparked
Flag received
```

## 运行输出 (Output) 解释

这段输出揭示了主线程如何精确地控制和唤醒子线程，实现了高效的信号传递：

1. **`Parking thread`**：
   - 这段文本由子线程打印。它表明子线程成功启动，进入 `while` 循环，并通过 **`flag2.load(Ordering::Relaxed)`** 检查到共享的 `flag` 仍然是 `false`。
   - 紧接着，子线程调用了 **`thread::park()`**，使自己进入**休眠状态**，暂停执行并释放了它占用的 CPU 资源。
2. **（主线程活动 - 未显示输出）**：
   - 此时，主线程执行 **`thread::sleep(Duration::from_millis(100))`** 短暂等待，以确保子线程已经进入休眠状态。
   - 随后，主线程通过 **`flag.store(true, Ordering::Relaxed)`** 将原子布尔值设置为 `true`，准备退出循环。
   - 最关键的一步，主线程调用 **`parked_thread.thread().unpark()`**，向休眠的子线程发送**唤醒信号**。
3. **`Thread unparked`**：
   - 这是子线程被主线程成功 **`unpark()`** 唤醒后，继续执行打印出的文本。
   - 子线程被唤醒后，会**重新从 `thread::park()` 之后的位置开始执行**，它立即再次检查 `while !flag2.load(...)` 的条件。
4. **`Flag received`**：
   - 由于主线程此前已经将 `flag` 设置为 `true`，此时子线程重新检查循环条件 `while !true` 为假，循环终止。
   - 子线程退出循环，打印出 **`Flag received`**，并安全结束执行。

**总结来说，** 整个输出流程清晰地证明了 `park()` 和 `unpark()` 机制实现了**非忙等（Non-Busy Waiting）的线程协作**：子线程高效地等待信号，而主线程在发送信号后精确地将其唤醒，避免了不必要的 CPU 消耗。

## 总结

本次实践的核心价值在于展示了 Rust 如何通过其内置的并发原语实现**非忙等（Non-Busy Waiting）**的线程协作。我们成功地结合了 **`park()/unpark()`** 所依赖的 **Token 概念模型**和 **原子操作** (`load`/`store`)，建立了一个安全且高性能的同步屏障。

理解其底层机制至关重要：**`unpark()` 实际上执行的是 Release 操作，而 `park()` 执行的是对应的 Acquire 操作**。这种内存顺序保证了在主线程中对 `flag` 所做的修改（将其设置为 `true`）在子线程被唤醒后**立即可见**。掌握这一机制，对于希望超越标准互斥锁（Mutex）和通道（Channel）进行并发优化的 Rust 开发者来说，是至关重要的知识。

## 参考

- <https://rust-lang.org/zh-CN/>
- <https://course.rs/about-book.html>
- <https://github.com/rust-lang>
- <https://doc.rust-lang.org/book/>
