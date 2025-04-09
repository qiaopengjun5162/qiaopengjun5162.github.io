+++
title = "数据库系统原理之数据库安全与保护"
date = 2023-03-21T22:14:28+08:00
description = "数据库系统原理之数据库安全与保护"
[taxonomies]
tags = ["数据库", "MySQL"]
categories = ["数据库", "MySQL"]
+++

# ​​数据库安全与保护：关键技术解析与实践指南​​

数据库作为现代信息系统的核心，其安全性与数据完整性直接影响业务的稳定性和可靠性。本文系统阐述数据库保护的五大核心模块：通过完整性约束保障数据逻辑正确性，利用触发器实现自动化监控，借助权限管理控制访问风险，依托事务与锁机制解决并发冲突，并结合备份恢复策略应对意外故障。文章以MySQL为例，结合代码示例与原理分析，为开发者提供从设计到运维的全链路防护方案。

本文聚焦数据库安全防护体系，深入解析关键技术实现路径：

1. ​​完整性约束​​：通过列级、元组级、表级约束及主键/外键规则，确保数据语义正确与关联可靠，例如复合主键的最小化原则和外键的级联策略。
2. ​​触发器机制​​：演示BEFORE/AFTER事件触发器的创建与应用，如通过NEW虚拟表实现插入数据自动校验。
3. ​​访问控制​​：详解用户权限的精细化管控，包括账号生命周期管理（创建、授权、回收）及WITH GRANT OPTION权限传递限制。
4. ​​并发控制​​：基于ACID特性与两段锁协议，分析事务隔离级别对脏读、幻读的规避效果，并给出死锁检测的实践方案。
5. ​​备份恢复​​：使用SELECT INTO OUTFILE实现逻辑备份，结合LOCK TABLES确保备份一致性，通过LOAD DATA快速恢复数据。

## 数据库安全与保护

## 第一节 数据库完整性

- 数据库完整性是指数据库中数据的正确性和相容性。
- 数据完整性约束是为了防止数据库中存在不符合语义的数据，为了维护数据的完整性，DBMS 必须提供一种机制来检查数据库中的数据，以判断其是否满足语义规定的条件。
- 这些加在数据库数据之上的语义约束条件就是数据完整性约束。
- DBMS 检查数据是否满足完整性约束条件的机制就称为完整性检查。

### 一、完整性约束条件的作用对象

- 完整性约束条件是完整性控制机制的核心。
- 完整性约束条件的作用对象可以是列、元组和表。

#### （1）列级约束

列级约束主要指对列的类型、取值范围、精度等的约束，具体包括如下内容：

- 对数据类型的约束，其包括数据类型、长度、精度等。
- 对数据格式的约束。
- 对取值范围或取值集合的约束。
- 对空值的约束。

#### （2）元组约束

元组约束指元组中各个字段之间的相互约束。

#### （3）表级约束

表级约束指若干元组之间、关系之间的联系的约束。

### 二、定义与实现完整性约束

#### 1 实体完整性

在MySQL中，实体完整性是通过主键约束和候选键约束来实现的。

##### （1）主键约束

主键可以是表中的某一列，也可以是表中多个列所构成的一个组合。

其中，由多个列组合而成的主键也称为复合主键。

在MySQL中，主键列必须遵守如下一些规则：

- 每一个表只能定义一个主键。
- 主键的值，也称为键值，必须能够唯一标志表中的每一行记录，且不能为NULL。也就是说，表中两个不同的行在主键上不能具有相同的值。这是唯一性原则。
- 复合主键不能包含不必要的多余列。也就是说，当从一个复合主键中删除一列后，如果剩下的列构成主键仍能满足唯一性原则，那么这个复合主键是不正确的。这是最小化原则。
- 一个列名在复合主键的列表中只能出现一次。

主键约束可以在 CREATE TABLE 或 ALTER TABLE 语句中使用关键字“PRIMARY KEY”来实现。

其方式有两种：

- 一种是作为列的完整性约束，此时只需在表中某个列的属性定义后加上关键字 “PRIMART KEY” 即可。
- 一种是作为表的完整性约束，需要再表中所有列的属性定义后添加一条 PRIMARY KEY(index_col_name, ...) 格式的子句。

注意：

如果主键仅由一个表中的某一列所构成，上述两种方法均可以定义主键约束。

如果主键是由表中多个列所构成的一个组合，则只能用上述第二种方法定义主键约束。

定义主键约束后，MySQL 会自动为主键创建一个唯一性索引，用于在查询中使用主键对数据进行快速检索，该索引名默认为 PRIMARY，也可以重新自定义命名。

##### （2）候选键约束

任何时候，候选键的值必须是唯一的，且不能为 NULL。

候选键可以在 CREATE TABLE 或 ALTER TABLE 语句中使用关键字“UNIQUE”来定义，其实现方法与主键约束相似，同样可作为列或者表（关系）的完整性约束两种方式。

MySQL中候选键与主键之间存在以下几点区别：

- 一个表中只能创建一个主键，但可以定义若干个候选键。
- 定义主键约束时，系统会自动产生 PRIMARY KEY 索引，而定义候选键约束时，系统会自动产生 UNIQUE 索引。

#### 2 参照完整性

外键声明的方式：

