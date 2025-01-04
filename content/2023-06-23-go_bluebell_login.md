+++
title = "bluebell 项目之使用mode控制日志输出位置和登录功能实现"
date = 2023-06-23T11:59:57+08:00
description = "bluebell 项目之使用mode控制日志输出位置和登录功能实现"
[taxonomies]
tags = ["Go", "项目"]
categories = ["Go", "项目"]
+++

# 05 bluebell 项目之使用mode控制日志输出位置和登录功能实现

## 使用mode控制日志输出位置和登录功能实现

### 项目目录

```bash
bluebell on  main [!] via 🐹 v1.20.3 via 🅒 base took 1h 4m 22.5s 
➜ tree                                               
.
├── LICENSE
├── README.md
├── bluebell.log
├── config.yaml
├── controller
│   ├── user.go
│   └── validator.go
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
│   ├── params.go
│   └── user.go
├── pkg
│   ├── snowflake
│   │   └── snowflake.go
│   └── sonyflake
│       └── sonyflake.go
├── router
│   └── router.go
└── setting
    └── setting.go

13 directories, 21 files

bluebell on  main [!] via 🐹 v1.20.3 via 🅒 base 
➜ 

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

func SetupRouter(mode string) *gin.Engine {
 if mode == gin.ReleaseMode {
  gin.SetMode(gin.ReleaseMode) // gin 设置成发布模式
 }
 r := gin.New()
 r.Use(logger.GinLogger(), logger.GinRecovery(true))

 // 注册业务路由
 r.POST("/signup", controller.SignUpHandler)
 r.POST("/login", controller.LoginHandler)

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

controller/user.go

```go
package controller

import (
 "bluebell/logic"
 "bluebell/models"
 "fmt"
 "github.com/gin-gonic/gin"
 "github.com/go-playground/validator/v10"
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
  // 判断 err 是否是 validator.ValidationErrors类型
  errs, ok := err.(validator.ValidationErrors)
  if !ok {
   // 非validator.ValidationErrors类型错误直接返回
   c.JSON(http.StatusOK, gin.H{
    "message": err.Error(),
   })
   return
  }
  // validator.ValidationErrors类型错误则进行翻译
  c.JSON(http.StatusOK, gin.H{
   "message": removeTopStruct(errs.Translate(trans)),
  })
  fmt.Printf("paramSignUp error %v\n", err)
  return
 }

 fmt.Printf("signUp params: %v\n", p)
 // 2. 业务处理
 // 结构体是值类型，字段很多的时候，会有性能影响，故最好传指针
 if err := logic.SignUp(p); err != nil {
  c.JSON(http.StatusInternalServerError, gin.H{
   "message": "registration failed",
  })
  return
 }
 // 3. 返回响应
 c.JSON(http.StatusOK, gin.H{"message": "success"})
}

func LoginHandler(c *gin.Context) {
 // 1. 获取请求参数及参数校验
 p := new(models.ParamLogin)
 if err := c.ShouldBindJSON(p); err != nil {
  // 请求参数有误，直接返回响应
  zap.L().Error("Login with invalid parameters", zap.Error(err))
  // 判断 err 是否是 validator.ValidationErrors类型
  errs, ok := err.(validator.ValidationErrors)
  if !ok {
   c.JSON(http.StatusOK, gin.H{
    "message": err.Error(),
   })
   return
  }
  c.JSON(http.StatusOK, gin.H{
   "message": removeTopStruct(errs.Translate(trans)), // 翻译错误
  })
  return
 }
 // 2. 业务逻辑处理
 if err := logic.Login(p); err != nil {
  zap.L().Error("logic Login failed", zap.String("username", p.Username), zap.Error(err))
  c.JSON(http.StatusInternalServerError, gin.H{
   "message": "Login failed, username or password incorrect",
  })
  return
 }
 // 3. 返回响应
 c.JSON(http.StatusOK, gin.H{"message": "login successful"})
}

```

logic/user.go

```go
package logic

import (
 "bluebell/dao/mysql"
 "bluebell/models"
 "bluebell/pkg/snowflake"

 "fmt"
)

// 存放业务逻辑的代码

// SignUp 注册
func SignUp(p *models.ParamSignUp) (err error) {
 // 1. 判断用户是否存在
 if err = mysql.CheckUserExist(p.Username); err != nil {
  return err
 }

 // 2. 生成 UID
 userID := snowflake.GenID()
 fmt.Printf("generation started with userID: %v\n", userID)
 // 3. 构造一个 User 实例
 user := &models.User{
  UserID:   userID,
  UserName: p.Username,
  Password: p.Password,
 }
 // 4. 保存到数据库
 return mysql.InsertUser(user)
}

