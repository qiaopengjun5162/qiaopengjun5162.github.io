+++
title = "Go 语言连接数据库实现增删改查"
date = 2023-06-10T18:55:16+08:00
description = "Go 语言之 zap 日志库简单使用"
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# Go 连接 MySQL实现增删改查

## 一、初始化连接

### 创建项目

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306101857652.png)

### 配置 Environment

```bash
https://goproxy.cn,direct
```

### MySQL 数据库驱动

[MySQL驱动](https://github.com/go-sql-driver/mysql)<https://github.com/go-sql-driver/mysql>

```bash
go get -u github.com/go-sql-driver/mysql
```

### main.go 文件 初始化连接

```go
package main

import (
 "database/sql"
 "fmt"

 _ "github.com/go-sql-driver/mysql" // 匿名导入 自动执行 init()
)

func main() {
 //DSN (Data Source Name)
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test"
 db, err := sql.Open("mysql", dsn) // 只对格式进行校验，并不会真正连接数据库
 if err != nil {
  panic(err)
 }
 // 检查完错误之后执行，确保 db 不为 nil
 // Close() 用来释放数据库连接相关的资源
 defer db.Close()
 fmt.Println("connect to database") // 打印这句话并不能表示数据库已经连上了
}

```

### 运行

```bash
Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ go mod tidy   
go: finding module for package github.com/go-sql-driver/mysql
go: found github.com/go-sql-driver/mysql in github.com/go-sql-driver/mysql v1.7.1

Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go 
connect to database

Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ 

```

### sql.Open 源码

```go
// Open may just validate its arguments without creating a connection
// to the database. To verify that the data source name is valid, call
// Ping.
// Open 可能只验证其参数，而不创建与数据库的连接。若要验证数据源名称是否有效，请调用 Ping。
//
// The returned DB is safe for concurrent use by multiple goroutines
// and maintains its own pool of idle connections. Thus, the Open
// function should be called just once. It is rarely necessary to
// close a DB.
// 返回的数据库可以安全地由多个 goroutines 并发使用，并维护自己的空闲连接池。因此，Open 函数应该只调用一次。很少需要关闭数据库。
func Open(driverName, dataSourceName string) (*DB, error) {
 driversMu.RLock()
 driveri, ok := drivers[driverName]
 driversMu.RUnlock()
 if !ok {
  return nil, fmt.Errorf("sql: unknown driver %q (forgotten import?)", driverName)
 }

 if driverCtx, ok := driveri.(driver.DriverContext); ok {
  connector, err := driverCtx.OpenConnector(dataSourceName)
  if err != nil {
   return nil, err
  }
  return OpenDB(connector), nil
 }

 return OpenDB(dsnConnector{dsn: dataSourceName, driver: driveri}), nil
}
```

### 初始化连接 验证数据源名称是否有效，调用 Ping

```go
package main

import (
 "database/sql"
 "fmt"

 _ "github.com/go-sql-driver/mysql" // 匿名导入 自动执行 init()
)

func main() {
 //DSN (Data Source Name)
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test"
 db, err := sql.Open("mysql", dsn) // 只对格式进行校验，并不会真正连接数据库
 if err != nil {
  panic(err)
 }
 // 检查完错误之后执行，确保 db 不为 nil
 // Close() 用来释放数据库连接相关的资源
 defer db.Close()

 // Ping 验证与数据库的连接是否仍处于活动状态，并在必要时建立连接。
 err = db.Ping()
 if err != nil {
  fmt.Printf("connect to db failed, err: %v\n", err)
  return
 }
 fmt.Println("connect to database success") // 
}

```

### 运行

```bash
Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
connect to database success

Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base took 2.5s 
➜ 
```

### db.Ping() 源码

```go
// PingContext verifies a connection to the database is still alive,
// establishing a connection if necessary.
// PingContext 验证与数据库的连接是否仍处于活动状态，并在必要时建立连接。
func (db *DB) PingContext(ctx context.Context) error {
 var dc *driverConn
 var err error

 err = db.retry(func(strategy connReuseStrategy) error {
  dc, err = db.conn(ctx, strategy)
  return err
 })

 if err != nil {
  return err
 }

 return db.pingDC(ctx, dc, dc.releaseConn)
}

// Ping verifies a connection to the database is still alive,
// establishing a connection if necessary.
// Ping 验证与数据库的连接是否仍处于活动状态，并在必要时建立连接。
//
// Ping uses context.Background internally; to specify the context, use
// PingContext.
func (db *DB) Ping() error {
 return db.PingContext(context.Background())
}
```

### 优化之后初始化连接完整代码

```go
package main

import (
 "database/sql"
 "fmt"
 "time"

 _ "github.com/go-sql-driver/mysql" // 匿名导入 自动执行 init()
)

var db *sql.DB

func initMySQL() (err error) {
 //DSN (Data Source Name)
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test"
 // 注意：要初始化全局的 db 对象，不要新声明一个 db 变量
 db, err = sql.Open("mysql", dsn) // 只对格式进行校验，并不会真正连接数据库
 if err != nil {
  return err
 }

 // Ping 验证与数据库的连接是否仍处于活动状态，并在必要时建立连接。
 err = db.Ping()
 if err != nil {
  fmt.Printf("connect to db failed, err: %v\n", err)
  return err
 }
 // 数值需要根据业务具体情况来确定
 db.SetConnMaxLifetime(time.Second * 10) // 设置可以重用连接的最长时间
 db.SetConnMaxIdleTime(time.Second * 5)  // 设置连接可能处于空闲状态的最长时间
 db.SetMaxOpenConns(200)                 // 设置与数据库的最大打开连接数
 db.SetMaxIdleConns(10)                  //  设置空闲连接池中的最大连接数
 return nil
}

func main() {
 if err := initMySQL(); err != nil {
  fmt.Printf("connect to db failed, err: %v\n", err)
 }
 // 检查完错误之后执行，确保 db 不为 nil
 // Close() 用来释放数据库连接相关的资源
 defer db.Close()

 fmt.Println("connect to database success")
 // db.xx() 去使用数据库操作...
}

```

### SetMaxIdleConns 和 SetMaxOpenConns 源码

```go
// SetMaxIdleConns sets the maximum number of connections in the idle
// connection pool.
//
// If MaxOpenConns is greater than 0 but less than the new MaxIdleConns,
// then the new MaxIdleConns will be reduced to match the MaxOpenConns limit.
//
// If n <= 0, no idle connections are retained.
//
// The default max idle connections is currently 2. This may change in
// a future release.
func (db *DB) SetMaxIdleConns(n int) {
 db.mu.Lock()
 if n > 0 {
  db.maxIdleCount = n
 } else {
  // No idle connections.
  db.maxIdleCount = -1
 }
 // Make sure maxIdle doesn't exceed maxOpen
 if db.maxOpen > 0 && db.maxIdleConnsLocked() > db.maxOpen {
  db.maxIdleCount = db.maxOpen
 }
 var closing []*driverConn
 idleCount := len(db.freeConn)
 maxIdle := db.maxIdleConnsLocked()
 if idleCount > maxIdle {
  closing = db.freeConn[maxIdle:]
  db.freeConn = db.freeConn[:maxIdle]
 }
 db.maxIdleClosed += int64(len(closing))
 db.mu.Unlock()
 for _, c := range closing {
  c.Close()
 }
}

// SetMaxOpenConns sets the maximum number of open connections to the database.
//
// If MaxIdleConns is greater than 0 and the new MaxOpenConns is less than
// MaxIdleConns, then MaxIdleConns will be reduced to match the new
// MaxOpenConns limit.
//
// If n <= 0, then there is no limit on the number of open connections.
// The default is 0 (unlimited).
func (db *DB) SetMaxOpenConns(n int) {
 db.mu.Lock()
 db.maxOpen = n
 if n < 0 {
  db.maxOpen = 0
 }
 syncMaxIdle := db.maxOpen > 0 && db.maxIdleConnsLocked() > db.maxOpen
 db.mu.Unlock()
 if syncMaxIdle {
  db.SetMaxIdleConns(n)
 }
}
```

### Database  与 MySQL 注册驱动

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306111115905.png)

