+++
title = "深入 Rust 内存模型：栈、堆、所有权与底层原理"
description = "深入 Rust 内存模型：栈、堆、所有权与底层原理"
date = 2025-07-19T01:14:30Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 深入 Rust 内存模型：栈、堆、所有权与底层原理

Rust 语言的性能与安全，并非魔法，而是源于其背后一套经过精心设计的、严谨的 内存模型。理解这个模型，是掌握 Rust 精髓、写出高质量代码的必经之路。然而，许多开发者常常陷入对所有权、生命周期等规则的零散学习，缺乏一个系统性的认知框架。

本文旨在进行一次系统性的 深入 探索。我们将不再孤立地看待每一个概念，而是将它们统一在 Rust 内存模型 的宏大视角下，自下而上地构建你的知识体系。

我们将从构成内存世界的基本元素（值、变量、指针）出发，深入剖析程序运行时两大核心区域——栈 (Stack) 与 堆 (Heap) 的运作机制与性能差异；紧接着，我们将揭示 Rust 最具革命性的 所有权 (Ownership) 系统，是如何作为该模型的核心抽象层，在编译期保证内存安全的；最后，我们将下探到更深的层次，触及支撑这一切的 底层原理，包括静态内存、虚拟内存与操作系统交互，让你明白这一切并非空中楼阁。

读完本文，你将获得的不仅是零散的知识点，而是一幅完整、连贯的 Rust 内存心智地图。

## 内存

### 值

- 值：类型 + 类型值域中的一个元素
  - 例如：true
- 通过它的类型表示，可以转化为字节序列
  - 6，u8 类型，数学整数；内存中：0x06
  - str "Hello World" 字符串域的值，它的表示是 UTF8编码
- 值的含义是独立于存储它字节的位置的

### 变量

- 值会存储到一个地方（这个地方可以容纳值）
- 可以在 Stack、Heap 或其它地方
- 最常见的存储值的地方就是变量，它是 Stack 上面的一个被命名的值的槽

### 指针

- 指针是一个值，值里面存放的是一块内存的地址，指针指向某个地方
- 指针可以被解引用（dereference）来访问它指向的内存里存放的值
- 可以把同一个指针存放在不同的变量里，也就是说多个变量可以间接的引用内存中的同一个地方，也就是相同的底层的值

例子

```rust
fn main() {
  let x = 42;
  let y = 43;
  let var1 = &x;
  let mut var2 = &x;
  var2 = &y;
  
  let s = "Hello World"; // 指针 执行变量第一个字符的位置
}
```

### 深入变量

- 高级模型：生命周期、借用等角度
- 低级模型：不安全代码、原始指针角度

### 变量的高级模型

- 变量就是给值的一个名称
- 当把值赋给一个变量的时候，这个值从那时起就由该变量命名了
  - let Dave = 1234;
- 当变量被访问的时候，可以从变量的上次访问到这次访问画一条线，从而在两次访问之间建立了依赖关系
- 如果变量被移动了，就不能从它那画线了

```rust
fn main() {
  let a = String::from("123");
  
  let b = a;
  
  println!("{}", b);
  // println!("{}", a);
}
```

- 在该模型里，变量只会在它持有合法值的时候才存在
- 如果变量的值未初始化，或者已经被移动了，那就无法从该变量画线了
- 使用该模型，整个程序会有许多依赖线组成，这些线叫做 flow
- 每个 flow 都在追踪一个值的特定实例的生命周期
- 当有分支存在时，flow 可以分叉或合并，每个分叉都在追踪该值的不同的生命周期
- 在程序中的任何给定点，编译器可以检查所有的 flow 是否可以互相兼容、并行存在：
  - 例如：一个值不可能有两个具有可变访问的并行 flow；也不能一个flow借用了一个值，但却没有 flow 拥有该值

```rust
fn main() {
  let mut a = 123;
  let b = &a;
  let c = &mut a; // 报错
  println!("{}", b);
  println!("{}", c);
}
```

### 变量的低级模型

