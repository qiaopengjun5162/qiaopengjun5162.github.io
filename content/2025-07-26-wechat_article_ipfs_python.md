+++
title = "Python x IPFS：构建生产级的 NFT 元数据自动化流程"
description = "还在手动处理 NFT 元数据？本篇指南提供一份强大的 Python 脚本，助你一键完成图片和 JSON 的 IPFS 上传、CID 获取和本地归档，支持单件与批量模式，极大提升你的 Web3 开发效率。"
date = 2025-07-26T01:39:36Z
[taxonomies]
categories = ["Web3", "IPFS", "Python"]
tags = ["Web3", "IPFS", "Python", "NFT"]
+++

<!-- more -->

# Python x IPFS：构建生产级的 NFT 元数据自动化流程

在 NFT 项目的生命周期中，元数据的准备是一个繁琐但至关重要的环节。手动上传数千张图片、逐一生成并更新 JSON 文件不仅效率低下，还极易出错。作为 Web3 开发的“瑞士军刀”，Python 凭借其强大的脚本能力和丰富的数据处理库，成为了自动化这一流程的理想选择。

本文将跳过理论，直入主题。我们将提供并逐行解析一份生产级的 Python 脚本，它能无缝衔接您本地的 IPFS 节点，并同时支持“单件艺术品”和“大型 PFP 集合”两种主流的元数据处理工作流。读完本文，您将拥有一个可以一键执行、自动完成图片上传、CID 获取、元数据生成与打包的强大工具。

## 实操

### 安装 IPFS

```bash
# 安装 IPFS Desktop (可选, 提供图形界面)
brew install ipfs --cask

# 安装 IPFS 命令行工具 (Kubo)
brew install --formula ipfs

# 创建“快捷方式”，确保命令行可用
brew link ipfs

# 修改终端配置 (让终端知道路径)
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

```

### 初始化节点

```bash
ipfs init
```

### 启动节点并加入 IPFS 网络

```bash
ipfs daemon
```

### 实现上传 IPFS 脚本

