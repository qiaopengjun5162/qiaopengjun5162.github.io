+++
title = "Rust性能优化：零内存拷贝的链表合并技术实战"
description = "Rust性能优化：零内存拷贝的链表合并技术实战"
date = 2025-10-04T04:07:16Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust性能优化：零内存拷贝的链表合并技术实战

Rust 以其内存安全和零成本抽象著称，但在实现如链表合并这类底层数据结构和算法时，为追求**极致性能**，我们必须深入 **`unsafe`** 领域。本文将实战一种基于 **裸指针 (`NonNull`)** 的单向有序链表合并技术。该技术巧妙地**绕过 Rust 的所有权系统**，实现了**零内存拷贝**的 **O(N+M)** 合并算法，性能媲美 C 语言。同时，我们将重点展示如何通过正确实现 **`Drop` trait**，来确保我们在获得高性能的同时，依然能兑现 Rust 对**内存安全的承诺**。

> 本文介绍了如何使用 Rust 的 **`NonNull` 裸指针**类型构建一个高性能单向链表，以规避所有权系统在自引用结构上的限制。核心在于 **`merge` 方法**，该方法实现了两个已排序链表的**零内存拷贝**合并，通过直接修改节点间的指针（指针缝合）实现了 **O(N+M)** 的线性时间复杂度。为确保安全，我们在 `add` 方法中使用 **`Box::into_raw`** 转移所有权，并在 **`Drop` trait** 中通过 **`Box::from_raw`** 恢复并释放内存，完美平衡了底层性能与 Rust 的内存安全性。

## 💻 实战代码清单：基于 `NonNull` 的高性能链表实现

