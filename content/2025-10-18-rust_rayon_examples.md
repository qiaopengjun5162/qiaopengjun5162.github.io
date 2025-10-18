+++
title = "Rust 并行加速：4 个实操案例，深度解析 Rayon 线程池的 Fork-Join 与广播机制"
description = "Rust 并行加速：4 个实操案例，深度解析 Rayon 线程池的 Fork-Join 与广播机制"
date = 2025-10-18T06:21:05Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# **Rust 并行加速：4 个实操案例，深度解析 Rayon 线程池的 Fork-Join 与广播机制**

在现代软件开发中，充分利用多核 CPU 的并行计算能力是提升应用性能的关键。Rust 语言通过其**零成本抽象**和**所有权系统**，在并发编程方面提供了卓越的安全保障。而 **Rayon** 库，作为 Rust 生态中最受欢迎的并行数据处理工具，更是将复杂的多线程编程简化为几行代码。

本文将通过 4 个精选的 Rayon 线程池实操案例，从最基本的矩阵求和到高级的线程广播和 `join` 模式，**深入浅出地**解释 Rayon 如何在底层实现高效的**任务并行（Task Parallelism）**、保证**结构化同步（Structured Concurrency）**，并揭示其并行输出的**非确定性**特征。无论您是 Rust 初学者还是希望进一步优化 CPU 密集型任务的开发者，都将从这些实战示例中获益。

本文通过 4 个 Rayon 实例，实操演示了 Rust 多线程并行计算的核心机制。我们创建自定义 4 线程线程池，并重点解析了 `scope` 的**并行任务分发**、**输出顺序不确定性**，以及 `scope` 和 `join` 的**强制同步（Fork-Join）**特性。同时，还展示了用于线程本地初始化的 `spawn_broadcast` 功能。通过两次运行结果对比，清晰展现了 Rayon 在提供强大并行能力的同时，如何利用作用域安全地管理并发任务的生命周期。

## 实操

Rust 多线程 - Rayon

### 示例一

```rust
fn main() {
    let pool = rayon::ThreadPoolBuilder::new()
        .num_threads(4)
        .build()
        .unwrap();

    let matrix = [
        vec![1, 2, 3],
        vec![4, 5, 6],
        vec![7, 8, 9],
        vec![10, 11, 12],
    ];

    pool.scope(|scope| {
        for (i, row) in matrix.iter().enumerate() {
            scope.spawn(move |_| {
                let sum: i32 = row.iter().sum();
                println!("Row {i} sum = {sum}");
            });
        }
    });

    println!("Main thread finished");
}

```

这段 Rust 代码使用了 **Rayon** 库来创建一个自定义的线程池并执行并行任务。

代码的详细解释如下：

1. **创建线程池**:

   ```rust
   let pool = rayon::ThreadPoolBuilder::new()
       .num_threads(4)
       .build()
       .unwrap();
   ```

   这行代码使用 `rayon::ThreadPoolBuilder` 构建了一个名为 `pool` 的自定义线程池。

   - `.num_threads(4)` 指定线程池中包含 **4** 个工作线程。
   - `.build()` 尝试创建线程池。
   - `.unwrap()` 处理可能出现的错误（例如线程创建失败），如果成功则返回 `ThreadPool` 实例。

2. **定义数据**:

   ```rust
   let matrix = [
       vec![1, 2, 3],
       vec![4, 5, 6],
       vec![7, 8, 9],
       vec![10, 11, 12],
   ];
   ```

   定义了一个包含 4 个向量的数组 `matrix`，可以将其视为一个 4 X 3 的矩阵。

3. **使用作用域（Scoped Task）执行并行任务**:

   ```rust
   pool.scope(|scope| {
       // ... 任务定义 ...
   });
   ```

   `pool.scope(|scope| { ... })` 创建了一个 **"fork-join" 作用域**。在这个作用域内部（即闭包 `{ ... }` 内部）可以安全地启动并发任务，这些任务可以借用外部栈上的局部变量（例如 `matrix`）。**关键点在于，当 `scope` 闭包返回时，程序会阻塞，直到所有通过 `scope.spawn()` 启动的任务都完成**。

