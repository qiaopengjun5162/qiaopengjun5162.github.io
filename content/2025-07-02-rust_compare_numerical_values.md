+++
title = "Rust 避坑指南：搞定数值比较，别再让 0.1 + 0.2 != 0.3 困扰你"
description = "Rust 避坑指南：搞定数值比较，别再让 0.1 + 0.2 != 0.3 困扰你"
date = 2025-07-02T01:15:32Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust 避坑指南：搞定数值比较，别再让 0.1 + 0.2 != 0.3 困扰你

在任何编程语言中，数值比较都是最基本的操作之一。但在以安全著称的 Rust 中，事情并没有那么简单。你是否曾遇到过因为类型不匹配而无法比较两个数字的编译错误？或者更诡异的，为什么 0.1 + 0.2 它就是不等于 0.3？

本文将带你深入了解 Rust 中数值比较的常见问题和最佳实践，从整数的类型转换到浮点数的精度陷阱，让你彻底搞定数值比较，写出更健壮、更安全的代码。

本文主要探讨了 Rust 语言中数值比较的两个核心方面。首先，针对 Rust 强类型系统下不同整数类型（如 i32 和 u16）无法直接比较的问题，文章介绍了 as 关键字进行强制类型转换和更安全的 try_into() 方法。其次，文章深入剖析了浮点数（f32, f64）比较的常见陷阱，解释了因精度问题导致 0.1 + 0.2 == 0.3 为 false 的原因，并给出了使用 EPSILON 常量进行容差比较的正确实践。最后，还提及了 NaN 等特殊值的处理方式。

## 内容

- 比较与类型转换
- 浮点类型比较

### 可以用这些运算符比较数值

`>  <  ==  !=  >=  <=`

### 无法比较不同类型的值

```rust
fn main() {
  let a: i32 = 10;
  let b: u16 = 100;
  if a < b { // 报错 mismatched types
    println!("Ten is less than one hundred.");
  }
}
```

### 解决办法 1：使用 as 进行类型转换

```rust
fn main() {
  let a: i32 = 10;
  let b: u16 = 100;
  if a < (b as i32) {
    println!("Ten is less than one hundred.");
  }
}
```

注意：从比较小的类型转成比较大的类型通常是比较安全的

```rust
fn main() {
    let a: i32 = 10;
    let b: u16 = 100;

    if a < (b as i32) {
        println!("10 is less than 100.")
    }

    let c : i32 = 1203414;
    println!("{}", c as i8);
}

```

### 运行

```bash
rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ cargo run                              
   Compiling rust_compare_numerical_values v0.1.0 (/Users/qiaopengjun/rust/rust_compare_numerical_values)
    Finished dev [unoptimized + debuginfo] target(s) in 0.22s
     Running `target/debug/rust_compare_numerical_values`
10 is less than 100.
-42

rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ 
```

### 解决办法 2：使用 try_into() 进行类型转换

```rust
use std::convert::TryInto;

fn main() {
    let a: i32 = 10;
    let b: u16 = 100;

    let b_ = b.try_into().unwrap();

    if a < b_ {
        println!("10 is less than 100.")
    }
}

```

运行

```bash
rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ cargo run
   Compiling rust_compare_numerical_values v0.1.0 (/Users/qiaopengjun/rust/rust_compare_numerical_values)
    Finished dev [unoptimized + debuginfo] target(s) in 0.20s
     Running `target/debug/rust_compare_numerical_values`
10 is less than 100.

rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ 
```

### try_into() 方法

- 导入 `std::convert::TryInto Trait`
- 返回 Result 类型

### 浮点类型（例如 f32、f64）有坑

- 浮点类型所代表的数字仅是近似值
  - 浮点类型是基于 2 进制实现的，但我们通常用 10 进制来计算数值
- 浮点类型的某些值不能很好的结合在一起
  - 例如 f32 和 f64 只实现了 `std::cmp::PartialEq`，而其它数值类型还实现了`std::cmp::Eq`

### 针对浮点类型需遵循的指导方针

- 避免测试浮点类型的相等性
- 如果结果在数学上属于未定义的，这时候要小心

```rust
fn main() {
    assert!(0.1 + 0.2 == 0.3);
}

```

### 运行

```bash
rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ cargo run
   Compiling rust_compare_numerical_values v0.1.0 (/Users/qiaopengjun/rust/rust_compare_numerical_values)
    Finished dev [unoptimized + debuginfo] target(s) in 0.15s
     Running `target/debug/rust_compare_numerical_values`
thread 'main' panicked at 'assertion failed: 0.1 + 0.2 == 0.3', src/main.rs:2:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace

rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ 
```

### 例子

```rust
fn main() {
    let abc: (f32, f32, f32) = (0.1, 0.2, 0.3);
    let xyz: (f64, f64, f64) = (0.1, 0.2, 0.3);

    println!("abc (f32)");
    println!(" 0.1 + 0.2: {:x}", (abc.0 + abc.1).to_bits());
    println!("       0.3: {:x}", (abc.2).to_bits());
    println!();

    println!("xyz (f64)");
    println!(" 0.1 + 0.2: {:x}", (xyz.0 + xyz.1).to_bits());
    println!("       0.3: {:x}", (xyz.2).to_bits());
    println!();

    assert!(abc.0 + abc.1 == abc.2);
    assert!(xyz.0 + xyz.1 == xyz.2);
}

```

