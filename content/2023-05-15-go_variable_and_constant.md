+++
title = "Go语言之变量和常量"
date = 2023-05-15T11:19:39+08:00
description = "Go 语言变量和常量"
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# 变量和常量

## 标识符与关键字

### 标识符

在编程语言中标识符就是程序员定义的具有特殊意义的词，比如变量名、常量名、函数名等等。 Go语言中标识符由字母数字和`_`(下划线）组成，并且只能以字母和`_`开头。 举几个例子：`abc`, `_`, `_123`, `a123`。

### 关键字

关键字是指编程语言中预先定义好的具有特殊含义的标识符。 关键字和保留字都不建议用作变量名。

Go语言中有25个关键字：

```go
    break        default      func         interface    select
    case         defer        go           map          struct
    chan         else         goto         package      switch
    const        fallthrough  if           range        type
    continue     for          import       return       var
```

此外，Go语言中还有37个保留字。

```go
    Constants:    true  false  iota  nil

        Types:    int  int8  int16  int32  int64  
                  uint  uint8  uint16  uint32  uint64  uintptr
                  float32  float64  complex128  complex64
                  bool  byte  rune  string  error

    Functions:   make  len  cap  new  append  copy  close  delete
                 complex  real  imag
                 panic  recover
```

变量（Variable）的功能是存储数据。

常见变量的数据类型有：整型、浮点型、布尔型等。

Go语言中的每一个变量都有自己的类型，并且变量必须经过声明才能开始使用。

Go语言中的变量必须先声明再使用

Go语言中的变量需要声明后才能使用，同一作用域内不支持重复声明。 并且Go语言的变量声明后必须使用。

## 声明变量

### 标准声明

Go语言的变量声明格式为：

```go
var 变量名 变量类型
```

变量声明以关键字`var`开头，变量类型放在变量的后面，行尾无需分号。 举个例子：

```go
var name string
var age int
var isOk bool
```

### 批量声明

每声明一个变量就需要写`var`关键字会比较繁琐，go语言中还支持批量变量声明：

```go
var (
    a string
    b int
    c bool
    d float32
)
```

### 变量的初始化

Go语言在声明变量的时候，会自动对变量对应的内存区域进行初始化操作。每个变量会被初始化成其类型的默认值，例如： 整型和浮点型变量的默认值为`0`。 字符串变量的默认值为`空字符串`。 布尔型变量默认为`false`。 切片、函数、指针变量的默认为`nil`。

```go
var 变量名 类型 = 表达式
```

#### 类型推导

```go
var name = "Q1mi"
var age = 18
```

#### 匿名变量

在使用多重赋值时，如果想要忽略某个值，可以使用`匿名变量（anonymous variable）`。 匿名变量用一个下划线`_`表示，例如：

```go
func foo() (int, string) {
 return 10, "Q1mi"
}
func main() {
 x, _ := foo()
 _, y := foo()
 fmt.Println("x=", x)
 fmt.Println("y=", y)
}
```

匿名变量不占用命名空间，不会分配内存，所以匿名变量之间不存在重复声明。 (在`Lua`等编程语言里，匿名变量也被叫做哑元变量。)

注意事项：

1. 函数外的每个语句都必须以关键字开始（var、const、func等）
2. `:=`不能使用在函数外。
3. `_`多用于占位，表示忽略值。

代码：

```go
package main

import "fmt"

// Go语言中推荐使用驼峰式命名

var student_name string
var studentName string  // 推荐小驼峰
var StudentName string

// go fmt main.go 格式化 main.go
// 声明变量
// var name string
// var age int
// var isOk bool

// 批量声明
var (
 name string
 age int
 isOk bool
)

func main(){
 name = "理想"
 age = 16
 isOk = true
 // Go语言中非全局变量声明必须使用，不使用就编译不过去
 fmt.Print(isOk) // 在终端中输出要打印的内容
 fmt.Println()
 fmt.Printf("name:%s\n",name) // %s:占位符 使用name这个变量的值去替换占位符
 fmt.Println(age) // 打印完指定的内容之后会在后面加一个换行符
 
 // 声明变量同时赋值
 var s1 string = "whb"
 fmt.Println(s1)
 // 类型推导（根据值判断该变量是什么类型）
 var s2 = "20"
 fmt.Println(s2)
 // 简短变量声明 只能在函数里面使用
 s3 := "哈哈"
 fmt.Println(s3)
 // s1 := "10" // 同一个作用域（{}）中不能重复声明同名的变量
 // 匿名变量是一个特殊的变量：_
}
```

## 常量

常量是程序运行中恒定不变的量

常量的声明和变量声明非常类似，只是把`var`换成了`const`，常量在定义的时候必须赋值。

const同时声明多个常量时，如果省略了值则表示和上面一行的值相同。

`iota`是go语言的常量计数器，只能在常量的表达式中使用。

`iota`在const关键字出现时将被重置为0。const中每新增一行常量声明将使`iota`计数一次(iota可理解为const语句块中的行索引)。 使用iota能简化定义，在定义枚举时很有用。

```go
package main

import "fmt"

// 常量
// 定义了常量之后不能修改
// 在程序运行期间不会改变的值
const pi = 3.1415926

const (
 statusOk = 200
 notFound = 404
)

// 批量声明常量时，如果某一行声明后没有赋值，默认就和上一行一致
const(
 n1 = 100
 n2
 n3
)

// iota 类似枚举
const (
 a1 = iota // 0
 a2 // 1
 a3 // 2
)

const(
 b1 = iota // 0
 b2       // 1
 _       // 2
 b3     // 3
)

// 插队
const (
 c1 = iota    // 0
 c2 = 100    // 100
 c3 = iota  // 2
 c4        // 3
)

// 多个常量声明在一行
const(
 d1, d2 = iota + 1, iota + 2 // d1:1 d2:2
 d3, d4 = iota + 1, iota + 2 // d3:2 d4:3
)

// 定义数量级
const (
  _  = iota
  KB = 1 << (10 * iota)
  MB = 1 << (10 * iota)
  GB = 1 << (10 * iota)
  TB = 1 << (10 * iota)
  PB = 1 << (10 * iota)
 )

func main(){
 // pi = 123
 fmt.Println("n1:", n1)
 fmt.Println("n2:", n2)
 fmt.Println("n3:", n3)

 fmt.Println("a1:", a1)
 fmt.Println("a2:", a2)
 fmt.Println("a3:", a3)

 fmt.Println("b1:", b1)
 fmt.Println("b2:", b2)
 fmt.Println("b3:", b3)

 fmt.Println("c1:", c1)
 fmt.Println("c2:", c2)
 fmt.Println("c3:", c3)
 fmt.Println("c4:", c4)

 fmt.Println("d1:", d1)
 fmt.Println("d2:", d2)
 fmt.Println("d3:", d3)
 fmt.Println("d4:", d4)
}
```
