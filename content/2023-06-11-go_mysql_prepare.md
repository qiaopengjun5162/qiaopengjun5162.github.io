+++
title = "Go 语言连接数据库之 MySQL 预处理"
date = 2023-06-11T15:18:41+08:00
description = "Go 语言之 连接 MySQL之 MySQL 预处理"
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# Go 连接 MySQL之 MySQL 预处理

## 一、ChatGPT 关于 MySQL 预处理 的回答

### 问：什么是MySQL 的预处理 具体执行过程时什么

#### ChatGPT 答

MySQL的预处理是一种在执行SQL语句之前，先进行编译和优化的机制。它将SQL语句分成两个阶段：预处理阶段和执行阶段。

具体的执行过程如下：

1. 预处理阶段：
   - 应用程序发送SQL语句给MySQL服务器，将其中的参数部分用占位符（如?）代替，形成一个预处理语句。
   - MySQL服务器对预处理语句进行解析、编译和优化。
   - 在这个阶段，MySQL会检查语法的正确性，创建执行计划，以及进行权限验证等。
2. 执行阶段：
   - 在预处理完成后，应用程序可以多次执行这个预处理语句，每次执行时只需提供具体的参数值。
   - 应用程序将具体的参数值绑定到预处理语句的占位符上。
   - MySQL服务器使用绑定的参数值执行预处理语句，并返回执行结果。

预处理的好处包括：

- 提高执行效率：预处理语句只需要编译一次，后续的执行可以重复使用，避免了每次执行都要重新解析和编译的开销。
- 防止SQL注入：通过使用参数化查询，将参数值与SQL语句分开处理，可以防止恶意用户利用输入数据进行SQL注入攻击。
- 简化参数处理：预处理语句可以通过占位符来接收参数，避免了手动拼接SQL语句的繁琐和潜在的错误。

总结而言，MySQL的预处理是一种提前编译和优化SQL语句的机制，它将SQL语句分为预处理和执行两个阶段，提高了执行效率和安全性，并简化了参数处理过程。

### 问：Go实现MySQL预处理

#### ChatGPT 答

在 Go 中，可以使用官方提供的 `database/sql` 包来实现 MySQL 的预处理。下面是一个示例代码，展示了如何在 Go 中进行 MySQL 预处理：

```go
import (
 "database/sql"
 "fmt"
 "log"

 _ "github.com/go-sql-driver/mysql"
)

func main() {
 db, err := sql.Open("mysql", "username:password@tcp(hostname:port)/database")
 if err != nil {
  log.Fatal(err)
 }
 defer db.Close()

 // 准备预处理语句
 stmt, err := db.Prepare("INSERT INTO users (name, age) VALUES (?, ?)")
 if err != nil {
  log.Fatal(err)
 }
 defer stmt.Close()

 // 执行预处理语句
 name := "John"
 age := 30
 _, err = stmt.Exec(name, age)
 if err != nil {
  log.Fatal(err)
 }

 fmt.Println("Insert successful!")
}

```

在上述代码中，我们使用 `sql.Open` 函数建立与 MySQL 数据库的连接。然后使用 `db.Prepare` 函数准备预处理语句，其中 SQL 语句中的参数位置用占位符 `?` 表示。接下来，通过 `stmt.Exec` 函数执行预处理语句，并传入具体的参数值。最后，我们在 `main` 函数中进行了错误处理，并打印了插入成功的消息。

请确保在代码中填入正确的 MySQL 连接信息（用户名、密码、主机名、端口号和数据库名），以便与目标数据库建立连接。同时，请根据实际的预处理语句和参数进行适当的修改。

注意：上述示例代码仅演示了预处理的基本流程，并没有包含完整的错误处理和其他功能。在实际应用中，建议加入适当的错误处理、事务处理等机制，以确保代码的健壮性和安全性。

#### 问：MySQL预处理适用于什么场景？

#### ChatGPT 答

MySQL预处理适用于以下场景：

1. 执行频繁的重复查询：如果应用程序需要多次执行相同的SQL查询，但只是参数值不同，预处理可以减少服务器的工作量。预处理语句只需要编译一次，后续的执行可以重复使用，避免了每次都重新解析和编译SQL语句的开销。
2. 参数化查询：当需要执行带有参数的查询时，预处理可以提高安全性并防止SQL注入攻击。通过使用参数化查询，将参数值与SQL语句分开处理，可以确保输入数据被正确地转义和处理，避免恶意用户利用输入数据进行攻击。
3. 提高性能：预处理可以在编译和优化阶段对SQL语句进行处理，生成更高效的执行计划。这可以提高查询的性能和响应时间，特别是对于复杂查询或涉及大量数据的查询。
4. 简化参数处理：预处理语句可以通过占位符（如?）来接收参数值，避免了手动拼接SQL语句的繁琐和潜在的错误。同时，使用预处理语句可以直接将参数值绑定到占位符上，而无需手动转义和处理参数值。

