+++
title = "Rust并发安全基石：Mutex与RwLock深度解析"
description = "Rust并发安全基石：Mutex与RwLock深度解析"
date = 2025-08-21T14:26:07Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust并发安全基石：Mutex与RwLock深度解析

在多线程编程中，如何安全、高效地共享和修改数据是一个永恒的核心难题。Rust通过其严格的所有权和借用检查机制，在编译期就为我们杜绝了大量数据竞争问题。但当多个线程确实需要访问同一份数据时，我们就必须借助强大的同步原语（Synchronization Primitives）。

`Mutex`（互斥锁）和`RwLock`（读写锁）正是Rust标准库为此提供的两大并发安全基石。本文将通过详尽的原理讲解和可运行的代码实例，带你深入探索这两者的工作机制、核心区别、适用场景，并揭示其独特的“锁中毒”（Lock Poisoning）安全策略。在此之前，我们也会先回顾单线程环境下的内部可变性工具`Cell`与`RefCell`，为彻底理解并发安全打下坚实的基础。

本文深度解析Rust并发编程核心Mutex与RwLock。Mutex保障线程安全的独占访问，RwLock则为“读多写少”场景提供性能优化。文章通过丰富的代码实例，详细讲解其工作原理、借用规则及关键的“锁中毒”恢复机制，助你构建安全、健壮的并发程序。

## 本文内容

- `Cell<T>`
- `RefCell<T>`
- `Mutex`
- `RwLock`

## `Cell<T>`

`Cell<T>` 和 `RefCell<T>` 都实现了内部可变性模式。

内部可变性：通过不可变引用来修改其持有的值。

对于一个对象 T，只能存在以下两种情况之一：

1. 若干个指向该对象的不可变引用 (`&T`)
2. 一个指向该对象的可变引用 (`&mut T`)

Cell 只能用于单线程

- 通过移动(move) 值的方式实现内部可变性
- 无法获取到内部值的 `&mut T`
- 无法直接获取内部的值，除非用别的值替换它
- 确保不会有多个引用同时指向内部的值
- 针对实现了 `Copy` 的类型，`get` 方法可通过复制的方式获取内部值
- 针对实现了`Default`的类型，`take` 方法会将当前内部值替换为 `Default::default()`，并返回原来的值
- 针对所有类型
  - Replace 方法，替换当前内部值，返回原来的内部值
  - into_inner 方法，消耗 (consume) 掉这个 `Cell<T>`，并返回内部值
  - set 方法，替换当前的内部值，丢弃原来的值
- `Cell<T>` 一般用于简单类型（如数值），因为复制/移动不会太消耗资源，它无法获取内部类型的直接引用
- 在可能得情况下应该优先使用`Cell<T>` 而不是其它的 Cell 类型
- 对于较大的或者不可复制 (non-copy) 的类型，RefCell 更有优势

## `Cell<T>`实操

```rust
use std::cell::Cell;

fn main() {
    let cell = Cell::new(5);
    assert_eq!(cell.get(), 5);

    assert_eq!(cell.replace(10), 5);
    assert_eq!(cell.get(), 10);

    let ten = cell.into_inner();
    assert_eq!(ten, 10);

    let cell = Cell::new(String::from("hello"));
    assert_eq!(cell.take(), "hello");
    assert_eq!(cell.take(), String::default());

    cell.set(String::from("world"));
    assert_eq!(cell.take(), "world");
}

```

### 运行

```bash
RustJourney/cell on  main [?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
   Compiling cell v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/cell)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.28s
     Running `target/debug/cell`
```

## `RefCell<T>`

- 与 `Cell<T>` 不同，`RefCell<T>` 允许直接借用它的内部值，但是会有一点运行时开销
- `RefCell<T>` 不仅持有 T  的值，还持有一个计数器，用来追踪有多少个借用
  - 借用是在运行时被追踪的
  - Rust 的原生引用类型在编译时进行静态检查
- `borrow()`：可以获取对 `RefCell` 内部值的不可变引用 (`&T`)
- `borrow_mut()`：可以获取对 `RefCell` 内部值的可变引用 (`&mut T`)
- 其它：`try_borrow()`、`try_borrow_mut()`、`into_inner()`、`replace()`、`take()`...
- 借用规则：
  - 任意数量的不可变借用 (&T)
  - 或单个可变借用 (&mut T)
  - 如果违反规则则线程会 panic