## 二、Database SQL CRUD 增删改查

#### 创建数据库后建表并插入数据

```sql
~ via 🅒 base
➜ mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 451
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
| information_schema |
| mysql              |
| mysql_test         |
| performance_schema |
| sql_test           |
| sys                |
+--------------------+
11 rows in set (0.02 sec)

mysql> use sql_test;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+--------------------+
| Tables_in_sql_test |
+--------------------+
| user               |
+--------------------+
1 row in set (0.00 sec)

mysql> desc user;
+-------+-------------+------+-----+---------+----------------+
| Field | Type        | Null | Key | Default | Extra          |
+-------+-------------+------+-----+---------+----------------+
| id    | bigint      | NO   | PRI | NULL    | auto_increment |
| name  | varchar(20) | YES  |     |         |                |
| age   | int         | YES  |     | 0       |                |
+-------+-------------+------+-----+---------+----------------+
3 rows in set (0.00 sec)

mysql> show create table user \G;
*************************** 1. row ***************************
       Table: user
Create Table: CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(20) DEFAULT '',
  `age` int DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
1 row in set (0.00 sec)

ERROR:
No query specified

mysql> select * from user;
+----+--------+------+
| id | name   | age  |
+----+--------+------+
|  1 | 小乔   |   16 |
|  2 | 小乔   |   12 |
+----+--------+------+
2 rows in set (0.00 sec)

mysql>
```

