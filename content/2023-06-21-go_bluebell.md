+++
title = "bluebell 项目之初始化"
date = 2023-06-21T22:18:17+08:00
description = "bluebell 项目之初始化"
[taxonomies]
tags = ["Go", "项目"]
categories = ["Go", "项目"]
+++

# 01 bluebell 项目之初始化

## 创建项目

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306212220578.png)

### 项目目录

```bash
Code/go/bluebell via 🐹 v1.20.3 via 🅒 base took 2m 5.3s 
➜ tree
.
├── config.yaml
├── controller
├── dao
│   ├── mysql
│   │   └── mysql.go
│   └── redis
│       └── redis.go
├── go.mod
├── go.sum
├── logger
│   └── logger.go
├── logic
├── main.go
├── models
│   └── create_table.sql
├── pkg
│   ├── snowflake
│   │   └── snowflake.go
│   └── sonyflake
│       └── sonyflake.go
├── router
│   └── router.go
├── setting
│   └── setting.go
└── web_app.log

13 directories, 13 files

Code/go/bluebell via 🐹 v1.20.3 via 🅒 base 
➜ 

```

config.yaml

```yaml
name: "web_app"
mode: "dev"
port: 8080
version: "v0.0.2"
start_time: "2023-06-22"
machine_id: 1

log:
  level: "debug"
  filename: "web_app.log"
  max_size: 30
  max_age: 30
  max_backups: 7

mysql:
  host: "127.0.0.1"
  port: 3306
  user: "root"
  password: "12345678"
  dbname: "bluebell"
  max_open_conns: 200
  max_idle_conns: 50

redis:
  host: "127.0.0.1"
  port: 6379
  password: ""
  db: 0
  pool_size: 100
```

setting/setting.go

```go
package setting

import (
 "fmt"

 "github.com/fsnotify/fsnotify"
 "github.com/spf13/viper"
)

// Conf 全局变量，用来保存程序的所有配置信息
var Conf = new(AppConfig)

type AppConfig struct {
 Name      string `mapstructure:"name"`
 Mode      string `mapstructure:"mode"`
 Version   string `mapstructure:"version"`
 StartTime string `mapstructure:"start_time"`
 MachineID int64  `mapstructure:"machine_id"`
 Port      int    `mapstructure:"port"`

 *LogConfig   `mapstructure:"log"`
 *MySQLConfig `mapstructure:"mysql"`
 *RedisConfig `mapstructure:"redis"`
}

type LogConfig struct {
 Level      string `mapstructure:"level"`
 Filename   string `mapstructure:"filename"`
 MaxSize    int    `mapstructure:"max_size"`
 MaxAge     int    `mapstructure:"max_age"`
 MaxBackups int    `mapstructure:"max_backups"`
}

type MySQLConfig struct {
 Host         string `mapstructure:"host"`
 User         string `mapstructure:"user"`
 Password     string `mapstructure:"password"`
 DbName       string `mapstructure:"db_name"`
 Port         int    `mapstructure:"port"`
 MaxOpenConns int    `mapstructure:"max_open_conns"`
 MaxIdleConns int    `mapstructure:"max_idle_conns"`
}

type RedisConfig struct {
 Host     string `mapstructure:"host"`
 Password string `mapstructure:"password"`
 Port     int    `matstructure:"port"`
 DB       int    `mapstructure:"db"`
 PoolSize int    `mapstructure:"pool_size"`
}

func Init(filePath string) (err error) {
 // 方式1：直接指定配置文件路径（相对路径或者绝对路径）
 // 相对路径：相对执行的可执行文件的相对路径
 // viper.SetConfigFile("./conf/config.yaml")
 // 绝对路径：系统中实际的文件路径
 // viper.SetConfigFile("/Users/qiaopengjun/Desktop/web_app2 /conf/config.yaml")

 // 方式2：指定配置文件名和配置文件的位置，viper 自行查找可用的配置文件
 // 配置文件名不需要带后缀
 // 配置文件位置可配置多个
 // 注意：viper 是根据文件名查找，配置目录里不要有同名的配置文件。
 // 例如：在配置目录 ./conf 中不要同时存在 config.yaml、config.json

 // 读取配置文件
 viper.SetConfigFile(filePath) // 指定配置文件路径
 //viper.SetConfigName("config")        // 配置文件名称(无扩展名)
 //viper.AddConfigPath(".")             // 指定查找配置文件的路径（这里使用相对路径）可以配置多个
 //viper.AddConfigPath("./conf")        // 指定查找配置文件的路径（这里使用相对路径）可以配置多个
 // SetConfigType设置远端源返回的配置类型，例如:“json”。
 // 基本上是配合远程配置中心使用的，告诉viper 当前的数据使用什么格式去解析
 //viper.SetConfigType("yaml")

 err = viper.ReadInConfig() // 查找并读取配置文件
 if err != nil {            // 处理读取配置文件的错误
  fmt.Printf("viper.ReadInConfig failed, error: %v\n", err)
  return
 }

 // 把读取到的配置信息反序列化到 Conf 变量中
 if err = viper.Unmarshal(Conf); err != nil {
  fmt.Printf("viper unmarshal failed, error: %v\n", err)
  return
 }

 // 实时监控配置文件的变化 WatchConfig 开始监视配置文件的更改。
 viper.WatchConfig()
 // OnConfigChange设置配置文件更改时调用的事件处理程序。
 // 当配置文件变化之后调用的一个回调函数
 viper.OnConfigChange(func(e fsnotify.Event) {
  fmt.Println("Config file changed:", e.Name)
  if err = viper.Unmarshal(Conf); err != nil {
   fmt.Printf("viper unmarshal OnConfigChange failed, error: %v\n", err)
  }
 })

 return
}

```

