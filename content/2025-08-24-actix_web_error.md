+++
title = "Rust Web实战：构建优雅的 Actix Web 统一错误处理"
description = "Rust Web实战：构建优雅的 Actix Web 统一错误处理"
date = 2025-08-24T02:42:41Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust Web实战：构建优雅的 Actix Web 统一错误处理

在构建任何健壮的 Web 服务时，错误处理都是不可或缺的核心环节。一个优秀的服务不仅要在正常情况下稳定运行，更要在遇到数据库连接失败、用户输入非法、I/O 异常等问题时，能给出清晰、统一且安全的响应。

然而，将来自不同来源（如数据库、序列化、业务逻辑）的错误整合成规范的 HTTP 响应，常常让代码变得混乱。本文将基于 Rust 及其高性能 Web 框架 Actix Web，通过一个完整的项目实例，手把手带你构建一个优雅、集中式的错误处理系统。你将学会如何利用 Rust 的类型系统和 Actix 的 ResponseError trait，将复杂的错误管理变得简单而高效。

本文深入探讨了在 Rust 和 Actix Web 框架中实现统一错误处理的最佳实践。文章从 Rust 语言的 Result 枚举和 ? 运算符入手，逐步引导读者创建一个自定义的全局错误类型。通过为该类型实现 ResponseError 和 From trait，我们将来自数据库 (sqlx)、框架本身及业务逻辑的多种错误，无缝转换为统一、规范的 HTTP 响应，最终实现代码的高度可维护性和应用的健壮性。

## Web Service 中的统一错误处

### Actix Web Service 自定义错误类型    ->    自定义错误转为 HTTP Response

- 数据库
  - 数据库错误
- 串行化
  - serde 错误
- I/O 操作
  - I/O 错误
- Actix-Web 库
  - Actix 错误
- 用户非法输入
  - 用户非法输入错误

## Actix-Web 的错误处理

- 编程语言常用的两种错误处理方式：
  - 异常
  - 返回值（ Rust 使用这种）
- Rust 希望开发者显式的处理错误，因此，可能出错的函数返回Result 枚举类型，其定义如下：

```rust
enum Result<T, E> {
  Ok(T),
 Err(E),
}
```

### 例子

```rust
use std::num::ParseIntError;

fn main() {
  let result = square("25");
  println!("{:?}", result);
}

fn square(val: &str) -> Result<i32, ParseIntError> {
  match val.parse::<i32>() {
    Ok(num) => Ok(num.pow(2)),
    Err(e) => Err(3),
  }
}
```

## ? 运算符

- 在某函数中使用 ? 运算符，该运算符尝试从 Result 中获取值：
  - 如果不成功，它就会接收 Error ，中止函数执行，并把错误传播到调用该函数的函数。

```rust
use std::num::ParseIntError;

fn main() {
  let result = square("25");
  println!("{:?}", result);
}

fn square(val: &str) -> Result<i32, ParseIntError> {
  let num = val.parse::<i32>()?;
  Ok(num ^ 2)
}
```

## 自定义错误类型

- 创建一个自定义错误类型，它可以是多种错误类型的抽象。
- 例如：

```rust
#[derive(Debug)]
pub enum MyError {
  ParseError,
 IOError,
}
```

## Actix-Web 把错误转化为 HTTP Response

- Actix-Web 定义了一个通用的错误类型（ struct ）：`actix_web::error::Error`
  - 它实现了 `std::error::Error` 这个 trait
- 任何实现了标准库 Error trait 的类型，都可以通过 ? 运算符，转化为 Actix 的 Error 类型
- Actix 的 Error 类型会自动的转化为 HTTP Response ，返回给客户端。
- ResponseError trait ：任何实现该 trait 的错误均可转化为HTTP Response 消息。
- 内置的实现： Actix-Web 对于常见错误有内置的实现，例如：
- Rust 标准 I/O 错误
- Serde 错误
- Web 错误，例如： ProtocolError 、 Utf8Error 、 ParseError 等等
- 其它错误类型：内置实现不可用时，需要自定义实现错误到 HTTP Response 的转换

## 创建自定义错误处理器

1. 创建一个自定义错误类型
2. 实现 From trait ，用于把其它错误类型转化为该类型
3. 为自定义错误类型实现 ResponseError trait
4. 在 handler 里返回自定义错误类型
5. Actix 会把错误转化为 HTTP 响应

