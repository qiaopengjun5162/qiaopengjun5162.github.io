+++
title = "Rust实战：博物馆门票限流系统设计与实现"
description = "Rust实战：博物馆门票限流系统设计与实现"
date = 2025-05-19T01:16:24Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust实战：博物馆门票限流系统设计与实现

在疫情期间，博物馆等公共场所需要严格控制人流量以确保安全。如何高效实现“满50人后，出来一个才能进一个”的限流机制？本文将通过Rust编程语言，结合Tokio的Semaphore信号量，带你一步步实现一个高并发、线程安全的门票限流系统。无论你是Rust新手还是并发编程爱好者，这篇实战教程都将为你提供清晰的思路和可运行的代码示例。

本文详细介绍了如何使用Rust和Tokio的Semaphore实现博物馆门票限流系统。文章从问题背景出发，通过代码分步展示了博物馆限流模型的设计与实现，包括依赖配置、核心逻辑、测试用例及运行结果。Semaphore的使用确保了并发安全，而Drop trait的实现则模拟了门票的自动回收机制。文章适合对Rust并发编程或限流场景感兴趣的开发者阅读。

- Rust实现博物馆门票限流
- 博物馆门票
- 疫情期间，博物馆内限流最大容量50人，满了以后，出来一个才能进一个，怎么设计？

## Rust实现博物馆门票限流实操

### cargo.toml

```ts
[package]
name = "training_code"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
tokio = { version = "1.29.1", features = ["sync"] }

```

### lib.rs

```rust
pub mod ticket;
```

### ticket.rs

```rust
// 博物馆门票
// 疫情期间，博物馆内限流最大容量50人，满了以后，出来一个才能进一个，怎么设计？
// Mutex -> Semaphore
// https://www.cs.brandeis.edu/~cs146a/rust/doc-02-21-2015/nightly/std/sync/struct.Semaphore.html
// https://docs.rs/tokio/latest/tokio/sync/struct.Semaphore.html
use tokio::sync::{Semaphore, SemaphorePermit};

pub struct Museum {
    remaining_tickets: Semaphore,
}

#[derive(Debug)]
pub struct Ticket<'a> {
    permit: SemaphorePermit<'a>,
}

impl<'a> Ticket<'a> {
    pub fn new(permit: SemaphorePermit<'a>) -> Self {
        Self { permit }
    }
}

impl<'a> Drop for Ticket<'a> {
    fn drop(&mut self) {
        println!("ticket freed")
    }
}

impl Museum {
    pub fn new(total: usize) -> Self {
        Self {
            remaining_tickets: Semaphore::new(total),
        }
    }

    pub fn get_ticket(&self) -> Option<Ticket<'_>> {
        // 从信号量中获取许可
        match self.remaining_tickets.try_acquire() {
            Ok(permit) => Some(Ticket::new(permit)),
            Err(_) => None,
        }
    }

    pub fn tickets(&self) -> usize {
        self.remaining_tickets.available_permits() // 返回当前可用许可的数量
    }
}

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn it_works() {
        let museum = Museum::new(50);
        let ticket = museum.get_ticket().unwrap();
        assert_eq!(museum.tickets(), 49);
        let _tickets: Vec<Ticket> = (0..49).map(|_| museum.get_ticket().unwrap()).collect();
        assert_eq!(museum.tickets(), 0);

        assert!(museum.get_ticket().is_none());

        drop(ticket);
        {
            let ticket = museum.get_ticket().unwrap();
            println!("got ticket: {:?}", ticket);
        }
        println!("!!!!!");
        assert!(museum.get_ticket().is_some());
    }
}

```

### 测试

```bash
training_code on  master [?] is 📦 0.1.0 via 🦀 1.71.0 via 🅒 base 
➜ cargo test ticket::test::it_works -- --nocapture                                
   Compiling training_code v0.1.0 (/Users/qiaopengjun/Code/rust/training_code)
warning: field `permit` is never read
  --> src/ticket.rs:14:5
   |
13 | pub struct Ticket<'a> {
   |            ------ field in this struct
14 |     permit: SemaphorePermit<'a>,
   |     ^^^^^^
   |
   = note: `Ticket` has a derived impl for the trait `Debug`, but this is intentionally ignored during dead code analysis
   = note: `#[warn(dead_code)]` on by default

warning: `training_code` (lib test) generated 1 warning
    Finished test [unoptimized + debuginfo] target(s) in 0.94s
     Running unittests src/lib.rs (target/debug/deps/training_code-5f74f464a78aa0d2)

running 1 test
ticket freed
got ticket: Ticket { permit: SemaphorePermit { sem: Semaphore { ll_sem: Semaphore { permits: 0 } }, permits: 1 } }
ticket freed
!!!!!
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
ticket freed
test ticket::test::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 2 filtered out; finished in 0.00s


training_code on  master [?] is 📦 0.1.0 via 🦀 1.71.0 via 🅒 base 
➜ 
```

## 总结

通过本文，我们使用Rust和Tokio的Semaphore成功实现了一个博物馆门票限流系统，解决了“最大容量50人，出来一个才能进一个”的需求。Semaphore作为并发控制的利器，结合Rust的内存安全特性，确保了系统的线程安全和高性能。测试结果验证了设计的正确性，Drop trait的自动回收机制也让代码更加优雅。希望这篇教程能为你的Rust并发编程之旅提供启发！欢迎关注我的公众号，获取更多Rust实战内容。

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://crates.io/>
- <https://course.rs/about-book.html>
- <https://doc.rust-lang.org/nomicon/>
- <https://doc.rust-lang.org/stable/rust-by-example/>
