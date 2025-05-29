+++
title = "Rust智能指针：解锁内存管理的进阶之道"
description = "Rust智能指针：解锁内存管理的进阶之道"
date = 2025-05-29T00:40:39Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust智能指针：解锁内存管理的进阶之道

在Rust编程中，内存安全是其核心优势之一，而智能指针作为Rust内存管理的关键工具，不仅提供了灵活的数据操作方式，还确保了高效和安全的内存管理。本文深入探讨Rust中智能指针的多种实现，包括Box<T>、Rc<T>、RefCell<T>等，结合实际代码示例，带你掌握智能指针的用法及其在复杂场景中的应用。无论你是Rust新手还是进阶开发者，这篇文章都将为你揭开智能指针的奥秘，助你在Rust编程中更进一步！

智能指针是Rust中一类行为类似指针但具备额外元数据和功能的数据结构，能够有效管理内存并支持复杂的数据共享场景。本文从基础概念入手，详细介绍了Box<T>在堆内存分配中的作用、Deref和Drop trait的实现原理、引用计数指针Rc<T>的多重所有权机制，以及RefCell<T>的内部可变性模式。文章还探讨了如何通过结合Rc<T>和RefCell<T>实现多重所有权的可变数据，并分析了循环引用可能导致的内存泄漏问题及使用Weak<T>的解决方法。通过代码示例和场景分析，本文旨在帮助读者全面理解Rust智能指针的强大功能及其适用场景。

## 智能指针（序）

### 相关的概念

- 指针：一个变量在内存中包含的是一个地址（指向其它数据）
- Rust 中最常见的指针就是”引用“
- 引用：
  - 使用 &
  - 借用它指向的值
  - 没有其余开销
  - 最常见的指针类型

### 智能指针

- 智能指针是这样一些数据结构：
  - 行为和指针相似
  - 有额外的元数据和功能

### 引用计数（Reference counting）智能指针类型

- 通过记录所有者的数量，使一份数据被多个所有者同时持有
- 并在没有任何所有者时自动清理数据

### 引用和智能指针的其它不同

- 引用：只借用数据
- 智能指针：很多时候都拥有它所指向的数据

### 智能指针的例子

- String 和 `Vec<T>`

- 都拥有一片内存区域，且允许用户对其操作
- 还拥有元数据（例如容量等）
- 提供额外的功能或保障（String 保障其数据是合法的 UTF-8 编码）

### 智能指针的实现

- 智能指针通常使用 Struct 实现，并且实现了：
  - Deref 和 Drop 这两个 trait
- Deref trait：允许智能指针 struct 的实例像引用一样使用
- Drop trait：允许你自定义当智能指针实例走出作用域时的代码

### 本章内容

- 介绍标准库中常见的智能指针
  - `Box<T>`：在 heap 内存上分配值
  - `Rc<T>`：启用多重所有权的引用计数类型
  - `Ref<T>`和`RefMut<T>`，通过 `RefCell<T>`访问：在运行时而不是编译时强制借用规则的类型
- 此外：
  - 内部可变模型（interior mutability pattern）：不可变类型暴露出可修改其内部值的 API
  - 引用循环（reference cycles）：它们如何泄露内存，以及如何防止其发生。

## 一、使用`Box<T>` 来指向 Heap 上的数据

### `Box<T>`

- `Box<T>` 是最简单的智能指针：
  - 允许你在 heap 上存储数据（而不是 stack）
  - stack 上是指向 heap 数据的指针
  - 没有性能开销
  - 没有其它额外功能
  - 实现了 Deref trait 和 Drop trait

### `Box<T>` 的常用场景

- 在编译时，某类型的大小无法确定。但使用该类型时，上下文却需要知道它的确切大小。
- 当你有大量数据，想移交所有权，但需要确保在操作时数据不会被复制。
- 使用某个值时，你只关心它是否实现了特定的 trait，而不关心它的具体类型。

