+++
title = "Rust Web 开发实战：使用 SQLx 连接 PostgreSQL 数据库"
description = "Rust Web 开发实战：使用 SQLx 连接 PostgreSQL 数据库"
date = 2025-08-19T14:25:59Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust Web 开发实战：使用 SQLx 连接 PostgreSQL 数据库

在现代 Web 应用开发中，与数据库的交互是不可或缺的核心环节。Rust 凭借其卓越的性能和内存安全特性，正成为后端开发的热门选择。本文将作为一篇入门实战教程，带领你一步步地使用流行的异步 SQL 库 sqlx，完成 Rust 应用与 PostgreSQL 数据库的连接和数据查询。无论你是 Rust 新手还是希望探索其 Web 开发能力的开发者，都能从中获得清晰的指引。

想用 Rust 写后端？数据库连接是第一步！本教程通过一个完整的项目实例，手把手教你如何配置 sqlx 库，安全地连接到 PostgreSQL 数据库，并执行编译时检查的 SQL 查询。这是为你的 Rust Web 全栈之路打下坚实数据基础的必备技能。

### 需要使用的 crate 和 数据库

- sqlx, v0.5.10
- PostgreSQL

### 创建项目

```bash
~/rust via 🅒 base
➜ cargo new db
     Created binary (application) `db` package

~/rust via 🅒 base
➜ cd db

db on  master [?] via 🦀 1.67.1 via 🅒 base
➜ c

db on  master [?] via 🦀 1.67.1 via 🅒 base
➜

```

### 项目目录

```bash
db on  master [?] is 📦 0.1.0 via 🦀 1.67.1 via 🅒 base
➜ tree -a  -I target
.
├── .env
├── .git
├── .gitignore
├── Cargo.lock
├── Cargo.toml
├── db.sql
└── src
    └── main.rs

11 directories, 11 files

db on  master [?] is 📦 0.1.0 via 🦀 1.67.1 via 🅒 base
➜
```

### Cargo.toml

```toml
[package]
name = "db"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
actix-rt = "2.8.0"
actix-web = "4.3.1"
chrono = { version = "0.4.24", features = ["serde"] }
dotenv = "0.15.0"
openssl = { version = "0.10.52", features = ["vendored"] }
serde = { version = "1.0.163", features = ["derive"] }
sqlx = { version = "0.6.3", features = [
    "postgres",
    "runtime-tokio-rustls",
    "macros",
    "chrono",
] }

```

### db.sql

```sql
DROP TABLE IF EXISTS course;

CREATE TABLE course
(
    ID serial PRIMARY KEY,
    teacher_id INT NOT NULL,
    NAME VARCHAR ( 140 ) NOT NULL,
    TIME TIMESTAMP DEFAULT now( )
);

INSERT INTO course ( ID, teacher_id, NAME, TIME )
VALUES
 ( 1, 1, 'First Course', '2023-05-18 21:30:00' );

INSERT INTO course ( ID, teacher_id, NAME, TIME )
VALUES
 ( 2, 1, 'Second Course', '2023-05-28 08:45:00' );

```

### .env

```bash
DATABASE_URL=postgres://postgres:postgres@127.0.0.1:5432/postgres
#      数据库名称    用户名    密码      主机名     端口  数据库名
```

### src/main.rs

```rust
use chrono::NaiveDateTime;
use dotenv::dotenv;
use sqlx::postgres::PgPoolOptions;
use std::env;
use std::io;

#[derive(Debug)]
pub struct Course {
    pub id: i32,
    pub teacher_id: i32,
    pub name: String,
    pub time: Option<NaiveDateTime>,
}

#[actix_rt::main]
async fn main() -> io::Result<()> {
    dotenv().ok(); // 把 .env 中的环境变量读取出来

    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL 没有在 .env 文件里设置");

    let db_pool = PgPoolOptions::new().connect(&database_url).await.unwrap();

    let course_rows = sqlx::query!(
        r#"select id, teacher_id, name, time from course where id = $1"#,
        1
    )
    .fetch_all(&db_pool)
    .await
    .unwrap();

    let mut courses_list = vec![];
    for row in course_rows {
        courses_list.push(Course {
            id: row.id,
            teacher_id: row.teacher_id,
            name: row.name,
            time: Some(chrono::NaiveDateTime::from(row.time.unwrap())),
        })
    }
    println!("Courses = {:?}", courses_list);
    Ok(())
}

```

### 运行

```rust
db on  master [?] is 📦 0.1.0 via 🦀 1.67.1 via 🅒 base
➜ cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 0.32s
     Running `target/debug/db`
Courses = [Course { id: 1, teacher_id: 1, name: "First Course", time: Some(2023-05-18T21:30:00) }]

db on  master [?] is 📦 0.1.0 via 🦀 1.67.1 via 🅒 base
➜

```

## 总结

通过本文的实践，我们从零开始完成了一个 Rust 项目与 PostgreSQL 数据库的成功连接。我们重点掌握了以下几个核心步骤：

1. 项目配置：正确设置 Cargo.toml 文件，引入 sqlx、dotenv 等关键依赖。

2. 环境管理：使用 .env 文件安全地管理数据库连接字符串。

3. 连接数据库：通过 PgPoolOptions 创建了一个异步数据库连接池。

4. 执行查询：利用 sqlx::query! 宏执行了类型安全的 SQL 查询，并将结果映射到自定义的 Rust 结构体中。

sqlx 最大的亮点在于其编译时查询检查，这极大地提升了代码的健壮性，避免了许多在运行时才会出现的 SQL 错误。本次实践是数据库交互的基础，在此之上，我们未来可以继续探索更复杂的增删改查 (CRUD) 操作、事务处理等，并最终将其无缝集成到 Actix-web 等 Web 框架中，构建功能完善的后端服务。
