+++
title = "Rust Web 开发实战：构建教师管理 API"
description = "Rust Web 开发实战：构建教师管理 API"
date = 2025-08-14T15:54:33Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# Rust Web 开发实战：构建教师管理 API

在现有的 Rust Web 服务基础上进行功能扩展是项目迭代的常见需求。本文将以一个全栈 Web 应用为例，详细阐述如何增加一个全新的“教师管理”模块。我们将遵循分层设计的原则，从数据库表的创建到 API 接口的实现，一步步构建一套完整的 CRUD (创建、读取、更新、删除) 功能。通过这个实战案例，您将了解如何使用 Actix Web、SQLx 和 PostgreSQL 等流行工具，高效地为您的 Rust 应用添加新功能。

本文演示了如何为 Rust Web 应用增加教师管理功能。基于 Actix Web 和 SQLx，文章详细分步实现了教师资源的 CRUD API，内容涵盖数据模型、数据库交互、请求处理、路由配置和单元测试，最终完成一个完整的功能模块。

## 增加教师管理功能

### 目标

#### Actix HTTP Server

#### Actix App

- Routes
  - GET /teachers
  - GET / teachers /{teacher_id}
  - POST /teachers
  - PUT /teachers /{teacher_id}
  - DELETE /teachers /{teacher_id}
- Handlers
  - get_all_teachers
  - get_teacher_details
  - post_new_teacher
  - update_teacher_details
  - delete_teacher
- DB Access
  - get_all_teachers_db
  - get_teacher_details_db
  - post_new_teacher_db
  - update_teacher_details_db
  - delete_teacher_db

### 项目目录

```bash
ws on  main [!?] via 🦀 1.67.1 via 🅒 base
➜ tree -a -I "target|.git"
.
├── .env
├── .gitignore
├── Cargo.lock
├── Cargo.toml
├── README.md
└── webservice
    ├── Cargo.toml
    └── src
        ├── bin
        │   └── teacher-service.rs
        ├── dbaccess
        │   ├── course.rs
        │   ├── mod.rs
        │   └── teacher.rs
        ├── errors.rs
        ├── handlers
        │   ├── course.rs
        │   ├── general.rs
        │   ├── mod.rs
        │   └── teacher.rs
        ├── main.rs
        ├── models
        │   ├── course.rs
        │   ├── mod.rs
        │   └── teacher.rs
        ├── routers.rs
        └── state.rs

7 directories, 21 files

ws on  main [!?] via 🦀 1.67.1 via 🅒 base
```

### webservice/src/models/mod.rs

```rust
pub mod course;
pub mod teacher;

```

### webservice/src/models/teacher.rs

```rust
use actix_web::web;
use serde::{Deserialize, Serialize};

#[derive(Deserialize, Serialize, Debug, Clone)]
pub struct Teacher {
    pub id: i32, // serial
    pub name: String,
    pub picture_url: String,
    pub profile: String,
}

#[derive(Deserialize, Debug, Clone)]
pub struct CreateTeacher {
    pub name: String,
    pub picture_url: String,
    pub profile: String,
}

#[derive(Deserialize, Debug, Clone)]
pub struct UpdateTeacher {
    pub name: Option<String>,
    pub picture_url: Option<String>,
    pub profile: Option<String>,
}

impl From<web::Json<CreateTeacher>> for CreateTeacher {
    fn from(new_teacher: web::Json<CreateTeacher>) -> Self {
        CreateTeacher {
            name: new_teacher.name.clone(),
            picture_url: new_teacher.picture_url.clone(),
            profile: new_teacher.profile.clone(),
        }
    }
}

impl From<web::Json<UpdateTeacher>> for UpdateTeacher {
    fn from(update_teacher: web::Json<UpdateTeacher>) -> Self {
        UpdateTeacher {
            name: update_teacher.name.clone(),
            picture_url: update_teacher.picture_url.clone(),
            profile: update_teacher.profile.clone(),
        }
    }
}

```

### webservice/src/dbaccess/mod.rs

