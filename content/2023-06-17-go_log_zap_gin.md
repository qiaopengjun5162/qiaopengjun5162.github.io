+++
title = "Go 语言之在 gin 框架中使用 zap 日志库"
date = 2023-06-17T14:31:35+08:00
description = "Go 语言之在 gin 框架中使用 zap 日志库"
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# Go 语言之在 gin 框架中使用 zap 日志库

## gin 框架默认使用的是自带的日志

### `gin.Default()`的源码 Logger(), Recovery()

```go
func Default() *Engine {
 debugPrintWARNINGDefault()
 engine := New()
 engine.Use(Logger(), Recovery())
 return engine
}

// Logger instances a Logger middleware that will write the logs to gin.DefaultWriter.
// By default, gin.DefaultWriter = os.Stdout.
func Logger() HandlerFunc {
 return LoggerWithConfig(LoggerConfig{})
}

// Recovery returns a middleware that recovers from any panics and writes a 500 if there was one.
func Recovery() HandlerFunc {
 return RecoveryWithWriter(DefaultErrorWriter)
}

// RecoveryWithWriter returns a middleware for a given writer that recovers from any panics and writes a 500 if there was one.
func RecoveryWithWriter(out io.Writer, recovery ...RecoveryFunc) HandlerFunc {
 if len(recovery) > 0 {
  return CustomRecoveryWithWriter(out, recovery[0])
 }
 return CustomRecoveryWithWriter(out, defaultHandleRecovery)
}

// CustomRecoveryWithWriter returns a middleware for a given writer that recovers from any panics and calls the provided handle func to handle it.
func CustomRecoveryWithWriter(out io.Writer, handle RecoveryFunc) HandlerFunc {
 var logger *log.Logger
 if out != nil {
  logger = log.New(out, "\n\n\x1b[31m", log.LstdFlags)
 }
 return func(c *Context) {
  defer func() {
   if err := recover(); err != nil {
    // Check for a broken connection, as it is not really a
    // condition that warrants a panic stack trace.
    var brokenPipe bool
    if ne, ok := err.(*net.OpError); ok {
     var se *os.SyscallError
     if errors.As(ne, &se) {
      seStr := strings.ToLower(se.Error())
      if strings.Contains(seStr, "broken pipe") ||
       strings.Contains(seStr, "connection reset by peer") {
       brokenPipe = true
      }
     }
    }
    if logger != nil {
     stack := stack(3)
     httpRequest, _ := httputil.DumpRequest(c.Request, false)
     headers := strings.Split(string(httpRequest), "\r\n")
     for idx, header := range headers {
      current := strings.Split(header, ":")
      if current[0] == "Authorization" {
       headers[idx] = current[0] + ": *"
      }
     }
     headersToStr := strings.Join(headers, "\r\n")
     if brokenPipe {
      logger.Printf("%s\n%s%s", err, headersToStr, reset)
     } else if IsDebugging() {
      logger.Printf("[Recovery] %s panic recovered:\n%s\n%s\n%s%s",
       timeFormat(time.Now()), headersToStr, err, stack, reset)
     } else {
      logger.Printf("[Recovery] %s panic recovered:\n%s\n%s%s",
       timeFormat(time.Now()), err, stack, reset)
     }
    }
    if brokenPipe {
     // If the connection is dead, we can't write a status to it.
     c.Error(err.(error)) //nolint: errcheck
     c.Abort()
    } else {
     handle(c, err)
    }
   }
  }()
  c.Next()
 }
}

```

### 自定义 Logger(), Recovery()

实操

