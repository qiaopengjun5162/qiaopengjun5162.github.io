+++
title = "Rust异步编程实战：彻底搞懂并发、并行与Tokio任务调度"
description = "Rust异步编程实战：彻底搞懂并发、并行与Tokio任务调度"
date = 2025-11-01T05:16:23Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# **Rust异步编程实战：彻底搞懂并发、并行与Tokio任务调度**

随着多核时代的到来，如何高效利用系统资源成为现代编程的关键挑战。在 Rust 语言中，异步编程（Async Rust）凭借其零成本抽象和卓越的性能，成为了构建高并发系统的首选方案。然而，初学者常常混淆“并发”与“并行”，也不清楚强大的 Tokio 运行时是如何调度和管理任务的。本文将从底层定义出发，通过厨房做饭的生动类比，并结合具体的 Rust 代码示例和运行结果分析，彻底解析异步 Rust 中的并发、并行以及 `tokio::join!`、`JoinSet` 等核心机制，带您领略高效任务调度的奥秘。

本文深入探讨 Rust 异步编程中的并发（逻辑同时）与并行（物理同时）的区别，并通过厨师类比助您理解。文章基于 Tokio 运行时，详解了 `async/await` 的挂起/恢复机制，并结合多个 Rust 代码示例，分析了 `tokio::spawn`、`tokio::join!` 和 `JoinSet` 如何实现高效任务调度和并发管理。内容涵盖 CPU 密集型任务的阻塞影响及 `yield_now` 的公平调度作用，是理解 Rust 高性能异步设计的实战指南。

## Async Rust - 并发 VS 并行

并发 VS 并行 Concurrency vs Parallelism  Async Rust

### 并发 VS 并行

![image-20251029175354104](/images/image-20251029175354104.png)

## 🧩 一、定义对比

| 概念                   | 含义                                                         | 核心关注点             |
| ---------------------- | ------------------------------------------------------------ | ---------------------- |
| **并发 (Concurrency)** | 在同一时间段内，系统可以同时处理多个任务的“**逻辑结构**”。这些任务可能是交替执行的。 | “任务之间如何协调切换” |
| **并行 (Parallelism)** | 在同一时刻，系统真的在“**物理上**”同时执行多个任务（例如多个 CPU 核同时运行）。 | “任务是否真正同时执行” |

📖 简单说：

> 并发是「**看起来同时**」，
> 并行是「**真的同时**」。

------

## 🧠 二、类比理解

想象你在厨房做饭 🍳：

- **并发**：你一个人炒菜、煮汤、蒸饭。你在三个任务之间来回切换。虽然是一个人，但三个任务“看起来”在同时进行。
- **并行**：你和朋友三个人，各自负责炒菜、煮汤、蒸饭，真的在同时进行。

👉 所以：

> 并发 = 切换快，看起来同时。
> 并行 = 多人多核，真正同时。

------

## ⚙️ 三、技术层面区别

| 项目              | 并发 (Concurrency)                       | 并行 (Parallelism)         |
| ----------------- | ---------------------------------------- | -------------------------- |
| **目的**          | 提高任务的响应性                         | 提高程序的执行速度         |
| **实现方式**      | 时间片轮转、协程、异步 I/O               | 多核 CPU、多线程、GPU 计算 |
| **是否同时执行**  | 逻辑上同时，物理上交替                   | 真正同时                   |
| **关键技术**      | 异步编程、事件循环（如 Node.js、Tokio）  | 多线程、分布式计算         |
| **典型语言/框架** | Python asyncio、Go goroutine、Rust async | C++ OpenMP、CUDA、Ray      |
| **瓶颈**          | 调度开销、共享资源竞争                   | 线程数、核数、内存带宽     |

------

## 💻 四、例子说明

### 1️⃣ 并发（单核异步）

```python
import asyncio

async def task(name, delay):
    await asyncio.sleep(delay)
    print(f"{name} done")

async def main():
    await asyncio.gather(
        task("A", 2),
        task("B", 1),
        task("C", 3)
    )

asyncio.run(main())
```

