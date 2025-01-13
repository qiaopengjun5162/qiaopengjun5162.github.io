+++
title = "Go语言（Golang）编写最简单的命令行工具"
date = 2023-05-07T21:59:51+08:00
description = "最简单的命令行工具"
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# 最简单的命令行工具

## 项目预览

```bash
>echo abc 123 --name=nick
abc 123 --name=nick
```

## 课程概述

- 如何制作命令行应用
- 如何使用 os.Args 获得命令行参数

## 前提条件

- 懂得 Go 语言基本语法

## 知识点

- OS 包提供了用于处理操作系统相关内容的函数/值
  - 独立于平台的方式
- os.Args 变量
  - 获得命令行的参数
  - 它是 string slice
  - 第一个值是命令本身
- strings.Join 函数

## 实践

### 创建项目目录并在该目录下创建 main.go 文件

```bash
~/Code/go via 🐹 v1.20.3 via 🅒 base
➜ mcd echo # mkdir echo cd echo

Code/go/echo via 🐹 v1.20.3 via 🅒 base
➜ c # code . 

Code/go/echo via 🐹 v1.20.3 via 🅒 base took 2.4s
➜
```

main.go 文件

```go
package main

import (
 "fmt"
 "os"
)

func main() {
 var s, sep string
 // os.Args

 for i := 1; i < len(os.Args); i++ {
  s += sep + os.Args[i]
  sep = " "
 }

 fmt.Println(s)
}

```

运行

```bash

Code/go/echo via 🐹 v1.20.3 via 🅒 base 
➜ go build .         

Code/go/echo via 🐹 v1.20.3 via 🅒 base 
➜ ls
echo    main.go

Code/go/echo via 🐹 v1.20.3 via 🅒 base 
➜ echo                                                                    


Code/go/echo via 🐹 v1.20.3 via 🅒 base 
➜ echo 123                                                                
123

Code/go/echo via 🐹 v1.20.3 via 🅒 base 
➜ echo 123 abc ert
123 abc ert

Code/go/echo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

优化修改一

```go
package main

import (
 "fmt"
 "os"
)

func main() {
 // var s, sep string
 s, sep := "", ""
 // os.Args

 for _, arg := range os.Args[1:] {
  s += sep + arg
  sep = " "
 }

 // for i := 1; i < len(os.Args); i++ {
 //  s += sep + os.Args[i]
 //  sep = " "
 // }

 fmt.Println(s)
}

```

运行

```bash
Code/go/echo via 🐹 v1.20.3 via 🅒 base 
➜ go build . && echo 123 abc x=123ed
123 abc x=123ed

Code/go/echo via 🐹 v1.20.3 via 🅒 base 
➜ 

```

优化修改二

```go
package main

import (
 "fmt"
 "os"
 "strings"
)

func main() {
 // var s, sep string
 // s, sep := "", ""
 // os.Args

 // for _, arg := range os.Args[1:] {
 //  s += sep + arg
 //  sep = " "
 // }

 // for i := 1; i < len(os.Args); i++ {
 //  s += sep + os.Args[i]
 //  sep = " "
 // }

 // fmt.Println(s)

 fmt.Println(strings.Join(os.Args[1:], " "))
}

```

## 用户输入

- bufio.NewReader()

实践

```bash
~/Code/go via 🐹 v1.20.3 via 🅒 base
➜ mcd cli-demo

Code/go/cli-demo via 🐹 v1.20.3 via 🅒 base
➜ go mod init
go: cannot determine module path for source directory /Users/qiaopengjun/Code/go/cli-demo (outside GOPATH, module path must be specified)

Example usage:
 'go mod init example.com/m' to initialize a v0 or v1 module
 'go mod init example.com/m/v2' to initialize a v2 module

Run 'go help mod init' for more information.

Code/go/cli-demo via 🐹 v1.20.3 via 🅒 base
➜ go mod init cli-demo
go: creating new go.mod: module cli-demo

Code/go/cli-demo via 🐹 v1.20.3 via 🅒 base
➜ c

Code/go/cli-demo via 🐹 v1.20.3 via 🅒 base
➜

```

main.go 代码

```go
package main

import (
 "bufio"
 "fmt"
 "os"
)

func main() {
 fmt.Println("What's your name?")
 reader := bufio.NewReader(os.Stdin)
 text, _ := reader.ReadString('\n')
 fmt.Printf("Your name is: %s", text)
}

```

运行

```bash
Code/go/cli-demo via 🐹 v1.20.3 via 🅒 base took 5.9s 
➜ go run .      
What's your name?
dave
Your name is: dave

Code/go/cli-demo via 🐹 v1.20.3 via 🅒 base took 3.1s 
➜ go run main.go
What's your name?
xiaoqiao
Your name is: xiaoqiao

Code/go/cli-demo via 🐹 v1.20.3 via 🅒 base took 3.1s 
➜ 

```





