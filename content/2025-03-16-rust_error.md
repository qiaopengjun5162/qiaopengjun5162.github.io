+++
title = "Rust 错误处理详解：掌握 anyhow、thiserror 和 snafu"
description = "Rust 错误处理详解：掌握 anyhow、thiserror 和 snafu"
date = 2025-03-16 21:40:52+08:00
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]

+++

<!-- more -->

# Rust 错误处理详解：掌握 anyhow、thiserror 和 snafu
错误处理是 Rust 开发中不可或缺的一部分。Rust 的 Result<T, E> 提供了基础支持，但具体实现却因场景而异。本文将介绍三种常用的错误处理工具——anyhow、thiserror 和 snafu，分析它们的特点和适用场景，并通过实战示例帮你理解如何在项目中使用它们。无论你是开发应用还是编写库，这里都能为你提供参考。

本文深入探讨 Rust 错误处理中的三大工具：anyhow 适合快速统一错误处理，适用于应用开发；thiserror 支持自定义错误类型，适合库的开发；snafu 提供上下文驱动的错误管理，适用于复杂系统。通过对比它们的优劣和实际代码演示，我们将展示如何根据项目需求选择合适的工具，并提供项目搭建步骤和示例代码，助你在 Rust 中更好地处理错误。
## Rust 错误处理

### 错误处理：`anyhow`、`thiserror`、`snafu`

- `anyhow`：统一、简单的错误处理，适用于应用程序级别
- `thiserror`：自定义、丰富的错误处理，适用于库级别
- `snafu`：更细粒度的管理错误

**注意：开发中需要注意 `Result<T, E>` 的大小**

### `anyhow` Error ：应用程序级错误处理

`anyhow` Error 的转换与统一错误处理

- 提供统一的 `anyhow::Error` 类型，支持任意实现 `std::error::Error` 的错误类型

- 通过 `?` 操作符自动传播错误，简化多层嵌套错误处理

- 支持添加动态上下文（`context()` 方法），提升错误可读性

```rust
fn get_cluster_info() -> Result<ClusterMap, anyhow::Error> {  // 错误3 Err3
  let config = std::fs::read_to_string("cluster.json")?; 			// 错误1 Err1
  // let config = std::fs::read_to_string("cluster.json").context("...")?; 			// 错误1 Err1
  let map: ClusterMap = serde_json::from_str(&config)?;  			// 错误2 Err2
  Ok(map)
}

struct Err1 {...}
struct Err2 {...}

match ret {
  Ok(v) => v,
  Err(e) => return Err(e.into)
}

Err1 => Err3: impl From<Err1> for Err3
Err2 => Err3: impl From<Err2> for Err3

impl From<Err1> for Err3 {
  fn from(v: Err1) -> Err3 {
    ...
  }
}
```

### `thiserror`Error：库级错误定义

- 通过宏自动生成符合 `std::error::Error` 的错误类型
- 支持嵌套错误源（`#[from]` 属性）和结构化错误信息
- 允许自定义错误消息模板（如 `#[error("Invalid header: {expected}")]`）

https://doc.rust-lang.org/beta/core/error/trait.Error.html

因为 `Error` trait 实现了 `Debug` 和 `Display` Trait

```rust
pub trait Error: Debug + Display {
```

所以，可以这样打印：

```rust
Error -> println("{}/{:?}", err)
```

### `snafu` Error ： 上下文驱动的错误管理

- 通过 `Snafu` 宏将底层错误转换为领域特定错误
- 支持在错误链中附加结构化上下文（如文件路径、输入参数）
- 提供 `ensure!` 宏简化条件检查与错误抛出

### `thiserror` vs `snafu` 

更多请参考：https://github.com/kube-rs/kube/discussions/453

### 对比与选型指南

| **维度**       | `anyhow`             | `thiserror`          | `snafu`                |
| -------------- | -------------------- | -------------------- | ---------------------- |
| **错误类型**   | 统一动态类型         | 静态自定义类型       | 领域驱动类型           |
| **上下文支持** | 动态字符串           | 结构体字段           | 结构化字段+动态模板    |
| **适用阶段**   | 应用开发（快速迭代） | 库开发（稳定接口）   | 复杂系统（可维护性）   |
| **学习曲线**   | 低（无需预定义类型） | 中（需设计错误结构） | 高（需理解上下文模型） |
| **典型用户**   | 前端开发者/脚本工具  | 框架开发者           | 基础设施工程师         |