```rust
pub mod course;
pub mod teacher;

```

### webservice/src/dbaccess/teacher.rs

```rust
use crate::errors::MyError;
use crate::models::teacher::{CreateTeacher, Teacher, UpdateTeacher};
use sqlx::postgres::PgPool;

pub async fn get_all_teachers_db(pool: &PgPool) -> Result<Vec<Teacher>, MyError> {
    let rows = sqlx::query!("SELECT id, name, picture_url, profile FROM teacher")
        .fetch_all(pool)
        .await?;

    let teachers: Vec<Teacher> = rows
        .iter()
        .map(|r| Teacher {
            id: r.id,
            name: r.name.clone().unwrap_or_default(),
            picture_url: r.picture_url.clone().unwrap_or_default(),
            profile: r.profile.clone().unwrap_or_default(),
        })
        .collect();

    match teachers.len() {
        0 => Err(MyError::NotFound("No teachers found".into())),
        _ => Ok(teachers),
    }
}

pub async fn get_teacher_details_db(pool: &PgPool, teacher_id: i32) -> Result<Teacher, MyError> {
    let row = sqlx::query!(
        "SELECT id, name, picture_url, profile FROM teacher WHERE id = $1",
        teacher_id
    )
    .fetch_one(pool)
    .await
    .map(|r| Teacher {
        id: r.id,
        name: r.name.unwrap_or_default(),
        picture_url: r.picture_url.unwrap_or_default(),
        profile: r.profile.unwrap_or_default(),
    })
    .map_err(|_err| MyError::NotFound("Teacher Id not found".into()))?;

    Ok(row)
}

pub async fn post_new_teacher_db(
    pool: &PgPool,
    new_teacher: CreateTeacher,
) -> Result<Teacher, MyError> {
    let row = sqlx::query!(
        "INSERT INTO teacher (name, picture_url, profile)
        VALUES ($1, $2, $3) RETURNING id, name, picture_url, profile",
        new_teacher.name,
        new_teacher.picture_url,
        new_teacher.profile
    )
    .fetch_one(pool)
    .await?;

    Ok(Teacher {
        id: row.id,
        name: row.name.unwrap_or_default(),
        picture_url: row.picture_url.unwrap_or_default(),
        profile: row.profile.unwrap_or_default(),
    })
}

pub async fn update_teacher_details_db(
    pool: &PgPool,
    teacher_id: i32,
    update_teacher: UpdateTeacher,
) -> Result<Teacher, MyError> {
    let row = sqlx::query!(
        "SELECT id, name, picture_url, profile FROM teacher WHERE id = $1",
        teacher_id
    )
    .fetch_one(pool)
    .await
    .map_err(|_err| MyError::NotFound("Teacher id not found".into()))?;

    let temp = Teacher {
        id: row.id,
        name: if let Some(name) = update_teacher.name {
            name
        } else {
            row.name.unwrap_or_default()
        },
        picture_url: if let Some(pic) = update_teacher.picture_url {
            pic
        } else {
            row.picture_url.unwrap_or_default()
        },
        profile: if let Some(profile) = update_teacher.profile {
            profile
        } else {
            row.profile.unwrap_or_default()
        },
    };

    let update_row = sqlx::query!(
        "UPDATE teacher SET name = $1, picture_url = $2, profile = $3 WHERE id = $4
        RETURNING id, name, picture_url, profile",
        temp.name,
        temp.picture_url,
        temp.profile,
        teacher_id
    )
    .fetch_one(pool)
    .await
    .map(|r| Teacher {
        id: r.id,
        name: r.name.unwrap_or_default(),
        picture_url: r.picture_url.unwrap_or_default(),
        profile: r.profile.unwrap_or_default(),
    })
    .map_err(|_err| MyError::NotFound("Teacher id not found".into()))?;
    Ok(update_row)
}

pub async fn delete_teacher_db(pool: &PgPool, teacher_id: i32) -> Result<String, MyError> {
    let row = sqlx::query(&format!("DELETE FROM teacher WHERE id = {}", teacher_id))
        .execute(pool)
        .await
        .map_err(|_err| MyError::DBError("Unable to delete teacher".into()))?;

    Ok(format!("Deleted {:?} record", row))
}

```

