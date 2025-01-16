+++
title = "Go 语言之自定义 zap 日志"
date = 2023-06-17T11:06:49+08:00
description = "Go 语言之自定义 zap 日志"
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# Go 语言之自定义 zap 日志

[zap 日志](https://github.com/uber-go/zap)：<https://github.com/uber-go/zap>

## 一、日志写入文件

- `zap.NewProduction`、`zap.NewDevelopment` 是预设配置好的。
- `zap.New` 可自定义配置

### `zap.New`源码

这是构造Logger最灵活的方式，但也是最冗长的方式。

对于典型的用例，高度固执己见的预设(NewProduction、NewDevelopment和NewExample)或Config结构体更方便。

```go
// New constructs a new Logger from the provided zapcore.Core and Options. If
// the passed zapcore.Core is nil, it falls back to using a no-op
// implementation.
//
// This is the most flexible way to construct a Logger, but also the most
// verbose. For typical use cases, the highly-opinionated presets
// (NewProduction, NewDevelopment, and NewExample) or the Config struct are
// more convenient.
//
// For sample code, see the package-level AdvancedConfiguration example.
func New(core zapcore.Core, options ...Option) *Logger {
 if core == nil {
  return NewNop()
 }
 log := &Logger{
  core:        core,
  errorOutput: zapcore.Lock(os.Stderr),
  addStack:    zapcore.FatalLevel + 1,
  clock:       zapcore.DefaultClock,
 }
 return log.WithOptions(options...)
}
```

### zapcore.Core 源码

```go
// Core is a minimal, fast logger interface. It's designed for library authors
// to wrap in a more user-friendly API.
type Core interface {
 LevelEnabler

 // With adds structured context to the Core.
 With([]Field) Core
 // Check determines whether the supplied Entry should be logged (using the
 // embedded LevelEnabler and possibly some extra logic). If the entry
 // should be logged, the Core adds itself to the CheckedEntry and returns
 // the result.
 //
 // Callers must use Check before calling Write.
 Check(Entry, *CheckedEntry) *CheckedEntry
 // Write serializes the Entry and any Fields supplied at the log site and
 // writes them to their destination.
 //
 // If called, Write should always log the Entry and Fields; it should not
 // replicate the logic of Check.
 Write(Entry, []Field) error
 // Sync flushes buffered logs (if any).
 Sync() error
}
```

### `zapcore.AddSync(file)` 源码解析

```go
func AddSync(w io.Writer) WriteSyncer {
 switch w := w.(type) {
 case WriteSyncer:
  return w
 default:
  return writerWrapper{w}
 }
}

type writerWrapper struct {
 io.Writer
}

func (w writerWrapper) Sync() error {
 return nil
}

type WriteSyncer interface {
 io.Writer
 Sync() error
}
```

### 日志级别

```go
// A Level is a logging priority. Higher levels are more important.
type Level int8

const (
 // DebugLevel logs are typically voluminous, and are usually disabled in
 // production.
 DebugLevel Level = iota - 1
 // InfoLevel is the default logging priority.
 InfoLevel
 // WarnLevel logs are more important than Info, but don't need individual
 // human review.
 WarnLevel
 // ErrorLevel logs are high-priority. If an application is running smoothly,
 // it shouldn't generate any error-level logs.
 ErrorLevel
 // DPanicLevel logs are particularly important errors. In development the
 // logger panics after writing the message.
 DPanicLevel
 // PanicLevel logs a message, then panics.
 PanicLevel
 // FatalLevel logs a message, then calls os.Exit(1).
 FatalLevel

 _minLevel = DebugLevel
 _maxLevel = FatalLevel

 // InvalidLevel is an invalid value for Level.
 //
 // Core implementations may panic if they see messages of this level.
 InvalidLevel = _maxLevel + 1
)
```

### 实操

```go
package main

import (
 "go.uber.org/zap"
 "go.uber.org/zap/zapcore"
 "net/http"
 "os"
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

func main() {
 // 初始化
 InitLogger()
 // Sync调用底层Core的Sync方法，刷新所有缓冲的日志条目。应用程序在退出之前应该注意调用Sync。
 // 在程序退出之前，把缓冲区里的日志刷到磁盘上
 defer logger.Sync()
 simpleHttpGet("www.baidu.com")
 simpleHttpGet("http://www.baidu.com")
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
 logger = zap.New(core)
 // Sugar封装了Logger，以提供更符合人体工程学的API，但速度略慢。糖化一个Logger的成本非常低，
 // 因此一个应用程序同时使用Loggers和SugaredLoggers是合理的，在性能敏感代码的边界上在它们之间进行转换。
 sugarLogger = logger.Sugar()
}

func getEncoder() zapcore.Encoder {
 // NewJSONEncoder创建了一个快速、低分配的JSON编码器。编码器适当地转义所有字段键和值。
 // NewProductionEncoderConfig returns an opinionated EncoderConfig for
 // production environments.
 return zapcore.NewJSONEncoder(zap.NewProductionEncoderConfig())
}

func getLogWriter() zapcore.WriteSyncer {
 // Create创建或截断指定文件。如果文件已经存在，它将被截断。如果该文件不存在，则以模式0666(在umask之前)创建。
 // 如果成功，返回的File上的方法可以用于IO;关联的文件描述符模式为O_RDWR。如果有一个错误，它的类型将是PathError。
 file, _ := os.Create("./test.log")
 // AddSync converts an io.Writer to a WriteSyncer. It attempts to be
 // intelligent: if the concrete type of the io.Writer implements WriteSyncer,
 // we'll use the existing Sync method. If it doesn't, we'll add a no-op Sync.
 return zapcore.AddSync(file)
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

#### 运行

```bash
Code/go/zap_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go

Code/go/zap_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306171153176.png)

