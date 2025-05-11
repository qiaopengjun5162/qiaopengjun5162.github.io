+++
title = "深入浅出 Rust：函数、控制流与所有权核心特性解析"
description = "深入浅出 Rust：函数、控制流与所有权核心特性解析"
date = 2025-05-11T05:12:37Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 深入浅出 Rust：函数、控制流与所有权核心特性解析

Rust 作为一门现代系统编程语言，以其内存安全、高性能和并发能力而备受推崇。本文深入探讨 Rust 的核心概念，包括函数的定义与使用、控制流的灵活运用，以及所有权机制的独特设计。通过代码示例和详细解析，带你快速掌握 Rust 的精髓，无论是初学者还是有经验的开发者，都能从中受益。

本文全面介绍了 Rust 编程语言的三大核心主题：函数、控制流和所有权。函数部分涵盖了函数声明、参数传递、表达式与语句的区别，以及返回值处理；控制流部分探讨了 if 表达式、match 模式匹配，以及 loop、while、for 三种循环的用法；所有权部分深入剖析了 Rust 独特的内存管理机制，包括栈与堆的区别、所有权规则、引用与借用、切片等概念。通过清晰的代码示例和解释，本文帮助读者理解 Rust 的设计哲学及其在系统编程中的优势。

## 函数

- 声明函数使用fn关键字
- 依照惯例，针对函数和变量名，Rust使用snake case 命名规范
  - 所有的字母都是小写的，单词之间使用下划线分开

```rust
fn main() {
    another_function();
}

fn another_function() {
    println!("Another function");
}

```

### 函数的参数

- parameters，arguments  (形参，实参)
- 在函数签名里，必须声明每个参数的类型

```rust
fn main() {
   another_function(5, 6); // argument
}

fn another_function(x: i32, y: i32) { // parameter
    println!("the value of x is {}", x);
    println!("the value of y is {}", y);
}
```

### 函数体中的语句与表达式

- 函数体由一系列语句组成，可选的由一个表达式结束
- Rust是一个基于表达式的语言
- 语句是执行一些动作的指令
- 表达式会计算产生一个值
- 函数的定义也是语句
- 语句不返回值，所以不可以使用let将一个语句赋给一个变量

```rust
fn main() {
    let y = 6; // 语句
    // let x = (let y = 6); // 报错
  
   let x = 5;

    let y = {
        let x = 1;
        x + 3
    };

    println!("The value of y is {}", y)
}
```

### 函数的返回值

- 在->符号后边声明函数返回值的类型，但是不可以为返回值命名
- 在Rust里面，返回值就是函数体里面最后一个表达式的值
- 若想提前返回，需使用return关键字，并指定一个值
  - 大多数函数都是默认使用最后一个表达式作为返回值

```rust
fn plus_five(x: i32) -> i32 {
    x + 5
}

fn main() {
   let x = plus_five(6);
   println!("The value of x is {}", x);
}
```

### 注释

- Rust还有一种“文档注释”

```rust
// This is a function
fn five(x: i32) -> i32 {
  x + 5
}

/* sdgagaf
sfgagaga */
// This is main function
// The entry point
fn main() {
  // call five()
  let x = five(6); // 5 + 6
  
  println!("The value of x is: {}", x);
}
```

## 控制流

### if 表达式

- if表达式允许您根据条件来执行不同的代码分支
  - 这个条件必须是bool类型
- if表达式中，与条件相关联的代码块叫做分支（arm）
- 可选的，在后边可以加上一个else表达式

```rust
fn main() {
    println!("Hello, world!");

    let number = 7;

    if number < 5 {
        println!("condition was true");
    } else {
        println!("condition was false");
    }
}

```

### 使用else if 处理多重条件

- 如果使用多于一个else if，那么最好使用match来重构代码

```rust
fn main() {
    let number = 6;

    if number % 4 == 0 {
        println!("number is divisible by 4");
    } else if number % 3 == 0 {
        println!("number is divisible by 3");
    } else if number % 2 == 0 {
        println!("number is divisible by 2");
    } else {
        println!("number is not divisible by 4, 3 or 2");
    }
}

```

使用match

```rust
fn main() {
    let number = 6;
    match number {
        number if number % 4 == 0 => println!("number is divisible by 4"),
        number if number % 3 == 0 => println!("number is divisible by 3"),
        number if number % 2 == 0 => println!("number is divisible by 2"),
        _ => println!("number is not divisible by 4, 3 or 2"),
    }
}

```

