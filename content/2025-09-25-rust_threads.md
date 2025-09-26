+++
title = "Rust 并发编程三步曲：`Join`、`Arc<Mutex>` 与 `mpsc` 通道同步实战"
description = "Rust 并发编程三步曲：`Join`、`Arc<Mutex>` 与 `mpsc` 通道同步实战"
date = 2025-09-25T14:43:24Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust 并发编程三步曲：`Join`、`Arc<Mutex>` 与 `mpsc` 通道同步实战

并发编程是 Rust 的核心优势之一，但处理共享状态和线程通信一直是编程中的难点。Rust 凭借其**所有权系统**和独特的**同步原语**，让多线程编程变得安全且高效，彻底告别数据竞争和死锁等常见问题。

本文将通过三个从基础到进阶的实战示例，系统掌握 Rust 并发编程的三个核心环节：**任务的启动与结果同步**、**共享可变状态的安全更新**，以及 **MPSC 通道的消息传递与优雅退出**。我们将深入剖析 `thread::spawn`、`JoinHandle`、`Arc`、`Mutex` 和 `mpsc::channel` 的协作机制，助你在 Rust 的高并发世界中构建健壮的系统。

本文通过三个递进的 Rust 代码示例，全面解析了并发编程的关键实践。**示例一**展示了如何使用 `thread::spawn` 启动并发任务，并利用 **`JoinHandle::join()`** 阻塞主线程，实现任务的**同步与结果收集**。**示例二**聚焦于线程安全地共享可变状态，通过 **`Arc<Mutex<T>>`** 模式实现了原子计数器，确保对共享数据的**互斥访问**。**示例三**则深入 **`mpsc::channel`** 的消息传递模型，对比了两种实现通道关闭同步的有效方法：**`join()` 强制等待**和依赖 **`mpsc::Sender` 自动 `drop`** 的机制，完美演示了任务解耦与优雅退出。

## 实操

### 示例一

```rust
// threads1.rs
//
// This program spawns multiple threads that each run for at least 250ms, and
// each thread returns how much time they took to complete. The program should
// wait until all the spawned threads have finished and should collect their
// return values into a vector.

use std::thread;
use std::time::{Duration, Instant};

fn main() {
    let mut handles = vec![];
    for i in 0..10 {
        handles.push(thread::spawn(move || {
            let start = Instant::now();
            thread::sleep(Duration::from_millis(250));
            println!("thread {} is complete", i);
            start.elapsed().as_millis()
        }));
    }

    let mut results: Vec<u128> = vec![];
    for handle in handles {
        results.push(handle.join().unwrap());
    }

    if results.len() != 10 {
        panic!("Oh no! All the spawned threads did not finish!");
    }

    println!();
    for (i, result) in results.into_iter().enumerate() {
        println!("thread {} took {}ms", i, result);
    }
}
```

这段 Rust 代码演示了如何使用多线程来并行执行任务，并等待所有任务完成后收集结果。程序首先在一个循环中创建了十个独立的线程，使用 **`thread::spawn`** 启动，并将每个线程的 **`JoinHandle`** 句柄存储在一个向量 `handles` 中。在每个线程内部，它记录了开始时间，强制休眠 250 毫秒，然后计算并返回线程执行的总耗时（以毫秒为单位）。在主线程中，代码通过遍历 `handles` 向量，对每个句柄调用 **`handle.join().unwrap()`**。这个 `join` 方法会**阻塞主线程**，直到对应的子线程执行完毕，并获取其返回的结果值。最终，程序将所有线程的耗时结果收集到 `results` 向量中，验证了所有线程都已完成，并打印出每个线程的运行时间，展示了多线程编程中任务的并发执行与结果同步。

### 示例二

```rust
// threads2.rs
//
// Building on the last exercise, we want all of the threads to complete their
// work but this time the spawned threads need to be in charge of updating a
// shared value: JobStatus.jobs_completed

use std::sync::Arc;
use std::sync::Mutex;
use std::thread;
use std::time::Duration;

struct JobStatus {
    jobs_completed: u32,
}

fn main() {
    let status = Arc::new(Mutex::new(JobStatus { jobs_completed: 0 }));
    let mut handles = vec![];
    for _ in 0..10 {
        let status_shared = Arc::clone(&status);
        let handle = thread::spawn(move || {
            thread::sleep(Duration::from_millis(250));
            let mut status = status_shared.lock().unwrap();
            status.jobs_completed += 1;
        });
        handles.push(handle);
    }
    for handle in handles {
        handle.join().unwrap();
        let status = status.lock().unwrap();
        println!("jobs completed {}", status.jobs_completed);
    }
}

```

这段 Rust 代码展示了如何在多线程环境中**安全地更新共享的可变数据**，主要依赖于 **`Arc<T>`** 和 **`Mutex<T>`** 这两种智能指针。程序创建了一个包含 `jobs_completed` 计数器的 `JobStatus` 结构体，并用 **`Mutex`** 将其包裹以确保**互斥访问（Mutual Exclusion）**，再用 **`Arc`** 将这个锁定的数据指针安全地**共享给多个线程**。在循环中，代码启动了十个线程，每个线程都通过 **`Arc::clone`** 获取共享数据的所有权。在子线程中，在修改 `jobs_completed` 之前，必须先调用 **`.lock().unwrap()`** 来获取锁，从而获得**独占的可变访问权**；一旦计数器更新完毕，锁就会自动释放。最后，主线程通过对每个线程句柄调用 **`.join()`** 来等待所有线程完成，并在每次等待完成后打印出当前的完成任务数，以此来同步并展示共享变量的最终状态。

