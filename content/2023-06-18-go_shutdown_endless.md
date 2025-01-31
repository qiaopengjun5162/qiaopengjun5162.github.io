+++
title = "Go 语言之 Shutdown 关机和fvbock/endless 重启"
date = 2023-06-18T15:39:33+08:00
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# Go 语言之 Shutdown 关机和fvbock/endless 重启

Shutdown 源码

```go
// Shutdown gracefully shuts down the server without interrupting any
// active connections. Shutdown works by first closing all open
// listeners, then closing all idle connections, and then waiting
// indefinitely for connections to return to idle and then shut down.
// If the provided context expires before the shutdown is complete,
// Shutdown returns the context's error, otherwise it returns any
// error returned from closing the Server's underlying Listener(s).
//
// When Shutdown is called, Serve, ListenAndServe, and
// ListenAndServeTLS immediately return ErrServerClosed. Make sure the
// program doesn't exit and waits instead for Shutdown to return.
//
// Shutdown does not attempt to close nor wait for hijacked
// connections such as WebSockets. The caller of Shutdown should
// separately notify such long-lived connections of shutdown and wait
// for them to close, if desired. See RegisterOnShutdown for a way to
// register shutdown notification functions.
//
// Once Shutdown has been called on a server, it may not be reused;
// future calls to methods such as Serve will return ErrServerClosed.
func (srv *Server) Shutdown(ctx context.Context) error {
 srv.inShutdown.Store(true)

 srv.mu.Lock()
 lnerr := srv.closeListenersLocked()
 for _, f := range srv.onShutdown {
  go f()
 }
 srv.mu.Unlock()
 srv.listenerGroup.Wait()

 pollIntervalBase := time.Millisecond
 nextPollInterval := func() time.Duration {
  // Add 10% jitter.
  interval := pollIntervalBase + time.Duration(rand.Intn(int(pollIntervalBase/10)))
  // Double and clamp for next time.
  pollIntervalBase *= 2
  if pollIntervalBase > shutdownPollIntervalMax {
   pollIntervalBase = shutdownPollIntervalMax
  }
  return interval
 }

 timer := time.NewTimer(nextPollInterval())
 defer timer.Stop()
 for {
  if srv.closeIdleConns() {
   return lnerr
  }
  select {
  case <-ctx.Done():
   return ctx.Err()
  case <-timer.C:
   timer.Reset(nextPollInterval())
  }
 }
}
```

### Shutdown 关机实操

```go
package main

import (
 "context"
 "log"
 "net/http"
 "os"
 "os/signal"
 "syscall"
 "time"

 "github.com/gin-gonic/gin"
)

func main() {
 // Default返回一个Engine实例，其中已经附加了Logger和Recovery中间件。
 router := gin.Default()
 // GET is a shortcut for router.Handle("GET", path, handlers).
 router.GET("/", func(c *gin.Context) {
  // Sleep暂停当前例程至少持续时间d。持续时间为负或为零将导致Sleep立即返回。
  time.Sleep(5 * time.Second)
  // String将给定的字符串写入响应体。
  c.String(http.StatusOK, "Welcome Gin Server")
 })

 // 服务器定义运行HTTP服务器的参数。Server的零值是一个有效的配置。
 srv := &http.Server{
  // Addr可选地以“host:port”的形式指定服务器要监听的TCP地址。如果为空，则使用“:http”(端口80)。
  // 服务名称在RFC 6335中定义，并由IANA分配
  Addr:    ":8080",
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
 log.Println("Shutdown Server ...")
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
  log.Fatal("Server Shutdown: ", err)
 }

 log.Println("Server exiting")
}

```

运行

```bash
Code/go/shutdown_demo via 🐹 v1.20.3 via 🅒 base took 1m 40.7s 
➜ go run main.go
[GIN-debug] [WARNING] Creating an Engine instance with the Logger and Recovery middleware already attached.

[GIN-debug] [WARNING] Running in "debug" mode. Switch to "release" mode in production.
 - using env:   export GIN_MODE=release
 - using code:  gin.SetMode(gin.ReleaseMode)

[GIN-debug] GET    /                         --> main.main.func1 (3 handlers)
^C2023/06/18 17:50:48 Shutdown Server ...
[GIN] 2023/06/18 - 17:50:48 | 200 |  5.001188625s |       127.0.0.1 | GET      "/"
2023/06/18 17:50:49 Server exiting

Code/go/shutdown_demo via 🐹 v1.20.3 via 🅒 base took 18.8s 
➜ 

```

访问：<http://127.0.0.1:8080/>

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306181753130.png)

运行之后访问：<http://127.0.0.1:8080/，然后> CTRL C 立即停止关闭服务。

会发现控制台中 Shutdown Server ... 会先打印出来，然后是200 请求响应 ，最后 Server exiting 打印出来。

所以 Shutdown 会把未处理完的请求，处理完成后再关闭服务。

如果不使用 Shutdown ，程序会立即退出。

### 友好的重启

程序在运行，一个重启的命令，会fork 一个子进程，在这个时间点之前，没有处理完的请求，由原来的父进程处理，从这个时间点之后，新来的请求，由 fork的子进程处理，等到父进程处理完成后，子进程就完全管理的Web服务。就实现了更加友好的重启。

