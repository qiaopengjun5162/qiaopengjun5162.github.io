+++
title = "Rust Async/Await 实战：从串行到并发，掌握 `block_on` 与 `join!` 的异步魔力"
description = "Rust Async/Await 实战：从串行到并发，掌握 `block_on` 与 `join!` 的异步魔力"
date = 2025-10-19T04:57:10Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# **Rust Async/Await 实战：从串行到并发，掌握 `block_on` 与 `join!` 的异步魔力**

Rust 以其零成本抽象和内存安全特性在系统编程领域备受推崇。在构建高性能网络服务或处理高并发任务时，理解和运用其异步编程模型至关重要。与 Go、Node.js 等语言提供“开箱即用”的异步方案不同，Rust 采取了更通用的方式，提供了 **`Future`** 和 **`async/await`** 这样的基础模块。本文将深入浅出地对比系统线程与异步模型的差异，并通过一系列实战代码示例，重点讲解如何使用 `futures::executor::block_on` 和 `futures::join!` 等工具，从最基础的串行调用逐步迈向高效的并发执行，解锁 Rust 并发模型的强大威力。

本文深入探讨 Rust 异步编程（Async Rust），对比其与系统线程在调度机制、适用场景和资源消耗上的差异。Rust 异步采用**协作式多任务**，适用于 I/O 密集型任务。通过五个实战示例，文章演示了 `async fn` 的基本用法、`await` 实现的异步串联，以及如何使用 **`block_on`** 驱动 Future。重点介绍了 **`join!` 宏**在异步任务中实现并发执行和同时接收返回值的功能。旨在帮助开发者理解和掌握 `block_on` 和 `join!`，将异步逻辑有效地整合到同步的 `main` 函数中，提升应用性能。

## Rust 异步编程 Async Rust

### 系统线程

由操作系统管理，抢占式多任务（preemptively multi-tasked）

- OS Scheduler （调度器）可随时中断一个线程
- 调度器本身是相对”重量级“的。需要保存当前线程的状态，加载下一个线程的状态，然后恢复执行
- 对任务的调度只有有限的控制权

### 异步模型

**Async Model，协作式多任务（cooperatively multi-tasked）**

- 可以只运行在一个线程上，也可以把任务分布到多个线程上
- 一个异步任务只有在主动让出控制权（yield control）时才会被中断，执行器进程本身仍然可能被操作系统调度器中断。
- 异步任务非常轻量，它只包含执行栈（局部变量和函数调用）以及用于恢复任务执行的必要信息（例如：当一个网络操作完成后，如何恢复）

### 何时使用 Async，何时使用系统线程？

| 场景         | 使用系统线程           | 使用 Async                                 |
| ------------ | ---------------------- | ------------------------------------------ |
| 任务运行时间 | 长时间运行的任务       | 短时间运行的任务                           |
| 任务类型     | CPU 密集型任务         | I/O 密集型任务                             |
| 并行性需求   | 需要真正并行运行的任务 | 需要并发运行的任务                         |
| 延迟需求     | 需要最小且可预测的延迟 | 能利用等待时间来做其他事，提升吞吐量的任务 |

### 不适合的场景示例

- 不适合 async 的场景：任务会占用大量 CPU，且在逻辑上很长时间都不会让出控制权时，否则会让整个系统的异步性能下降。
- 不适合系统线程的场景：当你为每个网络客户端都创建一个系统线程，而这些线程大多数时间都在等待 I/O 的场景，这会导致耗尽内存或线程资源。

**最好的做法是：将两者结合使用，这样才能真正发挥 Rust 并发模型的威力。**

### Rust 与 Async/Await

- NodeJs、Go、C#、Python 等语言都实现了一套有明确设计主张的且开箱即用（batteries included）的 Async/Await 方案
- C++ 和 Rust 都采用了一种更为通用（agnostic）的方式，提供了构建的基础模块，将组装成框架的工作留给了开发者

## Async Rust 实操

### 示例一

```rust
use futures::executor::block_on;

async fn hi() {
    println!("Hello, world!");
}

// 1. async fn 可以执行 non-async fn
// 2. non-async fn 不可以执行 async fn，除非有 executor

fn main() {
    let func = hi(); // executor
    block_on(func);
}

```