### 在let语句中使用If

- 因为if是一个表达式，所以可以将它放在let语句中等号的右边

```rust
fn main() {
    let condition = true;

    let number = if condition {5} else {6};

    println!("The value of number is {}", number);
}
```

### Rust的循环

- Rust提供了3种循环：loop，while和for

### loop循环

- loop关键字告诉Rust反复的执行一块代码，直到你喊停
- 可以在loop循环中使用break关键字来告诉程序何时停止循环

```rust
fn main() {
    let mut counter = 0;

    let result = loop {
        counter += 1;

        if counter == 10 {
            break counter * 2;
        }
    };

    println!("The result is {}", result);
}

```

### While 条件循环

- 每次执行循环体之前都判断一次条件

```rust
fn main() {
  let mut number = 3;
  
  while number != 0 {
    println!("{}", number);
    number = number - 1;
  }
  println!("LIFTOFF!!!");
}
```

### 使用for循环遍历集合

- 可以使用while或loop来遍历集合，但是易错且低效

```rust
fn main() {
    let a = [10, 20, 30, 40, 50];
    let mut index = 0;

    while index < 5 {
        println!("the index is {}", a[index]);

        index = index + 1;
    }
}

```

- 使用for循环更简洁紧凑，它可以针对集合中的每个元素来执行一些代码

```rust
fn main() {
  let a = [10, 20, 30, 40, 50];
  for element in a.iter() {
    println!("the value is {}", element);
  }
}
```

- 由于for循环的安全、简洁性，所以它在Rust里用的最多

### Range

- 标准库提供
- 指定一个开始数字和一个结束数字，Range可以生成它们之间的数字（不含结束）
- rev方法可以反转Range

```rust
fn main() {
    for number in (1..4).rev() {
        println!("{}", number);
    }
    println!("LIFTOFF!!!");
}

```

## 所有权

- 所有权是Rust最独特的特性，它让Rust无需GC就可以保证内存安全

### 1 什么是所有权

- Rust的核心特性就是所有权
- 所有程序在运行时都必须管理它们使用计算机内存的方式
  - 有些语言有垃圾收集机制，在程序运行时，它们会不断地寻找不再使用的内存
  - 在其他语言中，程序员必须显示地分配和释放内存
- Rust采用了第三种方式：
  - 内存是通过一个所有权系统来管理的，其中包含一组编译器在编译时检查的规则
  - 当程序运行时，所有权特性不会减慢程序的运行速度

#### Stack VS Heap

栈内存 VS 堆内存

- 在像Rust这样的系统级编程语言里，一个值是在stack上还是在heap上对语言的行为和你为什么要做某些决定时有更大的影响的
- 在你的代码运行的时候，stack和heap都是你可用的内存，但他们的结构很不相同

存储数据

- Stack按值的接收顺序来存储，按相反的顺序将它们移除（后进先出，LIFO）
  - 添加数据叫做压入栈
  - 移除数据叫做弹出栈
- 所有存储在stack上的数据必须拥有已知的固定的大小
  - 编译时大小未知的数据或运行时大小可能发生变化的数据必须存放在heap上
- Heap内存组织性差一些
  - 当你把数据放入heap时，你会请求一定数量的空间
  - 操作系统在heap里找到一块足够大的空间，把它标记为在用，并返回一个指针，也就是这个空间的地址
  - 这个过程叫做在heap上进行分配，有时仅仅称为“分配”
- 把值压到stack上不叫分配
- 因为指针是已知固定大小的，可以把指针存放在stack上
  - 但如果想要实际数据，你必须使用指针来定位
- 把数据压到stack上要比在heap上分配快得多
  - 因为操作系统不需要寻找用来存储新数据的空间，那个位置永远都在stack的顶端
- 在heap上分配空间需要做更多的工作
  - 操作系统首先需要找到一个足够大的空间来存放数据，然后要做好记录方便下次分配

访问数据

- 访问heap中的数据要比访问stack中的数据慢，因为需要通过指针才能找到heap中的数据
  - 对于现代的处理器来说，由于缓存的缘故，如果指令在内存中跳转的次数越少，那么速度就越快