- 变量会给哪些可能（不）存储合法值的内存地点进行命名
- 可以把变量想象为值的槽：当你赋值的时候，槽就装满了，而它里面原来的值（如果有的话）就被丢弃或替换了
- 当访问它时，编译器检查槽是不是空的；如果是空的，就说明变量未初始化，或者它的值被移动了
- 指向变量的指针，其实是指向变量的幕后内存，并通过解引用可以获得它的值
- 在本例中，我们忽略了CPU寄存器，并将其视为优化。实际上，如果变量不需要内存地址，编译器可以使用寄存器而不是内存区域来存放该变量

```rust
let dave = 123;
dave = 456;
```

### 内存区域

- 有许多内存区域，并不是都在 DRAM 上
- 三个比较重要的区域：Stack、heap、static 内存
- stack 和 heap：
  - stack 块
  - heap 慢

### stack 内存

- “有疑问时，首选 Stack”
  - 想把数据放在 Stack，编译器必须知道类型的大小
  - 换句话说：“有疑问时，使用实现了 Sized 的类型”
- Stack 是一段内存，程序把它作为一个暂存空间，用于函数调用
- 为什么叫 Stack？因为在Stack 上的条目是 LIFO（后进先出）

### Stack Frame

- 每个函数被调用，在 Stack 的顶部都会分配一个连续的内存块，它叫做 Stack Frame（栈帧）
- 接近 Stack 底部附近是 main 函数的 Frame，随着函数的调用，其余的 Frame 都推到了 Stack 上
- 函数的 frame 包含函数里所有的变量，以及函数所带的参数
- 当函数返回时，它的 frame 就被回收了
  - 构成函数本地变量值的那些字节不会立即擦除，但访问它们也是不安全的，因为它们可能被后续的函数调用所重写（如果后续函数调用的 frame 与回收的这个有重合的话）
  - 但即使没有被重写，它们也可能包含无法合法使用的值。例如函数返回后被移动的值

### Stack Pointer

- 随着程序的执行，CPU里有一个游标会随着更新，它会反映出当前 Stack frame 的当前地址，这个游标叫 stack pointer（stack 指针）
- 随着函数内不断的调用函数，stack 就会增长，而 stack pointer 的值会减少；当函数返回 stack pointer 的值会增加

### Stack Frame

- Stack Frame 也叫 activation frames 或 allocation record
- 每个 stack frame 的大小是不同的
- 在函数调用期间，Stack frame 会包含函数的状态。当一个函数在另外一个函数内调用时，原来的函数的值会被及时冻结
- stack frame 为函数参数，指向原来调用站的指针，以及本地变量（不包括在 heap 上分配的数据）提供空间
- Stack 的主要任务是为本地变量创造空间，为什么 stack 快？
  - 因为函数的所有变量在内存里都是紧挨着的

```rust
fn main() {
  let pw = "justok";
  let is_strong = is_strong(pw);
}

// &str -> Stack; String -> Heap

//fn is_strong(password: String) -> bool {
//  password.len() > 5
//}

fn is_strong<T: AsRef<str>>(password: T) -> bool {
  password.as_ref().len() > 5
}

fn is_strong<T: Into<String>>(password: T) -> bool {
  password.into().len() > 5
}
```

### Stack

- Stack Frames，它们最终也会消失这个事实，与Rust生命周期的概念是密切相关的。
- 任何在 stack 上的 frame 里存储的变量，在 frame 消失后，它就无法访问了
  - 所以任何到这些变量的引用的生命周期，最多只能与 frame 的生命周期一样长

### Heap 内存

- Heap 意味着混乱
- Heap 是一个内存池，并没有绑定到当前程序的调用栈
- Heap 是为在编译时没有已知大小的类型准备的
- 什么叫在编译时大小不已知？
  - 一些类型随着时间会变大或变小，例如 String、`Vec<T>`
  - 另一些类型的大小不会改变，但是无法告诉编译器需要分配多少内存
  - 这些都叫做动态大小的类型，例如 [T] (DST)
  - 另一个例子是 trait 对象，它允许程序员来模拟一些动态语言的特性：通过允许将多个类型放进一个容器
- Heap 允许你显示的分配连续的内存块。当这么做时，你会得到一个指针，它指向内存块开始的地方
- Heap 内存中的值会一直有效，直到你对它显示的释放
- 如果你想让值活得比当前函数 frame 的生命周期还长，就很有用
  - 如果值是函数的返回值，那么调用函数可以在它的 stack 上留一些空间给被调用函数让它把值在返回前写入进去

