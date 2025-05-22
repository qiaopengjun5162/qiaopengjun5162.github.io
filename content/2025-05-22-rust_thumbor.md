+++
title = "用 Rust 打造高性能图片处理服务器：从零开始实现类似 Thumbor 的功能"
description = "用 Rust 打造高性能图片处理服务器：从零开始实现类似 Thumbor 的功能"
date = 2025-05-22T01:01:39Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 用 Rust 打造高性能图片处理服务器：从零开始实现类似 Thumbor 的功能

在现代互联网应用中，图片处理服务是不可或缺的一环，无论是动态调整图片大小、裁剪、添加滤镜还是水印，都需要高效且可靠的解决方案。本文将带你从零开始，使用 Rust 编程语言构建一个类似 Thumbor 的图片处理服务器。通过这个实战项目，你将深入了解 Rust 的异步编程、Protobuf 数据结构、HTTP 服务搭建以及图片处理逻辑的实现。无论你是 Rust 新手还是希望提升技能的开发者，这篇文章都将为你提供清晰的指引和实操经验。

本文详细介绍了一个基于 Rust 的图片处理服务器的开发过程，灵感来源于开源图片处理工具 Thumbor。我们从项目初始化开始，逐步完成 Protobuf 定义、依赖配置、HTTP 服务器搭建、图片处理引擎实现以及缓存机制的集成。项目使用 Axum 框架构建异步 Web 服务，结合 photon-rs 库实现图片处理功能，支持调整大小、裁剪、翻转、滤镜和水印等操作。代码结构模块化，易于扩展，并通过 LRU 缓存优化性能。本文适合对 Rust、异步编程或图片处理感兴趣的开发者参考。

## 实操

一个类似 Thumbor 的图片服务器

### protobuf 的定义和编译

### 创建项目

```bash
/Code/rust via 🅒 base
➜ cargo new thumbor
     Created binary (application) `thumbor` package

~/Code/rust via 🅒 base
➜ cd thumbor

thumbor on  master [?] via 🦀 1.70.0 via 🅒 base
➜ c

thumbor on  master [?] via 🦀 1.70.0 via 🅒 base
➜


```

### `Cargo.toml` 文件

在项目的 Cargo.toml 中添加这些依赖：

```rust
[package]
name = "thumbor"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
axum = "0.6.18" # web 服务器
anyhow = "1.0.71" # 错误处理
base64 = "0.13.1" # base64 编码/解码
bytes = "1.4.0" # 处理字节流
image = "0.24.6" # 处理图片
lazy_static = "1.4.0" # 通过宏更方便地初始化静态变量
lru = "0.10.1" # LRU 缓存
percent-encoding = "2.3.0" # url 编码/解码
photon-rs = "0.3.2" # 图片效果
prost = "0.11.9" # protobuf 处理
reqwest = "0.11.18" # HTTP cliebnt
serde = { version = "1.0.164", features = ["derive"] } # 序列化/反序列化数据
tokio = { version = "1.29.1", features = ["full"] } # 异步处理
tower = { version = "0.4.13", features = [
    "util",
    "timeout",
    "load-shed",
    "limit",
] } # 服务处理及中间件
tower-http = { version = "0.4.1", features = [
    "add-extension",
    "compression-full",
    "trace",
] } # http 中间件
tracing = "0.1.37" # 日志和追踪
tracing-subscriber = "0.3.17" # 日志和追踪

[build-dependencies]
prost-build = "0.11.9" # 编译 protobuf

```

### 创建文件并编译构建项目

在项目根目录下，生成一个 abi.proto 文件，写入我们支持的图片处理服务用到的数据结构：

```bash
thumbor on  master [?] via 🦀 1.70.0 via 🅒 base 
➜ touch abi.proto    

thumbor on  master [?] via 🦀 1.70.0 via 🅒 base 
➜ touch build.rs 

thumbor on  master [?] via 🦀 1.70.0 via 🅒 base 
➜ mkdir src/pb                

thumbor on  master [?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base 
➜ cargo build          


thumbor on  master [?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base took 16.1s 
➜ touch src/pb/mod.rs
```

### `abi.proto` 文件

