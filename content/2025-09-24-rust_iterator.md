+++
title = "深度解析 Rust 迭代器：原理、链式调用与实战应用"
description = "深度解析 Rust 迭代器：原理、链式调用与实战应用"
date = 2025-09-24T02:49:17Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 深度解析 Rust 迭代器：原理、链式调用与实战应用

在 Rust 的世界里，迭代器（Iterator）不仅仅是一种遍历数据的方式，更是一种强大的编程范式，它提供了高效、安全且富有表现力的工具来处理集合数据。理解迭代器的底层原理和高级用法，是掌握 Rust 强大能力的必经之路。本文将带你深入探索 Rust 迭代器，从它的基本机制，到如何使用链式方法实现复杂的数据处理，再到它在实际应用中的各种妙用，助你写出更高效、更优雅的 Rust 代码。

本文深度解析 Rust 迭代器，从 `.next()` 方法理解其惰性原理。通过实战示例，展示如何用 `.map()`、`.collect()` 等链式方法高效转换和聚合数据，并结合 `Result` 实现灵活的错误处理。文章还探讨了 `.flat_map()`、`.product()` 等高级用法，旨在帮助开发者从基础遍历进阶到用函数式风格处理复杂任务。

## 原理篇：`.next()` 与惰性求值

### 示例一

```rust
// iterators1.rs
//
// When performing operations on elements within a collection, iterators are
// essential. This module helps you get familiar with the structure of using an
// iterator and how to go through elements within an iterable collection.

fn main() {
    let my_fav_fruits = vec!["banana", "custard apple", "avocado", "peach", "raspberry"];

    let mut my_iterable_fav_fruits = my_fav_fruits.iter();

    assert_eq!(my_iterable_fav_fruits.next(), Some(&"banana"));
    assert_eq!(my_iterable_fav_fruits.next(), Some(&"custard apple"));
    assert_eq!(my_iterable_fav_fruits.next(), Some(&"avocado"));
    assert_eq!(my_iterable_fav_fruits.next(), Some(&"peach"));
    assert_eq!(my_iterable_fav_fruits.next(), Some(&"raspberry"));
    assert_eq!(my_iterable_fav_fruits.next(), None);
}

```

这段 Rust 代码通过一个简单的水果集合，生动地展示了**迭代器（Iterator）**的核心概念。代码首先创建了一个包含水果名称的向量 `my_fav_fruits`，然后调用 `.iter()` 方法，将这个向量变成了一个**迭代器 `my_iterable_fav_fruits`**。迭代器允许我们以惰性（lazy）的方式逐个访问集合中的元素，而无需一次性将所有元素加载到内存中。通过反复调用 `.next()` 方法，我们可以从迭代器中依次取出下一个元素，直到所有元素都被访问完毕。当迭代器中没有更多元素时，`.next()` 方法会返回 `None`，这标志着迭代过程的结束。这段代码的核心在于，它用最直观的方式展示了迭代器是如何通过 **`.next()`** 方法，来实现对集合的顺序遍历和消费。

## 链式调用篇：`.map()` 与 `.collect()`

### 示例二

```rust
// iterators2.rs

// "hello" -> "Hello"
pub fn capitalize_first(input: &str) -> String {
    let mut c = input.chars();
    match c.next() {
        None => String::new(),
        // 方式一
        // Some(first) => {
        //     let mut result = first.to_uppercase().collect::<String>();
        //     result.push_str(&input[1..]);
        //     result
        // }

        // 方式二
        // Some(first) => format!("{}{}", first.to_uppercase(), &input[1..]),

        // 方式三
        // Some(first) => first.to_uppercase().collect::<String>() + &input[1..],

        // 方式四
        Some(first) => first.to_uppercase().collect::<String>() + c.as_str(),
    }
}

// Apply the `capitalize_first` function to a slice of string slices.
// Return a vector of strings.
// ["hello", "world"] -> ["Hello", "World"]
pub fn capitalize_words_vector(words: &[&str]) -> Vec<String> {
    words.iter().map(|word| capitalize_first(word)).collect()
}


// Apply the `capitalize_first` function again to a slice of string slices.
// Return a single string.
// ["hello", " ", "world"] -> "Hello World"
pub fn capitalize_words_string(words: &[&str]) -> String {
    words.iter().map(|word| capitalize_first(word)).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_success() {
        assert_eq!(capitalize_first("hello"), "Hello");
    }

    #[test]
    fn test_empty() {
        assert_eq!(capitalize_first(""), "");
    }

    #[test]
    fn test_iterate_string_vec() {
        let words = vec!["hello", "world"];
        assert_eq!(capitalize_words_vector(&words), ["Hello", "World"]);
    }

    #[test]
    fn test_iterate_into_string() {
        let words = vec!["hello", " ", "world"];
        assert_eq!(capitalize_words_string(&words), "Hello World");
    }
}

```

