+++
title = "深入浅出Rust：泛型、Trait与生命周期的硬核指南"
description = "深入浅出Rust：泛型、Trait与生命周期的硬核指南"
date = 2025-05-18T04:36:49Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 深入浅出Rust：泛型、Trait与生命周期的硬核指南

在Rust编程的世界中，泛型、Trait和生命周期是构建高效、可复用代码的三大核心支柱。它们不仅让你的代码更简洁优雅，还能确保内存安全和性能优化。无论是消除重复代码，还是定义灵活的接口，亦或是管理引用的生命周期，掌握这三者将让你在Rust开发中如虎添翼。本文将带你从基础到进阶，结合代码实例，轻松解锁Rust的这些“黑科技”！

本文深入探讨了Rust编程中的泛型、Trait和生命周期三大核心概念。从消除代码重复的函数提取开始，逐步介绍如何利用泛型提高代码复用性，通过Trait定义共享行为，以及借助生命周期管理引用以避免悬垂引用等问题。文章结合清晰的代码示例，涵盖泛型在函数、结构体和枚举中的应用，Trait的定义与实现，以及生命周期的标注规则和实际场景。无论你是Rust新手还是进阶开发者，这篇文章都将为你提供实用的知识和技巧，助你写出更安全、更高效的Rust代码。

## 一、提取函数消除重复

```rust
fn main() {
  let number_list = vec![34, 50, 25, 100, 65];
  let mut largest = number_list[0];
  for number in number_list {
    if number > largest {
      largest = number;
    }
  }
  
  println!("The largest number is {}", largest);
}
```

### 重复代码

- 重复代码的危害：
  - 容易出错
  - 需求变更时需要在多处进行修改
- 消除重复：提取函数

```rust
fn largest(list: &[i32]) -> i32 {
  let mut largest = list[0];
  for &item in list { // &item 解构
    if item > largest {
      largest = item;
    }
  }
  largest
}

fn main() {
  let number_list = vec![34, 50, 25, 100, 65];
  let result = largest(&number_list);
  println!("The largest number is {}", result);
  
  let number_list = vec![102, 34, 6000, 89, 54, 2, 43, 8];
  let result = largest(&number_list);
  println!("The largest number is {}", result);
}
```

### 消除重复的步骤

- 识别重复代码
- 提取重复代码到函数体中，并在函数签名中指定函数的输入和返回值
- 将重复的代码使用函数调用进行替代

## 二、泛型

### 泛型

- 泛型：提高代码复用能力
  - 处理重复代码的问题
- 泛型是具体类型或其它属性的抽象代替：
  - 你编写的代码不是最终的代码，而是一种模版，里面有一些“占位符”
  - 编译器在编译时将“占位符”替换为具体的类型
- 例如：`fn largest<T>(list: &[T]) -> T {...}`  
- 类型参数：
  - 很短，通常一个字母
  - CamelCase
  - T：type 的缩写

### 函数定义中的泛型

- 泛型函数：
  - 参数类型
  - 返回类型

```rust
fn largest<T>(list: &[T]) -> T {
  let mut largest = list[0];
  for &item in list { 
    if item > largest {  // 比较 报错 ToDo 
      largest = item;
    }
  }
  largest
}

fn main() {
  let number_list = vec![34, 50, 25, 100, 65];
  let result = largest(&number_list);
  println!("The largest number is {}", result);
  
  let char_list = vec!['y', 'm', 'a', 'q'];
  let result = largest(&char_list);
  println!("The largest number is {}", result);
}
```

### Struct 定义中的泛型

```rust
struct Point<T> {
  x: T,
  y: T,
}

struct Point1<T, U> {
  x: T,
  y: U,
}

fn main() {
  let integer = Point {x: 5, y: 10};
  let float = Point(x: 1.0, y: 4.0);
  
  let integer1 = Point1 {x: 5, y: 10.0};
}
```

- 可以使用多个泛型的类型参数
  - 太多类型参数：你的代码需要重组为多个更小的单元

### Enum 定义中的泛型

- 可以让枚举的变体持有泛型数据类型
  - 例如 `Option<T>`，`Result<T, E>`

```rust
enum Option<T> {
  Some(T),
  None,
}

enum Result<T, E> {
  Ok(T),
  Err(E),
}

fn main() {}
```

### 方法定义中的泛型

- 为 struct 或 enum 实现方法的时候，可在定义中使用泛型

```rust
struct Point<T> {
  x: T,
  y: T,
}

impl<T> Point<T> {
  fn x(&self) -> &T {
    &self.x
  }
}

impl Point<i32> {
  fn x1(&self) -> &i32 {
    &self.x
  }
}

fn main() {
  let p = Point {x: 5, y: 10};
  println!("p.x = {}", p.x());
}
```