### 使用`Box<T>`在heap上存储数据

```rust
fn main() {
  let b = Box::new(5);
  println!("b = {}", b);
} // b 释放存在 stack 上的指针 heap上的数据
```

### 使用 Box 赋能递归类型

- 在编译时，Rust需要知道一个类型所占的空间大小
- 而递归类型的大小无法再编译时确定
- 但 Box 类型的大小确定
- 在递归类型中使用 Box 就可解决上述问题
- 函数式语言中的 Cons List

### 关于 Cons List

- Cons List 是来自 Lisp 语言的一种数据结构
- Cons List 里每个成员由两个元素组成
  - 当前项的值
  - 下一个元素
- Cons List 里最后一个成员只包含一个 Nil 值，没有下一个元素  （Nil 终止标记）

### Cons List 并不是 Rust 的常用集合

- 通常情况下，Vec<T> 是更好的选择
- （例子）创建一个 Cons List

```rust
use crate::List::{Cons, Nil};

fn main() {
  let list = Cons(1, Cons(2, Cons(3, Nil)));
}

enum List {  // 报错
  Cons(i32, List),
  Nil,
}
```

- （例）Rust 如何确定为枚举分配的空间大小

```rust
enum Message {
  Quit,
  Move {x: i32, y: i32},
  Write(String),
  ChangeColor(i32, i32, i32),
}
```

### 使用 Box 来获得确定大小的递归类型

- Box<T> 是一个指针，Rust知道它需要多少空间，因为：
  - 指针的大小不会基于它指向的数据的大小变化而变化

```rust
use crate::List::{Cons, Nil};

fn main() {
  let list = Cons(1, 
    Box::new(Cons(2, 
      Box::new(Cons(3, 
        Box::new(Nil))))));
}

enum List {  
  Cons(i32, Box<List>),
  Nil,
}
```

- Box<T>：
  - 只提供了”间接“存储和 heap 内存分配的功能
  - 没有其它额外功能
  - 没有性能开销
  - 适用于需要”间接“存储的场景，例如 Cons List
  - 实现了 Deref trait 和 Drop trait

## 二、Deref Trait（1）

### Deref Trait

- 实现 Deref Trait 使我们可以自定义解引用运算符 * 的行为。
- 通过实现 Deref，智能指针可像常规引用一样来处理

### 解引用运算符

- 常规引用是一种指针

```rust
fn main() {
  let x = 5;
  let y = &x;
  
  assert_eq!(5, x);
  assert_eq!(5, *y);
}
```

### 把 `Box<T>` 当作引用

- `Box<T>` 可以替代上例中的引用

```rust
fn main() {
  let x = 5;
  let y = Box::new(x);
  
  assert_eq!(5, x);
  assert_eq!(5, *y);
}
```

### 定义自己的智能指针

- `Box<T>` 被定义成拥有一个元素的 tuple struct
- （例子）`MyBox<T>`

```rust
struct MyBox<T>(T);

impl<T> MyBox<T> {
  fn new(x: T) -> MyBox<T> {
    MyBox(x)
  }
}

fn main() {
  let x = 5;
  let y = MyBox::new(x);  // 报错
  
  assert_eq!(5, x);
  assert_eq!(5, *y);
}
```

### 实现 Deref Trait

- 标准库中的 Deref trait 要求我们实现一个 deref 方法：
  - 该方法借用 self
  - 返回一个指向内部数据的引用
- （例子）

```rust
use std::ops::Deref;

struct MyBox<T>(T);

impl<T> MyBox<T> {
  fn new(x: T) -> MyBox<T> {
    MyBox(x)
  }
}

impl<T> Deref for MyBox<T> {
  type Target = T;
  
  fn deref(&self) -> &T {
    &self.0
  }
}

fn main() {
  let x = 5;
  let y = MyBox::new(x);  
  
  assert_eq!(5, x);
  assert_eq!(5, *y);  // *(y.deref())
}
```