### 单行查询

```go
package main

import (
 "database/sql"
 "fmt"
 "time"

 _ "github.com/go-sql-driver/mysql" // 匿名导入 自动执行 init()
)

var db *sql.DB

func initMySQL() (err error) {
 //DSN (Data Source Name)
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test"
 // 注意：要初始化全局的 db 对象，不要新声明一个 db 变量
 db, err = sql.Open("mysql", dsn) // 只对格式进行校验，并不会真正连接数据库
 if err != nil {
  return err
 }

 // Ping 验证与数据库的连接是否仍处于活动状态，并在必要时建立连接。
 err = db.Ping()
 if err != nil {
  fmt.Printf("connect to db failed, err: %v\n", err)
  return err
 }
 // 数值需要根据业务具体情况来确定
 db.SetConnMaxLifetime(time.Second * 10) // 设置可以重用连接的最长时间
 db.SetConnMaxIdleTime(time.Second * 5)  // 设置连接可能处于空闲状态的最长时间
 db.SetMaxOpenConns(200)                 // 设置与数据库的最大打开连接数
 db.SetMaxIdleConns(10)                  //  设置空闲连接池中的最大连接数
 return nil
}

type user struct {
 id   int
 age  int
 name string
}

// 查询单条数据
func queryRowDemo(id int) (user, error) {
 sqlStr := "SELECT id, name, age FROM user WHERE id = ?"
 var u user
 // QueryRow 执行预期最多返回一行的查询。
 // QueryRow 始终返回一个非 nil 值。错误将延迟到调用 row 的 Scan 方法。
 // Scan 将匹配行中的列复制到 dest 指向的值中
 // 如果多行与查询匹配，Scan 将使用第一行并丢弃其余行。
 // 如果没有与查询匹配的行，Scan 将返回 ErrNoRows。
  // QueryRow 之后要调用 Scan 方法，否则数据库连接不会被释放
 // Scan 源码：defer r.rows.Close() 
 err := db.QueryRow(sqlStr, id).Scan(&u.id, &u.name, &u.age)
 if err != nil {
  fmt.Printf("scan failed, err: %v\n", err)
  return u, err
 }
 return u, nil

}

func main() {
 if err := initMySQL(); err != nil {
  fmt.Printf("connect to db failed, err: %v\n", err)
 }
 // 检查完错误之后执行，确保 db 不为 nil
 // Close() 用来释放数据库连接相关的资源
 defer db.Close()

 fmt.Println("connect to database success")
 // db.xx() 去使用数据库操作...
 u, err := queryRowDemo(1)
 if err != nil {
  fmt.Printf("query row failed, err: %v", err)
 }
 fmt.Printf("id: %d name: %s age: %d\n", u.id, u.name, u.age)
}

```

### 运行

```bash
Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
connect to database success
id: 1 name: 小乔 age: 16

```

### 多行查询

