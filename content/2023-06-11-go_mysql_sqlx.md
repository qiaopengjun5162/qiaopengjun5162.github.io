+++
title = "Go 语言之 sqlx 库使用"
date = 2023-06-11T22:16:09+08:00
description = "Go 语言之 sqlx 库使用"
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# Go 语言之 sqlx 库使用

## 一、sqlx 库安装与连接

### sqlx 介绍

sqlx is a library which provides a set of extensions on go's standard `database/sql` library. The sqlx versions of `sql.DB`, `sql.TX`, `sql.Stmt`, et al. all leave the underlying interfaces untouched, so that their interfaces are a superset on the standard ones. This makes it relatively painless to integrate existing codebases using database/sql with sqlx.

Sqlx 是一个库，它在 go 的标准数据库/sql 库上提供了一组扩展。

sqlx库：<https://github.com/jmoiron/sqlx>

Illustrated guide to SQLX：<http://jmoiron.github.io/sqlx/>

sqlx：<https://pkg.go.dev/github.com/jmoiron/sqlx>

### 安装

```bash
go get github.com/jmoiron/sqlx
```

### 创建 sqlx_demo 项目

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306112235131.png)

### 创建 main.go 文件

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306112239546.png)

### 使用  go mod tidy 添加丢失的模块和删除未使用的模块

### go mod tidy   add missing and remove unused modules

```bash
Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ go mod tidy   
go: finding module for package github.com/jmoiron/sqlx
go: finding module for package github.com/go-sql-driver/mysql
go: downloading github.com/jmoiron/sqlx v1.3.5
go: found github.com/go-sql-driver/mysql in github.com/go-sql-driver/mysql v1.7.1
go: found github.com/jmoiron/sqlx in github.com/jmoiron/sqlx v1.3.5
go: downloading github.com/lib/pq v1.2.0
go: downloading github.com/mattn/go-sqlite3 v1.14.6

Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ 

```

### 连接 MySQL 数据库

```go
package main

import (
 "fmt"

 _ "github.com/go-sql-driver/mysql"
 "github.com/jmoiron/sqlx"
)

var db *sqlx.DB

func initDB() (err error) {
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test?charset=utf8mb4&parseTime=True"
 // 连接到数据库并使用ping进行验证。
 // 也可以使用 MustConnect MustConnect连接到数据库，并在出现错误时恐慌 panic。
 db, err = sqlx.Connect("mysql", dsn)
 if err != nil {
  fmt.Printf("connect DB failed, err:%v\n", err)
  return
 }
 db.SetMaxOpenConns(20) // 设置数据库的最大打开连接数。
 db.SetMaxIdleConns(10) // 设置空闲连接池中的最大连接数。
 return
}

func main() {
 if err := initDB(); err != nil {
  fmt.Printf("init DB failed, err:%v\n", err)
  return
 }
 fmt.Println("init DB succeeded")
}

```

#### 运行

```bash
Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
init DB succeeded

Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base took 2.0s 
➜ 
```

## 二、sqlx 的 CRUD （查询、插入、更新、修改）

### 查询单条数据

