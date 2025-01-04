+++
title = "bluebell 项目之使用Refresh token刷新access token模式和限制账号同一时间只能登录一个设备"
date = 2023-06-24T12:26:55+08:00
description = "bluebell 项目之使用Refresh token刷新access token模式和限制账号同一时间只能登录一个设备"
[taxonomies]
tags = ["Go", "项目"]
categories = ["Go", "项目"]
+++

# 09 bluebell 项目之使用Refresh token刷新access token模式和限制账号同一时间只能登录一个设备

## 使用 refresh token 刷新 access token 模式

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306231851685.png)

### 基于 JWT 实现认证实践

前面说的 Token，都是 Access Token，也就是访问资源接口时所需要的 Token，还有另外一种 Token，Refresh Token，通常情况下，Refresh Token 的有效期会比较长，而 Access Token 的有效期比较短，当 Access Token 由于过期而失效时，使用 Refresh Token 就可以获取到新的 Access Token，如果 Refresh Token 也失效了，用户就只能重新登陆了。

在 JWT 的实践中，引入 Refresh Token，将会话管理流程改进如下：

- 客户端使用用户名密码进行认证
- 服务端生成有效时间较短的 Access Token（例如 10 分钟），和有效时间较长的 Refresh Token（例如 7 天）
- 客户端访问需要认证的接口时，携带 Access Token
- 如果 Access Token 没有过期，服务端鉴权后返回给客户端需要的数据
- 如果携带 Access Token 访问需要认证的接口时鉴权失败（例如返回 401 错误），则客户端使用 Refresh Token 向刷新接口申请新的 Access Token
- 如果 Refresh Token 没有过期，服务端向客户端下发新的 Access Token
- 客户端使用新的 Access Token 访问需要认证的接口

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306241300256.png)

后续需要对外提供一个刷新 Token 的接口，前端需要实现一个当 Access Token 过期时自动请求刷新 Token 接口获取新 Access Token 的拦截器。

<https://datatracker.ietf.org/doc/html/rfc6749#section-1.5>

示例：

#### 生成 Access Token 和 Refresh Token

```go
// GenToken 生成 Access Token 和 Refresh Token
func GenToken(UserID int64) (aToken, rToken string, err error) {
 // 创建一个我们自己的声明的数据
 claims := CustomClaims{
  UserID, // 自定义字段
  jwt.RegisteredClaims{
      ExpiresAt:  jwt.NewNumericDate(time.Now().Add(TokenExpireDuration)), // 过期时间
   Issuer:    "bluebell",                                              // 签发人 发行人
  },
 }
 // 加密并获得完整的编码后的字符串 Token
 atoken, err = jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(CustomSecret)
 // Refresh token 不需要存任何自定义数据
 rtoken, err = jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.RegisteredClaims{
      ExpiresAt: jwt.NewNumericDate(time.Now().Add(TokenExpireDuration)), // 过期时间
   Issuer:    "bluebell",                                              // 签发人 发行人
  }).SignedString(CustomSecret)
  // 使用指定的 secret 签名并获得完整的编码后的字符串 Token
 return
}
```

#### 解析 Access Token

```go
// ParseToken 解析 JWT
func ParseToken(tokenString string) (claims *MyClaims, err error) {
  // 解析 Token
  var token *jwt.Token
  claims = new(MyClaims)
  token, err = jwt.ParseWithClaims(tokenString, claims, keyFunc)
  if err !- nil {
    return
  }
  if !token.Valid { // 校验 Token
    err = errors.New("invalid token")
  }
  return
}
```

#### Refresh Token

```go
// RefreshToken 刷新 Access Token
func RefreshToken(aToken, rToken string) (newAToken, newRToken string, err error) {
 // refresh token 无效直接返回
 if _, err := jwt.Parse(rToken, keyFunc); err != nil {
  return
 }
 //  从旧 Access Token 中解析出 claims 数据
 var claims MyClaims
 _, err = jwt.ParseWithClaims(aToken, &claims, keyFunc)
 v, _ := err.(*jwt.ValidationError)
 
 // 当 Access Token 是过期错误，并且 Refresh Token 没有过期时就创建一个新的 Access Token
 if v.Errors == jwt.ValidationErrorExpired {
  return GenToken(claims.UserID)
 }
 return 
}
```

## 限制账号同一时间只能登录一个设备

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306241847681.png)
