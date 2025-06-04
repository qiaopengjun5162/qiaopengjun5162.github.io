+++
title = "解锁Rust代码组织：轻松掌握Package、Crate与Module"
description = "解锁Rust代码组织：轻松掌握Package、Crate与Module"
date = 2025-06-04T00:38:22Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 解锁Rust代码组织：轻松掌握Package、Crate与Module

想在2025年成为Rust编程的佼佼者？代码组织是Rust开发的第一道门槛，也是释放其高效与安全潜力的关键！Rust的模块系统通过Package、Crate和Module，为开发者提供了优雅而强大的代码管理方式。本文将带你轻松解锁Rust代码组织的秘密，从Package与Crate的定义到Module的灵活应用，手把手带你掌握Rust模块系统的核心技巧。无论你是初学者还是进阶开发者，这篇干货满满的指南都将助你快速上手，编写更清晰、更高效的Rust代码！

本文以通俗易懂的方式，系统讲解了Rust编程语言中Package、Crate和Module的定义与使用方法。文章从Rust代码组织的基本原则入手，详细解析了Package与Crate的类型及Cargo工具的惯例，深入剖析Module的作用、路径（Path）的使用规则，以及pub和use关键字的灵活运用。同时，介绍了如何通过拆分模块到不同文件提升代码可维护性。无论你是想快速入门Rust，还是希望优化代码结构，这篇指南都将为你提供清晰的思路和实用的技巧。

## 一、Package、Crate、定义 Module

### Rust的代码组织

- 代码组织主要包括：
  - 哪些细节可以暴露，哪些细节是私有的
  - 作用域内哪些名称有效
- 模块系统：
  - Package（包）：Cargo 的特性，让你构建、测试、共享 crate
  - Crate（单元包）：一个模块树，它可产生一个library 或可执行文件
  - Module（模块）、use：让你控制代码的组织、作用域、私有路径
  - Path（路径）：为struct、function 或 module 等命名的方式

### Package 和 Crate

- Crate 的类型：
  - binary
  - library
- Crate Root：
  - 是源代码文件
  - Rust编译器从这里开始，组成你的Crate的根Module
- 一个 Package：
  - 包含1个 Cargo.toml，它描述了如何构建这些Crates
  - 只能包含0-1个 library crate
  - 可以包含任意数量的 binary crate
  - 但必须至少包含一个 crate（library 或 binary）

```bash
~/rust
➜ cargo new my-project
     Created binary (application) `my-project` package

~/rust
➜ cd my-project

my-project on  master [?] via 🦀 1.67.1
➜ c  # vscode打开（设置了别名）

my-project on  master [?] via 🦀 1.67.1
➜

```

### Cargo 的惯例

- src/main.rs:
  - binary crate 的 crate root
  - crate 名与 package 名相同
- src/lib.rs:
  - package 包含一个 library crate
  - library crate 的 crate root
  - crate 名 与 package 名相同
- Cargo 把 crate root 文件交给 rustc 来构建 library 或 binary
- 一个Package可以同时包含 src/main.rs和src/lib.rs
  - 一个 binary crate，一个 library crate
  - 名称与package名相同
- 一个Package可以有多个 binary crate：
  - 文件放在 src/bin
  - 每个文件是单独的 binary crate

### Crate 的作用

- 将相关功能组合到一个作用域内，便于在项目间进行分享
  - 防止冲突
- 例如 rand crate，访问它的功能需要通过它的名字：rand

### 定义 module 来控制作用域和私有性

- Module：
  - 在一个 crate 内，将代码进行分组
  - 增加可读性，易于复用
  - 控制项目(item) 的私有性。public、private
- 建立 module：
  - mod 关键字
  - 可嵌套
  - 可包含其它项（struct、enum、常量、trait、函数等）的定义

### Module

- lib.rs 文件

```rust
mod front_of_house {
    mod hosting {
        fn add_to_waitlist() {}
        fn seat_at_table() {}
    }

    mod serving {
        fn take_order() {}
        fn serve_order() {}
        fn take_payment() {}
    }
}

```

- Src/main.rs 和 src/lib.rs 叫做 crate roots：
  - 这两个文件（任意一个）的内容形成了名为crate 的模块，位于整个模块树的根部

```
crate
 - front_of_house
   - hosting
     - add_to_waitlist
     - seat_at_table
      - serving
        - take_order
        - serve_order
        - take_payment
```

## 二、路径 Path

### 路径（Path）