- 注意：
- 把 T 放在 impl 关键字后，表示在类型 T 上实现方法
  - 例如： `impl<T> Point<T>`
- 只针对具体类型实现方法（其余类型没实现方法）：
  - 例如：`impl Point<f32>`
- struct 里的泛型类型参数可以和方法的泛型类型参数不同

```rust
struct Point<T, U> {
  x: T,
  y: U,
}

impl<T, U> Point<T, U> {
  fn mixup<V, W>(self, other: Point<V, W>) -> Point<T, W> {
    Point {
      x: self.x,
      y: other.y,
    }
  }
}

fn main() {
  let p1 = Point {x: 5, y: 4};
  let p2 = Point {x: "Hello", y: 'c'};
  let p3 = p1.mixup(p2);
  
  println!("p3.x = {}, p3.y = {}", p3.x, p3.y);
}
```

### 泛型代码的性能

- 使用泛型的代码和使用具体类型的代码运行速度是一样的。
- 单态化（monomorphization）：
  - 在编译时将泛型替换为具体类型的过程

```rust
fn main() {
  let integer = Some(5);
  let float = Some(5.0);
}

enum Option_i32 {
  Some(i32),
  None,
}

enum Option_f64 {
  Some(f64),
  None,
}

fn main() {
  let integer = Option_i32::Some(5);
  let float = Option_f64::Some(5.0);
}
```

## 三、Trait（上）

### Trait

- Trait 告诉 Rust 编译器：
  - 某种类型具有哪些并且可以与其它类型共享的功能
- Trait：抽象的定义共享行为
- Trait bounds（约束）：泛型类型参数指定为实现了特定行为的类型
- Trait 与其它语言的接口（Interface）类似，但有些区别

### 定义一个 Trait

- Trait 的定义：把方法签名放在一起，来定义实现某种目的所必需的一组行为。
  - 关键字：trait
  - 只有方法签名，没有具体实现
  - trait 可以有多个方法：每个方法签名占一行，以 ; 结尾
  - 实现该 trait 的类型必须提供具体的方法实现

```rust
pub trait Summary {
  fn summarize(&self) -> String;
}

// NewsArticle
// Tweet

fn main() {}
```

### 在类型上实现 trait

- 与为类型实现方法类似
- 不同之处：
  - `impl xxxx for Tweet {...}`
  - 在 impl 的块里，需要对 Trait 里的方法签名进行具体的实现

lib.rs 文件

```rust
pub trait Summary {
  fn summarize(&self) -> String;
}

pub struct NewsArticle {
  pub headline: String,
  pub location: String,
  pub author: String,
  pub content: String,
}

impl Summary for NewsArticle {
  fn summarize(&self) -> String {
    format!("{}, by {} ({})", self.headline, self.author, self.location)
  }
}

pub struct Tweet {
  pub username: String,
  pub content: String,
  pub reply: bool,
  pub retweet: bool,
}

impl Summary for Tweet {
  fn summarize(&self) -> String {
    format!("{}: {}", self.username, self.content)
  }
}
```

main.rs 文件

```rust
use demo::Summary;
use demo::Tweet;

fn main() {
  let tweet = Tweet {
    username: String::from("horse_ebooks"),
    content: String::from("of course, as you probably already know, people"),
    reply: false,
    retweet: false,
  };
  
  println!("1 new tweet: {}", tweet.summarize())
}
```

### 实现 trait 的约束

- 可以在某个类型上实现某个 trait 的前提条件是：
  - 这个类型或这个 trait 是在本地 crate 里定义的
- 无法为外部类型来实现外部的 trait：
  - 这个限制是程序属性的一部分（也就是一致性）
  - 更具体地说是孤儿规则：之所以这样命名是因为父类型不存在
  - 此规则确保其他人的代码不能破坏您的代码，反之亦然
  - 如果没有这个规则，两个crate 可以为同一类型实现同一个 trait，Rust就不知道应该使用哪个实现了

### 默认实现

lib.rs 文件

```rust
pub trait Summary {
  // fn summarize(&self) -> String;
  fn summarize(&self) -> String {
    String::from("(Read more...)")
  }
}

pub struct NewsArticle {
  pub headline: String,
  pub location: String,
  pub author: String,
  pub content: String,
}

impl Summary for NewsArticle {
  // fn summarize(&self) -> String {
   // format!("{}, by {} ({})", self.headline, self.author, self.location)
  // }
}

pub struct Tweet {
  pub username: String,
  pub content: String,
  pub reply: bool,
  pub retweet: bool,
}

impl Summary for Tweet {
  fn summarize(&self) -> String {
    format!("{}: {}", self.username, self.content)
  }
}
```

