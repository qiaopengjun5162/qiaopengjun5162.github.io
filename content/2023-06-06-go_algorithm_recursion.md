+++
title = "算法 in Golang：Recursion（递归）"
date = 2023-06-06T17:56:28+08:00
description = "算法 in Golang：Recursion（递归）"
[taxonomies]
tags = ["Go", "算法"]
categories = ["Go","算法"]
+++

# 算法 in Golang：Recursion（递归）

## 递归算法

### 场景：在套娃中找到宝石

### 可以这样做

- while 没找到：
  - if 当前项 is 宝石：
    - return 宝石
  - else if 当前项 is 套娃：
    - 打开这个套娃
    - if 当前项 is 宝石：
      - return 宝石
    - else if 当前项 is 套娃：
      - 打开这个套娃
      - if 当前项 is 宝石：
        - ... ...

### 递归

- 打开套娃
  - 找到的是宝石，结束
  - 得到的是一个套娃（重复操作，再次打开套娃，进行判断...）

### 递归术语解释

- 递归 Recursion
  - 基线条件 Base Case
  - 递归条件 Recursive Case

### 创建递归算法项目文件夹，并初始化用VSCode打开

```bash
~/Code/go via 🐹 v1.20.3 via 🅒 base
➜ mcd recursion_demo

Code/go/recursion_demo via 🐹 v1.20.3 via 🅒 base
➜ go mod init recursion_demo
go: creating new go.mod: module recursion_demo

Code/go/recursion_demo via 🐹 v1.20.3 via 🅒 base
➜ c

Code/go/recursion_demo via 🐹 v1.20.3 via 🅒 base
➜
```

代码：

```go
package main

import "fmt"

func main() {
 doll := Item{
  ID:   1,
  Type: "doll",
  Child: &Item{
   ID:   2,
   Type: "doll",
   Child: &Item{
    ID:   3,
    Type: "doll",
    Child: &Item{
     ID:    4,
     Type:  "diamond",
     Child: nil,
    },
   },
  },
 }
 diamond := findDiamond(doll)
 fmt.Printf("Item %d is diamond\n", diamond.ID)
}

func findDiamond(item Item) Item {
 if item.IsDoll() {
  return findDiamond(*item.Child)
 } else {
  return item
 }
}

type Item struct {
 ID    int
 Type  string
 Child *Item
}

type ItemClassifier interface {
 IsDoll() bool
}

func (it *Item) IsDoll() bool {
 if it.Type == "doll" {
  return true
 }
 return false
}

```

运行

```bash

Code/go/recursion_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run .                  
Item 4 is diamond

Code/go/recursion_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

优化

```go
package main

import "fmt"

func main() {
 doll := Item{
  ID:   1,
  Type: "doll",
  Child: &Item{
   ID:   2,
   Type: "doll",
   Child: &Item{
    ID:   3,
    Type: "doll",
    Child: &Item{
     ID:    4,
     Type:  "diamond",
     Child: nil,
    },
   },
  },
 }
 diamond := findDiamond(doll)
 fmt.Printf("Item %d is diamond\n", diamond.ID)
}

func findDiamond(item Item) Item {
 if item.IsDoll() {
  return findDiamond(*item.Child)
 } else {
  return item
 }
}

type Item struct {
 ID    int
 Type  string
 Child *Item
}

type ItemClassifier interface {
 IsDoll() bool
}

func (it *Item) IsDoll() bool {
 return it.Type == "doll"
}

```

### vscode ChatGPT优化解释

这段代码的主要功能是查找一个嵌套的Item结构体中的钻石，并输出其ID。优化的话可以考虑以下几点：

1. 可以将嵌套的Item结构体改为一个数组或切片，这样可以更方便地遍历和查找其中的元素。
2. 可以使用递归函数来查找钻石，但是需要注意避免出现无限递归的情况。
3. 可以将Item结构体中的Child字段改为一个指向父节点的指针，这样可以更方便地遍历整个结构体。
4. 可以将Item结构体实现IsDiamond()方法，这样可以更方便地判断一个Item是否为钻石。
5. 可以将ItemClassifier接口改为一个IsDiamond()方法，这样可以更方便地判断一个Item是否为钻石。

### ChatGPT 优化

下面是优化后的代码：

```go
package main

import "fmt"

func main() {
 doll := createItemChain()
 diamond := findDiamond(doll)
 fmt.Printf("Item %d is diamond\n", diamond.ID)
}

func createItemChain() *Item {
 doll := &Item{
  ID:   1,
  Type: "doll",
 }
 doll.Child = &Item{
  ID:   2,
  Type: "doll",
 }
 doll.Child.Child = &Item{
  ID:   3,
  Type: "doll",
 }
 doll.Child.Child.Child = &Item{
  ID:    4,
  Type:  "diamond",
 }
 return doll
}

func findDiamond(item *Item) *Item {
 if item.IsDoll() {
  return findDiamond(item.Child)
 }
 return item
}

type Item struct {
 ID    int
 Type  string
 Child *Item
}

func (it *Item) IsDoll() bool {
 return it.Type == "doll"
}
```

优化说明：

1. 将 **findDiamond** 函数的参数和返回值改为 ***Item** 类型，以便避免不必要的内存拷贝。
2. 将创建 `Item` 链的代码提取到一个单独的函数 `createItemChain` 中，使代码更清晰。
3. 在 `createItemChain` 函数中使用指针来创建 `Item` 对象，以避免在函数间传递大量的数据。
4. 修改 `findDiamond` 函数，使其接受 `*Item` 参数，以避免在递归调用时进行不必要的解引用。
5. 修改 `findDiamond` 函数的递归调用，将 `item.Child` 直接传递给 `findDiamond`，而不是解引用再传递。
6. 将 `ItemClassifier` 接口的定义移除，因为在当前代码中没有使用到它。
