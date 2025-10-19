+++
title = "Rust 实战：用两个队列实现栈——重温经典数据结构面试题"
description = "Rust 实战：用两个队列实现栈——重温经典数据结构面试题"
date = 2025-10-18T13:26:58Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# **Rust 实战：用两个队列实现栈——重温经典数据结构面试题**

在计算机科学和软件开发中，栈（Stack）和队列（Queue）是两种最基础也最重要的抽象数据类型。它们遵循着截然不同的存取原则：队列是“先进先出”（FIFO），而栈是“后进先出”（LIFO）。一个经典的面试挑战就是：**如何使用队列来模拟栈的行为？**

本文将通过 Rust 语言，从零开始实现一个基本的泛型队列结构体，并利用两个这样的队列，优雅地解决了“用队列实现栈”这一问题。通过详细的代码和原理分析，带您深入理解数据结构转换的精髓。

本文展示了如何用 Rust 的泛型队列（`Queue`）结构体，通过两个队列（`q1` 和 `q2`）巧妙地实现一个 LIFO（后进先出）的栈（`myStack`）。核心思路在于 `push` 操作：新元素先入队到辅助队列 `q2`，随后将主队列 `q1` 中的所有元素转移到 `q2` 尾部，最后交换 `q1` 和 `q2`，确保新元素始终位于主队列的队首，从而实现 $O(1)$ 的 `pop` 操作。

## 实操

### 用队列实现栈

```rust
/*
    queue
    use queues to implement the functionality of the stac
*/

#[derive(Debug)]
pub struct Queue<T> {
    elements: Vec<T>,
}

impl<T> Queue<T> {
    pub fn new() -> Queue<T> {
        Queue {
            elements: Vec::new(),
        }
    }

    pub fn enqueue(&mut self, value: T) {
        self.elements.push(value)
    }

    pub fn dequeue(&mut self) -> Result<T, &str> {
        if !self.elements.is_empty() {
            Ok(self.elements.remove(0usize))
        } else {
            Err("Stack is empty")
        }
    }

    pub fn peek(&self) -> Result<&T, &str> {
        match self.elements.first() {
            Some(value) => Ok(value),
            None => Err("Stack is empty"),
        }
    }

    pub fn size(&self) -> usize {
        self.elements.len()
    }

    pub fn is_empty(&self) -> bool {
        self.elements.is_empty()
    }
}

impl<T> Default for Queue<T> {
    fn default() -> Queue<T> {
        Queue {
            elements: Vec::new(),
        }
    }
}

pub struct myStack<T> {
    q1: Queue<T>,
    q2: Queue<T>,
}
impl<T> myStack<T> {
    pub fn new() -> Self {
        Self {
            q1: Queue::<T>::new(),
            q2: Queue::<T>::new(),
        }
    }
    pub fn push(&mut self, elem: T) {
        // 1. 将新元素推入辅助队列 q2 (新元素成为 q2 的队尾)
        self.q2.enqueue(elem);

        // 2. 将 q1 (旧数据) 中的所有元素移动到 q2 的队尾
        // q1: [1, 2], Push 3. q2: [3]. q1 -> q2: q2: [3, 1, 2]
        while let Ok(val) = self.q1.dequeue() {
            self.q2.enqueue(val);
        }

        // 3. 交换 q1 和 q2 的角色。现在 q1 包含所有元素，且新元素在队首
        // Q1: [3, 1, 2], Q2: []
        std::mem::swap(&mut self.q1, &mut self.q2);
    }
    pub fn pop(&mut self) -> Result<T, &str> {
        self.q1.dequeue()
    }
    pub fn is_empty(&self) -> bool {
        self.q1.is_empty()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_queue() {
        let mut s = myStack::<i32>::new();
        assert_eq!(s.pop(), Err("Stack is empty"));
        s.push(1);
        s.push(2);
        s.push(3);
        assert_eq!(s.pop(), Ok(3));
        assert_eq!(s.pop(), Ok(2));
        s.push(4);
        s.push(5);
        assert_eq!(s.is_empty(), false);
        assert_eq!(s.pop(), Ok(5));
        assert_eq!(s.pop(), Ok(4));
        assert_eq!(s.pop(), Ok(1));
        assert_eq!(s.pop(), Err("Stack is empty"));
        assert_eq!(s.is_empty(), true);
    }
}

```

这段 Rust 代码实现了一个**队列（`Queue`）** 结构，并利用 **两个队列** 实现了一个**栈（`myStack`）**的功能，这是一种经典的“用队列实现栈”的数据结构面试题解法。

### 1. 队列 (`Queue<T>`) 的实现

