+++
title = "深入 Rust 核心：彻底搞懂指针、引用与智能指针"
description = "本文深入探讨了 Rust 中的指针概念及其生态。文章首先从基础出发，阐释了指针作为内存地址引用的本质，并详细区分了汇编、高级语言及 Rust 对指针的不同层级抽象——内存地址、指针和引用。随后，文章通过代码实例展示了 Rust 安全引用与 unsafe 原始指针（Raw Pointer）的用法与区别，并解释了使用原始指针的场景。最后，本文以表格形式系统地梳理了 Box<T>, Rc<T>, Arc<T> 等十余种常用智能指针的特性、优缺点及适用场景，为读者在实际开发中选择合适的指针类型提供了清晰的指引。"
date = 2025-07-15T01:08:36Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 深入 Rust 核心：彻底搞懂指针、引用与智能指针

指针，是通往底层世界的大门，也是许多程序员既爱又恨的概念。在 C/C++ 中，它赋予了我们直接操控内存的无上权力，但也带来了悬垂指针、内存泄漏等无尽的烦恼。那么，以“安全”著称的 Rust 是如何处理指针的呢？它又是如何做到既能媲美 C 的性能，又能保证内存安全的呢？

本文将带你踏上一场从内存地址到高级抽象的探索之旅。我们将从最基本的“什么是指针”讲起，厘清 Rust 中引用 (&)、原始指针 (*const T) 和智能指针之间的区别与联系。你不仅会看到清晰的代码示例，还将理解 unsafe Rust 为何存在，以及何时应该使用它。最后，我们将为你全面梳理 Rust 强大的智能指针生态，助你写出既安全又高效的 Rust 代码。

## 指针

### 什么是指针

- 指针是计算机引用无法立即直接访问的数据的一种方式（类比 书的目录）
- 数据在物理内存（RAM）中是分散的存储着
- 地址空间是检索系统
- 指针就被编码为内存地址，使用 usize 类型的整数表示。
  - 一个地址就会指向地址空间中的某个地方
- 地址空间的范围是 OS 和 CPU 提供的外观界面
  - 程序只知道有序的字节序列，不会考虑系统中实际 RAM 的数量

### 名词解释

- 内存地址（地址），就是指代内存中单个字节的一个数
  - 内存地址是汇编语言提供的抽象
- 指针（有时扩展称为原始指针），就是指向某种类型的一个内存地址
  - 指针是高级语言提供的抽象
- 引用，就是指针。如果是动态大小的类型，就是指针和具有额外保证的一个整数
  - 引用是 Rust 提供的抽象

### Rust 的引用

- 引用始终引用的是有效数据
- 引用与 usize 的倍数对齐
- 引用可以为动态大小的类型提供上述保障

### Rust 的引用 和 指针

```rust
static B: [u8; 10] = [99, 97, 114, 114, 121, 116, 111, 119, 101, 108];
static C: [u8; 11] = [116, 104, 97, 110, 107, 115, 102, 105, 115, 104, 0];

fn main() {
    let a = 42;
    let b = &B;
    let c = &C;

    println!("a: {}, b: {:p}, c: {:p}", a, b, c);
}

```

### 运行

```bash
point_demo on  master [?] is 📦 0.1.0 via 🦀 1.67.1 via 🅒 base 
➜ cargo run           
   Compiling point_demo v0.1.0 (/Users/qiaopengjun/rust/point_demo)
    Finished dev [unoptimized + debuginfo] target(s) in 0.44s
     Running `target/debug/point_demo`
a: 42, b: 0x1023dc660, c: 0x1023dc66a

point_demo on  master [?] is 📦 0.1.0 via 🦀 1.67.1 via 🅒 base 
➜ 

```

### 一个更加逼真的例子

使用更复杂的类型展示指针内部的区别

```go
use std::mem::size_of;

static B: [u8; 10] = [99, 97, 114, 114, 121, 116, 111, 119, 101, 108];
static C: [u8; 11] = [116, 104, 97, 110, 107, 115, 102, 105, 115, 104, 0];

fn main() {
    // let a = 42;
    // let b = &B;
    // let c = &C;

    // println!("a: {}, b: {:p}, c: {:p}", a, b, c);

    let a: usize = 42;
    let b: Box<[u8]> = Box::new(B);
    let c: &[u8; 11] = &C;

    println!("a (unsigned 整数):");
    println!("  地址: {:p}", &a);
    println!("  大小:    {:?} bytes", size_of::<usize>());
    println!("  值:  {:?}\n", a);

    println!("b (B 装在 Box 里):");
    println!("  地址:  {:p}", &b);
    println!("  大小:    {:?} bytes", size_of::<Box<[u8]>>());
    println!("  指向:  {:p}\n", b);

    println!("c (C 的引用):");
    println!("  地址:  {:p}", &c);
    println!("  大小:  {:?} bytes", size_of::<&[u8; 11]>());
    println!("  指向:  {:p}\n", c);

    println!("B (10 bytes 的数组):");
    println!("  地址:  {:p}", &B);
    println!("  大小:  {:?} bytes", size_of::<[u8; 10]>());
    println!("  值:  {:?}\n", B);

    println!("C (11 bytes 的数字):");
    println!("  地址:  {:p}", &C);
    println!("  大小:  {:?} bytes", size_of::<[u8; 11]>());
    println!("  值:  {:?}\n", C);
}

```