这段 Rust 代码的核心在于如何利用**迭代器（Iterator）**链式方法高效地处理字符串集合。`capitalize_first` 函数通过 `.chars().next()` 获取字符串的第一个字符，并将其转为大写，然后与字符串的其余部分拼接，实现了首字母大写的功能。

而在 `capitalize_words_vector` 和 `capitalize_words_string` 函数中，我们看到了迭代器链的强大：

1. **`.iter()`** 将输入的字符串切片转换为迭代器。
2. **`.map(|word| capitalize_first(word))`** 对迭代器中的每一个元素应用 `capitalize_first` 函数，返回一个新的迭代器，其中包含了所有处理后的字符串。
3. **`.collect()`** 则扮演了关键角色，它将这个新的迭代器中产生的结果，收集到不同的数据类型中：在 `capitalize_words_vector` 中，它收集成了一个 `Vec<String>`；而在 `capitalize_words_string` 中，它将所有字符串拼接成了一个**单个的 `String`**。

这段代码完美展示了 Rust 迭代器如何通过 `.map()` 和 `.collect()` 这样的高阶函数，以一种声明式、函数式的方式完成复杂的数据转换和聚合，写出简洁且高效的代码。

## 高级应用篇：错误处理与聚合

### 示例三

```rust
// iterators3.rs

#[derive(Debug, PartialEq, Eq)]
pub enum DivisionError {
    NotDivisible(NotDivisibleError),
    DivideByZero,
}

#[derive(Debug, PartialEq, Eq)]
pub struct NotDivisibleError {
    dividend: i32,
    divisor: i32,
}

// Calculate `a` divided by `b` if `a` is evenly divisible by `b`.
// Otherwise, return a suitable error.
pub fn divide(a: i32, b: i32) -> Result<i32, DivisionError> {
    // 方式一
    // if b == 0 {
    //     return Err(DivisionError::DivideByZero);
    // }
    // if a % b != 0 {
    //     return Err(DivisionError::NotDivisible(NotDivisibleError {
    //         dividend: a,
    //         divisor: b,
    //     }));
    // }
    // Ok(a / b)

    // 方式二
    // if b == 0 {
    //     Err(DivisionError::DivideByZero)
    // } else if a % b != 0 {
    //     Err(DivisionError::NotDivisible(NotDivisibleError {
    //         dividend: a,
    //         divisor: b,
    //     }))
    // } else {
    //     Ok(a / b)
    // }

    // 方式三
    match b {
        0 => Err(DivisionError::DivideByZero),
        _ => {
            if a % b != 0 {
                Err(DivisionError::NotDivisible(NotDivisibleError {
                    dividend: a,
                    divisor: b,
                }))
            } else {
                Ok(a / b)
            }
        }
    }
}

// Complete the function and return a value of the correct type so the test
// passes.
// Desired output: Ok([1, 11, 1426, 3])
fn result_with_list() -> Result<Vec<i32>, DivisionError> {
    let numbers = vec![27, 297, 38502, 81];
    let division_results = numbers.into_iter().map(|n| divide(n, 27));
    division_results.collect()
}

// Complete the function and return a value of the correct type so the test
// passes.
// Desired output: [Ok(1), Ok(11), Ok(1426), Ok(3)]
fn list_of_results() -> Vec<Result<i32, DivisionError>> {
    let numbers = vec![27, 297, 38502, 81];
    let division_results = numbers.into_iter().map(|n| divide(n, 27)).collect();
    division_results
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_success() {
        assert_eq!(divide(81, 9), Ok(9));
    }

    #[test]
    fn test_not_divisible() {
        assert_eq!(
            divide(81, 6),
            Err(DivisionError::NotDivisible(NotDivisibleError {
                dividend: 81,
                divisor: 6
            }))
        );
    }

    #[test]
    fn test_divide_by_0() {
        assert_eq!(divide(81, 0), Err(DivisionError::DivideByZero));
    }

    #[test]
    fn test_divide_0_by_something() {
        assert_eq!(divide(0, 81), Ok(0));
    }

    #[test]
    fn test_result_with_list() {
        assert_eq!(format!("{:?}", result_with_list()), "Ok([1, 11, 1426, 3])");
    }

    #[test]
    fn test_list_of_results() {
        assert_eq!(
            format!("{:?}", list_of_results()),
            "[Ok(1), Ok(11), Ok(1426), Ok(3)]"
        );
    }
}

```

