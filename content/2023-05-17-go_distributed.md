+++
title = "Go语言编写简单分布式系统"
date = 2023-05-17T09:59:55+08:00
description = "Go语言编写简单分布式系统"
[taxonomies]
tags = ["Go"]
categories = ["Go"]
+++

# Go语言编写简单分布式系统

### 课程内容

简介

服务注册

服务发现

状态监测

## 一、课程简介

使用Go语言构建一套非常简单的分布式系统

重点是Go语言

组件的选择并不是面向生产环境

### 技术选型

### 分布式模型

- Hub & Spoke  所有的服务都依赖于一个中心的服务 有利于负载均衡 方便做集中式的追踪和日志  单点故障 多种角色
- Peer to Peer 点对点  没有单点故障 解耦程度比较高  服务很难被发现 负载均衡比较困难
- Message Queues  消息队列  有利于消息的持久化 单点故障  配置相对比较困难

### 混合模型

客户端 网关  Hub 各类 Service

### 混合模型优缺点

| 优点                     | 缺点                        |
| ------------------------ | --------------------------- |
| 有利于负载均衡           | 架构更加复杂                |
| 对服务失败的防范更加健壮 | 这个 Hub 的作用范围难以界定 |

### 系统主要组件

| 服务注册 | 用户门户 | 日志服务   | 业务服务   |
| -------- | -------- | ---------- | ---------- |
| 服务注册 | Web 应用 | 集中式日志 | 业务逻辑   |
| 健康检查 | API 网关 |            | 数据持久化 |

### 技术选型

- 开发语言：Go
- 框架：不使用框架
- 数据传输：HTTP
- 传输协议：JSON

## 二、服务注册

### 本章内容

- 创建 Web 服务
- 创建注册服务
- 注册Web服务
- 取消注册Web服务

### 创建日志服务

```bash
~ via 🅒 base
➜ cd Code/go

~/Code/go via 🐹 v1.20.3 via 🅒 base
➜ mcd distributed # mkdir distributed cd distributed

Code/go/distributed via 🐹 v1.20.3 via 🅒 base
➜ go mod init distributed
go: creating new go.mod: module distributed

Code/go/distributed via 🐹 v1.20.3 via 🅒 base
➜ c # code .

Code/go/distributed via 🐹 v1.20.3 via 🅒 base
➜


```

log/server.go

```go
package log

import (
 "io/ioutil"
 stlog "log"
 "net/http"
 "os"
)

var log *stlog.Logger

type fileLog string

func (fl fileLog) Write(data []byte) (int, error) {
 f, err := os.OpenFile(string(fl), os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0600)
 if err != nil {
  return 0, err
 }
 defer f.Close()
 return f.Write(data)
}

func Run(destination string) {
 log = stlog.New(fileLog(destination), "go", stlog.LstdFlags)
}

func RegisterHandlers() {
 http.HandleFunc("/log", func(w http.ResponseWriter, r *http.Request) {
  switch r.Method {
  case http.MethodPost:
   msg, err := ioutil.ReadAll(r.Body)
   if err != nil || len(msg) == 0 {
    w.WriteHeader(http.StatusBadRequest)
    return
   }
   write(string(msg))
  default:
   w.WriteHeader(http.StatusMethodNotAllowed)
   return
  }
 })
}

func write(message string) {
 log.Printf("%v\n", message)
}

```

### 独立的日志服务

```bash
Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ tree
.
├── cmd
│   └── logservice
│       ├── distributed.log
│       └── main.go
├── go.mod
├── log
│   └── server.go
└── service
    └── service.go

5 directories, 5 files

Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ 
```

main.go

```go
package main

import (
 "context"
 "distributed/log"
 "distributed/service"
 "fmt"
 stlog "log"
)

func main() {
 log.Run("./distributed.log")
 host, port := "localhost", "4000"
 ctx, err := service.Start(
  context.Background(),
  "Log Service",
  host,
  port,
  log.RegisterHandlers,
 )

 if err != nil {
  fmt.Println("err", err)
  stlog.Fatalln(err)
 }
 <-ctx.Done()

 fmt.Println("Shutting down log service")
}

```

server.go

```go
package log

import (
 "fmt"
 "io"
 stlog "log"
 "net/http"
 "os"
)

var log *stlog.Logger

type fileLog string // 实际就是 String 类型的别名

func (fl fileLog) Write(data []byte) (int, error) {
 // 把数据写入到文件里
 f, err := os.OpenFile(string(fl), os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0600)
 if err != nil {
  fmt.Println("error opening file", err)
  return 0, err
 }
 defer f.Close()
 return f.Write(data)
}

func Run(destination string) {
 // 创建一个自定义的log 把日志写入到传进来的地址 destination
 log = stlog.New(fileLog(destination), "go: ", stlog.LstdFlags)
}

func RegisterHandlers() {
 http.HandleFunc("/log", func(w http.ResponseWriter, r *http.Request) {
  switch r.Method {
  case http.MethodPost:
   msg, err := io.ReadAll(r.Body)
   if err != nil || len(msg) == 0 {
    w.WriteHeader(http.StatusBadRequest)
    return
   }
   write(string(msg))
  default:
   w.WriteHeader(http.StatusMethodNotAllowed)
   return
  }
 })
}

func write(message string) {
 log.Printf("%v\n", message)
}

```

service.go

```go
package service

import (
 "context"
 "fmt"
 "log"
 "net/http"
)

func Start(ctx context.Context, serviceName, host, port string,
 registerHandlersFunc func()) (context.Context, error) {
 registerHandlersFunc()
 ctx = startService(ctx, serviceName, host, port)

 return ctx, nil
}

func startService(ctx context.Context, serviceName, host, port string) context.Context {
 ctx, cancel := context.WithCancel(ctx)

 var srv http.Server
 srv.Addr = ":" + port

 go func() {
  log.Println(srv.ListenAndServe())
  cancel()
 }()

 go func() {
  fmt.Printf("%v started. Pree any key to stop. \n", serviceName)
  var s string
  fmt.Scanln(&s)
  srv.Shutdown(ctx)
  cancel()
 }()

 return ctx
}

```

POST 请求 <http://localhost:4000/log>

```bash
Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ cd cmd/logservice 

distributed/cmd/logservice via 🐹 v1.20.3 via 🅒 base 
➜ go run .
Log Service started. Pree any key to stop. 

```

### 服务注册 - 注册逻辑

### 现状

log  service   logservice   cmd

### 现状

log service  registry  logservice cmd

```bash
Code/go/distributed via 🐹 v1.20.3 via 🅒 base
➜ tree
.
├── cmd
│   └── logservice
│       ├── distributed.log
│       └── main.go
├── go.mod
├── log
│   └── server.go
├── registry
│   ├── registration.go
│   └── server.go
└── service
    └── service.go

6 directories, 7 files

Code/go/distributed via 🐹 v1.20.3 via 🅒 base
➜

```

registry/server.go

```go
package registry

import (
 "encoding/json"
 "log"
 "net/http"
 "sync"
)

const ServerPort = ":3000"
const ServiceURL = "http://localhost" + ServerPort + "/services"

type registry struct {
 registrations []Registration
 mutex         *sync.Mutex
}

func (r *registry) add(reg Registration) error {
 r.mutex.Lock()
 r.registrations = append(r.registrations, reg)
 r.mutex.Unlock()
 return nil
}

var reg = registry{
 registrations: make([]Registration, 0),
 mutex:         new(sync.Mutex),
}

type RegistryService struct{}

func (s RegistryService) ServeHTTP(w http.ResponseWriter, r *http.Request) {
 log.Println("Request received")
 switch r.Method {
 case http.MethodPost:
  dec := json.NewDecoder(r.Body)
  var r Registration
  err := dec.Decode(&r)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusBadRequest)
   return
  }
  log.Printf("Adding service: %v with URL: %s\n", r.ServiceName, r.ServiceURL)
  err = reg.add(r)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusBadRequest)
   return
  }
 default:
  w.WriteHeader(http.StatusMethodNotAllowed)
  return
 }
}

```

registry/registration.go

```go
package registry

type Registration struct {
 ServiceName ServiceName
 ServiceURL  string
}

type ServiceName string

const (
 LogService = ServiceName("LogService")
)

```

### 服务注册 - 独立服务

#### 现状

log  service   registry

logservice  **registryservice**   cmd

```bash
Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ tree
.
├── cmd
│   ├── logservice
│   │   ├── distributed.log
│   │   └── main.go
│   └── registryservice
│       └── main.go
├── go.mod
├── log
│   └── server.go
├── registry
│   ├── registration.go
│   └── server.go
└── service
    └── service.go

7 directories, 8 files

Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ 
```

registryservice/main.go

