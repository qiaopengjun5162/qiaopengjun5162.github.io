+++
title = "NFT 开发核心步骤：本地 IPFS 节点搭建与元数据上传实战"
description = "NFT 开发核心步骤：本地 IPFS 节点搭建与元数据上传实战"
date = 2025-07-24T00:35:51Z
[taxonomies]
categories = ["Web3", "IPFS", "NFT"]
tags = ["Web3", "IPFS", "NFT"]
+++

<!-- more -->

# NFT 开发核心步骤：本地 IPFS 节点搭建与元数据上传实战

在 Web3 开发中，“将元数据上传到 IPFS”是确保 NFT 资产去中心化的行业共识。然而，许多教程对此一笔带过，让开发者在面对环境配置、节点操作和脚本自动化时困难重重。从 `ipfs init` 与 `daemon` 的区别，到实现图片和 JSON 的链式上传，每个环节都可能成为项目的瓶颈。

本文旨在终结这种困惑。我们将以一篇“生产级”的实操指南，手把手带你走完在 macOS 上从零搭建本地 IPFS 节点，并使用 TypeScript 脚本自动化处理 NFT 元数据的完整流程。无论你是初涉此领域的开发者，还是希望规范化开发流程的资深工程师，都能在这里找到清晰、可复现的最佳实践。

告别 NFT 元数据上传的困惑！本篇实战指南将带你从零配置本地 IPFS 节点，到用 TypeScript 脚本实现图片与 JSON 的自动化链式上传，为你的 Web3 项目打下坚实基础。

## 实操

### 第一步：安装与配置

**目标**：让您的电脑拥有 `ipfs` 这个命令行工具，并让终端能找到它。

```bash
# 安装
brew install ipfs --cask
brew install --formula ipfs
# 修改 ~/.zshrc (让终端知道路径)
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
brew install ipfs
# brew link ipfs (创建“快捷方式”)
brew link ipfs
```

### 第二步：初始化节点

**目标**：在您的电脑上创建一个 IPFS 仓库（`.ipfs` 文件夹），生成您节点的唯一身份密钥和配置文件。这是**一次性**的操作。

```bash
ipfs init
generating ED25519 keypair...done
peer identity: 12D3KooWPvJRR6eakpAo4Kjb8jdPWJPhNpkV4ujTFfn4uxxPsgF2
initializing IPFS node at /Users/qiaopengjun/.ipfs
```

`ipfs init` 和 `ipfs daemon` 是 IPFS (InterPlanetary File System) 中两个不同的命令，它们的功能和用途有显著区别：

#### 1. `ipfs init`

- **作用**：初始化一个新的 IPFS 节点（即本地仓库）。

- 功能：

  - 在用户的主目录（默认是 `~/.ipfs`）创建一个新的 IPFS 配置文件。
  - 生成一对加密密钥（用于节点身份验证）。
  - 创建默认的 IPFS 数据存储结构。

- 使用场景：

  - 首次安装 IPFS 后，需要运行此命令来设置本地节点。
  - 只需运行一次（除非删除配置后重新初始化）。

- 示例：

  ```bash
  ipfs init
  ```

#### 2. `ipfs daemon`

- **作用**：启动 IPFS 守护进程（后台服务）。

- 功能：

  - 启动一个长期运行的进程，使本地节点加入 IPFS 网络。
  - 启用以下功能：
    - 与其他节点通信（发现和连接对等节点）。
    - 提供本地 API 和网关服务（默认端口：`5001` 和 `8080`）。
    - 支持文件上传、下载和网络共享。
  - 持续运行直到手动终止（按 `Ctrl+C` 或关闭终端）。

- 使用场景：

  - 需要与 IPFS 网络交互时（如上传/下载文件）。
  - 每次重启后或需要重新连接网络时运行。

- 示例：

  ```bash
  ipfs daemon
  ```

#### 关键区别

| 命令          | 目的                     | 运行频率       | 结果                          |
| ------------- | ------------------------ | -------------- | ----------------------------- |
| `ipfs init`   | 初始化本地节点配置       | 仅一次         | 创建 `~/.ipfs` 目录和配置文件 |
| `ipfs daemon` | 启动节点并加入 IPFS 网络 | 每次需要使用时 | 激活网络连接和 API 服务       |

#### 补充说明

