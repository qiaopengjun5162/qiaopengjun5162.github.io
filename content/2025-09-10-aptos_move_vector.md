+++
title = "Aptos Move实战：5分钟掌握链上向量（Vector）核心操作"
description = "Aptos Move实战：5分钟掌握链上向量（Vector）核心操作"
date = 2025-09-10T03:50:02Z
[taxonomies]
categories = ["Web3", "Move", "Aptos"]
tags = ["Web3", "Move", "Aptos"]
+++

<!-- more -->

# **`Aptos Move实战：5分钟掌握链上向量（Vector）核心操作`**

想快速开发 Aptos 上的智能合约？首先你必须掌握 Move 语言的核心数据结构。**向量（Vector）**作为最基础且常用的动态数组，其概念类似于其他编程语言中的 **数组（Array）** 或 **列表（List）**，其操作的熟练度直接影响你的开发效率。本文将通过一个高度精炼的 Move 代码示例，带你用最少的时间，最快地掌握向量的创建、增、删、改、查等所有关键操作。准备好了吗？让我们立即进入实战！

本文专为希望高效学习的 Aptos 开发者打造。通过一个简洁的 Move 代码，我们将手把手演示向量（vector）的创建、**push_back**、**insert**、**remove**、**swap**、**borrow_mut** 等核心操作。文章提供清晰代码和测试输出，让你能直观理解每一步操作。这是一篇面向实战的 Move 向量速查手册，助你快速上手链上开发。

## 实操

Aptos Move Vectors

### 示例一

```rust
module net2dev_addr::vectors_one {
    use std::vector;

    fun vector_basics(): vector<u64> {
        // Initialize a Vector
        let list = vector::empty<u64>();

        // insert 10 at the end of the vector (last index);
        list.push_back(10); // [10]
        list.push_back(20); // [10, 20]

        // store 30 at specified index 2
        list.insert(2, 30); // [10, 20, 30]
        list.insert(3, 50); // [10, 20, 30, 50]
        list.insert(2, 20); // [10, 20, 20, 30, 50]

        // swap index 0 with 1
        list.swap(0, 1); // [20, 10, 20, 30, 50]

        // return vector index 2 mutable reference value
        let value = list.borrow_mut(2); // 20
        *value += 10; // 30
        list.insert(2, *value); // [20, 10, 30, 20, 30, 50]

        // remove element from vector at index 3
        list.remove(3); // [20, 10, 30, 30, 50]

        // return last element from vector (last index) and remove it
        list.pop_back(); // [20, 10, 30, 30] returns 50
        list // [20, 10, 30, 30]
    }

    #[test_only]
    use std::debug::print as p;

    #[test]
    fun test_function() {
        let list = vector_basics();
        assert!(list.length() == 4, 1);
        p(&list);
    }
}


```

这段 Aptos Move 代码通过一个名为 `vector_basics` 的函数，生动地展示了 `vector`（动态数组）的核心操作方法。首先，它使用 `vector::empty<u64>()` 创建了一个空的 `u64` 类型向量。接着，代码演示了如何添加元素：`push_back` 用于在末尾追加，`insert` 则可以在指定索引位置插入。此外，它还展示了如何使用 `swap` 交换两个元素的位置。在修改数据方面，代码通过 `borrow_mut` 获取了特定位置元素的可变引用，并直接更新了其值。对于删除操作，`remove` 可以删除指定索引的元素，而 `pop_back` 则会移除并返回向量的最后一个元素。最后，代码还包含一个 `test_function` 测试函数，它调用 `vector_basics` 并使用 `assert!` 来验证最终向量的长度是否符合预期，确保了代码逻辑的正确性。这串代码是学习 Move 语言中 `vector` 用法的绝佳实例。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] [ 20, 10, 30, 30 ]
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::vectors_one::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这段终端输出是执行 `aptos move test` 命令后的成功反馈。它首先加载了项目依赖库并完成了编译，然后进入单元测试环节。其中，`[debug] [ 20, 10, 30, 30 ]` 这一行是关键，它正是我们代码中测试函数打印出的最终向量状态，直观地验证了前面一系列增、删、改、换操作的最终结果。随后的 `[ PASS ]` 状态和 `Test result: OK. Total tests: 1; passed: 1; failed: 0` 的总结，明确地告诉我们，`vectors_one::test_function` 这个测试用例已经顺利通过了所有断言检查，证明我们的代码逻辑完全符合预期，整个测试过程圆满成功。

### 示例二