🔹 实际上是单核运行，通过 **协程切换** 实现“同时”执行的效果。
 🔹 这就是并发：**交替执行**。

------

### 2️⃣ 并行（多核线程）

```python
from multiprocessing import Pool
import time

def task(n):
    time.sleep(2)
    return n*n

if __name__ == "__main__":
    with Pool(4) as p:
        results = p.map(task, [1,2,3,4])
    print(results)
```

🔹 使用 4 个 CPU 核同时执行任务。
 🔹 这是真正的 **并行**：**物理同时执行**。

------

## 🔗 五、并发与并行的关系

> 并行 ⊂ 并发

也就是说：

- 并发是一种**设计思想**；
- 并行是一种**执行方式**；
- 有并发，不一定有并行；
- 但有并行，必然也是并发的一种表现。

📊 形象图：

```
          并发 (Concurrency)
        ┌──────────────────────┐
        │                      │
        │   并行 (Parallelism) │
        │     ← 子集关系       │
        └──────────────────────┘
```

------

## 🚀 六、总结一句话记忆法

| 关键词       | 口诀                                   |
| ------------ | -------------------------------------- |
| **并发**     | “我一个人做多件事”——切换快，看起来同时 |
| **并行**     | “我找多人同时干”——真正在同时执行       |
| **关系**     | 并行是并发的实现方式之一               |
| **典型应用** | 并发→异步 I/O；并行→多核加速           |

## 异步挂起/恢复 Async Suspend/Resume

异步挂起/恢复（Async Suspend/Resume）是指在异步执行中，当任务遇到无法立即完成的操作时暂停执行（挂起），待条件满足后再从暂停点继续执行（恢复），以实现高效的并发处理。

## 系统线程 VS 绿色线程 OS Threads VS Green Threads Async Rust

### 示例一

```rust
async fn hello() {
    println!("Hello, world!");
}

async fn run() {
    for i in 0..10 {
        println!("{i}");
    }
}

#[tokio::main]
async fn main() {
    tokio::spawn(run());
    hello().await;
}

```

这段 Rust 代码展示了**异步编程**的基本用法，使用了流行的异步运行时 **Tokio**。

### 详细解释

1. **`async fn hello()`** 和 **`async fn run()`**:
   - `async fn` 关键字定义了**异步函数**。调用这些函数并不会立即执行它们里面的代码，而是返回一个表示**异步操作**的**Future**（一个尚未完成的计算）。
   - `hello` 函数非常简单，它会打印一次 "Hello, world!"。
   - `run` 函数会执行一个简单的循环，打印数字 $0$ 到 $9$。
2. **`#[tokio::main]`**:
   - 这是一个 **Tokio 提供的宏**，用于标记程序的**入口点** `main` 函数。
   - 它将 `async fn main()` 转换为一个**同步的 `main` 函数**，这个同步 `main` 函数负责**初始化 Tokio 异步运行时（Runtime）**，然后在这个运行时上**执行**异步的 `main` 函数体。
   - **异步运行时**是执行和调度异步任务（Future）的核心组件。
3. **`async fn main()`**:
   - 这是程序的逻辑起点。
   - **`tokio::spawn(run());`**:
     - `tokio::spawn()` 是 Tokio 运行时提供的方法，用于在**异步运行时**上**启动一个新的异步任务**（一个 Future）。
     - 这里它接收 `run()` 返回的 Future，并将其**非阻塞地**调度到后台运行。这意味着 `run` 函数中的循环将与主任务（`main` 函数的其余部分）**并发**执行。
     - `tokio::spawn()` 立即返回一个**JoinHandle**，但代码中没有接收或使用它。
   - **`hello().await;`**:
     - `hello()` 调用返回一个 Future。
     - `.await` 运算符用于**暂停**当前异步任务（这里是 `main` 函数）的执行，**等待**它所修饰的 Future（`hello()` 的结果）完成。
     - 当 `hello()` 完成（即打印出 "Hello, world!"）后，`main` 函数才会继续执行。
     - **注意**: **`await` 只在 `async` 函数/块内使用**。

