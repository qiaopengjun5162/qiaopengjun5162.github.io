+++
title = "Solidity on Polkadot: Web3 实战开发指南"
description = "Solidity on Polkadot: Web3 实战开发指南"
date = 2025-03-22 16:03:50+08:00
[taxonomies]
categories = ["Solidity", "Polkadot", "Web3"]
tags = ["Solidity", "Polkadot", "Web3"]

+++

<!-- more -->

# Solidity on Polkadot: Web3 实战开发指南

Polkadot 2.0 为 Web3 开发者打开了一扇新大门：用熟悉的 Solidity 在跨链生态中挥洒创意。本文通过实战带你一步步掌握从项目搭建到合约部署的全流程，打造一个功能完备的 PaxonToken 代币合约。无论你是初学者还是资深开发者，这份指南都将助你快速融入 Polkadot 的 Web3 世界！

本文以 Polkadot 的 Westend Asset Hub 为实验场，基于 RISC-V 的 PVM 运行时，展示如何用 Solidity 开发并部署 PaxonToken——一个标准的 ERC-20 代币合约。从项目初始化、代码编写、全面测试到覆盖率分析，再到通过 Remix 实现部署上线，每一步都详细记录。最终，PaxonToken 在 Asset Hub 成功运行，为开发者提供了一条清晰的 Web3 实战路径，助力 Solidity 技能无缝迁移至 Polkadot 生态。

Asset Hub 是系统平行链。在 Westend 的 Asset Hub 上可以支持 Solidity 编写合约。它是在新的基于 RISC-V 的 PVM 上运行 Solidity 代码。**对于很多 DApp 和智能合约的开发者，这将是进入和了解 Polkadot 2.0 的绝佳路径**。

## 实操

Write a ERC20 contract according to IERC20 from scratch. Don't use library.

```bash
1. fork the project
2. create a folder with your ID like `homework-2/001`
3. complete the homework and create a PR
```

### 第一步：fork 并克隆项目

```bash
git clone git@github.com:qiaopengjun5162/2025-17-solidity-on-polkadot.git
正克隆到 '2025-17-solidity-on-polkadot'...
remote: Enumerating objects: 14, done.
remote: Counting objects: 100% (14/14), done.
remote: Compressing objects: 100% (10/10), done.
remote: Total 14 (delta 0), reused 11 (delta 0), pack-reused 0 (from 0)
接收对象中: 100% (14/14), 完成.
```

### 第二步：创建并初始化项目

在终端运行以下命令创建项目：

```bash
forge init PaxonToken
cd PaxonToken
```

实操如下：

```bash
2025-17-solidity-on-polkadot on  feature/homework on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ cd homework-2/1490/code        

2025-17-solidity-on-polkadot/homework-2/1490/code on  feature/homework on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ forge init PaxonToken

Warning: This is a nightly build of Foundry. It is recommended to use the latest stable version. Visit https://book.getfoundry.sh/announcements for more information. 
To mute this warning set `FOUNDRY_DISABLE_NIGHTLY_WARNING` in your environment. 

Initializing /Users/qiaopengjun/Code/polkadot/2025-17-solidity-on-polkadot/homework-2/1490/code/PaxonToken...
Installing forge-std in /Users/qiaopengjun/Code/polkadot/2025-17-solidity-on-polkadot/homework-2/1490/code/PaxonToken/lib/forge-std (url: Some("https://github.com/foundry-rs/forge-std"), tag: None)
Cloning into '/Users/qiaopengjun/Code/polkadot/2025-17-solidity-on-polkadot/homework-2/1490/code/PaxonToken/lib/forge-std'...
remote: Enumerating objects: 2086, done.
remote: Counting objects: 100% (1017/1017), done.
remote: Compressing objects: 100% (133/133), done.
remote: Total 2086 (delta 937), reused 893 (delta 884), pack-reused 1069 (from 1)
Receiving objects: 100% (2086/2086), 653.50 KiB | 997.00 KiB/s, done.
Resolving deltas: 100% (1413/1413), done.
    Installed forge-std v1.9.6
    Initialized forge project

2025-17-solidity-on-polkadot/homework-2/1490/code on  feature/homework [!+?] on 🐳 v27.5.1 (orbstack) via 🅒 base took 2.6s 
➜ export FOUNDRY_DISABLE_NIGHTLY_WARNING=1

2025-17-solidity-on-polkadot/homework-2/1490/code on  feature/homework [!+?] on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ cd PaxonToken          
```

