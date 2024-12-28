+++
title = "算法 in Golang：Quicksort（快速排序）"
date = 2023-06-06T21:34:06+08:00
description = "算法 in Golang：Quicksort（快速排序）"
[taxonomies]
tags = ["Go", "算法"]
categories = ["Go","算法"]
+++

# 算法 in Golang：Quicksort（快速排序）

## Quicksort（快速排序）

- 快速排序 O(nlog2^n)，比选择排序要快 O(n²)
- 在日常生活中经常使用
- 使用了 D & C 策略（分而治之）

## 使用 Quicksort 排序数组

- 不需要排序的数组（也就是 Base Case 基线条件）：
  - []，空数组
  - [s]，单元素数组
- 很容易排序的数组：
  - [a, b]，两个元素的数组，只需检查它们之间的大小即可，调换位置
- 3 个元素的数组（例如 [23, 19, 35]）：
  - 使用 D & C 策略，简化至基线条件（Base case）

1. 从数组中随便选一个元素，例如 35，这个元素叫做 pivot（基准元素）

2. 找到比 pivot 小的元素，找到比 pivot 大的元素，这叫做分区：[23, 19], (35), []

3. 如果左右两个子数组已排好序（达到基线条件），结果：左边 + [pivot] + 右边

4. 如果左右两个子数组没排好序（没达到基线条件），那么：

   quicksort(左边) + [pivot] + quicksort(右边)

## 使用 Quicksort 排序数组的步骤

1. 选择一个 pivot
2. 将数组分为两个子数组：
   1. 左侧数组的元素都比 pivot 小
   2. 右侧数组的元素都比 pivot 大
3. 在两个子数组上递归的调用 quicksort

### 创建项目

```bash
~/Code/go via 🐹 v1.20.3 via 🅒 base
➜ mcd quicksort

Code/go/quicksort via 🐹 v1.20.3 via 🅒 base
➜ go mod init quicksort
go: creating new go.mod: module quicksort

Code/go/quicksort via 🐹 v1.20.3 via 🅒 base
➜ c

Code/go/quicksort via 🐹 v1.20.3 via 🅒 base
➜

```

### main.go 代码

```go
package main

import "fmt"

func main() {
 arr := []int{12, 87, 1, 66, 30, 126, 328, 12, 653, 67, 98, 3, 256, 5, 1, 1, 99, 109, 17, 70, 4}
 result := quicksort(arr)
 fmt.Println("result: ", result)
}

func quicksort(arr []int) []int {
 if len(arr) < 2 {
  return arr
 }

 pivot := arr[0]
 var left, right []int

 for _, ele := range arr[1:] {
  if ele <= pivot {
   left = append(left, ele)
  } else {
   right = append(right, ele)
  }
 }
 return append(quicksort(left), append([]int{pivot}, quicksort(right)...)...)
}

```

### 运行

```bash
Code/go/quicksort via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go       
result:  [1 1 1 3 4 5 12 12 17 30 66 67 70 87 98 99 109 126 256 328 653]

Code/go/quicksort via 🐹 v1.20.3 via 🅒 base took 3.2s 
➜ 

```
