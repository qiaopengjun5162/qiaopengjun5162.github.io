+++
title = "算法初识"
date = 2023-02-11T10:25:06+08:00
description = "算法初识"
[taxonomies]
tags = ["算法"]
categories = ["算法"]
+++

# 算法初识

- 博客地址：<https://www.cnblogs.com/bobo-zhang/p/10514873.html>

- 算法

  - 所谓的算法就是对问题进行处理且求解的一种实现思路或者思想。

  - 案例： a+b+c = 1000 a**2 + b**2 = c**2 (a,b,c均为自然数)，求出a,b,c可能的组合？

  - ```Python
    for a in range(0,1001):
        for b in range(0,1001):
            for c in range(0,1001):
                if a**2+b**2 == c**2 and a+b+c==1000:
                    print(a,b,c)
    ```

  - ```python
    for a in range(0,1001):
        for b in range(0,1001):
            c = 1000 - a - b
            if a**2+b**2 == c**2 and a+b+c==1000:
                    print(a,b,c)
    ```

  - 如何取衡量一个算法性能的好坏优劣？

    - 计算算法执行的耗时
    - 量化算法执行消耗计算机的资源大小
    - 时间复杂度（推荐）

  - 时间复杂度

    - 量化执法执行步骤的数量。

    - 案例：

    - ```python
      1 a=5
       2 b=6
       3 c=10
       4 for i in range(n):
       5    for j in range(n):
       6       x = i * i
       7       y = j * j
       8       z = i * j
       9 for k in range(n):
      10    w = a*k + 45
      11    v = b*b
      12 d = 33
      ```

      - 执行步骤：4+2n+3n**2

      - 时间复杂度的表示方法：大O记法

        - 将执行步骤数量表示的表达式中最有意义的一项取出，放置在大O后面的括号即可。

        - ```python
          4+2n+3n**2最有意义的一项是 n**2,大O记法：O(n**2)
          ```

        - 常见的时间复杂度： O(1) < O(logn) < O(n) < O(nlogn) < O(n^2) < O(n^3) < O(2^n) < O(n!) < O(n^n)

- 数据结构

  - 对组织方式就被称作为数据结构 。或者，认为所有不同形式的数据结构都可以表示一种容器，容器是用来装载数据。

  - 案例： 需要存储一些学生的学生信息（name,score）,那么这些数据应该如何组织呢？查询某一个具体学生的时间复杂度是什么呢？

  - ```python
    #方式1
    [{'name':'zhangsan','score':100},
     {'name':'lisi','score':99}
    ] 
    
    #方式2
    [('zhangsan',100),
     ('lisi',99)
    ] 
    
    #方式3
    {'zhangsan':{'score':100},
     'lisi':{'score':99}
    } 
    ```

  - 需求：对指定学生的成绩进行查询？上述的数据结构那种形式是最好的？

    - 方式3最好，因为时间复杂度为O(1),剩下两个为O(n)

  - 算法和数据结构之间的关系？

    - 因此认为算法是为了解决实际问题而设计的，数据结构是算法需要处理问题的载体 。

- 栈：先进后出

  - 栈顶，栈底
  - 元素的添加和提取都是从栈顶向栈底的方向进行。

- 案例：浏览器的回退按钮。

- 实现：

- ```python
  class Stack():
   def __init__(self):
    self.items = [] #构建一个空栈
   def push(self,item): #添加元素
    self.items.append(item)
   def pop(self):#取出元素
    return self.items.pop()
   def isEmpty(self):
    return self.items == []
   def length(self):
    return len(self.items)
  
  
  s = Stack()
  s.push(1)
  s.push(2)
  s.push(3)
  
  for i in range(s.length()):
   print(s.pop())
  
  ```

- 队列：先进先出

  - 队头，队尾
  - 元素必须是从队尾向队头的方向进行添加，且必须从队头以此取出元素。

- 案例：一个教室有10台电脑和一台打印机联网。电脑给打印机发送的打印任务必须放置在队列中。

- 队列的实现：

- ```python
  class Queue():
   def __init__(self):
    self.items = []
   def enqueue(self,item):#添加元素
    self.items.insert(0,item)
   def dequeue(self):#取出元素
    return self.items.pop()
   def isEmpty(self):
    return self.items == []
  ```

