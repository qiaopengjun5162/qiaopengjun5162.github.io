+++
title = "Go语言之基本数据类型"
date = 2023-05-17T09:20:25+08:00
description = "Go语言之基本数据类型"
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# 基本数据类型

## 整型

整型分为以下两个大类： 按长度分为：int8、int16、int32、int64 对应的无符号整型：uint8、uint16、uint32、uint64

其中，`uint8`就是我们熟知的`byte`型，`int16`对应C语言中的`short`型，`int64`对应C语言中的`long`型。

|  类型  |                             描述                             |
| :----: | :----------------------------------------------------------: |
| uint8  |                  无符号 8位整型 (0 到 255)                   |
| uint16 |                 无符号 16位整型 (0 到 65535)                 |
| uint32 |              无符号 32位整型 (0 到 4294967295)               |
| uint64 |         无符号 64位整型 (0 到 18446744073709551615)          |
|  int8  |                 有符号 8位整型 (-128 到 127)                 |
| int16  |              有符号 16位整型 (-32768 到 32767)               |
| int32  |         有符号 32位整型 (-2147483648 到 2147483647)          |
| int64  | 有符号 64位整型 (-9223372036854775808 到 9223372036854775807) |

### 特殊整型

|  类型   |                          描述                          |
| :-----: | :----------------------------------------------------: |
|  uint   | 32位操作系统上就是`uint32`，64位操作系统上就是`uint64` |
|   int   |  32位操作系统上就是`int32`，64位操作系统上就是`int64`  |
| uintptr |              无符号整型，用于存放一个指针              |

**注意：** 在使用`int`和 `uint`类型时，不能假定它是32位或64位的整型，而是考虑`int`和`uint`可能在不同平台上的差异。

**注意事项** 获取对象的长度的内建`len()`函数返回的长度可以根据不同平台的字节长度进行变化。实际使用中，切片或 map 的元素数量等都可以用`int`来表示。在涉及到二进制传输、读写文件的结构描述时，为了保持文件的结构不会受到不同编译目标平台字节长度的影响，不要使用`int`和 `uint`。

```go
package main

import "fmt"

// 整型

func main()  {
 var i1 = 101
 fmt.Printf("%d\n", i1)
 fmt.Printf("%b\n", i1) // 把十进制转换成二进制
 fmt.Printf("%o\n", i1) // 把十进制转换成八进制
 fmt.Printf("%x\n", i1) // 把十进制转换成十六进x
 // 八进制
 i2 := 077
 fmt.Printf("%d\n", i2)
 // 十六进制
 i3 := 0x1234567
 fmt.Printf("%d\n", i3)
 // 查看变量的类型
 fmt.Printf("%T\n", i3)
 // 声明int8类型的变量
 i4 := int8(9)  // 明确指定int8类型，否则默认int类型
 fmt.Printf("%T\n", i4)
}
```

## 浮点型

Go语言支持两种浮点型数：`float32`和`float64`。这两种浮点型数据格式遵循`IEEE 754`标准： `float32` 的浮点数的最大范围约为 `3.4e38`，可以使用常量定义：`math.MaxFloat32`。 `float64` 的浮点数的最大范围约为 `1.8e308`，可以使用一个常量定义：`math.MaxFloat64`。

```go
package main

import "fmt"


// 浮点数
func main(){
 // math.MaxFloat32 // float32最大值
 f1 := 1.23456
 fmt.Printf("%T\n", f1) // 默认Go语言中的小数都是float64类型
}


E:\go\src\github.com\qiaopengjun\day01\05float>go build

E:\go\src\github.com\qiaopengjun\day01\05float>05float.exe
float64


package main

import "fmt"

// 浮点数
func main(){
 // math.MaxFloat32 // float32最大值
 f1 := 1.23456
 fmt.Printf("%T\n", f1) // 默认Go语言中的小数都是float64类型
 f2 := float32(1.23456) 
 fmt.Printf("%T\n", f2) // 显示声明float32类型
 // f1 = f2 // float32类型的值不能直接赋值给float64类型的变量
}
```

