+++
title = "Rust 开发踩坑：无法删除数据库？教你一招解决 `is being accessed` 错误"
description = "Rust 开发踩坑：无法删除数据库？教你一招解决 `is being accessed` 错误"
date = 2025-12-11T14:22:46Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# **Rust 开发踩坑：无法删除数据库？教你一招解决 `is being accessed` 错误**

在 Rust + SQLx 的开发过程中，我们经常需要彻底重置数据库环境：删掉旧库、重建新库，然后重新运行 Migration。这是一个非常标准的“洗库”流程。

然而，当你信心满满地输入 `dropdb` 时，终端却冷冰冰地甩给你一句报错：“数据库正在被其他用户访问”。这通常是因为之前的 `pgcli` 终端、某个未关闭的测试进程，或者 IDE 的数据库插件还连在上面。

今天我们来看一看，如何优雅地踢掉这些“钉子户”连接，顺利完成数据库重置。

在进行 Rust 项目开发重置数据库时，常遇到 `dropdb` 失败的问题，提示数据库正被其他会话占用。本文记录了该问题的排查过程，提供了两种解决方案：一种是通过 `pg_stat_activity` 查询并手动终止进程的常规方法；另一种是利用 PostgreSQL 新版本特性的“一行命令强制删除”法。文末附带了重置后的环境恢复步骤。

## 💥 问题复现

### 当我们试图删除 `chat` 数据库时，出现了以下报错

```bash
➜ dropdb chat
dropdb: error: database removal failed: ERROR:  database "chat" is being accessed by other users
DETAIL:  There are 2 other sessions using the database.
```

**原因分析：** PostgreSQL 拥有自我保护机制，为了防止数据损坏，它**绝对禁止**在还有活动连接（Active Sessions）的情况下删除数据库。报错详情显示，目前还有 2 个会话（Session）“赖”在数据库里没走。也就是说删除失败是因为有其他会话正在使用数据库 "chat"。PostgreSQL 不允许在有活动连接时删除数据库。

## 🛠️ 方案一：常规排查法（了解原理）

如果你想知道到底是谁在占用数据库，可以使用这个方法。

### **第一步：揪出“钉子户”** 查询系统视图 `pg_stat_activity`，看看是谁连接着 `chat`

### 检查当前连接到 "chat" 的会话

```sql
psql -U postgres -c "SELECT pid, usename, application_name, client_addr, state FROM pg_stat_activity WHERE datname = 'chat';"
```

#### 输出结果

```bash
 pid  | usename  | application_name | client_addr | state
------+----------+------------------+-------------+-------
 3086 | postgres |                  | ::1         | idle
 5406 | postgres |                  | ::1         | idle
(2 rows)
```

可以看到，有两个 PID 为 3086 和 5406 的进程处于 `idle`（空闲）状态。这很可能就是你忘记关掉的 `pgcli` 窗口。即发现两个空闲会话（PID 3086 和 5406）连接到 "chat"。

### **第二步：强制终止会话** 使用 `pg_terminate_backend` 函数杀掉这些进程

### 终止这些会话后再删除数据库

```sql
psql -U postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'chat' AND pid <> pg_backend_pid();"
```

*注：`pid <> pg_backend_pid()` 是为了防止把自己当前的执行连接也给杀掉。*

#### 输出结果

```bash
 pg_terminate_backend
----------------------
 t
 t
(2 rows)
```

会话已终止。

### **第三步：再次删除** 现在连接已清空，可以安全删除

### 删除数据库

```sql
dropdb chat
```

数据库已删除。

## 🚀 方案二：一行命令“核弹”法（推荐）

如果你觉得方案一太繁琐，而且你的 PostgreSQL 版本较新（**PostgreSQL 13+**），那么可以直接使用 `FORCE` 选项。它会自动帮你切断所有连接并删除数据库，干净利落。

直接执行：

```sql
psql -U postgres -c "DROP DATABASE chat WITH (FORCE);"
```

**注意：** `WITH (FORCE)` 是强制操作，生产环境请慎用！但在本地开发环境（Localhost）重置数据时，它是最高效的工具。

## ♻️ 后续：重建与迁移

清理完旧环境后，我们就可以愉快地重新初始化 Rust 项目的数据库环境了：

**1. 创建新库**

```bash
➜ createdb chat

ferris-chat on  main [!?] via 🦀 1.91.1 took 8.2s
➜ createdb chat
```

**2. 运行 SQLx 迁移**

```sql
ferris-chat on  main [!?] via 🦀 1.91.1
➜ sqlx migrate run
Applied 20251203080702/migrate initial (20.680416ms)
```

至此，一个干干净净的数据库环境已经准备好，可以继续写代码了。

## 📌 总结与速查

PostgreSQL 不允许在有活动连接时删除数据库。你的 "chat" 数据库有两个空闲会话（可能是之前的 psql 连接或应用连接未关闭）。

解决方案：

1. 终止所有连接到该数据库的会话
2. 然后删除数据库

如果以后再遇到类似问题，可以直接复制下面的命令：

**方法 A：通用组合命令（推荐加入 Makefile）**

```sql
# 终止所有连接到数据库的会话，然后删除数据库
psql -U postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'chat' AND pid <> pg_backend_pid();" && dropdb chat
```

方法 B：极简命令（仅限 PostgreSQL 12+）

```sql
psql -U postgres -c "DROP DATABASE chat WITH (FORCE);"
```

注意：`DROP DATABASE ... WITH (FORCE)` 是 PostgreSQL 12+ 的功能，会自动终止所有连接并删除数据库。

#### 总结

遇到 `database is being accessed` 错误时：

1. **想看原因**：查 `pg_stat_activity` 表。
2. **只想解决**：用 `DROP DATABASE ... WITH (FORCE)`。

把这行命令加入你的 `Makefile` 或 `Justfile` 中，下次重置数据库也就是一键的事。

## 参考

- <https://crates.io/crates/sqlx-db-tester>
- <https://docs.rs/argon2/latest/argon2/>
- <https://github.com/launchbadge/sqlx>
