+++
title = "算法 in Golang：Selection sort（选择排序）"
date = 2023-06-05T23:24:35+08:00
description = "算法 in Golang：Selection sort（选择排序）"
[taxonomies]
tags = ["Go", "算法"]
categories = ["Go","算法"]
+++

# 算法 in Golang：Selection sort（选择排序）

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
