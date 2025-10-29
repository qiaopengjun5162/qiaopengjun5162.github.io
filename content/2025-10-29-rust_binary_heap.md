+++
title = "告别重复造轮子：用 Rust 实现一个可大可小的通用“万能”二叉堆"
description = "告别重复造轮子：用 Rust 实现一个可大可小的通用“万能”二叉堆"
date = 2025-10-29T13:02:13Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 告别重复造轮子：用 Rust 实现一个可大可小的通用“万能”二叉堆

在高性能编程领域，**堆（Heap）** 是一个基石般的数据结构，广泛应用于优先队列、调度算法、以及各种高效的排序场景中。Rust 语言标准库虽然提供了 `std::collections::BinaryHeap`，但它是一个最大堆。

本篇文章将带你深入理解堆的原理，并利用 **Rust 的泛型、函数指针和 `Iterator` Trait** 的强大组合，亲手打造一个**通用、灵活且高性能**的二叉堆（`Heap<T>`）。它能够通过一个简单的比较函数切换，在**最小堆（MinHeap）** 和 **最大堆（MaxHeap）** 之间自由转换，让你彻底掌握这一核心算法结构。

本文使用 Rust 实现了高度泛化的二叉堆（Binary Heap）。通过传入自定义的**比较函数**（`fn(&T, &T) -> bool`）控制堆的性质，轻松实现**最小堆**和**最大堆**的切换。代码结构清晰，利用数组下标从 1 开始的技巧简化了父子节点索引计算。同时，通过实现 **`Iterator` Trait**，使得堆顶元素的提取过程（`next()`）优雅地融入 Rust 生态，是学习和实践 Rust 数据结构与算法的绝佳案例。

## 实操

实现一个 **通用的二叉堆（Binary Heap）**

```rust
/*
    heap
    implement a binary heap function
*/

use std::cmp::Ord;
use std::default::Default;

pub struct Heap<T>
where
    T: Default,
{
    count: usize,
    items: Vec<T>,
    comparator: fn(&T, &T) -> bool,
}

impl<T> Heap<T>
where
    T: Default,
{
    pub fn new(comparator: fn(&T, &T) -> bool) -> Self {
        Self {
            count: 0,
            items: vec![T::default()],
            comparator,
        }
    }

    pub fn len(&self) -> usize {
        self.count
    }

    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }

    pub fn add(&mut self, value: T) {
        self.count += 1;

        // 1. 将新值添加到 items 的末尾（即 items[self.count]）
        if self.items.len() > self.count {
            self.items[self.count] = value;
        } else {
            self.items.push(value);
        }

        // 2. 向上浮动 (Sift-Up)
        let mut current_idx = self.count;

        // 只要当前节点不是根节点 (idx > 1)
        while current_idx > 1 {
            let parent_idx = self.parent_idx(current_idx);

            // 检查当前节点和父节点是否违反堆属性
            // (即在 MinHeap 中，子节点比父节点小；在 MaxHeap 中，子节点比父节点大)
            if (self.comparator)(&self.items[current_idx], &self.items[parent_idx]) {
                // 违反属性，交换
                self.items.swap(current_idx, parent_idx);
                current_idx = parent_idx;
            } else {
                // 属性已满足，停止上浮
                break;
            }
        }
    }

    fn parent_idx(&self, idx: usize) -> usize {
        idx / 2
    }

    fn children_present(&self, idx: usize) -> bool {
        self.left_child_idx(idx) <= self.count
    }

    fn left_child_idx(&self, idx: usize) -> usize {
        idx * 2
    }

    fn right_child_idx(&self, idx: usize) -> usize {
        self.left_child_idx(idx) + 1
    }

    fn smallest_child_idx(&self, idx: usize) -> usize {
        let left_idx = self.left_child_idx(idx);
        let right_idx = self.right_child_idx(idx);

        // 1. 检查是否有右子节点
        if right_idx > self.count {
            // 只有左子节点（或没有子节点，但 children_present 已经保证了至少有左子节点）
            left_idx
        } else {
            // 2. 左右子节点都存在，使用比较器判断哪个更符合堆属性
            // (self.comparator)(a, b) 为 true，则 a 是我们想要的 (e.g., MinHeap 中 a 较小)
            if (self.comparator)(&self.items[left_idx], &self.items[right_idx]) {
                left_idx
            } else {
                right_idx
            }
        }
    }
}

impl<T> Heap<T>
where
    T: Default + Ord,
{
    /// Create a new MinHeap
    pub fn new_min() -> Self {
        Self::new(|a, b| a < b)
    }

    /// Create a new MaxHeap
    pub fn new_max() -> Self {
        Self::new(|a, b| a > b)
    }
}

impl<T> Iterator for Heap<T>
where
    T: Default,
{
    type Item = T;

    fn next(&mut self) -> Option<T> {
        if self.is_empty() {
            return None;
        }

        // 1. 交换根节点 (index 1) 和最后一个元素 (index self.count)
        self.items.swap(1, self.count);

        // 2. 弹出并返回旧的根节点（现在在末尾）
        self.count -= 1;
        // 因为 self.items[0] 是默认值，所以我们pop掉最后一个元素是安全的
        let extracted_value = self.items.pop().unwrap_or_default();

        // 3. 向下沉降 (Sift-Down)
        let mut current_idx = 1;

        while self.children_present(current_idx) {
            // 找到最符合堆属性的子节点索引
            let target_child_idx = self.smallest_child_idx(current_idx);

            // 检查当前节点是否违反堆属性与目标子节点进行比较
            // 如果子节点比当前节点更符合堆属性 (e.g., MinHeap 中子节点更小)
            if (self.comparator)(&self.items[target_child_idx], &self.items[current_idx]) {
                // 违反属性，交换
                self.items.swap(current_idx, target_child_idx);
                current_idx = target_child_idx;
            } else {
                // 属性已满足，停止下沉
                break;
            }
        }

        Some(extracted_value)
    }
}

pub struct MinHeap;

impl MinHeap {
    #[allow(clippy::new_ret_no_self)]
    pub fn new<T>() -> Heap<T>
    where
        T: Default + Ord,
    {
        Heap::new(|a, b| a < b)
    }
}

pub struct MaxHeap;

impl MaxHeap {
    #[allow(clippy::new_ret_no_self)]
    pub fn new<T>() -> Heap<T>
    where
        T: Default + Ord,
    {
        Heap::new(|a, b| a > b)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn test_empty_heap() {
        let mut heap = MaxHeap::new::<i32>();
        assert_eq!(heap.next(), None);
    }

    #[test]
    fn test_min_heap() {
        let mut heap = MinHeap::new();
        heap.add(4);
        heap.add(2);
        heap.add(9);
        heap.add(11);
        assert_eq!(heap.len(), 4);
        assert_eq!(heap.next(), Some(2));
        assert_eq!(heap.next(), Some(4));
        assert_eq!(heap.next(), Some(9));
        heap.add(1);
        assert_eq!(heap.next(), Some(1));
    }

    #[test]
    fn test_max_heap() {
        let mut heap = MaxHeap::new();
        heap.add(4);
        heap.add(2);
        heap.add(9);
        heap.add(11);
        assert_eq!(heap.len(), 4);
        assert_eq!(heap.next(), Some(11));
        assert_eq!(heap.next(), Some(9));
        assert_eq!(heap.next(), Some(4));
        heap.add(1);
        assert_eq!(heap.next(), Some(2));
    }
}

```