- 为了在Rust的模块中找到某个条目，需要使用路径
- 路径的两种形式：
  - 绝对路径：从 crate root 开始，使用 crate 名或字面值 crate
  - 相对路径：从当前模块开始，使用 self，super 或当前模块的标识符
- 路径至少由一个标识符组成，标识符之间使用 ::。(定义和使用一起移动使用相对路径)

### 私有边界（privacy boundary）

- 模块不仅可以组织代码，还可以定义私有边界
- 如果想把函数或 struct等设为私有，可以将它放到某个模块中
- Rust中所有的条目（函数、方法、struct、enum、模块、常量）默认是私有的
- 父级模块无法访问子模块中的私有条目
- 子模块里可以使用所有祖先模块中的条目

### pub 关键字

- 使用pub关键字来将某些条目标记为公共的

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

pub fn eat_at_restautant() {
    crate::front_of_house::hosting::add_to_waitlist();
    
    front_of_house::hosting::add_to_waitlist();
}

```

## 三、路径 Path （第二部分）

### super 关键字

- Super： 用来访问父级模块路径中的内容，类似文件系统中的 ..

```rust
fn serve_order() {}

mod back_of_house {
    fn fix_incorrect_order() {
        cook_order();
        super::serve_order();
        crate::serve_order();
    }

    fn cook_order() {}
}

```

### pub struct

- pub 放在 struct 前：
  - Struct 是公共的
  - struct 的字段默认是私有的

```rust
mod back_of_house {
    pub struct Breakfast {

    }
}
```

- struct 的字段需要单独设置 pub 来变成公有

```rust
mod back_of_house {
    pub struct Breakfast {
        pub toast: String,
        seasonal_fruit: String,
    }

    impl Breakfast {
        pub fn summer(toast: &str) -> Breakfast {
            Breakfast { 
              toast: String::from(toast), 
              seasonal_fruit: String::from("peaches"), 
          }
      }
    }
}

pub fn eat_at_restautant() {
    let mut meal = back_of_house::Breakfast::summer("Rye");
    meal.toast = String::from("Wheat");
    println!("I'd like {} toast please", meal.toast);
    meal.seasonal_fruit = String::from("blueberries"); // 私有的 报错
}

```

### pub enum

- pub 放在 enum 前：
  - enum 是公共的
  - enum 的变体也都是公共的

```rust
mod back_of_house {
  pub enum Appetizer {
    Soup,
    Salad,
  }
}
```

## 四、use 关键字

### use 关键字

- 可以使用 use 关键字将路径导入到作用域内
  - 仍遵循私有性规则

```rust
mod front_of_house {
  pub mod hosting {
    pub fn add_to_waitlist() {}
  }
}

use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
  hosting::add_to_waitlist();
  hosting::add_to_waitlist();
  hosting::add_to_waitlist();
}
```

- 使用 use 来指定相对路径

```rust
mod front_of_house {
  pub mod hosting {
    pub fn add_to_waitlist() {}
  }
}

use front_of_house::hosting;

pub fn eat_at_restaurant() {
  hosting::add_to_waitlist();
  hosting::add_to_waitlist();
  hosting::add_to_waitlist();
}
```

### use 的习惯用法

- 函数：将函数的父级模块引入作用域（指定到父级）
- struct，enum，其它：指定完整路径（指定到本身）

```rust
use std::collections::HashMap;

fn main() {
  let mut map = HashMap::new();
  map.insert(1, 2);
}
```

- 同名条目：指定到父级

```rust
use std::fmt;
use std::io;

fn f1() -> fmt::Result {}

fn f2() -> io::Result {}

fn main() {}
```

### As 关键字

- as 关键字可以为引入的路径指定本地的别名

```rust
use std::fmt::Result;
use std::io::Result as IoResult;

fn f1() -> Result {}

fn f2() -> IoResult {}

fn main() {}
```

## 五、use 关键字（第二部分）

### 使用pub use 重新导出名称

- 使用 use 将路径（名称）导入到作用域内后，该名称在此作用域内是私有的

```rust
mod front_of_house {
  pub mod hosting {
    pub fn add_to_waitlist() {}
  }
}

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
  hosting::add_to_waitlist();
  hosting::add_to_waitlist();
  hosting::add_to_waitlist();
}
```

- pub use：重导出
  - 将条目引入作用域
  - 该条目可以被外部代码引入到它们的作用域

### 使用外部包（package）

- Cargo.toml 添加依赖的包（package）
  - <https://crates.io/>
- use 将特定条目引入作用域

```bash
my-project on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ where cargo  
/opt/homebrew/bin/cargo
/opt/homebrew/bin/cargo
/Users/qiaopengjun/.cargo/bin/cargo

