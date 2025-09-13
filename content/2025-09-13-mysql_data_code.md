+++
title = "MySQL 数据库编程：存储过程与存储函数详解"
description = "MySQL 数据库编程：存储过程与存储函数详解"
date = 2025-09-13T13:38:36Z
[taxonomies]
categories = ["MySQL", "数据库"]
tags = ["MySQL", "数据库"]
+++

<!-- more -->

# MySQL 数据库编程：存储过程与存储函数详解

在数据库管理与应用开发中，许多复杂的业务逻辑需要通过多条 SQL 语句组合完成。然而，将这些逻辑全部放在应用程序中执行，不仅会增加网络开销，还会导致性能瓶颈和维护上的困难。MySQL 的存储过程与存储函数提供了一种优雅的解决方案。它们允许你将一组预编译的 SQL 语句封装在数据库中，从而提升执行效率、增强代码复用性并提高安全性。本文将作为一份详尽的指南，深入解析存储过程与存储函数的核心概念、创建、调用、以及高级用法，助你全面掌握这两大数据库编程利器。

本文详细介绍了 MySQL 存储过程与存储函数的原理与实践。内容涵盖存储过程的基本概念、创建语法、局部变量、流程控制和游标等高级特性；同时，对比了存储函数与存储过程的区别，并通过实例展示了它们的创建与调用方法。通过学习本文，你将能够掌握如何将复杂的业务逻辑封装在数据库内部，从而有效提升数据库操作的性能与灵活性。

## 存储过程

数据库系统原理之数据库编程

### 一、存储过程的基本概念

- 存储过程是一组为了完成某项特定功能的 SQL 语句集，其实质上就是一段存储在数据库中的代码，它可以由声明式的 SQL 语句（如 CREATE、UPDATE 和 SELECT 等语句）和过程式 SQL 语句（如 IF...THEN...ELSE 控制结构语句）组成。
- 这组语句集经过编译后会存储在数据库中，用户只需通过指定存储过程的名字并给定参数（如果该存储过程带有参数），即可随时调用并执行它，而不必重新编译，因此这种通过定义一段程序存储在数据库中的方式，可加大数据库操作语句的执行效率。
- 使用存储过程通常具有以下一些好处：
  - 可增强SQL语言的功能和灵活性
  - 良好的封装性
  - 高性能
  - 可减少网络流量
  - 存储过程可作为一种安全机制来确保数据库的安全性和数据的完整性

### 二、创建存储过程

DELIMITER 命令的使用语法格式是：

```sql
DELIMITER $$
```

- `$$` 是用户定义的结束符，通常这个符号可以是一些特殊的符号，例如两个“#”，或两个“￥”等
- 当使用 DELIMITER 命令时，应该避免使用反斜杠（“\”）字符，因为它是MySQL的转义字符

例子：将 MySQL 结束符修改为两个感叹号“!!”。

```sql
mysql> DELIMITER !!
```

换回默认的分行“;”

```sql
mysql> DELIMITER ;
```

创建存储过程

```sql
CREATE PROCEDURE sp_name ([proc_parameter[,...]])
 routine_body
```

"proc_parameter" 的语法格式：

```sql
[IN | OUT | INOUT] param_name type

# 参数的取名不要与数据表的列名相同
```

- 语法项“routine_body” 表示存储过程的主体部分，也称为存储过程体，其包含了在过程调用的时候必须执行的SQL语句。
- 这个部分以关键字“BEGIN” 开始，以关键字“END”结束。
- 如若存储过程体中只有一条 SQL语句时，可以省略 BEGIN...END 标志。
- 在存储过程体中，BEGIN...END 复合语句可以嵌套使用

例子：在数据库 mysql_test 中创建一个存储过程，用于实现给定表 customers 中一个客户 id 号即可修改表 customers 中该客户的性别为一个指定的性别。

```sql
➜ mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1850
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
mysql> delimiter $$
mysql> create procedure sp_update_sex(in cid int,in csex char(1))
    -> begin
    -> update customers set cust_sex=csex where cust_id=cid;
    -> end $$
Query OK, 0 rows affected (0.03 sec)

mysql>
```

### 三、存储过程体

#### 1 局部变量

- 用来存储存储过程体中的临时结果

```sql
DECLARE var_name[,...] type [DEFAULT value]
```

例子：声明一个整形局部变量 cid。

```sql
DECLARE cid INT(10);
```

- 局部变量只能在存储过程体的 BEGIN...END 语句块中声明
- 局部变量必须在存储过程体的开头出声明
- 局部变量的作用范围仅限于声明它的 BEGIN...END 语句块，其他语句块中的语句不可以使用它
- 局部变量不同于用户变量，两者的区别是：
  - 局部变量声明时，在其前面没有使用 @ 符号，并且它只能被声明它的 BEGIN...END 语句块中的语句所使用
  - 用户变量在声明时，会在其名称前面使用 @ 符号，同时已声明的用户变量存在于整个会话之中

#### 2 SET 语句

```sql
SET var_name = expr [, var_name = expr] ...
```