- 如果数据存放的距离比较近，那么处理器的处理速度就会更快一些（stack上）
- 如果数据之间的距离比较远，那么处理速度就会慢一些（heap上）
  - 在heap上分配大量的空间也是需要时间的

函数调用

- 当你的代码调佣函数时，值被传入到函数（也包括指向heap的指针）。函数本地的变量被压到stack上。当函数结束后，这些值会从stack上弹出

所有权存在的原因

- 所有权解决的问题：
  - 跟踪代码的哪些部分正在使用heap的哪些数据
  - 最小化heap上的重复数据量
  - 清理heap上未使用的数据以避免空间不足
- 一旦你懂的了所有权，那么就不需要经常去想stack或heap了
- 但是知道管理heap数据是所有权存在的原因，这有助于解释它为什么会这样工作

#### 所有权规则

- 每个值都有一个变量，这个变量是该值的所有者
- 每个值同时只能有一个所有者
- 当所有者超出作用域（scope）时，该值将被删除

#### 变量作用域

- Scope就是程序中一个项目的有效范围

```rust
fn main() {
  // s 不可用
  let s = "hello"; // s 可用
                   // 可以对 s 进行相关操作 
} // s 作用域到此结束，s 不再可用
```

#### String 类型

- String 比那些基础标量数据类型更复杂
- 字符串字面值：程序里手写的那些字符串值。它们是不可变的
- Rust还有第二种字符串类型：String
  - 在heap上分配。能够存储在编译时未知数量的文本

#### 创建String类型的值

- 可以使用from函数从字符串字面值创建出String类型
- let s = String::from("hellp");
  - “::”表示from是String类型下的函数
- 这类字符串是可以被修改的

```rust
fn main() {
    let mut s = String::from("Hello");

    s.push_str(", World");

    println!("{}", s);
}

```

- 为什么String类型的值可以修改，而字符串字面值却不能修改？
  - 因为它们处理内存的方式不同

#### 内存和分配

- 字符串字面值，在编译时就知道它的内容了，其文本内容直接被硬编码到最终的可执行文件里
  - 速度快、高效。是因为其不可变性
- String类型，为了支持可变性，需要在heap上分配内存来保存编译时未知的文本内容：
  - 操作系统必须在运行时来请求内存
    - 这步通过调用`String::from`来实现
  - 当用完String之后，需要使用某种方式将内存返回给操作系统
    - 这步，在拥有GC的语言中，GC会跟踪并清理不再使用的内存
    - 没有GC，就需要我们去识别内存何时不再使用，并调用代码将它返回
      - 如果忘了，那就浪费内存
      - 如果提前做了，变量就会非法
      - 如果做了两次，也是Bug，必须一次分配对应一次释放
- Rust采用了不同的方式：对于某个值来说，当拥有它的变量走出作用范围时，内存会立即自动的交还给操作系统
- DROP函数（当变量走出作用域的时候，Rust会自动调用这个函数）

#### 变量和数据交互的方式：移动（Move）

- 多个变量可以与同一个数据使用一种独特的方式来交互

```rust
let x = 5;
let y = x;
```

- 整数是已知且固定大小的简单的值，这两个5倍压到了stack中

String版本

```rust
let s1 = String::from("hello");
let s2 = s1;
```

- 一个String由3部分组成：
  - 一个指向存放字符串内容的内存的指针（ptr）
  - 一个长度（len）
  - 一个容量（capacity）
- 上面这些东西放在stack上
- 存放字符串内容的部分在heap上
- 长度len，就是存放字符串内容所需的字节数
- 容量capacity是指String从操作系统总共获得内存的总字节数
- 当把s1赋给s2，String的数据被复制了一份：
  - 在stack上复制了一份指针、长度、容量
  - 并没有复制指针所指向的heap上的数据
- 当变量离开作用域时，Rust会自动调用DROP函数，并将变量使用的heap内存释放
- 当s1、s2离开作用域时，它们都会尝试释放相同的内存：
  - 二次释放（double free）bug
- 为了保证内存安全：
  - Rust没有尝试复制被分配的内存
  - Rust让s1失效
    - 当s1离开作用域的时候，Rust不需要释放任何东西
