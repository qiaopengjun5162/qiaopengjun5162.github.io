+++
title = "用 Rust 打造命令行利器：从零到一实现 mini-grep"
description = "用 Rust 打造命令行利器：从零到一实现 mini-grep"
date = 2025-06-02T02:21:41Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 用 Rust 打造命令行利器：从零到一实现 mini-grep

在开发中，命令行工具以其高效和灵活深受开发者喜爱。本文通过一个 Rust 实现的 mini-grep 项目，带你从零开始学习如何构建一个功能强大的命令行程序。从接收参数、读取文件到模块化重构、TDD 开发和错误处理，这篇教程将为你揭开 Rust 在命令行开发中的魅力，助你快速上手！

本文详细介绍了使用 Rust 开发命令行工具 mini-grep 的完整过程，涵盖以下核心内容：  

- 接收和解析命令行参数，实现基本的搜索功能；  
- 读取文件内容并输出匹配结果；  
- 通过模块化和错误处理优化代码结构；  
- 引入 TDD（测试驱动开发）确保代码健壮性；  
- 使用环境变量支持大小写敏感搜索；  
- 将错误信息输出到标准错误，提升用户体验。

通过逐步重构和代码示例，你将掌握 Rust 的核心特性和命令行程序开发的实用技巧。

## 一、实例：接收命令行参数

### 本文内容

- 1 接收命令行参数
- 2 读取文件
- 3 重构：改进模块和错误处理
- 4 使用 TDD（测试驱动开发）开发库功能
- 5 使用环境变量
- 6 将错误消息写入标准错误而不是标准输出

### 创建项目

```rust
~/rust
➜ cargo new minigrep
     Created binary (application) `minigrep` package

~/rust
➜ cd minigrep


minigrep on  master [?] via 🦀 1.67.1
➜ c // code .

minigrep on  master [?] via 🦀 1.67.1
➜

```

### main.rs 文件

```rust
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();

    // env::args_os() // OsString
    // println!("{:?}", args);

    let query = &args[1];
    let filename = &args[2];

    println!("Search for {}", query);
    println!("In file {}", filename);
}

```

### 运行

```bash
minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ cargo run
   Compiling minigrep v0.1.0 (/Users/qiaopengjun/rust/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.17s
     Running `target/debug/minigrep`
["target/debug/minigrep"]

minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ 

minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ cargo run 1234 abcd
    Finished dev [unoptimized + debuginfo] target(s) in 0.02s
     Running `target/debug/minigrep 1234 abcd`
["target/debug/minigrep", "1234", "abcd"]

minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 took 2.3s 
➜ 

minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 took 2.3s 
➜ cargo run abcd readme.txt
   Compiling minigrep v0.1.0 (/Users/qiaopengjun/rust/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.39s
     Running `target/debug/minigrep abcd readme.txt`
Search for abcd
In file readme.txt

minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 took 2.4s 
➜ 
```

## 二、实例：读取文件

### src/main.rs 文件

```rust
use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();

    // env::args_os() // OsString
    // println!("{:?}", args);

    let query = &args[1];
    let filename = &args[2];

    println!("Search for {}", query);
    println!("In file {}", filename);

    let contents = fs::read_to_string(filename)
    .expect("Something went wrong reading the file");

    println!("With text:\n{}", contents);
}

```

### poem.txt 文件

```rust
I'm nobody! Who are you?
Are you nobody, too?
Then there's a pair of us - don't tell!
They'd banish us, you know.

How dreary to be somebody!
How public, like a frog
To tell your name the livelong day
To an admiring bog!

```

### 运行

```bash
minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ cargo run the poem.txt   
   Compiling minigrep v0.1.0 (/Users/qiaopengjun/rust/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.41s
     Running `target/debug/minigrep the poem.txt`
Search for the
In file poem.txt
With text:
I'm nobody! Who are you?
Are you nobody, too?
Then there's a pair of us - don't tell!
They'd banish us, you know.

How dreary to be somebody!
How public, like a frog
To tell your name the livelong day
To an admiring bog!


minigrep on  master [?] is 📦 0.1.0 via 🦀 
```

## 三、实例：重构（上：改善模块化）

### 二进制程序关注点分离的指导性原则

- 将程序拆分为 main.rs 和 lib.rs ，将业务逻辑放入 lib.rs
- 当命令行解析逻辑较少时，将它放在 main.rs 也行
- 当命令行解析逻辑变复杂时，需要将它从 main.rs 提取到 lib.rs

### 经过上述拆分，留在 main 的功能有

- 使用参数值调用命令行解析逻辑
- 进行其它配置
- 调用 lib.rs 中的 run 函数
- 处理 run 函数可能出现的错误

### 优化一

```rust
use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();
    let (_query, filename) = parse_config(&args);
    let contents = fs::read_to_string(filename).expect("Something went wrong reading the file");
    println!("With text:\n{}", contents);
}

fn parse_config(args: &[String]) -> (&str, &str) {
    let query = &args[1];
    let filename = &args[2];

    (query, filename)
}

```

### 优化二