### Heap 线程安全的例子

- 但是如果想把值送到另一个线程，当前线程可能根本无法与那个线程共享 stack frames，你就可以把它存放在 heap上
- 因为函数返回时 heap 上的分配并不会消失，所以你在一个地方为值分配内存，把指向它的指针传给另一个线程，就可以让那个线程继续安全的操作于这个值。
- 换一种说法：当你分配 heap 内存时，结果指针会有一个无约束的生命周期，你的程序让它活多久都行。

### Heap 交互机制

- Heap 上面的变量必须通过指针访问（例子）

```rust
fn main() {
  let a: i32 = 40; // stack
  let b: Box<i32> = Box::new(60); // Heap
  
  //let result = a + b; // 报错
  
  let result = a + *b;
  
  println!("{} + {} = {}", a, b, a + *b);
}
```

- Rust 里与Heap交互的首要机制就是 Box类型
- 当 Box::new(value) 时，值就会放在 heap 上，返回的 (`Box<T>`) 就是指向 heap 上该值的指针。当 box 被丢弃时，内存就被释放
- 如果忘记释放 heap 内存，就会导致内存泄漏
- 有时你就想让内存泄漏：
  - 例如有一个只读的配置，整个程序都需要访问它。就可以把它分配在 heap 上，通过 Box::leak 得到一个 ’static 引用，从而显式的让其进行泄漏

```rust
use std::mem::drop;

fn main() {
  let a = Box::new(1);
  let b = Box::new(1);
  let c = Box::new(1);
  
  let result1 = *a + *b + *c;
  
  drop(a);
  let d = Box::new(1);
  let result2 = *b + *c + *d;
  
  println!("{} {}", result1, result2);
}
```

### Static 静态内存

- Static 内存实际是一个统称，它指的是程序编译后的文件中几个密切相关的区域
  - 当程序执行时，这些区域会自动加载到你程序的内存里
- Static 内存里的值在你的程序的整个执行期间会一直存活
- 程序的 Static 内存是包含程序二进制代码的（通常映射为只读的）
  - 随着程序的执行，它会在本文段的二进制代码中挨个指令进行遍历，而当函数被调用时就进行跳跃
- Static 内存会持有使用Static声明的变量的内存，也包括某些常量值，例如字符串

### ‘static

- ’static 是特殊的生命周期
  - 它的名字就是来自于 static 内存区，它将引用标记为只要 static 内存还存在（程序关闭前），那么引用就合法
- static 变量的内存在程序开始运行时就分配了，到 static 内存中变量的引用，按定义来说，就是 ‘static 的，因为程序关闭前它不会被释放
- 反过来却不行，可以有 ’static 的引用不指向 static 内存
- 但是名称仍然适用：
  - 一旦你创建了一个 ‘static 生命周期的引用，就程序的其余部分而言，它所指向的内容都可能在 static 内存中，因为程序想要使用它多久就可以使用多久

### static 内存

- 你可能会更多遇到 ’static 生命周期而不是 static 内存
- ‘static 经常出现在类型参数的 trait bounds 上
  - 例如：T: 'static，表示类型 T 可以存活我们想要的任何时长（直到程序关闭），同时这也要求 T 是拥有所有权的和自给自足的
    - 要么它不借用其他（非 static）值
    - 要么它借用的东西也都是 “static 的”
  - 因此将一直保留到程序结束

### const 与 static 区别

- const 关键字会把紧随它的东西声明为常量

```rust
const X: i32 = 123;
```

- 常量可在编译时完全计算出来
- 在编译期间，任何引用常量的代码会被替换为常量的计算结果值
- 常量没有内存或关联其它存储（因为它不是一个地方）
- 你可以把常量理解为某个特殊值的方便的名称

### 问题

- static 内存 和 Heap 内存分别在哪？（内存条）

### 动态内存分配

- 任何时刻，运行中的程序都需要一定数量的内存。
- 当程序需要更多内存时，就需要从OS请求。这是动态内存分配（dynamic allocation）。

### 动态内存分配步骤

1. 通过系统调用从 OS 请求内存
   1. UNIX 类：alloc()
   2. Windows：HeapAlloc()