```rust
module net2dev_addr::vectors_one {
    use std::vector;
    use std::debug::print as p;

    fun vector_basics(): vector<u64> {
        // Initialize a Vector
        let list = vector::empty<u64>();

        // insert 10 at the end of the vector (last index);
        list.push_back(10); // [10]
        list.push_back(20); // [10, 20]

        // store 30 at specified index 2
        list.insert(2, 30); // [10, 20, 30]
        list.insert(3, 50); // [10, 20, 30, 50]
        list.insert(2, 20); // [10, 20, 20, 30, 50]

        // swap index 0 with 1
        list.swap(0, 1); // [20, 10, 20, 30, 50]

        // return vector index 2 mutable reference value
        let value = list.borrow_mut(2); // 20
        *value += 10; // 30
        list.insert(2, *value); // [20, 10, 30, 20, 30, 50]

        // remove element from vector at index 3
        list.remove(3); // [20, 10, 30, 30, 50]

        // return last element from vector (last index) and remove it
        list.pop_back(); // [20, 10, 30, 30] returns 50
        list // [20, 10, 30, 30]
    }

    // 打印向量中的所有元素，同时保持向量内容不变。它相当于一个调试工具，用于查看向量中存储的所有值。
    fun while_loop_vector(list: vector<u64>): vector<u64> {
        // return vector length
        let length = list.length();
        let i: u64 = 0;
        while (i < length) {
            let value = list.borrow(i);
            p(value);
            i += 1;
        };
        list
    }

    #[test]
    fun test_function() {
        let list = vector_basics();
        assert!(list.length() == 4, 1);
        assert!(list == vector[20, 10, 30, 30], 2);
        assert!(list.contains(&10), 3); // return true if vector contains 10;
        assert!(list.contains(&30), 3);
        let (b, index) = list.index_of(&30); // returns true and the index of a value
        assert!(b, 4);
        assert!(index == 2, 5);

        p(&list);

        let list = while_loop_vector(list);
        assert!(list == vector[20, 10, 30, 30], 6);
        assert!(list.length() == 4, 7);
        p(&list);
    }
}


```

这段Aptos Move代码定义了一个名为`vectors_one`的模块，主要演示了**向量（vector）**的基本操作。该模块包含三个函数：`vector_basics`、`while_loop_vector` 和一个测试函数 `test_function`。

`vector_basics`函数创建并操作一个**u64**类型的向量，展示了向量的初始化、添加（`push_back`、`insert`）、交换（`swap`）、可变引用（`borrow_mut`）、删除（`remove`、`pop_back`）等多种方法，最终返回一个被修改后的向量。

`while_loop_vector`函数则演示了如何使用**`while`循环**遍历向量中的所有元素，并使用`borrow`方法获取每个元素的值，通过`p(value)`进行打印，这是一种调试和检查向量内容的方法。

最后，`test_function`是一个测试用例，它调用前两个函数，并使用`assert!`宏来验证向量在执行各种操作后是否符合预期状态。它检查了向量的长度、内容、是否包含特定元素（`contains`）以及某个元素的索引（`index_of`），确保了向量操作的正确性。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] [ 20, 10, 30, 30 ]
[debug] 20
[debug] 10
[debug] 30
[debug] 30
[debug] [ 20, 10, 30, 30 ]
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::vectors_one::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这段测试结果显示，你运行了Move语言的单元测试，并且**测试成功通过**。

`[debug]`开头的几行是代码中`p(&list)`和`p(value)`等调试打印语句的输出，展示了向量在不同操作步骤后的实际内容。这有助于开发者在测试过程中观察数据变化。

`[ PASS ]`这一行则明确告诉你，名为`test_function`的测试函数成功执行，并且所有`assert!`断言都通过了。

最后，`Test result: OK. Total tests: 1; passed: 1; failed: 0` 总结了测试的整体情况：总共运行了1个测试，1个通过，0个失败，表明你的代码在逻辑上是**符合预期**的。

### 示例三

