+++
title = "数据库系统原理之SQL与关系数据库基本操作"
date = 2023-02-27T18:51:31+08:00
description = "数据库系统原理之SQL与关系数据库基本操作"
[taxonomies]
tags = ["数据库", "MySQL"]
categories = ["数据库", "MySQL"]
+++

# SQL与关系数据库基本操作

## 第一节 SQL概述

结构化查询语言（Structured Query Language，SQL）是一种专门用来与数据库通信的语言，它可以帮助用户操作关系数据库。

### 一、SQL的发展

- 从20世纪80年代以来，SQL一直是关系数据库管理系统（RDBMS）的标准语言。
- SQL-89  SQL-92（SQL2）  SQL-99（SQL3）
- 目前没有一个数据库系统能够支持SQL标准的全部概念和特性。

### 二、SQL的特点

- SQL不是某个特定数据库供应商专有的语言
- SQL简单易学
- SQL尽管看上去很简单，但它实际上是一种强有力的语言，灵活使用其语言元素，可以进行非常复杂和高级的数据库操作
- SQL语句不区分大小写（开发人员习惯于对所有SQL关键字使用大写，对所有列和表的名称使用小写）

### 三、SQL的组成

SQL集数据查询（Data Query）、数据定义（Data Definition）、数据操纵（Data Manipulation）和数据控制（Data Control）四大功能于一体，其核心主要包含有以下几个部门：

- 数据定义语言（Data Definition Language，DDL）：主要用于对数据库及数据库中的各种对象进行创建、删除、修改等操作。其中数据库对象主要有表、默认约束、规则、视图、触发器、存储过程等。
  - CREATE：用于创建数据库或数据库对象
  - ALTER：用于对数据库或数据库对象进行修改
  - DROP：用于删除数据库或数据库对象
- 数据操纵语言（Data Manipulation Language，DML）：主要用于操纵数据库中各种对象、特别是检索和修改数据。
  - SELECT：用于从表或视图中检索数据，其是数据库中使用最为频繁的SQL语句之一
  - INSERT：用于将数据插入到表或视图中
  - UPDATE：用于修改表或视图中的数据，其即可修改表或视图中一行数据，也可同时修改多行或全部数据
  - DELETE：用于从表或视图中删除数据，其中可根据条件删除指定的数据
- 数据控制语言（Data Control Language，DCL）：主要用于安全管理，例如确定哪些用户可以查看或修改数据库中的数据。
  - GRANT：用于授予权限，可把语句许可或对象许可的权限授予其他用户或角色
  - REVOKE：用于收回权限，其功能与GRANT相反，但不影响该用户或角色从其他角色中作为成员继承许可权限
- 嵌入式和动态SQL规则：规定了SQL语句在高级程序设计语言中使用的规范方法，以便适应较为复杂的应用。
- SQL调用和会话规则：SQL调用包括SQL例程和调用规则，以便提高SQL的灵活性、有效性、共享性以及使SQL具有更多的高级语言的特征。SQL会话规则则可使应用程序连接到多个SQL服务器中的某一个，并与之交互。

## 第二节 MySQL预备知识

MySQL是一个关系数据库管理系统（RDBMS），它具有客户/服务器体系结构 ，最初是由瑞典MySQL AB公司开发。

### 一、MySQL使用基础

- LAMP（Linux+Apache+MySQL+PHP/Perl/Python），即使用Linux作为操作系统，Apache作为Web服务器，MySQL作为数据库管理系统，PHP、Perl或Python语言作为服务器端脚本解释器。
- WAMP（Windows+Apache+MySQL+PHP/Perl/Python），即使用Windows作为操作系统，Apache作为Web服务器，MySQL作为数据库管理系统，PHP、Perl或Python语言作为服务器端脚本解释器。

### 二、MySQL中的SQL

MySQL在SQL标准的基础上增加了部分扩展的语言要素：

- 常量：是指在程序运行过程中值不变的量，也称为字面值或标量值
  - 常量的使用格式取决于值的数据类型，可分为字符串常量、数值常量、十六进制常量、时间日期常量、位字段值、布尔值和NULL值
- 变量：用于临时存储数据，变量中的数据可以随着程序的运行而变化。
  - 变量有名字和数据类型两个属性
    - 变量的名字用于标识变量
    - 变量的数据类型用于确定变量中存储数值的格式和可执行的运算
  - 在MySQL中，变量分为用户变量和系统变量
    - 用户变量前添加一个“@”
    - 系统变量前添加两个“@”
- 运算法
  - 算术运算符：+（加）、-（减）、*（乘）、/（除）和%（求模）5种运算
  - 位运算符：&（位与）、|（位或）、^（位异或）、~（位取反）、>>（位右移）、<<（位左移）
  - 比较运算符：=（等于）、>（大于）、<（小于）、>=（大于等于）、<=（小于等于）、<>（不等于）、!=（不等于）、<=>（相等或都等于空）
  - 逻辑运算符：NOT或!（逻辑非）、AND或&&（逻辑与）、OR或||（逻辑或）、XOR（逻辑异或）
- 表达式：是常量、变量、列名、复杂计算、运算符和函数的组合
  - 根据表达式的值的数据类型，表示式可分为字符型表达式、数值型表达式和日期表达式
- 内置函数
  - 数学函数，例如ABS()函数、SORT()函数
  - 聚合函数，例如COUNT()函数
  - 字符串函数，例如ASCII()函数、CHAR()函数
  - 日期和时间函数，例如NOW()函数、YEAR()函数
  - 加密函数，例如FNCODE()函数、ENCRYPT()函数
  - 控制流程函数，例如IF()函数、IFNULL()函数
  - 格式化函数，例如FORMAT()函数
  - 类型转换函数，例如CAST()函数
  - 系统信息函数，例如USER()函数、VERSION()函数

## 第三节 数据定义

SQL标准不提供修改数据库模式定义和修改视图定义的操作，用户如果需要修改这些对象，可先将它们删除然后再重建，或者也可以使用具体的关系数据库关系系统所提供的扩展语句来实现。

SQL标准没有提供索引相关的语句。

SQL标准提供的数据定义语句

| 操作对象 |        创建        |       删除       |       修改       |
| :------: | :----------------: | :--------------: | :--------------: |
|   模式   | CREATE SCHEMA 语句 | DROP SCHEMA 语句 |                  |
|    表    | CREATE TABLE 语句  | DROP TABLE 语句  | ALTER TABLE 语句 |
|   视图   |  CREATE VIEW 语句  |  DROP VIEW 语句  |                  |

### 一、数据库模式定义

- 创建数据库

```sql
CREATE {DATABASE|SCHEMA}[IF NOT EXISTS] db_name
[DEFAULT] CHARACTER SET [=] charset_name
|[DEFAULT] COLLATE [=] collation_name

此语法说明：
"[]" 标示其内容为可选项

"|" 用于分隔花括号中的选择项，表示可任选其中一项来与花括号外的语法成分共同组成SQL语句命令，即选项彼此间是“或”的关系

"db_name" 用于标示具体的数据库命名，且该数据库名必须符号操作系统文件夹命名规则，在MySQL中不区分大小写

"DEFAULT" 指定默认值

"CHARACTER SET" 指定数据库字符集（Charset）

"COLLATE" 指定字符集的校对规则

"IF NOT EXISTS" 用于在创建数据库前进行判断，只有该数据库目前尚不存在时才执行CREATE DATABASE操作，即此选项可以避免出现数据库已经存在而再新建的错误
```

在MySQL中创建一个名为mysql_test的数据库

```sql
➜ mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1370
Server version: 8.0.32 Homebrew

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> create database if not exists mysql_test;
Query OK, 1 row affected (0.03 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| mysql_test         |
| performance_schema |
| sys                |
| win_pro            |
| win_pro_test       |
+--------------------+
7 rows in set (0.01 sec)

mysql>
```

- 选择数据库

```mysql
USE db_name;
```

只有使用USE命令指定某个数据库为当前数据库之后，才能对该数据库及其存储的数据对象执行各种后续操作

- 修改稿数据库

```sql
ALTER {DATABASE | SCHEMA} [db_name]
 alter_specification ...
```

修改已有数据库mysql_test的默认字符集和校对规则

```sql
mysql> use mysql_test;
Database changed
mysql> alter database mysql_test
    -> default character set gb2312
    -> default collate gb2312_chinese_ci;
Query OK, 1 row affected (0.02 sec)

mysql>
```

