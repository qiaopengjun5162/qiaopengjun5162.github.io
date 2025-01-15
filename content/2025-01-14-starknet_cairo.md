+++
title = "从基础到实战：深入了解 Cairo 编程语言与 Starknet 生态"
description = "从基础到实战：深入了解 Cairo 编程语言与 Starknet 生态"
date = 2025-01-14 17:21:05+08:00
[taxonomies]
categories = ["Starknet", "Web3"]
tags = ["Starknet", "Web3"]
+++

<!-- more -->
# 从基础到实战：深入了解 Cairo 编程语言与 Starknet 生态

Cairo 是一种创新的编程语言，其设计目的是支持高效的零知识证明，尤其是在 Starknet 的生态中具有重要地位。从基础知识到实战操作，本篇文章将带您全面了解 Cairo 的特性、历史以及如何通过 Starklings 应用其核心概念。无论您是区块链开发者还是对 Starknet 感兴趣的技术爱好者，都可以通过本篇内容快速上手并深入探索 Cairo。

本文章详细介绍了 Cairo 编程语言及其在 Starknet 上的应用，包括以下几部分：

1. 什么是 Cairo：从基本定义到历史演进，解析 Cairo 的独特特性。
2. Field Element（felt252）：深入剖析 Cairo 的默认数据类型及其与 Solidity 的对比。
3. Starklings 练习：通过交互式学习工具 Starklings，快速掌握 Cairo 的语法和实践技巧。
4. 实战操作：提供全面的安装、配置及问题解决方案，引导您轻松完成基础练习。

通过本文，您将对 Cairo 的理论和实际应用形成系统化的认知。

## 深入探索 Cairo 编程语言

## Starknet 的基础与实践

`Cairo` 和 `Cairo` 实战

### 主题

1. 什么是`Cairo`
2. `Field Element`
3. `Starklings` 介绍
4. 实战

#### 什么是`Cairo`

## [What is Cairo?](https://book.cairo-lang.org/ch00-00-introduction.html#what-is-cairo)

Cairo is a programming language designed for a virtual CPU of the same name. The unique aspect of this processor is that it was not created for the physical constraints of our world but for cryptographic ones, making it capable of efficiently proving the execution of any program running on it. This means that you can perform time consuming operations on a machine you don't trust, and check the result very quickly on a cheaper machine. While Cairo 0 used to be directly compiled to CASM, the Cairo CPU assembly, Cairo 1 is a higher level language. It first compiles to Sierra, an intermediate representation of Cairo which will compile later down to a safe subset of CASM. The point of Sierra is to ensure your CASM will always be provable, even when the computation fails.

#### `Cairo` 特征

- `Cairo` 最初是指计算机架构 虚拟处理器
- CPU AIR（代数中间表示）
- 由 CPU AIR 执行的字节码称为 `"Cairo Assembly"` 或 CASM
- 编译为Sierra 然后编译为 CASM 的高级语言也称为 `Cairo`
- 旧版本 Cairo 称为 CairoZero
- 开罗是埃及的首都（糟糕的SEO） 可以使用 `Cairo book` 或者 `Starknet`

#### `Cairo` 的历史

2018：Stark 白皮书发布

2019： StarkEx 发布

2020：CairoZero 发布

2021：Cairo 白皮书发布

2023：Cairo 1 发布