- 在表中某个列的属性定义后直接加上”reference_definition“语法项。
- 在表中所有列的属性定义后添加”FOREIGN KEY (index_col_name, ...) reference_definition“ 子句的语法项。

"reference_definition" 语法项的定义：

```sql
REFERENCES tbl_name (index_col_name, ...)
 [ON DELETE reference_option]
 [ON UPDATE reference_option]
```

`index_col_name` 的语法格式：

```sql
col_name [(length)] [ASC | DESC]
```

`reference_option` 的语法格式：

```sql
RESTRICT | CASCADE | SET NULL | NO ACTION

限制策略    级联策略    置空策略    不采取实施策略
```

例子：在数据库 mysql_test 中创建一个商品订单表 orders，该表包含的订单信息有：订单号 oder_id、订购商品名 order_product、订购商品类型 order_product_type、订购客户 id 号 cust_id、订购时间 order_date、订购价格 order_price、订购数量 order_amount。要求商品订单表 orders 中的所有订购客户信息均已在表 customers 中记录在册。

```sql
mysql> use mysql_test;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> create table orders
    -> (
    -> order_id int not null auto_increment,
    -> order_product char(50) not null,
    -> order_product_type char(50) not null,
    -> cust_id int not null,
    -> order_date datetime not null,
    -> order_price double not null,
    -> order_amount int not null,
    -> primart key (order_id),
    -> foreign key (cust_id)
    -> references customers(cust_id)
    -> on delete restrict
    -> on update restrict
    -> );
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'key (order_id),
foreign key (cust_id)
references customers(cust_id)
on delete r' at line 10
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
6 rows in set (0.01 sec)

mysql> create table orders ( order_id int not null auto_increment, order_product char(50) not null, order_product_type char(50) not null, cust_id int not null, order_date datetime not null, order_price double not null, order_amount int not null, primary key (order_id), foreign key (cust_id)  references customers(cust_id) on delete restrict on update restrict );
Query OK, 0 rows affected (0.05 sec)

mysql> desc orders;
+--------------------+----------+------+-----+---------+----------------+
| Field              | Type     | Null | Key | Default | Extra          |
+--------------------+----------+------+-----+---------+----------------+
| order_id           | int      | NO   | PRI | NULL    | auto_increment |
| order_product      | char(50) | NO   |     | NULL    |                |
| order_product_type | char(50) | NO   |     | NULL    |                |
| cust_id            | int      | NO   | MUL | NULL    |                |
| order_date         | datetime | NO   |     | NULL    |                |
| order_price        | double   | NO   |     | NULL    |                |
| order_amount       | int      | NO   |     | NULL    |                |
+--------------------+----------+------+-----+---------+----------------+
7 rows in set (0.00 sec)

mysql>
```

当指定一个外键时，需要遵守下列原则：

- 被参照表必须已经用一条 CREATE TABLE 语句创建了，或者必须是当前正在创建的表。
  - 如若是后一种情形，则被参照表与参照表是同一个表，这样的表称为自参照表(self-referencing table)，这种结构称为自参照完整性(self-referential integrity)。
- 必须为被参照表定义主键。
- 必须在被参照表的表名后面指定列名或列名的组合。
  - 这个列或列组合必须是这个被参照表的主键或候选键。
- 尽管主键是不能够包含空值的，但允许在外键中出现一个空值。
  - 这意味着，只要外键的每个非空值出现在指定的主键中，这个外键的内容就是正确的。
- 外键中的列的数目必须和被参照表的主键中的列的数目相同。
- 外键中的列的数据类型必须和被参照表的主键中的对应列的数据类型相同。

#### 3 用户定义的完整性

- 非空约束
  - NOT NULL
- CHECK 约束
  - `CHECK (expr)`
  - 基于列的 CHECK 约束
  - 基于表的 CHECK 约束
- 触发器

### 三、命名完整性约束

```sql
CONSTRAINT [symbol]
```

- 只能给基于表的完整性约束指定名字，而无法给基于列的完整性约束指定名字

### 四、更新完整性约束

添加约束：ALTER TABLE 语句中使用 ADD CONSTRAINT子句

- 完整性约束不能直接被修改。
  - 若要修改某个约束，实际上是用 ALTER TABLE 语句先删除该约束，然后再增加一个与该约束同名的新约束
- 使用 ALTER TABLE 语句，可以独立地删除完整性约束，而不会删除表本身。
  - 若使用 DROP TABLE 语句删除一个表，则表中所有的完整性约束都会自动被删除。

## 第二节 触发器

触发器（Trigger）是用户定义在关系表上的一类由事件驱动的数据库对象，也是一种保证数据完整性的方法。

触发器一旦定义，无须用户调用，任何对表的修改操作均由数据库服务器自动激活相应的触发器。

### 一、创建触发器

```sql
CREATE TRIGGER trigger_name trigger_time trigger_event
 ON tbl_name FOR EACH ROW trigger_body
```

- trigger_time
  - BEFORE
  - AFTER
- trigger_event
  - INSERT
  - UPDATE
  - DELETE
- tbl_name
  - 用于指定与触发器相关联的表名，必须引用永久性表
  - 不能将触发器与临时表或视图关联起来
  - 同一个表不能拥有两个具有相同触发时刻和事件的触发器
