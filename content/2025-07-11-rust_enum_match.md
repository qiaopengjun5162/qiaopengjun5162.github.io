+++
title = "Rust核心利器：枚举(Enum)与模式匹配(Match)，告别空指针，写出优雅健壮的代码"
description = "Rust核心利器：枚举(Enum)与模式匹配(Match)，告别空指针，写出优雅健壮的代码"
date = 2025-07-11T00:31:29Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust核心利器：枚举(Enum)与模式匹配(Match)，告别空指针，写出优雅健壮的代码

在任何编程语言中，我们经常需要处理一个值可能是多种不同类型或状态之一的情况。你可能会想到用继承、接口或者复杂的 if-else 链来解决。

但在 Rust 中，我们有一种更强大、更优雅的工具——枚举 (Enum)。它不仅仅是简单的数值列表，更可以像一个“多态”容器，为每一种可能性附加不同的数据。

但仅仅定义类型还不够，我们还需要一种方法来根据不同的类型执行不同的代码，这就是模式匹配 (Pattern Matching) 大显身手的地方。它是 Rust 安全性和表达力的核心体现。

本文将带你深入理解这两个密不可分的概念，看看它们是如何协同工作，帮助我们写出没有空指针烦恼、清晰且极其稳固的 Rust 代码。

## 一、定义枚举

### 枚举

- 枚举允许我们列举所有可能的值来定义一个类型

### 定义枚举

- IP地址：IPv4、IPv6

```rust
enum IpAddrKind {
  V4,
  V6,
}
```

### 枚举值

- 例子：
- `let four = IpAddrKind::V4;`
- `let six = IpAddrKind::V6;`
- 枚举的变体都位于标识符的命名空间下，使用两个冒号:: 进行分隔

```rust
enum IpAddrKind {
    V4,
    V6,
}

fn main() {
    let four = IpAddrKind::V4;
    let six = IpAddrKind::V6;

    route(four);
    route(six);
    route(IpAddrKind::V6);
}

fn route(ip_kind: IpAddrKind) {}

```

### 将数据附加到枚举的变体中

```rust
enum IpAddr {
  V4(String),
  V6(String),
}
```

未使用前：

```rust
enum IpAddrKind {
    V4,
    V6,
}

struct IpAddr {
    kind: IpAddrKind,
    address: String,
}

fn main() {
    let home = IpAddr {
        kind: IpAddrKind::V4,
        address: String::from("127.0.0.1"),
    };

    let loopback = IpAddr {
        kind: IpAddrKind::V6,
        address: String::from("::1"),
    };
}
```

- 优点：
  - 不需要额外使用 struct
  - 每个变体可以拥有不同的类型以及关联的数据量
- 例如：

```rust
enum IpAddr {
  V4(u8, u8, u8, u8),
  V6(String),
}
```

使用之后：

```rust
enum IpAddrKind {
    V4(u8, u8, u8, u8),
    V6(String),
}

fn main() {
    let home = IpAddrKind::V4(127, 0, 0, 1);
    let loopback = IpAddrKind::V6(String::from("::1"));
}
```

### 标准库中的 IpAddr

```rust
struct Ipv4Addr {
  // --snip--
}

struct Ipv6Addr {
  // --snip--
}

enum IpAddr {
  V4(Ipv4Addr),
  V6(Ipv6Addr),
}
```

例子：

```rust
enum Message {
    Quit,
    Move {x: i32, y: i32},
    Write(String),
    ChangeColor(i32, i32, i32),
}

fn main() {
    let q = Message::Quit;
    let m = Message::Move { x: 12, y: 24 };
    let w = Message::Write(String::from("hello"));
    let c = Message::ChangeColor(0, 255, 255);
}
```

### 为枚举定义方法

- 使用 impl 关键字

```rust
enum Message {
    Quit,
    Move {x: i32, y: i32},
    Write(String),
    ChangeColor(i32, i32, i32),
}

impl Message {
    fn call(&self) {}
}

fn main() {
    let q = Message::Quit;
    let m = Message::Move { x: 12, y: 24 };
    let w = Message::Write(String::from("hello"));
    let c = Message::ChangeColor(0, 255, 255);

    m.call();
}
```

## 二、Option 枚举

### Option 枚举

- 定义于标准库中
- 在 Prelude （预导入模块）中
- 描述了：某个值可能存在（某种类型）或不存在的情况

### Rust 没有 Null

- 其它语言中：
  - NULL 是一个值，它表示“没有值”
  - 一个变量可以处于两种状态：空值（NULL）、非空
- NULL 引用：Billion Dollar Mistake
- NULL 的问题在于：当你尝试像使用非NULL值那样使用NULL值的时候，就会引起某种错误
- NULL的概念还是有用的：因某种原因而变为无效或缺失的值