## 三、Deref Trait （2）

### 函数和方法的隐式解引用转化（Deref Coercion)

- 隐式解引用转化（Deref Coercion）是为函数和方法提供的一种便捷特性
- 假设 T 实现了 Deref trait：
  - Deref Coercion 可以把 T 的引用转化为 T 经过 Deref 操作后生成的引用
- 当把某类型的引用传递给函数或方法时，但它的类型与定义的参数类型不匹配：
  - Deref Coercion 就会自动发生
  - 编译器会对 deref 进行一系列调用，来把它转为所需的参数类型
    - 在编译时完成，没有额外性能开销

```rust
use std::ops::Deref;

fn hello(name: &str) {
  println!("Hello, {}", name);
}

fn main() {
  let m = MyBox::new(String::from("Rust"));
  
  // &m &MyBox<String> 实现了 deref trait
  // deref &String
  // deref &str
  hello(&m);
  hello(&(*m)[..]);
  
  hello("Rust");
}

struct MyBox<T>(T);

impl<T> MyBox<T> {
  fn new(x: T) -> MyBox<T> {
    MyBox(x)
  }
}

impl<T> Deref for MyBox<T> {
  type Target = T;
  
  fn deref(&self) -> &T {
    &self.0
  }
}

fn main() {
  let x = 5;
  let y = MyBox::new(x);  
  
  assert_eq!(5, x);
  assert_eq!(5, *y);  // *(y.deref())
}
```

### 解引用与可变性

- 可使用 DerefMut trait 重载可变引用的 * 运算符
- 在类型和 trait 在下列三种情况发生时，Rust会执行 deref coercion：
  - 当 T：Deref<Target=U>，允许 &T 转换为 &U
  - 当 T：DerefMut<Target=U>，允许 &mut T 转换为 &mut U
  - 当 T：Deref<Target=U>，允许 &mut T 转换为 &U

## 四、Drop Trait

### Drop Trait

- 实现 Drop Trait，可以让我们自定义当值将要离开作用域时发生的动作。
  - 例如：文件、网络资源释放等
  - 任何类型都可以实现 Drop trait
- Drop trait 只要求你实现 drop 方法
  - 参数：对self 的可变引用
- Drop trait 在预导入模块里（prelude）

```rust
/*
 * @Author: QiaoPengjun5162 qiaopengjun0@gmail.com
 * @Date: 2023-04-13 21:39:51
 * @LastEditors: QiaoPengjun5162 qiaopengjun0@gmail.com
 * @LastEditTime: 2023-04-13 21:46:50
 * @FilePath: /smart/src/main.rs
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE 
 */
struct CustomSmartPointer {
    data: String,
}

impl Drop for CustomSmartPointer {
    fn drop(&mut self) {
        println!("Dropping CustomSmartPointer with data: `{}`!", self.data);
    }
}

fn main() {
    let c = CustomSmartPointer {data: String::from("my stuff")};
    let d = CustomSmartPointer {data: String::from("other stuff")};
    println!("CustomSmartPointers created.")
}

```

运行

```bash
smart on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ cargo run         
   Compiling smart v0.1.0 (/Users/qiaopengjun/rust/smart)
warning: unused variable: `c`
  --> src/main.rs:20:9
   |
20 |     let c = CustomSmartPointer {data: String::from("my stuff")};
   |         ^ help: if this is intentional, prefix it with an underscore: `_c`
   |
   = note: `#[warn(unused_variables)]` on by default

warning: unused variable: `d`
  --> src/main.rs:21:9
   |
21 |     let d = CustomSmartPointer {data: String::from("other stuff")};
   |         ^ help: if this is intentional, prefix it with an underscore: `_d`

warning: `smart` (bin "smart") generated 2 warnings (run `cargo fix --bin "smart"` to apply 2 suggestions)
    Finished dev [unoptimized + debuginfo] target(s) in 0.53s
     Running `target/debug/smart`