- 在触发器的创建中，每个表每个事件每次只允许一个触发器
- 每个表最多支持6个触发器，即每条 INSERT、UPDATE 和 DELETE 的“之前”与“之后”
- 单一触发器不能与多个事件或多个表关联

例子：在数据库 mysql_test 的表 customers 中创建一个触发器 customers_insert_trigger，用于每次向表 customers 插入一行数据时，将用户变量 str 的值设置为 “one customer added!”。

```sql
mysql> use mysql_test;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> create trigger mysql_test.customers_insert_trigger after insert
    -> on mysql_test.customers for each row set @str='one customer added!';
Query OK, 0 rows affected (0.02 sec)

mysql> insert into mysql_test.customers
    -> values(null,'万华','F','长沙市','芙蓉区');
ERROR 1136 (21S01): Column count doesn't match value count at row 1
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
6 rows in set (0.01 sec)

mysql> alter table mysql_test.customers drop column cust_contact;
Query OK, 0 rows affected (0.03 sec)
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
+--------------+----------+------+-----+---------+----------------+
5 rows in set (0.01 sec)

mysql> insert into mysql_test.customers values(null,'万华','F','长沙市','芙蓉区');
Query OK, 1 row affected (0.00 sec)

mysql> select @str;
+---------------------+
| @str                |
+---------------------+
| one customer added! |
+---------------------+
1 row in set (0.00 sec)

mysql>
```

### 二、删除触发器

```sql
DROP TRIGGER [IF EXISTS] [schema_name.] trigger_name
```

例子：删除数据库 mysql_test 中的触发器 customers_insert_trigger。

```sql
mysql> drop trigger if exists mysql_test.customers_insert_trigger;
Query OK, 0 rows affected (0.00 sec)

mysql>
```

- 当删除一个表的同时，也会自动地删除该表上的触发器，且触发器不能更新或覆盖，为了修改一个触发器，必须先删除它，然后再重新创建。

### 三、使用触发器

#### 1 INSERT 触发器

- 在 INSERT 触发器代码内，可引用一个名为 NEW（不区分大小写）的虚拟表，来访问被插入的行。
- 在 BEFORE INSERT 触发器中，NEW 中的值也可以被更新，即允许更改被插入的值（只要具有对应的操作权限）。
- 对于 AUTO_INCREMENT 列，NEW 在 INSERT 执行之前包含的是0值，在 INSERT 执行之后将包含新的自动生成值。

例子：在数据库 mysql_test 的表 customers 中重新创建触发器 customers_insert_trigger，用于每次向表 customers插入一行数据时，将用户变量 str 的值设置为新插入客户的 id 号。

```sql
mysql> create trigger mysql_test.customers_insert_trigger after insert
    -> on mysql_test.customers for each row set @str=new.cust_id;
Query OK, 0 rows affected (0.00 sec)

mysql> insert into mysql_test.customers values(null,'曾伟','F','长沙市','芙蓉区');
Query OK, 1 row affected (0.00 sec)

mysql> select @str;
+------+
| @str |
+------+
|  911 |
+------+
1 row in set (0.00 sec)

mysql> select * from customers;
+---------+-----------+----------+-----------+--------------+
| cust_id | cust_name | cust_sex | cust_city | cust_address |
+---------+-----------+----------+-----------+--------------+
|     901 | 张三      | F        | 北京市    | 武汉市       |
|     902 | 李四      | M        | 武汉市    | 上海市       |
|     903 | 李四      | M        | Beijing   | 上海市       |
|     904 | 李四      | M        | Beijing   | 上海市       |
|     910 | 万华      | F        | 长沙市    | 芙蓉区       |
|     911 | 曾伟      | F        | 长沙市    | 芙蓉区       |
+---------+-----------+----------+-----------+--------------+
6 rows in set (0.00 sec)

mysql>
```

#### 2 DELETE 触发器

- 在 DELETE 触发器代码内，可以引用一个名为 OLD（不区分大小写）的虚拟表，来访问被删除的表。
- OLD 中的值全部是只读的，不能被更新。

#### 3 UPDATE 触发器

- 在 UPDATE 触发器代码内，可以引用一个名为 OLD（不区分大小写）的虚拟表访问以前（UPDATE 语句执行前）的值，也可以引用一个名为 NEW（不区分大小写）的虚拟表访问新更新的值。
- 在 BEFORE UPDATE 触发器中，NEW 中的值可能也被更新，即允许更改将要用于 UPDATE 语句中的值（只要具有对应的操作权限）。
- OLD 中的值全部是只读的，不能被更新。
- 当触发器涉及对触发表自身的更新操作时，只能使用 BEFORE UPDATE 触发器，而 AFTER UPDATE 触发器将不被允许。

例子：在数据库 mysql_test 的表 customers 中创建一个触发器 customers_update_trigger，用于每次更新表 customers时，将该表中 cust_address 列的值设置为 cust_contact 列的值。

