+++
title = "Go 语言实现 MySQL 数据库事务"
date = 2023-06-11T17:47:40+08:00
description = "Go 语言之 实现 MySQL 数据库事务"
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# Go 实现 MySQL 数据库事务

## 一、MySQL事务

MySQL事务是指一组数据库操作，它们被视为一个逻辑单元，并且要么全部成功执行，要么全部回滚（撤销）。事务是数据库管理系统提供的一种机制，用于确保数据的一致性和完整性。

事务具有以下特性（通常由ACID原则定义）：

1. 原子性（Atomicity）：事务中的所有操作要么全部成功执行，要么全部回滚，不存在部分执行的情况。如果事务中的任何一个操作失败，则所有操作都会被回滚到事务开始之前的状态，保持数据的一致性。
2. 一致性（Consistency）：事务的执行使数据库从一个一致的状态转换到另一个一致的状态。这意味着在事务开始和结束时，数据必须满足预定义的完整性约束。
3. 隔离性（Isolation）：事务的执行是相互隔离的，即一个事务的操作在提交之前对其他事务是不可见的。并发事务之间的相互影响被隔离，以避免数据损坏和不一致的结果。
4. 持久性（Durability）：一旦事务提交成功，其对数据库的更改将永久保存，即使在系统故障或重启之后也能保持数据的持久性。

在MySQL中，使用以下语句来开始一个事务：

```sql
START TRANSACTION;
```

在事务中，可以执行一系列的数据库操作，如插入、更新和删除等。最后，使用以下语句来提交事务或回滚事务：

提交事务：

```sql
COMMIT;
```

回滚事务：

```sql
ROLLBACK;
```

通过使用事务，可以确保数据库操作的一致性和完整性，尤其在处理涉及多个相关操作的复杂业务逻辑时非常有用。

## 二、MySQL 事务 示例

以下是一个示例，演示如何在MySQL中使用事务：

```sql
START TRANSACTION;

-- 在事务中执行一系列数据库操作
INSERT INTO users (name, age) VALUES ('Alice', 25);
UPDATE accounts SET balance = balance - 100 WHERE user_id = 1;
DELETE FROM logs WHERE user_id = 1;

-- 如果一切正常，提交事务
COMMIT;
```

在上述示例中，我们开始了一个事务，并在事务中执行了一系列数据库操作。

首先，我们向`users`表插入了一条新记录，

然后更新了`accounts`表中用户ID为1的账户余额，

最后删除了`logs`表中与用户ID为1相关的日志条目。

如果在事务执行的过程中出现任何错误或异常情况，可以使用`ROLLBACK`语句回滚事务，使所有操作都被撤销，数据库恢复到事务开始之前的状态：

```sql
START TRANSACTION;

-- 在事务中执行一系列数据库操作
INSERT INTO users (name, age) VALUES ('Bob', 30);
UPDATE accounts SET balance = balance - 200 WHERE user_id = 2;

-- 发生错误或异常，回滚事务
ROLLBACK;
```

在上述示例中，如果在更新`accounts`表的操作中发生错误，整个事务将被回滚，插入的用户记录和更新的账户余额将被撤销。

事务的关键在于将多个相关的数据库操作组织在一起，并以原子性和一致性的方式进行提交或回滚。这确保了数据的完整性和一致性，同时也提供了灵活性和错误恢复机制。

## 三、MySQL 事务引擎

MySQL提供了多个事务引擎，每个引擎都具有不同的特性和适用场景。以下是MySQL中常见的事务引擎：

1. InnoDB：InnoDB是MySQL默认的事务引擎。它支持事务、行级锁定、外键约束和崩溃恢复等功能。InnoDB适用于需要强调数据完整性和并发性能的应用程序。
2. MyISAM：MyISAM是MySQL的另一个常见的事务引擎。它不支持事务和行级锁定，但具有较高的插入和查询性能。MyISAM适用于读密集型应用程序，例如日志记录和全文搜索。
3. NDB Cluster：NDB Cluster是MySQL的集群事务引擎，适用于需要高可用性和可扩展性的分布式应用程序。它具有自动分片、数据冗余和故障恢复等功能。
4. Memory：Memory（也称为Heap）引擎将表数据存储在内存中，提供非常高的插入和查询性能。但由于数据存储在内存中，因此在数据库重新启动时数据会丢失。Memory引擎适用于临时数据或缓存数据的存储。

除了以上列出的常见事务引擎之外，MySQL还支持其他一些事务引擎，例如Archive、Blackhole等。每个引擎都有其独特的特性和适用场景，选择合适的事务引擎需要根据应用程序的需求和性能要求进行评估。

在创建表时，可以指定所需的事务引擎。例如，使用以下语句创建一个使用InnoDB引擎的表：

```sql
CREATE TABLE mytable (
  id INT PRIMARY KEY,
  name VARCHAR(50)
) ENGINE=InnoDB;

```

需要注意的是，不同的事务引擎可能会有不同的配置和限制，因此在选择和使用特定的事务引擎时，建议参考MySQL文档以了解详细信息和最佳实践。

## 四、事务实例

### 开启事务 Begin 源码

```go
// BeginTx starts a transaction.
//
// The provided context is used until the transaction is committed or rolled back.
// If the context is canceled, the sql package will roll back
// the transaction. Tx.Commit will return an error if the context provided to
// BeginTx is canceled.
//
// The provided TxOptions is optional and may be nil if defaults should be used.
// If a non-default isolation level is used that the driver doesn't support,
// an error will be returned.
func (db *DB) BeginTx(ctx context.Context, opts *TxOptions) (*Tx, error) {
 var tx *Tx
 var err error

 err = db.retry(func(strategy connReuseStrategy) error {
  tx, err = db.begin(ctx, opts, strategy)
  return err
 })

 return tx, err
}

// Begin starts a transaction. The default isolation level is dependent on
// the driver.
//
// Begin uses context.Background internally; to specify the context, use
// BeginTx.
func (db *DB) Begin() (*Tx, error) {
 return db.BeginTx(context.Background(), nil)
}
```