- 删除数据库

```sql
DROP {DATABASE|SCHEMA} [IF EXISTS] db_name
```

分别不使用和使用关键字”IF EXISTS“删除一个系统中尚未创建的数据库”mytest“

```sql
mysql> drop database mytest;
ERROR 1008 (HY000): Can't drop database 'mytest'; database doesn't exist
mysql> drop database if exists mytest;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql>
```

可选项”IF EXISTS“可以避免删除不存在的数据库时出现的MySQL错误信息。

使用DROP DATABASE 或 DROP SCHEMA 语句会删除指定的整个数据库，该数据库中的所有表（包括其中的数据）也将永久删除，因而使用该语句时，需谨慎，以免错误删除。

- 查看数据库

```sql
SHOW {DATABASES|SCHEMAS}
[LIKE 'pattern'|WHERE expr]

"LIKE" 匹配指定的数据库名称
"WHERE" 指定数据库名称查询范围的条件
```

使用SHOW DATABASES或SHOW SCHEMAS语句，只会列出当前用户权限范围内所能查看到的所有数据库名称。

列出当前用户可查看的数据库列表

```sql
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| mysql_test         |
| performance_schema |
| sys                |
| win_pro            |
| win_pro_test       |
+--------------------+
7 rows in set (0.00 sec)

mysql>
```

### 二、表定义

数据表是关系数据库中最重要、最基本的数据对象，也是数据存储的基本单位。

数据表被定义为字段的集合，数据在表中是按照行和列的格式来存储的，每一行代表一条记录，每一列代表记录中一个字段的取值。

创建数据表的过程，实质上就是定义每个字段的过程，同时也是实施数据完整性约束的过程。

- #### 创建表

```sql
CREATE [TEMPORARY] TABLE tbl_name
(
  字段名1 数据类型 [列级完整性约束条件] [默认值]
  [, 字段名2 数据类型 [列级完整性约束条件] [默认值]]
  [, ......]
  [, 表级完整性约束条件]
) [ENGINE=引擎类型];
```

在一个已有数据库mysql_test中新建一个包含客户姓名、性别、地址、联系方式等内容的客户基本信息表，要求将客户的id号指定为该表的主键。

```sql
mysql> use mysql_test;
Database changed
mysql> create table customers
    -> (
    -> cust_id int not null auto_increment,
    -> cust_name char(50) not null,
    -> cust_sex char(1) not null default 0,
    -> cust_address char(50) null,
    -> cust_contact char(50) null,
    -> primary key (cust_id)
    -> );
Query OK, 0 rows affected (0.04 sec)

mysql> show tables;
+----------------------+
| Tables_in_mysql_test |
+----------------------+
| customers            |
+----------------------+
1 row in set (0.01 sec)

mysql>
```

1. 临时表与持久表
   1. 添加可选性“TEMPORARY”关键字创建的表为临时表，否则为持久表。
   2. 临时表的生命周期较短，只对创建它的用户可见，当断开与该数据库的连接时，MySQL会自动删除。
   3. 两个不同的连接可以使用相同的临时表名称，同时两个临时表不会互相冲突，也不与原有的同名的非临时表冲突。
2. 数据类型
   1. 数据类型是指系统中所允许的数据的类型。
   2. 数据库中每个列都应有适当的数据类型，用于限制或允许该列中存储的数据。
   3. 在创建表时必须为每个表列指定正确的数据类型及可能得数据长度。
   4. 在MySQL中，主要的数据类型包括数值类型、日期和时间类型、字符串类型、空间数据类型等。
3. 关键字 AUTO_INCREMENT
   1. 关键字“AUTO_INCREMENT”可以为表中数据类型为整型的列设置自增属性。
   2. 顺序是从数字1开始。
   3. 每个表只能有一个AUTO_INCREMENT列，并且它必须被索引。
   4. 其值是可以被覆盖的。
4. 指定默认值
   1. 在MySQL中，默认值使用关键字“DEFAULT”来指定。
   2. 如果没有为列指定默认值，MySQL会自动为其分配一个。
   3. 如若该列可以去NULL值，则默认值为NULL。
   4. 如若该列被定义为NOT NULL，则默认值取决于该列的类型。
5. NULL值
   1. NULL值是指没有值或缺值。
   2. 在MySQL中是通过关键字“NULL”来指定。
   3. 允许NULL的列，可以在插入行时不给出该列的值。
   4. 不能将NULL值与空串相混淆，NULL值是没有值，它不是空串。
6. 主键
   1. 通过 PRIMARY KEY 关键字来指定。
   2. 主键值必须唯一，即表中的每个行必须具有唯一的主键值，而且主键一定要为NOT NULL。
   3. 如果主键使用单个列，则它的值必须唯一。
   4. 如果使用多个列，则这些列的组合值必须唯一。

- ### 更新表

- #### ADD [COLUMN] 子句 （向表中增加新列，且其可同时增加多个列）

  - 通过“FIRST”关键字将新列作为原表的第一列
  - 若不指定关键字（after/first），则新列会添加到原表的最后
  - 可以在ALTER TABLE 语句中通过使用 ADDPRIMARY KEY 子句、ADDFOREIGN KEY 子句、ADD INDEX 子句为原表添加一个主键、外键和索引等

向数据库mysql_test的表customers中添加一列，并命名为cust_city,用于描述用户所在的城市，要求其不能为NULL，默认值为字符串’Wuhan‘，且该列位于原表cust_sex列之后

- SQL语句

```sql
mysql> alter table mysql_test.customers
    -> add column cust_city char(10) not null default 'Wuhan' after cust_sex;
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc customers;
+--------------+----------+------+-----+---------+----------------+
| Field        | Type     | Null | Key | Default | Extra          |
+--------------+----------+------+-----+---------+----------------+
| cust_id      | int      | NO   | PRI | NULL    | auto_increment |
| cust_name    | char(50) | NO   |     | NULL    |                |
| cust_sex     | char(1)  | NO   |     | 0       |                |
| cust_city    | char(10) | NO   |     | Wuhan   |                |
| cust_address | char(50) | YES  |     | NULL    |                |
| cust_contact | char(50) | YES  |     | NULL    |                |
+--------------+----------+------+-----+---------+----------------+
6 rows in set (0.00 sec)

mysql>
```

- #### CHANGE [COLUMN] 子句

  - 可同时修改表中指定列的名称和数据类型
  - 可同时放入多个子句，只需彼此间用逗号分隔

将数据库mysql_test中表customers的cust_sex列重命名为sex，且将其数据类型更改为字符长度为1的字符数据类型char(1)，允许其为NULL，默认值为字符常量’M‘

```sql
mysql> alter table mysql_test.customers
    -> change column cust_sex sex char(1) null default 'M';
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc customers;
+--------------+----------+------+-----+---------+----------------+
| Field        | Type     | Null | Key | Default | Extra          |
+--------------+----------+------+-----+---------+----------------+
| cust_id      | int      | NO   | PRI | NULL    | auto_increment |
| cust_name    | char(50) | NO   |     | NULL    |                |
| sex          | char(1)  | YES  |     | M       |                |
| cust_city    | char(10) | NO   |     | Wuhan   |                |
| cust_address | char(50) | YES  |     | NULL    |                |
| cust_contact | char(50) | YES  |     | NULL    |                |
+--------------+----------+------+-----+---------+----------------+
6 rows in set (0.01 sec)

mysql>
```

- ALTER [COLUMN] 子句
  - 修改或删除表中指定列的默认值

将数据库mysql_test中表customers的cust_city列的默认值修改为字符常量’Beijing‘

```sql
mysql> alter table mysql_test.customers
    -> alter column cust_city set default 'Beijing';
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc customers;
+--------------+----------+------+-----+---------+----------------+
| Field        | Type     | Null | Key | Default | Extra          |
+--------------+----------+------+-----+---------+----------------+
| cust_id      | int      | NO   | PRI | NULL    | auto_increment |
| cust_name    | char(50) | NO   |     | NULL    |                |
| sex          | char(1)  | YES  |     | M       |                |
| cust_city    | char(10) | NO   |     | Beijing |                |
| cust_address | char(50) | YES  |     | NULL    |                |
| cust_contact | char(50) | YES  |     | NULL    |                |
+--------------+----------+------+-----+---------+----------------+
6 rows in set (0.01 sec)

mysql>
```

