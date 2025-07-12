+++
title = "Rust 错误处理终极指南：从 panic! 到 Result 的优雅之道"
description = "Rust 错误处理终极指南：从 panic! 到 Result 的优雅之道"
date = 2025-07-12T02:24:21Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust 错误处理终极指南：从 panic! 到 Result 的优雅之道

嗨，各位 Rustacean！你是否曾被程序的突然崩溃（panic）搞得一头雾水？或者面对复杂的 match 嵌套感到力不从心？

Rust 以其无与伦比的可靠性著称，而这背后最大的功臣就是其独特的错误处理机制。它在编译时就强制我们思考并处理潜在的失败，从根源上消除了大量的运行时错误。

本文将带你深入探索 Rust 的两大错误处理核心：用于不可恢复错误的 panic! 宏，以及用于可恢复错误的 Result 枚举。我们将从基本概念讲起，一路剖析 unwrap、expect、错误传播的 ? 运算符，并最终探讨何时应该让程序崩溃，何时应该优雅地返回一个结果。

读完本文，你将对 Rust 的错误处理哲学有更深刻的理解，写出更健壮、更优雅、更符合 Rust 风格的代码！

## 一、panic! 不可恢复的错误

### Rust 错误处理概述

- Rust 的可靠性：错误处理
  - 大部分情况下：在编译时提示错误，并处理
- 错误的分类：
  - 可恢复
    - 例如文件未找到，可再次尝试
  - 不可恢复
    - bug，例如访问的索引超出范围
- Rust没有类似异常的机制
  - 可恢复错误：Result<T, E>
  - 不可恢复：panic! 宏

### 不可恢复的错误与 panic

- 当 panic! 宏执行：
  - 你的程序会打印一个错误信息
  - 展开(unwind)、清理调用栈(Stack)
  - 退出程序

### 为应对 panic，展开或中止(abort) 调用栈

- 默认情况下，当 panic 发生：
  - 程序展开调用栈（工作量大）
    - Rust 沿着调用栈往回走
    - 清理每个遇到的函数中的数据
  - 或立即中止调用栈：
    - 不进行清理，直接停止程序
    - 内存需要 OS 进行清理
- 想让二进制文件更小，把设置从“展开”改为“中止”：
  - 在 Cargo.toml 中适当的 profile 部分设置：
    - panic = 'abort'

例子：Cargo.toml 文件

```toml
[package]
name = "vector_demo"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]

[profile.release]
panic = 'abort'
```

例子：src/main.rs 文件

```rust
fn main() {
  // panic!("crash and burn");
  
  let v = vec![1, 2, 3];
  
  v[99]; // panic
}
```

### 使用 panic! 产生的回溯信息

- panic! 可能出现在：
  - 我们写的代码中
  - 我们所依赖的代码中
- 可通过调用 panic! 的函数的回溯信息来定位引起问题的代码
- 通过设置环境变量 RUST_BACKTRACE 可得到回溯信息
- 为了获取带有调试信息的回溯，必须启用调试符号（不带 --release）

## 二、Result 枚举与可恢复的错误（上）

### Result 枚举

```rust
enum Result<T, E> {
  Ok(T),
  Err(E),
}
```

- T：操作成功情况下，Ok 变体里返回的数据的类型
- E：操作失败情况下，Err 变体里返回的错误的类型

```rust
use std::fs::File

fn main() {
  let f = File::open("hello.txt");
}
```

### 处理 Result 的一种方式：match 表达式

- 和 Option 枚举一样，Result 及其变体也是由 prelude 带入作用域

```rust
use std::fs::File

fn main() {
  let f = File::open("hello.txt");
  
  let f = match f {
    Ok(file) => file,
    Err(error) => {
      panic!("Error opening file {:?}", error)
    }
  };
}
```

### 匹配不同的错误

```rust
use std::fs::File

fn main() {
  let f = File::open("hello.txt");
  
  let f = match f {
    Ok(file) => file,
    Err(error) => match error.kind() {
      ErrorKind::NotFound => match File::create("hello.txt") {
        Ok(fc) => fc,
        Err(e) => panic!("Error creating file: {:?}", e),
      },
      other_error = panic!("Error opening the file: {:?}", other_error),
    },
  };
}
```