logger/logger.go

```go
package logger

import (
 "bluebell/setting"
 "net"
 "net/http"
 "net/http/httputil"
 "os"
 "runtime/debug"
 "strings"
 "time"

 "github.com/gin-gonic/gin"
 "go.uber.org/zap"
 "go.uber.org/zap/zapcore"
 "gopkg.in/natefinch/lumberjack.v2"
)

func Init(cfg *setting.LogConfig) (err error) {
 writeSyncer := getLogWriter(
  cfg.Filename,
  cfg.MaxSize,
  cfg.MaxBackups,
  cfg.MaxAge,
 )
 encoder := getEncoder()
 var l = new(zapcore.Level)
 err = l.UnmarshalText([]byte(cfg.Level))
 if err != nil {
  return
 }
 // NewCore创建一个向WriteSyncer写入日志的Core。

 // A WriteSyncer is an io.Writer that can also flush any buffered data. Note
 // that *os.File (and thus, os.Stderr and os.Stdout) implement WriteSyncer.

 // LevelEnabler决定在记录消息时是否启用给定的日志级别。
 // Each concrete Level value implements a static LevelEnabler which returns
 // true for itself and all higher logging levels. For example WarnLevel.Enabled()
 // will return true for WarnLevel, ErrorLevel, DPanicLevel, PanicLevel, and
 // FatalLevel, but return false for InfoLevel and DebugLevel.
 core := zapcore.NewCore(encoder, writeSyncer, l)

 // New constructs a new Logger from the provided zapcore.Core and Options. If
 // the passed zapcore.Core is nil, it falls back to using a no-op
 // implementation.

 // AddCaller configures the Logger to annotate each message with the filename,
 // line number, and function name of zap's caller. See also WithCaller.
 logger := zap.New(core, zap.AddCaller())
 // 替换 zap 库中全局的logger
 zap.ReplaceGlobals(logger)
 return
 // Sugar封装了Logger，以提供更符合人体工程学的API，但速度略慢。糖化一个Logger的成本非常低，
 // 因此一个应用程序同时使用Loggers和SugaredLoggers是合理的，在性能敏感代码的边界上在它们之间进行转换。
 //sugarLogger = logger.Sugar()
}

func getEncoder() zapcore.Encoder {
 // NewJSONEncoder创建了一个快速、低分配的JSON编码器。编码器适当地转义所有字段键和值。
 // NewProductionEncoderConfig returns an opinionated EncoderConfig for
 // production environments.
 encoderConfig := zap.NewProductionEncoderConfig()
 encoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
 encoderConfig.TimeKey = "time"
 encoderConfig.EncodeLevel = zapcore.CapitalLevelEncoder
 encoderConfig.EncodeDuration = zapcore.SecondsDurationEncoder
 encoderConfig.EncodeCaller = zapcore.ShortCallerEncoder
 return zapcore.NewJSONEncoder(encoderConfig)
}

func getLogWriter(filename string, maxSize, maxBackup, maxAge int) zapcore.WriteSyncer {
 // Logger is an io.WriteCloser that writes to the specified filename.
 // 日志记录器在第一次写入时打开或创建日志文件。如果文件存在并且小于MaxSize兆字节，则lumberjack将打开并追加该文件。
 // 如果该文件存在并且其大小为>= MaxSize兆字节，
 // 则通过将当前时间放在文件扩展名(或者如果没有扩展名则放在文件名的末尾)的名称中的时间戳中来重命名该文件。
 // 然后使用原始文件名创建一个新的日志文件。
 // 每当写操作导致当前日志文件超过MaxSize兆字节时，将关闭当前文件，重新命名，并使用原始名称创建新的日志文件。
 // 因此，您给Logger的文件名始终是“当前”日志文件。
 // 如果MaxBackups和MaxAge均为0，则不会删除旧的日志文件。
 lumberJackLogger := &lumberjack.Logger{
  // Filename是要写入日志的文件。备份日志文件将保留在同一目录下
  Filename: filename,
  // MaxSize是日志文件旋转之前的最大大小(以兆字节为单位)。默认为100兆字节。
  MaxSize: maxSize, // M
  // MaxBackups是要保留的旧日志文件的最大数量。默认是保留所有旧的日志文件(尽管MaxAge仍然可能导致它们被删除)。
  MaxBackups: maxBackup, // 备份数量
  // MaxAge是根据文件名中编码的时间戳保留旧日志文件的最大天数。
  // 请注意，一天被定义为24小时，由于夏令时、闰秒等原因，可能与日历日不完全对应。默认情况下，不根据时间删除旧的日志文件。
  MaxAge: maxAge, // 备份天数
  // Compress决定是否应该使用gzip压缩旋转的日志文件。默认情况下不执行压缩。
  Compress: false, // 是否压缩
 }

 return zapcore.AddSync(lumberJackLogger)
}

// GinLogger
func GinLogger() gin.HandlerFunc {
 return func(c *gin.Context) {
  start := time.Now()
  path := c.Request.URL.Path
  query := c.Request.URL.RawQuery
  c.Next() // 执行后续中间件

  // Since returns the time elapsed since t.
  // It is shorthand for time.Now().Sub(t).
  cost := time.Since(start)
  zap.L().Info(path,
   zap.Int("status", c.Writer.Status()),
   zap.String("method", c.Request.Method),
   zap.String("path", path),
   zap.String("query", query),
   zap.String("ip", c.ClientIP()),
   zap.String("user-agent", c.Request.UserAgent()),
   zap.String("errors", c.Errors.ByType(gin.ErrorTypePrivate).String()),
   zap.Duration("cost", cost), // 运行时间
  )
 }
}

// GinRecovery
func GinRecovery(stack bool) gin.HandlerFunc {
 return func(c *gin.Context) {
  defer func() {
   if err := recover(); err != nil {
    // Check for a broken connection, as it is not really a
    // condition that warrants a panic stack trace.
    var brokenPipe bool
    if ne, ok := err.(*net.OpError); ok {
     if se, ok := ne.Err.(*os.SyscallError); ok {
      if strings.Contains(strings.ToLower(se.Error()), "broken pipe") || strings.Contains(strings.ToLower(se.Error()), "connection reset by peer") {
       brokenPipe = true
      }
     }
    }

    httpRequest, _ := httputil.DumpRequest(c.Request, false)
    if brokenPipe {
     zap.L().Error(c.Request.URL.Path,
      zap.Any("error", err),
      zap.String("request", string(httpRequest)),
     )
     // If the connection is dead, we can't write a status to it.
     c.Error(err.(error)) // nolint: errcheck
     c.Abort()
     return
    }

    if stack {
     zap.L().Error("[Recovery from panic]",
      zap.Any("error", err),
      zap.String("request", string(httpRequest)),
      zap.String("stack", string(debug.Stack())),
     )
    } else {
     zap.L().Error("[Recovery from panic]",
      zap.Any("error", err),
      zap.String("request", string(httpRequest)),
     )
    }
    c.AbortWithStatus(http.StatusInternalServerError)
   }
  }()
  c.Next()
 }
}

```