4. **分发任务**:

   ```rust
   for (i, row) in matrix.iter().enumerate() {
       scope.spawn(move |_| {
           let sum: i32 = row.iter().sum();
           println!("Row {i} sum = {sum}");
       });
   }
   ```

   - `matrix.iter().enumerate()` 遍历 `matrix` 数组，同时获取行索引 `i` 和行数据 `row`（一个向量的引用 `&Vec<i32>`）。
   - `scope.spawn(move |_| { ... })` 在线程池中创建一个新的异步任务。
     - `move` 关键字确保闭包获得了它所使用的变量（这里是 `i` 和 `row`）的所有权或所有必要的拷贝。由于 `row` 是对 `matrix` 元素的引用，Rayon 的 scoped task 机制保证了在任务完成之前 `matrix` 不会被释放，从而使这个引用是安全的。
     - 每个任务都并行地计算一行向量的元素之和 (`row.iter().sum()`)，并打印结果。
     - 因为有 4 行数据和 4 个线程，理论上这 4 个求和任务可以同时在 4 个线程上并行执行（但实际调度取决于 Rayon 运行时）。

5. **主线程继续执行**:

   ```rust
   println!("Main thread finished");
   ```

   这行代码会在 `pool.scope(|...| { ... })` 完成（即所有并行任务都执行完毕）之后，由主线程执行并打印出来，这证明了 **scoped task 机制确保了任务的完成性**。

**总结**:

这段代码利用 Rayon 库创建了一个 4 线程的线程池，然后使用一个 **scoped task** 机制将一个矩阵的 **4 行数据的求和任务** 分发给线程池中的线程进行 **并行计算**。程序保证在打印 "Main thread finished" 之前，所有行的求和任务都已经完成并打印了各自的结果。这是一种典型的 **Fork-Join** 并行模式的实现。

### 运行

```bash
RustJourney/rayon_examples on  main [?] is 📦 0.1.0 via 🦀 1.90.0 took 2.7s
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/rayon_examples`
Row 3 sum = 33
Row 1 sum = 15
Row 2 sum = 24
Row 0 sum = 6
Main thread finished

RustJourney/rayon_examples on  main [?] is 📦 0.1.0 via 🦀 1.90.0
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.01s
     Running `target/debug/rayon_examples`
Row 3 sum = 33
Row 0 sum = 6
Row 1 sum = 15
Row 2 sum = 24
Main thread finished

```

这段运行结果清晰地展示了 **Rayon 库进行并行计算**的两个关键特性：**并行性（Parallelism）** 和 **确定性同步（Deterministic Synchronization）**。

1. **并行性与输出顺序不确定性（Non-deterministic Output Order）**:
   - 代码为矩阵的四行创建了四个独立的并行任务，分别计算 `Row 0` 到 `Row 3` 的和。
   - 在两次运行中，**`Row 0 sum` 到 `Row 3 sum` 的输出顺序是不同的**（第一次是 3, 1, 2, 0；第二次是 3, 0, 1, 2）。这正是使用 **Rayon 线程池** 进行并行计算的直接体现。由于这四个求和任务是并发执行的，它们完成的顺序取决于操作系统对线程的调度以及线程池中 4 个工作线程的可用性，因此 **输出顺序是不确定的**。
2. **作用域同步保证（Scoped Synchronization Guarantee）**:
   - 尽管并行任务的输出顺序不确定，但在两次运行中，**`Main thread finished` 总是最后打印**。
   - 这证明了 `pool.scope(|...| { ... })` 机制的有效性：主线程会**阻塞**并等待 `scope` 闭包内所有通过 `scope.spawn()` 启动的并行任务（即所有行的求和任务）**全部完成后**，才会继续执行 `scope` 之后的代码 (`println!("Main thread finished")`)。这确保了主程序的正确同步，即所有并行工作都已完成。

### 示例二

```rust
fn main() {
    let outer_pool = rayon::ThreadPoolBuilder::new()
        .num_threads(2)
        .build()
        .unwrap();

    outer_pool.scope(|scope| {
        for stage in 0..2 {
            scope.spawn(move |_scope| {
                println!("Stage {stage} started.");

                let inner_pool = rayon::ThreadPoolBuilder::new()
                    .num_threads(2)
                    .build()
                    .unwrap();

                inner_pool.scope(|inner_scope| {
                    for task in 0..2 {
                        inner_scope.spawn(move |_inner_scope| {
                            println!("\t-> Inner task {task} of stage {stage} started.");
                        });
                    }
                });

                println!("\t-> Stage {stage} completed.");
            });
        }
    });

    println!("-> All stages completed.");
}

