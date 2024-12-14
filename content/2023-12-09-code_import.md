+++
title= "Python 中 import 的使用说明"
date= 2023-12-09T18:16:48+08:00
[taxonomies]
tags= ["Python"]
categories= ["Python"]
+++

# Python 中 import 的使用说明

## 1. 导入模块

### 1.1 导入模块

```python
import module1, module2
```

### 1.2 导入模块时给模块指定别名

```python
import module1 as m1
import module2 as m2
```

### 1.3 导入模块时给模块指定别名，并指定模块的路径

```python
import module1 as m1
import module2 as m2
from module1 import func1
from module2 import func2
```

## 2. import的格式说明

Python官方给出的建议是这样的，把import分为三个类型：

官方标准库，比如sys, os
第三方库，比如numpy
本地库

每一组import都要用空格区分开。

在每一组import内，每个import只import一个库，不要出现 import os, sys 这样的用法。如果用from，可以import多个内容，比如 from subprocess import Popen, PIPE 。尽量避免使用 from XX import * ，以防命名冲突。

在每一组import内，先写import完整库的，再写使用from的。每一类再按照字典序排序。

## 3. 导入模块的顺序

Python的import语句是可以在程序中多次使用的，所以，如果导入的模块过多，那么导入顺序就显得尤为重要。

### 3.1 导入顺序

1. 标准库
2. 第三方库
3. 本地库

### 3.2 导入顺序示例

```python
import os
import sys
import time
import datetime
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import xlrd
import xlwt
import xlsxwriter
import openpyxl
```