### 示例三

```rust
// threads3.rs

use std::sync::mpsc;
use std::sync::Arc;
use std::thread;
use std::time::Duration;

struct Queue {
    length: u32,
    first_half: Vec<u32>,
    second_half: Vec<u32>,
}

impl Queue {
    fn new() -> Self {
        Queue {
            length: 10,
            first_half: vec![1, 2, 3, 4, 5],
            second_half: vec![6, 7, 8, 9, 10],
        }
    }
}

// 方式一
fn send_tx(q: Queue, tx: mpsc::Sender<u32>) -> () {
    let qc = Arc::new(q);

    let qc1 = Arc::clone(&qc);
    let qc2 = Arc::clone(&qc);

    let tx1 = tx.clone();

    let handle1 = thread::spawn(move || {
        for val in &qc1.first_half {
            println!("sending {:?}", val);
            tx1.send(*val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });

    let handle2 = thread::spawn(move || {
        for val in &qc2.second_half {
            println!("sending {:?}", val);
            tx.send(*val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });

    handle1.join().unwrap();
    handle2.join().unwrap();
}

fn main() {
    let (tx, rx) = mpsc::channel();
    let queue = Queue::new();
    let queue_length = queue.length;

    send_tx(queue, tx);

    let mut total_received: u32 = 0;
    for received in rx {
        println!("Got: {}", received);
        total_received += 1;
    }

    println!("total numbers received: {}", total_received);
    assert_eq!(total_received, queue_length)
}


// 方式二
fn send_tx(q: Queue, tx: mpsc::Sender<u32>) -> () {
    let qc = Arc::new(q);

    let qc1 = Arc::clone(&qc);
    let qc2 = Arc::clone(&qc);

    let tx1 = tx.clone();

    thread::spawn(move || {
        for val in &qc1.first_half {
            println!("sending {:?}", val);
            tx1.send(*val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });

    let tx2 = tx.clone();
    thread::spawn(move || {
        for val in &qc2.second_half {
            println!("sending {:?}", val);
            tx2.send(*val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });
}
```

这段 Rust 代码的核心是利用 **`mpsc::channel`**（多生产者、单消费者通道）和 **`Arc`**（原子引用计数）来实现多线程间的数据安全传输和同步。

#### 核心功能与机制

程序首先创建了一个 `Queue` 结构体，其中包含两组数字。**`Arc`** 智能指针用于安全地将 `Queue` 数据共享给多个子线程，使它们能够并发地作为数据的**生产者**。主线程则作为**消费者**，通过 `for received in rx` 循环来接收所有发送的数据。

为了确保接收端 `rx` 在所有数据发送完毕后能够**优雅退出**（即知道通道已关闭），代码提出了两种不同的发送端管理方式：

1. **方式一：利用 `handle.join()` 强制同步**
   - **原理：** 在 `send_tx` 函数内部，通过对两个线程句柄调用 **`join()`**，强制**阻塞** `send_tx` 函数的执行，直到两个子线程完成发送并退出。这确保了在 `send_tx` 返回主线程之前，所有子线程中的 `mpsc::Sender` 实例（`tx1` 和原始 `tx`）都已经被销毁（`drop`）。这是最**可靠**、逻辑最**清晰**的同步方式，因为它明确保证了函数返回时通道已关闭。
2. **方式二：利用 `tx` 实例的自动 `drop` 退出**
   - **原理：** 在 `send_tx` 内部，创建了两个发送端克隆（`tx1` 和 `tx2`）并分别移动到两个子线程，而**原始传入的 `tx` 实例被闲置**。当 `send_tx` 函数执行结束返回时，这个闲置的**原始 `tx` 会立即被自动销毁**。一旦所有三个发送端（原始 `tx`、`tx1`、`tx2`）都销毁后，`rx` 就会收到通道关闭信号并退出循环。这种方式**避免了阻塞**，代码更简洁，但其正确性依赖于子线程能够在主线程接收数据期间完成工作。

最终，无论是哪种方式，主线程都能顺利接收到 10 个数字，然后循环退出，并执行最后的 `assert_eq!` 验证总接收数量，完美展示了多线程协作与通道关闭的机制。

## 总结

这三个示例涵盖了 Rust 并发编程的三个关键支柱：**线程管理**、**状态共享**和**消息传递**。

1. **任务同步：** 通过 **`handle.join()`** 机制，确保主线程在子线程工作完成时进行同步，安全地获取并收集返回结果。
2. **状态共享：** 针对共享的可变数据，**`Arc<Mutex<T>>`** 是 Rust 中提供线程安全共享的标准模式，`Mutex` 保证了同一时间只有一个线程能进行修改。
3. **通道同步：** **`mpsc::channel`** 提供了线程间通信的解耦方案。通过精确管理所有 **`mpsc::Sender`** 实例的生命周期（确保它们最终被 `drop`），可以通知接收端通道关闭，实现程序循环的优雅退出。

掌握这些并发原语，你就掌握了 Rust 语言在构建高性能、高可靠性并发系统时的核心能力。

## 参考

- **Rust 程序设计语言：** <https://kaisery.github.io/trpl-zh-cn/>
- **通过例子学 Rust：** <https://rustwiki.org/zh-CN/rust-by-example/>
- **Rust 语言圣经：** <https://course.rs/about-book.html>
- **Rust 秘典：** <https://nomicon.purewhite.io/intro.html>
- **Rust 算法教程：** <https://algo.course.rs/about-book.html>
- **Rust 参考手册：**<https://rustwiki.org/zh-CN/reference/introduction.html>