```sql
mysql> create trigger mysql_test.customers_update_trigger before update
    -> on mysql_test.customers for each row
    -> set new.cust_address=old.cust_contact;
ERROR 1054 (42S22): Unknown column 'cust_contact' in 'OLD'
mysql> alter table mysql_test.customers
    -> add column cust_contact char(50) null;
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> create trigger mysql_test.customers_update_trigger before update on mysql_test.customers for each row set new.cust_address=old.cust_contact;
Query OK, 0 rows affected (0.01 sec)

mysql> update mysql_test.customers set cust_address='武汉市' where cust_name='曾伟';
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select cust_address from mysql_test.customers where cust_name='曾伟';
+--------------+
| cust_address |
+--------------+
| NULL         |
+--------------+
1 row in set (0.00 sec)

mysql> select * from customers;
+---------+-----------+----------+-----------+--------------+--------------+
| cust_id | cust_name | cust_sex | cust_city | cust_address | cust_contact |
+---------+-----------+----------+-----------+--------------+--------------+
|     901 | 张三      | F        | 北京市    | 武汉市       | NULL         |
|     902 | 李四      | M        | 武汉市    | 上海市       | NULL         |
|     903 | 李四      | M        | Beijing   | 上海市       | NULL         |
|     904 | 李四      | M        | Beijing   | 上海市       | NULL         |
|     910 | 万华      | F        | 长沙市    | 芙蓉区       | NULL         |
|     911 | 曾伟      | F        | 长沙市    | NULL         | NULL         |
+---------+-----------+----------+-----------+--------------+--------------+
6 rows in set (0.00 sec)

mysql>

```

## 第三节 安全性与访问控制

### 一、用户账号管理

查看MySQL数据库的使用者账号

```sql
mysql> select user from mysql.user;
+------------------+
| user             |
+------------------+
| root             |
| mysql.infoschema |
| mysql.session    |
| mysql.sys        |
+------------------+
4 rows in set (0.01 sec)

```

#### 1 创建用户账号

```sql
CREATE USER user[IDENTIFIED BY [PASSWORD] 'password']
```

- "user" 格式：'user_name'@'host_name'
- 没指定主机名，则主机名会默认为是"%"，其表示一组主机

例子：在MySQL服务器中添加两个新的用户，其用户名分别为 zhangsan 和 lisi，他们的主机名均为 localhost，用户  zhangsan的口令设置为明文 123，用户 lisi的口令设置为对明文456使用 PASSWORD()函数加密返回的散列值。

```sql
# 查看 mysql 初始的密码策略
mysql> show variables like 'validate_password%';
+--------------------------------------+--------+
| Variable_name                        | Value  |
+--------------------------------------+--------+
| validate_password.check_user_name    | ON     |
| validate_password.dictionary_file    |        |
| validate_password.length             | 8      |
| validate_password.mixed_case_count   | 1      |
| validate_password.number_count       | 1      |
| validate_password.policy             | MEDIUM |
| validate_password.special_char_count | 1      |
+--------------------------------------+--------+
7 rows in set (0.01 sec)

# 设置密码的验证强度等级，设置 validate_password_policy 的全局参数为 LOW 
mysql> set global validate_password.policy=LOW;
Query OK, 0 rows affected (0.01 sec)


mysql>  create user 'zhangsan'@'localhost' identified by '12345678';
Query OK, 0 rows affected (0.01 sec)

mysql> select md5(12345678);  # MySQL 8.0+以上版本 password() 不可用
+----------------------------------+
| md5(12345678)                    |
+----------------------------------+
| 25d55ad283aa400af464c76d713c07ad |
+----------------------------------+
1 row in set (0.00 sec)

mysql> create user 'lisi'@'localhost' identified by '12345678';
Query OK, 0 rows affected (0.00 sec)

mysql>
```

官网：<https://dev.mysql.com/doc/refman/8.0/en/create-user.html>

```sql
CREATE USER
  'jeffrey'@'localhost' IDENTIFIED WITH mysql_native_password
                                   BY 'new_password1',
  'jeanne'@'localhost' IDENTIFIED WITH caching_sha2_password
                                  BY 'new_password2'
  REQUIRE X509 WITH MAX_QUERIES_PER_HOUR 60
  PASSWORD HISTORY 5
  ACCOUNT LOCK;
```

- 要使用 CREATE USER 语句，必须拥有 MySQL 中 mysql 数据库的 INSERT 权限或全局 CREATE USER 权限。
- 使用 CREATE USER 语句创建一个用户账号后，会在系统自身的mysql数据库的user表中添加一条新记录。如果创建的账户已经存在，则语句执行会出现错误。
- 如果两个用户具有相同的用户名和不同的主机名，MySQL会将他们视为不同的用户，并允许为这两个用户分配不同的权限集合。
- 如果在 CREATE USER 语句的使用中，没有为用户指定口令，那么MySQL允许该用户可以不使用口令登录系统，然而从安全的角度而言，不推荐这种做法。
- 新创建的用户拥有的权限很少。

#### 2 删除用户

```sql
DROP USER user [,user]...
```

例子：删除lisi用户

```sql
mysql> drop user lisi;
ERROR 1396 (HY000): Operation DROP USER failed for 'lisi'@'%'
mysql> drop user lisi@localhost;
Query OK, 0 rows affected (0.00 sec)

mysql>
```