```rust
use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();
    let config = parse_config(&args);
    let contents = fs::read_to_string(config.filename).expect("Something went wrong reading the file");
    println!("With text:\n{}", contents);
    println!("query: {:?}", config.query)
}

struct Config {
    query: String,
    filename: String,
}

fn parse_config(args: &[String]) -> Config  {
    let query = args[1].clone();
    let filename = args[2].clone();

    Config { query, filename }
}

```

### 优化三

```rust
use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();
    let config = Config::new(&args);
    let contents =
        fs::read_to_string(config.filename).expect("Something went wrong reading the file");
    println!("With text:\n{}", contents);
    println!("query: {:?}", config.query)
}

struct Config {
    query: String,
    filename: String,
}

impl Config {
    fn new(args: &[String]) -> Config {
        let query = args[1].clone();
        let filename = args[2].clone();

        Config { query, filename }
    }
}

```

## 四、实例：重构（中：错误处理）

### 错误信息

```bash
minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ cargo run             
   Compiling minigrep v0.1.0 (/Users/qiaopengjun/rust/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.11s
     Running `target/debug/minigrep`
thread 'main' panicked at 'index out of bounds: the len is 1 but the index is 1', src/main.rs:20:21
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace

minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ 
```

### 优化一

```rust
use std::env;
use std::fs;

fn main() {
    let args: Vec<String> = env::args().collect();
    let config = Config::new(&args);
    let contents =
        fs::read_to_string(config.filename).expect("Something went wrong reading the file");
    println!("With text:\n{}", contents);
    println!("query: {:?}", config.query)
}

struct Config {
    query: String,
    filename: String,
}

impl Config {
    fn new(args: &[String]) -> Config {
        if args.len() < 3 {
            panic!("not enough arguments");
        }
        let query = args[1].clone();
        let filename = args[2].clone();

        Config { query, filename }
    }
}

```

### 优化二

```rust
use std::env;
use std::fs;
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();
    let config = Config::new(&args).unwrap_or_else(|err| {
        println!("Problem parsing arguments: {}", err);
        process::exit(1);
    });
    let contents =
        fs::read_to_string(config.filename).expect("Something went wrong reading the file");
    println!("With text:\n{}", contents);
    println!("query: {:?}", config.query)
}

struct Config {
    query: String,
    filename: String,
}

impl Config {
    fn new(args: &[String]) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("not enough arguments");
        }
        let query = args[1].clone();
        let filename = args[2].clone();

        Ok(Config { query, filename })
    }
}

```

## 五、实例：重构（下：将业务逻辑移至 lib.rs）

### 优化一

```rust
use std::env;
use std::fs;
use std::process;
use std::error::Error;

fn main() {
    let args: Vec<String> = env::args().collect();
    let config = Config::new(&args).unwrap_or_else(|err| {
        println!("Problem parsing arguments: {}", err);
        process::exit(1);
    });
    if let Err(e) = run(config) {
        println!("Application error: {}", e);
        process::exit(1);
    }
}

fn run(config: Config) -> Result<(), Box<dyn Error>> {
    let contents =
    fs::read_to_string(config.filename)?;
    println!("With text:\n{}", contents);
    println!("query: {:?}", config.query);
    Ok(())
}

struct Config {
    query: String,
    filename: String,
}

impl Config {
    fn new(args: &[String]) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("not enough arguments");
        }
        let query = args[1].clone();
        let filename = args[2].clone();

        Ok(Config { query, filename })
    }
}

```

### 迁移 模块化

### src/mian.rs 文件

```rust
use minigrep::Config;
use std::env;
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();
    let config = Config::new(&args).unwrap_or_else(|err| {
        println!("Problem parsing arguments: {}", err);
        process::exit(1);
    });
    if let Err(e) = minigrep::run(config) {
        println!("Application error: {}", e);
        process::exit(1);
    }
}

```

### src/lib.rs 文件

```rust
use std::error::Error;
use std::fs;

pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
    let contents = fs::read_to_string(config.filename)?;
    println!("With text:\n{}", contents);
    println!("query: {:?}", config.query);
    Ok(())
}

pub struct Config {
    pub query: String,
    pub filename: String,
}

impl Config {
    pub fn new(args: &[String]) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("not enough arguments");
        }
        let query = args[1].clone();
        let filename = args[2].clone();

        Ok(Config { query, filename })
    }
}

```

## 六、使用 TDD（测试驱动开发）编写库功能

### 测试驱动开发 TDD（Test-Driven Development）

- 编写一个会失败的测试，运行该测试，确保它是按照预期的原因失败
- 编写或修改刚好足够的代码，让新测试通过
- 重构刚刚添加或修改的代码，确保测试会始终通过
- 返回步骤 1 ，继续

### src/lib.rs 文件

