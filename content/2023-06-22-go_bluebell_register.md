+++
title = "bluebell 项目之请求参数的获取与校验"
date = 2023-06-22T14:43:52+08:00
description = "bluebell 项目之请求参数的获取与校验"
[taxonomies]
tags = ["Go", "项目"]
categories = ["Go", "项目"]
+++

# 02 bluebell 项目之请求参数的获取与校验

## 请求参数的获取与校验

### 项目目录

```bash
bluebell on  main [!?] via 🐹 v1.20.3 via 🅒 base took 7m 17.0s 
➜ tree
.
├── LICENSE
├── README.md
├── bluebell.log
├── config.yaml
├── controller
│   └── user.go
├── dao
│   ├── mysql
│   │   ├── mysql.go
│   │   └── user.go
│   └── redis
│       └── redis.go
├── go.mod
├── go.sum
├── logger
│   └── logger.go
├── logic
│   └── user.go
├── main.go
├── models
│   ├── create_table.sql
│   └── params.go
├── pkg
│   ├── snowflake
│   │   └── snowflake.go
│   └── sonyflake
│       └── sonyflake.go
├── router
│   └── router.go
└── setting
    └── setting.go

13 directories, 19 files

bluebell on  main [!?] via 🐹 v1.20.3 via 🅒 base 
➜ 

```

main.go

```go
package main

import (
 "bluebell/dao/mysql"
 "bluebell/dao/redis"
 "bluebell/logger"
 "bluebell/pkg/snowflake"
 "bluebell/router"
 "bluebell/setting"
 "context"
 "flag"
 "fmt"
 "log"
 "net/http"
 "os"
 "os/signal"
 "syscall"
 "time"

 "go.uber.org/zap"
)

// Go Web 开发通用的脚手架模版

func main() {
 filename := flag.String("filename", "config.yaml", "config file")
 // 解析命令行参数
 flag.Parse()
 fmt.Println(*filename)
 //返回命令行参数后的其他参数
 fmt.Println(flag.Args())
 //返回命令行参数后的其他参数个数
 fmt.Println("NArg", flag.NArg())
 //返回使用的命令行参数个数
 fmt.Println("NFlag", flag.NFlag())
 if flag.NArg() != 1 || flag.NArg() != 1 {
  fmt.Println("please need config file.eg: bluebell config.yaml")
  return
 }
 // 1. 加载配置
 if err := setting.Init(*filename); err != nil {
  fmt.Printf("init settings failed, error: %v\n", err)
  return
 }
 // 2. 初始化日志
 if err := logger.Init(setting.Conf.LogConfig); err != nil {
  fmt.Printf("init logger failed, error: %v\n", err)
  return
 }
 defer zap.L().Sync()
 zap.L().Debug("logger initialized successfully")
 // 3. 初始化 MySQL 连接
 if err := mysql.Init(setting.Conf.MySQLConfig); err != nil {
  fmt.Printf("init mysql failed, error: %v\n", err)
  return
 }
 defer mysql.Close()
 // 4. 初始化 Redis 连接
 if err := redis.Init(setting.Conf.RedisConfig); err != nil {
  fmt.Printf("init redis failed, error: %v\n", err)
  return
 }
 defer redis.Close()
 // snowflake
 if err := snowflake.Init(setting.Conf.StartTime, setting.Conf.MachineID); err != nil {
  fmt.Printf("init snowflake failed with error: %v\n", err)
  return
 }
 id := snowflake.GenID()
 fmt.Printf("generation started with id: %v\n", id)

 // 5. 注册路由
 router := router.SetupRouter()
 // 6. 启动服务（优雅关机）
 // 服务器定义运行HTTP服务器的参数。Server的零值是一个有效的配置。
 srv := &http.Server{
  // Addr可选地以“host:port”的形式指定服务器要监听的TCP地址。如果为空，则使用“:http”(端口80)。
  // 服务名称在RFC 6335中定义，并由IANA分配
  Addr:    fmt.Sprintf(":%d", setting.Conf.Port),
  Handler: router,
 }

 go func() {
  // 开启一个goroutine启动服务，如果不用 goroutine，下面的代码 ListenAndServe 会一直接收请求，处理请求，进入无限循环。代码就不会往下执行。

  // ListenAndServe监听TCP网络地址srv.Addr，然后调用Serve来处理传入连接上的请求。接受的连接配置为使TCP能保持连接。
  // ListenAndServe always returns a non-nil error. After Shutdown or Close,
  // the returned error is ErrServerClosed.
  if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
   log.Fatalf("listen: %s\n", err) // Fatalf 相当于Printf()之后再调用os.Exit(1)。
  }
 }()

 // 等待中断信号来优雅地关闭服务器，为关闭服务器操作设置一个5秒的超时

 // make内置函数分配并初始化(仅)slice、map或chan类型的对象。
 // 与new一样，第一个参数是类型，而不是值。
 // 与new不同，make的返回类型与其参数的类型相同，而不是指向它的指针
 // Channel:通道的缓冲区用指定的缓冲区容量初始化。如果为零，或者忽略大小，则通道未被缓冲。

 // 信号 Signal 表示操作系统信号。通常的底层实现依赖于操作系统:在Unix上是syscall.Signal。
 quit := make(chan os.Signal, 1) // 创建一个接收信号的通道
 // kill 默认会发送 syscall.SIGTERM 信号
 // kill -2 发送 syscall.SIGINT 信号，Ctrl+C 就是触发系统SIGINT信号
 // kill -9 发送 syscall.SIGKILL 信号，但是不能被捕获，所以不需要添加它
 // signal.Notify把收到的 syscall.SIGINT或syscall.SIGTERM 信号转发给quit

 // Notify使包信号将传入的信号转发给c，如果没有提供信号，则将所有传入的信号转发给c，否则仅将提供的信号转发给c。
 // 包信号不会阻塞发送到c:调用者必须确保c有足够的缓冲空间来跟上预期的信号速率。对于仅用于通知一个信号值的通道，大小为1的缓冲区就足够了。
 // 允许使用同一通道多次调用Notify:每次调用都扩展发送到该通道的信号集。从集合中移除信号的唯一方法是调用Stop。
 // 允许使用不同的通道和相同的信号多次调用Notify:每个通道独立地接收传入信号的副本。
 signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM) // 此处不会阻塞
 <-quit                                               // 阻塞在此，当接收到上述两种信号时才会往下执行
 zap.L().Info("Shutdown Server ...")
 // 创建一个5秒超时的context
 ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
 defer cancel()
 // 5秒内优雅关闭服务（将未处理完的请求处理完再关闭服务），超过5秒就超时退出

 // 关机将在不中断任何活动连接的情况下优雅地关闭服务器。
 // Shutdown的工作原理是首先关闭所有打开的侦听器，然后关闭所有空闲连接，然后无限期地等待连接返回空闲状态，然后关闭。
 // 如果提供的上下文在关闭完成之前过期，则shutdown返回上下文的错误，否则返回关闭服务器的底层侦听器所返回的任何错误。
 // 当Shutdown被调用时，Serve, ListenAndServe和ListenAndServeTLS会立即返回ErrServerClosed。确保程序没有退出，而是等待Shutdown返回。
 // 关闭不试图关闭或等待被劫持的连接，如WebSockets。如果需要的话，Shutdown的调用者应该单独通知这些长寿命连接关闭，并等待它们关闭。
 // 一旦在服务器上调用Shutdown，它可能不会被重用;以后对Serve等方法的调用将返回ErrServerClosed。
 if err := srv.Shutdown(ctx); err != nil {
  zap.L().Fatal("Server Shutdown", zap.Error(err))
 }

 zap.L().Info("Server exiting")
}

```