```go
package main

import (
 "context"
 "distributed/registry"
 "fmt"
 "log"
 "net/http"
)

func main() {
 http.Handle("/services", &registry.RegistryService{})

 ctx, cancel := context.WithCancel(context.Background())
 defer cancel()

 var srv http.Server
 srv.Addr = registry.ServerPort

 go func() {
  log.Println(srv.ListenAndServe())
  cancel()
 }()

 go func() {
  fmt.Println("Registry service started. Press any key to stop.")
  var s string
  fmt.Scanln(&s)
  srv.Shutdown(ctx)
  cancel()
 }()

 <-ctx.Done()
 fmt.Println("Shutting down registry service")
}

```

### 服务注册 - 注册服务

现状

log  service      registry

 logservice      registryservice    cmd

```bash
Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ tree
.
├── cmd
│   ├── logservice
│   │   ├── distributed.log
│   │   └── main.go
│   └── registryservice
│       └── main.go
├── go.mod
├── log
│   └── server.go
├── registry
│   ├── client.go
│   ├── registration.go
│   └── server.go
└── service
    └── service.go

7 directories, 9 files

Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ 
```

registry/client.go

```go
package registry

import (
 "bytes"
 "encoding/json"
 "fmt"
 "net/http"
)

func RegisterService(r Registration) error {
 buf := new(bytes.Buffer)
 enc := json.NewEncoder(buf)
 err := enc.Encode(r)
 if err != nil {
  return err
 }

 res, err := http.Post(ServiceURL, "application/json", buf)
 if err != nil {
  return err
 }

 if res.StatusCode != http.StatusOK {
  return fmt.Errorf("failed to register service. Registry service "+
   "responded with code %v", res.StatusCode)
 }

 return nil
}

```

service/service.go

```go
package service

import (
 "context"
 "distributed/registry"
 "fmt"
 "log"
 "net/http"
)

func Start(ctx context.Context, host, port string, reg registry.Registration,
 registerHandlersFunc func()) (context.Context, error) {
 registerHandlersFunc()
 ctx = startService(ctx, reg.ServiceName, host, port)
 // 注册服务
 err := registry.RegisterService(reg)
 if err != nil {
  return ctx, err
 }

 return ctx, nil
}

func startService(ctx context.Context, serviceName registry.ServiceName, host, port string) context.Context {
 ctx, cancel := context.WithCancel(ctx)

 var srv http.Server
 srv.Addr = ":" + port

 go func() {
  log.Println(srv.ListenAndServe())
  cancel()
 }()

 go func() {
  fmt.Printf("%v started. Pree any key to stop. \n", serviceName)
  var s string
  fmt.Scanln(&s)
  srv.Shutdown(ctx)
  cancel()
 }()

 return ctx
}

```

logservice/main.go

```go
package main

import (
 "context"
 "distributed/log"
 "distributed/registry"
 "distributed/service"
 "fmt"
 stlog "log"
)

func main() {
 log.Run("./distributed.log")
 host, port := "localhost", "4000"
 serviceAddress := fmt.Sprintf("http://%s:%s", host, port)

 r := registry.Registration{
  ServiceName: "Log Service",
  ServiceURL:  serviceAddress,
 }
 ctx, err := service.Start(
  context.Background(),
  host,
  port,
  r,
  log.RegisterHandlers,
 )

 if err != nil {
  fmt.Println("err", err)
  stlog.Fatalln(err)
 }
 <-ctx.Done()

 fmt.Println("Shutting down log service")
}

```

运行

```bash
distributed/cmd/registryservice via 🐹 v1.20.3 via 🅒 base 
➜ go run .
Registry service started. Press any key to stop.
2023/05/18 13:13:12 Request received
2023/05/18 13:13:12 Adding service: Log Service with URL: http://localhost:4000



distributed/cmd/logservice via 🐹 v1.20.3 via 🅒 base
➜ go run .
Log Service started. Pree any key to stop.

```

现状

log    service        registry client.go

  logservice        registryservice        cmd

### 服务注册 - 取消注册

registry/client.go

```go
package registry

import (
 "bytes"
 "encoding/json"
 "fmt"
 "net/http"
)

func RegisterService(r Registration) error {
 buf := new(bytes.Buffer)
 enc := json.NewEncoder(buf)
 err := enc.Encode(r)
 if err != nil {
  return err
 }

 res, err := http.Post(ServiceURL, "application/json", buf)
 if err != nil {
  return err
 }

 if res.StatusCode != http.StatusOK {
  return fmt.Errorf("failed to register service. Registry service "+
   "responded with code %v", res.StatusCode)
 }

 return nil
}

func ShutdownService(url string) error {
 req, err := http.NewRequest(http.MethodDelete, ServiceURL, bytes.NewBuffer([]byte(url)))
 if err != nil {
  return err
 }
 req.Header.Add("Content-Type", "text/plain")
 res, err := http.DefaultClient.Do(req)
 if err != nil {
  return err
 }
 if res.StatusCode != http.StatusOK {
  return fmt.Errorf("failed to deregister service. Registry "+
   "service responded with code %v", res.StatusCode)
 }
 return nil
}

```

registry/server.go

```go
package registry

import (
 "encoding/json"
 "fmt"
 "io"
 "log"
 "net/http"
 "sync"
)

const ServerPort = ":3000"
const ServiceURL = "http://localhost" + ServerPort + "/services"

type registry struct {
 registrations []Registration
 mutex         *sync.Mutex
}

func (r *registry) add(reg Registration) error {
 r.mutex.Lock()
 r.registrations = append(r.registrations, reg)
 r.mutex.Unlock()
 return nil
}

func (r *registry) remove(url string) error {
 for i := range reg.registrations {
  if reg.registrations[i].ServiceURL == url {
   r.mutex.Lock()
   reg.registrations = append(reg.registrations[:i], reg.registrations[i+1:]...)
   r.mutex.Unlock()
   return nil
  }
 }
 return fmt.Errorf("service at URL %s not found", url)
}

var reg = registry{
 registrations: make([]Registration, 0),
 mutex:         new(sync.Mutex),
}

type RegistryService struct{}

func (s RegistryService) ServeHTTP(w http.ResponseWriter, r *http.Request) {
 log.Println("Request received")
 switch r.Method {
 case http.MethodPost:
  dec := json.NewDecoder(r.Body)
  var r Registration
  err := dec.Decode(&r)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusBadRequest)
   return
  }
  log.Printf("Adding service: %v with URL: %s\n", r.ServiceName, r.ServiceURL)
  err = reg.add(r)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusBadRequest)
   return
  }
 case http.MethodDelete:
  payload, err := io.ReadAll(r.Body)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusInternalServerError)
   return
  }
  url := string(payload)
  log.Printf("Removing service at URL: %s", url)
  err = reg.remove(url)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusInternalServerError)
   return
  }
 default:
  w.WriteHeader(http.StatusMethodNotAllowed)
  return
 }
}

```

service/service.go

```go
package service

import (
 "context"
 "distributed/registry"
 "fmt"
 "log"
 "net/http"
)

func Start(ctx context.Context, host, port string, reg registry.Registration,
 registerHandlersFunc func()) (context.Context, error) {
 registerHandlersFunc()
 ctx = startService(ctx, reg.ServiceName, host, port)
 // 注册服务
 err := registry.RegisterService(reg)
 if err != nil {
  return ctx, err
 }

 return ctx, nil
}

func startService(ctx context.Context, serviceName registry.ServiceName, host, port string) context.Context {
 ctx, cancel := context.WithCancel(ctx)

 var srv http.Server
 srv.Addr = ":" + port

 go func() {
  log.Println(srv.ListenAndServe())
  err := registry.ShutdownService(fmt.Sprintf("http://%s:%s", host, port))
  if err != nil {
   log.Println(err)
  }
  cancel()
 }()

 go func() {
  fmt.Printf("%v started. Pree any key to stop. \n", serviceName)
  var s string
  fmt.Scanln(&s)
  err := registry.ShutdownService(fmt.Sprintf("http://%s:%s", host, port))
  if err != nil {
   log.Println(err)
  }
  srv.Shutdown(ctx)
  cancel()
 }()

 return ctx
}

```

运行

```bash
distributed/cmd/registryservice via 🐹 v1.20.3 via 🅒 base took 2m 4.7s 
➜ go run .
Registry service started. Press any key to stop.
2023/05/18 23:42:33 Request received
2023/05/18 23:42:33 Adding service: Log Service with URL: http://localhost:4000
2023/05/18 23:42:40 Request received
2023/05/18 23:42:40 Removing service at URL: http://localhost:4000
2023/05/18 23:42:40 Request received
2023/05/18 23:42:40 Removing service at URL: http://localhost:4000
2023/05/18 23:42:40 service at URL http://localhost:4000 not found


distributed/cmd/logservice via 🐹 v1.20.3 via 🅒 base took 31.2s
➜ go run .
Log Service started. Pree any key to stop.

2023/05/18 23:42:40 http: Server closed
Shutting down log service

distributed/cmd/logservice via 🐹 v1.20.3 via 🅒 base took 8.0s
➜

```