```go
package main

import (
 "github.com/gin-gonic/gin"
 "go.uber.org/zap"
 "go.uber.org/zap/zapcore"
 "gopkg.in/natefinch/lumberjack.v2"
 "net"
 "net/http"
 "net/http/httputil"
 "os"
 "runtime/debug"
 "strings"
 "time"
)

// 定义一个全局 logger 实例
// Logger提供快速、分级、结构化的日志记录。所有方法对于并发使用都是安全的。
// Logger是为每一微秒和每一个分配都很重要的上下文设计的，
// 因此它的API有意倾向于性能和类型安全，而不是简便性。
// 对于大多数应用程序，SugaredLogger在性能和人体工程学之间取得了更好的平衡。
var logger *zap.Logger

// SugaredLogger将基本的Logger功能封装在一个较慢但不那么冗长的API中。任何Logger都可以通过其Sugar方法转换为sugardlogger。
//与Logger不同，SugaredLogger并不坚持结构化日志记录。对于每个日志级别，它公开了四个方法:
//   - methods named after the log level for log.Print-style logging
//   - methods ending in "w" for loosely-typed structured logging
//   - methods ending in "f" for log.Printf-style logging
//   - methods ending in "ln" for log.Println-style logging

// For example, the methods for InfoLevel are:
//
// Info(...any)           Print-style logging
// Infow(...any)          Structured logging (read as "info with")
// Infof(string, ...any)  Printf-style logging
// Infoln(...any)         Println-style logging
var sugarLogger *zap.SugaredLogger

//func main() {
// // 初始化
// InitLogger()
// // Sync调用底层Core的Sync方法，刷新所有缓冲的日志条目。应用程序在退出之前应该注意调用Sync。
// // 在程序退出之前，把缓冲区里的日志刷到磁盘上
// defer logger.Sync()
// simpleHttpGet("www.baidu.com")
// simpleHttpGet("http://www.baidu.com")
//
// for i := 0; i < 10000; i++ {
//  logger.Info("test lumberjack for log rotate....")
// }
//}

func main() {
 InitLogger()
 //r := gin.Default()

 r := gin.New()
 r.Use(GinLogger(logger), GinRecovery(logger, true))
 r.GET("/hello", func(c *gin.Context) {
  c.String(http.StatusOK, "hello xiaoqiao!")
 })
 r.Run()
}

// GinLogger
func GinLogger(logger *zap.Logger) gin.HandlerFunc {
 return func(c *gin.Context) {
  start := time.Now()
  path := c.Request.URL.Path
  query := c.Request.URL.RawQuery
  c.Next() // 执行后续中间件

  // Since returns the time elapsed since t.
  // It is shorthand for time.Now().Sub(t).
  cost := time.Since(start)
  logger.Info(path,
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
func GinRecovery(logger *zap.Logger, stack bool) gin.HandlerFunc {
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
     logger.Error(c.Request.URL.Path,
      zap.Any("error", err),
      zap.String("request", string(httpRequest)),
     )
     // If the connection is dead, we can't write a status to it.
     c.Error(err.(error)) // nolint: errcheck
     c.Abort()
     return
    }

    if stack {
     logger.Error("[Recovery from panic]",
      zap.Any("error", err),
      zap.String("request", string(httpRequest)),
      zap.String("stack", string(debug.Stack())),
     )
    } else {
     logger.Error("[Recovery from panic]",
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

func InitLogger() {
 writeSyncer := getLogWriter()
 encoder := getEncoder()
 // NewCore创建一个向WriteSyncer写入日志的Core。

 // A WriteSyncer is an io.Writer that can also flush any buffered data. Note
 // that *os.File (and thus, os.Stderr and os.Stdout) implement WriteSyncer.

 // LevelEnabler决定在记录消息时是否启用给定的日志级别。
 // Each concrete Level value implements a static LevelEnabler which returns
 // true for itself and all higher logging levels. For example WarnLevel.Enabled()
 // will return true for WarnLevel, ErrorLevel, DPanicLevel, PanicLevel, and
 // FatalLevel, but return false for InfoLevel and DebugLevel.
 core := zapcore.NewCore(encoder, writeSyncer, zapcore.DebugLevel)

 // New constructs a new Logger from the provided zapcore.Core and Options. If
 // the passed zapcore.Core is nil, it falls back to using a no-op
 // implementation.

 // AddCaller configures the Logger to annotate each message with the filename,
 // line number, and function name of zap's caller. See also WithCaller.
 logger = zap.New(core, zap.AddCaller())
 // Sugar封装了Logger，以提供更符合人体工程学的API，但速度略慢。糖化一个Logger的成本非常低，
 // 因此一个应用程序同时使用Loggers和SugaredLoggers是合理的，在性能敏感代码的边界上在它们之间进行转换。
 sugarLogger = logger.Sugar()
}

func getEncoder() zapcore.Encoder {
 // NewJSONEncoder创建了一个快速、低分配的JSON编码器。编码器适当地转义所有字段键和值。
 // NewProductionEncoderConfig returns an opinionated EncoderConfig for
 // production environments.
 //return zapcore.NewJSONEncoder(zap.NewProductionEncoderConfig())

 // NewConsoleEncoder创建一个编码器，其输出是为人类而不是机器设计的。
 // 它以纯文本格式序列化核心日志条目数据(消息、级别、时间戳等)，并将结构化上下文保留为JSON。
 encoderConfig := zapcore.EncoderConfig{
  TimeKey:        "ts",
  LevelKey:       "level",
  NameKey:        "logger",
  CallerKey:      "caller",
  FunctionKey:    zapcore.OmitKey,
  MessageKey:     "msg",
  StacktraceKey:  "stacktrace",
  LineEnding:     zapcore.DefaultLineEnding,
  EncodeLevel:    zapcore.LowercaseLevelEncoder,
  EncodeTime:     zapcore.ISO8601TimeEncoder,
  EncodeDuration: zapcore.SecondsDurationEncoder,
  EncodeCaller:   zapcore.ShortCallerEncoder,
 }

 return zapcore.NewConsoleEncoder(encoderConfig)
}

//func getLogWriter() zapcore.WriteSyncer {
// // Create创建或截断指定文件。如果文件已经存在，它将被截断。如果该文件不存在，则以模式0666(在umask之前)创建。
// // 如果成功，返回的File上的方法可以用于IO;关联的文件描述符模式为O_RDWR。如果有一个错误，它的类型将是PathError。
// //file, _ := os.Create("./test.log")
// file, err := os.OpenFile("./test.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0644)
// if err != nil {
//  log.Fatalf("open log file failed with error: %v", err)
// }
// // AddSync converts an io.Writer to a WriteSyncer. It attempts to be
// // intelligent: if the concrete type of the io.Writer implements WriteSyncer,
// // we'll use the existing Sync method. If it doesn't, we'll add a no-op Sync.
// return zapcore.AddSync(file)
//}

func getLogWriter() zapcore.WriteSyncer {
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
  Filename: "./test.log",
  // MaxSize是日志文件旋转之前的最大大小(以兆字节为单位)。默认为100兆字节。
  MaxSize: 1, // M
  // MaxBackups是要保留的旧日志文件的最大数量。默认是保留所有旧的日志文件(尽管MaxAge仍然可能导致它们被删除)。
  MaxBackups: 5, // 备份数量
  // MaxAge是根据文件名中编码的时间戳保留旧日志文件的最大天数。
  // 请注意，一天被定义为24小时，由于夏令时、闰秒等原因，可能与日历日不完全对应。默认情况下，不根据时间删除旧的日志文件。
  MaxAge: 30, // 备份天数
  // Compress决定是否应该使用gzip压缩旋转的日志文件。默认情况下不执行压缩。
  Compress: false, // 是否压缩
 }

 return zapcore.AddSync(lumberJackLogger)
}

func simpleHttpGet(url string) {
 // Get向指定的URL发出Get命令。如果响应是以下重定向代码之一，则Get跟随重定向，最多可重定向10个:
 // 301 (Moved Permanently)
 // 302 (Found)
 // 303 (See Other)
 // 307 (Temporary Redirect)
 // 308 (Permanent Redirect)
 // Get is a wrapper around DefaultClient.Get.
 // 使用NewRequest和DefaultClient.Do来发出带有自定义头的请求。
 resp, err := http.Get(url)
 if err != nil {
  // Error在ErrorLevel记录消息。该消息包括在日志站点传递的任何字段，以及日志记录器上积累的任何字段。
  //logger.Error(

  // 错误使用fmt。以Sprint方式构造和记录消息。
  sugarLogger.Error(
   "Error fetching url..",
   zap.String("url", url), // 字符串用给定的键和值构造一个字段。
   zap.Error(err))         // // Error is shorthand for the common idiom NamedError("error", err).
 } else {
  // Info以infollevel记录消息。该消息包括在日志站点传递的任何字段，以及日志记录器上积累的任何字段。
  //logger.Info("Success..",

  // Info使用fmt。以Sprint方式构造和记录消息。
  sugarLogger.Info("Success..",
   zap.String("statusCode", resp.Status),
   zap.String("url", url))
  resp.Body.Close()
 }
}

```

