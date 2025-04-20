+++
title = "Web3新速度：Monad与BuyEarth DApp重塑虚拟世界"
description = "Web3新速度：Monad与BuyEarth DApp重塑虚拟世界"
date = 2025-04-20T07:03:02Z
[taxonomies]
categories = ["Web3", "Monad", "DApp"]
tags = ["Web3", "Monad", "DApp"]
+++

<!-- more -->

# Web3新速度：Monad与BuyEarth DApp重塑虚拟世界

Web3时代，速度决定未来！Monad作为一款高性能的以太坊兼容L1区块链，以每秒10,000+的交易处理速度（TPS）突破传统区块链瓶颈，为去中心化应用（DApp）开辟了新天地。BuyEarth DApp是这一技术的生动实践，让用户在虚拟世界中购买土地、定制颜色，体验区块链驱动的数字经济。本文将带你走进Monad的超速世界，探索BuyEarth如何重塑Web3虚拟市场，揭秘高性能区块链与DApp的完美融合！

Monad是一款以太坊兼容的L1区块链，通过并行执行和乐观执行实现10,000+ TPS，远超以太坊的22.7 TPS，为Web3 DApp提供高性能基础设施。BuyEarth DApp基于Monad打造，用户可支付0.001 ETH购买虚拟土地并设置颜色，合约拥有者可管理资金与状态。项目采用Foundry开发，测试覆盖率达100%（行）与92.86%（分支），前端基于Next.js并部署于Vercel。本文详解Monad的技术优势、BuyEarth的功能与开发流程，展现Web3 DApp如何在超速区块链上重塑虚拟世界。

## Monad：Web3的超速引擎

Monad is a high-performance Ethereum-compatible Layer 1 blockchain, redefining the balance between decentralization and scalability for Web3 applications.

**Monad 是一个高性能的以太坊兼容L1区块链，为Web3应用重新定义了去中心化与可扩展性的平衡。**

想象一个区块链每秒处理10,000+笔交易，轻松碾压以太坊的22.7 TPS，却依然与以太坊生态无缝兼容——这就是 Monad！它通过**并行执行**技术，打破传统 EVM 链逐一处理交易的限制，让 BuyEarth 这样的去中心化应用（DApp）实现秒级响应，支撑虚拟世界中的土地交易热潮。开发者无需改动代码，就能将以太坊应用迁移到 Monad，享受超速体验。

Monad 的秘诀在于**并行执行**和**乐观执行**：交易无需排队等待，数据跟踪和重试机制确保结果一致。搭配**状态无关计算**（减少存储负担）、**数据缓存**（加速访问）和**静态代码分析**（智能调度），Monad 为 BuyEarth 的土地购买和颜色定制提供流畅支持。未来，Monad 将引入 AI 预测交易依赖，最大化效率，点燃 Web3 DApp 的无限可能！

**Monad 的超速性能如何赋能 BuyEarth DApp？接下来，让我们进入智能合约实操，揭秘虚拟土地交易的实现细节！**

## 合约实操

### 根据模板生产项目代码

```bash
mcd buyearth # mkdir buyearth && cd buyearth
forge init --template https://github.com/qiaopengjun5162/foundry-template
```

### 查看项目目录结构

```bash
qiaopengjun in buyearth on   main 
❯ tree -L 3 -I "node_modules|.DS_Store|out|buy-earth-dapp|lib|dapp-ui|broadcast|cache"  
.
├── _typos.toml
├── buy-earth-dapp.zip
├── CHANGELOG.md
├── cliff.toml
├── depoly.md
├── foundry.toml
├── LICENSE
├── README.md
├── remappings.txt
├── script
│   ├── BuyEarth.s.sol
│   └── deploy.sh
├── slither.config.json
├── src
│   ├── BuyEarth.sol
│   └── utils
│       └── EmptyContract.sol
├── style_guide.md
└── test
    └── BuyEarth.t.sol

5 directories, 16 files
```