```go
package main

import (
 "database/sql"
 "fmt"
 "time"

 _ "github.com/go-sql-driver/mysql" // 匿名导入 自动执行 init()
)

var db *sql.DB

func initMySQL() (err error) {
 //DSN (Data Source Name)
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test"
 // 注意：要初始化全局的 db 对象，不要新声明一个 db 变量
 db, err = sql.Open("mysql", dsn) // 只对格式进行校验，并不会真正连接数据库
 if err != nil {
  return err
 }

 // Ping 验证与数据库的连接是否仍处于活动状态，并在必要时建立连接。
 err = db.Ping()
 if err != nil {
  fmt.Printf("connect to db failed, err: %v\n", err)
  return err
 }
 // 数值需要根据业务具体情况来确定
 db.SetConnMaxLifetime(time.Second * 10) // 设置可以重用连接的最长时间
 db.SetConnMaxIdleTime(time.Second * 5)  // 设置连接可能处于空闲状态的最长时间
 db.SetMaxOpenConns(200)                 // 设置与数据库的最大打开连接数
 db.SetMaxIdleConns(10)                  //  设置空闲连接池中的最大连接数
 return nil
}

type user struct {
 id   int
 age  int
 name string
}

// 查询单条数据
func queryRowDemo(id int) (user, error) {
 sqlStr := "SELECT id, name, age FROM user WHERE id = ?"
 var u user
 // QueryRow 执行预期最多返回一行的查询。
 // QueryRow 始终返回一个非 nil 值。错误将延迟到调用 row 的 Scan 方法。
 // Scan 将匹配行中的列复制到 dest 指向的值中
 // 如果多行与查询匹配，Scan 将使用第一行并丢弃其余行。
 // 如果没有与查询匹配的行，Scan 将返回 ErrNoRows。
 // QueryRow 之后要调用 Scan 方法，否则数据库连接不会被释放
 // Scan 源码：defer r.rows.Close()
 err := db.QueryRow(sqlStr, id).Scan(&u.id, &u.name, &u.age)
 if err != nil {
  fmt.Printf("scan failed, err: %v\n", err)
  return u, err
 }
 return u, nil

}

// 查询多条数据
func queryMultiRowDemo(id int) {
 sqlStr := "SELECT id, name, age FROM user WHERE id > ?"
 rows, err := db.Query(sqlStr, id)
 if err != nil {
  fmt.Printf("query failed, err: %v\n", err)
  return
 }
 // 关闭 rows 释放持有的数据库链接
 // Close 关闭行，防止进一步枚举。
 // 如果调用 Next 并返回 false 并且没有其他结果集，
 // 则行将自动关闭，检查 Err. 的结果就足够了。 关闭是幂等的，不会影响 Err 的结果。
 // 因为不能保证 for rows.Next() 一定可以执行完，有可能会 panic 或其他情况，
 // 故需要在此 defer 关闭连接
 defer rows.Close()

 // 循环读取结果集中的数据
 // Next 准备下一个结果行，以便使用 Scan 方法读取。
 // 成功时返回 true，如果没有下一个结果行或在准备时发生错误，则返回 false。
 for rows.Next() {
  var u user
  err := rows.Scan(&u.id, &u.name, &u.age)
  if err != nil {
   fmt.Printf("scan failed, err:%v\n", err)
   return
  }
  fmt.Printf("id:%d name:%s age:%d\n", u.id, u.name, u.age)
 }
}

func main() {
 if err := initMySQL(); err != nil {
  fmt.Printf("connect to db failed, err: %v\n", err)
 }
 // 检查完错误之后执行，确保 db 不为 nil
 // Close() 用来释放数据库连接相关的资源
 // Close 将关闭数据库并阻止启动新查询。关闭，然后等待服务器上已开始处理的所有查询完成。
 defer db.Close()

 fmt.Println("connect to database success")
 // db.xx() 去使用数据库操作...
 // 查询单行数据
 //u, err := queryRowDemo(1)
 //if err != nil {
 // fmt.Printf("query row failed, err: %v", err)
 //}
 //fmt.Printf("id: %d name: %s age: %d\n", u.id, u.name, u.age)
 // 查询多行数据
 queryMultiRowDemo(0)
}

```

### 运行

```bash
Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
connect to database success
id:1 name:小乔 age:16
id:2 name:小乔 age:12

Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

### 插入数据

```go
package main

import (
 "database/sql"
 "fmt"
 "time"

 _ "github.com/go-sql-driver/mysql" // 匿名导入 自动执行 init()
)

var db *sql.DB

func initMySQL() (err error) {
 //DSN (Data Source Name)
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test"
 // 注意：要初始化全局的 db 对象，不要新声明一个 db 变量
 db, err = sql.Open("mysql", dsn) // 只对格式进行校验，并不会真正连接数据库
 if err != nil {
  return err
 }

 // Ping 验证与数据库的连接是否仍处于活动状态，并在必要时建立连接。
 err = db.Ping()
 if err != nil {
  fmt.Printf("connect to db failed, err: %v\n", err)
  return err
 }
 // 数值需要根据业务具体情况来确定
 db.SetConnMaxLifetime(time.Second * 10) // 设置可以重用连接的最长时间
 db.SetConnMaxIdleTime(time.Second * 5)  // 设置连接可能处于空闲状态的最长时间
 db.SetMaxOpenConns(200)                 // 设置与数据库的最大打开连接数
 db.SetMaxIdleConns(10)                  //  设置空闲连接池中的最大连接数
 return nil
}

type user struct {
 id   int
 age  int
 name string
}