- DROP USER 语句可用于删除一个或多个MySQL账户，并消除其权限。
- 要使用DROP USER 语句，必须拥有MySQL中mysql数据库的DELETE权限或全局 CREATE USER 权限。
- 在 DROP USER 语句的使用中，如果没有明确地给出账户的主机名，则该主机名会默认为是 %。
- 用户的删除不会影响到他们之前所创建的表、索引或其他数据库对象，这是因为MySQL并没有记录是谁创建了这些对象。

#### 3 修改用户账号

```sql
RENAME USER old_user TO new_user [, old_user TO new_user] ...
```

例子：将用户 zhangsan 的名字修改成 wangwu

```sql
mysql> rename user 'zhangsan'@'localhost' to 'wangwu'@'localhost';
Query OK, 0 rows affected (0.00 sec)

mysql>

```

- RENAME USER 语句用于对原有MySQL账户进行重命名。
- 要使用 RENAME USER 语句，必须拥有MySQL中mysql数据库的UPDATE权限或全局CREATE USER 权限。
- 倘若系统中旧账户不存在或者新账户已存在，则语句执行会出现错误。

#### 4 修改用户口令

```sql
SET PASSWORD [FOR user] =
 {
 PASSWORD('new_password') | 'encrypted password'
 }
```

例子：

```sql
mysql> set password for 'wangwu'@'localhost' = '88888888';
Query OK, 0 rows affected (0.00 sec)

mysql>
```

### 二、账户权限管理

```sql
mysql> select user from mysql.user;
+------------------+
| user             |
+------------------+
| root             |
| mysql.infoschema |
| mysql.session    |
| mysql.sys        |
| wangwu           |
+------------------+
5 rows in set (0.00 sec)

mysql> show grants for 'wangwu'@'localhost';
+--------------------------------------------+
| Grants for wangwu@localhost                |
+--------------------------------------------+
| GRANT USAGE ON *.* TO `wangwu`@`localhost` |
+--------------------------------------------+
1 row in set (0.01 sec)

mysql>
```

#### 1 权限的授予

```sql
GRANT
 priv_type [(column_list)]
  [, priv_type [(column_list)]] ...
  ON [object_type] priv_level
  TO user_specification [, user_specification] ...
  [WITH GRANT OPTION]
```

- “priv_level”：用于指定权限的级别
  - "*" 表示当前数据库中的所有表
  - "`*.*`" 表示所有数据库中的所有表
  - "db_name.*" 表示某个数据库中的所有表
- 如果权限被授予给一个不存在的用户，MySQL会自动执行一条 CREATE USER 语句来创建这个用户，但同时必须为该用户指定口令。
- "user_specification" 是 TO 子句中的具体描述部分
  - `user[IDENTIFIED BY [PASSWORD] 'password']`

例子：授予用户 zhangsan 在数据库 mysql_test 的表 customers 上拥有对列 cust_id 和列 cust_name 的 SELECT 权限

```sql
➜ mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1105
Server version: 8.0.32 Homebrew

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> grant select (cust_id, cust_name) on mysql_test.customers to 'zhangsan'@'localhost';
ERROR 1410 (42000): You are not allowed to create a user with GRANT
mysql> select user from mysql.user;
+------------------+
| user             |
+------------------+
| root             |
| mysql.infoschema |
| mysql.session    |
| mysql.sys        |
| wangwu           |
+------------------+
5 rows in set (0.00 sec)

mysql> rename user 'wangwu'@'localhost' to 'zhangsan'@'localhost';
Query OK, 0 rows affected (0.01 sec)

mysql> grant select (cust_id, cust_name) on mysql_test.customers to 'zhangsan'@'localhost';
Query OK, 0 rows affected (0.01 sec)


➜ mysql -uzhangsan -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1107
Server version: 8.0.32 Homebrew

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> select * from mysql_test.customers;
ERROR 1142 (42000): SELECT command denied to user 'zhangsan'@'localhost' for table 'customers'
mysql> select cust_id,cust_name from mysql_test.customers;
+---------+-----------+
| cust_id | cust_name |
+---------+-----------+
|     901 | 张三      |
|     902 | 李四      |
|     903 | 李四      |
|     904 | 李四      |
|     910 | 万华      |
|     911 | 曾伟      |
+---------+-----------+
6 rows in set (0.00 sec)

```

例子2：创建 liming 和 huang 两个用户，并设置对应的系统登录口令，同时授予他们在数据库 mysql_test 的表 customers 上拥有 SELECT 和 UPDATE 的权限。

```sql
mysql> grant select, update on mysql_test.customers to 'liming'@'localhost';
ERROR 1410 (42000): You are not allowed to create a user with GRANT 
# mysql 8 最新的MySQL8不允许直接创建并授权，必须先让自己有GRANT权限，然后创建用户，再授权。

mysql> SELECT host,user,Grant_priv,Super_priv FROM mysql.user;
+-----------+------------------+------------+------------+
| host      | user             | Grant_priv | Super_priv |
+-----------+------------------+------------+------------+
| %         | root             | Y          | Y          |
| localhost | mysql.infoschema | N          | N          |
| localhost | mysql.session    | N          | Y          |
| localhost | mysql.sys        | N          | N          |
| localhost | zhangsan         | N          | N          |
+-----------+------------------+------------+------------+
5 rows in set (0.00 sec)

mysql>

```

例子3：授予zhangsan 可以在数据库 mysql_test 中执行所有数据库操作的权限

