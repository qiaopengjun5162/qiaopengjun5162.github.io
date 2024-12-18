+++
title = "Hugo博客PaperMod主题配置"
date= 2024-12-18T15:11:00+08:00
[taxonomies]
tags = ["Blog","Hugo"]
categories = ["Blog","Hugo"]
+++
# Hugo博客PaperMod主题配置

config.yml配置文件

```yml
baseURL: https://qiaopengjun5162.github.io/
languageCode: en-us
title: Qiao's Blog
theme: PaperMod

paginate: 10 # 每页显示的文章数
summaryLength: 140 # 文章概览的自字数，默认70
minify:
  disableXML: true
  minifyOutput: true

params:
  # home-info mode
  homeInfoParams:
    Title: "Hi there \U0001F44B"
    Content: Welcome to my blog

  socialIcons:
    - name: bilibili
      url: "https://bilibili.com"
    - name: youtube
      url: "https://youtube.com"
    - name: github
      url: "https://github.com/"
    - name: "reddit"
      url: "https://reddit.com"

  cover:
    linkFullImages: true

  ShowBreadCrumbs: true

  ShowReadingTime: true

  ShowShareButtons: false
  ShowPostNavLinks: true
  ShowCodeCopyButtons: true
  ShowToc: true
  comments: true
  TocOpen: true
  busuanzi:
    enable: true

  utteranc:
    enable: true
    repo: "qiaopengjun5162/hugoblogtalks"
    issueTerm: "pathname"
    theme: "github-light"

menu:
  main:
    - identifier: categories
      name: Categories
      url: /categories/
      weight: 10
    - identifier: tags
      name: Tags
      url: /tags/
      weight: 20
    - identifier: archives
      name: Archives
      url: /archives/
      weight: 30
    - identifier: about
      name: About
      url: /about/
      weight: 40

# Read: https://github.com/adityatelange/hugo-PaperMod/wiki/FAQs#using-hugos-syntax-highlighter-chroma
pygmentsUseClasses: true
markup:
  goldmark:
    renderer:
      unsafe: true
  highlight:
    # anchorLineNos: true
    codeFences: true
    guessSyntax: true
    lineNos: true
    # noClasses: false
    style: monokai

```