### 运行

```bash
rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ cargo run
   Compiling rust_compare_numerical_values v0.1.0 (/Users/qiaopengjun/rust/rust_compare_numerical_values)
    Finished dev [unoptimized + debuginfo] target(s) in 0.89s
     Running `target/debug/rust_compare_numerical_values`
abc (f32)
 0.1 + 0.2: 3e99999a
       0.3: 3e99999a

xyz (f64)
 0.1 + 0.2: 3fd3333333333334
       0.3: 3fd3333333333333

thread 'main' panicked at 'assertion failed: xyz.0 + xyz.1 == xyz.2', src/main.rs:16:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace

rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ 
```

### 怎么比较浮点类型？

- 一般来说，测试数学运算是否在其真实数学结果的可接受范围内更安全。这个边界通常被称为ε。
- Rust 提供了一些可容忍的误差值：f32::EPSILON 和 f64::EPSILON

```rust
fn main() {
    let result: f32 = 0.1 + 0.2;
    let desired: f32 = 0.3;

    let abs_diff = (desired - result).abs();

    assert!(abs_diff <= f32::EPSILON)
}

```

### 运行

```bash
rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ cargo run
   Compiling rust_compare_numerical_values v0.1.0 (/Users/qiaopengjun/rust/rust_compare_numerical_values)
    Finished dev [unoptimized + debuginfo] target(s) in 0.14s
     Running `target/debug/rust_compare_numerical_values`

rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ 
```

### 例子

```rust
fn main() {
    let result: f64 = 0.1 + 0.2;
    let desired: f64 = 0.3;

    print!("{}\n", desired - result);

    let abs_diff = (desired - result).abs();

    assert!(abs_diff <= f64::EPSILON)
}

```

### 运行

```bash
rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ cargo run
   Compiling rust_compare_numerical_values v0.1.0 (/Users/qiaopengjun/rust/rust_compare_numerical_values)
    Finished dev [unoptimized + debuginfo] target(s) in 0.13s
     Running `target/debug/rust_compare_numerical_values`
-0.00000000000000005551115123125783

rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ 

```

- Rust 编译器实际上将比较的工作交给了 CPU，浮点运算是使用芯片内的定制硬件实现的

### NAN

- 表示”不是一个数“，例如负数的平方根就是 NAN
- NAN 会影响其它数值：
  - 几乎所有与 NAN 交互的操作都返回 NAN
  - NAN 值永远不相等

```rust
fn main() {
    let x = (-42.0_f32).sqrt();

    assert_eq!(x, x);
}

```

### 运行

```bash
rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ cargo run
   Compiling rust_compare_numerical_values v0.1.0 (/Users/qiaopengjun/rust/rust_compare_numerical_values)
    Finished dev [unoptimized + debuginfo] target(s) in 0.38s
     Running `target/debug/rust_compare_numerical_values`
thread 'main' panicked at 'assertion failed: `(left == right)`
  left: `NaN`,
 right: `NaN`', src/main.rs:4:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace

rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ 
```

- Is_nan() 和 is_finite() 方法

```rust
fn main() {
    let x: f32 = 1.0 / 0.0;

    println!("{}", x);
    
    assert!(x.is_finite());
}

```

### 运行

```bash
rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ cargo run
   Compiling rust_compare_numerical_values v0.1.0 (/Users/qiaopengjun/rust/rust_compare_numerical_values)
    Finished dev [unoptimized + debuginfo] target(s) in 0.08s
     Running `target/debug/rust_compare_numerical_values`
inf
thread 'main' panicked at 'assertion failed: x.is_finite()', src/main.rs:6:5
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace

rust_compare_numerical_values on  master [?] is 📦 0.1.0 via 🦀 1.88.0 via 🅒 base 
➜ 
```

## 总结

今天我们探讨了 Rust 中数值比较的细节，看似简单的操作背后其实蕴含着 Rust 对类型安全和计算精度的严谨思考。总结一下关键要点：

1. **整数比较先转换**: 不同整数类型需显式转换才能比较。优先使用 try_into() 进行安全的、可失败的转换，仅在确保数值不会溢出的情况下才使用 as。

2. **浮点比较用容差: 绝对不要用 == 直接比较浮点数！** 因为精度问题，这很可能导致非预期的结果。正确的做法是计算两个数的差值的绝对值，并判断其是否小于一个极小的公差值（如 f32::EPSILON）。

3. **警惕特殊值** NaN: NaN（Not a Number）不等于任何值，包括它自己。请使用 is_nan() 方法来检查。

掌握这些技巧，可以帮助我们避免在开发中踩坑，写出更加稳健和可靠的 Rust 代码。记住，Rust 的“啰嗦”正是其安全性的体现。

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://course.rs/about-book.html>
- <https://lab.cs.tsinghua.edu.cn/rust/>
- <https://rustwasm.github.io/book/>