![image-20240720220157575.png](https://img.learnblockchain.cn/attachments/2024/08/goo5A8Aq66af37cbb2756.png)

### `Field Element`

`Cairo` 的默认数据类型 `felt252`

`felt` 可以表示一个值 0 < x < P

```shell
P = 2^251 + 17 * 2^192 + 1 （小于2^252）
x/y * y == x  除法
```

`felt` 可以 overflow 或 underflow

支持有符号和无符号整数 u8、u16、u32、u64、u128、u256

`felt` 占用 252 位存储空间，与solidity中默认类型无符号整数u256相比它更小。

我们把它的最大值表示为P

`Cairo` 支持有符号的整数

但`Starknet` 目前只支持无符号的整数

### `Starklings` 实战

交互式学习 `Cairo`

Created by Shramee

Starklings App created by Damian

Maintained by the community

<https://starklings.app/exercise/intro1>

![image-20240720224758449.png](https://img.learnblockchain.cn/attachments/2024/08/IfpZYLsj66af37e8cde7e.png)

这是一个类似于`Rustlings` 的通过做题来实战的练习，可以快速的对`Cairo`语法基础有一个了解学习。

上面的是网页版的，当然也可以在本地进行练习。

<https://github.com/shramee/starklings-cairo1>

#### Setup and run

Make sure you have Rust and Cargo installed with the `default` toolchain.
With rustup `curl https://sh.rustup.rs -sSf | sh -s`

1. Clone the repo and go in the directory,
   `git clone https://github.com/shramee/starklings-cairo1.git && cd starklings-cairo1`.
2. Run `cargo run -r --bin starklings`, this might take a while the first time.
3. You should see this intro message, run `cargo run -r --bin starklings watch` when you are ready!

### 问题

![image-20240721105632027.png](https://img.learnblockchain.cn/attachments/2024/08/I1ZJC80o66af38014c971.png)

解决：

<https://github.com/shramee/starklings-cairo1/issues/215>

把Rust 版本切换为 1.76

if you have `rustup`, you can switch to `v1.7.6.0` by running the following commands:

1. `rustup toolchain install 1.76.0`
2. `run rustup default 1.76.0` - this sets your toolchain (cargo and rustc) to v1.76.0
   check the respective versions of your toolchain by running:
   `rustc --version` and `cargo --version`

Make sure you see 1.76 for both rustc and cargo on your terminal. Then you can proceed to run:
`cargo run -r --bin starklings watch ⁠`

下面我们一起来做`Cairo` 的练习：

```rust
fn main() {}

fn main() {
    let x = 5 ;
    println!(" x is {}", x)
}

fn main() {
    let x = 1;
    if x == 10 {
        println!("x is ten! ");
    } else {
        println!("x is not ten! ");
    }
}

fn main() {
    let x: felt252 = 1;
    println!("x is {}", x);
}

fn main() {
    let mut x = 3;
    println!("x is {}", x);
    x = 5; // don't change this line
    println!("x is now {}", x);
}

fn main() {
    let number = 1_u8; // don't change this line
    println!("number is {}", number);
    let number = 3; // don't rename this variable
    println!("number is {}", number);
}

const NUMBER: u8 = 3;
const SMALL_NUMBER: u8 = 3_u8; //don't change the value of this constant
fn main() {
    println!("NUMBER is {}", NUMBER);
    println!("SMALL_NUMBER is {}", SMALL_NUMBER);
}

fn main() {
    // Booleans (`bool`)

    let is_morning = true;
    if is_morning {
        println!("Good morning!");
    }

    let is_evening = false; // Finish the rest of this line like the example! Or make it be false!
    if is_evening {
        println!("Good evening!");
    }
}

fn main() {
    // A short string is a string whose length is at most 31 characters, and therefore can fit into a single field element.
    // Short strings are actually felts, they are not a real string.
    // Note the _single_ quotes that are used with short strings.

    let mut my_first_initial = 'C';
    if is_alphabetic(
        ref my_first_initial
    ) {
        println!(" Alphabetical !");
    } else if is_numeric(
        ref my_first_initial
    ) {
        println!(" Numerical !");
    } else {
        println!(" Neither alphabetic nor numeric!");
    }

    let mut your_character = 'D';  // Finish this line like the example! What's your favorite short string?
    // Try a letter, try a number, try a special character, try a short string!
    if is_alphabetic(
        ref your_character
    ) {
        println!(" Alphabetical !");
    } else if is_numeric(
        ref your_character
    ) {
        println!(" Numerical!");
    } else {
        println!(" Neither alphabetic nor numeric!");
    }
}

fn is_alphabetic(ref char: felt252) -> bool {
    if char >= 'a' {
        if char <= 'z' {
            return true;
        }
    }
    if char >= 'A' {
        if char <= 'Z' {
            return true;
        }
    }
    false
}

fn is_numeric(ref char: felt252) -> bool {
    if char >= '0' {
        if char <= '9' {
            return true;
        }
    }
    false
}

// Note: the following code is not part of the challenge, it's just here to make the code above work.
// Direct felt252 comparisons have been removed from the core library, so we need to implement them ourselves.
// There will probably be a string / short string type in the future
impl Felt252PartialOrd of PartialOrd<felt252> {
    fn le(lhs: felt252, rhs: felt252) -> bool {
        Into::<felt252, u256>::into(lhs) <= Into::<felt252, u256>::into(rhs)
    }

    fn ge(lhs: felt252, rhs: felt252) -> bool {
        Into::<felt252, u256>::into(lhs) >= Into::<felt252, u256>::into(rhs)
    }

    fn lt(lhs: felt252, rhs: felt252) -> bool {
        Into::<felt252, u256>::into(lhs) < Into::<felt252, u256>::into(rhs)
    }

    fn gt(lhs: felt252, rhs: felt252) -> bool {
        Into::<felt252, u256>::into(lhs) > Into::<felt252, u256>::into(rhs)
    }
}

fn main() {
    let cat = ('Furry McFurson', 3); // don't change this line
    let (name, age) = cat; // your pattern here = cat;
    println!("name is {}", name);
    println!("age is {}", age);
}

fn sum_u8s(x: u8, y: u8) -> u8 {
    x + y
}

//TODO modify the types of this function to prevent an overflow when summing big values
fn sum_big_numbers(x: u8, y: u8) -> u16 {
    x.into() + y.into()
}

fn convert_to_felt(x: u8) -> felt252 { //TODO return x as a felt252.
    x.into()
}

fn convert_felt_to_u8(x: felt252) -> u8 { //TODO return x as a u8.
    x.try_into().unwrap()
}

#[test]
fn test_sum_u8s() {
    assert(sum_u8s(1, 2_u8) == 3_u8, 'Something went wrong');
}

#[test]
fn test_sum_big_numbers() {
    //TODO modify this test to use the correct integer types.
    // Don't modify the values, just the types.
    // See how using the _u8 suffix on the numbers lets us specify the type?
    // Try to do the same thing with other integer types.
    assert(sum_big_numbers(255_u8, 255_u8) == 510_u16, 'Something went wrong');
}

#[test]
fn test_convert_to_felt() {
    assert(convert_to_felt(1_u8) == 1, 'Type conversion went wrong');
}

#[test]
fn test_convert_to_u8() {
    assert(convert_felt_to_u8(1) == 1_u8, 'Type conversion went wrong');
}

// Return the solution of x^3 + y - 2

fn poly(x: usize, y: usize) -> usize {
    // FILL ME
    let res = x * x * x + y - 2;
    res // Do not change
}


// Do not change the test function
#[test]
fn test_poly() {
    let res = poly(5, 3);
    assert(res == 126, 'Error message');
    assert(res < 300, 'res < 300');
    assert(res <= 300, 'res <= 300');
    assert(res > 20, 'res > 20');
    assert(res >= 2, 'res >= 2');
    assert(res != 27, 'res != 27');
    assert(res % 2 == 0, 'res %2 != 0');
}

fn modulus(x: u8, y: u8) -> u8 {
    // calculate the modulus of x and y
    // FILL ME
    let res = x % y;
    res
}

fn floor_division(x: usize, y: usize) -> usize {
    // calculate the floor_division of x and y
    // FILL ME
    let res = x / y;
    res
}

fn multiplication(x: u64, y: u64) -> u64 {
    // calculate the multiplication of x and y
    // FILL ME
    let res = x * y;
    res
}


// Do not change the tests
#[test]
fn test_modulus() {
    let res = modulus(16, 2);
    assert(res == 0, 'Error message');

    let res = modulus(17, 3);
    assert(res == 2, 'Error message');
}

#[test]
fn test_floor_division() {
    let res = floor_division(160, 2);
    assert(res == 80, 'Error message');

    let res = floor_division(21, 4);
    assert(res == 5, 'Error message');
}

#[test]
fn test_mul() {
    let res = multiplication(16, 2);
    assert(res == 32, 'Error message');

    let res = multiplication(21, 4);
    assert(res == 84, 'Error message');
}

#[test]
#[should_panic]
fn test_u64_mul_overflow_1() {
    let _res = multiplication(0x100000000, 0x100000000);
}

fn bigger(a: usize, b: usize) -> usize {
// Do not use:
// - another function call
// - additional variables
    if a > b {
        return a;
    }

    return b;
}

// Don't mind this for now :)
#[cfg(test)]
mod tests {
    use super::bigger;

    #[test]
    fn ten_is_bigger_than_eight() {
        assert(10 == bigger(10, 8), '10 bigger than 8');
    }

    #[test]
    fn fortytwo_is_bigger_than_thirtytwo() {
        assert(42 == bigger(32, 42), '42 bigger than 32');
    }
}

fn foo_if_fizz(fizzish: felt252) -> felt252 {
    // Complete this function using if, else if and/or else blocks.
    // If fizzish is,
    // 'fizz', return 'foo'
    // 'fuzz', return 'bar'
    // anything else, return 'baz'
    if fizzish == 'fizz' {
        'foo'
    } else if fizzish == 'fuzz' {
        'bar'
    } else {
        'baz'
    }
}

// No test changes needed!
#[cfg(test)]
mod tests {
    use super::foo_if_fizz;

    #[test]
    fn foo_for_fizz() {
        assert(foo_if_fizz('fizz') == 'foo', 'fizz returns foo')
    }

    #[test]
    fn bar_for_fuzz() {
        assert(foo_if_fizz('fuzz') == 'bar', 'fuzz returns bar');
    }

    #[test]
    fn default_to_baz() {
        assert(foo_if_fizz('literally anything') == 'baz', 'anything else returns baz');
    }
}

fn main() {
    call_me();
}

fn call_me() {
    
}

fn main() {
    call_me(3);
}

fn call_me(num: u8) {
    println!("num is {}", num);
}

fn main() {
    call_me(2);
}

fn call_me(num: u64) {
    println!("num is {}", num);
}

fn main() {
    let original_price = 51;
    println!("sale_price is {}", sale_price(original_price));
}

fn sale_price(price: u32) -> u32 {
    if is_even(price) {
        price - 10
    } else {
        price - 3
    }
}

fn is_even(num: u32) -> bool {
    num % 2 == 0
}

// Put your function here!
fn calculate_price_of_apples(numbers: u32) -> u32 {
    if numbers <= 40 {
        return numbers * 3;
    } else {
        return numbers * 2;
    }
}

// Do not change the tests!
#[test]
fn verify_test() {
    let price1 = calculate_price_of_apples(35);
    let price2 = calculate_price_of_apples(40);
    let price3 = calculate_price_of_apples(41);
    let price4 = calculate_price_of_apples(65);

    assert(105 == price1, 'Incorrect price');
    assert(120 == price2, 'Incorrect price');
    assert(82 == price3, 'Incorrect price');
    assert(130 == price4, 'Incorrect price');
}

#[test]
#[available_gas(200000)]
fn test_loop() {
    let mut counter = 0;
    //TODO make the test pass without changing any existing line
    loop {
        if counter == 10 {
            break ();
        }
       
        counter += 1;
    };
    assert(counter == 10, 'counter should be 10')
}

#[test]
#[available_gas(200000)]
fn test_loop() {
    let mut counter = 0;

    let result = loop {
        if counter == 5 {
            //TODO return a value from the loop
            break counter;
        }
        counter += 1;
    };

    assert(result == 5, 'result should be 5');
}

use core::fmt::{Display, Formatter, Error};

#[derive(Drop)]
enum Message { // TODO: define a few types of messages as used below
    Quit,
    Echo,
    Move,
    ChangeColor,
}

fn main() { // don't change any of the lines inside main
    println!("{}", Message::Quit);
    println!("{}", Message::Echo);
    println!("{}", Message::Move);
    println!("{}", Message::ChangeColor);
}

impl MessageDisplay of Display<Message> {
    fn fmt(self: @Message, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = match self {
            Message::Quit => format!("Quit"),
            Message::Echo => format!("Echo"),
            Message::Move => format!("Move"),
            Message::ChangeColor => format!("ChangeColor")
        };
        f.buffer.append(@str);
        Result::Ok(())
    }
}

use core::fmt::{Display, Formatter, Error};

#[derive(Copy, Drop)]
enum Message { // TODO: define the different variants used below
    Quit,
    Echo: felt252,
    Move: (u8, u8),
    ChangeColor: (u8, u8, u8)
}


fn main() { // don't change any of the lines inside main
    let mut messages: Array<Message> = ArrayTrait::new();

    //don't change any of the next 4 lines
    messages.append(Message::Quit);
    messages.append(Message::Echo('hello world'));
    messages.append(Message::Move((10, 30)));
    messages.append(Message::ChangeColor((0, 255, 255)));

    print_messages_recursive(messages, 0)
}

// Utility function to print messages. Don't modify these.

trait MessageTrait<T> {
    fn call(self: T);
}

impl MessageImpl of MessageTrait<Message> {
    fn call(self: Message) {
        println!("{}", self);
    }
}

fn print_messages_recursive(messages: Array<Message>, index: u32) {
    if index >= messages.len() {
        return ();
    }
    let message = *messages.at(index);
    message.call();
    print_messages_recursive(messages, index + 1)
}


impl MessageDisplay of Display<Message> {
    fn fmt(self: @Message, ref f: Formatter) -> Result<(), Error> {
        println!("___MESSAGE BEGINS___");
        let str: ByteArray = match self {
            Message::Quit => format!("Quit"),
            Message::Echo(msg) => format!("{}", msg),
            Message::Move((a, b)) => {
                format!("{} {}", a, b)
            },
            Message::ChangeColor((red, green, blue)) => {
                format!("{} {} {}", red, green, blue)
            }
        };
        f.buffer.append(@str);
        println!("___MESSAGE ENDS___");
        Result::Ok(())
    }
}

#[derive(Drop, Copy)]
enum Message { // TODO: implement the message variant types based on their usage below
    ChangeColor: (u8, u8, u8),
    Echo: felt252,
    Move: Point,
    Quit,
}

#[derive(Drop, Copy)]
struct Point {
    x: u8,
    y: u8,
}

#[derive(Drop, Copy)]
struct State {
    color: (u8, u8, u8),
    position: Point,
    quit: bool,
}

trait StateTrait {
    fn change_color(ref self: State, new_color: (u8, u8, u8));
    fn quit(ref self: State);
    fn echo(ref self: State, s: felt252);
    fn move_position(ref self: State, p: Point);
    fn process(ref self: State, message: Message);
}
impl StateImpl of StateTrait {
    fn change_color(ref self: State, new_color: (u8, u8, u8)) {
        let State { color: _, position, quit, } = self;
        self = State { color: new_color, position: position, quit: quit, };
    }
    fn quit(ref self: State) {
        let State { color, position, quit: _, } = self;
        self = State { color: color, position: position, quit: true, };
    }

    fn echo(ref self: State, s: felt252) {
        println!("{}", s);
    }

    fn move_position(ref self: State, p: Point) {
        let State { color, position: _, quit, } = self;
        self = State { color: color, position: p, quit: quit, };
    }

    fn process(
        ref self: State, message: Message
    ) { // TODO: create a match expression to process the different message variants
        match message {
            Message::ChangeColor(new_color) => self.color = new_color,
            Message::Quit => self.quit = true,
            Message::Echo => {},
            Message::Move(new_position) => self.position = new_position,
        }
    }
}


#[test]
fn test_match_message_call() {
    let mut state = State { quit: false, position: Point { x: 0, y: 0 }, color: (0, 0, 0), };
    state.process(Message::ChangeColor((255, 0, 255)));
    state.process(Message::Echo('hello world'));
    state.process(Message::Move(Point { x: 10, y: 15 }));
    state.process(Message::Quit);

    assert(state.color == (255, 0, 255), 'wrong color');
    assert(state.position.x == 10, 'wrong x position');
    assert(state.position.y == 15, 'wrong y position');
    assert(state.quit == true, 'quit should be true');
}

// This function returns how much icecream there is left in the fridge.
// If it's before 10PM, there's 5 pieces left. At 10PM, someone eats them
// all, so there'll be no more left :(
fn maybe_icecream(
    time_of_day: usize
) -> Option<usize> { // We use the 24-hour system here, so 10PM is a value of 22 and 12AM is a value of 0
// The Option output should gracefully handle cases where time_of_day > 23.
// TODO: Complete the function body - remember to return an Option!
    if time_of_day < 22 {
        return Option::Some(5);
    } else if time_of_day <= 24 {
        return Option::Some(0);
    } else {
        return Option::None;
    }
}


#[test]
fn check_icecream() {
    assert(maybe_icecream(9).unwrap() == 5, 'err_1');
    assert(maybe_icecream(10).unwrap() == 5, 'err_2');
    assert(maybe_icecream(23).unwrap() == 0, 'err_3');
    assert(maybe_icecream(22).unwrap() == 0, 'err_4');
    assert(maybe_icecream(25).is_none(), 'err_5');
}

#[test]
fn raw_value() {
    // TODO: Fix this test. How do you get at the value contained in the Option?
    let icecreams = maybe_icecream(12).unwrap();
    assert(icecreams == 5, 'err_6'); // don't change this line
}

#[test]
fn test_options() {
    let target = 'starklings';
    let optional_some = Option::Some(target);
    let optional_none: Option<felt252> = Option::None;
    simple_option(optional_some);
    simple_option(optional_none);
}

fn simple_option(optional_target: Option<felt252>) {
    // TODO: use the `is_some` and `is_none` methods to check if `optional_target` contains a value.
    // Place the assertion and the print statement below in the correct blocks.
    if optional_target.is_some() {
        assert(optional_target.unwrap() == 'starklings', 'err1');
    } else if optional_target.is_none() {
        println!(" option is empty ! ");
    }
}

#[derive(Drop)]
struct Student {
    name: felt252,
    courses: Array<Option<felt252>>,
}


fn display_grades(student: @Student, index: usize) {

    if index == 0 {
        println!("{} index 0", *student.name);
    }
    
    if index >= student.courses.len() {
        return ();
    }

    let course = *student.courses.at(index);

    // TODO: Modify the following lines so that if there is a grade for the course, it is printed.
    //       Otherwise, print "No grade".
    // 
    if course.is_some() {
        println!("grade is {}", course.unwrap());
    } else if course.is_none() {
        println!("No grade");
    }
    display_grades(student, index + 1);
}


#[test]
#[available_gas(20000000)]
fn test_all_defined() {
    let courses = array![
        Option::Some('A'),
        Option::Some('B'),
        Option::Some('C'),
        Option::Some('A'),
    ];
    let mut student = Student { name: 'Alice', courses: courses };
    display_grades(@student, 0);
}


#[test]
#[available_gas(20000000)]
fn test_some_empty() {
    let courses = array![
        Option::Some('A'),
        Option::None,
        Option::Some('B'),
        Option::Some('C'),
        Option::None,
    ];
    let mut student = Student { name: 'Bob', courses: courses };
    display_grades(@student, 0);
}

fn create_array() -> Array<felt252> {
    let mut a = ArrayTrait::new(); // something to change here...
    a.append(0);
    a.append(1);
    a.append(2);
    a
}


// Don't change anything in the test
#[test]
fn test_array_len() {
    let mut a = create_array();
    assert(a.len() == 3, 'Array length is not 3');
    assert(a.pop_front().unwrap() == 0, 'First element is not 0');
}

// Don't modify this function
fn create_array() -> Array<felt252> {
    let mut a = ArrayTrait::new();
    a.append(42);
    a
}

fn remove_element_from_array(
    ref a: Array<felt252>
) { //TODO something to do here...Is there an array method I can use?
    a.pop_front().unwrap();
}

#[test]
fn test_arrays2() {
    let mut a = create_array();
    assert(*a.at(0) == 42, 'First element is not 42');
}

#[test]
fn test_arrays2_empty() {
    let mut a = create_array();
    remove_element_from_array(ref a);
    assert(a.len() == 0, 'Array length is not 0');
}

fn create_array() -> Array<felt252> {
    let mut a = ArrayTrait::new(); // something to change here...
    a.append(0);
    a.append(1);
    a.append(2);
    a.pop_front().unwrap();
    a
}


#[test]
fn test_arrays3() {
    let mut a = create_array();
    //TODO modify the method called below to make the test pass.
    // You should not change the index accessed.
    // a.at(2);
    match a.get(2) {
        Option::Some(_) => {},
        Option::None => {},
    }
}

#[derive(Copy, Drop)]
struct ColorStruct { // TODO: Something goes here
    // TODO: Your struct needs to have red, green, blue felts
    red: u8,
    green: u8,
    blue: u8
}

#[test]
fn classic_c_structs() {
    // TODO: Instantiate a classic color struct!
    // Green color neeeds to have green set to 255 and, red and blue, set to 0
    let green = ColorStruct{red: 0, green: 255, blue: 0};

    assert(green.red == 0, 0);
    assert(green.green == 255, 0);
    assert(green.blue == 0, 0);
}

#[derive(Copy, Drop)]
struct Order {
    name: felt252,
    year: felt252,
    made_by_phone: bool,
    made_by_mobile: bool,
    made_by_email: bool,
    item_number: felt252,
    count: felt252,
}

fn create_order_template() -> Order {
    Order {
        name: 'Bob',
        year: 2019,
        made_by_phone: false,
        made_by_mobile: false,
        made_by_email: true,
        item_number: 123,
        count: 0
    }
}
#[test]
fn test_your_order() {
    let order_template = create_order_template();
    // TODO: Destructure your order into multiple variables to make the assertions pass!
    // let ...
     let Order { name, year, made_by_phone, made_by_mobile, made_by_email, item_number, count, } =
        order_template;

    assert(name == 'Bob', 'Wrong name');
    assert(year == order_template.year, 'Wrong year');
    assert(made_by_phone == order_template.made_by_phone, 'Wrong phone');
    assert(made_by_mobile == order_template.made_by_mobile, 'Wrong mobile');
    assert(made_by_email == order_template.made_by_email, 'Wrong email');
    assert(item_number == order_template.item_number, 'Wrong item number');
    assert(count == 0, 'Wrong count');
}

#[derive(Copy, Drop)]
struct Package {
    sender_country: felt252,
    recipient_country: felt252,
    weight_in_grams: usize,
}

trait PackageTrait {
    fn new(sender_country: felt252, recipient_country: felt252, weight_in_grams: usize) -> Package;
    fn is_international(ref self: Package) -> bool; //???;
    fn get_fees(ref self: Package, cents_per_gram: usize) -> usize; //???;
}
impl PackageImpl of PackageTrait {
    fn new(sender_country: felt252, recipient_country: felt252, weight_in_grams: usize) -> Package {
        if weight_in_grams <= 0{
            let mut data = ArrayTrait::new();
            data.append('x');
            panic(data);
        }
        Package { sender_country, recipient_country, weight_in_grams,  }
    }

    fn is_international(ref self: Package) -> bool //???
    {
    /// Something goes here...
        if self.sender_country == self.recipient_country {
            return false;
        }
        return true;
    }

    fn get_fees(ref self: Package, cents_per_gram: usize) -> usize //???
    {
    /// Something goes here...
        return cents_per_gram * self.weight_in_grams;
    }
}

#[test]
#[should_panic]
fn fail_creating_weightless_package() {
    let sender_country = 'Spain';
    let recipient_country = 'Austria';
    PackageTrait::new(sender_country, recipient_country, 0);
}

#[test]
fn create_international_package() {
    let sender_country = 'Spain';
    let recipient_country = 'Russia';

    let mut package = PackageTrait::new(sender_country, recipient_country, 1200);

    assert(package.is_international() == true, 'Not international');
}

#[test]
fn create_local_package() {
    let sender_country = 'Canada';
    let recipient_country = sender_country;

    let mut package = PackageTrait::new(sender_country, recipient_country, 1200);

    assert(package.is_international() == false, 'International');
}

#[test]
fn calculate_transport_fees() {
    let sender_country = 'Spain';
    let recipient_country = 'Spain';

    let cents_per_gram = 3;

    let mut package = PackageTrait::new(sender_country, recipient_country, 1500);

    assert(package.get_fees(cents_per_gram) == 4500, 'Wrong fees');
}


```

## 总结

Cairo 是 Starknet 生态中的核心编程语言，通过零知识证明提升计算安全性和效率。本文从基础到实战，帮助读者深入理解 Cairo 的核心概念与实践应用。掌握 Cairo 后，您不仅能更好地理解其底层架构，还能为去中心化应用的开发提供强大的工具支持，开启 Starknet 开发之门。

## 参考

- <https://www.bilibili.com/video/BV17E421P7PV/?spm_id_from=333.788&vd_source=bba3c74b0f6a3741d178163e8828d21b>
- <https://docs.starknet.io/quick-start/deploy-interact-with-a-smart-contract-remix/>
- <https://docs.starknet.io/>
- <https://github.com/starkware-libs/cairo>
- <https://starknet-by-example.voyager.online/>
- <https://starklings.app/exercise/intro1>
- <https://github.com/shramee/starklings-cairo1>
- <https://book.cairo-lang.org/title-page.html>