main.rs 文件

```rust
use demo::NewsArticle;
use demo::Summary;

fn main() {
  let article = NewsArticle {
    headline: String::from("Penguins win the Stanley Cup Championship!"),
    content: String::from("The pittsburgh penguins once again are the best hockey team in the NHL."),
    author: String::from("Iceburgh"),
    location: String::from("Pittsburgh, PA, USA"),
  };
  
  println!("1 new tweet: {}", article .summarize())
}
```

- 默认实现的方法可以调用 trait 中其它的方法，即使这些方法没有默认实现。

```rust
pub trait Summary {
  fn summarize_author(&self) -> String;
  
  fn summarize(&self) -> String {
    format!("Read more from {} ...", self.summarize_author())
  }
}

pub struct NewsArticle {
  pub headline: String,
  pub location: String,
  pub author: String,
  pub content: String,
}

impl Summary for NewsArticle {
  fn summarize_author(&self) -> String {
    format!("@{}", self.author)
  }
}
```

- 无法从方法的重写实现里面调用默认的实现

## 四、Trait（下）

### Trait 作为参数

```rust
pub fn notify(item: impl Summary) {
  println!("Breaking news! {}", item.summarize());
}
```

- impl Trait 语法：适用于简单情况
- Trait bound 语法：可用于复杂情况
  - impl Trait 语法是 Trait bound 的语法糖

```rust
pub fn notify<T: Summary>(item: T) {
  println!("Breaking news! {}", item.summarize());
}
```

- 使用 + 指定多个 Trait bound

```rust
pub fn notify(item: impl Summary + Display) {
  println!("Breaking news! {}", item.summarize());
}

pub fn notify<T: Summary + Display>(item: T) {
  println!("Breaking news! {}", item.summarize());
}
```

- Trait bound 使用where 子句
  - 在方法签名后指定 where 子句

```rust
pub fn notify<T: Summary + Display, U: Clone + Debug>(a: T, b: U) -> String {
  format!("Breaking news! {}", a.summarize())
}

pub fn notify<T, U>(a: T, b: U) -> String
where 
 T: Summary + Display, 
 U: Clone + Debug,
{
  format!("Breaking news! {}", a.summarize())
}
```

### 实现 Trait 作为返回类型

- impl Trait 语法

```rust
pub fn notify1(s: &str) -> impl Summary {
  NewsArticle {
    headline: String::from("Penguins win the Stanley Cup Championship!"),
    content: String::from("The Pittsburgh Penguins once again are the best hockey team in the NHL."),
    author: String::from("Iceburgh"),
    location: String::from("Pittsburgh, PA, USA"),
  }
}
```

- 注意： impl Trait 只能返回确定的同一种类型，返回可能不同类型的代码会报错

### 使用 Trait Bound 的例子

- 例子：使用 Trait Bound 修复 largest 函数

```rust
fn largest<T: PartialOrd + Clone>(list: &[T]) -> T {
  let mut largest = list[0].clone();
  
  for item in list.iter() {
    if item > &largest { // std::cmp::ParticalOrd
      largest = item.clone();
    }
  }
  
  largest
}

fn main() {
  let number_list = vec![34, 50, 25, 100, 65];
  let result = largest(&number_list);
  println!("The largest number is {}", result);
  
  let char_list = vec!['y', 'm', 'a', 'q'];
  let result = largest(&char_list);
  println!("The largest char is {}", result)
}


fn largest<T: PartialOrd + Clone>(list: &[T]) -> &T {
  let mut largest = &list[0];
  
  for item in list.iter() {
    if item > &largest { // std::cmp::ParticalOrd
      largest = item;
    }
  }
  
  largest
}

fn main() {
  let str_list = vec![String::from("hello"), String::from("world")];
  let result = largest(&str_list);
  println!("The largest word is {}", result);
  
}
```

### 使用 Trait Bound 有条件的实现方法

- 在使用泛型类型参数的 impl 块上使用 Trait Bound，我们可以有条件的为实现了特定 Trait的类型来实现方法

```rust
use std::fmt::Display;

struct Pair<T> {
  x: T,
  y: T,
}

impl<T> Pair<T> {
  fn new(x: T, y: T) -> Self {
    Self {x, y}
  }
}

impl<T: Display + PartialOrd> Pair<T> {
  fn cmp_display(&self) {
    if self.x >= self.y {
      println!("The largest member is x = {}", self.x);
    } else {
      println!("The largest member is y = {}", self.y);
    }
  }
}
```

