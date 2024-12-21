+++
title = "TypeScript 初识"
description = "TypeScript 初识"
date = 2024-07-26 14:46:00+08:00
[taxonomies]
categories = ["TypeScript"]
tags = ["TypeScript"]
+++

# TypeScript 初识

## 熟悉 TypeScript

<https://www.typescriptlang.org/>

![image-20240727232320362](/images/image-20240727232320362.png)

Typescript 是微软公司在2012年发布的开源项目，是一种最终要编译为 JavaScript 的编程语言。

由 TypeScript 编写的程序首先需要被转编译为 JavaScript，然后才可以在浏览器中或者在独立的 JavaScript 引擎中执行。

转编译和编译的差别：

- 编译是直接将程序的源代码编译为字节码或机器码
- 转编译是首先要将一种语言转换为另一种语言，例如从 TypeScript 转换为 JavaScript。在 TypeScript 社区中，更流行用编译来描述这一过程，因此在后文中，我们将采用编译这个词来描述将 TyepScript 转换为 JavaScript 的过程

### 使用 TypeScript 编程的理由

你也许想知道，为什么要不辞辛劳地先用 TypeScript 编写程序，然后再将其编译为 JavaScript，而不是直接使用 JavaScript 编写程序呢？

要回答这个问题，让我们先从更高级的层面上来看看 TypeScript。

TypeScript 是 JavaScript 的超集，因此你可以任取一个 JavaScript 文件（例如 `mymain.js`），将扩展名从 `.js` 修改为 `.ts`，这样 `mymain.ts` 就可能成为一个合法的 TypeScript 文件。

之所以说”可能“，是因为源 JavaScript 代码可能隐藏着雨类型有关的错误（它可能动态地改变对象属性的类型，或者在声明对象后，增加了新的类型）以及其他问题，但这些问题只有在 JavaScript 代码被编译后才能被发现。

![image-20240726145014536](/images/image-20240726145014536.png)

通常，”超集“这个词，意味着它包含集合拥有的一切，还包含集合没有的一些东西。

TypeScript 作为 ECMAScript 的超集，它是所有版本 JavaScript 的规范定义。

ES.Next 代表 ECMAScript 的最新修订，但目前尚未完成。

除了支持 JavaScript 集外，TypeScript 也支持静态类型，而 JavaScript 仅支持动态类型。

此处的”类型“意指给程序变量分配的类型。

对支持静态类型的编程语言来说，在使用变量前，必须为变量声明一种类型。

对TypeScript类说，可以将变量声明为某种类型，此后，所有试图将与定义类型不同类型的值赋给该变量的尝试都会导致编译错误。

对 JavaScript 来说，情况却并非如此，因为JavaScript 直到运行时才知道程序中变量的类型。

即使在运行时，仍然可以通过给变量分配不同类型的值的方式来改变变量的类型。

对 TypeScript 来说，如果你声明某个变量为字符串类型，在程序中为其分配数字值将会在编译时出现错误。

```typescript
let custonerId: string;
customerId = 123; // 编译错误
```

JavaScript 在运行时才确定变量类型，而且变量的类型可以动态变换，如以下实例所示。

```typescript
let customerId = "A12BN"; // OK，customerId 被定义为字符型
customerId = 123; // OK，从现在开始，customerId 变为数字型
```

接下来考虑一个 JavaScript 函数，该函数提供价格打折计算。

函数包含两个参数，均为数字型。

```typescript
function getFinalPrice(price, discount) {
  return price - price / discount;
}
```

你如何知道参数一定是数字类型的呢？

首先，该程序是你在不久前编写好的，你具有非凡的记忆力，刚好能够记住所有参数类型。

其次，给参数使用描述性名称，这些名称恰好暗示出它们的类型。

最后，通过阅读函数代码猜测处参数的类型。

上述函数虽然非常简单，假设有人调用了该函数，折扣被该调用者以字符类型提供给函数，则函数在运行时将给出 ”NaN“ 错误。

```typescript
console.log(getFinalPrice(100, "10%")); // 控制台屏幕显示 NaN
```

该实例给出了错误使用函数造成运行错误的情况之一。

在TypeScript中，你可以给函数的参数提供类型，因此此类运行错误是不可能发生的。

如果有人在钓鱼函数时，采用错误的参数类型调用函数，这类错误在你定义类型时就会被发现。

定义类型时，如果有错误，在用 TypeScript 编译器编译代码前，TypeScript 静态代码分析器就能发现该错误。

定义变量类型时，编辑器或者 IDE（集成开发环境）将根据特征自动为函数 getFinalPrice() 提供建议的参数名称和类型。

两类编译错误：

- 当你输入时立即就会被工具报告
- 由使用程序的用户报告。采用 TypeScript 编程将会大大减少这类错误出现的次数

#### 注意：请记住，在 TypeScript 中，类型定义是可选的 —— 你可以继续使用 JavaScript 编写程序并且仍然可以在工作流中使用 tsc

因为你将能够使用最新的 ECMAScript 语法（例如 async 和 await）并将你的 JavaScript 代码编译为 ES5。

由此，你的代码就可以在更早期的浏览器上运行。

··你可以在今天的 TypeScript 代码中使用未来的 JavaScript 才能用到的语法，并且可以将其编译成早期的被所有浏览器支持的 JavaScript 语法（例如 ES5）。

思考了解：ECMAScript 规范描述的语法与 TypeScript 特有的语法之间的差异？

查看 TypeScript 路线图

<https://github.com/microsoft/TypeScript/wiki/Roadmap>

![image-20240727232457148](/images/image-20240727232457148.png)

### 关于 TypeScript 的 几个事实

- TypeScript 的核心开发者是 Anders Hejlsberg，他也是 Turbo Pascal 和 Delphi 的设计者、微软 C#的首席架构师
- 2014年年底，Google 与微软接洽，询问微软能否将装饰器引入 TypeScript 中，使该语音能够用于开发 Angular2 框架。微软同意了这一请求，这一决定对 TypeScript 的流行起到了巨大的作用，因为成千上万的开发者使用 Angular。
- 截至2024年7月，npmjs.org 网站的 tsc 每周大约有55,87万次下载，注意这不是唯一的TypeScript下载网站。

<https://www.npmjs.com/package/typescript>

![image-20240727234232092](/images/image-20240727234232092.png)

- 根据软件分析业界著名公司 Redmonk 提供的数据，TypeScript 在2019年1月的编程语言排名中位列第12位。而到在2024年1月的编程语言排名中已经位列第6位了。

#### 2019年1月编程语言排名详情

<https://redmonk.com/sogrady/2019/03/20/language-rankings-1-19/>

![image-20240727233300317](/images/image-20240727233300317.png)

#### 2024年1月编程语言排名详情

<https://redmonk.com/sogrady/2024/03/08/language-rankings-1-24/>

![image-20240727233100553](/images/image-20240727233100553.png)

- 根据 Stack Overflow 公司 2019年开发人员调查结果，TypeScript 在最受欢迎的语言排名中名列第3位。

<https://survey.stackoverflow.co/2019>

![image-20240727235435625](/images/image-20240727235435625.png)

#### 2023年的最受欢迎的语言情况

<https://survey.stackoverflow.co/2023/#section-admired-and-desired-programming-scripting-and-markup-languages>

![image-20240727235946921](/images/image-20240727235946921.png)
