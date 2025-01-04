+++
title = "bluebell 项目之前端项目搭建"
date = 2023-06-25T14:17:33+08:00
description = "bluebell 项目之前端项目搭建"
[taxonomies]
tags = ["Go", "项目"]
categories = ["Go", "项目"]
+++

# 10 bluebell 项目之前端项目搭建

## 前端项目搭建

[Vite 官方中文文档](https://cn.vitejs.dev/guide/)：<https://cn.vitejs.dev/guide/>

### 搭建 Vite 项目

```bash
~/Code/go via 🐹 v1.20.3 via 🅒 base
➜ mcd bluebell_project

Code/go/bluebell_project via 🐹 v1.20.3 via 🅒 base
➜

Code/go/bluebell_project via 🐹 v1.20.3 via 🅒 base
➜ pnpm create vite
.../Library/pnpm/store/v3/tmp/dlx-23890  | Progress: resolved 1, reused 0, downl.../Library/pnpm/store/v3/tmp/dlx-23890  |   +1 +
.../Library/pnpm/store/v3/tmp/dlx-23890  | Progress: resolved 1, reused 0, downl.../Library/pnpm/store/v3/tmp/dlx-23890  | Progress: resolved 1, reused 0, downlPackages are hard linked from the content-addressable store to the virtual store.
  Content-addressable store is at: /Users/qiaopengjun/Library/pnpm/store/v3
  Virtual store is at:             ../../../Library/pnpm/store/v3/tmp/dlx-23890/node_modules/.pnpm
.../Library/pnpm/store/v3/tmp/dlx-23890  | Progress: resolved 1, reused 0, downl.../Library/pnpm/store/v3/tmp/dlx-23890  | Progress: resolved 1, reused 0, downloaded 1, added 1, done
✔ Project name: … bluebell_frontend
✔ Select a framework: › Vue
✔ Select a variant: › TypeScript

Scaffolding project in /Users/qiaopengjun/Code/go/bluebell_project/bluebell_frontend...

Done. Now run:

  cd bluebell_frontend
  pnpm install
  pnpm run dev


Code/go/bluebell_project via 🐹 v1.20.3 via 🅒 base took 1m 51.8s
➜
```

### 运行项目

```bash
Code/go/bluebell_project via 🐹 v1.20.3 via 🅒 base took 1m 51.8s
➜ cd bluebell_frontend

go/bluebell_project/bluebell_frontend via ⬢ v19.7.0 via 🐹 v1.20.3 via 🅒 base
➜ pnpm install

   ╭─────────────────────────────────────────────────────────────────╮
   │                                                                 │
   │                Update available! 8.3.1 → 8.6.3.                 │
   │   Changelog: https://github.com/pnpm/pnpm/releases/tag/v8.6.3   │
   │                Run "pnpm add -g pnpm" to update.                │
   │                                                                 │
   │     Follow @pnpmjs for updates: https://twitter.com/pnpmjs      │
   │                                                                 │
   ╰─────────────────────────────────────────────────────────────────╯

Downloading registry.npmjs.org/typescript/5.0.2: 7.05 MB/7.05 MB, done
 WARN  deprecated sourcemap-codec@1.4.8: Please use @jridgewell/sourcemap-codec instead
Packages: +57
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Packages are copied from the content-addressable store to the virtual store.
  Content-addressable store is at: /Users/qiaopengjun/Library/pnpm/store/v3
  Virtual store is at:             node_modules/.pnpm
node_modules/.pnpm/esbuild@0.17.19/node_modules/esbuild: Running postinstall scrnode_modules/.pnpm/esbuild@0.17.19/node_modules/esbuild: Running postinstall script, done in 305ms 78, reused 36, downloaded 21, added 57, done

dependencies:
+ vue 3.2.47 (3.3.4 is available)

devDependencies:
+ @vitejs/plugin-vue 4.1.0 (4.2.3 is available)
+ typescript 5.0.2 (5.1.3 is available)
+ vite 4.3.9
+ vue-tsc 1.4.2 (1.8.1 is available)

Done in 8.8s

go/bluebell_project/bluebell_frontend via ⬢ v19.7.0 via 🐹 v1.20.3 via 🅒 base took 8.9s
➜  pnpm run dev

> bluebell_frontend@0.0.0 dev /Users/qiaopengjun/Code/go/bluebell_project/bluebell_frontend
> vite


  VITE v4.3.9  ready in 420 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h to show help
 ELIFECYCLE  Command failed with exit code 1.

go/bluebell_project/bluebell_frontend via ⬢ v19.7.0 via 🐹 v1.20.3 via 🅒 base took 6m 25.1s
➜

```

![](https://raw.githubusercontent.com/qiaopengjun5162/blogpicgo/master/img202306251438845.png)