## 三、服务发现

### 本章内容

- 业务服务
- 服务发现
- 依赖服务变化的通知

### 3.1 业务服务（1）

### 现状

服务注册

Log 服务

业务服务

```go
Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ tree
.
├── cmd
│   ├── logservice
│   │   ├── distributed.log
│   │   └── main.go
│   └── registryservice
│       └── main.go
├── go.mod
├── grades
│   ├── grades.go
│   └── mockdata.go
├── log
│   └── server.go
├── registry
│   ├── client.go
│   ├── registration.go
│   └── server.go
└── service
    └── service.go

8 directories, 11 files

Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ 
```

grades.go

```go
package grades

import "fmt"

type Student struct {
 ID        int
 FirstName string
 LastName  string
 Grades    []Grade
}

func (s Student) Average() float32 {
 var result float32
 for _, grade := range s.Grades {
  result += grade.Score
 }

 return result / float32(len(s.Grades))
}

type Students []Student

var students Students

func (ss Students) GetByID(id int) (*Student, error) {
 for i := range ss {
  if ss[i].ID == id {
   return &ss[i], nil
  }
 }

 return nil, fmt.Errorf("Student with ID %d not found", id)
}

type GradeType string

const (
 GradeQuiz = GradeType("Quiz")
 GradeTest = GradeType("Test")
 GradeExam = GradeType("Exam")
)

type Grade struct {
 Title string
 Type  GradeType
 Score float32
}

```

mockdata.go

```go
package grades

func init() {
 students = []Student{
  {
   ID:        1,
   FirstName: "Nick",
   LastName:  "Carter",
   Grades: []Grade{
    {
     Title: "Quiz 1",
     Type:  GradeQuiz,
     Score: 85,
    },
    {
     Title: "Final Exam",
     Type:  GradeExam,
     Score: 94,
    },
    {
     Title: "Quiz 2",
     Type:  GradeQuiz,
     Score: 82,
    },
   },
  },
  {
   ID:        2,
   FirstName: "Roberto",
   LastName:  "Baggio",
   Grades: []Grade{
    {
     Title: "Quiz 1",
     Type:  GradeQuiz,
     Score: 100,
    },
    {
     Title: "Final Exam",
     Type:  GradeExam,
     Score: 100,
    },
    {
     Title: "Quiz 2",
     Type:  GradeQuiz,
     Score: 81,
    },
   },
  },
  {
   ID:        3,
   FirstName: "Emma",
   LastName:  "Stone",
   Grades: []Grade{
    {
     Title: "Quiz 1",
     Type:  GradeQuiz,
     Score: 67,
    },
    {
     Title: "Final Exam",
     Type:  GradeExam,
     Score: 0,
    },
    {
     Title: "Quiz 2",
     Type:  GradeQuiz,
     Score: 75,
    },
   },
  },
  {
   ID:        4,
   FirstName: "zhangsan",
   LastName:  "san",
   Grades: []Grade{
    {
     Title: "Quiz 1",
     Type:  GradeQuiz,
     Score: 44,
    },
    {
     Title: "Final Exam",
     Type:  GradeExam,
     Score: 0,
    },
    {
     Title: "Quiz 2",
     Type:  GradeQuiz,
     Score: 66,
    },
   },
  },
  {
   ID:        5,
   FirstName: "xiaoqiao",
   LastName:  "qiao",
   Grades: []Grade{
    {
     Title: "Quiz 1",
     Type:  GradeQuiz,
     Score: 23,
    },
    {
     Title: "Final Exam",
     Type:  GradeExam,
     Score: 0,
    },
    {
     Title: "Quiz 2",
     Type:  GradeQuiz,
     Score: 44,
    },
   },
  },
 }
}

```

### 3.2 业务服务（2）

业务服务   服务注册  Log服务

```bash
Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ tree
.
├── cmd
│   ├── gradingservice
│   │   └── main.go
│   ├── logservice
│   │   ├── distributed.log
│   │   └── main.go
│   └── registryservice
│       └── main.go
├── go.mod
├── grades
│   ├── grades.go
│   ├── mockdata.go
│   └── server.go
├── log
│   └── server.go
├── registry
│   ├── client.go
│   ├── registration.go
│   └── server.go
└── service
    └── service.go

9 directories, 13 files

Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
```

grades/grades.go

```go
package grades

import (
 "fmt"
 "sync"
)

type Student struct {
 ID        int
 FirstName string
 LastName  string
 Grades    []Grade
}

func (s Student) Average() float32 {
 var result float32
 for _, grade := range s.Grades {
  result += grade.Score
 }

 return result / float32(len(s.Grades))
}

type Students []Student

var (
 students      Students
 studentsMutex sync.Mutex
)

func (ss Students) GetByID(id int) (*Student, error) {
 for i := range ss {
  if ss[i].ID == id {
   return &ss[i], nil
  }
 }

 return nil, fmt.Errorf("Student with ID %d not found", id)
}

type GradeType string

const (
 GradeQuiz = GradeType("Quiz")
 GradeTest = GradeType("Test")
 GradeExam = GradeType("Exam")
)

type Grade struct {
 Title string
 Type  GradeType
 Score float32
}

```

grades/server.go

```go
package grades

import (
 "bytes"
 "encoding/json"
 "fmt"
 "log"
 "net/http"
 "strconv"
 "strings"
)

func RegisterHandlers() {
 handler := new(studentsHandler)
 http.Handle("/students", handler)
 http.Handle("/students/", handler)
}

type studentsHandler struct{}

// /students
// /students/{id}
// /students/{id}/grades
func (sh studentsHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
 pathSegments := strings.Split(r.URL.Path, "/")
 switch len(pathSegments) {
 case 2:
  sh.getAll(w, r)
 case 3:
  id, err := strconv.Atoi(pathSegments[2])
  if err != nil {
   w.WriteHeader(http.StatusNotFound)
   return
  }
  sh.getOne(w, r, id)
 case 4:
  id, err := strconv.Atoi(pathSegments[2])
  if err != nil {
   w.WriteHeader(http.StatusNotFound)
   return
  }
  sh.addGrade(w, r, id)
 default:
  w.WriteHeader(http.StatusNotFound)
 }
}

func (sh studentsHandler) getAll(w http.ResponseWriter, r *http.Request) {
 studentsMutex.Lock()
 defer studentsMutex.Unlock()

 data, err := sh.toJSON(students)
 if err != nil {
  w.WriteHeader(http.StatusInternalServerError)
  log.Println(err)
  return
 }

 w.Header().Add("Content-Type", "application/json")
 w.Write(data)
}

func (sh studentsHandler) getOne(w http.ResponseWriter, r *http.Request, id int) {
 studentsMutex.Lock()
 defer studentsMutex.Unlock()

 student, err := students.GetByID(id)
 if err != nil {
  w.WriteHeader(http.StatusNotFound)
  log.Println(err)
  return
 }

 data, err := sh.toJSON(student)
 if err != nil {
  w.WriteHeader(http.StatusInternalServerError)
  log.Printf("Failed to serialize student: %q", err)
  return
 }
 w.Header().Add("Content-Type", "application/json")
 w.Write(data)
}

func (sh studentsHandler) addGrade(w http.ResponseWriter, r *http.Request, id int) {
 studentsMutex.Lock()
 defer studentsMutex.Unlock()
 student, err := students.GetByID(id)
 if err != nil {
  w.WriteHeader(http.StatusNotFound)
  log.Println(err)
  return
 }
 var g Grade
 dec := json.NewDecoder(r.Body)
 err = dec.Decode(&g)
 if err != nil {
  w.WriteHeader(http.StatusBadRequest)
  log.Println(err)
  return
 }
 student.Grades = append(student.Grades, g)
 w.WriteHeader(http.StatusCreated)
 data, err := sh.toJSON(g)
 if err != nil {
  log.Println(err)
  return
 }
 w.Header().Add("Content-Type", "application/json")
 w.Write(data)
}

func (sh studentsHandler) toJSON(obj interface{}) ([]byte, error) {
 var b bytes.Buffer
 enc := json.NewEncoder(&b)
 err := enc.Encode(obj)
 if err != nil {
  return nil, fmt.Errorf("failed to serialize students: %q", err)
 }
 return b.Bytes(), nil
}

```

registry/registration.go

```go
package registry

type Registration struct {
 ServiceName ServiceName
 ServiceURL  string
}

type ServiceName string

const (
 LogService     = ServiceName("LogService")
 GradingService = ServiceName("GradingService")
)

```

gradingservice/main.go