### 项目目录

```bash
ws on  main [✘!?] via 🦀 1.67.1 via 🅒 base
➜ tree -a -I target
.
├── .env
├── .git
├── .gitignore
├── Cargo.lock
├── Cargo.toml
├── README.md
└── webservice
    ├── Cargo.toml
    └── src
        ├── bin
        │   ├── server1.rs
        │   └── teacher-service.rs
        ├── db_access.rs
        ├── errors.rs
        ├── handlers.rs
        ├── main.rs
        ├── models.rs
        ├── routers.rs
        └── state.rs

40 directories, 47 files

ws on  main [✘!?] via 🦀 1.67.1 via 🅒 base
```

### webservice/src/errors.rs

```rust
use actix_web::{error, http::StatusCode, HttpResponse, Result};
use serde::Serialize;
use sqlx::error::Error as SQLxError;
use std::fmt;

#[derive(Debug, Serialize)]
pub enum MyError {
    DBError(String),
    ActixError(String),
    NotFound(String),
}
#[derive(Debug, Serialize)]
pub struct MyErrorResponse {
    error_message: String,
}

impl MyError {
    fn error_response(&self) -> String {
        match self {
            MyError::DBError(msg) => {
                println!("Database error occurred: {:?}", msg);
                "Database error".into()
            }
            MyError::ActixError(msg) => {
                println!("Server error occurred: {:?}", msg);
                "Internal server error".into()
            }
            MyError::NotFound(msg) => {
                println!("Not found error occurred: {:?}", msg);
                msg.into()
            }
        }
    }
}

impl error::ResponseError for MyError {
    fn status_code(&self) -> StatusCode {
        match self {
            MyError::DBError(msg) | MyError::ActixError(msg) => StatusCode::INTERNAL_SERVER_ERROR,
            MyError::NotFound(msg) => StatusCode::NOT_FOUND,
        }
    }
    fn error_response(&self) -> HttpResponse {
        HttpResponse::build(self.status_code()).json(MyErrorResponse {
            error_message: self.error_response(),
        })
    }
}

impl fmt::Display for MyError {
    fn fmt(&self, f: &mut fmt::Formatter) -> Result<(), fmt::Error> {
        write!(f, "{}", self)
    }
}

impl From<actix_web::error::Error> for MyError {
    fn from(err: actix_web::error::Error) -> Self {
        MyError::ActixError(err.to_string())
    }
}

impl From<SQLxError> for MyError {
    fn from(err: SQLxError) -> Self {
        MyError::DBError(err.to_string())
    }
}

```

### webservice/src/bin/teacher-service.rs

```rust
use actix_web::{web, App, HttpServer};
use dotenv::dotenv;
use sqlx::postgres::PgPoolOptions;
use std::env;
use std::io;
use std::sync::Mutex;

#[path = "../db_access.rs"]
mod db_access;
#[path = "../errors.rs"]
mod errors;
#[path = "../handlers.rs"]
mod handlers;
#[path = "../models.rs"]
mod models;
#[path = "../routers.rs"]
mod routers;
#[path = "../state.rs"]
mod state;

use routers::*;
use state::AppState;

#[actix_rt::main]
async fn main() -> io::Result<()> {
    dotenv().ok();

    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set.");
    let db_pool = PgPoolOptions::new().connect(&database_url).await.unwrap();

    let shared_data = web::Data::new(AppState {
        health_check_response: "I'm Ok.".to_string(),
        visit_count: Mutex::new(0),
        // courses: Mutex::new(vec![]),
        db: db_pool,
    });
    let app = move || {
        App::new()
            .app_data(shared_data.clone())
            .configure(general_routes)
            .configure(course_routes) // 路由注册
    };

    HttpServer::new(app).bind("127.0.0.1:3000")?.run().await
}

```

### webservice/src/db_access.rs