例子：为声明的局部变量 cid 赋予一个整数值 910

```sql
SET cid=910;
```

#### 3 SELECT...INTO 语句

- 把选定列的值直接存储到局部变量中

```sql
SELECT col_name [,...] INTO var_name[,...] table_expr
```

- 存储过程体中的 SELECT...INTO 语句返回的结果集只能有一行数据

#### 4 流程控制语句

##### （1）条件判断语句

- 常用的条件判断语句有 IF...THEN...ELSE 语句和 CASE 语句。
- 它们的使用语法及方式类似于高级程序设计语言。

##### （2）循环语句

- 常用的循环语句有 WHILE 语句、REPEAT 语句和 LOOP 语句。
- 它们的使用语法及方式同样类似于高级程序设计语言。
- 循环语句中还可以使用 ITERATE 语句，但它只能出现在循环语句的 LOOP、REPEAT 和 WHILE 子句中，用于表示退出当前循环，且重新开始一个循环。

#### 5 游标

- 在MySQL中，一条 SELECT...INTO 语句成功执行后，会返回带有值的一行数据，这行数据可以被读取到存储过程中进行处理。
- 然而，在使用 SELECT 语句进行数据检索时，若该语句成功被执行，则会返回一组称为结果集的数据行，该结果集中可能拥有多行数据，这些数据无法直接被一行一行地进行处理，此时就需要使用游标。
- 游标是一个被 SELECT 语句检索出来的结果集。
- 在存储了游标后，应用程序或用户就可以根据需要滚动或浏览其中的数据。

在MySQL中，使用游标的具体步骤如下：

##### （1）声明游标

```sql
DECLARE cursor_name CURSOR FOR select_statement
```

- 语法项“select_statement”用于指定一个 SELECT 语句，其会返回一行或多行的数据，且需注意此处的 SELECT 语句不能有 INTO 子句。

##### （2）打开游标

```sql
OPEN cursor_name
```

##### （3）读取数据

```sql
FETCH cursor_name INTO var_name [, var_name] ...
```

- 游标相当于一个指针，它指向当前的一行数据。

##### （4）关闭游标

```sql
CLOSE cursor_name
```

- 如果没有明确关闭游标，MySQL将会在到达 END 语句时自动关闭它。
- 在一个游标被关闭后，如果没有重新被打开，则不能被使用。
- 对于声明过的游标，则不需要再次声明，可直接使用 OPEN 语句打开。

例子：在数据库 mysql_test 中创建一个存储过程，用于计算表 customers 中数据行的行数。

首先，在MySQL命令行客户端输入如下 SQL语句创建存储过程 sq_sumofrow：

```sql
➜ mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2286
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
mysql> delimiter $$
mysql> create procedure sp_sumofrow(OUT ROWS INT)
    -> begin
    -> declare cid int;
    -> declare found boolean default true;
    -> declare cur_cid cursor for
    -> select cust_id from customers;
    -> declare continue handler for not found
    -> set found=false;
    -> set rows=0;
    -> open cur_cid;
    -> fetch cur_cid into cid;
    -> while found do
    -> set rows=rows+1;
    -> fetch cur_cid into cid;
    -> end while;
    -> close cur_cid;
    -> end$$
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'ROWS INT)
begin
declare cid int;
declare found boolean default true;
declare cur' at line 1
mysql>


mysql> CREATE PROCEDURE sp_sumofrow(OUT ROWS INT)
    -> BEGIN
    -> DECLARE cid INT;
    -> DECLARE FOUND BOOLEAN DEFAULT TRUE;
    -> DECLARE cur_cid CURSOR FOR
    -> SELECT cust_id FROM customers;
    -> DECLARE CONTINUE HANDLER FOR NOT FOUND
    -> SET FOUND=FALSE;
    -> SET ROWS=0;
    -> OPEN cur_cid;
    -> FETCH cur_cid INTO cid;
    -> WHILE FOUND DO
    -> SET ROWS=ROWS+1;
    -> FETCH cur_cid INTO cid;
    -> END WHILE;
    -> CLOSE cur_cid;
    -> END$$
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'ROWS INT)
BEGIN
DECLARE cid INT;
DECLARE FOUND BOOLEAN DEFAULT TRUE;
DECLARE cur' at line 1
mysql>


mysql> CREATE PROCEDURE sp_sumofrow(OUT `ROWS` INT) BEGIN DECLARE cid INT; DECLARE FOUND BOOLEAN DEFAULT TRUE; DECLARE cur_cid CURSOR FOR SELECT cust_id FROM customers; DECLARE CONTINUE HANDLER FOR NOT FOUND SET FOUND=FALSE; SET `ROWS`=0; OPEN cur_cid; FETCH cur_cid INTO cid; WHILE FOUND DO SET `ROWS`=`ROWS`+1; FETCH cur_cid INTO cid; END WHILE; CLOSE cur_cid; END$$
Query OK, 0 rows affected (0.01 sec)

mysql>
```

然后，在 MySQL 命令行客户端输入如下 SQL语句对存储过程 sp_sumofrow 进行调用：