```sql
mysql> grant all on mysql_test.* to 'zhangsan'@'localhost';
Query OK, 0 rows affected (0.01 sec)
```

例子4：授予 zhangsan 创建用户的权限

```sql
mysql> grant create user on *.* to 'zhangsan'@'localhost';
Query OK, 0 rows affected (0.01 sec)

mysql>
```

"priv_type"  的使用

- 授予表权限时，可以指定为以下值
  - SELECT
  - INSERT
  - DELETE
  - UPDATE
  - REFERENCES
  - CREATE
  - ALTER
  - INDEX
  - DROP
  - ALL 或 ALL PRIVILEGES
- 授予列权限时：
  - SELECT
  - INSERT
  - UPDATE
  - 权限的后面需要加上列名列表 column_list
- 授予数据库权限时：
  - SELECT
  - INSERT
  - DELETE
  - UPDATE
  - REFERENCES
  - CREATE
  - ALTER
  - INDEX
  - DROP
  - CREATE TEMPORARY TABLES
  - CREATE VIEW
  - SHOW VIEW
  - CREATE ROUTINE
  - ALTER ROUTINE
  - EXECUTE ROUTINE
  - LOCK TABLES
  - ALL 或 ALL PRIVILEGES
- 授予用户权限时：
  - 授予数据库权限时的所有值
  - CREATE USER
  - SHOW DATABASES

#### 2 权限的转移

- 权限的转移可以通过在 GRANT 语句中使用 WITH 子句来实现。
- 如果将 WITH 子句指定为关键字 "WITH GRANT OPTION"，则表示 TO 子句中所指定的所有用户都具有把自己所拥有授予给其他用户的权利，而无论那些其他用户是否拥有该权限。

例子：

```sql
~
➜ mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1173
Server version: 8.0.32 Homebrew

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> grant select,update on mysql_test.customers to 'zhou'@'localhost' identified by '123' with grant option;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'identified by '123' with grant option' at line 1
# mysql 8.0+ 报错　先创建用户　后授权


mysql> create user 'zhou'@'localhost' identified by '12345678';
Query OK, 0 rows affected (0.01 sec)

mysql> grant select,update on mysql_test.customers to 'zhou'@'localhost' identified by '12345678' with grant option;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'identified by '12345678' with grant option' at line 1

mysql> grant select,update on mysql_test.customers to 'zhou'@'localhost'  with grant option;
Query OK, 0 rows affected (0.01 sec)

mysql>

```

#### ３权限的撤销

- 当需要回收某些特定的权限时

```sql
REVOKE
 priv_type [(column_list)]
  [, priv_type [(column_list)]] ...
  ON [object_type] priv_level
  FROM user [, user] ...
```

- 当需要回收特定用户的所有权限时

```sql
REVOKE ALL PRIVILEGES, GRANT OPTION FROM user [, user]... 
```

例子：

```sql
mysql> revoke select on mysql_test.customers from 'zhou'@'localhost';
Query OK, 0 rows affected (0.00 sec)

mysql>

```

- 要使用 REVOKE 语句，必须拥有 mysql 数据库的全局 CREATE USER 权限或 UPDATE 权限

## 第四节 事物与并发控制

事务就是为保证数据的一致性而产生的一个概念和基本手段

### 一、事务的概念

- 所谓事务是用户定义的一个数据操作序列，这些操作可作为一个完整的工作单元，要么全部执行，要么全部不执行，是一个不可分割的工作单位。
- 事务与程序的区别：
  - 程序是静止的
  - 事务是动态的，是程序的执行而不是程序本身
  - 同一程序的多个独立执行可以同时进行，而每一步执行则是一个不同的事务

### 二、事务的特征 ACID

- 原子性（Atomicity）
  - 事务是不可分割的最小工作单位，所包含的这些操作是一个整体
  - 要么全做，要么全不做
- 一致性（Consistency）
  - 完整性约束
- 隔离性（Isolation）
  - 事务彼此独立的、隔离的
  - 可串行性 串行调度
- 持续性（Durability）
  - 永久性（Permanence）

例子：依据事物的ACID特性，分析并编写银行数据库系统中的转账事务T：从账户A转账S金额资金到账户B。

```sql
BEGIN TRANSACTION
 read(A);
 A=A-S;
 write(A);
 if(A<0) ROLLBACK
 else {
 read(B);
 B=B+S
 write(B);
 COMMIT;
 }
```

#### 三、并发操作问题

事务是并发控制的基本单位，保证事务的ACID特征是事务处理的重要任务，而事务的ACID特征可能遭到破坏的原因之一是多个事务对数据库的并发操作造成的。

完整性检验可以保证一个事务单独执行时，若输入的数据库状态是正确的，则其输出的数据库状态也是正确的。

当多个事务交错执行时，可能出现不一致问题，这也称为并发操作问题。

（1）丢失更新

（2）不可重复读

（3）读“脏”数据

并发控制机制就是用正确的方式调度并发操作，使一个用户事务的执行不受其他事务的干扰，从而避免造成数据的不一致性。

解决并发操作所带来的数据不一致性问题的方法有封锁、时间戳、乐观控制法和多版本并发控制等。

#### 四、封锁