- MODIFY [COLUMN] 子句
  - 只会修改指定列的数据类型，而不会干涉它的列名
  - 可以通过关键字“FIRST”或“AFTER”修改指定列在表中的位置

将数据库mysql_test中表customers的cust_name列的数据类型由之前的字符长度为50的定长字符数据类型char(50)更改为字符长度为20的定长字符数据类型char(20)，并将此列设置成表的第一列。

```sql
mysql> alter table mysql_test.customers
    -> modify column cust_name char(20) first;
Query OK, 0 rows affected (0.04 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc customers;
+--------------+----------+------+-----+---------+----------------+
| Field        | Type     | Null | Key | Default | Extra          |
+--------------+----------+------+-----+---------+----------------+
| cust_name    | char(20) | YES  |     | NULL    |                |
| cust_id      | int      | NO   | PRI | NULL    | auto_increment |
| sex          | char(1)  | YES  |     | M       |                |
| cust_city    | char(10) | NO   |     | Beijing |                |
| cust_address | char(50) | YES  |     | NULL    |                |
| cust_contact | char(50) | YES  |     | NULL    |                |
+--------------+----------+------+-----+---------+----------------+
6 rows in set (0.01 sec)

mysql> 
```

- DROP [COLUMN] 子句

删除数据库mysql_test中表custmoers的 cust_contact列

```sql
mysql> alter table mysql_test.customers
    -> drop column cust_contact;
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc customers;
+--------------+----------+------+-----+---------+----------------+
| Field        | Type     | Null | Key | Default | Extra          |
+--------------+----------+------+-----+---------+----------------+
| cust_name    | char(20) | YES  |     | NULL    |                |
| cust_id      | int      | NO   | PRI | NULL    | auto_increment |
| sex          | char(1)  | YES  |     | M       |                |
| cust_city    | char(10) | NO   |     | Beijing |                |
| cust_address | char(50) | YES  |     | NULL    |                |
+--------------+----------+------+-----+---------+----------------+
5 rows in set (0.01 sec)

mysql>
```

- RENAME [TO] 子句
  - 为表重新赋予一个表名

使用RENAME [TO] 子句，重命名数据库mysql_test中表customers的表名为backup_customers

```sql
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| mysql_test         |
| performance_schema |
| sys                |
| win_pro            |
| win_pro_test       |
+--------------------+
7 rows in set (0.01 sec)

mysql> use mysql_test;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+----------------------+
| Tables_in_mysql_test |
+----------------------+
| customers            |
+----------------------+
1 row in set (0.00 sec)

mysql> alter table mysql_test.customers
    -> rename to mysql_test.backup_customers;
Query OK, 0 rows affected (0.02 sec)

mysql> show tables;
+----------------------+
| Tables_in_mysql_test |
+----------------------+
| backup_customers     |
+----------------------+
1 row in set (0.00 sec)

mysql>
```

- ### 重命名表

用RENAME TABLE 语句来更改表的名字，并可同时重命名多个表

```sql
RENAME TABLE tbl_name TO new_tal_name
 [, tbl_name2 TO new_tbl_name2] ...
```

使用RENAME TABLE 语句，将表backup_customers命名为customers

```sql
mysql> rename table mysql_test.backup_customers to mysql_test.customers;
Query OK, 0 rows affected (0.01 sec)

mysql> show tables;
+----------------------+
| Tables_in_mysql_test |
+----------------------+
| customers            |
+----------------------+
1 row in set (0.00 sec)

mysql>
```

- ### 删除表

```sql
DROP [TEMPORARY] TABLE [IF EXISTS]
 tbl_name [, tbl_name] ...
 [RESTRICT | CASCADE]
```

DROP TABLE 语句可以同时删除多个表（包括临时表），但操作者必须拥有该命令的权限

当表被删除时，其中存储的数据和分区信息均会被删除，所以使用该语句须格外小心，但操作者在该表上的权限并不会自动被删除

- ### 查看表

（1）显示表的名称

```sql
SHOW [FULL] TABLES [{FROM | IN} db_name]
 [LIKE 'pattern' | WHERE expr]
```

显示数据库mysql_test中所有的表名

```sql
mysql> use mysql_test;
Database changed
mysql> show tables;
+----------------------+
| Tables_in_mysql_test |
+----------------------+
| customers            |
+----------------------+
1 row in set (0.00 sec)

mysql>

```

（2）显示表的结构

```sql
第一种

SHOW [FULL] COLUMNS {FROM | IN} tbl_name [{FROM | IN} db_name]
 [LIKE 'pattern' | WHERE expr]
 
第二种

{DESCRIBE | DESC} tbl_name [col_name | wild]
```

说明：MySQL支持用DESCRIBE 作为 SHOW COLUMNS FROM 的一种快捷方式

显示数据库mysql_test中表customers的结构

```sql
mysql> desc mysql_test.customers;
+--------------+----------+------+-----+---------+----------------+
| Field        | Type     | Null | Key | Default | Extra          |
+--------------+----------+------+-----+---------+----------------+
| cust_name    | char(20) | YES  |     | NULL    |                |
| cust_id      | int      | NO   | PRI | NULL    | auto_increment |
| sex          | char(1)  | YES  |     | M       |                |
| cust_city    | char(10) | NO   |     | Beijing |                |
| cust_address | char(50) | YES  |     | NULL    |                |
+--------------+----------+------+-----+---------+----------------+
5 rows in set (0.00 sec)

mysql>
```

## 三、索引定义

索引是DBMS根据表中的一列或若干列按照一定顺序建立的列值与记录行之间的对应关系表，因而索引实质上是一张描述索引列的列值与原表中记录行之间一一对应关系的有序表。

索引是提高数据文件访问效率的有效方法。

1）索引是以文件的形式存储的，DBMS会将一个表的所有索引保存在同一个索引文件中，索引文件需要占用磁盘空间。

2）索引在提供查询速度的同时，却会降低更新表的速度。表中的索引越多，则更新表的时间就会越长。

- 普通索引（INDEX）：INDEX  KEY
- 唯一性索引（UNIQUE）：索引列中的所有值都只能出现一次，必须是唯一的，UNIQUE。
- 主键（PRIMARY KEY）：
  - 主键是一种唯一性索引
  - 创建主键时，必须指定关键字 PRIMARY KEY，且不能有空值
  - 主键一般是在创建表的时候指定，也可以通过修改表的方式添加主键，并且每个表只能有一个主键

单列索引：一个索引只包含原表中的一个列

组合索引：也称复合索引或多列索引，就是原表中多个列共同组成一个索引

一个表可以有多个单列索引，但这些索引不是组合索引

按照最左前缀的法则，一个组合索引实质上为表的查询提供了多个索引，以此来加快查询速度

### 1 索引的创建

- 使用CREATE INDEX 语句创建索引
  - 可以在一个已有的表上创建索引，但不能创建主键

```sql
CREATE [UNIQUE] INDEX index_name
 ON tbl_name (index_col_name, ...)
 
其中，index_col_name的格式为：

col_name [(length)][ASC | DESC]
```

可选项”UNIQUE“关键字用于指定创建唯一性索引

”Index_name“用于指定索引名，一个表可以创建多个索引，但每个索引在该表中的名称必须是唯一的

”tbl_name"用于指定要建立索引的表名

“Index_col_name”是关于索引列的描述

例子：在数据库mysql_test 的表customers 上，根据客户姓名列的前三个字符创建一个升序索引 index_customers

```sql
mysql> create index index_customers
    -> on mysql_test.customers(cust_name(3) asc);
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> show index from mysql_test.customers;
+-----------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table     | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-----------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| customers |          0 | PRIMARY         |            1 | cust_id     | A         |           0 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| customers |          1 | index_customers |            1 | cust_name   | A         |           0 |        3 |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
+-----------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
2 rows in set (0.00 sec)

mysql>

```

例子：在数据库mysql_test的表customers 上，根据客户姓名列和客户id号创建一个组合索引 index_cust

```sql
mysql> create index index_cust
    -> on mysql_test.customers(cust_name, cust_id);
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> show index from mysql_test.customers;
+-----------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table     | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-----------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| customers |          0 | PRIMARY         |            1 | cust_id     | A         |           0 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| customers |          1 | index_customers |            1 | cust_name   | A         |           0 |        3 |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| customers |          1 | index_cust      |            1 | cust_name   | A         |           0 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| customers |          1 | index_cust      |            2 | cust_id     | A         |           0 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-----------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
4 rows in set (0.01 sec)

mysql>

```

