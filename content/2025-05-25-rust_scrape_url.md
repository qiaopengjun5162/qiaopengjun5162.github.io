+++
title = "Rust 编程入门实战：从零开始抓取网页并转换为 Markdown"
description = "Rust 编程入门实战：从零开始抓取网页并转换为 Markdown"
date = 2025-05-25T13:13:23Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust", "爬虫", "Markdown"]
+++

<!-- more -->

# Rust 编程入门实战：从零开始抓取网页并转换为 Markdown

Rust 作为一门以性能、安全和并发著称的现代编程语言，正逐渐成为开发者的新宠。本文将通过一个简单但实用的案例，带你走进 Rust 编程的世界：通过 HTTP 请求抓取 Rust 官网首页内容，并将其 HTML 转换为 Markdown 文件保存。这不仅能帮助你快速上手 Rust 项目开发，还能让你感受 Rust 的独特魅力！无论你是编程新手还是有经验的开发者，这篇文章都将为你打开 Rust 编程的大门。

本文详细介绍了一个基于 Rust 的网页抓取项目，通过 cargo 创建项目、添加 reqwest 和 html2md 依赖，实现从 Rust 官网获取 HTML 内容并转换为 Markdown 文件保存的功能。我们将逐步解析代码，展示 Rust 的项目管理、语法特点、错误处理以及命令行参数处理等核心概念。同时，通过代码示例和运行结果，带你体验 Rust 的强类型、类型推导和宏编程等特性。文章适合 Rust 初学者以及希望快速上手 Rust 开发的开发者阅读。

## 需求

通过 HTTP 请求 Rust 官网首页，然后把获得的 HTML 转换成 Markdown 保存起来。

## 实操

首先，我们用 cargo new scrape_url 生成一个新项目。默认情况下，这条命令会生成一个可执行项目 scrape_url，入口在 src/main.rs。

```bash
~/Code via 🅒 base
➜ mcd rust  # mkdir rust cd rust

~/Code/rust via 🅒 base
➜

~/Code/rust via 🅒 base
➜ cargo new scrape_url
     Created binary (application) `scrape_url` package

~/Code/rust via 🅒 base
➜ ls
scrape_url

~/Code/rust via 🅒 base
➜ cd scrape_url

scrape_url on  master [?] via 🦀 1.70.0 via 🅒 base
➜ c

scrape_url on  master [?] via 🦀 1.70.0 via 🅒 base
➜

```

我们在 Cargo.toml 文件里，加入如下的依赖：

Cargo.toml 是 Rust 项目的配置管理文件，它符合 toml 的语法。我们为这个项目添加了两个依赖：reqwest 和 html2md。reqwest 是一个 HTTP 客户端，它的使用方式和 Python 下的 request 类似；html2md 顾名思义，把 HTML 文本转换成 Markdown。

```toml
[package]
name = "scrape_url"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
reqwest ={ version = "0.11.18", features = ["blocking"] }
html2md = "0.2.14"

```

接下来，在 src/main.rs 里，我们为 main() 函数加入以下代码：

```rust
use std::fs;

fn main() {
    let url = "https://www.rust-lang.org/";
    let output = "rust.md";

    println!("Fetching url: {}", url);
    let body = reqwest::blocking::get(url).unwrap().text().unwrap();

    println!("Converting html to markdown...");
    let md = html2md::parse_html(&body);
    
    fs::write(output, md.as_bytes()).unwrap();
    println!("Converted markdown has been saved in {}", output);
}

```

保存后，在命令行下，进入这个项目的目录，运行 cargo run，在一段略微漫长的编译后，程序开始运行，在命令行下，你会看到如下的输出：

```bash
scrape_url on  master [?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base 
➜ cargo run           
   Compiling cfg-if v1.0.0
    ...
   Compiling hyper-tls v0.5.0
   Compiling reqwest v0.11.18
   Compiling scrape_url v0.1.0 (/Users/qiaopengjun/Code/rust/scrape_url)
    Finished dev [unoptimized + debuginfo] target(s) in 7.14s
     Running `target/debug/scrape_url`
Fetching url: https://www.rust-lang.org/
Converting html to markdown...
Converted markdown has been saved in rust.md

scrape_url on  master [?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base took 9.1s 
➜ 
```

并且，在当前目录下，一个 rust.md 文件被创建出来了。打开一看，其内容就是 Rust 官网主页的内容。

从这段并不长的代码中，我们可以感受到 Rust 的一些基本特点：

