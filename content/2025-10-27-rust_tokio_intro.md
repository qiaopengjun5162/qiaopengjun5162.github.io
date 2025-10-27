+++
title = "Rust 异步编程基石：Tokio 运行时从入门到精通（单线程与多线程实战）"
description = "Rust 异步编程基石：Tokio 运行时从入门到精通（单线程与多线程实战）"
date = 2025-10-27T13:53:04Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# **Rust 异步编程基石：Tokio 运行时从入门到精通（单线程与多线程实战）**

随着高并发、高性能网络服务的需求日益增长，异步编程已成为现代系统开发不可或缺的一环。在 Rust 语言的生态中，Tokio 扮演着异步运行时的核心角色。它不仅提供了高效的 I/O 和任务调度机制，还为构建健壮、可伸缩的网络应用奠定了基础。本文将通过详尽的代码示例，带您从零开始，掌握 Tokio 运行时的创建、配置，以及在单线程和多线程模式下的实际应用，助您迈出 Rust 异步编程的关键一步。

**本文介绍了 Rust 异步运行时 Tokio，它是构建高性能网络应用的核心组件。内容涵盖 Tokio 的主要组成、项目创建，并通过代码示例详细解析了手动和宏方式（`#[tokio::main]`）创建**单线程**运行时的方法。随后，深入探讨了如何精细化配置**多线程**运行时（如设置工作线程数、线程名称等）。通过实战代码与运行结果，清晰展示了 Tokio 异步任务的调度与执行流程。**

## Rust Async Tokio 简介

### Tokio

Rust编程语言的一个异步运行时，但并不是唯一的。

- 提供了编写网络应用程序所需的构建块。它具有灵活性，可以针对各种系统，从拥有数十个内核的大型服务器到小型嵌入式设备。
- 几个主要的组件：一个用于执行异步代码的多线程运行时、标准库的异步版本、一个庞大的库生态系统

### Tokio 的主要部分

- Executor
- Reactor

### 异步版本

- Runtime
- I/O
- File System
- Network
- Time
- Process
- ...

## 单线程模式

- `block_on(...)`
- `#[tokio::main(flavor = "current_thread")]`

## 实操

### 创建项目

```bash
cargo new tokio_intro

cd tokio_intro/

ls

cc # open -a cursor .

➜ cargo add tokio -F full
```

### 示例一

**如何在 Rust 中使用 Tokio 手动创建并运行一个异步运行时（Runtime）**

```rust
use tokio::runtime;

async fn hi() {
    println!("Hello tokio!");
}

fn main() {
    runtime::Builder::new_current_thread()
        .enable_all()
        .build()
        .unwrap()
        .block_on(hi());
}

```

### 🔹 详细解释

1. **`use tokio::runtime;`**
    这一行引入了 Tokio 的运行时模块。Tokio 是 Rust 中最常用的异步运行时库，它负责 **执行 async 异步任务**、**管理事件循环**、**处理 I/O、定时器等异步操作**。

2. **`async fn hi()`**
    定义了一个异步函数 `hi`，其返回一个 `Future`（异步任务），执行时会打印 `"Hello tokio!"`。

   > 注意：定义 `async fn` 并不会立刻执行函数体，它只会返回一个 **Future 对象**，必须由运行时（runtime）来驱动执行。

3. **`runtime::Builder::new_current_thread()`**
    这里使用 Tokio 的 **Builder 模式** 手动创建一个运行时。

   - `new_current_thread()` 表示创建一个 **单线程** 的运行时（所有任务都在当前线程中执行）。
   - 相对地，Tokio 还提供 `new_multi_thread()` 来创建多线程运行时。

4. **`.enable_all()`**
    启用 Tokio 提供的所有功能模块，例如：

   - 定时器（`tokio::time`）
   - I/O（`tokio::net`）
   - 信号处理（`tokio::signal`）等
      如果不启用，某些异步功能可能无法使用。

5. **`.build().unwrap()`**
    调用 `build()` 来真正构建运行时，如果创建失败则用 `unwrap()` 抛出错误（直接 panic）。

6. **`.block_on(hi())`**
    `block_on()` 方法会：

   - 启动运行时；
   - 同步阻塞当前线程；
   - 直到传入的异步任务 `hi()` 执行完毕后才返回。
      简而言之，这一步是 **在同步上下文中运行异步函数**。

------

### 🔹 执行流程总结

