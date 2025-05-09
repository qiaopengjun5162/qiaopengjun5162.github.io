+++
title = "Rust 入门教程：变量到数据类型，轻松掌握"
description = "Rust 入门教程：变量到数据类型，轻松掌握"
date = 2025-05-09T04:02:00Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust 入门教程：变量到数据类型，轻松掌握

想学一门既强大又安全的编程语言？Rust 绝对值得一试！这篇教程专为初学者打造，带你轻松掌握 Rust 的核心基础——从变量的声明与可变性，到数据类型和复合类型的应用。代码示例简单直观，零基础也能快速上手！快来一起探索 Rust 的魅力，开启你的系统编程新旅程！

这篇 Rust 入门教程让你快速掌握编程基础！通过通俗的讲解和实用代码示例，带你学会变量与可变性、标量类型（整数、浮点数等）以及元组和数组的使用。无需复杂背景，轻松搞定 Rust 核心技能，适合所有编程新手！

## 变量与可变性

- 声明变量使用`let`关键字
- 默认情况下，变量是不可变的（Immutable）
  - （例子 variables）
- 声明变量时，在变量前面加上`mut`，就可以使变量可变。

```bash
~/rust
➜ cargo new variables
     Created binary (application) `variables` package

~/rust
➜ cd var*

variables on  master [?] via 🦀 1.67.1
➜ code .

variables on  master [?] via 🦀 1.67.1
➜
```

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img/202302250858666.png)

### 代码

```rust
fn main() {
    println!("Hello, world!");

    let mut x = 5;
    println!("The value of x is {}", x);

    x = 6;
    println!("The value of x is {}", x);
}

```

### 变量与常量

- 常量（constant），常量在绑定值以后也是不可变的，但是它与不可变的变量有很多区别：
  - 不可以使用`mut`，常量永远都是不可变的
  - 声明常量使用`const`关键字，它的类型必须被标注
  - 常量可以在任何作用域内进行声明，包括全局作用域
  - 常量只可以绑定到常量表达式，无法绑定到函数的调用结果或只能在运行时才能计算出的值
- 在程序运行期间，常量在其声明的作用域内一直有效
- 命名规范：Rust里常量使用全大写字母，每个单词之间用下划线分开，例如：`MAX_POINTS`
- 例子：`const MAX_POINTS: u32 = 100_000;`

### Shadowing（隐藏）

- 可以使用相同的名字声明新的变量，新的变量就会shadow（隐藏）之前声明的同名变量
  - 在后续的代码中这个变量名代表的就是新的变量
- Shadow 和把变量标记为mut是不一样的：
  - 如果不使用let关键字，那么重新给非mut的变量赋值会导致编译时错误
  - 而使用let声明的同名新变量，也是不可变的
  - 使用let声明的同名新变量，它的类型可以与之前不同

```rust
// const MAX_POINTS: u32 = 100_000;

fn main() {
    // const MAX_POINTS: u32 = 100_000;
    println!("Hello, world!");

    let mut x = 5;
    println!("The value of x is {}", x);

    x = 6;
    println!("The value of x is {}", x);

    let x = x + 1;
    let x = x * 2;
    println!("The value of x is {}", x);

    let spaces = "    ";
    let spaces = spaces.len();
    println!("The length of spaces is {}", spaces);
  
   let guess: u32 = "42".parse().expect("Not a number");

    println!("The guess is {}", guess);
}

```

## 数据类型

- 标量和复合类型
- Rust是静态编译语言，在编译时必须知道所有变量的类型
  - 基于使用的值，编译器通常能够推断出它的具体类型
  - 但如果可能的类型比较多（例如把String转为整数的parse方法），就必须添加类型的标注，否则编译会报错

## 标量类型

- 一个标量类型代表一个单个的值
- Rust有四个主要的标量类型：
  - 整数类型
  - 浮点类型
  - 布尔类型
  - 字符类型

### 整数类型

- 整数类型没有小数部分
- 例如u32就是一个无符号的整数类型，占据32位的空间
- 无符号整数类型以u开头
- 有符号整数类型以i开头
- Rust的整数类型列表：
  - 每种都分i和u，以及固定的位数
  - 有符号范围： -(2^n-1)到2^{n-1}-1
  - 无符号范围：0到2^n-1

| length  | signed | unsigned |
| :------ | ------ | -------- |
| 8-bit   | i8     | u8       |
| 16-bit  | i16    | u16      |
| 32-bit  | i32    | u32      |
| 64-bit  | i64    | u64      |
| 128-bit | i128   | u128     |
| arch    | isize  | usize    |

#### isize和usize类型

- isize和usize类型的位数由程序运行的计算机的架构所决定：
  - 如果是64位计算机，那就是64位的
  - ...
- 使用isize或usize的主要场景是对某种集合进行索引操作。

#### 整数字面值

十进制、十六进制、八进制、二进制、byte

- 除了byte类型外，所有的数值字面值都允许使用类型后缀。例如 57u8
- 如果你不太清楚应该使用那种类型，可以使用Rust相应的默认类型
- 整数的默认类型就是i32，总体上来说速度很快，即使在64位系统中

#### 整数溢出