### webservice/src/handlers/mod.rs

```rust
pub mod course;
pub mod general;
pub mod teacher;

```

### webservice/src/handlers/teacher.rs

```rust
use crate::dbaccess::teacher::*;
use crate::errors::MyError;
use crate::models::teacher::{CreateTeacher, UpdateTeacher};
use crate::state::AppState;

use actix_web::{web, HttpResponse};

pub async fn get_all_teachers(app_state: web::Data<AppState>) -> Result<HttpResponse, MyError> {
    get_all_teachers_db(&app_state.db)
        .await
        .map(|teachers| HttpResponse::Ok().json(teachers))
}

pub async fn get_teacher_details(
    app_state: web::Data<AppState>,
    params: web::Path<i32>,
) -> Result<HttpResponse, MyError> {
    let teacher_id = params.into_inner();
    get_teacher_details_db(&app_state.db, teacher_id)
        .await
        .map(|teacher| HttpResponse::Ok().json(teacher))
}

pub async fn post_new_teacher(
    new_teacher: web::Json<CreateTeacher>,
    app_state: web::Data<AppState>,
) -> Result<HttpResponse, MyError> {
    post_new_teacher_db(&app_state.db, CreateTeacher::from(new_teacher))
        .await
        .map(|teacher| HttpResponse::Ok().json(teacher))
}

pub async fn update_teacher_details(
    app_state: web::Data<AppState>,
    params: web::Path<i32>,
    update_teacher: web::Json<UpdateTeacher>,
) -> Result<HttpResponse, MyError> {
    let teacher_id = params.into_inner();
    update_teacher_details_db(
        &app_state.db,
        teacher_id,
        UpdateTeacher::from(update_teacher),
    )
    .await
    .map(|teacher| HttpResponse::Ok().json(teacher))
}

pub async fn delete_teacher(
    app_state: web::Data<AppState>,
    params: web::Path<i32>,
) -> Result<HttpResponse, MyError> {
    let teacher_id = params.into_inner();
    delete_teacher_db(&app_state.db, teacher_id)
        .await
        .map(|teacher| HttpResponse::Ok().json(teacher))
}

#[cfg(test)]
mod tests {
    use super::*;
    use actix_web::http::StatusCode;
    use dotenv::dotenv;
    use sqlx::postgres::PgPoolOptions;
    use std::env;
    use std::sync::Mutex;

    #[actix_rt::test]
    async fn get_all_teachers_success_test() {
        dotenv().ok();
        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
        let db_pool = PgPoolOptions::new().connect(&db_url).await.unwrap();
        let app_state: web::Data<AppState> = web::Data::new(AppState {
            health_check_response: "".to_string(),
            visit_count: Mutex::new(0),
            db: db_pool,
        });
        let resp = get_all_teachers(app_state).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[actix_rt::test]
    async fn get_tutor_detail_success_test() {
        dotenv().ok();
        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
        let db_pool = PgPoolOptions::new().connect(&db_url).await.unwrap();
        let app_state: web::Data<AppState> = web::Data::new(AppState {
            health_check_response: "".to_string(),
            visit_count: Mutex::new(0),
            db: db_pool,
        });
        let params: web::Path<i32> = web::Path::from(1);
        let resp = get_teacher_details(app_state, params).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    // #[ignore]
    #[actix_rt::test]
    async fn post_teacher_success_test() {
        dotenv().ok();
        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
        let db_pool = PgPoolOptions::new().connect(&db_url).await.unwrap();
        let app_state: web::Data<AppState> = web::Data::new(AppState {
            health_check_response: "".to_string(),
            visit_count: Mutex::new(0),
            db: db_pool,
        });
        let new_teacher = CreateTeacher {
            name: "Third Teacher".into(),
            picture_url: "https://www.rust-lang.org/static/images/rust-logo-blk.svg".into(),
            profile: "A teacher in Machine Learning".into(),
        };
        let teacher_param = web::Json(new_teacher);
        let resp = post_new_teacher(teacher_param, app_state).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[actix_rt::test]
    async fn delete_teacher_success_test() {
        dotenv().ok();
        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
        let db_pool = PgPoolOptions::new().connect(&db_url).await.unwrap();
        let app_state: web::Data<AppState> = web::Data::new(AppState {
            health_check_response: "".to_string(),
            visit_count: Mutex::new(0),
            db: db_pool,
        });
        let params: web::Path<i32> = web::Path::from(1);
        let resp = delete_teacher(app_state, params).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }
}

```