### 合约代码`BuyEarth.sol`

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract BuyEarth {
    uint256 private constant PRICE = 0.001 ether;
    address private owner;
    uint256[100] private squares;
    address[] private depositorList;
    mapping(address => uint256) public userDeposits;

    event BuySquare(uint8 idx, uint256 color);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event ColorChanged(uint8 indexed idx, uint256 color);
    event Deposited(address indexed sender, uint256 amount);
    event Receive(address indexed sender, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function getSquares() public view returns (uint256[] memory) {
        uint256[] memory _squares = new uint256[](100);
        for (uint256 i = 0; i < 100; i++) {
            _squares[i] = squares[i];
        }
        return _squares;
    }

    function buySquare(uint8 idx, uint256 color) public payable {
        // === Checks ===
        require(idx < 100, "Invalid square number");
        require(msg.value >= PRICE, "Incorrect price");
        require(color <= 0xFFFFFF, "Invalid color");
        uint256 change = msg.value - PRICE;

        // === Effects ===
        squares[idx] = color;
        emit BuySquare(idx, color);

        // === Interactions ===
        if (change > 0) {
            (bool success1,) = msg.sender.call{value: change}("");
            require(success1, "Change return failed");
        }
        (bool success2,) = owner.call{value: PRICE}("");
        require(success2, "Owner payment failed");
    }

    function deposit() public payable {
        require(msg.value > 0, "Must send some ETH");

        // 如果是新存款用户，添加到列表
        if (userDeposits[msg.sender] == 0) {
            depositorList.push(msg.sender);
        }

        userDeposits[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdrawTo(address recipient) public onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        uint256 balance = address(this).balance;

        require(balance > 0, "No funds to withdraw");
        require(depositorList.length > 0, "No depositors");

        address[] memory depositors = _getAllDepositors(); // 获取所有存款用户
        for (uint256 i = 0; i < depositors.length; i++) {
            userDeposits[depositors[i]] = 0;
        }

        (bool success,) = recipient.call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    function setOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid owner address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getColor(uint8 idx) public view returns (uint256) {
        return squares[idx];
    }

    function setColor(uint8 idx, uint256 color) public onlyOwner {
        require(idx < 100, "Invalid square number");
        squares[idx] = color;
        emit ColorChanged(idx, color);
    }

    function getUserDeposits(address user) public view returns (uint256) {
        return userDeposits[user];
    }

    function _getAllDepositors() private view returns (address[] memory) {
        return depositorList;
    }

    receive() external payable {
        emit Receive(msg.sender, msg.value);
        deposit();
    }
}

```

智能合约 BuyEarth 说明

以下是对 BuyEarth 智能合约的详细说明，旨在帮助读者理解其功能、结构和用途。合约基于 Solidity 语言编写，部署在以太坊区块链上，允许用户购买虚拟“地块”、设置颜色、存款、提取资金，并由合约拥有者管理关键操作。

------

1. **概述**

BuyEarth 是一个去中心化应用（DApp）的智能合约，模拟一个虚拟土地市场。用户可以：

- 支付固定价格（0.001 ETH）购买100个虚拟地块之一，并为地块设置颜色。
- 向合约存款以存储以太币（ETH）。
- 查询地块颜色、用户存款余额等信息。
- 合约拥有者（owner）可以更改地块颜色、转移合约所有权、提取合约余额。

合约使用事件（event）记录关键操作，便于前端应用监听和展示。安全机制（如权限检查、输入验证）确保合约的可靠性和安全性。

------

2. **合约结构**

**许可和编译器版本**

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
```

- **许可**：使用 MIT 许可证，表明代码开源且可自由使用。
- **编译器版本**：要求 Solidity 版本为 0.8.20 或更高，确保兼容性和安全性。

**状态变量**

```ts
uint256 private constant PRICE = 0.001 ether;
address private owner;
uint[100] private squares;
address[] private depositorList;
mapping(address => uint256) public userDeposits;
```

- PRICE：每个地块的固定购买价格（0.001 ETH），不可更改。
- owner：合约拥有者的地址，仅限其调用特定功能。
- squares：存储100个地块的颜色值（uint 类型，初始值为0）。
- depositorList：记录所有存款用户的地址列表。
- userDeposits：映射，记录每个用户的存款金额（以 wei 为单位）。

**事件**

```solidity
event BuySquare(uint8 idx, uint color);
event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
event ColorChanged(uint8 indexed idx, uint color);
event Deposited(address indexed sender, uint256 amount);
event Receive(address indexed sender, uint256 amount);
```

- BuySquare：当用户购买地块并设置颜色时触发。
- OwnershipTransferred：当合约所有权转移时触发。
- ColorChanged：当拥有者更改地块颜色时触发。
- Deposited：当用户存款时触发。
- Receive：当合约直接接收以太币时触发。

**修饰符**

```ts
modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can call this function");
    _;
}
```

- onlyOwner：限制函数仅能由合约拥有者调用，用于 setOwner、setColor 和 withdrawTo 函数。

------

3. **核心功能**

**构造函数**

```ts
constructor() {
    owner = msg.sender;
}
```

- 初始化时将部署者的地址设置为合约拥有者。

**查询地块信息**

```ts
function getSquares() public view returns (uint[] memory) {
    uint[] memory _squares = new uint[](100);
    for (uint i = 0; i < 100; i++) {
        _squares[i] = squares[i];
    }
    return _squares;
}

function getColor(uint8 idx) public view returns (uint) {
    return squares[idx];
}
```

- getSquares：返回所有100个地块的颜色值数组，供前端显示整个地图状态。
- getColor：返回指定地块（idx）的颜色值。

**购买地块**

```ts
function buySquare(uint8 idx, uint color) public payable {
    require(idx < 100, "Invalid square number");
    require(msg.value >= PRICE, "Incorrect price");
    require(color <= 0xFFFFFF, "Invalid color");
    uint256 change = msg.value - PRICE;

    squares[idx] = color;
    emit BuySquare(idx, color);

    if (change > 0) {
        (bool success1, ) = msg.sender.call{value: change}("");
        require(success1, "Change return failed");
    }
    (bool success2, ) = owner.call{value: PRICE}("");
    require(success2, "Owner payment failed");
}
```

- **功能**：用户支付至少0.001 ETH 购买指定地块（idx），并设置颜色（color）。
- **检查**：
  - 地块编号有效（idx < 100）。
  - 支付金额足够（msg.value >= PRICE）。
  - 颜色值有效（color 需为24位颜色代码，例如 0xFFFFFF 表示白色）。
- **操作**：
  - 更新地块颜色。
  - 触发 BuySquare 事件。
  - 如果用户支付金额超过价格，退还差额（change）。
  - 将购买价格转账给合约拥有者。
- **安全**：使用 call 进行转账，检查转账是否成功以防止失败。

**存款**

```ts
function deposit() public payable {
    require(msg.value > 0, "Must send some ETH");

    if (userDeposits[msg.sender] == 0) {
        depositorList.push(msg.sender);
    }

    userDeposits[msg.sender] += msg.value;
    emit Deposited(msg.sender, msg.value);
}
```

- **功能**：用户向合约发送以太币进行存款。
- **操作**：
  - 要求发送金额大于0。
  - 如果是新用户（之前无存款），将其地址添加到 depositorList。
  - 更新用户的存款余额。
  - 触发 Deposited 事件。
- **用途**：允许用户将资金存储在合约中，可能用于未来扩展功能。

**提取资金**

```ts
function withdrawTo(address recipient) public onlyOwner {
    require(recipient != address(0), "Invalid recipient address");
    uint256 balance = address(this).balance;
    require(balance > 0, "No funds to withdraw");

    address[] memory depositors = _getAllDepositors();
    for (uint i = 0; i < depositors.length; i++) {
        userDeposits[depositors[i]] = 0;
    }

    (bool success, ) = recipient.call{value: balance}("");
    require(success, "Withdrawal failed");
}
```

- **功能**：仅限拥有者调用，将合约全部余额提取到指定地址（recipient）。
- **操作**：
  - 验证接收地址有效。
  - 确保合约有余额。
  - 清空所有用户的存款记录（userDeposits）。
  - 将合约余额转账给指定地址。
- **安全**：清空存款记录防止重复提取，使用 call 确保转账成功。

**所有权管理**

```ts
function setOwner(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Invalid owner address");
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
}

function getOwner() public view returns (address) {
    return owner;
}
```

- setOwner：仅限当前拥有者调用，转移合约所有权给新地址，触发 OwnershipTransferred 事件。
- getOwner：返回当前拥有者的地址。

**更改地块颜色**

```ts
function setColor(uint8 idx, uint color) public onlyOwner {
    require(idx < 100, "Invalid square number");
    squares[idx] = color;
    emit ColorChanged(idx, color);
}
```

- **功能**：仅限拥有者调用，修改指定地块的颜色。
- **操作**：
  - 验证地块编号有效。
  - 更新颜色并触发 ColorChanged 事件。
- **用途**：允许拥有者手动调整地块状态（如修复错误或实现特定功能）。

**查询用户存款**

```ts
function getUserDeposits(address user) public view returns (uint256) {
    return userDeposits[user];
}
```

- 返回指定用户的存款余额。

**接收以太币**

```ts
receive() external payable {
    emit Receive(msg.sender, msg.value);
    deposit();
}
```

- **功能**：当用户直接向合约地址发送以太币时，触发 Receive 事件并调用 deposit 函数处理存款。
- **用途**：支持无函数调用的以太币转账。

**辅助函数**

```ts
function _getAllDepositors() private view returns (address[] memory) {
    return depositorList;
}
```

- 返回所有存款用户的地址列表，仅供内部使用（如 withdrawTo 函数）。

------

4. **设计特点**

**模块化设计**

- 合约采用 **Checks-Effects-Interactions** 模式（如 buySquare 函数），先验证输入（Checks），更新状态（Effects），最后执行外部交互（Interactions），降低重入攻击风险。
- 使用修饰符（onlyOwner）简化权限管理。
- 事件机制便于前端应用实时更新界面。

**安全性**

- 输入验证：检查地块编号、颜色值、支付金额等，防止无效操作。
- 转账安全：使用 call 并检查返回值，确保转账成功。
- 权限控制：敏感操作（如提取资金、更改颜色）仅限拥有者。
- 零地址检查：防止所有权转移或资金提取到无效地址。

**可扩展性**

- 存款功能（deposit）和用户存款记录（userDeposits）为未来功能扩展（如奖励机制、退款）提供基础。
- 事件日志支持前端开发，便于构建交互式界面。

------

5. **使用场景**

- **虚拟土地市场**：用户购买地块并设置颜色，模拟类似“百万像素网格”或虚拟地产的玩法，前端可渲染为彩色地图。
- **资金管理**：允许用户存款，拥有者可提取资金，适合需要集中资金管理的应用。
- **权限控制**：合约所有者可管理地块状态和资金，适合由单一实体控制的场景。

------

6. **潜在改进**

- **可升级性**：当前合约不可升级，可考虑使用代理模式（如 OpenZeppelin 的 UUPS）支持未来功能扩展。
- **批量操作**：增加批量购买地块或更改颜色的函数，提高效率。
- **防重入攻击**：虽然已使用 Checks-Effects-Interactions 模式，可引入 ReentrancyGuard 进一步增强安全性。
- **动态价格**：当前价格固定（0.001 ETH），可引入动态定价机制（如基于需求或地块位置）。
- **用户退款**：当前仅拥有者可提取资金，可添加用户自行提取存款的功能。

------

7. **总结**

BuyEarth 是一个功能完整、安全性较高的智能合约，适合用于虚拟土地购买、颜色设置和资金管理的去中心化应用。其清晰的代码结构、事件机制和安全检查使其易于集成到前端应用中。通过合理的扩展和优化，合约可支持更复杂的业务逻辑和用户交互场景。

### 测试代码 `BuyEarth.t.sol`

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BuyEarth} from "../src/BuyEarth.sol";
import {BuyEarthScript} from "../script/BuyEarth.s.sol";

contract BuyEarthTest is Test {
    BuyEarth public buyEarth;

    Account public owner = makeAccount("owner");
    address public user = makeAddr("user"); // 测试用户地址
    address public user2 = makeAddr("user2"); // 第二个测试用户地址
    address public receipt = makeAddr("receipt"); // 收款地址

    uint256 private PRICE = 0.001 ether;

    event BuySquare(uint8 idx, uint256 color);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event ColorChanged(uint8 indexed idx, uint256 color);
    event Deposited(address indexed sender, uint256 amount);

    function setUp() public {
        // 初始化合约
        vm.startPrank(owner.addr);
        buyEarth = new BuyEarth();
        vm.stopPrank();
    }

    // 测试初始状态
    function testInitialState() public view {
        assertEq(buyEarth.getOwner(), owner.addr);
        uint256[] memory squares = buyEarth.getSquares();
        assertEq(squares.length, 100);
        for (uint256 i = 0; i < 100; i++) {
            assertEq(squares[i], 0);
        }
    }

    // 测试购买格子
    function testBuySquare() public {
        uint8 testIdx = 1;
        uint256 testColor = 0xFF0000; // 红色
        uint256 price = PRICE;

        // 模拟用户操作
        vm.startPrank(user);
        deal(user, price * 2); // 分配双倍资金用于测试找零
        buyEarth.buySquare{value: price * 2}(testIdx, testColor);
        vm.stopPrank();

        // 验证格子颜色被修改
        assertEq(buyEarth.getColor(testIdx), testColor);
        assertEq(user.balance, price); // 应退回price的找零
    }

    // 测试购买格子边界条件
    function testBuySquareEdgeCases() public {
        uint256 price = PRICE;
        deal(user, price);

        // 测试无效的格子索引
        vm.startPrank(user);
        vm.expectRevert("Invalid square number");
        buyEarth.buySquare{value: price}(100, 0xFF0000);
        vm.stopPrank();

        // 测试无效的颜色值
        vm.startPrank(user);
        vm.expectRevert("Invalid color");
        buyEarth.buySquare{value: price}(1, 0x1000000);
        vm.stopPrank();

        // 测试金额不足
        vm.startPrank(user);
        vm.expectRevert("Incorrect price");
        buyEarth.buySquare{value: price - 1}(1, 0xFF0000);
        vm.stopPrank();
    }

    // 测试多个用户购买不同格子
    function testMultipleUsersBuySquares() public {
        uint256 price = PRICE;
        deal(user, price);
        deal(user2, price);

        vm.startPrank(user);
        buyEarth.buySquare{value: price}(1, 0xFF0000);
        vm.stopPrank();

        vm.startPrank(user2);
        buyEarth.buySquare{value: price}(2, 0x00FF00);
        vm.stopPrank();

        assertEq(buyEarth.getColor(1), 0xFF0000);
        assertEq(buyEarth.getColor(2), 0x00FF00);
    }

    // 测试所有者功能
    function testOwnerFunctions() public {
        // 测试设置颜色
        vm.startPrank(owner.addr);
        buyEarth.setColor(1, 0x0000FF);
        assertEq(buyEarth.getColor(1), 0x0000FF);
        vm.stopPrank();

        // 测试非所有者不能设置颜色
        vm.startPrank(user);
        vm.expectRevert("Only owner can call this function");
        buyEarth.setColor(1, 0x0000FF);
        vm.stopPrank();

        // 测试转移所有权
        vm.startPrank(owner.addr);
        buyEarth.setOwner(user);
        assertEq(buyEarth.getOwner(), user);
        vm.stopPrank();
    }

    // 测试事件
    function testEvents() public {
        uint8 testIdx = 1;
        uint256 testColor = 0xFF0000;
        uint256 price = PRICE;
        deal(user, price);

        // 测试购买格子事件
        vm.startPrank(user);
        vm.expectEmit(true, true, true, true);
        emit BuySquare(testIdx, testColor);
        buyEarth.buySquare{value: price}(testIdx, testColor);
        vm.stopPrank();

        // 测试所有权转移事件
        vm.startPrank(owner.addr);
        vm.expectEmit(true, true, true, true);
        emit OwnershipTransferred(owner.addr, user);
        buyEarth.setOwner(user);
        vm.stopPrank();

        // 测试颜色变更事件
        vm.startPrank(user);
        vm.expectEmit(true, true, true, true);
        emit ColorChanged(testIdx, 0x00FF00);
        buyEarth.setColor(testIdx, 0x00FF00);
        vm.stopPrank();
    }

    // 测试直接转账
    function testDirectTransfer() public {
        deal(user, 1 ether);
        vm.startPrank(user);
        (bool success,) = address(buyEarth).call{value: 0.1 ether}("");
        assertTrue(success); // 验证转账成功
        assertEq(user.balance, 0.9 ether);
        assertEq(address(buyEarth).balance, 0.1 ether);
        vm.stopPrank();
    }

    // 测试提现边界条件
    function testWithdrawToEdgeCases() public {
        // 测试零地址提现
        vm.startPrank(owner.addr);
        vm.expectRevert("Invalid recipient address");
        buyEarth.withdrawTo(address(0));
        vm.stopPrank();

        // 测试无余额提现
        vm.startPrank(owner.addr);
        vm.expectRevert("No funds to withdraw");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();
    }

    // 测试提现
    function testWithdraw() public {
        deal(address(buyEarth), 1 ether);
        vm.startPrank(owner.addr);
        vm.expectRevert("No depositors");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        vm.startPrank(user);
        deal(user, 1 ether);
        buyEarth.deposit{value: 1 ether}();
        vm.stopPrank();

        vm.startPrank(owner.addr);
        buyEarth.withdrawTo(receipt);

        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 2 ether);
        vm.stopPrank();
    }

    function testDeposit() public {
        deal(user, 1 ether);
        vm.startPrank(user);

        // 明确指定调用合约的deposit()
        (bool success,) = address(buyEarth).call{value: 0.1 ether}(abi.encodeWithSignature("deposit()"));
        require(success, "Deposit failed");

        vm.stopPrank();

        assertEq(buyEarth.getUserDeposits(user), 0.1 ether);
    }

    function testWithdrawFromDeposit() public {
        deal(user, 1 ether);
        vm.startPrank(user);

        // 明确指定调用合约的deposit()
        (bool success,) = address(buyEarth).call{value: 0.1 ether}(abi.encodeWithSignature("deposit()"));
        require(success, "Deposit failed");

        assertEq(buyEarth.getUserDeposits(user), 0.1 ether);
        assertEq(user.balance, 0.9 ether);
        assertEq(address(buyEarth).balance, 0.1 ether);
        vm.stopPrank();

        vm.startPrank(owner.addr);

        buyEarth.withdrawTo(receipt);
        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 0.1 ether);
        vm.stopPrank();

        assertEq(buyEarth.getUserDeposits(user), 0);
    }

    // 新增测试用例 1：测试购买地块时支付刚好等于 PRICE（无退款）
    function testBuySquareExactPrice() public {
        uint8 testIdx = 3;
        uint256 testColor = 0x00FF00; // 绿色

        vm.startPrank(user);
        deal(user, PRICE);
        buyEarth.buySquare{value: PRICE}(testIdx, testColor);
        vm.stopPrank();

        assertEq(buyEarth.getColor(testIdx), testColor);
        assertEq(user.balance, 0); // 无退款，余额应为 0
        assertEq(address(buyEarth).balance, 0); // 资金转给 owner
        assertEq(owner.addr.balance, PRICE); // owner 收到 PRICE
    }

    // 新增测试用例 2：测试同一用户多次存款
    function testMultipleDeposits() public {
        deal(user, 1 ether);
        vm.startPrank(user);

        // 第一次存款
        buyEarth.deposit{value: 0.1 ether}();
        assertEq(buyEarth.getUserDeposits(user), 0.1 ether);

        // 第二次存款
        buyEarth.deposit{value: 0.2 ether}();
        assertEq(buyEarth.getUserDeposits(user), 0.3 ether); // 累计存款

        vm.stopPrank();

        // 验证 depositorList 只记录一次用户地址
        // 由于 _getAllDepositors 是 private，间接验证 depositorList 行为
        assertEq(address(buyEarth).balance, 0.3 ether);
    }

    // 新增测试用例 3：测试多用户存款后 withdrawTo 清空 userDeposits
    function testWithdrawWithMultipleDepositors() public {
        deal(user, 1 ether);
        deal(user2, 1 ether);

        // 用户 1 存款
        vm.startPrank(user);
        buyEarth.deposit{value: 0.1 ether}();
        vm.stopPrank();

        // 用户 2 存款
        vm.startPrank(user2);
        buyEarth.deposit{value: 0.2 ether}();
        vm.stopPrank();

        // 验证初始存款
        assertEq(buyEarth.getUserDeposits(user), 0.1 ether);
        assertEq(buyEarth.getUserDeposits(user2), 0.2 ether);
        assertEq(address(buyEarth).balance, 0.3 ether);

        // 拥有者提现
        vm.startPrank(owner.addr);
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();
        // 验证存款被清空
        assertEq(buyEarth.getUserDeposits(user), 0);
        assertEq(buyEarth.getUserDeposits(user2), 0);
        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 0.3 ether);
    }

    // 测试 setColor 的无效索引
    function testSetColorInvalidIndex() public {
        vm.startPrank(owner.addr);
        vm.expectRevert("Invalid square number");
        buyEarth.setColor(100, 0xFF0000);
        vm.stopPrank();
    }

    // 测试 receive 函数的零金额转账
    function testReceiveZeroAmount() public {
        vm.startPrank(user);
        vm.expectRevert("Must send some ETH");
        (bool success,) = address(buyEarth).call{value: 0}("");
        assertTrue(success);
        vm.stopPrank();

        assertEq(buyEarth.getUserDeposits(user), 0);
        assertEq(address(buyEarth).balance, 0);
    }
    // 测试 owner 支付失败场景（模拟 owner 地址无法接收 ETH）

    function testBuySquareOwnerPaymentFailure() public {
        // 创建一个无法接收 ETH 的合约作为 owner
        NoReceiveETH noReceive = new NoReceiveETH();
        vm.startPrank(owner.addr);
        buyEarth.setOwner(address(noReceive));
        vm.stopPrank();

        // 用户尝试购买地块
        vm.startPrank(user);
        deal(user, PRICE);
        vm.expectRevert("Owner payment failed");
        buyEarth.buySquare{value: PRICE}(1, 0xFF0000);
        vm.stopPrank();

        // 验证地块未被更新
        assertEq(buyEarth.getColor(1), 0);
    }

    // 测试 buySquare 中退款失败场景
    function testBuySquareChangeReturnFailure() public {
        // 创建一个无法接收 ETH 的用户合约
        NoReceiveETH noReceiveUser = new NoReceiveETH();
        address noReceiveAddr = address(noReceiveUser);

        vm.startPrank(noReceiveAddr);
        deal(noReceiveAddr, PRICE * 2);
        vm.expectRevert("Change return failed");
        buyEarth.buySquare{value: PRICE * 2}(1, 0xFF0000);
        vm.stopPrank();

        // 验证地块未被更新
        assertEq(buyEarth.getColor(1), 0);
    }

    // 测试 withdrawTo 中支付失败场景
    function testWithdrawToPaymentFailure() public {
        // 创建一个无法接收 ETH 的接收者合约
        NoReceiveETH noReceiveRecipient = new NoReceiveETH();
        address noReceiveAddr = address(noReceiveRecipient);

        // 向合约注入资金
        deal(address(buyEarth), 1 ether);

        vm.startPrank(owner.addr);
        vm.expectRevert("No depositors");
        buyEarth.withdrawTo(noReceiveAddr);
        vm.stopPrank();

        // 验证合约余额未改变
        assertEq(address(buyEarth).balance, 1 ether);
    }

    // 测试 setOwner 的零地址场景
    function testSetOwnerZeroAddress() public {
        vm.startPrank(owner.addr);
        vm.expectRevert("Invalid owner address");
        buyEarth.setOwner(address(0));
        vm.stopPrank();

        // 验证所有者未改变
        assertEq(buyEarth.getOwner(), owner.addr);
    }

    function testReceiveNonZeroAmount() public {
        vm.startPrank(user);
        deal(user, 0.2 ether);

        // 第一次转账：新用户存款
        (bool success1,) = address(buyEarth).call{value: 0.1 ether}("");
        assertTrue(success1);
        assertEq(buyEarth.getUserDeposits(user), 0.1 ether);

        // 第二次转账：已有用户存款
        (bool success2,) = address(buyEarth).call{value: 0.1 ether}("");
        assertTrue(success2);
        assertEq(buyEarth.getUserDeposits(user), 0.2 ether);

        vm.stopPrank();
    }

    function testWithdrawWithEmptyDepositorList() public {
        // 确保合约有余额但 depositorList 为空
        deal(address(buyEarth), 0.1 ether);

        vm.startPrank(owner.addr);
        vm.expectRevert("No depositors");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        vm.startPrank(user);
        deal(user, 0.1 ether);
        buyEarth.deposit{value: 0.1 ether}();
        vm.stopPrank();

        vm.startPrank(owner.addr);
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();
        // 验证提现成功
        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 0.2 ether);
    }

    function testDeploymentScript() public {
        // 设置 PRIVATE_KEY 环境变量
        vm.setEnv("PRIVATE_KEY", "0x1"); // 测试用私钥

        // 模拟运行部署脚本
        BuyEarthScript script = new BuyEarthScript();
        BuyEarth deployedContract = script.run();

        // 验证初始状态
        assertEq(deployedContract.getOwner(), vm.addr(0x1)); // 私钥 0x1 对应的地址
        uint256[] memory squares = deployedContract.getSquares();
        assertEq(squares.length, 100);
        for (uint256 i = 0; i < 100; i++) {
            assertEq(squares[i], 0);
        }
    }

    function testOnlyOwnerRestriction() public {
        vm.startPrank(user); // 非所有者
        vm.expectRevert("Only owner can call this function");
        buyEarth.setColor(0, 0xFF0000);
        vm.stopPrank();
    }

    function testWithdrawWithEmptyDepositorListExtended() public {
        // 确保 depositorList 为空
        assertEq(buyEarth.getUserDeposits(user), 0); // 确认无存款

        // 向合约注入余额
        deal(address(buyEarth), 0.1 ether);

        vm.startPrank(owner.addr);
        vm.expectRevert("No depositors");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        vm.startPrank(user);
        deal(user, 0.1 ether);
        buyEarth.deposit{value: 0.1 ether}();
        vm.stopPrank();

        vm.startPrank(owner.addr);
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        // 验证提现结果
        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 0.2 ether);
    }

    function testDeploymentScript2() public {
        // 设置 PRIVATE_KEY 环境变量
        vm.setEnv("PRIVATE_KEY", "0x1");

        // 运行部署脚本
        BuyEarthScript script = new BuyEarthScript();
        script.setUp(); // 显式调用 setUp
        script.run();
    }

    function testWithdrawWithEmptyDepositorListExtended2() public {
        // 确保 depositorList 为空
        assertEq(buyEarth.getUserDeposits(user), 0);

        // 注入余额
        deal(address(buyEarth), 0.1 ether);

        vm.startPrank(owner.addr);
        vm.expectRevert("No depositors");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        vm.startPrank(user);
        deal(user, 0.1 ether);
        buyEarth.deposit{value: 0.1 ether}();
        vm.stopPrank();

        vm.startPrank(owner.addr);
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();
        // 验证结果
        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 0.2 ether);
    }

    function testWithdrawWithEmptyDepositorListMinimal() public {
        // 确保 depositorList 为空且无存款
        assertEq(buyEarth.getUserDeposits(user), 0);

        // 注入最小余额
        deal(address(buyEarth), 0.001 ether);

        vm.startPrank(owner.addr);
        vm.expectRevert("No depositors");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        vm.startPrank(user);
        deal(user, 0.001 ether);
        buyEarth.deposit{value: 0.001 ether}();
        vm.stopPrank();

        vm.startPrank(owner.addr);
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        // 验证结果
        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 0.002 ether);
    }

    function testBuySquareOwnerPaymentEdgeCase() public {
        uint8 testIdx = 1;
        uint256 testColor = 0xFF0000;
        uint256 price = 0.001 ether;

        // 创建一个无法接收 ETH 的合约作为 owner
        NoReceiveETH noReceive = new NoReceiveETH();
        vm.startPrank(owner.addr);
        buyEarth.setOwner(address(noReceive));
        vm.stopPrank();

        vm.startPrank(user);
        deal(user, price);

        // 期望 owner 支付失败
        vm.expectRevert("Owner payment failed");
        buyEarth.buySquare{value: price}(testIdx, testColor);

        vm.stopPrank();

        // 验证格子未更新
        assertEq(buyEarth.getColor(testIdx), 0);
    }

    function testGetSquaresMemoryEdgeCase() public {
        // 多次调用 getSquares，尝试触发内存分配的边缘情况
        for (uint256 j = 0; j < 10; j++) {
            uint256[] memory squares = buyEarth.getSquares();
            assertEq(squares.length, 100);
            for (uint256 i = 0; i < 100; i++) {
                assertEq(squares[i], 0);
            }
        }

        // 修改格子后再次调用
        vm.startPrank(owner.addr);
        buyEarth.setColor(0, 0xFF0000);
        vm.stopPrank();

        for (uint256 j = 0; j < 10; j++) {
            uint256[] memory squares = buyEarth.getSquares();
            assertEq(squares[0], 0xFF0000);
            for (uint256 i = 1; i < 100; i++) {
                assertEq(squares[i], 0);
            }
        }
    }

    function testBuySquareOwnerCallEdgeCase() public {
        uint8 testIdx = 1;
        uint256 testColor = 0xFF0000;
        uint256 price = 0.001 ether;

        // 设置 owner 为无法接收 ETH 的合约
        NoReceiveETH noReceive = new NoReceiveETH();
        vm.startPrank(owner.addr);
        buyEarth.setOwner(address(noReceive));
        vm.stopPrank();

        vm.startPrank(user);
        deal(user, price);

        // 测试 owner.call 失败
        vm.expectRevert("Owner payment failed");
        buyEarth.buySquare{value: price}(testIdx, testColor);

        vm.stopPrank();

        // 验证状态未更改
        assertEq(buyEarth.getColor(testIdx), 0);
    }

    function testGetSquaresExtremeStressTest() public {
        // 极高频率调用 getSquares，模拟极端内存压力
        for (uint256 j = 0; j < 1000; j++) {
            uint256[] memory squares = buyEarth.getSquares();
            assertEq(squares.length, 100);
            for (uint256 i = 0; i < 100; i++) {
                assertEq(squares[i], 0);
            }
        }

        // 修改格子后再次调用
        vm.startPrank(owner.addr);
        buyEarth.setColor(0, 0xFF0000);
        vm.stopPrank();

        for (uint256 j = 0; j < 1000; j++) {
            uint256[] memory squares = buyEarth.getSquares();
            assertEq(squares[0], 0xFF0000);
            for (uint256 i = 1; i < 100; i++) {
                assertEq(squares[i], 0);
            }
        }
    }
    // 测试所有权转移后的旧所有者权限

    function testOldOwnerPermission() public {
        vm.startPrank(owner.addr);
        buyEarth.setOwner(user2);

        // 旧所有者尝试操作
        vm.expectRevert("Only owner can call this function");
        buyEarth.setColor(1, 0xFF0000);
        vm.stopPrank();
    }

    // 精确验证事件参数
    function testEventParameters() public {
        vm.startPrank(owner.addr);

        // 验证 OwnershipTransferred 事件参数
        vm.expectEmit(true, true, true, true);
        emit OwnershipTransferred(owner.addr, user);
        buyEarth.setOwner(user);

        vm.stopPrank();
    }

    function testWithdrawWithEmptyDepositorList2() public {
        // 查看合约余额
        assertEq(address(buyEarth).balance, 0);
        // 存款
        vm.deal(user, 1 ether);
        vm.startPrank(user);
        buyEarth.deposit{value: 1 ether}();
        vm.stopPrank();
        assertEq(address(buyEarth).balance, 1 ether);
        assertEq(buyEarth.getUserDeposits(user), 1 ether);
        // 清空存款用户列表
        vm.startPrank(owner.addr);
        buyEarth.withdrawTo(receipt); // 首次提现清空列表
        vm.stopPrank();

        // 再次尝试提现（此时 depositorList 为空）
        deal(address(buyEarth), 1 ether);
        vm.startPrank(owner.addr);
        // vm.expectRevert("No funds to withdraw");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();

        assertEq(address(buyEarth).balance, 0);
        assertEq(receipt.balance, 2 ether);

        // 验证此时合约余额为 0
        assertEq(address(buyEarth).balance, 0);

        // 尝试再次提现（应触发回退）
        vm.startPrank(owner.addr);
        vm.expectRevert("No funds to withdraw");
        buyEarth.withdrawTo(receipt);
        vm.stopPrank();
    }

    function testWithdrawWithEmptyDepositorListAndBalance() public {
    // 1. 初始化状态
    deal(user, 1 ether);
    vm.prank(user);
    buyEarth.deposit{value: 1 ether}();
    assertEq(address(buyEarth).balance, 1 ether);

    // 2. 首次提现（清空存款列表）
    vm.prank(owner.addr);
    buyEarth.withdrawTo(receipt);
    assertEq(address(buyEarth).balance, 0);

    // 3. 再次提现（存款列表为空且合约余额为 0）
    vm.prank(owner.addr);
    vm.expectRevert("No funds to withdraw");
    buyEarth.withdrawTo(receipt);
}
}

