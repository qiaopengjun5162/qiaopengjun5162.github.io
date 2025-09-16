+++
title = "Rust 并发编程利器：`OnceCell` 与 `OnceLock` 深度解析"
description = "Rust 并发编程利器：`OnceCell` 与 `OnceLock` 深度解析"
date = 2025-09-16T14:00:40Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust 并发编程利器：`OnceCell` 与 `OnceLock` 深度解析

在 Rust 的并发编程世界中，如何安全高效地初始化共享数据是一个常见的挑战。`OnceCell` 和 `OnceLock` 作为标准库提供的强大工具，完美地解决了这一问题。它们的核心思想是“一次性”初始化：确保一个值只被设置一次，从而避免了复杂的数据竞争问题。本文将带你深入理解这两个类型，并通过一系列代码示例，探索它们在单线程和多线程环境下的应用。

本文深入探讨了 Rust 中的 `OnceCell` 和 `OnceLock` 类型，它们是用于单次初始化值的容器。`OnceCell` 适用于单线程环境，其核心方法包括 `get`、`set` 和 `get_or_init`，能够确保值只被设置一次，但允许在可变引用下修改。而 `OnceLock` 是其线程安全版本，专为多线程场景设计，通过原子操作确保了即使多个线程同时尝试初始化，也只有一个线程会成功，从而安全地实现了全局变量的惰性初始化。文章通过多个代码示例，清晰地展示了它们的工作原理和实际应用，包括构建线程安全的链表。

## Rust 多线程：OnceCell & OnceLock

### `OnceCell<T>`

- `OnceCell<T>` 在某种程度上是 Cell 和 RefCell 的混合体，用于那些通常只需要设置一次的值。
- 可以在不移动或复制内部值的情况下获得一个引用 &T
- 同时也不需要运行时检查
- 一旦设置后，它的值就不能再被更新，除非你对 OnceCell 本身有一个可变引用

### OnceCell 主要方法

- `get`：获取内部值的引用
- `set`：在值尚未设置时进行设置（返回一个 Result）
- `get_or_init`：返回内部值，如果需要则进行初始化
- `get_mut`：提供内部值的可变引用，但只有当你对 OnceCell 本身持有一个可变引用时才能使用
- 因为它是 Cell ，它不是线程安全的

## 实操

### 示例一

```rust
use std::cell::OnceCell;

fn main() {
    let cell = OnceCell::new();
    assert!(cell.get().is_none());

    let result = cell.set(String::from("hello"));
    assert!(result.is_ok());

    let result = cell.set(String::from("world"));
    assert!(result.is_err());
}

```

这段代码展示了如何使用 Rust 标准库中的 **`OnceCell`** 类型。你可以把它想象成一个“一次性”的容器。

------

`OnceCell` 的核心特性是它只能被 **成功赋值一次**。

- 首先，我们创建了一个空的 `OnceCell` 实例 `cell`，此时它里面没有任何值，所以 `cell.get().is_none()` 返回 `true`。
- 接着，我们尝试用 `String::from("hello")` 第一次给它赋值，这个操作是成功的，`cell.set()` 返回 `Ok(())`，所以 `result.is_ok()` 返回 `true`。
- 最后，我们试图用 `String::from("world")` **第二次** 给它赋值。由于 `OnceCell` 已经被填满，这次操作会失败，`cell.set()` 返回一个错误 `Err(String::from("world"))`，所以 `result.is_err()` 返回 `true`。

简而言之，这段代码通过两次 `set` 操作，清晰地演示了 `OnceCell` “只设置一次”的特性。

### 运行

```bash
➜ cargo run
   Compiling cell v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/cell)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.45s
     Running `target/debug/cell`
```

### 示例二

```rust
use std::cell::OnceCell;

fn main() {
    let cell = OnceCell::new();
    assert!(cell.get().is_none());

    let value = cell.get_or_init(|| "Hello, World!".to_string());
    assert_eq!(value, "Hello, World!");
    assert_eq!(cell.get(), Some(&"Hello, World!".to_string()));
    assert_eq!(cell.get(), Some(value));
    assert!(cell.get().is_some());
}

```

这段代码展示了 `OnceCell` 的一个核心功能：`get_or_init`。你可以把它想象成一个“惰性加载”的单例容器。

### `OnceCell` 的 `get_or_init` 方法

`OnceCell` 是一个特殊的容器，它要么是空的，要么只包含一个值。这段代码利用了 `get_or_init` 方法，这个方法非常实用：它首先会检查 `OnceCell` 是否已经有值。