```rust
module net2dev_addr::vectors_one {
    use std::vector;
    use std::string::utf8;
    use std::debug::print as p;

    fun vector_basics(): vector<u64> {
        // Initialize a Vector
        let list = vector::empty<u64>();

        // insert 10 at the end of the vector (last index);
        list.push_back(10); // [10]
        list.push_back(20); // [10, 20]

        // store 30 at specified index 2
        list.insert(2, 30); // [10, 20, 30]
        list.insert(3, 50); // [10, 20, 30, 50]
        list.insert(2, 20); // [10, 20, 20, 30, 50]

        // swap index 0 with 1
        list.swap(0, 1); // [20, 10, 20, 30, 50]

        // return vector index 2 mutable reference value
        let value = list.borrow_mut(2); // 20
        *value += 10; // 30
        list.insert(2, *value); // [20, 10, 30, 20, 30, 50]

        // remove element from vector at index 3
        list.remove(3); // [20, 10, 30, 30, 50]

        // return last element from vector (last index) and remove it
        list.pop_back(); // [20, 10, 30, 30] returns 50
        list // [20, 10, 30, 30]
    }

    // 打印向量中的所有元素，同时保持向量内容不变。它相当于一个调试工具，用于查看向量中存储的所有值。
    fun while_loop_vector(list: vector<u64>): vector<u64> {
        // return vector length
        let length = list.length();
        let i: u64 = 0;
        while (i < length) {
            let value = list.borrow(i);
            p(value);
            i += 1;
        };
        list
    }

    fun read_element(element: u64) {
        p(&element);
    }

    fun update_element(element: &u64) {
        let value = *element + 1;
        p(&value);
    }

    fun for_each_vector(list: vector<u64>) {
        p(&utf8(b"For Each"));

        list.for_each(|element| {
            read_element(element);
        });

        p(&utf8(b"For Each Mutable"));
        list.for_each_mut(|element| {
            update_element(element);
        });
    }

    #[test]
    fun test_function() {
        let list = vector_basics();
        assert!(list.length() == 4, 1);
        assert!(list == vector[20, 10, 30, 30], 2);
        assert!(list.contains(&10), 3); // return true if vector contains 10;
        assert!(list.contains(&30), 3);
        let (b, index) = list.index_of(&30); // returns true and the index of a value
        assert!(b, 4);
        assert!(index == 2, 5);

        p(&list);

        p(&utf8(b"While Loop"));
        let list = while_loop_vector(list);
        assert!(list == vector[20, 10, 30, 30], 6);
        assert!(list.length() == 4, 7);
        p(&list);

        for_each_vector(list);
    }
}


```

这段 Aptos Move 代码是一个名为 `vectors_one` 的模块，它全面演示了 Aptos 中向量（**`vector`**）的多种常用操作。代码中定义了三个核心函数来展示不同的操作方式：

- **`vector_basics`**：这个函数是入门级的向量操作指南。它从创建一个空向量开始，逐步展示了如何**向向量尾部添加元素**（`push_back`）、**在指定位置插入元素**（`insert`）、**交换元素位置**（`swap`）、**修改指定位置的元素**（`borrow_mut`）以及**删除元素**（`remove`、`pop_back`），最后返回修改后的向量。
- **`while_loop_vector`**：该函数演示了如何使用传统的 **`while`** 循环来遍历向量。它获取向量的长度，然后通过一个计数器迭代访问每一个元素，并使用 `borrow` 方法获取元素的值进行打印，这是一种常见的调试手段。
- **`for_each_vector`**：这个函数则展示了 Move 语言中更现代、更简洁的迭代方式：**`for_each`** 和 **`for_each_mut`**。前者用于只读遍历，后者则允许在遍历时修改向量中的元素。它通过调用 `read_element` 和 `update_element` 这两个辅助函数，清晰地展示了两种迭代方式的不同应用场景。

最后，`test_function` 包含了多个断言（`assert!`），用于验证以上所有操作的正确性，确保向量在经过一系列增删改查后，其内容和状态都符合预期，充分保障了代码的可靠性。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] [ 20, 10, 30, 30 ]
[debug] "While Loop"
[debug] 20
[debug] 10
[debug] 30
[debug] 30
[debug] [ 20, 10, 30, 30 ]
[debug] "For Each"
[debug] 20
[debug] 10
[debug] 30
[debug] 30
[debug] "For Each Mutable"
[debug] 21
[debug] 11
[debug] 31
[debug] 31
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::vectors_one::test_function
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这段测试结果表明，你的Move代码中的所有单元测试都**成功通过**了。`[debug]`开头的多行输出是你在代码中设置的调试信息，它们清晰地展示了向量在不同操作（**`while`** 循环、**`for_each`** 和 **`for_each_mut`**）过程中，元素的具体值变化。这验证了向量的遍历和修改功能按预期工作，例如在 `for_each_mut` 遍历中，每个元素的值都成功地增加了 1。最终的摘要 **`Test result: OK. Total tests: 1; passed: 1; failed: 0`** 确认了测试的整体结果：总共运行了 1 个测试，所有测试都成功通过，没有失败。

## 总结

通过本文的实战演练，你已经全面掌握了 Aptos Move 语言中向量的各种核心操作。我们从基础的增删改查，到更高级的引用和遍历，每一个步骤都通过清晰的代码和成功的测试结果进行了验证。这篇指南旨在帮你快速上手，避免陷入冗长的理论学习。熟练运用这些向量操作，将让你在未来的 Aptos 链上应用开发中事半功倍。

## 参考

- <https://aptos.dev/zh>
- <https://x.com/aptos>
- <https://github.com/aptos-labs>
- <https://aptoslabs.com/>
