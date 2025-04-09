+++
title = "Rust 如何优雅实现冒泡排序"
description = "Rust 如何优雅实现冒泡排序"
date = 2025-04-09 20:22:04+08:00
[taxonomies]
categories = ["Rust"，"算法"]
tags = ["Rust", "冒泡排序", "算法"]
+++

<!-- more -->

# Rust 如何优雅实现冒泡排序

冒泡排序作为一种经典的排序算法，以其直观的比较与交换逻辑，成为算法学习的重要起点。尽管它在性能上并非最优，但在理解排序思想和编程实践上仍有独特价值。本文将带你走进冒泡排序的核心原理，结合 Rust 语言的安全性与简洁性，探索如何以优雅的方式实现这一算法。从逐步拆解的过程到高效的代码实现，无论你是算法爱好者还是 Rust 编程的探索者，这篇文章都将为你呈现一场技术与美感的碰撞。

本文深入剖析了冒泡排序的工作机制，通过示例数组 [5, 3, 8, 4, 2] 清晰展示了相邻元素比较与交换的每一步操作。接着，我们提供了 Python 和 Rust 两种语言的实现，其中 Rust 版本利用 swapped 标志位优化循环，在数组已有序时提前退出，兼顾效率与逻辑清晰。代码还包含全面测试，验证了算法在多种场景下的可靠性。Rust 实现通过借用检查和 arr.swap() 等特性，展现了语言的安全性与优雅表达。本文适合希望理解冒泡排序本质或探索 Rust 编程之美的读者。

## 冒泡排序（Bubble Sort）算法详解

冒泡排序是一种简单的**基于比较的排序算法**，其核心思想是**通过相邻元素的反复比较和交换，将较大的元素逐步“浮”到数组的末尾**（像气泡上浮一样，因此得名）。以下是逐步解析：

### 算法步骤（黑板图示）

假设对数组 `[5, 3, 8, 4, 2]` 升序排序：

```plaintext
初始状态: [5, 3, 8, 4, 2]

第1轮:
  比较 5↔3 → 交换 → [3, 5, 8, 4, 2]
  比较 5↔8 → 不交换
  比较 8↔4 → 交换 → [3, 5, 4, 8, 2]
  比较 8↔2 → 交换 → [3, 5, 4, 2, 8] （最大值8已到末尾）

第2轮:
  比较 3↔5 → 不交换
  比较 5↔4 → 交换 → [3, 4, 5, 2, 8]
  比较 5↔2 → 交换 → [3, 4, 2, 5, 8] （次大值5就位）

第3轮:
  比较 3↔4 → 不交换
  比较 4↔2 → 交换 → [3, 2, 4, 5, 8] （4就位）

第4轮:
  比较 3↔2 → 交换 → [2, 3, 4, 5, 8] （完全有序）
```

## 实操冒泡排序

### Python 代码

```python
def bubble_sort(arr):
    n = len(arr)
    for i in range(n-1):            # 外层控制轮数
        swapped = False             # 优化：若本轮无交换，则已有序
        for j in range(n-1-i):      # 内层比较相邻元素
            if arr[j] > arr[j+1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]  # 交换
                swapped = True
        if not swapped:
            break
    return arr

# 测试
print(bubble_sort([5, 3, 8, 4, 2]))  # 输出: [2, 3, 4, 5, 8]
```

### Rust 代码

```rust
// 目标：对数组进行冒泡排序
fn bubble_sort(arr: &mut [i32]) {
    let len = arr.len();
    let mut swapped;  // 标记本轮是否有交换发生
    
    for i in 0..len {
        swapped = false;
        
        // 每次只需比较到 len - i - 1
      // len-i-1 中的 i 正好是已完成的轮数，也是已排序的元素数
      // -1 是因为比较的是 arr[j] 和 arr[j+1]，防止数组越界
        for j in 0..len - i - 1 {
            if arr[j] > arr[j + 1] {
                arr.swap(j, j + 1);
                swapped = true;  // 标记有交换发生
            }
        }
        
        // 如果本轮没有交换，说明数组已有序，可以提前终止
        if !swapped {
            break;
        }
    }
}

fn bubble_sort(arr: &mut [i32]) {
    let len = arr.len();
    let mut swapped;
    
    for i in 0..len {
        swapped = false;
        for j in 0..len - i - 1 {
            if arr[j] > arr[j + 1] {
                arr.swap(j, j + 1);
                swapped = true;
            }
        }
        if !swapped {
            break;
        }
    }
}

#[test]
fn test_bubble_sort() {
    // 普通测试用例
    let mut arr = [5, 3, 4, 1, 2];
    bubble_sort(&mut arr);
    assert_eq!(arr, [1, 2, 3, 4, 5]);

    // 已排序数组
    let mut arr2 = [1, 2, 3, 4, 5];
    bubble_sort(&mut arr2);
    assert_eq!(arr2, [1, 2, 3, 4, 5]);

    // 逆序数组
    let mut arr3 = [5, 4, 3, 2, 1];
    bubble_sort(&mut arr3);
    assert_eq!(arr3, [1, 2, 3, 4, 5]);

    // 空数组
    let mut arr4: [i32; 0] = [];
    bubble_sort(&mut arr4);
    assert_eq!(arr4, []);

    // 单元素数组
    let mut arr5 = [1];
    bubble_sort(&mut arr5);
    assert_eq!(arr5, [1]);
}

fn main() {
    let mut arr = [5, 3, 4, 1, 2];
    println!("Before sorting: {:?}", arr);
    bubble_sort(&mut arr);
    println!("After sorting: {:?}", arr);
}
```

这段 Rust 代码实现了一个冒泡排序算法，主要包含三个部分：排序函数实现、测试用例和主函数演示。冒泡排序的核心思想是通过反复比较相邻元素并交换它们的位置，使得较大的元素逐渐"浮"到数组末尾。该实现特别添加了 `swapped` 标志位进行优化：在外层循环的每一轮开始时将 `swapped` 设为 false，在内层循环中若发生元素交换则设为 true；当完成一轮比较后若 `swapped` 仍为 false，说明数组已完全有序，可提前终止排序，这使得算法在最佳情况（已排序数组）下的时间复杂度从 O(n²) 降为 O(n)。测试用例验证了算法对普通数组、已排序数组、逆序数组、空数组和单元素数组都能正确工作，而主函数则展示了实际使用时的输入输出效果。整个实现体现了 Rust 的安全特性（如借用检查确保内存安全）和简洁语法（如 `arr.swap()` 方法）。

## 总结

冒泡排序虽简单，却承载了算法设计的基础思想。通过本文的解析，我们不仅掌握了其通过相邻交换实现有序化的过程，还见证了 Rust 如何以优雅的方式赋予这一经典算法新的生命。Rust 实现的优化设计与安全特性，让代码既高效又可靠，充分体现了现代编程语言的魅力。对于算法学习者，这是一次扎实的实践；对于 Rust 爱好者，这是一场优雅实现的启发。未来，不妨尝试用 Rust 挑战更复杂的排序算法，探索技术之美的更多可能。

## 参考

- <https://course.rs/about-book.html>
- <https://rustwiki.org/zh-CN/>
- <https://rustwiki.org/zh-CN/cargo/commands/cargo-run.html>
- <https://rust-chinese-translation.github.io/api-guidelines/>
- <https://rusty.course.rs/algos/awesome.html>
