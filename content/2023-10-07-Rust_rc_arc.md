+++
title = "Rust 学习之所有权 Rc"
date = 2023-10-07T13:00:03+08:00
[taxonomies]
tags = ["Rust"]
categories = ["Rust"]
+++

# Rust 学习笔记之所有权 Rc

Rust 处理很多问题时的思路：

- 编译时，处理大部分使用场景，保证安全性和效率；
- 运行时，处理无法在编译时处理的场景，会牺牲一部分效率，提高灵活性。

Rust具体如何在运行时做动态检查呢？运行时的动态检查又如何与编译时的静态检查自洽呢？

Rust 的答案是使用引用计数的智能指针：Rc（Reference counter） 和 Arc（Atomic reference counter）。这里要特别说明一下，Arc 和 ObjC/Swift 里的 ARC（Automatic Reference Counting）不是一个意思，不过它们解决问题的手段类似，都是通过引用计数完成的。

## Rc

- 对某个数据结构 T，我们可以创建引用计数 Rc，使其有多个所有者。
- Rc 会把对应的数据结构创建在堆上。
- 堆是唯一可以让动态创建的数据被到处使用的内存。

```rust
use std::rc::Rc;
fn main() {    
  let a = Rc::new(1);
}
```

- 如果想对数据创建更多的所有者，我们可以通过 clone() 来完成。
- clone() 方法会创建一个新引用计数，并把新引用计数指向的数据的所有者数量加 1。

```rust
use std::rc::Rc;
fn main() {
  let a = Rc::new(1);
  let b = a.clone();
}
```

- 如果我们把数据的所有者数量减到 0，那么数据就会被销毁。
- 对一个 Rc 结构进行 clone()，不会将其内部的数据复制，只会增加引用计数。
- 当一个 Rc 结构离开作用域被 drop() 时，也只会减少其引用计数，直到引用计数为零，才会真正清除对应的内存。

```rust
use std::rc::Rc;
fn main() {
    let a = Rc::new(1);
    let b = a.clone();
    let c = a.clone();
}
```

上面的代码我们创建了三个 Rc，分别是 a、b 和 c。它们共同指向堆上相同的数据，也就是说，堆上的数据有了三个共享的所有者。在这段代码结束时，c 先 drop，引用计数变成 2，然后 b drop、a drop，引用计数归零，堆上内存被释放。

- a 是 Rc::new(1) 的所有者，b 和 c 是 a 的 clone() 所有者。
- 引用计数是 3，因为 a 有三个所有者，b 和 c 各有一个。
- 引用计数归零，a 离开作用域，a 的所有者变成 2，a 的内存被释放。
- b 和 c 离开作用域，引用计数减 1，b 和 c 的内存被释放。
- 从编译器的角度，abc 都各自拥有一个 Rc，所以编译器不会报错。

### Rc 的 clone() 函数的实现

Rc 的 clone() 函数的实现很简单，就是增加引用计数：

```rust
#[stable(feature = "rust1", since = "1.0.0")]
impl<T: ?Sized, A: Allocator + Clone> Clone for Rc<T, A> {
    /// Makes a clone of the `Rc` pointer.
    ///
    /// This creates another pointer to the same allocation, increasing the
    /// strong reference count.
    ///
    /// # Examples
    ///
    /// ```
    /// use std::rc::Rc;
    ///
    /// let five = Rc::new(5);
    ///
    /// let _ = Rc::clone(&five);
    /// ```
    #[inline]
    fn clone(&self) -> Self {
        unsafe {
            // 增加引用计数
            self.inner().inc_strong();
            / 通过 self.ptr 生成一个新的 Rc 结构
            Self::from_inner_in(self.ptr, self.alloc.clone())
        }
    }
}
```

更多详情请查看：

Rc文档：<https://docs.rs/rc/latest/rc/>

Rc 的 clone() 函数的实现：<https://doc.rust-lang.org/src/alloc/rc.rs.html#1433-1453>

## Box::leak()机制

Box::leak()：创建不受栈内存控制的堆内存，绕过编译时的所有权规则。

Box 是 Rust 下的智能指针，它可以强制把任何数据结构创建在堆上，然后在栈上放一个指针指向这个数据结构，但此时堆内存的生命周期仍然是受控的，跟栈上的指针一致。

Box::leak()，顾名思义，它创建的对象，从堆内存上泄漏出去，不受栈内存控制，是一个自由的、生命周期可以大到和整个进程的生命周期一致的对象。

#### Box::leak() 函数的实现

Box::leak() 函数的实现很简单，就是返回一个 Box 指针，指向堆内存，然后把堆内存的引用计数减 1：

```rust
#[stable(feature = "rust1", since = "1.0.0")]
impl<T> Box<T, A> {
    /// Consumes the `Box`, returning the wrapped pointer.
    ///
    /// The pointer will be deallocated, and the contents will be dropped.
    ///
    /// # Examples
    ///
    /// ```
    /// use std::boxed::Box;
    ///
    /// let x = Box::new(5);
    ///
    /// assert_eq!(5, *x);
    /// assert!(x.is_null());
    /// ```
    #[inline]
    #[stable(feature = "rust1", since = "1.0.0")]
    pub fn into_raw(b: Box<T, A>) -> *mut T {
        Box::into_raw(b)
    }
}

#[stable(feature = "rust1", since = "1.0.0")]
impl<T> Box<T> {
    /// Consumes the `Box`, returning the wrapped pointer.
    ///
    /// The pointer will be deallocated, and the contents will be dropped.
    ///
    /// # Examples
    ///
    /// ```
    /// use std::boxed::Box;
    ///
    /// let x = Box::new(5);
    ///
    /// assert_eq!(5, *x);
    /// assert!(x.is_null());
    /// ```
    #[inline]
    #[stable(feature = "rust1", since = "1.0.0")]
    pub fn into_raw(b: Box<T>) -> *mut T {
        Box::into_raw(b)
    }
}
```

- 堆：编译器静态检查受栈内存控制 = 创建它的栈内存的生命周期
- Box::leak：跳过编译器静态检查，不受栈内存控制 = 整个进程的生命周期

#### Rust 是如何进行所有权的静态检查和动态检查

- 静态检查，靠编译器保证代码符合所有权规则；
- 动态检查，通过 Box::leak 让堆内存拥有不受限的生命周期，然后在运行过程中，通过对引用计数的检查，保证这样的堆内存最终会得到释放。
