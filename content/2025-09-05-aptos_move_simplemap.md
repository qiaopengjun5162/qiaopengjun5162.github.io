+++
title = "Aptos Move 实战：全面掌握 `SimpleMap` 的增删改查"
description = "Aptos Move 实战：全面掌握 `SimpleMap` 的增删改查"
date = 2025-09-05T02:49:46Z
[taxonomies]
categories = ["Web3", "Move", "Aptos"]
tags = ["Web3", "Move", "Aptos"]
+++

<!-- more -->

# **Aptos Move 实战：全面掌握 `SimpleMap` 的增删改查**

在智能合约开发中，管理动态的数据集合是一项基本功。键值对（Key-Value）映射作为最高效、最常用的数据结构之一，是每个开发者都必须掌握的工具。在 Aptos Move 中，`SimpleMap` 就为我们提供了这样一个基础而强大的实现。

这篇实战教程的目标只有一个：带你**全面掌握 `SimpleMap` 的增删改查（CRUD）**。我们将从最基础的创建和添加操作开始，逐步学习如何读取、移除，并最终掌握强大的更新或插入 (`upsert`) 功能。更重要的是，你将学会如何将这些操作封装成清晰的辅助函数，并通过单元测试来验证一个映射（Map）从诞生到变化的完整生命周期。

这篇 Aptos Move 实战教程，带你全面掌握核心数据结构 `SimpleMap`。你将通过渐进式案例，学会 `add`, `borrow`, `remove`, `upsert` 等完整的增删改查（CRUD）操作，并通过单元测试验证其生命周期。

## 实操

Aptos Move Maps

### 示例一

```rust
module net2dev_addr::MapsDemo {
    use std::simple_map::{SimpleMap, Self};
    use std::string::{String, utf8};

    fun create_map(): SimpleMap<u64, String> {
        let my_map: SimpleMap<u64, String> = simple_map::create();
        my_map.add(1, utf8(b"UAE"));
        my_map.add(2, utf8(b"RUS"));
        my_map.add(3, utf8(b"MEX"));
        my_map.add(4, utf8(b"COL"));
        my_map
    }

    #[test_only]
    use std::debug::print;

    #[test]
    fun test_map() {
        let my_map = create_map();
        assert!(my_map.contains_key(&1), 0);
        assert!(my_map.contains_key(&2), 1);
        assert!(my_map.contains_key(&3), 2);
        assert!(my_map.contains_key(&4), 3);
        assert!(my_map.length() == 4, 4);

        let country = my_map.borrow(&1);
        assert!(country == &utf8(b"UAE"), 5);
        print(country);

        let country = my_map.borrow(&2);
        assert!(country == &utf8(b"RUS"), 6);
        print(country);

        let country = my_map.borrow(&3);
        assert!(country == &utf8(b"MEX"), 7);
        print(country);

        let country = my_map.borrow(&4);
        assert!(country == &utf8(b"COL"), 8);
        print(country);
    }
}


```

这段 Aptos Move 代码通过一个名为 `MapsDemo` 的模块，演示了标准库中基础键值对数据结构 **`SimpleMap`** 的用法。模块中的 `create_map` 函数展示了如何初始化一个空映射并用多个键值对（在此例中是 `u64` 整数键到 `String` 字符串值）进行填充。而 `test_map` 单元测试则验证了该映射的功能，它通过执行一系列常用操作——如使用 **`contains_key`** 检查键是否存在、使用 **`length`** 获取大小、以及使用 **`borrow`** 读取值——并利用 `assert!` 语句来确保所有操作都返回了预期的正确结果。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] "UAE"
[debug] "RUS"
[debug] "MEX"
[debug] "COL"
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::MapsDemo::test_map
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过其全部单元测试**。在成功编译项目后，测试框架执行了 `MapsDemo` 模块中定义的唯一一个测试函数 `test_map`。日志中的 `[debug]` 行清晰地打印出了 "UAE"、"RUS" 等字符串，这些正是测试代码在执行过程中**通过 `borrow` 方法从 `SimpleMap` 中成功读取出的值**。最终的 `[ PASS ]` 状态，结合 `Test result: OK` 的总结陈述，共同确认了该测试用例顺利完成，意味着其内部所有关于 `contains_key`、`length` 和 `borrow` 的 `assert!` 断言均已满足，证明了你代码中对 `SimpleMap` 的各项操作逻辑完全正确。

### 示例二

