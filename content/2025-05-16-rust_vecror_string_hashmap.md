+++
title = "Rust 集合类型解析：Vector、String、HashMap"
description = "Rust 集合类型解析：Vector、String、HashMap"
date = 2025-05-16T07:33:16Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust 集合类型解析：Vector、String、HashMap

Rust 作为一门兼顾性能与内存安全的系统编程语言，其标准库中的集合类型为开发者提供了高效的数据管理工具。本文聚焦 Rust 中三种核心集合类型——Vector、String 和 HashMap，通过详细讲解和代码示例，剖析它们的基本原理、用法及注意事项。无论你是 Rust 新手还是进阶开发者，本文都将为你提供清晰的指引，助你更好地掌握这些集合类型在实际开发中的应用。

本文系统解析 Rust 的三大集合类型：Vector、String 和 HashMap。Vector 提供动态数组功能，适合连续存储同类型数据；String 支持可变 UTF-8 字符串操作；HashMap 实现键值对高效查询。文章通过代码示例详细介绍创建、更新、遍历及所有权管理等操作，揭示字符串索引限制及 HashMap 更新策略，帮助开发者在 Rust 项目中灵活运用这些工具。

## 常用的集合

- Vector
- String
- HashMap

## 一、 Vector

### 使用 Vector 存储多个值

- `Vec<T>`，叫做 vector
  - 由标准库提供
  - 可存储多个值
  - 只能存储相同类型的数据
  - 值在内存中连续存放

### 创建 Vector

- Vec::new 函数
- 使用初始值创建 `Vec<T>`，使用 vec! 宏

```rust
fn main() {
    // let v: Vec<i32> = Vec::new();
    let v = vec![1, 2, 3];
}

```

### 更新 Vector

- 向 Vector 添加元素，使用 push 方法

```rust
fn main() {
    let mut v = Vec::new();
    
    v.push(1);
    v.push(2);
    v.push(3);
    v.push(4);
}

```

### 删除 Vector

- 与任何其他 struct 一样，当 Vector 离开作用域后
  - 它就被清理掉了
  - 它所有的元素也被清理掉了

### 读取 Vector 的元素

- 两种方式可以引用 Vector 里的值：
  - 索引
  - get 方法

```rust
fn main() {
    let v = vec![1, 2, 3, 4, 5];
    let third: &i32 = &v[2];
    println!("The third element is {}", third);

    match v.get(2) {
        Some(third) => println!("The third element is {}", third),
        None => println!("The third element is not found"),
        
    }
}
```

### 索引 VS get 处理访问越界

- 索引：panic
- get：返回 None

### 所有权和借用规则

- 不能在同一作用域内同时拥有可变和不可变引用

```rust
fn main() {
  let mut v = vec![1,2,3,4,5];
  let first = &v[0];
  v.push(6); // 报错
  println!("The first element is {}", first);
}
```

### 遍历 Vector 中的值

- for 循环

```rust
fn main() {
  let v = vec![100, 32, 57];
  for i in &v {
    println!("{}", i);
  }
  
  let mut v = vec![100, 32, 57];
  for i in &mut v {
    *i += 50;
  }
  
   for i in v {
    println!("{}", i);
  }
}
```

## 二、Vector - 例子

### 使用 enum 来存储多种数据类型

- Enum 的变体可以附加不同类型的数据
- Enum 的变体定义在同一个 enum 类型下

```rust
enum SpreadsheeetCell {
      Int(i32),
      Float(f64),
      Text(String),
}

fn main() {
  let row = vec![
    SpreadsheetCell::Int(3),
    SpreadsheetCell::Text(String::from("blue")),
    SpreadsheetCell::Float(10.12),
  ];
}
```

## 三、String（上）

### Rust开发者经常会被字符串困扰的原因

- Rust倾向于暴露可能得错误
- 字符串数据结构复杂
- UTF-8

### 字符串是什么

- Byte 的集合
- 一些方法
  - 能将 byte 解析为文本
- Rust的核心语言层面，只有一个字符串类型：字符串切片 str（或 &str）
- 字符串切片：对存储在其它地方、UTF-8编码的字符串的引用
  - 字符串字面值：存储在二进制文件中，也是字符串切片
- String 类型：
  - 来自标准库而不是核心语言
  - 可增长、可修改、可拥有
  - UTF-8 编码

### 通常说的字符串是指？

- String 和 &str
  - 标准库里用的多
  - UTF-8 编码

### 其它类型的字符串

- Rust的标准库还包含了很多其它的字符串类型，例如：OsString、OsStr、CString、CStr
  - String vs Str 后缀：拥有或借用的变体
  - 可存储不同编码的文本或在内存中以不同的形式展现
- Library crate 针对存储字符串可提供更多的选项

### 创建一个新的字符串（String）

- 很多 `Vec<T>` 的操作都可用于 String
- String::new() 函数

```rust
fn main() {
  let mut s = String::new();
}
```

