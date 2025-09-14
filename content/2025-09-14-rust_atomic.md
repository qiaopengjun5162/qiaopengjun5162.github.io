+++
title = "深入浅出：Rust 原子类型与多线程编程实践"
description = "深入浅出：Rust 原子类型与多线程编程实践"
date = 2025-09-14T02:17:47Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# **深入浅出：Rust 原子类型与多线程编程实践**

在现代软件开发中，充分利用多核 CPU 的性能至关重要。然而，在多线程环境中共享数据，一不小心就可能引入棘手的数据竞争问题。Rust 以其出色的内存安全机制而闻名，但它如何解决多线程下的并发挑战呢？答案就是：**原子类型（Atomic Types）**。本文将带你深入探索 Rust 的原子操作，通过实际代码案例，为你揭示如何安全、高效地在线程间共享数据，并解决那些看似简单的并发陷阱。

本文系统介绍了 Rust 的原子类型和原子操作。从基础的不可分割性概念，到 `load/store`、`fetch-modify` 和 `compare-exchange` 等核心操作，文章通过三个实际代码示例，详细演示了如何安全地在多线程中共享计数器。此外，本文还深入解析了原子内存排序的意义，并揭示了 `load/store` 非原子操作可能导致的问题，展示了 `compare_exchange` 的强大之处，最终为读者提供了多线程编程的最佳实践。

## Rust 多线程：Atomics 原子性

### Atomic Type 原子类型

原子类型（Atomic Type）提供线程之间原始的共享内存通信机制，是其他并发类型的基础构件

### Atomic Operations 原子操作

Atomic：不可分割的操作，要么执行完了，要么还没发生，它不存在一个中间的状态，比如说执行一半这个状态它是不存在的，或者更准确的说它这个中间状态对外是不可见的。

原子操作允许不同线程安全地读取和修改同一个变量。

原子操作是并发编程的基础。

所有高级并发工具都是通过原子操作实现的。

### 原子类型 Atomic Types

位于 `std::sync::atomic`，以 Atomic 开头。例如：AtomicBool、AtomicIsize、AtomicUsize、AtomicI8、AtomicU16...

内部可变性，允许通过共享引用进行修改（例如 &AtomicUsize）

相同的接口：加载与存储（load/store）、获取并修改（fetch-modify）、比较并交换（compare-exchange）

### Load & Store 加载 & 存储

- load：以原子方式加载原子变量中存储的值。`pub fn load(&self, order: Ordering) -> usize`
- store：以原子方式将新值存入变量。`pub fn store(&self, val: usize, order: Ordering)`

### Atomic Memory Ordering 原子内存排序

```rust
#[non_exhaustive]
pub enum Ordering {
  Relaxed,
  Release,
  Acquire,
  AcqRel,
  SeqCst,
}
```

- 内存排序用于指定原子操作如何同步内存
- Relaxed -- 最弱保证。含义：只保证这个操作是原子的，没有对排序的约束。适合场景：只关心“计数正确”，而不关心不同线程之间的操作顺序（例如：一个全局统计计数器，线程只需要把值加一）

### Fetch Modify 获取 & 修改

```rust
fetch_add
fetch_and
fetch_max
fetch_min
fetch_nand
fetch_or
fetch_sub
fetch_update
fetch_xor
```

- `fetch_modify`：修改原子变量、同时获取（Fetch）其原始值、整个过程是单一的原子操作

### 示例一

```rust
use std::{
    sync::atomic::{AtomicUsize, Ordering},
    thread,
    time::Duration,
};

fn main() {
    let done = AtomicUsize::new(0);

    thread::scope(|s| {
        for t in 0..10 {
            s.spawn(|| {
                for i in 0..100 {
                    thread::sleep(Duration::from_millis(20));
                    let current = done.load(Ordering::Relaxed);
                    done.store(current + 1, Ordering::Relaxed);
                }
            });
        }

        loop {
            let n = done.load(Ordering::Relaxed);
            if n == 1000 {
                break;
            }
            println!("Progress: {n}/1000 done!");
            thread::sleep(Duration::from_secs(1));
        }
    });

    println!("All done!");
}

```

这段 Rust 代码演示了如何在多线程环境下，使用原子类型 `AtomicUsize` 安全地追踪任务进度。

### 代码解释

### 1. 原子类型 `AtomicUsize`

代码首先创建了一个名为 `done` 的 **`AtomicUsize`** 类型变量。`AtomicUsize` 是一种特殊的整数类型，它提供了原子操作，这意味着即使在多个线程同时对其进行读写时，也能保证操作的完整性，不会出现数据竞争。这是实现多线程安全计数的关键。