- 面试题：烫手的山芋

  - 6个孩子围城一个圈，排列顺序孩子们自己指定。第一个孩子手里有一个烫手的山芋，需要在计时器计时1秒后将山芋传递给下一个孩子，依次类推。规则是，在计时器每计时7秒时，手里有山芋的孩子退出游戏。该游戏直到剩下一个孩子时结束，最后剩下的孩子获胜。请使用队列实现该游戏策略，排在第几个位置最终会获胜。

    - 找已知的条件：
      - 把圈屡直了就是一个队列的结构
        - 只可以从队头取元素，从队尾添加元素
      - 山芋是1s中向后传递一次
      - 一轮游戏是7s的时长，一轮游戏山芋需要被传递6次
      - 当队列中只剩下一个孩子的时候游戏结束
      - 核心：必须要让手中有山芋的孩子作为队头元素！
        - 如何实现：山芋不动，人动

  - ```python
    class Queue():
     def __init__(self):
      self.items = []
     def enqueue(self,item):#添加元素
      self.items.insert(0,item)
     def dequeue(self):#取出元素
      return self.items.pop()
     def isEmpty(self):
      return self.items == []
     def length(self):
      return len(self.items)
    
    
    kids = ['A','B','C','D','E','F']
    queue = Queue()
    for kid in kids:#将孩子入队列
     queue.enqueue(kid)
    
    while queue.length() > 1: #多轮游戏进行时
     #实现一轮游戏策略
     for i in range(6): #一轮游戏山芋被传递的次数
      item = queue.dequeue()
      queue.enqueue(item)
     queue.dequeue() #一轮游戏后将队头元素淘汰
    
    print('最终的获胜者是：',queue.dequeue())
    ```

  - 如何使用两个队列实现一个栈？（使用两个先进先出的数据结构实现一种先进后出的效果）

    - ```python
      q1 = Queue()
      q2 = Queue()
      #数据存储到q1中
      alist = [1,2,3,4,5]
      for item in alist:
       q1.enqueue(item)
      
      while q1.length() >= 1:
       for i in range(q1.length()-1):
        item = q1.dequeue()
        q2.enqueue(item)
       print(q1.dequeue())
       q1,q2 = q2,q1
      ```

  - 链表

    - 计算机本质作用是什么？

      - 存储和运算二进制的数据！

    - 变量表示的是什么？

      - 面向对象的语言中所有的变量都是引用。

      - a = 10表示什么？

        - 在计算机的内存中开启一块内存空间，然后将10这个数据存储到该块内存空间中。a就是用来引用这个块内存空间的。通俗理解，所谓的变量或者引用表示的就是计算机内存中某一块内存空间。
        - 在计算机中开辟的每一块内存空间都拥有两个默认的属性：
          - 大小：决定可以存储最大的数据范围是什么
            - bit位：只能存放以为二进制的数。最大可以存储的数据是1，最小是0
            - byte字节：8bit。
          - 地址：用来让cpu寻址
        - 指向：如果一个变量引用了某一块内存空间，则该变量指向该块内存空间。

      - 计算机在为数据开辟内存的时候，内存空间大小是根据数据实际值的大小开辟呢还是统一大小开辟呢？

        - 统一开辟固定大小的内存
          - 整型数据：4字节
          - 字符串：一个字符一个字节
          - 小数：4、8字节

      - 为什么要有链表数据结构呢？

        - 顺序表：内存开辟是连续
          - 集合中存储的元素是有顺序的。顺序表的结构可以分为两种形式：单数据类型和多数据类型。
        - 弊端： 顺序表的结构需要预先知道数据大小来申请连续的存储空间，而在进行扩充时又需要进行数据的搬迁。

      - 实现：

      - ```python
        class Node():
         #构建一个节点
         def __init__(self,item):
          self.item = item
          self.next = None
        
        class Link():
         def __init__(self): #构建空链表
          self.head = None
         def add(self,item):#向链表头部插入节点：类比于列表的insert(0,item)
          node = Node(item)
          node.next = self.head
          self.head = node
        
         def travle(self):
          # print(self.head.item)
          # print(self.head.next.item)
          # print(self.head.next.next.item)
          cur = self.head  #head要永远指向头结点
          while cur:
           print(cur.item)
           cur = cur.next
         def isEmpty(self):
          return self.head == None
        
         def size(self):
          cur = self.head
          count = 0
          while cur:
           count += 1
           cur = cur.next
          return count
         def append(self,item): #向链表尾部添加新的节点
          node = Node(item)
          if self.isEmpty():#链表为空
           self.head = node
           return
          #链表为非空
          pre = None #pre永远指向cur前一个节点
          cur = self.head
          while cur:
           pre = cur
           cur = cur.next
          pre.next = node
        
         def insert(self,pos,item):#向pos表示的指定位置添加节点
          if pos == 0:
           self.add(item)
           return
          node = Node(item)
          #pos的位置的值刚好可以作为pre和cur向后偏移次数的值
          pre = None
          cur = self.head
          for i in range(pos):
           pre = cur
           cur = cur.next
          pre.next = node
          node.next = cur
        
         def remove(self,item): #删除item表示的节点
          pre = None
          cur = self.head
          #如果删除的是第一个节点
          if item == self.head.item:
           self.head = self.head.next
           return
          while cur:
           pre = cur
           cur = cur.next
           if cur:
            if cur.item == item:
             pre.next = cur.next
             return
        ```