```rust
syntax = "proto3";

package abi; // 这个名字会被用作编译结果，prost 会产生：abi.rs

// 一个 ImageSpec 是一个有序的数组，服务器按照 spec 的顺序处理
message ImageSpec { repeated Spec specs = 1; }

// 处理图片改变大小
message Resize {
  uint32 width = 1;
  uint32 height = 2;

  enum ResizeType {
    NORMAL = 0;
    SEAM_CARVE = 1;
  }

  ResizeType rtype = 3;

  enum SampleFilter {
    UNDEFINED = 0;
    NEAREST = 1;
    TRIANGLE = 2;
    CATMULL_ROM = 3;
    GAUSSIAN = 4;
    LANCZOS3 = 5;
  }

  SampleFilter filter = 4;
}

// 处理图片截取
message Crop {
  uint32 x1 = 1;
  uint32 y1 = 2;
  uint32 x2 = 3;
  uint32 y2 = 4;
}

// 处理水平翻转
message Fliph {}
// 处理垂直翻转
message Flipv {}
// 处理对比度
message Contrast { float contrast = 1; }
// 处理滤镜
message Filter {
  enum Filter {
    UNSPECIFIED = 0;
    OCEANIC = 1;
    ISLANDS = 2;
    MARINE = 3;
    // more: https://docs.rs/photon-rs/0.3.1/photon_rs/filters/fn.filter.html
  }
  Filter filter = 1;
}

// 处理水印
message Watermark {
  uint32 x = 1;
  uint32 y = 2;
}

// 一个 spec 可以包含上述的处理方式之一
message Spec {
  oneof data {
    Resize resize = 1;
    Crop crop = 2;
    Flipv flipv = 3;
    Fliph fliph = 4;
    Contrast contrast = 5;
    Filter filter = 6;
    Watermark watermark = 7;
  }
}

```

### `build.rs` 文件

在项目根目录下，创建一个 build.rs，写入以下代码：

```rust
fn main() {
    prost_build::Config::new()
        .out_dir("src/pb")
        .compile_protos(&["abi.proto"], &["."])
        .unwrap();
}

```

### `abi.rs` 文件

mkdir src/pb 创建src/pb 目录。运行 cargo build，你会发现在 src/pb 下，有一个 abi.rs 文件被生成出来

