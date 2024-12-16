+++
title = "Hugo博客Maupassant主题配置"
date= 2024-12-16T15:00:00+08:00
[taxonomies]
tags = ["Blog","Hugo"]
categories = ["Blog"]
+++

# Maupassant主题配置

================

## 主题安装

```bash
git submodule add https://github.com/flysnow-org/maupassant-hugo themes/maupassant
```

## 主题配置

```toml
baseURL = 'http://qiaopengjun5162.github.io/'
languageCode = "zh-CN"                        ## 'en-us'
title = '小乔的博客'
theme = "maupassant"
# theme = "PaperMod"


# 编译草稿，使用改参数保证hugo server即使没有加`--buildDrafts`，也能访问draft=true的md
buildDrafts = true

googleAnalytics = "GA ID"

## 保持分类的原始名字（false会做转小写处理）
preserveTaxonomyNames = true
## 是否禁止URL Path转小写
disablePathToLower = true

hasCJKLanguage = true

# 自定义文章摘要
summaryLength = 70

disqusShortname = "yourdiscussshortname" ## 是否开启disqus评论，不要和utteranc同时开启

[author]
name = "小乔"

[params]
author = "小乔"
subtitle = "专注于Python、Go、Rust、数据库、Linux、软件架构、软件工程、数据结构、算法、操作系统等"
keywords = "golang,go语言,go语言笔记,小乔,Python,rust,博客,项目管理,数据库,软件架构,公众号,算法"
description = "专注于Python、Go、Rust、数据库、Linux、软件架构、软件工程、数据结构、算法、操作系统等"
busuanzi = true                                                        #启用不算子网页统计
googleAd = ""                                                          #ca-pub-xxxxxxxxxxxxxx
localSearch = true                                                     # 启用本地搜索

# 这里我存放在了主题的static文件夹里，根目录的似乎也可以
# customCSS = ['douban.css', 'other.css']
# if ['custom.css'], load '/static/css/custom.css' file
# customJS = ['douban.js']
# if ['custom.js'], load '/static/js/custom.js' file

# 全局开关，你也可以在每一篇内容的 front matter 中针对单篇内容关闭或开启某些功能
toc = false # 是否开启目录

## 配置代码高亮
[markup]
[markup.highlight]
lineNos = true            # 是否显示行列
style = "monokai"         # 设置代码高亮的样式 manni
codeFences = true         # 允许在 Markdown 中使用代码块
guessSyntax = true        # 尝试猜测代码的语法类型
hl_Lines = ""
lineAnchors = ""
lineNoStart = 1
lineNumbersInTable = true
noClasses = true
tabWidth = 4              # 置代码块中的制表符宽度为 4 个空格。
[markup.goldmark]
[markup.goldmark.renderer]
unsafe = true # 默认值不支持在 markdown 中写 html，需改成 true 开启


## 配置网站菜单
[menu]
[[menu.main]]
identifier = "tools"
name = "工具"
url = "/tools/"
weight = 2

[[menu.main]]
identifier = "archives"
name = "归档"
url = "/archives/"
weight = 3

[[menu.main]]
identifier = "about"
name = "关于"
url = "/about/"
weight = 4


## 配置 utteranc评论,教程参考 https://utteranc.es/
[params.utteranc]
enable = true
repo = "qiaopengjun5162/hugoblogtalks" ##换成自己得
issueTerm = "pathname"
theme = "github-light"


## 配置 waline 评论系统,教程参考 https://waline.js.org/
[params.waline]
enable = false
placeholder = "说点什么吧..."
serverURL = "https://qiaopengjun5162.github.io" #换成你的serverURL

## 开启版权声明，协议名字和链接都可以换
[params.cc]
name = "知识共享署名-非商业性使用-禁止演绎 4.0 国际许可协议"
link = "https://creativecommons.org/licenses/by-nc-nd/4.0/"


## 友情链接，可以多个
[[params.links]]
title = "Yuan的博客"
name = "Yuan的博客"
url = "http://www.yuan316.com/"

[[params.links]]
title = "飞雪无情的博客"
name = "飞雪无情的博客"
url = "https://www.flysnow.org/"

[[params.links]]
title = "李文周的博客"
name = "李文周的博客"
url = "https://www.liwenzhou.com/"


[params.flowchartDiagrams]
enable = true
options = ""

[params.sequenceDiagrams]
enable = true
options = ""  # default: "{theme: 'simple'}"
```