### 总结执行流程

1. 程序启动，`#[tokio::main]` 宏初始化 Tokio 运行时并开始执行 `async main`。
2. **`tokio::spawn(run());`**：`run` 任务（打印 $0-9$）被提交给运行时，**开始在后台并发执行**。
3. **`hello().await;`**：`main` 任务暂停，等待 `hello` 函数执行完毕（打印 "Hello, world!"）。
4. 在 `main` 任务等待时，**Tokio 运行时可以切换到执行其他任务**，例如**并发运行的 `run` 任务**。
5. `hello` 任务执行完毕后，`main` 任务恢复，程序结束。

由于 `run` 是**并发**执行的，因此 `run` 中打印的数字 $0-9$ 和 `hello` 中打印的 "Hello, world!" 在控制台的**出现顺序是不确定的**，取决于 Tokio 运行时对这两个任务的调度情况。`run` 任务可能会在 "Hello, world!" 之前、之后或中间穿插打印。

### 运行

```bash
➜ cargo run
   Compiling scopeguard v1.2.0
   Compiling smallvec v1.15.1
   Compiling cfg-if v1.0.4
   Compiling bytes v1.10.1
   Compiling pin-project-lite v0.2.16
   Compiling libc v0.2.177
   Compiling lock_api v0.4.14
   Compiling parking_lot_core v0.9.12
   Compiling mio v1.1.0
   Compiling signal-hook-registry v1.4.6
   Compiling socket2 v0.6.1
   Compiling parking_lot v0.12.5
   Compiling tokio v1.48.0
   Compiling rust_os_threads v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rust_os_threads)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 3.17s
     Running `target/debug/rust_os_threads`
Hello, world!
0
1
2
3
4
5
6
7
8
9
```

### 💻 运行结果解释

#### 1. 编译阶段 (Compiling & Finished)

这是 Rust 的构建工具 **`cargo`** 执行 **`cargo run`** 命令时首先完成的工作：

- **`Compiling ...`**: 这一系列行表示 **Cargo 正在编译项目及其依赖项**。由于您的代码使用了 `#[tokio::main]`，它依赖于 **Tokio 运行时**，因此 Cargo 会编译如 `tokio`、`mio`、`bytes` 等一系列相关的异步和低级系统库。
- **`Compiling rust_os_threads v0.1.0 (...)`**: 这是在编译您的**本地项目**（项目名称为 `rust_os_threads`）。
- **`Finished ... target(s) in 3.17s`**: 表示编译过程成功完成，生成了调试版本 (`dev` profile) 的可执行文件。

#### 2. 运行阶段 (Running & Output)

编译成功后，Cargo 接着执行生成的可执行文件：

- **`Running target/debug/rust_os_threads`**: Cargo 启动了编译好的程序。
- **`Hello, world!`**: 这是由您的 **`hello()`** 异步函数打印的输出。在 `main` 函数中，`hello().await;` 会确保这个任务完成。
- **`0` 到 `9`**: 这是由您的 **`run()`** 异步函数打印的输出。在 `main` 函数中，`tokio::spawn(run());` 将此任务**并发地**调度到后台。

**关键点在于输出的顺序：**

程序首先等待 `hello().await` 完成，因此 **`Hello, world!`** 被打印出来。然后，由于 **`run` 任务是并发运行的**，Tokio 运行时在执行 `hello` 和等待其完成的过程中，也同时调度了 `run` 任务。在这个特定的运行实例中，**`run` 任务在 `hello` 任务完成后才开始或继续执行**，所以打印 $0$ 到 $9$ 的循环是在 `Hello, world!` 之后连续完成的。如果调度顺序不同，`0-9` 的输出可能会出现在 `Hello, world!` 之前或中间。