这段 Rust 代码展示了 **异步函数 (async fn)** 的基本使用和如何在 **非异步函数 (non-async fn)** 中执行它。`hi` 函数被声明为 `async fn`，这意味着它返回一个 **Future**。Future 表示一个可能还没有完成的异步操作。**非异步函数**，例如 `main` 函数，不能直接调用并等待一个 `async fn` 完成，因为它需要一个 **执行器 (executor)** 来驱动 Future 的执行。代码中使用的 `use futures::executor::block_on;` 引入了 `block_on` 这个执行器。在 `main` 函数中，`let func = hi();` 实际上只是创建了一个 Future（即那个异步操作的**定义**），并没有开始执行。然后，`block_on(func);` 充当了**阻塞式**的执行器，它会阻塞当前的线程（即 `main` 函数）直到 `hi()` 返回的 Future 完成，从而输出 "Hello, world!"。简而言之，这段代码演示了如何使用 `block_on` 库中的工具在同步的 `main` 函数中**同步地**运行一个异步函数。

### 运行

```bash
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.01s
     Running `target/debug/async_rust`
Hello, world!
```

这段运行结果表明 Rust 程序已成功编译和执行。具体来说，`cargo run` 命令首先完成了代码的编译（`Finished 'dev' profile...`），这个过程非常快，只用了 $0.01$ 秒。然后，它执行了生成的调试版本程序（`Running 'target/debug/async_rust'`），程序的执行结果输出了 **"Hello, world!"**。这个输出是程序中 `async fn hi()` 内部的 `println!` 宏在 `main` 函数通过 **`block_on(func)`** 被成功驱动执行后产生的。这证明了异步函数被执行器正确地运行。

### 示例二

```rust
use futures::executor::block_on;

async fn hi() {
    println!("Hello, world!");
    hello_rust().await;
}

// 1. async fn 可以执行 non-async fn
// 2. non-async fn 不可以执行 async fn，除非有 executor

async fn hello_rust() {
    println!("Hello, Rust!");
}

fn main() {
    let func = hi(); // executor
    block_on(func);
}

```

这段 Rust 代码进一步展示了异步函数 (async fn) 之间的**串联调用**。`hi` 函数和 `hello_rust` 函数都被定义为 `async fn`。在 `hi` 函数内部，它首先打印 "Hello, world!"，然后使用 **`.await`** 关键字来暂停自身的执行，直到另一个异步函数 `hello_rust()` 完成。`hello_rust()` 只打印 "Hello, Rust!"。由于 `hi()` 内部有 `.await`，它会等待 `hello_rust()` 运行完毕才会继续。最后，在同步的 `main` 函数中，`block_on(func)` 充当执行器，**阻塞地**驱动整个异步操作 (`hi()` 及其内部调用的 `hello_rust()`) 运行直到完成，因此程序会按顺序输出两条信息。这段代码的核心在于说明 `async fn` 之间可以通过 `.await` 实现非阻塞的等待和协作，而 **`block_on`** 则是将整个异步世界接入到同步程序入口的桥梁。

### 运行

```bash
➜ cargo run
   Compiling async_rust v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/async_rust)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.54s
     Running `target/debug/async_rust`
Hello, world!
Hello, Rust!
```

这段运行结果完美地体现了上一个代码块中 **`async fn` 通过 `.await` 实现的串行执行顺序**。`cargo run` 首先编译并构建了程序（`Compiling... Finished 'dev' profile...`），然后执行了它（`Running 'target/debug/async_rust'`）。输出结果显示 **"Hello, world!"** 在 **"Hello, Rust!"** 之前。这正是因为在 `async fn hi()` 中，`println!("Hello, world!");` 是第一条执行语句，随后 **`.await`** 等待了 `hello_rust()` 的完成，所以 `hello_rust()` 打印的 "Hello, Rust!" 紧接着被执行。`block_on` 确保了整个由 `.await` 连接的异步链条被完整且按序地执行完毕。

### 示例三

```rust
use futures::executor::block_on;

async fn hi() {
    println!("Hello, world!");
    hello_rust().await;
}

// 1. async fn 可以执行 non-async fn
// 2. non-async fn 不可以执行 async fn，除非有 executor

async fn hello_rust() {
    println!("Hello, Rust!");
    hello_sync();
}

fn hello_sync() {
    println!("Hello, sync!");
}

fn main() {
    let func = hi(); // executor
    block_on(func); // cooperative multitasking
}

```