### webservice/src/routers.rs

```rust
use crate::handlers::{course::*, general::*, teacher::*};
use actix_web::web;

pub fn general_routes(cfg: &mut web::ServiceConfig) {
    cfg.route("/health", web::get().to(health_check_handler));
}

pub fn course_routes(cfg: &mut web::ServiceConfig) {
    // courses 是一套资源的根路径
    cfg.service(
        web::scope("/courses")
            .route("/", web::post().to(post_new_course))
            .route("/{teacher_id}", web::get().to(get_courses_for_tescher))
            .route(
                "/{teacher_id}/{course_id}",
                web::get().to(get_courses_detail),
            )
            .route("/{teacher_id}/{course_id}", web::delete().to(delete_course))
            .route(
                "/{teacher_id}/{course_id}",
                web::put().to(update_course_details),
            ),
    );
}

pub fn teacher_routes(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/teachers")
            .route("/", web::post().to(post_new_teacher))
            .route("/", web::get().to(get_all_teachers))
            .route("/{teacher_id}", web::get().to(get_teacher_details))
            .route("/{teacher_id}", web::put().to(update_teacher_details))
            .route("/{teacher_id}", web::delete().to(delete_teacher)),
    );
}

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
    InvalidInput(String),
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
            MyError::InvalidInput(msg) => {
                println!("Invaild parameters received: {:?}", msg);
                msg.into()
            }
        }
    }
}

impl error::ResponseError for MyError {
    fn status_code(&self) -> StatusCode {
        match self {
            MyError::DBError(_msg) | MyError::ActixError(_msg) => StatusCode::INTERNAL_SERVER_ERROR,
            MyError::NotFound(_msg) => StatusCode::NOT_FOUND,
            MyError::InvalidInput(_msg) => StatusCode::BAD_REQUEST,
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
use crate::errors::MyError;
use actix_web::{web, App, HttpServer};
use dotenv::dotenv;
use sqlx::postgres::PgPoolOptions;
use std::env;
use std::io;
use std::sync::Mutex;

#[path = "../dbaccess/mod.rs"]
mod dbaccess;
#[path = "../errors.rs"]
mod errors;
#[path = "../handlers/mod.rs"]
mod handlers;
#[path = "../models/mod.rs"]
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
            .app_data(web::JsonConfig::default().error_handler(|_err, _req| {
                MyError::InvalidInput("Please provide valid json input".to_string()).into()
            }))
            .configure(general_routes)
            .configure(course_routes) // 路由注册
            .configure(teacher_routes)
    };

    HttpServer::new(app).bind("127.0.0.1:3000")?.run().await
}

```

### 创建数据库