## 实操

### 根据模版创建并生成项目`rust-ecosystem-learning`

```bash
cargo generate --git git@github.com:qiaopengjun5162/rust-template.git
cd rust-ecosystem-learning
code .
```

### 项目目录结构

```bash
rust-ecosystem-learning on  main [!] is 📦 0.1.0 via 🦀 1.85.0 via 🅒 base 
➜ tree . -L 6 -I 'target|coverage|coverage_report|node_modules'                                


.
├── CHANGELOG.md
├── CONTRIBUTING.md
├── Cargo.lock
├── Cargo.toml
├── LICENSE
├── README.md
├── _typos.toml
├── cliff.toml
├── deny.toml
├── docs
└── src
    ├── error.rs
    ├── lib.rs
    └── main.rs

3 directories, 12 files

```

### 添加依赖

```bash
cargo add anyhow     
cargo add thiserror   
cargo add serde_json
```

### `main.rs` 文件

```rust
use anyhow::Context;
use rust_ecosystem_learning::MyError;
use std::fs;

fn main() -> Result<(), anyhow::Error> {
    println!("size of anyhow::Error: {}", size_of::<anyhow::Error>());
    println!("size of std::io::Error: {}", size_of::<std::io::Error>());
    println!(
        "size of std::num::ParseIntError: {}",
        size_of::<std::num::ParseIntError>()
    );
    println!(
        "size of serde_json::Error: {}",
        size_of::<serde_json::Error>()
    );
    println!("size of string: {}", size_of::<String>());
    println!("size of MyError: {}", size_of::<MyError>());

    let filename = "non_existent_file.txt";
    let _fd =
        fs::File::open(filename).with_context(|| format!("Can not find file: {}", filename))?;

    fail_with_error()?;
    Ok(())
}

fn fail_with_error() -> Result<(), MyError> {
    Err(MyError::Custom("This is a custom error".to_string()))
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}

```

### `lib.rs` 文件

```rust
mod error;

pub use error::MyError;
```

### `error.rs` 文件

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum MyError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Parse error: {0}")]
    Parse(#[from] std::num::ParseIntError),
    #[error("Serialize json error: {0}")]
    Serialize(#[from] serde_json::Error),
    // #[error("Error: {a}, {b:?}, {c:?}, {d:?}")]
    // BigError {
    //     a: String,
    //     b: Vec<String>,
    //     c: [u8; 64],
    //     d: u64,
    // },
    #[error("Error: {0:?}")]
    BigError(Box<BigError>),

    #[error("An error occurred: {0}")]
    Custom(String),
}

#[derive(Debug)]
pub struct BigError {
    pub a: String,
    pub b: Vec<String>,
    pub c: [u8; 64],
    pub d: u64,
}

```

### `Cargo.toml` 文件

```toml
[package]
name = "rust-ecosystem-learning"
version = "0.1.0"
edition = "2021"
license = "MIT"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
anyhow = "1.0.97"
serde = { version = "1.0.217", features = ["derive"] }
serde_json = "1.0.140"
thiserror = "2.0.11"

```

### 运行

```bash
rust-ecosystem-learning on  main [!] is 📦 0.1.0 via 🦀 1.85.0 via 🅒 base took 2.9s 
➜ cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.02s
     Running `target/debug/rust-ecosystem-learning`
size of anyhow::Error: 8
size of std::io::Error: 8
size of std::num::ParseIntError: 1
size of serde_json::Error: 8
size of string: 24
size of MyError: 24
Error: Can not find file: non_existent_file.txt

Caused by:
    No such file or directory (os error 2)
```

## 总结
Rust 的错误处理工具各有侧重：anyhow 简单高效，适合应用开发；thiserror 结构清晰，适合库设计；snafu 上下文丰富，适合复杂场景。通过本文的分析和实战，你可以根据实际需求选择合适的错误处理方案。合理的错误处理能让代码更健壮，动手实践起来，提升你的 Rust 项目质量吧！

## 参考

- https://github.com/dtolnay/anyhow
- https://github.com/dtolnay/thiserror
- https://github.com/kube-rs/kube/discussions/453
- https://doc.rust-lang.org/beta/core/error/trait.Error.html
- https://docs.rs/snafu/latest/snafu/
