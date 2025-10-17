+++
title = "Rust 实战：使用自定义泛型栈实现高效、严谨的括号匹配算法"
description = "Rust 实战：使用自定义泛型栈实现高效、严谨的括号匹配算法"
date = 2025-10-17T12:02:57Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# **Rust 实战：使用自定义泛型栈实现高效、严谨的括号匹配算法**

在计算机科学中，验证代码或数学表达式中的括号是否正确配对是一项基础而重要的任务。这种“结构平衡”问题最完美的解决方案就是使用 **栈 (Stack)** 这一数据结构。本实践教程将深入展示如何使用 Rust 语言，从零开始构建一个安全、高效的泛型栈，并利用它来实现一个严谨的括号匹配算法，以确保 `()`、`[]` 和 `{}` 能够正确地嵌套和闭合。

本文通过 Rust 泛型实现了完整的 **栈（Stack）** 数据结构，并利用其 **后进先出（LIFO）** 特性，设计了经典的**括号匹配**算法。代码详尽展示了栈的核心操作（`push`、`pop`、`peek`）和迭代器实现。通过单元测试，证明了算法能高效准确地校验表达式中的 `()`、`[]`、`{}` 嵌套平衡性。

## 实操

### 📋 Rust 代码及实现解析

用栈实现经典的 **括号匹配** 算法

以下是完整的 Rust 代码，包括泛型栈的实现、括号匹配函数和单元测试。

```rust
/*
    stack
    use a stack to achieve a bracket match
*/

#[derive(Debug)]
struct Stack<T> {
    size: usize,
    data: Vec<T>,
}
impl<T> Stack<T> {
    fn new() -> Self {
        Self {
            size: 0,
            data: Vec::new(),
        }
    }
    fn is_empty(&self) -> bool {
        0 == self.size
    }
    fn len(&self) -> usize {
        self.size
    }
    fn clear(&mut self) {
        self.size = 0;
        self.data.clear();
    }
    fn push(&mut self, val: T) {
        self.data.push(val);
        self.size += 1;
    }
    fn pop(&mut self) -> Option<T> {
        if self.size > 0 {
            self.size -= 1;
            // Vec's pop handles the actual retrieval and removal
            self.data.pop()
        } else {
            None
        }
    }
    fn peek(&self) -> Option<&T> {
        if 0 == self.size {
            return None;
        }
        self.data.get(self.size - 1)
    }
    fn peek_mut(&mut self) -> Option<&mut T> {
        if 0 == self.size {
            return None;
        }
        self.data.get_mut(self.size - 1)
    }
    fn into_iter(self) -> IntoIter<T> {
        IntoIter(self)
    }
    fn iter(&self) -> Iter<T> {
        let mut iterator = Iter { stack: Vec::new() };
        for item in self.data.iter() {
            iterator.stack.push(item);
        }
        iterator
    }
    fn iter_mut(&mut self) -> IterMut<T> {
        let mut iterator = IterMut { stack: Vec::new() };
        for item in self.data.iter_mut() {
            iterator.stack.push(item);
        }
        iterator
    }
}
struct IntoIter<T>(Stack<T>);
impl<T: Clone> Iterator for IntoIter<T> {
    type Item = T;
    fn next(&mut self) -> Option<Self::Item> {
        if !self.0.is_empty() {
            self.0.size -= 1;
            self.0.data.pop()
        } else {
            None
        }
    }
}
struct Iter<'a, T: 'a> {
    stack: Vec<&'a T>,
}
impl<'a, T> Iterator for Iter<'a, T> {
    type Item = &'a T;
    fn next(&mut self) -> Option<Self::Item> {
        self.stack.pop()
    }
}
struct IterMut<'a, T: 'a> {
    stack: Vec<&'a mut T>,
}
impl<'a, T> Iterator for IterMut<'a, T> {
    type Item = &'a mut T;
    fn next(&mut self) -> Option<Self::Item> {
        self.stack.pop()
    }
}

fn bracket_match(bracket: &str) -> bool {
    // The stack will store the EXPECTED closing bracket for every opening bracket encountered.
    let mut stack = Stack::new();

    for c in bracket.chars() {
        match c {
            // Found opening bracket: push its expected closing counterpart onto the stack
            '(' => stack.push(')'),
            '[' => stack.push(']'),
            '{' => stack.push('}'),

            // Found closing bracket: check for a match
            ')' | ']' | '}' => {
                // Pop the expected closing bracket from the stack
                // If stack is empty (pop returns None) OR the popped character doesn't match the current one,
                // the brackets are unbalanced.
                if stack.pop() != Some(c) {
                    return false;
                }
            }
            // Ignore other characters like numbers, operators, or letters
            _ => continue,
        }
    }

    // After processing the whole string, the stack must be empty for the brackets to be fully matched.
    stack.is_empty()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn bracket_matching_1() {
        let s = "(2+3){func}[abc]";
        assert_eq!(bracket_match(s), true);
    }
    #[test]
    fn bracket_matching_2() {
        let s = "(2+3)*(3-1";
        assert_eq!(bracket_match(s), false);
    }
    #[test]
    fn bracket_matching_3() {
        let s = "{{([])}}";
        assert_eq!(bracket_match(s), true);
    }
    #[test]
    fn bracket_matching_4() {
        let s = "{{(}[)]}";
        assert_eq!(bracket_match(s), false);
    }
    #[test]
    fn bracket_matching_5() {
        let s = "[[[]]]]]]]]]";
        assert_eq!(bracket_match(s), false);
    }
    #[test]
    fn bracket_matching_6() {
        let s = "";
        assert_eq!(bracket_match(s), true);
    }
}

```

