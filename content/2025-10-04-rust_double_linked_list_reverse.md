+++
title = "Rust 进阶：用 `NonNull` 裸指针实现高性能双向链表 O(N) 反转实战"
description = "Rust 进阶：用 `NonNull` 裸指针实现高性能双向链表 O(N) 反转实战"
date = 2025-10-04T05:17:44Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# **Rust 进阶：用 `NonNull` 裸指针实现高性能双向链表 O(N) 反转实战**

Rust 以其**内存安全**和**零成本抽象**闻名，但当我们需要构建如双向链表这类复杂的**自引用数据结构**，并追求极致的底层性能时，就必须深入 **`unsafe`** 的领域。

本文将带你探索 Rust 的安全边界，实战一个基于 **`NonNull` 裸指针**的高性能双向链表。我们将详细解析如何利用裸指针实现**线性 O(N) 时间复杂度**的**原地反转**算法，性能直接对标 C/C++。

更重要的是，我们将重点展示 Rust 工程师如何负责任地管理内存：在 **`unsafe`** 环境下操作 `Box::into_raw` 放弃所有权后，如何通过严谨的 **`Drop` Trait 实现**来安全回收堆内存，完美地证明 **“Fast and Safe”** 在底层编程中是完全可兼得的。

在 Rust 中实现高性能链表必须面对**所有权**的挑战。本文实战基于 **`NonNull` 裸指针**的双向链表，实现了 O(N) 复杂度的**原地反转**算法，性能媲美 C 语言。关键是通过 `unsafe` 直接操作指针高效重排结构。同时，我们通过**正确实现 `Drop` Trait**，将内存所有权安全地交还给 Rust 析构系统，完美平衡了**极致性能**与 **内存安全** 的承诺。

## 实操

### 双向链表反转