- 使用 CREATE TABLE 语句创建索引

例子：在已有数据库mysql_test上新建一个包含产品卖家id号、姓名、地址、联系方式、售卖产品类型、当月销量等内容的产品卖家信息表 seller，要求在创建表的同时，为该表添加由卖家id号和售卖产品类型组成的联合主键，并在当月销量上创建索引

```sql
mysql> use mysql_test;
Database changed
mysql> create table seller
    -> (
    -> seller_id int not null auto_increment,
    -> seller_name char(50) not null,
    -> seller_address char(50) null,
    -> seller_contact char(50) null,
    -> product_type int(5) null,
    -> sales int null,
    -> primary key (seller_id, product_type),
    -> index index_seller(sales)
    -> );
ERROR 1171 (42000): All parts of a PRIMARY KEY must be NOT NULL; if you need NULL in a key, use UNIQUE instead
mysql>
```

这个例子说明：MySQL可以在一个表上同时创建多个索引，并且使用 PRIMARY KEY 的列必须是一个具有 NOT NULL属性的列

```sql
mysql> create table seller
    -> (
    -> seller_id int not null auto_increment,
    -> seller_name char(50) not null,
    -> seller_address char(50) null,
    -> seller_contact char(50) null,
    -> product_type int(5) not null,
    -> sales int null,
    -> primary key (seller_id, product_type),
    -> index index_seller(sales)
    -> );
Query OK, 0 rows affected, 1 warning (0.02 sec)

mysql> desc mysql_test.seller;
+----------------+----------+------+-----+---------+----------------+
| Field          | Type     | Null | Key | Default | Extra          |
+----------------+----------+------+-----+---------+----------------+
| seller_id      | int      | NO   | PRI | NULL    | auto_increment |
| seller_name    | char(50) | NO   |     | NULL    |                |
| seller_address | char(50) | YES  |     | NULL    |                |
| seller_contact | char(50) | YES  |     | NULL    |                |
| product_type   | int      | NO   | PRI | NULL    |                |
| sales          | int      | YES  | MUL | NULL    |                |
+----------------+----------+------+-----+---------+----------------+
6 rows in set (0.01 sec)

mysql>
```

- 使用 ALTER TABLE 语句创建索引

例子：使用 ALTER TABLE 语句在数据库 mysql_test 中表 seller的姓名列上添加一个非唯一的索引，取名为 index_seller_name

```sql
mysql> alter table mysql_test.seller
    -> add index index_seller_name(seller_name);
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> show index from mysql_test.seller;
+--------+------------+-------------------+--------------+--------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table  | Non_unique | Key_name          | Seq_in_index | Column_name  | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+--------+------------+-------------------+--------------+--------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| seller |          0 | PRIMARY           |            1 | seller_id    | A         |           0 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| seller |          0 | PRIMARY           |            2 | product_type | A         |           0 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| seller |          1 | index_seller      |            1 | sales        | A         |           0 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| seller |          1 | index_seller_name |            1 | seller_name  | A         |           0 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+--------+------------+-------------------+--------------+--------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
4 rows in set (0.00 sec)

mysql>

```

### 2 索引的查看

```sql
SHOW {INDEX | INDEXES | KEYS}
 {FROM | IN} tbl_name
 [{FROM | IN} db_name]
 [WHERE expr]
```

### 3 索引的删除

- 使用 DROP INDEX 语句删除索引

```sql
DROP INDEX index_name ON tbl_name
```

例子：删除 customers表创建的索引 index_cust

```sql
mysql> show index from mysql_test.customers;
+-----------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table     | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-----------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| customers |          0 | PRIMARY         |            1 | cust_id     | A         |           0 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| customers |          1 | index_customers |            1 | cust_name   | A         |           0 |        3 |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| customers |          1 | index_cust      |            1 | cust_name   | A         |           0 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| customers |          1 | index_cust      |            2 | cust_id     | A         |           0 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-----------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
4 rows in set (0.00 sec)

mysql> drop index index_cust on mysql_test.customers;
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> show index from mysql_test.customers;
+-----------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table     | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-----------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| customers |          0 | PRIMARY         |            1 | cust_id     | A         |           0 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| customers |          1 | index_customers |            1 | cust_name   | A         |           0 |        3 |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
+-----------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
2 rows in set (0.00 sec)

mysql>
```

- 使用 ALTER TABLE 语句删除索引

例子：使用 ALTER TABLE 语句删除数据库 mysql_test 中表 customers 的主键和索引 index_customers

```sql
# 删除索引报错
ERROR 1075 (42000): Incorrect table definition; there can be only one auto column and it must be defined as a key

# 解决：修改为唯一约束
mysql> alter table mysql_test.customers add unique(cust_id);
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> alter table mysql_test.customers drop primary key, drop index index_customers;
Query OK, 0 rows affected (0.04 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> show index from mysql_test.customers;
+-----------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table     | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-----------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| customers |          0 | cust_id  |            1 | cust_id     | A         |           0 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-----------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
1 row in set (0.00 sec)

```

## 第四节 数据更新

### 一、插入数据

#### 1 使用 INSERT...VALUES 语句插入单行或多行元组数据

```sql
INSERT [INTO] tbl_name [(col_name, ...)]
 {VALUES | VALUE} ({expr | DEFAULT}, ...), (...), ...
```

例子：使用 INSERT...VALUES 语句向数据库 mysql_test 的表 customers 中插入这样一行完整数据：（901，张三，F，北京市，朝阳区）

```sql
mysql> insert into mysql_test.customers
    -> values (901,'张三','F','北京市','朝阳区');
ERROR 1366 (HY000): Incorrect integer value: '张三' for column 'cust_id' at row 1
mysql> desc customers;
+--------------+----------+------+-----+---------+----------------+
| Field        | Type     | Null | Key | Default | Extra          |
+--------------+----------+------+-----+---------+----------------+
| cust_name    | char(20) | YES  |     | NULL    |                |
| cust_id      | int      | NO   | PRI | NULL    | auto_increment |
| sex          | char(1)  | YES  |     | M       |                |
| cust_city    | char(10) | NO   |     | Beijing |                |
| cust_address | char(50) | YES  |     | NULL    |                |
+--------------+----------+------+-----+---------+----------------+
5 rows in set (0.00 sec)

mysql> alter table mysql_test.customers modify cust_name char(20) after cust_id;
Query OK, 0 rows affected (0.04 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc customers;
+--------------+----------+------+-----+---------+----------------+
| Field        | Type     | Null | Key | Default | Extra          |
+--------------+----------+------+-----+---------+----------------+
| cust_id      | int      | NO   | PRI | NULL    | auto_increment |
| cust_name    | char(20) | YES  |     | NULL    |                |
| sex          | char(1)  | YES  |     | M       |                |
| cust_city    | char(10) | NO   |     | Beijing |                |
| cust_address | char(50) | YES  |     | NULL    |                |
+--------------+----------+------+-----+---------+----------------+
5 rows in set (0.01 sec)

mysql> insert into mysql_test.customers values (901,'张三','F','北京市','朝阳区');
Query OK, 1 row affected (0.00 sec)

mysql> select * from customers;
+---------+-----------+------+-----------+--------------+
| cust_id | cust_name | sex  | cust_city | cust_address |
+---------+-----------+------+-----------+--------------+
|     901 | 张三      | F    | 北京市    | 朝阳区       |
+---------+-----------+------+-----------+--------------+
1 row in set (0.00 sec)

mysql>
```

例子：使用 INSERT...VALUES 语句向数据库 mysql_test 的表 customers 中插入一行数据，要求该数据目前只用明确给出cust_name列和cust_address列的信息，即分别为“李四”和“武汉市”，而cust_id列的值由系统自动生成，cust_sex列选用表中默认值，另外cust_contact列的值暂不确定，可不用指定。

```sql
mysql> insert into mysql_test.customers values(0,'李四',default,'武汉市',null);
Query OK, 1 row affected (0.01 sec)

mysql> select * from customers;
+---------+-----------+------+-----------+--------------+
| cust_id | cust_name | sex  | cust_city | cust_address |
+---------+-----------+------+-----------+--------------+
|     901 | 张三      | F    | 北京市    | 朝阳区       |
|     902 | 李四      | M    | 武汉市    | NULL         |
+---------+-----------+------+-----------+--------------+
2 rows in set (0.00 sec)

```

为了编写更为安全的 INSERT...VALUES 语句，通常需要在表名后的括号中明确地给出列名清单