##### 1 锁

- 一个锁实质上就是允许或阻止一个事务对一个数据对象的存取特权。
- 基本的封锁类型有两种：
  - 排他锁（Exclusive Look，X锁）  写操作
  - 共享锁（Shared Lock，S锁）   读操作

##### 2 用封锁进行并发控制

封锁的工作原理如下：

- 若事务T对数据D加了X锁，则所有别的事务对数据D的锁请求都必须等待直到事务T释放锁。
- 若事务T对数据D加了S锁，则别的事务还可对数据D请求S锁，而对数据D的X锁请求必须等待直到事务T释放锁
- 事务执行数据库操作时都要先请求相应的锁，即对读请求S锁，对更新（插入、删除、修改）请求X锁。这个过程一般是由DBMS在执行操作时自动隐含地进行。
- 事务一直占有获得的锁直到结束（COMMIT 或 ROLLBACK）时释放。

##### 3 封锁的粒度

通常由粒度来描述封锁的数据单元的大小。

大多数高性能系统都选择折中的锁粒度，至于哪一层最合适，则与应用环境下事务量、数据量及数据的易变特征等都紧密相关。

##### 4 封锁的级别

封锁的级别又称为一致性级别或隔离度。

- 0级封锁：封锁的事物不重写其他非0级封锁事务的未提交的更新数据。这种状态实际上实用价值不大。
- 1级封锁：被封锁的实物不允许重写未提交的更新数据。这防止了丢失更新的发生。
- 2级封锁：被封锁的事物即不重写也不读未提交的更新数据。这除了1级封锁的效果外还防止了读脏数据。
- 3级封锁：被封锁的事物不读未提交的更新数据，不写任何（包括读操作）未提交数据。
  - 这除了包含2级封锁外，还不写未提交的读数据，因而防止了不可重读的问题。
  - 这是严格的封锁，它保证了多个事务并发执行的“可串行化”。

##### 5 活锁与死锁

封锁带来的一个重要问题是可能引起“活锁”与“死锁”。

在并发事务处理过程中，由于锁会使一事务处于等待状态而调度其他事务处理，因而该事务可能会因优先级低而永远等待下去，这种现象称为“活锁”。

活锁问题的解决与调度算法有关，一种最简单的办法是“先来先服务”。

两个以上事务循环等待被同组中另一事务锁住的数据单元的情形，称为“死锁”。

在任何一个多任务程序设计系统中，死锁总是潜在的，所以在这种环境下的DBMS需要提供死锁预防、死锁检测和死锁发生后的处理技术与方法。

预防死锁的方法：

- 一次性锁请求
- 锁请求排序
- 序列化处理
- 资源剥夺

对待死锁的另一种办法是不去防止，而让其发生并随时进行检测，一旦检测到系统已发生了死锁再进行解除处理。

死锁检测可以用图论的方法实现，并以正在执行的事物为结点。

##### 6 可串行性

若一个调度等价于某一串行高度，即它所产生的结果与某一串行调度的结果一样，则说调度是可串行化的（Serializable）。

一组事务的串行调度不是唯一的，因而可串行化的调度也不是唯一的。

通常，在数据库系统中，可串行性就是并发执行的正确性准则，即当且仅当一组事务的并发执行调度是可串行化的，才认为它们是正确的。

##### 7 两段封锁法

采用两段封锁法（Two-Phase Locking，2PL）是一种最简单而有效的保障封锁其调度是可串行性的方法。

两段封锁法是事务遵循两段锁协议的调度方法。

协议就是所有事务都必须遵循的关于基本操作执行顺序的一种限制。

两段锁协议规定在任何一个事务中，所有加锁操作都必须在所有释放锁操作之前。

事务划分成如下两个阶段：

- 发展（Growing）或加锁阶段
- 收缩（Shrinking）或释放锁阶段

定理6.1：遵循两段锁协议的事务的任何并发调度都是可串行化的。

2PL 是可串行化的充分条件，不是必要条件，即存在不全是2PL的事务的可串行化调度。

## 第五节 备份与恢复

数据库的实际使用过程中，存在着一些不可预估的因素：

- 计算机硬件故障
- 计算机软件故障
- 病毒
- 人为操作
- 自然灾害
- 盗窃

数据库备份是指通过导出数据或者复制表文件的方式来制作数据库的复本

数据库恢复则是当数据库出现故障或遭到破坏时，将备份的数据库加载到系统，从而使数据库从错误状态恢复到备份时的正确状态。

数据库的恢复是以备份为基础的。它是与备份相对应的系统维护和管理操作。

### 1 使用 SELECT INTO...OUTFILE 语句备份数据

```sql
SELECT * INTO OUTFILE 'file_name' export_options
 | INTO DUMPFILE 'file_name'
```

其中，语法项“export_options” 的格式是：

```sql
[FIELDS 
 [TERMINATED BY 'string']
 [[OPTIONALLY] ENCLOSED BY 'char']
 [ESCAPED BY 'char']
]
[LINES TERMINATED BY 'string']
```

- 在文件中，导出的数据行会以一定的形式存储，其中空值是用"\N" 表示。

### 2 使用 LOAD DATA...INFILE 语句恢复数据