- 也可以为实现了其它Trait的任意类型有条件的实现某个Trait
- 为满足Trait Bound 的所有类型上实现 Trait 叫做覆盖实现（blanket implementations）

```rust
fn main() {
  let s = 3.to_string();
}
```

## 五、生命周期（1/4）

### 生命周期

- Rust的每个引用都有自己的生命周期
- 生命周期：引用保持有效的作用域
- 大多数情况：生命周期是隐式的、可被推断的
- 当引用的生命周期可能以不同的方式互相关联时：手动标注生命周期。

### 生命周期 - 避免悬垂引用(dangling regerence)

- 生命周期的主要目标：避免悬垂引用(dangling regerence)

```rust
fn main() {
  {
    let r;
    {
      let x = 5;
      r = &x; // 报错
    }
    println!("r: {}", r);
  }
}
```

### 借用检查器

- Rust编译器的借用检查器：比较作用域来判断所有的借用是否合法。

```rust
fn main() {
  let x = 5;
  let r = &x;
  
  println!("r: {}", r);
}
```

### 函数中的泛型生命周期

```rust
fn main() {
  let string1 = String::from("abcd");
  let string2 = "xyz";
  
  let result = longest(string1.as_str(), string2);
  
  println!("The longest string is {}", result);
}

fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
  if x.len() > y.len() {
    x
  } else {
    y
  }
}
```

## 六、生命周期（2/4）

### 生命周期标注语法

- 生命周期的标注不会改变引用的生命周期长度
- 当指定了泛型生命周期参数，函数可以接收带有任何生命周期的引用
- 生命周期的标注：描述了多个引用的生命周期间的关系，但不影响生命周期

### 生命周期标注 - 语法

- 生命周期参数名：
  - 以 '  开头
  - 通常全小写且非常短
  - 很多人使用 'a
- 生命周期标注的位置：
  - 在引用的 & 符号后
  - 使用空格将标注和引用类型分开

### 生命周期标注 - 例子

- &i32  // 一个引用
- &'a i32  // 带有显示生命周期的引用
- &'a mut i32  // 带有显示生命周期的可变引用
- 单个生命周期标注本身没有意义

### 函数签名中的生命周期标注

- 泛型生命周期参数声明在：函数名和参数列表之间的 <>里
- 生命周期 'a 的实际生命周期是：x 和 y 两个生命周期中较小的那个

```rust
fn main() {
  let string1 = String::from("abcd");
  let result;
  {
    let string2 = String::from("xyz");
    let result = longest(string1.as_str(), string2.as_str());  // 报错 string2
  }
 
  println!("The longest string is {}", result);
}

fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
  if x.len() > y.len() {
    x
  } else {
    y
  }
}
```

## 七、生命周期（3/4）

### 深入理解生命周期

- 指定生命周期参数的方式依赖于函数所做的事情

```rust
fn main() {
  let string1 = String::from("abcd");
  let string2 = "xyz";
  
  let result = longest(string1.as_str(), string2);
  
  println!("The longest string is {}", result);
}

fn longest<'a>(x: &'a str, y: &str) -> &'a str {
  x
}
```

- 从函数返回引用时，返回类型的生命周期参数需要与其中一个参数的生命周期匹配
- 如果返回的引用没有指向任何参数，那么它只能引用函数内创建的值

```rust
fn main() {
  let string1 = String::from("abcd");
  let string2 = "xyz";
  
  let result = longest(string1.as_str(), string2);
  
  println!("The longest string is {}", result);
}

fn longest<'a>(x: &'a str, y: &str) -> &'a str {
  let result = String::from("abc");
  result.as_str()  // 报错 
}

fn longest<'a>(x: &'a str, y: &str) -> String {
  let result = String::from("abc");
  result
}
```

### Struct 定义中的生命周期标注

- Struct 里可包括：
  - 自持有的类型
  - 引用：需要在每个引用上添加生命周期标注

```rust
struct ImportantExcerpt<'a> {
  part: &'a str,
}

fn main() {
  let novel = String::from("Call me Ishmael. Some years ago ...")
  
  let first_sentence = novel.split('.')
   .next()
   .expect("Could not found a '.'");
  
  let i = ImportantExcerpt {
    part: first_sentence
  };
}
```

### 生命周期的省略

- 我们知道：
  - 每个引用都有生命周期
  - 需要为使用生命周期的函数或Struct指定生命周期参数