```sql
mysql> insert into mysql_test.customers(cust_id,cust_name,cust_sex,cust_address,cust_contact)
    -> values(0,'李四',default,'武汉市',null);
ERROR 1054 (42S22): Unknown column 'cust_sex' in 'field list'

mysql> desc customers;
+--------------+----------+------+-----+---------+----------------+
| Field        | Type     | Null | Key | Default | Extra          |
+--------------+----------+------+-----+---------+----------------+
| cust_id      | int      | NO   | PRI | NULL    | auto_increment |
| cust_name    | char(20) | YES  |     | NULL    |                |
| sex          | char(1)  | YES  |     | M       |                |
| cust_city    | char(10) | NO   |     | Beijing |                |
| cust_address | char(50) | YES  |     | NULL    |                |
+--------------+----------+------+-----+---------+----------------+
5 rows in set (0.01 sec)

mysql> alter table mysql_test.customers change column sex cust_sex char(1) null default 'M';
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> insert into mysql_test.customers(cust_id,cust_name,cust_sex,cust_address,cust_contact) values(0,'李四',default,'武汉市',null);
ERROR 1054 (42S22): Unknown column 'cust_contact' in 'field list'
mysql> alter table mysql_test.customers
    -> add column cust_contact char(50) null;
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc customers;
+--------------+----------+------+-----+---------+----------------+
| Field        | Type     | Null | Key | Default | Extra          |
+--------------+----------+------+-----+---------+----------------+
| cust_id      | int      | NO   | PRI | NULL    | auto_increment |
| cust_name    | char(20) | YES  |     | NULL    |                |
| cust_sex     | char(1)  | YES  |     | M       |                |
| cust_city    | char(10) | NO   |     | Beijing |                |
| cust_address | char(50) | YES  |     | NULL    |                |
| cust_contact | char(50) | YES  |     | NULL    |                |
+--------------+----------+------+-----+---------+----------------+
6 rows in set (0.00 sec)

mysql> insert into mysql_test.customers(cust_id,cust_name,cust_sex,cust_address,cust_contact) values(0,'李四',default,'武汉市',null);
Query OK, 1 row affected (0.00 sec)

mysql> select * from customers;
+---------+-----------+----------+-----------+--------------+--------------+
| cust_id | cust_name | cust_sex | cust_city | cust_address | cust_contact |
+---------+-----------+----------+-----------+--------------+--------------+
|     901 | 张三      | F        | 北京市    | 朝阳区       | NULL         |
|     902 | 李四      | M        | 武汉市    | NULL         | NULL         |
|     903 | 李四      | M        | Beijing   | 武汉市       | NULL         |
+---------+-----------+----------+-----------+--------------+--------------+
3 rows in set (0.00 sec)

mysql>
```

#### 2 使用 INSERT...SET 语句插入部分列值数据

```sql
INSERT [INTO] tbl_name
 SET col_name={expr | DEFAULT}, ...
```

例子：

```sql
mysql> insert into mysql_test.customers
    -> set cust_name='李四',cust_address='武汉市',cust_sex=DEFAULT;
Query OK, 1 row affected (0.00 sec)

mysql> select * from customers;
+---------+-----------+----------+-----------+--------------+--------------+
| cust_id | cust_name | cust_sex | cust_city | cust_address | cust_contact |
+---------+-----------+----------+-----------+--------------+--------------+
|     901 | 张三      | F        | 北京市    | 朝阳区       | NULL         |
|     902 | 李四      | M        | 武汉市    | NULL         | NULL         |
|     903 | 李四      | M        | Beijing   | 武汉市       | NULL         |
|     904 | 李四      | M        | Beijing   | 武汉市       | NULL         |
+---------+-----------+----------+-----------+--------------+--------------+
4 rows in set (0.00 sec)

mysql>
```

#### 3 使用 INSERT...SELECT 语句插入子查询数据

```sql
INSERT [INTO] tbl_name [(col_name, ...)]
SELECT ...
```

SELECT 子句返回的是一个查询到的结果集

### 二、 删除数据

```sql
DELETE FROM tbl_name
 [WHERE wherr_condition]
 [ORDER BY ...]
 [LIMIT row_count]
```

- DELETE 语句删除的是表中的数据，而不是关于表的定义

例子：使用DELETE 语句删除数据库 mysql_test 的表 customers 中客户名为“王五”的客户信息

```sql
mysql> insert into mysql_test.customers set cust_name='王五',cust_address='武汉市',cust_sex=DEFAULT;
Query OK, 1 row affected (0.00 sec)

mysql> select * from customers;
+---------+-----------+----------+-----------+--------------+--------------+
| cust_id | cust_name | cust_sex | cust_city | cust_address | cust_contact |
+---------+-----------+----------+-----------+--------------+--------------+
|     901 | 张三      | F        | 北京市    | 朝阳区       | NULL         |
|     902 | 李四      | M        | 武汉市    | NULL         | NULL         |
|     903 | 李四      | M        | Beijing   | 武汉市       | NULL         |
|     904 | 李四      | M        | Beijing   | 武汉市       | NULL         |
|     905 | 王五      | M        | Beijing   | 武汉市       | NULL         |
+---------+-----------+----------+-----------+--------------+--------------+
5 rows in set (0.00 sec)

mysql> delete from mysql_test.customers
    -> where cust_name='王五';
Query OK, 1 row affected (0.00 sec)

mysql> select * from customers;
+---------+-----------+----------+-----------+--------------+--------------+
| cust_id | cust_name | cust_sex | cust_city | cust_address | cust_contact |
+---------+-----------+----------+-----------+--------------+--------------+
|     901 | 张三      | F        | 北京市    | 朝阳区       | NULL         |
|     902 | 李四      | M        | 武汉市    | NULL         | NULL         |
|     903 | 李四      | M        | Beijing   | 武汉市       | NULL         |
|     904 | 李四      | M        | Beijing   | 武汉市       | NULL         |
+---------+-----------+----------+-----------+--------------+--------------+
4 rows in set (0.00 sec)

mysql>

```

### 三、修改数据

```sql
UPDATE tbl_name
 SET col_name={expr|DEFAULT}[,col_name2={expr|DEFAULT}]...
 [WHERE where_condition]
 [ORDER BY ...]
 [LIMIT row_count]
```

例子：使用 UPDATE 语句将数据库 mysql_test 的表 customers 中姓名为“张三”的客户的地址更新为“武汉市”

```sql
mysql> update mysql_test.customers
    -> set cust_address='武汉市'
    -> where cust_name='张三';
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from customers;
+---------+-----------+----------+-----------+--------------+--------------+
| cust_id | cust_name | cust_sex | cust_city | cust_address | cust_contact |
+---------+-----------+----------+-----------+--------------+--------------+
|     901 | 张三      | F        | 北京市    | 武汉市       | NULL         |
|     902 | 李四      | M        | 武汉市    | NULL         | NULL         |
|     903 | 李四      | M        | Beijing   | 武汉市       | NULL         |
|     904 | 李四      | M        | Beijing   | 武汉市       | NULL         |
+---------+-----------+----------+-----------+--------------+--------------+
4 rows in set (0.00 sec)

mysql>
```

- 使用UPDATE语句可同时修改数据行的多个列值，只需其彼此间用逗号分隔即可
- 如若删除表中某个列的值，在允许该列可为空值的前提下，可将它设置为NULL来实现

## 第五节 数据查询

### 一、SELECT 语句

```sql
SELECT
 [ALL | DISTINCT | DISTINCTROW]
 select_expr [,select_expr ...]
 FROM table_references
 [WHERE where_condition]
 [GROUP BY {col_name|expr|position}
   [ASC|DESC],...[WITH ROLLUP]]
  [HAVING where_condition]
  [ORDER BY {col_name|expr|position}
   [ASC|DESC],...]
  [LIMIT {[offset,]row_count|row_count OFFSET offset}]
```

#### SELECT 语句中各子句的使用次序及说明

|   子句   |        说明        |      是否必须使用      |
| :------: | :----------------: | :--------------------: |
|  SELECT  | 要返回的列或表达式 |           是           |
|   FROM   |  从中检索数据的表  | 仅在从表选择数据时使用 |
|  WHERE   |      行级过滤      |           否           |
| GROUP BY |      分组说明      | 仅在按组计算聚合时使用 |
|  HAVING  |      组级过滤      |           否           |
| ORDER BY |    输出排序顺序    |           否           |
|  LIMIT   |    要检索的行数    |           否           |