```python
# main.py

import json
import subprocess
import shlex
import shutil
from pathlib import Path
from datetime import datetime
from typing import Any

# --- 配置 ---
# (此脚本不再需要 API 地址，因为它直接与命令行工具交互)

################################################################
# 核心上传函数 (使用 subprocess)
################################################################


def upload_to_ipfs(target_path: Path) -> str | None:
    """
    上传一个文件或整个文件夹到 IPFS CLI。
    """
    if not target_path.exists():
        print(f"❌ 路径不存在: {target_path}")
        return None

    safe_path = shlex.quote(str(target_path))
    command = f"ipfs add -r -Q --cid-version 1 {safe_path}"

    try:
        print(f"\n--- 正在执行上传命令: {command} ---")
        result = subprocess.run(
            command, shell=True, check=True, capture_output=True, text=True
        )
        cid = result.stdout.strip()
        print("✅ 上传成功!")
        print(f"   - 名称: {target_path.name}")
        print(f"   - CID: {cid}")
        return cid
    except subprocess.CalledProcessError as e:
        print(f"❌ 上传失败 (命令返回非零退出码): {e}")
        print(f"   - 错误信息: {e.stderr.strip()}")
        return None
    except Exception as e:
        print(f"❌ 执行上传命令时发生未知错误: {e}")
        return None


def upload_json_str_to_ipfs(
    data: dict[str, Any],
) -> str | None:  # ✅ 优化：为 data 参数添加了更精确的类型注解
    """
    将一个 Python 字典 (JSON 对象) 作为字符串直接上传到 IPFS。
    """
    try:
        print("\n--- 正在上传 JSON 对象 ---")
        json_string = json.dumps(data)
        command = "ipfs add -Q --cid-version 1"
        result = subprocess.run(
            command,
            shell=True,
            check=True,
            input=json_string,
            capture_output=True,
            text=True,
        )
        cid = result.stdout.strip()
        print("✅ JSON 元数据上传成功!")
        print(f"   - CID: {cid}")
        return cid
    except subprocess.CalledProcessError as e:
        print(f"❌ 上传 JSON 失败: {e}")
        print(f"   - 错误信息: {e.stderr.strip()}")
        return None
    except Exception as e:
        print(f"❌ 执行 JSON 上传时发生未知错误: {e}")
        return None


################################################################
# 工作流一：处理单个 NFT
################################################################


def process_single_nft(image_path: Path):
    """
    处理单个 NFT 的流程，并在本地创建一个包含图片和元数据的独立文件夹。
    """
    print("\n==============================================")
    print("🚀 开始处理单个 NFT...")
    print("==============================================")

    image_cid = upload_to_ipfs(image_path)
    if not image_cid:
        return

    print(f"\n🖼️  图片 CID 已获取: {image_cid}")

    metadata = {
        "name": image_path.stem,
        "description": f"这是一个为图片 {image_path.name} 动态生成的元数据。",
        "image": f"ipfs://{image_cid}",
        "attributes": [{"trait_type": "类型", "value": "单件艺术品"}],
    }

    metadata_cid = upload_json_str_to_ipfs(metadata)
    if not metadata_cid:
        return

    # ✅ 创建独立的输出文件夹，并将图片和 JSON 都保存在里面
    output_dir = Path(__file__).parent / "output" / image_path.stem
    output_dir.mkdir(parents=True, exist_ok=True)

    # 复制图片
    _ = shutil.copy(image_path, output_dir / image_path.name)

    # 保存元数据 JSON
    output_file_path = output_dir / f"{image_path.stem}.json"
    with open(output_file_path, "w", encoding="utf-8") as f:
        json.dump(metadata, f, indent=4, ensure_ascii=False)

    print(f"\n💾 图片和元数据已在本地打包保存至: {output_dir}")
    print("\n--- ✨ 单件流程完成 ✨ ---")
    print(f"下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://{metadata_cid}")


################################################################
# 工作流二：处理批量 NFT 集合
################################################################


def process_batch_collection(images_input_dir: Path):
    """
    处理整个 NFT 集合的流程，并在本地创建一个包含 images 和 metadata 两个子文件夹的集合文件夹。
    """
    print("\n==============================================")
    print("🚀 开始处理批量 NFT 集合...")
    print("==============================================")

    images_folder_cid = upload_to_ipfs(images_input_dir)
    if not images_folder_cid:
        return

    print(f"\n🖼️  图片文件夹 CID 已获取: {images_folder_cid}")

    # ✅ 为本次批量处理创建一个带时间戳的唯一父文件夹
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    collection_output_dir = Path(__file__).parent / "output" / f"collection_{timestamp}"
    images_output_dir = collection_output_dir / "images"
    metadata_output_dir = collection_output_dir / "metadata"

    # 复制整个图片文件夹到输出目录
    _ = shutil.copytree(images_input_dir, images_output_dir)
    print(f"\n💾 所有图片已复制到: {images_output_dir}")

    print("\n--- 正在为每张图片生成元数据 JSON 文件 ---")
    metadata_output_dir.mkdir(parents=True, exist_ok=True)

    image_files = sorted(
        [
            f
            for f in images_input_dir.iterdir()
            if f.is_file()
            and f.name.lower().endswith((".png", ".jpg", ".jpeg", ".gif"))
        ]
    )

    for image_file in image_files:
        token_id = image_file.stem
        metadata = {
            "name": f"MetaCore #{token_id}",
            "description": "MetaCore 集合中的一个独特成员。",
            "image": f"ipfs://{images_folder_cid}/{image_file.name}",
            "attributes": [{"trait_type": "ID", "value": int(token_id)}],
        }
        with open(metadata_output_dir / f"{token_id}.json", "w", encoding="utf-8") as f:
            json.dump(metadata, f, indent=4, ensure_ascii=False)

    print(f"✅ 成功生成 {len(image_files)} 个元数据文件到: {metadata_output_dir}")

    metadata_folder_cid = upload_to_ipfs(metadata_output_dir)
    if not metadata_folder_cid:
        return

    print(f"\n📄 元数据文件夹 CID 已获取: {metadata_folder_cid}")
    print("\n--- ✨ 批量流程完成 ✨ ---")
    print(f"下一步，您可以在合约中将 Base URI 设置为: ipfs://{metadata_folder_cid}/")


################################################################
# 主程序入口
################################################################

if __name__ == "__main__":
    current_dir = Path(__file__).parent
    single_image_path = (
        current_dir.parent / "assets" / "image" / "IMG_20210626_180340.jpg"
    )
    batch_images_path = current_dir.parent / "assets" / "batch_images"
    batch_images_path.mkdir(parents=True, exist_ok=True)

    try:
        _ = subprocess.run("ipfs id", shell=True, check=True, capture_output=True)
        print("✅ 成功连接到 IPFS 节点")
    except subprocess.CalledProcessError:
        print("❌ 连接 IPFS 节点失败。")
        print("请确保你的 IPFS 节点正在运行 (命令: ipfs daemon)。")
        exit()

    # --- 在这里选择要运行的工作流 ---

    # 运行工作流一：处理单个 NFT
    # process_single_nft(single_image_path)

    # 运行工作流二：处理批量 NFT 集合
    process_batch_collection(batch_images_path)

    # ✅ 生产环境最终发布流程说明
    print("\n======================================================================")
    print("✅ 本地准备工作已完成！")
    print("下一步是发布到专业的 Pinning 服务 (如 Pinata):")
    print("1. 登录 Pinata。")
    print("2. 上传您本地 `python/output/collection_[时间戳]/images` 文件夹。")
    print("3. 上传您本地 `python/output/collection_[时间戳]/metadata` 文件夹。")
    print("4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。")
    print("======================================================================")


```