## 复数

complex64和complex128

```go
var c1 complex64
c1 = 1 + 2i
var c2 complex128
c2 = 2 + 3i
fmt.Println(c1)
fmt.Println(c2)
```

复数有实部和虚部，complex64的实部和虚部为32位，complex128的实部和虚部为64位。

## 布尔值

Go语言中以`bool`类型进行声明布尔型数据，布尔型数据只有`true（真）`和`false（假）`两个值。

**注意：**

1. 布尔类型变量的默认值为`false`。
2. Go 语言中不允许将整型强制转换为布尔型.
3. 布尔型无法参与数值运算，也无法与其他类型进行转换。

```go
package main

import "fmt"

// 布尔类型

func main(){
 b1 := true
 var b2 bool // 默认是false
 fmt.Printf("%T value:%v\n", b1, b1)
 fmt.Printf("%T value:%v\n", b2, b2)
}


E:\go\src\github.com\qiaopengjun\day01\06bool>go build   

E:\go\src\github.com\qiaopengjun\day01\06bool>06bool.exe
bool value:true
bool value:false
```

#### fmt占位符

```go
package main

import "fmt"

// fmt占位符
func main(){
 var n = 100
 // 查看类型
 fmt.Printf("%T\n", n)
 fmt.Printf("%v\n", n)
 fmt.Printf("%b\n", n)
 fmt.Printf("%d\n", n)
 fmt.Printf("%o\n", n)
 fmt.Printf("%x\n", n)
 var s = "Hello 沙河！"
 fmt.Printf("字符串：%s\n", s)
 fmt.Printf("字符串：%v\n", s)
 fmt.Printf("字符串：%#v\n", s)

}


E:\go\src\github.com\qiaopengjun\day01\07fmt>go build

E:\go\src\github.com\qiaopengjun\day01\07fmt>07fmt.exe
int
100
1100100
100
144
64
Hello 沙河！
Hello 沙河！

E:\go\src\github.com\qiaopengjun\day01\07fmt>go build  

E:\go\src\github.com\qiaopengjun\day01\07fmt>07fmt.exe
int
100
1100100
100
144
64
字符串：Hello 中国！
字符串：Hello 中国！
字符串："Hello 中国！"

E:\go\src\github.com\qiaopengjun\day01\07fmt>
```

## 字符串

Go语言中的字符串以原生数据类型出现。 Go 语言里的字符串的内部实现使用`UTF-8`编码。 字符串的值为`双引号(")`中的内容，可以在Go语言的源码中直接添加非ASCII码字符

GO语言中字符串是用双引号包裹的

GO语言中单引号包裹的是字符

```go
// 字符串
s := "Hello 中国"
// 单独的字母、汉字、符合表示一个字符
c1 := 'h'
c2 := '1'
c3 := '中'
// 字节：1字节=8Bit(8个二进制位)
// 1个字符'A'=1个字节
// 1个utf8编码的汉字'中'= 一般占3个字节
```

### 字符串转义符

| 转义符 |                含义                |
| :----: | :--------------------------------: |
|  `\r`  |         回车符（返回行首）         |
|  `\n`  | 换行符（直接跳到下一行的同列位置） |
|  `\t`  |               制表符               |
|  `\'`  |               单引号               |
|  `\"`  |               双引号               |
|  `\\`  |               反斜杠               |

### 字符串的常用操作

|                方法                 |      介绍      |
| :---------------------------------: | :------------: |
|              len(str)               |     求长度     |
|           +或fmt.Sprintf            |   拼接字符串   |
|            strings.Split            |      分割      |
|          strings.contains           |  判断是否包含  |
| strings.HasPrefix,strings.HasSuffix | 前缀/后缀判断  |
| strings.Index(),strings.LastIndex() | 子串出现的位置 |
| strings.Join(a[]string, sep string) |    join操作    |