| 系统线程 OS Threads                     | 绿色线程 Green Threads                        |
| --------------------------------------- | --------------------------------------------- |
| 更高效的利用多 CPU / 核                 | 轻量，开销小                                  |
| 开销更大：Context Switching，资源管理等 | 不依靠额外机制的话，难以高效利用多 CPU / 内核 |
| 创建大量 OS 线程会导致资源紧张          | 轻松创建成千上万，乃至百万级的并发任务        |
| 每个线程需要大量的内存                  | 更具扩展性，高并发                            |
| 阻塞操作，OS 来处理                     | 由运行时更高效的处理阻塞操作                  |
| 不同 OS 间的行为、性能可能差距很大      | 不同平台间一致的并发模型                      |

## Async Rust - Tokio：spawn join! yield_now

### 示例二

```rust
async fn hello() {
    for i in 0..10000 {
        let _ = i * 25;
    }
    println!("Hello, world!");
}

async fn run() {
    for i in 0..10 {
        println!("{i}");
    }
}

#[tokio::main]
async fn main() {
    tokio::spawn(run());
    hello().await;
}

```

### 💻 代码解释

- **`async fn run()`**: 这是一个**非密集型**异步任务，它会打印数字 $0$ 到 $9$。
- **`async fn hello()`**: 这是一个**伪 CPU 密集型**异步任务。它包含一个**非常大的同步循环**（$0$ 到 $9999$ 次计算），此循环在没有任何 `await` 的情况下运行，因此它是**不可中断**的。循环完成后，它才打印 `"Hello, world!"`。
- **`#[tokio::main] async fn main()`**: 这是程序入口点。
  - **`tokio::spawn(run());`**: 将 **`run` 任务**提交给 Tokio 运行时，使其在后台**并发**运行。
  - **`hello().await;`**: **`main` 任务**暂停，并等待 **`hello` 任务**完成。

### 运行结果预期解释

由于 `hello()` 任务在打印之前执行了一个**巨大的同步循环，且循环内部没有 `.await` 让出控制权**，Tokio 运行时**无法在循环执行期间切换到其他任务**。这意味着，尽管 `run()` 任务被并发地 `spawn` 到了后台，但它必须等待 **`hello` 函数中的那段 CPU 密集型同步代码执行完毕**。

因此，这段代码的运行结果几乎总是：

1. **`hello` 任务**中的**同步大循环**会首先**完全执行**（这个过程耗时，但不会有任何输出）。
2. 循环结束后，**`hello` 任务**会打印 **`Hello, world!`**。
3. 一旦 `hello` 任务完成并**让出控制权**（通过 `hello().await;`），Tokio 运行时才有机会充分执行或完成 **`run` 任务**。
4. 紧接着，**`run` 任务**才会打印出完整的数字序列 **$0$ 到 $9$**。

**结论**：这个例子强调了在 Rust 异步编程中，**长时间运行的同步代码（CPU 密集型计算）会阻塞执行任务的线程，从而影响异步并发调度的效果**。如果要在异步代码中执行大量计算，通常需要将计算**移入单独的线程池**（例如使用 `tokio::task::spawn_blocking`）或在计算中使用异步 I/O 操作来**主动让出控制权**。

### 运行

```bash
➜ cargo run
   Compiling rust_os_threads v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rust_os_threads)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.84s
     Running `target/debug/rust_os_threads`
0
1
2
3
4
5
6
7
8
9
Hello, world!
```

### 💻 运行结果解释

- **编译阶段** (`Compiling...Finished...`)：这部分是 Rust 构建工具 **`cargo`** 编译您的项目及其依赖项的过程，表示编译成功。
- **运行阶段** (`Running...` 及输出)：这是程序实际执行的结果。

**关键点在于输出的顺序：**