### 二、列的选择与指定

在 SELECT 语句中，语法项”select_expr“主要用于指定需要查询的内容，其指定方法通常有以下几种：

#### 1 选择指定的列

例子：查询数据库mysql_test的表customers中各个客户的姓名、性别和地址信息

```sql
mysql> select cust_name,cust_sex,cust_address
    -> from mysql_test.customers;
+-----------+----------+--------------+
| cust_name | cust_sex | cust_address |
+-----------+----------+--------------+
| 张三      | F        | 武汉市       |
| 李四      | M        | NULL         |
| 李四      | M        | 武汉市       |
| 李四      | M        | 武汉市       |
+-----------+----------+--------------+
4 rows in set (0.00 sec)

mysql>
```

例子：查询数据库mysql_test的表customers中各个客户的所有信息

```sql
mysql> select * from mysql_test.customers;
+---------+-----------+----------+-----------+--------------+--------------+
| cust_id | cust_name | cust_sex | cust_city | cust_address | cust_contact |
+---------+-----------+----------+-----------+--------------+--------------+
|     901 | 张三      | F        | 北京市    | 武汉市       | NULL         |
|     902 | 李四      | M        | 武汉市    | NULL         | NULL         |
|     903 | 李四      | M        | Beijing   | 武汉市       | NULL         |
|     904 | 李四      | M        | Beijing   | 武汉市       | NULL         |
+---------+-----------+----------+-----------+--------------+--------------+
4 rows in set (0.00 sec)

mysql>
```

#### 2 定义并使用列的别名

将SELECT语句的语法项”select_expr“指定为如下语法格式：

```sql
column_name [AS] column_alias
```

例子：查询数据库mysql_test的表customers中客户的cust_name列、cust_address列和cust_contact，要求将结果集中cust_address列的名称使用别名”地址“替代

```sql
mysql> select cust_name,cust_address as 地址,cust_contact
    -> from mysql_test.customers;
+-----------+-----------+--------------+
| cust_name | 地址      | cust_contact |
+-----------+-----------+--------------+
| 张三      | 武汉市    | NULL         |
| 李四      | NULL      | NULL         |
| 李四      | 武汉市    | NULL         |
| 李四      | 武汉市    | NULL         |
+-----------+-----------+--------------+
4 rows in set (0.00 sec)

mysql>
```

#### 3 替换查询结果集中的数据

将SELECT语句的语法项”select_expr“指定为如下语法格式：

```sql
CASE
WHERE 条件1 THEN 表达式1
 WHERE 条件2 THEN 表达式2
 ...
ELSE 表达式
END[AS] colunm_alias
```

例子：查询数据库mysql_test的表customers中客户的cust_name列和cust_sex列，要求判断结果集中cust_sex列的值，如果该列的值为M，则显示输出”男“，否则为”女“，同时在结果集的显示中奖cust_sex列用别名”性别“标注

```sql
mysql> select cust_name,
    -> case
    -> when cust_sex='M' then '男'
    -> else '女'
    -> end as 性别
    -> from mysql_test.customers;
+-----------+--------+
| cust_name | 性别   |
+-----------+--------+
| 张三      | 女     |
| 李四      | 男     |
| 李四      | 男     |
| 李四      | 男     |
+-----------+--------+
4 rows in set (0.00 sec)

mysql>
```

#### 4 计算列值

例子：查询数据库 mysql_test 的表 customers 中每个客户的 cust_name 列、cust_sex列，以及对cust_id列加上数字100后的值

```sql
mysql> select cust_name,cust_sex,cust_id+100
    -> from mysql_test.customers;
+-----------+----------+-------------+
| cust_name | cust_sex | cust_id+100 |
+-----------+----------+-------------+
| 张三      | F        |        1001 |
| 李四      | M        |        1002 |
| 李四      | M        |        1003 |
| 李四      | M        |        1004 |
+-----------+----------+-------------+
4 rows in set (0.00 sec)

```

#### 5 聚合函数

聚合函数通常是数据库系统中一类系统内置函数，常用于对一组值进行计算，然后返回单个值。

除COUNT函数外，聚合函数都会忽略空值。

MySQL中常用聚合函数表

| 函数名        | 说明                                   |
| ------------- | -------------------------------------- |
| COUNT         | 求组中项数，返回INT类型整数            |
| MAX           | 求最大值                               |
| MIN           | 求最小值                               |
| SUM           | 返回表达式中所有值的和                 |
| AVG           | 求组中值的平均値                       |
| STD 或 STDDEV | 返回给定表达式中所有值的标准值         |
| VARIANCE      | 返回给定表达式中所有值的方差           |
| GROUP_CONCAT  | 返回由属于一组的列值连接组合而成的结果 |
| BIT_AND       | 逻辑或                                 |
| BIR_OR        | 逻辑与                                 |
| BIT_XOR       | 逻辑异或                               |

### 三、FROM 子句与多表连接查询

若一个查询同时涉及两个或两个以上的表，则称之为多表连接查询，也称多表查询或连接查询。

多表连接查询是关系数据库中最主要的查询。

通过在FROM子句中指定多个表时，SELECT操作会使用“连接”运算将不同表中需要查询的数据组合到一个结果集中，并同样以一个临时表的形式返回，其连接方式主要包括交叉连接、内连接和外连接。

#### 1 交叉连接

- 交叉连接，又称笛卡尔积
- 在MySQL中，它是通过在FROM子句中使用关键字“CROSS JOIN” 来连接两张表，从而实现一张表的每一行与另一张表的每一行的笛卡尔乘积，并返回两张表的每一行相乘的所有可能的搭配结果，供SELECT 语句中其他语法元素（如 WHERE 子句、GROUP BY 子句等）进行过滤和筛选操作

例子：假设数据库中有两张表，分别是 tbl1 和tbl2，现要求输出这两张表执行交叉联接后的所有数据集

```sql
mysql> SELECT * FROM tbl1 CROSS JOIN tbl2;

mysql> SELECT * FROM tbl1,tbl2;
```

- 交叉连接返回的查询结果集的记录行数，等于其所连接的两张表记录行数的乘积
- 对于存在大量数据的表，应该避免使用交叉连接

#### 2 内连接

```sql
SELECT some_columns
FROM table1
INNER JOIN
 table2
ON some_conditions;
```

连接条件“some_sonditions”一般使用的语法格式是：

```sql
[<table1>.]<列名或列别名><比较运算符>[<table2>.]<列名或列别名>
```

示例：

```sql
mysql> SELECT * FROM tb_student INNER JOIN tb_score ON tb_student.studentNo = tb_score.studentNo;
```

- 由于内连接是系统默认的表连接，因而在 FROM 子句中可以省略关键字 “INNER”，而只用关键字“JOIN”连接表

##### （1）等值连接

在FROM子句中使用关键字“INNER JOIN” 或 “JOIN”连接两张表时，如若在ON子句的连接条件中使用运算符 “=”（即等号），即进行相等性测试，则此连接方式称为等值连接，也称为相等连接。通常，在等值连接的条件设置中会包含一个主键和一个外键。

##### （2）非等值连接

在FROM子句中使用关键字“INNER JOIN” 或 “JOIN”连接两张表时，如若在ON子句的连接条件中使用除运算符 “=”之外的其他比较运算符，即进行不相等性测试，则此连接方式称为非等值连接，也称为不等连接。

##### （3）自连接

在FROM子句中使用关键字“INNER JOIN” 或 “JOIN”连接两张表时，可以将一个表与它自身进行连接，这种连接方式称为自连接。

自连接时一种特殊的内连接，若需要在一个表中查找具有相同列值的行，则可以考虑使用自连。

使用自连接时，需要为表指定两个不同的别名，且对所有查询列的引用均必须使用表别名限定，否则SELECT操作会失败。

#### 3 外连接

外连接是首先将连接的两张表分为基表和参考表，然后再以基表为依据返回满足和不满足条件的记录。

外连接可以在表中没有匹配记录的情况下仍返回记录。

##### （1）左外连接

左外连接，也称左连接，它的使用语法格式与内连接大致相同，区别仅在于它在 FROM 子句中使用关键字 “LEFT OUTER JOIN” 或关键字 “LEFT JOIN" 来连接两张表，而不是使用关键字 ”INNER JOIN“ 或 ”JOIN“，如此可用于接收关键字 ”LEFT OUTER JOIN“ 或 ”LEFT JOIN“ 左边表（也称为基表）的所有行，并用这些行与该关键字右边表（也称为参考表）中的行进行匹配，即匹配左表中的每一行及右表中符号条件的行。