- 在同一作用域内，一个值要么可以有多个不可变借用（&T），要么只能有一个可变借用（&mut T）。

## `RefCell<T>` 实操

```rust
use std::cell::RefCell;

fn main() {
    let rc = RefCell::new(5);
    println!("rc = {rc:#?}");

    {
        let five = rc.borrow();
        let five1 = rc.borrow();
        assert_eq!(*five, 5);
        assert_eq!(*five1, 5);
    }

    let mut f = rc.borrow_mut();
    *f += 10;
    assert_eq!(*f, 15);
    println!("f = {f:#?}");

    let v = rc.try_borrow();
    assert!(v.is_err());

    drop(f);

    // RefMut 实现了 Deref Trait
    *rc.borrow_mut() += 10;

    println!("rc = {rc:#?}");
}

```

### 运行

```bash
RustJourney/cell on  main [?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.04s
     Running `target/debug/cell`
rc = RefCell {
    value: 5,
}
f = 15
rc = RefCell {
    value: 25,
}

```

## `Mutex`

Mutual Exclusion

互斥锁：一种用于保护共享数据的互斥原语。

- 原语 (primitive)：最基本、不可再分解的操作或机制
- `Mutex`：
  - 最常见的用于在线程间分享（可变）数据的工具
  - 只允许对数据的独占 (exclusive) 访问，临时阻塞同一时刻想要访问数据的其它线程

### `Mutex`两种状态 (LOCKED UNLOCKED)

- 访问数据前需要请求锁 (lock)
- 处理完成时需要移除锁 (unlock)
- 锁定 (locked)
- 未锁定 (unlocked)
- `Mutex` 锁定 Lock
- `Mutex` 解锁 unlock

- 这里的 unlock 是指等着 `MutexGuard` 走出作用域

- 解锁的线程与锁定的线程应该是同一个

### Lock Poisoning 锁中毒

- 当某个线程在持有 Mutex 时发生 panic，这个互斥锁就会被视为已中毒，不是“locked”状态
- 如果一个线程在持有 Mutex 锁时发生 panic，Mutex 将会“中毒”。为了防止访问可能已损坏的数据，此后其他线程对该 Mutex 的所有锁定请求都会失败。
- 调用 lock 和 try_lock 方法会返回一个 Result，用于指示该互斥锁是否已中毒
- 中毒的 Mutex 并不会阻止对底层数据的所有访问
- `PoisonError` 类型提供了一个 `into_inner` 方法，可以返回原本在成功加锁时会返回的守卫 (guard)
- 即使互斥锁已中毒，仍然可以访问到它所保护的数据
- Mutex 中毒会使常规的加锁操作（如 `.unwrap()`）失败以默认阻止访问，但它并不彻底锁死数据，而是通过返回一个 `PoisonError` 给予程序员选择权，可以从中显式地恢复数据访问权限。

## `Mutex`实操

```rust
use std::{sync::Mutex, thread};

static NUMBERS: Mutex<Vec<u32>> = Mutex::new(Vec::new());

fn main() {
    let mut handles = Vec::new();
    for _ in 0..20 {
        let handle = thread::spawn(move || {
            let mut numbers = NUMBERS.lock().unwrap();
            numbers.push(42);
        });
        handles.push(handle);
    }

    handles
        .into_iter()
        .for_each(|handle| handle.join().unwrap());

    let numbers = NUMBERS.lock().unwrap();
    println!("{:?}", numbers);
}

```

### 运行

```bash
RustJourney/cell on  main [?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
   Compiling cell v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/cell)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.33s
     Running `target/debug/cell`
[42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42, 42]
```

### `Mutex` 中毒示例

```rust
use std::{
    sync::{Arc, Mutex},
    thread,
};

fn main() {
    let data = Arc::new(Mutex::new(0));

    {
        let data = Arc::clone(&data);
        thread::spawn(move || {
            let mut data = data.lock().unwrap();
            *data += 1;
            panic!();
        })
        .join()
        .unwrap_err();
    }

    {
        let data = Arc::clone(&data);
        thread::spawn(move || match data.lock() {
            Ok(mut guard) => {
                println!("Thread 2: OK!");
                *guard += 10000;
            }
            Err(poisoned) => {
                println!("Thread 2: Poisoned!");
                let mut guard = poisoned.into_inner();
                *guard += 1;
                println!("Thread 2: New value {}", *guard);
            }
        })
        .join()
        .unwrap();
    }
}

```