dao/mysql/mysql.go

```go
package mysql

import (
 "bluebell/setting"
 "fmt"

 "go.uber.org/zap"

 _ "github.com/go-sql-driver/mysql" // 匿名导入 自动执行 init()
 "github.com/jmoiron/sqlx"
)

var db *sqlx.DB

func Init(cfg *setting.MySQLConfig) (err error) {
 //DSN (Data Source Name) Sprintf根据格式说明符进行格式化，并返回结果字符串。
 dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=utf8mb4&parseTime=true",
  cfg.User,
  cfg.Password,
  cfg.Host,
  cfg.Port,
  cfg.DbName,
 )
 // 连接到数据库并使用ping进行验证。
 // 也可以使用 MustConnect MustConnect连接到数据库，并在出现错误时恐慌 panic。
 db, err = sqlx.Connect("mysql", dsn)
 if err != nil {
  zap.L().Error("connect DB failed", zap.Error(err))
  return
 }
 db.SetMaxOpenConns(cfg.MaxOpenConns) // 设置数据库的最大打开连接数。
 db.SetMaxIdleConns(cfg.MaxIdleConns) // 设置空闲连接池中的最大连接数。
 return
}

func Close() {
 _ = db.Close()
}

```

dao/redis/redis.go

```go
package redis

import (
 "bluebell/setting"
 "context"
 "fmt"
 "github.com/redis/go-redis/v9"
)

// 声明一个全局的 rdb 变量
var rdb *redis.Client

// 初始化连接
func Init(cfg *setting.RedisConfig) (err error) {
 // NewClient将客户端返回给Options指定的Redis Server。
 // Options保留设置以建立redis连接。
 rdb = redis.NewClient(&redis.Options{
  Addr:     fmt.Sprintf("%s:%d", cfg.Host, cfg.Port),
  Password: cfg.Password, // 没有密码，默认值
  DB:       cfg.DB,       // 默认DB 0 连接到服务器后要选择的数据库。
  PoolSize: cfg.PoolSize, // 最大套接字连接数。 默认情况下，每个可用CPU有10个连接，由runtime.GOMAXPROCS报告。
 })

 // Background返回一个非空的Context。它永远不会被取消，没有值，也没有截止日期。
 // 它通常由main函数、初始化和测试使用，并作为传入请求的顶级上下文
 ctx := context.Background()

 _, err = rdb.Ping(ctx).Result()
 return
}

func Close() {
 _ = rdb.Close()
}

```