router/router.go

```go
package router

import (
 "bluebell/controller"
 "bluebell/logger"
 "bluebell/setting"
 "github.com/gin-gonic/gin"
 "net/http"
)

func SetupRouter() *gin.Engine {
 r := gin.New()
 r.Use(logger.GinLogger(), logger.GinRecovery(true))

 // 注册业务路由
 r.POST("/signup", controller.SignUpHandler)

 r.GET("/version", func(context *gin.Context) {
  context.String(http.StatusOK, setting.Conf.Version)
 })
 r.NoRoute(func(context *gin.Context) {
  context.JSON(http.StatusOK, gin.H{
   "message": "404",
  })
 })
 return r
}

```

logic/user.go

```go
package logic

import (
 "bluebell/dao/mysql"
 "bluebell/models"
 "bluebell/pkg/snowflake"
)

// 存放业务逻辑的代码

func SignUp(p *models.ParamSignUp) {
 // 1. 判断用户是否存在
 mysql.QueryUserByUsername()
 // 2. 生成 UID
 snowflake.GenID()
 // 3. 密码加密

 // 4. 保存到数据库
 mysql.InsertUser()
}

```

models/params.go

```go
package models

// 定义请求的参数结构体

type ParamSignUp struct {
 Username   string `json:"username"`
 Password   string `json:"password"`
 RePassword string `json:"re_password"`
}

```

dao/mysql/user.go

```go
package mysql

// 把每一步数据库操作封装成函数
// 待 Logic 层根据业务需求调用

func QueryUserByUsername() {

}

func InsertUser() {

}

```

controller/user.go

```go
package controller

import (
 "bluebell/logic"
 "bluebell/models"
 "fmt"
 "github.com/gin-gonic/gin"
 "go.uber.org/zap"
 "net/http"
)

// SignUpHandler 处理注册请求的函数
func SignUpHandler(c *gin.Context) {
 // 1. 获取参数和参数校验
 p := new(models.ParamSignUp)
 if err := c.ShouldBindJSON(p); err != nil {
  // 请求参数有误，直接返回响应
  zap.L().Error("SignUp with invalid parameters", zap.Error(err))
  c.JSON(http.StatusOK, gin.H{
   "message": "Invalid parameters",
  })
  fmt.Printf("paramSignUp error %v\n", err)
  return
 }
 // 手动对请求参数进行详细的业务规则校验
 if len(p.Username) == 0 || len(p.Password) == 0 || len(p.RePassword) == 0 || p.Password != p.RePassword {
  zap.L().Error("SignUp with invalid param")
  c.JSON(http.StatusOK, gin.H{
   "message": "Invalid parameters",
  })
  return
 }
 fmt.Printf("signUp params: %v\n", p)
 // 2. 业务处理
 // 结构体是值类型，字段很多的时候，会有性能影响，故最好传指针
 logic.SignUp(p)
 // 3. 返回响应
 c.JSON(http.StatusOK, gin.H{"message": "OK"})
}

```

### 运行并请求：127.0.0.1:8080/signup

```bash
bluebell on  main [!?] via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go config.yaml
config.yaml
[config.yaml]
NArg 1
NFlag 0
generation started with id: 145785647796224
[GIN-debug] [WARNING] Running in "debug" mode. Switch to "release" mode in production.
 - using env:   export GIN_MODE=release
 - using code:  gin.SetMode(gin.ReleaseMode)

[GIN-debug] POST   /signup                   --> bluebell/controller.SignUpHandler (3 handlers)
[GIN-debug] GET    /version                  --> bluebell/router.SetupRouter.func1 (3 handlers)
signUp params: &{xiaoqiao 123 123}


```

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306221740339.png)

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306221741583.png)
