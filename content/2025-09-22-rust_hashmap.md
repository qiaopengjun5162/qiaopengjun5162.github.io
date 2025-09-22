+++
title = "Rust 实用进阶：用 HashMap 轻松搞定数据集合"
description = "Rust 实用进阶：用 HashMap 轻松搞定数据集合"
date = 2025-09-22T09:51:09Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# **Rust 实用进阶：用 HashMap 轻松搞定数据集合**

在编程世界中，数据组织和处理是核心任务。对于 Rust 开发者来说，如何高效地存储和访问键值对数据？答案就是 **`HashMap`**。它不仅仅是一个简单的容器，更是解决复杂数据统计、缓存、索引等问题的强大工具。

这篇文章将通过三个生动的实例，带你从入门到进阶，彻底掌握 `HashMap` 的核心用法。我们将用代码亲手构建一个水果篮，处理复杂的足球比赛数据，并深入理解 `entry`、`or_insert` 等高级方法，让你在 Rust 的世界里游刃有余。

本文通过三个独立的 Rust 代码示例，系统地讲解了 `HashMap` 的基础与高级用法。示例一展示了如何创建 `HashMap` 并使用 `insert` 方法添加键值对，通过简单的水果篮案例演示了基础的插入和数据验证。示例二引入了 `enum` 类型作为 `HashMap` 的键，并重点解析了 `entry().or_insert()` 这种更优雅、高效的条件插入方法，避免了重复查询。示例三则通过一个复杂的足球比赛计分表任务，深入讲解了如何结合 `struct` 和 `entry().and_modify().or_insert()` 方法，实现对现有数据的高效更新与插入，完美解决了数据累加的常见场景。通过这些实操，读者将全面掌握 `HashMap` 在 Rust 中的强大应用。

## 实操

### 示例一

```rust
// hashmaps1.rs
//
// A basket of fruits in the form of a hash map needs to be defined. The key
// represents the name of the fruit and the value represents how many of that
// particular fruit is in the basket. You have to put at least three different
// types of fruits (e.g apple, banana, mango) in the basket and the total count
// of all the fruits should be at least five.

use std::collections::HashMap;

fn fruit_basket() -> HashMap<String, u32> {
    let mut basket = HashMap::new();

    // Two bananas are already given for you :)
    basket.insert(String::from("banana"), 2);
    basket.insert(String::from("apple"), 4);
    basket.insert(String::from("orange"), 1);
    basket.insert(String::from("mango"), 3);

    basket
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn at_least_three_types_of_fruits() {
        let basket = fruit_basket();
        assert!(basket.len() >= 3);
    }

    #[test]
    fn at_least_five_fruits() {
        let basket = fruit_basket();
        assert!(basket.values().sum::<u32>() >= 5);
    }
}

```

这段 Rust 代码定义了一个名为 `fruit_basket` 的函数，该函数创建一个**哈希映射（`HashMap`）**来表示一个水果篮。哈希映射的**键（`Key`）**是水果的名称（`String` 类型），而**值（`Value`）**是该水果的数量（`u32` 类型）。代码通过插入（`insert`）操作向篮子中添加了四种水果（香蕉、苹果、橙子、芒果），并分别给它们设定了数量。最后，代码通过两个测试来确保这个水果篮满足要求：一是篮子里至少有三种不同的水果（通过 `basket.len() >= 3` 判断），二是所有水果的总数至少为五个（通过 `basket.values().sum::<u32>() >= 5` 计算所有值的总和来判断）。

### 示例二

