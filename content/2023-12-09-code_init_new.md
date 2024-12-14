+++
title = "如果我们要打印一个class的signature（比如使用help命令的时候），我们是应该优先__new__，还是__init__？"
date = 2023-12-09T18:08:19+08:00
[taxonomies]
tags = ["Python"]
categories = ["Python"]
+++

# 如果我们要打印一个class的signature（比如使用help命令的时候），我们是应该优先__new__，还是__init__？

如果这个class同时自定义了__new__和__init__，按照现在的实现，是先打印__new__的。

任何一个类，如果同时定义了__new__和__init__，只有__new__在instantiate的时候是一定会被运行的，因为__new__可以返回一个其他类型（衍生类甚至是完全无关的类型）的object，导致这个类的__init__压根没有被调用。也就是说，__new__是比__init__更稳定的signature。
<!--more-->

## 为什么是__new__？

因为__new__是比__init__更稳定的signature。

__new__的signature是：

```python
def __new__(cls, *args, **kwargs)
```

而__init__的signature是：

```python
def __init__(self, *args, **kwargs)
```

__new__的signature是比__init__更稳定的，因为__new__的signature可以返回一个完全无关的类型，比如int，而__init__的signature一定是cls

__new__是建立一个实例，__init__只是对这个实例进行初始化。