左外连接的结果集中的NULL值表示右表中没有找到与左表相符的记录

##### （2）右外连接

右外连接，也称右连接，它的使用语法格式与内连接大致相同，区别仅在于它在 FROM 子句中使用关键字 ”RIGHT OUTER JOIN“ 或关键字 ”RIGHT JOIN“ 来连接两张表，而不是使用关键字 ”INNER JOIN“ 或 ”JOIN“。

右外连接是以右表为基表，其连接方式与左外连接完全一样。

在右外连接的结果集中除了匹配的行之外，还包括右表中有的，但在左表中不匹配的行，对于这样的行，从左表中被选择的列的值被设置为NULL。

左外连接例子：

```sql
mysql> SELECT * FROM tb_student LEFT JOIN tb_score ON tb_student.studentNo = tb_score.studentNo;
```

### 四、WHERE 子句与条件查询

WHERE 子句中设置过滤条件的几个常用方法：

#### 1 比较运算

比较运算符表

| 比较运算符 | 说明             |
| ---------- | ---------------- |
| =          | 等于             |
| <>         | 不等于           |
| !=         | 不等于           |
| <          | 小于             |
| <=         | 小于等于         |
| >          | 大于             |
| >=         | 大于等于         |
| <=>        | 不会返回 UNKNOWN |

例子：在数据库 mysql_test 的表 customers 中查找所有男性客户的信息

```sql
mysql> select * from mysql_test.customers where cust_sex = 'M';
+---------+-----------+----------+-----------+--------------+--------------+
| cust_id | cust_name | cust_sex | cust_city | cust_address | cust_contact |
+---------+-----------+----------+-----------+--------------+--------------+
|     902 | 李四      | M        | 武汉市    | NULL         | NULL         |
|     903 | 李四      | M        | Beijing   | 武汉市       | NULL         |
|     904 | 李四      | M        | Beijing   | 武汉市       | NULL         |
+---------+-----------+----------+-----------+--------------+--------------+
3 rows in set (0.00 sec)

mysql>
```

#### 2 判定范围

（1） BETWEEN...AND

```sql
expression [NOT] BETWEEN expression1 AND expression2
```

- expression1的值不能大于expression2的值
- 例子：

在数据库mysql_test 的表 customers 中，查询客户 id号在903至912之间的十个客户信息

```sql
mysql> select * from mysql_test.customers where cust_id between 903 and 912;
+---------+-----------+----------+-----------+--------------+--------------+
| cust_id | cust_name | cust_sex | cust_city | cust_address | cust_contact |
+---------+-----------+----------+-----------+--------------+--------------+
|     903 | 李四      | M        | Beijing   | 武汉市       | NULL         |
|     904 | 李四      | M        | Beijing   | 武汉市       | NULL         |
+---------+-----------+----------+-----------+--------------+--------------+
2 rows in set (0.00 sec)

mysql>
```

（2）IN

```sql
expression IN (expression [,...n])
```

例子：在数据库 mysql_test 的表 customers 中，查询客户id号分别为903、906和908三个客户的信息

```sql
mysql> select * from mysql_test.customers where cust_id in (903,906,908);
+---------+-----------+----------+-----------+--------------+--------------+
| cust_id | cust_name | cust_sex | cust_city | cust_address | cust_contact |
+---------+-----------+----------+-----------+--------------+--------------+
|     903 | 李四      | M        | Beijing   | 武汉市       | NULL         |
+---------+-----------+----------+-----------+--------------+--------------+
1 row in set (0.00 sec)

mysql>
```

#### 3 判定空值

```sql
expression IS [NOT] NULL
```

例子：在数据库mysql_test的表customers中，查询是否存在没有填写客户联系方式的客户

```sql
mysql> select cust_name from mysql_test.customers where cust_contact is null;
+-----------+
| cust_name |
+-----------+
| 张三      |
| 李四      |
| 李四      |
| 李四      |
+-----------+
4 rows in set (0.01 sec)

mysql>
```

#### 4 子查询

通常，可以使用 SELECT 语句创建子查询，即可嵌套在其他SELECT查询中的SELECT查询。

在MySQL中，区分如下四类子查询：

- 表子查询，即子查询返回的结果集是一个表
- 行子查询，即子查询返回的结果集是带有一个或多个值的一行数据
- 列子查询，即子查询返回的结果集是一列数据，该列可以有一行或多行，但每行只有一个值
- 标量子查询，即子查询返回的结果集仅仅是一个值

##### （1）结合关键字“IN” 使用的子查询

```sql
expression [NOT] IN (subquery)
```

例子：根据学生基本信息登记表 tb_student 和学生成绩表 tb_score，使用子查询的方式查询任意所选课程成绩高于80分的学生的学号和姓名信息

```sql
mysql> SELECT studentNo, studentName FROM tb_student WHERE studentNo IN (SELECT studentNo FROM tb_score WHERE score>80);
```

##### （2）结合比较运算符使用的子查询

```sql
expression {=|<|<=|>|>=|<=>|<>|!=} {ALL|SOME|ANY} (subquery)
```

##### （3）结合关键字“EXIST”使用的子查询

```sql
EXIST (subquery)
```

### 五、GROUP BY 子句与分组数据

```sql
GROUP BY {col_name|expr|position}[ASC|DESC],...[WITH ROLLUP]
```

例子：在数据库 mysql_test 的表 customers 中获取一个数据结果集，要求改结果集中分别包含每个相同地址的男性客户人数和女性客户人数

```sql
mysql> select cust_address, cust_sex, count(*) as '人数'
    -> from mysql_test.customers
    -> group by cust_address,cust_sex;
+--------------+----------+--------+
| cust_address | cust_sex | 人数   |
+--------------+----------+--------+
| 武汉市       | F        |      1 |
| NULL         | M        |      1 |
| 武汉市       | M        |      2 |
+--------------+----------+--------+
3 rows in set (0.00 sec)

mysql>
```

例子2：在数据库 mysql_test 的表 customers 中获取一个数据结果集，要求该结果集中包含每个相同地址的男性客户人数、女性客户人数、总人数以及客户的总人数

```sql
mysql> select cust_address,cust_sex,count(*) as '人数'
    -> from mysql_test.customers
    -> group by cust_address,cust_sex
    -> with rollup;
+--------------+----------+--------+
| cust_address | cust_sex | 人数   |
+--------------+----------+--------+
| NULL         | M        |      1 |
| NULL         | NULL     |      1 |
| 武汉市       | F        |      1 |
| 武汉市       | M        |      2 |
| 武汉市       | NULL     |      3 |
| NULL         | NULL     |      4 |
+--------------+----------+--------+
6 rows in set (0.00 sec)

mysql>
```

- GROUP BY 子句可以包含任意数目的列，使得其可对分组进行嵌套，为数据分组提供更加细致的控制
- 如果在 GROUP BY 子句中嵌套了分组，那么将按 GROUP BY 子句中列的排列顺序的逆序方式依次进行汇总，并将在最后规定的分组上进行一个完全汇总
- GROUP BY 子句中列出的每个列都必须是检索列或有效的表达式，但不能是聚合函数。如果在 SELECT 语句中使用表达式，则必须在 GROUP BY 子句中指定相同的表达式。注意，不能使用别名。
- 除聚合函数之外，SELECT 语句中的每个列都必须在 GROUP BY 子句中给出。
- 如果用于分组的列中含有 NULL 值，则 NULL 将作为一个单独的分组返回；如果该列中存在多个 NULL值，则将这些NULL值所在的行分为一组。

### 六、HAVING 子句

```sql
HAVING where_condition
```

HAVING 子句与 WHERE 子句非常相似，HAVING 子句支持 WHERE 子句中所有的操作符和句法，但两者之间仍存在以下几点差异：

- WHERE 子句主要用于过滤数据行，而 HAVING 子句主要用于过滤分组，即HAVING 子句可基于分组的聚合值而不是特定行的值来过滤数据。
- HAVING 子句中的条件可以包含聚合函数，而 WHERE 子句中则不可以。
- WHERE 子句会在数据分组前进行过滤，HAVING 子句则会在数据分组后进行过滤。

