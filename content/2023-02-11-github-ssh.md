+++
title = "GitHub 配置SSH密钥"
date = 2023-02-11T15:46:08+08:00
description = "在 GitHub 上配置 SSH 密钥，方便推送代码"
[taxonomies]
categories = ["Github"]
tags = ["Github"]
+++

# ​​GitHub SSH密钥配置指南：从生成到验证的完整流程​​

SSH密钥是开发者与GitHub等代码托管平台建立安全连接的核心工具，可替代密码实现免密提交、克隆等操作。本文以GitHub为例，通过命令行操作与界面配置演示，系统讲解SSH密钥的生成、查看、添加及验证全流程，帮助开发者快速搭建安全的Git开发环境。

本文提供GitHub平台SSH密钥配置的完整解决方案，包含以下核心内容：

- ​​密钥检查与生成​​：通过cat ~/.ssh/id_rsa.pub验证现有密钥，使用ssh-keygen命令生成RSA加密密钥对，默认存储路径为~/.ssh/目录。
- ​​公钥配置​​：通过cat命令查看公钥内容，完整复制至GitHub账户的SSH设置页面（Settings → SSH and GPG keys）。
- ​​可视化指引​​：包含密钥生成过程交互提示、公钥内容格式示例、GitHub配置界面截图等辅助信息。
- ​​多平台兼容​​：所述方法同样适用于Gitee、GitLab等代码托管平台，仅需替换对应平台配置路径。

## GitHub 配置SSH密钥实操

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

## 总结

SSH密钥配置是开发者与代码托管平台建立信任关系的基础操作，本文通过三步完成安全连接搭建：首先生成加密密钥对，其次将公钥添加至平台账户，最后通过ssh -T命令验证连通性（如ssh -T <git@github.com>）。注意需确保密钥文件权限设置为600，避免私钥泄露风险。建议开发者为不同代码平台配置独立密钥对，并定期更新密钥以增强安全性。