```rust
/*
    double linked list reverse
*/

use std::fmt::{self, Display, Formatter};
use std::ptr::NonNull;
use std::vec::*;

#[derive(Debug)]
struct Node<T> {
    val: T,
    next: Option<NonNull<Node<T>>>,
    prev: Option<NonNull<Node<T>>>,
}

impl<T> Node<T> {
    fn new(t: T) -> Node<T> {
        Node {
            val: t,
            prev: None,
            next: None,
        }
    }
}
#[derive(Debug)]
struct LinkedList<T> {
    length: u32,
    start: Option<NonNull<Node<T>>>,
    end: Option<NonNull<Node<T>>>,
}

impl<T> Default for LinkedList<T> {
    fn default() -> Self {
        Self::new()
    }
}

impl<T> LinkedList<T> {
    pub fn new() -> Self {
        Self {
            length: 0,
            start: None,
            end: None,
        }
    }

    pub fn add(&mut self, obj: T) {
        let mut node = Box::new(Node::new(obj));
        node.next = None;
        node.prev = self.end;
        let node_ptr = Some(unsafe { NonNull::new_unchecked(Box::into_raw(node)) });
        match self.end {
            None => self.start = node_ptr,
            Some(end_ptr) => unsafe { (*end_ptr.as_ptr()).next = node_ptr },
        }
        self.end = node_ptr;
        self.length += 1;
    }

    pub fn get(&mut self, index: i32) -> Option<&T> {
        self.get_ith_node(self.start, index)
    }

    fn get_ith_node(&mut self, node: Option<NonNull<Node<T>>>, index: i32) -> Option<&T> {
        match node {
            None => None,
            Some(next_ptr) => match index {
                0 => Some(unsafe { &(*next_ptr.as_ptr()).val }),
                _ => self.get_ith_node(unsafe { (*next_ptr.as_ptr()).next }, index - 1),
            },
        }
    }
    pub fn reverse(&mut self) {
        // 只有 0 或 1 个元素的链表无需反转
        if self.length <= 1 {
            return;
        }

        // 使用 unsafe 代码进行裸指针操作
        unsafe {
            let mut current = self.start;

            // 1. 遍历所有节点，交换 next 和 prev
            while let Some(mut node_ptr) = current {
                let node_ref = node_ptr.as_ptr();

                // 暂时保存原始的 next 指针，这是下一次循环要移动到的节点
                let original_next = (*node_ref).next;

                // 交换 next 和 prev 指针：
                // 新的 next 应该指向旧的 prev
                (*node_ref).next = (*node_ref).prev;
                // 新的 prev 应该指向旧的 next
                (*node_ref).prev = original_next;

                // 推进到下一个节点（即原始的 next 指针）
                current = original_next;
            }

            // 2. 交换链表的 start 和 end 指针
            std::mem::swap(&mut self.start, &mut self.end);
        }
    }
}

// ----------------------------------------------------
// ✅ 内存安全保障：实现 Drop Trait
// ----------------------------------------------------
impl<T> Drop for LinkedList<T> {
    fn drop(&mut self) {
        // 从链表头部开始，依次将裸指针转换回 Box，触发 Box 的析构函数，从而安全释放内存。

        // 1. 取出链表头指针。take() 将 self.start 置为 None，确保链表结构被清空。
        let mut current = self.start.take();

        // 2. 循环遍历所有节点
        while let Some(node_ptr) = current {

            // SAFETY:
            // 1. 我们正在 Drop 链表，保证了对该内存的所有权是唯一的（因为 LinkedList 即将被销毁）。
            // 2. Box::from_raw() 恢复了 Rust 对该堆内存的所有权。
            let node_ptr_raw = node_ptr.as_ptr();
            let node = unsafe { Box::from_raw(node_ptr_raw) };

            // 3. 移动到下一个节点
            // node.next 是 Option<NonNull<Node<T>>>。
            // 必须使用 take() 将其从当前节点中移出，这样 current 才能指向下一个节点。
            current = node.next.take();

            // 当前节点 'node'（一个 Box）在离开作用域时（此处循环结束）
            // 会被 Rust 自动调用析构函数（Drop），安全释放内存。
        }

        // 额外操作：由于 Drop 只能从 start 向后遍历，我们需要显式清除 end
        // 这一步虽然在逻辑上不严格必要（因为 start 已经接管了释放责任），
        // 但可以保证 LinkedList 实例在被销毁时是完全干净的。
        self.end.take();
        self.length = 0;
    }
}
// ----------------------------------------------------

impl<T> Display for LinkedList<T>
where
    T: Display,
{
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        match self.start {
            Some(node) => write!(f, "{}", unsafe { node.as_ref() }),
            None => Ok(()),
        }
    }
}

impl<T> Display for Node<T>
where
    T: Display,
{
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        match self.next {
            Some(node) => write!(f, "{}, {}", self.val, unsafe { node.as_ref() }),
            None => write!(f, "{}", self.val),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::LinkedList;

    #[test]
    fn create_numeric_list() {
        let mut list = LinkedList::<i32>::new();
        list.add(1);
        list.add(2);
        list.add(3);
        println!("Linked List is {}", list);
        assert_eq!(3, list.length);
    }

    #[test]
    fn create_string_list() {
        let mut list_str = LinkedList::<String>::new();
        list_str.add("A".to_string());
        list_str.add("B".to_string());
        list_str.add("C".to_string());
        println!("Linked List is {}", list_str);
        assert_eq!(3, list_str.length);
    }

    #[test]
    fn test_reverse_linked_list_1() {
        let mut list = LinkedList::<i32>::new();
        let original_vec = vec![2, 3, 5, 11, 9, 7];
        let reverse_vec = vec![7, 9, 11, 5, 3, 2];
        for i in 0..original_vec.len() {
            list.add(original_vec[i]);
        }
        println!("Linked List is {}", list);
        list.reverse();
        println!("Reversed Linked List is {}", list);
        for i in 0..original_vec.len() {
            assert_eq!(reverse_vec[i], *list.get(i as i32).unwrap());
        }
    }

    #[test]
    fn test_reverse_linked_list_2() {
        let mut list = LinkedList::<i32>::new();
        let original_vec = vec![34, 56, 78, 25, 90, 10, 19, 34, 21, 45];
        let reverse_vec = vec![45, 21, 34, 19, 10, 90, 25, 78, 56, 34];
        for i in 0..original_vec.len() {
            list.add(original_vec[i]);
        }
        println!("Linked List is {}", list);
        list.reverse();
        println!("Reversed Linked List is {}", list);
        for i in 0..original_vec.len() {
            assert_eq!(reverse_vec[i], *list.get(i as i32).unwrap());
        }
    }
}

```

## 🛠️ 裸指针双向链表：结构、性能与内存安全

这段 Rust 代码呈现了一个高性能的**双向链表 (`LinkedList<T>`)** 实现，它通过使用 **`std::ptr::NonNull` 裸指针**，巧妙地规避了 Rust 所有权系统对链表这种**自引用数据结构**的限制。这种实现方式使我们能够实现与 C/C++ 媲美的底层性能，特别是在操作大型数据结构时。

### 1. 结构与所有权转移