首先，Rust 使用名为 cargo 的工具来管理项目，它类似 Node.js 的 npm、Golang 的 go，用来做依赖管理以及开发过程中的任务管理，比如编译、运行、测试、代码格式化等等。

其次，Rust 的整体语法偏 C/C++ 风格。函数体用花括号 {} 包裹，表达式之间用分号 ; 分隔，访问结构体的成员函数或者变量使用点 . 运算符，而访问命名空间（namespace）或者对象的静态函数使用双冒号 :: 运算符。如果要简化对命名空间内部的函数或者数据类型的引用，可以使用 use 关键字，比如 use std::fs。此外，可执行体的入口函数是 main()。

另外，你也很容易看到，Rust 虽然是一门强类型语言，但编译器支持类型推导，这使得写代码时的直观感受和写脚本语言差不多。

最后，Rust 支持宏编程，很多基础的功能比如 println!() 都被封装成一个宏，便于开发者写出简洁的代码。

这里例子没有展现出来，但 Rust 还具备的其它特点有：

- Rust 的变量默认是不可变的，如果要修改变量的值，需要显式地使用 mut 关键字。
- 除了 let / static / const / fn 等少数语句外，Rust 绝大多数代码都是表达式（expression）。所以 if / while / for / loop 都会返回一个值，函数最后一个表达式就是函数的返回值，这和函数式编程语言一致。
- Rust 支持面向接口编程和泛型编程。
- Rust 有非常丰富的数据类型和强大的标准库。
- Rust 有非常丰富的控制流程，包括模式匹配（pattern match）。

<https://static001.geekbang.org/resource/image/15/cb/15e5152fe2b72794074cff40041722cb.jpg?wh=1920x1898>

如果想让错误传播，可以把所有的 unwrap() 换成 ? 操作符，并让 main() 函数返回一个 Result，如下所示：

```rust
use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let url = "https://www.rust-lang.org/";
    let output = "rust.md";

    println!("Fetching url: {}", url);
    let body = reqwest::blocking::get(url)?.text()?;

    println!("Converting html to markdown...");
    let md = html2md::parse_html(&body);
    
    fs::write(output, md.as_bytes())?;
    println!("Converted markdown has been saved in {}", output);

    Ok(())
}

```

从命令行参数中获取用户提供的信息来绑定 URL 和文件名

```rust
use std::env;
use std::fs;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();
    let url = &args[1];
    let output = &args[2];
    // let url = "https://www.rust-lang.org/";
    // let output = "rust.md";

    println!("Fetching url: {}", url);
    let body = reqwest::blocking::get(url)?.text()?;

    println!("Converting html to markdown...");
    let md = html2md::parse_html(&body);

    fs::write(output, md.as_bytes())?;
    println!("Converted markdown has been saved in {}", output);

    Ok(())
}

```

运行

```bash
scrape_url on  master [?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base 
➜ cargo run https://www.rust-lang.org/ rust1.md
   Compiling scrape_url v0.1.0 (/Users/qiaopengjun/Code/rust/scrape_url)
    Finished dev [unoptimized + debuginfo] target(s) in 1.48s
     Running `target/debug/scrape_url 'https://www.rust-lang.org/' rust1.md`
Fetching url: https://www.rust-lang.org/
Converting html to markdown...
Converted markdown has been saved in rust1.md

scrape_url on  master [?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base took 3.5s 
➜ 

```

## 总结

通过这个简单的网页抓取项目，我们初步领略了 Rust 编程的魅力：  

- Cargo 的便捷性：Rust 的包管理工具 cargo 让项目初始化、依赖管理和构建变得高效而简单。  
- 语法与特性：Rust 的 C/C++ 风格语法结合类型推导和宏编程，让代码既简洁又强大。  
- 错误处理：通过 unwrap() 和 ? 操作符，我们看到了 Rust 在错误处理上的灵活性和严谨性。  
- 扩展性：通过命令行参数的引入，代码具备了更高的灵活性和实用性。

这个项目只是 Rust 编程的冰山一角。Rust 还拥有强大的并发模型、丰富的标准库和模式匹配等特性，值得深入探索。如果你对 Rust 感兴趣，不妨继续尝试更复杂的项目，比如并发编程或构建 CLI 工具。欢迎关注我的微信公众号，获取更多 Rust 学习资源和实战案例！

## 参考

- <https://github.com/alloy-rs/examples/blob/main/examples/providers/examples/ws.rs>
- <https://github.com/watchexec/cargo-watch>
- <https://www.rust-lang.org/zh-CN>
- <https://course.rs/about-book.html>
- <https://doc.rust-lang.org/nomicon/>