这段 Rust 代码通过一个除法函数 `divide`，展示了如何用**`Result` 枚举**来优雅地处理潜在的错误，并利用**迭代器的 `.collect()` 方法**灵活地聚合处理结果。`divide` 函数返回 `Result<i32, DivisionError>`，它要么是一个成功的 `Ok(i32)`，要么是一个包含错误信息的 `Err(DivisionError)`。

在 `result_with_list` 函数中，`numbers` 上的迭代器被 `map` 转换后，`.collect()` 方法会尝试将所有 `Result` 类型的结果聚合为一个单一的 `Result<Vec<i32>, DivisionError>`。这种方式是“快速失败”的，一旦遇到任何一个 `Err`，整个集合就会立即返回这个错误。

而在 `list_of_results` 函数中，`.collect()` 则直接将每个 `Result` 结果收集到一个 `Vec<Result<i32, DivisionError>>` 中，这意味着即使某个元素处理失败，它也只会以 `Err` 形式存在于向量中，而不会中断整个处理流程。

这段代码的核心在于，它展示了 Rust 如何通过 `Result` 和迭代器的 `.collect()` 组合，以**声明式**的方式实现强大的错误处理和数据聚合，提供两种不同的错误处理策略：**快速失败**和**收集所有结果**。

### 示例四

```rust
// iterators4.rs

pub fn factorial(num: u64) -> u64 {
    // 方式一
    (1..=num).product()

    // 方式二
    // (1..=num).fold(1, |acc, x| acc * x)

    // 方式三
    // if num == 0 {
    //     1
    // } else {
    //     (1..=num).fold(1, |acc, x| acc * x)
    // }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn factorial_of_0() {
        assert_eq!(1, factorial(0));
    }

    #[test]
    fn factorial_of_1() {
        assert_eq!(1, factorial(1));
    }
    #[test]
    fn factorial_of_2() {
        assert_eq!(2, factorial(2));
    }

    #[test]
    fn factorial_of_4() {
        assert_eq!(24, factorial(4));
    }
}

```

这段 Rust 代码展示了如何用**迭代器（Iterator）**以优雅且富有表现力的方式计算阶乘。`factorial` 函数通过一个**范围（`1..=num`）**来创建一个迭代器，它包含了从 1 到 `num` 的所有数字。然后，它利用迭代器适配器来对这些数字进行聚合计算。

其中：

- **方式一** 使用了 `.product()` 方法。这是迭代器专门为求乘积而设计的一个便捷方法，它将迭代器中的所有元素相乘并返回最终结果。
- **方式二**和**方式三**使用了 `.fold()` 方法。`.fold()` 是一个更通用的聚合函数，它接受一个初始值（这里是 `1`）和一个闭包（`|acc, x| acc * x`），闭包在每次迭代中更新累加器 `acc`。这种方法展示了迭代器强大的灵活性，可以用于执行任何类型的聚合操作，不仅仅是乘法。

这段代码的核心在于，它用简洁明了的方式，突显了 Rust 迭代器在处理数学计算和数据聚合方面的强大功能。

### 示例五

