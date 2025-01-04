+++
title = "bluebell 项目之使用JWT实现用户认证"
date = 2023-06-23T17:59:50+08:00
description = "bluebell 项目之使用JWT实现用户认证"
[taxonomies]
tags = ["Go", "项目"]
categories = ["Go", "项目"]
+++

# 07 bluebell 项目之使用JWT实现用户认证

## 基于cookie-Session 和基于token的认证模式

**需求：请求分类**

### 用户认证

HTTP 是一个无状态的协议，一次请求结束后，下次再发送，服务器就不知道这个请求是谁发过来的（同一个 IP 不代表同一个用户），在Web 应用中，用户的认证和鉴权是非常重要的一环，实践中有多种实现方案，各有千秋。

### Cookie - Session 认证模式

在 Web 应用发展的初期，大部分采用基于 Cookie - Session 的会话管理方式。逻辑如下：

- 客户端使用用户名、密码进行认证
- 服务端验证用户名、密码正确后生成并存储 Session，将SessionID 通过 Cookie 返回给客户端
- 客户端访问需认证的接口时在 Cookie 中携带 SessionID
- 服务端通过 SessionID 查找 Session 并进行鉴权，返回给客户端需要的数据

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306231831221.png)

基于 Session 的方式存在多种问题

- 服务端需要存储 Session，并且由于 Session 需要经常快速查找，通常存储在内存或内存数据库中，同时在线用户较多时需要占用大量的服务器资源。
- 当需要扩展时，创建 Session 的服务器可能不是验证 Session 的服务器，所以还需要将所有Session 单独存储并共享。
- 由于客户端使用 Cookie 存储 SessionID，在跨域场景下需要进行兼容性处理，同时这种方式也难以防范CSRF 攻击。

### Token 认证模式

鉴于基于 Session 的会话管理方式存在上述多个缺点，基于 Token 的无状态会话管理方式诞生了，所谓无状态，就是服务端可以不再存储信息，甚至是不再存储Session。逻辑如下：

- 客户端使用用户名、密码进行认证
- 服务端验证用户名、密码正确后生成 Token 返回给客户端
- 客户端保存 Token，访问需要认证的接口时在 URL 参数或 HTTP Header 中加入 Token
- 服务端通过解码 Token 进行鉴权，返回给客户端需要的数据

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306231851685.png)

基于 Token 的会话管理方式有效解决了基于 Session 的会话管理方式带来的问题。

- 服务端不需要存储和用户鉴权有关的信息，鉴权信息会被加密到 Token 中，服务端只需要读取 Token 中包含的鉴权信息即可
- 避免了共享 Session 导致的不易扩展问题
- 不需要依赖 Cookie，有效避免 Cookie 带来的 CSRF  攻击问题
- 使用 CORS 可以快速解决跨域问题

### JWT 介绍