### 第三步：查看项目目录结构

```bash
➜ tree . -L 6 -I 'target|cache|lib|out'   


.
├── README.md
├── foundry.toml
├── remappings.txt
├── script
│   └── PaxonToken.s.sol
├── src
│   └── PaxonToken.sol
└── test
    └── PaxonToken.t.sol

4 directories, 6 files
```

### 第四步：编写`PaxonToken.sol`文件

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// IERC20 Interface
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract PaxonToken is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address private _owner;

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 initialSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _owner = msg.sender;
        _totalSupply = initialSupply_ * 10 ** uint256(decimals_);
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "PaxonToken: caller is not the owner");
        _;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
        require(to != address(0), "PaxonToken: transfer to the zero address");
        require(_balances[msg.sender] >= amount, "PaxonToken: transfer amount exceeds balance");

        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "PaxonToken: approve to the zero address");

        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        require(from != address(0), "PaxonToken: transfer from the zero address");
        require(to != address(0), "PaxonToken: transfer to the zero address");
        require(_balances[from] >= amount, "PaxonToken: transfer amount exceeds balance");
        require(_allowances[from][msg.sender] >= amount, "PaxonToken: transfer amount exceeds allowance");

        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) external onlyOwner returns (bool) {
        require(to != address(0), "PaxonToken: mint to the zero address");
        require(amount > 0, "PaxonToken: mint amount must be greater than zero");

        _totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
        return true;
    }

    function burn(uint256 amount) external returns (bool) {
        require(amount > 0, "PaxonToken: burn amount must be greater than zero");
        require(_balances[msg.sender] >= amount, "PaxonToken: burn amount exceeds balance");

        _totalSupply -= amount;
        _balances[msg.sender] -= amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }
}