```go
package main

import (
 "context"
 "distributed/grades"
 "distributed/registry"
 "distributed/service"
 "fmt"
 stlog "log"
)

func main() {
 host, port := "localhost", "6000"
 serviceAddress := fmt.Sprintf("http://%s:%s", host, port)

 r := registry.Registration{
  ServiceName: registry.GradingService,
  ServiceURL:  serviceAddress,
 }
 ctx, err := service.Start(
  context.Background(),
  host,
  port,
  r,
  grades.RegisterHandlers,
 )

 if err != nil {
  stlog.Fatal(err)
 }
 <-ctx.Done()

 fmt.Println("Shutting down grading service")
}

```

logservice/main.go

```go
package main

import (
 "context"
 "distributed/log"
 "distributed/registry"
 "distributed/service"
 "fmt"
 stlog "log"
)

func main() {
 log.Run("./distributed.log")
 host, port := "localhost", "4000"
 serviceAddress := fmt.Sprintf("http://%s:%s", host, port)

 r := registry.Registration{
  ServiceName: registry.LogService,
  ServiceURL:  serviceAddress,
 }
 ctx, err := service.Start(
  context.Background(),
  host,
  port,
  r,
  log.RegisterHandlers,
 )

 if err != nil {
  fmt.Println("err", err)
  stlog.Fatalln(err)
 }
 <-ctx.Done()

 fmt.Println("Shutting down log service")
}

```

### 3.3 服务发现（1）

registry/registration.go

```go
package registry

type Registration struct {
 ServiceName      ServiceName
 ServiceURL       string
 RequiredServices []ServiceName
 ServiceUpdateURL string
}

type ServiceName string

const (
 LogService     = ServiceName("LogService")
 GradingService = ServiceName("GradingService")
)

type patchEntry struct {
 Name ServiceName
 URL  string
}

type patch struct {
 Added   []patchEntry
 Removed []patchEntry
}

```

registry/server.go

```go
package registry

import (
 "bytes"
 "encoding/json"
 "fmt"
 "io"
 "log"
 "net/http"
 "sync"
)

const ServerPort = ":3000"
const ServiceURL = "http://localhost" + ServerPort + "/services"

type registry struct {
 registrations []Registration
 mutex         *sync.RWMutex
}

func (r *registry) add(reg Registration) error {
 r.mutex.Lock()
 r.registrations = append(r.registrations, reg)
 r.mutex.Unlock()
 err := r.sendRequiredServices(reg)
 return err
}

func (r registry) sendRequiredServices(reg Registration) error {
 r.mutex.RLock()
 defer r.mutex.RUnlock()

 var p patch
 for _, serviceReg := range r.registrations {
  for _, reqService := range reg.RequiredServices {
   if serviceReg.ServiceName == reqService {
    p.Added = append(p.Added, patchEntry{
     Name: serviceReg.ServiceName,
     URL:  serviceReg.ServiceURL,
    })
   }
  }
 }
 err := r.sendPatch(p, reg.ServiceUpdateURL)
 if err != nil {
  return err
 }
 return nil
}

func (r registry) sendPatch(p patch, url string) error {
 d, err := json.Marshal(p)
 if err != nil {
  return err
 }
 _, err = http.Post(url, "application/json", bytes.NewReader(d))
 if err != nil {
  return err
 }
 return nil
}

func (r *registry) remove(url string) error {
 for i := range reg.registrations {
  if reg.registrations[i].ServiceURL == url {
   r.mutex.Lock()
   reg.registrations = append(reg.registrations[:i], reg.registrations[i+1:]...)
   r.mutex.Unlock()
   return nil
  }
 }
 return fmt.Errorf("service at URL %s not found", url)
}

var reg = registry{
 registrations: make([]Registration, 0),
 mutex:         new(sync.RWMutex),
}

type RegistryService struct{}

func (s RegistryService) ServeHTTP(w http.ResponseWriter, r *http.Request) {
 log.Println("Request received")
 switch r.Method {
 case http.MethodPost:
  dec := json.NewDecoder(r.Body)
  var r Registration
  err := dec.Decode(&r)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusBadRequest)
   return
  }
  log.Printf("Adding service: %v with URL: %s\n", r.ServiceName, r.ServiceURL)
  err = reg.add(r)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusBadRequest)
   return
  }
 case http.MethodDelete:
  payload, err := io.ReadAll(r.Body)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusInternalServerError)
   return
  }
  url := string(payload)
  log.Printf("Removing service at URL: %s", url)
  err = reg.remove(url)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusInternalServerError)
   return
  }
 default:
  w.WriteHeader(http.StatusMethodNotAllowed)
  return
 }
}

```

### 3.4 服务发现（2）

registry/client.go

```go
package registry

import (
 "bytes"
 "encoding/json"
 "fmt"
 "log"
 "math/rand"
 "net/http"
 "net/url"
 "sync"
)

func RegisterService(r Registration) error {
 serviceUpdateURL, err := url.Parse(r.ServiceUpdateURL)
 if err != nil {
  return err
 }
 http.Handle(serviceUpdateURL.Path, &serviceUpdateHanlder{})

 buf := new(bytes.Buffer)
 enc := json.NewEncoder(buf)
 err = enc.Encode(r)
 if err != nil {
  return err
 }

 res, err := http.Post(ServiceURL, "application/json", buf)
 if err != nil {
  return err
 }

 if res.StatusCode != http.StatusOK {
  return fmt.Errorf("failed to register service. Registry service "+
   "responded with code %v", res.StatusCode)
 }

 return nil
}

type serviceUpdateHanlder struct{}

func (suh serviceUpdateHanlder) ServeHTTP(w http.ResponseWriter, r *http.Request) {
 if r.Method != http.MethodPost {
  w.WriteHeader(http.StatusMethodNotAllowed)
  return
 }
 dec := json.NewDecoder(r.Body)
 var p patch
 err := dec.Decode(&p)
 if err != nil {
  log.Println(err)
  w.WriteHeader(http.StatusBadRequest)
  return
 }
 prov.Update(p)
}

func ShutdownService(url string) error {
 req, err := http.NewRequest(http.MethodDelete, ServiceURL, bytes.NewBuffer([]byte(url)))
 if err != nil {
  return err
 }
 req.Header.Add("Content-Type", "text/plain")
 res, err := http.DefaultClient.Do(req)
 if err != nil {
  return err
 }
 if res.StatusCode != http.StatusOK {
  return fmt.Errorf("failed to deregister service. Registry "+
   "service responded with code %v", res.StatusCode)
 }
 return nil
}

type providers struct {
 services map[ServiceName][]string
 mutex    *sync.RWMutex
}

func (p *providers) Update(pat patch) {
 p.mutex.Lock()
 defer p.mutex.Unlock()

 for _, patchEntry := range pat.Added {
  if _, ok := p.services[patchEntry.Name]; !ok {
   p.services[patchEntry.Name] = make([]string, 0)
  }
  p.services[patchEntry.Name] = append(p.services[patchEntry.Name], patchEntry.URL)
 }

 for _, patchEntry := range pat.Removed {
  if providerURLs, ok := p.services[patchEntry.Name]; ok {
   for i := range providerURLs {
    if providerURLs[i] == patchEntry.URL {
     p.services[patchEntry.Name] = append(providerURLs[:i], providerURLs[i+1:]...)
    }
   }
  }
 }
}

func (p providers) get(name ServiceName) (string, error) {
 providers, ok := p.services[name]
 if !ok {
  return "", fmt.Errorf("no providers available for service %v", name)
 }
 idx := int(rand.Float32() * float32(len(providers)))
 return providers[idx], nil
}

func GetProvider(name ServiceName) (string, error) {
 return prov.get(name)
}

var prov = providers{
 services: make(map[ServiceName][]string),
 mutex:    new(sync.RWMutex),
}

```

### 3.5 服务发现（3）

请求并使用一个服务

```bash
Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ tree
.
├── cmd
│   ├── gradingservice
│   │   └── main.go
│   ├── logservice
│   │   ├── distributed.log
│   │   └── main.go
│   └── registryservice
│       └── main.go
├── go.mod
├── grades
│   ├── grades.go
│   ├── mockdata.go
│   └── server.go
├── log
│   ├── client.go
│   └── server.go
├── registry
│   ├── client.go
│   ├── registration.go
│   └── server.go
└── service
    └── service.go

9 directories, 14 files

Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
```

log/server.go

