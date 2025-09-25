+++
title = "Rust 智能指针大揭秘：Box、Rc、Arc、Cow 深度剖析与应用实践"
description = "Rust 智能指针大揭秘：Box、Rc、Arc、Cow 深度剖析与应用实践"
date = 2025-09-24T09:59:50Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# **Rust 智能指针大揭秘：Box、Rc、Arc、Cow 深度剖析与应用实践**

在 Rust 的世界里，智能指针扮演着至关重要的角色，它们不仅是内存管理的安全卫士，更是构建复杂、高效程序的强大工具。不同于 C++ 等语言的手动内存管理，Rust 通过所有权系统和智能指针，在编译期保障内存安全，杜绝了悬垂指针和内存泄漏等常见错误。

本文将通过四个经典代码示例，带你深入理解 Rust 中四种核心智能指针：**Box**、**Rc**、**Arc** 和 **Cow**。从解决递归类型大小不确定性的 **Box**，到实现多所有权的 **Rc** 和 **Arc**，再到优化性能的**写时克隆**智能指针 **Cow**，我们将逐一揭示它们的设计哲学、工作原理以及在实际编程中的应用场景，助你写出更安全、更高效、更具表现力的 Rust 代码。

本文深入探讨了 Rust 中四种关键智能指针：**Box**、**Rc**、**Arc** 和 **Cow**。通过 **Box** 解决编译时递归类型大小不确定的问题，展示了链表数据结构的实现。通过 **Rc** 和 **Arc**，揭示了 Rust 如何安全地实现单线程和多线程下的多所有权共享。最后，通过 **Cow** 示例，详细解析了其“写时克隆”机制，说明了它如何在保证数据安全的同时，显著提升只读场景下的程序性能。文章通过具体代码案例，清晰阐述了每种智能指针的用途与工作原理，旨在帮助读者掌握 Rust 内存管理的精髓。

## 实操

### 示例一

```rust
// box1.rs
//
// At compile time, Rust needs to know how much space a type takes up. This
// becomes problematic for recursive types, where a value can have as part of
// itself another value of the same type. To get around the issue, we can use a
// `Box` - a smart pointer used to store data on the heap, which also allows us
// to wrap a recursive type.
//
// The recursive type we're implementing in this exercise is the `cons list` - a
// data structure frequently found in functional programming languages. Each
// item in a cons list contains two elements: the value of the current item and
// the next item. The last item is a value called `Nil`.

#[derive(PartialEq, Debug)]
pub enum List {
    Cons(i32, Box<List>),
    Nil,
}

fn main() {
    println!("This is an empty cons list: {:?}", create_empty_list());
    println!(
        "This is a non-empty cons list: {:?}",
        create_non_empty_list()
    );
}

pub fn create_empty_list() -> List {
    List::Nil
}

pub fn create_non_empty_list() -> List {
    List::Cons(1, Box::new(List::Nil))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_empty_list() {
        assert_eq!(List::Nil, create_empty_list())
    }

    #[test]
    fn test_create_non_empty_list() {
        assert_ne!(create_empty_list(), create_non_empty_list())
    }
}

```

这段 Rust 代码展示了如何用 `Box` 智能指针来创建一个**递归数据结构**，即 **cons list（链表）**。由于递归类型（`List`）的大小在编译时是未知的（它可能包含无限个 `Cons` 变体），直接在栈上存储会引发编译错误。`Box` 通过将数据存储在堆上，并只在栈上保留一个固定大小的指针来巧妙地解决了这个问题。代码中的 `List::Cons(i32, Box<List>)` 变体就通过 `Box<List>` 来引用链表中的下一个元素，从而实现了递归定义。`create_empty_list` 函数返回一个 `List::Nil` 作为链表的末尾，而 `create_non_empty_list` 则创建了一个包含一个元素的链表，其末尾指向 `List::Nil`。

### 示例二