```rust
module net2dev_addr::MapsDemo {
    use std::simple_map::{SimpleMap, Self};
    use std::string::{String, utf8};

    fun create_map(): SimpleMap<u64, String> {
        let my_map: SimpleMap<u64, String> = simple_map::create();
        my_map.add(1, utf8(b"UAE"));
        my_map.add(2, utf8(b"RUS"));
        my_map.add(3, utf8(b"MEX"));
        my_map.add(4, utf8(b"COL"));
        my_map
    }

    fun check_map_length(my_map: SimpleMap<u64, String>): u64 {
        my_map.length()
    }

    #[test_only]
    use std::debug::print;

    #[test]
    fun test_map() {
        let my_map = create_map();
        assert!(my_map.contains_key(&1), 0);
        assert!(my_map.contains_key(&2), 1);
        assert!(my_map.contains_key(&3), 2);
        assert!(my_map.contains_key(&4), 3);
        assert!(my_map.length() == 4, 4);

        let country = my_map.borrow(&1);
        assert!(country == &utf8(b"UAE"), 5);
        print(country);

        let country = my_map.borrow(&2);
        assert!(country == &utf8(b"RUS"), 6);
        print(country);

        let country = my_map.borrow(&3);
        assert!(country == &utf8(b"MEX"), 7);
        print(country);

        let country = my_map.borrow(&4);
        assert!(country == &utf8(b"COL"), 8);
        print(country);

        let length = check_map_length(my_map);
        assert!(length == 4, 9);
        print(&length);
    }
}

```

这段 Aptos Move 代码通过一个名为 `MapsDemo` 的模块，演示了 **`SimpleMap`** 的用法以及创建**辅助函数 (helper function)** 的概念。在原有的 `create_map` 函数基础上，该模块新增了一个 `check_map_length` 函数，其唯一职责就是接收一个映射并返回它的大小。主单元测试 `test_map` 现在验证了整个工作流程：它首先直接检查映射的内容和属性，随后调用新增的 `check_map_length` 辅助函数并断言其返回值，从而确认了**直接的映射操作**和**封装后的辅助函数**都能正确工作。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] "UAE"
[debug] "RUS"
[debug] "MEX"
[debug] "COL"
[debug] 4
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::MapsDemo::test_map
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过其全部单元测试**。在成功编译项目后，测试框架执行了 `MapsDemo` 模块中定义的唯一一个测试函数 `test_map`。日志中的 `[debug]` 输清晰地展示了测试的全过程：它首先打印出了从 Map 中成功读取的 "UAE", "RUS" 等四个字符串值，最后打印出的数字 `4` 则是新增的 `check_map_length` 辅助函数返回的正确长度。最终的 `[ PASS ]` 状态和 `Test result: OK` 的总结陈述，共同确认了该测试用例顺利完成，证明了你代码中直接的 Map 操作以及封装后的辅助函数逻辑都完全正确。

### 示例三

```rust
module net2dev_addr::MapsDemo {
    use std::simple_map::{SimpleMap, Self};
    use std::string::{String, utf8};

    fun create_map(): SimpleMap<u64, String> {
        let my_map: SimpleMap<u64, String> = simple_map::create();
        my_map.add(1, utf8(b"UAE"));
        my_map.add(2, utf8(b"RUS"));
        my_map.add(3, utf8(b"MEX"));
        my_map.add(4, utf8(b"COL"));
        my_map
    }

    fun check_map_length(my_map: SimpleMap<u64, String>): u64 {
        my_map.length()
    }

    fun check_map_contains(my_map: SimpleMap<u64, String>, key: u64): bool {
        my_map.contains_key(&key)
    }

    fun remove_from_map(my_map: SimpleMap<u64, String>, key: u64): SimpleMap<u64, String> {
        my_map.remove(&key);
        my_map
    }

    fun upsert_map(
        my_map: SimpleMap<u64, String>,
        key: u64,
        value: String
    ): SimpleMap<u64, String> {
        my_map.upsert(key, value);
        my_map
    }

    #[test_only]
    use std::debug::print;

    #[test]
    fun test_map() {
        let my_map = create_map();
        assert!(my_map.contains_key(&1), 0);
        assert!(my_map.contains_key(&2), 1);
        assert!(my_map.contains_key(&3), 2);
        assert!(my_map.contains_key(&4), 3);
        assert!(my_map.length() == 4, 4);

        let country = my_map.borrow(&1);
        assert!(country == &utf8(b"UAE"), 5);
        print(country);

        let country = my_map.borrow(&2);
        assert!(country == &utf8(b"RUS"), 6);
        print(country);

        let country = my_map.borrow(&3);
        assert!(country == &utf8(b"MEX"), 7);
        print(country);

        let country = my_map.borrow(&4);
        assert!(country == &utf8(b"COL"), 8);
        print(country);

        let length = check_map_length(my_map);
        assert!(length == 4, 9);
        print(&length);

        let new_map = remove_from_map(my_map, 2);
        let length = check_map_length(new_map);
        assert!(length == 3, 10);
        print(&length);
        print(&new_map);

        let new_map = upsert_map(new_map, 2, utf8(b"CAN"));
        let length = check_map_length(new_map);
        assert!(length == 4, 11);
        print(&length);
        print(&new_map);

        let b = check_map_contains(new_map, 2);
        assert!(b == true, 12);
        print(&b);
    }
}


```

