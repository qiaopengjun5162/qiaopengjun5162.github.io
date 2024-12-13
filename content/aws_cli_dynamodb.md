---
title: "AWS CLI DynamoDB"
date: 2023-09-01T18:09:43+08:00
lastmod: 2023-09-01T18:09:43+08:00 
draft: false
categories:
- AWS
tags:
- AWS
---

# AWS CLI DynamoDB 实操

## AWS CLI 安装



## DynamoDB 实操

![image-20230829230450833](../../../../../Library/Application Support/typora-user-images/image-20230829230450833.png)

### dynamodb 创建表

```shell
dynamodb create-table --table-name contact --attribute-definitions AttributeName=name,AttributeType=S AttributeName=email,AttributeType=S --key-schema AttributeName=name,KeyType=HASH AttributeName=email,KeyType=RANGE --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
```

### dynamodb 创建项目 添加数据

```shell
aws> dynamodb put-item --table-name contact --item '{"name":{"S":"xiao qiao"},"email":{"S":"qpj4812@gmail.com"}}' --return-consumed-capacity TOTAL
----------------------------------
|             PutItem            |
+--------------------------------+
||       ConsumedCapacity       ||
|+----------------+-------------+|
||  CapacityUnits |  TableName  ||
|+----------------+-------------+|
||  1.0           |  contact    ||
|+----------------+-------------+|
aws>

aws> dynamodb put-item --table-name contact --item '{"name":{"S":"lixia"},"email":{"S":"lixia4812@gmail.com"}}' --return-consumed-capacity TOTAL
----------------------------------
|             PutItem            |
+--------------------------------+
||       ConsumedCapacity       ||
|+----------------+-------------+|
||  CapacityUnits |  TableName  ||
|+----------------+-------------+|
||  1.0           |  contact    ||
|+----------------+-------------+|
aws>

```

### dynamodb 查看数据

```shell
aws> dynamodb list-tables
---------------
| ListTables  |
+-------------+
||TableNames ||
|+-----------+|
||  contact  ||
|+-----------+|
aws> dynamodb scan --table-name contact
-----------------------------------------------
|                    Scan                     |
+-------------------+--------+----------------+
| ConsumedCapacity  | Count  | ScannedCount   |
+-------------------+--------+----------------+
|  None             |  2     |  2             |
+-------------------+--------+----------------+
||                   Items                   ||
|||                  email                  |||
||+------+----------------------------------+||
|||  S   |  qpj4812@gmail.com               |||
||+------+----------------------------------+||
|||                  name                   |||
||+----------+------------------------------+||
|||  S       |  xiao qiao                   |||
||+----------+------------------------------+||
||                   Items                   ||
|||                  email                  |||
||+------+----------------------------------+||
|||  S   |  lixia4812@gmail.com             |||
||+------+----------------------------------+||
|||                  name                   |||
||+-------------+---------------------------+||
|||  S          |  lixia                    |||
||+-------------+---------------------------+||
aws>
```



## 如何创建并使用 AWS Cli 管理 ec2实例

https://us-east-2.console.aws.amazon.com/ec2/home?region=us-east-2#Home:

### 前置条件

密钥对

容量

安全组

### 1 创建一个密钥对

```shell
aws> ec2 create-key-pair --key-name kgptalkie --query 'KeyMaterial' --output text > kgptalkie.pem
aws>

```

![image-20230902170750838](assets/image-20230902170750838.png)

### 2 添加只读权限

```shell
~ via 🅒 base
➜ chmod 400 kgptalkie.pem

~ via 🅒 base
➜
```

### 3 描述密钥对