1. 程序启动 → 进入 `main()`；
2. 构建一个单线程 Tokio 运行时；
3. 使用运行时的 `block_on` 方法执行异步函数 `hi()`；
4. 异步函数 `hi()` 打印 `"Hello tokio!"`；
5. 程序结束。

------

### 🔹 程序输出

```
Hello tokio!
```

------

### 🔹 补充说明

这种写法常用于：

- 在 **非异步的主函数中**（例如普通 `fn main()`）调用异步函数；
- 手动控制 Tokio 运行时（例如在嵌入式系统或需要精确控制线程数的环境中）。

若使用常规的 Tokio 宏方式，也可以简化为：

```rust
#[tokio::main]
async fn main() {
    hi().await;
}
```

它与上述代码逻辑完全等价，只是用宏自动帮你创建了运行时。

### 运行

```bash
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.02s
     Running `target/debug/tokio_intro`
Hello tokio!
```

这段运行结果表示：Rust 项目已经成功编译并执行，程序输出了预期的内容。
 具体来说：`cargo run` 会先编译当前项目（如果代码未变化，则直接使用已有构建结果），然后运行生成的可执行文件。在输出中，`Finished 'dev' profile` 表示编译完成，`Running 'target/debug/tokio_intro'` 表示正在运行名为 `tokio_intro` 的程序。随后，程序中的 Tokio 运行时启动并执行异步函数 `hi()`，最终在控制台打印出 `"Hello tokio!"`，说明异步任务顺利执行并正常结束。

### 示例二

```rust
// use tokio::runtime;

async fn hi() {
    println!("Hello tokio!");
}

#[tokio::main(flavor = "current_thread")]
async fn main() {
    // let rt = runtime::Builder::new_current_thread()
    //     .enable_all()
    //     .build()
    //     .unwrap();

    // rt.block_on(hi());

    hi().await;
}

```

这段代码展示了使用 **Tokio 的宏属性 `#[tokio::main]`** 来简化异步运行时创建与执行的过程。

代码中首先定义了一个异步函数 `hi()`，该函数的执行内容很简单——在控制台打印 `"Hello tokio!"`。接着在 `main` 函数上使用了 `#[tokio::main(flavor = "current_thread")]` 宏标注，这一宏会在编译时自动为 `main` 函数生成一个 **Tokio 运行时（Runtime）**，并将其作为程序入口点。`flavor = "current_thread"` 表示使用 **单线程运行时**，所有异步任务都会在当前线程中执行，而不是多线程并行执行。

在 `main` 函数内部，代码直接调用 `hi().await;` 来等待异步函数执行完成。这样做与手动创建运行时并调用 `block_on(hi())` 的效果完全相同，只是语法更加简洁、直观。最终，程序运行时会输出：

```rust
Hello tokio!
```

这说明 Tokio 运行时已成功启动，异步函数 `hi()` 被正确调度和执行。`main` 函数不是异步的，只不过看起来是异步的。

### 运行

```bash
➜ cargo run
   Compiling tokio_intro v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/tokio_intro)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.52s
     Running `target/debug/tokio_intro`
Hello tokio!


➜ cargo expand
    Checking tokio_intro v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/tokio_intro)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.17s

#![feature(prelude_import)]
#[macro_use]
extern crate std;
#[prelude_import]
use std::prelude::rust_2024::*;
async fn hi() {
    {
        ::std::io::_print(format_args!("Hello tokio!\n"));
    };
}
fn main() {
    let body = async {
        hi().await;
    };
    #[allow(
        clippy::expect_used,
        clippy::diverging_sub_expression,
        clippy::needless_return,
        clippy::unwrap_in_result
    )]
    {
        return tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .expect("Failed building the Runtime")
            .block_on(body);
    }
}
```

这段运行结果展示了两个重要部分：**程序的实际运行输出** 和 **宏展开后的内部实现**。

首先，执行 `cargo run` 时，Rust 编译器先编译项目 `tokio_intro`，然后运行生成的可执行文件。程序成功执行后打印出：

```rust
Hello tokio!
```

说明异步函数 `hi()` 已被 Tokio 运行时调度并执行，整个异步流程运行正常。

接着使用 `cargo expand` 展开代码后，可以看到编译器实际生成的底层实现。虽然源代码里只写了 `#[tokio::main(flavor = "current_thread")]`，但宏在编译时自动替换为更完整的运行时构建逻辑。展开结果显示，编译器为 `main` 函数生成了：

- 一个异步块 `body` 来包装 `hi().await;`；
- 调用了 `tokio::runtime::Builder::new_current_thread()` 创建单线程运行时；
- 启用了所有 Tokio 功能（`enable_all()`）；
- 使用 `block_on(body)` 启动并执行异步任务。