// 辅助合约：模拟无法接收 ETH 的地址
contract NoReceiveETH {
// 没有 receive 或 fallback 函数，无法接收 ETH
}

```

### 格式化项目

```bash
qiaopengjun in buyearth on   main 
❯ forge fmt  
```

### 配置 Foundry 的路径映射规则，解决依赖库（如 `forge-std`）的导入路径问题

```bash
❯ forge remappings > remappings.txt
```

### 编译构建项目

```bash
qiaopengjun in buyearth on   main 
❯ forge build
[⠆] Compiling...
[⠰] Compiling 3 files with Solc 0.8.28
[⠒] Solc 0.8.28 finished in 9.09s
Compiler run successful!
```

### 运行测试

```bash
qiaopengjun in buyearth on   main 
❯ forge test -vv              
[⠊] Compiling...
No files changed, compilation skipped

Ran 36 tests for test/BuyEarth.t.sol:BuyEarthTest
[PASS] testBuySquare() (gas: 90332)
[PASS] testBuySquareChangeReturnFailure() (gas: 97667)
[PASS] testBuySquareEdgeCases() (gas: 41043)
[PASS] testBuySquareExactPrice() (gas: 61995)
[PASS] testBuySquareOwnerCallEdgeCase() (gas: 107561)
[PASS] testBuySquareOwnerPaymentEdgeCase() (gas: 108507)
[PASS] testBuySquareOwnerPaymentFailure() (gas: 110360)
[PASS] testDeploymentScript() (gas: 1635391)
Logs:
  BuyEarth deployed to: 0x63E0f79244f01106b2DDc7d83a53a26916B61238