- 如果 **没有** 值，它就会执行你提供的闭包（即 `|| "Hello, World!".to_string()`）来生成一个值，然后把这个新值存储到 `cell` 中，并返回一个该值的引用。
- 如果 **已经有** 值，它就会直接返回现有值的引用，而 **不会** 再次执行闭包。

通过这种机制，`OnceCell` 确保了数据只被初始化一次，即使你多次调用 `get_or_init`，也不会重复创建值。这对于需要进行昂贵或复杂初始化的场景非常有用，因为它保证了性能的同时也确保了数据的单例性。

### 运行

```bash
➜ cargo run
   Compiling cell v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/cell)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.61s
     Running `target/debug/cell`
```

### 示例三

```rust
use std::cell::OnceCell;

fn main() {
    let mut cell = OnceCell::new();
    let _ = cell.set(String::from("hello"));

    if let Some(value_ref) = cell.get_mut() {
        // *value_ref = "!".to_string();
        // value_ref.push('!');
        value_ref.push_str("!");
    }

    let _ = cell.set(String::from("World"));

    if let Some(value) = cell.get() {
        println!("Value: {value}");
    }
}

```

这段代码展示了 `OnceCell` 的一个关键特性：**在赋值后仍然可以修改其内部值**，但前提是你需要一个可变的 `OnceCell` 实例。

------

首先，我们创建一个可变的 `OnceCell` 实例 `cell`，并用 `"hello"` 成功地给它赋了初值。接着，我们使用 `cell.get_mut()` 方法，这个方法会返回一个可变的引用 `Some(&mut String)`，这允许我们修改 `OnceCell` 内部的 `String` 值。在这里，我们将 `!` 附加到字符串末尾，使其变为 `"hello!"`。然后，我们再次尝试用 `"World"` 赋值，这次操作会失败，因为 `OnceCell` 只能被成功赋值一次。最后，我们使用 `get()` 方法获取不可变的引用并打印出最终值，证明了尽管第二次赋值失败了，但对值的修改是成功的，最终输出为 `"Value: hello!"`。

### 运行

```bash
➜ cargo run
   Compiling cell v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/cell)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.40s
     Running `target/debug/cell`
Value: !

RustJourney/cell on  main [!?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
   Compiling cell v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/cell)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.30s
     Running `target/debug/cell`
Value: hello!

RustJourney/cell on  main [!?] is 📦 0.1.0 via 🦀 1.89.0
➜ cargo run
   Compiling cell v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/cell)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.29s
     Running `target/debug/cell`
Value: hello!
```

##### 它只能 set 一次，第二次 set 并没有成功。但是获得 cell 的可变引用后你可以就地修改

### `OnceLock<T>`

- 一种同步原语，只能被写入一次（初始化一次）
- 是线程安全的 OnceCell，可以在 static 中使用
- 用于线程安全的、一次性的变量初始化，并且可以根据调用者使用不同的初始化函数

### 示例四

```rust
use std::{sync::OnceLock, thread};

static LOCK: OnceLock<usize> = OnceLock::new();

fn main() {
    assert!(LOCK.get().is_none());
    thread::spawn(|| {
        let value = LOCK.get_or_init(|| 42);
        assert_eq!(*value, 42);
        assert_eq!(value, &42);
        assert_eq!(LOCK.get(), Some(&42));
    })
    .join()
    .unwrap();

    assert_eq!(LOCK.get(), Some(&42));
}

```

这段代码展示了 `OnceLock` 的主要用途：**在多线程环境下安全地进行一次性初始化**。 `OnceLock` 是 `OnceCell` 的线程安全版本，它确保了即使有多个线程同时尝试初始化，也只有一个线程会成功，而其他线程会等待，并最终得到同一个初始化后的值。

------

代码中，我们定义了一个静态的、全局可用的 `OnceLock` 变量 `LOCK`。在主线程中，我们创建了一个新线程。这个新线程中的 `LOCK.get_or_init(|| 42)` 方法会检查 `LOCK` 是否已经被初始化：

- 如果是第一次调用，它就会执行闭包 `|| 42` 来生成值 `42`，然后将这个值原子性地存储到 `LOCK` 中，并返回一个对该值的引用。
- 如果其他线程同时调用 `get_or_init`，它们会等待第一个线程完成初始化，然后直接获取到同一个值，而不会重复执行初始化逻辑。

最后，当子线程执行完毕并返回主线程后，主线程通过 `assert_eq!(LOCK.get(), Some(&42))` 验证了 `LOCK` 已经成功被初始化，并包含了 `42` 这个值。这证明了 `OnceLock` 能够跨线程安全地完成一次性初始化。

