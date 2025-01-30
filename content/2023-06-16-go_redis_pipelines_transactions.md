+++
title = "Go Redis 管道和事务之 go-redis"
date = 2023-06-16T13:11:15+08:00
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# Go Redis 管道和事务之 go-redis

## [Go Redis 管道和事务官方文档介绍](https://redis.uptrace.dev/zh/guide/go-redis-pipelines.html)

Redis pipelines(管道) 允许一次性发送多个命令来提高性能，go-redis支持同样的操作， 你可以使用go-redis一次性发送多个命令到服务器，并一次读取返回结果，而不是一个个命令的操作。

[Go Redis 管道和事务](https://redis.uptrace.dev/zh/guide/go-redis-pipelines.html)

- [管道](https://redis.uptrace.dev/zh/guide/go-redis-pipelines.html#管道)

- [Watch 监听](https://redis.uptrace.dev/zh/guide/go-redis-pipelines.html#watch-监听)

- [事务](https://redis.uptrace.dev/zh/guide/go-redis-pipelines.html#事务)

## [管道](https://redis.uptrace.dev/zh/guide/go-redis-pipelines.html#管道)

通过 `go-redis Pipeline` 一次执行多个命令并读取返回值:

```go
pipe := rdb.Pipeline()

incr := pipe.Incr(ctx, "pipeline_counter")
pipe.Expire(ctx, "pipeline_counter", time.Hour)

cmds, err := pipe.Exec(ctx)
if err != nil {
 panic(err)
}

// 结果你需要再调用 Exec 后才可以使用
fmt.Println(incr.Val())
```

或者你也可以使用 `Pipelined` 方法，它将自动调用 Exec:

```go
var incr *redis.IntCmd

cmds, err := rdb.Pipelined(ctx, func(pipe redis.Pipeliner) error {
 incr = pipe.Incr(ctx, "pipelined_counter")
 pipe.Expire(ctx, "pipelined_counter", time.Hour)
 return nil
})
if err != nil {
 panic(err)
}

fmt.Println(incr.Val())
```

同时会返回每个命令的结果，你可以遍历结果集：

```go
cmds, err := rdb.Pipelined(ctx, func(pipe redis.Pipeliner) error {
 for i := 0; i < 100; i++ {
  pipe.Get(ctx, fmt.Sprintf("key%d", i))
 }
 return nil
})
if err != nil {
 panic(err)
}

for _, cmd := range cmds {
    fmt.Println(cmd.(*redis.StringCmd).Val())
}
```

## [#](https://redis.uptrace.dev/zh/guide/go-redis-pipelines.html#watch-监听)Watch 监听

使用 [Redis 事务](https://redis.io/topics/transactions)， 监听key的状态，仅当key未被其他客户端修改才会执行命令， 这种方式也被成为 [乐观锁](https://en.wikipedia.org/wiki/Optimistic_concurrency_control)。

[Redis 事务](https://redis.io/topics/transactions)：<https://redis.io/docs/manual/transactions/>

 [乐观锁](https://en.wikipedia.org/wiki/Optimistic_concurrency_control)：

```bash
WATCH mykey

val = GET mykey
val = val + 1

MULTI
SET mykey $val
EXEC
```

## [#](https://redis.uptrace.dev/zh/guide/go-redis-pipelines.html#事务)事务

你可以使用 `TxPipelined` 和 `TxPipeline` 方法，把命令包装在 `MULTI` 、 `EXEC` 中， 但这种做法没什么意义：

```go
cmds, err := rdb.TxPipelined(ctx, func(pipe redis.Pipeliner) error {
 for i := 0; i < 100; i++ {
  pipe.Get(ctx, fmt.Sprintf("key%d", i))
 }
 return nil
})
if err != nil {
 panic(err)
}

// MULTI
// GET key0
// GET key1
// ...
// GET key99
// EXEC
```

你应该正确的使用 [Watch](https://pkg.go.dev/github.com/redis/go-redis/v9#Client.Watch) + 事务管道， 比如以下示例，我们使用 `GET`, `SET` 和 `WATCH` 命令，来实现 `INCR` 操作， 注意示例中使用 `redis.TxFailedErr` 来判断失败：

```go
const maxRetries = 1000

// increment 方法，使用 GET + SET + WATCH 来实现Key递增效果，类似命令 INCR
func increment(key string) error {
 // 事务函数
 txf := func(tx *redis.Tx) error {
   // // 获得当前值或零值 
  n, err := tx.Get(ctx, key).Int()
  if err != nil && err != redis.Nil {
   return err
  }

  n++  // 实际操作

    // 仅在监视的Key保持不变的情况下运行
  _, err = tx.TxPipelined(ctx, func(pipe redis.Pipeliner) error {
   pipe.Set(ctx, key, n, 0)
   return nil
  })
  return err
 }
 
 for i := 0; i < maxRetries; i++ {
  err := rdb.Watch(ctx, txf, key)
  if err == nil {
   // Success.
   return nil
  }
  if err == redis.TxFailedErr {
   // 乐观锁失败
   continue
  }
  return err
 }

 return errors.New("increment reached maximum number of retries")
}
```

## Go Redis 管道和事务 实操

```go
package main

import (
 "context"
 "fmt"
 "github.com/redis/go-redis/v9"
 "time"
)

// 声明一个全局的 rdb 变量
var rdb *redis.Client

// 初始化连接
func initRedisClient() (err error) {
 // NewClient将客户端返回给Options指定的Redis Server。
 // Options保留设置以建立redis连接。
 rdb = redis.NewClient(&redis.Options{
  Addr:     "localhost:6379",
  Password: "", // 没有密码，默认值
  DB:       0,  // 默认DB 0 连接到服务器后要选择的数据库。
  PoolSize: 20, // 最大套接字连接数。 默认情况下，每个可用CPU有10个连接，由runtime.GOMAXPROCS报告。
 })

 // Background返回一个非空的Context。它永远不会被取消，没有值，也没有截止日期。
 // 它通常由main函数、初始化和测试使用，并作为传入请求的顶级上下文
 ctx := context.Background()

 _, err = rdb.Ping(ctx).Result()
 if err != nil {
  return err
 }
 return nil
}

// watchDemo 在key值不变的情况下将其值+1
func watchKeyDemo(key string) error {
 ctx, cancel := context.WithTimeout(context.Background(), 500*time.Millisecond)
 defer cancel()

 // Watch准备一个事务，并标记要监视的密钥，以便有条件执行(如果有密钥的话)。
 // 当fn退出时，事务将自动关闭。
 // func (c *Client) Watch(ctx context.Context, fn func(*Tx) error, keys ...string)
 return rdb.Watch(ctx, func(tx *redis.Tx) error {
  // Get Redis `GET key` command. It returns redis.Nil error when key does not exist.
  // 获取 Key 的值 n
  n, err := tx.Get(ctx, key).Int()
  if err != nil && err != redis.Nil {
   fmt.Printf("redis get failed, err: %v\n", err)
   return err
  }
  // 假设操作耗时5秒
  // 5秒内我们通过其他的客户端修改key，当前事务就会失败
  time.Sleep(5 * time.Second)
  // txpipeline 执行事务中fn队列中的命令。
  // 当使用WATCH时，EXEC只会在被监视的键没有被修改的情况下执行命令，从而允许检查和设置机制。
  // Exec总是返回命令列表。如果事务失败，则返回TxFailedErr。否则Exec返回第一个失败命令的错误或nil
  _, err = tx.TxPipelined(ctx, func(pipe redis.Pipeliner) error {
   // 业务逻辑 如果 Key 没有变化，则在原来的基础上加 1
   pipe.Set(ctx, key, n+1, time.Hour)
   return nil
  })
  return err
 }, key)
}

func main() {
 if err := initRedisClient(); err != nil {
  fmt.Printf("initRedisClient failed: %v\n", err)
  return
 }
 fmt.Println("initRedisClient started successfully")
 defer rdb.Close() // Close 关闭客户端，释放所有打开的资源。关闭客户端是很少见的，因为客户端是长期存在的，并在许多例程之间共享。


 err := watchKeyDemo("watch_key")
 if err != nil {
  fmt.Printf("watchKeyDemo failed: %v\n", err)
  return
 }
 fmt.Printf("watchKeyDemo succeeded!\n")
}

```

运行

```bash
Code/go/redis_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
initRedisClient started successfully
watchKeyDemo succeeded!

Code/go/redis_demo via 🐹 v1.20.3 via 🅒 base took 6.5s 
➜ go run main.go
initRedisClient started successfully
watchKeyDemo failed: redis: transaction failed

Code/go/redis_demo via 🐹 v1.20.3 via 🅒 base took 6.2s 
➜ 
```

Redis 操作

```bash
27.0.0.1:6379> get watch_key
(nil)
127.0.0.1:6379> set watch_key 9
OK
127.0.0.1:6379> get watch_key
"9"
127.0.0.1:6379> get watch_key
"10"
127.0.0.1:6379> set watch_key 99
OK
127.0.0.1:6379>
```
