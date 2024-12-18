+++
title = "Starknet开发实战"
date = 2024-01-10T12:06:44+08:00
[taxonomies]
tags = ["Starknet","Cairo"]
categories = ["Starknet","Cairo"]
+++

# Starknet开发实战

## 以太坊网络架构

以太坊有共识、数据可用性、结算、执行四个模块。

共识层

- 共识层指的是节点就区块链上哪些数据可以被验证为真实和准确达成协议的机制。
- 共识协议决定了交易如何排序，以及新区块如何被添加到链上。

执行层

- 执行层是区块链上的节点如何处理交易，以在不同状态之间过渡区块链。
- 参与共识的节点必须使用他们的区块链副本执行交易，以便在验证区块之前进行证明。

数据可用性

- 区块提议者发布区块的所有交易数据并且交易数据可供其他网络参与者使用的保证。
- 简单来讲，数据可用性是一个通信标准，以保证某个节点的数据可被另一个节点所接收并验证为正确，从而保证安全。
- 区块链执行的规则要求交易数据的可用性。这意味着区块生产者必须为每个区块发布数据，供网络对等者下载和存储；这些数据必须应要求提供。

结算层

- 区块链提供了 "最终性"--保证已经提交到链的历史的交易是不可逆的（或 "不可改变的"）。
- 要做到这一点，区块链必须确信交易的有效性。因此，结算功能需要链来验证交易，验证证明，并仲裁争端。

## 安装

- <https://foundry-rs.github.io/starknet-foundry/getting-started/installation.html>
- <https://book.cairo-lang.org/ch01-01-installation.html>

```bash
curl -L https://raw.githubusercontent.com/foundry-rs/starknet-foundry/master/scripts/install.sh | sh
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1616  100  1616    0     0    691      0  0:00:02  0:00:02 --:--:--   691
Installing snfoundryup...
######################################################################## 100.0%

Detected your preferred bash is zsh and added snfoundryup to PATH. Run 'source /Users/qiaopengjun/.zshenv' or start a new terminal session to use snfoundryup.
Then, simply run 'snfoundryup' to install Starknet-Foundry.

~ via 🅒 base took 3.3s
➜
snfoundryup
starknet-foundry-install: retrieving latest version from https://github.com/foundry-rs/starknet-foundry...
starknet-foundry-install: downloading starknet-foundry-v0.13.1-aarch64-apple-darwin.tar.gz...
########################################################################################################################################################## 100.0%
starknet-foundry-install: installed snforge and sncast to /Users/qiaopengjun/.local/share/starknet-foundry-install/0.13.1
starknet-foundry-install: created symlink /Users/qiaopengjun/.local/bin/snforge -> /Users/qiaopengjun/.local/share/starknet-foundry-install/0.13.1/bin/snforge
starknet-foundry-install: created symlink /Users/qiaopengjun/.local/bin/sncast -> /Users/qiaopengjun/.local/share/starknet-foundry-install/0.13.1/bin/sncast

Starknet Foundry has been successfully installed and should be already available in your PATH.
Run 'snforge --version' and 'sncast --version' to verify your installation. Happy coding!

~ via 🅒 base took 4.4s
➜
snsnforge --version
sncast --version

snforge 0.13.1
sncast 0.13.1

scarb --version
scarb 2.4.0 (cba988e68 2023-12-06)
cairo: 2.4.0 (https://crates.io/crates/cairo-lang-compiler/2.4.0)
sierra: 1.4.0
```

## 创建项目

```bash
which scarb
/Users/qiaopengjun/.local/bin/scarb

scarb new hello_world
Created `hello_world` package.

ls
hello_world

cd hello_world/

c

hello_world on  main [?] via 🅒 base 
➜ scarb test     
     Running cairo-test hello_world
   Compiling test(hello_world_unittest) hello_world v0.1.0 (/Users/qiaopengjun/Code/cairo/hello_world/Scarb.toml)
    Finished release target(s) in 1 second
testing hello_world ...
running 1 tests
test hello_world::tests::it_works ... ok (gas usage est.: 46860)
test result: ok. 1 passed; 0 failed; 0 ignored; 0 filtered out;

hello_world on  main [?] via 🅒 base 
➜  scarb cairo-run --available-gas=200000000
   Compiling hello_world v0.1.0 (/Users/qiaopengjun/Code/cairo/hello_world/Scarb.toml)
    Finished release target(s) in 1 second
     Running hello_world
Run completed successfully, returning [987]
Remaining gas: 199953640
```

### `lib.cairo` 文件

```cairo
fn main() {
    let mut x = 5;
    println!("Hello, world! {}", x);

    x = 6;
    println!("Hello, world! {}", x);
}


#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {}
}

```