```rust
// hashmaps2.rs
//
// We're collecting different fruits to bake a delicious fruit cake. For this,
// we have a basket, which we'll represent in the form of a hash map. The key
// represents the name of each fruit we collect and the value represents how
// many of that particular fruit we have collected. Three types of fruits -
// Apple (4), Mango (2) and Lychee (5) are already in the basket hash map. You
// must add fruit to the basket so that there is at least one of each kind and
// more than 11 in total - we have a lot of mouths to feed. You are not allowed
// to insert any more of these fruits!

use std::collections::HashMap;

#[derive(Hash, PartialEq, Eq)]
enum Fruit {
    Apple,
    Banana,
    Mango,
    Lychee,
    Pineapple,
}

fn fruit_basket(basket: &mut HashMap<Fruit, u32>) {
    let fruit_kinds = vec![
        Fruit::Apple,
        Fruit::Banana,
        Fruit::Mango,
        Fruit::Lychee,
        Fruit::Pineapple,
    ];

    for fruit in fruit_kinds {
        // Insert new fruits if they are not already present in the
        // basket. Note that you are not allowed to put any type of fruit that's
        // already present!

        // 方式一
        // if !basket.contains_key(&fruit) {
        //     basket.insert(fruit, 1);
        // }

        // 方式二
        // if let None = basket.get(&fruit) {
        //     basket.insert(fruit, 1);
        // }

        // 方式三
        basket.entry(fruit).or_insert(1);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // Don't modify this function!
    fn get_fruit_basket() -> HashMap<Fruit, u32> {
        let mut basket = HashMap::<Fruit, u32>::new();
        basket.insert(Fruit::Apple, 4);
        basket.insert(Fruit::Mango, 2);
        basket.insert(Fruit::Lychee, 5);

        basket
    }

    #[test]
    fn test_given_fruits_are_not_modified() {
        let mut basket = get_fruit_basket();
        fruit_basket(&mut basket);
        assert_eq!(*basket.get(&Fruit::Apple).unwrap(), 4);
        assert_eq!(*basket.get(&Fruit::Mango).unwrap(), 2);
        assert_eq!(*basket.get(&Fruit::Lychee).unwrap(), 5);
    }

    #[test]
    fn at_least_five_types_of_fruits() {
        let mut basket = get_fruit_basket();
        fruit_basket(&mut basket);
        let count_fruit_kinds = basket.len();
        assert!(count_fruit_kinds >= 5);
    }

    #[test]
    fn greater_than_eleven_fruits() {
        let mut basket = get_fruit_basket();
        fruit_basket(&mut basket);
        let count = basket.values().sum::<u32>();
        assert!(count > 11);
    }

    #[test]
    fn all_fruit_types_in_basket() {
        let mut basket = get_fruit_basket();
        fruit_basket(&mut basket);
        for amount in basket.values() {
            assert_ne!(amount, &0);
        }
    }
}

```

这段 Rust 代码通过一个名为 `fruit_basket` 的函数来管理一个水果哈希映射。首先，它定义了一个名为 `Fruit` 的**枚举**类型来代表不同的水果种类，并为它实现了哈希（`Hash`）、相等（`PartialEq`）和等价（`Eq`）等特性，以便能作为哈希映射的键。`fruit_basket` 函数会遍历一个包含多种水果类型的向量，并使用**哈希映射的 `entry` 方法**（`basket.entry(fruit).or_insert(1)`）来有条件地向水果篮中添加水果：如果水果篮中**尚不存在**某种水果，就将其插入并赋值数量为 1；如果水果**已经存在**，则**不做任何操作**。最后，代码通过四项测试，验证了最终的水果篮符合所有要求：原始水果（苹果、芒果、荔枝）的数量没有被修改，篮子里至少有五种不同类型的水果，水果总数大于 11 个，并且所有水果的数量都大于零。

### 示例三