```sql
postgres=# create table teacher (id int not null primary key,
name varchar(100),
picture_url varchar(200),
profile varchar(2000)
);
CREATE TABLE
postgres=# \l
postgres=# \dt
           List of relations
 Schema |  Name   | Type  |    Owner
--------+---------+-------+-------------
 public | course  | table | postgres
 public | teacher | table | qiaopengjun
(2 rows)

postgres=#


➜ psql
psql (14.6 (Homebrew))
Type "help" for help.

qiaopengjun=# \d
                     List of relations
 Schema |          Name           |   Type   |    Owner
--------+-------------------------+----------+-------------
 public | base_cache_signaling    | sequence | qiaopengjun
 public | base_registry_signaling | sequence | qiaopengjun
(2 rows)

qiaopengjun=# \l
qiaopengjun=# \c postgres
You are now connected to database "postgres" as user "qiaopengjun".
postgres=# ldt
postgres-# \dt
           List of relations
 Schema |  Name   | Type  |    Owner
--------+---------+-------+-------------
 public | course  | table | postgres
 public | teacher | table | qiaopengjun
(2 rows)

postgres-# alter table teacher owner to postgres
postgres-# ;
ERROR:  syntax error at or near "ldt"
LINE 1: ldt
        ^
postgres=# alter table teacher owner to postgres;
ALTER TABLE
postgres=# /d
postgres-# \d
              List of relations
 Schema |     Name      |   Type   |  Owner
--------+---------------+----------+----------
 public | course        | table    | postgres
 public | course_id_seq | sequence | postgres
 public | teacher       | table    | postgres
(3 rows)

postgres-# \dt
          List of relations
 Schema |  Name   | Type  |  Owner
--------+---------+-------+----------
 public | course  | table | postgres
 public | teacher | table | postgres
(2 rows)

postgres-#
```

要将现有的 `id` 列修改为自增列，你可以执行以下步骤：

1. 首先，备份你的数据库以防止意外数据丢失。
2. 在 PostgreSQL 中，你可以使用 `SERIAL` 或 `BIGSERIAL` 数据类型来创建自增列。在你的情况下，你可以选择 `SERIAL` 数据类型。
3. 执行以下 SQL 命令来修改表结构，将 `id` 列修改为自增列

```sql
-- 创建一个临时表来存储现有数据
CREATE TABLE teacher_temp AS SELECT * FROM teacher;

-- 删除原来的 teacher 表
DROP TABLE teacher;

-- 创建带有自增列的新 teacher 表
CREATE TABLE teacher (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  picture_url VARCHAR(200),
  profile VARCHAR(2000)
);

-- 将临时表中的数据插入到新表中
INSERT INTO teacher (name, picture_url, profile)
SELECT name, picture_url, profile
FROM teacher_temp;

-- 删除临时表
DROP TABLE teacher_temp;

```

上述代码首先创建一个临时表 `teacher_temp` 来存储现有数据，然后删除原来的 `teacher` 表，接着创建一个带有自增列的新 `teacher` 表，并将临时表中的数据插入到新表中，最后删除临时表。

执行上述代码后，你的 `teacher` 表的 `id` 列就会变成自增列了。请确保在执行这些修改之前备份你的数据，并在生产环境中小心操作。

### 报错

`ERROR:  null value in column "id" of relation "teacher" violates not-null constraint DETAIL:  Failing row contains (null, test, test, test).`

根据报错信息，看起来在插入数据时发生了错误，因为 `id` 列设置为非空约束（not-null constraint），但插入的数据中 `id` 列的值为 `null`。

解决这个问题，你可以尝试以下方法：

1. 如果你希望 `id` 列是自增的，那么在插入数据时不需要指定 `id` 列的值。让数据库自动生成自增的 `id` 值。修改插入数据的 SQL 语句，不包括 `id` 列，并确保其他列的值是有效的。例如：

   ```sql
   sqlCopy code
   INSERT INTO teacher (name, picture_url, profile)
   VALUES ('test', 'test', 'test');
   ```

   这样，数据库会自动分配一个新的自增 `id` 值。

2. 如果你希望手动指定 `id` 列的值，那么你需要确保插入的值不为 `null`，并且符合 `id` 列的约束条件。例如：

   ```sql
   sqlCopy code
   INSERT INTO teacher (id, name, picture_url, profile)
   VALUES (1, 'test', 'test', 'test');
   ```

   在这种情况下，你需要手动指定一个非空的 `id` 值，并确保它不与表中的其他行发生冲突。

请注意，在修改表结构之前，确保已备份数据，并小心执行修改操作。

### 测试