```go
package main

import (
 "fmt"

 _ "github.com/go-sql-driver/mysql"
 "github.com/jmoiron/sqlx"
)

var db *sqlx.DB

func initDB() (err error) {
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test?charset=utf8mb4&parseTime=True"
 // 连接到数据库并使用ping进行验证。
 // 也可以使用 MustConnect MustConnect连接到数据库，并在出现错误时恐慌 panic。
 db, err = sqlx.Connect("mysql", dsn)
 if err != nil {
  fmt.Printf("connect DB failed, err:%v\n", err)
  return
 }
 db.SetMaxOpenConns(20) // 设置数据库的最大打开连接数。
 db.SetMaxIdleConns(10) // 设置空闲连接池中的最大连接数。
 return
}

type user struct {
 ID   int    `db:"id"`
 Age  int    `db:"age"`
 Name string `db:"name"`
}

// 1. 想要让别的包能够访问到结构体中的字段，那这个结构体中的字段需要首字母大写
// 2. Go 语言中参数的传递是值拷贝

// 查询单条数据
func queryRowDemo(id int) (u user, err error) {
 sqlStr := "SELECT id, name, age FROM user WHERE id=?"
 // 使用这个数据库。任何占位符参数都将被提供的参数替换。如果结果集为空，则返回错误。
  // 在 Get 中要修改传入的变量，需要传指针，即 &u
 err = db.Get(&u, sqlStr, id)
 if err != nil {
  fmt.Printf("get failed, err:%v\n", err)
  return u, err
 }
 return u, nil
}

func main() {
 if err := initDB(); err != nil {
  fmt.Printf("init DB failed, err:%v\n", err)
  return
 }
 fmt.Println("init DB succeeded")
 // 查询
 u, err := queryRowDemo(1)
 if err != nil {
  fmt.Printf("query row demo failed, err %v\n", err)
 }
 fmt.Printf("id: %d name: %s age: %d\n", u.ID, u.Name, u.Age)
}

```

#### 运行

```bash
Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
init DB succeeded
id: 1 name: 小乔 age: 16

Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base took 3.1s 
➜ 
```

### 查询多条数据

```go
package main

import (
 "fmt"

 _ "github.com/go-sql-driver/mysql"
 "github.com/jmoiron/sqlx"
)

var db *sqlx.DB

func initDB() (err error) {
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test?charset=utf8mb4&parseTime=True"
 // 连接到数据库并使用ping进行验证。
 // 也可以使用 MustConnect MustConnect连接到数据库，并在出现错误时恐慌 panic。
 db, err = sqlx.Connect("mysql", dsn)
 if err != nil {
  fmt.Printf("connect DB failed, err:%v\n", err)
  return
 }
 db.SetMaxOpenConns(20) // 设置数据库的最大打开连接数。
 db.SetMaxIdleConns(10) // 设置空闲连接池中的最大连接数。
 return
}

type user struct {
 ID   int    `db:"id"`
 Age  int    `db:"age"`
 Name string `db:"name"`
}

// 1. 想要让别的包能够访问到结构体中的字段，那这个结构体中的字段需要首字母大写
// 2. Go 语言中参数的传递是值拷贝

// 查询多条数据
func queryMultiRowDemo(id int) (users []user, err error) {
 sqlStr := "SELECT id, name, age FROM user WHERE id > ?"
 err = db.Select(&users, sqlStr, id)
 if err != nil {
  fmt.Printf("query failed, err: %v\n", err)
  return users, err
 }
 return users, nil
}

func main() {
 if err := initDB(); err != nil {
  fmt.Printf("init DB failed, err:%v\n", err)
  return
 }
 fmt.Println("init DB succeeded")

 // 查询多条
 users, err := queryMultiRowDemo(0)
 if err != nil {
  fmt.Printf("query many rows failed %v\n", err)
 }
 fmt.Printf("users: %#v\n", users)
}

```

#### 运行

```bash
Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base took 3.1s 
➜ go run main.go
init DB succeeded
users: []main.user{main.user{ID:1, Age:16, Name:"小乔"}, main.user{ID:2, Age:22, Name:"小乔"}, main.user{ID:5, Age:100, Name:"昭君"}, main.user{ID:6, Age:16, Name:"黛玉"}}

Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

#### SQL 查询结果

```sql
~ via 🅒 base
➜ mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 476
Server version: 8.0.32 Homebrew

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> use sql_test;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> select * from user;
+----+--------+------+
| id | name   | age  |
+----+--------+------+
|  1 | 小乔   |   16 |
|  2 | 小乔   |   22 |
|  5 | 昭君   |  100 |
|  6 | 黛玉   |   16 |
+----+--------+------+
4 rows in set (0.00 sec)

mysql>
```

### 插入

```go
package main

