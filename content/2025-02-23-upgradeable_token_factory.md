+++
title = "Foundry 高级实战：实现一个可升级的工厂合约 UpgradeableTokenFactory"
description = "Foundry 高级实战：实现一个可升级的工厂合约 UpgradeableTokenFactory"
date = 2025-02-23 09:21:40+08:00
[taxonomies]
categories = ["Web3", "Foundry", "Solidity", "Contract", "Ethereum"]
tags = ["Web3", "Foundry", "Solidity", "Contract", "Ethereum"]
+++

<!-- more -->

# Foundry 高级实战：实现一个可升级的工厂合约 UpgradeableTokenFactory

## 实践可升级合约及最小代理

挑战以铸币工厂为例， 理解可升级合约的编写及最小代理如何节省 Gas 。

实现⼀个可升级的工厂合约，工厂合约有两个方法：

1. `deployInscription(string symbol, uint totalSupply, uint perMint)` ，该方法用来创建 ERC20 token，（模拟铭文的 deploy）， symbol 表示 Token 的名称，totalSupply 表示可发行的数量，perMint 用来控制每次发行的数量，用于控制`mintInscription`函数每次发行的数量
2. `mintInscription(address tokenAddr)` 用来发行 ERC20 token，每次调用一次，发行perMint指定的数量。

要求：
• 合约的第⼀版本用普通的 new 的方式发行 ERC20 token 。
• 第⼆版本，deployInscription 加入一个价格参数 price `deployInscription(string symbol, uint totalSupply, uint perMint, uint price)` , price 表示发行每个 token 需要支付的费用，并且 第⼆版本使用最小代理的方式以更节约 gas 的方式来创建 ERC20 token，需要同时修改 mintInscription 的实现以便收取每次发行的费用。

## token 的创建和发行不需要任何中心化的管理者

#### 在某些区块链项目中，**token 的创建和发行不需要任何中心化的管理者**，这种设计背后体现了区块链技术的一些核心思想，包括去中心化、公平性和透明性

### 解释

1. **没有管理员**：
   - 在这种系统中，token 的创建和发行是通过智能合约自动执行的，没有一个中心化的实体（如传统金融中的银行或公司）来干预或管理这一过程。所有的操作都是由智能合约代码决定的，而智能合约的执行是去中心化的。

2. **公平发射**：
   - 公平发射（Fair Launch）指的是所有参与者在创建和发行 token 时，拥有平等的机会，没有任何人或组织可以通过特权获得额外的优势或机会。这种方式可以避免早期投资者或特权用户对 token 的不公平控制。

3. **铭文火的背后思想**：
   - 这种思想反映了区块链和去中心化技术的核心理念，即通过智能合约的自执行机制，去中心化地管理 token 的生命周期，从而减少对中心化控制的依赖，增加系统的透明度和公平性。

### 如何实现

1. **智能合约**：
   - 使用智能合约自动化创建和发行 token 的流程。例如，发行 ERC20 token 或 ERC721 NFT，可以通过智能合约定义和执行这些操作。

2. **去中心化**：
   - 在没有中心化管理员的情况下，所有操作和决策都是由智能合约和区块链网络的共识机制决定的。所有的创建和发行过程都是透明的，所有参与者都可以在区块链上查看。

3. **公平性**：
   - 公平发射可能涉及设计机制确保所有用户能够以相同的条件获得 token。例如，不通过私募或预售，而是通过公开拍卖或其他公平的分发方式进行发行。

### 示例

- **DeFi 代币**：很多去中心化金融（DeFi）项目的 token 发行采用了公平发射的方式，不依赖于传统的中心化机构，所有人可以通过参与特定的去中心化平台获得代币。

- **NFT 项目**：某些 NFT 项目也可能采用这种方式，在没有中心化管理者的情况下，通过智能合约进行公开的铸造（minting）和分发。

##### token 的创建和发行不需要管理员，这个是铭文火的背后思想，没有管理员，公平发射

这句话强调了去中心化和公平发射在区块链和加密货币项目中的重要性，突出了技术对传统管理模式的挑战。

## 什么是虚函数

在 Solidity 中，虚函数（Virtual Function）指的是一种可以被子合约重写的方法。虚函数是一种合约的函数声明，它允许在派生合约中定义特定的实现，而不是在基合约中提供一个固定的实现。

### 虚函数的概念

- **虚函数**：在基合约中声明的函数，可以被派生合约重写以提供不同的实现。
- **覆盖**：派生合约中的实现会覆盖基合约中的实现。

### 如何使用虚函数

在 Solidity 中，你可以通过以下步骤定义和使用虚函数：

1. **定义虚函数**：
   在基合约中使用 `virtual` 关键字标记函数，表示该函数可以被子合约重写。

   ```ts
   pragma solidity ^0.8.0;
   
   contract BaseContract {
       // 声明虚函数
       function getValue() public virtual pure returns (uint256) {
           return 1;
       }
   }
   ```

2. **重写虚函数**：
   在派生合约中使用 `override` 关键字实现虚函数的具体逻辑。

   ```ts
   pragma solidity ^0.8.0;
   
   contract DerivedContract is BaseContract {
       // 重写虚函数
       function getValue() public override pure returns (uint256) {
           return 2;
       }
   }
   ```

### 示例解释

```ts
pragma solidity ^0.8.0;

contract BaseContract {
    // 声明虚函数
    function getValue() public virtual pure returns (uint256) {
        return 1;
    }
}

contract DerivedContract is BaseContract {
    // 重写虚函数
    function getValue() public override pure returns (uint256) {
        return 2;
    }
}
```

在上面的代码中：

- `BaseContract` 中的 `getValue()` 函数被标记为 `virtual`，这意味着它可以在派生合约中被重写。
- `DerivedContract` 中重写了 `getValue()` 函数，使用 `override` 关键字表示这个函数重写了基合约中的 `getValue()` 函数。

### 虚函数的特点

- **多态性**：虚函数实现了面向对象编程中的多态性，使得你可以在不同的派生合约中提供不同的实现。
- **合约继承**：虚函数使得合约的继承机制更加灵活，可以通过继承链中的不同实现来实现复杂的逻辑。

### 注意事项

- **构造函数**：构造函数不能是虚函数。
- **访问控制**：虚函数和覆盖函数的访问控制修饰符必须一致，例如都为 `public` 或 `external`。
- **`override` 关键字**：派生合约中重写的函数必须使用 `override` 关键字标记。

虚函数是 Solidity 合约开发中实现灵活和可扩展设计的重要工具。

## 什么情况下会用到`delegatecall`?

- 代理合约（`Proxy Contract`）：将智能合约的存储合约和逻辑合约分开：代理合约（`Proxy Contract`）存储所有相关的变量，并且保存逻辑合约的地址；所有函数存在逻辑合约（`Logic Contract`）里，通过`delegatecall`执行。当升级时，只需要将代理合约指向新的逻辑合约即可。
- EIP-2535 Diamonds（钻石）：钻石是一个支持构建可在生产中扩展的模块化智能合约系统的标准。钻石是具有多个实施合约的代理合约。

### EIP-1967

<https://eips.ethereum.org/EIPS/eip-1967>

![image-20240728185442784](/images/image-20240728185442784.png)

## 合约升级方式

- 透明代理（Transparent Proxy）- ERC1967Proxy
- UUPS（universal upgradeable proxy standard）- ERC-1822

### ERC-1822: Universal Upgradeable Proxy Standard (UUPS)

# ![ERC-1822UUPS](https://eips.ethereum.org/assets/eip-1822/proxy-diagram.png)

<https://eips.ethereum.org/EIPS/eip-1822>

## 使用 DelegateCall 要注意的点

- ##### 代理和逻辑合约的存储布局需要一致

- ##### `delegateCall` 返回值

- ##### `(bool success, bytes memory returnData) = address.delegatecall(payload)`

- ##### `Bytes` 需转化为具体的类型

- ##### 不能有函数冲撞

- ##### 初始化问题？ - 实现合约中构造函数无效

### ERC-1167: Minimal Proxy Contract

<https://eips.ethereum.org/EIPS/eip-1167>

<https://github.com/optionality/clone-factory>

## 创建项目

![image-20240728173806902](/images/image-20240728173806902.png)

## 项目目录

```bash
├── script
│   ├── DeployProxy.s.sol
│   ├── ERC20Token.s.sol
│   ├── TokenFactoryV1.s.sol
│   └── TokenFactoryV2.s.sol
├── src
│   ├── ERC20Token.sol
│   ├── TokenFactoryV1.sol
│   └── TokenFactoryV2.sol
├── test
│   ├── ERC20TokenTest.sol
│   ├── TokenFactoryV1Test.sol
│   └── TokenFactoryV2Test.sol
```

## 代码

### `ERC20Token.sol` 文件

```ts
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Script, console} from "forge-std/Script.sol";

contract ERC20Token is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    ERC20PausableUpgradeable,
    OwnableUpgradeable,
    ERC20PermitUpgradeable,
    ERC20VotesUpgradeable
{
    uint public totalSupplyToken;
    uint public perMint;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // _disableInitializers();
    }

    /**
     * initializes the token
     * @param initialOwner the initial owner
     * @param _symbol symbol 表示 Token 的名称
     * @param _totalSupply totalSupply 表示可发行的数量
     * @param _perMint perMint 用来控制每次发行的数量
     *
     */
    function initialize(
        address initialOwner,
        string memory _symbol,
        uint _totalSupply,
        uint _perMint
    ) public initializer {
        __ERC20_init("ERC20Token", _symbol);
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __Ownable_init(initialOwner);
        __ERC20Permit_init("ERC20Token");
        __ERC20Votes_init();
        perMint = _perMint;
        totalSupplyToken = _totalSupply;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to) public {
        uint currentSupply = totalSupply(); // 获取当前代币供应量
        // 确保铸造后总供应量不超过最大供应量
        require(
            currentSupply + perMint <= totalSupplyToken,
            "Exceeds max total supply"
        );
        _mint(to, perMint);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address from,
        address to,
        uint256 value
    )
        internal
        override(
            ERC20Upgradeable,
            ERC20PausableUpgradeable,
            ERC20VotesUpgradeable
        )
    {
        super._update(from, to, value);
    }

    function nonces(
        address owner
    )
        public
        view
        override(ERC20PermitUpgradeable, NoncesUpgradeable)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}

```

### `TokenFactoryV1.sol` 文件

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import "./ERC20Token.sol";

