+++
title = "Rust 编程入门：Struct 让代码更优雅"
description = "Rust 编程入门：Struct 让代码更优雅"
date = 2025-05-02T05:40:31Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust 编程入门：Struct 让代码更优雅

想写出简洁又高效的代码？Rust 的 Struct 带你轻松入门！
在 Rust 编程世界中，Struct（结构体）是组织数据、提升代码质量的利器。无论是定义用户资料、计算几何面积，还是构建复杂逻辑，Struct 都能让你的代码更优雅、更清晰。本文将从零开始，带你掌握 Struct 的定义、实例化、方法实现及优化技巧，通过直观的示例和实用代码，助你快速上手 Rust 编程。无论你是编程新手还是进阶开发者，这篇入门指南都将为你打开 Rust 的新大门！快来一起探索吧！

本文是 Rust 编程初学者的 Struct 入门指南，深入浅出地讲解了 Struct 的核心概念与实用技巧。内容涵盖 Struct 的定义与实例化、字段访问与更新、Tuple Struct 和 Unit-Like Struct 的特性，以及方法和关联函数的实现。通过计算长方形面积的案例，展示了如何用 Struct 优化代码，提升可读性和性能。文章还介绍了调试技巧（如 #[derive(Debug)]）和所有权机制，配以清晰的代码示例，帮助读者快速掌握 Struct 的优雅用法。无论你是 Rust 新手还是想提升代码质量的开发者，本文都为你提供了实用的学习路径。

## 一、定义并实例化struct

### 什么是 struct

- struct，结构体
  - 自定义的数据类型
  - 为相关联的值命名，打包 => 有意义的组合

### 定义 struct

- 使用 `struct` 关键字，并为整个struct命名
- 在花括号内，为所有字段（Field）定义名称和类型

例如：

```rust
struct User {
  username: String,
  email: String,
  sign_in_count: u64,
  active: bool,
}
```

### 实例化struct

- 想要使用struct，需要创建struct的实例：
  - 为每个字段指定具体值
  - 无需按声明的顺序进行指定

例子：

```rust
let user1 = User {
  email: String::from("someone@example.com"),
  username: String::from("someusername123"),
  active: true,
  sign_in_count: 1,
};
```

代码：

```rust
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
    active: bool,
}

fn main() {
    println!("Hello, world!");

    let user1 = User {
        email: String::from("user1@example.com"),
        username: String::from("user1"),
        active: true,
        sign_in_count: 556,
    };
}

```

### 取得struct里面的某个值

- 使用点标记法：

```rust
let mut user1 = User {
  email: String::from("someone@example.com"),
  username: String::from("someusername123"),
  active: true,
  sign_in_count: 1,
};

user1.email = String::from("anotheremail@example.com");
```

#### 注意

- 一旦struct的实例是可变的，那么实例中所有的字段都是可变的

### struct 作为函数的返回值

例子：

```rust
fn build_user(email: String, username: String) -> User {
  User {
    email: email,
    username: username,
    active: true,
    sign_in_count: 1,
  }
}
```

### 字段初始化简写

- 当字段名与字段值对应变量名相同时，就可以使用字段初始化简写的方式：

```rust
fn build_user(email: String, username: String) -> User {
  User {
    email,
    username,
    active: true,
    sign_in_count: 1,
  }
}
```

### Struct 更新语法

- 当你想基于某个struct实例来创建一个新实例的时候，可以使用struct更新语法：

```rust
let user2 = User {
  email: String::from("another@example.com"),
  username: String::from("anotherusername567"),
  active: user1.active,
  sign_in_count: user1.sign_in_count,
};


let user2 = User {
  email: String::from("another@example.com"),
  username: String::from("anotherusername567"),
  ..user1
};
```

### Tuple struct

- 可定义类似 tuple 的struct，叫做 tuple struct
  - Tuple struct 整体有个名，但里面的元素没有名
  - 适用：想给整个 tuple起名，并让它不同于其它tuple，而且又不需要给每个元素起名
- 定义 tuple struct：使用 struct 关键字，后边是名字，以及里面元素的类型
- 例子：

```rust
struct Color(i32, i32, i32);
struct Point(i32, i32, i32);
let black = Color(0, 0, 0);
let origin = Point(0, 0, 0);
```

- black 和 origin 是不同的类型，是不同 tuple struct 的实例

### Unit-Like Struct （没有任何字段）

- 可以定义没有任何字段的 struct，叫做 Unit-Like struct（因为与()，单元类型类似）
- 适用于需要在某个类型上实现某个Trait，但是在里面又没有想要存储的数据

### struct 数据的所有权

```rust
struct User {
  username: String,
  email: String,
  sign_in_count: u64,
  active: bool,
}
```

- 这里的字段使用了String 而不是 &str：
  - 该 struct 实例拥有其所有的数据
  - 只要 struct 实例是有效的，那么里面的字段数据也是有效的
- struct 里也可以存放引用，但这需要使用生命周期
  - 生命周期保证只要struct实例是有效的，那么里面的引用也是有效的
  - 如果 struct 里面存储引用，而不使用生命周期，就会报错

```rust
// 没有使用生命周期
struct User {
  username: &str,
  email: &str,
  sign_in_count: u64,
  active: bool,
}

fn main() {
  println!("Hello, world!");
  
  let user1 = User {
    email: "fdsa",
    username: "fds",
    active: true,
    sign_in _count: 556,
  };
}
```

