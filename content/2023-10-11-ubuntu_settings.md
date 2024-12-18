+++
title = "MacBookPro 16 M2 使用Parallels Desktop 安装 Ubuntu-22.04.3及相关配置"
date = 2023-10-11T14:17:45+08:00
[taxonomies]
tags = ["Ubunut"]
categories = ["Ubunut"]
+++

# MacBookPro 16 M2 使用Parallels Desktop 安装 Ubuntu-22.04.3及相关配置

### 适用于 ARM 的 Ubuntu 服务器

<https://ubuntu.com/download/server/arm>

### 安装搜狗输入法

<https://shurufa.sogou.com/linux/guide>

```bash
sudo apt-get install fcitx
sudo apt-get install fonts-wqy-microhei
```

### 安装谷歌浏览器

```bash
sudo apt install chromium-browser

sudo tzselect
```

### 更改系统时区为亚洲/上海

```bash
# 复制时区文件
sudo cp /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime
# 安装ntp时间服务器
sudo apt install ntpdate
# 同步ntp时间服务器
sudo ntpdate time.windows.com
# 将系统时间与网络同步
sudo ntpdate cn.pool.ntp.org
# 将时间写入硬件
sudo hwclock --systohc
# 重启Ubuntu
reboot
```

<https://github.com/Dreamacro/clash/blob/master/docs/logo.png>

```bash
sudo snap remove --purge firefox
```