### 运行

```bash
hello_world on  main [?] via 🅒 base 
➜ scarb cairo-run --available-gas=200000000
   Compiling hello_world v0.1.0 (/Users/qiaopengjun/Code/cairo/hello_world/Scarb.toml)
    Finished release target(s) in 1 second
     Running hello_world
Hello, world! 5
Hello, world! 6
Run completed successfully, returning []
Remaining gas: 199661300

```

Cairo  没有办法对 felt252 做除法

### `lib.cairo` 文件

```rust
const ONE_HOUR_IN_SECONDS: u32 = 3600;

#[derive(Drop)]
struct Rectangle {
    width: u64,
    height: u64
}

#[derive(Drop)]
struct Rectangle1<T> {
    width: T,
    height: T
}

trait RectangleTrait {
    fn area(self: @Rectangle) -> u64;
}

trait RectangleTrait1<T> {
    fn area(self: @Rectangle1<T>) -> T;
}

impl RectangleImpl1<T, +Mul<T>, +Copy<T>> of RectangleTrait1<T> {
    fn area(self: @Rectangle1<T>) -> T {
        *self.width * *self.height
    }
}

fn main() {
    let mut x = 5;
    println!("Hello, world! {}", x);

    x = 6;
    println!("Hello, world! {}", x);

    println!("ONE_HOUR_IN_SECONDS is {ONE_HOUR_IN_SECONDS}");

    let mut y: u16 = 10;
    y = y / 2;
    println!("y is {y}");

    let z: u256 = 10;
    let l = 5_u8;
    println!("z is {z} and l is {l}");
    println!("z + l is {}", z + l.into());
    println!("l / y is {}", l / y.try_into().unwrap());

    let x = 'Hello World';
    println!("x is {x}"); // x is 87521618088882533792115812

    let x = 25_u16;
    println!("{}", format!("https://example.com/{}", x));

    let y: ByteArray = "Hello World";
    println!("y is {y}");
    println!("{y:?}");

    println!("{}", sum_three(1, 2, 3));

    println!("{}", min(1, 2));
    println!("{}", min2(1, 2, 3));
    println!("fib: {}", fib(1, 2, 5));

    let a = array![1, 2, 3, 4, 5];
    println!("sum_array! {}", sum_array(a));
    // println!("Arr Len is {}", a.len());  error: Variable was previously moved.

    let (a, b, c) = (1, 2, 3);
    println!("sum_three: {}", sum_three(a, b, c));
    println!("A is {a}");

    let arr = array![1, 2, 3, 4, 5];
    // println!("arr len is {}", return_len(@arr));
    println!("arr len is {}", return_len(arr.span()));
    // println!("arr len {}", arr.len());  error: Variable was previously moved.
    println!("arr len {}", arr.len());
    // 快照传参 @ 会获得变量的不可变引用
    // 可变引用传参

    println!("sum_array2: {}", sum_array2(arr.span()));

    let mut arr = array![1, 2, 3, 4];
    println!("sum_array3: {}", sum_array3(ref arr));
    println!("arr len is {}", arr.len());

    let rectangle = Rectangle { width: 30, height: 50 };
    let area = area(@rectangle);
    println!("area is {}", area);
    println!(
        "Width is {}", rectangle.width
    ); // Variable not dropped.  Variable was previously moved.

    println!("Rectangle is {}", rectangle);

    println!("Area is {}", rectangle.area());
    let rectangle1 = Rectangle1 { width: 30_u32, height: 50 };
    println!("Area is rectangle1 {}", rectangle1.area());
}

fn sum_three(a: u32, b: u32, c: u32) -> u32 {
    a + b + c
}

fn min(a: u32, b: u32) -> u32 {
    if a < b {
        a
    } else {
        b
    }
}

fn min2(a: u32, b: u32, c: u32) -> u32 {
    if (a <= b) & (a <= c) {
        a
    } else if (b <= a) & (b <= c) {
        b
    } else {
        c
    }
}

fn fib(mut a: felt252, mut b: felt252, mut n: felt252) -> felt252 {
    loop {
        if n == 0 {
            break a;
        }
        n -= 1;
        let temp = b;
        b = a + b;
        a = temp;
    }
}

fn sum_array(mut arr: Array<u32>) -> u32 {
    let mut sum = 0_u32;

    loop {
        match arr.pop_front() {
            Option::Some(current_value) => { sum += current_value },
            Option::None => { break; },
        }
    };
    sum
}

// fn return_len(arr: Array<u32>) -> u32 {
// fn return_len(arr: @Array<u32>) -> u32 {
fn return_len(arr: Span<u32>) -> u32 {
    arr.len()
}

fn sum_array2(mut arr: Span<u32>) -> u32 {
    let mut sum: u32 = 0;

    loop {
        match arr.pop_front() {
            Option::Some(current_value) => { sum += *current_value },
            Option::None => { break; },
        }
    };
    sum
}

fn sum_array3(ref arr: Array<u32>) -> u32 {
    let mut sum: u32 = 0;

    loop {
        match arr.pop_front() {
            Option::Some(current_value) => { sum += current_value },
            Option::None => { break; },
        }
    };
    sum
}

fn area(rectangle: @Rectangle) -> u64 {
    *rectangle.width * *rectangle.height
}

impl RectangleDisplay of core::fmt::Display<Rectangle> {
    fn fmt(self: @Rectangle, ref f: core::fmt::Formatter) -> Result<(), core::fmt::Error> {
        write!(f, "width: ")?;
        core::fmt::Display::fmt(self.width, ref f)?;
        write!(f, ", height: ")?;
        core::fmt::Display::fmt(self.height, ref f)
    }
}

impl RectangleImpl of RectangleTrait {
    fn area(self: @Rectangle) -> u64 {
        *self.width * *self.height
    }
}

#[cfg(test)]
mod tests {
    use super::sum_three;

    #[test]
    fn it_works() {
        assert(sum_three(1, 2, 3) == 6, 'Sum Fail');
        assert_eq!(sum_three(1, 2, 3), 6);
        assert_eq!(sum_three(10, 20, 30), 60);
    }
}
// 当我们使用简单类型 （u8 u16 u32） 时， 不需要关注所有权类型，只有报错的时候才关注
// 当遇到所有权的时候，不想改变则使用 @ Span 快照类型  修改则使用 ref 要求是可变的变量 使用 mut 



```