```

### 第五步：编写测试

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {PaxonToken} from "../src/PaxonToken.sol";

contract PaxonTokenTest is Test {
    PaxonToken token;
    address owner;
    address alice = address(0x1);
    address bob = address(0x2);

    function setUp() public {
        owner = address(this);
        token = new PaxonToken("Paxon Token", "PAX", 18, 1000); // 1000 tokens
    }

    function testInitialSupply() public view {
        assertEq(token.totalSupply(), 1000 * 10 ** 18);
        assertEq(token.balanceOf(address(this)), 1000 * 10 ** 18);
    }

    function testTransfer() public {
        token.transfer(alice, 100 * 10 ** 18);
        assertEq(token.balanceOf(alice), 100 * 10 ** 18);
        assertEq(token.balanceOf(address(this)), 900 * 10 ** 18);
    }

    function testApproveAndTransferFrom() public {
        token.approve(bob, 200 * 10 ** 18);
        assertEq(token.allowance(address(this), bob), 200 * 10 ** 18);

        vm.prank(bob);
        token.transferFrom(address(this), alice, 150 * 10 ** 18);
        assertEq(token.balanceOf(alice), 150 * 10 ** 18);
        assertEq(token.allowance(address(this), bob), 50 * 10 ** 18);
    }

    function testMint() public {
        uint256 initialSupply = token.totalSupply();
        token.mint(alice, 500 * 10 ** 18);
        assertEq(token.totalSupply(), initialSupply + 500 * 10 ** 18);
        assertEq(token.balanceOf(alice), 500 * 10 ** 18);
    }

    function testMintFailNotOwner() public {
        vm.prank(alice);
        vm.expectRevert("PaxonToken: caller is not the owner");
        token.mint(alice, 100 * 10 ** 18);
    }

    function testBurn() public {
        uint256 initialSupply = token.totalSupply();
        token.burn(300 * 10 ** 18);
        assertEq(token.totalSupply(), initialSupply - 300 * 10 ** 18);
        assertEq(token.balanceOf(address(this)), 700 * 10 ** 18);
    }

    function testBurnFailInsufficientBalance() public {
        vm.expectRevert("PaxonToken: burn amount exceeds balance");
        token.burn(2000 * 10 ** 18);
    }

    function testTransferToZeroAddress() public {
        vm.expectRevert("PaxonToken: transfer to the zero address");
        token.transfer(address(0), 100 * 10 ** 18);
    }

    function testMintZeroAmount() public {
        vm.expectRevert("PaxonToken: mint amount must be greater than zero");
        token.mint(alice, 0);
    }

    function testMetadata() public view {
        assertEq(token.name(), "Paxon Token");
        assertEq(token.symbol(), "PAX");
        assertEq(token.decimals(), 18);
    }

    function testAllowance() public {
        token.approve(bob, 200 * 10 ** 18);
        assertEq(token.allowance(address(this), bob), 200 * 10 ** 18);
    }

    function testTransferFromMaxAllowance() public {
        token.approve(bob, 200 * 10 ** 18);
        vm.prank(bob);
        token.transferFrom(address(this), alice, 200 * 10 ** 18);
        assertEq(token.balanceOf(alice), 200 * 10 ** 18);
        assertEq(token.allowance(address(this), bob), 0);
    }

    function testBurnZeroAmount() public {
        vm.expectRevert("PaxonToken: burn amount must be greater than zero");
        token.burn(0);
    }

    function testTransferInsufficientBalance() public {
        token.transfer(alice, 500 * 10 ** 18); // 先转移一些给 alice
        vm.prank(alice);
        vm.expectRevert("PaxonToken: transfer amount exceeds balance");
        token.transfer(bob, 501 * 10 ** 18); // alice 余额不足
    }

    function testApproveExplicit() public {
        token.approve(bob, 100 * 10 ** 18);
        assertEq(token.allowance(address(this), bob), 100 * 10 ** 18);
    }

    function testTransferFromFromZeroAddress() public {
        vm.prank(address(0));
        vm.expectRevert("PaxonToken: transfer from the zero address");
        token.transferFrom(address(0), alice, 100 * 10 ** 18);
    }

    function testTransferFromToZeroAddress() public {
        token.approve(bob, 200 * 10 ** 18);
        vm.prank(bob);
        vm.expectRevert("PaxonToken: transfer to the zero address");
        token.transferFrom(address(this), address(0), 100 * 10 ** 18);
    }

    function testTransferFromInsufficientBalance() public {
        token.transfer(alice, 100 * 10 ** 18);
        token.approve(bob, 200 * 10 ** 18);
        vm.prank(bob);
        vm.expectRevert("PaxonToken: transfer amount exceeds balance");
        token.transferFrom(alice, address(this), 101 * 10 ** 18);
    }

    function testTransferFromInsufficientAllowance() public {
        token.transfer(alice, 200 * 10 ** 18);
        vm.prank(alice);
        token.approve(bob, 100 * 10 ** 18);
        vm.prank(bob);
        vm.expectRevert("PaxonToken: transfer amount exceeds allowance");
        token.transferFrom(alice, address(this), 101 * 10 ** 18);
    }

    function testApproveToZeroAddress() public {
        vm.expectRevert("PaxonToken: approve to the zero address");
        token.approve(address(0), 100 * 10 ** 18);
    }

    function testTransferFromExplicitSuccess() public {
        token.transfer(alice, 200 * 10 ** 18);
        vm.prank(alice);
        token.approve(bob, 150 * 10 ** 18);
        vm.prank(bob);
        token.transferFrom(alice, address(this), 100 * 10 ** 18);
        assertEq(token.balanceOf(address(this)), 800 * 10 ** 18 + 100 * 10 ** 18);
    }

    function testMintToZeroAddress() public {
        vm.expectRevert("PaxonToken: mint to the zero address");
        token.mint(address(0), 100 * 10 ** 18);
    }
}

```

### 第六步：运行测试