```rust
/// 一个 ImageSpec 是一个有序的数组，服务器按照 spec 的顺序处理
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct ImageSpec {
    #[prost(message, repeated, tag = "1")]
    pub specs: ::prost::alloc::vec::Vec<Spec>,
}
/// 处理图片改变大小
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct Resize {
    #[prost(uint32, tag = "1")]
    pub width: u32,
    #[prost(uint32, tag = "2")]
    pub height: u32,
    #[prost(enumeration = "resize::ResizeType", tag = "3")]
    pub rtype: i32,
    #[prost(enumeration = "resize::SampleFilter", tag = "4")]
    pub filter: i32,
}
/// Nested message and enum types in `Resize`.
pub mod resize {
    #[derive(
        Clone,
        Copy,
        Debug,
        PartialEq,
        Eq,
        Hash,
        PartialOrd,
        Ord,
        ::prost::Enumeration
    )]
    #[repr(i32)]
    pub enum ResizeType {
        Normal = 0,
        SeamCarve = 1,
    }
    impl ResizeType {
        /// String value of the enum field names used in the ProtoBuf definition.
        ///
        /// The values are not transformed in any way and thus are considered stable
        /// (if the ProtoBuf definition does not change) and safe for programmatic use.
        pub fn as_str_name(&self) -> &'static str {
            match self {
                ResizeType::Normal => "NORMAL",
                ResizeType::SeamCarve => "SEAM_CARVE",
            }
        }
        /// Creates an enum from field names used in the ProtoBuf definition.
        pub fn from_str_name(value: &str) -> ::core::option::Option<Self> {
            match value {
                "NORMAL" => Some(Self::Normal),
                "SEAM_CARVE" => Some(Self::SeamCarve),
                _ => None,
            }
        }
    }
    #[derive(
        Clone,
        Copy,
        Debug,
        PartialEq,
        Eq,
        Hash,
        PartialOrd,
        Ord,
        ::prost::Enumeration
    )]
    #[repr(i32)]
    pub enum SampleFilter {
        Undefined = 0,
        Nearest = 1,
        Triangle = 2,
        CatmullRom = 3,
        Gaussian = 4,
        Lanczos3 = 5,
    }
    impl SampleFilter {
        /// String value of the enum field names used in the ProtoBuf definition.
        ///
        /// The values are not transformed in any way and thus are considered stable
        /// (if the ProtoBuf definition does not change) and safe for programmatic use.
        pub fn as_str_name(&self) -> &'static str {
            match self {
                SampleFilter::Undefined => "UNDEFINED",
                SampleFilter::Nearest => "NEAREST",
                SampleFilter::Triangle => "TRIANGLE",
                SampleFilter::CatmullRom => "CATMULL_ROM",
                SampleFilter::Gaussian => "GAUSSIAN",
                SampleFilter::Lanczos3 => "LANCZOS3",
            }
        }
        /// Creates an enum from field names used in the ProtoBuf definition.
        pub fn from_str_name(value: &str) -> ::core::option::Option<Self> {
            match value {
                "UNDEFINED" => Some(Self::Undefined),
                "NEAREST" => Some(Self::Nearest),
                "TRIANGLE" => Some(Self::Triangle),
                "CATMULL_ROM" => Some(Self::CatmullRom),
                "GAUSSIAN" => Some(Self::Gaussian),
                "LANCZOS3" => Some(Self::Lanczos3),
                _ => None,
            }
        }
    }
}
/// 处理图片截取
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct Crop {
    #[prost(uint32, tag = "1")]
    pub x1: u32,
    #[prost(uint32, tag = "2")]
    pub y1: u32,
    #[prost(uint32, tag = "3")]
    pub x2: u32,
    #[prost(uint32, tag = "4")]
    pub y2: u32,
}
/// 处理水平翻转
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct Fliph {}
/// 处理垂直翻转
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct Flipv {}
/// 处理对比度
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct Contrast {
    #[prost(float, tag = "1")]
    pub contrast: f32,
}
/// 处理滤镜
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct Filter {
    #[prost(enumeration = "filter::Filter", tag = "1")]
    pub filter: i32,
}
/// Nested message and enum types in `Filter`.
pub mod filter {
    #[derive(
        Clone,
        Copy,
        Debug,
        PartialEq,
        Eq,
        Hash,
        PartialOrd,
        Ord,
        ::prost::Enumeration
    )]
    #[repr(i32)]
    pub enum Filter {
        Unspecified = 0,
        Oceanic = 1,
        Islands = 2,
        /// more: <https://docs.rs/photon-rs/0.3.1/photon_rs/filters/fn.filter.html>
        Marine = 3,
    }
    impl Filter {
        /// String value of the enum field names used in the ProtoBuf definition.
        ///
        /// The values are not transformed in any way and thus are considered stable
        /// (if the ProtoBuf definition does not change) and safe for programmatic use.
        pub fn as_str_name(&self) -> &'static str {
            match self {
                Filter::Unspecified => "UNSPECIFIED",
                Filter::Oceanic => "OCEANIC",
                Filter::Islands => "ISLANDS",
                Filter::Marine => "MARINE",
            }
        }
        /// Creates an enum from field names used in the ProtoBuf definition.
        pub fn from_str_name(value: &str) -> ::core::option::Option<Self> {
            match value {
                "UNSPECIFIED" => Some(Self::Unspecified),
                "OCEANIC" => Some(Self::Oceanic),
                "ISLANDS" => Some(Self::Islands),
                "MARINE" => Some(Self::Marine),
                _ => None,
            }
        }
    }
}
/// 处理水印
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct Watermark {
    #[prost(uint32, tag = "1")]
    pub x: u32,
    #[prost(uint32, tag = "2")]
    pub y: u32,
}
/// 一个 spec 可以包含上述的处理方式之一
#[allow(clippy::derive_partial_eq_without_eq)]
#[derive(Clone, PartialEq, ::prost::Message)]
pub struct Spec {
    #[prost(oneof = "spec::Data", tags = "1, 2, 3, 4, 5, 6, 7")]
    pub data: ::core::option::Option<spec::Data>,
}
/// Nested message and enum types in `Spec`.
pub mod spec {
    #[allow(clippy::derive_partial_eq_without_eq)]
    #[derive(Clone, PartialEq, ::prost::Oneof)]
    pub enum Data {
        #[prost(message, tag = "1")]
        Resize(super::Resize),
        #[prost(message, tag = "2")]
        Crop(super::Crop),
        #[prost(message, tag = "3")]
        Flipv(super::Flipv),
        #[prost(message, tag = "4")]
        Fliph(super::Fliph),
        #[prost(message, tag = "5")]
        Contrast(super::Contrast),
        #[prost(message, tag = "6")]
        Filter(super::Filter),
        #[prost(message, tag = "7")]
        Watermark(super::Watermark),
    }
}

```

### 创建 src/pb/mod.rs