test.log 文件

```
{"level":"error","ts":1686973863.114231,"msg":"Error fetching url..{url 15 0 www.baidu.com <nil>} {error 26 0  Get \"www.baidu.com\": unsupported protocol scheme \"\"}"}
{"level":"info","ts":1686973863.160213,"msg":"Success..{statusCode 15 0 200 OK <nil>} {url 15 0 http://www.baidu.com <nil>}"}

```

运行后终端无输出，日志写入到 test.log 文件中，是 JSON 格式的。

## 二、实现编码形式修改

### NewJSONEncoder 修改为 NewConsoleEncoder

```go
package main

import (
 "go.uber.org/zap"
 "go.uber.org/zap/zapcore"
 "net/http"
 "os"
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

func main() {
 // 初始化
 InitLogger()
 // Sync调用底层Core的Sync方法，刷新所有缓冲的日志条目。应用程序在退出之前应该注意调用Sync。
 // 在程序退出之前，把缓冲区里的日志刷到磁盘上
 defer logger.Sync()
 simpleHttpGet("www.baidu.com")
 simpleHttpGet("http://www.baidu.com")
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
 logger = zap.New(core)
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
 return zapcore.NewConsoleEncoder(zap.NewProductionEncoderConfig())
}

func getLogWriter() zapcore.WriteSyncer {
 // Create创建或截断指定文件。如果文件已经存在，它将被截断。如果该文件不存在，则以模式0666(在umask之前)创建。
 // 如果成功，返回的File上的方法可以用于IO;关联的文件描述符模式为O_RDWR。如果有一个错误，它的类型将是PathError。
 file, _ := os.Create("./test.log")
 // AddSync converts an io.Writer to a WriteSyncer. It attempts to be
 // intelligent: if the concrete type of the io.Writer implements WriteSyncer,
 // we'll use the existing Sync method. If it doesn't, we'll add a no-op Sync.
 return zapcore.AddSync(file)
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

运行

```bash
Code/go/zap_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go

Code/go/zap_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

test.log 文件

```
1.68697448701199e+09 error Error fetching url..{url 15 0 www.baidu.com <nil>} {error 26 0  Get "www.baidu.com": unsupported protocol scheme ""}
1.68697448705248e+09 info Success..{statusCode 15 0 200 OK <nil>} {url 15 0 http://www.baidu.com <nil>}

```

#### 思考：为什么 test.log 文件中日志不是追加？

#### 答：因为使用的是 os.Create。 Create creates or truncates the named file. If the file already exists

it is truncated. If the file does not exist, it is created with mode 0666
(before umask). 可以使用  os.OpenFile 实现追加。

## 三、使用 os.OpenFile 实现日志追加

```go
package main

import (
 "go.uber.org/zap"
 "go.uber.org/zap/zapcore"
 "log"
 "net/http"
 "os"
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

func main() {
 // 初始化
 InitLogger()
 // Sync调用底层Core的Sync方法，刷新所有缓冲的日志条目。应用程序在退出之前应该注意调用Sync。
 // 在程序退出之前，把缓冲区里的日志刷到磁盘上
 defer logger.Sync()
 simpleHttpGet("www.baidu.com")
 simpleHttpGet("http://www.baidu.com")
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
 logger = zap.New(core)
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
 return zapcore.NewConsoleEncoder(zap.NewProductionEncoderConfig())
}

func getLogWriter() zapcore.WriteSyncer {
 // Create创建或截断指定文件。如果文件已经存在，它将被截断。如果该文件不存在，则以模式0666(在umask之前)创建。
 // 如果成功，返回的File上的方法可以用于IO;关联的文件描述符模式为O_RDWR。如果有一个错误，它的类型将是PathError。
 //file, _ := os.Create("./test.log")
 file, err := os.OpenFile("./test.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0644)
 if err != nil {
  log.Fatalf("open log file failed with error: %v", err)
 }
 // AddSync converts an io.Writer to a WriteSyncer. It attempts to be
 // intelligent: if the concrete type of the io.Writer implements WriteSyncer,
 // we'll use the existing Sync method. If it doesn't, we'll add a no-op Sync.
 return zapcore.AddSync(file)
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

运行

```bash
Code/go/zap_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go

