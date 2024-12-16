+++
title = "Rust学习之Diesel setup报错解决"
date = 2024-01-28T17:02:08+08:00
[taxonomies]
tags = ["Rust"]
categories = ["Rust"]
+++

# Diesel setup报错解决

Diesel 是一个安全、可扩展的Rust ORM 和查询生成器。
Diesel 是 Rust 中与数据库交互最高效的方式，因为它对查询进行了安全且可组合的抽象。

## 1. 报错信息

```shell
diesel_demo on  master [?] via 🦀 1.75.0 via 🅒 base 
➜ diesel setup

Creating migrations directory at: /Users/qiaopengjun/Code/rust/diesel_demo/migrations
Creating database: postgres
could not translate host name "db" to address: nodename nor servname provided, or not known
```

## 2. 解决方案

- 检查数据库是否正常运行
- 检查数据库连接配置是否正确
- 检查数据库用户名和密码是否正确

```shell
sudo vim /etc/hosts
127.0.0.1       db
```

## 3. 参考文档

- <https://diesel.rs/>
- <https://github.com/diesel-rs/diesel>
