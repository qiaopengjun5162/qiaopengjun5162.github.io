+++
title = "bacon 点燃 Rust：比 cargo-watch 更爽的开发体验"
description = "bacon 点燃 Rust：比 cargo-watch 更爽的开发体验"
date = 2025-06-13T00:48:23Z
[taxonomies]
categories = ["Rust"]
tags = ["bacon", "cargo-watch", "Rust"]
+++

<!-- more -->

# bacon 点燃 Rust：比 cargo-watch 更爽的开发体验

Rust 开发追求效率与极致体验，但频繁手动运行代码和测试总让人抓狂！cargo-watch 早已是 Rust 开发者的老朋友，而 bacon 横空出世，带来比 cargo-watch 更爽的自动化监控与测试体验。本文通过一个实战项目，带你解锁 bacon 与 cargo-watch 的完美配合，搭配自定义命令，让你的 Rust 开发如火箭般“点燃”！准备好体验开发新姿势了吗？

本文通过一个名为 rust-bacon 的实战项目，详细展示如何用 `cargo-watch` 和 `bacon` 加速 Rust 开发。内容涵盖项目初始化、依赖配置、示例代码运行、测试自动化，以及自定义 bre 和 bt 命令的技巧。`cargo-watch` 实时监控代码变更，`bacon` 则以更智能的方式优化测试流程，二者结合让开发体验飞跃。无论你是 Rust 新手还是老兵，这篇教程都能让你开发效率翻倍！

## 实操

### 创建项目并初始化

```bash
cargo new rust-bacon
    Creating binary (application) `rust-bacon` package
note: see more `Cargo.toml` keys and their definitions at *******************************************************
```

### 切换到项目目录并用 cursor 打开项目

```bash
cd rust-bacon
cc # open -a cursor .
```

### 创建并切换到 examples 目录

```bash
RustJourney/rust-bacon on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ mcd examples  # mkdir examples && cd examples   
/Users/qiaopengjun/Code/Rust/RustJourney/rust-bacon/examples
```

### 添加依赖

```bash
RustJourney/rust-bacon/examples on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo add mlua                           
```

### 查看项目目录结构

```bash
RustJourney/rust-bacon on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 19.9s 
➜ tree . -L 6 -I "coverage_report|lib|.vscode|out|lcov.info|target|node_modules"
.
├── Cargo.lock
├── Cargo.toml
├── examples
│   └── simple.rs
├── src
│   └── main.rs
└── tests
    └── tests_p_simple.rs

4 directories, 5 files

```

### Cargo.toml 文件

```ts
[package]
name = "rust-bacon"
version = "0.1.0"
edition = "2024"

[dependencies]
mlua = { version = "0.10.5", features = ["lua54", "vendored"] }


[dev-dependencies]
reqwest = { version = "0.12.20", features = ["json"] }
tokio = { version = "1.45.1", features = ["full"] }

```

### examples/simple.rs 文件

```rust
use mlua::{Lua, Value};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let lua = Lua::new();

    // -- Load
    let chunk = lua.load(
        r#"
        local num = 123
        print("Hello, from Lua! " .. num)
        return num +  1
    "#,
    );

    // -- Execute
    // let result = chunk.exec::<i64>()?;
    // println!("Result: {}", result);

    // -- Eval
    let result = chunk.eval::<Value>()?;
    println!("Result: --> {:?}", result);

    Ok(())
}


```

### 编译构建

```bash
RustJourney/rust-bacon on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo build                  
   Compiling rust-bacon v0.1.0 (/Users/qiaopengjun/Code/Rust/RustJourney/rust-bacon)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.23s

RustJourney/rust-bacon on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo build
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.03s

```

### 安装 `cargo-watch`

```bash
cargo install cargo-watch --locked
```

### cargo watch 运行示例代码

使用 `cargo-watch` 工具监控代码变化并自动运行指定的 Cargo 示例（example）

```bash
RustJourney/rust-bacon/examples on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 1m 15.8s 
➜ cargo watch -c -q -x "run -q --example simple"     
```

#### 命令解析

#### **`cargo watch -c -q -x "run -q --example simple"`**

|           部分            |                作用                 |
| :-----------------------: | :---------------------------------: |
|       `cargo watch`       |    监控文件变化的工具（需安装）     |
|           `-c`            |          清屏后再执行命令           |
|           `-q`            |     安静模式（不显示监控日志）      |
|           `-x`            |          指定要运行的命令           |
| `run -q --example simple` | 安静模式下运行 `examples/simple.rs` |

