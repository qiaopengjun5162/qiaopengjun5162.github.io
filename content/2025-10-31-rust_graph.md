+++
title = "Rust 实战：从零开始实现一个无向带权图"
description = "Rust 实战：从零开始实现一个无向带权图"
date = 2025-10-31T09:37:50Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 💻 Rust 实战：从零开始实现一个无向带权图

图（Graph）是计算机科学中极其重要且强大的数据结构，广泛应用于网络路由、社交关系、地图导航等领域。掌握图的底层实现是深入理解算法和数据结构的关键一步。

本文将聚焦于 Rust 语言，通过一段实战代码，为您彻底剖析如何构建一个**高性能的无向带权图**。我们将看到 Rust 的 **Trait (特性)** 如何定义标准接口，**HashMap** 如何作为高效的邻接表，以及如何确保无向图的每一条边都是双向联通的。无论您是 Rust 初学者还是希望加深对数据结构理解的开发者，这篇文章都将提供清晰、实用的指导。

本文通过一段完整的 Rust 代码，详细解析了如何利用 **HashMap** 和 **Trait (特性)** 实现一个**基于邻接表的无向带权图** (`UndirectedGraph`)。内容涵盖图的底层数据结构设计、`Graph` 特性的核心接口定义（如 `add_node`、`add_edge`）以及无向边双向添加的关键逻辑。通过测试代码，演示了图结构创建和数据存储的正确性。

## 实操

Rust 图代码

```rust
/*
    graph
    implement a basic graph functio
*/

use std::collections::{HashMap, HashSet};
use std::fmt;
#[derive(Debug, Clone)]
pub struct NodeNotInGraph;
impl fmt::Display for NodeNotInGraph {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "accessing a node that is not in the graph")
    }
}
pub struct UndirectedGraph {
    adjacency_table: HashMap<String, Vec<(String, i32)>>,
}
impl Graph for UndirectedGraph {
    fn new() -> UndirectedGraph {
        UndirectedGraph {
            adjacency_table: HashMap::new(),
        }
    }
    fn adjacency_table_mutable(&mut self) -> &mut HashMap<String, Vec<(String, i32)>> {
        &mut self.adjacency_table
    }
    fn adjacency_table(&self) -> &HashMap<String, Vec<(String, i32)>> {
        &self.adjacency_table
    }
    fn add_edge(&mut self, edge: (&str, &str, i32)) {
        let (u, v, weight) = edge;

        // 1. Ensure both nodes exist in the graph (using the trait's add_node implementation)
        self.add_node(u);
        self.add_node(v);

        // 2. Add edge u -> v
        if let Some(neighbours_u) = self.adjacency_table_mutable().get_mut(u) {
            // Store the edge: target node and weight
            neighbours_u.push((v.to_string(), weight));
        }

        // 3. Add edge v -> u (completing the undirected link)
        if u != v {
            // Avoid adding duplicate self-loop entry
            if let Some(neighbours_v) = self.adjacency_table_mutable().get_mut(v) {
                neighbours_v.push((u.to_string(), weight));
            }
        }
    }
}
pub trait Graph {
    fn new() -> Self;
    fn adjacency_table_mutable(&mut self) -> &mut HashMap<String, Vec<(String, i32)>>;
    fn adjacency_table(&self) -> &HashMap<String, Vec<(String, i32)>>;
    fn add_node(&mut self, node: &str) -> bool {
        let table = self.adjacency_table_mutable();
        if table.contains_key(node) {
            false
        } else {
            // Insert the node with an empty list of neighbours
            table.insert(node.to_string(), Vec::new());
            true
        }
    }
    fn add_edge(&mut self, edge: (&str, &str, i32));
    fn contains(&self, node: &str) -> bool {
        self.adjacency_table().get(node).is_some()
    }
    fn nodes(&self) -> HashSet<&String> {
        self.adjacency_table().keys().collect()
    }
    fn edges(&self) -> Vec<(&String, &String, i32)> {
        let mut edges = Vec::new();
        for (from_node, from_node_neighbours) in self.adjacency_table() {
            for (to_node, weight) in from_node_neighbours {
                edges.push((from_node, to_node, *weight));
            }
        }
        edges
    }
}
#[cfg(test)]
mod test_undirected_graph {
    use super::Graph;
    use super::UndirectedGraph;
    #[test]
    fn test_add_edge() {
        let mut graph = UndirectedGraph::new();
        graph.add_edge(("a", "b", 5));
        graph.add_edge(("b", "c", 10));
        graph.add_edge(("c", "a", 7));
        let expected_edges = [
            (&String::from("a"), &String::from("b"), 5),
            (&String::from("b"), &String::from("a"), 5),
            (&String::from("c"), &String::from("a"), 7),
            (&String::from("a"), &String::from("c"), 7),
            (&String::from("b"), &String::from("c"), 10),
            (&String::from("c"), &String::from("b"), 10),
        ];
        for edge in expected_edges.iter() {
            assert_eq!(graph.edges().contains(edge), true);
        }
    }
}

```

这段 Rust 代码实现了一个基于邻接表的**无向带权图（Undirected Weighted Graph）**数据结构，并使用 **Trait**（特性）来定义图的标准接口。

### 1. 依赖和错误处理

- **`use std::collections::{HashMap, HashSet};`**: 引入了两个核心数据结构：
  - `HashMap`：用于构建图的邻接表，提供高效的节点查找。
  - `HashSet`：用于高效地存储和返回图中节点的集合。
- **`#[derive(Debug, Clone)] pub struct NodeNotInGraph;`**: 定义了一个自定义的错误类型。
  - 当用户尝试访问或操作一个不存在的节点时，可以使用这个类型来表示错误。
  - 它实现了 `fmt::Display`，使得在打印时能显示友好的错误信息：`"accessing a node that is not in the graph"`。

