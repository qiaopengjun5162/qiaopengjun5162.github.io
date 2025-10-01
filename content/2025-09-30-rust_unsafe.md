+++
title = "揭秘 Rust Unsafe 编程：程序员接管内存安全的契约与实践"
description = "揭秘 Rust Unsafe 编程：程序员接管内存安全的契约与实践"
date = 2025-09-30T09:31:52Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 揭秘 Rust Unsafe 编程：程序员接管内存安全的契约与实践

Rust 语言以其**内存安全性**闻名于世，这主要得益于其严格的所有权和借用检查机制。然而，在进行系统级编程、与 C/C++ 代码交互、实现高度优化的数据结构或直接操作硬件时，我们必须进入 Rust 的“底层世界”——使用 `unsafe` 关键字。

`unsafe` 存在的意义并非允许我们为所欲为，而是要求我们履行一份**安全契约（Safety Contract）**。一旦使用了 `unsafe`，编译器就会信任你能够像编写 C 语言一样，手动保证代码的内存安全。本文将通过两个经典且实用的示例，揭示如何在 `unsafe` 环境下，通过明确的文档和代码保证代码的健全性。

Rust 的 `unsafe` 关键字并非关闭安全检查，而是将责任转交开发者。本文通过裸指针修改内存和 `Box` 转换两个实操案例，详细解析了 `unsafe` 下的“安全契约”（`# Safety`），阐明了程序员在处理底层内存时的核心责任与规范。

## 实操：Unsafe 的契约与裸指针

### 示例一：通过裸指针修改内存

```rust
// An `unsafe` in Rust serves as a contract.
//
// When `unsafe` is marked on an item declaration, such as a function,
// a trait or so on, it declares a contract alongside it. However,
// the content of the contract cannot be expressed only by a single keyword.
// Hence, its your responsibility to manually state it in the `# Safety`
// section of your documentation comment on the item.
//
// When `unsafe` is marked on a code block enclosed by curly braces,
// it declares an observance of some contract, such as the validity of some
// pointer parameter, the ownership of some memory address. However, like
// the text above, you still need to state how the contract is observed in
// the comment on the code block.
//
// NOTE: All the comments are for the readability and the maintainability of
// your code, while the Rust compiler hands its trust of soundness of your
// code to yourself! If you cannot prove the memory safety and soundness of
// your own code, take a step back and use safe code instead!