import (
 "fmt"

 _ "github.com/go-sql-driver/mysql"
 "github.com/jmoiron/sqlx"
)

var db *sqlx.DB

func initDB() (err error) {
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test?charset=utf8mb4&parseTime=True"
 // 连接到数据库并使用ping进行验证。
 // 也可以使用 MustConnect MustConnect连接到数据库，并在出现错误时恐慌 panic。
 db, err = sqlx.Connect("mysql", dsn)
 if err != nil {
  fmt.Printf("connect DB failed, err:%v\n", err)
  return
 }
 db.SetMaxOpenConns(20) // 设置数据库的最大打开连接数。
 db.SetMaxIdleConns(10) // 设置空闲连接池中的最大连接数。
 return
}

type user struct {
 ID   int    `db:"id"`
 Age  int    `db:"age"`
 Name string `db:"name"`
}

// 1. 想要让别的包能够访问到结构体中的字段，那这个结构体中的字段需要首字母大写
// 2. Go 语言中参数的传递是值拷贝

// 插入数据
func insertRowDemo(name string, age int) (int64, error) {
 sqlStr := "INSERT INTO user(name, age) VALUES (?,?)"
 // 执行查询而不返回任何行。
 // 参数用于查询中的任何占位符参数
 ret, err := db.Exec(sqlStr, name, age)
 if err != nil {
  fmt.Printf("insert failed, err: %v\n", err)
  return 0, err
 }
 // 返回数据库响应命令生成的整数。
 // 通常，当插入新行时，这将来自“自动增量”列。
 // 并非所有数据库都支持此特性，并且此类语句的语法各不相同。
 var LastInsertId int64
 LastInsertId, err = ret.LastInsertId() // 新插入数据的id
 if err != nil {
  fmt.Printf("get lastinsert ID failed, err: %v\n", err)
  return 0, err
 }
 return LastInsertId, nil
}

func main() {
 if err := initDB(); err != nil {
  fmt.Printf("init DB failed, err:%v\n", err)
  return
 }
 fmt.Println("init DB succeeded")

 // 插入数据
 LastInsertId, err := insertRowDemo("宝玉", 17)
 if err != nil {
  fmt.Printf("insert row demo failed %v\n", err)
 }
 fmt.Printf("insert success, the id is %d.\n", LastInsertId)
}
```

#### 运行

```bash
Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
init DB succeeded
insert success, the id is 7.

Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

#### SQL 查询结果

```sql
mysql> select * from user;
+----+--------+------+
| id | name   | age  |
+----+--------+------+
|  1 | 小乔   |   16 |
|  2 | 小乔   |   22 |
|  5 | 昭君   |  100 |
|  6 | 黛玉   |   16 |
|  7 | 宝玉   |   17 |
+----+--------+------+
5 rows in set (0.01 sec)

mysql>
```

### 更新

```go
package main

import (
 "fmt"

 _ "github.com/go-sql-driver/mysql"
 "github.com/jmoiron/sqlx"
)

var db *sqlx.DB

func initDB() (err error) {
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test?charset=utf8mb4&parseTime=True"
 // 连接到数据库并使用ping进行验证。
 // 也可以使用 MustConnect MustConnect连接到数据库，并在出现错误时恐慌 panic。
 db, err = sqlx.Connect("mysql", dsn)
 if err != nil {
  fmt.Printf("connect DB failed, err:%v\n", err)
  return
 }
 db.SetMaxOpenConns(20) // 设置数据库的最大打开连接数。
 db.SetMaxIdleConns(10) // 设置空闲连接池中的最大连接数。
 return
}

type user struct {
 ID   int    `db:"id"`
 Age  int    `db:"age"`
 Name string `db:"name"`
}

// 1. 想要让别的包能够访问到结构体中的字段，那这个结构体中的字段需要首字母大写
// 2. Go 语言中参数的传递是值拷贝


// 更新数据
func updateRowDemo(age, id int) (int64, error) {
 sqlStr := "UPDATE user SET age=? WHERE id = ?"
 ret, err := db.Exec(sqlStr, age, id)
 if err != nil {
  fmt.Printf("update failed, err:%v\n", err)
  return 0, err
 }
 // 返回受更新、插入或删除影响的行数。并非每个数据库或数据库驱动程序都支持此功能。
 var n int64
 n, err = ret.RowsAffected() // 操作影响的行数
 if err != nil {
  fmt.Printf("get RowsAffected failed, err:%v\n", err)
  return 0, err
 }
 return n, nil
}

func main() {
 if err := initDB(); err != nil {
  fmt.Printf("init DB failed, err:%v\n", err)
  return
 }
 fmt.Println("init DB succeeded")

 // 更新数据
 n, err := updateRowDemo(18, 5)
 if err != nil {
  fmt.Printf("update row demo failed %v\n", err)
 }
 fmt.Printf("update success, affected rows: %d\n", n)
}
```