### 2. `UndirectedGraph` 结构体

这是图的具体数据结构，它只包含一个字段：

- **`adjacency_table: HashMap<String, Vec<(String, i32)>>`**:
  - 这是图的核心——**邻接表**。它使用 `HashMap` 来存储图的连接关系。
  - **键 (`String`)**: 表示图中的一个**节点名称**。
  - **值 (`Vec<(String, i32)>`)**: 是一个包含邻居和权重的**列表**。每个元组 `(String, i32)` 中，第一个 `String` 是邻居节点的名称，`i32` 是连接它们边的**权重**。

### 3. `Graph` 特性 (Trait)

`Graph` 特性定义了所有图实现（包括 `UndirectedGraph`）必须具备的**标准操作**，这增强了代码的通用性和可扩展性。

| **方法**                  | **签名**                                          | **作用**                                                     | **默认实现**                                                |
| ------------------------- | ------------------------------------------------- | ------------------------------------------------------------ | ----------------------------------------------------------- |
| `new`                     | `fn new() -> Self`                                | **构造函数**：创建一个新的空图实例。                         | 无                                                          |
| `adjacency_table_mutable` | `&mut HashMap<String, Vec<(String, i32)>>`        | 获取对邻接表的**可变引用**，允许修改图结构。                 | 无                                                          |
| `adjacency_table`         | `&HashMap<String, Vec<(String, i32)>>`            | 获取对邻接表的**不可变引用**，用于读取数据。                 | 无                                                          |
| `add_node`                | `fn add_node(&mut self, node: &str) -> bool`      | **添加节点**：检查节点是否存在，如果不存在，则将其插入邻接表，并关联一个空的邻居列表。返回 `true` 表示添加成功，`false` 表示节点已存在。 | **有**（默认实现）                                          |
| `add_edge`                | `fn add_edge(&mut self, edge: (&str, &str, i32))` | **添加边**：在两个节点之间添加一条带权重的边。               | 无                                                          |
| `contains`                | `fn contains(&self, node: &str) -> bool`          | 检查图中是否包含指定名称的节点。                             | **有**（通过 `adjacency_table().get(node).is_some()` 实现） |
| `nodes`                   | `fn nodes(&self) -> HashSet<&String>`             | 返回一个包含图中所有节点名称（键）的 `HashSet`。             | **有**（通过邻接表的 `keys()` 迭代器实现）                  |
| `edges`                   | `fn edges(&self) -> Vec<(&String, &String, i32)>` | **返回所有边**：遍历邻接表，将所有边以 `(&from_node, &to_node, weight)` 元组列表的形式返回。 | **有**                                                      |

### 4. `UndirectedGraph` 的实现 (`impl Graph for UndirectedGraph`)

这是无向图特有的**关键实现逻辑**：

- **`fn add_edge(&mut self, edge: (&str, &str, i32))`**:
  1. `self.add_node(u); self.add_node(v);`: **自动添加节点**。在添加边之前，确保边的两个端点 `u` 和 `v` 都已存在于图中（利用了 `Graph` trait 中的 `add_node` 默认实现）。
  2. **添加 $u \to v$ 的边**: 将 `(v.to_string(), weight)` 加入到节点 `u` 的邻居列表。
  3. **添加 $v \to u$ 的边（无向性）**: **关键步骤**。如果 $u \neq v$（防止自环被重复添加），则将 `(u.to_string(), weight)` 加入到节点 `v` 的邻居列表。**正是这个双向添加的操作，使得这个图成为了一个无向图。**

### 5. 测试模块 (`#[cfg(test)] mod test_undirected_graph`)

测试模块确保了 `UndirectedGraph` 的 `add_edge` 方法能够正确工作。

- **`#[test] fn test_add_edge()`**:
  1. **初始化**: `let mut graph = UndirectedGraph::new();` 创建一个空的无向图实例。
  2. **添加边**: 依次添加三条边：`("a", "b", 5)`，`("b", "c", 10)`，`("c", "a", 7)`。
  3. **期望结果**: 定义了一个 `expected_edges` 数组。由于这是一个**无向图**，添加一条边 `(u, v, w)` 必须产生两条记录（边），一条是 $u \to v$，另一条是 $v \to u$。因此，添加 3 条逻辑边会产生 6 条记录：
     - `(a, b, 5)` $\to$ `(a, b, 5)` 和 `(b, a, 5)`
     - `(b, c, 10)` $\to$ `(b, c, 10)` 和 `(c, b, 10)`
     - `(c, a, 7)` $\to$ `(c, a, 7)` 和 `(a, c, 7)`
  4. **断言**: 遍历 `expected_edges` 中的每一条期望边，通过 `assert_eq!(graph.edges().contains(edge), true);` 来断言（检查）图的 `edges()` 方法返回的边列表中是否包含了这条期望的边。这证明了图的添加和存储逻辑是正确的。

## 🌟 总结

本文深入解析了使用 Rust 实现一个无向带权图 (`UndirectedGraph`) 的完整过程。我们利用 **Trait** 抽象了图的基本操作，使得代码结构清晰且易于扩展；通过 **HashMap** 实现了高效的邻接表存储，确保了节点和边的快速存取；并重点解析了 `add_edge` 方法中**双向插入**的逻辑，这是实现无向图的关键。

这段代码不仅是图数据结构的一个优秀范例，也充分展示了 Rust 在设计复杂系统时，如何利用其类型系统和特性机制来构建安全、模块化且高性能的数据结构。掌握这段实战代码，您就具备了在 Rust 生态中处理复杂网络关系的基础能力。

## 参考

- <https://course.rs/about-book.html>
- <https://github.com/rust-lang>
- <https://github.com/rust-boom/rust-boom>