[JWT 官网](https://jwt.io/)：<https://jwt.io/>

[JWT 文档](https://jwt.io/introduction)：<https://jwt.io/introduction>

JWT 是 JSON Web Token 的缩写，是为了在网络应用环境间传递声明而执行的一种基于 JSON 的开放标准（([RFC 7519](https://tools.ietf.org/html/rfc7519))。JWT 本身没有定义任何技术实现，它只是定义了一种基于 Token 的会话管理的规则，涵盖 Token 需要包含的标准内容和 Token 的生成过程，特别适用于分布式站点的单点登录（SSO）场景。

JSON Web Token (JWT)是一个开放标准(RFC 7519) ，它定义了一种紧凑和自包含的方式，用于作为 JSON 对象在各方之间安全地传输信息。此信息可以进行验证和信任，因为它是经过数字签名的。JWT 可以使用机密(使用 HMAC 算法)或使用 RSA 或 ECDSA 的公钥/私钥对进行签名。

虽然可以对 JWT 进行加密，以便在各方之间提供保密性，但是我们将重点关注已签名的令牌。签名令牌可以验证其中包含的声明的完整性，而加密令牌可以向其他方隐藏这些声明。当使用公钥/私钥对对令牌进行签名时，该签名还证明只有持有私钥的一方才是对其进行签名的一方。

下面是 JSON Web 令牌非常有用的一些场景:

- **Authorization** 授权: 这是使用 JWT 最常见的场景。一旦用户登录，每个后续请求都将包含 JWT，允许用户访问该令牌所允许的路由、服务和资源。单点登录是目前广泛使用 JWT 的一个特性，因为它的开销很小，而且能够很容易地跨不同域使用。
- **Information Exchange** 信息交换: JSON Web 令牌是在各方之间安全传输信息的好方法。因为可以对 JWT 进行签名(例如，使用公钥/私钥对) ，所以可以确保发件人就是他们所说的那个人。此外，由于签名是使用头和有效负载计算的，因此还可以验证内容是否被篡改。

一个 JWT Token 就像这样：

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
```

JSON Web Token由以点(.)分隔的三个部分组成，它们是:

- Header 头部
- Payload 负载
- Signature 签名

因此，JWT 通常如下所示。

```bash
xxxxx.yyyyy.zzzzz
```

#### Header

Header通常由两部分组成: 令牌的类型(即 JWT)和所使用的签名算法(如 HMAC SHA256或 RSA)。

For example:

```bash
{
  "alg": "HS256",
  "typ": "JWT"
}
```

然后，对这个 JSON 进行 **Base64Url**  编码，形成 JWT 的第一部分。

#### Payload

Payload 表示负载，也是一个 JSON 对象，JWT 规定了 7 个官方字段供选用：

```bash
iss (issuer)：签发人
exp (expiration time)：过期时间
sub (subject)：主题
aud (audience)：受众
"nbf" (Not Before)：生效时间
"iat" (Issued At) ：签发时间
"jti" (JWT ID)：编号
```

<https://datatracker.ietf.org/doc/html/rfc7519#section-4.1>

除了官方字段，开发者也可以自己指定字段和内容，例如下面的内容。

```bash
{
  "sub": "1234567890",
  "name": "John Doe",
  "admin": true
}
```

然后对有效 payload 进行  **Base64Url**  编码，形成 JSON Web Token的第二部分。

请注意，对于已签名的令牌，这些信息虽然受到保护，不会被篡改，但任何人都可以阅读。除非加密，否则不要将机密信息放在 JWT 的有效负载或头元素中。

#### Signature

signature 部分是对前两部分的签名，防止数据篡改。

首先需要指定一个密钥（secret）。这个密钥只有服务器才知道，不能泄漏给用户。然后使用Header 里面指定的签名算法（默认是 HMAC SHA256）。

To create the signature part you have to take the encoded header, the encoded payload, a secret, the algorithm specified in the header, and sign that.

要创建签名部分，您必须获取编码的标头、编码的有效载荷、秘密、标头中指定的算法，并对其进行签名。

例如，如果您想使用 HMAC SHA256算法，签名将按以下方式创建:

```bash
HMACSHA256(
  base64UrlEncode(header) + "." +
  base64UrlEncode(payload),
  secret)
```

该签名用于验证消息在执行过程中没有被更改，并且，对于使用私钥签名的令牌，它还可以验证 JWT 的发送方是否就是它所说的那个人。

#### Putting all together

输出是三个由点分隔的 Base64-URL 字符串，这些字符串可以在 HTML 和 HTTP 环境中轻松传递，同时与基于 XML 的标准(如 SAML)相比更加紧凑。

The following diagram shows how a JWT is obtained and used to access APIs or resources:

![How does a JSON Web Token work](https://cdn2.auth0.com/docs/media/articles/api-auth/client-credentials-grant.png)

1. The application or client requests authorization to the authorization server. This is performed through one of the different authorization flows. For example, a typical [OpenID Connect](http://openid.net/connect/) compliant web application will go through the `/oauth/authorize` endpoint using the [authorization code flow](http://openid.net/specs/openid-connect-core-1_0.html#CodeFlowAuth).
2. When the authorization is granted, the authorization server returns an access token to the application.
3. The application uses the access token to access a protected resource (like an API).

### JWT 优缺点

JWT 拥有基于 Token 的会话管理方式所拥有的一切优势，不依赖 Cookie，使得其可以防止 CSRF 攻击，也能在禁用 Cookie 的浏览器环境中正常运行。

而 JWT 的最大优势是服务端不再需要存储 Session，使得服务端认证鉴权业务可以方便扩展，避免存储 Session 所需要引入的 Redis 等组件，降低了系统架构复杂度。但这也是 JWT 最大的劣势，由于有效期存储在 Token 中，JWT  Token 一旦签发，就会在有效期内一直可用，无法在服务端废止，当用户进行登出操作，只能依赖客户端删除掉本地存储的 JWT Token，如果需要禁用用户，单纯使用 JWT 就无法做到了。

### 基于 JWT 实现认证实践

前面说的 Token，都是 Access Token，也就是访问资源接口时所需要的 Token，还有另外一种 Token，Refresh Token，通常情况下，Refresh Token 的有效期会比较长，而 Access Token 的有效期比较短，当 Access Token 由于过期而失效时，使用 Refresh Token 就可以获取到新的 Access Token，如果 Refresh Token 也失效了，用户就只能重新登陆了。

## 使用JWT实现用户认证

**golang-jwt**：<https://github.com/golang-jwt/jwt>

### 安装指南

1. 要安装 jwt 包，首先需要安装 Go，然后可以使用下面的命令在 Go 程序中添加 jwt-Go 作为依赖项。

```
go get -u github.com/golang-jwt/jwt/v5
```

2. Import it in your code:

```
import "github.com/golang-jwt/jwt/v5"
```

**[golang-jwt docs](https://golang-jwt.github.io/jwt/usage/create/)**：<https://golang-jwt.github.io/jwt/usage/create/>

<https://github.com/appleboy/gin-jwt>

## 项目实操

### 项目目录

```go
bluebell on  main [!?] via 🐹 v1.20.3 via 🅒 base took 1m 24.6s 
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

14 directories, 24 files

bluebell on  main [!?] via 🐹 v1.20.3 via 🅒 base 

```

pkg/jwt/jwt.go

```go
package jwt

import (
 "errors"
 "time"

 "github.com/golang-jwt/jwt/v5"
)

const TokenExpireDuration = time.Hour * 24

// CustomSecret 用于加盐的字符串
var CustomSecret = []byte("恰似人间惊鸿客墨染星辰云水间")

// CustomClaims 自定义声明类型 并内嵌jwt.RegisteredClaims
// jwt包自带的jwt.RegisteredClaims只包含了官方字段
// 假设我们这里需要额外记录一个username字段，所以要自定义结构体
// 如果想要保存更多信息，都可以添加到这个结构体中
type CustomClaims struct {
 // 可根据需要自行添加字段
 UserID               int64  `json:"user_id"`
 Username             string `json:"username"`
 jwt.RegisteredClaims        // 内嵌标准的声明
}

// GenToken 生成JWT
func GenToken(UserID int64, username string) (string, error) {
 // 创建一个我们自己的声明的数据
 claims := CustomClaims{
  UserID,
  username, // 自定义字段
  jwt.RegisteredClaims{
   ExpiresAt: jwt.NewNumericDate(time.Now().Add(TokenExpireDuration)), // 过期时间
   Issuer:    "bluebell",                                              // 签发人 发行人
  },
 }
 // 使用指定的签名方法创建签名对象
 token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
 // 使用指定的secret签名并获得完整的编码后的字符串token
 return token.SignedString(CustomSecret)
}

// ParseToken 解析JWT
func ParseToken(tokenString string) (*CustomClaims, error) {
 // 解析token
 var claims = new(CustomClaims)
 // 如果是自定义Claim结构体则需要使用 ParseWithClaims 方法
 token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (i interface{}, err error) {
  // 直接使用标准的Claim则可以直接使用Parse方法
  //token, err := jwt.Parse(tokenString, func(token *jwt.Token) (i interface{}, err error) {
  return CustomSecret, nil
 })
 if err != nil {
  return nil, err
 }
 // 对token对象中的Claim进行类型断言
 if token.Valid { // 校验token
  return claims, nil
 }
 return nil, errors.New("invalid token")
}

```

router/router.go

```go
package router

import (
 "bluebell/controller"
 "bluebell/logger"
 "bluebell/pkg/jwt"
 "net/http"
 "strings"

 "github.com/gin-gonic/gin"
)

func SetupRouter(mode string) *gin.Engine {
 if mode == gin.ReleaseMode {
  gin.SetMode(gin.ReleaseMode) // gin 设置成发布模式
 }
 r := gin.New()
 r.Use(logger.GinLogger(), logger.GinRecovery(true))

 // 注册业务路由
 r.POST("/signup", controller.SignUpHandler)
 // 登录
 r.POST("/login", controller.LoginHandler)

 r.GET("/ping", JWTAuthMiddleware(), func(context *gin.Context) {
  context.String(http.StatusOK, "pong")
 })
 r.NoRoute(func(context *gin.Context) {
  context.JSON(http.StatusOK, gin.H{
   "message": "404",
  })
 })
 return r
}

// JWTAuthMiddleware 基于JWT的认证中间件
func JWTAuthMiddleware() func(c *gin.Context) {
 return func(c *gin.Context) {
  // 客户端携带Token有三种方式 1.放在请求头 2.放在请求体 3.放在URI
  // 这里假设Token放在Header的Authorization中，并使用Bearer开头
  // Authorization: Bearer xxxx.xxx.xx
  // 这里的具体实现方式要依据你的实际业务情况决定
  authHeader := c.Request.Header.Get("Authorization")
  if authHeader == "" {
   c.JSON(http.StatusOK, gin.H{
    "code": 2003,
    "msg":  "请求头中auth为空",
   })
   c.Abort()
   return
  }
  // 按空格分割
  parts := strings.SplitN(authHeader, " ", 2)
  if !(len(parts) == 2 && parts[0] == "Bearer") {
   c.JSON(http.StatusOK, gin.H{
    "code": 2004,
    "msg":  "请求头中auth格式有误",
   })
   c.Abort()
   return
  }
  // parts[1]是获取到的tokenString，我们使用之前定义好的解析JWT的函数来解析它
  mc, err := jwt.ParseToken(parts[1])
  if err != nil {
   c.JSON(http.StatusOK, gin.H{
    "code": 2005,
    "msg":  "无效的Token",
   })
   c.Abort()
   return
  }
  // 将当前请求的userID信息保存到请求的上下文c上
  c.Set("userID", mc.UserID)
  c.Next() // 后续的处理函数可以用过c.Get("username")来获取当前请求的用户信息
 }
}

```

logic/user.go

```go
package logic

import (
 "bluebell/dao/mysql"
 "bluebell/models"
 "bluebell/pkg/jwt"
 "bluebell/pkg/snowflake"
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
func Login(p *models.ParamLogin) (token string, err error) {
 // 构造一个 User 实例
 user := &models.User{
  UserName: p.Username,
  Password: p.Password,
 }
 // 传递的是指针, 数据库中查询出来最后也赋值给 user，就能拿到 user.UserID
 if err = mysql.Login(user); err != nil {
  return "", err
 }
 // 生成 JWT
 return jwt.GenToken(user.UserID, user.UserName)

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
 token, err := logic.Login(p)
 if err != nil {
  zap.L().Error("logic Login failed", zap.String("username", p.Username), zap.Error(err))
  if errors.Is(err, mysql.ErrorUserNotExist) {
   ResponseError(c, CodeUserNotExist)
   return
  }
  ResponseError(c, CodeInvalidPassword)
  return
 }
 // 3. 返回响应
 ResponseSuccess(c, token)
}

```

### 运行

```bash
bluebell on  main [!?] via 🐹 v1.20.3 via 🅒 base took 4m 32.9s 
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
[GIN-debug] GET    /ping                     --> bluebell/router.SetupRouter.func1 (4 handlers)

```

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306232229252.png)

请求：127.0.0.1:8080/ping

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306232230587.png)

## 优化JWT认证中间件

### 项目目录

```go
bluebell on  main [!?] via 🐹 v1.20.3 via 🅒 base 
➜ tree
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

bluebell on  main [!?] via 🐹 v1.20.3 via 🅒 base 

```

router/router.go

```go
package router

import (
 "bluebell/controller"
 "bluebell/logger"
 "bluebell/middlewares"
 "net/http"

 "github.com/gin-gonic/gin"
)

func SetupRouter(mode string) *gin.Engine {
 if mode == gin.ReleaseMode {
  gin.SetMode(gin.ReleaseMode) // gin 设置成发布模式
 }
 r := gin.New()
 r.Use(logger.GinLogger(), logger.GinRecovery(true))

 // 注册业务路由
 r.POST("/signup", controller.SignUpHandler)
 // 登录
 r.POST("/login", controller.LoginHandler)

 r.GET("/ping", middlewares.JWTAuthMiddleware(), func(context *gin.Context) {
  context.String(http.StatusOK, "pong")
 })
 r.NoRoute(func(context *gin.Context) {
  context.JSON(http.StatusOK, gin.H{
   "message": "404",
  })
 })
 return r
}

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

const CtxUserIDKey = "userID"

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
  c.Set(CtxUserIDKey, mc.UserID)
  c.Next() // 后续的处理请求函数中 可以用过 c.Get(CtxUserIDKey) 来获取当前请求的用户信息
 }
}

```

controller/request.go

```go
package controller

import (
 "bluebell/middlewares"
 "errors"

 "github.com/gin-gonic/gin"
)

var ErrorUserNotLogin = errors.New("用户未登录")

// getCurrentUser 获取当前登录的用户ID
func getCurrentUser(c *gin.Context) (userID int64, err error) {
 uid, ok := c.Get(middlewares.CtxUserIDKey)
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

 CodeNeedLogin
 CodeInvalidToken
)

var codeMsgMap = map[ResCode]string{
 CodeSuccess:         "success",
 CodeInvalidParam:    "请求参数错误",
 CodeUserExist:       "用户名已存在",
 CodeUserNotExist:    "用户名不存在",
 CodeInvalidPassword: "用户名或密码错误",
 CodeServerBusy:      "服务繁忙",

 CodeNeedLogin:    "需要登录",
 CodeInvalidToken: "无效的Token",
}

func (c ResCode) Msg() string {
 msg, ok := codeMsgMap[c]
 if !ok {
  msg = codeMsgMap[CodeServerBusy]
 }
 return msg
}

```