```bash
2025-17-solidity-on-polkadot/homework-2/1490/code/PaxonToken on  feature/homework [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ forge test --match-path test/PaxonToken.t.sol --show-progress -vvvv
[⠊] Compiling...
[⠑] Compiling 1 files with Solc 0.8.20
[⠘] Solc 0.8.20 finished in 5.79s
Compiler run successful!
... ...

Suite result: ok. 22 passed; 0 failed; 0 skipped; finished in 6.71ms (19.21ms CPU time)

Ran 1 test suite in 195.04ms (6.71ms CPU time): 22 tests passed, 0 failed, 0 skipped (22 total tests)


2025-17-solidity-on-polkadot/homework-2/1490/code/PaxonToken on  feature/homework [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base took 7.2s 
➜ forge test --match-path test/PaxonToken.t.sol --show-progress -vv  
[⠊] Compiling...
No files changed, compilation skipped
test/PaxonToken.t.sol:PaxonTokenTest
  ↪ Suite result: ok. 22 passed; 0 failed; 0 skipped; finished in 5.88ms (14.33ms CPU time)

Ran 22 tests for test/PaxonToken.t.sol:PaxonTokenTest
[PASS] testAllowance() (gas: 36455)
[PASS] testApproveAndTransferFrom() (gas: 73307)
[PASS] testApproveExplicit() (gas: 36235)
[PASS] testApproveToZeroAddress() (gas: 9063)
[PASS] testBurn() (gas: 24292)
[PASS] testBurnFailInsufficientBalance() (gas: 11024)
[PASS] testBurnZeroAmount() (gas: 9249)
[PASS] testInitialSupply() (gas: 14309)
[PASS] testMetadata() (gas: 20369)
[PASS] testMint() (gas: 45470)
[PASS] testMintFailNotOwner() (gas: 13694)
[PASS] testMintToZeroAddress() (gas: 11191)
[PASS] testMintZeroAmount() (gas: 13204)
[PASS] testTransfer() (gas: 43464)
[PASS] testTransferFromExplicitSuccess() (gas: 74568)
[PASS] testTransferFromFromZeroAddress() (gas: 11678)
[PASS] testTransferFromInsufficientAllowance() (gas: 70213)
[PASS] testTransferFromInsufficientBalance() (gas: 70068)
[PASS] testTransferFromMaxAllowance() (gas: 53223)
[PASS] testTransferFromToZeroAddress() (gas: 36798)
[PASS] testTransferInsufficientBalance() (gas: 44359)
[PASS] testTransferToZeroAddress() (gas: 9508)
Suite result: ok. 22 passed; 0 failed; 0 skipped; finished in 5.88ms (14.33ms CPU time)

Ran 1 test suite in 194.77ms (5.88ms CPU time): 22 tests passed, 0 failed, 0 skipped (22 total tests)

```

### 第七步：查看测试覆盖率