```rust
use base64::{decode_config, encode_config, URL_SAFE_NO_PAD};
use photon_rs::transform::SamplingFilter;
use prost::Message;
use std::convert::TryFrom;

mod abi; // 声明 abi.rs
pub use abi::*;

impl ImageSpec {
    pub fn new(specs: Vec<Spec>) -> Self {
        Self { specs }
    }
}

// 让 ImageSpec 可以生成一个字符串
impl From<&ImageSpec> for String {
    fn from(image_spec: &ImageSpec) -> Self {
        let data = image_spec.encode_to_vec();
        encode_config(data, URL_SAFE_NO_PAD)
    }
}

// 让 ImageSpec 可以通过一个字符串创建。比如 s.parse().unwrap()
impl TryFrom<&str> for ImageSpec {
    type Error = anyhow::Error;

    fn try_from(value: &str) -> Result<Self, Self::Error> {
        let data = decode_config(value, URL_SAFE_NO_PAD)?;
        Ok(ImageSpec::decode(&data[..])?)
    }
}

// 辅助函数，photon_rs 相应的方法里需要字符串
impl filter::Filter {
    pub fn to_str(&self) -> Option<&'static str> {
        match self {
            filter::Filter::Unspecified => None,
            filter::Filter::Oceanic => Some("oceanic"),
            filter::Filter::Islands => Some("islands"),
            filter::Filter::Marine => Some("marine"),
        }
    }
}

// 在我们定义的 SampleFilter 和 photon_rs 的 SamplingFilter 间转换
impl From<resize::SampleFilter> for SamplingFilter {
    fn from(v: resize::SampleFilter) -> Self {
        match v {
            resize::SampleFilter::Undefined => SamplingFilter::Nearest,
            resize::SampleFilter::Nearest => SamplingFilter::Nearest,
            resize::SampleFilter::Triangle => SamplingFilter::Triangle,
            resize::SampleFilter::CatmullRom => SamplingFilter::CatmullRom,
            resize::SampleFilter::Gaussian => SamplingFilter::Gaussian,
            resize::SampleFilter::Lanczos3 => SamplingFilter::Lanczos3,
        }
    }
}

// 提供一些辅助函数，让创建一个 spec 的过程简单一些
impl Spec {
    pub fn new_resize_seam_carve(width: u32, height: u32) -> Self {
        Self {
            data: Some(spec::Data::Resize(Resize {
                width,
                height,
                rtype: resize::ResizeType::SeamCarve as i32,
                filter: resize::SampleFilter::Undefined as i32,
            })),
        }
    }

    pub fn new_resize(width: u32, height: u32, filter: resize::SampleFilter) -> Self {
        Self {
            data: Some(spec::Data::Resize(Resize {
                width,
                height,
                rtype: resize::ResizeType::Normal as i32,
                filter: filter as i32,
            })),
        }
    }

    pub fn new_filter(filter: filter::Filter) -> Self {
        Self {
            data: Some(spec::Data::Filter(Filter {
                filter: filter as i32,
            })),
        }
    }

    pub fn new_watermark(x: u32, y: u32) -> Self {
        Self {
            data: Some(spec::Data::Watermark(Watermark { x, y })),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::borrow::Borrow;
    use std::convert::TryInto;

    #[test]
    fn encoded_spec_could_be_decoded() {
        let spec1 = Spec::new_resize(600, 600, resize::SampleFilter::CatmullRom);
        let spec2 = Spec::new_filter(filter::Filter::Marine);
        let image_spec = ImageSpec::new(vec![spec1, spec2]);
        let s: String = image_spec.borrow().into();
        assert_eq!(image_spec, s.as_str().try_into().unwrap());
    }
}

```

在这个文件中，我们引入 abi.rs，并且撰写一些辅助函数。这些辅助函数主要是为了，让 ImageSpec 可以被方便地转换成字符串，或者从字符串中恢复。

### 测试

cargo test 测试

```bash
thumbor on  master [?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base 
➜ cargo test 
   Compiling thumbor v0.1.0 (/Users/qiaopengjun/Code/rust/thumbor)
    Finished test [unoptimized + debuginfo] target(s) in 1.47s
     Running unittests src/main.rs (target/debug/deps/thumbor-65758f02ef3fc46d)

running 1 test
test pb::tests::encoded_spec_could_be_decoded ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s


thumbor on  main is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base 
➜ 
```

### 引入 HTTP 服务器

#### main.rs

```rust
use axum::{extract::Path, http::StatusCode, routing::get, Router};
use percent_encoding::percent_decode_str;
use serde::Deserialize;
use std::convert::TryInto;

// 引入 protobuf 生成的代码，我们暂且不用太关心他们
mod pb;

use pb::*;

// 参数使用 serde 做 Deserialize，axum 会自动识别并解析
#[derive(Deserialize)]
struct Params {
    spec: String,
    url: String,
}

#[tokio::main]
async fn main() {
    // 初始化 tracing
    tracing_subscriber::fmt::init();

    // 构建路由
    let app = Router::new()
        // `GET /image` 会执行 generate 函数，并把 spec 和 url 传递过去
        .route("/image/:spec/:url", get(generate));

    // 运行 web 服务器
    let addr = "127.0.0.1:3000".parse().unwrap();
    tracing::debug!("listening on {}", addr);
    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

// 目前我们就只把参数解析出来
async fn generate(Path(Params { spec, url }): Path<Params>) -> Result<String, StatusCode> {
    let url = percent_decode_str(&url).decode_utf8_lossy();
    let spec: ImageSpec = spec
        .as_str()
        .try_into()
        .map_err(|_| StatusCode::BAD_REQUEST)?;
    Ok(format!("url: {}\n spec: {:#?}", url, spec))
}

```

### 使用 cargo run 运行服务器。然后HTTPie 测试（eat your own dog food）