等效于：每当项目文件变动时，自动执行 `cargo run --example simple`

### `cargo add`和 `cargo install`**关键区别**

|      特性       |    `cargo add`    | `cargo install`  |
| :-------------: | :---------------: | :--------------: |
|  **作用范围**   |     当前项目      |     全局安装     |
|  **修改文件**   | 更新 `Cargo.toml` |  不修改项目文件  |
|  **安装目标**   |     库/依赖项     |    可执行程序    |
| `--locked` 用途 |      不适用       | 确保依赖版本锁定 |

### 安装 bacon

```bash
RustJourney/rust-bacon on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 6.4s 
➜ cargo install --locked bacon 
```

### Bacon 运行示例代码

Bacon 监视 Rust 项目文件变化，并在变化时以静默模式运行名为 simple 的示例测试。

```bashg
RustJourney/rust-bacon on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 1m 11.9s 
➜ bacon run -- -q --example simple
```

![image-20250612105331447](/images/image-20250612105331447.png)

### 小技巧：设置 bre 快捷命令

在 ~/.zshrc 中添加以下代码：

```sh
# sh/zsh function - bacon run example 
# usage `bre xp_file_name`
function bre() {
    bacon run -- -q --example $1
}
```

通过在 ~/.zshrc 中定义 bre 函数，创建了一个便捷的命令，用于在 Rust 项目中以静默模式运行指定示例的测试，简化了使用 Bacon 的工作流程。

![image-20250612110014783](/images/image-20250612110014783.png)

运行示例：

```bash
RustJourney/rust-bacon on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ bre simple  
```

### 测试代码 tests_p_simple.rs

```rust
use reqwest::Client;

type Result<T> = core::result::Result<T, Box<dyn std::error::Error>>;

#[tokio::test]
async fn test_simple() -> Result<()> {
    let client = Client::new(); // Create a new client

    let response = client.get("https://httpbin.org/get").send().await?; // Send a GET request to the URL

    assert_eq!(response.status(), 200); // Check that the response status is 200
    assert_eq!(
        response.text().await?,
        "{\"headers\":{\"Accept\":\"*/*\",\"User-Agent\":\"reqwest\"}}"
    );

    Ok(())
}

#[tokio::test]
async fn test_simple_with_headers() -> Result<()> {
    let client = Client::new(); // Create a new client

    let response = client
        .get("https://v1.hitokoto.cn/")
        .header("Accept", "application/json")
        .send()
        .await?; // Send a GET request to the URL with a custom header

    assert_eq!(response.status(), 200); // Check that the response status is 200
    println!("{}", response.text().await?); // Print the response body
    Ok(())
}


```

### 使用 `cargo test` 运行测试

```bash
RustJourney/rust-bacon/tests on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 14.6s 
➜ cargo test --test tests_p_simple test_simple      
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.17s
     Running tests/tests_p_simple.rs (/Users/qiaopengjun/Code/Rust/RustJourney/rust-bacon/target/debug/deps/tests_p_simple-a7daca0f722d0ca6)

running 1 test
test test_simple ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 1.52s

RustJourney/rust-bacon/tests on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo test --test tests_p_simple            
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.18s
     Running tests/tests_p_simple.rs (/Users/qiaopengjun/Code/Rust/RustJourney/rust-bacon/target/debug/deps/tests_p_simple-a7daca0f722d0ca6)

running 1 test
test test_simple ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 2.41s


```

### 使用`cargo nextest` 运行测试

```bash
RustJourney/rust-bacon on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo nextest run 
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.08s
────────────
 Nextest run ID 461d65d9-1af7-4759-872f-1dde9dad6de9 with nextest profile: default
    Starting 1 test across 2 binaries
        PASS [   1.325s] rust-bacon::tests_p_simple test_simple
────────────
     Summary [   1.325s] 1 test run: 1 passed, 0 skipped

RustJourney/rust-bacon on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ cargo nextest run test_simple
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.10s
────────────
 Nextest run ID d9bbac85-4268-4e7b-a111-d7bed1818de9 with nextest profile: default
    Starting 1 test across 2 binaries
        PASS [   1.377s] rust-bacon::tests_p_simple test_simple
────────────
     Summary [   1.378s] 1 test run: 1 passed, 0 skipped

```