这份 `main.py` 脚本的核心目标是自动化处理 NFT 上链前所有与图片和元数据（Metadata）相关的准备工作。它通过调用您本地安装的 IPFS 命令行工具（CLI），实现了两种核心工作流：

1. **单件处理**：为一个独立的艺术品（图片）上传并生成对应的元数据。
2. **批量处理**：为一个完整的 NFT 集合（例如一个包含 10,000 张图片的 PFP 项目）批量上传图片、生成并上传所有元数据。

同时，它还会在本地创建一个结构清晰的 `output` 文件夹，用于归档和方便地上传到专业的 Pinning 服务（如 Pinata）。

### **代码逐段解析**

#### **1. 导入 (Imports)**

```
import json
import subprocess
import shlex
import shutil
from pathlib import Path
from datetime import datetime
from typing import Any
```

- `json`: 用于处理 JSON 数据的创建和转换。
- `subprocess`: **核心模块**，允许 Python 脚本执行外部命令行程序，我们用它来调用 `ipfs` 命令。
- `shlex`: 一个安全工具，用于正确地格式化命令行参数，防止因文件名包含空格或特殊字符而导致命令执行失败。
- `shutil`: 提供了高级的文件操作功能，我们用它来复制文件和文件夹。
- `pathlib.Path`: 一个现代化的、面向对象的路径处理库，让文件路径的操作更简单、更不容易出错。
- `datetime`: 用于生成带时间戳的唯一文件夹名，避免批量处理时覆盖旧的结果。
- `typing.Any`: 用于提供更精确的类型注解。

#### **2. 核心上传函数**

##### `upload_to_ipfs(target_path: Path)`

这个函数是上传文件或文件夹的通用工具。

- 它接收一个 `Path` 对象作为参数。
- 它构建一个 `ipfs add` 命令，其中：
  - `-r` (recursive): 允许递归上传整个文件夹。
  - `-Q` (quiet): 让命令只输出最终的根 CID，而不是每个文件的信息，便于我们捕获结果。
  - `--cid-version 1`: 使用 CIDv1，这是更现代、兼容性更好的 CID 格式。