Code/go/zap_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

test.log

```
1.68697448701199e+09 error Error fetching url..{url 15 0 www.baidu.com <nil>} {error 26 0  Get "www.baidu.com": unsupported protocol scheme ""}
1.68697448705248e+09 info Success..{statusCode 15 0 200 OK <nil>} {url 15 0 http://www.baidu.com <nil>}
1.6869751152769642e+09 error Error fetching url..{url 15 0 www.baidu.com <nil>} {error 26 0  Get "www.baidu.com": unsupported protocol scheme ""}
1.686975115813772e+09 info Success..{statusCode 15 0 200 OK <nil>} {url 15 0 http://www.baidu.com <nil>}
```

## 四、优化时间展示

- 目前时间展示：1.686975115813772e+09

### 实操

```go
package main

import (
 "go.uber.org/zap"
 "go.uber.org/zap/zapcore"
 "log"
 "net/http"
 "os"
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

func main() {
 // 初始化
 InitLogger()
 // Sync调用底层Core的Sync方法，刷新所有缓冲的日志条目。应用程序在退出之前应该注意调用Sync。
 // 在程序退出之前，把缓冲区里的日志刷到磁盘上
 defer logger.Sync()
 simpleHttpGet("www.baidu.com")
 simpleHttpGet("http://www.baidu.com")
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
 logger = zap.New(core)
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

func getLogWriter() zapcore.WriteSyncer {
 // Create创建或截断指定文件。如果文件已经存在，它将被截断。如果该文件不存在，则以模式0666(在umask之前)创建。
 // 如果成功，返回的File上的方法可以用于IO;关联的文件描述符模式为O_RDWR。如果有一个错误，它的类型将是PathError。
 //file, _ := os.Create("./test.log")
 file, err := os.OpenFile("./test.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0644)
 if err != nil {
  log.Fatalf("open log file failed with error: %v", err)
 }
 // AddSync converts an io.Writer to a WriteSyncer. It attempts to be
 // intelligent: if the concrete type of the io.Writer implements WriteSyncer,
 // we'll use the existing Sync method. If it doesn't, we'll add a no-op Sync.
 return zapcore.AddSync(file)
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

运行

```bash
Code/go/zap_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go

Code/go/zap_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

test.log

```
1.68697448701199e+09 error Error fetching url..{url 15 0 www.baidu.com <nil>} {error 26 0  Get "www.baidu.com": unsupported protocol scheme ""}
1.68697448705248e+09 info Success..{statusCode 15 0 200 OK <nil>} {url 15 0 http://www.baidu.com <nil>}
1.6869751152769642e+09 error Error fetching url..{url 15 0 www.baidu.com <nil>} {error 26 0  Get "www.baidu.com": unsupported protocol scheme ""}
1.686975115813772e+09 info Success..{statusCode 15 0 200 OK <nil>} {url 15 0 http://www.baidu.com <nil>}
2023-06-17T13:00:07.720+0800 error Error fetching url..{url 15 0 www.baidu.com <nil>} {error 26 0  Get "www.baidu.com": unsupported protocol scheme ""}
2023-06-17T13:00:07.766+0800 info Success..{statusCode 15 0 200 OK <nil>} {url 15 0 http://www.baidu.com <nil>}

```

根据 ISO8601TimeEncoder 源码 可修改为自定义格式

```go
func encodeTimeLayout(t time.Time, layout string, enc PrimitiveArrayEncoder) {
 type appendTimeEncoder interface {
  AppendTimeLayout(time.Time, string)
 }

 if enc, ok := enc.(appendTimeEncoder); ok {
  enc.AppendTimeLayout(t, layout)
  return
 }

 enc.AppendString(t.Format(layout))
}


// ISO8601TimeEncoder serializes a time.Time to an ISO8601-formatted string
// with millisecond precision.
//
// If enc supports AppendTimeLayout(t time.Time,layout string), it's used
// instead of appending a pre-formatted string value.
func ISO8601TimeEncoder(t time.Time, enc PrimitiveArrayEncoder) {
 encodeTimeLayout(t, "2006-01-02T15:04:05.000Z0700", enc)
}
```

## 五、添加调用者信息（使用zap调用者的文件名、行号和函数名(或不使用)来注释每条消息）