// 查询单条数据
func queryRowDemo(id int) (user, error) {
 sqlStr := "SELECT id, name, age FROM user WHERE id = ?"
 var u user
 // QueryRow 执行预期最多返回一行的查询。
 // QueryRow 始终返回一个非 nil 值。错误将延迟到调用 row 的 Scan 方法。
 // Scan 将匹配行中的列复制到 dest 指向的值中
 // 如果多行与查询匹配，Scan 将使用第一行并丢弃其余行。
 // 如果没有与查询匹配的行，Scan 将返回 ErrNoRows。
 // QueryRow 之后要调用 Scan 方法，否则数据库连接不会被释放
 // Scan 源码：defer r.rows.Close()
 err := db.QueryRow(sqlStr, id).Scan(&u.id, &u.name, &u.age)
 if err != nil {
  fmt.Printf("scan failed, err: %v\n", err)
  return u, err
 }
 return u, nil

}

// 查询多条数据
func queryMultiRowDemo(id int) {
 sqlStr := "SELECT id, name, age FROM user WHERE id > ?"
 rows, err := db.Query(sqlStr, id)
 if err != nil {
  fmt.Printf("query failed, err: %v\n", err)
  return
 }
 // 关闭 rows 释放持有的数据库链接
 // Close 关闭行，防止进一步枚举。
 // 如果调用 Next 并返回 false 并且没有其他结果集，
 // 则行将自动关闭，检查 Err. 的结果就足够了。 关闭是幂等的，不会影响 Err 的结果。
 // 因为不能保证 for rows.Next() 一定可以执行完，有可能会 panic 或其他情况，
 // 故需要在此 defer 关闭连接
 defer rows.Close()

 // 循环读取结果集中的数据
 // Next 准备下一个结果行，以便使用 Scan 方法读取。
 // 成功时返回 true，如果没有下一个结果行或在准备时发生错误，则返回 false。
 for rows.Next() {
  var u user
  err := rows.Scan(&u.id, &u.name, &u.age)
  if err != nil {
   fmt.Printf("scan failed, err:%v\n", err)
   return
  }
  fmt.Printf("id:%d name:%s age:%d\n", u.id, u.name, u.age)
 }
}

// 插入数据
func insertRowDemo(name string, age int) (int64, error) {
 sqlStr := "INSERT INTO user (name, age) VALUES (?,?)"
 result, err := db.Exec(sqlStr, name, age)
 if err != nil {
  fmt.Printf("insert failed, err: %v\n", err)
  return 0, err
 }
 // LastInsertId 返回数据库为响应命令而生成的整数。
 // 通常，这将来自插入新行时的“自动增量”列。
 // 并非所有数据库都支持此功能，并且此类语句的语法各不相同。
 var newID int64
 newID, err = result.LastInsertId() // 新插入数据的id
 if err != nil {
  fmt.Printf("get lastinsert ID failed, err: %v\n", err)
  return 0, err
 }
 return newID, nil
}

func main() {
 if err := initMySQL(); err != nil {
  fmt.Printf("connect to db failed, err: %v\n", err)
 }
 // 检查完错误之后执行，确保 db 不为 nil
 // Close() 用来释放数据库连接相关的资源
 // Close 将关闭数据库并阻止启动新查询。关闭，然后等待服务器上已开始处理的所有查询完成。
 defer db.Close()

 fmt.Println("connect to database success")
 // db.xx() 去使用数据库操作...
 // 查询单行数据
 //u, err := queryRowDemo(1)
 //if err != nil {
 // fmt.Printf("query row failed, err: %v", err)
 //}
 //fmt.Printf("id: %d name: %s age: %d\n", u.id, u.name, u.age)
 // 查询多行数据
 //queryMultiRowDemo(0)
 // 插入数据
 newID, err := insertRowDemo("小跟班", 12)
 if err != nil {
  fmt.Printf("insert row failed, err: %v", err)
 }
 fmt.Printf("insert success, the id is %d.\n", newID)
}

```

### 运行

```bash
Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
connect to database success
insert success, the id is 4.

Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

#### SQL 查询 插入结果

```sql
mysql> select * from user;
+----+-----------+------+
| id | name      | age  |
+----+-----------+------+
|  1 | 小乔      |   16 |
|  2 | 小乔      |   12 |
|  4 | 小跟班    |   12 |
+----+-----------+------+
3 rows in set (0.00 sec)

mysql>
```

### 更新数据