- 它使用 `subprocess.run` 来执行这个命令，并捕获其标准输出（`stdout`），这个输出就是我们需要的 CID。
- 它还包含了详尽的错误处理，如果 `ipfs` 命令执行失败，它会打印出错误信息。

##### `upload_json_str_to_ipfs(data: dict)`

这个函数专门用于上传由 Python 字典动态生成的 JSON 数据。

- 它接收一个 Python 字典作为参数。
- 它使用 `json.dumps()` 将字典转换为 JSON 格式的字符串。
- 它执行 `ipfs add -Q --cid-version 1` 命令，并通过 `input` 参数将 JSON 字符串直接“喂”给这个命令的标准输入。这是一种非常高效的方式，避免了先在本地创建一个临时 JSON 文件再上传的繁琐步骤。

#### **3. 工作流一：`process_single_nft(image_path: Path)`**

这个函数完整地实现了单个 NFT 的元数据准备流程。

1. **上传图片**：调用 `upload_to_ipfs` 上传指定的单张图片，获取**图片 CID**。
2. **构建元数据**：创建一个 Python 字典，其中 `name` 和 `description` 根据图片的文件名动态生成，最重要的 `image` 字段则被设置为 `ipfs://<刚刚获取的图片CID>`。
3. **上传元数据**：调用 `upload_json_str_to_ipfs` 将这个字典上传，获得最终的**元数据 CID**。
4. **本地归档**：在 `output/` 目录下创建一个以图片名命名的文件夹，并将**原始图片**和生成的**元数据 JSON 文件**都保存在里面，形成一个独立的、完整的“NFT 资产包”。

#### **4. 工作流二：`process_batch_collection(images_input_dir: Path)`**

这个函数实现了 PFP 等大型项目所需的专业批量处理流程。

1. **上传图片文件夹**：调用 `upload_to_ipfs` 上传包含所有图片的**整个文件夹**，获得一个唯一的**图片文件夹 CID**。
2. **创建输出目录**：在 `output/` 目录下创建一个带时间戳的、唯一的集合文件夹（如 `collection_20250726_090500`），以防止覆盖。
3. **复制图片**：为了方便打包和上传到 Pinning 服务，它使用 `shutil.copytree` 将所有原始图片复制到输出目录下的 `images` 子文件夹中。
4. **批量生成元数据**：它遍历输入目录中的所有图片，为每一张图片（如 `1.png`）生成一个对应的 JSON 文件（`1.json`）。在每个 JSON 文件中，`image` 字段都会被正确地设置为 `ipfs://<图片文件夹CID>/1.png`。所有这些 JSON 文件都被保存在输出目录下的 `metadata` 子文件夹中。
5. **上传元数据文件夹**：最后，它调用 `upload_to_ipfs` 上传刚刚创建的**整个 `metadata` 文件夹**，获得最终的**元数据文件夹 CID**。这个 CID 就是您需要在智能合约中设置为 `baseURI` 的最终结果。

#### **5. 主程序入口 (`if __name__ == "__main__":`)**

这是脚本的启动点。

- **路径定义**：它定义了资产文件夹的路径。
- **连接检查**：在执行任何操作之前，它会先运行 `ipfs id` 命令来检查本地的 `ipfs daemon` 是否正在运行，如果连接失败，脚本会提前退出并给出提示。
- **工作流选择**：它允许您通过简单地注释或取消注释 `process_single_nft()` 和 `process_batch_collection()` 这两行代码，来轻松选择您想要运行的工作流。
- **最终指引**：在脚本成功运行后，它会打印出清晰的下一步操作指引，告诉您如何将本地准备好的文件夹上传到 Pinning 服务，以及如何使用最终的 CID。

### 运行上传脚本