- 必须先运行 `ipfs init` 才能使用 `ipfs daemon`（否则会报错找不到配置）。
- 如果 `ipfs daemon` 未运行，许多 IPFS 命令（如 `ipfs add` 或 `ipfs cat`）将无法正常工作。
- 可以通过 `ipfs config` 命令修改初始化后的配置（如更改存储路径或端口）。

### 第三步：实现上传 IPFS 脚本

```ts
import { create } from "kubo-rpc-client";
import * as fs from "fs";
import { Buffer } from "buffer";
import * as path from "path";
import { fileURLToPath } from "url"; // ✅ 导入 url 模块的辅助函数

// ✅ 定义更详细的元数据接口，以匹配您的示例
interface Attribute {
  trait_type: string;
  value: string | number;
  display_type?: "number";
}

interface NftMetadata {
  name: string;
  description: string;
  image: string; // 将会是 ipfs://<Image_CID>
  external_url?: string;
  attributes: Attribute[];
}

// --- 配置 ---
const ipfs = create({ url: "http://localhost:5001/api/v0" });

// ✅ 新增：在 ESM 模块中获取当前目录路径的正确方法
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * 上传一个本地文件到 IPFS。
 * @param filePath 文件的本地路径
 * @returns 上传结果或 undefined
 */
export async function uploadFileToIPFS(filePath: string) {
  try {
    console.log(`\n--- 正在上传文件: ${filePath} ---`);
    const file: Buffer = fs.readFileSync(filePath);

    const result = await ipfs.add({
      path: path.basename(filePath), // 只使用文件名
      content: file,
    });

    console.log("✅ 文件上传成功!");
    console.log(`   - 文件名: ${result.path}`);
    console.log(`   - CID: ${result.cid.toString()}`);
    console.log(`   - 大小: ${result.size} 字节`);
    return result;
  } catch (err) {
    console.error("❌ 上传文件失败:", err);
  }
}

/**
 * 将一个 JSON 对象上传到 IPFS。
 * @param json 要上传的 JSON 对象
 * @returns 上传结果或 undefined
 */
export async function uploadJSONToIPFS(json: NftMetadata) {
  try {
    console.log("\n--- 正在上传 JSON 对象 ---");
    const result = await ipfs.add(JSON.stringify(json));

    console.log("✅ JSON 元数据上传成功!");
    console.log(`   - CID: ${result.cid.toString()}`);
    console.log(`   - 大小: ${result.size} 字节`);
    return result;
  } catch (err) {
    console.error("❌ 上传 JSON 失败:", err);
  }
}

// 主执行函数
async function main() {
  try {
    // 检查 IPFS 节点连接
    const version = await ipfs.version();
    console.log(`✅ 成功连接到 IPFS 节点 (版本: ${version.version})`);

    // --- 步骤 1: 上传图片文件 ---
    // ✅ 修复：使用新的 __dirname 变量来构建正确的路径
    const imagePath = path.join(
      __dirname,
      "..",
      "..",
      "assets",
      "image",
      "IMG_20210626_180340.jpg"
    );

    if (!fs.existsSync(imagePath)) {
      console.error(`❌ 图片文件未找到: ${imagePath}`);
      return;
    }

    const imageUploadResult = await uploadFileToIPFS(imagePath);
    if (!imageUploadResult) {
      console.error("图片上传失败，脚本终止。");
      return;
    }
    const imageCid = imageUploadResult.cid.toString();
    console.log(`\n🖼️ 图片 CID 已获取: ${imageCid}`);

    // --- 步骤 2: 构建并上传元数据 JSON ---
    console.log("\n--- 正在构建元数据 JSON ---");

    // ✅ 使用获取到的图片 CID 构建元数据
    // 注意：在链上元数据中，标准做法是使用 "ipfs://" 协议前缀
    const metadata: NftMetadata = {
      name: "MyERC721Token",
      description: "这是一个使用 TypeScript 脚本动态生成的元数据。",
      image: `ipfs://${imageCid}`, // <-- 关键步骤！
      external_url: "https://testnets.opensea.io/zh-CN/account/collected",
      attributes: [
        { trait_type: "Background", value: "Blue" },
        { trait_type: "Eyes", value: "Green" },
        { trait_type: "Mouth", value: "Smile" },
        { trait_type: "Clothing", value: "T-shirt" },
        { trait_type: "Accessories", value: "Hat" },
        { display_type: "number", trait_type: "Generation", value: 1 },
      ],
    };

    const metadataUploadResult = await uploadJSONToIPFS(metadata);
    if (!metadataUploadResult) {
      console.error("元数据上传失败，脚本终止。");
      return;
    }
    const metadataCid = metadataUploadResult.cid.toString();
    console.log(`\n📄 元数据 CID 已获取: ${metadataCid}`);

    console.log("\n--- ✨ 流程完成 ✨ ---");
    console.log(
      `下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://${metadataCid}`
    );
  } catch (error) {
    console.error(`\n❌ 脚本执行过程中发生错误:`, error);
    console.error("\n--- 故障排查 ---");
    console.error("1. 请确保你的 IPFS 节点正在运行 (命令: ipfs daemon)。");
    console.error("2. 检查文件路径是否正确，以及脚本是否有读取权限。");
  }
}

