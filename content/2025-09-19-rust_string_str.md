+++
title = "Rust 字符串魔法：String 与 &str 的深度解析与实践*"
description = "Rust 字符串魔法：String 与 &str 的深度解析与实践*"
date = 2025-09-19T09:59:59Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# **Rust 字符串魔法：String 与 &str 的深度解析与实践**

在 Rust 中，字符串是开发者经常会遇到的一个“痛点”，因为它不像其他语言那样简单。`String` 和 `&str` 这两种类型，一个拥有所有权，一个只是借用，它们之间的微妙关系是理解 Rust 所有权系统的关键。然而，一旦掌握了它们，你将能体会到 Rust 在内存安全和性能上的独特优势。本文将通过一系列实践案例，为你揭开 Rust 字符串的神秘面纱，让你从此告别困惑，真正用好这把强大的工具。

还在为 Rust 里的 `String` 和 `&str` 感到困惑吗？本文将通过四个精心设计的代码示例，带你彻底掌握这两种字符串类型的核心区别和用法。我们将从基础的创建和转换，到复杂的切片与操作，全面展示它们在实际编程中的协作方式。读完本文，你将能自信地处理 Rust 里的所有字符串问题，写出更高效、更地道的 Rust 代码。

## 实操

### 示例一

```rust
// strings1.rs

fn main() {
    let answer = current_favorite_color();
    println!("My current favorite color is {}", answer);
}

fn current_favorite_color() -> String {
    "blue".to_string()
}

```

这段 Rust 代码展示了如何使用 `String` 类型来处理文本数据。`current_favorite_color` 函数返回一个 `String` 类型的值，它是通过调用 `.to_string()` 方法将一个字符串字面量 `"blue"` 转换而来的。这种转换是必要的，因为字符串字面量 (`&'static str`) 是不可变的、固定大小的，而 `String` 则是可变的、在堆上分配的、可增长的。`main` 函数调用这个函数并将返回的 `String` 值绑定到 `answer` 变量上，然后使用 `println!` 宏将其打印到控制台，从而展示了 `String` 类型在程序中的基本使用方式。

### 示例二

```rust
// strings2.rs

fn main() {
    let word = String::from("green"); // Try not changing this line :)
    if is_a_color_word(&word) {
        println!("That is a color word I know!");
    } else {
        println!("That is not a color word I know.");
    }
}

fn is_a_color_word(attempt: &str) -> bool {
    attempt == "green" || attempt == "blue" || attempt == "red"
}

```

这段 Rust 代码展示了 `String` 类型和字符串切片 `&str` 之间的互操作性。在 `main` 函数中，一个可变的 `String` 类型变量 `word` 被初始化为 `"green"`。`is_a_color_word` 函数接收一个**字符串切片** `&str` 作为参数，而不是 `String`。`&str` 是一种对字符串数据进行引用的类型，它通常是只读的，并且指向一个固定的位置。当 `word` 变量被传递给 `is_a_color_word` 函数时，Rust 会自动将 `String` 变量**解引用**成一个 `&str` 切片，这被称为**Deref 强制转换 (Deref Coercion)**。该函数通过比较输入的字符串切片是否等于预定义的颜色字符串来返回布尔值，最终在 `main` 函数中根据结果打印相应的消息。这个例子完美地说明了在 Rust 中，通过使用 `&str` 参数，函数可以灵活地接受 `String` 或其他字符串字面量作为输入，提高了代码的通用性。

### 示例三

```rust
// strings3.rs

fn trim_me(input: &str) -> String {
    // Remove whitespace from both ends of a string!
    input.trim().to_string()
}

fn compose_me(input: &str) -> String {
    // Add " world!" to the string! There's multiple ways to do this!
    format!("{} world!", input)
}

fn replace_me(input: &str) -> String {
    // Replace "cars" in the string with "balloons"!
    input.replace("cars", "balloons")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn trim_a_string() {
        assert_eq!(trim_me("Hello!     "), "Hello!");
        assert_eq!(trim_me("  What's up!"), "What's up!");
        assert_eq!(trim_me("   Hola!  "), "Hola!");
    }

    #[test]
    fn compose_a_string() {
        assert_eq!(compose_me("Hello"), "Hello world!");
        assert_eq!(compose_me("Goodbye"), "Goodbye world!");
    }

    #[test]
    fn replace_a_string() {
        assert_eq!(
            replace_me("I think cars are cool"),
            "I think balloons are cool"
        );
        assert_eq!(
            replace_me("I love to look at cars"),
            "I love to look at balloons"
        );
    }
}

```