```

这段 Rust 代码演示了 Rayon 线程池的**嵌套使用**，但其实现方式在性能上是**低效且不推荐的**，因为它在并行任务内部**反复创建新的线程池**。

### 代码结构与逻辑解释

1. 外部线程池创建:

   代码首先创建了一个名为 outer_pool 的 2 线程 Rayon 线程池。这个线程池用于执行顶层的并行任务。

2. 外部作用域（Outer Scope）:

   outer_pool.scope(|scope| { ... }) 创建了一个外部 "fork-join" 作用域。在这个作用域内，代码通过循环执行了两次 scope.spawn()，启动了 2 个并行任务，分别对应 stage 0 和 stage 1。

3. 内部任务逻辑（低效部分）:

   在每个 stage 的任务内部，代码执行了以下操作：

   - 打印 `Stage {stage} started.`。
   - **在运行时动态创建**了一个名为 `inner_pool` 的 **新的 2 线程 Rayon 线程池**。
   - 使用 `inner_pool.scope(|inner_scope| { ... })` 再次创建了一个作用域，并在其中启动了 **2 个**更小的并行任务（`inner task 0` 和 `inner task 1`）。
   - `inner_pool.scope` 会**阻塞**，直到这两个内部任务完成并打印 `-> Inner task ... started.`。
   - 内部作用域完成后，**`inner_pool` 被销毁**（当 `stage` 任务结束时），然后打印 `-> Stage {stage} completed.`。

4. 同步机制:

   最外层的 outer_pool.scope 会阻塞主线程，直到 stage 0 和 stage 1 这两个并行任务全部完成。当所有工作完成后，主线程才会打印 -> All stages completed.。

### 核心要点和性能问题

这段代码的核心问题在于它**没有利用 Rayon 的工作窃取（Work Stealing）机制**。Rayon 的设计宗旨是使用**一个全局线程池**，通过 `rayon::scope` 或并行迭代器 (`par_iter`) 在这个单一线程池内高效地调度任务。

然而，这段代码的实现方式是：

- `Stage 0` 任务启动后，它会在 **`outer_pool` 的一个线程**上运行。
- 在该线程上，它又创建了 **4 个全新的系统线程**（通过 `inner_pool`）来处理内部任务。
- 最终，程序在运行过程中可能同时拥有 **6 个或更多的系统线程**（主线程 1 个 + `outer_pool` 2 个 + 两个 `inner_pool` 各 2 个），这造成了**额外的线程创建和销毁开销**，浪费了资源。

**正确的 Rayon 实践**是在一个线程池内部，直接使用 `rayon::scope` 或 `rayon::spawn` 来分发任务，**而不是在任务内部创建新的线程池**。

### 运行

```bash
RustJourney/rayon_examples on  main [?] is 📦 0.1.0 via 🦀 1.90.0
➜ cargo run
   Compiling rayon_examples v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rayon_examples)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.63s
     Running `target/debug/rayon_examples`
Stage 1 started.
Stage 0 started.
        -> Inner task 1 of stage 1 started.
        -> Inner task 0 of stage 1 started.
        -> Inner task 1 of stage 0 started.
        -> Inner task 0 of stage 0 started.
        -> Stage 0 completed.
        -> Stage 1 completed.
-> All stages completed.

RustJourney/rayon_examples on  main [?] is 📦 0.1.0 via 🦀 1.90.0
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.06s
     Running `target/debug/rayon_examples`
Stage 1 started.
Stage 0 started.
        -> Inner task 1 of stage 1 started.
        -> Inner task 0 of stage 1 started.
        -> Inner task 1 of stage 0 started.
        -> Inner task 0 of stage 0 started.
        -> Stage 0 completed.
        -> Stage 1 completed.