```bash
thumbor on  main is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base 
➜ cargo run 
   Compiling thumbor v0.1.0 (/Users/qiaopengjun/Code/rust/thumbor)
    Finished dev [unoptimized + debuginfo] target(s) in 4.49s
     Running `target/debug/thumbor`



httpie/pub on  main is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base
➜ ./httpie get "http://localhost:3000/image/CgoKCAjYBBCgBiADCgY6BAgUEBQKBDICCAM/https%3A%2F%2Fimages%2Epexels%2Ecom%2Fphotos%2F2470905%2Fpexels%2Dphoto%2D2470905%2Ejpeg%3Fauto%3Dcompress%26cs%3Dtinysrgb%26dpr%3D2%26h%3D750%26w%3D1260"
HTTP/1.1 200 OK

content-type: "text/plain; charset=utf-8"
content-length: "901"
date: "Fri, 30 Jun 2023 15:50:46 GMT"

url: https://images.pexels.com/photos/2470905/pexels-photo-2470905.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260
 spec: ImageSpec {
    specs: [
        Spec {
            data: Some(
                Resize(
                    Resize {
                        width: 600,
                        height: 800,
                        rtype: Normal,
                        filter: CatmullRom,
                    },
                ),
            ),
        },
        Spec {
            data: Some(
                Watermark(
                    Watermark {
                        x: 20,
                        y: 20,
                    },
                ),
            ),
        },
        Spec {
            data: Some(
                Filter(
                    Filter {
                        filter: Marine,
                    },
                ),
            ),
        },
    ],
}

httpie/pub on  main is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base
➜
```

### Git  代码提交

```bash
thumbor on  master [?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base
➜ echo "# thumbor" >> README.md

thumbor on  master [?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base
➜ git add .

thumbor on  master [+] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base
➜ git commit -m "first commit"
[master（根提交） 679d01f] first commit
 9 files changed, 3256 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 Cargo.lock
 create mode 100644 Cargo.toml
 create mode 100644 README.md
 create mode 100644 abi.proto
 create mode 100644 build.rs
 create mode 100644 src/main.rs
 create mode 100644 src/pb/abi.rs
 create mode 100644 src/pb/mod.rs

thumbor on  master is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base
➜ git branch -M main

thumbor on  main is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base
➜ git remote add origin git@github.com:qiaopengjun5162/thumbor.git

thumbor on  main is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base
➜ git push -u origin main
枚举对象中: 13, 完成.
对象计数中: 100% (13/13), 完成.
使用 12 个线程进行压缩
压缩对象中: 100% (11/11), 完成.
写入对象中: 100% (13/13), 22.91 KiB | 7.64 MiB/s, 完成.
总共 13（差异 0），复用 0（差异 0），包复用 0
To github.com:qiaopengjun5162/thumbor.git
 * [new branch]      main -> main
分支 'main' 设置为跟踪 'origin/main'。

thumbor on  main is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base took 16.5s
➜
```

### 获取源图并缓存

```rust
use anyhow::Result;
use axum::{
    extract::{Extension, Path},
    http::{HeaderMap, HeaderValue, StatusCode},
    routing::get,
    Router,
};
use bytes::Bytes;
use lru::LruCache;
use percent_encoding::{percent_decode_str, percent_encode, NON_ALPHANUMERIC};
use serde::Deserialize;
use std::num::NonZeroUsize;
use std::{
    collections::hash_map::DefaultHasher,
    convert::TryInto,
    hash::{Hash, Hasher},
    sync::Arc,
};
use tokio::sync::Mutex;
use tower::ServiceBuilder;
use tower_http::add_extension::AddExtensionLayer;
use tracing::{info, instrument};

mod pb;

use pb::*;

#[derive(Deserialize)]
struct Params {
    spec: String,
    url: String,
}
type Cache = Arc<Mutex<LruCache<u64, Bytes>>>;

#[tokio::main]
async fn main() {
    // 初始化 tracing
    tracing_subscriber::fmt::init();
    let value = 1024;
    let non_zero_value = NonZeroUsize::new(value).expect("value must be non-zero");
    let cache: Cache = Arc::new(Mutex::new(LruCache::new(non_zero_value)));
    // 构建路由
    let app = Router::new()
        // `GET /` 会执行
        .route("/image/:spec/:url", get(generate))
        .layer(
            ServiceBuilder::new()
                .layer(AddExtensionLayer::new(cache))
                .into_inner(),
        );

    // 运行 web 服务器
    let addr = "127.0.0.1:3000".parse().unwrap();

    print_test_url("https://images.pexels.com/photos/1562477/pexels-photo-1562477.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260");

    info!("Listening on {}", addr);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

async fn generate(
    Path(Params { spec, url }): Path<Params>,
    Extension(cache): Extension<Cache>,
) -> Result<(HeaderMap, Vec<u8>), StatusCode> {
    let _spec: ImageSpec = spec
        .as_str()
        .try_into()
        .map_err(|_| StatusCode::BAD_REQUEST)?;

    let url: &str = &percent_decode_str(&url).decode_utf8_lossy();
    let data = retrieve_image(&url, cache)
        .await
        .map_err(|_| StatusCode::BAD_REQUEST)?;

    // TODO: 处理图片

    let mut headers = HeaderMap::new();

    headers.insert("content-type", HeaderValue::from_static("image/jpeg"));
    Ok((headers, data.to_vec()))
}

#[instrument(level = "info", skip(cache))]
async fn retrieve_image(url: &str, cache: Cache) -> Result<Bytes> {
    let mut hasher = DefaultHasher::new();
    url.hash(&mut hasher);
    let key = hasher.finish();

    let g = &mut cache.lock().await;
    let data = match g.get(&key) {
        Some(v) => {
            info!("Match cache {}", key);
            v.to_owned()
        }
        None => {
            info!("Retrieve url");
            let resp = reqwest::get(url).await?;
            let data = resp.bytes().await?;
            g.put(key, data.clone());
            data
        }
    };

    Ok(data)
}

// 调试辅助函数
fn print_test_url(url: &str) {
    use std::borrow::Borrow;
    let spec1 = Spec::new_resize(500, 800, resize::SampleFilter::CatmullRom);
    let spec2 = Spec::new_watermark(20, 20);
    let spec3 = Spec::new_filter(filter::Filter::Marine);
    let image_spec = ImageSpec::new(vec![spec1, spec2, spec3]);
    let s: String = image_spec.borrow().into();
    let test_image = percent_encode(url.as_bytes(), NON_ALPHANUMERIC).to_string();
    println!("test url: http://localhost:3000/image/{}/{}", s, test_image);
}

```