这段 Aptos Move 代码扩展了 `MapsDemo` 模块，通过将更全面的 **`SimpleMap`** 操作**封装**到各自的辅助函数中来进行演示。除了创建和读取映射，代码新增了用于检查键是否存在 (`check_map_contains`)、移除键值对 (`remove_from_map`) 以及插入或更新值 (`upsert_map`) 的函数。其主单元测试 `test_map` 现在演示了该映射的一个**完整生命周期**：它首先创建并验证初始数据，接着调用辅助函数移除一个元素，然后使用 `upsert` 将该元素以不同的值重新加回，并通过 `assert!` 语句在**每个阶段都验证了映射的状态**。

### 测试

```bash
➜ aptos move test
INCLUDING DEPENDENCY AptosFramework
INCLUDING DEPENDENCY AptosStdlib
INCLUDING DEPENDENCY MoveStdlib
BUILDING my-dapp
Running Move unit tests
[debug] "UAE"
[debug] "RUS"
[debug] "MEX"
[debug] "COL"
[debug] 4
[debug] 3
[debug] 0x1::simple_map::SimpleMap<u64, 0x1::string::String> {
  data: [
    0x1::simple_map::Element<u64, 0x1::string::String> {
      key: 1,
      value: "UAE"
    },
    0x1::simple_map::Element<u64, 0x1::string::String> {
      key: 4,
      value: "COL"
    },
    0x1::simple_map::Element<u64, 0x1::string::String> {
      key: 3,
      value: "MEX"
    }
  ]
}
[debug] 4
[debug] 0x1::simple_map::SimpleMap<u64, 0x1::string::String> {
  data: [
    0x1::simple_map::Element<u64, 0x1::string::String> {
      key: 1,
      value: "UAE"
    },
    0x1::simple_map::Element<u64, 0x1::string::String> {
      key: 4,
      value: "COL"
    },
    0x1::simple_map::Element<u64, 0x1::string::String> {
      key: 3,
      value: "MEX"
    },
    0x1::simple_map::Element<u64, 0x1::string::String> {
      key: 2,
      value: "CAN"
    }
  ]
}
[debug] true
[ PASS    ] 0x48daaa7d16f1a59929ece03157b8f3e4625bc0a201988ac6fea9b38f50db5ef3::MapsDemo::test_map
Test result: OK. Total tests: 1; passed: 1; failed: 0
{
  "Result": "Success"
}
```

这个测试结果表明，你的 `my-dapp` 项目**已成功通过其全部单元测试**。在成功编译项目后，唯一的测试函数 `test_map` 被执行，其详细的 `[debug]` 输出清晰地记录了 `SimpleMap` 对象的**完整生命周期**：从初始内容和长度（`4`）的验证，到移除一个元素后其内容的变化和长度缩减为 `3`，再到通过 `upsert` 操作将键重新插入新值 "CAN" 后内容恢复且长度变回 `4`。最终的 `[ PASS ]` 状态及 `Test result: OK` 的总结，证明了测试中的每一步 `assert!` 断言均已满足，验证了你代码中对 `SimpleMap` 的创建、读取、移除和更新/插入等一系列连续操作的逻辑完全正确。

## 总结

恭喜你！通过本篇详尽的实战教程，你已经全面掌握了 Aptos Move 中 `SimpleMap` 的**增删改查（CRUD）**全流程。我们一起走完了创建、填充、读取、移除、再到更新/插入 (`upsert`) 的完整生命周期，并学习了将其操作逻辑封装成独立函数的优秀实践。

最终测试报告中每一条 `[ PASS ]` 记录，都证明了我们对 `SimpleMap` 每一步操作的逻辑都精准无误。现在，你可以自信地在自己的 Aptos Move 项目中使用 `SimpleMap` 来高效、安全地管理链上数据了。掌握了 `SimpleMap`，你已经为学习 Aptos 中更强大的 `Table` 等大规模存储工具打下了坚实的基础。

## 参考

- <https://dorahacks.io/hackathon/aptos-ctrlmove-hackathon/detail>
- <https://aptos.dev/>
- <https://learn.aptoslabs.com/en>
- <https://github.com/aptos-labs/move-by-examples>