1. 在 `main` 函数中，**`tokio::spawn(run());`** 将打印 $0$ 到 $9$ 的 **`run` 任务**提交给 Tokio 运行时，让它**非阻塞地**在后台开始执行。
2. 紧接着，**`hello().await;`** 被调用。虽然 `hello` 任务内部包含一个**巨大的同步循环**，但在 **`main` 任务**等待它完成（`await`）时，**Tokio 运行时会利用这段时间执行其他已经准备好的任务**，即**并发运行的 `run` 任务**。
3. 在这个特定的运行实例中，**`run` 任务（打印 $0$ 到 $9$）被调度并迅速执行完毕**，因此 **$0$ 到 $9$** 序列首先被打印出来。
4. 当 `run` 任务完成后，或者 `hello` 任务中的同步大循环**终于执行完毕**时，`hello` 任务才能打印出它的最终输出 **`Hello, world!`**。

**结论**：这个结果表明，尽管 `hello` 任务内部有阻塞执行的同步代码，但 **`run` 任务的启动和完成速度比 `hello` 任务的大循环要快**。因此，Tokio 运行时在等待 `hello` 任务完成时，**优先并完成了 `run` 任务**，实现了任务之间的**并发执行**，使得 **$0-9$ 的输出出现在 `Hello, world!` 之前**。

### 示例三

```rust
async fn add(a: i32, b: i32) -> i32 {
    println!("{a} + {b} = {}", a + b);
    a + b
}

#[tokio::main]
async fn main() {
    let result = tokio::join!(add(1, 2), add(3, 4));
    println!("{result:?}");
}

```

### 💻 代码解释

- **`async fn add(a: i32, b: i32) -> i32`**: 这是一个简单的**异步函数**，它接收两个 $i32$ 整数，打印它们的和，并返回这个和。函数体是同步执行的，但它被标记为 `async`，因此调用它会返回一个 **Future**。
- **`#[tokio::main] async fn main()`**: 程序入口点，由 Tokio 宏初始化异步运行时。
- **`let result = tokio::join!(add(1, 2), add(3, 4));`**:
  - **`tokio::join!`** 是一个强大的宏，它接收多个 Future 作为参数，并**并发地**在同一个线程或一组线程上运行它们。
  - 它**等待所有传入的 Future 都完成**后才会返回。
  - 它的返回值是一个 **Tuple**，其中包含每个 Future 的结果，顺序与传入的 Future 顺序一致。
  - 这意味着 `add(1, 2)` 和 `add(3, 4)` 这两个计算任务将**同时启动并执行**。
- **`println!("{result:?}");`**: 打印 `tokio::join!` 返回的结果元组。

这段代码的核心是演示了如何使用 **`tokio::join!` 宏**来简洁、高效地将多个独立的异步任务汇集在一起，等待它们全部完成并获取结果，从而实现强大的并发控制。

### 运行

```bash
➜ cargo run
   Compiling rust_os_threads v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rust_os_threads)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.83s
     Running `target/debug/rust_os_threads`
1 + 2 = 3
3 + 4 = 7
(3, 7)
```

### 💻 运行结果解释

这段输出是 **Tokio 异步运行时**执行代码的结果，清楚地展示了 **`tokio::join!` 宏**的功能。打印的 **`1 + 2 = 3`** 和 **`3 + 4 = 7`** 来源于宏中**并发执行**的两个 `add` 异步函数。最后的输出 **`(3, 7)`** 则是 `tokio::join!` 宏等待这两个并发任务都完成后，将它们的返回值（$3$ 和 $7$）收集并以元组形式返回给 `main` 函数的结果。这整个过程体现了 Rust 异步编程中高效的任务并发和结果同步机制。

### 示例四

```rust
use tokio::task::JoinSet;

async fn add(a: i32, b: i32) -> i32 {
    println!("{a} + {b} = {}", a + b);
    a + b
}

#[tokio::main]
async fn main() {
    let mut set = JoinSet::new();
    for i in 0..10 {
        set.spawn(add(i, 2));
    }
    while let Some(result) = set.join_next().await {
        println!("{result:?}");
    }
}

```