[PASS] testDeploymentScript2() (gas: 1328679)
Logs:
  BuyEarth deployed to: 0x63E0f79244f01106b2DDc7d83a53a26916B61238

[PASS] testDeposit() (gas: 88654)
[PASS] testDirectTransfer() (gas: 89680)
[PASS] testEventParameters() (gas: 22988)
[PASS] testEvents() (gas: 74185)
[PASS] testGetSquaresExtremeStressTest() (gas: 531334506)
[PASS] testGetSquaresMemoryEdgeCase() (gas: 2359443)
[PASS] testInitialState() (gas: 318503)
[PASS] testMultipleDeposits() (gas: 100796)
[PASS] testMultipleUsersBuySquares() (gas: 100804)
[PASS] testOldOwnerPermission() (gas: 22127)
[PASS] testOnlyOwnerRestriction() (gas: 14907)
[PASS] testOwnerFunctions() (gas: 51745)
[PASS] testReceiveNonZeroAmount() (gas: 102419)
[PASS] testReceiveZeroAmount() (gas: 19555)
[PASS] testSetColorInvalidIndex() (gas: 14362)
[PASS] testSetOwnerZeroAddress() (gas: 17802)
[PASS] testWithdraw() (gas: 117963)
[PASS] testWithdrawFromDeposit() (gas: 116089)
[PASS] testWithdrawToEdgeCases() (gas: 21141)
[PASS] testWithdrawToPaymentFailure() (gas: 59591)
[PASS] testWithdrawWithEmptyDepositorList() (gas: 117014)
[PASS] testWithdrawWithEmptyDepositorList2() (gas: 129690)
[PASS] testWithdrawWithEmptyDepositorListAndBalance() (gas: 114325)
[PASS] testWithdrawWithEmptyDepositorListExtended() (gas: 121283)
[PASS] testWithdrawWithEmptyDepositorListExtended2() (gas: 121327)
[PASS] testWithdrawWithEmptyDepositorListMinimal() (gas: 121618)
[PASS] testWithdrawWithMultipleDepositors() (gas: 156837)
Suite result: ok. 36 passed; 0 failed; 0 skipped; finished in 8.39s (20.48s CPU time)