-> All stages completed.
```

这段运行结果清晰地展示了 **Rayon 线程池的并行和同步机制**，即使是在这种不推荐的**线程池嵌套**场景中。

1. 顶层任务并行性（不确定顺序）:

   两次运行的输出都以 Stage 1 started. 和 Stage 0 started. 交替开始，例如第一次运行是 Stage 1 先于 Stage 0 启动。这表明最外层 outer_pool 将 stage 0 和 stage 1 任务作为并行任务分发给了其两个工作线程，它们的启动顺序是不确定的，体现了并发执行。

2. 内部任务并行性:

   一旦某个 stage 启动，它会立即在其内部创建并激活一个新的 inner_pool，然后并行地启动 inner task 0 和 inner task 1。因此，可以看到来自不同 Stage 的内部任务（如 Inner task 1 of stage 1 和 Inner task 1 of stage 0）的启动信息是混合交错在一起的，证实了它们也是并发执行的。

3. Scoped Task 的同步保证（确定性完成）:

   尽管所有的 started 消息都是不确定的交错输出，但程序的完成顺序是严格确定的：

   - **首先**，每个 `inner_pool.scope` 保证其内部的两个 `Inner task` 结束后，才能打印相应的 `-> Stage X completed.`。
   - **其次**，最外层 `outer_pool.scope` 保证**所有 `Stage` 任务**（`Stage 0` 和 `Stage 1`）都打印了 `completed` 消息后，**主线程**才会继续执行，最终打印 `-> All stages completed.`。

因此，结果表明：**并行任务的执行顺序是随机的**，但 Rayon 的 **"fork-join" 作用域**机制保证了程序会**等待所有子任务完成后**，才允许流程进入下一阶段，从而实现正确的程序同步。

### 示例三

线程广播

```rust
fn main() {
    let pool = rayon::ThreadPoolBuilder::new()
        .num_threads(4)
        .build()
        .unwrap();

    pool.scope(|scope| {
        scope.spawn_broadcast(|_scope, ctx| {
            let id = ctx.index();
            println!("Thread {id}.");
        });
    });
}

```

这段 Rust 代码利用 Rayon 库展示了**线程广播（Thread Broadcast）**这一高级功能，它用于在自定义线程池的所有工作线程上运行相同的任务，通常用于**线程本地初始化或状态同步**。

1. 线程池创建:

   代码首先使用 `rayon::ThreadPoolBuilder::new().num_threads(4).build().unwrap()` 创建了一个包含 4 个 工作线程的自定义线程池 pool。

2. Scoped Task（作用域）:

   `pool.scope(|scope| { ... })` 创建了一个 "fork-join" 作用域，确保在主线程继续执行之前，作用域内所有派生的并行任务都将完成。

3. 线程广播任务:

   核心是 `scope.spawn_broadcast(|_scope, ctx| { ... })`。这个方法不是像 spawn 那样创建一个任务让任一空闲线程去执行，而是特意为线程池中的 每一个 工作线程都安排一个相同的任务去执行。

   - 闭包接收一个 `BroadcastContext` 结构体 `ctx`。
   - `ctx.index()` 方法会返回**当前正在执行此广播任务的线程**在线程池中的**唯一索引**（从 0 到线程数减 1)。

**总结**:

这段代码的功能是：在创建的 4 线程线程池的**每个线程**上运行一个任务，每个任务打印出自己线程的索引。因此，代码的运行结果会打印出 4 行消息，内容是 `Thread 0.`、`Thread 1.`、`Thread 2.`、`Thread 3.`，但由于并行执行，这 4 行的**输出顺序是不确定的**。这个模式非常适合用于在并行工作开始前，对每个 Rayon 工作线程的**本地状态进行设置**或**进行一次性操作**。

### 运行

```bash
➜ cargo run
   Compiling rayon_examples v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rayon_examples)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.57s
     Running `target/debug/rayon_examples`
Thread 0.
Thread 1.
Thread 3.
Thread 2.
```

这段运行结果完美地证实了 `scope.spawn_broadcast()` **线程广播**功能的行为以及 **Rayon 的并行特性**。

1. **广播执行**: 代码创建了一个包含 4 个线程的线程池，并使用 `spawn_broadcast` **精确地在线程池的每个工作线程上**执行了一次任务。因此，程序输出了 4 条 `Thread X.` 消息，分别对应线程索引 0 到 3，这证明了广播任务确实在所有线程上运行了。
2. **并行性与输出顺序不确定性**: 尽管这 4 个线程任务是同时被启动的，但由于操作系统的**线程调度**机制，这些任务完成和打印输出的顺序是**不确定的**。运行结果中的输出顺序是 `0, 1, 3, 2`，而不是严格的升序 `0, 1, 2, 3`，这充分体现了 Rayon 在多个核心上并行执行任务时，任务完成顺序的**非确定性**。

**结论**: 运行结果表明，线程广播任务在线程池的所有 4 个线程上都成功执行，并且输出顺序的不确定性是并发编程的典型特征。

### 示例四

线程池 JOIN

```rust
fn main() {
    let pool = rayon::ThreadPoolBuilder::new()
        .num_threads(4)
        .build()
        .unwrap();

    let func = || println!("Hello, world!");

    pool.join(func, func);
}