```shell
~ via 🅒 base
➜ aws-shell
aws> ec2 describe-key-pairs --key-names kgptalkie
------------------------------------------------------------------------------------------------------------------------------------------------
|                                                               DescribeKeyPairs                                                               |
+----------------------------------------------------------------------------------------------------------------------------------------------+
||                                                                  KeyPairs                                                                  ||
|+--------------------------+---------------------------------------------------------------+------------+------------------------+-----------+|
||        CreateTime        |                        KeyFingerprint                         |  KeyName   |       KeyPairId        |  KeyType  ||
|+--------------------------+---------------------------------------------------------------+------------+------------------------+-----------+|
||  2023-09-02T09:04:11.669Z|  5e:06:ea:24:2a:38:3b:c5:91:60:9b:db:8f:14:4f:f5:ae:c7:f2:c0  |  kgptalkie |  key-055dcede4aa2d400c |  rsa      ||
|+--------------------------+---------------------------------------------------------------+------------+------------------------+-----------+|
aws>


```

### 4 删除密钥对

```shell
aws> ec2 delete-key-pair --key-name kgptalkie
-------------------------------------
|           DeleteKeyPair           |
+------------------------+----------+
|        KeyPairId       | Return   |
+------------------------+----------+
|  key-055dcede4aa2d400c |  True    |
+------------------------+----------+
aws>

```

## 使用 Aws 创建安全组并更新

```shell
aws> ec2 create-security-group --group-name my-sg --description "my sg group" --vpc-id vpc-0202e1374ee1fbf85
-------------------------------------
|        CreateSecurityGroup        |
+----------+------------------------+
|  GroupId |  sg-02a39ddd15525edfb  |
+----------+------------------------+
aws>


```

### 添加ec2 实例入站规则（向安全组添加规则）

```shell
aws> ec2 authorize-security-group-ingress --group-id sg-02a39ddd15525edfb --protocol tcp --port 0-65535 --cidr 0.0.0.0/0
----------------------------------------------------------------------------------------------------------------------------------
|                                                  AuthorizeSecurityGroupIngress                                                 |
+----------------------------------------------------------------------+---------------------------------------------------------+
|  Return                                                              |  True                                                   |
+----------------------------------------------------------------------+---------------------------------------------------------+
||                                                      SecurityGroupRules                                                      ||
|+-----------+-----------+-----------------------+---------------+-------------+-----------+-------------------------+----------+|
|| CidrIpv4  | FromPort  |        GroupId        | GroupOwnerId  | IpProtocol  | IsEgress  |   SecurityGroupRuleId   | ToPort   ||
|+-----------+-----------+-----------------------+---------------+-------------+-----------+-------------------------+----------+|
||  0.0.0.0/0|  0        |  sg-02a39ddd15525edfb |  386159697246 |  tcp        |  False    |  sgr-0b8b4eb60a5f4671a  |  65535   ||
|+-----------+-----------+-----------------------+---------------+-------------+-----------+-------------------------+----------+|
aws>

```

![image-20230903110335120](assets/image-20230903110335120.png)

### 查询安全组描述

```shell
aws> ec2 describe-security-groups --group-ids sg-02a39ddd15525edfb
-------------------------------------------------------------------------------------------------
|                                    DescribeSecurityGroups                                     |
+-----------------------------------------------------------------------------------------------+
||                                       SecurityGroups                                        ||
|+-------------+------------------------+------------+---------------+-------------------------+|
|| Description |        GroupId         | GroupName  |    OwnerId    |          VpcId          ||
|+-------------+------------------------+------------+---------------+-------------------------+|
||  my sg group|  sg-02a39ddd15525edfb  |  my-sg     |  386159697246 |  vpc-0202e1374ee1fbf85  ||
|+-------------+------------------------+------------+---------------+-------------------------+|
|||                                       IpPermissions                                       |||
||+-----------------------------+-----------------------------------+-------------------------+||
|||          FromPort           |            IpProtocol             |         ToPort          |||
||+-----------------------------+-----------------------------------+-------------------------+||
|||  0                          |  tcp                              |  65535                  |||
||+-----------------------------+-----------------------------------+-------------------------+||
||||                                        IpRanges                                         ||||
|||+-----------------------------------------------------------------------------------------+|||
||||                                         CidrIp                                          ||||
|||+-----------------------------------------------------------------------------------------+|||
||||  0.0.0.0/0                                                                              ||||
|||+-----------------------------------------------------------------------------------------+|||
|||                                    IpPermissionsEgress                                    |||
||+-------------------------------------------------------------------------------------------+||
|||                                        IpProtocol                                         |||
||+-------------------------------------------------------------------------------------------+||
|||  -1                                                                                       |||
||+-------------------------------------------------------------------------------------------+||
||||                                        IpRanges                                         ||||
|||+-----------------------------------------------------------------------------------------+|||
||||                                         CidrIp                                          ||||
|||+-----------------------------------------------------------------------------------------+|||
||||  0.0.0.0/0                                                                              ||||
|||+-----------------------------------------------------------------------------------------+|||
aws>

```