这段 Rust 代码完整实现了一个 **通用的二叉堆（Binary Heap）**，支持同时构建 **最小堆 (MinHeap)** 和 **最大堆 (MaxHeap)**，并且通过泛型和函数指针实现了灵活的比较逻辑。

------

### 📘 Rust 二叉堆实现详解

这段代码实现了一个通用的 **堆 (Heap)** 数据结构，它支持通过传入不同的比较函数构造 **最小堆** 或 **最大堆**。堆是一种完全二叉树，常用于 **优先队列 (Priority Queue)**、**排序算法 (Heap Sort)** 等场景。

------

#### 🧩 1. 结构体定义

```rust
pub struct Heap<T>
where
    T: Default,
{
    count: usize,                    // 当前堆中元素数量
    items: Vec<T>,                   // 存储堆元素的动态数组，下标从 1 开始
    comparator: fn(&T, &T) -> bool,  // 比较函数，用于控制堆的性质（大顶堆/小顶堆）
}
```

- `items[0]` 被保留为默认值（不参与运算），这使得计算父子节点索引更简单：
  - 父节点：`idx / 2`
  - 左子节点：`idx * 2`
  - 右子节点：`idx * 2 + 1`
- `comparator` 是一个函数指针，它决定了堆的排序规则。
   例如：
  - 对于最小堆：`|a, b| a < b`
  - 对于最大堆：`|a, b| a > b`

------

#### ⚙️ 2. 构造与基本操作

```rust
pub fn new(comparator: fn(&T, &T) -> bool) -> Self { ... }
pub fn len(&self) -> usize { self.count }
pub fn is_empty(&self) -> bool { self.count == 0 }
```

这些函数提供了堆的基本管理功能。`new` 初始化堆并设置比较逻辑，`len` 和 `is_empty` 提供统计信息。

------

#### 🔼 3. 元素插入：上浮（Sift-Up）