2. 使用分配的内存
3. 将不再需要的内存释放给 OS
   1. UNIX 类：free()
   2. Windows：HeapFree()

- 程序和 OS 间有一个分配器：嵌入你程序幕后的专业子程序，会经常执行优化来避免 OS 和 CPU 内的大量工作

### 为什么 Stack 和 Heap 存在性能差异

- Stack 和 Heap 只是概念而已，内存在物理上不存在这两个区域
- 访问 Stack 快：
  - 函数本地变量（都分配在 stack 上）在 RAM 上都彼此相邻（连续布局）
  - 连续布局对缓冲友好
- 访问 Heap 慢：
  - 分配在 heap 上的变量不太可能彼此相邻
  - 访问 heap 上的数据涉及对指针进行解引用（页表查找和去访问主存）

### Stack VS Heap 简单粗暴对比

| Stack | Heap | 备注           |
| ----- | ---- | -------------- |
| 简单  | 复杂 |                |
| 安全  | 危险 | 指 Unsafe Rust |
| 快    | 慢   |                |
| 死板  | 灵活 |                |

- Stack 上的数据结构在生命周期内大小不能变
- Heap 上的数据结构更灵活，因为指针可以改变

```rust
use graphics::math::{add, mul_scalar, Vec2d};
use piston_window::*;
use rand::prelude::*;
use std::alloc::{GlobalAlloc, Layout, System};
use std::time::Instant;

use std::cell::Cell;

#[global_allocator]
static ALLOCATOR: ReportingAllocator = ReportingAllocator;

struct ReportingAllocator;

// Execute a closure without logging on allocations.
pub fn run_guarded<F>(f: F)
where
    F: FnOnce(),
{
    thread_local! {
        static GUARD: Cell<bool> = Cell::new(false);
    }

    GUARD.with(|guard| {
        if !guard.replace(true) {
            f();
            guard.set(false)
        }
    })
}

unsafe impl GlobalAlloc for ReportingAllocator {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        let start = Instant::now();
        let ptr = System.alloc(layout);
        let end = Instant::now();
        let time_taken = end - start;
        let bytes_requested = layout.size();

        // eprintln!("{}\t{}", bytes_requested, time_taken.as_nanos());
        run_guarded(|| {eprintln!("{}\t{}", bytes_requested, time_taken.as_nanos())});
        ptr
    }

    unsafe fn dealloc(&self, ptr: *mut u8, layout: Layout) {
        System.dealloc(ptr, layout);
    }
}

struct World {
    current_turn: u64,
    particles: Vec<Box<Particle>>,
    height: f64,
    width: f64,
    rng: ThreadRng,
}

struct Particle {
    height: f64,
    width: f64,
    position: Vec2d<f64>,
    velocity: Vec2d<f64>,
    acceleration: Vec2d<f64>,
    color: [f32; 4],
}

impl Particle {
    fn new(world: &World) -> Particle {
        let mut rng = thread_rng();
        let x = rng.gen_range(0.0..=world.width);
        let y = world.height;
        let x_velocity = 0.0;
        let y_velocity = rng.gen_range(-2.0..0.0);
        let x_acceleration = 0.0;
        let y_acceleration = rng.gen_range(0.0..0.15);

        Particle {
            height: 4.0,
            width: 4.0,
            position: [x, y].into(),
            velocity: [x_velocity, y_velocity].into(),
            acceleration: [x_acceleration, y_acceleration].into(),
            color: [1.0, 1.0, 1.0, 0.99],
        }
    }

    fn update(&mut self) {
        self.velocity = add(self.velocity, self.acceleration);
        self.position = add(self.position, self.velocity);
        self.acceleration = mul_scalar(self.acceleration, 0.7);
        self.color[3] *= 0.995;
    }
}

impl World {
    fn new(width: f64, height: f64) -> World {
        World {
            current_turn: 0,
            particles: Vec::<Box<Particle>>::new(),
            height: height,
            width: width,
            rng: thread_rng(),
        }
    }

    fn add_shapes(&mut self, n: i32) {
        for _ in 0..n.abs() {
            let particle = Particle::new(&self);
            let boxed_particle = Box::new(particle);
            self.particles.push(boxed_particle);
        }
    }

    fn remove_shapes(&mut self, n: i32) {
        for _ in 0..n.abs() {
            let mut to_delete = None;

            let particle_iter = self.particles.iter().enumerate();

            for (i, particle) in particle_iter {
                if particle.color[3] < 0.02 {
                    to_delete = Some(i)
                }
                break;
            }

            if let Some(i) = to_delete {
                self.particles.remove(i);
            } else {
                self.particles.remove(0);
            };
        }
    }

    fn update(&mut self) {
        let n = self.rng.gen_range(-3..=3);

        if n > 0 {
            self.add_shapes(n);
        } else {
            self.remove_shapes(n);
        }

        self.particles.shrink_to_fit();
        for shape in &mut self.particles {
            shape.update();
        }
        self.current_turn += 1;
    }
}

fn main() {
    let (width, height) = (1280.0, 960.0);
    let mut window: PistonWindow = WindowSettings::new("particles", [width, height])
        .exit_on_esc(true)
        .build()
        .expect("Could not create a window.");

    let mut world = World::new(width, height);
    world.add_shapes(1000);

    while let Some(event) = window.next() {
        world.update();

        window.draw_2d(&event, |ctx, renderer, _device| {
            clear([0.15, 0.17, 0.17, 0.9], renderer);

            for s in &mut world.particles {
                let size = [s.position[0], s.position[1], s.width, s.height];
                rectangle(s.color, size, ctx.transform, renderer);
            }
        });
    }
}

```