```rust
// rc1.rs
//
// In this exercise, we want to express the concept of multiple owners via the
// Rc<T> type. This is a model of our solar system - there is a Sun type and
// multiple Planets. The Planets take ownership of the sun, indicating that they
// revolve around the sun.

use std::rc::Rc;

#[derive(Debug)]
struct Sun {}

#[derive(Debug)]
enum Planet {
    Mercury(Rc<Sun>),
    Venus(Rc<Sun>),
    Earth(Rc<Sun>),
    Mars(Rc<Sun>),
    Jupiter(Rc<Sun>),
    Saturn(Rc<Sun>),
    Uranus(Rc<Sun>),
    Neptune(Rc<Sun>),
}

impl Planet {
    fn details(&self) {
        println!("Hi from {:?}!", self)
    }
}

fn main() {
    let sun = Rc::new(Sun {});
    println!("reference count = {}", Rc::strong_count(&sun)); // 1 reference

    let mercury = Planet::Mercury(Rc::clone(&sun));
    println!("reference count = {}", Rc::strong_count(&sun)); // 2 references
    mercury.details();

    let venus = Planet::Venus(Rc::clone(&sun));
    println!("reference count = {}", Rc::strong_count(&sun)); // 3 references
    venus.details();

    let earth = Planet::Earth(Rc::clone(&sun));
    println!("reference count = {}", Rc::strong_count(&sun)); // 4 references
    earth.details();

    let mars = Planet::Mars(Rc::clone(&sun));
    println!("reference count = {}", Rc::strong_count(&sun)); // 5 references
    mars.details();

    let jupiter = Planet::Jupiter(Rc::clone(&sun));
    println!("reference count = {}", Rc::strong_count(&sun)); // 6 references
    jupiter.details();

    let saturn = Planet::Saturn(Rc::clone(&sun));
    println!("reference count = {}", Rc::strong_count(&sun)); // 7 references
    saturn.details();

    let uranus = Planet::Uranus(Rc::clone(&sun));
    println!("reference count = {}", Rc::strong_count(&sun)); // 8 references
    uranus.details();

    let neptune = Planet::Neptune(Rc::clone(&sun));
    println!("reference count = {}", Rc::strong_count(&sun)); // 9 references
    neptune.details();

    assert_eq!(Rc::strong_count(&sun), 9);

    drop(neptune);
    println!("reference count = {}", Rc::strong_count(&sun)); // 8 references

    drop(uranus);
    println!("reference count = {}", Rc::strong_count(&sun)); // 7 references

    drop(saturn);
    println!("reference count = {}", Rc::strong_count(&sun)); // 6 references

    drop(jupiter);
    println!("reference count = {}", Rc::strong_count(&sun)); // 5 references

    drop(mars);
    println!("reference count = {}", Rc::strong_count(&sun)); // 4 references

    drop(earth); // 3 references
    println!("reference count = {}", Rc::strong_count(&sun)); // 3 references

    drop(venus); // 2 references
    println!("reference count = {}", Rc::strong_count(&sun)); // 2 references

    drop(mercury); // 1 reference
    println!("reference count = {}", Rc::strong_count(&sun)); // 1 reference

    assert_eq!(Rc::strong_count(&sun), 1);
}

```

这段 Rust 代码使用 `Rc<T>` 智能指针来模拟太阳系中“多所有权”的关系。`Rc<T>`，全称是**引用计数（Reference Counted）**，允许一个数据拥有多个所有者。代码创建了一个 `Sun` 实例，并使用 `Rc::new` 将其包裹起来，使其可以被共享。接着，通过 **`Rc::clone`** 方法为每一颗行星 (`Planet`) 创建 `Sun` 的共享所有权。`Rc::clone` 仅仅是增加引用计数，而不是深度克隆数据，这使得内存开销非常小。每当一个行星被创建，太阳的引用计数（通过 **`Rc::strong_count`** 查看）就会增加，表示又多了一个“所有者”。当行星变量被销毁（例如通过 **`drop`** 或超出作用域），引用计数就会自动减少。只有当引用计数归零时，`Rc<T>` 才会释放其包裹的数据，完美地展示了多所有权以及安全的内存管理。

### 示例三

```rust
// arc1.rs
//
// In this exercise, we are given a Vec of u32 called "numbers" with values
// ranging from 0 to 99 -- [ 0, 1, 2, ..., 98, 99 ] We would like to use this
// set of numbers within 8 different threads simultaneously. Each thread is
// going to get the sum of every eighth value, with an offset.
//
// The first thread (offset 0), will sum 0, 8, 16, ...
// The second thread (offset 1), will sum 1, 9, 17, ...
// The third thread (offset 2), will sum 2, 10, 18, ...
// ...
// The eighth thread (offset 7), will sum 7, 15, 23, ...

#![forbid(unused_imports)]
use std::sync::Arc;
use std::thread;

fn main() {
    let numbers: Vec<_> = (0..100u32).collect();
    let shared_numbers = Arc::new(numbers);
    let mut joinhandles = Vec::new();

    for offset in 0..8 {
        let child_numbers = Arc::clone(&shared_numbers);
        joinhandles.push(thread::spawn(move || {
            let sum: u32 = child_numbers.iter().filter(|&&n| n % 8 == offset).sum();
            println!("Sum of offset {} is {}", offset, sum);
        }));
    }
    for handle in joinhandles.into_iter() {
        handle.join().unwrap();
    }
}

```

