+++
title= "Rust 学习之数组和切片的大小问题"
date= 2023-10-09T00:10:23+08:00
[taxonomies]
tag= ["Rust"]
categories= ["Rust"]
+++

# Rust 学习之数组和切片的大小问题

### 问题

```shell
error[E0277]: the size for values of type `[{integer}]` cannot be known at compilation time
  --> exercises/primitive_types/primitive_types4.rs:14:9
   |
14 |     let nice_slice = a[1..4];
   |         ^^^^^^^^^^ doesn't have a size known at compile-time
   |
   = help: the trait `Sized` is not implemented for `[{integer}]`
   = note: all local variables must have a statically known size
   = help: unsized locals are gated as an unstable feature
help: consider borrowing here
   |
14 |     let nice_slice = &a[1..4];
   |                      +

error: aborting due to previous error

For more information about this error, try `rustc --explain E0277`.
```

### 解决

你的问题是在Rust编程语言中遇到的，它涉及到数组和切片的大小问题。在Rust中，所有的局部变量都必须有一个在编译时已知的大小。这是因为Rust需要在栈上分配这些变量，而栈上的空间大小是在编译时确定的。

在你的代码中，你试图创建一个名为 `nice_slice` 的变量，它是数组 `a` 的一个切片。然而，切片的大小是在运行时确定的，而不是在编译时。这就是为什么你收到了这个错误。

解决这个问题的一种方法是，你可以将 `nice_slice` 变为一个引用（&），如错误提示所建议的那样。这样，`nice_slice` 将指向切片，而不是拥有切片。由于引用的大小是固定的（在64位系统中为8字节，32位系统中为4字节），所以可以在编译时确定其大小。这是修改后的代码：

```rust

let nice_slice = &a[1..4];
```

这样，你就能够创建一个指向你所需切片的引用，而不是尝试在栈上直接存储切片本身。