```go
package log

import (
 "fmt"
 "io"
 stlog "log"
 "net/http"
 "os"
)

var log *stlog.Logger

type fileLog string // 实际就是 String 类型的别名

func (fl fileLog) Write(data []byte) (int, error) {
 // 把数据写入到文件里
 f, err := os.OpenFile(string(fl), os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0600)
 if err != nil {
  fmt.Println("error opening file", err)
  return 0, err
 }
 defer f.Close()
 return f.Write(data)
}

func Run(destination string) {
 // 创建一个自定义的log 把日志写入到传进来的地址 destination
 log = stlog.New(fileLog(destination), "[go] - ", stlog.LstdFlags)
}

func RegisterHandlers() {
 http.HandleFunc("/log", func(w http.ResponseWriter, r *http.Request) {
  switch r.Method {
  case http.MethodPost:
   msg, err := io.ReadAll(r.Body)
   if err != nil || len(msg) == 0 {
    w.WriteHeader(http.StatusBadRequest)
    return
   }
   write(string(msg))
  default:
   w.WriteHeader(http.StatusMethodNotAllowed)
   return
  }
 })
}

func write(message string) {
 log.Printf("%v\n", message)
}

```

log/client.go

```go
package log

import (
 "bytes"
 "distributed/registry"
 "fmt"
 "net/http"

 stlog "log"
)

func SetClientLogger(serviceURL string, clientService registry.ServiceName) {
 stlog.SetPrefix(fmt.Sprintf("[%v] - ", clientService))
 stlog.SetFlags(0)
 stlog.SetOutput(&clientLogger{url: serviceURL})
}

type clientLogger struct {
 url string
}

func (cl clientLogger) Write(data []byte) (int, error) {
 b := bytes.NewBuffer([]byte(data))
 res, err := http.Post(cl.url+"/log", "text/plain", b)
 if err != nil {
  return 0, err
 }
 if res.StatusCode != http.StatusOK {
  return 0, fmt.Errorf("failed to send log message. Service responded with status code %v", res.StatusCode)
 }
 return len(data), nil
}

```

gradingservice/main.go

```go
package main

import (
 "context"
 "distributed/grades"
 "distributed/log"
 "distributed/registry"
 "distributed/service"
 "fmt"
 stlog "log"
)

func main() {
 host, port := "localhost", "6000"
 serviceAddress := fmt.Sprintf("http://%s:%s", host, port)

 r := registry.Registration{
  ServiceName:      registry.GradingService,
  ServiceURL:       serviceAddress,
  RequiredServices: []registry.ServiceName{registry.LogService},
  ServiceUpdateURL: serviceAddress + "/services",
 }
 ctx, err := service.Start(
  context.Background(),
  host,
  port,
  r,
  grades.RegisterHandlers,
 )

 if err != nil {
  stlog.Fatal(err)
 }

 if logProvider, err := registry.GetProvider(registry.LogService); err == nil {
  fmt.Printf("Logging service found at: %s\n", logProvider)
  log.SetClientLogger(logProvider, r.ServiceName)
 }

 <-ctx.Done()

 fmt.Println("Shutting down grading service")
}

```

logservice/main.go

```go
package main

import (
 "context"
 "distributed/log"
 "distributed/registry"
 "distributed/service"
 "fmt"
 stlog "log"
)

func main() {
 log.Run("./distributed.log")
 host, port := "localhost", "4000"
 serviceAddress := fmt.Sprintf("http://%s:%s", host, port)

 r := registry.Registration{
  ServiceName:      registry.LogService,
  ServiceURL:       serviceAddress,
  RequiredServices: make([]registry.ServiceName, 0),
  ServiceUpdateURL: serviceAddress + "/services",
 }
 ctx, err := service.Start(
  context.Background(),
  host,
  port,
  r,
  log.RegisterHandlers,
 )

 if err != nil {
  fmt.Println("err", err)
  stlog.Fatalln(err)
 }
 <-ctx.Done()

 fmt.Println("Shutting down log service")
}

```

启动

```bash
Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ cd cmd/registryservice 

distributed/cmd/registryservice via 🐹 v1.20.3 via 🅒 base 
➜ go run .
Registry service started. Press any key to stop.
2023/05/19 18:44:53 Request received
2023/05/19 18:44:53 Adding service: LogService with URL: http://localhost:4000
2023/05/19 18:45:10 Request received
2023/05/19 18:45:10 Adding service: GradingService with URL: http://localhost:6000




Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ cd cmd/logservice    

distributed/cmd/logservice via 🐹 v1.20.3 via 🅒 base 
➜ go run .
LogService started. Pree any key to stop. 




Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ cd cmd/gradingservice 

distributed/cmd/gradingservice via 🐹 v1.20.3 via 🅒 base 
➜ go run .
GradingService started. Pree any key to stop. 
Logging service found at: http://localhost:4000





```

### 3.6 服务发现（4）依赖变化时进行通知

registry/server.go

```go
package registry

import (
 "bytes"
 "encoding/json"
 "fmt"
 "io"
 "log"
 "net/http"
 "sync"
)

const ServerPort = ":3000"
const ServiceURL = "http://localhost" + ServerPort + "/services"

type registry struct {
 registrations []Registration
 mutex         *sync.RWMutex
}

func (r *registry) add(reg Registration) error {
 r.mutex.Lock()
 r.registrations = append(r.registrations, reg)
 r.mutex.Unlock()
 err := r.sendRequiredServices(reg)
 r.notify(patch{
  Added: []patchEntry{
   {
    Name: reg.ServiceName,
    URL:  reg.ServiceURL,
   },
  },
 })
 return err
}

func (r registry) notify(fullPatch patch) {
 r.mutex.RLock()
 defer r.mutex.RUnlock()
 for _, reg := range r.registrations {
  go func(reg Registration) {
   for _, reqService := range reg.RequiredServices {
    p := patch{Added: []patchEntry{}, Removed: []patchEntry{}}
    sendUpdate := false
    for _, added := range fullPatch.Added {
     if added.Name == reqService {
      p.Added = append(p.Added, added)
      sendUpdate = true
     }
    }
    for _, removed := range fullPatch.Removed {
     if removed.Name == reqService {
      p.Removed = append(p.Removed, removed)
      sendUpdate = true
     }
    }
    if sendUpdate {
     err := r.sendPatch(p, reg.ServiceUpdateURL)
     if err != nil {
      log.Println(err)
      return
     }
    }
   }
  }(reg)
 }
}

func (r registry) sendRequiredServices(reg Registration) error {
 r.mutex.RLock()
 defer r.mutex.RUnlock()

 var p patch
 for _, serviceReg := range r.registrations {
  for _, reqService := range reg.RequiredServices {
   if serviceReg.ServiceName == reqService {
    p.Added = append(p.Added, patchEntry{
     Name: serviceReg.ServiceName,
     URL:  serviceReg.ServiceURL,
    })
   }
  }
 }
 err := r.sendPatch(p, reg.ServiceUpdateURL)
 if err != nil {
  return err
 }
 return nil
}

func (r registry) sendPatch(p patch, url string) error {
 d, err := json.Marshal(p)
 if err != nil {
  return err
 }
 _, err = http.Post(url, "application/json", bytes.NewReader(d))
 if err != nil {
  return err
 }
 return nil
}

func (r *registry) remove(url string) error {
 for i := range reg.registrations {
  if reg.registrations[i].ServiceURL == url {
   r.notify(patch{
    Removed: []patchEntry{
     {
      Name: r.registrations[i].ServiceName,
      URL:  r.registrations[i].ServiceURL,
     },
    },
   })

   r.mutex.Lock()
   reg.registrations = append(reg.registrations[:i], reg.registrations[i+1:]...)
   r.mutex.Unlock()
   return nil
  }
 }
 return fmt.Errorf("service at URL %s not found", url)
}

var reg = registry{
 registrations: make([]Registration, 0),
 mutex:         new(sync.RWMutex),
}

type RegistryService struct{}

func (s RegistryService) ServeHTTP(w http.ResponseWriter, r *http.Request) {
 log.Println("Request received")
 switch r.Method {
 case http.MethodPost:
  dec := json.NewDecoder(r.Body)
  var r Registration
  err := dec.Decode(&r)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusBadRequest)
   return
  }
  log.Printf("Adding service: %v with URL: %s\n", r.ServiceName, r.ServiceURL)
  err = reg.add(r)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusBadRequest)
   return
  }
 case http.MethodDelete:
  payload, err := io.ReadAll(r.Body)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusInternalServerError)
   return
  }
  url := string(payload)
  log.Printf("Removing service at URL: %s", url)
  err = reg.remove(url)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusInternalServerError)
   return
  }
 default:
  w.WriteHeader(http.StatusMethodNotAllowed)
  return
 }
}

```

registry/client.go

