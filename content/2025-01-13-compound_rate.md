+++
title = "全面解读 Compound 资金利用率的计算公式与源码实现"
description = "全面解读 Compound 资金利用率的计算公式与源码实现"
date = 2025-01-13 23:55:49+08:00
[taxonomies]
categories = ["Web3", "DeFi"]
tags = ["Web3", "DeFi"]
+++

<!-- more -->

# 全面解读 Compound 资金利用率的计算公式与源码实现

Compound 协议作为一个去中心化借贷平台，其核心之一便是资金池的资金利用率（Utilization Rate）。资金利用率不仅影响借贷市场的流动性，还直接影响借款利率与存款利率。本篇文章将深入探讨 Compound 中资金利用率的定义、计算公式，以及如何通过源码计算出实际的资金利用率，并进行实际案例验证。

本文首先介绍了 **资金利用率** 的基本概念，并重点分析了 Compound 协议中资金利用率的计算方式，特别是为何需要从总资产中减去储备金（Reserves）。然后，通过 Compound 协议的源码解析，进一步探讨了如何在 Solidity 合约中实现资金利用率的计算方法。最后，结合 USDC 作为案例，通过 Compound 的界面及源码验证了资金利用率的计算过程，确保计算结果与实际数据一致。

## 资金利用率

**资金利用率**（Utilization Rate）通常可以理解为 **总借款**（Total Borrows）除以 **总资产**（Total Assets），但为了更准确地表达，在 **Compound** 协议中，计算资金池的利用率时，会有一些额外的调整。具体来说，资金池的总资产通常包括：

- **总现金**（Cash）：即存入的资金池中可立即借出的资产数量。
- **总借款**（Borrows）：用户借出的资产总量。
- **储备金**（Reserves）：协议为应对突发提取需求和风险所保留的资金。

所以，在 **Compound 协议** 中，资金利用率的计算公式为：
$$
Utilization Rate= \frac{\text{Total Borrows}}{\text{Total Assets} - \text{Reserves}}
$$
其中，**Total Assets** = **Cash + Borrows**。这个计算方法考虑了储备金的存在，因为储备金并不直接用于借款，因此不能算作可以借出的资产。

### 具体公式

$$
Utilization Rate=\frac{\text{Borrows}}{\text{Cash} + \text{Borrows} - \text{Reserves}}
$$

- **Borrows**：总借款，即所有借款用户所借的资金总额。
- **Cash**：可供借款的现金，即存款池中的可用资产。
- **Reserves**：储备金，是协议预留的一部分资金，用于应对流动性风险。

### 资金利用率的意义

- **高利用率**：意味着借款需求高，资金池中的大部分资金都已经被借出，可能导致流动性紧张，借款利率也可能上升。
- **低利用率**：表示借款需求较低，资金池中有大量的未借出资金，存款利率可能较低。

## 思考：为什么要减 Reserves

在计算 **资产利用率（Utilization Rate）** 时，减去 **Reserves（储备金）** 是为了更准确地衡量市场中可供借款的资金量。

### 理由

**Reserves（储备金）** 是平台为了确保其流动性和应对潜在风险所保留的一部分资金。这部分资金并不参与借贷过程，因此不应该算作市场中可用来借出的资金。

在 **Compound 协议** 中，存款人将资金存入市场中，平台会借给其他用户。但由于存在 **储备金**，它需要被从市场可用资金中扣除，因为这部分资金是为保障平台稳定和应对紧急情况而保留的，不能用于借贷。

#### 更清楚的解释

- **Cash**（现金）：这是平台上可用来借出的资金，存款人存入的资金。
- **Borrows**（借款）：这部分资金已经被借出，但它仍然在市场上存在，因为借款人最终需要归还这些资金。
- **Reserves**（储备金）：这些是平台专门保留的资金，用于防范风险和保持市场流动性，不能被借出。

因此，**Reserves** 应该从计算中扣除，才能得出真正可以用于借贷的资金池。否则，利用率计算会高估市场的资金可用性，因为储备金不参与借贷。

#### 公式背后的逻辑

1. **Cash + Borrows**：代表市场中所有存款和借款的资金。
2. **Reserves**：需要从中减去，因为它是为保障平台安全而预留的资金，不能用于借贷。
3. **Utilization Rate**：利用率表示已借出的资金（Borrows）与市场中实际可用于借贷的资金（Cash + Borrows - Reserves）的比例。

#### 总结

减去 **Reserves（储备金）** 是为了确保计算的是 **真实的可借资金池**，而不是包括了平台为保障安全和应对风险而保留的资金。这种计算方式使得资产利用率更加准确，反映了市场上实际可供借出的资金的比例。

## Compound 资金利用率源码解析

<https://github.com/compound-finance/compound-protocol/blob/master/contracts/BaseJumpRateModelV2.sol>

![image-20250113214634898](/images/image-20250113214634898.png)

### `utilizationRate` 代码

```ts
 /**
     * @notice Calculates the utilization rate of the market: `borrows / (cash + borrows - reserves)`
     * @param cash The amount of cash in the market
     * @param borrows The amount of borrows in the market
     * @param reserves The amount of reserves in the market (currently unused)
     * @return The utilization rate as a mantissa between [0, BASE]
     */
    // cash：市场中的现金数量。
    // borrows：市场中的借贷数量。
    // reserves：市场中的储备数量（当前未使用）。
    function utilizationRate(
        uint cash,
        uint borrows,
        uint reserves
    ) public pure returns (uint) {
        // 首先检查borrows是否为0。如果为0，则直接返回0，因为此时没有借贷，利用率自然为0。
        // Utilization rate is 0 when there are no borrows
        if (borrows == 0) {
            return 0;
        }

        // 如果borrows不为0，则计算利用率。利用率的公式是：borrows / (cash + borrows - reserves)。
        // 这里使用了BASE作为基数，通常BASE是一个很大的数（如10^18），用于将小数转换为整数，便于计算和存储。
        // 利用率 = (借贷资产 / 总资产)。
        return (borrows * BASE) / (cash + borrows - reserves);
    }
```