## 💡 核心逻辑解释

### 栈 (`Stack<T>`) 的实现

代码定义了一个泛型结构体 `Stack<T>`，它使用 `Vec<T>` 作为底层存储，并提供了栈的全部核心功能：**`push` (入栈)**、**`pop` (出栈)**（返回 `Option<T>` 处理空栈）、**`peek` (查看栈顶)**。它还通过实现 `IntoIter`、`Iter` 和 `IterMut` 结构体，提供了对栈元素的**三种迭代器**支持，确保了栈作为数据结构的完整性和灵活性。

### 括号匹配逻辑 (`bracket_match`)

`bracket_match` 函数利用这个栈来验证输入字符串中的圆括号 `()`、方括号 `[]` 和花括号 `{}` 是否正确嵌套和平衡。

1. **开括号处理**: 遍历字符串时，如果遇到 **开括号**（`(`、`[`、`{`），函数会将它**期望**对应的 **闭括号**（`)`、`]`、`}`）`push` 到栈中。
2. **闭括号处理**: 如果遇到 **闭括号**，函数会从栈中 **`pop`** 出一个元素。
   - **匹配判断**: 只有当弹出的元素 **存在** (`Some`) 且 **精确等于** 当前的闭括号时，才算匹配成功，继续处理下一个字符。
   - **失败条件**: 如果栈为空 (`pop` 返回 `None`，意味着多余的闭括号）或弹出的字符不匹配当前的闭括号（例如，期望 `)` 却遇到了 `]`），则立即返回 `false`。
3. **最终结果**: 遍历完成后，只有当栈**完全为空** (`stack.is_empty()`) 时，才说明所有开括号都被正确闭合，返回 `true`。

### 单元测试 (`#[cfg(test)]`) 🧪

代码底部提供了一组全面的单元测试来验证 `bracket_match` 函数的健壮性：

- **`_1` 和 `_3`**: 验证**正确匹配**和**嵌套**的复杂情况。
- **`_2`**: 验证**缺少闭括号**（导致栈非空）的情况，应返回 `false`。
- **`_4`**: 验证**括号类型错位**或**交叉**（`pop` 结果不匹配）的情况，应返回 `false`。
- **`_5`**: 验证**多余闭括号**（导致对空栈执行 `pop`）的情况，应返回 `false`。
- **`_6`**: 验证**空字符串**，应返回 `true`。

通过这些实现和测试，该代码展示了如何在 Rust 中构建一个 LIFO 栈并将其应用于实际的算法问题（如语法解析中的括号验证）。

## 总结

本实践项目不仅成功地在 Rust 中构建了一个功能完整的 **泛型栈**，提供了包括三种迭代器在内的丰富 API，更重要的是，我们利用栈的 LIFO 特性，高效地解决了**括号匹配**这一经典算法问题。通过将开括号对应的闭括号推入栈中，并确保闭括号出现时能正确弹出栈顶元素，我们实现了一个鲁棒（Robust）的验证逻辑。文章附带的全面单元测试进一步证明了该实现的稳定性和准确性，为在 Rust 中进行结构化数据验证提供了可靠的基础。

## 参考

- **Rust 程序设计语言：** <https://kaisery.github.io/trpl-zh-cn/>

- **通过例子学 Rust：** <https://rustwiki.org/zh-CN/rust-by-example/>

- **Rust 语言圣经：** <https://course.rs/about-book.html>

- **Rust 秘典：** <https://nomicon.purewhite.io/intro.html>

- **Rust 算法教程：** <https://algo.course.rs/about-book.html>

- **Rust 参考手册：** <https://rustwiki.org/zh-CN/reference/introduction.html>
