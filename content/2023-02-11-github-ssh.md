+++
title = "GitHub 配置SSH密钥"
date = 2023-02-11T15:46:08+08:00
description = "在 GitHub 上配置 SSH 密钥，方便推送代码"
[taxonomies]
categories = ["Github"]
tags = ["Github"]
+++

# GitHub 配置SSH密钥

## 查看已存在的 SSH 密钥

```bash
cat ~/.ssh/id_rsa.pub
```

## 生成SSH密钥

```bash
ssh-keygen -t rsa -C "GitHub/gitee邮箱地址"
```

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img/202302162157637.png)

密钥默认生成路径：`/home/user/.ssh/id_rsa`，公钥与之对应为：`/home/user/.ssh/id_rsa.pub`。

## 查看公钥并把公钥复制到GitHub中

```bash
cat /Users/qiaopengjun/.ssh/id_rsa.pub
```

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img/202302162157634.png)

GitHub中settings页面

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img/202302162157635.png)