总结而言，MySQL预处理适用于需要执行重复查询、参数化查询、提高性能和简化参数处理的场景。它可以减少服务器的工作量，提高查询的安全性和性能，并简化代码的编写和维护。

## 二、Go 实现 MySQL 预处理

### 查询

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

// 预处理查询
func prepareQueryDemo(id int) {
 sqlStr := "SELECT id, name, age FROM user WHERE id > ?"
 stmt, err := db.Prepare(sqlStr)
 if err != nil {
  fmt.Printf("prepare failed, err: %v\n", err)
  return
 }
 defer stmt.Close()
 rows, err := stmt.Query(id)
 if err != nil {
  fmt.Printf("query failed, err: %v\n", err)
  return
 }
 defer rows.Close()
 // 循环读取结果集中的数据
 for rows.Next() {
  var u user
  err := rows.Scan(&u.id, &u.name, &u.age)
  if err != nil {
   fmt.Printf("scan failed, err: %v\n", err)
   return
  }
  fmt.Printf("id: %d name: %s age: %d\n", u.id, u.name, u.age)
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

 // MySQL预处理查询多行数据
 prepareQueryDemo(0)
}

```

#### 运行

```bash
Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
connect to database success
id: 1 name: 小乔 age: 16
id: 2 name: 小乔 age: 12

Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

### 插入、更新和删除操作的预处理基本一样，下面是插入示例

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

// 预处理插入
func prepareInsertDemo() {
 sqlStr := "INSERT INTO user(name, age) VALUES (?,?)"
 // 为以后的查询或执行创建预准备语句。
 // 可以从返回的语句并发运行多个查询或执行。
 // 当不再需要语句时，调用方必须调用语句的 Close 方法。
 stmt, err := db.Prepare(sqlStr)
 if err != nil {
  fmt.Printf("prepare failed, err:%v\n", err)
  return
 }
 defer stmt.Close()
 _, err = stmt.Exec("昭君", 12)
 if err != nil {
  fmt.Printf("insert failed, err:%v\n", err)
  return
 }
 _, err = stmt.Exec("黛玉", 16)
 if err != nil {
  fmt.Printf("insert failed, err:%v\n", err)
  return
 }
 fmt.Println("insert success.")
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
 
 // MySQL预处理 插入数据
 prepareInsertDemo()
}

```

#### 运行

```bash
Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
connect to database success
insert success.

Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ 
```

#### SQL 查询 插入结果

```sql
mysql> select * from user;
+----+--------+------+
| id | name   | age  |
+----+--------+------+
|  1 | 小乔   |   16 |
|  2 | 小乔   |   12 |
|  5 | 昭君   |   12 |
|  6 | 黛玉   |   16 |
+----+--------+------+
4 rows in set (0.00 sec)

mysql>

```

## 三、SQL注入问题

### 问：什么是SQL注入问题？

#### ChatGPT 答

SQL注入（SQL Injection）是一种常见的安全漏洞，指的是攻击者通过在应用程序的用户输入中插入恶意的SQL代码，从而利用应用程序对数据库的不当处理，执行未经授权的数据库操作。

SQL注入攻击通常发生在使用动态构建SQL语句的应用程序中，例如Web应用程序。攻击者利用应用程序没有正确验证、过滤或转义用户输入的数据，将恶意的SQL代码插入到查询语句中。

攻击者可以利用SQL注入问题进行各种恶意行为，包括但不限于以下情况：

1. 绕过身份验证：通过注入恶意的SQL代码，攻击者可以绕过应用程序的身份验证机制，以管理员或其他特权用户的身份执行操作。
2. 数据泄露：攻击者可以通过注入SELECT语句，获取应用程序未授权访问的数据，包括敏感信息（如用户密码、个人信息等）。
3. 数据篡改：攻击者可以通过注入UPDATE或DELETE语句，修改或删除数据库中的数据，破坏数据完整性。
4. 执行任意代码：攻击者可以通过注入恶意的SQL代码，执行任意的数据库操作或其他系统命令，导致系统崩溃、服务拒绝或其他安全问题。

为了防止SQL注入攻击，开发人员应该采取以下措施：

- 使用参数化查询或预处理语句：使用参数化查询或预处理语句可以将参数值与SQL语句分开处理，确保输入数据被正确转义和处理，避免了直接拼接用户输入到SQL语句中的问题。
- 输入验证与过滤：对用户输入的数据进行严格的验证和过滤，确保只接受符合预期的数据格式和范围，并在必要时进行转义处理。
- 最小权限原则：应用程序在连接数据库时，使用具有最低权限的数据库用户，仅具备执行必要操作的权限。
- 安全配置：确保数据库和应用程序的安全配置，包括禁用不必要的数据库功能、限制网络访问、定期更新数据库软件等。

通过采取这些安全措施，可以有效减轻SQL注入攻击的风险，提升应用程序的安全性。

#### 注意：不要自己拼接SQL语句，不要相信用户输入的内容是安全的、合法的

### 例子

以下是一个示例，展示了一个存在SQL注入漏洞的情况，并使用Go语言来演示如何预防注入问题：

```go
import (
 "database/sql"
 "fmt"
 "log"

 _ "github.com/go-sql-driver/mysql"
)

func main() {
 db, err := sql.Open("mysql", "username:password@tcp(hostname:port)/database")
 if err != nil {
  log.Fatal(err)
 }
 defer db.Close()

 // 假设用户输入的参数
 username := "admin' OR 1=1 --"
 password := "123456"

 // 构建SQL查询语句
 query := fmt.Sprintf("SELECT * FROM users WHERE username = '%s' AND password = '%s'", username, password)

 // 执行查询
 rows, err := db.Query(query)
 if err != nil {
  log.Fatal(err)
 }
 defer rows.Close()

 // 处理查询结果
 for rows.Next() {
  // 处理每一行数据
  var id int
  var username string
  var password string
  err := rows.Scan(&id, &username, &password)
  if err != nil {
   log.Fatal(err)
  }
  fmt.Println(id, username, password)
 }

 if err = rows.Err(); err != nil {
  log.Fatal(err)
 }
}

```

在上述代码中，我们假设用户输入的`username`参数为`admin' OR 1=1 --`，这是一种常见的注入尝试。然后，我们使用字符串插值的方式构建了一个SQL查询语句，将用户输入的参数直接嵌入到SQL语句中。

这种构建SQL语句的方式存在SQL注入漏洞。攻击者可以在`username`参数中插入恶意的SQL代码，使查询语句的逻辑被破坏。在本例中，`1=1`条件将始终为真，绕过了正常的身份验证。

为了防止SQL注入，我们应该使用预处理语句或参数化查询。以下是修复SQL注入漏洞的示例代码：

```go
import (
 "database/sql"
 "fmt"
 "log"

 _ "github.com/go-sql-driver/mysql"
)

func main() {
 db, err := sql.Open("mysql", "username:password@tcp(hostname:port)/database")
 if err != nil {
  log.Fatal(err)
 }
 defer db.Close()

 // 假设用户输入的参数
 username := "admin' OR 1=1 --"
 password := "123456"

 // 使用预处理语句
 stmt, err := db.Prepare("SELECT * FROM users WHERE username = ? AND password = ?")
 if err != nil {
  log.Fatal(err)
 }
 defer stmt.Close()

 // 执行查询
 rows, err := stmt.Query(username, password)
 if err != nil {
  log.Fatal(err)
 }
 defer rows.Close()

 // 处理查询结果
 for rows.Next() {
  // 处理每一行数据
  var id int
  var username string
  var password string
  err := rows.Scan(&id, &username, &password)
  if err != nil {
   log.Fatal(err)
  }
  fmt.Println(id, username, password)
 }

 if err = rows.Err

```

### 例子二

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

// sql注入示例
func sqlInjectDemo(name string) {
 sqlStr := fmt.Sprintf("select id, name, age from user where name='%s'", name)
 fmt.Printf("SQL: %s\n", sqlStr)
 var u user
 err := db.QueryRow(sqlStr).Scan(&u.id, &u.name, &u.age)
 if err != nil {
  fmt.Printf("exec failed, err: %v\n", err)
  return
 }
 fmt.Printf("user: %#v\n", u)
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
 
 // SQL 注入
 //sqlInjectDemo("黛玉")
 //  select id, name, age from user where name='xxx ' or 1=1#'
 sqlInjectDemo("xxx ' or 1=1#")
}

```

#### 运行

```bash
➜ go run main.go
connect to database success
SQL:select id, name, age from user where name='黛玉'
user: main.user{id:6, age:16, name:"黛玉"}

Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
connect to database success
SQL: select id, name, age from user where name='xxx ' or 1=1#'
user: main.user{id:1, age:16, name:"小乔"}

Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ 

```

## 四、SQL 占位符

不同的数据库使用不同的占位符语法，下面是一些常见数据库的占位符语法：

1. MySQL 使用问号（?）作为占位符。

示例：

```sql
SELECT * FROM table WHERE column = ?
```

2. PostgreSQL 使用美元符号加数字（$1、$2、$3...）作为占位符。

示例：

```sql
SELECT * FROM table WHERE column = $1
```

3. SQLite 使用问号（?）或冒号加数字（:1、:2、:3...）作为占位符。

示例：

```sql
SELECT * FROM table WHERE column = ?
```

或

```sql
SELECT * FROM table WHERE column = :1
```

4. Oracle 使用冒号加数字（:1、:2、:3...）作为占位符。

示例：

```sql
SELECT * FROM table WHERE column = :1
```

需要注意的是，占位符的语法可能会因不同的数据库驱动程序或框架而略有差异。因此，使用数据库驱动程序的文档或框架的指南来确定正确的占位符语法是很重要的。

此外，还有一些ORM（对象关系映射）框架，如GORM、Hibernate等，它们可以在不同的数据库中使用统一的语法和方式来表示占位符，以提供更高级的查询功能和更好的跨数据库兼容性。