#### 2. 创建并运行线程

在 `thread::scope` 块中，程序启动了10个独立的线程。每个线程都执行一个任务：

- 线程会循环100次。
- 在每次循环中，线程会暂停20毫秒，模拟一个耗时操作。
- 随后，它会执行一个原子操作：首先使用 **`load(Ordering::Relaxed)`** 读取 `done` 的当前值，然后将该值加1，最后使用 **`store(current + 1, Ordering::Relaxed)`** 将新值写回 `done`。

### 3. 主线程监控进度

与此同时，主线程进入一个 `loop` 循环，它的作用是监控任务进度：

- 主线程每隔1秒，会使用 **`done.load(Ordering::Relaxed)`** 操作，非阻塞地读取 `done` 的当前值。
- 它将读取到的值打印出来，显示当前已完成的任务数量，形成一个进度条效果。
- 当 `done` 的值达到1000（10个线程 * 100次循环）时，主线程跳出循环并结束程序。

### 4. 内存排序 `Ordering::Relaxed`

代码中使用的 `Ordering::Relaxed` 是最弱的内存排序模型。它只保证原子操作本身是不可分割的，但不保证不同线程之间操作的顺序。在这个例子中，我们只需要保证每个线程对 `done` 的加1操作是正确的，而不需要关心这些加1操作在时间上的具体顺序，因此 `Relaxed` 就可以了。这使得编译器可以进行更多的优化，从而获得更好的性能。

总而言之，这段代码通过 `AtomicUsize` 成功地实现了多个线程并行执行任务，而主线程则可以安全、实时地监控所有任务的总体完成进度。

### 运行

```bash
➜ cargo run
warning: unused variable: `t`
  --> src/main.rs:11:13
   |
11 |         for t in 0..10 {
   |             ^ help: if this is intentional, prefix it with an underscore: `_t`
   |
   = note: `#[warn(unused_variables)]` on by default

warning: unused variable: `i`
  --> src/main.rs:13:21
   |
