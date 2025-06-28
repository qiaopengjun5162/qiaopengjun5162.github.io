+++
title = "函数式编程的Rust之旅：闭包与迭代器的深入解析与实践"
description = "函数式编程的Rust之旅：闭包与迭代器的深入解析与实践"
date = 2025-06-28T03:39:16Z
[taxonomies]
categories = ["Rust"]
tags = ["Rust"]
+++

<!-- more -->

# 函数式编程的Rust之旅：闭包与迭代器的深入解析与实践

在Rust编程语言中，闭包（Closures）和迭代器（Iterators）是两大利器，它们不仅体现了函数式编程的优雅，还为开发者提供了强大的抽象能力和代码复用性。无论你是Rust新手还是有一定经验的开发者，理解和掌握闭包与迭代器都能让你的代码更简洁、高效。本文将带你深入探索闭包和迭代器的核心概念、用法及优化技巧，并通过一个实际项目展示它们的威力。让我们一起开启这场Rust的函数式编程之旅吧！

本文从闭包的基础定义入手，讲解了其类型推断、捕获环境及抽象行为的创建方法，随后深入剖析迭代器的Iterator trait及next方法，揭示其懒惰特性和性能优势。我们还将探讨如何结合闭包与迭代器优化代码，并通过改进 minigrep 项目展示其实战价值。最后，对闭包和迭代器的运行时性能进行分析，帮助你更好地在项目中应用这些特性，提升代码质量与效率。

## 函数式语言特性：闭包与迭代器在Rust中的魅力

## 本文内容

- 闭包（Closures）：匿名函数的魔法  
- 迭代器（iterators)：懒惰遍历的艺术  
- 优化实战：优化改善 minigrep 实例项目
- 性能探讨：闭包与迭代器的运行时效率

## 一、闭包（1）- 使用闭包创建抽象行为

### 什么是闭包（closure）

- 闭包：可以捕获其所在环境的匿名函数。
- 闭包：
  - 是匿名函数
  - 保存为变量、作为参数
  - 可在一个地方创建闭包，然后在另一个上下文中调用闭包来完成运算
  - 可从其定义的作用域捕获值
  
闭包是Rust中可以捕获环境的匿名函数，具有以下特点：  

- 匿名性：无需命名，可直接保存为变量或作为参数传递。  
- 灵活性：可在定义处创建，在另一处调用。  
- 捕获能力：能从定义作用域中获取值。

### 例子 - 生成自定义运动计划的程序

- 算法的逻辑并不是重点，重点是算法中的计算过程需要几秒钟时间
- 目标：不让用户发生不必要的等待
  - 仅在必要时调用该算法
  - 只调用一次

### 创建项目

```bash
~/rust
➜ cargo new closure
     Created binary (application) `closure` package

~/rust
➜ cd closure

closure on  master [?] via 🦀 1.67.1
➜ c

closure on  master [?] via 🦀 1.67.1
➜
```

### src/main.rs 文件

```rust
use std::thread;
use std::time::Duration;

fn main() {
    let simulated_user_specified_value = 10;
    let simulated_random_number = 7;

    generate_workout(simulated_user_specified_value, simulated_random_number);
}

fn simnulated_expensive_calculation(intensity: u32) -> u32 {
    println!("calculating slowly ...");
    thread::sleep(Duration::from_secs(2));
    intensity
}

fn generate_workout(intensity: u32, random_number: u32) {
    if intensity < 25 {
        println!("Today, do {} pushups!", simnulated_expensive_calculation(intensity));
        println!("Next, do {} situps!", simnulated_expensive_calculation(intensity));
    } else {
        if random_number == 3 {
            println!("Take a break today! Remember to stay hydrated!");
        } else {
            println!("Today, run for {} minutes!", simnulated_expensive_calculation(intensity));
        }
    }
}

```

### 未用闭包优化

未优化版本：每次调用都重复计算，效率低下。  

