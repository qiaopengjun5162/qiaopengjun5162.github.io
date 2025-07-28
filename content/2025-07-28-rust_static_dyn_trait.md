+++
title = "Rust Trait 分派机制：静态与动态的抉择与权衡"
description = "本文深入剖析 Rust Trait 的两大核心调用机制：静态分派与动态分派。文章通过解析“单态化”和“vtable”的底层原理，清晰对比了两者在编译速度、二进制文件大小和运行时性能上的根本差异。同时，我们探讨了“对象安全”等关键概念，并为开发者在库和应用程序开发中如何选择合适的分派策略提供了明确、实用的建议。"
date = 2025-07-28T01:33:53Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust Trait 分派机制：静态与动态的抉择与权衡

在使用 Rust 时，我们经常会用到 impl Trait 和 &dyn Trait 来处理泛型和接口。你是否曾好奇，这两种看似相似的语法，在编译器底层究竟是如何工作的？它们一个在编译期确定类型，一个在运行时查找实现，这背后隐藏着 Rust 语言设计的两大核心机制：静态分派 (Static Dispatch) 与 动态分派 (Dynamic Dispatch)。

本文将带你深入探索这两种分派方式的内部原理，从单态化 (Monomorphization) 到虚方法表 (vtable)，清晰地揭示它们的实现细节、性能优劣，并最终为你提供在实际项目中如何做出明智选择的实用指南。

## Trait（Bound）的编译与分派

### 静态分派（static dispatch）

- 编译泛型代码或者调用 dyn Trait 上的方法时发生了什么？
- 当编写关于泛型 T 的类型或函数时：
  - 编译器会针对每个 T （的类型），都将类型或函数复制一份
  - 当你构建 `Vec<i32>` 或 `HashMap<String, bool>` 的时候：
    - 编译器会复制它的泛型类型以及所有的实现块
      - 例如：`Vec<i32>`，就是对 Vec 做一个完整的复制，所有遇到的 T 都换成 i32
    - 并把每个实例的泛型参数使用具体类型替换
- 注意：编译器其实不会做完整的复制粘贴，它只复制你用的代码

```rust
impl String {
  pub fn contains(&self, p: impl Pattern) -> bool {
    f.is_contained_in(self)
  }
}
```

- 针对不同的 Pattern 类型，该方法都会复制一遍，为什么？
  - 因为我们需要知道 is_contained_in 方法的地址，以便进行调用。CPU 需要知道在哪跳转和继续执行
  - 对于任何给定的 Pattern，编译器知道那个地址是 Pattern 类型实现 Trait 方法的地址
  - 不存在一个可给任意类型用的通用地址
- 需要为每个类型复制一份（方法体），每份都有自己的地址，可用来跳转。
- 这就是静态分派（static dispatch）：
  - 因为对于方法的任何给定副本，我们“分派到”的地址都是静态已知的
- 静态（static）：就是指编译时已知的事务（或可被视为此的）。

### 单态化（monomorphization)

- 从一个泛型类型到多个泛型类型的过程叫做单态化
- 当编译器开始优化代码时，就好像根本没有泛型！
  - 每个实例都是单独优化的，具有了所有的已知类型
  - 所以 is_contained_in 方法调用的执行效率就如同 Trait 不存在一样
  - 编译器对设计的类型完全掌握，甚至可以将它进行 inline 实现

### 单态化的代价

- 所有的实例需要单独编译，编译时间增加（如果不能优化编译）
- 每个单态化的函数会有自己的一段机器码，让程序更大
- 指令在泛型方法的不同实例间无法共享，CPU 的指令缓存效率降低，因为它需要持有相同指令的多个不同副本

### 动态分派（dynamic dispatch）

- 动态分派：使代码可以调用泛型类型上的 trait 方法，而无需知道具体的类型

```rust
impl String {
  pub fn contains(&self, p: &dyn Pattern) -> bool {
    p.is_contained_in(&*self)
  }
}
```