```rust
use super::errors::MyError;
use super::models::*;
use chrono::NaiveDateTime;
use sqlx::postgres::PgPool;

pub async fn get_courses_for_teacher_db(
    pool: &PgPool,
    teacher_id: i32,
) -> Result<Vec<Course>, MyError> {
    let rows = sqlx::query!(
        r#"SELECT id, teacher_id, name, time FROM course WHERE teacher_id = $1"#,
        teacher_id
    )
    .fetch_all(pool)
    .await?;

    let courses: Vec<Course> = rows
        .iter()
        .map(|row| Course {
            id: Some(row.id),
            teacher_id: row.teacher_id,
            name: row.name.clone(),
            time: Some(NaiveDateTime::from(row.time.unwrap())),
        })
        .collect();

    match courses.len() {
        0 => Err(MyError::NotFound("Courses not found teacher".into())),
        _ => Ok(courses),
    }
}

pub async fn get_courses_detail_db(pool: &PgPool, teacher_id: i32, course_id: i32) -> Course {
    let row = sqlx::query!(
        r#"SELECT id, teacher_id, name, time FROM course WHERE teacher_id = $1 and id = $2"#,
        teacher_id,
        course_id
    )
    .fetch_one(pool)
    .await
    .unwrap();

    Course {
        id: Some(row.id),
        teacher_id: row.teacher_id,
        name: row.name.clone(),
        time: Some(NaiveDateTime::from(row.time.unwrap())),
    }
}

pub async fn post_new_course_db(pool: &PgPool, new_course: Course) -> Course {
    let row = sqlx::query!(
        r#"INSERT INTO course (id, teacher_id, name) VALUES ($1, $2, $3)
        RETURNING id, teacher_id, name, time"#,
        new_course.id,
        new_course.teacher_id,
        new_course.name
    )
    .fetch_one(pool)
    .await
    .unwrap();

    Course {
        id: Some(row.id),
        teacher_id: row.teacher_id,
        name: row.name.clone(),
        time: Some(NaiveDateTime::from(row.time.unwrap())),
    }
}

```

### webservice/src/handlers.rs

```rust
use super::db_access::*;
use super::errors::MyError;
use super::state::AppState;
use actix_web::{web, HttpResponse};

pub async fn health_check_handler(app_state: web::Data<AppState>) -> HttpResponse {
    let health_check_response = &app_state.health_check_response;
    let mut visit_count = app_state.visit_count.lock().unwrap();
    let response = format!("{} {} times", health_check_response, visit_count);
    *visit_count += 1;
    HttpResponse::Ok().json(&response)
}

use super::models::Course;

pub async fn new_course(
    new_course: web::Json<Course>,
    app_state: web::Data<AppState>,
) -> HttpResponse {
    let course = post_new_course_db(&app_state.db, new_course.into()).await;
    HttpResponse::Ok().json(course)
}

pub async fn get_courses_for_teacher(
    app_state: web::Data<AppState>,
    params: web::Path<usize>,
) -> Result<HttpResponse, MyError> {
    let teacher_id = i32::try_from(params.into_inner()).unwrap();
    get_courses_for_teacher_db(&app_state.db, teacher_id)
        .await
        .map(|courses| HttpResponse::Ok().json(courses))
}

pub async fn get_courses_detail(
    app_state: web::Data<AppState>,
    params: web::Path<(usize, usize)>,
) -> HttpResponse {
    let teacher_id = i32::try_from(params.0).unwrap();
    let course_id = i32::try_from(params.1).unwrap();
    let course = get_courses_detail_db(&app_state.db, teacher_id, course_id).await;
    HttpResponse::Ok().json(course)
}

#[cfg(test)]
mod tests {
    use super::*;
    use actix_web::http::StatusCode;
    use dotenv::dotenv;
    use sqlx::postgres::PgPoolOptions;
    use std::env;
    use std::sync::Mutex;

    #[actix_rt::test] // 异步测试
    async fn post_course_test() {
        dotenv().ok();
        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
        let db_pool = PgPoolOptions::new().connect(&db_url).await.unwrap();
        let app_state: web::Data<AppState> = web::Data::new(AppState {
            health_check_response: "".to_string(),
            visit_count: Mutex::new(0),
            db: db_pool,
        });

        let course = web::Json(Course {
            teacher_id: 1,
            name: "Test course".into(),
            id: Some(3), // serial
            time: None,
        });

        let resp = new_course(course, app_state).await;
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[actix_rt::test]
    async fn get_all_courses_success() {
        dotenv().ok();
        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
        let db_pool = PgPoolOptions::new().connect(&db_url).await.unwrap();
        let app_state: web::Data<AppState> = web::Data::new(AppState {
            health_check_response: "".to_string(),
            visit_count: Mutex::new(0),
            db: db_pool,
        });
        let teacher_id: web::Path<usize> = web::Path::from(1);
        let resp = get_courses_for_tescher(app_state, teacher_id)
            .await
            .unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[actix_rt::test]
    async fn get_one_course_success() {
        dotenv().ok();
        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
        let db_pool = PgPoolOptions::new().connect(&db_url).await.unwrap();
        let app_state: web::Data<AppState> = web::Data::new(AppState {
            health_check_response: "".to_string(),
            visit_count: Mutex::new(0),
            db: db_pool,
        });
        let params: web::Path<(usize, usize)> = web::Path::from((1, 1));
        let resp = get_courses_detail(app_state, params).await;
        assert_eq!(resp.status(), StatusCode::OK);
    }
}

```