### Cargo.toml

```toml
[package]
name = "particles"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
piston2d-graphics = "0.43.0"
piston_window = "0.128.0"
rand = "0.8.5"

```

### 问题：运行Rust程序报错   51287 illegal hardware instruction  cargo run

```bash
➜ cargo run                
    Finished dev 【unoptimized + debuginfo】 target(s) in 0.18s
     Running `target/debug/particles`
【1】    29813 illegal hardware instruction  cargo run
```

### 解决

<https://github.com/rust-in-action/code/pull/106>

<https://github.com/rust-in-action/code/commit/a0731bc66504fdd74f4d548059cb6ad2fb34539a>

### 运行

```bash
cargo run

cargo run -q 2> alloc.tsv
```

<https://jupyter.org/install>

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt 
from matplotlib import font_manager
plt.rcParams["font.sans-serif"]=["Songti SC"]
df = pd.read_csv('/Users/qiaopengjun/rust/particles/alloc.tsv', sep='\t', header=None)
df.head()
df.columns
df.info
plt.figure(figsize=(25, 7))

plt.scatter(df[0], df[1], s=12, facecolors='none', edgecolors='b')
plt.xlim(0, 20000)
plt.ylim(0, 20000)
plt.xlabel('分配内存大小(byte)')
plt.ylabel('分配持续时间(ns)')
plt.show()

```

### 虚拟内存

- 程序的内存视图，程序可访问的所有数据都是由操作系统在其地址空间中提供。
- 直觉上，程序的内存就是一系列字节，从开始位置 0 到结束位置 n
  - 例如：程序汇报使用了 100 KB 的 RAM，那么 n 就应该是在 100000 左右

### 例子

```rust
fn main() {
  let mut n_nonzero = 0;
  
  for i in 0..10000 { // 当 i = 0 None 指针
    let ptr = i as *const u8;
    let byte_at_addr = unsafe {*ptr};
    
    if byte_at_addr != 0 {
      n_nonzero += 1;
    }
  }
  
  println!("内存中的非 0 字节：{}", n_nonzero);
}
```

- segmentation fault：当 CPU 或 OS 检测到程序试图请求非法（无权访问）内存地址时，所产生的错误

### 修改之后

```rust
static GLOBAL: i32 = 1000;

fn noop() -> *const i32 {
  let noop_local = 12345;
  &noop_local as *const i32
}