- 调用者只需提供两个信息：
  - Pattern 的地址
  - is_contained_in 的地址

问题：为什么在 dyn 前面加 &？

### vtable

- 实际上，调用者会提供指向一块内存的指针，它叫做虚方法表（virtual method table）或叫 vtable
  - 它持上例该类型所有的 trait 方法实现的地址
    - 其中一个就是 is_contained_in
- 当代码想调用提供类型的一个 trait 方法时，就会从 vtable 查询 is_contained_in 方法的实现地址，并调用
  - 这允许我们使用相同的函数体，而不关心调用者想要使用的类型
- 每个 vtable 还包含具体类型的布局和对齐信息（总是需要这些）

### 对象安全（Object-Safe）

- 类型实现了一个 Trait 和它的 vtable 的组合就形成了一个 trait object （trait 对象）
- 大部分 trait 可转为 trait object，但不是所有：
  - 例如 Clone trait 就不行（它的 clone 方法返回 Self），Extend trait 也不行
  - 这些例子就不是 对象安全的（object-safe）
- 对象安全的要求：
  - trait 所有的方法都不能是泛型的，也不可以使用 Self
  - trait 不可拥有静态方法（无法知道在哪个实例上调用的方法）

### Self: Sized

- Self: Sized 意味着 Self 无法用于 trait object（因为它是 !Sized）
- 将 Self: Sized 用在某个 trait，就是要求它永远不使用动态分派
- 也可以将 Self: Sized 用在特定方法上，这时当 trait 通过 trait object 访问的时候，该方法就不可用了
- 当检查 trait 是否对象安全的时候，使用了 where Self: Sized 的方法就会被免除

### 动态分派

- 优点
  - 编译时间减少
  - 提升 CPU 指令缓存效率
- 缺点
  - 编译器无法对特定类型优化
    - 只能通过 vtable 调用函数
  - 直接调用方法的开销增加
    - trait object 上的每次方法调用都需要查 vtable

### 如何选择（一般而言）

- 静态分派
  - 在 library 中使用静态分派
    - 无法知道用户的需求
    - 如果使用动态分派，用户也只能如此
    - 如果使用静态分派，用户可自行选择
- 动态分派
  - 在 binary 中使用动态分派
    - binary 是最终代码
    - 动态分派使代码更整洁（省去了泛型参数）
    - 编译更快
    - 以边际性能为代价

## 总结

本文详细探讨了 Rust 中 Trait 的两种核心分派机制，它们是理解 Rust 性能和抽象能力的关键。

1. 静态分派 (Static Dispatch):

- 核心机制: 单态化 (Monomorphization)，即编译器在编译时为每个具体类型生成一份专门的代码。
- 优点: 性能极高，因为方法调用在编译期就已确定，可以进行内联等深度优化，运行时无额外开销。
- 缺点: 可能导致编译时间变长和最终生成的二进制文件体积增大。

2. 动态分派 (Dynamic Dispatch):

- 核心机制: 使用 dyn Trait 创建 Trait 对象，并通过虚方法表 (vtable) 在运行时查找并调用正确的方法。
  ·
- 优点: 提高代码灵活性，减少编译时间和二进制文件大小，提升 CPU 指令缓存效率。
- 缺点: 存在运行时开销（vtable 查询），且编译器无法进行跨类型的优化。

核心选择原则：

- 在编写库 (library) 时，优先使用静态分派（泛型），将选择权交给用户。
- 在编写应用程序 (binary) 时，可以根据具体场景考虑使用动态分派，以缩短编译时间、减小二进制体积。

理解静态与动态分派之间的权衡，能帮助我们写出更高效、更符合需求的 Rust 代码。这不仅仅是一个技术细节，更是体现 Rust “零成本抽象” 设计哲学的重要一环。

## 参考

- <https://course.rs/about-book.html>
- <https://lab.cs.tsinghua.edu.cn/rust/>
- <https://www.rust-lang.org/>
- <https://rustwiki.org/docs/>
- <https://rustcc.gitbooks.io/rustprimer/content/>