### 运行

```bash
point_demo on  master [?] is 📦 0.1.0 via 🦀 1.67.1 via 🅒 base 
➜ cargo run
   Compiling point_demo v0.1.0 (/Users/qiaopengjun/rust/point_demo)
    Finished dev [unoptimized + debuginfo] target(s) in 0.19s
     Running `target/debug/point_demo`
a (unsigned 整数):
  地址: 0x16dda9a08
  大小:    8 bytes
  值:  42

b (B 装在 Box 里):
  地址:  0x16dda9a10
  大小:    16 bytes
  指向:  0x12b606ba0

c (C 的引用):
  地址:  0x16dda9a30
  大小:  8 bytes
  指向:  0x10208d7ba

B (10 bytes 的数组):
  地址:  0x10208d7b0
  大小:  10 bytes
  值:  [99, 97, 114, 114, 121, 116, 111, 119, 101, 108]

C (11 bytes 的数字):
  地址:  0x10208d7ba
  大小:  11 bytes
  值:  [116, 104, 97, 110, 107, 115, 102, 105, 115, 104, 0]


point_demo on  master [?] is 📦 0.1.0 via 🦀 1.67.1 via 🅒 base 
➜ 
```

### 对 B 和 C 中文本进行解码的例子

它创建了一个与前图更加相似的内存地址布局

```go
use std::borrow::Cow;
use std::ffi::CStr;
use std::os::raw::c_char;

static B: [u8; 10] = [99, 97, 114, 114, 121, 116, 111, 119, 101, 108];
static C: [u8; 11] = [116, 104, 97, 110, 107, 115, 102, 105, 115, 104, 0];

fn main() {
  let a = 42;
  let b: String;
  let c: Cow<str>;
  
  unsafe {
    let b_ptr = &B as * const u8 as *mut u8;
    b = String::from_raw_parts(b_ptr, 10, 10);
    
    let c_ptr = &C as *const u8 as *const c_char;
    c = CStr::from_ptr(c_ptr).to_string_lossy();
  }
  println!("a: {}, b: {}, c: {}", a, b, c);
}
```

### Raw Pointers（原始指针）

- Raw Pointer （原始指针）是没有 Rust 标准保障的内存地址。
  - 这些本质上是 unsafe 的
- 语法：
  - 不可变 Raw Pointer：*const T
  - 可变的 Raw Pointer：*mut T
  - 注意：*const T，这三个标记放在一起表示的是一个类型
  - 例子：*const String
- *const T 与*mut T 之间的差异很小，相互可以自由转换
- Rust 的引用（&mut T 和 &T）会编译为原始指针
  - 这意味着无需冒险进入 unsafe 块，就可以获得原始指针的性能
- 例子：把引用转为原始指针

```rust
fn main() {
  let a: i64 = 42;
  let a_ptr = &a as *const i64;
  
  println!("a: {} ({:p})", a, a_ptr);
}
```

- 解引用（dereference）：通过指针从 RAM 内存提取数据的过程叫做对指针进行解引用（dereferencing a pointer）
- 例子：把引用转为原始指针

```rust
fn main() {
  let a: i64 = 42;
  let a_ptr = &a as *const i64;
  let a_addr: usize = unsafe {std::mem::transmute(a_ptr)};
  
  println!("a: {} ({:p}...0x{:x})", a, a_ptr, a_addr + 7);
}
```

### 关于 Raw Pointer 的提醒

- 在底层，引用（&T 和 &mutT）被实现为原始指针。但引用带有额外的保障，应该始终作为首选使用
- 访问 Raw Pointer 的值总是 unsafe 的
- Raw Pointer 不拥有值的所有权
  - 在访问时编译器不会检查数据的合法性
- 允许多个 Raw Pointer 指向同一数据
  - Rust 无法保证共享数据的合法性

