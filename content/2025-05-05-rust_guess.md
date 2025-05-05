+++
title = "用 Rust 写个猜数游戏，编程小白也能上手"
description = "用 Rust 写个猜数游戏，编程小白也能上手"
date = 2025-05-05T02:03:43Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 用 Rust 写个猜数游戏，编程小白也能上手

想用编程写一个属于自己的小游戏吗？猜数游戏简单又有趣，10分钟就能上手！本文将带你用 Rust——这门被程序员票选为“最受喜爱”的语言，打造一个交互式的猜数游戏。从零开始，手把手教你生成随机数、处理用户输入、比较大小，甚至实现多次猜测。无论你是编程小白还是想尝鲜 Rust 的开发者，这篇教程让你轻松入门，边玩边学，解锁编程的乐趣！

本文通过 Rust 语言，带你一步步打造一个趣味猜数游戏：程序生成 1 到 100 的随机数，玩家猜测后会收到“太小”“太大”或“猜中”的提示。教程从基础输入开始，逐步引入随机数生成、数字比较和多次猜测功能，代码简单易懂。无论你是零基础小白还是想快速上手 Rust 的开发者，都能通过这个实战项目学会 Rust 的输入输出、模式匹配和错误处理。10分钟，轻松搞定你的第一个 Rust 程序！

## 实操

## 猜数游戏-一次猜测

### 猜数游戏 - 目标

- 生成一个1到100间的随机数
- 提示玩家输入一个猜测
- 猜完之后，程序会提示猜测是太小了还是太大了
- 如果猜测正确，那么打印出一个庆祝信息，程序退出

### 写代码

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img/202302182323253.png)

```rust
use std::io; // prelude

fn main() {
    println!("猜数!");

    println!("猜测一个数");

    // let mut foo = 1;
    // let bar = foo; // immutable

    // foo = 2;

    let mut guess = String::new();

    io::stdin().read_line(&mut guess).expect("无法读取行");
    // io::Result Ok Err 

    println!("你猜测的数是：{}", guess);
}

```

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img/202302190029828.png)

## 猜数游戏 - 生成神秘数字

Rand：<https://crates.io/crates/rand>

```bash
➜ cd rust/guessing_game

guessing_game on  main [✘!] is 📦 0.1.0 via 🦀 1.67.1
➜ cargo build
   Compiling cfg-if v1.0.0
   Compiling ppv-lite86 v0.2.17
   Compiling libc v0.2.139
   Compiling getrandom v0.2.8
   Compiling rand_core v0.6.4
   Compiling rand_chacha v0.3.1
   Compiling rand v0.8.5
   Compiling guessing_game v0.1.0 (/Users/qiaopengjun/rust/guessing_game)
    Finished dev [unoptimized + debuginfo] target(s) in 1.08s

guessing_game on  main [✘!] is 📦 0.1.0 via 🦀 1.67.1
➜ cargo build
    Finished dev [unoptimized + debuginfo] target(s) in 0.03s

guessing_game on  main [✘!] is 📦 0.1.0 via 🦀 1.67.1
➜ cargo update
```

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img/202302202323209.png)

### 随机数

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img/202302202342562.png)

### 代码

```rust
use std::io; // prelude
use rand::Rng; // trait

fn main() {
    println!("猜数!");

    let secret_number = rand::thread_rng().gen_range(1..101);

    println!("神秘数字是：{}", secret_number);

    println!("猜测一个数");

    // let mut foo = 1;
    // let bar = foo; // immutable

    // foo = 2;

    let mut guess = String::new();

    io::stdin().read_line(&mut guess).expect("无法读取行");
    // io::Result Ok Err 

    println!("你猜测的数是：{}", guess);
}

```

## 猜数游戏 - 比较猜测数字与神秘数字

```rust
use std::io; // prelude
use rand::Rng; // trait
use std::cmp::Ordering; // 枚举类型 三个变体（值）

fn main() {
    println!("猜数!");

    let secret_number = rand::thread_rng().gen_range(1..101);

    println!("神秘数字是：{}", secret_number);

    println!("猜测一个数");

    // let mut foo = 1;
    // let bar = foo; // immutable

    // foo = 2;

    let mut guess = String::new();

    io::stdin().read_line(&mut guess).expect("无法读取行");
    // io::Result Ok Err 

    // shadow
    let guess: u32 = guess.trim().parse().expect("Please type a number!"); // \n

    println!("你猜测的数是：{}", guess);

    match guess.cmp(&secret_number) {
        Ordering::Less => println!("Too small!"), // arm
        Ordering::Greater => println!("Too big!"), 
        Ordering::Equal => println!("You win!"),
    }
}

```

## 猜数游戏 - 允许多次猜测

```rust
use std::io; // prelude
use rand::Rng; // trait
use std::cmp::Ordering; // 枚举类型 三个变体（值）

fn main() {
    println!("猜数!");

    let secret_number = rand::thread_rng().gen_range(1..101);

    // println!("神秘数字是：{}", secret_number);

    loop {
        println!("猜测一个数");

        // let mut foo = 1;
        // let bar = foo; // immutable

        // foo = 2;

        let mut guess = String::new();

        io::stdin().read_line(&mut guess).expect("无法读取行");
        // io::Result Ok Err 

        // shadow
        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(_) => {
                println!("请输入正确的数字");
                continue;
            }
        };
        println!("你猜测的数是：{}", guess);

        match guess.cmp(&secret_number) {
            Ordering::Less => println!("Too small!"), // arm
            Ordering::Greater => println!("Too big!"), 
            Ordering::Equal => {
                println!("You win!");
                break;
            }
        }
    }
}

```

## 总结

通过这个猜数游戏实战，你不仅用 Rust 写出了一个好玩的交互程序，还掌握了编程的精髓！从简单的用户输入，到随机数生成、数字比较，再到循环实现的多次猜测，每一步都让你更靠近 Rust 大门。核心收获：

- 上手 Rust：学会用 std::io 处理输入、rand 生成随机数，解锁 Rust 的强大功能。

- 错误处理：通过 match 和 expect，让程序更稳健。

- 编程思维：从零到完整项目，体验迭代开发的乐趣。

这个小游戏只是起点！试试加个猜测次数限制，或炫酷的得分系统，继续用 Rust 探索编程的无限可能吧！快来留言，分享你的成果！

## 参考

- <https://crates.io/crates/rand>
- <https://www.rust-lang.org/zh-CN>
- <https://doc.rust-lang.org/stable/book/>
- <https://this-week-in-rust.org/>
- <https://rust-lang.github.io/rustup/overrides.html#toolchain-override-shorthand>
- <https://doc.rust-lang.org/stable/rust-by-example/>