## 创建 AWS EC2 实例

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/identify_ec2_instances.html

```shell
aws> ec2 run-instances --image-id ami-0cf0e376c672104d6 --count 1 --instance-type t2.micro --key-name kgptalkie --security-group-ids sg-02a39ddd15525edfb --subnet-id subnet-06ea29a210f12daa7

-----------------------------------------------------------------------------
|                               RunInstances                                |
+-------------------------------+-------------------------------------------+
|  OwnerId                      |  386159697246                             |
|  ReservationId                |  r-061539ad22b7e9c1e                      |
+-------------------------------+-------------------------------------------+
||                                Instances                                ||
|+--------------------------+----------------------------------------------+|
||  AmiLaunchIndex          |  0                                           ||
||  Architecture            |  x86_64                                      ||
||  BootMode                |  uefi-preferred                              ||
||  ClientToken             |  47d5bc44-90c8-4274-b92b-fcdfe1192230        ||
||  CurrentInstanceBootMode |  legacy-bios                                 ||
||  EbsOptimized            |  False                                       ||
||  EnaSupport              |  True                                        ||
||  Hypervisor              |  xen                                         ||
||  ImageId                 |  ami-0cf0e376c672104d6                       ||
||  InstanceId              |  i-01c751f6c8019edd3                         ||
||  InstanceType            |  t2.micro                                    ||
||  KeyName                 |  kgptalkie                                   ||
||  LaunchTime              |  2023-09-03T07:32:57.000Z                    ||
||  PrivateDnsName          |  ip-172-31-39-13.us-east-2.compute.internal  ||
||  PrivateIpAddress        |  172.31.39.13                                ||
||  PublicDnsName           |                                              ||
||  RootDeviceName          |  /dev/xvda                                   ||
||  RootDeviceType          |  ebs                                         ||
||  SourceDestCheck         |  True                                        ||
||  StateTransitionReason   |                                              ||
||  SubnetId                |  subnet-06ea29a210f12daa7                    ||
||  VirtualizationType      |  hvm                                         ||
||  VpcId                   |  vpc-0202e1374ee1fbf85                       ||
|+--------------------------+----------------------------------------------+|
|||                   CapacityReservationSpecification                    |||
||+---------------------------------------------------------+-------------+||
|||  CapacityReservationPreference                          |  open       |||
||+---------------------------------------------------------+-------------+||
|||                              CpuOptions                               |||
||+-------------------------------------------------------+---------------+||
|||  CoreCount                                            |  1            |||
|||  ThreadsPerCore                                       |  1            |||
||+-------------------------------------------------------+---------------+||
|||                            EnclaveOptions                             |||
||+--------------------------------------+--------------------------------+||
|||  Enabled                             |  False                         |||
||+--------------------------------------+--------------------------------+||
|||                          MaintenanceOptions                           |||
||+-----------------------------------------+-----------------------------+||
|||  AutoRecovery                           |  default                    |||
||+-----------------------------------------+-----------------------------+||
|||                            MetadataOptions                            |||
||+-------------------------------------------------+---------------------+||
|||  HttpEndpoint                                   |  enabled            |||
|||  HttpProtocolIpv6                               |  disabled           |||
|||  HttpPutResponseHopLimit                        |  2                  |||
|||  HttpTokens                                     |  required           |||
|||  InstanceMetadataTags                           |  disabled           |||
|||  State                                          |  pending            |||
||+-------------------------------------------------+---------------------+||
|||                              Monitoring                               |||
||+-----------------------------+-----------------------------------------+||
|||  State                      |  disabled                               |||
||+-----------------------------+-----------------------------------------+||
|||                           NetworkInterfaces                           |||
||+----------------------+------------------------------------------------+||
|||  Description         |                                                |||
|||  InterfaceType       |  interface                                     |||
|||  MacAddress          |  0a:56:76:bf:2b:c9                             |||
|||  NetworkInterfaceId  |  eni-05d1f84d9e05bcc3e                         |||
|||  OwnerId             |  386159697246                                  |||
|||  PrivateDnsName      |  ip-172-31-39-13.us-east-2.compute.internal    |||
|||  PrivateIpAddress    |  172.31.39.13                                  |||
|||  SourceDestCheck     |  True                                          |||
|||  Status              |  in-use                                        |||
|||  SubnetId            |  subnet-06ea29a210f12daa7                      |||
|||  VpcId               |  vpc-0202e1374ee1fbf85                         |||
||+----------------------+------------------------------------------------+||
||||                             Attachment                              ||||
|||+----------------------------+----------------------------------------+|||
||||  AttachTime                |  2023-09-03T07:32:57.000Z              ||||
||||  AttachmentId              |  eni-attach-04125c5652501d2e7          ||||
||||  DeleteOnTermination       |  True                                  ||||
||||  DeviceIndex               |  0                                     ||||
||||  NetworkCardIndex          |  0                                     ||||
||||  Status                    |  attaching                             ||||
|||+----------------------------+----------------------------------------+|||
||||                               Groups                                ||||
|||+-----------------------+---------------------------------------------+|||
||||  GroupId              |  sg-02a39ddd15525edfb                       ||||
||||  GroupName            |  my-sg                                      ||||
|||+-----------------------+---------------------------------------------+|||
||||                         PrivateIpAddresses                          ||||
|||+--------------------+------------------------------------------------+|||
||||  Primary           |  True                                          ||||
||||  PrivateDnsName    |  ip-172-31-39-13.us-east-2.compute.internal    ||||
||||  PrivateIpAddress  |  172.31.39.13                                  ||||
|||+--------------------+------------------------------------------------+|||
|||                               Placement                               |||
||+-----------------------------------------+-----------------------------+||
|||  AvailabilityZone                       |  us-east-2c                 |||
|||  GroupName                              |                             |||
|||  Tenancy                                |  default                    |||
||+-----------------------------------------+-----------------------------+||
|||                         PrivateDnsNameOptions                         |||
||+------------------------------------------------------+----------------+||
|||  EnableResourceNameDnsAAAARecord                     |  False         |||
|||  EnableResourceNameDnsARecord                        |  False         |||
|||  HostnameType                                        |  ip-name       |||
||+------------------------------------------------------+----------------+||
|||                            SecurityGroups                             |||
||+------------------------+----------------------------------------------+||
|||  GroupId               |  sg-02a39ddd15525edfb                        |||
|||  GroupName             |  my-sg                                       |||
||+------------------------+----------------------------------------------+||
|||                                 State                                 |||
||+-----------------------------+-----------------------------------------+||
|||  Code                       |  0                                      |||
|||  Name                       |  pending                                |||
||+-----------------------------+-----------------------------------------+||
|||                              StateReason                              |||
||+----------------------------------+------------------------------------+||
|||  Code                            |  pending                           |||
|||  Message                         |  pending                           |||
||+----------------------------------+------------------------------------+||
aws>
```