```go
package main

import (
 "database/sql"
 "fmt"
 "time"

 _ "github.com/go-sql-driver/mysql" // 匿名导入 自动执行 init()
)

var db *sql.DB

func initMySQL() (err error) {
 //DSN (Data Source Name)
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test"
 // 注意：要初始化全局的 db 对象，不要新声明一个 db 变量
 db, err = sql.Open("mysql", dsn) // 只对格式进行校验，并不会真正连接数据库
 if err != nil {
  return err
 }

 // Ping 验证与数据库的连接是否仍处于活动状态，并在必要时建立连接。
 err = db.Ping()
 if err != nil {
  fmt.Printf("connect to db failed, err: %v\n", err)
  return err
 }
 // 数值需要根据业务具体情况来确定
 db.SetConnMaxLifetime(time.Second * 10) // 设置可以重用连接的最长时间
 db.SetConnMaxIdleTime(time.Second * 5)  // 设置连接可能处于空闲状态的最长时间
 db.SetMaxOpenConns(200)                 // 设置与数据库的最大打开连接数
 db.SetMaxIdleConns(10)                  //  设置空闲连接池中的最大连接数
 return nil
}

type user struct {
 id   int
 age  int
 name string
}

// 查询单条数据
func queryRowDemo(id int) (user, error) {
 sqlStr := "SELECT id, name, age FROM user WHERE id = ?"
 var u user
 // QueryRow 执行预期最多返回一行的查询。
 // QueryRow 始终返回一个非 nil 值。错误将延迟到调用 row 的 Scan 方法。
 // Scan 将匹配行中的列复制到 dest 指向的值中
 // 如果多行与查询匹配，Scan 将使用第一行并丢弃其余行。
 // 如果没有与查询匹配的行，Scan 将返回 ErrNoRows。
 // QueryRow 之后要调用 Scan 方法，否则数据库连接不会被释放
 // Scan 源码：defer r.rows.Close()
 err := db.QueryRow(sqlStr, id).Scan(&u.id, &u.name, &u.age)
 if err != nil {
  fmt.Printf("scan failed, err: %v\n", err)
  return u, err
 }
 return u, nil

}

// 查询多条数据
func queryMultiRowDemo(id int) {
 sqlStr := "SELECT id, name, age FROM user WHERE id > ?"
 rows, err := db.Query(sqlStr, id)
 if err != nil {
  fmt.Printf("query failed, err: %v\n", err)
  return
 }
 // 关闭 rows 释放持有的数据库链接
 // Close 关闭行，防止进一步枚举。
 // 如果调用 Next 并返回 false 并且没有其他结果集，
 // 则行将自动关闭，检查 Err. 的结果就足够了。 关闭是幂等的，不会影响 Err 的结果。
 // 因为不能保证 for rows.Next() 一定可以执行完，有可能会 panic 或其他情况，
 // 故需要在此 defer 关闭连接
 defer rows.Close()

 // 循环读取结果集中的数据
 // Next 准备下一个结果行，以便使用 Scan 方法读取。
 // 成功时返回 true，如果没有下一个结果行或在准备时发生错误，则返回 false。
 for rows.Next() {
  var u user
  err := rows.Scan(&u.id, &u.name, &u.age)
  if err != nil {
   fmt.Printf("scan failed, err:%v\n", err)
   return
  }
  fmt.Printf("id:%d name:%s age:%d\n", u.id, u.name, u.age)
 }
}

// 插入数据
func insertRowDemo(name string, age int) (int64, error) {
 sqlStr := "INSERT INTO user (name, age) VALUES (?,?)"
 result, err := db.Exec(sqlStr, name, age)
 if err != nil {
  fmt.Printf("insert failed, err: %v\n", err)
  return 0, err
 }
 // LastInsertId 返回数据库为响应命令而生成的整数。
 // 通常，这将来自插入新行时的“自动增量”列。
 // 并非所有数据库都支持此功能，并且此类语句的语法各不相同。
 var newID int64
 newID, err = result.LastInsertId() // 新插入数据的id
 if err != nil {
  fmt.Printf("get lastinsert ID failed, err: %v\n", err)
  return 0, err
 }
 return newID, nil
}

// 更新数据
func updateRowDemo(age, id int) (int64, error) {
 sqlStr := "UPDATE user SET age=? WHERE id = ?"
 ret, err := db.Exec(sqlStr, age, id)
 if err != nil {
  fmt.Printf("update failed, err: %v\n", err)
  return 0, err
 }
 // 返回受更新、插入或删除影响的行数。并非每个数据库或数据库驱动程序都支持此功能。
 var n int64
 n, err = ret.RowsAffected() // 操作影响的行数
 if err != nil {
  fmt.Printf("get RowsAffected failed, err: %v\n", err)
  return 0, err
 }
 return n, nil
}

func main() {
 if err := initMySQL(); err != nil {
  fmt.Printf("connect to db failed, err: %v\n", err)
 }
 // 检查完错误之后执行，确保 db 不为 nil
 // Close() 用来释放数据库连接相关的资源
 // Close 将关闭数据库并阻止启动新查询。关闭，然后等待服务器上已开始处理的所有查询完成。
 defer db.Close()

 fmt.Println("connect to database success")
 // db.xx() 去使用数据库操作...
 // 查询单行数据
 //u, err := queryRowDemo(1)
 //if err != nil {
 // fmt.Printf("query row failed, err: %v", err)
 //}
 //fmt.Printf("id: %d name: %s age: %d\n", u.id, u.name, u.age)
 // 查询多行数据
 //queryMultiRowDemo(0)
 // 插入数据
 //newID, err := insertRowDemo("小跟班", 12)
 //if err != nil {
 // fmt.Printf("insert row failed, err: %v", err)
 //}
 //fmt.Printf("insert success, the id is %d.\n", newID)
 // 更新数据
 n, err := updateRowDemo(88, 4)
 if err != nil {
  fmt.Printf("update row failed with err: %v", err)
 }
 fmt.Printf("update success, affected rows:%d\n", n)
}

```