### 运行

```bash
hello_world on  main via 🅒 base took 6.7s 
➜ scarb cairo-run --available-gas=200000000                                
   Compiling hello_world v0.1.0 (/Users/qiaopengjun/Code/cairo/hello_world/Scarb.toml)
    Finished release target(s) in 1 second
     Running hello_world
Hello, world! 5
Hello, world! 6
ONE_HOUR_IN_SECONDS is 3600
y is 5
z is 10 and l is 5
z + l is 15
l / y is 1
x is 87521618088882533792115812
https://example.com/25
y is Hello World
"Hello World"
6
1
1
fib: 13
sum_array! 15
sum_three: 6
A is 1
arr len is 5
arr len 5
sum_array2: 15
sum_array3: 10
arr len is 0
area is 1500
Width is 30
Rectangle is width: 30, height: 50
Area is 1500
Area is rectangle1 1500
Run completed successfully, returning []
Remaining gas: 194095080

```

## 安装 starkli

- <https://github.com/xJonathanLEI/starkli>
- <https://book.starkli.rs/installation>

```bash
curl https://get.starkli.sh | sh
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3574  100  3574    0     0   2064      0  0:00:01  0:00:01 --:--:--  2064
Installing starkliup...
######################################################################## 100.0%

bash detection variables (for debugging use):
- ZSH_NAME =
- bash = /bin/zsh

Run '. /Users/qiaopengjun/.starkli/env' or start a new terminal session to use starkliup.
Then, simply run starkliup to install starkli.


~ via 🅒 base took 11.3s
➜
. /Users/qiaopengjun/.starkli/env


~ via 🅒 base
➜
starkliup -v v0.2.3
Installing version v0.2.3...
Detected host triple: aarch64-apple-darwin
Downloading release file from GitHub...
########################################################################################################################################################## 100.0%
Successfully installed starkli

Generating bash completion files...
- Bash ... Done
- Zsh ... Done
Note that bash completions might not work until you start a new session.

Installation successfully completed.

~ via 🅒 base took 2.5s
➜
mkdir ~/.starknet_accounts

~ via 🅒 base
➜
starkli signer keystore new ~/.starknet_accounts/key.json
Enter password:
Created new encrypted keystore file: /Users/qiaopengjun/.starknet_accounts/key.json
Public key: 0x04bf26d3d5789369d5254c9e82278007fd2ceccb3edf3e45e74107a4fafe619a

~ via 🅒 base took 8.1s
➜
starkli -h
Starkli (/ˈstɑːrklaɪ/), a blazing fast CLI tool for Starknet powered by starknet-rs

Usage: starkli [OPTIONS] [COMMAND]

Commands:
  selector            Calculate selector from name
  class-hash          Calculate class hash from any contract artifacts (Sierra, casm, legacy)
  to-cairo-string     Encode string into felt with the Cairo short string representation
  parse-cairo-string  Decode string from felt with the Cairo short string representation
  mont                Print the montgomery representation of a field element
  call                Call contract functions without sending transactions
  transaction         Get Starknet transaction by hash
  block-number        Get latest block number
  block-hash          Get latest block hash
  block               Get Starknet block
  block-time          Get Starknet block timestamp only
  state-update        Get state update from a certain block
  receipt             Get transaction receipt by hash
  trace               Get transaction trace by hash
  chain-id            Get Starknet network ID
  balance             Get native gas token (currently ETH) balance
  nonce               Get nonce for a certain contract
  storage             Get storage value for a slot at a contract
  class-hash-at       Get contract class hash deployed at a certain address
  class-by-hash       Get contract class by hash
  class-at            Get contract class deployed at a certain address
  syncing             Get node syncing status
  signer              Signer management commands
  account             Account management commands
  invoke              Send an invoke transaction from an account contract
  declare             Declare a contract class
  deploy              Deploy contract via the Universal Deployer Contract
  completions         Generate bash completions script
  lab                 Experimental commands for fun and profit
  help                Print this message or the help of the given subcommand(s)

Options:
  -V, --version  Print version info and exit
  -v, --verbose  Use verbose output (currently only applied to version)
  -h, --help     Print help

~ via 🅒 base
➜
starkli account -h
Account management commands

Usage: starkli account <COMMAND>

Commands:
  fetch    Fetch account config from an already deployed account contract
  deploy   Deploy account contract with a DeployAccount transaction
  oz       Create and manage OpenZeppelin account contracts
  argent   Create and manage Argent X account contracts
  braavos  Create and manage Braavos account contracts
  help     Print this message or the help of the given subcommand(s)

Options:
  -h, --help  Print help

~ via 🅒 base
➜
export STARKNET_KEYSTORE=~/.starknet_accounts/key.json

~ via 🅒 base
➜
starkli account oz init  ~/.starknet_accounts/starkli.json
Enter keystore password:
Created new account config file: /Users/qiaopengjun/.starknet_accounts/starkli.json

Once deployed, this account will be available at:
    0x03886a342a2bc5a497bb3b4f3c4152c7b3778de4c638b05be7bca46b8476db2a

Deploy this account by running:
    starkli account deploy /Users/qiaopengjun/.starknet_accounts/starkli.json

~ via 🅒 base took 7.5s
➜
export STARKNET_RPC=https://starknet-testnet.public.blastapi.io

~ via 🅒 base
➜
starkli account deploy /Users/qiaopengjun/.starknet_accounts/starkli.json
Enter keystore password:
Error: JSON-RPC error: code=-32602, message="Invalid params", data={"reason":"expected value at line 1 column 491"}


~ via 🅒 base
➜
starkli -V
0.2.3 (5880a23)

~ via 🅒 base
➜
export STARKNET_RPC=https://starknet-testnet.public.blastapi.io/rpc/v0_6

~ via 🅒 base
➜
starkli account deploy /Users/qiaopengjun/.starknet_accounts/starkli.json
Enter keystore password:
The estimated account deployment fee is 0.000004431000062034 ETH. However, to avoid failure, fund at least:
    0.000006646500093051 ETH
to the following address:
    0x03886a342a2bc5a497bb3b4f3c4152c7b3778de4c638b05be7bca46b8476db2a
Press [ENTER] once you've funded the address.
Account deployment transaction: 0x0702470c421f248a6a3c3ff2c6398f433218fe0b0b18a45424860df12db35e24
Waiting for transaction 0x0702470c421f248a6a3c3ff2c6398f433218fe0b0b18a45424860df12db35e24 to confirm. If this process is interrupted, you will need to run `starkli account fetch` to update the account file.
Transaction not confirmed yet...
Transaction 0x0702470c421f248a6a3c3ff2c6398f433218fe0b0b18a45424860df12db35e24 confirmed

~ via 🅒 base took 17m 41.8s
➜
```

![image-20240112224741141](/images/image-20240112224741141.png)

![image-20240112224903698](/images/image-20240112224903698.png)

## 相关链接

- <https://blastapi.io/public-api/starknet>
- <https://faucet.goerli.starknet.io/>
- <https://book.cairo-lang.org/ch01-01-installation.html>
- <https://foundry-rs.github.io/starknet-foundry/getting-started/installation.html>
- <https://testnet.starkscan.co/tx/0x0702470c421f248a6a3c3ff2c6398f433218fe0b0b18a45424860df12db35e24>
- <https://testnet.starkscan.co/contract/0x03886a342a2bc5a497bb3b4f3c4152c7b3778de4c638b05be7bca46b8476db2a>