### 测试

```bash
ws on  main via 🦀 1.67.1 via 🅒 base
➜ cargo test --bin teacher-service get_all_courses_success
   Compiling webservice v0.1.0 (/Users/qiaopengjun/rust/ws/webservice)
warning: unused variable: `msg`
  --> webservice/src/bin/../errors.rs:39:30
   |
39 |             MyError::DBError(msg) | MyError::ActixError(msg) => StatusCode::INTERNAL_SERVER_ERROR,
   |                              ^^^                        ^^^
   |
   = note: `#[warn(unused_variables)]` on by default
help: if this is intentional, prefix it with an underscore
   |
39 |             MyError::DBError(_msg) | MyError::ActixError(_msg) => StatusCode::INTERNAL_SERVER_ERROR,
   |                              ~~~~                        ~~~~

warning: unused variable: `msg`
  --> webservice/src/bin/../errors.rs:40:31
   |
40 |             MyError::NotFound(msg) => StatusCode::NOT_FOUND,
   |                               ^^^ help: if this is intentional, prefix it with an underscore: `_msg`

warning: `webservice` (bin "teacher-service" test) generated 2 warnings (run `cargo fix --bin "teacher-service" --tests` to apply 2 suggestions)
    Finished test [unoptimized + debuginfo] target(s) in 1.55s
     Running unittests src/bin/teacher-service.rs (target/debug/deps/teacher_service-32d6a48d6ee3c4b4)

running 1 test
test handlers::tests::get_all_courses_success ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 2 filtered out; finished in 0.01s


ws on  main [✘!?] via 🦀 1.67.1 via 🅒 base took 2.1s
➜
```

在 match 分支中我们只关心错误的类型，而没有使用具体的错误信息 msg，可以通过将其重命名为 _msg 来消除警告。

### webservice/src/db_access.rs

```rust
use super::errors::MyError;
use super::models::*;
use chrono::NaiveDateTime;
use sqlx::postgres::PgPool;

pub async fn get_courses_for_teacher_db(
    pool: &PgPool,
    teacher_id: i32,
) -> Result<Vec<Course>, MyError> {
    let rows = sqlx::query!(
        r#"SELECT id, teacher_id, name, time FROM course WHERE teacher_id = $1"#,
        teacher_id
    )
    .fetch_all(pool)
    .await?;

    let courses: Vec<Course> = rows
        .iter()
        .map(|row| Course {
            id: Some(row.id),
            teacher_id: row.teacher_id,
            name: row.name.clone(),
            time: Some(NaiveDateTime::from(row.time.unwrap())),
        })
        .collect();

    match courses.len() {
        0 => Err(MyError::NotFound("Courses not found teacher".into())),
        _ => Ok(courses),
    }
}

pub async fn get_courses_detail_db(
    pool: &PgPool,
    teacher_id: i32,
    course_id: i32,
) -> Result<Course, MyError> {
    let row = sqlx::query!(
        r#"SELECT id, teacher_id, name, time FROM course WHERE teacher_id = $1 and id = $2"#,
        teacher_id,
        course_id
    )
    .fetch_one(pool)
    .await;

    if let Ok(row) = row {
        Ok(Course {
            id: Some(row.id),
            teacher_id: row.teacher_id,
            name: row.name.clone(),
            time: Some(NaiveDateTime::from(row.time.unwrap())),
        })
    } else {
        Err(MyError::NotFound("Course Id not found".into()))
    }
}