### 运行

```bash
thumbor on  main [!] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base took 2.7s 
➜ RUST_LOG=info cargo run --quiet
test url: http://localhost:3000/image/CgoKCAj0AxCgBiADCgY6BAgUEBQKBDICCAM/https%3A%2F%2Fimages%2Epexels%2Ecom%2Fphotos%2F1562477%2Fpexels%2Dphoto%2D1562477%2Ejpeg%3Fauto%3Dcompress%26cs%3Dtinysrgb%26dpr%3D3%26h%3D750%26w%3D1260
2023-06-30T16:26:31.587989Z  INFO thumbor: Listening on 127.0.0.1:3000
2023-06-30T16:27:38.372733Z  INFO retrieve_image{url="https://images.pexels.com/photos/1562477/pexels-photo-1562477.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260"}: thumbor: Retrieve url


```

### 图片处理

我们创建 src/engine 目录，并添加 src/engine/mod.rs，在这个文件里添加对 trait 的定义：

```bash
thumbor on  main is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base took 4.4s 
➜ mkdir src/engine      

thumbor on  main is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base 
➜ touch src/engine/mod.rs             

thumbor on  main [?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base 
➜ 

thumbor on  main [?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base 
➜ touch src/engine/photon.rs                 

```

### src/engine/mod.rs

```rust
use crate::pb::Spec;
use image::ImageOutputFormat;

mod photon;
pub use photon::Photon;

// Engine trait：未来可以添加更多的 engine，主流程只需要替换 engine
pub trait Engine {
    // 对 engine 按照 specs 进行一系列有序的处理
    fn apply(&mut self, specs: &[Spec]);
    // 从 engine 中生成目标图片，注意这里用的是 self，而非 self 的引用
    fn generate(self, format: ImageOutputFormat) -> Vec<u8>;
}

// SpecTransform：未来如果添加更多的 spec，只需要实现它即可
pub trait SpecTransform<T> {
    // 对图片使用 op 做 transform
    fn transform(&mut self, op: T);
}

```

### src/engine/photon.rs