```go
package registry

import (
 "bytes"
 "encoding/json"
 "fmt"
 "log"
 "math/rand"
 "net/http"
 "net/url"
 "sync"
)

func RegisterService(r Registration) error {
 serviceUpdateURL, err := url.Parse(r.ServiceUpdateURL)
 if err != nil {
  return err
 }
 http.Handle(serviceUpdateURL.Path, &serviceUpdateHanlder{})

 buf := new(bytes.Buffer)
 enc := json.NewEncoder(buf)
 err = enc.Encode(r)
 if err != nil {
  return err
 }

 res, err := http.Post(ServiceURL, "application/json", buf)
 if err != nil {
  return err
 }

 if res.StatusCode != http.StatusOK {
  return fmt.Errorf("failed to register service. Registry service "+
   "responded with code %v", res.StatusCode)
 }

 return nil
}

type serviceUpdateHanlder struct{}

func (suh serviceUpdateHanlder) ServeHTTP(w http.ResponseWriter, r *http.Request) {
 if r.Method != http.MethodPost {
  w.WriteHeader(http.StatusMethodNotAllowed)
  return
 }
 dec := json.NewDecoder(r.Body)
 var p patch
 err := dec.Decode(&p)
 if err != nil {
  log.Println(err)
  w.WriteHeader(http.StatusBadRequest)
  return
 }
 fmt.Printf("Update received %v\n", p)
 prov.Update(p)
}

func ShutdownService(url string) error {
 req, err := http.NewRequest(http.MethodDelete, ServiceURL, bytes.NewBuffer([]byte(url)))
 if err != nil {
  return err
 }
 req.Header.Add("Content-Type", "text/plain")
 res, err := http.DefaultClient.Do(req)
 if err != nil {
  return err
 }
 if res.StatusCode != http.StatusOK {
  return fmt.Errorf("failed to deregister service. Registry "+
   "service responded with code %v", res.StatusCode)
 }
 return nil
}

type providers struct {
 services map[ServiceName][]string
 mutex    *sync.RWMutex
}

func (p *providers) Update(pat patch) {
 p.mutex.Lock()
 defer p.mutex.Unlock()

 for _, patchEntry := range pat.Added {
  if _, ok := p.services[patchEntry.Name]; !ok {
   p.services[patchEntry.Name] = make([]string, 0)
  }
  p.services[patchEntry.Name] = append(p.services[patchEntry.Name], patchEntry.URL)
 }

 for _, patchEntry := range pat.Removed {
  if providerURLs, ok := p.services[patchEntry.Name]; ok {
   for i := range providerURLs {
    if providerURLs[i] == patchEntry.URL {
     p.services[patchEntry.Name] = append(providerURLs[:i], providerURLs[i+1:]...)
    }
   }
  }
 }
}

func (p providers) get(name ServiceName) (string, error) {
 providers, ok := p.services[name]
 if !ok {
  return "", fmt.Errorf("no providers available for service %v", name)
 }
 idx := int(rand.Float32() * float32(len(providers)))
 return providers[idx], nil
}

func GetProvider(name ServiceName) (string, error) {
 return prov.get(name)
}

var prov = providers{
 services: make(map[ServiceName][]string),
 mutex:    new(sync.RWMutex),
}

```

## 四、Web应用和服务状态监控

### 4.1 WEB 应用

portal/handlers.go

```go
package portal

import (
 "bytes"
 "distributed/grades"
 "distributed/registry"
 "encoding/json"
 "fmt"
 "log"
 "net/http"
 "strconv"
 "strings"
)

func RegisterHandlers() {
 http.Handle("/", http.RedirectHandler("/students", http.StatusPermanentRedirect))

 h := new(studentsHandler)
 http.Handle("/students", h)
 http.Handle("/students/", h)
}

type studentsHandler struct{}

func (sh studentsHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
 pathSegments := strings.Split(r.URL.Path, "/")
 switch len(pathSegments) {
 case 2: // /students
  sh.renderStudents(w, r)
 case 3: // /students/{:id}
  id, err := strconv.Atoi(pathSegments[2])
  if err != nil {
   w.WriteHeader(http.StatusNotFound)
   return
  }
  sh.renderStudent(w, r, id)
 case 4: // /students/{:id}/grades
  id, err := strconv.Atoi(pathSegments[2])
  if err != nil {
   w.WriteHeader(http.StatusNotFound)
   return
  }
  if strings.ToLower(pathSegments[3]) != "grades" {
   w.WriteHeader(http.StatusNotFound)
   return
  }
  sh.renderGrades(w, r, id)

 default:
  w.WriteHeader(http.StatusNotFound)
 }
}

func (studentsHandler) renderStudents(w http.ResponseWriter, r *http.Request) {
 var err error
 defer func() {
  if err != nil {
   w.WriteHeader(http.StatusInternalServerError)
   log.Println("Error retrieving students: ", err)
  }
 }()

 serviceURL, err := registry.GetProvider(registry.GradingService)
 if err != nil {
  return
 }

 res, err := http.Get(serviceURL + "/students")
 if err != nil {
  return
 }

 var s grades.Students
 err = json.NewDecoder(res.Body).Decode(&s)
 if err != nil {
  return
 }

 rootTemplate.Lookup("students.html").Execute(w, s)
}

func (studentsHandler) renderStudent(w http.ResponseWriter, r *http.Request, id int) {

 var err error
 defer func() {
  if err != nil {
   w.WriteHeader(http.StatusInternalServerError)
   log.Println("Error retrieving students: ", err)
   return
  }
 }()

 serviceURL, err := registry.GetProvider(registry.GradingService)
 if err != nil {
  fmt.Println("registry.GetProvider err", err)
  return
 }

 res, err := http.Get(fmt.Sprintf("%v/students/%v", serviceURL, id))
 if err != nil {
  fmt.Println("http.Get err", err)
  return
 }

 var s grades.Student
 err = json.NewDecoder(res.Body).Decode(&s)
 if err != nil {
  return
 }

 rootTemplate.Lookup("student.html").Execute(w, s)
}

func (studentsHandler) renderGrades(w http.ResponseWriter, r *http.Request, id int) {

 if r.Method != http.MethodPost {
  w.WriteHeader(http.StatusMethodNotAllowed)
  return
 }
 defer func() {
  w.Header().Add("location", fmt.Sprintf("/students/%v", id))
  w.WriteHeader(http.StatusTemporaryRedirect)
 }()
 title := r.FormValue("Title")
 gradeType := r.FormValue("Type")
 score, err := strconv.ParseFloat(r.FormValue("Score"), 32)
 if err != nil {
  log.Println("Failed to parse score: ", err)
  return
 }
 g := grades.Grade{
  Title: title,
  Type:  grades.GradeType(gradeType),
  Score: float32(score),
 }
 data, err := json.Marshal(g)
 if err != nil {
  log.Println("Failed to convert grade to JSON: ", g, err)
 }

 serviceURL, err := registry.GetProvider(registry.GradingService)
 if err != nil {
  log.Println("Failed to retrieve instance of Grading Service", err)
  return
 }
 res, err := http.Post(fmt.Sprintf("%v/students/%v/grades", serviceURL, id), "application/json", bytes.NewBuffer(data))
 if err != nil {
  log.Println("Failed to save grade to Grading Service", err)
  return
 }
 if res.StatusCode != http.StatusCreated {
  log.Println("Failed to save grade to Grading Service. Status: ", res.StatusCode)
  return
 }
}

```

portal/templates.go

```go
package portal

import (
 "html/template"
)

var rootTemplate *template.Template

func ImportTemplates() error {
 var err error
 rootTemplate, err = template.ParseFiles(
  "../../portal/students.html",
  "../../portal/student.html",
 )
 if err != nil {
  return err
 }
 return nil
}

```

portal/student.html

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student</title>
</head>

<body>
    <h1>
        <a href="/students">Grade Book</a>
        - {{.LastName}}, {{.FirstName}}
    </h1>
    {{if gt (len .Grades) 0}}
    <table>
        <tr>
            <th>Title</th>
            <th>Type</th>
            <th>Score</th>
        </tr>
        {{range .Grades}}
        <tr>
            <td>{{.Title}}</td>
            <td>{{.Type}}</td>
            <td>{{.Score}}</td>
        </tr>
        {{end}}
    </table>
    {{else}}
    <em>No grades available</em>
    {{end}}

    <fieldset>
        <legend>Add a Grade</legend>
        <form action="/students/{{.ID}}/grades" method="POST">
            <table>
                <tr>
                    <td>Title</td>
                    <td>
                        <input type="text" name="Title">
                    </td>
                </tr>
                <tr>
                    <td>Type</td>
                    <td>
                        <select name="Type" id="Type">
                            <option value="Test">Test</option>
                            <option value="Quiz">Quiz</option>
                            <option value="Homework">Homework</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td>Score</td>
                    <td>
                        <input type="number" min="0" max="100" step="1" name="Score">
                    </td>
                </tr>
            </table>
            <button type="submit">Submit</button>
        </form>
    </fieldset>
</body>

</html>