```rust
/*
    single linked list merge
*/

use std::fmt::{self, Display, Formatter};
use std::ptr::NonNull;
use std::vec::*;

#[derive(Debug)]
struct Node<T> {
    val: T,
    next: Option<NonNull<Node<T>>>,
}

impl<T> Node<T> {
    fn new(t: T) -> Node<T> {
        Node { val: t, next: None }
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
    pub fn merge(list_a: LinkedList<T>, list_b: LinkedList<T>) -> Self
    where
        T: PartialOrd,
    {
        unsafe {
            let mut current_a = list_a.start;
            let mut current_b = list_b.start;
            let mut result = Self::new();
            result.length = list_a.length + list_b.length;

            // current_merged_ptr 始终指向已合并部分的最后一个节点。
            let mut current_merged_ptr: Option<NonNull<Node<T>>> = None;

            // --- 1. 确定合并链表的起始节点 ---
            let initial_choice = loop {
                match (current_a, current_b) {
                    (Some(a_ptr), Some(b_ptr)) => {
                        let a_val = &(*a_ptr.as_ptr()).val;
                        let b_val = &(*b_ptr.as_ptr()).val;

                        // 比较值并选择较小的节点
                        if a_val <= b_val {
                            current_a = (*a_ptr.as_ptr()).next; // 推进 A 的指针
                            break Some(a_ptr);
                        } else {
                            current_b = (*b_ptr.as_ptr()).next; // 推进 B 的指针
                            break Some(b_ptr);
                        }
                    }
                    // 如果其中一个链表为空，则起始节点是另一个链表的头
                    (Some(a_ptr), None) => break Some(a_ptr),
                    (None, Some(b_ptr)) => break Some(b_ptr),
                    (None, None) => break None, // 两个链表都为空
                }
            };

            if initial_choice.is_none() {
                return Self::new(); // 返回空链表
            }

            // 设置结果链表的 start 和初始 merged_ptr
            result.start = initial_choice;
            current_merged_ptr = initial_choice;

            // --- 2. 循环合并剩余的节点 ---
            while current_a.is_some() && current_b.is_some() {
                let next_node_to_link: NonNull<Node<T>>;
                let a_ptr = current_a.unwrap();
                let b_ptr = current_b.unwrap();

                let a_val = &(*a_ptr.as_ptr()).val;
                let b_val = &(*b_ptr.as_ptr()).val;

                if a_val <= b_val {
                    next_node_to_link = a_ptr;
                    current_a = (*a_ptr.as_ptr()).next; // 推进 A
                } else {
                    next_node_to_link = b_ptr;
                    current_b = (*b_ptr.as_ptr()).next; // 推进 B
                }

                // 将已合并节点的 next 指针指向新选中的节点
                (*current_merged_ptr.unwrap().as_ptr()).next = Some(next_node_to_link);

                // 推进 current_merged_ptr
                current_merged_ptr = Some(next_node_to_link);
            }

            // --- 3. 连接剩余部分 (其中一个链表已耗尽) ---
            let remainder = current_a.or(current_b);

            if let Some(end_ptr) = current_merged_ptr {
                // 将 merged 链表的末尾连接到剩余部分的起始
                (*end_ptr.as_ptr()).next = remainder;
            }

            // --- 4. 确定最终的 end 指针 ---
            result.end = if remainder.is_some() {
                // 如果有剩余部分，则 end 是原链表的 end
                if current_a.is_some() {
                    list_a.end
                } else {
                    // current_b 必须是 Some
                    list_b.end
                }
            } else {
                // 如果没有剩余，则 end 是最后连接的节点
                current_merged_ptr
            };

            result
        }
    }
}

// ----------------------------------------------------
// ✅ 内存安全保障：实现 Drop Trait
// ----------------------------------------------------
impl<T> Drop for LinkedList<T> {
    fn drop(&mut self) {
        // 从链表头开始，依次将裸指针转换回 Box，触发 Box 的析构函数，从而安全释放内存。
        let mut current = self.start.take();

        while let Some(node_ptr) = current {
            // SAFETY:
            // 1. 我们正在 Drop 链表，保证了对该内存的所有权唯一性。
            // 2. 将 NonNull<T> 转换回 Box，以便 Rust 能够释放内存。
            let node_ptr_raw = node_ptr.as_ptr() as *mut Node<T>;
            let node = unsafe { Box::from_raw(node_ptr_raw) };

            // 移动到下一个节点，当前节点 (node) 在作用域结束时被安全释放。
            current = node.next.take();
        }
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
    fn test_merge_linked_list_1() {
        let mut list_a = LinkedList::<i32>::new();
        let mut list_b = LinkedList::<i32>::new();
        let vec_a = vec![1, 3, 5, 7];
        let vec_b = vec![2, 4, 6, 8];
        let target_vec = vec![1, 2, 3, 4, 5, 6, 7, 8];

        for i in 0..vec_a.len() {
            list_a.add(vec_a[i]);
        }
        for i in 0..vec_b.len() {
            list_b.add(vec_b[i]);
        }
        println!("list a {} list b {}", list_a, list_b);
        let mut list_c = LinkedList::<i32>::merge(list_a, list_b);
        println!("merged List is {}", list_c);
        for i in 0..target_vec.len() {
            assert_eq!(target_vec[i], *list_c.get(i as i32).unwrap());
        }
    }
    #[test]
    fn test_merge_linked_list_2() {
        let mut list_a = LinkedList::<i32>::new();
        let mut list_b = LinkedList::<i32>::new();
        let vec_a = vec![11, 33, 44, 88, 89, 90, 100];
        let vec_b = vec![1, 22, 30, 45];
        let target_vec = vec![1, 11, 22, 30, 33, 44, 45, 88, 89, 90, 100];

        for i in 0..vec_a.len() {
            list_a.add(vec_a[i]);
        }
        for i in 0..vec_b.len() {
            list_b.add(vec_b[i]);
        }
        println!("list a {} list b {}", list_a, list_b);
        let mut list_c = LinkedList::<i32>::merge(list_a, list_b);
        println!("merged List is {}", list_c);
        for i in 0..target_vec.len() {
            assert_eq!(target_vec[i], *list_c.get(i as i32).unwrap());
        }
    }
}
```

## Rust `unsafe` 单链表实现及零拷贝合并算法详解

这段 Rust 代码实现了一个**高性能的单向链表 (`LinkedList<T>`)**，它通过使用 **裸指针 (`std::ptr::NonNull`)** 绕过 Rust 的所有权系统，从而能够构建链表这种自引用的数据结构。这种实现方式能够提供与 C/C++ 媲美的性能，因为操作的是原始内存地址，而其最关键之处在于**正确实现了 `Drop` trait**，确保了在高性能的同时依然能保持 Rust 的**内存安全**承诺。

### 核心结构与内存管理

链表的核心由 **`Node<T>`** 和 **`LinkedList<T>`** 两个结构体构成。`Node<T>` 包含数据 `val` 和指向下一个节点的指针 `next`。这个 `next` 字段被定义为 **`Option<NonNull<Node<T>>>`**，`NonNull` 是一个非空裸指针，它的使用是绕开 Rust 所有权检查、构建链表的唯一途径。`LinkedList<T>` 则作为链表的容器，维护着 **`length`**、链表头部 **`start`** 和链表尾部 **`end`** 的裸指针。`end` 指针是关键优化，它确保了 `add` 方法（在链表尾部添加元素）的时间复杂度为 O(1)。