```rust
use super::{Engine, SpecTransform};
use crate::pb::*;
use anyhow::Result;
use bytes::Bytes;
use image::{DynamicImage, ImageBuffer, ImageOutputFormat};
use lazy_static::lazy_static;
use photon_rs::{
    effects, filters, multiple, native::open_image_from_bytes, transform, PhotonImage,
};
use std::convert::TryFrom;
use std::io::Cursor;

lazy_static! {
    // 预先把水印文件加载为静态变量
    static ref WATERMARK: PhotonImage = {
        // 这里你需要把我 github 项目下的对应图片拷贝到你的根目录
        // 在编译的时候 include_bytes! 宏会直接把文件读入编译后的二进制
        let data = include_bytes!("../../rust-logo.png");
        let watermark = open_image_from_bytes(data).unwrap();
        transform::resize(&watermark, 64, 64, transform::SamplingFilter::Nearest)
    };
}

// 我们目前支持 Photon engine
pub struct Photon(PhotonImage);

// 从 Bytes 转换成 Photon 结构
impl TryFrom<Bytes> for Photon {
    type Error = anyhow::Error;

    fn try_from(data: Bytes) -> Result<Self, Self::Error> {
        Ok(Self(open_image_from_bytes(&data)?))
    }
}

impl Engine for Photon {
    fn apply(&mut self, specs: &[Spec]) {
        for spec in specs.iter() {
            match spec.data {
                Some(spec::Data::Crop(ref v)) => self.transform(v),
                Some(spec::Data::Contrast(ref v)) => self.transform(v),
                Some(spec::Data::Filter(ref v)) => self.transform(v),
                Some(spec::Data::Fliph(ref v)) => self.transform(v),
                Some(spec::Data::Flipv(ref v)) => self.transform(v),
                Some(spec::Data::Resize(ref v)) => self.transform(v),
                Some(spec::Data::Watermark(ref v)) => self.transform(v),
                // 对于目前不认识的 spec，不做任何处理
                _ => {}
            }
        }
    }

    fn generate(self, format: ImageOutputFormat) -> Vec<u8> {
        image_to_buf(self.0, format)
    }
}

impl SpecTransform<&Crop> for Photon {
    fn transform(&mut self, op: &Crop) {
        let img = transform::crop(&mut self.0, op.x1, op.y1, op.x2, op.y2);
        self.0 = img;
    }
}

impl SpecTransform<&Contrast> for Photon {
    fn transform(&mut self, op: &Contrast) {
        effects::adjust_contrast(&mut self.0, op.contrast);
    }
}

impl SpecTransform<&Flipv> for Photon {
    fn transform(&mut self, _op: &Flipv) {
        transform::flipv(&mut self.0)
    }
}

impl SpecTransform<&Fliph> for Photon {
    fn transform(&mut self, _op: &Fliph) {
        transform::fliph(&mut self.0)
    }
}

impl SpecTransform<&Filter> for Photon {
    fn transform(&mut self, op: &Filter) {
        match filter::Filter::from_i32(op.filter) {
            Some(filter::Filter::Unspecified) => {}
            Some(f) => filters::filter(&mut self.0, f.to_str().unwrap()),
            _ => {}
        }
    }
}

impl SpecTransform<&Resize> for Photon {
    fn transform(&mut self, op: &Resize) {
        let img = match resize::ResizeType::from_i32(op.rtype).unwrap() {
            resize::ResizeType::Normal => transform::resize(
                &mut self.0,
                op.width,
                op.height,
                resize::SampleFilter::from_i32(op.filter).unwrap().into(),
            ),
            resize::ResizeType::SeamCarve => {
                transform::seam_carve(&mut self.0, op.width, op.height)
            }
        };
        self.0 = img;
    }
}

impl SpecTransform<&Watermark> for Photon {
    fn transform(&mut self, op: &Watermark) {
        multiple::watermark(&mut self.0, &WATERMARK, op.x, op.y);
    }
}

// photon 库竟然没有提供在内存中对图片转换格式的方法，只好手工实现
fn image_to_buf(img: PhotonImage, format: ImageOutputFormat) -> Vec<u8> {
    let raw_pixels = img.get_raw_pixels();
    let width = img.get_width();
    let height = img.get_height();

    let img_buffer = ImageBuffer::from_vec(width, height, raw_pixels).unwrap();
    let dynimage = DynamicImage::ImageRgba8(img_buffer);

    let mut buffer = Cursor::new(Vec::with_capacity(32768));
    dynimage.write_to(&mut buffer, format).unwrap();
    buffer.into_inner()
}

```

### main.rs

把 engine 模块加入 main.rs，并引入 Photon：

TODO: 处理图片 Photon 引擎处理：