这段 Rust 代码利用 **`Arc<T>`** 智能指针实现了安全的**多线程数据共享**。`Arc` 代表 **Atomic Reference Counted**（原子引用计数），它类似于 `Rc`，但专为多线程环境设计，确保即使在多个线程同时访问时，引用计数的增减也是安全的。程序首先创建了一个包含 0 到 99 的数字向量，并使用 `Arc::new` 将其包裹，以便在线程间共享。在循环中，它生成了八个独立的线程，每个线程通过 **`Arc::clone`** 获取一个 `Arc` 智能指针的克隆。`Arc::clone` 同样只增加引用计数，不会复制底层数据，这使得多个线程能高效地**共享同一份只读数据**。每个线程根据自己的 `offset` 过滤并求和，最后 `handle.join()` 确保主线程会等待所有子线程执行完毕后再退出，完美展示了 `Arc` 在并发编程中提供安全、高效共享数据的功能。

### 示例四

```rust
// cow1.rs
//
// This exercise explores the Cow, or Clone-On-Write type. Cow is a
// clone-on-write smart pointer. It can enclose and provide immutable access to
// borrowed data, and clone the data lazily when mutation or ownership is
// required. The type is designed to work with general borrowed data via the
// Borrow trait.

use std::borrow::Cow;

fn abs_all<'a, 'b>(input: &'a mut Cow<'b, [i32]>) -> &'a mut Cow<'b, [i32]> {
    for i in 0..input.len() {
        let v = input[i];
        if v < 0 {
            // Clones into a vector if not already owned.
            input.to_mut()[i] = -v;
        }
    }
    input
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn reference_mutation() -> Result<(), &'static str> {
        // Clone occurs because `input` needs to be mutated.
        let slice = [-1, 0, 1];
        let mut input = Cow::from(&slice[..]);
        match abs_all(&mut input) {
            Cow::Owned(_) => Ok(()),
            _ => Err("Expected owned value"),
        }
    }

    #[test]
    fn reference_no_mutation() -> Result<(), &'static str> {
        // No clone occurs because `input` doesn't need to be mutated.
        let slice = [0, 1, 2];
        let mut input = Cow::from(&slice[..]);
        match abs_all(&mut input) {
            Cow::Borrowed(_) => Ok(()),
            _ => Err("Expected borrowed value"),
        }
    }

    #[test]
    fn owned_no_mutation() -> Result<(), &'static str> {
        // We can also pass `slice` without `&` so Cow owns it directly. In this
        // case no mutation occurs and thus also no clone, but the result is
        // still owned because it was never borrowed or mutated.
        let slice = vec![0, 1, 2];
        let mut input = Cow::from(slice);
        match abs_all(&mut input) {
            Cow::Owned(_) => Ok(()),
            _ => Err("Expected owned value"),
        }
    }

    #[test]
    fn owned_mutation() -> Result<(), &'static str> {
        // Of course this is also the case if a mutation does occur. In this
        // case the call to `to_mut()` returns a reference to the same data as
        // before.
        let slice = vec![-1, 0, 1];
        let mut input = Cow::from(slice);
        match abs_all(&mut input) {
            Cow::Owned(_) => Ok(()),
            _ => Err("Expected owned value"),
        }
    }
}

```

`Cow` 是 Rust 中的一个**智能指针**，全称为 **Clone-on-Write**。它在处理数据时非常灵活，可以根据需要自动在**借用**和**拥有**两种状态间切换，从而优化性能。

#### **Cow 类型解析**

`Cow` 的核心思想是**“写时克隆”**。

- 当你只需要**读取**数据时，`Cow` 只会借用数据，避免不必要的内存分配和克隆。
- 当你需要**修改**数据时，如果 `Cow` 借用着数据，它会先自动克隆一份，然后对克隆出的新数据进行修改。这样既保证了修改的安全性（不影响原始数据），又实现了性能优化（只有在需要修改时才进行克隆）。如果它已经拥有了数据（即数据是它自己的），则直接在原地修改，不会产生额外的克隆。