router/router.go

```go
package router

import (
 "bluebell/logger"
 "bluebell/setting"
 "github.com/gin-gonic/gin"
 "net/http"
)

func Setup() *gin.Engine {
 r := gin.New()
 r.Use(logger.GinLogger(), logger.GinRecovery(true))

 r.GET("/version", func(context *gin.Context) {
  context.String(http.StatusOK, setting.Conf.Version)
 })
 return r
}

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
 router := router.Setup()
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

models/create_table.sql

```sql

CREATE TABLE `user` (
                        `id` bigint(20) NOT NULL AUTO_INCREMENT,
                        `user_id` bigint(20) NOT NULL,
                        `username` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
                        `password` varchar(64) COLLATE utf8mb4_general_ci NOT NULL,
                        `email` varchar(64) COLLATE utf8mb4_general_ci,
                        `gender` tinyint(4) NOT NULL DEFAULT '0',
                        `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        PRIMARY KEY (`id`),
                        UNIQUE KEY `idx_username` (`username`) USING BTREE,
                        UNIQUE KEY `idx_user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

### 连接数据库

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306212253703.png)

### 创建 bluebell 数据库

```sql
➜ mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 826
Server version: 8.0.32 Homebrew

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| db_xuanke          |
| information_schema |
| mingde             |
| mysql              |
| mysql_test         |
| nucleic            |
| performance_schema |
| sql_test           |
| sys                |
| win_pro            |
| win_pro_test       |
+--------------------+
11 rows in set (0.01 sec)

mysql> create database if not exists bluebell;
Query OK, 1 row affected (0.02 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| bluebell           |
| db_xuanke          |
| information_schema |
| mingde             |
| mysql              |
| mysql_test         |
| nucleic            |
| performance_schema |
| sql_test           |
| sys                |
| win_pro            |
| win_pro_test       |
+--------------------+
12 rows in set (0.00 sec)

mysql>
```

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306212303976.png)

### 创建用户 user 表

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306212308456.png)

## 分布式ID生成器

### 分布式ID的特点