### 运行

```bash
➜ cargo run
   Compiling cell v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/cell)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.60s
     Running `target/debug/cell`
```

可以看到 OnceLock 是线程安全的，而 OnceCell 不是。

### 示例五

```rust
use std::{
    sync::{
        OnceLock,
        atomic::{AtomicU32, Ordering},
    },
    thread,
};

static LIST: OnceList<u32> = OnceList::new();
static COUNTER: AtomicU32 = AtomicU32::new(0);

const LEN: u32 = 1000;

fn main() {
    thread::scope(|s| {
        for _ in 0..thread::available_parallelism().unwrap().get() {
            s.spawn(|| {
                while let i @ 0..LEN = COUNTER.fetch_add(1, Ordering::Relaxed) {
                    LIST.push(i);
                }
            });
        }
    });

    for i in 0..LEN {
        assert!(LIST.contains(&i));
    }
}

struct OnceList<T> {
    data: OnceLock<T>,
    next: OnceLock<Box<OnceList<T>>>,
}

impl<T> OnceList<T> {
    const fn new() -> OnceList<T> {
        OnceList {
            data: OnceLock::new(),
            next: OnceLock::new(),
        }
    }

    fn push(&self, value: T) {
        if let Err(value) = self.data.set(value) {
            let next = self.next.get_or_init(|| Box::new(OnceList::new()));
            next.push(value);
        }
    }

    fn contains(&self, example: &T) -> bool
    where
        T: PartialEq<T>,
    {
        self.data
            .get()
            .map(|value| value == example)
            .filter(|v| *v)
            .unwrap_or_else(|| {
                self.next
                    .get()
                    .map(|next| next.contains(example))
                    .unwrap_or(false)
            })
    }
}

```

这段代码定义并使用了一个名为 `OnceList` 的自定义数据结构，它利用 **`OnceLock`** 和 **原子操作**，在多线程环境下构建了一个**线程安全且只支持尾部追加的链表**。

代码的核心思想是：

1. **`OnceList` 结构**: 每个 `OnceList` 节点都包含一个 `OnceLock` 来存储当前节点的值，以及另一个 `OnceLock` 来存储下一个节点的指针。`OnceLock` 的“只设置一次”特性保证了每个节点的值一旦被设置，就不会被修改，从而避免了数据竞争。
2. **`push` 方法**: 当多个线程同时调用 `push` 方法时，它们会尝试给当前的 `OnceList` 节点赋值。只有一个线程会成功(`self.data.set(value)` 返回 `Ok`)，而失败的线程(`self.data.set(value)` 返回 `Err`)则会通过 `get_or_init` 方法安全地获取或创建下一个节点，并将自己的值推送到下一个节点。这个过程会递归地进行，直到找到一个空的节点来存储值，从而确保所有线程都能安全地向列表中添加元素。
3. **多线程环境**: `main` 函数利用 `thread::scope` 和 `AtomicU32` 来生成一系列不重复的数字，并让多个线程并发地将这些数字推入 `OnceList`。即使多个线程同时对同一个节点进行操作，`OnceLock` 的内部机制也保证了操作的原子性和线程安全性。

最终，`main` 函数通过断言 (`assert!`) 验证了所有从 0 到 999 的数字都成功地被添加到了 `OnceList` 中，证明了这种基于 `OnceLock` 的链表实现在高并发场景下是正确且有效的。

### 运行

```bash
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/cell`
```

## 总结

`OnceCell` 和 `OnceLock` 是 Rust 并发编程中不可或缺的工具。它们的设计理念简洁而强大：只允许一次成功设置，从而根本上杜绝了重复初始化和数据竞争的可能。

- **`OnceCell`** 适用于单线程环境，是实现惰性加载和单例模式的理想选择。尽管它不能在多个线程间共享，但它提供了便捷的 API，如 `get_or_init`，让你可以优雅地初始化和访问值。
- **`OnceLock`** 则将这一概念提升到线程安全层面。它保证了即使在最复杂的并发场景下，静态变量或全局资源也只会被初始化一次。这对于数据库连接、缓存池或任何昂贵的全局资源初始化都至关重要。

通过巧妙地结合 `OnceLock` 和原子操作，我们甚至可以构建出复杂的、线程安全的数据结构，如示例中的 `OnceList`。掌握了这两个工具，你就掌握了在 Rust 中进行安全、高效、并发初始化的核心方法。

## 参考

- <https://github.com/rust-lang/rust>
- <https://course.rs/about-book.html>
- <https://doc.rust-lang.org/reference/introduction.html>