- 例如：u8的范围是0-255，如果你把一个u8变量的值设为256，那么：
  - 调试模型下编译：Rust会检查整数溢出，如果发生溢出，程序在运行时就会panic
  - 发布模型下(--release)编译：Rust不会检查可能导致panic的整数溢出
    - 如果溢出发生：Rust会执行“环绕”操作：256变成0,257变成1... 但程序不会panic

### 浮点类型

- Rust有两种基础的浮点类型，也就是含有小数部分的类型
  - f32，32位，单精度
  - f64，64位，双精度
- Rust 的浮点类型使用了IEEE-754标准来表述
- f64是默认类型，因为在现代CPU上f64和f32的速度差不多，而且精度更高。

#### 数值操作

- 加减乘除余等

### 布尔类型

- Rust的布尔类型也有两个值：true 和 false
- 一个字节大小
- 符号是bool

### 字符类型

- Rust语言中char类型被用来描述语言中最基础的单个字符
- 字符类型的字面值使用单引号
- 占用4字节大小
- 是Unicode标量值，可以表示比ASCII多得多的字符内容：拼音、中日韩文、零长度空白字符、emoji表情等
  - U+0000 到 U+D7FF
  - U+E000 到 U+10FFFF
- 但Unicode中并没有“字符”的概念，所以直觉上认为的字符也许与Rust中的概念并不相符

```rust
// const MAX_POINTS: u32 = 100_000;

fn main() {
    // const MAX_POINTS: u32 = 100_000;
    println!("Hello, world!");

    let mut x = 5;
    println!("The value of x is {}", x);

    x = 6;
    println!("The value of x is {}", x);

    let x = x + 1;
    let x = x * 2;
    println!("The value of x is {}", x);

    let spaces = "    ";
    let spaces = spaces.len();
    println!("The length of spaces is {}", spaces);

    let guess: u32 = "42".parse().expect("Not a number");

    println!("The guess is {}", guess);

    // let x = 2.0; // f64

    // let y: f32 = 3.0; // f32

    // let sum = 5 + 10;

    // let difference = 95.5 - 4.3;

    // let product = 4 * 30;

    // let quotient = 56.7 / 32.2;

    // let reminder = 54 % 5;

    // let t = true;

    // let f: bool = false;

    // let x = 'z';
    // let y: char = 'a';
    // let z = '😘';
}

```

## 复合类型

- 复合类型可以将多个值放在一个类型里
- Rust提供了两种基础的复合类型：元组（Tuple）、数组

### Tuple

- Tuple  可以将多个类型的多个值放在一个类型里
- Tuple  的长度是固定的：一旦声明就无法改变

#### 创建Tuple

- 在小括号里，将值用逗号分开
- Tuple 中的每个位置都对应一个类型，Tuple中各元素的类型不必相同

#### 获取Tuple的元素值

- 可以使用模式匹配来解构（destructure）一个Tuple来获取元素的值

#### 访问Tuple的元素

- 在Tuple变量使用点标记法，后接元素的索引号

```rust
fn main() {

    let tup: (i32, f64, u8) = (500, 6.4, 1);

    println!("{}, {}, {}", tup.0, tup.1, tup.2);

    let (x, y, z) = tup;
    println!("{}, {}, {}", x, y, z);
}

```

### 数组

- 数组也可以将多个值放在一个类型里
- 数组中每个元素的类型必须相同
- 数组的长度也是固定的

#### 声明一个数组

- 在中括号里，各值用逗号分开

#### 数组的用处

- 如果想让你的数据存放在stack（栈）上而不是heap（堆）上，或者想保证有固定数量的元素，这时使用数组更有好处
- 数组没有Vector灵活
  - Vector和数组类似，它由标准款提供
  - Vector的长度可以改变
  - 如果你不确定应该用数组还是Vector，那么估计你应该用Vector

#### 数组的类型

- 数组的类型以这种形式表示：[类型; 长度]  例如：`let a: [i32; 5] = [1, 2, 3, 4, 5];`

#### 另一种声明数组的方法

- 如果数组的每个元素值都相同，那么可以在：
  - 在中括号里指定初始值
  - 然后是一个“;”
  - 最后是数组的长度
- 例如：`let a = [3; 5];` 它就相当于：`let a = [3, 3, 3, 3, 3];`

#### 访问数组的元素

- 数组是stack上分配的单个块的内存
- 可以使用索引来访问数组的元素
- 如果访问的索引超出了数组的范围，那么：
  - 编译会通过
  - 运行会报错（runtime时会panic）
    - Rust不会允许其继续访问相应地址的内存

```rust
fn main() {
    // let a = [1, 2, 3, 4, 5];

    let months = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
    ];

    // let first = months[0];
    // let second = months[1];

    // let index = 15;
    let index = [12, 13, 14, 15];
    let month = months[index[1]];
    println!("{}", month);
}

```

## 总结

恭喜你迈出 Rust 编程的第一步！通过这篇教程，你已经轻松掌握了变量、数据类型和复合类型的基础知识，这些是构建 Rust 程序的基石。现在就打开编辑器，试着写几行 Rust 代码，感受它的强大吧！想更深入？关注我们的 Rust 教程系列，下一站带你探索更多精彩内容！

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://doc.rust-lang.org/book/>
- <https://course.rs/about-book.html>
- <https://lab.cs.tsinghua.edu.cn/rust/>
- <https://rustwiki.org/docs/>
- <https://mirrors.tuna.tsinghua.edu.cn/help/crates.io-index.git/>