main();

/*
YuanqiGenesis/polyglot-ipfs-uploader/typescript is 📦 1.0.0 via ⬢ v23.11.0 via 🍞 v1.2.17 on 🐳 v28.2.2 (orbstack) 
➜ bun start
$ ts-node src/index.ts
(node:52662) ExperimentalWarning: Type Stripping is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
✅ 成功连接到 IPFS 节点 (版本: 0.36.0)

--- 正在上传文件: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/assets/image/IMG_20210626_180340.jpg ---
✅ 文件上传成功!
   - 文件名: IMG_20210626_180340.jpg
   - CID: QmXgwL18mcPFTJvbLmGXet4rpGwU9oNH9bDRGYuV1vNtQs
   - 大小: 4051551 字节

🖼️ 图片 CID 已获取: QmXgwL18mcPFTJvbLmGXet4rpGwU9oNH9bDRGYuV1vNtQs

--- 正在构建元数据 JSON ---

--- 正在上传 JSON 对象 ---
✅ JSON 元数据上传成功!
   - CID: QmVHfPYQVnoaUa1Z6MuEy4rmUfWadR6yAkU44fe18ztrL1
   - 大小: 532 字节

📄 元数据 CID 已获取: QmVHfPYQVnoaUa1Z6MuEy4rmUfWadR6yAkU44fe18ztrL1

--- ✨ 流程完成 ✨ ---
下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://QmVHfPYQVnoaUa1Z6MuEy4rmUfWadR6yAkU44fe18ztrL1

Mint ERC721 Token
https://hoodi.etherscan.io/tx/0x51424695af291d3a3b7fc54b1a5b1308ea39a94f564e16de3bafe3bff565423a
https://hoodi.etherscan.io/tx/0x0b0771edee0cc9f702433ef8f6b044d6aa6740ad91961cf745ccf7b235426e3c
*/

```

### 第四步：启动节点并交互

**目标**：将您的节点上线，让它连接到全球 IPFS 网络，并准备好接收来自您代码的上传指令。

**启动节点**：在一个**独立的终端窗口**中运行 `ipfs daemon`，并让它一直开着。

```bash
ipfs daemon
Initializing daemon...
Kubo version: 0.36.0-Homebrew
Repo version: 16
System version: arm64/darwin
Golang version: go1.24.5
PeerID: 12D3KooWPvJRR6eakpAo4Kjb8jdPWJPhNpkV4ujTFfn4uxxPsgF2
Swarm listening on 10.1.91.117:4001 (TCP+UDP)
Swarm listening on 127.0.0.1:4001 (TCP+UDP)
Swarm listening on 192.168.194.0:4001 (TCP+UDP)
Swarm listening on 192.168.97.0:4001 (TCP+UDP)
Swarm listening on 198.19.249.3:4001 (TCP+UDP)
Swarm listening on [::1]:4001 (TCP+UDP)
Swarm listening on [fd07:b51a:cc66:0:a617:db5e:ab7:e9f1]:4001 (TCP+UDP)
Swarm listening on [fd07:b51a:cc66:a:ffff:ffff:ffff:fffe]:4001 (TCP+UDP)
Run 'ipfs id' to inspect announced and discovered multiaddrs of this node.
RPC API server listening on /ip4/127.0.0.1/tcp/5001
WebUI: http://127.0.0.1:5001/webui
Gateway server listening on /ip4/127.0.0.1/tcp/8080
Daemon is ready
```

![image-20250723164955561](/images/image-20250723164955561.png)

**运行上传脚本**：在**另一个终端窗口**中，进入您的 `polyglot-ipfs-uploader` 项目，运行您选择的任何一种语言的脚本（如 `npx ts-node src/index.ts`）。

```bash
YuanqiGenesis/polyglot-ipfs-uploader/typescript is 📦 1.0.0 via ⬢ v23.11.0 via 🍞 v1.2.17 on 🐳 v28.2.2 (orbstack) 
➜ bun start
$ ts-node src/index.ts
(node:52662) ExperimentalWarning: Type Stripping is an experimental feature and might change at any time
(Use `node --trace-warnings ...` to show where the warning was created)
✅ 成功连接到 IPFS 节点 (版本: 0.36.0)

