+++
title = "Uniswap V3 流动性机制与限价订单解析：资金效率提升之道"
description = "Uniswap V3 流动性机制与限价订单解析：资金效率提升之道"
date = 2025-05-22T03:45:12Z
[taxonomies]
categories = ["Web3", "Uniswap", "DeFi"]
tags = ["Web3", "Uniswap", "DeFi"]
+++

<!-- more -->

# Uniswap V3 流动性机制与限价订单解析：资金效率提升之道

Uniswap V3 引入了集中流动性和价格区间的创新机制，相较于 V2 显著提升了资金使用效率。本文通过数学推导、案例分析和限价订单实现，深入剖析 Uniswap V3 的流动性计算原理及其实际应用，适合对去中心化金融（DeFi）和自动化做市商（AMM）感兴趣的读者。

本文详细讲解了 Uniswap V3 中流动性的计算公式，推导了 X、Y Token 与流动性 L、价格 P 之间的关系，并通过案例分析展示了虚拟流动性如何将资金效率提升一倍。进一步探讨了限价订单的实现原理，揭示了价格区间设置对流动性和资金效率的影响。最后通过一个思考问题，引导读者深入理解流动性参数 L 的计算。

## 流动性计算

![image-20250522093613396](/images/image-20250522093613396.png)

### 一、确定 x, y 与 L, P 的关系

#### 推导 X

$$
\begin{align*}
x \cdot y = k =  L^2 \\
(Xr + Xv) \cdot (Yr + Yv) = k \\
p = \frac{y}{x} \\
x = \frac{L^2}{y} = \frac{L^2}{px} \\
x^2 = \frac{L^2}{p} \\
x = \frac{L}{\sqrt{{p}}}
\end{align*}
$$

#### 推导 Y

$$
\begin{align*}
x \cdot y = k =  L^2 \\
p = \frac{y}{x} \\
y = p \cdot x = p \cdot \frac{L^2}{y} \\
y^2 = p \cdot L^2 \\
y = L \cdot \sqrt{p}
\end{align*}
$$

#### 在 P = Pb 时

$$
\begin{align*}
x = Xv + Xr = \frac{L}{\sqrt{{Pb}}}
\end{align*}
$$

因为 Xr = 0，故得出 $Xv =  \frac{L}{\sqrt{{Pb}}}$

#### 在 P = Pa 时

$$
\begin{align*}
y = Yr + Yv = L \cdot \sqrt{Pa}
\end{align*}
$$

因为 Yr = 0，故得出 $Yv =  L \cdot \sqrt{Pa}$

根据上述可推导公式如下：
$$
\begin{align*}
x \cdot y = k =  L^2 \\
(Xr + Xv) \cdot (Yr + Yv) = k = L^2 \\
(Xr +  \frac{L}{\sqrt{{Pb}}}) \cdot (Yr +  L \cdot \sqrt{Pa}) = k = L^2 \\
(x +  \frac{L}{\sqrt{{Pb}}}) \cdot (y +  L \cdot \sqrt{Pa}) = L^2 \\
\end{align*}
$$

![image-20250522094846030](/images/image-20250522094846030.png)

这就是 Uniswap V3 实际流动性和X、Y Token 数量关系的公式。这也是 Uniswap V3 白皮书中的公式 其实它本质上也是$ x \cdot y = k$ 的一个变种。

![image-20250522094943657](/images/image-20250522094943657.png)

### 二、案例

#### 真实场景下流动性的变化影响

![image-20250522094325770](/images/image-20250522094325770.png)

求 Xv, Yv ?
$$
\begin{align*}
Xv &=  \frac{L}{\sqrt{{Pb}}} \\
&= \frac{\sqrt{1 \cdot 4000}}{\sqrt{16000}} \\
&= \sqrt{\frac{1}{4}} \\
&= \frac{1}{2} = 0.5
\end{align*}
$$