### 使用 `cargo watch test` 运行测试

#### 运行测试方式一

```bash
RustJourney/rust-bacon/tests on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 3.6s 
➜ cargo watch test test_p_simple
[Running 'cargo test test_p_simple']
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.07s
     Running unittests src/main.rs (target/debug/deps/rust_bacon-4dd54cf859ff75e4)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

     Running tests/tests_p_simple.rs (target/debug/deps/tests_p_simple-a7daca0f722d0ca6)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 1 filtered out; finished in 0.00s

[Finished running. Exit status: 0]

```

#### 运行测试方式二

```bash
RustJourney/rust-bacon/tests on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 14.0s 
➜ cargo watch test --test tests_p_simple test_simple  
[Running 'cargo test --test tests_p_simple test_simple']
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.09s
     Running tests/tests_p_simple.rs (target/debug/deps/tests_p_simple-a7daca0f722d0ca6)

running 1 test
test test_simple ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 1.67s

[Finished running. Exit status: 0]
```

### 使用 `bacon test` 运行测试

#### 指定测试方法进行测试

运行 Bacon 工具，监视 Rust 项目并以静默模式执行名为 test_simple 的测试。

```bash
RustJourney/rust-bacon on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) 
➜ bacon test -- test_simple      
```

![image-20250612112955370](/images/image-20250612112955370.png)

#### 明确指定测试文件中测试方法进行测试

运行 Bacon 工具，监视 Rust 项目并以静默模式执行 tests_p_simple.rs 测试文件中名为 test_simple_with_headers 的测试方法。

```bash
RustJourney/rust-bacon on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 47.9s 
➜ bacon test -- --test tests_p_simple test_simple_with_headers
```

![image-20250612113214272](/images/image-20250612113214272.png)

#### 明确指定测试文件中测试方法进行测试并显示打印输出

运行 Bacon 工具，监视 Rust 项目并执行 tests_p_simple.rs 测试文件中名为 test_simple_with_headers 的测试方法，同时显示测试中的标准输出（--nocapture）。

```bash
RustJourney/rust-bacon on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 6m 2.5s 
➜ bacon test -- --test tests_p_simple test_simple_with_headers -- --nocapture
```

![image-20250612114318019](/images/image-20250612114318019.png)

### 小技巧：设置`bt`快捷命令

- 编辑 ~/.zshrc：运行 vim ~/.zshrc 将 bt 函数代码添加或更新。
- 保存后运行 source ~/.zshrc 使函数生效。

```bash
vim ~/.zshrc

source ~/.zshrc
```

bt 函数简化 Bacon 测试命令，支持运行特定测试方法（bt test_my_fn）、特定测试文件和方法（bt test_file_name test_my_fn），或所有测试（bt），并始终启用 --nocapture 显示标准输出。

```sh
# zsh/sh function
# - `bt test_my_fn` for a test function name match
# - `bt test_file_name test_my_fn`
function bt() {
    if [[ $# -eq 1 ]]; then
        bacon test -- $1 -- --nocapture
    elif [[ $# -eq 2 ]]; then
        bacon test -- --test $1 $2 -- --nocapture
    else
        bacon test -- -- --nocapture
    fi
}
```

![image-20250612114523149](/images/image-20250612114523149.png)

#### 验证测试命令

运行 `bt tests_p_simple test_simple_with_headers` 或 `bt test_my_fn`，`检查是否正确执行并显示 println! 输出。

```bash
RustJourney/rust-bacon on  main [?] is 📦 0.1.0 via 🦀 1.89.0 on 🐳 v28.2.2 (orbstack) took 17.9s 
➜ bt tests_p_simple test_simple_with_headers           
```

## 总结

`bacon` 点燃了 Rust 开发的无限可能！它不仅继承了 `cargo-watch` 的实时监控优势，还以更智能的测试自动化和简洁的工作流，带来远超预期的开发体验。通过本文的实战演练和自定义命令（如 bre 和 bt），你已掌握让 Rust 项目飞速运行的秘诀。快用 `bacon` 和 `cargo-watch` 点燃你的代码，体验比以往更爽的 Rust 开发之旅！

## 参考

- <https://crates.io/crates/bacon>
- <https://crates.io/crates/cargo-watch>
- <https://github.com/watchexec/cargo-watch>
- <https://github.com/mlua-rs/mlua>
- <https://docs.rs/mlua/latest/mlua/>
- <https://nexte.st/>