- 使用初始值来创建 String：
  - to_string() 方法，可用于实现了 Display trait 的类型，包括字符串字面值
  - String::from() 函数，从字面值创建 String

```rust
fn main() {
  let data = "initial contents";
  let s = data.to_string();
  
  let s1 = "initial contents".to_string();
  
  let s = String::from("initial contents");
}
```

- UTF-8 编码

### 更新 String

- push_str() 方法：把一个字符串切片附加到String

```rust
fn main() {
  let mut s = String::from("foo");
  s.push_str("bar");
  
  println!("{}", s);
}
```

- push() 方法：把单个字符附加到String

```rust
fn main() {
  let mut s = String::from("lo");
  s.push('l');
}
```

- `+` ：连接字符串
  - 使用了类似这个签名的方法 `fn add(self, s:&str) -> String {...}`
    - 标准库中的 add 方法使用了泛型
    - 只能把 &str 添加到 String
    - 解引用强制转换（deref coercion）

```rust
fn main() {
  let s1 = String::from("Hello, ");
  let s2 = String::from("World!");
  
  let s3 = s1 + &s2; // &s2 把String的引用转换成字符串切片所以编译通过（解引用强制转换）所有权保留
  
  println!("{}", s3);
  println!("{}", s1); // 报错 s1不可以继续使用
  println!("{}", s2);
}
```

- `format!`：连接多个字符串
  - 和 println!() 类似，但返回字符串
  - 不会获得参数的所有权

```rust
fn main() {
  let s1 = String::from("tic");
  let s2 = String::from("tac");
  let s3 = String::from("toe");
  
  // let s3 = s1 + "-" + &s2 + "-" + &s3;
  // println!("{}", s3);
  
  let s = format!("{}-{}-{}", s1, s2, s3);
  println!("{}", s);
}
```

## 四、String（下）

### 对 String 按索引的形式进行访问

- 按索引语法访问String的某部分，会报错

```rust
fn main() {
  let s1 = String::from("hello");
  let h = s1[0]; // 报错
}
```

- Rust的字符串不支持索引语法访问

### 内部表示

- String 是对 `Vec<u8>` 的包装
  - len() 方法 （字节数）

```rust
fn main() {
  let len = String::from("Hola").len();
  // Unicode 标量值
  
  println!("{}", len);
}
```

### 字节(Bytes)、标量值(Scalar Values)、字形簇(Grapheme Clusters)

- Rust有三种看待字符串的方式：
  - 字节
  - 标量值
  - 字形簇（最接近所谓的“字母”）

```rust
fn main() {
  let w = "redis";
  
  for b in w.bytes() { // 字节
    println!("{}", b);
  }
  
   for b in w.chars() { // 标量值
    println!("{}", b);
   }
}
```

- Rust不允许对String进行索引的最后一个原因：
  - 索引操作应消耗一个常量时间 (O(1))
  - 而String无法保证：需要遍历所有内容，来确定有多少个合法的字符

### 切割 String

- 可以使用 [] 和一个范围来创建字符串的切片
  - 必须谨慎使用
  - 如果切割时跨域了字符边界，程序就会 panic

```rust
fn main() {
  let hello = "creative";
  let s = &hello[0..4];
  
  println!("{}", s)
}
```

### 遍历 String 的方法

- 对于标量值：chars() 方法
- 对于字节：bytes() 方法
- 对于字形簇：很复杂，标准库未提供

### String 不简单

- Rust选择将正确处理String数据作为所有Rust程序的默认行为
  - 程序员必须在处理UTF-8数据之前投入更多的精力
- 可防止在开发后期处理涉及非 ASCII 字符的错误

## 五、HashMap（上）

### `HashMap<K, V>`

- 键值对的形式存储数据，一个键（Key）对应一个值（Value）
- Hash 函数：决定如何在内存中存放 K 和 V
- 使用场景：通过 K （任何类型）来寻找数据，而不是通过索引

### 创建 HashMap

- 创建空 HashMap：new() 函数
- 添加数据：insert() 方法

```rust
use std::collections::HashMap;

fn main() {
   let mut scores = HashMap::new();

   scores.insert(String::from("Blue"), 10);
   scores.insert(String::from("Yellow"), 50);
}

```

### HashMap

- HashMap 用的较少，不在 Prelude 中
- 标准库对其支持较少，没有内置的宏来创建 HashMap
- 数据存储在 heap上
- 同构的。一个HashMap中：
  - 所有的K必须是同一种类型
  - 所有的V必须是同一种类型

### 另一种创建 HashMap 的方式：collect 方法

- 在元素类型为Tuple的 Vector 上使用 collect 方法，可以组建一个 HashMap：
  - 要求 Tuple有两个值：一个作为K，一个作为 V
  - collect 方法可以把数据整合成很多种集合类型，包括 HashMap
    - 返回值需要显示指明类型

```rust
use std::collections::HashMap;

fn main() {
    let teams = vec![String::from("Blue"), String::from("Yellow")];
    let intial_scores = vec![10, 50];

    let scores: HashMap<_, _> = 
        teams.iter().zip(intial_scores.iter()).collect();
}

```