- 上例中使用了很多 match ...
- Match  很有用，但是很原始
- 闭包(closure)。Result<T, E> 有很多方法：
  - 它们接收闭包作为参数
  - 使用 match 实现
  - 使用这些方法会让代码更简洁

```rust
use std::fs::File

fn main() {
  let f = File::open("hello.txt").unwrap_or_else(|error| {
    if error.kind() == ErrorKind::NotFound {
      File::create("hello.txt").unwrap_or_else(|error| {
        panic!("Error creating file: {:?}", error);
      })
    } else {
      panic!("Error opening the file: {:?}", error);
    }
  });
}
```

### unwrap

- unwrap：match 表达式的一个快捷方式：
  - 如果 Result 结果是 Ok，返回 Ok 里面的值
  - 如果 Result 结构是 Err，调用 panic! 宏

```rust
use std::fs::File

fn main() {
  let f = File::open("hello.txt");
  
  let f = match f {
    Ok(file) => file,
    Err(error) => {
      panic!("Error opening file {:?}", error)
    }
  };
  
  let f = File::open("hello.txt").unwrap();  // 错误信息不可自定义
}
```

### expect

- expect：和 unwrap 类似，但可指定错误信息

```rust
use std::fs::File

fn main() {
  let f = File::open("hello.txt").expect("无法打开文件 hello.txt");  
}
```

## 三、Result 枚举与可恢复的错误（下）

### 传播错误

- 在函数处处理错误
- 将错误返回给调用者

```rust
use std::fs::File;
use std::io;
use std::io::Read;

fn read_username_from_file() -> Result<String, io::Error> {
  let f = File::open("hello.txt");
  
  let mut f = match f {
    Ok(file) => file,
    Err(e) => return Err(e),
  };
  
  let mut s = String::new();
  match f.read_to_string(&mut s) {
    Ok(_) => Ok(s),
    Err(e) => Err(e),
  }
}

fn main() {
  let result = read_username_from_file();
}
```

### ? 运算符

- ？ 运算符：传播错误的一种快捷方式

```rust
use std::fs::File;
use std::io;
use std::io::Read;

fn read_username_from_file() -> Result<String, io::Error> {
  let mut f = File::open("hello.txt")?;
  
  let mut s = String::new();
  f.read_to_string(&mut s)?;
  Ok(s)
}

fn main() {
  let result = read_username_from_file();
}
```

- 如果 Result 是 Ok：Ok 中的值就是表达式的结果，然后继续执行程序
- 如果 Result 是 Err：Err 就是整个函数的返回值，就像使用了 return

### ? 与 from 函数

- Trait std::convert::From 上的 from 函数：
  - 用于错误之间的转换
- 被 ？ 所应用的错误，会隐式的被 from 函数处理
- 当 ？ 调用 from 函数时：
  - 它所接收的错误类型会被转化为当前函数返回类型所定义的错误类型
- 用于：针对不同错误原因，返回同一种错误类型
  - 只要每个错误类型实现了转换为所返回的错误类型的from函数

- 链式调用

```rust
use std::fs::File;
use std::io;
use std::io::Read;

fn read_username_from_file() -> Result<String, io::Error> {
  let mut s = String::new();
  File::open("hello.txt")?.read_to_string(&mut s)?;
  Ok(s)
}

fn main() {
  let result = read_username_from_file();
}
```

### ? 运算符只能用于返回 Result 的函数

```rust
use std::fs::File;

fn main() {
  let f = File::open("hello.txt")?; // 报错 
}
```

### ? 运算符与 main 函数

- main 函数返回类型是: ()
- main 函数的返回类型也可以是： Result<T, E>

```rust
use std::error::Error;
use std::fs::File;

fn main() -> Result<(), Box<dyn Error>> {
  let f = File::open("hello.txt")?;
  Ok(())
}
```