```rust
use std::thread;
use std::time::Duration;

fn main() {
    let simulated_user_specified_value = 10;
    let simulated_random_number = 7;

    generate_workout(simulated_user_specified_value, simulated_random_number);
}

fn simnulated_expensive_calculation(intensity: u32) -> u32 {
    println!("calculating slowly ...");
    thread::sleep(Duration::from_secs(2));
    intensity
}

fn generate_workout(intensity: u32, random_number: u32) {
    let expensive_result = simnulated_expensive_calculation(intensity);
    if intensity < 25 {
        println!("Today, do {} pushups!", expensive_result);
        println!("Next, do {} situps!", expensive_result);
    } else {
        if random_number == 3 {
            println!("Take a break today! Remember to stay hydrated!");
        } else {
            println!("Today, run for {} minutes!", expensive_result);
        }
    }
}

```

### 闭包优化

闭包优化版：将计算逻辑封装为闭包，按需调用。  

```rust
use std::thread;
use std::time::Duration;

fn main() {
    let simulated_user_specified_value = 10;
    let simulated_random_number = 7;

    generate_workout(simulated_user_specified_value, simulated_random_number);
}

fn generate_workout(intensity: u32, random_number: u32) {
    
    let expensive_closure = |num| {
        println!("calculating slowly ...");
        thread::sleep(Duration::from_secs(2));
        num
    };

    if intensity < 25 {
        println!("Today, do {} pushups!", expensive_closure(intensity));
        println!("Next, do {} situps!", expensive_closure(intensity));
    } else {
        if random_number == 3 {
            println!("Take a break today! Remember to stay hydrated!");
        } else {
            println!("Today, run for {} minutes!", expensive_closure(intensity));
        }
    }
}

```

## 二、闭包（2）- 闭包类型推断和标注

### 闭包的类型推断

- 闭包不要求标注参数和返回值的类型
- 闭包通常很短小，只在狭小的上下文中工作，编译器通常能推断出类型
- 可以手动添加类型标注

Rust编译器能自动推断闭包参数和返回值的类型，但也可手动标注：  

```rust
 let expensive_closure = |num: u32| -> u32 {
        println!("calculating slowly ...");
        thread::sleep(Duration::from_secs(2));
        num
    };
```

### 函数和闭包的定义语法

函数与闭包对比

```rust
fn add_one_v1(x: u32) -> u32 { x + 1 }  // 函数
let add_one_v2 = |x: u32| -> u32 { x + 1 };  // 闭包
let add_one_v3 = |x| { x + 1 };  // 闭包
let add_one_v4 = |x| x + 1 ;  // 简洁闭包
```

### 闭包的类型推断

- 注意：闭包的定义最终只会为参数/返回值推断出唯一具体的类型

```rust
fn main() {
  let example_closure = |x| x;
  
  let s = example_closure(String::from("hello"));
  let n = example_closure(5)  // 报错
}
```

注意：闭包类型一旦推断固定，不能更改参数类型。  

## 三、闭包（3）- 使用泛型参数和 Fn Trait 来存储闭包

### 继续解决 ”运动计划“ 程序的问题

- 另一种解决方案：
- 创建一个 Struct，它持有闭包及其调用结果。
  - 只会在需要结果时才执行该闭包
  - 可缓存结果
- 这个模式通常叫做记忆化（memoization）或延迟计算（lazy evaluation）

### 如何让 Struct 持有闭包

- Struct 的定义需要知道所有字段的类型
  - 需要指明闭包的类型
- 每个闭包实例都有自己唯一的匿名类型，即使两个闭包签名完全一样。
- 所以需要使用：泛型和 Trait Bound

### Fn Trait

- Fn traits 由标准库提供
- 所有的闭包都至少实现了以下 Trait 之一：
  - Fn
  - FnMut
  - FnOnce

### 缓存优化：Cacher结构

为避免重复计算，我们可以用结构体缓存闭包结果：  