## 二、 struct 例子

例子需求

- 计算长方形面积

```rust
fn main() {
    let w = 30;
    let l = 50;

    println!("{}", area(w, l));
}

fn area(width: u32, length: u32) -> u32 {
    width * length
}

```

优化一：

```rust
fn main() {
    let rect = (30, 50);

    println!("{}", area(rect));
}

fn area(dim: (u32, u32)) -> u32 {
    dim.0 * dim.1
}

```

优化二：

```rust
struct Rectangle {
    width: u32,
    length: u32,
}

fn main() {
    let rect = Rectangle {
        width: 30,
        length: 50,
    };

    println!("{}", area(&rect));
}

fn area(rect: &Rectangle) -> u32 {
    rect.width * rect.length
}

```

### 什么是struct

- `std::fmt::Display`
- `std::fmt::Debug`
- `#[derive(debug)]`
- `{:?}`
- `{:#?}`

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    length: u32,
}

fn main() {
    let rect = Rectangle {
        width: 30,
        length: 50,
    };

    println!("{}", area(&rect));

    
    println!("{:?}", rect);
    println!("{:#?}", rect);
}

fn area(rect: &Rectangle) -> u32 {
    rect.width * rect.length
}

```

## Struct 方法

- 方法和函数类似：fn 关键字、名称、参数、返回值
- 方法与函数不同之处：
  - 方法是在struct（或 enum、trait 对象）的上下文中定义
  - 第一个参数是self，表示方法被调用的struct实例

### 定义方法

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    length: u32,
}

impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.length
    }
}    

fn main() {
    let rect = Rectangle {
        width: 30,
        length: 50,
    };

    println!("{}", rect.area());

    
    println!("{:?}", rect);
    println!("{:#?}", rect);
}
```

- 在 impl 块里定义方法
- 方法的第一个参数可以是 &self，也可以获得其所有权或可变借用。和其他参数一样。
- 更良好的代码组织。

### 方法调用的运算符

- C/C++：`ogject->something()` 和 `(*object).something()` 一样
- Rust没有 -> 运算符
- Rust会自动引用或解引用
  - 在调用方法时就会发生这种行为
- 在调用方法时，Rust根据情况自动添加&、&mut或*，以便object可以匹配方法的签名
- 下面两行代码效果相同：
  - `p1.distance(&p2);`
  - `(&p1).distance(&p2);`

### 方法参数

- 方法可以由多个参数

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    length: u32,
}

impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.length
    }

    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.length > other.length
    }
}    

fn main() {
    let rect = Rectangle {
        width: 30,
        length: 50,
    };

    let rect1 = Rectangle {
        width: 30,
        length: 50,
    };

    let rect2 = Rectangle {
        width: 10,
        length: 40,
    };

    let rect3 = Rectangle {
        width: 35,
        length: 55,
    };

    println!("{}", rect1.can_hold(&rect2));
    println!("{}", rect1.can_hold(&rect3));

    println!("{}", rect.area());

    
    println!("{:?}", rect);
    println!("{:#?}", rect);
}

// fn area(rect: &Rectangle) -> u32 {
//     rect.width * rect.length
// }

```

### 关联函数

- 可以在 impl 块里定义不把self作为第一个参数的函数，它们叫关联函数（不是方法）
  - 例如：`String::from()`
- 关联函数通常用于构造器（被关联类型的实例）

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    length: u32,
}

impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.length
    }

    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.length > other.length
    }

    fn square(size: u32) -> Rectangle {
        Rectangle { width: size, length: size }
    }
}    

fn main() {
    let s = Rectangle::square(20);
    let rect = Rectangle {
        width: 30,
        length: 50,
    };

    let rect1 = Rectangle {
        width: 30,
        length: 50,
    };

    let rect2 = Rectangle {
        width: 10,
        length: 40,
    };

    let rect3 = Rectangle {
        width: 35,
        length: 55,
    };

    println!("{}", rect1.can_hold(&rect2));
    println!("{}", rect1.can_hold(&rect3));

    println!("{}", rect.area());

    
    println!("{:?}", rect);
    println!("{:#?}", rect);

    println!("{:?}", s)
}
```

- :: 符号
  - 关联函数
  - 模块创建的命名空间

### 多个 impl 块

- 每个struct允许拥有多个impl块

## 总结

Rust 的 Struct 是编程中的优雅利器，让你轻松组织数据、优化代码结构。通过本文，你学会了如何定义和实例化 Struct，使用方法和关联函数实现功能扩展，以及通过更新语法和调试技巧提升开发效率。从简单的长方形面积计算到复杂的数据管理，Struct 让 Rust 代码更清晰、更高效。无论你是刚入门 Rust 的新手，还是追求极致代码质量的开发者，掌握 Struct 都将为你的编程之旅增添无限可能！快动手实践，留言分享你的 Struct 代码吧！关注我们，解锁更多 Rust 编程干货！

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://crates.io/>
- <https://course.rs/about-book.html>
- <https://users.rust-lang.org/>
- <https://lab.cs.tsinghua.edu.cn/rust/>
- <https://github.com/justjavac/unicode-encoding-error-table>
- <https://github.com/rust-lang>