$$
\begin{align*}
Yv &=  L \cdot \sqrt{Pa} \\
&= \sqrt{1 \cdot 4000} \cdot \sqrt{1000} \\
&= 2000
\end{align*}
$$

根据公式计算：
$$
\begin{align*}
x \cdot y = k =  L^2 \\
(x +  \frac{L}{\sqrt{{Pb}}}) \cdot (y +  L \cdot \sqrt{Pa}) = L^2 \\
(x + 0.5) \cdot (y + 2000) = 4000 = L^2
\end{align*}
$$

对比 Uniswap V2
$$
\begin{align*}
x = 1 \\
y = 4000 \\
Xr = 1 - 0.5 = 0.5 \\
Yr = 4000 - 2000 = 2000
\end{align*}
$$

>**总结：因为虚拟流动性的引入，资金使用效率增加了一倍，即使用了一半的资金达到了同样的K值，资金效率提升了一倍。本来在 Unisawp V2 需要 1 和 4000 才能实现的曲线，在Uniswap V3 中的价格范围内容只需要提供 0.5 和 2000 就可以同样达到K值，实现同样的曲线。在本案例中资金使用效率是提升了一倍的。如果我们把价格范围设置的越小，资金使用效率越高。如果 Pa 越大，则 Yv 越大，如果Pb 越小，Xv 则越大。也就是说，Pa 和 Pb 越来越接近的话，也就是说，Pa 越大，Pb 越小，Xv 和 Yv 就会越来越大。因为 x = Xv + Xr, y = Yv + Yr 所以最后K 值和 L值也会越来越大。这也就是 Xv 和 Yv 的变化导致的流动性的变化。**

### 三、限价订单是如何实现的？

限价订单的实现
$$
\begin{align*}
x \cdot y = k =  L^2 \\
(x +  \frac{L}{\sqrt{{Pb}}}) \cdot (y +  L \cdot \sqrt{Pa}) = L^2 \\
(x + 0.5) \cdot (y + 2000) = 4000 = L^2 \\
Xv = 0.5 \\
Yv = 2000
\end{align*}
$$

#### 在 a 点添加流动性

$$
\begin{align*}
总流动性 - 虚拟流动性 = 实际流动性 \\
Xr = X - Xv \\
Yr = Y - Yv \\
Xr = 2 - 0.5 = 1.5 ETH \\
Yr = 2000 - 2000 = 0 DAI \\
\end{align*}
$$

此时添加流动性需要 1.5 ETH

#### 在 b 点添加流动性

总流动性 - 虚拟流动性 = 实际流动性
$$
\begin{align*}
Xr &= X - Xv \\
&= 0.5 - 0.5 = 0 ETH \\
Yr &= Y - Yv \\
&= 8000 - 2000 = 6000 DAI \\
\end{align*}
$$
此时移出流动性可获得 6000 DAI

我给池子1.5 ETH, 最后因为价格的波动，能拿到 6000 DAI。
Uniswap V3 因为引入了集中流动性、价格区间，它支持模拟限价订单的实现。

#### 思考

在以上案例中，在价格P点，真实提供 (1, 4000) 的 LP，求 L 为多少？

## 总结

Uniswap V3 通过集中流动性和价格区间设计，显著提高了资金使用效率。案例表明，相比 V2，V3 能在相同 K 值下用一半资金实现相同曲线，效率提升一倍。限价订单的实现进一步增强了其灵活性，使 LP 能更精准地管理资金。价格区间越窄，资金效率越高，但需注意 Xv 和 Yv 的动态变化对流动性的影响。读者可参考 Uniswap V3 白皮书及相关合约代码深入学习。

## 参考

- <https://github.com/Uniswap/v3-periphery/tree/main/contracts>
- <https://github.com/Uniswap/v3-core/blob/main/contracts/UniswapV3Pool.sol>
- <https://www.desmos.com/calculator/vtiwukgo2s?lang=zh-CN>
- <https://docs.uniswap.org/contracts/v3/guides/local-environment>
- <https://app.uniswap.org/whitepaper-v3.pdf>