contract TokenFactoryV1 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    ERC20Token myToken;
    address[] public deployedTokens;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    /**
     * 该方法用来创建 ERC20 token，（模拟铭文的 deploy）
     * @param symbol symbol 表示 Token 的名称
     * @param totalSupply totalSupply 表示可发行的数量，
     * @param perMint perMint 用来控制每次发行的数量，用于控制mintInscription函数每次发行的数量
     * @dev Deploys a new ERC20Token contract with the given parameters and adds it to the deployedTokens array.
     *
     * deployInscription(string symbol, uint totalSupply, uint perMint)
     *
     */
    function deployInscription(
        string memory symbol,
        uint totalSupply,
        uint perMint
    ) public {
        myToken = new ERC20Token();
        myToken.initialize(msg.sender, symbol, totalSupply, perMint);
        console.log("deployInscription newToken: ", address(myToken));

        deployedTokens.push(address(myToken));
    }

    /**
     * 该方法用来给用户发行 token
     * @param tokenAddr tokenAddr 表示要发行 token 的地址
     * @dev Mints tokens to the caller address using the ERC20Token contract at the given address.
     *
     * mintInscription(address tokenAddr) 用来发行 ERC20 token，每次调用一次，发行perMint指定的数量。
     */
    function mintInscription(address tokenAddr) public {
        ERC20Token token = ERC20Token(tokenAddr); // Correctly cast the address to the ERC20Token type
        token.mint(msg.sender); // Assuming ERC20Token has a mint function with (address, uint256) parameters
    }

    function size() public view returns (uint) {
        return deployedTokens.length;
    }
}

```

### `TokenFactoryV2.sol` 文件

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
// import "@optionality.io/clone-factory/contracts/CloneFactory.sol";
import "./ERC20Token.sol";

/// @custom:oz-upgrades-from TokenFactoryV1
contract TokenFactoryV2 is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    ERC20Token myToken;
    address[] public deployedTokens;
    mapping(address => uint) public tokenPrices;
    mapping(address => uint) public tokenperMint;
    mapping(address => address) public tokenDeployUser;

    event deployInscriptionEvent(
        address indexed tokenAddress,
        address indexed userAddress,
        uint indexed price
    );

    event mintInscriptionEvent(
        address indexed tokenAddress,
        address indexed userAddress,
        uint indexed amount
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    function setTokenAddress(address _tokenAddress) public onlyOwner {
        myToken = ERC20Token(_tokenAddress);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}

    /**
     * 部署新的 ERC20 代币合约
     * @param symbol symbol 表示 Token 的名称
     * @param totalSupply totalSupply 表示可发行的数量
     * @param perMint perMint 用来控制每次发行的数量，用于控制mintInscription函数每次发行的数量
     * @param price 每个代币的价格 price 表示发行每个 token 需要支付的费用
     */
    function deployInscription(
        string memory symbol,
        uint totalSupply,
        uint perMint,
        uint price
    ) public {
        require(bytes(symbol).length > 0, "Symbol cannot be empty");
        require(totalSupply > 0, "Total supply must be greater than zero");
        require(perMint > 0, "Per mint must be greater than zero");
        require(price > 0, "Price must be greater than zero");

        require(
            address(myToken) != address(0),
            "Implementation address is not set"
        );

        console.log("deployInscription  msg.sender, address:", msg.sender);
        // 使用 Clones 库创建最小代理合约实例
        address newToken = Clones.clone(address(myToken));

        ERC20Token(newToken).initialize(
            msg.sender,
            symbol,
            totalSupply,
            perMint
        );

        deployedTokens.push(newToken);
        tokenPrices[newToken] = price;
        tokenperMint[newToken] = perMint;
        tokenDeployUser[newToken] = msg.sender;
        emit deployInscriptionEvent(newToken, msg.sender, price);
    }

    /**
     * 铸造 ERC20 代币
     * @param tokenAddr 代币地址
     */
    function mintInscription(address tokenAddr) public payable {
        ERC20Token token = ERC20Token(tokenAddr);
        uint price = tokenPrices[tokenAddr];
        uint perMint = tokenperMint[tokenAddr];
        address userAddr = tokenDeployUser[tokenAddr];
        require(msg.value >= (price * perMint), "Incorrect payment");
        token.mint(msg.sender);
        // 使用 call 方法转账，以避免 gas 限制问题 payable(userAddr).transfer(msg.value);
        (bool success, ) = userAddr.call{value: msg.value}("");
        require(success, "Transfer failed.");

        emit mintInscriptionEvent(tokenAddr, userAddr, msg.value);
    }

    /**
     * 提取合约余额
     */
    function withdraw() external onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner()).transfer(balance);
    }

    function size() public view returns (uint) {
        return deployedTokens.length;
    }
}

```

`TokenFactoryV2` 合约是一个功能全面的代币工厂，提供了代币的部署、铸造和管理功能，同时考虑了合约的安全性和升级能力。通过使用 OpenZeppelin 的库和模式，确保了合约的可靠性和可维护性。

## 测试代码

### `ERC20TokenTest.sol` 文件

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {ERC20Token} from "../src/ERC20Token.sol";

contract ERC20TokenTest is Test {
    ERC20Token myToken;
    ERC1967Proxy proxy;
    Account public owner = makeAccount("owner");
    Account public newOwner = makeAccount("newOwner");
    Account public user = makeAccount("user");
    string public symbol = "ETK";
    uint public totalSupply = 1_000_000 ether;
    uint public perMint = 10 ether;

    function setUp() public {
        // 部署实现
        ERC20Token implementation = new ERC20Token();
        // Deploy the proxy and initialize the contract through the proxy
        proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(
                implementation.initialize,
                (owner.addr, symbol, totalSupply, perMint)
            )
        );
        // 用代理关联 MyToken 接口
        myToken = ERC20Token(address(proxy));
        // Emit the owner address for debugging purposes
        emit log_address(owner.addr);
    }

    // Test the basic ERC20 functionality of the MyToken contract
    function testERC20Functionality() public {
        // Impersonate the owner to call mint function
        vm.prank(owner.addr);
        // Mint tokens to address(2) and assert the balance
        myToken.mint(user.addr);
        assertEq(myToken.balanceOf(user.addr), 10 ether);
    }
}

```

### `TokenFactoryV1Test.sol` 文件

```ts
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {ERC20Token} from "../src/ERC20Token.sol";
import {TokenFactoryV1} from "../src/TokenFactoryV1.sol";
import {TokenFactoryV2} from "../src/TokenFactoryV2.sol";

contract TokenFactoryV1Test is Test {
    TokenFactoryV1 public factoryv1;
    TokenFactoryV2 public factoryv2;
    ERC20Token public myToken;
    ERC20Token deployedToken;

    ERC1967Proxy proxy;
    Account public owner = makeAccount("owner");
    Account public newOwner = makeAccount("newOwner");
    Account public user = makeAccount("user");

    string public symbol = "ETK";
    uint public totalSupply = 1_000_000 ether;
    uint public perMint = 10 ether;
    uint public price = 10 ** 16; // 0.01 ETH in wei

    function setUp() public {
        myToken = new ERC20Token();
        myToken.initialize(msg.sender, symbol, totalSupply, perMint);
        // 部署实现
        TokenFactoryV1 implementation = new TokenFactoryV1();
        // Deploy the proxy and initialize the contract through the proxy
        proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(implementation.initialize, owner.addr)
        );
        // 用代理关联 TokenFactoryV1 接口
        factoryv1 = TokenFactoryV1(address(proxy));
        // Emit the owner address for debugging purposes
        emit log_address(owner.addr);
    }

    function testTokenFactoryV1DeployInscriptionFunctionality() public {
        vm.prank(owner.addr);
        factoryv1.deployInscription(symbol, totalSupply, perMint);

        assertEq(factoryv1.size(), 1);
        // Fetch the deployed token address
        address deployedTokenAddress = factoryv1.deployedTokens(0);

        // Create an instance of the deployed token contract
        deployedToken = ERC20Token(deployedTokenAddress);

        // Verify token initialization
        assertEq(deployedToken.symbol(), symbol);
        assertEq(deployedToken.totalSupply(), 0);
        assertEq(deployedToken.totalSupplyToken(), totalSupply);
        assertEq(deployedToken.perMint(), perMint);

        // Optionally verify owner initialization
        assertEq(deployedToken.owner(), owner.addr);
    }

    function testTokenFactoryV1PermissionsDeployInscriptionFunctionality()
        public
    {
        vm.startPrank(user.addr);
        factoryv1.deployInscription(symbol, totalSupply, perMint);

        assertEq(factoryv1.size(), 1);
        // Fetch the deployed token address
        address deployedTokenAddress = factoryv1.deployedTokens(0);

        // Create an instance of the deployed token contract
        deployedToken = ERC20Token(deployedTokenAddress);

        // Verify token initialization
        assertEq(deployedToken.symbol(), symbol);
        assertEq(deployedToken.totalSupply(), 0);
        assertEq(deployedToken.totalSupplyToken(), totalSupply);
        assertEq(deployedToken.perMint(), perMint);

        // Optionally verify owner initialization
        assertEq(deployedToken.owner(), user.addr);
        vm.stopPrank();
    }

    function testTokenFactoryV1MintInscriptionFunctionality() public {
        vm.prank(owner.addr);
        factoryv1.deployInscription(symbol, totalSupply, perMint);

        assertEq(factoryv1.size(), 1);
        // Fetch the deployed token address
        address deployedTokenAddress = factoryv1.deployedTokens(0);
        deployedToken = ERC20Token(deployedTokenAddress);
        vm.startPrank(user.addr);
        factoryv1.mintInscription(deployedTokenAddress);
        assertEq(deployedToken.balanceOf(user.addr), 10 ether);
        assertEq(deployedToken.totalSupply(), 10 ether);
        assertEq(deployedToken.totalSupplyToken(), totalSupply);
        vm.stopPrank();
    }

    function testTokenFactoryV1PermissionsMintInscriptionFunctionality()
        public
    {
        vm.startPrank(user.addr);
        factoryv1.deployInscription(symbol, totalSupply, perMint);

        assertEq(factoryv1.size(), 1);
        // Fetch the deployed token address
        address deployedTokenAddress = factoryv1.deployedTokens(0);
        deployedToken = ERC20Token(deployedTokenAddress);

        factoryv1.mintInscription(deployedTokenAddress);
        assertEq(
            ERC20Token(deployedTokenAddress).balanceOf(user.addr),
            10 ether
        );
        assertEq(deployedToken.balanceOf(user.addr), 10 ether);
        assertEq(deployedToken.totalSupply(), 10 ether);
        assertEq(deployedToken.totalSupplyToken(), totalSupply);
        vm.stopPrank();
    }

    // 测试升级
    function testUpgradeability() public {
        Upgrades.upgradeProxy(
            address(proxy),
            "TokenFactoryV2.sol:TokenFactoryV2",
            "",
            owner.addr
        );
    }

    function testERC20Functionality() public {
        vm.startPrank(user.addr);
        factoryv1.deployInscription(symbol, totalSupply, perMint);
        address deployedTokenAddress = factoryv1.deployedTokens(0);
        deployedToken = ERC20Token(deployedTokenAddress);

        factoryv1.mintInscription(deployedTokenAddress);
        vm.stopPrank();
        assertEq(deployedToken.balanceOf(user.addr), perMint);
    }

    function testVerifyUpgradeability() public {
        testERC20Functionality();
        vm.prank(owner.addr);
        // TokenFactoryV2 factoryV2 = new TokenFactoryV2();
        assertEq(deployedToken.balanceOf(user.addr), perMint); ///
        // 1. 升级代理合约
        Upgrades.upgradeProxy(
            address(proxy),
            "TokenFactoryV2.sol:TokenFactoryV2",
            "",
            owner.addr
        );
        // TokenFactoryV2 factoryV2 = TokenFactoryV2(address(proxy));
        factoryv2 = TokenFactoryV2(address(proxy));
        console.log("Verify upgradeability");
        vm.prank(owner.addr);
        (bool s, ) = address(proxy).call(
            abi.encodeWithSignature(
                "setTokenAddress(address)",
                address(myToken)
            )
        );
        require(s);

        // 验证新的功能
        // 2. deployInscription
        vm.startPrank(user.addr);
        deal(user.addr, price * perMint);
        (bool success, ) = address(proxy).call(
            abi.encodeWithSelector(
                factoryv2.deployInscription.selector,
                symbol,
                totalSupply,
                perMint,
                price
            )
        );
        assertEq(success, true);

        (bool su, bytes memory deployedTokenAddressBytes) = address(proxy).call(
            abi.encodeWithSelector(factoryv2.deployedTokens.selector, 0)
        );
        assertEq(su, true);
        address deployedTokenAddress = abi.decode(
            deployedTokenAddressBytes,
            (address)
        );

        console.log("deployedTokenAddress", deployedTokenAddress);
        (bool sus, bytes memory deployedTokensLengthBytes) = address(proxy)
            .call(abi.encodeWithSelector(factoryv2.size.selector));
        assertEq(sus, true);
        uint256 deployedTokensLength = abi.decode(
            deployedTokensLengthBytes,
            (uint256)
        );
        console.log("deployedTokensLength", deployedTokensLength);
        assertEq(deployedTokensLength, 2);

        (bool su2, bytes memory deployedTokenAddressBytes2) = address(proxy)
            .call(abi.encodeWithSelector(factoryv2.deployedTokens.selector, 1));
        assertEq(su2, true);
        address deployedTokenAddress2 = abi.decode(
            deployedTokenAddressBytes2,
            (address)
        );

        assertNotEq(deployedTokenAddress, deployedTokenAddress2);
        // 3. mintInscription
        deployedToken = ERC20Token(deployedTokenAddress2);
        (bool mintSuccess, ) = address(proxy).call{value: price * perMint}(
            abi.encodeWithSignature(
                "mintInscription(address)",
                deployedTokenAddress2
            )
        );
        require(mintSuccess, "Minting of token failed");

        assertEq(factoryv2.tokenPrices(deployedTokenAddress), 0);
        assertEq(factoryv2.tokenPrices(deployedTokenAddress2), price);
        assertEq(factoryv2.tokenperMint(deployedTokenAddress2), perMint);

        assertEq(deployedToken.balanceOf(user.addr), 10 ether);
        assertEq(deployedToken.totalSupply(), perMint);
        assertEq(deployedToken.totalSupplyToken(), totalSupply);
        vm.stopPrank();
    }
}