这段 Rust 代码利用 **Tokio 的 `JoinSet` 结构体**，灵活高效地管理和等待**一组动态生成的异步任务**。程序首先初始化一个 **`JoinSet`**，然后在一个循环中，通过 **`set.spawn(add(i, 2))`** 语句**并发地**启动 $10$ 个 `add` 异步任务，每个任务计算 $i+2$ 并将其加入到集合中。随后，代码进入一个 **`while let Some(result) = set.join_next().await`** 循环，这行代码是关键：它会**非阻塞地**等待并取出 **`JoinSet` 中最先完成的那个任务的结果**。通过这种方式，程序能够以**任务完成的顺序**处理所有结果，而不是等待所有任务完成后再统一处理，从而实现高度灵活和动态的异步并发管理。

### 运行

```bash
➜ cargo run
   Compiling rust_os_threads v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rust_os_threads)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.92s
     Running `target/debug/rust_os_threads`
0 + 2 = 2
2 + 2 = 4
4 + 2 = 6
5 + 2 = 7
1 + 2 = 3
3 + 2 = 5
8 + 2 = 10
Ok(2)
6 + 2 = 8
7 + 2 = 9
9 + 2 = 11
Ok(4)
Ok(6)
Ok(7)
Ok(3)
Ok(5)
Ok(10)
Ok(8)
Ok(9)
Ok(11)
```

### 💻 运行结果解释

这段输出首先是 **Cargo 的编译信息**，表示程序编译成功并开始运行。关键输出分为两部分：

1. **交错的 `a + b = c` 打印输出**：这 $10$ 行输出来自 $10$ 个并发运行的 `add` 任务。由于这些任务是**并行启动**且由 Tokio 运行时**自由调度**，它们的打印语句是**无序且交错**地出现的，反映了运行时对任务的动态调度，任务之间没有固定的执行顺序。
2. **交错的 `Ok(result)` 输出**：这 $10$ 行输出来自 `main` 函数中的 **`while let Some(result) = set.join_next().await`** 循环。这个循环在等待 `JoinSet` 中**任意一个**任务完成，并取出其结果。因此，这些 `Ok(...)` 行（包含 $2$ 到 $11$ 的结果）是**按照任务实际完成的顺序**逐个打印出来的，进一步证明了任务的并发性，以及 `JoinSet` 能够灵活地处理异步任务的动态完成顺序。

### 示例五

```rust
async fn hello() {
    println!("Hello, world!");
}

async fn run() {
    for i in 0..10 {
        println!("{i}");
    }
}


#[tokio::main]
async fn main() {
    let _ = tokio::join!(
        tokio::spawn(hello()),
        tokio::spawn(run()),
        tokio::spawn(run()),
    );

    println!("Finished")
}

```

这段 Rust 代码利用 **Tokio 运行时**结合 **`tokio::spawn`** 和 **`tokio::join!` 宏**，并发地启动并等待三个独立的异步任务完成。程序在 `main` 函数中，通过三次调用 **`tokio::spawn`**，将一个 `hello()` 任务和两个 `run()` 任务提交给异步运行时，使其在后台**并发执行**。随后，所有这三个 `spawn` 调用返回的 **`JoinHandle`** 被传入 **`tokio::join!`** 宏中。`tokio::join!` 会**等待这三个任务全部执行完毕**（即等待它们的 `JoinHandle` 上的 Future 完成），然后 `main` 函数才会继续执行并打印 `"Finished"`。这种组合模式确保了所有后台任务都能在程序结束前完成，是 Rust 异步编程中管理和同步多个并发任务的常见方式。

### 运行

```bash
RustJourney/rust_os_threads on  main [?] is 📦 0.1.0 via 🦀 1.90.0
➜ cargo run
   Compiling rust_os_threads v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rust_os_threads)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.63s
     Running `target/debug/rust_os_threads`
Hello, world!
0
1
2
3
4
5
6
7
8
9
0
1
2
3
4
5
6
7
8
9
Finished

```

### 💻 运行结果解释

这段输出首先是 **Cargo 的编译信息**，表示程序编译成功并开始运行。关键输出位于程序运行阶段：