fn main() {
  let local_str = "a";
  let local_int = 123;
  let boxed_str = Box::new('b');
  let boxed_int = Box::new(789);
  let fn_int = noop();
  
  println!("GLOBAL: {:p}"， &GLOBAL as *const i32);
  println!("local_str: {:p}", local_str as *const str);
  println!("local_int: {:p}", &local_int as *const i32);
  println!("boxed_int: {:p}", Box::into_raw(boxed_int));
  println!("boxed_str: {:p}", Box::into_raw(boxed_str));
  println!("fn_int: {:p}", fn_int);
}
```

- segment：虚拟内存中的块。虚拟内存被划分为块，以最小化虚拟和物理地址之间转换所需的空间

### 通过例子

- 某些内存地址是非法的：访问越界的内存，OS 就会关掉你程序
- 内存地址并不是随机的：看起来在地址空间内分布的比较广，值相当于是聚集在口袋内。

### 翻译虚拟地址到物理地址

- 程序里访问数据需要虚拟地址（程序只能范围虚拟地址）
- 虚拟地址会翻译成物理地址
  - 涉及程序、OS、CPU、RAM 硬件，有时涉及硬盘或其它设备
  - CPU 负责执行翻译，OS 负责存储指令
  - CPU 包含一个内存管理单元（MMU）负责这项工作
  - 这些指令也存在内存中一个预定义的地址中
- 最坏情况下，每次访问内存都会发生两次内存查找
- CPU 会维护一个最近转换地址的缓存
  - 它有自己的快速内存来加速内存的访问
  - 历史原因，该内存称为转换后备缓冲区（Translation Lookaside Buffer，TLB）
- 为提高性能，程序员需要保持数据结构精简，避免深度嵌套
  - 达到 TLB 的容量后（对于 x86 处理器，通常约为 100 页）可能成本高
- 页（page）：实际内存中固定大小的字块，64位系统通常是 4K
- 字（Word）：指针大小的任何类型，对应CPU寄存器的宽度
  - usize 和 isize 字长类型（word-length type）
- 虚拟地址被分成很多块，叫做页（page），通常 4KB 大小
  - 这就避免了需要为每个变量都存储转换映射
  - 页统一大小有助于避免内存碎片（可用 RAM 中出现空的、不可用的空间）
- 注意：这只是通用性指导，例如像微控制器情况就不同了。

### 数据在 RAM 中展示的指导建议

- 将程序热工作部分保持在 4KB 以内，从而保持快速查找
- 如果 4KB 不合理，那么下个目标是 4KB * 100
  - 意味着 CPU 可维护其转换缓存（TLB）来支持你的程序
- 避免深度嵌套数据结构（像意大利面）
  - 如果指针指向另一个页（page），性能会受到影响
- 测试嵌套循环的顺序：
  - CPU 会从 RAM 读取小块字节（cache line、缓存行）。在处理数组时，可以通过判断是按列操作还是按行操作来利用这一点

### 注意

- 虚拟化会让情况更糟，如果在虚拟机内运行应用程序，Hypervisor 还必须为其客户 OS 转换地址。
  - 这就是为什么许多 CPU 附带虚拟化支持，这可以减少额外的开销
- 在虚拟机中运行容器又添加一层间接，也增加了延迟
- 要想获得裸机的性能，就必须在裸机上运行程序

### 通过 OS 扫描地址空间（例子）

- OS 提供了接口可让程序发出请求：系统调用（system call）
- 在 Windows 里，KERNEL.DLL 提供了用于检查和操纵运行进程内存的功能
- 为什么以 Windows 为例？
  - 函数命名易于理解
  - 无需 POSIX API 知识

目的：在程序运行的时候扫描程序的内存

### main.rs 文件

```rust
use kernel32;
use winapi;

use winapi::{
    DWORO, // Rust 里就是 u32

    HANDLE, // 各种内部 API 的指针类型，没有关联类型。
            // 在 Rust 里 std::os::raw::c_void 定义了 void 指针
    LPVOID, // Handle 是指向 Windows 内一些不透明资源的指针

    PVOID, // Windows 里，数据类型名的前缀通常是其类型的缩写
    SIZE_T, // 这台机器上 u64 是 usize
    LPSYSTEM_INFO, // 到 SYSTEM_INFO struct 的指针

    MEMORY_BASIC_INFORMATION as MEMINFO, // Windows 内部定义的一些 Struct
    SYSTEM_INFO,
};