```

### `TokenFactoryV2Test.sol` 文件

```ts
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {TokenFactoryV2} from "../src/TokenFactoryV2.sol";
import {ERC20Token} from "../src/ERC20Token.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract CounterTest is Test {
    TokenFactoryV2 public factoryv2;

    ERC20Token public myToken;
    ERC1967Proxy proxy;
    ERC1967Proxy proxy2;
    Account public owner = makeAccount("owner");
    Account public user = makeAccount("user");

    string public symbol = "ETK";
    uint public totalSupply = 1_000_000 ether;
    uint public perMint = 10 ether;
    uint public price = 10 ** 16; // 0.01 ETH in wei
    address public tokenAddr;

    function setUp() public {
        myToken = new ERC20Token();
        myToken.initialize(msg.sender, symbol, totalSupply, perMint);

        TokenFactoryV2 implementationV2 = new TokenFactoryV2();
        vm.prank(owner.addr);
        proxy = new ERC1967Proxy(
            address(implementationV2),
            abi.encodeCall(implementationV2.initialize, (owner.addr))
        );

        // 用代理关联 TokenFactoryV2 接口
        factoryv2 = TokenFactoryV2(address(proxy));

        vm.prank(owner.addr);
        (bool success, ) = address(proxy).call(
            abi.encodeWithSelector(
                factoryv2.setTokenAddress.selector,
                address(myToken)
            )
        );

        require(success);

        // Emit the owner address for debugging purposes
        emit log_address(owner.addr);
    }

    function testTokenFactoryV2DeployInscriptionFunctionality() public {
        vm.startPrank(owner.addr);
        factoryv2.deployInscription(symbol, totalSupply, perMint, price);

        assertEq(factoryv2.size(), 1);

        // Fetch the deployed token address
        address deployedTokenAddress = factoryv2.deployedTokens(0);
        assertEq(factoryv2.tokenPrices(deployedTokenAddress), price);
        // Create an instance of the deployed token contract
        ERC20Token deployedToken = ERC20Token(deployedTokenAddress);
        assertEq(address(deployedToken), deployedTokenAddress);
        // Verify token initialization
        assertEq(deployedToken.symbol(), symbol);
        assertEq(deployedToken.balanceOf(owner.addr), 0);
        assertEq(deployedToken.totalSupplyToken(), totalSupply);
        assertEq(deployedToken.perMint(), perMint);

        // Optionally verify owner initialization
        assertEq(deployedToken.owner(), owner.addr);
        vm.stopPrank();
    }

    function testTokenFactoryV2PermissionsDeployInscriptionFunctionality()
        public
    {
        vm.startPrank(user.addr);
        factoryv2.deployInscription(symbol, totalSupply, perMint, price);

        assertEq(factoryv2.size(), 1);

        // Fetch the deployed token address
        address deployedTokenAddress = factoryv2.deployedTokens(0);
        assertEq(factoryv2.tokenPrices(deployedTokenAddress), price);
        // Create an instance of the deployed token contract
        ERC20Token deployedToken = ERC20Token(deployedTokenAddress);
        assertEq(address(deployedToken), deployedTokenAddress);
        // Verify token initialization
        assertEq(deployedToken.symbol(), symbol);
        assertEq(deployedToken.balanceOf(owner.addr), 0);
        assertEq(deployedToken.totalSupplyToken(), totalSupply);
        assertEq(deployedToken.perMint(), perMint);

        // Optionally verify owner initialization
        assertEq(deployedToken.owner(), user.addr);
        vm.stopPrank();
    }

    function testTokenFactoryV2MintInscriptionFunctionality() public {
        vm.prank(owner.addr);
        factoryv2.deployInscription(symbol, totalSupply, perMint, price);

        assertEq(factoryv2.size(), 1);
        // Fetch the deployed token address
        address deployedTokenAddress = factoryv2.deployedTokens(0);
        ERC20Token deployedToken = ERC20Token(deployedTokenAddress);
        vm.startPrank(user.addr);
        vm.deal(user.addr, price * perMint);
        factoryv2.mintInscription{value: price * perMint}(deployedTokenAddress);
        assertEq(deployedToken.balanceOf(user.addr), 10 ether);
        assertEq(deployedToken.totalSupply(), 10 ether);
        // Verify the total supply token
        assertEq(deployedToken.totalSupplyToken(), totalSupply);
        vm.stopPrank();
    }

    function testTokenFactoryV2PermissionsMintInscriptionFunctionality()
        public
    {
        vm.startPrank(user.addr);
        factoryv2.deployInscription(symbol, totalSupply, perMint, price);

        assertEq(factoryv2.size(), 1);
        // Fetch the deployed token address
        address deployedTokenAddress = factoryv2.deployedTokens(0);
        ERC20Token deployedToken = ERC20Token(deployedTokenAddress);

        vm.deal(user.addr, price * perMint);
        factoryv2.mintInscription{value: price * perMint}(deployedTokenAddress);
        assertEq(deployedToken.balanceOf(user.addr), 10 ether);
        assertEq(deployedToken.totalSupply(), 10 ether);
        assertEq(factoryv2.tokenperMint(deployedTokenAddress), perMint);
        // Verify the total supply token
        assertEq(deployedToken.totalSupplyToken(), totalSupply);
        vm.stopPrank();
    }
}

```

## 部署

第一步：部署 `ERC20Token`  合约

第二步： 部署 `TokenFactoryV1`  合约 和 部署 `DeployUUPSProxy`  代理合约

第三步：部署 并升级TokenFactoryV2`  合约

### 部署脚本

#### `ERC20Token.s.sol` 文件

```ts
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ERC20Token} from "../src/ERC20Token.sol";

contract ERC20TokenScript is Script {
    ERC20Token public token;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        token = new ERC20Token();
        console.log("Token address: ", address(token));

        vm.stopBroadcast();
    }
}

```

#### `DeployUUPSProxy.s.sol` 文件

#### 注意：同时部署 代理合约和 TokenFactoryV1

```ts
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../src/ERC20Token.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/Script.sol";
import {TokenFactoryV1} from "../src/TokenFactoryV1.sol";

contract DeployUUPSProxy is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with the account:", deployerAddress);
        vm.startBroadcast(deployerPrivateKey);
        // address _implementation = 0xa8672dfDb0d5A672CC599C3E8D77F8E807cEc6d6; // Replace with your token address
        TokenFactoryV1 _implementation = new TokenFactoryV1(); // Replace with your token address
        console.log("TokenFactoryV1 deployed to:", address(_implementation));

        // Encode the initializer function call
        bytes memory data = abi.encodeCall(
            _implementation.initialize,
            deployerAddress
        );

        // Deploy the proxy contract with the implementation address and initializer
        ERC1967Proxy proxy = new ERC1967Proxy(address(_implementation), data);

        vm.stopBroadcast();
        // Log the proxy address
        console.log("UUPS Proxy Address:", address(proxy));
    }
}

```

#### `TokenFactoryV2.s.sol` 文件

```ts
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

import {TokenFactoryV2} from "../src/TokenFactoryV2.sol";

contract TokenFactoryV2Script is Script {
    address public proxy = 0x90635Ff2Ff7E64872848612ad6B943b04B089Db0;
    address public erc20Token = 0x65869BaA9336F8968704F2dd60C40959a7bD202b;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with the account:", deployerAddress);
        vm.startBroadcast(deployerPrivateKey);

        Upgrades.upgradeProxy(
            address(proxy),
            "TokenFactoryV2.sol:TokenFactoryV2",
            "",
            deployerAddress
        );
        (bool successful, ) = address(proxy).call(
            abi.encodeWithSelector(
                TokenFactoryV2.setTokenAddress.selector,
                address(erc20Token)
            )
        );
        console.log("setTokenAddress success:", successful);

        // console.log("TokenFactoryV1 deployed to:", address(factoryv2));

        vm.stopBroadcast();
    }
}

```

### `ERC20Token` 部署

