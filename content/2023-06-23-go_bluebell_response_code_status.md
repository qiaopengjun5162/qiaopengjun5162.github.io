+++
title = "bluebell 项目之定义业务状态码并封装响应方法"
date = 2023-06-23T14:57:43+08:00
description = "bluebell 项目之定义业务状态码并封装响应方法"
[taxonomies]
tags = ["Go", "项目"]
categories = ["Go", "项目"]
+++

# 06 bluebell 项目之定义业务状态码并封装响应方法

## 定义业务状态码并封装响应方法

### 项目目录

```bash
bluebell on  main [!?] via 🐹 v1.20.3 via 🅒 base took 8.0s 
➜ tree                                                                 
.
├── LICENSE
├── README.md
├── bluebell.log
├── config.yaml
├── controller
│   ├── code.go
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

13 directories, 23 files

bluebell on  main [!?] via 🐹 v1.20.3 via 🅒 base 

```

controller/response.go

```go
package controller

import (
 "github.com/gin-gonic/gin"
 "net/http"
)

/*
{
 "code": 10000, // code 程序中的状态码
 "msg": xx, // msg 提示信息g
 "data": {}, // data 数据
}
*/

type ResponseData struct {
 Code ResCode     `json:"code"`
 Msg  interface{} `json:"msg"`
 Data interface{} `json:"data"`
}

func ResponseError(c *gin.Context, code ResCode) {
 c.JSON(http.StatusOK, &ResponseData{
  Code: code,
  Msg:  code.Msg(),
  Data: nil,
 })
}

func ResponseErrorWithMsg(c *gin.Context, code ResCode, msg interface{}) {
 c.JSON(http.StatusOK, &ResponseData{
  Code: code,
  Msg:  msg,
  Data: nil,
 })
}

func ResponseSuccess(c *gin.Context, data interface{}) {
 c.JSON(http.StatusOK, &ResponseData{
  Code: CodeSuccess,
  Msg:  CodeSuccess.Msg(),
  Data: data,
 })
}

```

controller/code.go

```go
package controller

type ResCode int64

const (
 CodeSuccess ResCode = 1000 + iota
 CodeInvalidParam
 CodeUserExist
 CodeUserNotExist
 CodeInvalidPassword
 CodeServerBusy
)

var codeMsgMap = map[ResCode]string{
 CodeSuccess:         "success",
 CodeInvalidParam:    "请求参数错误",
 CodeUserExist:       "用户名已存在",
 CodeUserNotExist:    "用户名不存在",
 CodeInvalidPassword: "用户名或密码错误",
 CodeServerBusy:      "服务繁忙",
}

func (c ResCode) Msg() string {
 msg, ok := codeMsgMap[c]
 if !ok {
  msg = codeMsgMap[CodeServerBusy]
 }
 return msg
}

```

controller/user.go

```go
package controller

import (
 "bluebell/dao/mysql"
 "bluebell/logic"
 "bluebell/models"
 "errors"
 "github.com/gin-gonic/gin"
 "github.com/go-playground/validator/v10"
 "go.uber.org/zap"
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
   ResponseError(c, CodeInvalidParam)
   return
  }
  ResponseErrorWithMsg(c, CodeInvalidParam, removeTopStruct(errs.Translate(trans)))
  return
 }
 // 2. 业务处理
 // 结构体是值类型，字段很多的时候，会有性能影响，故最好传指针
 if err := logic.SignUp(p); err != nil {
  zap.L().Error("logic.SignUp failed", zap.Error(err))
  if errors.Is(err, mysql.ErrorUserExist) {
   ResponseError(c, CodeUserExist)
   return
  }
  ResponseError(c, CodeServerBusy)
  return
 }
 // 3. 返回响应
 ResponseSuccess(c, nil)
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
   ResponseError(c, CodeInvalidParam)
   return
  }
  ResponseErrorWithMsg(c, CodeInvalidParam, removeTopStruct(errs.Translate(trans))) // 翻译错误
  return
 }
 // 2. 业务逻辑处理
 if err := logic.Login(p); err != nil {
  zap.L().Error("logic Login failed", zap.String("username", p.Username), zap.Error(err))
  if errors.Is(err, mysql.ErrorUserNotExist) {
   ResponseError(c, CodeUserNotExist)
   return
  }
  ResponseError(c, CodeInvalidPassword)
  return
 }
 // 3. 返回响应
 ResponseSuccess(c, nil)
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

// 把每一步数据库操作封装成函数
// 待 Logic 层根据业务需求调用

const secret = "qiaopengjun.com"

var (
 ErrorUserExist       = errors.New("用户已存在")
 ErrorUserNotExist    = errors.New("用户不存在")
 ErrorInvalidPassword = errors.New("用户名或密码错误")
)

// CheckUserExist 检查指定用户名的用户是否存在
func CheckUserExist(username string) (err error) {
 sqlStr := `SELECT count(user_id) FROM user WHERE username = ?`
 var count int
 if err = db.Get(&count, sqlStr, username); err != nil {
  return err
 }
 if count > 0 {
  // 用户已存在的错误
  return ErrorUserExist
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
  return ErrorUserNotExist
 }
 // 判断密码是否正确
 password := encryptPassword(oPassword)
 if password != user.Password {
  return ErrorInvalidPassword
 }
 return
}

```