#### 运行

```bash
Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
connect to database success
update success, affected rows:1

Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

#### SQL 查询更新结果

```sql
mysql> select * from user;
+----+-----------+------+
| id | name      | age  |
+----+-----------+------+
|  1 | 小乔      |   16 |
|  2 | 小乔      |   12 |
|  4 | 小跟班    |   88 |
+----+-----------+------+
3 rows in set (0.00 sec)

mysql>
```

### 删除数据

```go
package main

import (
 "database/sql"
 "fmt"
 "time"

 _ "github.com/go-sql-driver/mysql" // 匿名导入 自动执行 init()
)

var db *sql.DB

func initMySQL() (err error) {
 //DSN (Data Source Name)
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test"
 // 注意：要初始化全局的 db 对象，不要新声明一个 db 变量
 db, err = sql.Open("mysql", dsn) // 只对格式进行校验，并不会真正连接数据库
 if err != nil {
  return err
 }

 // Ping 验证与数据库的连接是否仍处于活动状态，并在必要时建立连接。
 err = db.Ping()
 if err != nil {
  fmt.Printf("connect to db failed, err: %v\n", err)
  return err
 }
 // 数值需要根据业务具体情况来确定
 db.SetConnMaxLifetime(time.Second * 10) // 设置可以重用连接的最长时间
 db.SetConnMaxIdleTime(time.Second * 5)  // 设置连接可能处于空闲状态的最长时间
 db.SetMaxOpenConns(200)                 // 设置与数据库的最大打开连接数
 db.SetMaxIdleConns(10)                  //  设置空闲连接池中的最大连接数
 return nil
}

type user struct {
 id   int
 age  int
 name string
}

// 查询单条数据
func queryRowDemo(id int) (user, error) {
 sqlStr := "SELECT id, name, age FROM user WHERE id = ?"
 var u user
 // QueryRow 执行预期最多返回一行的查询。
 // QueryRow 始终返回一个非 nil 值。错误将延迟到调用 row 的 Scan 方法。
 // Scan 将匹配行中的列复制到 dest 指向的值中
 // 如果多行与查询匹配，Scan 将使用第一行并丢弃其余行。
 // 如果没有与查询匹配的行，Scan 将返回 ErrNoRows。
 // QueryRow 之后要调用 Scan 方法，否则数据库连接不会被释放
 // Scan 源码：defer r.rows.Close()
 err := db.QueryRow(sqlStr, id).Scan(&u.id, &u.name, &u.age)
 if err != nil {
  fmt.Printf("scan failed, err: %v\n", err)
  return u, err
 }
 return u, nil

}

