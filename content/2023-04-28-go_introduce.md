+++
title = "Go语言介绍"
date = 2023-04-28T09:28:57+08:00
description = "Go语言介绍"
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# Go语言介绍

## 一、Go语言介绍

#### 什么是go语言？

- Google开源
- 编译型语言
- 21世纪的C语言

#### 解释型语言与编译型语言的区别

#### go语言的特点

- 语法简洁
- 开发效率高
- 执行性能好

go语言真的很小众吗

Go语言真的没人用吗

Gopher China 2019盛况

百度、腾讯、知乎（使用Go语言重构）内部Go语言应用

#### Go语言发展现状（新公司的选择、新行业的选择）

#### Go语言发展前景

- 天生支持并发
- 项目转型首选语言
- 岗位机会多
- 21世纪的C语言
- 开发效率高
- 新领域首选语言
- 真正的企业级编程语言
- 薪资高
- 语法简单易学
- 执行性能好

语言只是一个工具，人用工具干活

#### 如何学习Go语言？

- 与其他编程语言对比学习
- 多写多写多写代码
- 在工作中使用Go语言
- 培养自主学习能力

坚持这两个字说起来总是很空，

但是真正做到的大多都能成功！

## 二、Go语言开发环境搭建

### 安装Go开发包

### 下载地址

Go官网下载地址：<https://golang.org/dl/>

Go官方镜像站（推荐）：<https://golang.google.cn/dl/>

打开终端窗口，输入`go version`命令，查看安装的Go版本

```bash
C:\Users\Thinkpad>go version
go version go1.17.6 windows/amd64

```

详细步骤：

1. 在自己的电脑上新建一个目录D:go(存放我编写的Go语言代码)
2. 在环境变量里，新建一项：GOPATH:D:\go
3. 在D:\go下新建三个文件夹，分别是：bin src pkg
4. 把D:\go\bin这个目录添加到PATH这个环境变量的后面
   1. Win7是英文的;分割
   2. Win10是单独一行
5. 你电脑上GOPATH应该是有默认值的，通常是%USERPROFILE%/go，你把这一项删掉，自己安装上面的步骤新建一个就可以了。

go env 查看Go相关的环境变量

Go目录结构

Go开发编辑器

下载并安装vscode

`VS Code`官方下载地址：<https://code.visualstudio.com/Download>

安装

下一步安装法

安装中文插件包

安装go扩展包

从零开始搭建GO语言开发环境

```go
package main

import "fmt"

func main()  {
 fmt.Println("Hello World!")
}



Microsoft Windows [版本 10.0.19043.1415]
(c) Microsoft Corporation。保留所有权利。

E:\go\src\hello>go build
go: go.mod file not found in current directory or any parent directory; see 'go help modules'

E:\go\src\hello>go env -w GO111MODULE=auto

E:\go\src\hello>go build

E:\go\src\hello>hello.exe
Hello World!

E:\go\src\hello>
```

### 编译 go build

使用go build

1. 在项目目录下执行 go build
2. 在其他路径下执行 go build ，需要在后面加上项目的路径（项目路径从GOPATH/src后开始写起，编译之后的可执行文件就保存在当前目录下）
3. go build - o hello.exe （Mac上不需要加exe）（编译之后的名字自定义）

### go run main.go

像执行脚本文件一样执行Go代码

### go install

go install 分为两步：

1. 先编译得到一个可执行文件
2. 将可执行文件拷贝到GOPATH/bin

```go
package main  // 声明 main 包，表明当前是一个可执行程序

import "fmt"  // 导入内置 fmt 包

func main(){  // main函数，是程序执行的入口
 fmt.Println("Hello World!")  // 在终端打印 Hello World!
}
```

### 交叉编译

Go支持跨平台编译

默认我们`go build`的可执行文件都是当前操作系统可执行的文件，Go语言支持跨平台编译——在当前平台（例如Windows）下编译其他平台（例如Linux）的可执行文件。

#### Windows编译Linux可执行文件

如果我想在Windows下编译一个Linux下可执行文件，那需要怎么做呢？只需要在编译时指定目标操作系统的平台和处理器架构即可。

> 注意：无论你在Windows电脑上使用VsCode编辑器还是Goland编辑器，都要注意你使用的终端类型，因为不同的终端下命令不一样！！！目前的Windows通常默认使用的是`PowerShell`终端。

如果你的`Windows`使用的是`cmd`，那么按如下方式指定环境变量。

```bash
SET CGO_ENABLED=0  // 禁用CGO
SET GOOS=linux  // 目标平台是linux
SET GOARCH=amd64  // 目标处理器架构是amd64
```

如果你的`Windows`使用的是`PowerShell`终端，那么设置环境变量的语法为

```bash
$ENV:CGO_ENABLED=0
$ENV:GOOS="linux"
$ENV:GOARCH="amd64"
```

在你的`Windows`终端下执行完上述命令后，再执行下面的命令，得到的就是能够在Linux平台运行的可执行文件了。

```bash
go build
```

#### Windows编译Mac可执行文件

Windows下编译Mac平台64位可执行程序：

cmd终端下执行：

```bash
SET CGO_ENABLED=0
SET GOOS=darwin
SET GOARCH=amd64
go build
```

PowerShell终端下执行：

```bash
$ENV:CGO_ENABLED=0
$ENV:GOOS="darwin"
$ENV:GOARCH="amd64"
go build
```

#### Mac编译Linux可执行文件

Mac电脑编译得到Linux平台64位可执行程序：

```bash
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build
```

#### Mac编译Windows可执行文件

Mac电脑编译得到Windows平台64位可执行程序：

```bash
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build
```

#### Linux编译Mac可执行文件

Linux平台下编译Mac平台64位可执行程序：

```bash
CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build
```

#### Linux编译Windows可执行文件

Linux平台下编译Windows平台64位可执行程序：

```bash
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build
```

### Go语言文件的基本结构

```go
package main

// 导入语句
import "fmt"

// 函数外只能放置标识符（变量、常量、函数、类型）的声明
// 程序的入口函数 main函数没有参数也没有返回值
func main(){
 fmt.Println("Hello world")
}
```

2