```bash
UpgradeableTokenFactory on  main [!?] via ⬢ v22.1.0 via 🅒 base took 8.1s 
➜ source .env

UpgradeableTokenFactory on  main [!] via ⬢ v22.1.0 via 🅒 base 
➜ forge script --chain sepolia ERC20TokenScript --rpc-url $SEPOLIA_RPC_URL --account MetaMask --broadcast --verify -vvvv

[⠢] Compiling...
[⠑] Compiling 1 files with Solc 0.8.20
[⠘] Solc 0.8.20 finished in 1.49s
Compiler run successful!
Enter keystore password:
Traces:
  [2196112] ERC20TokenScript::run()
    ├─ [0] VM::startBroadcast()
    │   └─ ← [Return] 
    ├─ [2149887] → new ERC20Token@0x65869BaA9336F8968704F2dd60C40959a7bD202b
    │   └─ ← [Return] 10738 bytes of code
    ├─ [0] console::log("Token address: ", ERC20Token: [0x65869BaA9336F8968704F2dd60C40959a7bD202b]) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    └─ ← [Stop] 


Script ran successfully.

== Logs ==
  Token address:  0x65869BaA9336F8968704F2dd60C40959a7bD202b

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [2149887] → new ERC20Token@0x65869BaA9336F8968704F2dd60C40959a7bD202b
    └─ ← [Return] 10738 bytes of code


==========================

Chain 11155111

Estimated gas price: 86.582754516 gwei

Estimated total gas used for script: 3083806

Estimated amount required: 0.267004417872967896 ETH

==========================

##### sepolia
✅  [Success]Hash: 0xa9616c34ca9e776eddd5c9f0ebab2b6d634e25f28f8835c9e37aa5600b5cbb98
Contract Address: 0x65869BaA9336F8968704F2dd60C40959a7bD202b
Block: 6396610
Paid: 0.098080535921111506 ETH (2372833 gas * 41.334782482 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.098080535921111506 ETH (2372833 gas * avg 41.334782482 gwei)
                                                                                            

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (1) contracts
Start verifying contract `0x65869BaA9336F8968704F2dd60C40959a7bD202b` deployed on sepolia

Submitting verification for [src/ERC20Token.sol:ERC20Token] 0x65869BaA9336F8968704F2dd60C40959a7bD202b.

Submitting verification for [src/ERC20Token.sol:ERC20Token] 0x65869BaA9336F8968704F2dd60C40959a7bD202b.
Submitted contract for verification:
        Response: `OK`
        GUID: `62qbazivmkngcqyckp4smut8hh4wlpt3tw1hkjbhrncngggtiy`
        URL: https://sepolia.etherscan.io/address/0x65869baa9336f8968704f2dd60c40959a7bd202b
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (1) contracts were verified!

Transactions saved to: /Users/qiaopengjun/Code/solidity-code/UpgradeableTokenFactory/broadcast/ERC20Token.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/solidity-code/UpgradeableTokenFactory/cache/ERC20Token.s.sol/11155111/run-latest.json


UpgradeableTokenFactory on  main [!?] via ⬢ v22.1.0 via 🅒 base took 1m 9.2s 
➜ 
```

<https://sepolia.etherscan.io/address/0x65869baa9336f8968704f2dd60c40959a7bd202b#code>

![image-20240729170624739](/images/image-20240729170624739.png)

### `TokenFactoryV1` 部署

```bash
UpgradeableTokenFactory on  main [!?] via ⬢ v22.1.0 via 🅒 base took 13.2s 
➜ forge script --chain sepolia DeployUUPSProxy --rpc-url $SEPOLIA_RPC_URL --account MetaMask --broadcast --verify -vvvv

[⠒] Compiling...
[⠘] Compiling 1 files with Solc 0.8.20
[⠊] Solc 0.8.20 finished in 1.66s
Compiler run successful!
Traces:
  [3075117] DeployUUPSProxy::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
    ├─ [0] console::log("Deploying contracts with the account:", 0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return] 
    ├─ [2890311] → new TokenFactoryV1@0x67fC7A2D6E5C1eD37Af85397DB083568bf7e0234
    │   ├─ emit Initialized(version: 18446744073709551615 [1.844e19])
    │   └─ ← [Return] 14318 bytes of code
    ├─ [0] console::log("TokenFactoryV1 deployed to:", TokenFactoryV1: [0x67fC7A2D6E5C1eD37Af85397DB083568bf7e0234]) [staticcall]
    │   └─ ← [Stop] 
    ├─ [107802] → new ERC1967Proxy@0x90635Ff2Ff7E64872848612ad6B943b04B089Db0
    │   ├─ emit Upgraded(implementation: TokenFactoryV1: [0x67fC7A2D6E5C1eD37Af85397DB083568bf7e0234])
    │   ├─ [48636] TokenFactoryV1::initialize(0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5) [delegatecall]
    │   │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5)
    │   │   ├─ emit Initialized(version: 1)
    │   │   └─ ← [Stop] 
    │   └─ ← [Return] 170 bytes of code
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    ├─ [0] console::log("UUPS Proxy Address:", ERC1967Proxy: [0x90635Ff2Ff7E64872848612ad6B943b04B089Db0]) [staticcall]
    │   └─ ← [Stop] 
    └─ ← [Stop] 


Script ran successfully.

== Logs ==
  Deploying contracts with the account: 0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
  TokenFactoryV1 deployed to: 0x67fC7A2D6E5C1eD37Af85397DB083568bf7e0234
  UUPS Proxy Address: 0x90635Ff2Ff7E64872848612ad6B943b04B089Db0

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [2890311] → new TokenFactoryV1@0x67fC7A2D6E5C1eD37Af85397DB083568bf7e0234
    ├─ emit Initialized(version: 18446744073709551615 [1.844e19])
    └─ ← [Return] 14318 bytes of code

  [110302] → new ERC1967Proxy@0x90635Ff2Ff7E64872848612ad6B943b04B089Db0
    ├─ emit Upgraded(implementation: TokenFactoryV1: [0x67fC7A2D6E5C1eD37Af85397DB083568bf7e0234])
    ├─ [48636] TokenFactoryV1::initialize(0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5) [delegatecall]
    │   ├─ emit OwnershipTransferred(previousOwner: 0x0000000000000000000000000000000000000000, newOwner: 0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5)
    │   ├─ emit Initialized(version: 1)
    │   └─ ← [Stop] 
    └─ ← [Return] 170 bytes of code


==========================

Chain 11155111

Estimated gas price: 72.74057709 gwei

Estimated total gas used for script: 4356665

Estimated amount required: 0.31690632628780485 ETH

==========================
Enter keystore password:

##### sepolia
✅  [Success]Hash: 0x0eeb69d7cc59e24da2f681eb30de9d37ea72e2c5dac7e423312391384c546d6e
Contract Address: 0x90635Ff2Ff7E64872848612ad6B943b04B089Db0
Block: 6396821
Paid: 0.006243301675965136 ETH (180646 gas * 34.560973816 gwei)


##### sepolia
✅  [Success]Hash: 0x2681b0452bc1f217c7456df4ce763daa96aaeb3e5acba6cf26cd9a91600f3e02
Contract Address: 0x67fC7A2D6E5C1eD37Af85397DB083568bf7e0234
Block: 6396821
Paid: 0.109614379457223368 ETH (3171623 gas * 34.560973816 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.115857681133188504 ETH (3352269 gas * avg 34.560973816 gwei)
                                                                                                                                        

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (2) contracts
Start verifying contract `0x67fC7A2D6E5C1eD37Af85397DB083568bf7e0234` deployed on sepolia

Submitting verification for [src/TokenFactoryV1.sol:TokenFactoryV1] 0x67fC7A2D6E5C1eD37Af85397DB083568bf7e0234.

Submitting verification for [src/TokenFactoryV1.sol:TokenFactoryV1] 0x67fC7A2D6E5C1eD37Af85397DB083568bf7e0234.

Submitting verification for [src/TokenFactoryV1.sol:TokenFactoryV1] 0x67fC7A2D6E5C1eD37Af85397DB083568bf7e0234.
Submitted contract for verification:
        Response: `OK`
        GUID: `fdivnqljbb7xmbxq62cf6wwqtkp9en5bqbratcuwaz3pgkswxr`
        URL: https://sepolia.etherscan.io/address/0x67fc7a2d6e5c1ed37af85397db083568bf7e0234
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
Start verifying contract `0x90635Ff2Ff7E64872848612ad6B943b04B089Db0` deployed on sepolia

Submitting verification for [lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy] 0x90635Ff2Ff7E64872848612ad6B943b04B089Db0.
Submitted contract for verification:
        Response: `OK`
        GUID: `awwcjbgju4sc5m6wzkannu8h66sy8hjscndbenhet99q3xvfhj`
        URL: https://sepolia.etherscan.io/address/0x90635ff2ff7e64872848612ad6b943b04b089db0
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (2) contracts were verified!

Transactions saved to: /Users/qiaopengjun/Code/solidity-code/UpgradeableTokenFactory/broadcast/DeployProxy.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/solidity-code/UpgradeableTokenFactory/cache/DeployProxy.s.sol/11155111/run-latest.json


UpgradeableTokenFactory on  main [!?] via ⬢ v22.1.0 via 🅒 base took 1m 50.9s 
➜ 
```

<https://sepolia.etherscan.io/address/0x67fc7a2d6e5c1ed37af85397db083568bf7e0234#code>

![image-20240729180105650](/images/image-20240729180105650.png)

### `DeployUUPSProxy` 部署

<https://sepolia.etherscan.io/address/0x90635ff2ff7e64872848612ad6b943b04b089db0#code>

![image-20240729175857531](/images/image-20240729175857531.png)

### 验证合约是否是代理

This contract may be a proxy contract. Click on **More Options** and select **Is this a proxy?** to confirm and enable the "Read as Proxy" & "Write as Proxy" tabs.

![image-20240729180440174](/images/image-20240729180440174.png)

### 点击 `Is this a proxy`

![image-20240729180545813](/images/image-20240729180545813.png)

### 点击Verify 进行验证

![image-20240729180727507](/images/image-20240729180727507.png)

### 点击 Save

![image-20240729180836830](/images/image-20240729180836830.png)

### 成功验证

![image-20240729180909439](/images/image-20240729180909439.png)

### 查看

![image-20240729181016024](/images/image-20240729181016024.png)

### `TokenFactoryV2` 部署并升级

<https://sepolia.etherscan.io/address/0xdddc3837f0d3cb104b768208327f3017ba22bb6f#code>