```rust
use std::thread;
use std::time::Duration;

struct Cacher<T>
where
    T: Fn(u32) -> u32,
{
    calculation: T,
    value: Option<u32>,
}

impl<T> Cacher<T>
where
    T: Fn(u32) -> u32,
{
    fn new(calculation: T) -> Cacher<T> {
        Cacher {
            calculation,
            value: None,
        }
    }

    fn value(&mut self, arg: u32) -> u32 {
        match self.value {
            Some(v) => v,
            None => {
                let v = (self.calculation)(arg);
                self.value = Some(v);
                v
            }
        }
    }
}

fn main() {
    let simulated_user_specified_value = 10;
    let simulated_random_number = 7;

    generate_workout(simulated_user_specified_value, simulated_random_number);
}

fn generate_workout(intensity: u32, random_number: u32) {
    
    let mut expensive_closure = Cacher::new(|num| {
        println!("calculating slowly ...");
        thread::sleep(Duration::from_secs(2));
        num
    });

    if intensity < 25 {
        println!("Today, do {} pushups!", expensive_closure.value(intensity));
        println!("Next, do {} situps!", expensive_closure.value(intensity));
    } else {
        if random_number == 3 {
            println!("Take a break today! Remember to stay hydrated!");
        } else {
            println!("Today, run for {} minutes!", expensive_closure.value(intensity));
        }
    }
}

```

### 使用缓存器 （Cacher）实现的限制

- Cacher 实例假定针对不同的参数 arg，Value 方法总会得到同样的值。
  - 可以使用 HashMap 代替单个值：
    - Key：arg 参数
    - Value：执行闭包的结果

```rust
use std::thread;
use std::time::Duration;

struct Cacher<T>
where
    T: Fn(u32) -> u32,
{
    calculation: T,
    value: Option<u32>,
}

impl<T> Cacher<T>
where
    T: Fn(u32) -> u32,
{
    fn new(calculation: T) -> Cacher<T> {
        Cacher {
            calculation,
            value: None,
        }
    }

    fn value(&mut self, arg: u32) -> u32 {
        match self.value {
            Some(v) => v,
            None => {
                let v = (self.calculation)(arg);
                self.value = Some(v);
                v
            }
        }
    }
}

fn main() {
    let simulated_user_specified_value = 10;
    let simulated_random_number = 7;

    generate_workout(simulated_user_specified_value, simulated_random_number);
}

fn generate_workout(intensity: u32, random_number: u32) {
    let mut expensive_closure = Cacher::new(|num| {
        println!("calculating slowly ...");
        thread::sleep(Duration::from_secs(2));
        num
    });

    if intensity < 25 {
        println!("Today, do {} pushups!", expensive_closure.value(intensity));
        println!("Next, do {} situps!", expensive_closure.value(intensity));
    } else {
        if random_number == 3 {
            println!("Take a break today! Remember to stay hydrated!");
        } else {
            println!(
                "Today, run for {} minutes!",
                expensive_closure.value(intensity)
            );
        }
    }
}

#[cfg(test)]
mod tests {

    #[test]
    fn call_with_different_values() {
        let mut c = super::Cacher::new(|a| a);
        let v1 = c.value(1);
        let v2 = c.value(2);

        assert_eq!(v2, 2);
    }
}

```

- 只能接收一个u32类型的参数和 u32 类型的返回值

应用：只计算一次，结果可复用，大幅提升性能。  

## 四、闭包（4）- 使用闭包捕获环境

### 闭包可以捕获他们所在的环境

- 闭包可以访问定义它的作用域内的变量，而普通函数则不能。

闭包能访问定义时的变量：  

```rust
fn main() {
  let x = 4;
  
  let equal_to_x = |z| z == x; // 捕获x
  
  let y = 4;
  
  assert!(equal_to_x(y));
}
```

- 会产生内存开销。

### 闭包从所在环境捕获值的方式

- 与函数获得参数的三种方式一样：
  - 取得所有权：FnOnce
  - 可变借用：FnMut
  - 不可变借用：Fn
- 创建闭包时，通过闭包对环境值的使用，Rust推断出具体使用哪个 Trait：
  - 所有的闭包都实现了 FnOnce
  - 没有移动捕获变量的实现了 FnMut
  - 无需可变访问捕获变量的闭包实现了 Fn

### move 关键字

