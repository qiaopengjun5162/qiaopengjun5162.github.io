+++
title = "掌握 Rust 核心：生命周期与借用检查全解析"
description = "本文深入探讨 Rust 的核心概念——生命周期。我们将从生命周期的基本定义和借用检查器的工作原理讲起，逐步深入到泛型生命周期和生命周期型变（Variance）等高级主题，旨在帮助开发者彻底理解 Rust 如何在编译期保证引用的有效性，从而掌握其内存安全的基石，写出更安全、高效的代码。"
date = 2025-07-25T00:38:33Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 掌握 Rust 核心：生命周期与借用检查全解析

“生命周期”和“借用检查器”无疑是 Rust 学习路上的两大核心挑战，它们是 Rust 实现内存安全、告别垃圾回收的基石，却也常常让初学者望而生畏，面对一堆编译错误不知所措。

别担心，这篇文章就是为你准备的。我们将系统性地剖析生命周期的本质，理解借用检查器“保守”的工作原则。从最基础的概念出发，逐步深入到泛型生命周期、生命周期型变（Variance）等高级主题。无论你是初学者还是希望巩固知识的开发者，本文都将帮助你建立一个清晰、完整的知识框架，让你自信地驾驭 Rust 的所有权系统。

本文深入探讨 Rust 的核心概念——生命周期。我们将从生命周期的基本定义和借用检查器的工作原理讲起，逐步深入到泛型生命周期和生命周期型变（Variance）等高级主题，旨在帮助开发者彻底理解 Rust 如何在编译期保证引用的有效性，从而掌握其内存安全的基石，写出更安全、高效的代码。

## 生命周期

### 生命周期（Lifetime）

- 官方教程中提到：
  - Rust 里每个引用都有生命周期，它就是引用保持合法作用域（scope），大多数时候是隐式和推断出来的
- 对某个变量取得引用时生命周期开始，当变量移动或离开作用域时生命周期结束
- 生命周期：对于某个引用来说，它必须保持合法的一个代码区域的名称
  - 生命周期通常与作用域重合，但也不一定

### 借用检查器（Borrow Checker）

- 每当具有某个生命周期 ‘a 的引用被使用，借用检查器都会检查 ’a 是否还存活
  - 追踪路径直到 ‘a 开始（获得引用）的地方
  - 从这开始，检查沿着路径是否存在冲突
  - 保证引用指向一个可安全访问的值

```rust
use rand::prelude::*;

fn main() {
  let mut x = Box::new(42);
  let r = &x; // (1) 'a
  if random::<f32>() > 0.5 {
    *x = 84; // (2)
  } else {
    println!("{}", r); // (3) 'a
  }
}
// (4)
```

- 生命周期很复杂：
- 生命周期有“漏洞”

```rust
fn main() {
  let mut x = Box::new(42);

  let mut x = &x; // (1) a'
  for i in 0..100 {
    println!("{}", z); // (2) a'
    x = Box::new(i); // (3)
    z = &x; // (4) a'
  }
  println!("{}", z); // a'
}
```

- 借用检查器是保守的：
  - 如果不确定某个借用是否合法，借用检查器就会拒绝该借用
- 借用检查器有时需要帮助来理解某个借用 为什么是合法的：
  - 这也是 Unsafe Rust 存在的部分原因

### 泛型生命周期

- 有时需要在自己的类型里存储引用：
  - 这些引用都有生命周期，以便借用检查器检查合法性
  - 例如：在该类型方法中返回引用，且存活比 self 的长
- Rust 允许你基于一个或多个生命周期将类型的定义泛型化

### 泛型生命周期 - 两点提醒

- 如果类型实现了 Drop，那么丢弃类型时，就被记作是使用了类型所泛型的生命周期或类型
  - 类型实例要被 drop 了，在 drop 之前，借用检查器会检查看是否仍然合法去使用你类型的泛型生命周期，因为你在 drop 里的代码可能会用到这些引用
- 如果类型没有实现 Drop，那么丢弃类型的时候不会当作使用，可以忽略类型内的引用
- 类型可泛型多个生命周期，但通常会不必要的让类型签名更复杂：
  - 只有类型包含多个引用时，你才应该使用多个生命周期参数
  - 并且它方法返回的引用只应绑定到其中一个引用的生命周期

```rust
strurc StrSplit<'s, 'p> {
  delimiter: &'p str,
  document: &'s str,
}

impl<'s, 'p> Iterator for StrSplit<'s, 'p> {
  type Item = &'s str;

  fn next(&mut self) -> Option<Self::Item> {
    todo!()
  }
}

fn str_before(s: &str, c: char) -> Option<&str> {
  StrSplit {
    document: s,
    delimiter: &c.to_string(),
  }
  .next()
}
```

### 生命周期 Variance

- Variance：
  - 哪些类型是其它类型的“子类”
  - 什么时候“子类”可以替换“超类”（反之亦然）
- 通常来说：
  - 如果 A 是 B 的子类，那么 A 至少和 B 一样有用
  - Rust 的例子：
    - 如果函数接收 &'a str 的参数，那么就可以传入 &'statci str 的参数
    - 'static 是 'a 的 “子类”，因为 'static 至少跟任何 'a 存活的一样长

### 生命周期 三种 Variance

- 所有的类型都有 Variance：
  - 定义了哪些类似类型可以用在该类型的位置上
- 三种 Variance：
  - covariant：某类型只能用“子类型”替代
    - 例如：&'static T 可替代 &'a T
  - invariant：必须提供指定的类型
    - 例如：&mut T，对于 T 来说就是 invariant 的
  - contravariant：函数对参数的要求越低，参数可发挥的作用越大

```rust
// let x1: &'static str;  // more useful, lives longer
// let x2: &'a str;  // less useful, lives shorter

// fn take_func1(&'static str1)  // stricter, so less useful
// fn take_func2(&'a str2)  // less strict, more useful
```

### 多生命周期与 Variance

```rust
struct MuStr<'a, 'b> {
  s: &'a mut &'b str,
}

fn main() {
  let mut r = "hello";  // &'static str => &'a str
  *MutStr {s: &mut r}.s = "world";
  println!("{}", r);
}
```

## 总结

本文详细梳理了 Rust 中至关重要的生命周期（Lifetime）概念。我们从以下几个方面进行了探讨：

1. 基本概念：明确了生命周期是引用保持合法的“代码区域”，并了解了借用检查器（Borrow Checker）如何通过追踪生命周期来防止悬垂引用，确保内存安全。

2. 泛型生命周期：学习了如何在结构体和函数签名中使用泛型生命周期（如 struct StrSplit<'s, 'p>)，这使得自定义类型能够安全地持有和返回引用。

3. 生命周期型变 (Variance)：介绍了协变（Covariant）、不变（Invariant）和逆变（Contravariant）这三种型变规则，解释了为什么 &'static str 可以作为 &'a str 使用，加深了对生命周期替换规则的理解。

总而言之，生命周期是 Rust 独特的、在编译时强制执行的内存安全机制。虽然初看时语法和概念较为复杂，但一旦掌握，它将成为你编写高性能、高可靠性程序的强大工具。彻底理解生命周期，是每一位 Rustacean 从入门到精通的必经之路。

## 参考

- https://www.rust-lang.org/
- https://crates.io/
- https://course.rs/about-book.html
- https://lab.cs.tsinghua.edu.cn/rust/