#### 运行

```bash
Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
init DB succeeded
update success, affected rows: 1

Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

#### SQL 查询结果

```sql
mysql> select * from user;
+----+--------+------+
| id | name   | age  |
+----+--------+------+
|  1 | 小乔   |   16 |
|  2 | 小乔   |   22 |
|  5 | 昭君   |   18 |
|  6 | 黛玉   |   16 |
|  7 | 宝玉   |   17 |
+----+--------+------+
5 rows in set (0.00 sec)

mysql>
```

### 删除

```go
package main

import (
 "fmt"

 _ "github.com/go-sql-driver/mysql"
 "github.com/jmoiron/sqlx"
)

var db *sqlx.DB

func initDB() (err error) {
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test?charset=utf8mb4&parseTime=True"
 // 连接到数据库并使用ping进行验证。
 // 也可以使用 MustConnect MustConnect连接到数据库，并在出现错误时恐慌 panic。
 db, err = sqlx.Connect("mysql", dsn)
 if err != nil {
  fmt.Printf("connect DB failed, err:%v\n", err)
  return
 }
 db.SetMaxOpenConns(20) // 设置数据库的最大打开连接数。
 db.SetMaxIdleConns(10) // 设置空闲连接池中的最大连接数。
 return
}

type user struct {
 ID   int    `db:"id"`
 Age  int    `db:"age"`
 Name string `db:"name"`
}

// 1. 想要让别的包能够访问到结构体中的字段，那这个结构体中的字段需要首字母大写
// 2. Go 语言中参数的传递是值拷贝

// 删除数据
func deleteRowDemo(id int) (int64, error) {
 sqlStr := "DELETE FROM user WHERE id = ?"
 ret, err := db.Exec(sqlStr, id)
 if err != nil {
  fmt.Printf("delete failed, err:%v\n", err)
  return 0, err
 }
 // 返回受更新、插入或删除影响的行数。并非每个数据库或数据库驱动程序都支持此功能。
 var n int64
 n, err = ret.RowsAffected() // 操作影响的行数
 if err != nil {
  fmt.Printf("get RowsAffected failed, err:%v\n", err)
  return 0, err
 }
 return n, nil
}

func main() {
 if err := initDB(); err != nil {
  fmt.Printf("init DB failed, err:%v\n", err)
  return
 }
 fmt.Println("init DB succeeded")
  
 // 删除数据
 n, err := deleteRowDemo(7)
 if err != nil {
  fmt.Printf("delete row demo failed %v\n", err)
 }
 fmt.Printf("delete success, affected rows:%d\n", n)
}

```

#### 运行

```bash
Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
init DB succeeded
delete success, affected rows:1

Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

#### SQL 查询结果

```sql
mysql> select * from user;
+----+--------+------+
| id | name   | age  |
+----+--------+------+
|  1 | 小乔   |   16 |
|  2 | 小乔   |   22 |
|  5 | 昭君   |   18 |
|  6 | 黛玉   |   16 |
|  7 | 宝玉   |   17 |
+----+--------+------+
5 rows in set (0.00 sec)

mysql>
```