```

portal/students.html

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Students</title>
</head>

<body>
    <h1>Grade Book</h1>
    {{ if len .}}
    <table>
        <tr>
            <th>Name</th>
            <th>Average [%]</th>
        </tr>
        {{range .}}
        <tr>
            <td>
                <a href="/students/{{.ID}}">{{.LastName}}, {{.FirstName}}</a>
            </td>
            <td>
                {{printf "%.1f%%" .Average}}
            </td>
        </tr>
        {{end}}
    </table>
    {{else}}
    <em>No students found</em>
    {{end}}
</body>

</html>

```

registry/

```go
package registry

type Registration struct {
 ServiceName      ServiceName
 ServiceURL       string
 RequiredServices []ServiceName
 ServiceUpdateURL string
}

type ServiceName string

const (
 LogService     = ServiceName("LogService")
 GradingService = ServiceName("GradingService")
 PortalService  = ServiceName("Portald")
)

type patchEntry struct {
 Name ServiceName
 URL  string
}

type patch struct {
 Added   []patchEntry
 Removed []patchEntry
}

```

```go
package main

import (
 "context"
 "distributed/log"
 "distributed/portal"
 "distributed/registry"
 "distributed/service"
 "fmt"
 stlog "log"
)

func main() {
 err := portal.ImportTemplates()
 if err != nil {
  stlog.Fatal(err)
 }
 host, port := "localhost", "5005"
 serviceAddress := fmt.Sprintf("http://%s:%s", host, port)

 r := registry.Registration{
  ServiceName: registry.PortalService,
  ServiceURL:  serviceAddress,
  RequiredServices: []registry.ServiceName{
   registry.LogService,
   registry.GradingService,
  },
  ServiceUpdateURL: serviceAddress + "/services",
 }
 ctx, err := service.Start(
  context.Background(),
  host,
  port,
  r,
  portal.RegisterHandlers,
 )

 if err != nil {
  fmt.Println("service Start err", err)
  stlog.Fatalln(err)
 }
 if logProvider, err := registry.GetProvider(registry.LogService); err != nil {
  log.SetClientLogger(logProvider, r.ServiceName)
 }
 <-ctx.Done()

 fmt.Println("Shutting down protal service")
}

```

 启动

```bash
distributed/cmd/registryservice via 🐹 v1.20.3 via 🅒 base took 4m 51.1s 
➜ go run .

distributed/cmd/logservice via 🐹 v1.20.3 via 🅒 base took 4m 48.4s 
➜ go run .

distributed/cmd/gradingservice via 🐹 v1.20.3 via 🅒 base took 4m 44.3s 
➜ go run .

distributed/cmd/partal via 🐹 v1.20.3 via 🅒 base 
➜ go run .

```

访问 <http://localhost:5005/>

![image-20230520111859166](../../../Library/Application Support/typora-user-images/image-20230520111859166.png)

```bash
Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ tree
.
├── cmd
│   ├── gradingservice
│   │   └── main.go
│   ├── logservice
│   │   ├── distributed.log
│   │   └── main.go
│   ├── partal
│   │   └── main.go
│   └── registryservice
│       └── main.go
├── go.mod
├── grades
│   ├── grades.go
│   ├── mockdata.go
│   └── server.go
├── log
│   ├── client.go
│   └── server.go
├── portal
│   ├── handlers.go
│   ├── student.html
│   ├── students.html
│   └── templates.go
├── registry
│   ├── client.go
│   ├── registration.go
│   └── server.go
└── service
    └── service.go

11 directories, 19 files

Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ 
```

### 4.2 状态监控

```bash
Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ tree
.
├── cmd
│   ├── gradingservice
│   │   └── main.go
│   ├── logservice
│   │   ├── distributed.log
│   │   └── main.go
│   ├── partal
│   │   └── main.go
│   └── registryservice
│       └── main.go
├── go.mod
├── grades
│   ├── grades.go
│   ├── mockdata.go
│   └── server.go
├── log
│   ├── client.go
│   └── server.go
├── portal
│   ├── handlers.go
│   ├── student.html
│   ├── students.html
│   └── templates.go
├── registry
│   ├── client.go
│   ├── registration.go
│   └── server.go
└── service
    └── service.go

11 directories, 19 files

Code/go/distributed via 🐹 v1.20.3 via 🅒 base 
➜ 
```

registry/server.go

```go
package registry

import (
 "bytes"
 "encoding/json"
 "fmt"
 "io"
 "log"
 "net/http"
 "sync"
 "time"
)

const ServerPort = ":3000"
const ServiceURL = "http://localhost" + ServerPort + "/services"

type registry struct {
 registrations []Registration
 mutex         *sync.RWMutex
}

func (r *registry) add(reg Registration) error {
 r.mutex.Lock()
 r.registrations = append(r.registrations, reg)
 r.mutex.Unlock()
 err := r.sendRequiredServices(reg)
 r.notify(patch{
  Added: []patchEntry{
   {
    Name: reg.ServiceName,
    URL:  reg.ServiceURL,
   },
  },
 })
 return err
}

func (r registry) notify(fullPatch patch) {
 r.mutex.RLock()
 defer r.mutex.RUnlock()
 for _, reg := range r.registrations {
  go func(reg Registration) {
   for _, reqService := range reg.RequiredServices {
    p := patch{Added: []patchEntry{}, Removed: []patchEntry{}}
    sendUpdate := false
    for _, added := range fullPatch.Added {
     if added.Name == reqService {
      p.Added = append(p.Added, added)
      sendUpdate = true
     }
    }
    for _, removed := range fullPatch.Removed {
     if removed.Name == reqService {
      p.Removed = append(p.Removed, removed)
      sendUpdate = true
     }
    }
    if sendUpdate {
     err := r.sendPatch(p, reg.ServiceUpdateURL)
     if err != nil {
      log.Println(err)
      return
     }
    }
   }
  }(reg)
 }
}

func (r registry) sendRequiredServices(reg Registration) error {
 r.mutex.RLock()
 defer r.mutex.RUnlock()

 var p patch
 for _, serviceReg := range r.registrations {
  for _, reqService := range reg.RequiredServices {
   if serviceReg.ServiceName == reqService {
    p.Added = append(p.Added, patchEntry{
     Name: serviceReg.ServiceName,
     URL:  serviceReg.ServiceURL,
    })
   }
  }
 }
 err := r.sendPatch(p, reg.ServiceUpdateURL)
 if err != nil {
  return err
 }
 return nil
}

func (r registry) sendPatch(p patch, url string) error {
 d, err := json.Marshal(p)
 if err != nil {
  return err
 }
 _, err = http.Post(url, "application/json", bytes.NewReader(d))
 if err != nil {
  return err
 }
 return nil
}

func (r *registry) remove(url string) error {
 for i := range reg.registrations {
  if reg.registrations[i].ServiceURL == url {
   r.notify(patch{
    Removed: []patchEntry{
     {
      Name: r.registrations[i].ServiceName,
      URL:  r.registrations[i].ServiceURL,
     },
    },
   })

   r.mutex.Lock()
   reg.registrations = append(reg.registrations[:i], reg.registrations[i+1:]...)
   r.mutex.Unlock()
   return nil
  }
 }
 return fmt.Errorf("service at URL %s not found", url)
}

func (r *registry) heartbeat(frequency time.Duration) {
 for {
  var wg sync.WaitGroup
  for _, reg := range r.registrations {
   wg.Add(1)
   go func(reg Registration) {
    defer wg.Done()
    success := true
    for attemps := 0; attemps < 3; attemps++ {
     res, err := http.Get(reg.HeartbeatURL)
     if err != nil {
      log.Printf("heartbeat error: %v", err)
     } else if res.StatusCode == http.StatusOK {
      log.Printf("Heartbeat check passed for %v", reg.ServiceName)
      if !success {
       r.add(reg)
      }
      break
     }
     log.Printf("Heartbeat check failed for %v", reg.ServiceName)
     if success {
      success = false
      r.remove(reg.ServiceURL)
     }
     time.Sleep(1 * time.Second)
    }
   }(reg)
   wg.Wait()
   time.Sleep(frequency)
  }
 }
}

var once sync.Once

func SetupRegistryService() {
 once.Do(func() {
  go reg.heartbeat(3 * time.Second)
 })
}

var reg = registry{
 registrations: make([]Registration, 0),
 mutex:         new(sync.RWMutex),
}

type RegistryService struct{}

func (s RegistryService) ServeHTTP(w http.ResponseWriter, r *http.Request) {
 log.Println("Request received")
 switch r.Method {
 case http.MethodPost:
  dec := json.NewDecoder(r.Body)
  var r Registration
  err := dec.Decode(&r)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusBadRequest)
   return
  }
  log.Printf("Adding service: %v with URL: %s\n", r.ServiceName, r.ServiceURL)
  err = reg.add(r)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusBadRequest)
   return
  }
 case http.MethodDelete:
  payload, err := io.ReadAll(r.Body)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusInternalServerError)
   return
  }
  url := string(payload)
  log.Printf("Removing service at URL: %s", url)
  err = reg.remove(url)
  if err != nil {
   log.Println(err)
   w.WriteHeader(http.StatusInternalServerError)
   return
  }
 default:
  w.WriteHeader(http.StatusMethodNotAllowed)
  return
 }
}

```