- 在参数列表前使用 move 关键字，可以强制闭包取得它所使用的环境值的所有权
  - 当将闭包传递给新线程以移动数据使其归新线程所有时，此技术最为有用。

```rust
fn main() {
  let x = vec![1, 2, 3];
  let equal_to_x = move |z| z == x;
  println!("can't use x here: {:?}", x);  // 报错
  let y = vec![1, 2, 3];
  assert!(equal_to_x(y))
}
```

move关键字：强制转移所有权，常用于线程。  

### 最佳实践

- 当指定 Fn trait bound 之一时，首先用 Fn，基于闭包体里的情况，如果需要 FnOnce 或 FnMut，编译器会再告诉你。

## 五、迭代器（1）- Iterator trait 和 next 方法

### 什么是迭代器

- 迭代器模式：读一系列项执行某些任务
- 迭代器负责：
  - 遍历每个项
  - 确定序列（遍历）何时完成
- Rust的迭代器：
  - 懒惰的：除非调用消费迭代器的方法，否则迭代器本身没有任何效果。

迭代器负责遍历序列，Rust中是懒惰的，需显式调用才会执行。  

```rust
fn main() {
  let v1 = vec![1, 2, 3];
  let v1_iter = v1.iter(); // 创建迭代器，未执行
  
  for val in v1_iter {
    pringln!("Got: {}", val); // 遍历时执行
  }
}
```

### Iterator trait

- 所有迭代器都实现了 Iterator trait
- Iterator trait 定义于标准库，定义大致如下：

```rust
pub trait Iterator {
  type item;
  
  fn next(&mut self) -> Option<Self::Item>;
  // methods with default implementations elided
}
```

- Type Item 和 Self::Item 定义了与此该 Trait 关联的类型。
  - 实现 Iterator trait 需要你定义一个 Item 类型，它用于 next 方法的返回类型（迭代器的返回类型）。

- Iterator trait 仅要求实现一个方法：next
- next：
  - 每次返回迭代器中的一项
  - 返回结果包裹在 Some 里
  - 迭代结束，返回 None
- 可直接在迭代器上调用 next 方法

```rust
#[cfg(test)]
mod tests {
  #[test]
  fn iterator_demonstration() {
    let v1 = vec![1, 2, 3];
    let mut v1_iter = v1.iter();
    
    assert_eq!(v1_iter.next(), Some(&1));
    assert_eq!(v1_iter.next(), Some(&2));
    assert_eq!(v1_iter.next(), Some(&3));
  }
}
```

### 几个迭代方法

- iter 方法：在不可变引用上创建迭代器
- into_iter 方法：创建的迭代器会获得所有权
- iter_mut 方法：迭代可变的引用

## 六、迭代器（2）- 消耗/产生迭代器

### 消耗迭代器的方法

- 在标准库中，Iterator trati 有一些带默认实现的方法
- 其中有一些方法会调用 next 方法
  - 实现 Iterator trati 时必须实现 next 方法的原因之一
- 调用next 的方法叫做”消耗型适配器“
  - 因为调用它们会把迭代器消耗尽
- 例如：Sum方法（就会耗尽迭代器）
  - 取得迭代器的所有权
  - 通过反复调用 next，遍历所有元素
  - 每次迭代，把当前元素添加到一个总和里，迭代结束，返回总和

消耗型方法
如sum：耗尽迭代器并返回结果。  

```rust
#[cfg(test)]
mod tests {
  #[test]
  fn iterator_sum() {
    let v1 = vec![1, 2, 3];
    let v1_iter = v1,iter();
    let total: i32 = v1_iter.sum(); // 6
    
    assert_eq!(total, 6);
  }
}
```

### 产生其它迭代器的方法

- 定义在 Iterator trait 上的另外一些方法叫做 ”迭代器适配器“
  - 把迭代器转换为不同种类的迭代器
- 可以通过链式调用使用多个迭代器适配器来执行复杂的操作，这种调用可读性较高。
- 例如：map
  - 接收一个闭包，闭包作用于每个元素
  - 产生一个新的迭代器

