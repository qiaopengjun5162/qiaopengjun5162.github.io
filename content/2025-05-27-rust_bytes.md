+++
title = "深入浅出 Rust：高效处理二进制数据的 Bytes 与 BytesMut 实战"
description = "深入浅出 Rust：高效处理二进制数据的 Bytes 与 BytesMut 实战"
date = 2025-05-27T00:40:30Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 深入浅出 Rust：高效处理二进制数据的 Bytes 与 BytesMut 实战

在高性能网络编程和二进制协议解析场景中，Rust 的 bytes 库提供了强大的工具来高效管理二进制数据。本文通过一个简单的 Rust 示例，深入讲解 Bytes 和 BytesMut 类型的基本用法，帮助开发者快速上手并理解其在实际项目中的应用价值。无论你是 Rust 新手还是有一定经验的开发者，这篇文章都将为你提供实用的代码分析与实践指导。

本文基于一个 Rust 示例代码，详细解析了 bytes 库中 Bytes 和 BytesMut 类型的使用方法。代码展示了如何创建、追加、分割、冻结和转换二进制缓冲区，并通过逐行分析和运行结果展示其功能。文章适合希望学习 Rust 高性能数据处理的开发者，涵盖了从安装依赖到实际运行的全流程，并提供相关参考资源。

## 实操

### 安装依赖

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 
➜ cargo add bytes --dev
```

### Bytes.rs 文件

```rust
use anyhow::Result;
use bytes::{BufMut, Bytes, BytesMut};

fn main() -> Result<()> {
    let mut buf = BytesMut::with_capacity(1024);
    buf.extend_from_slice(b"hello world\n");
    buf.put(&b"goodbye world"[..]);
    buf.put_u8(b'\n');
    buf.put_i64(1234567890);
    println!("buf: {:?}", buf);

    let buf1 = buf.split();
    println!("buf1: {:?}", buf1);
    let mut buf2 = buf1.freeze();
    println!("buf2: {:?}", buf2);

    let buf3 = buf2.split_to(12);
    println!("buf3: {:?}", buf3);
    println!("buf2: {:?}", buf2);

    let mut bytes = BytesMut::new();
    bytes.extend_from_slice(b"hello");

    println!("bytes: {:?}", bytes);

    let bytes = Bytes::from(b"hello".to_vec());
    assert_eq!(BytesMut::from(bytes), BytesMut::from(&b"hello"[..]));
    Ok(())
}

```

这段代码是一个 Rust 示例，演示了 bytes crate 的 Bytes 和 BytesMut 类型的基本用法，主要用于高效地处理二进制数据缓冲区。下面逐行解释：

```rust
use anyhow::Result;
use bytes::{BufMut, Bytes, BytesMut};
```

- 引入 anyhow::Result 作为 main 的返回类型，方便错误处理。
- 引入 bytes crate 的 BufMut trait 以及 Bytes、BytesMut 类型。

### 主函数

```rust
fn main() -> Result<()> {
```

- main 函数返回 Result，便于用 `?` 处理错误。

#### 1. 创建和操作 BytesMut

```rust
    let mut buf = BytesMut::with_capacity(1024);
```

- 创建一个可变的 BytesMut 缓冲区，初始容量为 1024 字节。

```rust
    buf.extend_from_slice(b"hello world\n");
```

- 向缓冲区追加字节序列 "hello world\n"。

```rust
    buf.put(&b"goodbye world"[..]);
```

- 使用 BufMut trait 的 put 方法追加 "goodbye world"。

```rust
    buf.put_u8(b'\n');
```

- 追加一个字节（换行符）。

```rust
    buf.put_i64(1234567890);
```

- 以大端序追加一个 64 位整数 1234567890。

```rust
    println!("buf: {:?}", buf);
```

- 打印当前 buf 的内容（调试格式）。

#### 2. split 和 freeze

```rust
    let buf1 = buf.split();
    println!("buf1: {:?}", buf1);
```

- split 会将 buf 的内容全部“分离”出来，buf 变为空，buf1 拥有原内容。

```rust
    let mut buf2 = buf1.freeze();
    println!("buf2: {:?}", buf2);
```

- freeze 会将 BytesMut 转换为不可变的 Bytes，buf2 现在是 Bytes 类型。

#### 3. split_to

```rust
    let buf3 = buf2.split_to(12);
    println!("buf3: {:?}", buf3);
    println!("buf2: {:?}", buf2);
```

- split_to(12) 会把 buf2 的前 12 个字节分离出来，buf3 拥有前 12 字节，buf2 剩下后面的内容。

#### 4. BytesMut 新建与比较

```rust
    let mut bytes = BytesMut::new();
    bytes.extend_from_slice(b"hello");
    println!("bytes: {:?}", bytes);
```

- 新建一个空的 BytesMut，追加 "hello"，并打印。

```rust
    let bytes = Bytes::from(b"hello".to_vec());
    assert_eq!(BytesMut::from(bytes), BytesMut::from(&b"hello"[..]));
```

- 创建一个 Bytes，内容为 "hello"。
- 将 Bytes 转为 BytesMut，并与从字节切片 b"hello" 创建的 BytesMut 进行断言比较，确保内容一致。

```rust
    Ok(())
}
```

- main 正常结束。

这段代码演示了 bytes crate 的 BytesMut（可变缓冲区）和 Bytes（不可变缓冲区）的常用操作，包括追加数据、分割、冻结、类型转换和内容比较。适合用于高性能网络编程、二进制协议解析等场景。

### 运行

```bash
rust-ecosystem-learning on  main [!?] is 📦 0.1.0 via 🦀 1.87.0 
➜ cargo run --example bytes
   Compiling rust-ecosystem-learning v0.1.0 (/Users/qiaopengjun/Code/Rust/rust-ecosystem-learning)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.42s
     Running `target/debug/examples/bytes`
buf: b"hello world\ngoodbye world\n\0\0\0\0I\x96\x02\xd2"
buf1: b"hello world\ngoodbye world\n\0\0\0\0I\x96\x02\xd2"
buf2: b"hello world\ngoodbye world\n\0\0\0\0I\x96\x02\xd2"
buf3: b"hello world\n"
buf2: b"goodbye world\n\0\0\0\0I\x96\x02\xd2"
bytes: b"hello"

```

## 总结

通过本文的示例代码，我们深入了解了 Rust bytes 库中 Bytes 和 BytesMut 类型的核心功能，包括缓冲区创建、数据追加、分割、冻结和类型转换等操作。这些功能在网络编程和二进制数据处理场景中尤为重要，展现了 Rust 在性能和内存安全上的优势。希望读者通过本文的讲解和实践，能够快速掌握 bytes 库的用法，并在实际项目中灵活运用。

## 参考

- <https://docs.rs/bytes/latest/bytes/>
- <https://docs.rs/bytes/latest/src/bytes/bytes.rs.html#102-108>
- <https://www.rust-lang.org/zh-CN>
- <https://tokio.rs/>
- <https://rust-book.junmajinlong.com/ch1/00.html>