### 使用 Raw Pointer 的情况

- 不可避免
  - 某些 OS 或 第三方库需要使用，例如与C交互
- 共享对某些内容的访问至关重要，运行时性能要求高

### Rust 指针生态

- Raw Pointer 是 unsafe 的
- Smart Pointer（智能指针）倾向于包装原始指针，附加更多的能力
  - 不仅仅是对内存地址解引用

### Rust 智能指针

| 名称         | 简介                                                         | 强项                                                | 弱项                                 |
| ------------ | ------------------------------------------------------------ | --------------------------------------------------- | ------------------------------------ |
| Raw Pointer  | *mut T 和*const T，自由基，闪电般块，极其 Unsafe             | 速度、与外界交互                                    | Unsafe                               |
| `Box<T>`     | 可把任何东西都放在Box里。可接受几乎任何类型的长期存储。新的安全编程时代的主力军。 | 将值集中存储在 Heap                                 | 大小增加                             |
| `Rc<T>`      | 是Rust的能干而吝啬的簿记员。它知道谁借了什么，何时借了什么   | 对值的共享访问                                      | 大小增加；运行时成本；线程不安全     |
| `Arc<T>`     | 是Rust的大使。它可以跨线程共享值，保证这些值不会相互干扰     | 对值的共享访问；线程安全                            | 大小增加；运行时成本                 |
| `Cell<T>`    | 变态专家，具有改变不可变值的能力                             | 内部可变性                                          | 大小增加；性能                       |
| `RefCell<T>` | 对不可变引用执行改变，但有代价                               | 内部可变性；可与仅接受不可变引用的Rc、Arc嵌套使用   | 大小增加；运行时成本；缺乏编译时保障 |
| `Cow<T>`     | 封闭并提供对借用数据的不可变访问，并在需要修改或所有权时延迟克隆数据 | 当只是只读访问时避免写入                            | 大小可能会增大                       |
| String       | 可处理可变长度的文本，展示了如何构建安全的抽象               | 动态按需增长；在运行时保证正确编码                  | 过度分配内存大小                     |
| `Vec<T>`     | 程序最常用的存储系统；它在创建和销毁值时保持数据有序         | 动态按需增长                                        | 过度分配内存大小                     |
| `RawVec<T>`  | 是`Vec<T>`和其它动态大小类型的基石；知道如何按需给你的数据提供一个家 | 动态按需增长；与内存分配器一起配合寻找空间          | 不直接适用于您的代码                 |
| `Unique<T>`  | 作为值的唯一所有者，可保证拥有完全控制权                     | 需要独占值的类型（如 String）的基础                 | 不适合直接用于应用程序代码           |
| `Shared<T>`  | 分享所有权很难，但他使生活更轻松                             | 共享所有权；可以将内存与T的宽度对齐，即使是空的时候 | 不适合直接用于应用程序代码           |

## 总结

经过本文的系统性梳理，我们深入了解了 Rust 从底层到高层的指针体系。我们从指针的基本概念——内存地址的抽象开始，理解了 Rust 如何通过“引用”这一概念，在编译期就为我们提供了强大的安全保障。

**核心要点回顾：**

1. 分层抽象，安全优先：Rust 的指针世界层次分明。最顶层、最安全的是“引用 (&T)”，它带有生命周期和借用检查，是日常开发的首选。往下是“原始指针 (*const T)”，它绕过了编译器的安全检查，提供了与 C 语言类似的灵活性，但必须在 unsafe 块中小心使用。
2. 拥抱安全，慎用 unsafe：Rust 的核心哲学是“默认安全”。应始终优先使用安全的引用。只有在与 C 库交互或进行极致性能优化等不得不操作裸内存的场景下，才考虑动用原始指针这一“大杀器”。
3. 智能指针是关键：Rust 通过丰富的智能指针生态系统，将原始指针的强大能力封装在安全的 API 之后。无论是独占所有权的 Box<T>，支持共享所有权的 Rc<T>/Arc<T>，还是提供内部可变性的 Cell<T>/RefCell<T>，它们都在特定场景下提供了兼具安全与功能的内存管理方案。

总而言之，Rust 并非消除了指针，而是驯服了它。通过掌握引用、原始指针和智能指针这“三驾马车”，你就能在享受 Rust 带来的内存安全的同时，写出不输于 C/C++ 的高性能底层代码。希望这篇文章能成为你精通 Rust 道路上的一块坚实基石。

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://course.rs/about-book.html>
- <https://doc.rust-lang.org/book/>
- <https://rust-lang-nursery.github.io/rust-cookbook/intro.html>
