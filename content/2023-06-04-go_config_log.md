+++
title = "Go 语言如何配置 log"
date = 2023-06-04T21:44:43+08:00
description = "Go 语言如何配置 log"
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# Go 语言如何配置 log

## 一、日志三大类

### 创建项目并初始化用vscode 打开

```bash
~/Code/go via 🐹 v1.20.3 via 🅒 base
➜ mcd demo

Code/go/demo via 🐹 v1.20.3 via 🅒 base
➜ go mod init
go: cannot determine module path for source directory /Users/qiaopengjun/Code/go/demo (outside GOPATH, module path must be specified)

Example usage:
 'go mod init example.com/m' to initialize a v0 or v1 module
 'go mod init example.com/m/v2' to initialize a v2 module

Run 'go help mod init' for more information.

Code/go/demo via 🐹 v1.20.3 via 🅒 base
➜ go mod init demo  #  初始化当前文件夹, 创建go.mod文件
go: creating new go.mod: module demo

Code/go/demo via 🐹 v1.20.3 via 🅒 base
➜ c

Code/go/demo via 🐹 v1.20.3 via 🅒 base
➜
```

### main.go 文件

```go
package main

import "log"

func init() {

}

func main() {
 log.Println("1234")

 // log.Fatalln("1234")

 // log.Panicln("1234")
}

```

### 运行 log.Println

```bash
Code/go/demo via 🐹 v1.20.3 via 🅒 base 
➜ go run .        
2023/06/04 22:16:25 1234

Code/go/demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

### main.go 文件

```go
package main

import "log"

func init() {

}

func main() {
 // log.Println("1234")

 log.Fatalln("1234")

 // log.Panicln("1234")
}

```

### 运行 log.Fatalln

```bash

Code/go/demo via 🐹 v1.20.3 via 🅒 base 
➜ go run .
2023/06/04 22:17:45 1234
exit status 1

Code/go/demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

相当于

```go
package main

import (
 "log"
 "os"
)

func init() {

}

func main() {
 // log.Println("1234")

 log.Fatalln("1234")
 os.Exit(1)

 // log.Panicln("1234")
}

```

### main.go 文件

```go
package main

import (
 "log"
)

func init() {

}

func main() {
 // log.Println("1234")

 // log.Fatalln("1234")
 // os.Exit(1)

 log.Panicln("1234")
}

```

### 运行 log.Panicln

```bash
Code/go/demo via 🐹 v1.20.3 via 🅒 base 
➜ go run .
2023/06/04 22:20:42 1234
panic: 1234


goroutine 1 [running]:
log.Panicln({0x14000092f58?, 0x0?, 0x1400004e768?})
        /usr/local/go/src/log/log.go:398 +0x64
main.main()
        /Users/qiaopengjun/Code/go/demo/main.go:17 +0x44
exit status 2

Code/go/demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

### 日志三大类

```go
package main

import (
 "log"
)

func init() {

}

func main() {
 log.Println("1234")

 log.Fatalln("1234")

 log.Panicln("1234")

 log.Panic("1234")
 log.Panicf("1234, %d", 5678)
}

```

## 二、配置日志

### 设置前缀

```go
package main

import (
 "log"
)

func init() {
 log.SetPrefix("LOG: ") // 设置前缀
}

func main() {
 log.Println("1234")

 // log.Fatalln("1234")

 // log.Panicln("1234")

 // log.Panic("1234")
 // log.Panicf("1234, %d", 5678)
}

```

#### 运行

```bash
Code/go/demo via 🐹 v1.20.3 via 🅒 base 
➜ go run .
LOG: 2023/06/04 22:26:08 1234

Code/go/demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

### 设置输出

```go
package main

import (
 "log"
 "os"
)

func init() {
 log.SetPrefix("LOG: ") // 设置前缀

 f, err := os.OpenFile("./log.log", os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0644)
 if err != nil {
  log.Fatalf("open log file failed with error: %v", err)
 }
 log.SetOutput(f) // 设置输出
}

func main() {
 log.Println("1234")

 // log.Fatalln("1234")

 // log.Panicln("1234")

 // log.Panic("1234")
 // log.Panicf("1234, %d", 5678)
}

```

#### 运行

```bash
Code/go/demo via 🐹 v1.20.3 via 🅒 base 
➜ go run .

Code/go/demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

#### log.log

```log
LOG: 2023/06/04 22:32:00 1234

```

### 设置 flag

#### main.go 文件

```go
package main

import (
 "log"
 "os"
)

func init() {
 log.SetPrefix("LOG: ") // 设置前缀

 f, err := os.OpenFile("./log.log", os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0644)
 if err != nil {
  log.Fatalf("open log file failed with error: %v", err)
 }
 log.SetOutput(f) // 设置输出

 log.SetFlags(log.Ldate | log.Ltime | log.Lmicroseconds | log.Llongfile)

 // const (
 //  Ldate         = 1 << iota // 1 << 0 = 000000001 = 1
 //  Ltime                     // 1 << 1 = 000000010 = 2
 //  Lmicroseconds             // 1 << 2 = 000000100 = 4
 //  Llongfile                 // 1 << 3 = 000001000 = 8
 //  Lshortfile                // 1 << 4 = 000010000 = 16
 //  ...
 // )
}

func main() {
 log.Println("1234")

 // log.Fatalln("1234")

 // log.Panicln("1234")

 // log.Panic("1234")
 // log.Panicf("1234, %d", 5678)
}

```

#### 源码

```go
const (
 Ldate         = 1 << iota     // the date in the local time zone: 2009/01/23
 Ltime                         // the time in the local time zone: 01:23:23
 Lmicroseconds                 // microsecond resolution: 01:23:23.123123.  assumes Ltime.
 Llongfile                     // full file name and line number: /a/b/c/d.go:23
 Lshortfile                    // final file name element and line number: d.go:23. overrides Llongfile
 LUTC                          // if Ldate or Ltime is set, use UTC rather than the local time zone
 Lmsgprefix                    // move the "prefix" from the beginning of the line to before the message
 LstdFlags     = Ldate | Ltime // initial values for the standard logger 默认flag
)
```

#### 运行

```bash
Code/go/demo via 🐹 v1.20.3 via 🅒 base 
➜ go run .

Code/go/demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

#### log.log

```log
LOG: 2023/06/04 22:32:00 1234
LOG: 2023/06/04 22:43:12.984321 /Users/qiaopengjun/Code/go/demo/main.go:30: 1234

```
