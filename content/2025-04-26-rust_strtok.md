+++
title = "Rust实战：打造高效字符串分割函数"
description = "Rust实战：打造高效字符串分割函数"
date = 2025-04-26T12:24:19Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust实战：打造高效字符串分割函数

字符串分割是编程中的常见需求，从文本解析到数据处理无处不在。Rust 凭借其高性能和内存安全特性，成为实现高效字符串操作的理想选择。本文将带你走进 Rust 实战，深入剖析如何打造一个基于指定分隔符的字符串分割函数 strtok。通过清晰的代码示例和测试验证，你将学会如何用 Rust 优雅地解决字符串分割问题，轻松提升开发效率！

本文通过 Rust 实现了一个高效的字符串分割函数 strtok，能够按指定字符分隔符分割字符串并返回子字符串，同时更新原字符串为剩余部分。文章详细解析了函数的设计逻辑，包括 Unicode 字符处理、切片操作及 UTF-8 编码的注意事项。结合代码示例和测试用例，展示了函数的正确性与实用性。无论你是 Rust 新手还是希望优化字符串处理的开发者，这篇实战指南都能为你提供清晰的思路和实用技巧。

## 实操

用Rust实现一个按照指定分隔符分割字符串的函数

### strtokstrtok 文档介绍

这是一个名为 `strtok` 的函数，它接收一个可变的字符串引用 `s` 和一个字符 `pat` 作为参数，并返回一个 `&str` 类型的值。
 函数的作用是将字符串 `s` 按照字符 `pat` 进行分割，并返回分割后的子字符串。
 函数的实现如下：

- 首先，使用 `find` 方法查找字符串 `s` 中第一次出现字符 `pat` 的位置。
- 如果找到了字符 `pat` ，则将字符串 `s` 分割成两部分：前缀 `prefix` 和后缀 `suffix` 。
  - 前缀 `prefix` 是从字符串 `s` 的开头到字符 `pat` 之前的部分。
  - 后缀 `suffix` 是从字符 `pat` 之后到字符串 `s` 的末尾的部分。
- 然后，将后缀 `suffix` 赋值给字符串 `s` ，以便在下一次调用 `strtok` 时继续处理剩余的部分。
- 最后，返回前缀 `prefix` 作为函数的结果。
  如果在字符串 `s` 中没有找到字符 `pat` ，则将整个字符串 `s` 作为前缀 `prefix` 返回，并将字符串 `s` 置为空字符串。

### strtok.rs 代码

```rust
// strtok(s = "hello world", " ")
// return "hello", s = "world"

pub fn strtok<'a>(s: &'a mut &str, pat: char) -> &'a str {
    match s.find(pat) {
        Some(i) => {
            let prefix = &s[..i]; // hello
            let suffix = &s[i + pat.len_utf8()..]; // char 是 Unicode &str 中的空格是 utf-8 故 pat 占的位置不一定是1
            *s = suffix;
            prefix
        }
        None => {
            let prefix = *s;
            *s = "";
            prefix
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let mut s = "hello world";
        assert_eq!(s.find(' '), Some(5));

        let s1 = &mut s;
        let t = strtok(s1, ' ');
        assert_eq!(t, "hello");
        assert_eq!(*s1, "world");
    }
}

```

这段代码实现了一个名为strtok的函数，用于将一个字符串按照指定的分隔符进行分割。
 代码步骤如下：

1. 接受两个参数：一个可变的字符串引用s和一个字符pat作为分隔符。
2. 使用match语句对字符串s中是否存在分隔符进行匹配。
3. 如果存在分隔符，则执行Some分支。
4. 在Some分支中，使用s.find(pat)方法找到分隔符的位置i。
5. 使用切片操作符(&s[..i])获取分隔符之前的部分作为前缀prefix。
6. 使用切片操作符(&s[i + pat.len_utf8()..])获取分隔符之后的部分作为后缀suffix。这里要注意，由于字符pat可能占用多个utf-8编码的字节，所以需要使用pat.len_utf8()来计算分隔符的长度。
7. 将s的值更新为后缀suffix。
8. 返回前缀prefix作为结果。
9. 如果不存在分隔符，则执行None分支。
10. 在None分支中，将s的值更新为空字符串""。
11. 返回原始的s作为结果。
     总结：这段代码实现了一个按照指定分隔符分割字符串的函数，如果存在分隔符，则返回分隔符之前的部分作为结果；如果不存在分隔符，则返回整个字符串作为结果。

### 测试

```bash
training_code on  master [?] is 📦 0.1.0 via 🦀 1.71.0 via 🅒 base 
➜ cargo test strtok::tests::it_works             
    Finished test [unoptimized + debuginfo] target(s) in 0.01s
     Running unittests src/lib.rs (target/debug/deps/training_code-c41752abc7a3994f)

running 1 test
test strtok::tests::it_works ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 1 filtered out; finished in 0.00s

```

## 总结

通过 Rust 实现的 strtok 函数，我们展示了一种高效、优雅的字符串分割方案。利用 Rust 的内存安全和切片操作，strtok 能在处理复杂文本时保持高性能，支持 Unicode 字符的正确分割。测试用例进一步验证了其可靠性，适用于从简单文本解析到大数据处理的多种场景。本文不仅为你提供了 strtok 的实现思路，还揭示了 Rust 在字符串操作中的强大潜力。快动手试试，打造属于你的高效 Rust 工具库吧！

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://crates.io/>
- <https://lab.cs.tsinghua.edu.cn/rust/>
- <https://awesome-rust.com/>
