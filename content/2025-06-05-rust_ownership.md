+++
title = "Rust 所有权：从内存管理到生产力释放"
description = "Rust 所有权：从内存管理到生产力释放"
date = 2025-06-05T00:38:55Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust 所有权：从内存管理到生产力释放

在编程世界中，内存管理一直是开发者面临的难题。C/C++ 的手动管理繁琐易错，Java 的垃圾回收（GC）带来性能损耗，而 Rust 凭借独特的所有权模型，提出了一种革命性的内存管理方案。本文通过一个简单的 Rust 示例，深入探讨所有权机制的核心思想及其对开发效率的提升，带你领略 Rust 如何通过限制引用行为释放生产力。

本文以一个 Rust 程序为例，展示了动态数组在函数调用中的内存管理过程，剖析了传统语言如 C/C++、Java 和 Swift 在堆内存引用上的不足。Rust 通过所有权模型和 Move 语义，限制了随意引用行为，确保单一所有权，自动管理内存释放，避免了内存泄漏和性能损耗。本文将详细解读所有权规则及其背后的设计哲学，帮助开发者理解 Rust 如何在安全性和性能之间找到平衡。

## 变量在函数调用时发生了什么

main() 函数中定义了一个动态数组 data 和一个值 v，然后将其传递给函数 find_pos，在 data 中查找 v 是否存在，存在则返回 v 在 data 中的下标，不存在返回 None

```rust
fn main() {
    // 动态数组因为大小在编译期无法确定，所以放在堆上，并且在栈上有一个包含了长度和容量的胖指针指向堆上的内存
    let data = vec![10, 42, 9, 8];
    let v = 42;
    if let Some(pos) = find_pos(data, v) {
        println!("Found {} at {}", v, pos);
    }
}

fn find_pos(data: Vec<u32>, v: u32) -> Option<usize> {
    for (pos, item) in data.iter().enumerate() {
        if *item == v {
            return Some(pos);
        }
    }
    None
}

```

**动态数组因为大小在编译期无法确定，所以放在堆上，并且在栈上有一个包含了长度和容量的胖指针指向堆上的内存**。

### 运行

```bash
variable_demo on  master [?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base 
➜ cargo run                        
   Compiling variable_demo v0.1.0 (/Users/qiaopengjun/Code/rust/variable_demo)
    Finished dev [unoptimized + debuginfo] target(s) in 0.62s
     Running `target/debug/variable_demo`
Found 42 at 1

variable_demo on  master [?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base 
➜ cargo run --quiet                
Found 42 at 1

```

对于堆内存多次引用的问题，我们先来看大多数语言的方案：

- **C/C++ 要求开发者手工处理**，非常不便。这需要我们在写代码时高度自律，按照前人总结的最佳实践来操作。但人必然会犯错，一个不慎就会导致内存安全问题，要么内存泄露，要么使用已释放内存，导致程序崩溃。
- **Java 等语言使用追踪式 GC**，通过定期扫描堆上数据还有没有人引用，来替开发者管理堆内存，不失为一种解决之道，但 GC 带来的 STW 问题让语言的使用场景受限，性能损耗也不小。
- **ObjC/Swift 使用自动引用计数（ARC）**，在编译时自动添加维护引用计数的代码，减轻开发者维护堆内存的负担。但同样地，它也会有不小的运行时性能损耗。

现存方案都是从管理引用的角度思考的，有各自的弊端。我们回顾刚才梳理的函数调用过程，从源头上看，本质问题是堆上内存会被随意引用，那么换个角度，我们是不是可以限制引用行为本身呢？

## Rust 的解决思路

在 Rust 以前，引用是一种随意的、可以隐式产生的、对权限没有界定的行为，比如 C 里到处乱飞的指针、Java 中随处可见的按引用传参，它们可读可写，权限极大。而 Rust 决定限制开发者随意引用的行为。

其实作为开发者，我们在工作中常常能体会到：**恰到好处的限制，反而会释放无穷的创意和生产力**。最典型的就是各种开发框架，比如 React、Ruby on Rails 等，他们限制了开发者使用语言的行为，却极大地提升了生产力。

好，思路我们已经有了，具体怎么实现来限制数据的引用行为呢？

要回答这个问题，我们需要先来回答：谁真正拥有数据或者说值的生杀大权，这种权利可以共享还是需要独占？

### 所有权和 Move 语义

Rust 给出了如下规则：

- **一个值只能被一个变量所拥有，这个变量被称为所有者**（Each value in Rust has a variable that’s called its *owner*）。
- **一个值同一时刻只能有一个所有者**（There can only be one owner at a time），也就是说不能有两个变量拥有相同的值。所以对应刚才说的变量赋值、参数传递、函数返回等行为，旧的所有者会把值的所有权转移给新的所有者，以便保证单一所有者的约束。
- **当所有者离开作用域，其拥有的值被丢弃**（When the owner goes out of scope, the value will be dropped），内存得到释放。

这三条规则很好理解，核心就是保证单一所有权。其中第二条规则讲的所有权转移是 Move 语义，Rust 从 C++ 那里学习和借鉴了这个概念。

第三条规则中的作用域（scope）是一个新概念，我简单说明一下，它指一个代码块（block），在 Rust 中，一对花括号括起来的代码区就是一个作用域。举个例子，如果一个变量被定义在 if {} 内，那么 if 语句结束，这个变量的作用域就结束了，其值会被丢弃；同样的，函数里定义的变量，在离开函数时会被丢弃。

## 总结

Rust 的所有权机制通过单一所有权、Move 语义和作用域自动清理，彻底改变了内存管理的传统方式。与 C/C++ 的手动管理、Java 的 GC 和 Swift 的 ARC 相比，Rust 在编译期通过严格的引用限制，消除了内存安全问题，同时避免了运行时性能开销。这种“恰到好处的限制”不仅提升了代码的安全性和可靠性，还释放了开发者的创造力，使 Rust 成为高性能系统编程的理想选择。无论是初学者还是资深开发者，理解所有权都将是掌握 Rust 的关键一步。

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://rustwiki.org/zh-CN/rust-by-example/>
- <https://www.rust-lang.org/>
- <https://rustwiki.org/docs/>
- <https://doc.rust-lang.org/nomicon/>