### 节点添加 (`add`) 与所有权交接

`add` 方法是手动内存管理的关键。它首先使用 **`Box::new()`** 在堆上安全地创建新节点，并由 `Box` 拥有所有权。随后，它调用 **`Box::into_raw(node)`**，这是一个**所有权交接的仪式**：`Box` 放弃了对堆内存的所有权，并返回一个 **`\*mut Node<T>` 原始指针**。一旦使用了 `into_raw`，Rust 就停止自动管理这块内存，程序员必须负责其生命周期。接下来的代码在 `unsafe` 块中执行：它将原始指针封装成 `NonNull`，然后通过解引用旧的 `end` 指针，修改其 `next` 字段，将新节点链接到链表的末尾。

### 访问元素 (`get`) 与安全封装

`get` 方法提供了按索引访问元素的功能。它通过递归的 **`get_ith_node`** 方法遍历链表查找目标节点。其核心在于 **`unsafe { &(*next_ptr.as_ptr()).val }`**，它在 `unsafe` 块内进行裸指针的解引用，访问节点数据，但最终返回给调用者的是一个**安全的、不可变的 Rust 引用 (`&T`)**。这种模式是将底层的不安全操作封装起来，向外部暴露一个安全的 API。值得注意的是，`get` 方法的签名使用了 `&mut self`，尽管它只是只读操作，更规范的 Rust 做法应该是使用 `&self`。

### 核心算法：零拷贝有序合并 (`merge`)

`merge` 方法是这段代码的精华，它实现了两个**已排序**链表的高效合并。该函数以**值**的形式接收 `list_a` 和 `list_b`，从而获得了两个链表中所有节点的独占所有权。算法的核心在于其**零内存拷贝**策略，时间复杂度为 **O(N + M)**，性能极高。

1. **确定起点**: 算法首先比较两个链表的头节点，选择值较小的一个作为新合并链表的起点。
2. **主循环重链接**: 在 `while` 循环中，它不断比较 `list_a` 和 `list_b` 的当前节点，选择值较小的节点。**零拷贝**是通过 **`(*current_merged_ptr.unwrap().as_ptr()).next = Some(next_node_to_link)`** 实现的——直接在 `unsafe` 块中修改已合并链表尾部节点的 `next` 裸指针，将其指向新选中的节点，**不涉及任何数据复制或内存分配**。
3. **连接剩余部分**: 当其中一个链表遍历完后，另一个链表剩余的已排序部分（`remainder`）会通过一个 **O(1)** 的操作被整体嫁接到新链表的末尾，避免了逐个节点遍历和链接的开销。
4. **尾部维护**: 最后，根据是否有剩余部分被连接，正确设置新链表的 `result.end` 指针。

### 内存安全保障 (`Drop` Trait)

由于 `add` 中使用了 `Box::into_raw` 放弃了所有权，**`Drop` trait 的实现是保证内存安全的关键**。`Drop::drop` 方法通过遍历链表，对每个 `NonNull` 裸指针调用 **`unsafe { Box::from_raw(ptr) }`**。这一操作将裸指针**恢复为 `Box<Node<T>>`**，重新建立 Rust 所有权。当这个临时的 `Box` 离开作用域时，Rust 的析构系统会自动触发 `Box` 的内存释放，**安全地回收了所有堆内存，从而避免了内存泄漏**。正是这一机制，使得这段 `unsafe` 链表代码成为了一个在性能和安全之间取得平衡的健壮实现。

## 总结

本次实战成功展示了在 Rust 中利用 **`unsafe` 裸指针**实现一个极高性能、**零内存拷贝**的有序链表合并算法。该算法的关键在于直接操作指针进行**链表重链接**，避免了数据复制，从而将时间复杂度优化到 **O(N+M)** 的理论最优水平。最重要的是，我们通过 **`Drop` trait** 机制，利用 **`Box::from_raw`** 恢复了对裸指针指向内存的所有权并触发了自动析构，有效防止了内存泄漏。这一实现是 Rust 开发者在追求极致性能时，如何将 **性能与内存安全** 结合的最佳范例。

## 参考

- **Rust 程序设计语言：** <https://kaisery.github.io/trpl-zh-cn/>

- **通过例子学 Rust：** <https://rustwiki.org/zh-CN/rust-by-example/>

- **Rust 语言圣经：** <https://course.rs/about-book.html>

- **Rust 秘典：** <https://nomicon.purewhite.io/intro.html>

- **Rust 算法教程：** <https://algo.course.rs/about-book.html>

- **Rust 参考手册：** <https://rustwiki.org/zh-CN/reference/introduction.html>