```bash
UpgradeableTokenFactory on  main [⇡] via ⬢ v22.1.0 via 🅒 base 
➜ forge script --chain sepolia TokenFactoryV2Script --rpc-url $SEPOLIA_RPC_URL --account MetaMask --broadcast --verify -vvvv  

[⠢] Compiling...
No files changed, compilation skipped
Traces:
  [4016026] TokenFactoryV2Script::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
    ├─ [0] console::log("Deploying contracts with the account:", 0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return] 
    ├─ [0] VM::startPrank(0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5)
    │   └─ ← [Revert] cannot `prank` for a broadcasted transaction; pass the desired `tx.origin` into the `broadcast` cheatcode call
    ├─ [0] VM::envOr("FOUNDRY_OUT", "out") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::projectRoot() [staticcall]
    │   └─ ← [Return] "/Users/qiaopengjun/Code/solidity-code/UpgradeableTokenFactory"
    ├─ [0] VM::readFile("/Users/qiaopengjun/Code/solidity-code/UpgradeableTokenFactory/out/TokenFactoryV2.sol/TokenFactoryV2.json") [staticcall]
    │   └─ ← [Return] <file>
    ├─ [0] VM::keyExistsJson("<JSON file>", ".ast") [staticcall]
    │   └─ ← [Return] true
    ├─ [0] VM::parseJsonString("<stringified JSON>", ".ast.absolutePath") [staticcall]
    │   └─ ← [Return] "src/TokenFactoryV2.sol"
    ├─ [0] VM::keyExistsJson("<JSON file>", ".ast.license") [staticcall]
    │   └─ ← [Return] true
    ├─ [0] VM::parseJsonString("<stringified JSON>", ".ast.license") [staticcall]
    │   └─ ← [Return] "MIT"
    ├─ [0] VM::parseJsonString("<stringified JSON>", ".metadata.sources.['src/TokenFactoryV2.sol'].keccak256") [staticcall]
    │   └─ ← [Return] "0xfecdbfc40eca8736c55d88b10040818f948a65cfa1103a0470295e2c2df7b8a4"
    ├─ [0] VM::envOr("OPENZEPPELIN_BASH_PATH", "bash") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::tryFfi(["bash", "-c", "npx @openzeppelin/upgrades-core@^1.32.3 validate out/build-info --contract src/TokenFactoryV2.sol:TokenFactoryV2 --requireReference"])
    │   └─ ← [Return] (0, 0xe29c9420207372632f546f6b656e466163746f727956322e736f6c3a546f6b656e466163746f72795632202875706772616465732066726f6d207372632f546f6b656e466163746f727956312e736f6c3a546f6b656e466163746f72795631290a0a53554343455353, 0x)
    ├─ [0] VM::getCode("TokenFactoryV2.sol:TokenFactoryV2") [staticcall]
    │   └─ ← [Return] 0x60a06040523060805234801561001457600080fd5b5061001d610022565b6100d4565b7ff0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00805468010000000000000000900460ff16156100725760405163f92ee8a960e01b815260040160405180910390fd5b80546001600160401b03908116146100d15780546001600160401b0319166001600160401b0390811782556040519081527fc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d29060200160405180910390a15b50565b60805161134a6100fd60003960008181610b8201528181610bab0152610cf1015261134a6000f3fe6080604052600436106100f35760003560e01c8063949d225d1161008a578063c4d66de811610059578063c4d66de81461028c578063d57fa2b6146102ac578063ec81aadb146102e2578063f2fde38b1461030257600080fd5b8063949d225d146101f9578063ad3cb1cc1461020e578063af7c6e551461024c578063b341458a1461027957600080fd5b80634f1ef286116100c65780634f1ef2861461018f57806352d1902d146101a2578063715018a6146101b75780638da5cb5b146101cc57600080fd5b8063204120bc146100f857806326a4e8d2146101385780633ccfd60b1461015a5780633ef8af431461016f575b600080fd5b34801561010457600080fd5b50610125610113366004611025565b60026020526000908152604090205481565b6040519081526020015b60405180910390f35b34801561014457600080fd5b50610158610153366004611025565b610322565b005b34801561016657600080fd5b5061015861034c565b34801561017b57600080fd5b5061015861018a3660046110cc565b6103e2565b61015861019d366004611134565b6106df565b3480156101ae57600080fd5b506101256106fa565b3480156101c357600080fd5b50610158610717565b3480156101d857600080fd5b506101e161072b565b6040516001600160a01b03909116815260200161012f565b34801561020557600080fd5b50600154610125565b34801561021a57600080fd5b5061023f604051806040016040528060058152602001640352e302e360dc1b81525081565b60405161012f91906111e6565b34801561025857600080fd5b50610125610267366004611025565b60036020526000908152604090205481565b610158610287366004611025565b610759565b34801561029857600080fd5b506101586102a7366004611025565b61090e565b3480156102b857600080fd5b506101e16102c7366004611025565b6004602052600090815260409020546001600160a01b031681565b3480156102ee57600080fd5b506101e16102fd3660046111f9565b610a26565b34801561030e57600080fd5b5061015861031d366004611025565b610a50565b61032a610a8e565b600080546001600160a01b0319166001600160a01b0392909216919091179055565b610354610a8e565b478061039e5760405162461bcd60e51b81526020600482015260146024820152734e6f2066756e647320746f20776974686472617760601b60448201526064015b60405180910390fd5b6103a661072b565b6001600160a01b03166108fc829081150290604051600060405180830381858888f193505050501580156103de573d6000803e3d6000fd5b5050565b600084511161042c5760405162461bcd60e51b815260206004820152601660248201527553796d626f6c2063616e6e6f7420626520656d70747960501b6044820152606401610395565b6000831161048b5760405162461bcd60e51b815260206004820152602660248201527f546f74616c20737570706c79206d7573742062652067726561746572207468616044820152656e207a65726f60d01b6064820152608401610395565b600082116104e65760405162461bcd60e51b815260206004820152602260248201527f506572206d696e74206d7573742062652067726561746572207468616e207a65604482015261726f60f01b6064820152608401610395565b600081116105365760405162461bcd60e51b815260206004820152601f60248201527f5072696365206d7573742062652067726561746572207468616e207a65726f006044820152606401610395565b6000546001600160a01b03166105985760405162461bcd60e51b815260206004820152602160248201527f496d706c656d656e746174696f6e2061646472657373206973206e6f742073656044820152601d60fa1b6064820152608401610395565b6105ba6040518060600160405280602781526020016112ce6027913933610ac0565b600080546105d0906001600160a01b0316610b05565b604051637433462960e11b81529091506001600160a01b0382169063e8668c5290610605903390899089908990600401611212565b600060405180830381600087803b15801561061f57600080fd5b505af1158015610633573d6000803e3d6000fd5b5050600180548082019091557fb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf60180546001600160a01b03199081166001600160a01b0386169081179092556000828152600260209081526040808320899055600382528083208a90556004909152808220805433941684179055518795509193507feff7155918865c0cf825001d51831de8285d88e661dea1d706f9c64211816b5191a45050505050565b6106e7610b77565b6106f082610c1c565b6103de8282610c24565b6000610704610ce6565b506000805160206112f583398151915290565b61071f610a8e565b6107296000610d2f565b565b7f9016d09d72d40fdae2fd8ceac6b6234c7706214fd39c1cd1e609a0528c199300546001600160a01b031690565b6001600160a01b03808216600090815260026020908152604080832054600383528184205460049093529220548493166107938284611249565b3410156107d65760405162461bcd60e51b8152602060048201526011602482015270125b98dbdc9c9958dd081c185e5b595b9d607a1b6044820152606401610395565b6040516335313c2160e11b81523360048201526001600160a01b03851690636a62784290602401600060405180830381600087803b15801561081757600080fd5b505af115801561082b573d6000803e3d6000fd5b505050506000816001600160a01b03163460405160006040518083038185875af1925050503d806000811461087c576040519150601f19603f3d011682016040523d82523d6000602084013e610881565b606091505b50509050806108c55760405162461bcd60e51b815260206004820152601060248201526f2a3930b739b332b9103330b4b632b21760811b6044820152606401610395565b34826001600160a01b0316876001600160a01b03167f30ec8252c6daf0651c3708437cd3947ffa8789a74488d4a9d22fa53b48d545e460405160405180910390a4505050505050565b7ff0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a008054600160401b810460ff16159067ffffffffffffffff166000811580156109545750825b905060008267ffffffffffffffff1660011480156109715750303b155b90508115801561097f575080155b1561099d5760405163f92ee8a960e01b815260040160405180910390fd5b845467ffffffffffffffff1916600117855583156109c757845460ff60401b1916600160401b1785555b6109d086610da0565b6109d8610db1565b8315610a1e57845460ff60401b19168555604051600181527fc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d29060200160405180910390a15b505050505050565b60018181548110610a3657600080fd5b6000918252602090912001546001600160a01b0316905081565b610a58610a8e565b6001600160a01b038116610a8257604051631e4fbdf760e01b815260006004820152602401610395565b610a8b81610d2f565b50565b33610a9761072b565b6001600160a01b0316146107295760405163118cdaa760e01b8152336004820152602401610395565b6103de8282604051602401610ad692919061126e565b60408051601f198184030181529190526020810180516001600160e01b031663319af33360e01b179052610db9565b6000763d602d80600a3d3981f3363d3d373d3d3d363d730000008260601b60e81c176000526e5af43d82803e903d91602b57fd5bf38260781b17602052603760096000f090506001600160a01b038116610b72576040516330be1a3d60e21b815260040160405180910390fd5b919050565b306001600160a01b037f0000000000000000000000000000000000000000000000000000000000000000161480610bfe57507f00000000000000000000000000000000000000000000000000000000000000006001600160a01b0316610bf26000805160206112f5833981519152546001600160a01b031690565b6001600160a01b031614155b156107295760405163703e46dd60e11b815260040160405180910390fd5b610a8b610a8e565b816001600160a01b03166352d1902d6040518163ffffffff1660e01b8152600401602060405180830381865afa925050508015610c7e575060408051601f3d908101601f19168201909252610c7b91810190611298565b60015b610ca657604051634c9c8ce360e01b81526001600160a01b0383166004820152602401610395565b6000805160206112f58339815191528114610cd757604051632a87526960e21b815260048101829052602401610395565b610ce18383610dc2565b505050565b306001600160a01b037f000000000000000000000000000000000000000000000000000000000000000016146107295760405163703e46dd60e11b815260040160405180910390fd5b7f9016d09d72d40fdae2fd8ceac6b6234c7706214fd39c1cd1e609a0528c19930080546001600160a01b031981166001600160a01b03848116918217845560405192169182907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a3505050565b610da8610e18565b610a8b81610e61565b610729610e18565b610a8b81610e69565b610dcb82610e8a565b6040516001600160a01b038316907fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b90600090a2805115610e1057610ce18282610eef565b6103de610f67565b7ff0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a0054600160401b900460ff1661072957604051631afcd79f60e31b815260040160405180910390fd5b610a58610e18565b80516a636f6e736f6c652e6c6f67602083016000808483855afa5050505050565b806001600160a01b03163b600003610ec057604051634c9c8ce360e01b81526001600160a01b0382166004820152602401610395565b6000805160206112f583398151915280546001600160a01b0319166001600160a01b0392909216919091179055565b6060600080846001600160a01b031684604051610f0c91906112b1565b600060405180830381855af49150503d8060008114610f47576040519150601f19603f3d011682016040523d82523d6000602084013e610f4c565b606091505b5091509150610f5c858383610f86565b925050505b92915050565b34156107295760405163b398979f60e01b815260040160405180910390fd5b606082610f9b57610f9682610fe5565b610fde565b8151158015610fb257506001600160a01b0384163b155b15610fdb57604051639996b31560e01b81526001600160a01b0385166004820152602401610395565b50805b9392505050565b805115610ff55780518082602001fd5b604051630a12f52160e11b815260040160405180910390fd5b80356001600160a01b0381168114610b7257600080fd5b60006020828403121561103757600080fd5b610fde8261100e565b634e487b7160e01b600052604160045260246000fd5b600067ffffffffffffffff8084111561107157611071611040565b604051601f8501601f19908116603f0116810190828211818310171561109957611099611040565b816040528093508581528686860111156110b257600080fd5b858560208301376000602087830101525050509392505050565b600080600080608085870312156110e257600080fd5b843567ffffffffffffffff8111156110f957600080fd5b8501601f8101871361110a57600080fd5b61111987823560208401611056565b97602087013597506040870135966060013595509350505050565b6000806040838503121561114757600080fd5b6111508361100e565b9150602083013567ffffffffffffffff81111561116c57600080fd5b8301601f8101851361117d57600080fd5b61118c85823560208401611056565b9150509250929050565b60005b838110156111b1578181015183820152602001611199565b50506000910152565b600081518084526111d2816020860160208601611196565b601f01601f19169290920160200192915050565b602081526000610fde60208301846111ba565b60006020828403121561120b57600080fd5b5035919050565b6001600160a01b0385168152608060208201819052600090611236908301866111ba565b6040830194909452506060015292915050565b8082028115828204841417610f6157634e487b7160e01b600052601160045260246000fd5b60408152600061128160408301856111ba565b905060018060a01b03831660208301529392505050565b6000602082840312156112aa57600080fd5b5051919050565b600082516112c3818460208701611196565b919091019291505056fe6465706c6f79496e736372697074696f6e20206d73672e73656e6465722c20616464726573733a360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbca264697066735822122024e97f259c62d9ba16fca8ceb047805e03f12f943e458b863f8e06c60cb0513b64736f6c63430008140033
    ├─ [1012207] → new TokenFactoryV2@0x89A14B4b7c9Ec826C1a3C38deF97b90565503992
    │   ├─ emit Initialized(version: 18446744073709551615 [1.844e19])
    │   └─ ← [Return] 4938 bytes of code
    ├─ [0] VM::load(MetaMultiSigWallet: [0x90635Ff2Ff7E64872848612ad6B943b04B089Db0], 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103) [staticcall]
    │   └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000000000000000
    ├─ [5441] MetaMultiSigWallet::UPGRADE_INTERFACE_VERSION()
    │   ├─ [545] MetaMultiSigWallet::UPGRADE_INTERFACE_VERSION() [delegatecall]
    │   │   └─ ← [Return] "5.0.0"
    │   └─ ← [Return] "5.0.0"
    ├─ [8915] MetaMultiSigWallet::upgradeToAndCall(TokenFactoryV2: [0x89A14B4b7c9Ec826C1a3C38deF97b90565503992], 0x)
    │   ├─ [8516] MetaMultiSigWallet::upgradeToAndCall(TokenFactoryV2: [0x89A14B4b7c9Ec826C1a3C38deF97b90565503992], 0x) [delegatecall]
    │   │   ├─ [343] TokenFactoryV2::proxiableUUID() [staticcall]
    │   │   │   └─ ← [Return] 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
    │   │   ├─ emit Upgraded(implementation: TokenFactoryV2: [0x89A14B4b7c9Ec826C1a3C38deF97b90565503992])
    │   │   └─ ← [Stop] 
    │   └─ ← [Return] 
    ├─ [23116] MetaMultiSigWallet::setTokenAddress(0x65869BaA9336F8968704F2dd60C40959a7bD202b)
    │   ├─ [22726] TokenFactoryV2::setTokenAddress(0x65869BaA9336F8968704F2dd60C40959a7bD202b) [delegatecall]
    │   │   └─ ← [Stop] 
    │   └─ ← [Return] 
    ├─ [0] console::log("setTokenAddress success:", true) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    └─ ← [Stop] 


Script ran successfully.

== Logs ==
  Deploying contracts with the account: 0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
  setTokenAddress success: true

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [1012207] → new TokenFactoryV2@0x89A14B4b7c9Ec826C1a3C38deF97b90565503992
    ├─ emit Initialized(version: 18446744073709551615 [1.844e19])
    └─ ← [Return] 4938 bytes of code

  [5441] MetaMultiSigWallet::UPGRADE_INTERFACE_VERSION()
    ├─ [545] MetaMultiSigWallet::UPGRADE_INTERFACE_VERSION() [delegatecall]
    │   └─ ← [Return] "5.0.0"
    └─ ← [Return] "5.0.0"

  [15915] MetaMultiSigWallet::upgradeToAndCall(TokenFactoryV2: [0x89A14B4b7c9Ec826C1a3C38deF97b90565503992], 0x)
    ├─ [11016] MetaMultiSigWallet::upgradeToAndCall(TokenFactoryV2: [0x89A14B4b7c9Ec826C1a3C38deF97b90565503992], 0x) [delegatecall]
    │   ├─ [343] TokenFactoryV2::proxiableUUID() [staticcall]
    │   │   └─ ← [Return] 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
    │   ├─ emit Upgraded(implementation: TokenFactoryV2: [0x89A14B4b7c9Ec826C1a3C38deF97b90565503992])
    │   └─ ← [Stop] 
    └─ ← [Return] 

  [29616] MetaMultiSigWallet::setTokenAddress(0x65869BaA9336F8968704F2dd60C40959a7bD202b)
    ├─ [24726] TokenFactoryV2::setTokenAddress(0x65869BaA9336F8968704F2dd60C40959a7bD202b) [delegatecall]
    │   └─ ← [Stop] 
    └─ ← [Return] 


==========================

Chain 11155111

Estimated gas price: 18.026614008 gwei

Estimated total gas used for script: 1650333

Estimated amount required: 0.029749915975664664 ETH

==========================
Enter keystore password:

Transactions saved to: /Users/qiaopengjun/Code/solidity-code/UpgradeableTokenFactory/broadcast/TokenFactoryV2.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/solidity-code/UpgradeableTokenFactory/cache/TokenFactoryV2.s.sol/11155111/run-latest.json

Error: 
Failed to send transaction

Context:
- server returned an error response: error code -32000: future transaction tries to replace pending



UpgradeableTokenFactory on  main [⇡?] via ⬢ v22.1.0 via 🅒 base 
➜ forge script --chain sepolia TokenFactoryV2Script --rpc-url $SEPOLIA_RPC_URL --account MetaMask --broadcast --verify -vvvv  

[⠢] Compiling...
No files changed, compilation skipped
Traces:
  [4016105] TokenFactoryV2Script::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::addr(<pk>) [staticcall]
    │   └─ ← [Return] 0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
    ├─ [0] console::log("Deploying contracts with the account:", 0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return] 
    ├─ [0] VM::startPrank(0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5)
    │   └─ ← [Revert] cannot `prank` for a broadcasted transaction; pass the desired `tx.origin` into the `broadcast` cheatcode call
    ├─ [0] VM::envOr("FOUNDRY_OUT", "out") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::projectRoot() [staticcall]
    │   └─ ← [Return] "/Users/qiaopengjun/Code/solidity-code/UpgradeableTokenFactory"
    ├─ [0] VM::readFile("/Users/qiaopengjun/Code/solidity-code/UpgradeableTokenFactory/out/TokenFactoryV2.sol/TokenFactoryV2.json") [staticcall]
    │   └─ ← [Return] <file>
    ├─ [0] VM::keyExistsJson("<JSON file>", ".ast") [staticcall]
    │   └─ ← [Return] true
    ├─ [0] VM::parseJsonString("<stringified JSON>", ".ast.absolutePath") [staticcall]
    │   └─ ← [Return] "src/TokenFactoryV2.sol"
    ├─ [0] VM::keyExistsJson("<JSON file>", ".ast.license") [staticcall]
    │   └─ ← [Return] true
    ├─ [0] VM::parseJsonString("<stringified JSON>", ".ast.license") [staticcall]
    │   └─ ← [Return] "MIT"
    ├─ [0] VM::parseJsonString("<stringified JSON>", ".metadata.sources.['src/TokenFactoryV2.sol'].keccak256") [staticcall]
    │   └─ ← [Return] "0xfecdbfc40eca8736c55d88b10040818f948a65cfa1103a0470295e2c2df7b8a4"
    ├─ [0] VM::envOr("OPENZEPPELIN_BASH_PATH", "bash") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::tryFfi(["bash", "-c", "npx @openzeppelin/upgrades-core@^1.32.3 validate out/build-info --contract src/TokenFactoryV2.sol:TokenFactoryV2 --requireReference"])
    │   └─ ← [Return] (0, 0xe29c9420207372632f546f6b656e466163746f727956322e736f6c3a546f6b656e466163746f72795632202875706772616465732066726f6d207372632f546f6b656e466163746f727956312e736f6c3a546f6b656e466163746f72795631290a0a53554343455353, 0x)
    ├─ [0] VM::getCode("TokenFactoryV2.sol:TokenFactoryV2") [staticcall]
    │   └─ ← [Return] 0x60a06040523060805234801561001457600080fd5b5061001d610022565b6100d4565b7ff0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a00805468010000000000000000900460ff16156100725760405163f92ee8a960e01b815260040160405180910390fd5b80546001600160401b03908116146100d15780546001600160401b0319166001600160401b0390811782556040519081527fc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d29060200160405180910390a15b50565b60805161134a6100fd60003960008181610b8201528181610bab0152610cf1015261134a6000f3fe6080604052600436106100f35760003560e01c8063949d225d1161008a578063c4d66de811610059578063c4d66de81461028c578063d57fa2b6146102ac578063ec81aadb146102e2578063f2fde38b1461030257600080fd5b8063949d225d146101f9578063ad3cb1cc1461020e578063af7c6e551461024c578063b341458a1461027957600080fd5b80634f1ef286116100c65780634f1ef2861461018f57806352d1902d146101a2578063715018a6146101b75780638da5cb5b146101cc57600080fd5b8063204120bc146100f857806326a4e8d2146101385780633ccfd60b1461015a5780633ef8af431461016f575b600080fd5b34801561010457600080fd5b50610125610113366004611025565b60026020526000908152604090205481565b6040519081526020015b60405180910390f35b34801561014457600080fd5b50610158610153366004611025565b610322565b005b34801561016657600080fd5b5061015861034c565b34801561017b57600080fd5b5061015861018a3660046110cc565b6103e2565b61015861019d366004611134565b6106df565b3480156101ae57600080fd5b506101256106fa565b3480156101c357600080fd5b50610158610717565b3480156101d857600080fd5b506101e161072b565b6040516001600160a01b03909116815260200161012f565b34801561020557600080fd5b50600154610125565b34801561021a57600080fd5b5061023f604051806040016040528060058152602001640352e302e360dc1b81525081565b60405161012f91906111e6565b34801561025857600080fd5b50610125610267366004611025565b60036020526000908152604090205481565b610158610287366004611025565b610759565b34801561029857600080fd5b506101586102a7366004611025565b61090e565b3480156102b857600080fd5b506101e16102c7366004611025565b6004602052600090815260409020546001600160a01b031681565b3480156102ee57600080fd5b506101e16102fd3660046111f9565b610a26565b34801561030e57600080fd5b5061015861031d366004611025565b610a50565b61032a610a8e565b600080546001600160a01b0319166001600160a01b0392909216919091179055565b610354610a8e565b478061039e5760405162461bcd60e51b81526020600482015260146024820152734e6f2066756e647320746f20776974686472617760601b60448201526064015b60405180910390fd5b6103a661072b565b6001600160a01b03166108fc829081150290604051600060405180830381858888f193505050501580156103de573d6000803e3d6000fd5b5050565b600084511161042c5760405162461bcd60e51b815260206004820152601660248201527553796d626f6c2063616e6e6f7420626520656d70747960501b6044820152606401610395565b6000831161048b5760405162461bcd60e51b815260206004820152602660248201527f546f74616c20737570706c79206d7573742062652067726561746572207468616044820152656e207a65726f60d01b6064820152608401610395565b600082116104e65760405162461bcd60e51b815260206004820152602260248201527f506572206d696e74206d7573742062652067726561746572207468616e207a65604482015261726f60f01b6064820152608401610395565b600081116105365760405162461bcd60e51b815260206004820152601f60248201527f5072696365206d7573742062652067726561746572207468616e207a65726f006044820152606401610395565b6000546001600160a01b03166105985760405162461bcd60e51b815260206004820152602160248201527f496d706c656d656e746174696f6e2061646472657373206973206e6f742073656044820152601d60fa1b6064820152608401610395565b6105ba6040518060600160405280602781526020016112ce6027913933610ac0565b600080546105d0906001600160a01b0316610b05565b604051637433462960e11b81529091506001600160a01b0382169063e8668c5290610605903390899089908990600401611212565b600060405180830381600087803b15801561061f57600080fd5b505af1158015610633573d6000803e3d6000fd5b5050600180548082019091557fb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf60180546001600160a01b03199081166001600160a01b0386169081179092556000828152600260209081526040808320899055600382528083208a90556004909152808220805433941684179055518795509193507feff7155918865c0cf825001d51831de8285d88e661dea1d706f9c64211816b5191a45050505050565b6106e7610b77565b6106f082610c1c565b6103de8282610c24565b6000610704610ce6565b506000805160206112f583398151915290565b61071f610a8e565b6107296000610d2f565b565b7f9016d09d72d40fdae2fd8ceac6b6234c7706214fd39c1cd1e609a0528c199300546001600160a01b031690565b6001600160a01b03808216600090815260026020908152604080832054600383528184205460049093529220548493166107938284611249565b3410156107d65760405162461bcd60e51b8152602060048201526011602482015270125b98dbdc9c9958dd081c185e5b595b9d607a1b6044820152606401610395565b6040516335313c2160e11b81523360048201526001600160a01b03851690636a62784290602401600060405180830381600087803b15801561081757600080fd5b505af115801561082b573d6000803e3d6000fd5b505050506000816001600160a01b03163460405160006040518083038185875af1925050503d806000811461087c576040519150601f19603f3d011682016040523d82523d6000602084013e610881565b606091505b50509050806108c55760405162461bcd60e51b815260206004820152601060248201526f2a3930b739b332b9103330b4b632b21760811b6044820152606401610395565b34826001600160a01b0316876001600160a01b03167f30ec8252c6daf0651c3708437cd3947ffa8789a74488d4a9d22fa53b48d545e460405160405180910390a4505050505050565b7ff0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a008054600160401b810460ff16159067ffffffffffffffff166000811580156109545750825b905060008267ffffffffffffffff1660011480156109715750303b155b90508115801561097f575080155b1561099d5760405163f92ee8a960e01b815260040160405180910390fd5b845467ffffffffffffffff1916600117855583156109c757845460ff60401b1916600160401b1785555b6109d086610da0565b6109d8610db1565b8315610a1e57845460ff60401b19168555604051600181527fc7f505b2f371ae2175ee4913f4499e1f2633a7b5936321eed1cdaeb6115181d29060200160405180910390a15b505050505050565b60018181548110610a3657600080fd5b6000918252602090912001546001600160a01b0316905081565b610a58610a8e565b6001600160a01b038116610a8257604051631e4fbdf760e01b815260006004820152602401610395565b610a8b81610d2f565b50565b33610a9761072b565b6001600160a01b0316146107295760405163118cdaa760e01b8152336004820152602401610395565b6103de8282604051602401610ad692919061126e565b60408051601f198184030181529190526020810180516001600160e01b031663319af33360e01b179052610db9565b6000763d602d80600a3d3981f3363d3d373d3d3d363d730000008260601b60e81c176000526e5af43d82803e903d91602b57fd5bf38260781b17602052603760096000f090506001600160a01b038116610b72576040516330be1a3d60e21b815260040160405180910390fd5b919050565b306001600160a01b037f0000000000000000000000000000000000000000000000000000000000000000161480610bfe57507f00000000000000000000000000000000000000000000000000000000000000006001600160a01b0316610bf26000805160206112f5833981519152546001600160a01b031690565b6001600160a01b031614155b156107295760405163703e46dd60e11b815260040160405180910390fd5b610a8b610a8e565b816001600160a01b03166352d1902d6040518163ffffffff1660e01b8152600401602060405180830381865afa925050508015610c7e575060408051601f3d908101601f19168201909252610c7b91810190611298565b60015b610ca657604051634c9c8ce360e01b81526001600160a01b0383166004820152602401610395565b6000805160206112f58339815191528114610cd757604051632a87526960e21b815260048101829052602401610395565b610ce18383610dc2565b505050565b306001600160a01b037f000000000000000000000000000000000000000000000000000000000000000016146107295760405163703e46dd60e11b815260040160405180910390fd5b7f9016d09d72d40fdae2fd8ceac6b6234c7706214fd39c1cd1e609a0528c19930080546001600160a01b031981166001600160a01b03848116918217845560405192169182907f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e090600090a3505050565b610da8610e18565b610a8b81610e61565b610729610e18565b610a8b81610e69565b610dcb82610e8a565b6040516001600160a01b038316907fbc7cd75a20ee27fd9adebab32041f755214dbc6bffa90cc0225b39da2e5c2d3b90600090a2805115610e1057610ce18282610eef565b6103de610f67565b7ff0c57e16840df040f15088dc2f81fe391c3923bec73e23a9662efc9c229c6a0054600160401b900460ff1661072957604051631afcd79f60e31b815260040160405180910390fd5b610a58610e18565b80516a636f6e736f6c652e6c6f67602083016000808483855afa5050505050565b806001600160a01b03163b600003610ec057604051634c9c8ce360e01b81526001600160a01b0382166004820152602401610395565b6000805160206112f583398151915280546001600160a01b0319166001600160a01b0392909216919091179055565b6060600080846001600160a01b031684604051610f0c91906112b1565b600060405180830381855af49150503d8060008114610f47576040519150601f19603f3d011682016040523d82523d6000602084013e610f4c565b606091505b5091509150610f5c858383610f86565b925050505b92915050565b34156107295760405163b398979f60e01b815260040160405180910390fd5b606082610f9b57610f9682610fe5565b610fde565b8151158015610fb257506001600160a01b0384163b155b15610fdb57604051639996b31560e01b81526001600160a01b0385166004820152602401610395565b50805b9392505050565b805115610ff55780518082602001fd5b604051630a12f52160e11b815260040160405180910390fd5b80356001600160a01b0381168114610b7257600080fd5b60006020828403121561103757600080fd5b610fde8261100e565b634e487b7160e01b600052604160045260246000fd5b600067ffffffffffffffff8084111561107157611071611040565b604051601f8501601f19908116603f0116810190828211818310171561109957611099611040565b816040528093508581528686860111156110b257600080fd5b858560208301376000602087830101525050509392505050565b600080600080608085870312156110e257600080fd5b843567ffffffffffffffff8111156110f957600080fd5b8501601f8101871361110a57600080fd5b61111987823560208401611056565b97602087013597506040870135966060013595509350505050565b6000806040838503121561114757600080fd5b6111508361100e565b9150602083013567ffffffffffffffff81111561116c57600080fd5b8301601f8101851361117d57600080fd5b61118c85823560208401611056565b9150509250929050565b60005b838110156111b1578181015183820152602001611199565b50506000910152565b600081518084526111d2816020860160208601611196565b601f01601f19169290920160200192915050565b602081526000610fde60208301846111ba565b60006020828403121561120b57600080fd5b5035919050565b6001600160a01b0385168152608060208201819052600090611236908301866111ba565b6040830194909452506060015292915050565b8082028115828204841417610f6157634e487b7160e01b600052601160045260246000fd5b60408152600061128160408301856111ba565b905060018060a01b03831660208301529392505050565b6000602082840312156112aa57600080fd5b5051919050565b600082516112c3818460208701611196565b919091019291505056fe6465706c6f79496e736372697074696f6e20206d73672e73656e6465722c20616464726573733a360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbca264697066735822122024e97f259c62d9ba16fca8ceb047805e03f12f943e458b863f8e06c60cb0513b64736f6c63430008140033
    ├─ [1012207] → new TokenFactoryV2@0xDdDC3837f0d3cb104B768208327F3017Ba22Bb6f
    │   ├─ emit Initialized(version: 18446744073709551615 [1.844e19])
    │   └─ ← [Return] 4938 bytes of code
    ├─ [0] VM::load(MetaMultiSigWallet: [0x90635Ff2Ff7E64872848612ad6B943b04B089Db0], 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103) [staticcall]
    │   └─ ← [Return] 0x0000000000000000000000000000000000000000000000000000000000000000
    ├─ [5486] MetaMultiSigWallet::UPGRADE_INTERFACE_VERSION()
    │   ├─ [590] MetaMultiSigWallet::UPGRADE_INTERFACE_VERSION() [delegatecall]
    │   │   └─ ← [Return] "5.0.0"
    │   └─ ← [Return] "5.0.0"
    ├─ [8949] MetaMultiSigWallet::upgradeToAndCall(TokenFactoryV2: [0xDdDC3837f0d3cb104B768208327F3017Ba22Bb6f], 0x)
    │   ├─ [8550] MetaMultiSigWallet::upgradeToAndCall(TokenFactoryV2: [0xDdDC3837f0d3cb104B768208327F3017Ba22Bb6f], 0x) [delegatecall]
    │   │   ├─ [343] TokenFactoryV2::proxiableUUID() [staticcall]
    │   │   │   └─ ← [Return] 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
    │   │   ├─ emit Upgraded(implementation: TokenFactoryV2: [0xDdDC3837f0d3cb104B768208327F3017Ba22Bb6f])
    │   │   └─ ← [Stop] 
    │   └─ ← [Return] 
    ├─ [23116] MetaMultiSigWallet::setTokenAddress(0x65869BaA9336F8968704F2dd60C40959a7bD202b)
    │   ├─ [22726] TokenFactoryV2::setTokenAddress(0x65869BaA9336F8968704F2dd60C40959a7bD202b) [delegatecall]
    │   │   └─ ← [Stop] 
    │   └─ ← [Return] 
    ├─ [0] console::log("setTokenAddress success:", true) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    └─ ← [Stop] 


Script ran successfully.

== Logs ==
  Deploying contracts with the account: 0x750Ea21c1e98CcED0d4557196B6f4a5974CCB6f5
  setTokenAddress success: true

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [1012207] → new TokenFactoryV2@0xDdDC3837f0d3cb104B768208327F3017Ba22Bb6f
    ├─ emit Initialized(version: 18446744073709551615 [1.844e19])
    └─ ← [Return] 4938 bytes of code

  [5486] MetaMultiSigWallet::UPGRADE_INTERFACE_VERSION()
    ├─ [590] MetaMultiSigWallet::UPGRADE_INTERFACE_VERSION() [delegatecall]
    │   └─ ← [Return] "5.0.0"
    └─ ← [Return] "5.0.0"

  [15949] MetaMultiSigWallet::upgradeToAndCall(TokenFactoryV2: [0xDdDC3837f0d3cb104B768208327F3017Ba22Bb6f], 0x)
    ├─ [11050] MetaMultiSigWallet::upgradeToAndCall(TokenFactoryV2: [0xDdDC3837f0d3cb104B768208327F3017Ba22Bb6f], 0x) [delegatecall]
    │   ├─ [343] TokenFactoryV2::proxiableUUID() [staticcall]
    │   │   └─ ← [Return] 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc
    │   ├─ emit Upgraded(implementation: TokenFactoryV2: [0xDdDC3837f0d3cb104B768208327F3017Ba22Bb6f])
    │   └─ ← [Stop] 
    └─ ← [Return] 

  [29616] MetaMultiSigWallet::setTokenAddress(0x65869BaA9336F8968704F2dd60C40959a7bD202b)
    ├─ [24726] TokenFactoryV2::setTokenAddress(0x65869BaA9336F8968704F2dd60C40959a7bD202b) [delegatecall]
    │   └─ ← [Stop] 
    └─ ← [Return] 


==========================

Chain 11155111

Estimated gas price: 12.340371374 gwei

Estimated total gas used for script: 1651348

Estimated amount required: 0.020378247587712152 ETH

==========================
Enter keystore password:

##### sepolia
✅  [Success]Hash: 0xdff6fc1e1c8c433603316f0ee29645c2697f7c15a526a9c44ccd2e31e55ec612
Block: 6397346
Paid: 0.0001663139166606 ETH (26550 gas * 6.264177652 gwei)


##### sepolia
✅  [Success]Hash: 0xd53ffbda9ecfe0e105e26cab1e014fdef4d91a4d08e9a55ee696404adada1b40
Contract Address: 0xDdDC3837f0d3cb104B768208327F3017Ba22Bb6f
Block: 6397346
Paid: 0.007177450904418036 ETH (1145793 gas * 6.264177652 gwei)


##### sepolia
✅  [Success]Hash: 0x460526792fb760d0a32c67c86a5d95931aa310774d7866d4966a362382b19b12
Block: 6397346
Paid: 0.000235840024420148 ETH (37649 gas * 6.264177652 gwei)


##### sepolia
✅  [Success]Hash: 0xf718a117d7a27f75b40545ed018f7c6d0e424945e7c59f818162274eb7d53b92
Block: 6397346
Paid: 0.000319773740779296 ETH (51048 gas * 6.264177652 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.00789937858627808 ETH (1261040 gas * avg 6.264177652 gwei)
                                                                                                                                        

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (1) contracts
Start verifying contract `0xDdDC3837f0d3cb104B768208327F3017Ba22Bb6f` deployed on sepolia

Submitting verification for [src/TokenFactoryV2.sol:TokenFactoryV2] 0xDdDC3837f0d3cb104B768208327F3017Ba22Bb6f.
Submitted contract for verification:
        Response: `OK`
        GUID: `xb9cv6f4g7ur7p7xj15um4gbfi7guyfsrvmpvjjgdq6dj3vqwd`
        URL: https://sepolia.etherscan.io/address/0xdddc3837f0d3cb104b768208327f3017ba22bb6f
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (1) contracts were verified!

Transactions saved to: /Users/qiaopengjun/Code/solidity-code/UpgradeableTokenFactory/broadcast/TokenFactoryV2.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/solidity-code/UpgradeableTokenFactory/cache/TokenFactoryV2.s.sol/11155111/run-latest.json


UpgradeableTokenFacto
```