产生型方法
如map：生成新迭代器。  

```rust
#[cfg(test)]
mod tests {
  #[test]
  fn iterator_sum() {
    let v1: Vec<i32> = vec![1, 2, 3];
    
    let v2: Vec<_> = v1.iter().map(|x| x + 1).collect(); // [2, 3, 4]
    
    assert_eq!(v2, vec![2, 3, 4]);
  }
}
```

- Collect 方法：消耗型适配器，把结果收集到一个集合类型中。

## 七、迭代器（3）- 使用闭包捕获环境

### 使用闭包捕获环境

- filter 方法：
  - 接收一个闭包
  - 这个闭包在遍历迭代器的每个元素时，返回bool类型
  - 如果闭包返回 true：当前元素将会包含在 filter 产生的迭代器中
  - 如果闭包返回 false：当前元素将不会包含在 filter 产生的迭代器中

filter示例：筛选符合条件的元素。  

```rust
#[derive(PartialEq, Debug)]
struct Shoe {
  size: u32,
  style: String,
}

fn shoes_in_my_size(shoes: Vec<Shoe>, shoe_size: u32) -> Vec<Shoe> {
  shoes.into_iter().filter(|x| x.size == shoe_size).collect()
}

#[test]
fn filter_by_size() {
  let shoes = vec![
    Shoe {
      size: 10,
      style: String::from("sneaker"),
    },
    Shoe {
      size: 13,
      style: String::from("sandal"),
    },
    Shoe {
      size: 10,
      style: String::from("boot").
    },
  ];
  
  let in_my_size = shoes_in_my_size(shoes, 10);
  
  assert_eq!(in_my_size, vec![
    Shoe {
      size: 10,
      style: String::from("sneaker")
    },
    Shoe {
      size: 10,
      style: String::from("boot")
    },
  ]);
}
```

## 八、迭代器（4）- 创建自定义迭代器

### 使用 Iterator trait 来创建自定义迭代器

- 实现 next 方法

```rust
struct Counter {
    count: u32,
}

impl Counter {
    fn new() -> Counter {
        Counter { count: 0 }
    }
}

impl Iterator for Counter {
    type Item = u32;

    fn next(&mut self) -> Option<Self::Item> {
        if self.count < 5 {
            self.count += 1;
            Some(self.count)
        } else {
            None
        }
    }
}

#[test]
fn calling_next_directly() {
    let mut counter = Counter::new();

    assert_eq!(counter.next(), Some(1));
    assert_eq!(counter.next(), Some(2));
    assert_eq!(counter.next(), Some(3));
    assert_eq!(counter.next(), Some(4));
    assert_eq!(counter.next(), Some(5));
    assert_eq!(counter.next(), None);
}

#[test]
fn using_other_iterator_trait_methods() {
    let sum: u32 = Counter::new() // 1 2 3 4 5
        .zip(Counter::new().skip(1))  // 2 3 4 5 None  
        .map(|(a, b)| a * b)  // 2 6 12 20 
        .filter(|x| x % 3 == 0)  // 6 12
        .sum();  // 6 + 12 = 18

    assert_eq!(18, sum);
}

```

## 九、使用迭代器和闭包改进I/O 项目（minigrep）

### 实战：优化minigrep

使用迭代器和闭包简化search函数：  

### src/main.rs 文件

```rust
use minigrep::Config;
use std::env;
use std::process;

fn main() {
    let config = Config::new(env::args()).unwrap_or_else(|err| {
        eprintln!("Problem parsing arguments: {}", err);
        process::exit(1);
    });
    if let Err(e) = minigrep::run(config) {
        eprintln!("Application error: {}", e);
        process::exit(1);
    }
}

```

### src/lib.rs 文件