1. **`Hello, world!`**: 这行输出来自并发执行的 **`hello()`** 任务。
2. **两组 $0$ 到 $9$ 的序列**: 这两组共 $20$ 行输出来自并发执行的**两个 `run()` 任务**。
3. **`Finished`**: 这行输出是 `main` 函数的最后一条语句。

**任务调度分析**:

整个输出序列（`Hello, world!`、两组 $0-9$）是三个并发任务（一个 `hello`，两个 `run`）在 Tokio 运行时上自由调度和执行的结果。由于这三个任务的 **`JoinHandle`** 被传入 **`tokio::join!`** 宏中，`main` 函数被阻塞，**直到这三个并发任务全部完成**。在这个特定的运行实例中，运行时先完成了 `hello` 任务的打印，然后是两个 `run` 任务的 $0-9$ 循环，最后 **`tokio::join!`** 完成等待，`main` 函数才得以继续执行，打印出最后的 **`Finished`**。这证明了 `tokio::join!` 成功地同步了所有并发任务的完成，确保了程序在所有后台工作结束后才退出。

### 示例六

```rust
async fn hello() {
    println!("Hello, world!");
}

async fn run() {
    for i in 0..10 {
        println!("{i}");
        tokio::task::yield_now().await;
    }
}


#[tokio::main]
async fn main() {
    let _ = tokio::join!(
        tokio::spawn(hello()),
        tokio::spawn(run()),
        tokio::spawn(run()),
    );

    println!("Finished")
}

```

这段 Rust 代码的核心在于利用 **`tokio::task::yield_now().await`** 来**主动让出 CPU 控制权**，从而极大地优化了异步任务的并发调度。与之前类似的代码结构相同，`main` 函数通过 **`tokio::spawn`** 启动了一个 `hello()` 任务和两个 `run()` 任务，并使用 **`tokio::join!`** 等待它们全部完成。然而，这里的 **`run()`** 函数在循环的每次迭代中都调用了 `yield_now().await`。这个调用会通知 Tokio 运行时：当前任务已达到一个自然暂停点，可以**立即切换**到执行其他就绪任务（例如另一个 `run` 任务或 `hello` 任务）。这种设计使得三个并发任务（特别是两个 `run` 任务）能够更加**细粒度地交错执行**，从而最大限度地提高并发度，而不是让一个 `run` 任务连续打印 $0$ 到 $9$ 后才切换到下一个。

### 运行

```bash
RustJourney/rust_os_threads on  main [?] is 📦 0.1.0 via 🦀 1.90.0
➜ cargo run
   Compiling rust_os_threads v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rust_os_threads)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.22s
     Running `target/debug/rust_os_threads`
0
Hello, world!
1
0
1
2
3
4
5
6
7
8
9
2
3
4
5
6
7
8
9
Finished
```

### 💻 运行结果解释

这段输出首先是 **Cargo 的编译信息**，表示程序编译成功并开始运行。关键输出位于程序运行阶段：

1. **高度交错的输出**: 核心区别在于，任务输出不再是成块的。在第一个 `run` 任务打印 `0` 之后，`Hello, world!` 紧接着被打印，然后两个 `run` 任务的输出 `$0-9$` **细粒度地交错在一起**（例如，`1` 后面跟着另一个 `0`）。
2. **`yield_now()` 的效果**: 这种交错是 **`tokio::task::yield_now().await`** 的直接结果。在 `run` 任务的每次循环迭代中，`yield_now()` 都会**主动暂停**当前任务并通知 Tokio 运行时：现在是切换到其他就绪任务的最佳时机。
3. **最终的 `Finished`**: 最后的 **`Finished`** 再次证明，无论是 `hello` 任务还是两个 `run` 任务，它们都完全执行完毕，因为 `tokio::join!` 确保了 `main` 函数在所有并发任务完成后才打印出这条语句。

**总结**：这段结果完美展示了 **`yield_now().await`** 如何强制运行时在多个并发任务之间进行**公平和细粒度的切换**，从而使得三个任务的输出高度混合，而不是按顺序成块出现。

### 示例七