```rust
use std::error::Error;
use std::fs;

pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
    let contents = fs::read_to_string(config.filename)?;
    for line in search(&config.query, &contents) {
        println!("line: {}", line);
    }
    // println!("With text:\n{}", contents);
    // println!("query: {:?}", config.query);
    Ok(())
}

pub struct Config {
    pub query: String,
    pub filename: String,
}

impl Config {
    pub fn new(args: &[String]) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("not enough arguments");
        }
        let query = args[1].clone();
        let filename = args[2].clone();

        Ok(Config { query, filename })
    }
}

pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    let mut results = Vec::new();

    for line in contents.lines() {
        if line.contains(query) {
            results.push(line);
        }
    }

    results
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn one_result() {
        let query = "duct";
        let contents = "\
Rust:
safe, fast, productive.
Pick three.";

        assert_eq!(vec!["safe, fast, productive."], search(query, contents))
    }
}

```

### 运行

```bash
minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ cargo run frog poem.txt
   Compiling minigrep v0.1.0 (/Users/qiaopengjun/rust/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.18s
     Running `target/debug/minigrep frog poem.txt`
line: How public, like a frog

minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ cargo run body poem.txt
    Finished dev [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/minigrep body poem.txt`
line: I'm nobody! Who are you?
line: Are you nobody, too?
line: How dreary to be somebody!

minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ cargo run 123 poem.txt 
    Finished dev [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/minigrep 123 poem.txt`

minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ 
```

## 七、实例：使用环境变量

### src/lib.rs 文件

```rust
use std::error::Error;
use std::fs;
use std::env;

pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
    let contents = fs::read_to_string(config.filename)?;
    let results = if config.case_sensitive {
        search(&config.query,  &contents)
    } else {
        search_case_insensitive(&config.query, &contents)
    };
    for line in results {
        println!("line: {}", line);
    }
    // println!("With text:\n{}", contents);
    // println!("query: {:?}", config.query);
    Ok(())
}

pub struct Config {
    pub query: String,
    pub filename: String,
    pub case_sensitive: bool,
}

impl Config {
    pub fn new(args: &[String]) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("not enough arguments");
        }
        let query = args[1].clone();
        let filename = args[2].clone();
        let case_sensitive = env::var("CASE_INSENSITIVE").is_err();
        Ok(Config { query, filename, case_sensitive })
    }
}

pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    let mut results = Vec::new();

    for line in contents.lines() {
        if line.contains(query) {
            results.push(line);
        }
    }

    results
}

pub fn search_case_insensitive<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    let mut results = Vec::new();
    let query = query.to_lowercase();

    for line in contents.lines() {
        if line.to_lowercase().contains(&query) {
            results.push(line);
        }
    }

    results
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
//     fn one_result() {
//         let query = "duct";
//         let contents = "\
// Rust:
// safe, fast, productive.
// Pick three.";

//         assert_eq!(vec!["safe, fast, productive."], search(query, contents))
//     }

    fn case_sensitive() {
        let query = "duct";
        let contents = "\
Rust:
safe, fast, productive.
Pick three.
Duct tape.";

        assert_eq!(vec!["safe, fast, productive."], search(query, contents))
    }

    #[test]
    fn case_insensitive() {
        let query = "rUsT";
        let contents = "\
Rust:
safe, fase, productive.
Pick three.
Trust me.";

        assert_eq!(vec!["Rust:", "Trust me."], search_case_insensitive(query, contents))
    }
}

```

### 运行

```bash
minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ cargo run to poem.txt 
   Compiling minigrep v0.1.0 (/Users/qiaopengjun/rust/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.40s
     Running `target/debug/minigrep to poem.txt`
line: Are you nobody, too?
line: How dreary to be somebody!

minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ CASE_INSENSITIVE=1 cargo run to poem.txt
    Finished dev [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/minigrep to poem.txt`
line: Are you nobody, too?
line: How dreary to be somebody!
line: To tell your name the livelong day
line: To an admiring bog!

minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ 

```

## 八、实例：将错误信息输出到标准错误

标准输出 VS 标准错误

- 标准输出：stdout
  - println!
- 标准错误：stderr
  - eprintln!

### src/main.rs 文件

```rust
use minigrep::Config;
use std::env;
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();
    let config = Config::new(&args).unwrap_or_else(|err| {
        eprintln!("Problem parsing arguments: {}", err);
        process::exit(1);
    });
    if let Err(e) = minigrep::run(config) {
        eprintln!("Application error: {}", e);
        process::exit(1);
    }
}

```

### 运行

```bash
minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ cargo run > output.txt
   Compiling minigrep v0.1.0 (/Users/qiaopengjun/rust/minigrep)
    Finished dev [unoptimized + debuginfo] target(s) in 0.14s
     Running `target/debug/minigrep`
Problem parsing arguments: not enough arguments

minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ cargo run to poem.txt > output.txt 
    Finished dev [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/minigrep to poem.txt`

minigrep on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ 
```

## 总结

通过 mini-grep 项目，我们不仅实现了一个功能完备的命令行工具，还深入探索了 Rust 的模块化、错误处理和测试驱动开发等特性。从简单的参数解析到复杂的功能实现，Rust 的安全性和性能优势得到了充分体现。无论你是 Rust 新手还是有一定经验的开发者，这个项目都能帮助你加深对 Rust 的理解，并为开发更复杂的命令行工具打下坚实基础。快动手试试，打造属于你的命令行利器吧！

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://course.rs/about-book.html>
- <https://lab.cs.tsinghua.edu.cn/rust/>