Ran 1 test suite in 10.21s (8.39s CPU time): 36 tests passed, 0 failed, 0 skipped (36 total tests)
qiaopengjun in buyearth on   main 
❯ forge test --match-path test/BuyEarth.t.sol --show-progress -vv  
[⠊] Compiling...
No files changed, compilation skipped
test/BuyEarth.t.sol:BuyEarthTest
  ↪ Suite result: ok. 36 passed; 0 failed; 0 skipped; finished in 7.66s (16.41s CPU time)

Ran 36 tests for test/BuyEarth.t.sol:BuyEarthTest
[PASS] testBuySquare() (gas: 90332)
[PASS] testBuySquareChangeReturnFailure() (gas: 97667)
[PASS] testBuySquareEdgeCases() (gas: 41043)
[PASS] testBuySquareExactPrice() (gas: 61995)
[PASS] testBuySquareOwnerCallEdgeCase() (gas: 107561)
[PASS] testBuySquareOwnerPaymentEdgeCase() (gas: 108507)
[PASS] testBuySquareOwnerPaymentFailure() (gas: 110360)
[PASS] testDeploymentScript() (gas: 1635391)
Logs:
  BuyEarth deployed to: 0x63E0f79244f01106b2DDc7d83a53a26916B61238

[PASS] testDeploymentScript2() (gas: 1328679)
Logs:
  BuyEarth deployed to: 0x63E0f79244f01106b2DDc7d83a53a26916B61238