// 查询多条数据
func queryMultiRowDemo(id int) {
 sqlStr := "SELECT id, name, age FROM user WHERE id > ?"
 rows, err := db.Query(sqlStr, id)
 if err != nil {
  fmt.Printf("query failed, err: %v\n", err)
  return
 }
 // 关闭 rows 释放持有的数据库链接
 // Close 关闭行，防止进一步枚举。
 // 如果调用 Next 并返回 false 并且没有其他结果集，
 // 则行将自动关闭，检查 Err. 的结果就足够了。 关闭是幂等的，不会影响 Err 的结果。
 // 因为不能保证 for rows.Next() 一定可以执行完，有可能会 panic 或其他情况，
 // 故需要在此 defer 关闭连接
 defer rows.Close()

 // 循环读取结果集中的数据
 // Next 准备下一个结果行，以便使用 Scan 方法读取。
 // 成功时返回 true，如果没有下一个结果行或在准备时发生错误，则返回 false。
 for rows.Next() {
  var u user
  err := rows.Scan(&u.id, &u.name, &u.age)
  if err != nil {
   fmt.Printf("scan failed, err:%v\n", err)
   return
  }
  fmt.Printf("id:%d name:%s age:%d\n", u.id, u.name, u.age)
 }
}

// 插入数据
func insertRowDemo(name string, age int) (int64, error) {
 sqlStr := "INSERT INTO user (name, age) VALUES (?,?)"
 result, err := db.Exec(sqlStr, name, age)
 if err != nil {
  fmt.Printf("insert failed, err: %v\n", err)
  return 0, err
 }
 // LastInsertId 返回数据库为响应命令而生成的整数。
 // 通常，这将来自插入新行时的“自动增量”列。
 // 并非所有数据库都支持此功能，并且此类语句的语法各不相同。
 var newID int64
 newID, err = result.LastInsertId() // 新插入数据的id
 if err != nil {
  fmt.Printf("get lastinsert ID failed, err: %v\n", err)
  return 0, err
 }
 return newID, nil
}

// 更新数据
func updateRowDemo(age, id int) (int64, error) {
 sqlStr := "UPDATE user SET age=? WHERE id = ?"
 ret, err := db.Exec(sqlStr, age, id)
 if err != nil {
  fmt.Printf("update failed, err: %v\n", err)
  return 0, err
 }
 // 返回受更新、插入或删除影响的行数。并非每个数据库或数据库驱动程序都支持此功能。
 var n int64
 n, err = ret.RowsAffected() // 操作影响的行数
 if err != nil {
  fmt.Printf("get RowsAffected failed, err: %v\n", err)
  return 0, err
 }
 return n, nil
}

// 删除数据
func deleteRowDemo(id int) (int64, error) {
 sqlStr := "DELETE FROM user WHERE id = ?"
 ret, err := db.Exec(sqlStr, id)
 if err != nil {
  fmt.Printf("delete failed, err: %v\n", err)
  return 0, err
 }
 // RowsAffected returns the number of rows affected by an
 // update, insert, or delete. Not every database or database
 // driver may support this.
 var n int64
 n, err = ret.RowsAffected() // 操作影响的行数
 if err != nil {
  fmt.Printf("get RowsAffected failed, err: %v\n", err)
  return 0, err
 }
 return n, nil
}

func main() {
 if err := initMySQL(); err != nil {
  fmt.Printf("connect to db failed, err: %v\n", err)
 }
 // 检查完错误之后执行，确保 db 不为 nil
 // Close() 用来释放数据库连接相关的资源
 // Close 将关闭数据库并阻止启动新查询。关闭，然后等待服务器上已开始处理的所有查询完成。
 defer db.Close()

 fmt.Println("connect to database success")
 // db.xx() 去使用数据库操作...
 // 查询单行数据
 //u, err := queryRowDemo(1)
 //if err != nil {
 // fmt.Printf("query row failed, err: %v", err)
 //}
 //fmt.Printf("id: %d name: %s age: %d\n", u.id, u.name, u.age)
 // 查询多行数据
 //queryMultiRowDemo(0)
 // 插入数据
 //newID, err := insertRowDemo("小跟班", 12)
 //if err != nil {
 // fmt.Printf("insert row failed, err: %v", err)
 //}
 //fmt.Printf("insert success, the id is %d.\n", newID)
 // 更新数据
 //n, err := updateRowDemo(88, 4)
 //if err != nil {
 // fmt.Printf("update row failed with err: %v", err)
 //}
 //fmt.Printf("update success, affected rows: %d\n", n)
 // 删除数据
 n, err := deleteRowDemo(4)
 if err != nil {
  fmt.Printf("delete row failed with err: %v", err)
 }
 fmt.Printf("delete success, affected rows:%d\n", n)
}

```

#### 运行

```bash
Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
connect to database success
delete success, affected rows:1

Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

#### SQL 查询删除结果

```sql
mysql> select * from user;
+----+--------+------+
| id | name   | age  |
+----+--------+------+
|  1 | 小乔   |   16 |
|  2 | 小乔   |   12 |
+----+--------+------+
2 rows in set (0.00 sec)

mysql>
```