CustomSmartPointers created.
Dropping CustomSmartPointer with data: `other stuff`!
Dropping CustomSmartPointer with data: `my stuff`!

smart on  master [?] is 📦 0.1.0 via 🦀 1.67.1 took 3.6s 
```

### 使用 `std::mem::drop` 来提前 drop 值

- 很难直接禁用自动的 drop 功能，也没必要
  - Drop trait 的目的就是进行自动的释放处理逻辑
- Rust 不允许手动调用 Drop trait 的 drop 方法
  - 但可以调用标准库的 `std::mem::drop` 函数，来提前 drop 值

```rust
struct CustomSmartPointer {
    data: String,
}

impl Drop for CustomSmartPointer {
    fn drop(&mut self) {
        println!("Dropping CustomSmartPointer with data: `{}`!", self.data);
    }
}

fn main() {
    let c = CustomSmartPointer {data: String::from("my stuff")};
   drop(c);
    let d = CustomSmartPointer {data: String::from("other stuff")};
    println!("CustomSmartPointers created.")
}

```

## 五、`Rc<T>`：引用计数智能指针

### `Rc<T>`引用计数智能指针

- 有时，一个值会有多个所有者
- 为了支持多重所有权：`Rc<T>`
  - reference couting（引用计数）
  - 追踪所有到值的引用
  - 0 个引用：该值可以被清理掉

### `Rc<T>`使用场景

- 需要在 heap上分配数据，这些数据被程序的多个部分读取（只读），但在编译时无法确定哪个部分最后使用完这些数据
- `Rc<T>` 只能用于单线程场景

### 例子

- `Rc<T>` 不在预导入模块（prelude）
- `Rc::clone(&a)` 函数：增加引用计数
- `Rc::strong_count(&a)`：获得引用计数
  - 还有 `Rc::weak_count` 函数
- （例子）
  - 两个 List 共享 另一个 List 的所有权

```rust
/*
 * @Author: QiaoPengjun5162 qiaopengjun0@gmail.com
 * @Date: 2023-04-13 22:32:41
 * @LastEditors: QiaoPengjun5162 qiaopengjun0@gmail.com
 * @LastEditTime: 2023-04-13 22:37:17
 * @FilePath: /smart/src/lib.rs
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
enum List {
    Cons(i32, Box<List>),
    Nil,
}

use crate::List::{Cons, Nil};

fn main() {
    let a = Cons(5, Box::new(Cons(10, Box::new(Nil))));
    let b = Cons(3, Box::new(a));
    let c = Cons(4, Box::new(a));  // 报错
}

```

优化修改一

```rust
/*
 * @Author: QiaoPengjun5162 qiaopengjun0@gmail.com
 * @Date: 2023-04-13 22:32:41
 * @LastEditors: QiaoPengjun5162 qiaopengjun0@gmail.com
 * @LastEditTime: 2023-04-13 22:45:15
 * @FilePath: /smart/src/lib.rs
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
enum List {
    Cons(i32, Rc<List>),
    Nil,
}

use crate::List::{Cons, Nil};
use std::rc::Rc;

fn main() {
    let a = Rc::new(Cons(5, Rc::new(Cons(10, Rc::new(Nil)))));
    // a.clone() // 深度拷贝操作

    let b = Cons(3, Rc::clone(&a));
    let c = Cons(4, Rc::clone(&a));  //
}

```

优化修改二

```rust
/*
 * @Author: QiaoPengjun5162 qiaopengjun0@gmail.com
 * @Date: 2023-04-13 22:32:41
 * @LastEditors: QiaoPengjun5162 qiaopengjun0@gmail.com
 * @LastEditTime: 2023-04-13 22:51:04
 * @FilePath: /smart/src/lib.rs
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
enum List {
    Cons(i32, Rc<List>),
    Nil,
}

use crate::List::{Cons, Nil};
use std::rc::Rc;

fn main() {
    let a = Rc::new(Cons(5, Rc::new(Cons(10, Rc::new(Nil)))));
    println!("count after creating a = {}", Rc::strong_count(&a));

    let b = Cons(3, Rc::clone(&a));
    println!("count after creating b = {}", Rc::strong_count(&a));

    {
        let c = Cons(4, Rc::clone(&a));
        println!("count after creating c = {}", Rc::strong_count(&a));
    }
    println!("count after c goes of scope = {}", Rc::strong_count(&a));
}

```

### `Rc::clone()` vs 类型的 clone() 方法

- `Rc::clone()`：增加引用，不会执行数据的深度拷贝操作
- 类型的 clone()：很多会执行数据的深度拷贝操作

### `Rc<T>`

- `Rc<T>` 通过不可变引用，使你可以在程序不同部分之间共享只读数据

- 但是，如何允许数据变化呢？

## 六、`RefCell<T>` 和内部可变性

### 内部可变性（interior mutability）

- 内部可变性是Rust的设计模式之一
- 它允许你在只持有不可变引用的前提下对数据进行修改
  - 数据结构中使用了 unsafe 代码来绕过 Rust 正常的可变性和借用规则

### `RefCell<T>`

- 与 `Rc<T>` 不同， `RefCell<T>` 类型代表了其持有数据的唯一所有权。

### 回忆一下：借用规则

- 在任何给定的时间里，你要么只能拥有一个可变引用，要么只能拥有任意数量的不可变引用
- 引用总是有效的

### `RefCell<T>` 与 `Box<T>` 的区别

`Box<T>`

- 编译阶段强制代码遵守借用规则
- 否则出现错误

`RefCell<T>`

- 只会在运行时检查借用规则
- 否则触发 panic

### 借用规则在不同阶段进行检查的比较

编译阶段

- 尽早暴露问题
- 没有任何运行时开销
- 对大多数场景是最佳选择
- 是Rust的默认行为

运行时

- 问题暴露延后，甚至到生产环境
- 因借用计数产生些许性能损失
- 实现某些特定的内存安全场景（不可变环境中修改自身数据）

### `RefCell<T>`

- 与 `Rc<T>`相似，只能用于单线程场景

### 选择`Box<T>`、`Rc<T>`、`RefCell<T>`的依据

|       说明       |            `Box<T>`            |         `Rc<T>`          |          `RefCell<T>`          |
| :--------------: | :----------------------------: | :----------------------: | :----------------------------: |
| 同一数据的所有者 |              一个              |           多个           |              一个              |
| 可变性、借用检查 | 可变、不可变借用（编译时检查） | 不可变借用（编译时检查） | 可变、不可变借用（运行时检查） |

- 其中：即便 `RefCell<T>`本身不可变，但仍能修改其中存储的值

### 内部可变性：可变的借用一个不可变的值

```rust
fn main() {
  let x = 5;
  let y = &mut x; // 报错 cannot borrow as mutable
}
```

例子：

```rust
pub trait Message {
    fn send(&self, msg: &str);
}

pub struct LimitTracker<'a, T: 'a + Message> {
    messenger: &'a T,
    value: usize,
    max: usize,
}

impl<'a, T> LimitTracker<'a, T>
where
    T: Messenger,
{
    pub fn new(messenger: &T, value: usize) -> LimitTracker<T> {
        LimitTracker {
            messenger,
            value: 0,
            max,
        }
    }

    pub fn set_value(&mut self, value: usize) {
        self.value = value;

        let percentage_of_max = self.value as f64 / self.max as f64;
        if percentage_of_max >= 1.0 {
            self.messenger.send("Error: You are over your quota!");
        } else if percentage_of_max >= 0.9 {
            self.messenger
                .send("Urgent warning: You're used up over 90% of your quota!");
        } else if percentage_of_max >= 0.75 {
            self.messenger
                .send("Warning: You're used up over 75% of your quota!");
        }
    }
}
#[cfg(test)]
mod tests {
    use super::*;

    struct MockMessenger {
        sent_messages: Vec<String>,
    }

    impl MockMessenger {
        fn new() -> MockMessenger {
            MockMessenger {
                sent_messages: vec![],
            }
        }
    }

    impl Messenger for MockMessenger {
        fn send(&mut self, message: &str) { // 报错
            self.sent_messages.push(String::from(message));
        }
    }

    #[test]
    fn it_sends_an_over_75_percent_warning_message() {
        let mock_messenger = MockMessenger::new();
        let mut limit_tracker = LimitTracker::new(&mock_messenger, 100);

        limit_tracker.set_value(80);
        assert_eq!(mock_messenger.sent_messages.len(), 1);
    }
}

```

修改之后：

```rust
pub trait Message {
    fn send(&self, msg: &str);
}

pub struct LimitTracker<'a, T: 'a + Message> {
    messenger: &'a T,
    value: usize,
    max: usize,
}

impl<'a, T> LimitTracker<'a, T>
where
    T: Messenger,
{
    pub fn new(messenger: &T, value: usize) -> LimitTracker<T> {
        LimitTracker {
            messenger,
            value: 0,
            max,
        }
    }

    pub fn set_value(&mut self, value: usize) {
        self.value = value;

        let percentage_of_max = self.value as f64 / self.max as f64;
        if percentage_of_max >= 1.0 {
            self.messenger.send("Error: You are over your quota!");
        } else if percentage_of_max >= 0.9 {
            self.messenger
                .send("Urgent warning: You're used up over 90% of your quota!");
        } else if percentage_of_max >= 0.75 {
            self.messenger
                .send("Warning: You're used up over 75% of your quota!");
        }
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    use std::cell::RefCell;

    struct MockMessenger {
        sent_messages: RefCell<Vec<String>>,
    }

    impl MockMessenger {
        fn new() -> MockMessenger {
            MockMessenger {
                sent_messages: RefCell::new(vec![]),
            }
        }
    }

    impl Messenger for MockMessenger {
        fn send(&self, message: &str) { // 报错
            self.sent_messages.borrow_mut().push(String::from(message));
        }
    }

    #[test]
    fn it_sends_an_over_75_percent_warning_message() {
        let mock_messenger = MockMessenger::new();
        let mut limit_tracker = LimitTracker::new(&mock_messenger, 100);

        limit_tracker.set_value(80);
        assert_eq!(mock_messenger.sent_messages.borrow().len(), 1);
    }
}

```

### 使用`RefCell<T>`在运行时记录借用信息

- 两个方法（安全接口）：
  - borrow 方法
    - 返回智能指针 `Ref<T>`，它实现了 Deref
  - borrow_mut 方法
    - 返回智能指针 `RefMut<T>`，它实现了 Deref
- `RefCell<T>` 会记录当前存在多少个活跃的 `Ref<T>` 和 `RefMut<T>` 智能指针：
  - 每次调用 borrow：不可变借用计数加1
  - 任何一个 `Ref<T>`的值离开作用域被释放时：不可变借用计数减1
  - 每次调用 borrow_mut：可变借用计数加1
  - 任何一下 `RefMut<T>` 的值离开作用域被释放时：可变借用计数减1
- 以此技术来维护借用检查规则：
  - 任何一个给定时间里，只允许拥有多个不可变借用或一个可变借用。

### 将 `Rc<T>` 和 `RefCell<T>` 结合使用来实现一个拥有多重所有权的可变数据

```rust
#[derive(Debug)]
enum List {
    Cons(Rc<RefCell<i32>>, Rc<List>),
    Nil,
}

use crate::List::{Cons, Nil};
use std::rc::Rc;
use std::cell::RefCell;

fn main() {
    let value = Rc::new(RefCell::new(5));
    let a = Rc::new(Cons(Rc::clone(&value), Rc::new(Nil)));
    let b = Cons(Rc::new(RefCell::new(6)), Rc::clone(&a));
    let c = Cons(Rc::new(RefCell::new(10)), Rc::clone(&a));

    *value.borrow_mut() += 10;

    println!("a after = {:?}", a);
    println!("b after = {:?}", b);
    println!("c after = {:?}", c);
}

```

运行

```bash
refdemo on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ cargo run        
   Compiling refdemo v0.1.0 (/Users/qiaopengjun/rust/refdemo)
    Finished dev [unoptimized + debuginfo] target(s) in 0.58s
     Running `target/debug/refdemo`
a after = Cons(RefCell { value: 15 }, Nil)
b after = Cons(RefCell { value: 6 }, Cons(RefCell { value: 15 }, Nil))
c after = Cons(RefCell { value: 10 }, Cons(RefCell { value: 15 }, Nil))

refdemo on  master [?] is 📦 0.1.0 via 🦀 1.67.1 
➜ 
```

### 其它可实现内部可变性的类型

- `Cell<T>`：通过复制来访问数据
- `Mutex<T>`：用于实现跨线程情形下的内部可变性模式

## 七、循环引用可导致内存泄漏

### Rust可能发生内存泄漏

- Rust的内存安全机制可以保证很难发生内存泄漏，但不是不可能。
- 例如使用 `Rc<T>` 和 `RefCell<T>`就可能创造出循环引用，从而发生内存泄漏：
  - 每个项的引用数量不会变成0，值也不会被处理掉。

```rust
use crate::List::{Cons, Nil};
use std::cell::RefCell;
use std::rc::Rc;

#[derive(Debug)]
enum List {
  Cons(i32, RefCell<Rc<List>>),
  Nil,
}

impl List {
  fn tail(&self) -> Option<&RefCell<Rc<List>>> {
    match self {
      Cons(_, item) => Some(item),
      Nil => None,
    }
  }
}

fn main() {
  let a = Rc::new(Cons(5, RefCell::new(Rc::new(Nil))));
  
  println!("a initial rc count = {}", Rc::strong_count(&a));
  println!("a next item = {:?}", a.tail());
  
  let b = Rc::new(Cons(10, RefCell::new(Rc::clone(&a))));
  println!("a rc count after b creation = {}", Rc::strong_count(&a));
  println!("b initial rc count = {}", Rc::strong_count(&b));
  println!("b next item = {:?}", b.tail());
  
  if let Some(link) = a.tail() {
    *link.borrow_mut() = Rc::clone(&b);
  }
  
  println!("b rc count after changing a = {}", Rc::strong_count(&b));
  println!("a rc count after changing a = {}", Rc::strong_count(&a));
  
  // Uncomment the next line to see that we have a cycle;
  // it will overflow the stack.
  // println!("a next item = {:?}", a.tail());
}
```

### 防止内存泄漏的解决办法

- 依靠开发者来保证，不能依靠Rust
- 重新组织数据结构：一些引用来表达所有权，一些引用不表达所有权
  - 循环引用中的一部分具有所有权关系，另一部分不涉及所有权关系
  - 而只有所有权关系才影响值的清理

### 防止循环引用 把`Rc<T>`换成`Weak<T>`

- `Rc::clone`为`Rc<T>`实例的 strong_count 加1，`Rc<T>`的实例只有在 strong_count 为0的时候才会被清理
- `Rc<T>`实例通过调用`Rc::downgrade`方法可以创建值的 Weak Reference （弱引用）
  - 返回类型是 `Weak<T>`（智能指针）
  - 调用 `Rc::downgrade`会为 weak_count 加 1
- `Rc<T>`使用 weak_count 来追踪存在多少`Weak<T>`
- weak_count 不为0并不影响`Rc<T>`实例的清理

### Strong vs Weak

- Strong Reference（强引用）是关于如何分享 `Rc<T>`实例的所有权
- Weak Reference（弱引用）并不表达上述意思
- 使用 Weak Reference 并不会创建循环引用：
  - 当 Strong Reference 数量为0的时候，Weak Reference 会自动断开
- 在使用 `Weak<T>`前，需保证它指向的值仍然存在：
  - 在`Weak<T>`实例上调用 upgrade 方法，返回`Option<Rc<T>>`

```rust
use std::rc::Rc;
use std::cell::RefCell;

#[derive(Debug)]
struct Node {
  value: i32,
  children: RefCell<Vec<Rc<Node>>>,
}

fn main() {
  let leaf = Rc::new(Node {
    value: 3,
    children: RefCell::new(vec![]),
  });
  
  let branch = Rc::new(Node {
    value: 5,
    children: RefCell::new(vec![Rc::clone(&leaf)]),
  });
}
```

修改后：

```rust
use std::rc::{ Rc, Weak };
use std::cell::RefCell;

#[derive(Debug)]
struct Node {
  value: i32,
  parent: RefCell<Weak<Node>>,
  children: RefCell<Vec<Rc<Node>>>,
}

fn main() {
  let leaf = Rc::new(Node {
    value: 3,
    parent: RefCell::new(Weak::new()),
    children: RefCell::new(vec![]),
  });
  
  println!("leaf parent - {:?}", leaf.parent.borrow().upgrade());
  
  let branch = Rc::new(Node {
    value: 5,
    parent: RefCell::new(Weak::new()),
    children: RefCell::new(vec![Rc::clone(&leaf)]),
  });
  
  *leaf.parent.borrow_mut() = Rc::downgrade(&branch);
  
  println!("leaf parent = {:?}", leaf.parent.borrow().upgrade());
}
```

修改后：

```rust
use std::rc::{ Rc, Weak };
use std::cell::RefCell;

#[derive(Debug)]
struct Node {
  value: i32,
  parent: RefCell<Weak<Node>>,
  children: RefCell<Vec<Rc<Node>>>,
}

fn main() {
  let leaf = Rc::new(Node {
    value: 3,
    parent: RefCell::new(Weak::new()),
    children: RefCell::new(vec![]),
  });
  
  println!(
    "leaf strong = {}, weak = {}",
   Rc::strong_count(&leaf),
   Rc::weak_count(&leaf),
  );
  
  {
    let branch = Rc::new(Node {
      value: 5,
      parent: RefCell::new(Weak::new()),
      children: RefCell::new(vec![Rc::clone(&leaf)]),
    });
  
    *leaf.parent.borrow_mut() = Rc::downgrade(&branch);

    println!(
      "leaf strong = {}, weak = {}",
      Rc::strong_count(&branch),
      Rc::weak_count(&branch),
    );
    println!(
      "leaf strong = {}, weak = {}",
      Rc::strong_count(&leaf),
      Rc::weak_count(&leaf),
    );
  }
  
  println!("leaf parent = {:?}", leaf.parent.borrow().upgrade());
  println!(
    "leaf strong = {}, weak = {}",
    Rc::strong_count(&leaf),
    Rc::weak_count(&leaf),
  );
}
```

## 总结

智能指针是Rust内存管理的核心组件，通过Box<T>、Rc<T>、RefCell<T>等类型，Rust提供了灵活而安全的内存操作方式。Box<T>适用于需要在堆上分配数据的场景，Rc<T>解决了多重所有权的问题，而RefCell<T>通过运行时借用检查实现了内部可变性。结合Rc<T>和RefCell<T>，开发者可以实现复杂的数据共享和修改逻辑，但需警惕循环引用导致的内存泄漏风险，Weak<T>则为此提供了优雅的解决方案。掌握智能指针的使用，不仅能提升Rust代码的效率和安全性，还能帮助开发者应对复杂的内存管理需求。快来动手实践，探索Rust智能指针的无限可能吧！

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://crates.io/>
- <https://course.rs/about-book.html>
- <https://doc.rust-lang.org/stable/rust-by-example/>
- <https://nomicon.purewhite.io/>