### NamedExec 的使用

```go
package main

import (
 "fmt"

 _ "github.com/go-sql-driver/mysql"
 "github.com/jmoiron/sqlx"
)

var db *sqlx.DB

func initDB() (err error) {
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test?charset=utf8mb4&parseTime=True"
 // 连接到数据库并使用ping进行验证。
 // 也可以使用 MustConnect MustConnect连接到数据库，并在出现错误时恐慌 panic。
 db, err = sqlx.Connect("mysql", dsn)
 if err != nil {
  fmt.Printf("connect DB failed, err:%v\n", err)
  return
 }
 db.SetMaxOpenConns(20) // 设置数据库的最大打开连接数。
 db.SetMaxIdleConns(10) // 设置空闲连接池中的最大连接数。
 return
}

type user struct {
 ID   int    `db:"id"`
 Age  int    `db:"age"`
 Name string `db:"name"`
}

// 1. 想要让别的包能够访问到结构体中的字段，那这个结构体中的字段需要首字母大写
// 2. Go 语言中参数的传递是值拷贝


func insertUserDemo(arg interface{}) (int64, error) {
 sqlStr := "INSERT INTO user (name,age) VALUES (:name,:age)"
 // 使用这个数据库。任何命名的占位符参数都将被arg中的字段替换。
 Result, err := db.NamedExec(sqlStr, arg)
 if err != nil {
  return 0, err
 }
 // 返回数据库响应命令生成的整数。
 // 通常，当插入新行时，这将来自“自动增量”列。
 // 并非所有数据库都支持此特性，并且此类语句的语法各不相同。
 var new_id int64
 new_id, err = Result.LastInsertId() // 新插入数据的id
 if err != nil {
  fmt.Printf("get lastinsert ID failed, err: %v\n", err)
  return 0, err
 }
 return new_id, nil
}

func main() {
 if err := initDB(); err != nil {
  fmt.Printf("init DB failed, err:%v\n", err)
  return
 }
 fmt.Println("init DB succeeded")
 
 // NamedExec
 arg := map[string]interface{}{"name": "李煜", "age": 26}
 new_id, err := insertUserDemo(arg)
 if err != nil {
  fmt.Printf("insert user demo failed %v\n", err)
 }
 fmt.Printf("insert user success, the new id is %d\n", new_id)
}

```

#### 运行

```bash
Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
init DB succeeded
insert user success, the new id is 8

Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

#### SQL 查询结果

```sql
mysql> select * from user;
+----+--------+------+
| id | name   | age  |
+----+--------+------+
|  1 | 小乔   |   16 |
|  2 | 小乔   |   22 |
|  5 | 昭君   |   18 |
|  6 | 黛玉   |   16 |
|  8 | 李煜   |   26 |
+----+--------+------+
5 rows in set (0.01 sec)

mysql>
```

### NamedQuery 的使用

```go
package main

import (
 "fmt"

 _ "github.com/go-sql-driver/mysql"
 "github.com/jmoiron/sqlx"
)

var db *sqlx.DB

func initDB() (err error) {
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test?charset=utf8mb4&parseTime=True"
 // 连接到数据库并使用ping进行验证。
 // 也可以使用 MustConnect MustConnect连接到数据库，并在出现错误时恐慌 panic。
 db, err = sqlx.Connect("mysql", dsn)
 if err != nil {
  fmt.Printf("connect DB failed, err:%v\n", err)
  return
 }
 db.SetMaxOpenConns(20) // 设置数据库的最大打开连接数。
 db.SetMaxIdleConns(10) // 设置空闲连接池中的最大连接数。
 return
}

type user struct {
 ID   int    `db:"id"`
 Age  int    `db:"age"`
 Name string `db:"name"`
}