```rust
// iterators5.rs

use std::collections::HashMap;

#[derive(Clone, Copy, PartialEq, Eq)]
enum Progress {
    None,
    Some,
    Complete,
}

fn count_for(map: &HashMap<String, Progress>, value: Progress) -> usize {
    let mut count = 0;
    for val in map.values() {
        if val == &value {
            count += 1;
        }
    }
    count
}

fn count_iterator(map: &HashMap<String, Progress>, value: Progress) -> usize {
    // map is a hashmap with String keys and Progress values.
    // map = { "variables1": Complete, "from_str": None, ... }
    // return the number of values in the map that are equal to value.
    // 方式一
    // map.values().filter(|&&val| val == value).count()

    // 方式二
    map.values().filter(|&v| v == &value).count()
}

fn count_collection_for(collection: &[HashMap<String, Progress>], value: Progress) -> usize {
    let mut count = 0;
    for map in collection {
        for val in map.values() {
            if val == &value {
                count += 1;
            }
        }
    }
    count
}

fn count_collection_iterator(collection: &[HashMap<String, Progress>], value: Progress) -> usize {
    // collection is a slice of hashmaps.
    // collection = [{ "variables1": Complete, "from_str": None, ... },
    //     { "variables2": Complete, ... }, ... ]
    // return the number of values in the collection that are equal to value.
    // 方式一
    // collection
    //     .iter()
    //     .map(|map| map.values())
    //     .flatten()
    //     .filter(|&&progress| progress == value)
    //     .count()

    // 方式二
    // collection
    //     .iter()
    //     .map(|map| map.values().filter(|&&progress| progress == value).count())
    //     .sum::<usize>()

    // 方式三
    collection
        .iter()
        .flat_map(|map| map.values())
        .filter(|&v| v == &value)
        .count()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn count_complete() {
        let map = get_map();
        assert_eq!(3, count_iterator(&map, Progress::Complete));
    }

    #[test]
    fn count_some() {
        let map = get_map();
        assert_eq!(1, count_iterator(&map, Progress::Some));
    }

    #[test]
    fn count_none() {
        let map = get_map();
        assert_eq!(2, count_iterator(&map, Progress::None));
    }

    #[test]
    fn count_complete_equals_for() {
        let map = get_map();
        let progress_states = vec![Progress::Complete, Progress::Some, Progress::None];
        for progress_state in progress_states {
            assert_eq!(
                count_for(&map, progress_state),
                count_iterator(&map, progress_state)
            );
        }
    }

    #[test]
    fn count_collection_complete() {
        let collection = get_vec_map();
        assert_eq!(
            6,
            count_collection_iterator(&collection, Progress::Complete)
        );
    }

    #[test]
    fn count_collection_some() {
        let collection = get_vec_map();
        assert_eq!(1, count_collection_iterator(&collection, Progress::Some));
    }

    #[test]
    fn count_collection_none() {
        let collection = get_vec_map();
        assert_eq!(4, count_collection_iterator(&collection, Progress::None));
    }

    #[test]
    fn count_collection_equals_for() {
        let progress_states = vec![Progress::Complete, Progress::Some, Progress::None];
        let collection = get_vec_map();

        for progress_state in progress_states {
            assert_eq!(
                count_collection_for(&collection, progress_state),
                count_collection_iterator(&collection, progress_state)
            );
        }
    }

    fn get_map() -> HashMap<String, Progress> {
        use Progress::*;

        let mut map = HashMap::new();
        map.insert(String::from("variables1"), Complete);
        map.insert(String::from("functions1"), Complete);
        map.insert(String::from("hashmap1"), Complete);
        map.insert(String::from("arc1"), Some);
        map.insert(String::from("as_ref_mut"), None);
        map.insert(String::from("from_str"), None);

        map
    }

    fn get_vec_map() -> Vec<HashMap<String, Progress>> {
        use Progress::*;

        let map = get_map();

        let mut other = HashMap::new();
        other.insert(String::from("variables2"), Complete);
        other.insert(String::from("functions2"), Complete);
        other.insert(String::from("if1"), Complete);
        other.insert(String::from("from_into"), None);
        other.insert(String::from("try_from_into"), None);

        vec![map, other]
    }
}

```

这段 Rust 代码展示了如何用**迭代器链式方法**来替代传统的 `for` 循环，实现更简洁、高效的数据计数。代码中定义了两个函数：`count_iterator` 和 `count_collection_iterator`。`count_iterator` 函数通过调用 `map.values()` 将 HashMap 的值转换为迭代器，然后使用 `.filter()` 方法筛选出与指定 `value` 相等的元素，最后用 `.count()` 得到符合条件的元素总数。而 `count_collection_iterator` 则展示了处理复杂集合（如 `HashMap` 的向量）的能力，它首先使用 `.flat_map()` (或 `.map().flatten()`) 来将所有 `HashMap` 中的迭代器“展平”成一个单一的迭代器，接着同样使用 `.filter()` 和 `.count()` 完成计数。这两种方式都与传统的 `for` 循环实现功能完全相同，但代码更具表现力和函数式风格，体现了 Rust 迭代器在数据处理上的强大之处。

## 总结

通过本文的深度解析，我们全面理解了 Rust 迭代器的核心价值。它不仅能替代传统的循环，更重要的是，它提供了一套完整的函数式编程工具链，让数据处理逻辑变得清晰、简洁。掌握 `.next()` 的原理，灵活运用 `.map()`、`.filter()`、`.collect()` 等方法，能够让你以一种声明式的方式解决复杂问题，极大地提升开发效率和代码质量。这正是 Rust 迭代器在保证性能的同时，所带来的独特魅力。

## 参考

- **Rust 程序设计语言：** <https://kaisery.github.io/trpl-zh-cn/>

- **通过例子学 Rust：** <https://rustwiki.org/zh-CN/rust-by-example/>

- **Rust 语言圣经：** <https://course.rs/about-book.html>

- **Rust 秘典：** <https://nomicon.purewhite.io/intro.html>

- **Rust 算法教程：** <https://algo.course.rs/about-book.html>

- **Rust 参考手册：** <https://rustwiki.org/zh-CN/reference/introduction.html>