![image-20230903153634099](assets/image-20230903153634099.png)

## 连接 EC2 实例

### 查看正在运行的实例列表

```shell
aws> ec2 describe-instances
----------------------------------------------------------------------------------------
|                                   DescribeInstances                                  |
+--------------------------------------------------------------------------------------+
||                                    Reservations                                    ||
|+-----------------------------------+------------------------------------------------+|
||  OwnerId                          |  386159697246                                  ||
||  ReservationId                    |  r-061539ad22b7e9c1e                           ||
|+-----------------------------------+------------------------------------------------+|
|||                                     Instances                                    |||
||+---------------------------+------------------------------------------------------+||
|||  AmiLaunchIndex           |  0                                                   |||
|||  Architecture             |  x86_64                                              |||
|||  BootMode                 |  uefi-preferred                                      |||
|||  ClientToken              |  47d5bc44-90c8-4274-b92b-fcdfe1192230                |||
|||  CurrentInstanceBootMode  |  legacy-bios                                         |||
|||  EbsOptimized             |  False                                               |||
|||  EnaSupport               |  True                                                |||
|||  Hypervisor               |  xen                                                 |||
|||  ImageId                  |  ami-0cf0e376c672104d6                               |||
|||  InstanceId               |  i-01c751f6c8019edd3                                 |||
|||  InstanceType             |  t2.micro                                            |||
|||  KeyName                  |  kgptalkie                                           |||
|||  LaunchTime               |  2023-09-03T07:32:57.000Z                            |||
|||  PlatformDetails          |  Linux/UNIX                                          |||
|||  PrivateDnsName           |  ip-172-31-39-13.us-east-2.compute.internal          |||
|||  PrivateIpAddress         |  172.31.39.13                                        |||
|||  PublicDnsName            |  ec2-18-216-156-171.us-east-2.compute.amazonaws.com  |||
|||  PublicIpAddress          |  18.216.156.171                                      |||
|||  RootDeviceName           |  /dev/xvda                                           |||
|||  RootDeviceType           |  ebs                                                 |||
|||  SourceDestCheck          |  True                                                |||
|||  StateTransitionReason    |                                                      |||
|||  SubnetId                 |  subnet-06ea29a210f12daa7                            |||
|||  UsageOperation           |  RunInstances                                        |||
|||  UsageOperationUpdateTime |  2023-09-03T07:32:57.000Z                            |||
|||  VirtualizationType       |  hvm                                                 |||
|||  VpcId                    |  vpc-0202e1374ee1fbf85                               |||
||+---------------------------+------------------------------------------------------+||
||||                               BlockDeviceMappings                              ||||
|||+-----------------------------------------+--------------------------------------+|||
||||  DeviceName                             |  /dev/xvda                           ||||
|||+-----------------------------------------+--------------------------------------+|||
|||||                                      Ebs                                     |||||
||||+----------------------------------+-------------------------------------------+||||
|||||  AttachTime                      |  2023-09-03T07:32:58.000Z                 |||||
|||||  DeleteOnTermination             |  True                                     |||||
|||||  Status                          |  attached                                 |||||
|||||  VolumeId                        |  vol-067989491145de4dc                    |||||
||||+----------------------------------+-------------------------------------------+||||
||||                        CapacityReservationSpecification                        ||||
|||+----------------------------------------------------------------+---------------+|||
||||  CapacityReservationPreference                                 |  open         ||||
|||+----------------------------------------------------------------+---------------+|||
||||                                   CpuOptions                                   ||||
|||+--------------------------------------------------------------+-----------------+|||
||||  CoreCount                                                   |  1              ||||
||||  ThreadsPerCore                                              |  1              ||||
|||+--------------------------------------------------------------+-----------------+|||
||||                                 EnclaveOptions                                 ||||
|||+-------------------------------------------+------------------------------------+|||
||||  Enabled                                  |  False                             ||||
|||+-------------------------------------------+------------------------------------+|||
||||                               HibernationOptions                               ||||
|||+------------------------------------------------+-------------------------------+|||
||||  Configured                                    |  False                        ||||
|||+------------------------------------------------+-------------------------------+|||
||||                               MaintenanceOptions                               ||||
|||+-----------------------------------------------+--------------------------------+|||
||||  AutoRecovery                                 |  default                       ||||
|||+-----------------------------------------------+--------------------------------+|||
||||                                 MetadataOptions                                ||||
|||+-------------------------------------------------------+------------------------+|||
||||  HttpEndpoint                                         |  enabled               ||||
||||  HttpProtocolIpv6                                     |  disabled              ||||
||||  HttpPutResponseHopLimit                              |  2                     ||||
||||  HttpTokens                                           |  required              ||||
||||  InstanceMetadataTags                                 |  disabled              ||||
||||  State                                                |  applied               ||||
|||+-------------------------------------------------------+------------------------+|||
||||                                   Monitoring                                   ||||
|||+---------------------------------+----------------------------------------------+|||
||||  State                          |  disabled                                    ||||
|||+---------------------------------+----------------------------------------------+|||
||||                                NetworkInterfaces                               ||||
|||+-------------------------+------------------------------------------------------+|||
||||  Description            |                                                      ||||
||||  InterfaceType          |  interface                                           ||||
||||  MacAddress             |  0a:56:76:bf:2b:c9                                   ||||
||||  NetworkInterfaceId     |  eni-05d1f84d9e05bcc3e                               ||||
||||  OwnerId                |  386159697246                                        ||||
||||  PrivateDnsName         |  ip-172-31-39-13.us-east-2.compute.internal          ||||
||||  PrivateIpAddress       |  172.31.39.13                                        ||||
||||  SourceDestCheck        |  True                                                ||||
||||  Status                 |  in-use                                              ||||
||||  SubnetId               |  subnet-06ea29a210f12daa7                            ||||
||||  VpcId                  |  vpc-0202e1374ee1fbf85                               ||||
|||+-------------------------+------------------------------------------------------+|||
|||||                                  Association                                 |||||
||||+-----------------+------------------------------------------------------------+||||
|||||  IpOwnerId      |  amazon                                                    |||||
|||||  PublicDnsName  |  ec2-18-216-156-171.us-east-2.compute.amazonaws.com        |||||
|||||  PublicIp       |  18.216.156.171                                            |||||
||||+-----------------+------------------------------------------------------------+||||
|||||                                  Attachment                                  |||||
||||+-------------------------------+----------------------------------------------+||||
|||||  AttachTime                   |  2023-09-03T07:32:57.000Z                    |||||
|||||  AttachmentId                 |  eni-attach-04125c5652501d2e7                |||||
|||||  DeleteOnTermination          |  True                                        |||||
|||||  DeviceIndex                  |  0                                           |||||
|||||  NetworkCardIndex             |  0                                           |||||
|||||  Status                       |  attached                                    |||||
||||+-------------------------------+----------------------------------------------+||||
|||||                                    Groups                                    |||||
||||+--------------------------+---------------------------------------------------+||||
|||||  GroupId                 |  sg-02a39ddd15525edfb                             |||||
|||||  GroupName               |  my-sg                                            |||||
||||+--------------------------+---------------------------------------------------+||||
|||||                              PrivateIpAddresses                              |||||
||||+----------------------+-------------------------------------------------------+||||
|||||  Primary             |  True                                                 |||||
|||||  PrivateDnsName      |  ip-172-31-39-13.us-east-2.compute.internal           |||||
|||||  PrivateIpAddress    |  172.31.39.13                                         |||||
||||+----------------------+-------------------------------------------------------+||||
||||||                                 Association                                ||||||
|||||+-----------------+----------------------------------------------------------+|||||
||||||  IpOwnerId      |  amazon                                                  ||||||
||||||  PublicDnsName  |  ec2-18-216-156-171.us-east-2.compute.amazonaws.com      ||||||
||||||  PublicIp       |  18.216.156.171                                          ||||||
|||||+-----------------+----------------------------------------------------------+|||||
||||                                    Placement                                   ||||
|||+----------------------------------------------+---------------------------------+|||
||||  AvailabilityZone                            |  us-east-2c                     ||||
||||  GroupName                                   |                                 ||||
||||  Tenancy                                     |  default                        ||||
|||+----------------------------------------------+---------------------------------+|||
||||                              PrivateDnsNameOptions                             ||||
|||+------------------------------------------------------------+-------------------+|||
||||  EnableResourceNameDnsAAAARecord                           |  False            ||||
||||  EnableResourceNameDnsARecord                              |  False            ||||
||||  HostnameType                                              |  ip-name          ||||
|||+------------------------------------------------------------+-------------------+|||
||||                                 SecurityGroups                                 ||||
|||+---------------------------+----------------------------------------------------+|||
||||  GroupId                  |  sg-02a39ddd15525edfb                              ||||
||||  GroupName                |  my-sg                                             ||||
|||+---------------------------+----------------------------------------------------+|||
||||                                      State                                     ||||
|||+---------------------------------+----------------------------------------------+|||
||||  Code                           |  16                                          ||||
||||  Name                           |  running                                     ||||
|||+---------------------------------+----------------------------------------------+|||
aws>
```