##### 注意：这里部署了两次，因为第一次部署时发生`Context:server returned an error response: error code -32000: future transaction tries to replace pending` 有可能是网络问题，导致部署上去的合约未验证，故重新再次部署，当然也可以进行验证``verify-contract`

#### 第一次部署

##### 刚部署时因为报错查看没有Verify，错误 `error code -32000: future transaction tries to replace pending` 通常发生在以太坊交易过程中，当一个新的交易试图替换一个尚未被矿工处理的待处理交易时。 第二次部署后，再次查看已经Verify了，估计是网络延迟或节点同步问题

<https://sepolia.etherscan.io/address/0x89A14B4b7c9Ec826C1a3C38deF97b90565503992#code>

![image-20240729201501613](/images/image-20240729201501613.png)

#### 第二次部署

<https://sepolia.etherscan.io/address/0xdddc3837f0d3cb104b768208327f3017ba22bb6f>

![image-20240729200513578](/images/image-20240729200513578.png)

### 成功部署升级

![image-20240729200912921](/images/image-20240729200912921.png)

### 问题

#### 报错

![image-20240728181656682](/images/image-20240728181656682.png)

![image-20240728172115753](/images/image-20240728172115753.png)

#### 解决

![image-20240728172010845](/images/image-20240728172010845.png)

