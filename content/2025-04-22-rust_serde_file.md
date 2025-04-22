+++
title = "用 Rust 玩转数据存储：JSON 文件持久化实战"
description = "用 Rust 玩转数据存储：JSON 文件持久化实战"
date = 2025-04-22T14:56:12Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 用 Rust 玩转数据存储：JSON 文件持久化实战

你是否想过如何让 Rust 程序中的数据“长久保存”？在开发中，数据从内存到文件的持久化是一个常见需求。Rust 凭借其高性能和安全性，结合强大的 Serde 框架，能轻松实现数据的 JSON 文件存储与读取。本文将带你通过一个简单却实用的 User 数据结构示例，从零开始实现数据的持久化，代码清晰、步骤详尽，适合 Rust 新手快速上手，也为进阶开发者提供灵感。快来一起“玩转” Rust 的数据存储吧！

本文通过一个 Rust 项目，展示了如何使用 Serde 框架实现 User 数据结构的 JSON 文件持久化。内容涵盖项目搭建、依赖配置、核心代码实现和测试验证，详细讲解了数据从内存到文件的序列化与反序列化过程。通过标准库的 std::fs::File 进行文件操作，结合 Serde 的强大功能，代码简洁高效。无论你是 Rust 初学者还是想深入学习数据持久化的开发者，这篇实战教程都能让你快速掌握从内存到文件的存储技巧。

## 用文件持久化数据结构

### 思考：如何在内存和 IO 设备间交换数据？

### 创建项目

```bash
~/Code/rust via 🅒 base
➜ cargo new training_code --lib
     Created library `training_code` package

~/Code/rust via 🅒 base
➜ cd training_code

training_code on  master [?] via 🦀 1.71.0 via 🅒 base
➜ c

```

### 项目目录

```bash
training_code on  master [?] is 📦 0.1.0 via 🦀 1.71.0 via 🅒 base
➜ tree -a -I "target|.git"
.
├── .gitignore
├── Cargo.lock
├── Cargo.toml
└── src
    ├── lib.rs
    └── user.rs

2 directories, 5 files

training_code on  master [?] is 📦 0.1.0 via 🦀 1.71.0 via 🅒 base
➜
```

### Cargo.toml

```ts
[package]
name = "training_code"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
serde = { version = "1.0.178", features = ["derive"] }
serde_json = "1.0.104"

```

### lib.rs

```rust
pub mod user;

```

### user.rs

```rust
// 用文件持久化数据结构
// 思考：如何在内存和IO设备间交换数据？

use std::{
    fs::File,
    io::{Read, Write},
};

use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, PartialEq)]
pub enum Gender {
    Unspecified = 0,
    Male = 1,
    Female = 2,
}

#[derive(Serialize, Deserialize, Debug, PartialEq)]
pub struct User {
    pub name: String,
    age: u8,
    pub(crate) gender: Gender,
}

impl User {
    pub fn new(name: String, age: u8, gender: Gender) -> Self {
        Self { name, age, gender }
    }

    pub fn load(filename: &str) -> Result<Self, std::io::Error> {
        let mut file = File::open(filename)?;
        let mut data = String::new();
        file.read_to_string(&mut data)?;
        let user = serde_json::from_str(&data)?;
        Ok(user)
    }

    pub fn persist(&self, filename: &str) -> Result<usize, std::io::Error> {
        let mut file = File::create(filename)?;

        // // ? eq
        // match File::create(filename) {
        //     Ok(f) => {
        //         todo!()
        //     }
        //     Err(e) => return Err(e),
        // }

        let data = serde_json::to_string(self)?;
        file.write_all(data.as_bytes())?;

        Ok(data.len())
    }
}

impl Default for User {
    fn default() -> Self {
        User::new("Unknown User".into(), 0, Gender::Unspecified)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let user = User::default();
        let path = "/tmp/user1";
        user.persist(path).unwrap();
        let user1 = User::load(path).unwrap();
        assert_eq!(user, user1);
    }
}

```

### 代码概述

- **目的**：通过 Rust 和 Serde 框架，实现 User 数据结构的序列化（保存到 JSON 文件）和反序列化（从 JSON 文件加载），解决内存与 IO 设备间的数据交换问题。
- **核心功能**：
  - 定义 User 数据结构，包含姓名、年龄和性别。
  - 提供 persist 方法将 User 实例序列化为 JSON 并保存到文件。
  - 提供 load 方法从文件中读取 JSON 并反序列化为 User 实例。
  - 包含测试用例验证持久化和加载的正确性。