这段 Rust 代码进一步扩展了异步函数 (`async fn`) 的能力，展示了异步代码如何调用**同步函数 (non-async fn)**。异步函数 `hello_rust()` 中调用了普通的同步函数 `hello_sync()`，这是完全允许的，因为同步函数不需要 Future 或执行器，可以直接执行。整个执行流程从 `main` 函数开始，`block_on(hi())` 阻塞地驱动异步任务 `hi()`。在 `hi()` 内部，首先打印 "Hello, world!"，然后 `.await` 等待 `hello_rust()` 完成。在 `hello_rust()` 内部，依次打印 "Hello, Rust!" 和 **"Hello, sync!"**（由同步函数 `hello_sync()` 产生）。最终，`block_on` 确保了所有代码按此**同步且串行**的顺序执行，证明了异步函数可以无缝地包含和执行同步逻辑。

### 运行

```bash
➜ cargo run
   Compiling async_rust v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/async_rust)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.57s
     Running `target/debug/async_rust`
Hello, world!
Hello, Rust!
Hello, sync!

```

这段运行结果展示了前一个代码块中异步函数调用同步函数后的**完整且严格的串行执行过程**。`cargo run` 完成编译和执行后，输出了三行内容。**"Hello, world!"** 是 `hi()` 函数的第一条语句；紧接着，`hi()` 通过 `.await` 调用并等待 `hello_rust()` 完成，从而输出了 **"Hello, Rust!"**；最后，在 `hello_rust()` 函数内部，同步函数 `hello_sync()` 被直接调用并执行，输出了 **"Hello, sync!"**。这个结果证实了整个异步任务链，包括异步等待和同步函数调用，都被 `block_on` 这个阻塞式执行器按照代码编写的顺序一步一步地驱动完成。

### 示例四

```rust
use futures::{executor::block_on, join};

async fn hi() {
    println!("Hello, world!");
    // hello_rust().await;
}

// 1. async fn 可以执行 non-async fn
// 2. non-async fn 不可以执行 async fn，除非有 executor

async fn hello_rust() {
    println!("Hello, Rust!");
    hello_sync();
}

fn hello_sync() {
    println!("Hello, sync!");
}

async fn do_mul() {
    join!(hi(), hello_rust());
}

fn main() {
    // let func = hi(); // executor
    // block_on(func); // cooperative multitasking

    block_on(do_mul());
}

```

这段 Rust 代码的核心在于引入了 **`futures::join!`** 宏，展示了如何在异步代码中实现**并发执行**多个 Future。函数 `do_mul()` 是一个新的异步入口，它使用 `join!(hi(), hello_rust())` 来**同时**驱动 `hi()` 和 `hello_rust()` 这两个 Future。`join!` 宏会等待它内部所有的 Future 都完成后才返回，但它允许这些 Future 在一个执行器上以**合作式多任务 (cooperative multitasking)** 的方式并发地推进执行。尽管 `hi()` 函数中原有的 `.await` 被注释掉了，但由于 `hi()` 和 `hello_rust()` 现在是并发运行的，它们各自内部的打印语句的**执行顺序将不再是严格固定的**。最后，`main` 函数通过 **`block_on(do_mul())`** 来阻塞地等待整个并发任务集合完成。这标志着代码从严格的串行执行迈向了并发执行。

### 运行

```bash
➜ cargo run
   Compiling async_rust v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/async_rust)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.47s
     Running `target/debug/async_rust`
Hello, world!
Hello, Rust!
Hello, sync!
```

这段运行结果显示，尽管代码使用了 **`join!` 宏**来并发地运行 `hi()` 和 `hello_rust()`，但最终的输出顺序仍是 **"Hello, world!"**、**"Hello, Rust!"** 和 **"Hello, sync!"**，与之前的串行执行结果**保持一致**。这表明在一个**单线程的 `block_on` 执行器**中，虽然任务是并发驱动的，但由于它们内部都没有遇到 I/O 阻塞或显式的 yield 操作，执行器会依次快速地轮询并完成它们。具体来说，`hi()` 及其打印语句可能先被执行完成，随后 `hello_rust()` 及其内部的打印和同步函数调用被执行完成。虽然 `join!` 提供了并发的可能性，但对于不包含等待或耗时操作的简单任务，**最终的输出顺序仍然可能依赖于执行器的调度细节**，在这个简单场景下，它表现为接近于串行的顺序。