```bash
ws on  main [!?] via 🦀 1.67.1 via 🅒 base took 2.3s
➜ cargo test teacher
   Compiling webservice v0.1.0 (/Users/qiaopengjun/rust/ws/webservice)
    Finished test [unoptimized + debuginfo] target(s) in 1.60s
     Running unittests src/bin/teacher-service.rs (target/debug/deps/teacher_service-32d6a48d6ee3c4b4)

running 4 tests
test handlers::teacher::tests::get_tutor_detail_success_test ... ok
test handlers::teacher::tests::get_all_teachers_success_test ... ok
test handlers::teacher::tests::post_teacher_success_test ... ok
test handlers::teacher::tests::delete_teacher_success_test ... ok

test result: ok. 4 passed; 0 failed; 0 ignored; 0 measured; 7 filtered out; finished in 0.02s

     Running unittests src/main.rs (target/debug/deps/webservice-77b07bbb613fc996)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s


ws on  main [!?] via 🦀 1.67.1 via 🅒 base took 2.4s
➜
```

### webservice/src/handlers/teacher.rs

```rust
use crate::dbaccess::teacher::*;
use crate::errors::MyError;
use crate::models::teacher::{CreateTeacher, UpdateTeacher};
use crate::state::AppState;

use actix_web::{web, HttpResponse};

pub async fn get_all_teachers(app_state: web::Data<AppState>) -> Result<HttpResponse, MyError> {
    get_all_teachers_db(&app_state.db)
        .await
        .map(|teachers| HttpResponse::Ok().json(teachers))
}

pub async fn get_teacher_details(
    app_state: web::Data<AppState>,
    params: web::Path<i32>,
) -> Result<HttpResponse, MyError> {
    let teacher_id = params.into_inner();
    get_teacher_details_db(&app_state.db, teacher_id)
        .await
        .map(|teacher| HttpResponse::Ok().json(teacher))
}

pub async fn post_new_teacher(
    new_teacher: web::Json<CreateTeacher>,
    app_state: web::Data<AppState>,
) -> Result<HttpResponse, MyError> {
    post_new_teacher_db(&app_state.db, CreateTeacher::from(new_teacher))
        .await
        .map(|teacher| HttpResponse::Ok().json(teacher))
}

pub async fn update_teacher_details(
    app_state: web::Data<AppState>,
    params: web::Path<i32>,
    update_teacher: web::Json<UpdateTeacher>,
) -> Result<HttpResponse, MyError> {
    let teacher_id = params.into_inner();
    update_teacher_details_db(
        &app_state.db,
        teacher_id,
        UpdateTeacher::from(update_teacher),
    )
    .await
    .map(|teacher| HttpResponse::Ok().json(teacher))
}

pub async fn delete_teacher(
    app_state: web::Data<AppState>,
    params: web::Path<i32>,
) -> Result<HttpResponse, MyError> {
    let teacher_id = params.into_inner();
    delete_teacher_db(&app_state.db, teacher_id)
        .await
        .map(|teacher| HttpResponse::Ok().json(teacher))
}

#[cfg(test)]
mod tests {
    use super::*;
    use actix_web::http::StatusCode;
    use dotenv::dotenv;
    use sqlx::postgres::PgPoolOptions;
    use std::env;
    use std::sync::Mutex;

    #[actix_rt::test]
    async fn get_all_teachers_success_test() {
        dotenv().ok();
        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
        let db_pool = PgPoolOptions::new().connect(&db_url).await.unwrap();
        let app_state: web::Data<AppState> = web::Data::new(AppState {
            health_check_response: "".to_string(),
            visit_count: Mutex::new(0),
            db: db_pool,
        });
        let resp = get_all_teachers(app_state).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[actix_rt::test]
    async fn get_tutor_detail_success_test() {
        dotenv().ok();
        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
        let db_pool = PgPoolOptions::new().connect(&db_url).await.unwrap();
        let app_state: web::Data<AppState> = web::Data::new(AppState {
            health_check_response: "".to_string(),
            visit_count: Mutex::new(0),
            db: db_pool,
        });
        let params: web::Path<i32> = web::Path::from(5);
        let resp = get_teacher_details(app_state, params).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[ignore]
    #[actix_rt::test]
    async fn post_teacher_success_test() {
        dotenv().ok();
        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
        let db_pool = PgPoolOptions::new().connect(&db_url).await.unwrap();
        let app_state: web::Data<AppState> = web::Data::new(AppState {
            health_check_response: "".to_string(),
            visit_count: Mutex::new(0),
            db: db_pool,
        });
        let new_teacher = CreateTeacher {
            name: "Third Teacher".into(),
            picture_url: "https://www.rust-lang.org/static/images/rust-logo-blk.svg".into(),
            profile: "A teacher in Machine Learning".into(),
        };
        let teacher_param = web::Json(new_teacher);
        let resp = post_new_teacher(teacher_param, app_state).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }

    #[ignore]
    #[actix_rt::test]
    async fn delete_teacher_success_test() {
        dotenv().ok();
        let db_url = env::var("DATABASE_URL").expect("DATABASE_URL is not set");
        let db_pool = PgPoolOptions::new().connect(&db_url).await.unwrap();
        let app_state: web::Data<AppState> = web::Data::new(AppState {
            health_check_response: "".to_string(),
            visit_count: Mutex::new(0),
            db: db_pool,
        });
        let params: web::Path<i32> = web::Path::from(1);
        let resp = delete_teacher(app_state, params).await.unwrap();
        assert_eq!(resp.status(), StatusCode::OK);
    }
}

```