运行并访问：<http://localhost:8080/hello>

```bash
Code/go/zap_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go 
[GIN-debug] [WARNING] Running in "debug" mode. Switch to "release" mode in production.
 - using env:   export GIN_MODE=release
 - using code:  gin.SetMode(gin.ReleaseMode)

[GIN-debug] GET    /hello                    --> main.main.func1 (3 handlers)
[GIN-debug] [WARNING] You trusted all proxies, this is NOT safe. We recommend you to set a value.
Please check https://pkg.go.dev/github.com/gin-gonic/gin#readme-don-t-trust-all-proxies for details.
[GIN-debug] Environment variable PORT is undefined. Using port :8080 by default
[GIN-debug] Listening and serving HTTP on :8080

```

test.log

```
2023-06-17T14:17:08.553+0800 info zap_demo/main.go:42 test lumberjack for log rotate....
2023-06-17T16:48:25.600+0800 info zap_demo/main.go:76 /hello {"status": 200, "method": "GET", "path": "/hello", "query": "", "ip": "::1", "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36", "errors": "", "cost": 0.000057417}
2023-06-17T16:48:25.753+0800 info zap_demo/main.go:76 /favicon.ico {"status": 404, "method": "GET", "path": "/favicon.ico", "query": "", "ip": "::1", "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36", "errors": "", "cost": 0.000000541}

```

其它参考：<https://github.com/gin-contrib/zap>