- 浅拷贝（shallow copy）
- 深拷贝（deep copy）
- 你也许会将复制指针、长度、容量视为浅拷贝，但由于Rust让s1失效了，所以我们用一个新的术语：移动（Move）
- 隐含的一个设计原则：Rust不会自动创建数据的深拷贝
  - 就运行时性能而言，任何自动赋值的操作都是廉价的

#### 变量和数据交互的方式：克隆（Clone）

- 如果真想对heap上面的String数据进行深度拷贝，而不仅仅是stack上的数据，可以使用Clone方法

```rust
fn main() {
  let s1 = String::from("Hello");
  let s2 = s1.clone();
  
  println!("{}, {}", s1, s2);
}
```

#### Stack上的数据：复制

```rust
fn main() {
  let x = 5;
  let y = x;
  
  println!("{}, {}", x, y);
}
```

- Copy trait， 可以用于像整数这样完全存放在stack上面的类型
- 如果一个类型实现了Copy这个trait，那么旧的变量在赋值后仍然可用
- 如果一个类型或者该类型的一部分实现了Drop trait，那么Rust不允许让它再去实现Copy Trait了

#### 一些拥有Copy Trait 的类型

- 任何简单标量的组合类型都可以是Copy的
- 任何需要分配内存或某种资源的都不是Copy的
- 一些拥有Copy Trait的类型：
  - 所有的整数类型，例如u32
  - bool
  - char
  - 所有的浮点类型，例如f64
  - Tuple（元组），如果起所有的字段都是Copy的
    - `(i32, i32)`是
    - `(i32, String)`不是

#### 所有权与函数

- 在语义上，将值传递给函数和把值赋给变量是类似的：
  - 将值传递给函数将发生移动或复制

```rust
fn main() {
    let s = String::from("Hello, World!");

    take_ownership(s);

    let x = 5;

    makes_copy(x);

    println!("x: {}", x);
}

fn take_ownership(some_string: String) {
    println!("{}", some_string)
}

fn makes_copy(some_number: i32) {
    println!("{}", some_number);
}

```

#### 返回值与作用域

- 函数在返回值的过程中同样也会发生所有权的转移

```rust
fn main() {
    let s1 = gives_ownership();

    let s2 = String::from("hello");

    let s3 = takes_and_gives_back(s2);
}

fn gives_ownership() -> String {
    let some_string = String::from("hello");
    some_string
}

fn takes_and_gives_back(a_string: String) -> String {
    a_string
}

```

- 一个变量的所有权总是遵循同样的模型：
  - 把一个值赋给其他变量时就会发生移动
  - 当一个包含heap数据的变量离开作用域时，它的值就会被Drop函数清理，除非数据的所有权移动到另一个变量上了

#### 如何让函数使用某个值，但不获得其所有权？

```rust
fn main() {
  let s1 = String::from("hello");
  
  let (s2, len) = calculate_length(s1);
  
  println!("The length of '{}' is {}.", s2, len);
}

fn calculate_length(s: String) -> (String, usize) {
  let length = s.len();
  
  (s, length)
}
```

- Rust有一个特性叫做“引用（Reference）”

### 2 引用和借用

```rust
fn main() {
  let s1 = String::from("Hello");
  let len = calculate_length(&s1);
  
  println!("The length of '{}' is {}.", s1, len);
}

fn calculate_length(s: &String) -> usize {
  s.len()
}
```

- 参数的类型是 &String 而不是 String
- & 符号就表示引用：允许你引用某些值而不取得其所有权

#### 借用

- 我们把引用作为函数参数这个行为叫做借用
- 是否可以修改借用的东西？ 不行
- 和变量一样，引用默认也是不可变的

#### 可变引用

- 可变引用有一个重要的限制：在特定作用域内，对某一块数据，只能有一个可变的引用
  - 这样做的好处是可在编译时防止数据竞争
- 以下三种行为下会发生数据竞争：
  - 两个或多个指针同时访问同一个数据
  - 至少有一个指针用于写入数据
  - 没有使用任何机制来同步对数据的访问
- 可以通过创建新的作用域，来允许非同时的创建多个可变引用

```rust
fn main() {
  let mut s = String::from("Hello");
  {
    let s1 = &mut s;
  }
  
  let s2 = &mut s;
}
```

#### 另外一个限制

- 不可用同时拥有一个可变引用和一个不可变的引用
- 多个不可变的引用是可以的