- `Box<dyn Error>` 是 Trait 对象：
  - 简单理解：“任何可能得错误类型”

## 四、什么时候应该用 panic

### 总体原则

- 在定义一个可能失败的函数时，优先考虑返回 Result
- 否则就 panic!

### 编写示例、原型代码、测试

- 可以使用panic!
  - 演示某些概念：unwrap
  - 原型代码：unwrap、expect
  - 测试：unwrap、expect

### 有时你比编译器掌握更多的信息

- 你可以确定 Result 就是 Ok：unwrap

```rust
use std::net::IpAddr;

fn main() {
  let home: IpAddr = "127.0.0.1".parse().unwrap();
}
```

### 错误处理的指导性建议

- 当代码最终可能处于损坏状态时，最号使用 panic!
- 损坏状态(Bad state)：某些假设、保证、约定或不可变性被打破
  - 例如非法的值、矛盾的值或空缺的值被传入代码
  - 以及下列中的一条：
    - 这种损坏状态并不是预期能够偶尔发生的事情
    - 在此之后，您的代码如果处于这种损坏状态就无法运行
    - 在您使用的类型中没有一个好的方法来将这些信息（处于损坏状态）进行编码

### 场景建议

- 调用你的代码，传入无意义的参数值：panic!
- 调用外部不可控代码，返回非法状态，你无法修复：panic!
- 如果失败是可预期的：Result
- 当你的代码对值进行操作，首先应该验证这些值：panic!

### 为验证创建自定义类型

```rust
fn main() {
  loop {
    // ...

    let guess = "32";
    let guess: i32 = match guess.trim().parse() {
      Ok(num) => num,
      Err(_) => continue,
    };

    if guess < 1 || guess > 100 {
      println!("The secret number will be between 1 and 100.");
      continue;
    }

    // ...
  }
}
```

- 创建新的类型，把验证逻辑放在构造实例的函数里

```rust
pub struct Guess {
  value: i32,
}

impl Guess {
  pub fn new(value: i32) -> Guess {
    if value < 1 || value >100 {
      panic!("Guess value must be between 1 and 100, got {}", value);
    }
    
    Guess {value}
  }
  
  pub fn value(&self) -> i32 {
    self.value
  }
}

fn main() {
  loop {
    // ...
    
    let guess = "32";
    let guess: i32 = match guess.trim().parse() {
      Ok(num) => num,
      Err(_) => continue,
    };
    
    let guess = Guess::new(guess);
    // ...
  }
}
```

- getter：返回字段数据
  - 字段是私有的：外部无法直接对字段赋值

## 总结

经过本文的探讨，我们可以对 Rust 的错误处理形成一个清晰的脉络：

1. 错误分类是核心：Rust 明确区分了“程序员的 bug”（应使用 panic!）和“可预期的操作失败”（应使用 Result）。panic! 用于那些我们不希望也无法正常处理的场景，代表程序已进入无法保证其正确性的“损坏状态”。
2. 优先使用 Result：对于任何可能失败的操作，例如文件 I/O、网络请求或数据解析，默认都应该返回 Result。这给了调用者选择如何处理错误的权力，使代码更加灵活和健壮。
3. 拥抱 ? 运算符：? 运算符是编写简洁、地道的 Rust 代码的关键。它极大地简化了错误的传播链，让你能专注于核心业务逻辑，而不是陷入层层 match 嵌套。
4. unwrap 和 expect 需谨慎：这两个方法虽然方便，但它们是 panic! 的快捷方式。在示例、测试或你 100% 确定结果为 Ok 的情况下可以使用，但在生产代码的业务逻辑中，它们往往是潜在的炸弹。

总而言之，精通 Rust 的错误处理机制，是从“会写”到“写好” Rust 的必经之路。它不仅仅是一种语法，更是一种构建可靠软件的设计哲学。希望你从现在开始，能更加自信和优雅地处理代码中的每一个潜在错误。

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://course.rs/about-book.html>
- <https://lab.cs.tsinghua.edu.cn/rust/>