这段 Rust 代码通过三个函数和相应的单元测试，展示了如何使用 `&str` 字符串切片和 `String` 类型进行常见的文本操作。`trim_me` 函数利用 `&str` 的 `trim()` 方法去除字符串两端的空白，并使用 `to_string()` 将结果转换回 `String` 类型。`compose_me` 函数则展示了 `format!` 宏的用法，它能够高效地格式化并拼接字符串，将一个 `&str` 和一个固定的字符串字面量组合成一个新的 `String`。最后，`replace_me` 函数使用了 `&str` 的 `replace()` 方法，该方法会查找并替换所有匹配的子字符串。这些函数都接受不可变的字符串切片 `&str` 作为输入，这是一种灵活且性能高效的设计，因为它允许函数处理各种字符串类型，而无需拥有所有权。每个函数都附带了单元测试，确保了代码的正确性。

### 示例四

```rust
// strings4.rs

fn string_slice(arg: &str) {
    println!("{}", arg);
}
fn string(arg: String) {
    println!("{}", arg);
}

fn main() {
    string_slice("blue");
    string("red".to_string());
    string(String::from("hi"));
    string("rust is fun!".to_owned());
    string("nice weather".into());
    string(format!("Interpolation {}", "Station"));
    string_slice(&String::from("abc")[0..1]);
    string_slice("  hello there ".trim());
    string("Happy Monday!".to_string().replace("Mon", "Tues"));
    string("mY sHiFt KeY iS sTiCkY".to_lowercase());
}
```

这段 Rust 代码通过 `main` 函数中的多个调用，系统地展示了 `String` 类型和 `&str` 字符串切片之间的多种创建和转换方式。`string_slice` 函数只接受不可变的 `&str` 类型，而 `string` 函数则接受可变的 `String` 类型。通过这些调用，我们可以看到：`&str` 可以直接从字符串字面量 (`"blue"`) 传递；`String` 可以通过 `.to_string()`、`String::from()`、`.to_owned()` 和 `.into()` 等多种方法从 `&str` 或其他类型转换而来；`format!` 宏能创建新的 `String`；`&String` 可以通过切片（`[0..1]`）转换为 `&str`；最后，一些常用方法如 `.trim()`、`.replace()` 和 `.to_lowercase()` 既可以作用于 `&str` 也可以作用于 `String`，并且通常会返回一个新的 `String`，从而展示了这两种类型在处理文本时的灵活性和互操作性。

### 输出

```bash
Output:
====================
blue
red
hi
rust is fun!
nice weather
Interpolation Station
a
hello there
Happy Tuesday!
my shift key is sticky

====================
```

## 总结

通过这四个循序渐进的示例，我们全面深入地学习了 Rust 字符串的精髓。我们首先理解了 `String` 作为可变、拥有所有权的字符串类型，以及 `&str` 作为不可变、借用的字符串切片的本质。接着，我们探索了它们之间的灵活转换和互操作性，特别是 `Deref` 强制转换如何让代码变得更加通用。最后，我们实践了多种字符串操作，例如修剪、拼接和替换，并深入了解了 `String` 和 `&str` 的实际应用场景。掌握 `String` 与 `&str` 的正确使用，不仅能让你写出高效、安全的代码，更是你迈向 Rust 高级开发者的重要一步。

## 参考

- <https://doc.rust-lang.org/book/>
- <https://rust-chinese-translation.github.io/api-guidelines/>
- <https://doc.rust-lang.org/reference/introduction.html>