这段代码的核心在于 **`Cow`** 智能指针，它是 **Clone-on-Write（写时克隆）** 的缩写，旨在优化性能。

#### `Cow` 智能指针解释

`Cow` 能够根据需要，自动在**借用（Borrowed）**和**拥有（Owned）**两种状态之间切换，从而避免不必要的内存分配。当你只需要读取数据时，`Cow` 会高效地借用数据，不进行克隆。但是，当你需要修改数据时，`Cow` 会检查当前状态：

- 如果 `Cow` **借用**着数据，它会立即自动克隆一份新的、可变的数据，然后对新数据进行修改。这种“写时克隆”的行为确保了原始数据的安全。
- 如果 `Cow` **已经拥有**了数据，它将直接在原地进行修改，不会产生任何克隆开销。

这段代码中的 `abs_all` 函数就是触发这个行为的关键。它通过 `input.to_mut()` 来获取一个可变引用，`to_mut()` 方法正是 `Cow` 判断是否需要克隆的地方。

#### 四个测试用例详解

1. **`reference_mutation`：**
   - **初始状态：** `Cow` 从一个切片 (`&[i32]`) 创建，处于 **`Cow::Borrowed`** 状态。
   - **行为：** `abs_all` 函数找到负数 `-1` 并尝试修改。由于 `Cow` 处于借用状态，`to_mut()` 会触发克隆，将数据复制到堆上。
   - **最终状态：** `Cow` 变为 **`Cow::Owned`**。
2. **`reference_no_mutation`：**
   - **初始状态：** `Cow` 从一个切片创建，处于 **`Cow::Borrowed`** 状态。
   - **行为：** `abs_all` 函数中没有找到负数，因此 `to_mut()` **没有被调用**。
   - **最终状态：** `Cow` 保持其初始的 **`Cow::Borrowed`** 状态。
3. **`owned_no_mutation`：**
   - **初始状态：** `Cow` 直接从一个 `Vec` 创建，从一开始就处于 **`Cow::Owned`** 状态。
   - **行为：** `abs_all` 没有找到负数，`to_mut()` 没有被调用。
   - **最终状态：** `Cow` 依然是 **`Cow::Owned`**，因为其所有权从未改变。
4. **`owned_mutation`：**
   - **初始状态：** `Cow` 直接从一个 `Vec` 创建，处于 **`Cow::Owned`** 状态。
   - **行为：** `abs_all` 找到负数 `-1` 并调用 `to_mut()`。由于 `Cow` 已经拥有数据，`to_mut()` 不会进行克隆，而是直接返回一个可变引用。
   - **最终状态：** `Cow` 依然是 **`Cow::Owned`**，数据被原地修改。

这段代码完美地展示了 `Cow` 如何通过惰性克隆，在保证数据安全和代码灵活性的同时，实现了高效的内存管理。

## 总结

通过对这四个智能指针的实战分析，我们看到 Rust 如何在语言层面提供强大的工具来解决复杂的内存管理问题。

- **Box** 帮助我们处理**大小不确定**的递归数据结构，将数据从栈上转移到堆上，从而让代码得以编译和运行。
- **Rc** 和 **Arc** 完美解决了**多所有权**的场景，前者适用于单线程，后者则以原子操作确保了在多线程环境下的数据安全，使得共享数据变得简单而高效。
- **Cow** 则以其独特的**写时克隆**机制，在需要可变性时才付出克隆的代价，这是一种优雅的性能优化方式，特别适合处理那些大多数时候只读、偶尔需要修改的数据。

掌握这些智能指针，不仅意味着你掌握了 Rust 内存管理的核心，更意味着你获得了编写高性能、安全、健壮程序的利器。在面对不同的编程挑战时，选择合适的智能指针将让你的代码更加优雅和高效。

## 参考

- **Rust 程序设计语言：** <https://kaisery.github.io/trpl-zh-cn/>

- **通过例子学 Rust：** <https://rustwiki.org/zh-CN/rust-by-example/>

- **Rust 语言圣经：** <https://course.rs/about-book.html>

- **Rust 秘典：** <https://nomicon.purewhite.io/intro.html>

- **Rust 算法教程：** <https://algo.course.rs/about-book.html>

- **Rust 参考手册：** <https://rustwiki.org/zh-CN/reference/introduction.html>