// Login 登录
func Login(p *models.ParamLogin) (err error) {
 // 构造一个 User 实例
 user := &models.User{
  UserName: p.Username,
  Password: p.Password,
 }
 // 登录
 return mysql.Login(user)
}

```

dao/mysql/user.go

```go
package mysql

import (
 "bluebell/models"
 "crypto/md5"
 "database/sql"
 "encoding/hex"
 "errors"
)

const secret = "qiaopengjun.com"

// 把每一步数据库操作封装成函数
// 待 Logic 层根据业务需求调用

// CheckUserExist 检查指定用户名的用户是否存在
func CheckUserExist(username string) (err error) {
 sqlStr := `SELECT count(user_id) FROM user WHERE username = ?`
 var count int
 if err = db.Get(&count, sqlStr, username); err != nil {
  return err
 }
 if count > 0 {
  // 用户已存在的错误
  return errors.New("user already")
 }
 return
}

// InsertUser 向数据库中插入一条新的用户记录
func InsertUser(user *models.User) (err error) {
 // 对密码进行加密
 user.Password = encryptPassword(user.Password)
 // 执行SQL 语句入库
 sqlStr := `INSERT INTO user (user_id, username, password) VALUES (?, ?, ?)`
 _, err = db.Exec(sqlStr, user.UserID, user.UserName, user.Password)
 return
}

func encryptPassword(oPassword string) string {
 h := md5.New()
 h.Write([]byte(secret))
 return hex.EncodeToString(h.Sum([]byte(oPassword)))
}

// Login
func Login(user *models.User) (err error) {
 oPassword := user.Password // 用户登录的密码
 sqlStr := `SELECT user_id, username, password FROM user WHERE username = ?`
 if err = db.Get(user, sqlStr, user.UserName); err != nil {
  return err // 查询数据库失败
 }
 if err == sql.ErrNoRows {
  return errors.New("用户不存在")
 }
 // 判断密码是否正确
 password := encryptPassword(oPassword)
 if password != user.Password {
  return errors.New("密码错误")
 }
 return
}

```

models/params.go

```go
package models

// 定义请求的参数结构体
// ParamSignUp 注册请求参数
type ParamSignUp struct {
 Username   string `json:"username" binding:"required"`
 Password   string `json:"password" binding:"required"`
 RePassword string `json:"re_password" binding:"required,eqfield=Password"`
}

// ParamLogin 登录请求参数
type ParamLogin struct {
 Username string `json:"username" binding:"required"`
 Password string `json:"password" binding:"required"`
}

```

main.go

```go
package main

import (
 "bluebell/controller"
 "bluebell/dao/mysql"
 "bluebell/dao/redis"
 "bluebell/logger"
 "bluebell/pkg/snowflake"
 "bluebell/router"
 "bluebell/setting"
 "context"
 "flag"
 "fmt"
 "github.com/gin-gonic/gin"
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

 // 初始化gin框架内置的校验器 validator 使用的翻译器
 if err := controller.InitTrans("zh"); err != nil {
  fmt.Printf("init validator trans failed with error: %v\n", err)
  return
 }

 // 5. 注册路由
 r := router.SetupRouter(gin.DebugMode)
 //err := r.Run(fmt.Sprintf(":%d", setting.Conf.Port))
 //if err != nil {
 // fmt.Printf("run server failed with error: %v\n", err)
 // return
 //}
 // 6. 启动服务（优雅关机）
 // 服务器定义运行HTTP服务器的参数。Server的零值是一个有效的配置。
 srv := &http.Server{
  // Addr可选地以“host:port”的形式指定服务器要监听的TCP地址。如果为空，则使用“:http”(端口80)。
  // 服务名称在RFC 6335中定义，并由IANA分配
  Addr:    fmt.Sprintf(":%d", setting.Conf.Port),
  Handler: r,
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

运行

```bash
bluebell on  main [!] via 🐹 v1.20.3 via 🅒 base took 4m 48.9s 
➜ go run main.go config.yaml
config.yaml
[config.yaml]
NArg 1
NFlag 0
[GIN-debug] [WARNING] Running in "debug" mode. Switch to "release" mode in production.
 - using env:   export GIN_MODE=release
 - using code:  gin.SetMode(gin.ReleaseMode)

[GIN-debug] POST   /signup                   --> bluebell/controller.SignUpHandler (3 handlers)
[GIN-debug] POST   /login                    --> bluebell/controller.LoginHandler (3 handlers)
[GIN-debug] GET    /version                  --> bluebell/router.SetupRouter.func1 (3 handlers)


```

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306231359811.png)