- 全局唯一性：不能出现有重复的ID标识，这是基本要求。
- 递增性：确保生成ID对于用户或业务是递增的。
- 高可用性：确保任何时候都能生成正确的ID。
- 高性能性：在高并发的环境下依然表现良好。

不仅仅是用于用户ID，实际互联网中有很多场景需要能够生成类似MySQL自增ID这样不断增大，同时又不会重复的ID。以支持业务中的高并发场景。

比较典型的场景有：电商促销时短时间内会有大量的订单涌入到系统，比如每秒 10w+；明星出轨时微博短时间内会产生大量的相关微博转发和评论消息。在这些业务场景下将数据插入数据库之前，我们需要给这样订单和消息先分配一个唯一ID，然后再保存到数据库中。对这个ID的要求是希望其中能带有一些时间信息，这样即使我们后端的系统对消息进行了分库分表，也能够以时间顺序对这些消息进行排序。

### Snowflake  算法介绍

雪花算法，它是 Twitter 开源的由64位整数组成分布式ID，性能较高，并且在单机上递增。

snowflake-64bit

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306212339110.png)

1. **第一位** 占用 1 bit，其值始终是0，没有实际作用。
2. **时间戳** 占用 41 bit，单位为毫秒，总共可以容纳约69年的时间。当然我们的时间毫秒技术不会真的从1970年开始记，那样我们的系统跑到 2039/9/7 23:47:35 就不能用了，所以这里的时间戳只是相对于某个时间的增量，比如我们的系统上线是2023-07-01，那么我们完全可以把这个 timestamp 当作是从 2023-07-01 00:00:00.000 的偏移量。
3. **工作机器ID** 占用 10 bit，其中高位5bit是数据中心ID，低位5bit是工作节点ID，最多可以容纳1024个节点。
4. **序列号** 占用 12 bit，用来记录同毫秒内产生的不同ID。每个节点每毫秒0开始不断累加，最多可以累加到4095，同一毫秒一共可以产生4096个ID。

SnowFlake 算法在同一毫秒内最多可以生成多少个全局唯一ID呢？

**同一毫秒的ID数量 = 1024 * 4096 = 4194304**

### Snowflake 的 Go实现

#### 一、snowflake：<https:://github.com/bwmarrin/snowflake>

<https://github.com/bwmarrin/snowflake> 是一个相当轻量化的 snowflake 的Go实现。

### How it Works

Each time you generate an ID, it works, like this.

- A timestamp with millisecond precision is stored using 41 bits of the ID.
- Then the NodeID is added in subsequent bits.
- Then the Sequence Number is added, starting at 0 and incrementing for each ID generated in the same millisecond. If you generate enough IDs in the same millisecond that the sequence would roll over or overfill then the generate function will pause until the next millisecond.

The default Twitter format shown below.

```
+--------------------------------------------------------------------------+
| 1 Bit Unused | 41 Bit Timestamp |  10 Bit NodeID  |   12 Bit Sequence ID |
+--------------------------------------------------------------------------+
```

Using the default settings, this allows for 4096 unique IDs to be generated every millisecond, per Node ID.

### 入门

#### 安装