使用 [fvbock/endless](https://github.com/fvbock/endless) 来替换默认的 `ListenAndServe`启动服务来实现。

当你的项目是使用类似`supervisor`的软件管理进程时就不适用这种方式。

```go
package main

import (
 "log"
 "net/http"
 "time"

 "github.com/fvbock/endless"
 "github.com/gin-gonic/gin"
)

func main() {
 // Default返回一个Engine实例，其中已经附加了Logger和Recovery中间件。
 router := gin.Default()
 // GET is a shortcut for router.Handle("GET", path, handlers).
 router.GET("/", func(c *gin.Context) {
  // Sleep暂停当前例程至少持续时间d。持续时间为负或为零将导致Sleep立即返回。
  time.Sleep(5 * time.Second)
  // String将给定的字符串写入响应体。
  c.String(http.StatusOK, "Welcome Gin Server")
 })

 // 服务器定义运行HTTP服务器的参数。Server的零值是一个有效的配置。
 //srv := &http.Server{
 // // Addr可选地以“host:port”的形式指定服务器要监听的TCP地址。如果为空，则使用“:http”(端口80)。
 // // 服务名称在RFC 6335中定义，并由IANA分配
 // Addr:    ":8080",
 // Handler: router,
 //}
 //
 //go func() {
 // // 开启一个goroutine启动服务，如果不用 goroutine，下面的代码 ListenAndServe 会一直接收请求，处理请求，进入无限循环。代码就不会往下执行。
 //
 // // ListenAndServe监听TCP网络地址srv.Addr，然后调用Serve来处理传入连接上的请求。接受的连接配置为使TCP能保持连接。
 // // ListenAndServe always returns a non-nil error. After Shutdown or Close,
 // // the returned error is ErrServerClosed.
 // if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
 //  log.Fatalf("listen: %s\n", err) // Fatalf 相当于Printf()之后再调用os.Exit(1)。
 // }
 //}()
 //
 //// 等待中断信号来优雅地关闭服务器，为关闭服务器操作设置一个5秒的超时
 //
 //// make内置函数分配并初始化(仅)slice、map或chan类型的对象。
 //// 与new一样，第一个参数是类型，而不是值。
 //// 与new不同，make的返回类型与其参数的类型相同，而不是指向它的指针
 //// Channel:通道的缓冲区用指定的缓冲区容量初始化。如果为零，或者忽略大小，则通道未被缓冲。
 //
 //// 信号 Signal 表示操作系统信号。通常的底层实现依赖于操作系统:在Unix上是syscall.Signal。
 //quit := make(chan os.Signal, 1) // 创建一个接收信号的通道
 //// kill 默认会发送 syscall.SIGTERM 信号
 //// kill -2 发送 syscall.SIGINT 信号，Ctrl+C 就是触发系统SIGINT信号
 //// kill -9 发送 syscall.SIGKILL 信号，但是不能被捕获，所以不需要添加它
 //// signal.Notify把收到的 syscall.SIGINT或syscall.SIGTERM 信号转发给quit
 //
 //// Notify使包信号将传入的信号转发给c，如果没有提供信号，则将所有传入的信号转发给c，否则仅将提供的信号转发给c。
 //// 包信号不会阻塞发送到c:调用者必须确保c有足够的缓冲空间来跟上预期的信号速率。对于仅用于通知一个信号值的通道，大小为1的缓冲区就足够了。
 //// 允许使用同一通道多次调用Notify:每次调用都扩展发送到该通道的信号集。从集合中移除信号的唯一方法是调用Stop。
 //// 允许使用不同的通道和相同的信号多次调用Notify:每个通道独立地接收传入信号的副本。
 //signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM) // 此处不会阻塞
 //<-quit                                               // 阻塞在此，当接收到上述两种信号时才会往下执行
 //log.Println("Shutdown Server ...")
 //// 创建一个5秒超时的context
 //ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
 //defer cancel()
 //// 5秒内优雅关闭服务（将未处理完的请求处理完再关闭服务），超过5秒就超时退出
 //
 //// 关机将在不中断任何活动连接的情况下优雅地关闭服务器。
 //// Shutdown的工作原理是首先关闭所有打开的侦听器，然后关闭所有空闲连接，然后无限期地等待连接返回空闲状态，然后关闭。
 //// 如果提供的上下文在关闭完成之前过期，则shutdown返回上下文的错误，否则返回关闭服务器的底层侦听器所返回的任何错误。
 //// 当Shutdown被调用时，Serve, ListenAndServe和ListenAndServeTLS会立即返回ErrServerClosed。确保程序没有退出，而是等待Shutdown返回。
 //// 关闭不试图关闭或等待被劫持的连接，如WebSockets。如果需要的话，Shutdown的调用者应该单独通知这些长寿命连接关闭，并等待它们关闭。
 //// 一旦在服务器上调用Shutdown，它可能不会被重用;以后对Serve等方法的调用将返回ErrServerClosed。
 //if err := srv.Shutdown(ctx); err != nil {
 // log.Fatal("Server Shutdown: ", err)
 //}

 // 默认endless服务器会监听下列信号：
 // syscall.SIGHUP，syscall.SIGUSR1，syscall.SIGUSR2，syscall.SIGINT，syscall.SIGTERM和syscall.SIGTSTP
 // 接收到 SIGHUP 信号将触发`fork/restart` 实现优雅重启（kill -1 pid会发送SIGHUP信号）
 // 接收到 syscall.SIGINT或syscall.SIGTERM 信号将触发优雅关机
 // 接收到 SIGUSR2 信号将触发HammerTime
 // SIGUSR1 和 SIGTSTP 被用来触发一些用户自定义的hook函数

 // ListenAndServe监听TCP网络地址addr，然后调用Serve处理程序来处理传入连接上的请求。
 // 处理程序通常为nil，在这种情况下使用DefaultServeMux。
 if err := endless.ListenAndServe(":8080", router); err != nil {
  log.Fatalf("listen: %s\n", err)
 }

 log.Println("Server exiting")
}

```

[更多](https://github.com/fvbock/endless)请访问：<https://github.com/fvbock/endless>
