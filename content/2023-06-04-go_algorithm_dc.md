+++
title = "算法 in Golang：D & C（分而治之）"
date = 2023-06-04T23:01:19+08:00
description = "算法 in Golang：D & C（分而治之）"
[taxonomies]
tags = ["Go", "算法"]
categories = ["Go","算法"]
+++

# 算法 in Golang：D & C（分而治之）

### D & C 算法（策略）

- Divide & Conquer
- 属于递归算法的一种
- 其实它更像是一种思路、策略

### 递归

- 递归 Recursion
  - 基线条件 Base Case
  - 递归条件 Recursive Case

### D & C 的步骤

1. 找到一个简单的基线条件（Base Case）
2. 把问题分开处理，直到它变为基线条件

### 例子

- 需求：将数组 [1, 3, 5, 7, 9] 求和
- 思路1：使用循环（例如 for 循环）
- 思路2：D & C （分而治之）

### 例子：D & C 策略

- 基线条件：空数组 []，其和为0
- 递归：[1, 3, 5, 7, 9]
  - 1 + SUM([3, 5, 7, 9])
    - 3 + SUM([5, 7, 9])
      - 5 + SUM([7, 9])
        - 7 + SUM([9])
          - 9 + SUM([])

### 创建项目并用vscode 打开

```bash
~/Code/go via 🐹 v1.20.3 via 🅒 base
➜ mcd divide_conquer

Code/go/divide_conquer via 🐹 v1.20.3 via 🅒 base
➜ go mod init divide_conquer
go: creating new go.mod: module divide_conquer

Code/go/divide_conquer via 🐹 v1.20.3 via 🅒 base
➜ c

Code/go/divide_conquer via 🐹 v1.20.3 via 🅒 base
➜

```

### main.go 代码

```go
package main

import "fmt"

func main() {
 total := sum([]int{1, 3, 5, 7, 9})
 fmt.Println("total: ", total)
}

func sum(arr []int) int {
 if len(arr) == 0 {
  return 0
 }
 return arr[0] + sum(arr[1:])
}

```

### 运行

```bash
Code/go/divide_conquer via 🐹 v1.20.3 via 🅒 base 
➜ go run .                  
total:  25

Code/go/divide_conquer via 🐹 v1.20.3 via 🅒 base 
➜ 


```