pub async fn post_new_course_db(pool: &PgPool, new_course: Course) -> Result<Course, MyError> {
    let row = sqlx::query!(
        r#"INSERT INTO course (id, teacher_id, name) VALUES ($1, $2, $3)
        RETURNING id, teacher_id, name, time"#,
        new_course.id,
        new_course.teacher_id,
        new_course.name
    )
    .fetch_one(pool)
    .await?;

    Ok(Course {
        id: Some(row.id),
        teacher_id: row.teacher_id,
        name: row.name.clone(),
        time: Some(NaiveDateTime::from(row.time.unwrap())),
    })
}

```

### webservice/src/handlers.rs

```rust
use super::db_access::*;
use super::errors::MyError;
use super::state::AppState;
use actix_web::{web, HttpResponse};

pub async fn health_check_handler(app_state: web::Data<AppState>) -> HttpResponse {
    let health_check_response = &app_state.health_check_response;
    let mut visit_count = app_state.visit_count.lock().unwrap();
    let response = format!("{} {} times", health_check_response, visit_count);
    *visit_count += 1;
    HttpResponse::Ok().json(&response)
}

use super::models::Course;

pub async fn new_course(
    new_course: web::Json<Course>,
    app_state: web::Data<AppState>,
) -> Result<HttpResponse, MyError> {
    post_new_course_db(&app_state.db, new_course.into())
        .await
        .map(|course| HttpResponse::Ok().json(course))
}

pub async fn get_courses_for_tescher(
    app_state: web::Data<AppState>,
    params: web::Path<usize>,
) -> Result<HttpResponse, MyError> {
    let teacher_id = i32::try_from(params.into_inner()).unwrap();
    get_courses_for_teacher_db(&app_state.db, teacher_id)
        .await
        .map(|courses| HttpResponse::Ok().json(courses))
}

pub async fn get_courses_detail(
    app_state: web::Data<AppState>,
    params: web::Path<(usize, usize)>,
) -> Result<HttpResponse, MyError> {
    let teacher_id = i32::try_from(params.0).unwrap();
    let course_id = i32::try_from(params.1).unwrap();
    get_courses_detail_db(&app_state.db, teacher_id, course_id)
        .await
        .map(|course| HttpResponse::Ok().json(course))
}

#[cfg(test)]
mod tests {
    use super::*;
    use actix_web::http::StatusCode;
    use dotenv::dotenv;
    use sqlx::postgres::PgPoolOptions;
    use std::env;
    use std::sync::Mutex;