```rust
// hashmaps3.rs
//
// A list of scores (one per line) of a soccer match is given. Each line is of
// the form : "<team_1_name>,<team_2_name>,<team_1_goals>,<team_2_goals>"
// Example: England,France,4,2 (England scored 4 goals, France 2).
//
// You have to build a scores table containing the name of the team, goals the
// team scored, and goals the team conceded. One approach to build the scores
// table is to use a Hashmap. The solution is partially written to use a
// Hashmap, complete it to pass the test.

use std::collections::HashMap;

// A structure to store the goal details of a team.
struct Team {
    goals_scored: u8,
    goals_conceded: u8,
}

fn build_scores_table(results: String) -> HashMap<String, Team> {
    // The name of the team is the key and its associated struct is the value.
    let mut scores: HashMap<String, Team> = HashMap::new();

    for r in results.lines() {
        let v: Vec<&str> = r.split(',').collect();
        let team_1_name = v[0].to_string();
        let team_1_score: u8 = v[2].parse().unwrap();
        let team_2_name = v[1].to_string();
        let team_2_score: u8 = v[3].parse().unwrap();
        // Populate the scores table with details extracted from the
        // current line. Keep in mind that goals scored by team_1
        // will be the number of goals conceded from team_2, and similarly
        // goals scored by team_2 will be the number of goals conceded by
        // team_1.

        // 方式一
        // if scores.contains_key(&team_1_name) {
        //     let team = scores.get_mut(&team_1_name).unwrap();
        //     team.goals_scored += team_1_score;
        //     team.goals_conceded += team_2_score;
        // } else {
        //     let team = Team {
        //         goals_scored: team_1_score,
        //         goals_conceded: team_2_score,
        //     };
        //     scores.insert(team_1_name, team);
        // }
        // if scores.contains_key(&team_2_name) {
        //     let team = scores.get_mut(&team_2_name).unwrap();
        //     team.goals_scored += team_2_score;
        //     team.goals_conceded += team_1_score;
        // } else {
        //     let team = Team {
        //         goals_scored: team_2_score,
        //         goals_conceded: team_1_score,
        //     };
        //     scores.insert(team_2_name, team);
        // }

        // 方式二
        // Update or insert team 1's scores
        scores
            .entry(team_1_name)
            .and_modify(|team| {
                team.goals_scored += team_1_score;
                team.goals_conceded += team_2_score;
            })
            .or_insert(Team {
                goals_scored: team_1_score,
                goals_conceded: team_2_score,
            });

        // Update or insert team 2's scores
        scores
            .entry(team_2_name)
            .and_modify(|team| {
                team.goals_scored += team_2_score;
                team.goals_conceded += team_1_score;
            })
            .or_insert(Team {
                goals_scored: team_2_score,
                goals_conceded: team_1_score,
            });
    }
    scores
}

#[cfg(test)]
mod tests {
    use super::*;

    fn get_results() -> String {
        let results = "".to_string()
            + "England,France,4,2\n"
            + "France,Italy,3,1\n"
            + "Poland,Spain,2,0\n"
            + "Germany,England,2,1\n";
        results
    }

    #[test]
    fn build_scores() {
        let scores = build_scores_table(get_results());

        let mut keys: Vec<&String> = scores.keys().collect();
        keys.sort();
        assert_eq!(
            keys,
            vec!["England", "France", "Germany", "Italy", "Poland", "Spain"]
        );
    }

    #[test]
    fn validate_team_score_1() {
        let scores = build_scores_table(get_results());
        let team = scores.get("England").unwrap();
        assert_eq!(team.goals_scored, 5);
        assert_eq!(team.goals_conceded, 4);
    }

    #[test]
    fn validate_team_score_2() {
        let scores = build_scores_table(get_results());
        let team = scores.get("Spain").unwrap();
        assert_eq!(team.goals_scored, 0);
        assert_eq!(team.goals_conceded, 2);
    }
}

```

这段 Rust 代码通过一个名为 `build_scores_table` 的函数来处理比赛结果字符串，并建立一个包含各球队得分信息的哈希映射（`HashMap`）。首先，代码定义了一个 `Team` **结构体**来存储每个球队的进球数（`goals_scored`）和失球数（`goals_conceded`）。然后，函数会遍历输入的每行比赛结果，将每行的字符串按逗号分隔，提取出两支球队的名称和各自的进球数。对于每一支球队，代码都使用哈希映射的 **`entry()` 方法**配合 **`and_modify()`** 和 **`or_insert()`** 来更新或插入数据：如果球队已存在于哈希映射中，就更新其进球和失球数；如果不存在，则创建一个新的 `Team` 实例并插入到哈希映射中。整个过程会处理所有比赛数据，最终返回一个包含了所有球队详细得分记录的哈希映射。

## 总结

通过这三个循序渐进的 Rust 示例，我们深入探索了 `HashMap` 的核心功能。从最基础的 `insert` 方法，到优雅地处理条件插入的 `entry().or_insert()`，再到高效更新与插入并存的 `entry().and_modify().or_insert()`，我们看到了 `HashMap` 在应对不同数据处理挑战时的灵活性和强大。

掌握 `HashMap` 的这些精髓，你将能够更自信地处理各种数据集合问题，无论是简单的数据统计还是复杂的业务逻辑。希望这些实操能帮助你更好地理解和运用 Rust 的这一重要数据结构，为你的编程之路添砖加瓦。

## 参考

- <https://github.com/qiaopengjun5162/rust-rustlings-2024-spring-qiaopengjun5162>
- <https://rust-book.junmajinlong.com/ch1/00.html>
- <https://blog.yoshuawuyts.com/futures-concurrency-3/>
- <https://dhghomon.github.io/easy_rust/Chapter_1.html>
