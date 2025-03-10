+++
title = "Rust 所有权和 Move 语义"
date = 2024-01-20T14:28:09+08:00
[taxonomies]
tags = ["Rust"]
categories = ["Rust"]
+++

# Rust 所有权和 Move 语义

所有权和生命周期是 Rust 和其它编程语言的主要区别，也是 Rust 其它知识点的基础。

动态数组因为大小在编译期无法确定，所以放在堆上，并且在栈上有一个包含了长度和容量的胖指针指向堆上的内存。

恰到好处的限制，反而会释放无穷的创意和生产力。

## Rust 所有权规则

- 一个值只能被一个变量所拥有，这个变量被称为所有者。
- 一个值同一时刻只能有一个所有者，也就是说不能有两个变量拥有相同的值。所以对应变量赋值、参数传递、函数返回等行为，旧的所有者会把值的所有权转移给新的所有者，以便保证单一所有者的约束。
- 当所有者离开作用域，其拥有的值被丢弃，内存得到释放。

这三条规则很好理解，核心就是保证单一所有权。其中第二条规则讲的所有权转移是 Move 语义，Rust 从 C++ 那里学习和借鉴了这个概念。

第三条规则中的作用域（scope）指一个代码块（block），在 Rust 中，一对花括号括起来的代码区就是一个作用域。举个例子，如果一个变量被定义在 if {} 内，那么 if 语句结束，这个变量的作用域就结束了，其值会被丢弃；同样的，函数里定义的变量，在离开函数时会被丢弃。

所有权规则，解决了谁真正拥有数据的生杀大权问题，让堆上数据的多重引用不复存在，这是它最大的优势。
但是，它也有一个缺点，就是每次赋值、参数传递、函数返回等行为，都会导致旧的所有者把值的所有权转移给新的所有者，这会导致一些性能上的问题。

Rust 提供了两种解决方案：

- 如果你不希望值的所有权被转移，在 Move 语义外，Rust 提供了 Copy 语义。如果一个数据结构实现了 Copy trait，那么它就会使用 Copy 语义。这样，在你赋值或者传参时，值会自动按位拷贝（浅拷贝）。
- 如果你不希望值的所有权被转移，又无法使用 Copy 语义，那你可以“借用”数据。

## Rust 生命周期

生命周期（lifetime）是 Rust 中的一个概念，它描述了一个引用（reference）的生命周期。

在 Rust 中，生命周期可以用来解决引用（reference）的悬垂（dangling）问题。

## Rust 中的引用

在 Rust 中，引用（reference）是一个特殊的指针，它指向一个特定的数据，并且可以被用来访问该数据。

Rust 中的引用（reference）分为两种：

- 不可变引用（immutable reference）：不可变引用是指指向不可变数据的引用，即不能修改被引用的数据。
- 可变引用（mutable reference）：可变引用是指指向可变数据的引用，即可以修改被引用的数据。
Rust 中的引用（reference）是借用（borrow）的语法糖，它使得 Rust 中的数据更加安全。

## Rust 中的生命周期

在 Rust 中，生命周期（lifetime）是引用（reference）的一个属性，它描述了一个引用（reference）的生命周期。

Rust 中的生命周期（lifetime）分为两种：

- 静态生命周期（'static）：静态生命周期是指引用（reference）的生命周期直到程序结束。
- 动态生命周期（'a）：动态生命周期是指引用（reference）的生命周期由其作用域（scope）决定。

## Rust 中的借用检查器

在 Rust 中，借用检查器（borrow checker）是一个工具，它用于检查引用（reference）的合法性。

在 Rust 中，借用检查器会检查引用的生命周期，以确保引用的有效性。如果引用的生命周期不合法，那么编译器会给出错误提示。

## Rust 中的所有权和借用规则

在 Rust 中，所有权和借用规则是 borrow checker 的基础。

Rust 的所有权规则规定，每个值都有一个所有者（owner），并且每个值只能有一个所有者。当所有者离开作用域时，该值将被丢弃。

Rust 的借用规则规定，当一个值被借出时，不能被再次借出。

## Rust 中的生命周期规则

在 Rust 中，生命周期规则规定，当一个值被借出时，其生命周期必须大于等于所有者的生命周期。

如果一个值的生命周期小于所有者的生命周期，那么编译器会给出错误提示。

## Rust 中的生命周期省略规则

在 Rust 中，生命周期省略规则规定，当一个值被借出时，其生命周期可以被省略。

如果编译器能够根据上下文推断出该值的生命周期，那么编译器会自动将其生命周期省略。

## Rust 中的生命周期标注规则

在 Rust 中，生命周期标注规则规定，当一个值被借出时，其生命周期必须被标注。

如果编译器无法推断出该值的生命周期，那么编译器会给出错误提示。