    #[ignore]
    #[actix_rt::test] // 异步测试
    async fn post_course_test() {
        dotenv().ok();
        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
        let db_pool = PgPoolOptions::new().connect(&db_url).await.unwrap();
        let app_state: web::Data<AppState> = web::Data::new(AppState {
            health_check_response: "".to_string(),
            visit_count: Mutex::new(0),
            db: db_pool,
        });

        let course = web::Json(Course {
            teacher_id: 1,
            name: "Test course".into(),
            id: Some(5), // serial
            time: None,
        });

        let resp = new_course(course, app_state).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[actix_rt::test]
    async fn get_all_courses_success() {
        dotenv().ok();
        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
        let db_pool = PgPoolOptions::new().connect(&db_url).await.unwrap();
        let app_state: web::Data<AppState> = web::Data::new(AppState {
            health_check_response: "".to_string(),
            visit_count: Mutex::new(0),
            db: db_pool,
        });
        let teacher_id: web::Path<usize> = web::Path::from(1);
        let resp = get_courses_for_tescher(app_state, teacher_id)
            .await
            .unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[actix_rt::test]
    async fn get_one_course_success() {
        dotenv().ok();
        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
        let db_pool = PgPoolOptions::new().connect(&db_url).await.unwrap();
        let app_state: web::Data<AppState> = web::Data::new(AppState {
            health_check_response: "".to_string(),
            visit_count: Mutex::new(0),
            db: db_pool,
        });
        let params: web::Path<(usize, usize)> = web::Path::from((1, 1));
        let resp = get_courses_detail(app_state, params).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }
}

```

### 测试

```bash
ws on  main [✘!?] via 🦀 1.67.1 via 🅒 base took 2.1s
➜ cargo test --bin teacher-service
   Compiling webservice v0.1.0 (/Users/qiaopengjun/rust/ws/webservice)
warning: unused variable: `msg`
  --> webservice/src/bin/../errors.rs:39:30
   |
39 |             MyError::DBError(msg) | MyError::ActixError(msg) => StatusCode::INTERNAL_SERVER_ERROR,
   |                              ^^^                        ^^^
   |
   = note: `#[warn(unused_variables)]` on by default
help: if this is intentional, prefix it with an underscore
   |
39 |             MyError::DBError(_msg) | MyError::ActixError(_msg) => StatusCode::INTERNAL_SERVER_ERROR,
   |                              ~~~~                        ~~~~

warning: unused variable: `msg`
  --> webservice/src/bin/../errors.rs:40:31
   |
40 |             MyError::NotFound(msg) => StatusCode::NOT_FOUND,
   |                               ^^^ help: if this is intentional, prefix it with an underscore: `_msg`

warning: `webservice` (bin "teacher-service" test) generated 2 warnings (run `cargo fix --bin "teacher-service" --tests` to apply 2 suggestions)
    Finished test [unoptimized + debuginfo] target(s) in 1.27s
     Running unittests src/bin/teacher-service.rs (target/debug/deps/teacher_service-32d6a48d6ee3c4b4)

running 3 tests
test handlers::tests::get_one_course_success ... ok
test handlers::tests::get_all_courses_success ... ok
test handlers::tests::post_course_test ... ok

test result: ok. 3 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.02s


ws on  main [✘!?] via 🦀 1.67.1 via 🅒 base
➜


ws on  main [✘!?] via 🦀 1.67.1 via 🅒 base
➜ cargo test --bin teacher-service
   Compiling webservice v0.1.0 (/Users/qiaopengjun/rust/ws/webservice)
warning: unused variable: `msg`
  --> webservice/src/bin/../errors.rs:39:30
   |
39 |             MyError::DBError(msg) | MyError::ActixError(msg) => StatusCode::INTERNAL_SERVER_ERROR,
   |                              ^^^                        ^^^
   |
   = note: `#[warn(unused_variables)]` on by default
help: if this is intentional, prefix it with an underscore
   |
39 |             MyError::DBError(_msg) | MyError::ActixError(_msg) => StatusCode::INTERNAL_SERVER_ERROR,
   |                              ~~~~                        ~~~~

warning: unused variable: `msg`
  --> webservice/src/bin/../errors.rs:40:31
   |
40 |             MyError::NotFound(msg) => StatusCode::NOT_FOUND,
   |                               ^^^ help: if this is intentional, prefix it with an underscore: `_msg`

warning: `webservice` (bin "teacher-service" test) generated 2 warnings (run `cargo fix --bin "teacher-service" --tests` to apply 2 suggestions)
    Finished test [unoptimized + debuginfo] target(s) in 0.71s
     Running unittests src/bin/teacher-service.rs (target/debug/deps/teacher_service-32d6a48d6ee3c4b4)

running 3 tests
test handlers::tests::post_course_test ... ignored
test handlers::tests::get_one_course_success ... ok
test handlers::tests::get_all_courses_success ... ok

test result: ok. 2 passed; 0 failed; 1 ignored; 0 measured; 0 filtered out; finished in 0.01s


ws on  main [✘!?] via 🦀 1.67.1 via 🅒 base
➜
```

## 总结

通过本文的实战演练，我们成功地为 Actix Web 服务构建了一个健壮且优雅的统一错误处理机制。

我们回顾并总结一下核心步骤：

1. 定义统一错误类型：我们创建了 MyError 枚举，用它来封装所有可能发生的错误，如 DBError、ActixError 和 NotFound。

2. 实现自动类型转换：通过为 MyError 实现 From trait，我们让 sqlx::Error 等外部错误类型可以被 ? 运算符自动转换成我们的自定义错误，极大地简化了代码。

3. 桥接到 HTTP 响应：最关键的一步是实现了 actix_web::error::ResponseError trait。这使得 Actix Web 框架能够自动识别我们的 MyError，并根据我们定义的逻辑，将其转换为对应的 HTTP 状态码和 JSON 响应体。

4. 应用于业务逻辑：最后，我们将新的错误处理机制应用到数据库访问和请求处理（handler）层，使整个服务的错误流向清晰、处理逻辑集中。

遵循这一模式，你的 Rust Web 应用将变得更加专业和可靠。代码不仅更易于阅读和维护，还能为客户端提供一致、可预测的错误信息，这是打造高质量 Web API 的重要基石。