- **结构体定义**: `Queue<T>` 使用一个泛型向量 `elements: Vec<T>` 作为底层存储，并标记为 `#[derive(Debug)]` 以便打印调试信息。
- **方法**:
  - `new()` / `default()`: 创建一个新的空队列。
  - `enqueue(&mut self, value: T)`: **入队**操作，将元素添加到向量的**尾部** (`self.elements.push(value)`)，这是 O(1) 的操作。
  - `dequeue(&mut self) -> Result<T, &str>`: **出队**操作，移除并返回向量**头部**的元素 (`self.elements.remove(0usize)`)。由于 `Vec::remove(0)` 需要将后续所有元素前移，因此这是一个 O(n)的操作（效率较低，实际生产环境的队列通常会使用更高效的双端队列或链表实现）。它返回一个 `Result`，如果队列为空则返回错误。
  - `peek(&self) -> Result<&T, &str>`: 查看队首元素，但不移除。
  - `size()` / `is_empty()`: 返回队列大小和判断是否为空。

### 2. 栈 (`myStack<T>`) 的实现（基于两个队列）

- **结构体定义**: `myStack<T>` 包含两个队列 `q1: Queue<T>` 和 `q2: Queue<T>`。`q1` 主要用来存储栈中的数据，而 `q2` 作为辅助队列进行数据转移。

- **栈的操作（LIFO - 后进先出）**:

  - `new()`: 创建一个新的空栈，初始化两个空队列。

  - `pop(&mut self) -> Result<T, &str>`: **出栈**操作。由于我们通过 `push` 操作确保了**栈顶元素始终在 `q1` 的队首**，所以直接对 `q1` 执行**出队**操作 (`self.q1.dequeue()`) 即可实现栈的 `pop`，这是 O(1)的操作。

  - `push(&mut self, elem: T)`: **入栈**操作是该实现的关键，它确保新元素成为新的栈顶（即 `q1` 的队首）。

    1. **新元素入辅助队列**: 将新元素 `elem` **入队**到辅助队列 `q2` (`self.q2.enqueue(elem)`)。此时 `q2` 为 `[新元素]`。

    2. **转移旧数据**: 将 `q1` (旧数据) 中的所有元素依次**出队**并**入队**到 `q2` 的尾部。例如，如果 `q1` 是 `[1, 2]`，`q2` 变成 `[3, 1, 2]`。这样，新元素 `3` 就排在了所有旧数据的前面。

    3. 交换角色: 使用 std::mem::swap 交换 q1 和 q2 的内容。现在，q1 包含所有元素，且新元素 (3) 位于 q1 的队首。q2 变为空。

       整个 push 操作的时间复杂度取决于 q1 中的元素数量，为 O(n)。

  - `is_empty()`: 检查 `q1` 是否为空。

### 3. 测试模块 (`#[cfg(test)] mod tests`)

测试用例 `test_queue()` 验证了 `myStack` 的功能是否符合栈的行为：

1. **初始状态**: 检查空栈 `pop` 会返回错误。
2. **Push 操作**: 依次推入 `1, 2, 3`。根据 `push` 逻辑，`q1` 最终应为 `[3, 2, 1]`（队首为 3）。
3. **Pop 操作**: 验证 `pop` 依次返回 `3` 和 `2`（**后进先出**）。
4. **混合操作**: 再次推入 `4, 5`。此时 `q1` 变成 `[5, 4, 1]`。
5. **最终 Pop**: 验证依次弹出 `5, 4, 1`，直到栈为空。
6. **最终状态**: 确认 `pop` 返回错误，且 `is_empty()` 为 `true`。

**总结**: 这段代码成功地使用两个遵循 FIFO（先进先出）原则的队列结构，实现了一个遵循 LIFO（后进先出）原则的栈结构。虽然 `Queue` 的 `dequeue` 操作以及 `myStack` 的 `push` 操作效率较低O(n)），但它清晰地展示了这种数据结构转换的逻辑。

## 总结

通过本文的 Rust 实战，我们成功地利用两个遵循 FIFO 规则的队列 `q1` 和 `q2`，构建了一个符合 LIFO 规则的栈 `myStack`。

实现的关键在于**维护栈顶元素始终位于主队列 (`q1`) 的队首**。这使得 `pop` 操作可以保持高效的 $O(1)$ 时间复杂度。然而，为了实现这一目标，`push` 操作需要将 $N$ 个旧元素转移到新元素之后，导致 `push` 操作的效率为 $O(N)$。

这种实现虽然在效率上有所牺牲（如果使用 `Vec` 直接实现栈，`push` 和 `pop` 都是 $O(1)$），但它清晰地展示了数据结构抽象和转换的强大能力，是理解和掌握数据结构原理的绝佳案例。

## 参考

- Rust 程序设计语言： <https://kaisery.github.io/trpl-zh-cn/>

- 通过例子学 Rust： <https://rustwiki.org/zh-CN/rust-by-example/>

- Rust 语言圣经： <https://course.rs/about-book.html>

- Rust 秘典： <https://nomicon.purewhite.io/intro.html>

- Rust 算法教程： <https://algo.course.rs/about-book.html>

- Rust 参考手册： <https://rustwiki.org/zh-CN/reference/introduction.html>