my-project on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ cd /Users/qiaopengjun/.cargo 

~/.cargo 
➜ ls
bin      env      registry

~/.cargo 
➜ ls -al       
total 8
drwxr-xr-x   6 qiaopengjun  staff   192 Feb 20 23:17 .
drwxr-x---+ 81 qiaopengjun  staff  2592 Mar 16 13:47 ..
-rw-r--r--@  1 qiaopengjun  staff     0 Feb 15 22:28 .package-cache #
drwxr-xr-x  15 qiaopengjun  staff   480 Mar 10 13:16 bin
-rw-r--r--   1 qiaopengjun  staff   300 Feb 13 23:48 env
drwxr-xr-x@  6 qiaopengjun  staff   192 Feb 20 23:20 registry

~/.cargo 
➜ 

~/.cargo 
➜ touch config    

~/.cargo 
➜ vim config    
```

Config  文件

```bash
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"

replace-with = 'tuna'
[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

[net]
git-fetch-with-cli = true
~                                                                                                                                                                 
~                                                                                                                                                                                                                                                                                                                              
~                                                                                                                                                                 
~                                                                                                                                                                 
"config" 9L, 221B
```

Cargo.toml 文件

```toml
[package]
name = "my-project"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
rand = "0.8.5"

```

src/main.rs 文件

```rust
use rand::Rng;

fn main() {
    println!("Hello, world!");
}

```

- 标准库（std）也被当做外部包
  - 不需要修改 Cargo.toml 来包含 std
  - 需要使用 use 将 std 中的特定条目引入当前作用域

```rust
use rand::Rng;
use std::collections::HashMap;

fn main() {
    println!("Hello, world!");
}

```

### 使用嵌套路径清理大量的 use 语句

- 如果使用同一个包或模块下的多个条目
- 例子：

```rust
use std::cmp::Ordering;
use std::io;

fn main() {}
```

- 可使用嵌套路径在同一行内将上述条目进行引入：
  - 路径相同的部分::{路径差异的部分}
- 如果两个use 路径之一是另一个的子路径
  - 使用 self

```rust
use std::{cmp::Ordering, io};

// use std::io;
// use std::io::Write;

use std::io::{self, Write};

fn main() {}
```

### 通配符 *

- 使用 * 可以把路径中的所有的公共条目都引入到作用域
- 注意：谨慎使用
- 应用场景：
  - 测试。将所有被测试代码引入到 tests 模块
  - 有时被用于预导入（prelude）模块

```rust
use std::collections::*
```

## 六、将模块拆分为不同文件

### 将模块内容移动到其他文件

- 模块定义时，如果模块名后边是“;”，而不是代码块：
  - Rust会从与模块同名的文件中加载内容
  - 模块树的结构不会变化

未拆分前：src/lib.rs 文件

```rust
mod front_of_house {
  pub mod hosting {
    pub fn add_to_waitlist() {}
  }
}

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
  hosting::add_to_waitlist();
  hosting::add_to_waitlist();
  hosting::add_to_waitlist();
}
```

### 拆分之后

src/lib.rs 文件

```rust
mod front_of_house;

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
  hosting::add_to_waitlist();
  hosting::add_to_waitlist();
  hosting::add_to_waitlist();
}
```

src/front_of_house.rs 文件

```rust
pub mod hosting;
```

src/front_of_house/hosting.rs 文件

```rust
pub fn add_to_waitlist() {}
```

- 随着模块逐渐变大，该技术让你可以把模块的内容移动到其它文件中

## 总结

Rust的模块系统是构建清晰、高效代码的基石。Package作为项目容器，管理多个Crate；Crate作为编译单元，分为binary和library类型；Module则通过分组与私有性控制，让代码更具可读性与复用性。结合pub、use关键字以及路径规则，开发者可以轻松管理代码作用域；通过模块拆分到不同文件，更能提升大型项目的维护性。掌握这些技巧，你将能轻松驾驭Rust的代码组织之道，为开发高质量项目奠定坚实基础。快来动手实践，解锁Rust编程的无限可能吧！

## 参考

- <https://www.anchor-lang.com/docs/clients/rust>
- <https://www.rust-lang.org/zh-CN>
- <https://course.rs/about-book.html>
- <https://crates.io/>
- <https://lab.cs.tsinghua.edu.cn/rust/>