```rust
async fn hello() {
    println!("Hello, world!");
}

async fn run() {
    for i in 0..10 {
        println!("{i}");
    }
}

async fn add(a: i32, b: i32) -> i32 {
    println!("{a} + {b} = {}", a + b);
    a + b
}

#[tokio::main]
async fn main() {
    let _ = tokio::join!(
        tokio::spawn(hello()),
        tokio::spawn(run()),
        tokio::spawn(add(1, 2))
    );

    println!("Finished")
}

```

这段 Rust 代码利用 **Tokio 运行时**管理和同步了三个类型和行为各异的异步任务。在 `main` 函数中，程序通过三次调用 **`tokio::spawn`** 将 `hello()`（简单打印）、`run()`（循环打印 $0-9$）和 `add(1, 2)`（计算并打印结果）三个独立的异步 Future 提交到运行时，使它们**并发执行**。随后，所有这三个 `spawn` 调用返回的 **`JoinHandle`** 被传入 **`tokio::join!`** 宏中。`tokio::join!` 的作用是**等待所有这三个并发任务全部执行完毕**。只有当三个任务（一个打印，一个循环，一个计算）都完成后，`tokio::join!` 才会结束等待，允许 `main` 函数继续执行并打印出最后的 `"Finished"` 消息。这展示了使用 `tokio::spawn` 启动任务和使用 `tokio::join!` 宏同步等待它们完成的异步编程核心模式。

### 运行

```bash
➜ cargo run
   Compiling rust_os_threads v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rust_os_threads)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.91s
     Running `target/debug/rust_os_threads`
0
1
2
3
1 + 2 = 3
Hello, world!
4
5
6
7
8
9
Finished
```

### 💻 运行结果解释

这段输出首先是 **Cargo 的编译信息**，表示程序编译成功并开始运行。关键输出位于程序运行阶段：

1. **交错的输出**: 任务输出是混合出现的。`run()` 任务（打印 $0-9$）启动后，先打印了 $0$ 到 $3$。随后，**`add(1, 2)` 任务**的输出 **`1 + 2 = 3`** 和 **`hello()` 任务**的输出 **`Hello, world!`** 迅速穿插或紧接出现。最后，`run()` 任务完成了它剩余的打印 ($4$ 到 $9$)。
2. **`tokio::join!` 的同步作用**: 最后的输出 **`Finished`** 证明 `main` 函数被 **`tokio::join!`** 阻塞，直到三个并发任务（`hello`、`run`、`add`）全部执行完毕。这说明，尽管三个任务的执行顺序和完成时间由 Tokio 运行时自由调度，但程序确保了所有后台工作完成后才退出。

**总结**：这个结果清晰地展示了 **Tokio 运行时**如何高效地并发调度这三个任务，它们的执行和打印输出相互竞争，并以**不确定但非阻塞**的方式交错出现，最终由 `tokio::join!` 确保了程序的正确同步和退出。

## 📌 总结

本文从根本上区分了**并发（逻辑切换）**和**并行（物理同时）**，明确了并行是并发的一种特殊实现。在异步 Rust 的实践中，我们通过 **Tokio 运行时**管理 **Future**，实现高效的并发。文章核心展示了三种关键任务管理模式：

1. **`tokio::spawn` + `hello().await`**: 启动后台任务并等待主任务完成。
2. **`tokio::join!`**: 简明高效地**同步等待**多个并发任务的结果。
3. **`JoinSet`**: 灵活地按**完成顺序**处理动态生成的并发任务。 此外，我们还通过实验证明，**同步长任务会阻塞异步调度**，而 **`yield_now().await`** 是实现任务间公平切换、保证高并发性的重要手段。掌握这些核心概念和工具，是您构建高性能 Rust 异步应用的关键一步。

## 参考

- <https://rust-lang.org/>
- <https://crates.io/>
- <https://rustcc.gitbooks.io/rustprimer/content/>
- <https://developer.mozilla.org/zh-CN/docs/WebAssembly/Guides/Rust_to_Wasm>