```rust
pub fn add(&mut self, value: T) { ... }
```

插入新元素的逻辑是堆的核心：

1. **将新元素插入数组末尾**

   ```rust
   self.items.push(value);
   self.count += 1;
   ```

2. **向上比较并交换**
    从新插入的节点开始，不断和父节点比较。如果违反堆的性质（例如在最小堆中，子节点比父节点更小），就交换它们的位置。

   ```rust
   while current_idx > 1 {
       let parent_idx = self.parent_idx(current_idx);
       if (self.comparator)(&self.items[current_idx], &self.items[parent_idx]) {
           self.items.swap(current_idx, parent_idx);
           current_idx = parent_idx;
       } else {
           break;
       }
   }
   ```

这一过程确保了堆在插入新元素后仍然保持有序。

------

#### 🔽 4. 元素移除：下沉（Sift-Down）

实现了 `Iterator` trait 后，可以使用 `.next()` 来弹出堆顶元素。

```rust
fn next(&mut self) -> Option<T> {
    if self.is_empty() { return None; }

    // 1. 交换根节点和最后一个节点
    self.items.swap(1, self.count);

    // 2. 弹出堆顶
    let extracted_value = self.items.pop().unwrap_or_default();
    self.count -= 1;

    // 3. 从根开始下沉
    let mut current_idx = 1;
    while self.children_present(current_idx) {
        let target_child_idx = self.smallest_child_idx(current_idx);
        if (self.comparator)(&self.items[target_child_idx], &self.items[current_idx]) {
            self.items.swap(current_idx, target_child_idx);
            current_idx = target_child_idx;
        } else {
            break;
        }
    }

    Some(extracted_value)
}
```

✅ `next()` 会不断返回当前堆顶元素，并在每次调用后重新维护堆的有序性。
 这样我们可以像迭代器一样使用堆来进行排序（堆排序的核心机制）。

------

#### 🧮 5. MinHeap 和 MaxHeap 的封装

为方便用户使用，代码提供了两个结构体包装器：

```rust
pub struct MinHeap;
pub struct MaxHeap;
```

它们的 `new()` 方法分别指定不同的比较逻辑：

```rust
pub fn new<T>() -> Heap<T>
where
    T: Default + Ord,
{
    Heap::new(|a, b| a < b)  // 最小堆
}
pub fn new<T>() -> Heap<T>
where
    T: Default + Ord,
{
    Heap::new(|a, b| a > b)  // 最大堆
}
```

------

#### 🧪 6. 单元测试

代码附带的测试验证了堆的基本功能：

- 空堆测试
- 最小堆的正确弹出顺序（从小到大）
- 最大堆的正确弹出顺序（从大到小）

```rust
#[test]
fn test_min_heap() {
    let mut heap = MinHeap::new();
    heap.add(4);
    heap.add(2);
    heap.add(9);
    assert_eq!(heap.next(), Some(2));
}
```

------

### 🧠 一句话

这段代码展示了如何使用 **Rust 泛型 + 函数指针 + Iterator trait**
 实现一个 **灵活、安全、通用的二叉堆结构**，支持最小堆与最大堆两种模式，并具备上浮、下沉、插入、弹出、迭代等核心功能。

## 🧠 总结

这段 Rust 代码以工程实践的角度，完美地实现了**通用二叉堆**这一核心数据结构。其核心设计思想在于：

1. **高度泛化 (Generics)**：使用 `Heap<T>` 泛型结构，并通过 `T: Default` 和 `T: Ord` 约束，确保代码的通用性和安全性。
2. **灵活控制 (Comparator)**：利用函数指针 `comparator: fn(&T, &T) -> bool`，将堆的**排序规则**（大顶堆或小顶堆）与核心逻辑分离，实现了**一套代码，两种功能**。
3. **遵循规范 (Iterator Trait)**：通过实现 `Iterator` Trait 的 `next()` 方法，将堆顶元素的提取操作（`pop`）转化为标准的**迭代行为**，极大地增强了代码的 Rust 风格和可用性。
4. **核心算法**：清晰地实现了 **上浮（Sift-Up）**（`add` 方法中）和 **下沉（Sift-Down）**（`next` 方法中）两大核心操作，确保了堆的 $\mathcal{O}(\log n)$ 时间复杂度特性。

总而言之，这个实现不仅是数据结构的学习范本，也是 Rust 语言高级特性（如 Trait、泛型、闭包与函数指针）的优秀实践案例。

## 参考

- <https://rust-lang.org/>
- <https://crates.io/>
- <https://rustcc.gitbooks.io/rustprimer/content/>
- <https://developer.mozilla.org/zh-CN/docs/WebAssembly/Guides/Rust_to_Wasm>
