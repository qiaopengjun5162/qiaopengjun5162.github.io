+++
title = "算法 in Golang：Breadth-first search（BFS、广度优先搜索）"
date = 2023-06-06T22:14:35+08:00
description = "算法 in Golang：Breadth-first search（BFS、广度优先搜索）"
[taxonomies]
tags = ["Go", "算法"]
categories = ["Go","算法"]
+++

# 算法 in Golang：Breadth-first search

# （BFS、广度优先搜索）

## 最短路径问题 Shortest-path problem

- 从 A 到 F 点有多条路径

## 解决问题的算法 Breadth-first Search（广度优先搜索）

1. 将问题建模为图（Graph）
2. 通过 Breadth-first Search 算法来解决问题

## 图（Graph）是什么？

图是用来对不同事物间如何关联进行建模的一种方式

图是一种数据结构

## Breadth-first Search（BFS）广度优先搜索算法

1. 作用于图（Graph）
2. 能够回答两类问题：
   1. 是否能够从节点 A 到节点 B？
   2. 从 A 到 B 的最短路径是什么？

## 以社交网络为例

- 直接添加的朋友
  - 朋友的朋友...
  - 第一层没找到再找第二层

## 数据结构 Queue

- 先进来的数据先处理（FIFO）先进先出原则
- 无法随机的访问 Queue 里面的元素
- 相关操作：
  - enqueue：添加元素
  - dequeue：移除元素

## 例子

找到名为 Tom 的朋友

1. 把你所有的朋友都加到 Queue 里面
2. 把 Queue 里面第一个人找出来
3. 看他是不是 Tom
   1. 是 结束任务
   2. 否 把他所有的朋友加到 Queue  重复操作

### 创建项目

```bash
~/Code/go via 🐹 v1.20.3 via 🅒 base
➜ mcd breadth_first_search

Code/go/breadth_first_search via 🐹 v1.20.3 via 🅒 base
➜ go mod init breadth_first_search
go: creating new go.mod: module breadth_first_search

Code/go/breadth_first_search via 🐹 v1.20.3 via 🅒 base
➜ c

Code/go/breadth_first_search via 🐹 v1.20.3 via 🅒 base
➜
```

### main.go 代码

```go
package main

import "fmt"

type GraphMap map[string][]string

func main() {
 var graphMap GraphMap = make(GraphMap, 0)
 graphMap["you"] = []string{"alice", "bob", "claire"}
 graphMap["bob"] = []string{"anuj", "peggy"}
 graphMap["alice"] = []string{"peggy"}
 graphMap["claire"] = []string{"tom", "johnny"}
 graphMap["anuj"] = []string{}
 graphMap["peggy"] = []string{}
 graphMap["tom"] = []string{}
 graphMap["johnny"] = []string{}

 search_queue := graphMap["you"]

 for {
  if len(search_queue) > 0 {
   var person string
   person, search_queue = search_queue[0], search_queue[1:]
   if personIsTom(person) {
    fmt.Printf("%s is already in the queue for you.\n", person)
    break
   } else {
    search_queue = append(search_queue, graphMap[person]...)
   }
  } else {
   fmt.Println("Not found in search queue")
   break
  }
 }
}

func personIsTom(p string) bool {
 return p == "tom"
}

```

### 运行

```bash
Code/go/breadth_first_search via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
tom is already in the queue for you.

Code/go/breadth_first_search via 🐹 v1.20.3 via 🅒 base took 3.2s 
➜ 
```