### 示例五

```rust
use futures::{executor::block_on, join};

async fn hi() {
    println!("Hello, world!");
    // hello_rust().await;
}

// 1. async fn 可以执行 non-async fn
// 2. non-async fn 不可以执行 async fn，除非有 executor

async fn hello_rust() {
    println!("Hello, Rust!");
    hello_sync();
}

fn hello_sync() {
    println!("Hello, sync!");
}

async fn do_mul() {
    join!(hi(), hello_rust());
    let sum = add(1, 2).await;
    println!("Sum: {sum}");

    let (sum1, sum2) = join!(add(1, 2), add(3, 4));
    println!("Sum1: {sum1}, Sum2: {sum2}");
}

async fn add(a: i32, b: i32) -> i32 {
    a + b
}

fn main() {
    // let func = hi(); // executor
    // block_on(func); // cooperative multitasking

    block_on(do_mul());
}

```

这段 Rust 代码展示了异步编程中的**并发执行 (`join!`)** 和 **值返回**。新的 `do_mul()` 异步函数现在不仅并发地运行了 **`hi()`** 和 **`hello_rust()`**（使用 `join!`), 而且还演示了异步函数 (`add`) 如何返回一个值。`add(1, 2).await` 展示了 `.await` 如何等待一个异步操作完成并**获取其返回值** (`sum`)。更重要的是，代码再次使用了 **`join!`** 宏，这次是用它来**同时执行**两个 `add` Future (`add(1, 2)` 和 `add(3, 4)`)，并用元组解构 **`(sum1, sum2)`** **同时接收它们各自的返回值**。整个程序依然通过同步的 `main` 函数中的 **`block_on(do_mul())`** 来驱动，确保了所有并发和异步操作在阻塞等待中依次完成，最终打印出所有字符串和计算结果。

### 运行

```bash
➜ cargo run
   Compiling async_rust v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/async_rust)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.62s
     Running `target/debug/async_rust`
Hello, world!
Hello, Rust!
Hello, sync!
Sum: 3
Sum1: 3, Sum2: 7
```

这段运行结果展示了程序中所有异步和并发任务**按顺序完成**后的输出。首先，`cargo run` 完成编译和执行。在 `do_mul()` 函数中，**`join!(hi(), hello_rust())`** 虽然是并发执行，但由于是简单的打印操作，它们几乎立即完成，输出 **"Hello, world!"**、**"Hello, Rust!"** 和 **"Hello, sync!"**（顺序与前一个示例相同）。随后，程序执行到 `add(1, 2).await`，计算结果 $3$ 被赋值给 `sum` 并输出 **"Sum: 3"**。最后，第二个 **`join!(add(1, 2), add(3, 4))`** 并发地计算出 $3$ 和 $7$，这些返回值被解构成 `sum1` 和 `sum2`，并输出 **"Sum1: 3, Sum2: 7"**。整个结果清晰地表明了异步任务的**串行推进**以及 **`join!` 宏成功地同时获取了并发异步操作的返回值**。

## 总结

Rust 的异步编程模型提供了一种强大的并发机制，它通过 **协作式多任务** 的方式，避免了传统系统线程的“重量级”开销，尤其适用于 **I/O 密集型**任务。本文通过实操代码，清晰展示了 `async fn` 如何定义 Future，以及必须通过 **执行器（Executor）** 来驱动这些 Future。

- **`block_on`** 是将异步世界接入同步 `main` 函数的桥梁，它会阻塞当前线程直到 Future 完成。
- **`.await`** 用于在异步函数内部进行**串行等待**和协作。
- **`join!` 宏**是实现真正**并发执行**多个 Future 的关键工具，它允许任务同时推进，并能方便地接收所有 Future 的返回值。

尽管在简单的非阻塞任务中，`join!` 的输出可能看起来是串行的，但它为 Rust 开发者提供了构建高性能、高吞吐量应用程序的基础。最佳实践是结合使用轻量的异步任务和操作系统的系统线程（例如使用线程池），以最大化发挥 Rust 并发模型的潜力。

## 参考

- <https://users.rust-lang.org/>
- <https://course.rs/about-book.html>
- <https://rust-lang.org/zh-CN/>
- <https://actix.rs/>
