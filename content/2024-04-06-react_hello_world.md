+++
title = "React 学习之 Hello World"
date = 2024-04-06T22:21:23+08:00
[taxonomies]
tags = ["React"]
categories = ["React"]
+++

# React 学习之 Hello World

## React 简介

React是一个用于构建用户界面的JavaScript库，由Facebook开发并维护。React通过声明式的方式来构建UI，使得代码更易于理解和测试。React的核心概念包括组件（Component）和虚拟DOM（Virtual DOM）。

组件：在React中，UI被构建为组件的集合。组件是封装了HTML、CSS和JavaScript代码的可重用单元。它们可以是函数或类，接受输入（称为“props”）并返回React元素树，这些元素树描述了用户界面在某一时刻的外观。

虚拟DOM：React使用虚拟DOM来提高性能。当组件的状态或属性发生变化时，React会创建一个新的虚拟DOM树，并将其与之前的树进行比较。然后，React计算出差异并仅将这些差异应用到实际的DOM中，从而实现高效的UI更新。

React的生态系统非常丰富，包括React Native（用于构建原生移动应用的框架）、Redux（用于管理应用状态的库）以及许多其他工具和库。这使得React成为构建复杂Web和移动应用的强大工具。

React的优点包括：

组件化：通过将UI拆分为独立的、可重用的组件，可以提高代码的可维护性和可测试性。
声明式：React使用声明式语法来描述UI，这使得代码更易于阅读和理解。
高效性能：虚拟DOM和React的更新策略使得应用能够高效地响应状态变化。
灵活性：React可以与多种其他库和工具配合使用，以满足不同项目的需求。
然而，React也有其局限性，例如学习曲线较陡峭，需要一定的JavaScript基础才能有效使用。此外，对于大型项目，可能需要额外的工具和库来管理状态和路由等复杂问题。

总之，React是一个强大的JavaScript库，适用于构建各种规模和复杂度的Web和移动应用。通过掌握React的核心概念和生态系统中的工具，开发者可以创建出高效、可维护且用户友好的界面。

## React的核心概念是什么

React的核心概念主要包括以下几个方面：

1. 组件（Components）：
   - React中构建用户界面的基本单位是组件。组件可以看作是一个独立的、可复用的代码块，它接受输入（通常是以“props”形式传递的数据）并返回React元素树，这些元素树描述了用户界面的一部分。
   - 组件可以是函数组件或类组件。函数组件接受props并返回JSX元素；类组件则继承自React.Component类，具有更多的生命周期方法和状态管理功能。
2. JSX（JavaScript XML）：
   - JSX是React中用于描述用户界面的一种语法扩展。它允许我们在JavaScript代码中编写类似HTML的结构，并在编译时转换成React元素。JSX使得组件的代码更加直观和易于理解。
3. 虚拟DOM（Virtual DOM）：
   - React使用虚拟DOM来提高应用的性能。当组件的状态或属性发生变化时，React会创建一个新的虚拟DOM树，并与之前的虚拟DOM树进行比较。通过比较这两个树，React能够计算出最小的DOM操作来更新实际的DOM，从而实现高效的UI更新。
4. 状态（State）和属性（Props）：
   - 状态是组件内部的数据，它决定了组件的渲染输出。状态是私有的，并且只能通过组件内部的方法（如setState）来更新。
   - 属性是父组件传递给子组件的数据。子组件通过props接收这些数据，并使用它们来渲染输出。属性是只读的，子组件不能修改它们。
5. 生命周期方法（Lifecycle Methods）：
   - 类组件具有一系列的生命周期方法，这些方法在组件的不同阶段（如挂载、更新、卸载）被调用。生命周期方法允许开发者在组件的不同阶段执行特定的逻辑，如数据获取、副作用处理等。
6. 钩子（Hooks）：
   - Hooks是React 16.8版本中引入的新特性，它们允许开发者在不编写类的情况下使用state以及其他的React特性。通过使用钩子，函数组件可以拥有与类组件相同的功能，同时保持代码的简洁和可维护性。
  
这些核心概念共同构成了React的基础，使得开发者能够高效地构建出复杂且响应式的用户界面。通过掌握这些概念，开发者可以充分利用React的优势来创建出高质量的Web应用。

## React 示例

```html
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello World</title>

    <!-- 引入React 的核心库 -->
    <script src="script/react.development.js"></script>
    <!-- 引入React 的DOM库 -->
    <script src="script/react-dom.development.js"></script>
</head>

<body>
    <div id="root"></div>
    <script>
        /*
        https://unpkg.com/react@18.2.0/umd/react.development.js
        https://unpkg.com/react-dom@18.2.0/umd/react-dom.development.js
        */
        // React 就是用来代替DOM的

        // // 通过DOM向页面中添加一个div
        // // 创建一个div
        // const div = document.createElement('div'); // 创建一个DOM元素
        // // 向div中添加内容
        // div.innerText = '我是一个div';
        // // 获取页面中的root节点
        // const root = document.getElementById('root');
        // // 将div添加到root节点中
        // root.appendChild(div);

        // 通过React向页面中添加一个div
        /*
        
        React.createElement()
            - 用来创建一个React元素
            - 参数1：表示创建元素的类型，比如div、p、span等 元素名(组件名)
            - 参数2：表示创建元素的属性，比如className、id等 元素中的属性
            - 参数3：表示创建元素的文本内容 元素的子元素（内容）
            - 返回值：表示创建的React元素
        */
        const div = React.createElement('div', {}, '我是React创建的div'); // 创建一个 React 元素
        // 获取页面中的root节点
        const root = document.getElementById('root');
        // 获取根元素对应的React元素
        // ReactDOM.createRoot()
        // - 用来创建一个React根元素
        // - createRoot 允许在浏览器的 DOM 节点中创建根节点以显示 React 组件。
        // - 参数1：表示创建的根元素对应的DOM元素
        // - createRoot 返回一个带有两个方法的的对象，这两个方法是：render 和 unmount。
        // https://zh-hans.react.dev/reference/react-dom/client/createRoot
        const react_root = ReactDOM.createRoot(root);
        // 将div渲染到根元素中
        // root.render(reactNode) 
        // 调用 root.render 以将一段 JSX（“React 节点”）在 React 的根节点中渲染为 DOM 节点并显示。
        // https://zh-hans.react.dev/reference/react-dom/client/createRoot#root-render
        react_root.render(div);

    </script>
</body>

</html>

```

## 参考

- [React 官网](https://react.dev/)
- [React 中文网](https://react.docschina.org/)
- [React 中文文档](https://zh-hans.react.dev/)