/// # Safety
///
/// The `address` must contain a mutable reference to a valid `u32` value.
unsafe fn modify_by_address(address: usize) {
    unsafe {
        *(address as *mut u32) = 0xAABBCCDD;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_success() {
        let mut t: u32 = 0x12345678;
        // SAFETY: The address is guaranteed to be valid and contains
        // a unique reference to a `u32` local variable.
        unsafe { modify_by_address(&mut t as *mut u32 as usize) };
        assert!(t == 0xAABBCCDD);
    }
}

```

这段 Rust 代码的核心在于演示和解释 **`unsafe`** 关键字在 Rust 中的作用、以及它所伴随的**安全契约**（Safety Contract）。代码实现了一个名为 `modify_by_address` 的不安全函数，其目的是通过内存地址直接修改一个 `u32` 变量的值。**`unsafe` 关键字本身并不关闭 Rust 的安全检查，而是将内存安全和代码健全性的责任从编译器转移给了程序员。**

具体来说：

1. **函数声明前的 `unsafe`：** `unsafe fn modify_by_address(address: usize)` 声明了一个不安全函数，这意味着调用者必须自行保证满足函数文档中的安全条件。在这里，安全契约在 `# Safety` 文档注释中明确指出：传入的 `address` 必须是一个有效的、指向可变 `u32` 值的内存地址。
2. **函数体内的 `unsafe` 块：** `unsafe { *(address as *mut u32) = 0xAABBCCDD; }` 标记了执行不安全操作的代码块。该代码将传入的整数地址 (`usize`) 强制转换为一个可变的裸指针 (`*mut u32`)，然后通过解引用 (`*`) 直接向该内存位置写入新的十六进制值 `0xAABBCCDD`。这种裸指针操作是绕过 Rust 所有权和借用检查的，因此必须放在 `unsafe` 块中。
3. **测试用例中的 `unsafe` 块：** 在 `test_success` 函数中，调用者通过 `&mut t as *mut u32 as usize` 将一个局部可变变量 `t` 的地址以 `usize` 类型传递给 `modify_by_address`。调用前的 `unsafe { ... }` 块表明程序员正在**遵守**函数声明时的安全契约，即保证这个地址是有效且独占的，从而确保了这次操作的内存安全性。

总之，这段代码是教科书式的示例，旨在教育开发者在编写 `unsafe` Rust 时，**必须**清晰地定义和遵守安全契约，以保持代码的可读性和内存安全性，因为编译器此时已经信任了开发者的判断。

## 实操：所有权与裸指针的转换

### 示例二：`Box::from_raw` 的应用

```rust
// In this example we take a shallow dive into the Rust standard library's
// unsafe functions.

struct Foo {
    a: u128,
    b: Option<String>,
}

/// # Safety
///
/// The `ptr` must contain an owned box of `Foo`.
unsafe fn raw_pointer_to_box(ptr: *mut Foo) -> Box<Foo> {
    // SAFETY: The `ptr` contains an owned box of `Foo` by contract.
    let mut ret: Box<Foo> = unsafe { Box::from_raw(ptr) };
    ret.b = Some("hello".to_owned());
    ret
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::time::Instant;

    #[test]
    fn test_success() {
        let data = Box::new(Foo { a: 1, b: None });

        let ptr_1 = &data.a as *const u128 as usize;
        // SAFETY: We pass an owned box of `Foo`.
        let ret = unsafe { raw_pointer_to_box(Box::into_raw(data)) };

        let ptr_2 = &ret.a as *const u128 as usize;

        assert!(ptr_1 == ptr_2);
        assert!(ret.b == Some("hello".to_owned()));
    }
}

```

这段 Rust 代码的核心在于探索标准库中的**不安全函数 `Box::from_raw`**，它演示了如何在**所有权**和**裸指针**之间进行转换，并强调了使用 `unsafe` 时的安全契约。

代码定义了一个结构体 `Foo` 和一个不安全函数 `raw_pointer_to_box`，该函数接受一个**裸指针** `*mut Foo` 作为输入，并将其转换为 Rust 的**智能指针 `Box<Foo>`**。要完成这种转换，开发者必须使用 `Box::from_raw`，这是一个不安全的标准库函数。它的安全契约是：传入的裸指针必须是先前通过 **`Box::into_raw`** 创建的，并且该指针指向的内存块当前没有其他拥有者（即它是一个**唯一的、有效的 Box**）。

在代码中：

1. **`Box::into_raw(data)`** 将 `data: Box<Foo>` 消耗掉，返回一个裸指针 `ptr`。此时，`data` 变量不再拥有内存的所有权，但内存本身仍然存活。
2. **`raw_pointer_to_box(ptr)`** 负责接收这个裸指针，并在内部使用 `Box::from_raw(ptr)` 将其**重新封装**回 `Box<Foo>`。这不仅重新构建了 `Box` 结构，更重要的是，它**重新建立了 Rust 的所有权**。
3. 测试用例通过断言 `ptr_1 == ptr_2` 证明了 `Box::into_raw` 和 `Box::from_raw` 只是在所有权结构上进行了转换，**内存地址本身保持不变**。

整个过程强调了 `unsafe` 编程的契约性：程序员必须保证传入 `Box::from_raw` 的指针是有效的、且是唯一的 Box 所有权来源，否则就会导致**内存重复释放（Double Free）**等未定义行为，从而破坏 Rust 的内存安全保证。

## 总结

这两个示例清楚地展示了 `unsafe` 代码的本质：它是一把双刃剑，赋予了我们强大的底层控制力，但要求我们承担全部的**安全责任**。

**`unsafe` 并不意味着可以关闭所有检查，它只是将部分责任转移给你。**

在编写 `unsafe` 代码时，以下几点至关重要：

1. **明确契约：** 每一个 `unsafe fn` 或 `unsafe trait` 都必须在文档中通过 `# Safety` 部分明确定义调用者需要满足的所有先决条件。
2. **遵守契约：** 每一个 `unsafe` 块都必须通过注释说明为什么这个块内的代码是安全的，即它是如何遵守外部安全契约的。
3. **自我证明：** 如果你无法证明一段 `unsafe` 代码是内存安全的（例如，不会导致数据竞争、内存泄漏或未定义行为），请不要使用它。

只有严格遵守这些规范，我们才能在享受 Rust 零抽象开销的性能优势时，仍然维护代码的最高安全标准。

## 参考

- <https://nomicon.purewhite.io/>
- <https://doc.rust-lang.org/book/>
- <https://doc.rust-lang.org/reference/index.html>
- <https://doc.rust-lang.org/nightly/unstable-book/index.html>
- <https://doc.rust-lang.org/std/index.html>
- <https://kaisery.github.io/trpl-zh-cn/>