例子：在数据库 mysql_test 的表 customers 中查找这样一类客户信息：要求在返回的结果集中，列出相同客户地址中满足客户人数少于3的所有客户姓名及其对应地址。

```sql
mysql> select cust_name,cust_address
    -> from mysql_test.customers
    -> group by cust_address,cust_name
    -> having count(*) <=3;
+-----------+--------------+
| cust_name | cust_address |
+-----------+--------------+
| 张三      | 武汉市       |
| 李四      | NULL         |
| 李四      | 武汉市       |
+-----------+--------------+
3 rows in set (0.01 sec)

mysql>

```

### 七、ORDER BY 子句

```sql
ORDER BY {col_name | expr | position} [ASC | DESC],...
```

例子：在数据库 mysql_test 的表 customers 中依次按照客户姓名和地址的降序方式，输出客户的姓名和性别。

```sql
mysql> select cust_name,cust_sex from mysql_test.customers
    -> order by cust_name desc,cust_address desc;
+-----------+----------+
| cust_name | cust_sex |
+-----------+----------+
| 张三      | F        |
| 李四      | M        |
| 李四      | M        |
| 李四      | M        |
+-----------+----------+
4 rows in set (0.01 sec)

mysql>
```

- ORDER BY 子句中可以包含子查询。
- 当对空值进行排序时，ORDER BY 子句会将该空值作为最小值来对待。即，若按升序排列结果集，则 ORDER BY 子句会将该空值所在的数据行置于结果集的最上方；若是使用降序排序，则会将其置于结果集的最下方。
- 若在 ORDER BY 子句中指定多个列进行排序，则在MySQL中会按照这些列从左至右所罗列的次序依次进行排序
- 在使用 GROUP BY 子句时，通常也会同时使用 ORDER BY 子句。

#### ORDER BY 子句与 GROUP BY 子句的差别汇总

| *ORDER BY 子句*  | GROUP BY 子句                              |
| ---------------- | ------------------------------------------ |
| 排序产生的输出   | 分组行，但输出可能不是分组的排序           |
| 任意列都可以使用 | 只可能使用选择列或表达式列                 |
| 不一定需要       | 若与聚合函数一起使用列或表达式，则必须使用 |

### 八、LIMIT 子句

```sql
LIMIT {[offset,] row_count | row_count OFFSET offset}
```

例子：在数据库 mysql_test 的表 customers 中查找从第5位客户开始的3位客户的id号和姓名信息

```sql
mysql> select cust_id,cust_name from mysql_test.customers
    -> order by cust_id
    -> limit 4,3;
Empty set (0.00 sec)

mysql> select cust_id,cust_name from mysql_test.customers
    -> order by cust_id
    -> limit 3 offset 4;
Empty set (0.01 sec)

mysql>
```

## 第六节 视图

外模式对应到数据库中的概念就是视图（View）。

视图是数据库中的一个对象，它是数据库管理系统提供给用户的以多种角度观察数据库中数据的一种重要机制。

视图是从一个或多个表或者其他视图中通过查询语句导出的表，它也包含一系列带有名称的数据列和若干条数据行，并有自己的视图名，由此可见视图与基本表十分类似。

视图与数据库中真实存在的基本表存在以下区别：

- 视图不是数据库中真实的表，而是一张虚拟表，其结构和数据是建立在对数据库中真实表的查询基础上的。
- 视图的内容是由存储在数据库中进行查询操作的SQL语句来定义的，它的列数据与行数据均来自于定义视图的查询所引用的真实表，并且这些数据是在引用视图时动态生成的。
- 视图不是以数据集的形式存储在数据库中，它所对应的数据实际上是存储在视图所引用的真实表（基本表）中
- 视图是用来查看存储在别处的数据的一种虚拟表，而其自身并不存储数据。

视图的优点：

- 集中分散数据
- 简化查询语句
- 重用SQL语句
- 保护数据安全
- 共享所需数据
- 更改数据格式

### 一、创建视图

```sql
CREATEVIEW view_name [(column_list)]
 AS select_statement
 [WITH [CASCADED | LOCAL] CHECK OPTION]
```

例子：在数据库mysql_test 中创建视图 customers_view，要求该视图包含客户信息表 customers 中所有男客户的信息，并且要求保证今后对该视图数据的修改都必须符合客户性别为男性这个条件。

```sql
➜ mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1849
Server version: 8.0.32 Homebrew

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> use mysql_test;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> create or replace view mysql_test.customers_view
    -> as
    -> select * from mysql_test.customers where cust_sex='M'
    -> with check option;
Query OK, 0 rows affected (0.03 sec)

mysql>
```

### 二、删除视图

```sql
DROP VIEW [IF EXISTS]
 view_name [,view_name] ...
 [RESTRICT | CASCADE]
```

### 三、修改视图定义

```sql
ALTERVIEW view_name [(column_list)]
 AS select_statement
 [WITH [CASCADED | LOCAL] CHECK OPTION]
```

### 四、查看视图定义

```sql
SHOW CREATE VIEW view_name
```

示例：

```sql
mysql> show create view customers_view;
+----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+
| View           | Create View                                                                                                                                                                                                                                                                                                                                                                                                                         | character_set_client | collation_connection |
+----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+
| customers_view | CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `customers_view` AS select `customers`.`cust_id` AS `cust_id`,`customers`.`cust_name` AS `cust_name`,`customers`.`cust_sex` AS `cust_sex`,`customers`.`cust_city` AS `cust_city`,`customers`.`cust_address` AS `cust_address`,`customers`.`cust_contact` AS `cust_contact` from `customers` where (`customers`.`cust_sex` = 'M') WITH CASCADED CHECK OPTION | utf8mb4              | utf8mb4_0900_ai_ci   |
+----------------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+
1 row in set (0.01 sec)

mysql>
```

### 五、更新视图数据

由于视图是一个虚拟表，所以通过插入、修改和删除等操作方式来更新视图中的数据，实质上是在更新视图所引用的基本表中的数据。

只有满足可更新条件的视图才能进行更新，否则可能会导致系统出现不可预期的结果。

#### 1 使用 INSERT 语句通过视图向基本表插入数据

例子：在数据库 mysql_test 中，向视图 customers_view 插入一条记录：（909,'周明','M','武汉市','洪山区'）。

```sql
mysql> insert into mysql_test.customers_view
    -> values(909,'周明','M','武汉市','洪山区');
ERROR 1136 (21S01): Column count doesn't match value count at row 1
mysql> select * from customers;
+---------+-----------+----------+-----------+--------------+--------------+
| cust_id | cust_name | cust_sex | cust_city | cust_address | cust_contact |
+---------+-----------+----------+-----------+--------------+--------------+
|     901 | 张三      | F        | 北京市    | 武汉市       | NULL         |
|     902 | 李四      | M        | 武汉市    | NULL         | NULL         |
|     903 | 李四      | M        | Beijing   | 武汉市       | NULL         |
|     904 | 李四      | M        | Beijing   | 武汉市       | NULL         |
+---------+-----------+----------+-----------+--------------+--------------+
4 rows in set (0.00 sec)

mysql> insert into mysql_test.customers_view values(909,'周明','M','武汉市','洪山区',null);
Query OK, 1 row affected (0.01 sec)

mysql>

```

#### 2 使用 UPDATE 语句通过视图修改基本表的数据

例子：将视图 customer_view 中所有客户的 cust_address 列更新为“上海市”。

```sql
mysql> update mysql_test.customers_view set cust_address='上海市';
Query OK, 4 rows affected (0.01 sec)
Rows matched: 4  Changed: 4  Warnings: 0

mysql>
```

- 若一个视图依赖于多个基本表，则一次视图数据修改操作只能改变一个基本表中的数据。

#### 3 使用 DELETE 语句通过视图删除基本表的数据

例子：删除视图 customers_view 中姓名为“周明”的客户信息。

```sql
mysql> delete from mysql_test.customers_view where cust_name='周明';
Query OK, 1 row affected (0.01 sec)

mysql>
```

注意：对于依赖多个基本表的视图，也是不能使用 DELETE 语句的。

### 六、查询视图数据

视图用于查询检索，主要体现在这样一些应用：利用视图简化复杂的表连接；使用视图重新格式化检索出的数据；使用视图过滤不想要的数据。

例子：在视图 customers_view 中查找客户 id 号为905的客户姓名及其地址信息。

```sql
mysql> select cust_name,cust_address from mysql_test.customers_view where cust_id=905;
Empty set (0.00 sec)

mysql>
```