func namedQueryMap(arg interface{}) {
 sqlStr := "SELECT * FROM user WHERE name=:name"
 // 任何命名的占位符参数都将被arg中的字段替换。
 rows, err := db.NamedQuery(sqlStr, arg)
 if err != nil {
  fmt.Printf("db.NamedQuery failed, err:%v\n", err)
  return
 }
 defer rows.Close()
 for rows.Next() {
  results := make(map[string]interface{})
  // 使用 map 做命名查询
  err := rows.MapScan(results)
  //dest, err := rows.SliceScan()
  if err != nil {
   fmt.Printf("scan failed, err:%v\n", err)
   continue
  }
  // 将 "name" 字段的值转换为字符串类型
  if nameBytes, ok := results["name"].([]uint8); ok {
   results["name"] = string(nameBytes)
  }
  fmt.Printf("NamedQuery Map user: %#v\n", results)
 }
}

func namedQuerySlice(arg interface{}) {
 sqlStr := "SELECT * FROM user WHERE name=:name"
 // 任何命名的占位符参数都将被arg中的字段替换。
 rows, err := db.NamedQuery(sqlStr, arg)
 if err != nil {
  fmt.Printf("db.NamedQuery failed, err:%v\n", err)
  return
 }
 defer rows.Close()
 for rows.Next() {
  results, err := rows.SliceScan()
  if err != nil {
   fmt.Printf("scan failed, err:%v\n", err)
   continue
  }
  if len(results) >= 3 {
   id, _ := results[0].(int64)
   name, _ := results[1].([]uint8)
   age, _ := results[2].(int64)

   fmt.Printf("NamedQuery Slice user: id=%d, name=%s, age=%d\n", id, string(name), age)
  }
 }
}

func namedQueryStruct(arg interface{}) {
 sqlStr := "SELECT * FROM user WHERE name=:name"
 // 任何命名的占位符参数都将被arg中的字段替换。
 rows, err := db.NamedQuery(sqlStr, arg)
 if err != nil {
  fmt.Printf("db.NamedQuery failed, err:%v\n", err)
  return
 }
 defer rows.Close()
 for rows.Next() {
  var results user
  err := rows.StructScan(&results)
  if err != nil {
   fmt.Printf("scan failed, err:%v\n", err)
   continue
  }
  fmt.Printf("NamedQuery struct user: %#v\n", results)
 }
}

func main() {
 if err := initDB(); err != nil {
  fmt.Printf("init DB failed, err:%v\n", err)
  return
 }
 fmt.Println("init DB succeeded")
 
 // NamedQuery
 // 使用 map 做命名查询
 arg := map[string]interface{}{"name": "黛玉"}
 namedQueryMap(arg)
 // 使用结构体命名查询，根据结构体字段的 db tag进行映射
 arg1 := user{Name: "黛玉"}
 namedQueryStruct(arg1)
 // 使用 Slice 做命名查询
 arg2 := []user{arg1}
 namedQuerySlice(arg2)
}

```

运行

```bash
Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
init DB succeeded
NamedQuery Map user: map[string]interface {}{"age":16, "id":6, "name":"黛玉"}
NamedQuery struct user: main.user{ID:6, Age:16, Name:"黛玉"}
NamedQuery Slice user: id=6, name=黛玉, age=16

Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

SQL 查询结果

```sql
mysql> select * from user;
+----+--------+------+
| id | name   | age  |
+----+--------+------+
|  1 | 小乔   |   16 |
|  2 | 小乔   |   22 |
|  5 | 昭君   |   18 |
|  6 | 黛玉   |   16 |
|  8 | 李煜   |   26 |
+----+--------+------+
5 rows in set (0.00 sec)

mysql>
```

### sqlx 事务