```sql
mysql> call sp_sumofrow(@rows);
    ->
    ->
    -> $$
Query OK, 0 rows affected (0.01 sec)


mysql> delimiter ;
mysql> select @rows;
+-------+
| @rows |
+-------+
|     4 |
+-------+
1 row in set (0.00 sec)

mysql>
```

最后，查看调用存储过程 sp_sumofrow后的结果：

```sql
mysql> select @rows;
+-------+
| @rows |
+-------+
|     4 |
+-------+
1 row in set (0.00 sec)

mysql>
```

由此例可以看出：

- 定义了一个 CONTINUE HANDLER 句柄，它是在条件出现时被执行的代码，用于控制循环语句，以实现游标的下移
- DECLARE 语句的使用存在特定的次序，即用 DECLARE 语句定义的局部变量必须在定义任意游标或句柄之前定义，而句柄必须在游标之后定义，否则系统会出现错误信息。

在使用游标的过程中，需要注意以下几点：

- 游标只能用于存储过程或存储函数中，不能单独在查询操作中使用。
- 在存储过程或存储函数中可以定义多个游标，但是在一个 BEGIN...END 语句块中每一个游标的名字必须是唯一的。
- 游标不是一条 SELECT 语句，是被 SELECT 语句检索出来的结果集。

### 四、调用存储过程

```sql
CALL sp_name([parameter[,...]])
CALL sp_name[()]
```

- 当调用没有参数的存储过程时，使用 CALL sp_name() 语句与使用 CALL sp_name 语句是相同的。

例子：调用数据库 mysql_test 中的存储过程 sp_update_sex，将客户 id 号位 909 的客户性别修改为男性“M”。

```sql
mysql> call sp_update_sex(909,'M');
Query OK, 0 rows affected (0.00 sec)

mysql>

```

### 五、删除存储过程

```sql
DROP PROCEDURE [IF EXISTS] sp_name
```

例子：删除数据库 mysql_test 中的存储过程 sp_update_sex。

```sql
mysql> DROP PROCEDURE sp_update_sex;
Query OK, 0 rows affected (0.01 sec)

mysql>
```

## 第二节 存储函数

存储函数与存储过程的区别：

- 存储函数不能拥有输出参数，这是因为存储函数自身就是输出参数；而存储过程可以拥有输出参数。
- 可以直接对存储函数进行调用，且不需要使用 CALL 语句；而对存储过程的调用，需要使用 CALL 语句。
- 存储函数中必须包含一条 RETURN 语句，而这条特殊的SQL语句不允许包含于存储过程中。

### 一、创建存储函数

```sql
CREATE FUNCTION sp_name ([func_parameter[,...]])
 RETURNS type
 routine_body
```

其中，语法项“func_parameter”的语法格式是：

```sql
param_name type
```

- 存储函数不能与存储过程具有相同的名字。
- 存储函数体中还必须包含一个 RETURN value 语句，其中 value 用于指定存储函数的返回值。

例子：在数据库 mysql_test 中创建一个存储函数，要求该函数能根据给定的客户 id 号返回客户的性别，如果数据库中没有给定的 id 号，则返回“没有该客户”。

```sql
➜ mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 659
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
mysql> DELIMITER $$
mysql> CREATE FUNCTION fn_search(cid INT)
    -> RETURNS CHAR(2)
    -> DETERMINISTIC
    -> BEGIN
    -> DECLARE SEX CHAR(2);
    -> SELECT cust_sex INTO SEX FROM customers
    -> WHERE cust_id=cid;
    -> IF SEX IS NULL THEN
    -> RETURN(SELECT '没有该客户');
    -> ELSE IF SEX='F' THEN
    -> RETURN(SELECT '女');
    -> ELSE RETURN(SELECT '男');
    -> END IF;
    -> END IF;
    -> END $$
Query OK, 0 rows affected (0.02 sec)

mysql>

```

### 二、调用存储函数

```sql
SELECT sp_name ([func_parameter[,...]])
```

例子：调用数据库 mysql_test 中的存储函数 fn_search。

```sql
mysql> delimiter ;
mysql> SELECT fn_search(904);
+----------------+
| fn_search(904) |
+----------------+
| 男             |
+----------------+
1 row in set (0.00 sec)

mysql>
```

### 三、删除存储函数

```sql
DROP FUNCTION [IF EXISTS] sp_name
```

例子：删除数据库 mysql_test 中的存储函数 fn_search。

```sql
mysql> DROP FUNCTION IF EXISTS fn_search;
Query OK, 0 rows affected (0.00 sec)

mysql>
```

## 总结

通过本文的系统学习，我们不仅掌握了 MySQL 存储过程和存储函数的基本用法，更深入理解了如何利用局部变量、流程控制和游标等特性来高效处理复杂的数据逻辑。存储过程和存储函数的强大之处在于，它们能将业务逻辑下沉到数据库层，从而实现更高的性能、更强的封装性和更好的安全性。希望本文能帮助你将这些强大的数据库编程工具应用到实际项目中，开启数据库编程的新篇章。
