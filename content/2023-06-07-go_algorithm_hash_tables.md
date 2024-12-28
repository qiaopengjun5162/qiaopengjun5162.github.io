+++
title = "数据结构 in Golang：Hash Tables（哈希表）"
date = 2023-06-07T21:28:47+08:00
description = "数据结构 in Golang：Hash Tables（哈希表）"
[taxonomies]
tags = ["Go", "算法"]
categories = ["Go","算法"]
+++

# 数据结构 in Golang：Hash Tables（哈希表）

### 场景

- 水果店的价格表：
  - 苹果 Apple：3元
  - 香蕉 Banana：4元
  - 桃子 Peach：2元
  - 梨 Pear：3元
- 找到一种水果的价格：
  - 可以使用 binary search，通过名称来查找，耗时：O(logn)
  - 如何只耗时 O(1) 来找到价格呢？

### Hash 函数

- Hash 函数：通过一个字符串 -> 一个数值
- 例如：
  - "Apple"  ->  1
  - "Banana"  -> 2
  - "Peach"  ->  7
  - "Pear"  -> 8
- 将字符串映射为数值

### Hash 函数的要求

- 一致性
- 将不同的字符串映射为不同的数值

### Hash 函数有什么用？

方便 快捷的得到自己想要的值...

### Hash Table

- Hash 函数 + 数组 = Hash Table
- 数组直接映射到内存
- Hash Table 具有额外的逻辑，它使用 Hash 函数智能的找到存放元素的位置
- 在 Go 语言中叫 Map

```go
package main

func main() {
  dict := make(map[string]int)
  dict1 := map[string]int{"Apple": 3, "Orange": 4}
}
```

- 其它语言中：Dictionary、Map、Hash Map......

### 使用场景

- 电话簿
- DNS 解析
- 缓存

### 冲突

- 冲突就是：两个 Key 被安排到了同一个位置
- 也就是说：K1 != K2，但 H(K1) == H(K2)

### 解决冲突

- 开放地址法、再 Hash 法、建立公共溢出区 ...
- 链地址法：链表

### 注意

- Hash 函数应尽可能的将 Key 平均的映射
- 如果链表过长，会让 Hash Table 变得很慢

### 选择 Hash 函数

|      | Hash Table 平均 | Hash Table 最坏 | 数组 | 链表 |
| ---- | --------------- | --------------- | ---- | ---- |
| 查找 | O(1)            | O(n)            | O(1) | O(n) |

### 避免冲突

- 装载因子（load factor）要低
- 一个好的 Hash 函数

### 装载因子（load factor）

- 调整大小，Resize
  - 例如：load factor 为 75% 的时候，就可以调整大小，通常是原来大小的两倍
  - 注意：调整大小也会花费很多时间

### 选择好的 Hash 函数

- 好的 Hash 函数会将值尽可能的平均分布在数组中
- 不好的 Hash 函数经常会把值聚集，并产生很多冲突
- 通常不需要自己编写 Hash 函数，可以了解 SHA 函数