```rust
use std::env;
use std::error::Error;
use std::fs;

pub fn run(config: Config) -> Result<(), Box<dyn Error>> {
    let contents = fs::read_to_string(config.filename)?;
    let results = if config.case_sensitive {
        search(&config.query, &contents)
    } else {
        search_case_insensitive(&config.query, &contents)
    };
    for line in results {
        println!("line: {}", line);
    }
    // println!("With text:\n{}", contents);
    // println!("query: {:?}", config.query);
    Ok(())
}

pub struct Config {
    pub query: String,
    pub filename: String,
    pub case_sensitive: bool,
}

impl Config {
    pub fn new(mut args: std::env::Args) -> Result<Config, &'static str> {
        if args.len() < 3 {
            return Err("not enough arguments");
        }
        args.next();

        let query = match args.next() {
            Some(arg) => arg,
            None => return Err("Didn't get a query string"),
        };
        let filename = match args.next() {
            Some(arg) => arg,
            None => return Err("Didn't get a file name"),
        };

        let case_sensitive = env::var("CASE_INSENSITIVE").is_err();
        Ok(Config {
            query,
            filename,
            case_sensitive,
        })
    }
}

pub fn search<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    // let mut results = Vec::new();

    // for line in contents.lines() {
    //     if line.contains(query) {
    //         results.push(line);
    //     }
    // }

    // results

    contents
        .lines()
        .filter(|line| line.contains(query))
        .collect()
}

pub fn search_case_insensitive<'a>(query: &str, contents: &'a str) -> Vec<&'a str> {
    // let mut results = Vec::new();
    // let query = query.to_lowercase();

    // for line in contents.lines() {
    //     if line.to_lowercase().contains(&query) {
    //         results.push(line);
    //     }
    // }

    // results

    contents
        .lines()
        .filter(|line| line.to_lowercase().contains(&query.to_lowercase()))
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    //     fn one_result() {
    //         let query = "duct";
    //         let contents = "\
    // Rust:
    // safe, fast, productive.
    // Pick three.";

    //         assert_eq!(vec!["safe, fast, productive."], search(query, contents))
    //     }

    fn case_sensitive() {
        let query = "duct";
        let contents = "\
Rust:
safe, fast, productive.
Pick three.
Duct tape.";

        assert_eq!(vec!["safe, fast, productive."], search(query, contents))
    }

    #[test]
    fn case_insensitive() {
        let query = "rUsT";
        let contents = "\
Rust:
safe, fase, productive.
Pick three.
Trust me.";

        assert_eq!(
            vec!["Rust:", "Trust me."],
            search_case_insensitive(query, contents)
        )
    }
}

```

## 十、性能比较：- 循环 VS 迭代器

循环 vs 迭代器：迭代器因零开销抽象（Zero-Cost Abstraction）往往更快。

### 一个测试

- 把一本小说的内容放在一个 String 里面，搜索 “the”：

```
test bench_search_for ... bench:  19,620,300 ns/iter (+/- 915,700)
test bench_search_iter ... bench: 19,234,900 ns/iter (+/- 657,200)
```

- 迭代器的版本更快一点！
测试结果：搜索小说中“the”，迭代器版本略胜一筹。  

### 零开销抽象 Zero-Cost Abstraction

- 使用抽象时不会引入额外的运行时开销。

### 音频解码器的例子

```rust
let buffer: &mut [i32];
let coefficients: [i64; 12];
let qlp_shift: i16;

for i in 12..buffer.len() {
  let prediction = coefficients.iter().zip(&buffer[i - 12..i]).map(|(&c, &s)| c * s as i64).sum::<i64>() >> qlp_shift;
  
  let delta = buffer[i];
  buffer[i] = prediction as i32 + delta;
}
```

## 总结

闭包和迭代器是Rust中不可或缺的函数式编程工具，它们以高度的抽象和灵活性赋予开发者编写优雅、高效代码的能力。通过本文的学习，你不仅能理解闭包如何捕获环境、迭代器如何懒惰执行，还能在实际项目中运用这些特性优化性能。无论是简化逻辑还是提升运行效率，闭包与迭代器都能成为你的得力助手。希望你在Rust的编程旅途中，能灵活运用这些工具，写出更出色的代码！

## 参考

- <https://embarkstudios.github.io/cargo-deny/>
- <https://llever.com/exercism-rust-zh/index.html>
- <https://www.lurklurk.org/effective-rust/>