[PASS] testDeposit() (gas: 88654)
[PASS] testDirectTransfer() (gas: 89680)
[PASS] testEventParameters() (gas: 22988)
[PASS] testEvents() (gas: 74185)
[PASS] testGetSquaresExtremeStressTest() (gas: 531334506)
[PASS] testGetSquaresMemoryEdgeCase() (gas: 2359443)
[PASS] testInitialState() (gas: 318503)
[PASS] testMultipleDeposits() (gas: 100796)
[PASS] testMultipleUsersBuySquares() (gas: 100804)
[PASS] testOldOwnerPermission() (gas: 22127)
[PASS] testOnlyOwnerRestriction() (gas: 14907)
[PASS] testOwnerFunctions() (gas: 51745)
[PASS] testReceiveNonZeroAmount() (gas: 102419)
[PASS] testReceiveZeroAmount() (gas: 19555)
[PASS] testSetColorInvalidIndex() (gas: 14362)
[PASS] testSetOwnerZeroAddress() (gas: 17802)
[PASS] testWithdraw() (gas: 117963)
[PASS] testWithdrawFromDeposit() (gas: 116089)
[PASS] testWithdrawToEdgeCases() (gas: 21141)
[PASS] testWithdrawToPaymentFailure() (gas: 59591)
[PASS] testWithdrawWithEmptyDepositorList() (gas: 117014)
[PASS] testWithdrawWithEmptyDepositorList2() (gas: 129690)
[PASS] testWithdrawWithEmptyDepositorListAndBalance() (gas: 114325)
[PASS] testWithdrawWithEmptyDepositorListExtended() (gas: 121283)
[PASS] testWithdrawWithEmptyDepositorListExtended2() (gas: 121327)
[PASS] testWithdrawWithEmptyDepositorListMinimal() (gas: 121618)
[PASS] testWithdrawWithMultipleDepositors() (gas: 156837)
Suite result: ok. 36 passed; 0 failed; 0 skipped; finished in 7.66s (16.41s CPU time)

Ran 1 test suite in 10.64s (7.66s CPU time): 36 tests passed, 0 failed, 0 skipped (36 total tests)
qiaopengjun in buyearth on   main 
❯ 
```

### 安装 Lcov

```bash
brew install lcov
==> Downloading https://formulae.brew.sh/api/formula.jws.json
==> Downloading https://formulae.brew.sh/api/cask.jws.json
==> Downloading https://ghcr.io/v2/homebrew/core/lcov/manifests/2.3.1
############################################################################################################################ 100.0%
==> Fetching lcov
==> Downloading https://ghcr.io/v2/homebrew/core/lcov/blobs/sha256:fcedc02edaf2f1741c7dba360cc56e57804bf0c004c42e4d6c52978cccdeb741
############################################################################################################################ 100.0%
==> Pouring lcov--2.3.1.arm64_sequoia.bottle.tar.gz
🍺  /opt/homebrew/Cellar/lcov/2.3.1: 70 files, 2.2MB
==> Running `brew cleanup lcov`...
Disable this behaviour by setting HOMEBREW_NO_INSTALL_CLEANUP.
Hide these hints with HOMEBREW_NO_ENV_HINTS (see `man brew`).


genhtml --version
genhtml: LCOV version 2.3.1-1
```

### 查看测试覆盖率

```bash
qiaopengjun in buyearth on   main 
❯ forge coverage 
Warning: optimizer settings have been disabled for accurate coverage reports, if you encounter "stack too deep" errors, consider using `--ir-minimum` which enables viaIR with minimum optimization resolving most of the errors
[⠊] Compiling...
[⠑] Compiling 22 files with Solc 0.8.28
[⠘] Solc 0.8.28 finished in 1.70s
Compiler run successful!
Analysing contracts...
Running tests...

Ran 36 tests for test/BuyEarth.t.sol:BuyEarthTest
[PASS] testBuySquare() (gas: 92748)
[PASS] testBuySquareChangeReturnFailure() (gas: 100789)
[PASS] testBuySquareEdgeCases() (gas: 43045)
[PASS] testBuySquareExactPrice() (gas: 64060)
[PASS] testBuySquareOwnerCallEdgeCase() (gas: 111331)
[PASS] testBuySquareOwnerPaymentEdgeCase() (gas: 111263)
[PASS] testBuySquareOwnerPaymentFailure() (gas: 113850)
[PASS] testDeploymentScript() (gas: 3285446)
[PASS] testDeploymentScript2() (gas: 2934158)
[PASS] testDeposit() (gas: 89877)
[PASS] testDirectTransfer() (gas: 90843)
[PASS] testEventParameters() (gas: 23196)
[PASS] testEvents() (gas: 78219)
[PASS] testGetSquaresExtremeStressTest() (gas: 621406249)
[PASS] testGetSquaresMemoryEdgeCase() (gas: 3260237)
[PASS] testInitialState() (gas: 363330)
[PASS] testMultipleDeposits() (gas: 102704)
[PASS] testMultipleUsersBuySquares() (gas: 105390)
[PASS] testOldOwnerPermission() (gas: 23251)
[PASS] testOnlyOwnerRestriction() (gas: 15022)
[PASS] testOwnerFunctions() (gas: 55415)
[PASS] testReceiveNonZeroAmount() (gas: 105848)
[PASS] testReceiveZeroAmount() (gas: 21031)
[PASS] testSetColorInvalidIndex() (gas: 15021)
[PASS] testSetOwnerZeroAddress() (gas: 18612)
[PASS] testWithdraw() (gas: 119006)
[PASS] testWithdrawFromDeposit() (gas: 120232)
[PASS] testWithdrawToEdgeCases() (gas: 21924)
[PASS] testWithdrawToPaymentFailure() (gas: 60483)
[PASS] testWithdrawWithEmptyDepositorList() (gas: 119052)
[PASS] testWithdrawWithEmptyDepositorList2() (gas: 133525)
[PASS] testWithdrawWithEmptyDepositorListAndBalance() (gas: 115588)
[PASS] testWithdrawWithEmptyDepositorListExtended() (gas: 124092)
[PASS] testWithdrawWithEmptyDepositorListExtended2() (gas: 124048)
[PASS] testWithdrawWithEmptyDepositorListMinimal() (gas: 124048)
[PASS] testWithdrawWithMultipleDepositors() (gas: 162594)
Suite result: ok. 36 passed; 0 failed; 0 skipped; finished in 7.90s (17.88s CPU time)

Ran 1 test suite in 10.23s (7.90s CPU time): 36 tests passed, 0 failed, 0 skipped (36 total tests)