```rust
fn main() {
  let mut s = String::from("Hello");
  let r1 = &s;
  let r2 = &s;
  let s1 = &mut s;  // 报错
  
  println!("{} {} {}", r1, r2, s1);
}
```

#### 悬空引用 Dangling References

- 悬空指针（Dangling Pointer）：一个指针引用了内存中的某个地址，而这块内存可能已经释放并分配给其它人使用了。
- 在Rust里，编译器可保证引用永远都不是悬空引用：
  - 如果你引用了某些数据，编译器将保证在引用离开作用域之前数据不会离开作用域

#### 引用的规则

- 在任何给定的时刻，只能满足下列条件之一：
  - 一个可变的引用
  - 任意数量不可变的引用
- 引用必须一直有效

### 3 切片

- Rust的另外一种不持有所有权的数据类型：切片（slice）
- 一道题，编写一个函数：
  - 它接收字符串作为参数
  - 返回它在这个字符串里找到的第一个单词
  - 如果函数没找到任何空格，那么整个字符串就被返回
- 尝试解答

```rust
fn main() {
    let mut s  = String::from("Hello world");
    let word_index = first_world(&s);

    println!("{}", word_index);
}

fn first_world(s: &String) -> usize {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return i;
        }
    }
    s.len()
}

```

#### 字符串切片

- 字符串切片是指向字符串中一部分内容的引用
- 形式：[开始索引..结束索引]
  - 开始索引就是切片起始位置的索引值
  - 结束索引是切片终止位置的下一个索引值

```rust
fn main() {
  let s = String::from("Hello world");
  
  let hello = &s[0..5];
  let world = &s[6..11];
  
  println!("{}, {}", hello, world);
}
```

#### 注意

- 字符串切片的范围索引必须发生在有效的UTF-8字符边界内
- 如果尝试从一个多字节的字符中创建字符串切片，程序会报错并退出

#### 使用字符串切片重写例子

```rust
fn main() {
    let s  = String::from("Hello world");
    let word_index = first_world(&s);

    println!("{}", word_index);
}

fn first_world(s: &String) -> &str {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[..i];
        }
    }
    &s[..]
}

```

#### 字符串字面值是切片

- 字符串字面值被直接存储在二进制程序中
- let s = "Hello, World!";

```rust
fn main() {
  let s = "Hello world";
  
  println!("{}", s)
}
```

- 变量s的类型是&str，它是一个指向二进制程序特定位置的切片
  - &str 是不可变引用，所以字符串字面值也是不可变的

#### 将字符串切片作为参数传递

- `fn first_word(s: &String) -> &str {`
- 有经验的Rust开发者会采用&str作为参数类型，因为这样就可以同时接收String和&str类型的参数了：
- `fn first_word(s: &str) -> &str {`
  - 使用字符串切片，直接调用该函数
  - 使用String，可以创建一个完整的String切片来调用该函数
- 定义函数时使用字符串切片来代替字符串引用会使我们的API更加通用，且不会损失任何功能
- 字符串字面值就是字符串切片

```rust
fn main() {
    let my_string  = String::from("Hello world");
    let word_index = first_world(&my_string[..]);

    println!("{}", word_index);

    let my_string_literal = "hello world";
    let word_literal = first_world(my_string_literal);

    println!("word_literal: {}", word_literal);
}

fn first_world(s: &str) -> &str {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[..i];
        }
    }
    &s[..]
}

```

#### 其他类型的切片

```rust
fn main() {
  let a = [1, 2, 3, 4, 5];
  let slice = &a[1..3];
}
```

## 总结

Rust 的函数、控制流和所有权机制共同构成了其高效、安全的核心优势。函数通过基于表达式的设计提供了灵活性和简洁性；控制流结构如 if、match 和多样化的循环方式，使得代码逻辑清晰且高效；所有权机制通过编译时检查和引用借用规则，消除了内存管理中的常见错误，为开发者提供了无垃圾回收器的高性能内存安全保障。掌握这些特性，不仅能帮助开发者编写健壮的 Rust 代码，还能深入理解系统编程的底层原理。无论是构建高性能系统还是探索现代编程语言的设计，Rust 都是一个值得深入学习的强大工具。

## 参考

- <https://crates.io/>
- <https://www.rust-lang.org/zh-CN>
- <https://course.rs/about-book.html>
- <https://rustwasm.github.io/book/>