### 测试

```bash
ws on  main [!?] via 🦀 1.67.1 via 🅒 base
➜ cargo test teacher
   Compiling webservice v0.1.0 (/Users/qiaopengjun/rust/ws/webservice)
    Finished test [unoptimized + debuginfo] target(s) in 1.75s
     Running unittests src/bin/teacher-service.rs (target/debug/deps/teacher_service-32d6a48d6ee3c4b4)

running 4 tests
test handlers::teacher::tests::delete_teacher_success_test ... ignored
test handlers::teacher::tests::post_teacher_success_test ... ignored
test handlers::teacher::tests::get_tutor_detail_success_test ... ok
test handlers::teacher::tests::get_all_teachers_success_test ... ok

test result: ok. 2 passed; 0 failed; 2 ignored; 0 measured; 7 filtered out; finished in 0.02s

     Running unittests src/main.rs (target/debug/deps/webservice-77b07bbb613fc996)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s


ws on  main [!?] via 🦀 1.67.1 via 🅒 base took 2.4s
➜
```

### 运行

```bash
ws on  main [!?] via 🦀 1.67.1 via 🅒 base took 2.4s
➜ cargo run
   Compiling webservice v0.1.0 (/Users/qiaopengjun/rust/ws/webservice)
    Finished dev [unoptimized + debuginfo] target(s) in 4.05s
     Running `target/debug/teacher-service`
```

## 总结

本文成功地在一个基于 Rust 和 Actix Web 的项目中实现了教师管理功能。我们从明确 API 目标开始，定义了针对教师资源的五种核心 HTTP 端点（GET、GET by id、POST、PUT、DELETE）。

在实现过程中，我们遵循了清晰的分层架构：

1. 模型层 (Models)：定义了 Teacher、CreateTeacher 和 UpdateTeacher 数据结构，用于在应用各层之间传递数据。

2. 数据库访问层 (DB Access)：使用 SQLx 编写了与 PostgreSQL 数据库交互的异步函数，封装了所有 SQL 操作，实现了业务逻辑与数据库的解耦。

3. 处理层 (Handlers)：创建了对应的 Actix Web 处理器函数，用于接收和解析 HTTP 请求，调用数据库访问函数，并返回响应。

4. 路由层 (Routers)：将 URL 路径与处理器函数进行绑定，完成了 API 的注册。

此外，文章还涵盖了数据库表的创建、将主键 id 修改为自增列的常见问题及解决方案，并编写了单元测试以确保各个 API 端点的正确性，最终成功运行了整个服务。这个过程完整地展示了在 Rust 全栈项目中添加一个功能模块的标准流程。