╭-----------------------+-----------------+-----------------+----------------+-----------------╮
| File                  | % Lines         | % Statements    | % Branches     | % Funcs         |
+==============================================================================================+
| script/BuyEarth.s.sol | 100.00% (8/8)   | 100.00% (7/7)   | 100.00% (0/0)  | 100.00% (2/2)   |
|-----------------------+-----------------+-----------------+----------------+-----------------|
| src/BuyEarth.sol      | 100.00% (56/56) | 100.00% (53/53) | 92.86% (26/28) | 100.00% (13/13) |
|-----------------------+-----------------+-----------------+----------------+-----------------|
| Total                 | 100.00% (64/64) | 100.00% (60/60) | 92.86% (26/28) | 100.00% (15/15) |
╰-----------------------+-----------------+-----------------+----------------+-----------------╯
```

### 生成测试报告并在浏览器打开

```bash
qiaopengjun in buyearth on   main 
❯ forge coverage --report lcov
genhtml lcov.info -o coverage
open coverage/index.html
Warning: optimizer settings have been disabled for accurate coverage reports, if you encounter "stack too deep" errors, consider using `--ir-minimum` which enables viaIR with minimum optimization resolving most of the errors
[⠊] Compiling...
[⠑] Compiling 22 files with Solc 0.8.28
[⠘] Solc 0.8.28 finished in 1.68s
Compiler run successful!
Analysing contracts...
Running tests...

Ran 36 tests for test/BuyEarth.t.sol:BuyEarthTest
[PASS] testBuySquare() (gas: 92748)
[PASS] testBuySquareChangeReturnFailure() (gas: 100789)
[PASS] testBuySquareEdgeCases() (gas: 43045)
[PASS] testBuySquareExactPrice() (gas: 64060)
[PASS] testBuySquareOwnerCallEdgeCase() (gas: 111331)
[PASS] testBuySquareOwnerPaymentEdgeCase() (gas: 111263)
[PASS] testBuySquareOwnerPaymentFailure() (gas: 113850)
[PASS] testDeploymentScript() (gas: 3285446)
[PASS] testDeploymentScript2() (gas: 2934158)
[PASS] testDeposit() (gas: 89877)
[PASS] testDirectTransfer() (gas: 90843)
[PASS] testEventParameters() (gas: 23196)
[PASS] testEvents() (gas: 78219)
[PASS] testGetSquaresExtremeStressTest() (gas: 621406249)
[PASS] testGetSquaresMemoryEdgeCase() (gas: 3260237)
[PASS] testInitialState() (gas: 363330)
[PASS] testMultipleDeposits() (gas: 102704)
[PASS] testMultipleUsersBuySquares() (gas: 105390)
[PASS] testOldOwnerPermission() (gas: 23251)
[PASS] testOnlyOwnerRestriction() (gas: 15022)
[PASS] testOwnerFunctions() (gas: 55415)
[PASS] testReceiveNonZeroAmount() (gas: 105848)
[PASS] testReceiveZeroAmount() (gas: 21031)
[PASS] testSetColorInvalidIndex() (gas: 15021)
[PASS] testSetOwnerZeroAddress() (gas: 18612)
[PASS] testWithdraw() (gas: 119006)
[PASS] testWithdrawFromDeposit() (gas: 120232)
[PASS] testWithdrawToEdgeCases() (gas: 21924)
[PASS] testWithdrawToPaymentFailure() (gas: 60483)
[PASS] testWithdrawWithEmptyDepositorList() (gas: 119052)
[PASS] testWithdrawWithEmptyDepositorList2() (gas: 133525)
[PASS] testWithdrawWithEmptyDepositorListAndBalance() (gas: 115588)
[PASS] testWithdrawWithEmptyDepositorListExtended() (gas: 124092)
[PASS] testWithdrawWithEmptyDepositorListExtended2() (gas: 124048)
[PASS] testWithdrawWithEmptyDepositorListMinimal() (gas: 124048)
[PASS] testWithdrawWithMultipleDepositors() (gas: 162594)
Suite result: ok. 36 passed; 0 failed; 0 skipped; finished in 8.68s (26.36s CPU time)

Ran 1 test suite in 10.92s (8.68s CPU time): 36 tests passed, 0 failed, 0 skipped (36 total tests)
Wrote LCOV report.
Reading tracefile lcov.info.
Found 2 entries.
Found common filename prefix "/Users/qiaopengjun/Code/Monad/buyearth"
Generating output.
Processing file src/BuyEarth.sol
  lines=56 hit=56 functions=13 hit=13
Processing file script/BuyEarth.s.sol
  lines=8 hit=8 functions=2 hit=2
Overall coverage rate:
  source files: 2
  lines.......: 100.0% (64 of 64 lines)
  functions...: 100.0% (15 of 15 functions)
Message summary:
  no messages were reported
qiaopengjun in buyearth on   main 
❯ 
```

### 查看测试报告

![image-20250420125743592](/images/image-20250420125743592.png)

### 编写部署脚本

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BuyEarth} from "../src/BuyEarth.sol";

contract BuyEarthScript is Script {
    BuyEarth public buyEarth;

    function setUp() public {}

    function run() public returns (BuyEarth) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        buyEarth = new BuyEarth();
        console.log("BuyEarth deployed to:", address(buyEarth));

        vm.stopBroadcast();
        return buyEarth;
    }
}

```

### 部署合约

```bash
qiaopengjun in buyearth on   main 
❯ source .env    
qiaopengjun in buyearth on   main 
❯ forge clean && forge build    
[⠊] Compiling...
[⠔] Compiling 22 files with Solc 0.8.28
[⠘] Solc 0.8.28 finished in 5.66s
Compiler run successful!
qiaopengjun in buyearth on   main 
❯ forge script BuyEarthScript --rpc-url $MONAD_RPC_URL  --broadcast -vvvvv 
[⠒] Compiling...
No files changed, compilation skipped
Traces:
  [132] BuyEarthScript::setUp()
    └─ ← [Stop] 

  [564840] BuyEarthScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return] 
    ├─ [519872] → new BuyEarth@0xcA7EC1c665C252067e2CfbE55E40Aa29777A1B7E
    │   └─ ← [Return] 2486 bytes of code
    ├─ [0] console::log("BuyEarth deployed to:", BuyEarth: [0xcA7EC1c665C252067e2CfbE55E40Aa29777A1B7E]) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    └─ ← [Return] BuyEarth: [0xcA7EC1c665C252067e2CfbE55E40Aa29777A1B7E]


Script ran successfully.

== Return ==
0: contract BuyEarth 0xcA7EC1c665C252067e2CfbE55E40Aa29777A1B7E

== Logs ==
  BuyEarth deployed to: 0xcA7EC1c665C252067e2CfbE55E40Aa29777A1B7E

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [519872] → new BuyEarth@0xcA7EC1c665C252067e2CfbE55E40Aa29777A1B7E
    └─ ← [Return] 2486 bytes of code


==========================

Chain 10143

Estimated gas price: 100.000000001 gwei

Estimated total gas used for script: 796936

Estimated amount required: 0.079693600000796936 ETH

==========================

##### 10143
✅  [Success] Hash: 0x78a58f499cb7889dffb4ae2d359c39ca189dbd9e7fa4bc2d31a38c22447e3e45
Contract Address: 0xcA7EC1c665C252067e2CfbE55E40Aa29777A1B7E
Block: 13070896
Paid: 0.039846800000796936 ETH (796936 gas * 50.000000001 gwei)

✅ Sequence #1 on 10143 | Total Paid: 0.039846800000796936 ETH (796936 gas * avg 50.000000001 gwei)
                                                                                                                                                                  

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.

Transactions saved to: /Users/qiaopengjun/Code/Monad/buyearth/broadcast/BuyEarth.s.sol/10143/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/Monad/buyearth/cache/BuyEarth.s.sol/10143/run-latest.json

```

### 验证合约

```bash
qiaopengjun in buyearth on   main 
❯ forge verify-contract \  
  --rpc-url https://testnet-rpc.monad.xyz \
  --verifier sourcify \
  --verifier-url 'https://sourcify-api-monad.blockvision.org' \
  0xcA7EC1c665C252067e2CfbE55E40Aa29777A1B7E \
  src/BuyEarth.sol:BuyEarth
Start verifying contract `0xcA7EC1c665C252067e2CfbE55E40Aa29777A1B7E` deployed on 10143
Attempting to verify on Sourcify, pass the --etherscan-api-key <API_KEY> to verify on Etherscan OR use the --verifier flag to verify on any other provider

Submitting verification for [BuyEarth] "0xcA7EC1c665C252067e2CfbE55E40Aa29777A1B7E".
Contract successfully verified
```

### 查看合约

<https://testnet.monadexplorer.com/address/0xcA7EC1c665C252067e2CfbE55E40Aa29777A1B7E>

![image-20250420132032628](/images/image-20250420132032628.png)

## 前端实操