### 生命周期省略规则

- 在Rust引用分析中所编入的模式称为生命周期省略规则。
  - 这些规则无需开发者来遵守
  - 它们是一些特殊情况，由编译器来考虑
  - 如果你的代码符合这些情况，那么就无需显式标注生命周期
- 生命周期省略规则不会提供完整的推断：
  - 如果应用规则后，引用的生命周期仍然模糊不清-> 编译错误
  - 解决办法：添加生命周期标注，表明引用间的相互关系

### 输入、输出生命周期

- 生命周期在：
  - 函数/方法的参数：输入生命周期
  - 函数/方法的返回值：输出生命周期

### 生命周期省略的三个规则

- 编译器使用3个规则在没有显示标注生命周期的情况下，来确定引用的生命周期
  - 规则 1 应用于输入生命周期
  - 规则 2、3 应用于输出生命周期
  - 如果编译器应用完 3 个规则之后，仍然有无法确定生命周期的引用 -> 报错
  - 这些规则适用于 fn 定义和 impl 块
- 规则 1：每个引用类型的参数都有自己的生命周期
- 规则 2：如果只有 1 个输入生命周期参数，那么该生命周期被赋给所有的输出生命周期参数
- 规则 3：如果有多个输入生命周期参数，但其中一个是 &self 或 &mut self （是方法），那么 self 的生命周期会被赋给所有的输出生命周期参数

### 生命周期省略的三个规则 - 例子

- 假设我们是编译器：
- `fn first_word(s: &str) -> &str {`
- `fn first_word<'a>(s: &'a str) -> &str {`
- `fn first_word<'a>(s: &'a str) -> &'a str {`
- `fn longest(x: &str, y: &str) -> &str{`
- `fn longest<'a, 'b>(x: &'a str, y: &'b str) -> &str{`  // 报错

## 八、生命周期（4/4）

### 方法定义中的生命周期标注

- 在 Struct 上使用生命周期实现方法，语法和泛型参数的语法一样
- 在哪声明和使用生命周期参数，依赖于：
  - 生命周期参数是否和字段、方法的参数或返回值有关
- Struct 字段的生命周期名：
  - 在 impl 后声明
  - 在 struct 名后声明
  - 这些声明周期是 Struct 类型的一部分
- impl 块内的方法签名中：
  - 引用必须绑定于 Struct 字段引用的生命周期，或者引用是独立的也可以
  - 生命周期省略规则经常使得方法中的生命周期标注不是必须的

```rust
struct ImportantExcerpt<'a> {
  part: &'a str,
}

impl<'a> ImportantExcerpt<'a> {
  fn level(&self) -> i32 {
    3
  }
  
  fn snnounce_and_return_part(&self, announcement: &str) -> &str {
    println!("Attention please: {}", announcement);
    self.part
  }
}

fn main() {
  let novel = String::from("Call me Ishmael. Some years ago ...")
  
  let first_sentence = novel.split('.')
   .next()
   .expect("Could not found a '.'");
  
  let i = ImportantExcerpt {
    part: first_sentence,
  };
}
```

### 静态生命周期

- 'static 是一个特殊的生命周期：整个程序的持续时间。
  - 例如：所有的字符串字面值都拥有 ‘static 生命周期
  - `let s: &'static str = "I have a static lifetime.";`
- 为引用指定 ’static 生命周期前要三思：
  - 是否需要引用在程序整个生命周期内都存活。

### 泛型参数类型、Trait Bound、生命周期

```rust
use std::fmt::Display;

fn longest_with_an_announcement<'a, T>(x: &'a str, y: &'a str, ann: T) -> &'a str
where
 T: Display,
{
  println!("Announcement! {}", ann);
  if x.len() > y.len() {
    x
  } else {
    y
  }
}

fn main() {}
```

## 总结

泛型、Trait和生命周期是Rust编程中不可或缺的工具，它们共同构成了Rust代码安全性和灵活性的基石。通过泛型，我们可以编写高度复用的代码；通过Trait，我们可以定义类型间的共享行为；通过生命周期，我们确保引用的正确性和内存安全。本文从实际代码出发，带你一步步掌握这些概念的应用场景和实现方法。希望你能将这些知识融入到自己的Rust项目中，写出更优雅、更高效的代码！快动手实践吧，Rust的魅力等待你去探索！

## 参考

- <https://www.reddit.com/r/rust/>
- <https://www.rust-lang.org/zh-CN>
- <https://crates.io/>
- <https://course.rs/about-book.html>
- <https://rustwiki.org/zh-CN/rust-cookbook/web/clients/requests.html>