registry/client.go

```go
package registry

import (
 "bytes"
 "encoding/json"
 "fmt"
 "log"
 "math/rand"
 "net/http"
 "net/url"
 "sync"
)

func RegisterService(r Registration) error {
 HeartbeatURL, err := url.Parse(r.HeartbeatURL)
 if err != nil {
  return err
 }
 http.HandleFunc(HeartbeatURL.Path, func(w http.ResponseWriter, r *http.Request) {
  w.WriteHeader(http.StatusOK)
 })

 serviceUpdateURL, err := url.Parse(r.ServiceUpdateURL)
 if err != nil {
  return err
 }
 http.Handle(serviceUpdateURL.Path, &serviceUpdateHanlder{})

 buf := new(bytes.Buffer)
 enc := json.NewEncoder(buf)
 err = enc.Encode(r)
 if err != nil {
  return err
 }

 res, err := http.Post(ServiceURL, "application/json", buf)
 if err != nil {
  return err
 }

 if res.StatusCode != http.StatusOK {
  return fmt.Errorf("failed to register service. Registry service "+
   "responded with code %v", res.StatusCode)
 }

 return nil
}

type serviceUpdateHanlder struct{}

func (suh serviceUpdateHanlder) ServeHTTP(w http.ResponseWriter, r *http.Request) {
 if r.Method != http.MethodPost {
  w.WriteHeader(http.StatusMethodNotAllowed)
  return
 }
 dec := json.NewDecoder(r.Body)
 var p patch
 err := dec.Decode(&p)
 if err != nil {
  log.Println(err)
  w.WriteHeader(http.StatusBadRequest)
  return
 }
 fmt.Printf("Update received %v\n", p)
 prov.Update(p)
}

func ShutdownService(url string) error {
 req, err := http.NewRequest(http.MethodDelete, ServiceURL, bytes.NewBuffer([]byte(url)))
 if err != nil {
  return err
 }
 req.Header.Add("Content-Type", "text/plain")
 res, err := http.DefaultClient.Do(req)
 if err != nil {
  return err
 }
 if res.StatusCode != http.StatusOK {
  return fmt.Errorf("failed to deregister service. Registry "+
   "service responded with code %v", res.StatusCode)
 }
 return nil
}

type providers struct {
 services map[ServiceName][]string
 mutex    *sync.RWMutex
}

func (p *providers) Update(pat patch) {
 p.mutex.Lock()
 defer p.mutex.Unlock()

 for _, patchEntry := range pat.Added {
  if _, ok := p.services[patchEntry.Name]; !ok {
   p.services[patchEntry.Name] = make([]string, 0)
  }
  p.services[patchEntry.Name] = append(p.services[patchEntry.Name], patchEntry.URL)
 }

 for _, patchEntry := range pat.Removed {
  if providerURLs, ok := p.services[patchEntry.Name]; ok {
   for i := range providerURLs {
    if providerURLs[i] == patchEntry.URL {
     p.services[patchEntry.Name] = append(providerURLs[:i], providerURLs[i+1:]...)
    }
   }
  }
 }
}

func (p providers) get(name ServiceName) (string, error) {
 providers, ok := p.services[name]
 if !ok {
  return "", fmt.Errorf("no providers available for service %v", name)
 }
 idx := int(rand.Float32() * float32(len(providers)))
 return providers[idx], nil
}

func GetProvider(name ServiceName) (string, error) {
 return prov.get(name)
}

var prov = providers{
 services: make(map[ServiceName][]string),
 mutex:    new(sync.RWMutex),
}

```

registry/registration.go

```go
package registry

type Registration struct {
 ServiceName      ServiceName
 ServiceURL       string
 RequiredServices []ServiceName
 ServiceUpdateURL string
 HeartbeatURL     string
}

type ServiceName string

const (
 LogService     = ServiceName("LogService")
 GradingService = ServiceName("GradingService")
 PortalService  = ServiceName("Portald")
)

type patchEntry struct {
 Name ServiceName
 URL  string
}

type patch struct {
 Added   []patchEntry
 Removed []patchEntry
}

```

registryservice/main.go

```go
package main

import (
 "context"
 "distributed/registry"
 "fmt"
 "log"
 "net/http"
)

func main() {
 registry.SetupRegistryService()
 http.Handle("/services", &registry.RegistryService{})

 ctx, cancel := context.WithCancel(context.Background())
 defer cancel()

 var srv http.Server
 srv.Addr = registry.ServerPort

 go func() {
  log.Println(srv.ListenAndServe())
  cancel()
 }()

 go func() {
  fmt.Println("Registry service started. Press any key to stop.")
  var s string
  fmt.Scanln(&s)
  srv.Shutdown(ctx)
  cancel()
 }()

 <-ctx.Done()
 fmt.Println("Shutting down registry service")
}

```

logservice/main.go

```go
package main

import (
 "context"
 "distributed/log"
 "distributed/registry"
 "distributed/service"
 "fmt"
 stlog "log"
)

func main() {
 log.Run("./distributed.log")
 host, port := "localhost", "4000"
 serviceAddress := fmt.Sprintf("http://%s:%s", host, port)

 r := registry.Registration{
  ServiceName:      registry.LogService,
  ServiceURL:       serviceAddress,
  RequiredServices: make([]registry.ServiceName, 0),
  ServiceUpdateURL: serviceAddress + "/services",
  HeartbeatURL:     serviceAddress + "/heartbeat",
 }
 ctx, err := service.Start(
  context.Background(),
  host,
  port,
  r,
  log.RegisterHandlers,
 )

 if err != nil {
  fmt.Println("err", err)
  stlog.Fatalln(err)
 }
 <-ctx.Done()

 fmt.Println("Shutting down log service")
}

```

gradingservice/main.go

```go
package main

import (
 "context"
 "distributed/grades"
 "distributed/log"
 "distributed/registry"
 "distributed/service"
 "fmt"
 stlog "log"
)

func main() {
 host, port := "localhost", "6000"
 serviceAddress := fmt.Sprintf("http://%s:%s", host, port)

 r := registry.Registration{
  ServiceName:      registry.GradingService,
  ServiceURL:       serviceAddress,
  RequiredServices: []registry.ServiceName{registry.LogService},
  ServiceUpdateURL: serviceAddress + "/services",
  HeartbeatURL:     serviceAddress + "/heartbeat",
 }
 ctx, err := service.Start(
  context.Background(),
  host,
  port,
  r,
  grades.RegisterHandlers,
 )

 if err != nil {
  stlog.Fatal(err)
 }

 if logProvider, err := registry.GetProvider(registry.LogService); err == nil {
  fmt.Printf("Logging service found at: %s\n", logProvider)
  log.SetClientLogger(logProvider, r.ServiceName)
 }

 <-ctx.Done()

 fmt.Println("Shutting down grading service")
}

```

partal/main.go

```go
package main

import (
 "context"
 "distributed/log"
 "distributed/portal"
 "distributed/registry"
 "distributed/service"
 "fmt"
 stlog "log"
)

func main() {
 err := portal.ImportTemplates()
 if err != nil {
  stlog.Fatal(err)
 }
 host, port := "localhost", "5005"
 serviceAddress := fmt.Sprintf("http://%s:%s", host, port)

 r := registry.Registration{
  ServiceName: registry.PortalService,
  ServiceURL:  serviceAddress,
  RequiredServices: []registry.ServiceName{
   registry.LogService,
   registry.GradingService,
  },
  ServiceUpdateURL: serviceAddress + "/services",
  HeartbeatURL:     serviceAddress + "/heartbeat",
 }
 ctx, err := service.Start(
  context.Background(),
  host,
  port,
  r,
  portal.RegisterHandlers,
 )

 if err != nil {
  fmt.Println("service Start err", err)
  stlog.Fatalln(err)
 }
 if logProvider, err := registry.GetProvider(registry.LogService); err != nil {
  log.SetClientLogger(logProvider, r.ServiceName)
 }
 <-ctx.Done()

 fmt.Println("Shutting down protal service")
}

```

运行

```bash
distributed/cmd/registryservice via 🐹 v1.20.3 via 🅒 base took 22m 50.5s 
➜ go run .

distributed/cmd/logservice via 🐹 v1.20.3 via 🅒 base 
➜ go run .

distributed/cmd/gradingservice via 🐹 v1.20.3 via 🅒 base took 22m 32.1s 
➜ go run .

distributed/cmd/partal via 🐹 v1.20.3 via 🅒 base 
➜ go run .
```

客户端 ->  portal -> 注册服务   Log 服务    Grading 服务