13 |                 for i in 0..100 {
   |                     ^ help: if this is intentional, prefix it with an underscore: `_i`

warning: `atomic_demo` (bin "atomic_demo") generated 2 warnings
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/atomic_demo`
Progress: 0/1000 done!
Progress: 418/1000 done!
Progress: 843/1000 done!
Progress: 995/1000 done!
Progress: 995/1000 done!
Progress: 995/1000 done!
Progress: 995/1000 done!
Progress: 995/1000 done!
Progress: 995/1000 done!
Progress: 995/1000 done!
Progress: 995/1000 done!
Progress: 995/1000 done!
Progress: 995/1000 done!
Progress: 995/1000 done!
Progress: 995/1000 done!
^C
```

我们可以看到运行之后它跑到 995 就不跑了，这是因为在这段代码`thread::sleep(Duration::from_millis(20));
let current = done.load(Ordering::Relaxed);
done.store(current + 1, Ordering::Relaxed);`中，在每个线程里面每一个任务它这个整体的操作不是原子性的。它把这个读和写分成了两步。所以就有可能出现同时读取，但一个先更新一个后更新把原来的覆盖了。这种情况应该发生了5次，所以它的结果是 995。

现在我们只需要把这两步变成一步单一的原子操作，就应该不会出现问题 了。

### 示例二

```rust
use std::{
    sync::atomic::{AtomicUsize, Ordering},
    thread,
    time::Duration,
};

fn main() {
    let done = AtomicUsize::new(0);

    thread::scope(|s| {
        for _ in 0..10 {
            s.spawn(|| {
                for _ in 0..100 {
                    thread::sleep(Duration::from_millis(20));
                    // let current = done.load(Ordering::Relaxed);
                    // done.store(current + 1, Ordering::Relaxed);

                    done.fetch_add(1, Ordering::Relaxed);
                }
            });
        }

        loop {
            let n = done.load(Ordering::Relaxed);
            if n == 1000 {
                break;
            }
            println!("Progress: {n}/1000 done!");
            thread::sleep(Duration::from_secs(1));
        }
    });

    println!("All done!");
}
```

这段 Rust 代码演示了如何使用**原子类型（Atomic types）**在多线程环境中安全地追踪任务进度。程序创建了一个名为 `done` 的 `AtomicUsize` 变量来安全地共享一个计数器，因为原子类型可以确保即使在多个线程同时访问时也不会发生数据竞争。它在 `thread::scope` 中启动了 10 个线程，每个线程都模拟执行 100 个耗时任务，并通过调用 `done.fetch_add(1, Ordering::Relaxed)` 原子地增加计数器。主线程则进入一个循环，每秒钟非阻塞地读取 `done` 的值并打印进度，直到总数达到 1000 时，所有线程的任务都已完成，主线程退出循环并结束程序。这种模式在多任务并行处理中非常常见，确保了任务计数的准确性。

### 运行

```bash
➜ cargo run
   Compiling atomic_demo v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/atomic_demo)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.55s
     Running `target/debug/atomic_demo`
Progress: 0/1000 done!
Progress: 420/1000 done!
Progress: 848/1000 done!
All done!
```

整个过程是单一的原子操作。

### Compare Exchange 比较和交换

```rust
pub fn compare_exchange(
  &self,
  current: usize,
  new: usize,
  success: Ordering,
  failure: Ordering,
) -> Result<usize, usize>
```

- `compare_exchange`：会检查原子值是否等于给定的值（current 参数），如果相等，就用新值（new 参数）替换它，否则不做任何修改，整个过程是单一原子操作。它会返回之前的值，并告诉我们是否替换成功。

#### 为什么说 compare_exchange 很强大？

- 你可以用它来实现几乎所有的其它原子操作，例如 fetch_add、fetch_sub 等。
- 只需在一个循环中不断尝试，直到成功为止。这种模式叫做 CAS loop （Compare-And-Swap 循环）

### 示例三

```rust
use std::{
    sync::atomic::{AtomicUsize, Ordering},
    thread,
};

fn main() {
    let counter = AtomicUsize::new(0);

    thread::scope(|s| {
        for _ in 0..1000 {
            s.spawn(|| {
                incr(&counter);
            });
        }
    });

    println!("Counted: {}", { counter.load(Ordering::Relaxed) });
}

fn incr(counter: &AtomicUsize) {
    let mut current = counter.load(Ordering::Relaxed);
    loop {
        let new = current + 1;
        match counter.compare_exchange(current, new, Ordering::Relaxed, Ordering::Relaxed) {
            Ok(_) => return,
            Err(v) => {
                println!("value changed {current} -> {v}");
                current = v;
            }
        }
    }
}

```

这段 Rust 代码展示了如何利用**原子类型（Atomic types）\**在多线程环境下安全地对一个计数器进行递增操作。它创建了一个名为 `counter` 的 `AtomicUsize` 变量作为共享计数器，然后通过 `thread::scope` 启动了 1000 个线程。每个线程都调用 `incr` 函数，该函数使用一个\**循环**和 `compare_exchange` 方法来尝试递增计数器。`compare_exchange` 会比较计数器的当前值（`current`）是否与它期望的值相同，如果相同就将其更新为新值（`new`），这个过程是原子性的。如果另一个线程抢先更新了计数器，`compare_exchange` 就会失败并返回新的值（`Err(v)`），`incr` 函数则会打印出冲突并用新值重新尝试，直到成功递增为止，这种模式被称为**自旋锁**。最后，主线程会加载并打印出计数器的最终值，该值将是精确的 1000。

### 运行

```bash
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.03s
     Running `target/debug/atomic_demo`
Counted: 1000

RustJourney/atomic_demo on  main [?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/atomic_demo`
value changed 1 -> 2
value changed 2 -> 3
Counted: 1000
```

### A -> B -> A 问题

读取出来的值中间可能变了， 变成其它的值，然后又变回来了。

- 如果原子值从A 变成 B，又变回A，在你调用 compare_exchange 之前，你是无法察觉这个变化的。
- 虽然值看起来没变，但它确实经历了变化
- 这在某些算法中可能导致严重问题，例如涉及原子指针的复杂算法

### compare_exchange_weak 更轻量但可能失败

- 即使值匹配，weak 版本也可能返回失败（Err），即所谓的“伪失败（spurious failure）”
- 这个方法在某些平台上会更高效
- 如果失败的代价不大（例如简单的重试循环），推荐优先使用 weak 版本

## 总结

通过本文的学习，我们不仅掌握了 Rust 原子类型的基本概念，更重要的是，通过实践深入理解了原子操作在多线程编程中的关键作用。我们亲眼见证了简单的 `load/store` 组合可能引发的数据竞争问题，并通过使用 `fetch_add` 或更强大的 `compare_exchange` 方法，成功解决了这些并发难题。原子类型是 Rust 安全并发的基石，掌握了它们，你就能在多线程的世界中自信地编写出高性能、无数据竞争的代码。

## 参考

- <https://paxonqiao.com/>
- <https://rustcc.cn/>
- <https://www.rust-lang.org/>
- <https://github.com/rust-lang/rust>