```go
logger = zap.New(core, zap.AddCaller())
```

AddCaller 源码

```go
// AddCaller configures the Logger to annotate each message with the filename,
// line number, and function name of zap's caller. See also WithCaller.
func AddCaller() Option {
 return WithCaller(true)
}

// WithCaller configures the Logger to annotate each message with the filename,
// line number, and function name of zap's caller, or not, depending on the
// value of enabled. This is a generalized form of AddCaller.
func WithCaller(enabled bool) Option {
 return optionFunc(func(log *Logger) {
  log.addCaller = enabled
 })
}
```

### 实操

```go
package main

import (
 "go.uber.org/zap"
 "go.uber.org/zap/zapcore"
 "log"
 "net/http"
 "os"
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

func main() {
 // 初始化
 InitLogger()
 // Sync调用底层Core的Sync方法，刷新所有缓冲的日志条目。应用程序在退出之前应该注意调用Sync。
 // 在程序退出之前，把缓冲区里的日志刷到磁盘上
 defer logger.Sync()
 simpleHttpGet("www.baidu.com")
 simpleHttpGet("http://www.baidu.com")
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

func getLogWriter() zapcore.WriteSyncer {
 // Create创建或截断指定文件。如果文件已经存在，它将被截断。如果该文件不存在，则以模式0666(在umask之前)创建。
 // 如果成功，返回的File上的方法可以用于IO;关联的文件描述符模式为O_RDWR。如果有一个错误，它的类型将是PathError。
 //file, _ := os.Create("./test.log")
 file, err := os.OpenFile("./test.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0644)
 if err != nil {
  log.Fatalf("open log file failed with error: %v", err)
 }
 // AddSync converts an io.Writer to a WriteSyncer. It attempts to be
 // intelligent: if the concrete type of the io.Writer implements WriteSyncer,
 // we'll use the existing Sync method. If it doesn't, we'll add a no-op Sync.
 return zapcore.AddSync(file)
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

运行

```bash
Code/go/zap_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
```

test.log

```
2023-06-17T13:31:22.417+0800 error zap_demo/main.go:125 Error fetching url..{url 15 0 www.baidu.com <nil>} {error 26 0  Get "www.baidu.com": unsupported protocol scheme ""}
2023-06-17T13:31:22.462+0800 info zap_demo/main.go:134 Success..{statusCode 15 0 200 OK <nil>} {url 15 0 http://www.baidu.com <nil>}
```

## 六、日志切割归档 zap 不支持，使用第三库 lumberjack

按日期切割参考以下链接：

[file-rotatelogs](https://github.com/lestrrat-go/file-rotatelogs)：<https://github.com/lestrrat-go/file-rotatelogs>

### 日志切割归档

[Lumberjack](https://github.com/natefinch/lumberjack)：<https://github.com/natefinch/lumberjack>

Lumberjack is a Go package for writing logs to rolling files.

lumberjack 使用

```go
import "gopkg.in/natefinch/lumberjack.v2"
```

Lumberjack is intended to be one part of a logging infrastructure. It is not an all-in-one solution, but instead is a pluggable component at the bottom of the logging stack that simply controls the files to which logs are written.

Lumberjack plays well with any logging package that can write to an io.Writer, including the standard library's log package.

Lumberjack assumes that only one process is writing to the output files. Using the same lumberjack configuration from multiple processes on the same machine will result in improper behavior.

**Example**

To use lumberjack with the standard library's log package, just pass it into the SetOutput function when your application starts.

Code:

```go
log.SetOutput(&lumberjack.Logger{
    Filename:   "/var/log/myapp/foo.log",
    MaxSize:    500, // megabytes
    MaxBackups: 3,
    MaxAge:     28, //days
    Compress:   true, // disabled by default
})
```

安装

```bash
go get gopkg.in/natefinch/lumberjack.v2
```

### 实操 测试

```go
package main

import (
 "go.uber.org/zap"
 "go.uber.org/zap/zapcore"
 "gopkg.in/natefinch/lumberjack.v2"
 "net/http"
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

func main() {
 // 初始化
 InitLogger()
 // Sync调用底层Core的Sync方法，刷新所有缓冲的日志条目。应用程序在退出之前应该注意调用Sync。
 // 在程序退出之前，把缓冲区里的日志刷到磁盘上
 defer logger.Sync()
 simpleHttpGet("www.baidu.com")
 simpleHttpGet("http://www.baidu.com")

 for i := 0; i < 10000; i++ {
  logger.Info("test lumberjack for log rotate....")
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

运行

```bash
Code/go/zap_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go                         

Code/go/zap_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go

Code/go/zap_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go

Code/go/zap_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306171417753.png)
