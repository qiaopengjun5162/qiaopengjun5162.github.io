+++
title = "bluebell 项目之循环引用问题的解决"
date = 2023-06-23T23:08:23+08:00
description = "bluebell 项目之循环引用问题的解决"
[taxonomies]
tags = ["Go", "项目"]
categories = ["Go", "项目"]
+++

# 08 bluebell 项目之循环引用问题的解决

## 循环引用问题的解决

### 运行

```bash
bluebell on  main via 🐹 v1.20.3 via 🅒 base 
⇣9% ➜ go run main.go config.yaml         
package command-line-arguments
        imports bluebell/controller
        imports bluebell/middlewares
        imports bluebell/controller: import cycle not allowed

bluebell on  main via 🐹 v1.20.3 via 🅒 base 

```

循环引用：A 导入 B ，B 导入 A

### 项目目录

```bash
bluebell on  main [!] via 🐹 v1.20.3 via 🅒 base took 1m 7.3s 
⇣6% ➜ tree
.
├── LICENSE
├── README.md
├── bluebell.log
├── config.yaml
├── controller
│   ├── code.go
│   ├── request.go
│   ├── response.go
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
├── middlewares
│   └── auth.go
├── models
│   ├── create_table.sql
│   ├── params.go
│   └── user.go
├── pkg
│   ├── jwt
│   │   └── jwt.go
│   ├── snowflake
│   │   └── snowflake.go
│   └── sonyflake
│       └── sonyflake.go
├── router
│   └── router.go
└── setting
    └── setting.go

15 directories, 26 files

bluebell on  main [!] via 🐹 v1.20.3 via 🅒 base 
⇣6% ➜ 

```

middlewares/auth.go

```go
package middlewares

import (
 "bluebell/controller"
 "bluebell/pkg/jwt"
 "strings"

 "github.com/gin-gonic/gin"
)

// JWTAuthMiddleware 基于JWT的认证中间件
func JWTAuthMiddleware() func(c *gin.Context) {
 return func(c *gin.Context) {
  // 客户端携带Token有三种方式 1.放在请求头 2.放在请求体 3.放在URI
  // 这里假设Token放在Header的Authorization中，并使用Bearer开头
  // Authorization: Bearer xxxx.xxx.xx
  // 这里的具体实现方式要依据你的实际业务情况决定
  authHeader := c.Request.Header.Get("Authorization")
  if authHeader == "" {
   controller.ResponseError(c, controller.CodeNeedLogin)
   c.Abort()
   return
  }
  // 按空格分割
  parts := strings.SplitN(authHeader, " ", 2)
  if !(len(parts) == 2 && parts[0] == "Bearer") {
   controller.ResponseError(c, controller.CodeInvalidToken)
   c.Abort()
   return
  }
  // parts[1]是获取到的tokenString，我们使用之前定义好的解析JWT的函数来解析它
  mc, err := jwt.ParseToken(parts[1])
  if err != nil {
   controller.ResponseError(c, controller.CodeInvalidToken)
   c.Abort()
   return
  }
  // 将当前请求的 userID 信息保存到请求的上下文c上
  c.Set(controller.CtxUserIDKey, mc.UserID)
  c.Next() // 后续的处理请求函数中 可以用过 c.Get(CtxUserIDKey) 来获取当前请求的用户信息
 }
}

```

controller/request.go

```go
package controller

import (
 "errors"

 "github.com/gin-gonic/gin"
)

const CtxUserIDKey = "userID"

var ErrorUserNotLogin = errors.New("用户未登录")

// getCurrentUser 获取当前登录的用户ID
func getCurrentUser(c *gin.Context) (userID int64, err error) {
 uid, ok := c.Get(CtxUserIDKey)
 if !ok {
  err = ErrorUserNotLogin
  return
 }
 userID, ok = uid.(int64)
 if !ok {
  err = ErrorUserNotLogin
  return
 }
 return
}

```