- **使用的库**：
  - std::fs::File 和 std::io::{Read, Write}：处理文件读写。
  - serde 和 serde_json：实现数据的序列化与反序列化。

---

#### 详细代码解释

1. **导入依赖**

```rust
use std::{
    fs::File,
    io::{Read, Write},
};
use serde::{Deserialize, Serialize};
```

- **std::fs::File**：提供文件操作功能，用于打开或创建文件。
- **std::io::{Read, Write}**：提供文件内容的读取和写入接口。
- **serde::{Deserialize, Serialize}**：Serde 框架的 trait，用于定义数据结构的可序列化和反序列化行为。
- **说明**：这些依赖为文件操作和 JSON 序列化提供了基础支持。

---

2. **定义 Gender 枚举**

```rust
#[derive(Serialize, Deserialize, Debug, PartialEq)]
pub enum Gender {
    Unspecified = 0,
    Male = 1,
    Female = 2,
}
```

- **功能**：定义 Gender 枚举，表示用户的性别，包含三种状态：未指定、男性和女性。
- **属性**：
  - \#[derive(Serialize, Deserialize)]：使 Gender 支持 Serde 的序列化和反序列化，允许其转换为 JSON 或从 JSON 恢复。
  - Debug：允许打印调试信息（用于日志或测试）。
  - PartialEq：支持比较两个 Gender 值是否相等（用于测试）。
  - pub：公开枚举，使其可在模块外部使用。
- **数值赋值**（如 Unspecified = 0）：为每个变体指定整数值，便于序列化时保持一致性。
- **说明**：Gender 是一个简单的枚举，作为 User 结构体的字段之一。

---

3. **定义 User 结构体**

```rust
#[derive(Serialize, Deserialize, Debug, PartialEq)]
pub struct User {
    pub name: String,
    age: u8,
    pub(crate) gender: Gender,
}
```

- **功能**：定义 User 数据结构，表示一个用户，包含姓名（name）、年龄（age）和性别（gender）。
- **字段**：
  - pub name: String：公开的姓名字段，存储用户姓名。
  - age: u8：私有字段，存储年龄（8 位无符号整数，范围 0-255）。
  - pub(crate) gender: Gender：仅在当前 crate 公开的性别字段，使用自定义 Gender 枚举。
- **属性**：
  - \#[derive(Serialize, Deserialize)]：使 User 支持 JSON 序列化和反序列化。
  - Debug 和 PartialEq：支持调试输出和相等性比较。
- **说明**：User 是核心数据结构，设计简洁，适合展示持久化功能。pub(crate) 限制了 gender 的访问，体现了 Rust 的封装性。

---

4. **实现 User 方法**

```rust
impl User {
    pub fn new(name: String, age: u8, gender: Gender) -> Self {
        Self { name, age, gender }
    }
```

- **功能**：提供构造方法，创建新的 User 实例。
- **参数**：接收 name（字符串）、age（8 位整数）和 gender（枚举）。
- **返回值**：返回 User 实例，使用 Self 简化字段赋值。
- **说明**：这是一个标准的构造方法，便于创建自定义的 User 实例。

```rust
pub fn load(filename: &str) -> Result<Self, std::io::Error> {
    let mut file = File::open(filename)?;
    let mut data = String::new();
    file.read_to_string(&mut data)?;
    let user = serde_json::from_str(&data)?;
    Ok(user)
}
```

- **功能**：从指定文件中加载 JSON 数据并反序列化为 User 实例。
- **参数**：filename: &str 表示文件路径。
- **返回值**：Result<Self, std::io::Error>，成功返回 User，失败返回 IO 错误。
- **实现步骤**：
  1. File::open(filename)?：打开指定文件，失败则返回错误（? 运算符传播错误）。
  2. let mut data = String::new()：创建空字符串用于存储文件内容。
  3. file.read_to_string(&mut data)?：将文件内容读取到 data 字符串中。
  4. serde_json::from_str(&data)?：将 JSON 字符串反序列化为 User 实例。
  5. Ok(user)：返回成功结果。
- **说明**：该方法实现了从文件到内存的反序列化，依赖 Serde 的 JSON 解析功能。错误处理使用 ? 运算符，简洁且符合 Rust 习惯。