### 中止事务 Rollback 源码

```go
// rollback aborts the transaction and optionally forces the pool to discard
// the connection.
func (tx *Tx) rollback(discardConn bool) error {
 if !tx.done.CompareAndSwap(false, true) {
  return ErrTxDone
 }

 if rollbackHook != nil {
  rollbackHook()
 }

 // Cancel the Tx to release any active R-closemu locks.
 // This is safe to do because tx.done has already transitioned
 // from 0 to 1. Hold the W-closemu lock prior to rollback
 // to ensure no other connection has an active query.
 tx.cancel()
 tx.closemu.Lock()
 tx.closemu.Unlock()

 var err error
 withLock(tx.dc, func() {
  err = tx.txi.Rollback()
 })
 if !errors.Is(err, driver.ErrBadConn) {
  tx.closePrepared()
 }
 if discardConn {
  err = driver.ErrBadConn
 }
 tx.close(err)
 return err
}

// Rollback aborts the transaction.
func (tx *Tx) Rollback() error {
 return tx.rollback(false)
}
```

### 提交事务 Commit 源码

```go
// Commit commits the transaction.
func (tx *Tx) Commit() error {
 // Check context first to avoid transaction leak.
 // If put it behind tx.done CompareAndSwap statement, we can't ensure
 // the consistency between tx.done and the real COMMIT operation.
 select {
 default:
 case <-tx.ctx.Done():
  if tx.done.Load() {
   return ErrTxDone
  }
  return tx.ctx.Err()
 }
 if !tx.done.CompareAndSwap(false, true) {
  return ErrTxDone
 }

 // Cancel the Tx to release any active R-closemu locks.
 // This is safe to do because tx.done has already transitioned
 // from 0 to 1. Hold the W-closemu lock prior to rollback
 // to ensure no other connection has an active query.
 tx.cancel()
 tx.closemu.Lock()
 tx.closemu.Unlock()

 var err error
 withLock(tx.dc, func() {
  err = tx.txi.Commit()
 })
 if !errors.Is(err, driver.ErrBadConn) {
  tx.closePrepared()
 }
 tx.close(err)
 return err
}
```

### 例子

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

// 事务操作
func transactionDemo() {
 // 启动事务。默认隔离级别取决于驱动程序。
 tx, err := db.Begin() // 开启事务
 if err != nil {
  if tx != nil {
   tx.Rollback() // 回滚 中止事务
  }
  fmt.Printf("begin trans failed, err:%v\n", err)
  return
 }
 sqlStr1 := "UPDATE user SET age=? WHERE id=?"
 ret1, err := tx.Exec(sqlStr1, 22, 2)
 if err != nil {
  tx.Rollback() // 回滚
  fmt.Printf("exec sql1 failed, err: %v\n", err)
  return
 }
 // RowsAffected 返回受更新、插入或删除影响的行数。并非每个数据库或数据库驱动程序都支持此功能。
 affRow1, err := ret1.RowsAffected()
 if err != nil {
  tx.Rollback() // 回滚
  fmt.Printf("exec ret1.RowsAffected() failed, err: %v\n", err)
  return
 }

 sqlStr2 := "UPDATE user SET age=? WHERE id=?"
 ret2, err := tx.Exec(sqlStr2, 100, 5)
 if err != nil {
  tx.Rollback() // 回滚
  fmt.Printf("exec sql2 failed, err: %v\n", err)
  return
 }
 affRow2, err := ret2.RowsAffected()
 if err != nil {
  tx.Rollback() // 回滚
  fmt.Printf("exec ret2.RowsAffected() failed, err: %v\n", err)
  return
 }

 fmt.Println(affRow1, affRow2)
 if affRow1 == 1 && affRow2 == 1 {
  fmt.Println("事务提交...")
  tx.Commit() // 提交事务
 } else {
  tx.Rollback()
  fmt.Println("事务回滚...")
 }

 fmt.Println("exec trans success!")
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

 // 事务
 transactionDemo()
}

```

#### 运行

```bash
Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
connect to database success
1 0
事务回滚...
exec trans success!

Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ go run main.go
connect to database success
1 1
事务提交...
exec trans success!

Code/go/mysql_demo via 🐹 v1.20.3 via 🅒 base 
➜ 

```

#### SQL 查询结果

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

mysql> select * from user;  # 第一次执行后查询
+----+--------+------+
| id | name   | age  |
+----+--------+------+
|  1 | 小乔   |   16 |
|  2 | 小乔   |   12 |
|  5 | 昭君   |   12 |
|  6 | 黛玉   |   16 |
+----+--------+------+
4 rows in set (0.00 sec)

mysql> select * from user;   # 第二次执行后查询
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

在上例中，第一次执行SQL更新中的sqlStr2值为：age = 100， id = 3。因没有id为3 的数据，故事务回滚了，即使sqlStr1执行成功，也会回滚到事务开始的状态。所以第一次执行后查询数据库，数据未发生改变。第二次执行SQL更新中的sqlStr2值为：age = 100， id = 5。数据库中存在 id 为 5 的数据，事务提交成功，SQL语句执行成功。故第二次执行后查询数据发生改变，更新成功。