### 以 USDC 为例实操验证

#### 第一步：在 Compound 界面查看资金利用率、借款利率、存款利率等参数

<https://app.compound.finance/markets/v2>

![image-20250113220344909](/images/image-20250113220344909.png)

由上图可知：

- 资金利用率： Utilization  `83.37%`

- 借款利率： Borrow APR  `9.43%`

- 存款利率：Earn APR  `5.90%`

#### 第二步：在 `Compound` 源码中找到 `cToken` 合约地址和 **`LegacyJumpRateModelV2`** 合约地址

在 `networks` 文件夹下`mainnet.json` 文件

##### **`cToken`** 合约地址

<https://github.com/compound-finance/compound-protocol/blob/master/networks/mainnet.json#L532>

![image-20250113215719672](/images/image-20250113215719672.png)

##### **`LegacyJumpRateModelV2`** 合约地址

<https://etherscan.io/address/0xd8ec56013ea119e7181d231e5048f90fbbe753c0#code>

![image-20250113221728105](/images/image-20250113221728105.png)

#### 第三步：在 `cToken` 合约中查询 `cash、borrows、reserves` 数据

<https://etherscan.io/address/0x39aa39c021dfbae8fac545936693ac917d5e7563>

![image-20250113222144875](/images/image-20250113222144875.png)

查询结果：

- cash = [15642016014429](https://etherscan.io/unitconverter?wei=15642016014429) *uint256*

- borrows = [30122447622903](https://etherscan.io/unitconverter?wei=30122447622903) *uint256*

- reserves = [9633321156234](https://etherscan.io/unitconverter?wei=9633321156234) *uint256*

#### 第四步：在利率模型合约 **`LegacyJumpRateModelV2`** 中调用`utilizationRate` 方法获取资金利用率

<https://etherscan.io/address/0xd8ec56013ea119e7181d231e5048f90fbbe753c0#code>

![image-20250113222557803](/images/image-20250113222557803.png)

根据上图结果可得资金利用率为： [833697623557338450](https://etherscan.io/unitconverter?wei=833697623557338450)

#### 手动验证

**`(borrows * BASE) / (cash + borrows - reserves)`**

根据上面的公式代入值可得我们要计算的表达式是：
$$
\frac{30122447622903 \times 1e18}{15642016014429 + 30122447622903 - 9633321156234}
$$

##### 步骤 1: 计算分母

首先，我们计算分母部分：
$$
15642016014429 + 30122447622903 - 9633321156234
$$

1. 计算第一部分：

$$
   15642016014429 + 30122447622903 = 45764463637332

$$

2. 计算第二部分：

$$
  
   45764463637332 - 9633321156234 = 36131132581108

$$

所以，分母的值是：
$$
\text{Denominator} = 36131132581108
$$

##### 步骤 2: 计算分子

接下来，我们计算分子部分：
$$
30122447622903 \times 1e18
$$

1. 计算分子：

$$
   30122447622903 \times 1e18 = 30122447622903 \times 10^{18}

$$

##### 步骤 3: 计算整个表达式

现在我们可以将分子和分母结合起来计算整个表达式：
$$

\frac{30122447622903 \times 10^{18}}{36131132581108}
$$

1. **计算分数**：

$$

   \frac{30122447622903}{36131132581108} \approx 0.8337

$$

2. 将结果乘以 $ 10^{18} $：

$$
   0.8337 \times 10^{18} \approx 8.337 \times 10^{17}

$$

##### 步骤 4: 转换为百分比

最后，将分数转换为百分比：
$$
0.8337 \times 100\% \approx 83.37\%
$$

#### 结论

因此，最终结果是：
$$
\text{Utilization Rate} \approx 83.37\%
$$
这与`Compound`页面显示的资金利用率一致。

## 总结

通过对 Compound 资金利用率的详细分析，我们深入理解了其计算方式的精妙，尤其是储备金扣除的逻辑。这一逻辑确保了计算结果的准确性，并真实反映了市场的借贷状况。本文不仅解析了公式的理论基础，还通过实际的代码实现和数据验证展示了该公式在 Compound 协议中的应用，帮助读者更好地理解去中心化借贷平台中的资金流动与风险管理。

此外，本文还强调了 Compound 协议资金利用率作为市场流动性与利率的关键指标，对 DeFi 协议的核心逻辑起到了重要作用。通过从公式推导到源码实现，再到实际案例验证的系统性分析，文章为开发者和用户提供了全面的参考。理解资金利用率的计算，有助于更好地参与和优化 DeFi 协议的开发。

## 参考

- <https://etherscan.io/address/0xd8ec56013ea119e7181d231e5048f90fbbe753c0#readContract>
- <https://compound.finance/documents/Compound.Whitepaper.pdf>
- <https://etherscan.io/address/0x39aa39c021dfbae8fac545936693ac917d5e7563#readContract>
- <https://www.rareskills.io/all-posts>
- <https://app.compound.finance/markets/v2>
- <https://github.com/compound-finance/compound-protocol/tree/master>
- <https://docs.compound.finance/liquidation/#liquidatable-accounts>
- <https://github.com/aave/protocol-v2/blob/master/contracts/protocol/lendingpool/LendingPool.sol>