换句话说，`#[tokio::main]` 宏只是帮开发者自动插入了这些底层运行时初始化代码，使我们能以简洁的异步语法编写主函数，而实际执行逻辑与手动创建运行时完全一致。

## 多线程模式

- 默认情况下，Tokio 会为每个 CPU 核心启动一个线程（可自行控制）
- 每个线程都有自己独立的任务队列（task list）
- 每个线程都有自己的反应器（reactor），即事件循环
- 每个线程都支持工作窃取（work stealing）
- 可以自定义配置线程数量，以及每个线程的事件循环数量

## 实操

### 示例三

```rust
use tokio::runtime;

async fn hi() {
    println!("Hello tokio!");
}

fn main() {
    let rt = runtime::Builder::new_multi_thread()
        .worker_threads(10)
        .thread_name("my-custom-name")
        .thread_stack_size(5 * 1024 * 1024)
        .event_interval(20)
        .max_blocking_threads(256)
        .enable_all()
        .build()
        .unwrap();

    rt.block_on(hi());
}

```

这段代码演示了如何使用 **Tokio 的多线程运行时（multi-thread runtime）** 来执行异步任务，并展示了运行时的多项自定义配置。

首先，定义了一个异步函数 `hi()`，执行时会打印 `"Hello tokio!"`。在 `main()` 函数中，通过 `tokio::runtime::Builder::new_multi_thread()` 创建一个 **多线程版 Tokio 运行时**，它允许在多个线程间并发执行异步任务。接下来的配置项依次指定运行时的详细参数：

- `.worker_threads(10)`：设置用于执行异步任务的工作线程数为 10；
- `.thread_name("my-custom-name")`：为这些工作线程统一命名，方便调试与日志查看；
- `.thread_stack_size(5 * 1024 * 1024)`：为每个线程分配 5 MB 的栈空间；
- `.event_interval(20)`：控制事件循环中每轮轮询的频率，影响任务切换的灵敏度；
- `.max_blocking_threads(256)`：允许最多 256 个阻塞任务（例如文件 I/O）同时运行；
- `.enable_all()`：启用 Tokio 的所有核心功能模块（定时器、I/O、信号等）。

构建完成后，`.build().unwrap()` 创建运行时实例，`rt.block_on(hi())` 则在运行时中执行异步函数 `hi()` 并阻塞主线程直到其完成。

程序运行后将在控制台输出：

```rust
Hello tokio!
```

这段代码的核心意义在于：**展示如何手动构建并精细化配置一个高性能、可并发执行的 Tokio 多线程运行时**，从而为复杂的异步任务提供灵活的调度环境。

### 运行

```bash
➜ cargo run
   Compiling tokio_intro v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/tokio_intro)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.75s
     Running `target/debug/tokio_intro`
Hello tokio!
```

这段运行结果说明程序已成功编译并执行。`cargo run` 命令首先编译项目 `tokio_intro`（如输出所示的 `Compiling` 与 `Finished` 表示编译过程完成并生成可执行文件），随后运行生成的二进制文件 `target/debug/tokio_intro`。程序启动后，Tokio 构建了一个多线程异步运行时，并在其中执行了异步函数 `hi()`。该函数的作用是在控制台打印 `"Hello tokio!"`，因此运行结果中最后输出了这一行文本，表示异步任务被成功调度并顺利执行完毕。

## 总结

> Tokio 是 Rust 异步生态中的核心运行时，它提供了 Executor、Reactor、异步 I/O 等关键组件，支撑着高性能并发应用。本文通过三个实操示例，完整演示了 Tokio 运行时的两种主要使用方式：
>
> 1. **手动创建单线程运行时**：适用于精确控制或资源受限环境。
> 2. **使用宏简化**：利用 `#[tokio::main]` 宏，实现简洁的异步主函数入口。
> 3. **手动创建多线程运行时**：通过 `new_multi_thread()` 实现高性能并发任务调度和精细化配置。 掌握 Tokio 的运行时配置，是编写高效、可扩展 Rust 异步代码的基础。无论是小型嵌入式系统还是大规模服务器，Tokio 都能提供灵活且强大的异步解决方案。

## 参考

- <https://tokio.rs/>
- <https://github.com/tower-rs/tower>
- <https://rust-lang.org/zh-CN/>
- <https://course.rs/about-book.html>
- <https://doc.rust-lang.org/stable/rust-by-example/>