```rust
pub fn persist(&self, filename: &str) -> Result<usize, std::io::Error> {
    let mut file = File::create(filename)?;

    // // ? eq
    // match File::create(filename) {
    //     Ok(f) => {
    //         todo!()
    //     }
    //     Err(e) => return Err(e),
    // }

    let data = serde_json::to_string(self)?;
    file.write_all(data.as_bytes())?;

    Ok(data.len())
}
```

- **功能**：将 User 实例序列化为 JSON 并写入指定文件。
- **参数**：filename: &str 表示目标文件路径。
- **返回值**：Result<usize, std::io::Error>，成功返回写入的字节数，失败返回 IO 错误。
- **实现步骤**：
  1. File::create(filename)?：创建或覆盖指定文件，失败则返回错误。
  2. serde_json::to_string(self)?：将 User 实例序列化为 JSON 字符串。
  3. file.write_all(data.as_bytes())?：将 JSON 字符串的字节写入文件。
  4. Ok(data.len())：返回写入的 JSON 字符串长度。
- **注释部分**：
  - 注释掉的 match 块展示了 ? 运算符的等价写法，说明 ? 是简化的错误处理方式。
  - todo!() 表示未实现，实际代码未使用此分支。
- **说明**：该方法实现了从内存到文件的序列化，核心是 Serde 的 JSON 序列化功能。返回 data.len() 提供额外信息（写入的字节数），增强方法实用性。

---

5. **实现 Default trait**

```rust
impl Default for User {
    fn default() -> Self {
        User::new("Unknown User".into(), 0, Gender::Unspecified)
    }
}
```

- **功能**：为 User 实现 Default trait，提供默认实例。
- **实现**：调用 User::new 创建一个默认 User，设置：
  - 姓名："Unknown User"（使用 into() 转换为 String）。
  - 年龄：0。
  - 性别：Gender::Unspecified。
- **说明**：Default trait 便于在需要默认值时快速创建 User 实例，常见于测试或初始化场景。

---

6. **测试模块**

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let user = User::default();
        let path = "/tmp/user1";
        user.persist(path).unwrap();
        let user1 = User::load(path).unwrap();
        assert_eq!(user, user1);
    }
}
```

- **功能**：测试 persist 和 load 方法的正确性。
- **实现**：
  1. let user = User::default()：创建默认 User 实例。
  2. let path = "/tmp/user1"：指定临时文件路径。
  3. user.persist(path).unwrap()：将 user 保存到文件，unwrap 假设无错误。
  4. let user1 = User::load(path).unwrap()：从文件加载 User 实例。
  5. assert_eq!(user, user1)：验证加载的 user1 与原始 user 相等。
- **属性**：#[cfg(test)] 确保测试模块仅在测试模式下编译。
- **说明**：测试验证了数据持久化的核心功能：保存到文件后加载的数据与原始数据一致。unwrap 用于简化测试，但在生产代码中应谨慎使用。

---

这段代码通过 Rust 和 Serde 实现了一个简单但完整的 JSON 文件持久化功能，展示了内存与 IO 设备间数据交换的核心流程。User 结构体的定义、persist 和 load 方法的实现，以及测试用例，共同构成了一个易于学习和扩展的示例。代码体现了 Rust 的安全性、高效性和 Serde 的灵活性，适合初学者学习数据持久化，也为进阶开发者提供了可复用的模板。

### 测试

```bash
training_code on  master [?] is 📦 0.1.0 via 🦀 1.71.0 via 🅒 base
➜ cargo test
   Compiling training_code v0.1.0 (/Users/qiaopengjun/Code/rust/training_code)
    Finished test [unoptimized + debuginfo] target(s) in 0.70s
     Running unittests src/lib.rs (target/debug/deps/training_code-c41752abc7a3994f)

running 1 test
test user::tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

   Doc-tests training_code

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s


training_code on  master [?] is 📦 0.1.0 via 🦀 1.71.0 via 🅒 base
➜
```

## 总结

通过这篇实战教程，我们用 Rust 和 Serde 完成了一个数据持久化的完整案例。从定义 User 数据结构到实现 JSON 序列化与文件读写，再到通过测试验证功能的正确性，整个过程清晰且实用。这个示例不仅展示了 Rust 在数据处理中的高效与安全，还为开发者提供了一个可复用的模板。无论是构建小型工具还是复杂应用，掌握数据持久化都是关键一步。希望这篇文章能激发你用 Rust 探索更多可能！

## 参考

- https://www.rust-lang.org/zh-CN
- https://course.rs/about-book.html
- https://lab.cs.tsinghua.edu.cn/rust/
- https://github.com/rustcn-org/async-book