```go
package main

import (
 "fmt"

 _ "github.com/go-sql-driver/mysql"
 "github.com/jmoiron/sqlx"
)

var db *sqlx.DB

func initDB() (err error) {
 dsn := "root:12345678@tcp(127.0.0.1:3306)/sql_test?charset=utf8mb4&parseTime=True"
 // 连接到数据库并使用ping进行验证。
 // 也可以使用 MustConnect MustConnect连接到数据库，并在出现错误时恐慌 panic。
 db, err = sqlx.Connect("mysql", dsn)
 if err != nil {
  fmt.Printf("connect DB failed, err:%v\n", err)
  return
 }
 db.SetMaxOpenConns(20) // 设置数据库的最大打开连接数。
 db.SetMaxIdleConns(10) // 设置空闲连接池中的最大连接数。
 return
}

type user struct {
 ID   int    `db:"id"`
 Age  int    `db:"age"`
 Name string `db:"name"`
}

func executeQuery(tx *sqlx.Tx, sqlStr string, args ...interface{}) error {
 rs, err := tx.Exec(sqlStr, args...)
 if err != nil {
  return err
 }

 // 返回受更新、插入或删除影响的行数。并非每个数据库或数据库驱动程序都支持此功能。
 var n int64
 n, err = rs.RowsAffected()
 if err != nil {
  return err
 }

 if n != 1 { // 如果受影响的行数不是 1 ，说明更新出了问题，return 错误
  return fmt.Errorf("exec failed for id: %d", args[1])
 }

 return nil
}

func transactionDemo() error {
 // 开始事务并返回sqlx.Tx而不是sql.Tx。
 tx, err := db.Beginx() // 开启事务
 if err != nil {
  return fmt.Errorf("begin trans failed, err: %v", err)
 }

 defer func() {
  // recover 恢复内置功能允许程序管理一个恐慌的程序的行为。
  // recover的返回值报告了例程是否处于恐慌状态。
    // recover 捕获当前函数可能会出现的 panic，执行恢复操作，即先回滚然后 panic
  if p := recover(); p != nil {
   _ = tx.Rollback() // 中止回滚事务。
   panic(p)
  } else if err != nil { // 判断 err 是否为空，如果当前函数有错误，则回滚
   fmt.Printf("begin trans failed, Rollback err: %v\n", err)
   _ = tx.Rollback()
  } else { // 如果没有错误也没有 panic 则提交
   err = tx.Commit()
   fmt.Printf("error committing transaction: %v\n", err)
  }
 }()

 sqlStr := "UPDATE user SET age=? WHERE id=?"

 queries := []struct {
  id  int
  age int
 }{
  {1, 88},
  {3, 16},
 }
 
  // 更新用户表 user 中两个用户的年龄，只有当这两个用户的年龄都更新成功的情况下才会去提交
 for _, query := range queries {
  if err = executeQuery(tx, sqlStr, query.age, query.id); err != nil {
   return err
  }
 }

 return nil
}

func main() {
 if err := initDB(); err != nil {
  fmt.Printf("init DB failed, err:%v\n", err)
  return
 }
 fmt.Println("init DB succeeded")
 
 // 事务
 _ = transactionDemo()
}

```

#### 运行

```bash
Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
init DB succeeded
begin trans failed, Rollback err: exec failed for id: 3

Code/go/sqlx_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

#### SQL 查询结果

```sql
mysql> select * from user;  # 事务执行前
+----+--------+------+
| id | name   | age  |
+----+--------+------+
|  1 | 小乔   |   12 |
|  2 | 小乔   |   22 |
|  5 | 昭君   |   18 |
|  6 | 黛玉   |   16 |
|  8 | 李煜   |   26 |
+----+--------+------+
5 rows in set (0.00 sec)

mysql> select * from user;  # 事务执行后
+----+--------+------+
| id | name   | age  |
+----+--------+------+
|  1 | 小乔   |   12 |
|  2 | 小乔   |   22 |
|  5 | 昭君   |   18 |
|  6 | 黛玉   |   16 |
|  8 | 李煜   |   26 |
+----+--------+------+
5 rows in set (0.01 sec)

mysql>
```

- 使用 defer 来做事务最终是回滚还是提交的判断。
- 执行之后，事务回滚了，查询数据库未发生改变，是因为 ID 为 3 的那条记录不存在。