```rust
use anyhow::Result;
use axum::{
    extract::{Extension, Path},
    http::{HeaderMap, HeaderValue, StatusCode},
    routing::get,
    Router,
};
use bytes::Bytes;
use lru::LruCache;
use percent_encoding::{percent_decode_str, percent_encode, NON_ALPHANUMERIC};
use serde::Deserialize;
use std::num::NonZeroUsize;
use std::{
    collections::hash_map::DefaultHasher,
    convert::TryInto,
    hash::{Hash, Hasher},
    sync::Arc,
};
use tokio::sync::Mutex;
use tower::ServiceBuilder;
use tower_http::add_extension::AddExtensionLayer;
use tracing::{info, instrument};

mod engine;
use engine::{Engine, Photon};
use image::ImageOutputFormat;
mod pb;

use pb::*;

#[derive(Deserialize)]
struct Params {
    spec: String,
    url: String,
}
type Cache = Arc<Mutex<LruCache<u64, Bytes>>>;

#[tokio::main]
async fn main() {
    // 初始化 tracing
    tracing_subscriber::fmt::init();
    let value = 1024;
    let non_zero_value = NonZeroUsize::new(value).expect("value must be non-zero");
    let cache: Cache = Arc::new(Mutex::new(LruCache::new(non_zero_value)));
    // 构建路由
    let app = Router::new()
        // `GET /` 会执行
        .route("/image/:spec/:url", get(generate))
        .layer(
            ServiceBuilder::new()
                .layer(AddExtensionLayer::new(cache))
                .into_inner(),
        );

    // 运行 web 服务器
    let addr = "127.0.0.1:3000".parse().unwrap();

    print_test_url("https://images.pexels.com/photos/1562477/pexels-photo-1562477.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260");

    info!("Listening on {}", addr);

    axum::Server::bind(&addr)
        .serve(app.into_make_service())
        .await
        .unwrap();
}

async fn generate(
    Path(Params { spec, url }): Path<Params>,
    Extension(cache): Extension<Cache>,
) -> Result<(HeaderMap, Vec<u8>), StatusCode> {
    let spec: ImageSpec = spec
        .as_str()
        .try_into()
        .map_err(|_| StatusCode::BAD_REQUEST)?;

    let url: &str = &percent_decode_str(&url).decode_utf8_lossy();
    let data = retrieve_image(&url, cache)
        .await
        .map_err(|_| StatusCode::BAD_REQUEST)?;

    // 使用 image engine 处理
    let mut engine: Photon = data
        .try_into()
        .map_err(|_| StatusCode::INTERNAL_SERVER_ERROR)?;
    engine.apply(&spec.specs);

    let image = engine.generate(ImageOutputFormat::Jpeg(85));

    info!("Finished processing: image size {}", image.len());
    let mut headers = HeaderMap::new();

    headers.insert("content-type", HeaderValue::from_static("image/jpeg"));
    Ok((headers, image))
}

#[instrument(level = "info", skip(cache))]
async fn retrieve_image(url: &str, cache: Cache) -> Result<Bytes> {
    let mut hasher = DefaultHasher::new();
    url.hash(&mut hasher);
    let key = hasher.finish();

    let g = &mut cache.lock().await;
    let data = match g.get(&key) {
        Some(v) => {
            info!("Match cache {}", key);
            v.to_owned()
        }
        None => {
            info!("Retrieve url");
            let resp = reqwest::get(url).await?;
            let data = resp.bytes().await?;
            g.put(key, data.clone());
            data
        }
    };

    Ok(data)
}

// 调试辅助函数
fn print_test_url(url: &str) {
    use std::borrow::Borrow;
    let spec1 = Spec::new_resize(500, 800, resize::SampleFilter::CatmullRom);
    let spec2 = Spec::new_watermark(20, 20);
    let spec3 = Spec::new_filter(filter::Filter::Marine);
    let image_spec = ImageSpec::new(vec![spec1, spec2, spec3]);
    let s: String = image_spec.borrow().into();
    let test_image = percent_encode(url.as_bytes(), NON_ALPHANUMERIC).to_string();
    println!("test url: http://localhost:3000/image/{}/{}", s, test_image);
}

```

### 用 cargo build --release 编译 thumbor 项目，然后打开日志运行

```bash
thumbor on  main [!?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base took 1m 24.7s 
➜ cargo build --release


thumbor on  main [!?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base took 40.9s 
➜ RUST_LOG=info target/release/thumbor
```

### 总计代码行数

```bash
thumbor on  main [!?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base took 2m 34.1s 
➜ tokei src/main.rs src/engine/* src/pb/mod.rs
===============================================================================
 Language            Files        Lines         Code     Comments       Blanks
===============================================================================
 Rust                    4          390          317           23           50
===============================================================================
 Total                   4          390          317           23           50
===============================================================================

thumbor on  main [!?] is 📦 0.1.0 via 🦀 1.70.0 via 🅒 base 
➜ 
```

学习Rust要打破很多自己原有的认知，去拥抱新的思想和概念。但是只要多写多思考，时间长了，理解起来就是水到渠成的事。

## 总结

通过本文的实战演练，我们成功实现了一个功能强大的图片处理服务器，涵盖了从项目搭建、Protobuf 定义到图片处理和缓存优化的完整开发流程。Rust 的高性能和内存安全特性使得它非常适合开发此类高并发、低延迟的服务。以下是项目的几个关键收获：

- 模块化设计：通过定义 Engine 和 SpecTransform trait，代码结构清晰，易于扩展新的图片处理引擎或功能。
- 异步编程：使用 Axum 和 Tokio 构建高效的异步 HTTP 服务，结合 LRU 缓存优化图片加载性能。
- Protobuf 集成：通过 Protobuf 定义图片处理规格，实现了灵活且可序列化的参数传递。
- 实践 Rust 特性：项目中使用了 Rust 的 trait、宏、异步运行时等特性，帮助开发者深入理解 Rust 的现代编程范式。

无论你是想学习 Rust 的异步编程，还是希望构建一个高性能的图片处理服务，这个项目都提供了一个实用的起点。你可以 fork 项目代码（GitHub 仓库），尝试添加更多功能，比如支持其他图片格式或新的滤镜效果。Rust 的学习曲线虽然陡峭，但通过这样的实战项目，你将逐渐掌握其强大之处。

## 参考

- <https://time.geekbang.org/column/article/413634>
- <https://www.rust-lang.org/zh-CN>
- <https://crates.io/>
- <https://course.rs/about-book.html>
