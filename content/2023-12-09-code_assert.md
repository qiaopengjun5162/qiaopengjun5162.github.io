+++
title: "Python中自带的 assert 的使用"
date: 2023-12-09T17:57:50+08:00
[taxonomies]
tags: ["Python"]
categories: ["Python"]
+++

# Python中自带的 assert 的使用

## 1. 概述

assert 语句用于判断一个表达式，在表达式条件为 false 的时候触发异常。

## 2. 语法

assert expression [, arguments]

## 3. 实例

```python
# 判断一个变量是否为空
assert a is not None
```

## 4. 注意事项

assert 语句只在调试模式开启时起作用，在发布模式时，assert 语句将被忽略。

## 5. 断言的用法

### 5.1 断言表达式为真

```python
assert 1 == 1
```

### 5.2 断言表达式为假

```python
assert 1 == 2
```

### 5.3 断言表达式为假，并抛出异常

```python
assert 1 == 2, "1 is not equal to 2"
```

### 5.4 断言表达式为假，并抛出异常，并附加额外的参数

```python
assert 1 == 2, "1 is not equal to 2", 100
```

### 5.5 断言表达式为假，并抛出异常，并附加额外的参数，并附加额外的参数

```python
assert 1 == 2, "1 is not equal to 2", 100, 200
```

## 6. 断言的执行

assert 语句只在调试模式开启时起作用，在发布模式时，assert 语句将被忽略。

## 7. 断言的执行过程

断言的执行过程如下：

1. 执行 assert 语句
2. 如果断言失败，则触发 AssertionError 异常
3. 异常被触发时，assert 语句后面的语句将不会执行

## 8. 断言的使用说明

首先，在python中，assert expression 在不开-O（即使用debug mode）的情况下，等价于if not expression: raise AssertionError 。python里的assert就是raise了一个exception而已。但是我们看待assert的时候，要从语言的层面去理解，背后的实现反而没那么重要。

assert的语义其实是非常清晰的——这个事情它压根不该发生。你永远不应该用assert处理任何错误，如果你能想到一个当前情况下assert不成立的可能性，你这里就不应该写这个assert。你不应该依赖assert的任何behavior，任何assert不成立的时候，你就应该接受你的程序可能发生任何事情。事实上，在使用-O（production mode）的时候，所有的assert都会被变成noop，也就是没有任何行为。

那为什么要写assert？当然还是有原因的。

第一，当你在对程序进行开发的时候，可以更快地发现一些程序的错误。比如你这个函数是个内部函数，只有自己的代码调用，你觉得传进来的都应该是int，你不需要对传入数据进行类型判断，这里可以加一个assert isinstance(arg, int) ，万一你在开发的时候出了一些比较蠢的错误，可以及时发现。这个用法其实大家相对熟悉一些，有的人在开发的时候会用这个方式调试。

第二，是一个被很多人忽略的点——assert是有注释含义的。它可以提醒后来的开发者（和一周后的你自己），这个地方我确认某个事情是成立的，你不需要去思考其他的可能性。这样的assert在开发时起到一个测试的作用，而在开发后维护的时候起到一个注释的作用。在assert起注释作用的时候，它的可信度是更高的。我相信大家都会有读代码的时候看到一段注释，不知道该不该信的时候（可能时间久远了）。但是如果是assert，说服力明显就更强。

最后再次强调一下，不要把assert当成一个正常的exception来用！不要去catch AssertionError！尽管在Python实现的层面上它就是一个exception，但是大家一定要习惯把语义和实现区分开这个事情，因为你写的代码在被别人阅读的时候是有隐含意的。