### 连接失败 权限拒绝

```shell
~ via 🅒 base
➜ ssh -i kgptalkie.pem ubuntu@18.216.156.171
The authenticity of host '18.216.156.171 (18.216.156.171)' can't be established.
ED25519 key fingerprint is SHA256:xAUdJEdlHd3yi4Pl7+k3NbwAy4WA1Gb7v9qNndJ5xZE.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '18.216.156.171' (ED25519) to the list of known hosts.
ubuntu@18.216.156.171: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).

~ via 🅒 base took 9.9s
➜

```

### 成功连接

```shell
~ via 🅒 base took 9.9s
➜ ssh -i kgptalkie.pem ec2-user@18.216.156.171
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
[ec2-user@ip-172-31-39-13 ~]$ ls
[ec2-user@ip-172-31-39-13 ~]$ cd /
[ec2-user@ip-172-31-39-13 /]$ ls
bin  boot  dev  etc  home  lib  lib64  local  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
[ec2-user@ip-172-31-39-13 /]$ exit
logout
Connection to 18.216.156.171 closed.

~ via 🅒 base took 2m 5.2s
```

### 删除实例

### 关闭终止运行实例

```shell
aws> ec2 terminate-instances --instance-ids i-01c751f6c8019edd3
-------------------------------
|     TerminateInstances      |
+-----------------------------+
||   TerminatingInstances    ||
|+---------------------------+|
||        InstanceId         ||
|+---------------------------+|
||  i-01c751f6c8019edd3      ||
|+---------------------------+|
|||      CurrentState       |||
||+-------+-----------------+||
||| Code  |      Name       |||
||+-------+-----------------+||
|||  32   |  shutting-down  |||
||+-------+-----------------+||
|||      PreviousState      |||
||+---------+---------------+||
|||  Code   |     Name      |||
||+---------+---------------+||
|||  16     |  running      |||
||+---------+---------------+||
aws>


```