```

这段 Rust 代码利用 Rayon 库展示了**结构化并行中的 "分叉-汇合" (Fork-Join) 模式**，旨在高效地并行执行两个独立的任务。

1. 线程池初始化:

   代码首先创建了一个名为 pool 的自定义 Rayon 线程池，并使用 .num_threads(4) 明确指定该线程池拥有 4 个 工作线程。这确保了后续的并行任务会在这个受控的环境中执行。

2. 定义任务:

   定义了一个简单的闭包 func，其唯一的副作用是打印 "Hello, world!"。

3. 分叉-汇合操作:

   核心操作是 `pool.join(func, func)`。join 是 Rayon 提供的最基本且最高效的并行操作之一，它将两个闭包（oper_a 和 oper_b）作为参数：

   - **分叉 (Fork)**: `join` 函数会尝试同时启动这两个任务。具体来说，当前调用 `join` 的线程会立即执行第一个闭包 (`func`)，同时将第二个闭包 (`func`) 作为一个新的并行任务提交给线程池。
   - **汇合 (Join)**: `join` 是一个**阻塞式**调用。它会一直等待，直到这两个闭包（无论它们在哪个线程上执行）都**彻底完成**并返回结果后，`join` 才会返回一个包含两个闭包返回值的元组。

总结:

这段代码通过自定义的 4 线程 Rayon 线程池，并行执行了两次打印 "Hello, world!" 的操作。由于这两个任务是并发运行的，它们在控制台输出的顺序将是不确定和交错的（但最终会输出两次 "Hello, world!"）。pool.join() 确保了主线程会等待这两个并行任务完成后，程序才继续向下或结束。这种模式常用于递归算法（如快速排序）的分治并行化，具有极高的效率，因为它主要利用栈分配来管理任务，避免了复杂的堆分配开销。

### 运行

```bash
➜ cargo run
   Compiling rayon_examples v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rayon_examples)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.45s
     Running `target/debug/rayon_examples`
Hello, world!
Hello, world!
```

这段运行结果是前述 Rust 代码执行 `pool.join(func, func)` 的直接体现，结果是程序输出了两行 `"Hello, world!"`。

1. **并行任务执行**: `pool.join(func, func)` 机制启动了两个完全相同的任务（即两次调用打印 `"Hello, world!"` 的闭包 `func`），并在创建的 4 线程 Rayon 线程池中**并行**执行。
2. **任务完成和同步**: 由于每个任务都只执行了一个简单的打印操作，它们几乎瞬间完成。`join` 操作保证了主程序会等待这两个并行任务都完成，因此确保了两次 `"Hello, world!"` 消息都成功输出。
3. **确定性输出（偶然）**: 尽管 Rayon 是并行执行任务的，且任务的完成顺序通常是不确定的，但由于这两个任务的代码完全相同且执行速度极快，系统调度器在本次运行中恰好使得这两个打印操作紧接着完成并输出了两次 `"Hello, world!"`。

**结论**: 运行结果证实了 `rayon::join` 成功地在线程池中并行执行了两个任务，并且主线程在所有并行工作完成后才结束。

## 总结

通过对这四个 Rayon 核心 API 的实操和结果分析，我们深刻理解了 Rayon 在 Rust 多线程编程中的强大和优雅：

1. **结构化同步的保证（`scope` 和 `join`）**: Rayon 的 `scope` 和 `join` API 实现了经典的 **Fork-Join 模式**。它保证了父任务在所有子并行任务彻底完成之前不会结束，从而消除了传统线程中常见的生命周期和数据安全问题。
2. **并行执行的非确定性**: 无论是使用 `scope.spawn()` 还是 `spawn_broadcast`，任务在线程池中的执行顺序都由操作系统调度和 Rayon 的**工作窃取**机制决定，因此输出顺序是随机的，这是并行编程的固有特征。
3. **高级控制能力**: `ThreadPoolBuilder` 允许我们精确控制线程池大小；`spawn_broadcast` 则提供了在每个工作线程上执行一次任务的独特能力，非常适合复杂的线程本地状态初始化。

Rayon 使得 Rust 开发者能够以安全、高效且易于理解的方式，释放现代多核 CPU 的全部潜能，是进行 CPU 密集型任务优化的首选工具。

## 参考

- <https://www.rust-lang.org/>
- <https://github.com/rayon-rs/rayon>
- <https://docs.rs/rayon/latest/rayon/>
- <https://stackoverflow.com/questions/78095243/using-par-iter-and-rayon-in-rust>
- <https://users.rust-lang.org/t/optimizations-in-rayon/121580>
