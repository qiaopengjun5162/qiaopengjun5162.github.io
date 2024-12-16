+++
title = "使用 Go 实现选择排序：详解算法原理与代码实践"
date = "2024-12-16"
description = "选择排序是一种简单的排序算法，通过多次遍历数组找到最小元素，并将其放置在当前排序位置，从而逐步构建一个有序数组。其时间复杂度为 O(n^2)，适用于小规模数据的排序需求。本文详细讲解了选择排序的实现过程，并使用 Go 语言代码进行了示例化，帮助读者掌握这一算法的基本原理和实际应用。"
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# 使用 Go 实现选择排序：详解算法原理与代码实践

排序算法是计算机科学中的基础内容，广泛应用于数据处理与优化中。本文将聚焦于一种经典排序算法——选择排序，介绍其原理、复杂度，并用 Go 语言完整实现该算法。通过学习选择排序，你将更好地理解排序算法的基础知识和实践技巧。

选择排序是一种简单的排序算法，通过多次遍历数组找到最小元素，并将其放置在当前排序位置，从而逐步构建一个有序数组。其时间复杂度为 O(n^2)，适用于小规模数据的排序需求。本文详细讲解了选择排序的实现过程，并使用 Go 语言代码进行了示例化，帮助读者掌握这一算法的基本原理和实际应用。

算法 in Golang：Selection sort（选择排序）

## Selection Sort（选择排序）

假设有一个数组，它里面有6个元素，它的顺序是乱的，现在我们想对这个数组进行排序，就是从小到大进行排序。

选择排序是挨个遍历元素，把最小的放在最前面，再把剩余的遍历，把最小的放在后面，依此类推，最终就会得到一个从小到大排序好的数组。

### 复杂度：O(n²)

- O(n²)：相当于是 n 次 O(n)
- 其实是 n, n-1, n-2, n-3, n-4, n-5
- 为什么不是 O(1/2n²)
- 大 O 标记法忽略了常数系统 1/2

### 创建文件

```bash
~/Code/go via 🐹 v1.20.3 via 🅒 base
➜ mcd selectionSort

Code/go/selectionSort via 🐹 v1.20.3 via 🅒 base
➜ go mod init selectionSort
go: creating new go.mod: module selectionSort

Code/go/selectionSort via 🐹 v1.20.3 via 🅒 base
➜ c

Code/go/selectionSort via 🐹 v1.20.3 via 🅒 base
➜
```

### 算法实现

```go
package main

import "fmt"

func main() {
 arr := []int{5, 7, 1, 8, 3, 2, 6, 4, 9}
 arr = selectiongSort(arr)

 fmt.Println("arr: ", arr)
}

func findSmallest(arr []int) int {
 smallest := arr[0]
 smallest_index := 0
 for i := 0; i < len(arr); i++ {
  if arr[i] < smallest {
   smallest = arr[i]
   smallest_index = i
  }
 }
 return smallest_index
}

func selectiongSort(arr []int) []int {
 result := []int{}
 count := len(arr)
 for i := 0; i < count; i++ {
  smallest_index := findSmallest(arr)
  result = append(result, arr[smallest_index])
  arr = append(arr[:smallest_index], arr[smallest_index+1:]...)
 }

 return result
}

```

### 运行

```bash
Code/go/selectionSort via 🐹 v1.20.3 via 🅒 base 
➜ go run .
arr:  [1 2 3 4 5 6 7 8 9]

Code/go/selectionSort via 🐹 v1.20.3 via 🅒 base 
➜ 
```

## 总结

通过本文的学习，我们实现了选择排序，并进一步理解了其工作原理和复杂度特性。尽管选择排序在性能上并不优于其他高级排序算法（如快速排序或归并排序），但其逻辑简单清晰，是学习排序算法的绝佳起点。借助 Go 语言，我们不仅能够直观地感受算法的执行过程，还能通过实际操作强化对算法基本概念的理解。希望本文能够为你的算法学习之旅提供实用的参考和启发。