![image-20230904002032691](assets/image-20230904002032691.png)

## Amazon S3 和 AWS cli

前提

默认凭证设置

存储服务

https://s3.console.aws.amazon.com/s3/get-started?region=us-east-2

存储桶

### 创建存储桶

```shell
aws> s3 help
aws> s3 mb s3://kgptalkie
make_bucket failed: s3://kgptalkie An error occurred (BucketAlreadyExists) when calling the CreateBucket operation: The requested bucket name is not available. The bucket namespace is shared by all users of the system. Please select a different name and try again.
aws> s3 mb s3://kgptalkie1
make_bucket: kgptalkie1
aws>

```

![image-20230904003140980](assets/image-20230904003140980.png)

### 查看所有存储桶

```shell
aws> s3 ls
2023-09-04 00:30:49 kgptalkie1
aws> s3 ls kgptalkie1
aws>

```

### 删除存储桶

```shell
aws> s3 rb s3://kgptalkie1
remove_bucket: kgptalkie1
aws>
```

### 删除不存在的存储桶

```shell
aws> s3 rb s3://kgptalkie1 --force
fatal error: An error occurred (NoSuchBucket) when calling the ListObjectsV2 operation: The specified bucket does not exist

remove_bucket failed: Unable to delete all objects in the bucket, bucket will not be deleted.
aws>

```

