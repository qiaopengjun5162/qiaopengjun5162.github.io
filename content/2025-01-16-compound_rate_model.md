+++
title = "compound_rate_model"
description = ""
date = 2025-01-16 23:06:21+08:00
[taxonomies]
categories = [""]
tags = [""]
+++

<!-- more -->












$$
利息 = 本金 * 利率 \\

本息 = 本金 + 本金 * 利率 = 本金 * (1 + 利率) \\
$$
假设每年的利率不一样，是浮动的，怎么计算？ 复利
$$
最终要还的本息 = 本金 * (1 + R1) * (1 + R2) * (1 + R3) ...
$$
从第五年开始借款到第十年还款，支付的本息
$$
\begin{align}
本息 &= 本金 * (1 + R6) * ... * (1 + R10) \\
\\
&= \frac{(1 + R1) * ... * (1 + R5) * (1 + R6) * ... * (1 + R10)}{(1 + R1) * ... * (1 + R5)}
\end{align}
$$
在每次发生借贷业务时，利率 Ri 会发生变化，把每次的变化都累积记录
$$
\begin{align}
\text{本息} &= \text{本金} \cdot (1 + R6) \cdot \ldots \cdot (1 + R10) \\
&= \frac{(1 + R1) \cdot \ldots \cdot (1 + R5) \cdot (1 + R6) \cdot \ldots \cdot (1 + R10)}{(1 + R1) \cdot \ldots \cdot (1 + R5)}
\end{align}
$$

$$
R0..i = (1 + R1) \cdot \ldots \cdot (1 + R5) \cdot (1 + R6) \cdot \ldots \cdot (1 + R10) \\

R0..5 = (1 + R1) \cdot \ldots \cdot (1 + R5)
$$

故本息：
$$
本息 &= 本金 \cdot  \frac{R0..i}{ R0..5 } \\
&= 本金 * \frac{Ri}{R5}
$$









## 参考

- https://compound.finance/
- https://docs.compound.finance/v2/
- https://medium.com/compound-finance/setting-up-an-ethereum-development-environment-7c387664c5fe