```sql
LOAD DATA INFILE 'file_name.txt'
 INTO TABLE tbl_name
 [FIELDS
   [TERMINATED BY 'string']
   [[OPTIONALLY] ENCLOSED BY 'char']
   [ESCAPED BY 'char']
  ]
  [LINES
   [STARTING BY 'string']
   [TERMINATED BY 'string']
  ]
```

例子：备份数据库mysql_test中表customers的全部数据。

```sql
➜ mysql -uroot -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2354
Server version: 8.0.32 Homebrew

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> select * from mysql_test.customers
    -> into outfile '/Users/qiaopengjun/backupfile.txt'
    -> fields terminated by ','
    -> optionally enclosed by ""
    -> lines terminated by '?';
ERROR 1290 (HY000): The MySQL server is running with the --secure-file-priv option so it cannot execute this statement
mysql> show variables like '%secure_file_priv%';
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| secure_file_priv | NULL  |
+------------------+-------+
1 row in set (0.01 sec)

mysql> show global variables like "%datadir%";
+---------------+--------------------------+
| Variable_name | Value                    |
+---------------+--------------------------+
| datadir       | /opt/homebrew/var/mysql/ |
+---------------+--------------------------+
1 row in set (0.02 sec)

mysql> select * from mysql_test.customers into outfile '/Users/qiaopengjun/backupfile.txt' fields terminated by ',' optionally enclosed by "" lines terminated by '?';
ERROR 2013 (HY000): Lost connection to MySQL server during query
No connection. Trying to reconnect...
Connection id:    8
Current database: *** NONE ***

Query OK, 6 rows affected (0.02 sec)

mysql> show variables like '%secure%';
+--------------------------+---------------------+
| Variable_name            | Value               |
+--------------------------+---------------------+
| require_secure_transport | OFF                 |
| secure_file_priv         | /Users/qiaopengjun/ |
+--------------------------+---------------------+
2 rows in set (0.01 sec)

mysql>

mysql> select * from mysql_test.customers into outfile '/Users/qiaopengjun/backupfile.txt' fields terminated by ',' optionally enclosed by "" lines terminated by '?';
Query OK, 6 rows affected (0.01 sec)

mysql>
```

mysql复制表的两种方式：

第一、只复制表结构到新表
create table 新表 select * from 旧表 where 1=2
或者
create table 新表 like 旧表

第二、复制表结构及数据到新表
create table新表 select * from 旧表

```bash
homebrew/var/mysql on  stable took 5.4s
➜ mysql --verbose --help | grep my.cnf
                      order of preference, my.cnf, $MYSQL_TCP_PORT,
/etc/my.cnf /etc/mysql/my.cnf /opt/homebrew/etc/my.cnf ~/.my.cnf

homebrew/var/mysql on  stable
➜

brew services restart mysql
```

将备份数据导入到一个和customers表结构相同的空表 customers_copy 中

```sql
mysql> create table customers_copy select * from customers where 1=2;
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> show tables;
+----------------------+
| Tables_in_mysql_test |
+----------------------+
| customers            |
| customers_copy       |
| customers_view       |
| orders               |
| seller               |
+----------------------+
5 rows in set (0.00 sec)

mysql> load data infile '/Users/qiaopengjun/backupfile.txt' into table mysql_test.customers_copy fields terminated by ',' optionally enclosed by "" lines terminated by '?';
Query OK, 6 rows affected (0.01 sec)
Records: 6  Deleted: 0  Skipped: 0  Warnings: 0

mysql> select * from customers_copy;
+---------+-----------+----------+-----------+--------------+--------------+
| cust_id | cust_name | cust_sex | cust_city | cust_address | cust_contact |
+---------+-----------+----------+-----------+--------------+--------------+
|     901 | 张三      | F        | 北京市    | 武汉市       | NULL         |
|     902 | 李四      | M        | 武汉市    | 上海市       | NULL         |
|     903 | 李四      | M        | Beijing   | 上海市       | NULL         |
|     904 | 李四      | M        | Beijing   | 上海市       | NULL         |
|     910 | 万华      | F        | 长沙市    | 芙蓉区       | NULL         |
|     911 | 曾伟      | F        | 长沙市    | NULL         | NULL         |
+---------+-----------+----------+-----------+--------------+--------------+
6 rows in set (0.00 sec)

mysql>

```

- 在多个用户同时使用MySQL数据库的情况下，为了得到一个一致的备份，需要在指定的表上使用 LOCK TABLES table_name READ 语句做一个读锁定，以防止在备份过程中表被其他用户更新。
- 当恢复数据时，则需要使用 LOCK TABLES table_name WRITE 语句做一个写锁定，以避免发生数据冲突。
- 在数据库备份或恢复完毕之后需要使用 UNLOCK TABLES 语句对该表进行解锁。

## 总结

数据库安全需通过多层次技术协同实现：完整性约束与触发器构成数据操作的前置校验层，权限管理构建访问控制的边界防护，事务机制保障并发场景下的数据一致性，备份策略则为灾难恢复提供兜底保障。开发实践中，建议遵循最小权限原则设计账号体系，对关键表启用行级锁减少并发冲突，并定期验证备份有效性。通过系统性防护策略，可显著降低数据泄露、逻辑错误及服务中断风险，为业务连续性提供坚实支撑。