--- 正在上传文件: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/assets/image/IMG_20210626_180340.jpg ---
✅ 文件上传成功!
   - 文件名: IMG_20210626_180340.jpg
   - CID: QmXgwL18mcPFTJvbLmGXet4rpGwU9oNH9bDRGYuV1vNtQs
   - 大小: 4051551 字节

🖼️ 图片 CID 已获取: QmXgwL18mcPFTJvbLmGXet4rpGwU9oNH9bDRGYuV1vNtQs

--- 正在构建元数据 JSON ---

--- 正在上传 JSON 对象 ---
✅ JSON 元数据上传成功!
   - CID: QmVHfPYQVnoaUa1Z6MuEy4rmUfWadR6yAkU44fe18ztrL1
   - 大小: 532 字节

📄 元数据 CID 已获取: QmVHfPYQVnoaUa1Z6MuEy4rmUfWadR6yAkU44fe18ztrL1

--- ✨ 流程完成 ✨ ---
下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://QmVHfPYQVnoaUa1Z6MuEy4rmUfWadR6yAkU44fe18ztrL1
```

完全成功了！** 您的脚本完美地执行了所有预定任务。

祝贺您！这标志着您已经完成了 NFT 上链前最关键的准备工作。

我们来解读一下您的成功日志：

1. `✅ 成功连接到 IPFS 节点 (版本: 0.36.0)`
   - 您的脚本成功地与本地运行的 IPFS 节点建立了通信。
2. `✅ 文件上传成功!`
   - 您的图片 `IMG_20210626_180340.jpg` 被成功上传到了 IPFS 网络。
   - `🖼️ 图片 CID 已获取: QmXgw...NtQs`
   - IPFS 为您的图片分配了一个唯一的地址（CID）。
3. `✅ JSON 元数据上传成功!`
   - 脚本使用上一步获得的图片 CID，构建了完整的 `metadata.json` 内容，并成功将其上传。
   - `📄 元数据 CID 已获取: QmVHf...trL1`
   - IPFS 为您的元数据文件也分配了一个唯一的地址。
4. `--- ✨ 流程完成 ✨ ---`
   - **`下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://QmVHfPYQVnoaUa1Z6MuEy4rmUfWadR6yAkU44fe18ztrL1`**
   - **这正是您最终需要的成果！** 这个 URI 就是您在调用智能合约的 `mint` 函数时，需要传入的 `uri` 参数。

## 总结

通过本文的实战演练，我们不仅成功搭建并运行了一个本地 IPFS 节点，更重要的是，我们掌握了 NFT 元数据准备的**核心工作流**：先上传媒体文件获得其 CID，再利用此 CID 构建元数据 JSON，最后上传该 JSON 获得最终的 Token URI。

我们提供的 TypeScript 脚本将这一关键流程自动化，确保了元数据链接的正确性。从最终的成功日志可以看到，我们已拥有铸造一个真正去中心化 NFT 所需的一切。

**但这并非终点。** 本地节点是开发与测试的利器，但生产环境中的 NFT 资产需要 7x24 小时的稳定在线。因此，项目的下一步是将这些 CID **“钉”（Pin）**在专业的 **Pinning 服务**上，这才是确保 NFT 永久可用的终极方案，我们将在未来的文章中深入探讨。

## 参考

- <https://formulae.brew.sh/formula/ipfs>
- <https://docs.ipfs.tech/how-to/command-line-quick-start/#initialize-the-repository>
- <https://docs.ipfs.tech/install/ipfs-desktop/#ubuntu>
- <https://github.com/qiaopengjun5162/nft-market-backend>
- <https://docs.opensea.io/docs/metadata-standards>
- <https://app.pinata.cloud/ipfs/files>
- <https://github.com/qiaopengjun5162/nft-market-backend>
