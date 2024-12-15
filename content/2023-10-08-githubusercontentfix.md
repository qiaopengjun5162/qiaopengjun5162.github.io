+++
title= "安装rustlings报错解决"
date= 2023-10-08T22:54:09+08:00
[taxonomies]
tags= ["Rust"]
categories= ["Rust"]
+++

# 安装rustlings报错解决

### 相关文档

<https://github.com/LearningOS/rust-rustlings-2023-autumn-qiaopengjun5162>

### 安装[rustlings](https://github.com/LearningOS/rust-rustlings-2023-autumn-qiaopengjun5162#rustlings-️)报错

```shell

~/Code/rust via 🅒 base took 53.7s
➜
curl -L https://raw.githubusercontent.com/rust-lang/rustlings/main/install.sh | bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:01:15 --:--:--     0
curl: (28) Failed to connect to raw.githubusercontent.com port 443 after 75005 ms: Couldn't connect to server
```

### 解决

- 访问<https://sites.ipaddress.com/raw.githubusercontent.com/>网站，获取最新IP地址。

- 修改hosts文件

  - sudo vim /etc/hosts

  - 编辑 hosts 文件，新增下列内容

  - 185.199.108.133 raw.githubusercontent.com