```bash
2025-17-solidity-on-polkadot/homework-2/1490/code/PaxonToken on  feature/homework [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base 
➜ forge coverage                                                  
Warning: optimizer settings and `viaIR` have been disabled for accurate coverage reports.
If you encounter "stack too deep" errors, consider using `--ir-minimum` which enables `viaIR` with minimum optimization resolving most of the errors
[⠊] Compiling...
[⠒] Compiling 23 files with Solc 0.8.20
[⠢] Solc 0.8.20 finished in 3.13s
Compiler run successful!
Analysing contracts...
Running tests...

Ran 22 tests for test/PaxonToken.t.sol:PaxonTokenTest
[PASS] testAllowance() (gas: 38620)
[PASS] testApproveAndTransferFrom() (gas: 80129)
[PASS] testApproveExplicit() (gas: 38577)
[PASS] testApproveToZeroAddress() (gas: 9922)
[PASS] testBurn() (gas: 26957)
[PASS] testBurnFailInsufficientBalance() (gas: 11715)
[PASS] testBurnZeroAmount() (gas: 9522)
[PASS] testInitialSupply() (gas: 15397)
[PASS] testMetadata() (gas: 23286)
[PASS] testMint() (gas: 48708)
[PASS] testMintFailNotOwner() (gas: 14832)
[PASS] testMintToZeroAddress() (gas: 12088)
[PASS] testMintZeroAmount() (gas: 14202)
[PASS] testTransfer() (gas: 46170)
[PASS] testTransferFromExplicitSuccess() (gas: 79946)
[PASS] testTransferFromFromZeroAddress() (gas: 12944)
[PASS] testTransferFromInsufficientAllowance() (gas: 74764)
[PASS] testTransferFromInsufficientBalance() (gas: 73798)
[PASS] testTransferFromMaxAllowance() (gas: 57424)
[PASS] testTransferFromToZeroAddress() (gas: 39425)
[PASS] testTransferInsufficientBalance() (gas: 47024)
[PASS] testTransferToZeroAddress() (gas: 9986)
Suite result: ok. 22 passed; 0 failed; 0 skipped; finished in 9.51ms (23.01ms CPU time)

Ran 1 test suite in 201.54ms (9.51ms CPU time): 22 tests passed, 0 failed, 0 skipped (22 total tests)

╭-------------------------+-----------------+-----------------+-----------------+-----------------╮
| File                    | % Lines         | % Statements    | % Branches      | % Funcs         |
+=================================================================================================+
| script/PaxonToken.s.sol | 0.00% (0/6)     | 0.00% (0/4)     | 100.00% (0/0)   | 0.00% (0/2)     |
|-------------------------+-----------------+-----------------+-----------------+-----------------|
| src/PaxonToken.sol      | 100.00% (58/58) | 100.00% (45/45) | 100.00% (24/24) | 100.00% (13/13) |
|-------------------------+-----------------+-----------------+-----------------+-----------------|
| Total                   | 90.62% (58/64)  | 91.84% (45/49)  | 100.00% (24/24) | 86.67% (13/15)  |
╰-------------------------+-----------------+-----------------+-----------------+-----------------╯

```

![image-20250321155126194](/images/image-20250321155126194.png)

### 第八步：**运行测试并生成覆盖率报告**

```bash
2025-17-solidity-on-polkadot/homework-2/1490/code/PaxonToken on  feature/homework [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base took 4.1s 
➜ forge coverage > test-report.txt
Warning: optimizer settings and `viaIR` have been disabled for accurate coverage reports.
If you encounter "stack too deep" errors, consider using `--ir-minimum` which enables `viaIR` with minimum optimization resolving most of the errors
```

Test-report.txt

```txt
Compiling 23 files with Solc 0.8.20
Solc 0.8.20 finished in 3.13s
Compiler run successful!
Analysing contracts...
Running tests...

Ran 22 tests for test/PaxonToken.t.sol:PaxonTokenTest
[PASS] testAllowance() (gas: 38620)
[PASS] testApproveAndTransferFrom() (gas: 80129)
[PASS] testApproveExplicit() (gas: 38577)
[PASS] testApproveToZeroAddress() (gas: 9922)
[PASS] testBurn() (gas: 26957)
[PASS] testBurnFailInsufficientBalance() (gas: 11715)
[PASS] testBurnZeroAmount() (gas: 9522)
[PASS] testInitialSupply() (gas: 15397)
[PASS] testMetadata() (gas: 23286)
[PASS] testMint() (gas: 48708)
[PASS] testMintFailNotOwner() (gas: 14832)
[PASS] testMintToZeroAddress() (gas: 12088)
[PASS] testMintZeroAmount() (gas: 14202)
[PASS] testTransfer() (gas: 46170)
[PASS] testTransferFromExplicitSuccess() (gas: 79946)
[PASS] testTransferFromFromZeroAddress() (gas: 12944)
[PASS] testTransferFromInsufficientAllowance() (gas: 74764)
[PASS] testTransferFromInsufficientBalance() (gas: 73798)
[PASS] testTransferFromMaxAllowance() (gas: 57424)
[PASS] testTransferFromToZeroAddress() (gas: 39425)
[PASS] testTransferInsufficientBalance() (gas: 47024)
[PASS] testTransferToZeroAddress() (gas: 9986)
Suite result: ok. 22 passed; 0 failed; 0 skipped; finished in 13.52ms (43.74ms CPU time)

Ran 1 test suite in 204.43ms (13.52ms CPU time): 22 tests passed, 0 failed, 0 skipped (22 total tests)

╭-------------------------+-----------------+-----------------+-----------------+-----------------╮
| File                    | % Lines         | % Statements    | % Branches      | % Funcs         |
+=================================================================================================+
| script/PaxonToken.s.sol | 0.00% (0/9)     | 0.00% (0/9)     | 100.00% (0/0)   | 0.00% (0/2)     |
|-------------------------+-----------------+-----------------+-----------------+-----------------|
| src/PaxonToken.sol      | 100.00% (58/58) | 100.00% (45/45) | 100.00% (24/24) | 100.00% (13/13) |
|-------------------------+-----------------+-----------------+-----------------+-----------------|
| Total                   | 86.57% (58/67)  | 83.33% (45/54)  | 100.00% (24/24) | 86.67% (13/15)  |
╰-------------------------+-----------------+-----------------+-----------------+-----------------╯

```