问题二

![image-20240729000025123](/images/image-20240729000025123.png)

解决：调用的时候一定要是代理去调用，而不能是factory合约去调用

### 测试输出

```bash
UpgradeableTokenFactory on  main [!?] via 🅒 base took 8.2s 
➜ forge test -vv            
[⠒] Compiling...
No files changed, compilation skipped

Ran 1 test for test/ERC20TokenTest.sol:ERC20TokenTest
[PASS] testERC20Functionality() (gas: 123304)
Logs:
  0x7c8999dC9a822c1f0Df42023113EDB4FDd543266

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 1.67ms (61.00µs CPU time)

Ran 4 tests for test/TokenFactoryV2Test.sol:CounterTest
[PASS] testTokenFactoryV2DeployInscriptionFunctionality() (gas: 2903155)
Logs:
  0x7c8999dC9a822c1f0Df42023113EDB4FDd543266
  deployInscription  msg.sender, address: 0x7c8999dC9a822c1f0Df42023113EDB4FDd543266

[PASS] testTokenFactoryV2MintInscriptionFunctionality() (gas: 3002961)
Logs:
  0x7c8999dC9a822c1f0Df42023113EDB4FDd543266
  deployInscription  msg.sender, address: 0x7c8999dC9a822c1f0Df42023113EDB4FDd543266

[PASS] testTokenFactoryV2PermissionsDeployInscriptionFunctionality() (gas: 2905067)
Logs:
  0x7c8999dC9a822c1f0Df42023113EDB4FDd543266
  deployInscription  msg.sender, address: 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D

[PASS] testTokenFactoryV2PermissionsMintInscriptionFunctionality() (gas: 3000572)
Logs:
  0x7c8999dC9a822c1f0Df42023113EDB4FDd543266
  deployInscription  msg.sender, address: 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D

Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 2.23ms (1.95ms CPU time)

Ran 2 tests for test/Counter.t.sol:CounterTest
[PASS] testFuzz_SetNumber(uint256) (runs: 256, μ: 30977, ~: 31288)
[PASS] test_Increment() (gas: 31303)
Suite result: ok. 2 passed; 0 failed; 0 skipped; finished in 5.42ms (4.31ms CPU time)

Ran 5 tests for test/TokenFactoryV1Test.sol:TokenFactoryV1Test
[PASS] testTokenFactoryV1DeployInscriptionFunctionality() (gas: 2972857)
Logs:
  0x7c8999dC9a822c1f0Df42023113EDB4FDd543266
  deployInscription newToken:  0x8d2C17FAd02B7bb64139109c6533b7C2b9CADb81

[PASS] testTokenFactoryV1MintInscriptionFunctionality() (gas: 3068046)
Logs:
  0x7c8999dC9a822c1f0Df42023113EDB4FDd543266
  deployInscription newToken:  0x8d2C17FAd02B7bb64139109c6533b7C2b9CADb81

[PASS] testTokenFactoryV1PermissionsDeployInscriptionFunctionality() (gas: 2973252)
Logs:
  0x7c8999dC9a822c1f0Df42023113EDB4FDd543266
  deployInscription newToken:  0x8d2C17FAd02B7bb64139109c6533b7C2b9CADb81

[PASS] testTokenFactoryV1PermissionsMintInscriptionFunctionality() (gas: 3065556)
Logs:
  0x7c8999dC9a822c1f0Df42023113EDB4FDd543266
  deployInscription newToken:  0x8d2C17FAd02B7bb64139109c6533b7C2b9CADb81

[PASS] testUpgradeability() (gas: 6337394)
Logs:
  0x7c8999dC9a822c1f0Df42023113EDB4FDd543266

Suite result: ok. 5 passed; 0 failed; 0 skipped; finished in 6.02s (6.02s CPU time)

Ran 4 test suites in 6.02s (6.03s CPU time): 12 tests passed, 0 failed, 0 skipped (12 total tests)

UpgradeableTokenFactory on  main [!?] via 🅒 base took 6.7s 
```