### HashMap 和所有权

- 对于实现了 Copy trait 的类型（例如 i32），值会被复制到 HashMap 中
- 对于拥有所有权的值（例如 String），值会被移动，所有权会转移给 HashMap

```rust
use std::collections::HashMap;

fn main() {
    let field_name = String::from("Favorite Color");
    let field_value = String::from("Blue");

    let mut map = HashMap::new();
    map.insert(field_name, field_value);

    // println!("{}: {}", field_name, field_value);  // 报错 借用了移动的值
}
```

- 如果将值的引用插入到 HashMap，值本身不会移动
  - 在 HashMap 有效的期间，被引用的值必须保持有效

```rust
use std::collections::HashMap;

fn main() {
    let field_name = String::from("Favorite Color");
    let field_value = String::from("Blue");

    let mut map = HashMap::new();
    map.insert(&field_name, &field_value);

    println!("{}: {}", field_name, field_value);  
}
```

### 访问 HashMap 中的值

- get 方法
  - 参数：K
  - 返回：Option<&V>

```rust
use std::collections::HashMap;

fn main() {
  let mut scores = HashMap::new();
  
  scores.insert(String::from("Blue"), 10);
  scores.insert(String::from("Yellow"), 50);
  
  let team_name = String::from("Blue");
  let score = scores.get(&team_name);
  
  match score {
    Some(s) => println!("{}", s),
    None => println!("team not exist"),
  };
}
```

### 遍历 HashMap

- for 循环

```rust
use std::collections::HashMap;

fn main() {
  let mut scores = HashMap::new();
  
  scores.insert(String::from("Blue"), 10);
  scores.insert(String::from("Yellow"), 50);
  
  for (k, v) in &scores {
    println!("{}: {}", k, v);
  }
}
```

## 六、HashMap（下）

### 更新 HashMap<K, V>

- HashMap 大小可变
- 每个K同时只能对应一个 V
- 更新 HashMap 中的数据：
  - K 已经存在，对应一个 V
    - 替换现有的 V
    - 保留现有的 V，忽略新的 V
    - 合并现有的 V 和新的 V
  - K 不存在
    - 添加一对 K，V

### 替换现有的 V

- 如果向 HashMap 插入一对 KV，然后再插入同样的 K，但是不同的 V，那么原来的 V 会被替换掉

```rust
use std::collections::HashMap;

fn main() {
  let mut scores = HashMap::new();
  
  scores.insert(String::from("Blue"), 10);
  scores.insert(String::from("Blue"), 25);
  
  println!("{:?}", scores);
  
}
```

### 只在 K 不对应任何值的情况下，才插入 V

- entry 方法：检查指定的 K 是否对应一个 V
  - 参数为 K
  - 返回 enum Entry：代表值是否存在

```rust
use std::collections::HashMap;

fn main() {
  let mut scores = HashMap::new();
  
  scores.insert(String::from("Blue"), 10);
  
  scores.entry(String::from("Yellow")).or_insert(50);
  scores.entry(String::from("Blue")).or_insert(50);  // Blue 存在不会插入
  
  println!("{:?}", scores);
  
}
```

- Entry 的 or_insert() 方法：
  - 返回：
    - 如果 K 存在，返回到对应的 V 的一个可变引用
    - 如果 K 不存在，将方法参数作为 K 的新值插进去，返回到这个值的可变引用

### 基于现有的 V 来更新 V

```rust
use std::collections::HashMap;

fn main() {
  let text = "hello world wonderful world";
  
  let mut map = HashMap::new();
  
  for word in text.split_whitespace() { // 按空格分隔
    let count = map.entry(word).or_insert(0); // 返回可变引用
    *count += 1; // 解引用 加1
  }
  
  println!("{:#?}", map);
}
```

### Hash 函数

- 默认情况下，HashMap 使用加密功能强大的 Hash 函数，可以抵抗拒绝服务(DoS) 攻击。
  - 不是可用的最快的 Hash 算法
  - 但具有更好安全性
- 可以指定不同的 hasher 来切换到另一个函数。
  - hasher 是实现 BuildHasher trait 的类型
  
## 总结

Rust 的 Vector、String 和 HashMap 是高效数据处理的基础工具。Vector 提供连续存储的灵活性，String 适配复杂的 UTF-8 字符串操作，HashMap 则以键值对实现快速数据访问。本文通过详尽的代码示例和解析，阐明了它们的使用方法及内存安全特性。掌握这些集合类型，不仅能提升 Rust 编程效率，还能帮助开发者编写更健壮的代码，应对多样化的开发需求。

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://course.rs/about-book.html>
- <https://lab.cs.tsinghua.edu.cn/rust/>
- <https://github.com/rustcn-org/async-book>
- <https://rustwiki.org/zh-CN/edition-guide/rust-2018/cargo-and-crates-io/cargo-install-for-easy-installation-of-tools.html>
- <https://awesome-rust.com/>