### 第九步：生成详细的 HTML 覆盖率报告

需要更详细的可视化报告，可以生成 LCOV 文件并转换为 HTML 格式：

首先运行以下命令生成 LCOV 文件：

```bash
2025-17-solidity-on-polkadot/homework-2/1490/code/PaxonToken on  feature/homework [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base took 4.1s 
➜ forge coverage --report lcov --report-file coverage.lcov
Warning: optimizer settings and `viaIR` have been disabled for accurate coverage reports.
If you encounter "stack too deep" errors, consider using `--ir-minimum` which enables `viaIR` with minimum optimization resolving most of the errors
[⠊] Compiling...
[⠒] Compiling 23 files with Solc 0.8.20
[⠆] Solc 0.8.20 finished in 3.15s
Compiler run successful!
Analysing contracts...
Running tests...

Ran 22 tests for test/PaxonToken.t.sol:PaxonTokenTest
[PASS] testAllowance() (gas: 38620)
[PASS] testApproveAndTransferFrom() (gas: 80129)
[PASS] testApproveExplicit() (gas: 38577)
[PASS] testApproveToZeroAddress() (gas: 9922)
[PASS] testBurn() (gas: 26957)
[PASS] testBurnFailInsufficientBalance() (gas: 11715)
[PASS] testBurnZeroAmount() (gas: 9522)
[PASS] testInitialSupply() (gas: 15397)
[PASS] testMetadata() (gas: 23286)
[PASS] testMint() (gas: 48708)
[PASS] testMintFailNotOwner() (gas: 14832)
[PASS] testMintToZeroAddress() (gas: 12088)
[PASS] testMintZeroAmount() (gas: 14202)
[PASS] testTransfer() (gas: 46170)
[PASS] testTransferFromExplicitSuccess() (gas: 79946)
[PASS] testTransferFromFromZeroAddress() (gas: 12944)
[PASS] testTransferFromInsufficientAllowance() (gas: 74764)
[PASS] testTransferFromInsufficientBalance() (gas: 73798)
[PASS] testTransferFromMaxAllowance() (gas: 57424)
[PASS] testTransferFromToZeroAddress() (gas: 39425)
[PASS] testTransferInsufficientBalance() (gas: 47024)
[PASS] testTransferToZeroAddress() (gas: 9986)
Suite result: ok. 22 passed; 0 failed; 0 skipped; finished in 11.14ms (24.29ms CPU time)

Ran 1 test suite in 209.53ms (11.14ms CPU time): 22 tests passed, 0 failed, 0 skipped (22 total tests)
Wrote LCOV report.

```

然后使用 genhtml（需要先安装 LCOV 工具，例如通过 sudo apt install lcov 或 brew install lcov）将 LCOV 文件转换为 HTML 报告：

```bash
2025-17-solidity-on-polkadot/homework-2/1490/code/PaxonToken on  feature/homework [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base took 3.9s 
➜ genhtml coverage.lcov --output-directory coverage-report
Reading tracefile coverage.lcov.
Found 2 entries.
Found common filename prefix "/Users/qiaopengjun/Code/polkadot/2025-17-solidity-on-polkadot/homework-2/1490/code/PaxonToken"
Generating output.
Processing file src/PaxonToken.sol
  lines=58 hit=58 functions=13 hit=13
Processing file script/PaxonToken.s.sol
  lines=9 hit=0 functions=2 hit=0
Overall coverage rate:
  source files: 2
  lines.......: 86.6% (58 of 67 lines)
  functions...: 86.7% (13 of 15 functions)
Message summary:
  no messages were reported
```