## Foundry Upgrades

### Run these commands

```bash
forge install foundry-rs/forge-std
forge install OpenZeppelin/openzeppelin-foundry-upgrades
forge install OpenZeppelin/openzeppelin-contracts-upgradeable
```

#### Set the following in `remappings.txt`, replacing any previous definitions of these remappings

```bash
@openzeppelin/contracts/=lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/
@openzeppelin/contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/contracts/
```

#### Configure your `foundry.toml` to enable ffi, ast, build info and storage layout

```toml
[profile.default]
ffi = true
ast = true
build_info = true
extra_output = ["storageLayout"]
```

更多请参考：<https://github.com/OpenZeppelin/openzeppelin-foundry-upgrades>

## 源码

### [UpgradeableTokenFactory](https://github.com/qiaopengjun5162/UpgradeableTokenFactory)

## 参考

- [ERC1967Utils](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/ERC1967/ERC1967Utils.sol)
- [ERC1967Proxy](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/proxy/ERC1967/ERC1967Proxy.sol)
- [Foundry Book](https://book.getfoundry.sh/)
- <https://github.com/OpenZeppelin/openzeppelin-foundry-upgrades>
- <https://github.com/OpenZeppelin/openzeppelin-upgrades>
- <https://sepolia.etherscan.io/address/0x2b25e3f0879c4f9d7dedfe5414d6e48045b2fa57#writeProxyContract>
- <https://github.com/OpenZeppelin/openzeppelin-contracts>
- <https://eips.ethereum.org/EIPS/eip-1967>
- <https://eips.ethereum.org/EIPS/eip-1822>
- <https://eips.ethereum.org/EIPS/eip-1167>
- <https://github.com/optionality/clone-factory>
- <https://book.getfoundry.sh/forge/deploying>