This assumes you already have a working Go environment, if not please see [this page](https://golang.org/doc/install) first.

```
go get github.com/bwmarrin/snowflake
```

#### 使用

将包导入到项目中，然后使用唯一的节点号构建一个新的雪花节点。默认设置允许节点编号范围从0到1023。如果已经设置了自定义 NodeBits 值，则需要计算节点编号范围。使用节点对象调用 Generate ()方法生成并返回唯一的雪花 ID。

请记住，您创建的每个节点必须具有唯一的节点号，即使是跨多个服务器也是如此。如果不保持节点编号唯一，则生成器不能保证所有节点的 ID 都是唯一的。

**Example Program:**

```go
package main

import (
 "fmt"

 "github.com/bwmarrin/snowflake"
)

func main() {

 // Create a new Node with a Node number of 1
 node, err := snowflake.NewNode(1)
 if err != nil {
  fmt.Println(err)
  return
 }

 // Generate a snowflake ID.
 id := node.Generate()

 // Print out the ID in a few different ways.
 fmt.Printf("Int64  ID: %d\n", id)
 fmt.Printf("String ID: %s\n", id)
 fmt.Printf("Base2  ID: %s\n", id.Base2())
 fmt.Printf("Base64 ID: %s\n", id.Base64())

 // Print out the ID's timestamp
 fmt.Printf("ID Time  : %d\n", id.Time())

 // Print out the ID's node number
 fmt.Printf("ID Node  : %d\n", id.Node())

 // Print out the ID's sequence number
 fmt.Printf("ID Step  : %d\n", id.Step())

  // Generate and print, all in one.
  fmt.Printf("ID       : %d\n", node.Generate().Int64())
}
```

示例：snowflake.go

```go
package main

import (
 "fmt"
 "github.com/bwmarrin/snowflake"
 "time"
)

var node *snowflake.Node

func Init(startTime string, machineID int64) (err error) {
 var st time.Time
 st, err = time.Parse("2006-01-02", startTime)
 if err != nil {
  return
 }
 snowflake.Epoch = st.UnixNano() / 1000000
 node, err = snowflake.NewNode(machineID)
 return
}

func GenID() int64 {
 return node.Generate().Int64()
}

func main() {
 if err := Init("2023-06-01", 1); err != nil {
  fmt.Printf("init failed with error: %v\n", err)
  return
 }
 id := GenID()
 fmt.Printf("generation started with id: %v\n", id)
}

```

#### 二、Sonyflake：<https://github.com/sony/sonyflake>

Sonyflake 是 Sony公司的一个开源项目，其基本思路和 snowflake 差不多，不过位分配上稍有不同：

| 1 Bit Unused | 39 Bit Timestamp | 8 Bit Sequence ID | 16 Bit Machine ID |
| ------------ | ---------------- | ----------------- | ----------------- |

这里的时间只用了39个bit，但时间的单位变成了10ms，所以理论上比41位表示的时间还要久（174年）。

Sequence ID 和之前的定义一致，Machine ID 其实就是节点ID。

Sonyflake is a distributed unique ID generator inspired by [Twitter's Snowflake](https://blog.twitter.com/2010/announcing-snowflake).

Sonyflake 是一个分布式唯一 ID 生成器，灵感来自 Twitter 的 Snowflake。

Sonyflake 关注许多主机/核心环境的生命周期和性能。所以它和雪花有不同的位分配。Sonyflake ID 由

```
39 bits for time in units of 10 msec
 8 bits for a sequence number
16 bits for a machine id
```

因此，Sonyflake 有以下优点和缺点:

- 寿命(174年)比雪花(69年)长
- 它可以工作在更多的分布式机器(2 ^ 16)比雪花(2 ^ 10)
- 它最多可以在一台机器/线程中每10毫秒生成2 ^ 8个 ID (比 Snowflake 慢)

但是，如果希望在单个主机中获得更高的生成速率，可以使用 goroutines 轻松地并发运行多个 Sonyflake ID 生成器。

#### 安装

```bash
go get github.com/sony/sonyflake
```

#### 使用

函数 NewSonyflake 创建一个新的 Sonyflake 实例。

```go
func NewSonyflake(st Settings) *Sonyflake
```

您可以通过 struct 设置来配置 Sonyflake:

```go
type Settings struct {
 StartTime      time.Time
 MachineID      func() (uint16, error)
 CheckMachineID func(uint16) bool
}
```

- StartTime 是将 Sonyflake 时间定义为运行时间的时间。如果 StartTime 为0，则 Sonyflake 的开始时间设置为“2014-09-0100:00:00 + 0000 UTC”。如果 StartTime 超前于当前时间，则不创建 Sonyflake。
- MachineID 返回 Sonyflake 实例的唯一 ID。如果 MachineID 返回错误，则不会创建 Sonyflake。如果 MachineID 为空，则使用默认 MachineID。默认 MachineID 返回私有 IP 地址的较低的16位。
- CheckMachineID 验证机器 ID 的唯一性。如果 CheckMachineID 返回 false，则不会创建 Sonyflake。如果 CheckMachineID 为空，则不执行验证。

为了获得一个新的唯一 ID，您只需要调用方法 NextID。

```go
func (sf *Sonyflake) NextID() (uint64, error)
```

NextID 可以继续从 StartTime 生成 ID 长达174年。但是在 Sonyflake 时间超过限制之后，NextID 返回一个错误。

> 注意: Sonyflake 目前不使用最重要的 ID 位，因此可以安全地将 Sonyflake ID 从 uint64转换为 int64。

示例：sonyflake.go

```go
package main

import (
 "fmt"
 "github.com/sony/sonyflake"
 "time"
)

var (
 sonyFlake     *sonyflake.Sonyflake
 sonyMachineID uint16
)

func getMachineID() (uint16, error) {
 return sonyMachineID, nil
}

// Init 需传入当前的机器ID
func Init(startTime string, machineId uint16) (err error) {
 sonyMachineID = machineId
 var st time.Time
 st, err = time.Parse("2006-01-02", startTime)
 if err != nil {
  return err
 }
 settings := sonyflake.Settings{
  StartTime: st,
  MachineID: getMachineID,
 }
 sonyFlake = sonyflake.NewSonyflake(settings)
 return
}

// GenID 生成ID
func GenID() (id uint64, err error) {
 if sonyFlake == nil {
  err = fmt.Errorf("sony flake not initialized")
  return
 }
 id, err = sonyFlake.NextID()
 return
}

func main() {
 if err := Init("2023-06-01", 1); err != nil {
  fmt.Printf("Init failed, err: %v\n", err)
  return
 }
 id, _ := GenID()
 fmt.Println("id: ", id)
}

```

运行

```bash
Code/go/bluebell via 🐹 v1.20.3 via 🅒 base 
➜ go run pkg/sonyflake/sonyflake.go
id:  3064864318685185

Code/go/bluebell via 🐹 v1.20.3 via 🅒 base 
➜ go run pkg/snowflake/snowflake.go
generation started with id: 7662201183670272

Code/go/bluebell via 🐹 v1.20.3 via 🅒 base 
➜ 

```

### 运行项目

```go
Code/go/bluebell via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go config.yaml
config.yaml
[config.yaml]
NArg 1
NFlag 0
generation started with id: 91271540510720
[GIN-debug] [WARNING] Running in "debug" mode. Switch to "release" mode in production.
 - using env:   export GIN_MODE=release
 - using code:  gin.SetMode(gin.ReleaseMode)

[GIN-debug] GET    /version                  --> bluebell/router.Setup.func1 (3 handlers)



```

### git 提交

```bash
Code/go/bluebell via 🐹 v1.20.3 via 🅒 base took 13m 43.2s 
➜ git init                     
提示：使用 'master' 作为初始分支的名称。这个默认分支名称可能会更改。要在新仓库中
提示：配置使用初始分支名，并消除这条警告，请执行：
提示：
提示：  git config --global init.defaultBranch <名称>
提示：
提示：除了 'master' 之外，通常选定的名字有 'main'、'trunk' 和 'development'。
提示：可以通过以下命令重命名刚创建的分支：
提示：
提示：  git branch -m <name>
已初始化空的 Git 仓库于 /Users/qiaopengjun/Code/go/bluebell/.git/

bluebell on  master [?] via 🐹 v1.20.3 via 🅒 base 
➜ git add .

bluebell on  master [+] via 🐹 v1.20.3 via 🅒 base 
➜ git commit -m "bluebell 项目初始化"      
[master（根提交） d07c5a5] bluebell 项目初始化
 19 files changed, 1795 insertions(+)
 create mode 100644 .idea/.gitignore
 create mode 100644 .idea/bluebell.iml
 create mode 100644 .idea/dataSources.xml
 create mode 100644 .idea/dbnavigator.xml
 create mode 100644 .idea/modules.xml
 create mode 100644 .idea/vcs.xml
 create mode 100644 config.yaml
 create mode 100644 dao/mysql/mysql.go
 create mode 100644 dao/redis/redis.go
 create mode 100644 go.mod
 create mode 100644 go.sum
 create mode 100644 logger/logger.go
 create mode 100644 main.go
 create mode 100644 models/create_table.sql
 create mode 100644 pkg/snowflake/snowflake.go
 create mode 100644 pkg/sonyflake/sonyflake.go
 create mode 100644 router/router.go
 create mode 100644 setting/setting.go
 create mode 100644 web_app.log

bluebell on  master via 🐹 v1.20.3 via 🅒 base 
➜ git branch -M main                     

bluebell on  main via 🐹 v1.20.3 via 🅒 base 
➜ git remote add origin git@github.com:qiaopengjun5162/bluebell.git                                              

bluebell on  main via 🐹 v1.20.3 via 🅒 base 
➜ git push -u origin main
To github.com:qiaopengjun5162/bluebell.git
 ! [rejected]        main -> main (fetch first)
错误：无法推送一些引用到 'github.com:qiaopengjun5162/bluebell.git'
提示：更新被拒绝，因为远程仓库包含您本地尚不存在的提交。这通常是因为另外
提示：一个仓库已向该引用进行了推送。再次推送前，您可能需要先整合远程变更
提示：（如 'git pull ...'）。
提示：详见 'git push --help' 中的 'Note about fast-forwards' 小节。

bluebell on  main via 🐹 v1.20.3 via 🅒 base took 3.7s 
➜ git fetch origin
remote: Enumerating objects: 5, done.
remote: Counting objects: 100% (5/5), done.
remote: Compressing objects: 100% (4/4), done.
remote: Total 5 (delta 0), reused 0 (delta 0), pack-reused 0
展开对象中: 100% (5/5), 1.61 KiB | 549.00 KiB/s, 完成.
来自 github.com:qiaopengjun5162/bluebell
 * [新分支]          main       -> origin/main

bluebell on  main via 🐹 v1.20.3 via 🅒 base took 5.1s 
➜ git merge origin/main
致命错误：拒绝合并无关的历史

bluebell on  main via 🐹 v1.20.3 via 🅒 base 
➜ git pull origin main  --allow-unrelated-histories
来自 github.com:qiaopengjun5162/bluebell
 * branch            main       -> FETCH_HEAD
提示：您有偏离的分支，需要指定如何调和它们。您可以在执行下一次
提示：pull 操作之前执行下面一条命令来抑制本消息：
提示：
提示：  git config pull.rebase false  # 合并
提示：  git config pull.rebase true   # 变基
提示：  git config pull.ff only       # 仅快进
提示：
提示：您可以将 "git config" 替换为 "git config --global" 以便为所有仓库设置
提示：缺省的配置项。您也可以在每次执行 pull 命令时添加 --rebase、--no-rebase，
提示：或者 --ff-only 参数覆盖缺省设置。
致命错误：需要指定如何调和偏离的分支。

bluebell on  main via 🐹 v1.20.3 via 🅒 base took 4.4s 
➜ git pull origin main  --allow-unrelated-histories
来自 github.com:qiaopengjun5162/bluebell
 * branch            main       -> FETCH_HEAD
提示：您有偏离的分支，需要指定如何调和它们。您可以在执行下一次
提示：pull 操作之前执行下面一条命令来抑制本消息：
提示：
提示：  git config pull.rebase false  # 合并
提示：  git config pull.rebase true   # 变基
提示：  git config pull.ff only       # 仅快进
提示：
提示：您可以将 "git config" 替换为 "git config --global" 以便为所有仓库设置
提示：缺省的配置项。您也可以在每次执行 pull 命令时添加 --rebase、--no-rebase，
提示：或者 --ff-only 参数覆盖缺省设置。
致命错误：需要指定如何调和偏离的分支。

bluebell on  main via 🐹 v1.20.3 via 🅒 base took 4.0s 
➜  git config pull.rebase false

bluebell on  main via 🐹 v1.20.3 via 🅒 base 
➜ git pull origin main  --allow-unrelated-histories
来自 github.com:qiaopengjun5162/bluebell
 * branch            main       -> FETCH_HEAD
Merge made by the 'ort' strategy.
 .gitignore | 21 +++++++++++++++++++++
 LICENSE    | 21 +++++++++++++++++++++
 README.md  |  1 +
 3 files changed, 43 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 LICENSE
 create mode 100644 README.md

bluebell on  main via 🐹 v1.20.3 via 🅒 base took 1m 45.2s 
➜ git push -u origin main                          
枚举对象中: 35, 完成.
对象计数中: 100% (35/35), 完成.
使用 12 个线程进行压缩
压缩对象中: 100% (26/26), 完成.
写入对象中: 100% (34/34), 36.66 KiB | 9.16 MiB/s, 完成.
总共 34（差异 1），复用 0（差异 0），包复用 0
remote: Resolving deltas: 100% (1/1), done.
To github.com:qiaopengjun5162/bluebell.git
   f0ed1c1..f5bbf3a  main -> main
分支 'main' 设置为跟踪 'origin/main'。

bluebell on  main via 🐹 v1.20.3 via 🅒 base took 4.5s 
➜ 

```