fn main() {
    // 这些变量将在 unsafe 块进行初始化
    let this_pid: DWORO;
    let this_proc: HANDLE;
    let min_addr: LPVOID;
    let max_addr: LPVOID;
    let mut base_addr: PVOID;
    let mut proc_info: SYSTEM_INFO;
    let mut mem_info: MEMINFO;

    const MEMINFO_SIZE: usize = std::mem::size_of::<MEMINFO>();

    // 保证所有的内存都初始化了
    unsafe {
        base_addr = std::mem::zeroed();
        proc_info = std::mem::zeroed();
        mem_info = std::mem::zeroed();
    }

    // 系统调用
    unsafe {
        this_pid = kernel32::GetCurrentProcessId();
        this_proc = kernel32::GetCurrentProcess();
        // 下面代码使用 C 的方式将结果返回给调用者。
        // 提供一个到预定义 Struct 的指针，一旦函数返回就读取 Struct 的新值
        kernel32::GetSystemInfo(&mut proc_info as LPSYSTEM_INFO);
    };

    // 对变量重命名
    min_addr = proc_info.lpMinimumApplicationAddress;
    max_addr = proc_info.lpMaximumApplicationAddress;

    println!("{:?} @ {:p}", this_pid, this_proc);
    println!("{:?}", proc_info);
    println!("min: {:p}, max: {:p}", min_addr, max_addr);

    // 扫描地址空间
    loop {
        let rc: SIZE_T = unsafe {
            // 提供运行程序内存地址空间特定段的信息，从 base_addr 开始
            kernel32::VirtualQueryEx(this_proc, base_addr, &mut mem_info, MEMINFO_SIZE as usize)
        };

        if rc == 0 {
            break;
        }

        println!("{:#?}", mem_info);
        base_addr = ((base_addr as u64) + mem_info.RegionSize) as PVOID;
    }
}

```

### Cargo.toml 文件

```toml
[package]
name = "tlearn"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
winapi = "0.2" # 定义一些有用的类型别名，对所有 Windows API 的原始的 FFI 绑定
kernel32-sys = "0.2" # 提供与 KERNEL.DLL 的交互，包含 Windows API 库 Kernel32 的函数定义

```

### 读取和写入进程内存的步骤

```rust
let pid = some_process_id;

OpenProcess(pid);

loop 地址空间 {
  调用 VirtualQueryEx() 来访问下个内存块
  
  通过调用 ReadProcessMemory()，来扫描内存块
  寻找某种特定的模式
  
  使用所需的值调用 WriteProcessMemory()
}
```

- Linux 提供了简单的 API：process_vm_readv()，process_vm_writev()
- Windows：ReadProcessMemory()，WriteProcessMemory()

## 总结

回顾全文，我们完成了一次对 Rust 内存模型 自上而下、层层递进的探索。现在，我们可以将所有知识点串联起来，形成一个融会贯通的整体认知：

- 法则层：所有权是纲领。Rust 的所有权、借用和生命周期系统，是整个内存模型的最高指导法则。它在编译期就为所有的内存操作制定了严格、无歧义的规则，这是 Rust 内存安全的根本保障。
- 实现层：栈与堆是舞台。为了执行这些法则，程序将数据存放在两个主要的舞台上。栈 以其高效的 LIFO 结构和作用域绑定的生命周期，成为性能的优选；而 堆 则以其灵活性，承载了动态变化的数据，并由所有权系统精确管理其生命周期。它们是法则的具体执行者。
- 基础层：底层原理是基石。无论是栈的快速访问，还是堆的动态分配，最终都建立在操作系统提供的 底层原理 之上。虚拟内存机制为程序提供了独立、安全的地址空间，而 CPU 的缓存和内存管理单元（MMU）则决定了数据访问的最终性能。理解这一层，是突破性能瓶颈、进行极致优化的关键。

总而言之，Rust 的内存管理是一个环环相扣、设计精妙的完整 模型。从底层的硬件与OS原理，到中间的栈堆实现，再到上层的编译器所有权法则，三者协同工作，共同铸就了 Rust 语言闻名于世的“安全与性能”。真正掌握这个模型，而非仅仅记住规则，将使你对内存的理解提升到新的高度，从而真正释放 Rust 的全部潜力。

## 参考

- <https://www.rust-lang.org/zh-CN>
- <https://crates.io/>
- <https://course.rs/about-book.html>