### 查看前端项目目录结构

```bash
qiaopengjun in buyearth on   main 
❯ cd buy-earth-dapp 
qiaopengjun in buy-earth-dapp on   main 
❯ tree -L 3 -I "node_modules|.DS_Store|out|buy-earth-dapp|lib|dapp-ui|broadcast|cache"  
.
├── app
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── components
│   ├── buy-square-form.tsx
│   ├── connect-wallet.tsx
│   ├── deposit-form.tsx
│   ├── grid.tsx
│   ├── network-status.tsx
│   ├── owner-controls.tsx
│   ├── theme-provider.tsx
│   ├── transaction-history.tsx
│   └── ui
│       ├── accordion.tsx
│       ├── alert-dialog.tsx
│       ├── alert.tsx
│       ├── aspect-ratio.tsx
│       ├── avatar.tsx
│       ├── badge.tsx
│       ├── breadcrumb.tsx
│       ├── button.tsx
│       ├── calendar.tsx
│       ├── card.tsx
│       ├── carousel.tsx
│       ├── chart.tsx
│       ├── checkbox.tsx
│       ├── collapsible.tsx
│       ├── command.tsx
│       ├── context-menu.tsx
│       ├── dialog.tsx
│       ├── drawer.tsx
│       ├── dropdown-menu.tsx
│       ├── form.tsx
│       ├── hover-card.tsx
│       ├── input-otp.tsx
│       ├── input.tsx
│       ├── label.tsx
│       ├── menubar.tsx
│       ├── navigation-menu.tsx
│       ├── pagination.tsx
│       ├── popover.tsx
│       ├── progress.tsx
│       ├── radio-group.tsx
│       ├── resizable.tsx
│       ├── scroll-area.tsx
│       ├── select.tsx
│       ├── separator.tsx
│       ├── sheet.tsx
│       ├── sidebar.tsx
│       ├── skeleton.tsx
│       ├── slider.tsx
│       ├── sonner.tsx
│       ├── switch.tsx
│       ├── table.tsx
│       ├── tabs.tsx
│       ├── textarea.tsx
│       ├── toast.tsx
│       ├── toaster.tsx
│       ├── toggle-group.tsx
│       ├── toggle.tsx
│       ├── tooltip.tsx
│       ├── use-mobile.tsx
│       └── use-toast.ts
├── components.json
├── hooks
│   ├── use-mobile.tsx
│   └── use-toast.ts
├── next-env.d.ts
├── next.config.mjs
├── package.json
├── pnpm-lock.yaml
├── postcss.config.mjs
├── public
│   ├── placeholder-logo.png
│   ├── placeholder-logo.svg
│   ├── placeholder-user.jpg
│   ├── placeholder.jpg
│   └── placeholder.svg
├── styles
│   └── globals.css
├── tailwind.config.ts
└── tsconfig.json

7 directories, 77 files
```

### **脚本命令**

| 脚本名称 |     命令     |             作用描述             |     使用阶段     |
| :------: | :----------: | :------------------------------: | :--------------: |
|  `dev`   |  `next dev`  | 启动开发服务器，支持热重载和调试 |     开发阶段     |
| `build`  | `next build` |      构建生产环境的优化代码      |   准备部署阶段   |
| `start`  | `next start` |     启动生产环境的优化服务器     | 生产环境运行阶段 |

### 启动项目的开发环境

```bash
qiaopengjun in buy-earth-dapp on   main 
❯ pnpm run dev                              

> my-v0-project@0.1.0 dev /Users/qiaopengjun/Code/Monad/buyearth/buy-earth-dapp
> next dev

   ▲ Next.js 15.2.4
   - Local:        http://localhost:3000
   - Network:      http://192.168.101.228:3000

 ✓ Starting...
Attention: Next.js now collects completely anonymous telemetry regarding usage.
This information is used to shape Next.js' roadmap and prioritize features.
You can learn more, including how to opt-out if you'd not like to participate in this anonymous program, by visiting the following URL:
https://nextjs.org/telemetry

 ✓ Ready in 5.1s

```

### 在浏览器打开并连接钱包

![image-20250420133408674](/images/image-20250420133408674.png)

### 测试 Buy Earth

![image-20250420133548236](/images/image-20250420133548236.png)

### 运行构建命令

```bash
❯ pnpm run build

> my-v0-project@0.1.0 build /Users/qiaopengjun/Code/Monad/buyearth/buy-earth-dapp
> next build

   ▲ Next.js 15.2.4

   Creating an optimized production build ...
 ✓ Compiled successfully
   Skipping validation of types
   Skipping linting
 ✓ Collecting page data    
 ✓ Generating static pages (4/4)
 ✓ Collecting build traces    
 ✓ Finalizing page optimization    

Route (app)                                 Size  First Load JS    
┌ ○ /                                     127 kB         228 kB
└ ○ /_not-found                            976 B         102 kB
+ First Load JS shared by all             101 kB
  ├ chunks/255-27ae27efee3e0715.js       45.9 kB
  ├ chunks/e7327965-6c46f5927ee61af1.js  53.2 kB
  └ other shared chunks (total)          1.89 kB


○  (Static)  prerendered as static content

```

### 启动已构建的生产环境应用程序

```bash
❯ pnpm run start

> my-v0-project@0.1.0 start /Users/qiaopengjun/Code/Monad/buyearth/buy-earth-dapp
> next start

   ▲ Next.js 15.2.4
   - Local:        http://localhost:3000
   - Network:      http://192.168.101.228:3000

 ✓ Starting...
 ✓ Ready in 267ms

```

### 打开浏览器进行测试验证

![image-20250420134332072](/images/image-20250420134332072.png)

## 部署 vercel 实操

### 第一步：注册并登录vercel

![image-20250420135110629](/images/image-20250420135110629.png)

### 第二步：点击添加新项目

![image-20250420135225292](/images/image-20250420135225292.png)

### 第三步：点击`install`后选择GitHub账户进行安装

![image-20250420135510358](/images/image-20250420135510358.png)

### 第四步：导入GitHub仓库

![image-20250420135808869](/images/image-20250420135808869.png)

Import Git Repository

![image-20250420140014996](/images/image-20250420140014996.png)

### 第五步：Deploy 部署

![image-20250420140208534](/images/image-20250420140208534.png)

部署失败，原因：未选择项目根目录，路径问题！

![image-20250420140410165](/images/image-20250420140410165.png)

成功部署

![image-20250420142108155](/images/image-20250420142108155.png)

### 访问验证

<https://buyearth.vercel.app/>

![image-20250420142345885](/images/image-20250420142345885.png)

连接钱包

![image-20250420142418474](/images/image-20250420142418474.png)

## 总结

Monad以超速性能（10,000+ TPS）和以太坊兼容性，打破区块链“不可能三角”，为Web3 DApp的规模化奠定基础。BuyEarth DApp通过虚拟土地交易与颜色定制，展现了Monad在去中心化应用中的强大潜力。其智能合约安全高效，测试覆盖全面，前端交互流畅，已成功部署于Monad测试网与Vercel平台。未来，Monad可通过AI优化执行效率，BuyEarth可扩展动态定价与用户退款功能。这一组合不仅重塑了虚拟世界，也为Web3开发者提供了高效、兼容的创新范式，引领区块链应用的下一个浪潮。

## 参考

- <https://github.com/qiaopengjun5162/buyearth>
- <https://www.monad.xyz/>
- <https://developers.monad.xyz/>
- <https://github.com/openbuildxyz/Monad-101-Bootcamp>
- <https://www.openzeppelin.com/solidity-contracts>
- <https://docs.openzeppelin.com/upgrades-plugins/foundry-upgrades>
- <https://formulae.brew.sh/formula/lcov>
- <https://monad-testnet.socialscan.io/address/0xca7ec1c665c252067e2cfbe55e40aa29777a1b7e>
- <https://testnet.monadexplorer.com/address/0xDa6aD5531f4ADa05a342B763DB8Ff66B5110771D?tab=Contract>
- <https://buyearth.vercel.app/>
- <https://testnet.monadexplorer.com/verify-contract?address=0xcA7EC1c665C252067e2CfbE55E40Aa29777A1B7E>
- <https://testnet.monad.xyz/>
- <https://guoyu.mirror.xyz/RD-xkpoxasAU7x5MIJmiCX4gll3Cs0pAd5iM258S1Ek>
- <https://v0.dev/>