### Rust中类似NULL概念的枚举- Option<T>

- 标准库中的定义：
- `enum Option<T> {Some(T), None,}`
- 它包含在Prelude（预导入模块）中。可直接使用：
  - `Option<T>`
  - `Some(T)`
  - `None`
- 例子：

```rust
fn main() {
    let some_number = Some(5);
    let some_string = Some("A String");

    let absent_number: Option<i32> = None;
}
```

### `Option<T>`比 Null 好在哪？

- `Option<T>`和T 是不同的类型，不可以把 `Option<T>` 直接当成 T
- 若想使用 `Option<T>` 中的 T，必须将它转换为 T
- 而在 C# 中：
  - `string a = null;`
  - `string b = a + "12345";`

```rust
fn main() {
  let x: i8 = 5;
  let y: Option<i8> = Some(5);
  
  let sum = x + y;  // 报错 需要转换
}
```

## 三、控制流运算符 - match

### 强大的控制流运算符 - match

- 允许一个值与一系列模式进行匹配，并执行匹配的模式对应的代码
- 模式可以是字面值、变量名、通配符...
- 例子：

```rust
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter,
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter => 25,
    }
}

fn main() {
    println!("Hello, world!");
}

```

### 绑定值得模式

- 匹配的分支可以绑定到被匹配对象的部分值
  - 因此，可以从enum 变体中提取值

```rust
#[derive(Debug)]
enum UsState {
    Alabama,
    Alaska,
}

enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => {
            println!("Penny!");
            1
        }
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("State quarter from: {:?}!", state);
            25
        }
    }
}

fn main() {
    let c = Coin::Quarter(UsState::Alaska);
    println!("{}", value_in_cents(c));
}

```

### 匹配 `Option<T>`

```rust
fn main() {
  let five = Some(5);
  let six = plus_one(five);
  let none = plus_one(None);
}

fn plus_one(x: Option<i32>) -> Option<i32> {
  match x {
    None => None,
    Some(i) => Some(i + 1),
  }
}
```

### Match 匹配必须穷举所有的可能

- _ 通配符：替代其余没列出的值
- 例子：

```rust
fn main() {
  let v = 0u8;
  match v {
    1 => println!("one"),
    3 => println!("three"),
    5 => println!("five"),
    7 => println!("seven"),
    _ => (),
  }
}
```

## 四、if let

- 处理只关心一种匹配而忽略其它匹配的情况

```rust
fn main() {
  let v = Some(0u8);
  match v {
    Some(3) => println!("three"),
    _ => (),
  }
  
  if let Some(3) = v {
    println!("three");
  }
}
```

- 更少的代码，更少的缩进，更少的模版代码
- 放弃了穷举的可能
- 可以把if let 看作是 match 的语法糖
- 搭配 else

```rust
fn main() {
  let v = Some(0u8);
  match v {
    Some(3) => println!("three"),
    _ => println!("others"),
  }
  
  if let Some(3) = v {
    println!("three");
  } else {
    println!("others");
  }
}
```

## 总结

通过本文的学习，我们深入了解了 Rust 中两个密不可分且极其强大的特性：枚举和模式匹配。
我们总结出以下核心要点：

1. 枚举 (Enum) 是类型的集合：Rust 的枚举远比其他语言的枚举强大，它允许每个变体持有不同类型和数量的数据，能用非常简洁的方式定义一个“和类型 (Sum Type)”。
2. Option<T> 是对“空”的优雅抽象：Rust 通过 Option<T> 枚举（包含 Some(T) 和 None）来处理可能不存在的值，将空值问题从一个难以追踪的运行时错误，变成了一个必须在编译时处理的类型问题，极大地提升了代码的安全性。
3. match 是安全的代码分支逻辑：match 表达式强制我们处理一个枚举的所有可能变体，确保了代码逻辑的完备性，杜绝了因遗漏某些情况而导致的 Bug。编译器会成为你最可靠的助手。
4. if let 是简洁的语法糖：当我们只关心一种匹配情况时，if let 提供了一种更轻量、更简洁的语法，避免了 match 的冗余代码。

总而言之，枚举让我们能够在一个类型中优雅地定义所有可能性，而模式匹配（特别是 match 表达式）则为我们提供了一种安全、详尽的方式来处理这些可能性。这种设计哲学的核心在于将许多潜在的运行时错误（如空指针异常）转移到编译时，让问题在开发阶段就被发现和解决。
  
掌握枚举和模式匹配，是写出地道、高效 Rust 代码的关键一步，也是体验 Rust 语言安全与性能之美的开始。

## 参考

- <https://rust10x.com/>
- <https://www.rust-lang.org/>
- <https://lab.cs.tsinghua.edu.cn/rust/>
- <https://course.rs/about-book.html>