- **核心结构**：`Node<T>` 包含了数据 `val`、指向下一节点的裸指针 `next`，以及指向上一节点的裸指针 `prev`。
- **节点添加 (`add`)**：该方法是所有权转移的关键。我们首先使用 `Box::new()` 安全地在堆上创建节点，然后通过 **`Box::into_raw(node)`** 将 `Box` 智能指针的所有权彻底放弃，只返回一个原始指针。此后，这块内存的生命周期和安全释放完全由程序员手动负责。
- **裸指针操作**：在 `add` 中，我们通过 **`unsafe`** 块解引用 (`*end_ptr.as_ptr()`) 旧的尾指针，并修改其 `next` 字段，将新节点缝合到链表末尾，实现了**O(1)** 的高效尾部插入。

### 2. 核心算法：原地反转 (`reverse`)

`reverse` 方法实现了双向链表**原地反转（In-Place Reversal）**的经典算法，其时间复杂度为线性 O(N)。

- **指针交换**：算法的核心逻辑在于遍历链表中的每一个节点，并利用裸指针的优势，**交换**该节点的 **`next` 指针**和 **`prev` 指针**。
  - 在 `unsafe` 块中，我们首先缓存原始的 `next` 指针 (`original_next`)，这是因为我们下一步需要用它来推进循环。
  - 随后，我们执行 **`(*node_ref).next = (*node_ref).prev`** (将 `next` 指向前一个节点) 和 **`(*node_ref).prev = original_next`** (将 `prev` 指向后一个节点) 的操作。
- **零拷贝**：这个过程**不涉及任何数据复制或新的内存分配**。我们只是在堆内存中修改了节点内部的指针地址，实现了极致效率的链表结构重排。
- **头尾更新**：遍历完成后，所有节点的局部指针已反转，但链表容器的全局指针 (`self.start` 和 `self.end`) 仍指向旧的头尾。最后通过 **`std::mem::swap(&mut self.start, &mut self.end)`**，以一个**O(1)** 的操作，交换头尾指针，完成整个链表的逻辑反转。

### 3. 内存安全保障 (Drop Trait)

由于 `add` 中使用了 `Box::into_raw` 放弃了所有权，**`Drop` Trait 的正确实现是保证内存安全的关键**，它负责回收所有被手动管理的堆内存，从而避免内存泄漏。

- **恢复所有权**：在 `drop` 方法中，我们从链表头部开始遍历。对于获得的每一个裸指针，我们调用 **`unsafe { Box::from_raw(node_ptr_raw) }`**。这一操作将裸指针指向的内存**重新封装成一个临时的 `Box<Node<T>>` 智能指针**，有效地将内存的所有权交还给 Rust。
- **安全释放**：当这个临时的 `Box` 变量在循环结束时离开其作用域，**Rust 的析构系统会自动触发 `Box` 的内存释放机制**，安全地回收了堆内存。
- **链式析构**：我们通过 **`current = node.next.take()`** 推进到下一个节点，并在前一个节点被安全释放后，对链上的每一个节点重复此过程，确保了整个链表的**链式安全析构**。正是这一严谨的机制，使得我们的 `unsafe` 代码依然能够兑现 Rust 对内存安全的承诺。

## 总结

本次实战成功展示了在 Rust 中利用 **`unsafe` 裸指针**实现一个高性能双向链表，并完成了经典的 **O(N) 原地反转**算法。该实现的核心在于在 **`unsafe`** 块内直接**交换节点的 `next` 和 `prev` 裸指针**，以零内存拷贝的方式完成了链表结构的重排，达到了算法的理论性能上限。

**技术亮点回顾：**

1. **性能突破**：利用 `NonNull` 绕过所有权检查，实现 O(1) 尾部插入和 O(N) 原地反转。
2. **内存管理**：通过 **`Box::into_raw`** 放弃所有权，并使用 **`Box::from_raw`** 在 **`Drop` Trait** 中恢复所有权并触发安全析构。

这一实践是 Rust 开发者在追求底层极致性能时，如何**恪守内存安全承诺**的最佳示例。它表明，掌握 `unsafe` 并不意味着放弃安全，而是获得了在 Rust 框架下**像 C 语言一样高效操作内存**的能力。

## 参考

- rust-lang.org/zh-CN
- <https://algo.course.rs/>
- <https://github.com/rustcn-org/rust-algos>
- <https://rustwiki.org/zh-CN/rust-cookbook/algorithms.html>
- <https://github.com/huangbqsky/rust-datastruct-and-algorithm>
- <https://rusty.course.rs/algos/awesome.html>
- <https://github.com/RustCrypto>