### 运行

```bash
RustJourney/cell on  main [?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
   Compiling cell v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/cell)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.02s
     Running `target/debug/cell`

thread '<unnamed>' panicked at src/main.rs:14:13:
explicit panic
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
Thread 2: Poisoned!
Thread 2: New value 2
```

## `RwLock` 读写锁

- `RwLock` 允许多个“读取者”（共享只读访问）或单个“写入者”（独占可写访问）。
- 适用于“读多写少”的并发场景。
- 三种状态：未锁定、由独占的写入者锁定、由任意数量的读取者锁定
- `std::sync::RwLock<T>`
- 锁定的方法
  - `read()` --> `RwLockReadGuard (Deref)`
  - `write()` --> `RwLockWriteGuard (Deref & DerefMut)`
- T：是`Send` 和 `Sync`
- `Send`：类型可以跨线程传输
- `Sync`：可以在多个线程之间安全共享引用
- 是跨线程版本的 RefCell？
- std 的 RwLock：其具体事项依赖于操作系统
- 大多数实现：如果有写入者在等待，那么就先阻塞新的读取者（即使当前是读取锁定的状态）
- 读写锁 (RwLock) 在发生 panic 时也可能进入中毒状态
- 与 `Mutex` 不同，`RwLock` 只有在写入者（持有写锁）panic 时才会中毒；读取者 panic 并不会导致中毒
- 如果 panic 发生在任意一个读取者中，那么该锁不会被中毒

## `RwLock` 实操

```rust
use std::{
    sync::{Arc, RwLock},
    thread,
};

fn main() {
    let counter = Arc::new(RwLock::new(0));

    let mut handles = vec![];

    for i in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let value = counter.read().unwrap();
            println!("Thread {i} read the value {value}");
        });
        handles.push(handle);
    }

    {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut value = counter.write().unwrap();
            *value += 1;
            println!("Thread wrote the value {value}");
        });
        handles.push(handle);
    }

    handles
        .into_iter()
        .for_each(|handle| handle.join().unwrap());

    println!("Result: {}", *counter.read().unwrap());
}

```

### 运行

```bash
RustJourney/cell on  main [?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
   Compiling cell v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/cell)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.67s
     Running `target/debug/cell`
Thread 0 read the value 0
Thread 1 read the value 0
Thread 2 read the value 0
Thread 3 read the value 0
Thread 4 read the value 0
Thread 5 read the value 0
Thread 6 read the value 0
Thread 7 read the value 0
Thread 8 read the value 0
Thread 9 read the value 0
Thread wrote the value 1
Result: 1
```

## 总结

本文系统地探讨了Rust中从单线程到多线程的内存安全与状态共享机制。通过对`Cell`、`RefCell`、`Mutex`和`RwLock`的逐一解析，我们可以得出以下核心结论：

1. **分场景的工具箱**：Rust提供了层次分明的工具。`Cell`和`RefCell`在单线程内通过“内部可变性”解决了所有权与修改的矛盾，前者适用于`Copy`类型的值操作，后者则提供运行时的动态借用检查。
2. **并发安全的核心**：当进入多线程世界，`Mutex`和`RwLock`成为保障数据同步的基石。`Mutex`提供简单、绝对的互斥访问，是保证线程安全最通用的工具。而`RwLock`则是一种性能优化，它允许多个读取者并发访问，特别适用于“读多写少”的高性能场景。
3. **安全为先的“锁中毒”机制**：Rust的锁实现了一个关键的“中毒”概念。当持有写锁的线程发生`panic`时，锁会进入中毒状态，默认阻止后续线程的访问，以防止它们接触到可能已损坏的数据。同时，Rust也提供了从“中毒”中恢复数据的能力，给予了开发者处理异常的灵活性。

总而言之，理解并恰当选择这些工具是编写高效、安全Rust程序的关键。从`Cell`的简单值替换，到`RwLock`的复杂读写并发控制，Rust在赋予我们强大能力的同时，也通过精巧的设计，始终将内存安全放在首位。

## 参考

- <https://www.rust-lang.org/>
- <https://doc.rust-lang.org/book/>
- <https://course.rs/about-book.html>
