+++
title= "React 学习之 createElement"
date= 2024-04-07T21:12:11+08:00
[taxonomies]
tags= ["React"]
categories= ["React"]
+++

# React 学习之 createElement

## React 元素

在 React 中，元素是 React 应用的最小构建块。
一个 React 元素是 React 对象的一个轻量级、静态的表示。
它们被 React 用于知道屏幕上什么应该被渲染，并在数据改变时保持 UI 的更新。

React 元素是不可变的：一旦创建，就不能更改它的子元素或属性。
一个元素就像电影的单帧：它代表 UI 在某一时间点的样子。

尽管 React 元素在技术上是一个对象，但它们并不是实际的 DOM 元素。
React 使用这些对象来构建 DOM，并在必要时更新它。
React 元素是 React 的抽象表示，而不是 DOM 的直接表示。

总的来说，React 元素确实可以被视为普通的 JavaScript 对象，但它们在 React 的工作流中扮演着特殊的角色，用于描述 UI 的结构和属性。

### React.createElement

用来创建一个React元素

参数：

- 标签名 元素的名称（HTML标签必须小写）
- 属性 标签中的属性
  - 在设置事件时，属性名需要修改为驼峰命名法 值为一个函数
  - 例如：onClick 需要修改为 onClick
  - Warning: Invalid DOM property `class`. Did you mean `className`? class -> className
- 子元素 标签中的子元素
  - 例如：<div>这是一个div</div> 子元素为"这是一个div"
  - 子元素可以是字符串、数字、React元素、数组、布尔值、null、undefined
- 返回值：一个React元素
- 注意点：
  - React 元素最终会通过虚拟DOM转换为真实的DOM元素
  - React 元素是一个普通的JS对象

React.createElement 是 React 库中的一个函数，用于在 JavaScript 中创建 React 元素。在 JSX 语法被引入之前，React.createElement 是创建 React 组件树的主要方式。尽管现在 JSX 在 React 社区中非常流行，但理解 React.createElement 仍然很重要，因为它实际上是 JSX 在编译时转换为的东西。

React.createElement 函数接受三个参数：

类型 (type)：这通常是一个字符串（表示一个 DOM 元素，如 'div' 或 'span'）或一个 React 组件类（或函数）。
配置对象 (config)：一个可选的对象，包含该元素的 props。
子元素 (children)：可以是任何有效的 React 子元素，可以是一个或多个。
示例：

```javascript
const element = React.createElement(  
  'div',  
  { id: 'myDiv', className: 'myClass' },  
  'Hello, world!',  
  React.createElement('span', null, 'This is a span.')  
);
```

这个示例创建了一个 div 元素，它有一个 ID 和一个类名，以及两个子元素：一个文本节点和一个 span 元素。

当你使用 JSX 时，上述代码可以写为：

```jsx
const element = (  
  <div id="myDiv" className="myClass">  
    Hello, world!  
    <span>This is a span.</span>  
  </div>  
);
```

尽管 JSX 提供了更简洁、更易于理解的语法，但理解 React.createElement 仍然有助于你理解 React 的底层工作原理。

## React createElement 示例

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>React learning</title>
    <script src="script/react.development.js"></script>
    <script src="script/react-dom.development.js"></script>
  </head>

  <body>
    <button id="btn">我是一个按钮</button>
    <div id="root"></div>

    <script>
      /*

        在 React 中，元素是 React 应用的最小构建块。一个 React 元素是 React 对象的一个轻量级、静态的表示。
        它们被 React 用于知道屏幕上什么应该被渲染，并在数据改变时保持 UI 的更新。

        React 元素是不可变的：一旦创建，就不能更改它的子元素或属性。一个元素就像电影的单帧：它代表 UI 在某一时间点的样子。

        尽管 React 元素在技术上是一个对象，但它们并不是实际的 DOM 元素。
        React 使用这些对象来构建 DOM，并在必要时更新它。React 元素是 React 的抽象表示，而不是 DOM 的直接表示。

        总的来说，React 元素确实可以被视为普通的 JavaScript 对象，但它们在 React 的工作流中扮演着特殊的角色，用于描述 UI 的结构和属性。
        
        React.createElement
            - 用来创建一个React元素
            - 参数：
                - 标签名 元素的名称（HTML标签必须小写）
                - 属性 标签中的属性
                    - 在设置事件时，属性名需要修改为驼峰命名法 值为一个函数
                    - 例如：onClick 需要修改为 onClick 
                    - Warning: Invalid DOM property `class`. Did you mean `className`? class属性需要使用 className 设置
                - 子元素 元素的内容（子元素）
            - 返回值：一个React元素
            - 注意点：
                - React 元素最终会通过虚拟DOM转换为真实的DOM元素
                - React 元素是一个普通的JS对象
                - React 元素是不可变的，一旦创建，就不能更改它的子元素或者属性 React 元素一旦创建就无法修改，
                    如果想要修改，只能重新创建新的元素，即只能通过新创建的元素进行替换
        
        */
      // 创建一个React元素
      const button = React.createElement(
        "button",
        {
          id: "btn",
          type: "button",
          className: "hello",
          onClick: () => {
            alert(123);
          },
        },
        "点我一下"
      );

      // 创建一个div
      const div = React.createElement("div", {}, "这是一个div", button);

      // 获取根元素
      const root = ReactDOM.createRoot(document.getElementById("root"));

      // 将React元素渲染到根元素中 将元素在根元素中显示
      root.render(div);

      // 获取按钮对象
      const btn = document.getElementById("btn");
      btn.addEventListener("click", () => {
        // 点击按钮后，修改div中button中的文字为 click me
        const button = React.createElement(
          "button",
          {
            id: "btn",
            type: "button",
            className: "hello",
            onClick: () => {
              alert(123);
            },
          },
          "click me"
        );

        // 创建一个div
        const div = React.createElement("div", {}, "这是一个div", button);

        // 修改React元素后，必须重新渲染React根元素
        // 当调用render渲染页面时，React会自动比较两次渲染的元素，只在真实DOM中更新发生变化的部分，没发生变化的保持不变
        // 这样可以提高页面的性能
        // 重新渲染React根元素
        root.render(div);
      });
    </script>
  </body>
</html>

```

## 参考

- [React 官方中文文档](https://react.docschina.org/)
