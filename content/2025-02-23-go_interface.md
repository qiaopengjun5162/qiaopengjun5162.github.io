+++
title = "Go Interface 源码分析（Go 1.24）"
description = "深入探索 Go 1.24 中接口的底层实现，包括 eface、iface 和类型元数据的源码分析"
date = 2025-02-23 21:46:31+08:00
[taxonomies]
categories = ["Go"]
tags = ["Go"]

+++

<!-- more -->

# Go Interface 1.24

## 源码分析

#### **源码位置**

- **`eface` 和 `iface` 定义**：
  - 文件：runtime/runtime2.go
  - GitHub 链接：[runtime/runtime2.go](https://github.com/golang/go/blob/master/src/runtime/runtime2.go)
  - [iface](https://github.com/golang/go/blob/e7cd4979bec709b6d9c7428912e66348405e2a51/src/runtime/runtime2.go#L179)
  - [eface](https://github.com/golang/go/blob/e7cd4979bec709b6d9c7428912e66348405e2a51/src/runtime/runtime2.go#L184)

- **`_type` 定义**：
  - 文件：`runtime/type.go`  
  - GitHub 链接：[runtime/type.go#L21](https://github.com/golang/go/blob/master/src/runtime/type.go#L21)
- **`abi.Type` 定义**：
  - 文件：`internal/abi/type.go`  
  - GitHub 链接：[internal/abi/type.go](https://github.com/golang/go/blob/e7cd4979bec709b6d9c7428912e66348405e2a51/src/internal/abi/type.go#L20)

### 核心结构体

#### `eface` - 空接口的底层表示

- **定义**：

<https://github.com/golang/go/blob/e7cd4979bec709b6d9c7428912e66348405e2a51/src/runtime/runtime2.go#L184>

```go
type eface struct {
 _type *_type
 data  unsafe.Pointer
}
```

### `eface`**字段解析**

- `_type *_type`：

  - 指向类型元数据的指针，定义在 runtime/type.go。
    - **类型元数据**：
      - 在 Go 的运行时，类型元数据是对某种数据类型的描述，例如 int、string、结构体等。
      - 这些信息包括类型的大小、对齐方式、种类（kind，如 int、struct）等。
    - **指针**：
      - *_type 表示这个字段存储的是一个地址（指针），指向内存中某个_type 类型的数据。

  - _type 包含类型的大小、对齐方式、种类（kind）等信息。

  - 作用：标识空接口（interface{}）中存储的值的具体类型。
  - `type _type = abi.Type`

- `data unsafe.Pointer`：

  - 指向值的内存地址，用 unsafe.Pointer 表示任意类型的值。

  - 作用：存储实际数据的指针。

<https://github.com/golang/go/blob/master/src/runtime/type.go#L21>

```go
type _type = abi.Type
```

#### **1. `type _type = abi.Type` 的含义**

- `type _type`：

  - 这是一个类型别名（type alias），将 `_type` 定义为 `abi.Type` 的别名。

  - 在 Go 中，`type NewName = ExistingType` 表示 `NewName` 是 `ExistingType` 的另一个名字，两者完全等价。

- `abi.Type`：
  - `abi.Type` 是定义在 `internal/abi/type.go` 中的结构体，表示类型元数据的具体实现。
  - 源码（`internal/abi/type.go`）：

<https://github.com/golang/go/blob/master/src/internal/abi/type.go>

```go
// Type is the runtime representation of a Go type.
//
// Be careful about accessing this type at build time, as the version
// of this type in the compiler/linker may not have the same layout
// as the version in the target binary, due to pointer width
// differences and any experiments. Use cmd/compile/internal/rttype
// or the functions in compiletype.go to access this type instead.
// (TODO: this admonition applies to every type in this package.
// Put it in some shared location?)
type Type struct {
 Size_       uintptr
 PtrBytes    uintptr // number of (prefix) bytes in the type that can contain pointers
 Hash        uint32  // hash of type; avoids computation in hash tables
 TFlag       TFlag   // extra type information flags
 Align_      uint8   // alignment of variable with this type
 FieldAlign_ uint8   // alignment of struct field with this type
 Kind_       Kind    // enumeration for C
 // function for comparing objects of this type
 // (ptr to object A, ptr to object B) -> ==?
 Equal func(unsafe.Pointer, unsafe.Pointer) bool
 // GCData stores the GC type data for the garbage collector.
 // Normally, GCData points to a bitmask that describes the
 // ptr/nonptr fields of the type. The bitmask will have at
 // least PtrBytes/ptrSize bits.
 // If the TFlagGCMaskOnDemand bit is set, GCData is instead a
 // **byte and the pointer to the bitmask is one dereference away.
 // The runtime will build the bitmask if needed.
 // (See runtime/type.go:getGCMask.)
 // Note: multiple types may have the same value of GCData,
 // including when TFlagGCMaskOnDemand is set. The types will, of course,
 // have the same pointer layout (but not necessarily the same size).
 GCData    *byte
 Str       NameOff // string form
 PtrToThis TypeOff // type for pointer to this type, may be zero
}

// A Kind represents the specific kind of type that a Type represents.
// The zero Kind is not a valid kind.
type Kind uint8

// TFlag is used by a Type to signal what extra type information is
// available in the memory directly following the Type value.
type TFlag uint8

// NameOff is the offset to a name from moduledata.types.  See resolveNameOff in runtime.
type NameOff int32

// TypeOff is the offset to a type from moduledata.types.  See resolveTypeOff in runtime.
type TypeOff int32
```

**字段解析**：

- Size_：类型的大小（字节）。
- Hash：类型的哈希值，用于快速比较。
- Kind_：类型种类（如 KindInt、KindString）。
- Equal：比较两个值是否相等的函数。

#### **2. 为什么是别名？**

- 在 `runtime/type.go`中使用 `type _type = abi.Type`，而不是直接定义 `_type`，是为了：
  - **复用 `abi` 包的类型定义**：`abi.Type` 是 Go 内部抽象接口（ABI，Application Binary Interface）的一部分，统一了类型的表示。
  - **保持一致性**：运行时和编译器共享相同的类型描述。
- 因此，`runtime/type.go` 中的 `_type` 实际上是 `abi.Type` 的别名。

#### **3. 完整链条**

- `eface` 中的`_type *_type`：
  - 字段名：_type。
  - 类型：`*_type`，即指向 `_type` 的指针。
- `runtime/type.go` 中的 `_type`：
  - `_type` 是 `abi.Type` 的别名。
- `internal/abi/type.go` 中的 `abi.Type`：
  - 具体的结构体，描述类型元数据。

所以，`eface` 的 `_type` 字段是一个指针，指向 abi.Type 类型的实例。

完整路径：`eface._type` -> `runtime/type.go:_type` -> `internal/abi/type.go:Type`

#### `iface` - 非空接口的底层表示

- 定义

<https://github.com/golang/go/blob/e7cd4979bec709b6d9c7428912e66348405e2a51/src/runtime/runtime2.go#L179>

```go
type iface struct {
 tab  *itab
 data unsafe.Pointer
}
```

**字段解析**：

- `tab *itab`：

  - **字段名**：`tab`。

  - **类型**：`*itab`，指向方法表的指针。

  - **含义**：`itab` 存储接口类型和具体类型的方法映射，见 `runtime/iface.go`。

  - **作用**：支持非空接口的方法调用。

- `data unsafe.Pointer`：

  - 同 eface，存储值的指针。

**与 `eface` 的区别**：

- `eface` 用于空接口（`interface{}`），无方法表。
- `iface` 用于非空接口（如 `interface{ Write() }`），通过 `itab` 支持动态分派。

```go
type itab = abi.ITab
```

<https://github.com/golang/go/blob/fba83cdfc6c4818af5b773afa39e457d16a6db7a/src/runtime/runtime2.go#L952>

```go
// The first word of every non-empty interface type contains an *ITab.
// It records the underlying concrete type (Type), the interface type it
// is implementing (Inter), and some ancillary information.
//
// allocated in non-garbage-collected memory
type ITab struct {
 Inter *InterfaceType // 接口类型
 Type  *Type      // 具体类型
 Hash  uint32       // copy of Type.Hash. Used for type switches.
 Fun   [1]uintptr   // variable sized. fun[0]==0 means Type does not implement Inter.
}
```

<https://github.com/golang/go/blob/fba83cdfc6c4818af5b773afa39e457d16a6db7a/src/internal/abi/iface.go#L14>

## 参考

- <https://go.dev/doc/effective_go#interfaces>
- <https://research.swtch.com/interfaces>
- <https://github.com/golang/go/blob/master/src/runtime/iface.go>
- <https://github.com/golang/go/blob/master/src/runtime/runtime2.go>