```bash
python on  master [?] via 🐍 3.13.5 on 🐳 v28.2.2 (orbstack) via python
➜ python main.py
✅ 成功连接到 IPFS 节点

==============================================
🚀 开始处理单个 NFT...
==============================================

--- 正在执行上传命令: ipfs add -r -Q --cid-version 1 /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/assets/image/IMG_20210626_180340.jpg ---
✅ 上传成功!
   - 名称: IMG_20210626_180340.jpg
   - CID: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

🖼️  图片 CID 已获取: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

--- 正在上传 JSON 对象 ---
✅ JSON 元数据上传成功!
   - CID: bafkreigvggefv56bv6nmmqekyh2hc4iybn5lblinqimajatrvoxbbqcy2e

💾 图片和元数据已在本地打包保存至: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/python/output/IMG_20210626_180340

--- ✨ 单件流程完成 ✨ ---
下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://bafkreigvggefv56bv6nmmqekyh2hc4iybn5lblinqimajatrvoxbbqcy2e

python on  master [?] via 🐍 3.13.5 on 🐳 v28.2.2 (orbstack) via python
➜ python main.py
✅ 成功连接到 IPFS 节点

==============================================
🚀 开始处理批量 NFT 集合...
==============================================

--- 正在执行上传命令: ipfs add -r -Q --cid-version 1 /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/assets/batch_images ---
✅ 上传成功!
   - 名称: batch_images
   - CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e

🖼️  图片文件夹 CID 已获取: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e

💾 所有图片已复制到: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/python/output/collection_20250724_213845/images

--- 正在为每张图片生成元数据 JSON 文件 ---
✅ 成功生成 3 个元数据文件到: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/python/output/collection_20250724_213845/metadata

--- 正在执行上传命令: ipfs add -r -Q --cid-version 1 /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/python/output/collection_20250724_213845/metadata ---
✅ 上传成功!
   - 名称: metadata
   - CID: bafybeiczqa75ljidb7esu464fj6a64nfujxcd2mum73t5yaw2llkrzb4zy

📄 元数据文件夹 CID 已获取: bafybeiczqa75ljidb7esu464fj6a64nfujxcd2mum73t5yaw2llkrzb4zy

--- ✨ 批量流程完成 ✨ ---
下一步，您可以在合约中将 Base URI 设置为: ipfs://bafybeiczqa75ljidb7esu464fj6a64nfujxcd2mum73t5yaw2llkrzb4zy/

```

您的 Python 脚本已成功运行，并完美地执行了两种核心工作流：在“单件处理”模式下，脚本成功地为单个图片上传并生成了唯一的元数据 CID，为您准备好了可以直接用于 `mint` 函数的 Token URI；在“批量处理”模式下，它则完整地模拟了生产级流程，先上传整个图片文件夹获得图片根 CID，然后利用这个 CID 批量生成所有对应的元数据文件，最后再上传整个元数据文件夹，为您提供了可以直接在合约中设置的最终 `baseURI`。总而言之，这个脚本已经成功地将 NFT 上链前所有复杂的元数据准备工作完全自动化了。

## 总结

本文的核心不仅仅是展示了如何将文件上传到 IPFS，更重要的是，我们构建了一个强大而灵活的 Python 自动化工具。这个脚本将 NFT 集合的元数据准备工作从繁琐的手工劳动，转变为一个可重复、可预测的工程化流程。通过支持单件和批量两种模式，并自动在本地生成结构化的归档文件，它为您未来的项目管理和与 Pinning 服务的对接铺平了道路。

当然，本地节点的成功运行只是开发阶段的一步。要让您的 NFT 资产真正做到永久在线、全球可访问，下一步的关键是将脚本生成的 `output` 文件夹上传并“钉”（Pin）在专业的 **Pinning 服务**上。这才是通往生产级 Web3 应用的必经之路。

## 参考

- https://app.pinata.cloud/ipfs/files
- https://github.com/ipfs/ipfs
- https://ipfs.tech/
- https://github.com/ipfs/kubo