```go
package main

import (
 "fmt"
 "strings"
)

// 字符串

func main(){
 // \ 本来是具有特殊含义的，告诉程序\就是一个单纯的\
 path := "\"E:\\36期Python全栈开发资料\\Administrator(8E5370323193)\\预习(2)\""
 path1 := "'E:\\36期Python全栈开发资料\\Administrator(8E5370323193)\\预习(2)'"
 fmt.Println(path)
 fmt.Println(path1)

 s := "I'm ok"
 fmt.Println(s)

 // 多行的字符串
 s2 := `
 世情薄
 人情恶
 雨送黄昏花易落
 `
 fmt.Println(s2)
 s3 := `E:\36期Python全栈开发资料\Administrator(8E5370323193)\预习(2)`
 fmt.Println(s3)

 // 字符串相关操作
 fmt.Println(len(s3))

 // 字符串拼接
 name := "理想"
 world := "远大"
 ss := name + world
 fmt.Println(ss)
 ss1 := fmt.Sprintf("%s%s", name, world)
 // fmt.Printf("%s%s", name, world)
 fmt.Println(ss1)
 // 分割
 ret := strings.Split(s3, "\\")
 fmt.Println(ret)

 // 包含
 fmt.Println(strings.Contains(ss, "理想"))
 // 前缀
 fmt.Println(strings.HasPrefix(ss, "理想"))
 // 后缀
 fmt.Println(strings.HasSuffix(ss, "理想"))

 s4 := "abcded"
 fmt.Println(strings.Index(s4, "c"))
 fmt.Println(strings.LastIndex(s4, "c"))
 fmt.Println(strings.Index(s4, "d"))
 fmt.Println(strings.LastIndex(s4, "d"))
 // 拼接
 fmt.Println(strings.Join(ret, "+"))

}
```

## byte和rune类型

字符用单引号（’）包裹起来

Go 语言的字符有以下两种：

1. `uint8`类型，或者叫 byte 型，代表了`ASCII码`的一个字符。
2. `rune`类型，代表一个 `UTF-8字符`。rune`类型实际是一个`int32

字符串底层是一个byte数组，可以和`[]byte`类型相互转换。字符串是不能修改的 字符串是由byte字节组成，所以字符串的长度是byte字节的长度。 rune类型用来表示utf8字符，一个rune字符由一个或多个byte组成。

### 修改字符串

要修改字符串，需要先将其转换成`[]rune`或`[]byte`，完成后再转换为`string`。无论哪种转换，都会重新分配内存，并复制字节数组。

## 类型转换

强制类型转换的基本语法如下：

```bash
T(表达式)
```

其中，T表示要转换的类型。表达式包括变量、复杂算子和函数返回值等.

```go
package main

import (
 "fmt"
)

func main() {
 s := "Hello 中国"
 // len()求的是byte字节的数量
 n := len(s)
 fmt.Println(n)

 // for i := 0; i < len(s); i++ {
 //  fmt.Println(s[i])
 //  fmt.Printf("%c\n", s[i]) // %c：字符
 // }

 // 字符串修改
 s2 := "白萝卜" // [白 萝 卜]
 s3 := []rune(s2) // 把字符串强制转换成了一个rune切片
 s3[0] = '红' // 单引号表示字符
 fmt.Println(string(s3)) // 把rune切片强制转换成字符串

 c1 := "红"
 c2 := '红' // rune(int32)
 fmt.Printf("c1:%T c2:%T\n", c1, c2) // c1:string c2:int32
 c3 := "H"
 c4 := 'H'
 c5 := byte('H')
 fmt.Printf("c3:%T c4:%T\n", c3, c4) // c3:string c4:int32
 fmt.Printf("c4:%d\n", c4) // c4:72
 fmt.Printf("c5:%T\n", c5) // c5:uint8

 // 类型转换
 n1 := 10 // int
 var f float64
 f = float64(n1)
 fmt.Println(f)
 fmt.Printf("%T\n", f) // float64


}
```