完成后，打开 coverage-report/index.html 文件即可在浏览器中查看详细的覆盖率报告，显示每行代码的执行情况。

### ![image-20250321212123782](/images/image-20250321212123782.png)

### 第十步：remix 连接 本地项目

![image-20250321212747574](/images/image-20250321212747574.png)

```bash
2025-17-solidity-on-polkadot on  feature/homework [+?] on 🐳 v27.5.1 (orbstack) via 🅒 base took 25.9s 
➜ remixd -s /Users/qiaopengjun/Code/polkadot/2025-17-solidity-on-polkadot/homework-2/1490/code/PaxonToken -u http://remix.ethereum.org
[WARN] latest version of remixd is 0.6.44, you are using 0.6.41
[WARN] please update using the following command:
[WARN] yarn global add @remix-project/remixd
[WARN] You may now only use IDE at http://remix.ethereum.org to connect to that instance
[WARN] Any application that runs on your computer can potentially read from and write to all files in the directory.
[WARN] Symbolic links are not forwarded to Remix IDE

[INFO] Fri Mar 21 2025 21:39:28 GMT+0800 (China Standard Time) remixd is listening on 127.0.0.1:65520
[INFO] Fri Mar 21 2025 21:39:28 GMT+0800 (China Standard Time) slither is listening on 127.0.0.1:65523
[INFO] Fri Mar 21 2025 21:39:28 GMT+0800 (China Standard Time) foundry is listening on 127.0.0.1:65525
```

![image-20250321212908928](/images/image-20250321212908928.png)

连接失败：

![image-20250321214036897](/images/image-20250321214036897.png)

### 第十步：部署合约

![image-20250321224112251](/images/image-20250321224112251.png)

点击确认：

![image-20250321224023772](/images/image-20250321224023772.png)

成功部署：

![image-20250321224525654](/images/image-20250321224525654.png)

### 第十一步：查看合约

合约地址：0x8b5a5b438ca58167a7a6552d45f36490d4a1dadb

- <https://assethub-westend.subscan.io/account/0x8b5a5b438ca58167a7a6552d45f36490d4a1dadb>

![image-20250321224656585](/images/image-20250321224656585.png)

![image-20250321201532238](/images/image-20250321201532238.png)

## 总结

通过本次实战，我们用 Solidity 在 Polkadot 的 Asset Hub 上成功打造并上线了 PaxonToken，完整验证了从开发到部署的 Web3 开发流程。Polkadot 2.0 的开放性让开发者能轻松将以太坊经验应用于跨链生态，开启更多创新可能。这份指南不仅是入门的敲门砖，更是探索 Web3 未来的起点——现在，就用 Solidity 在 Polkadot 上开启你的实战之旅吧！

## 参考

- <https://www.youtube.com/watch?v=2QBa0Rk_4vo&list=PLKgwQU2jh_H-aBKhG3X7XueytJVl_YuiF&index=5>
- <https://wiki.polkadot.network/docs/build-smart-contracts>
- <https://wiki.acala.network/build/development-guide>
- <https://contracts.polkadot.io/tutorial/try>
- <https://support.subscan.io/doc-361776>
- <https://pro.subscan.io/overview>
- <https://github.com/papermoonio/2025-17-solidity-on-polkadot>
- <https://github.com/paritytech/>
- <https://github.com/paritytech/rust-contract-template/blob/master/src/main.rs>
- <https://github.com/paritytech/polkadot-sdk/blob/master/substrate/frame/revive/fixtures/contracts/balance.rs>
- <https://github.com/polkadot-evm/frontier>
- <https://remix-ide.readthedocs.io/en/latest/remixd.html#ports-usage>
- <https://remix-ide.readthedocs.io/zh-cn/latest/remixd.html>
- <https://faucet.polkadot.io/westend?parachain=1000>
- <https://mp.weixin.qq.com/s/f7QAQExGMLT4L7jbdwb_zw>
- <https://github.com/smol-dot/smoldot>
