+++
title = "Rust x IPFS：从命令行到官方库，精通NFT元数据上传"
description = "Rust x IPFS：从命令行到官方库，精通NFT元数据上传"
date = 2025-08-05T02:59:17Z
[taxonomies]
categories = ["Rust", "IPFS", "NFT"]
tags = ["Rust", "IPFS", "NFT"]
+++

<!-- more -->

# Rust x IPFS：从命令行到官方库，精通NFT元数据上传

继我们先前在《NFT 开发核心步骤：本地 IPFS 节点搭建与元数据上传实战》、《Python x IPFS：构建生产级的 NFT 元数据自动化流程》、《从命令行到官方库：用 Go 语言精通 NFT 元数据 IPFS 上传》中分别使用 TypeScript、Python 和 Go 成功实现元数据自动化上传后，本系列文章将迎来新的篇章——使用性能卓越且安全可靠的 Rust 语言来完成这一核心任务。本文将深入探讨两种截然不同的实现路径：一种是直接通过调用 `ipfs` 命令行工具的快捷方式，另一种是采用官方 `ipfs-api-backend-hyper` 库进行原生集成的专业方式。我们将通过详细的实战代码，分别处理单个 NFT 和批量 NFT 集合这两种关键场景，最终呈现一个经过精心重构和优化的生产级解决方案。

本实战教程演示了如何用 Rust 将 NFT 元数据高效上传至 IPFS。文章核心在于对比了两种实现路径：直接调用 IPFS 命令行，以及通过官方 ipfs-api-backend-hyper 库进行原生集成。教程完整覆盖了单个及批量 NFT 的处理工作流，并通过代码重构，最终提供了一个模块化、适用于生产环境的 Web3 开发方案。

## 实操

IPFS 的两种不同使用场景：

- 对于单个 NFT，链接直接指向文件内容 CID，不带文件名或后缀。
- 对于批量集合中的 NFT，链接指向文件夹 CID 下的具体文件名。

### 查看项目目录

```bash
polyglot-ipfs-uploader/rust on  main is 📦 0.1.0 via 🦀 1.88.0 on 🐳 v28.2.2 (orbstack)
➜ tree . -L 6 -I "migrations|mochawesome-report|.anchor|docs|target|node_modules"
.
├── Cargo.lock
├── Cargo.toml
├── examples
│   ├── cli_uploader.rs
│   └── library_uploader.rs
└── src
    ├── lib.rs
    └── main.rs

3 directories, 6 files
```

### `Cargo.toml` 文件

```rust
[package]
name = "rust"
version = "0.1.0"
edition = "2024"

[[example]]
name = "cli_uploader"
path = "examples/cli_uploader.rs"

[[example]]
name = "library_uploader"
path = "examples/library_uploader.rs"


[dependencies]
anyhow = "1.0.98"
chrono = "0.4.41"
futures = "0.3.31"
ipfs-api-backend-hyper = "0.6.0"
serde = { version = "1.0.219", features = ["derive"] }
serde_json = "1.0.141"
tokio = { version = "1.47.0", features = ["full"] }
walkdir = "2.5.0"

```

### `src/main.rs` 文件

```rust
use anyhow::{Result, anyhow};
use chrono::Utc;
use serde::{Deserialize, Serialize};
use std::fs::{self, File};
use std::io::{self, Write};
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use walkdir::WalkDir;

// ✅ 配置开关
const USE_JSON_SUFFIX: bool = false;

// ✅ 定义元数据结构体
#[derive(Serialize, Deserialize)]
struct Attribute {
    trait_type: String,
    value: serde_json::Value,
}

#[derive(Serialize, Deserialize)]
struct NftMetadata {
    name: String,
    description: String,
    image: String,
    attributes: Vec<Attribute>,
}

// 核心上传函数 (使用 std::process::Command)
fn upload_to_ipfs(target_path: &Path) -> Result<String> {
    if !target_path.exists() {
        return Err(anyhow!("❌ 路径不存在: {:?}", target_path));
    }

    let path_str = target_path
        .to_str()
        .ok_or_else(|| anyhow!("无效的文件路径"))?;
    println!(
        "\n--- 正在执行上传命令: ipfs add -r -Q --cid-version 1 {} ---",
        path_str
    );

    let output = Command::new("ipfs")
        .arg("add")
        .arg("-r") // 递归上传
        .arg("-Q") // 只输出根 CID
        .arg("--cid-version")
        .arg("1")
        .arg(path_str)
        .output()?;

    if !output.status.success() {
        return Err(anyhow!(
            "❌ 上传失败: {}",
            String::from_utf8_lossy(&output.stderr)
        ));
    }

    let cid = String::from_utf8(output.stdout)?.trim().to_string();
    println!("✅ 上传成功!");
    println!(
        "   - 名称: {}",
        target_path.file_name().unwrap().to_str().unwrap()
    );
    println!("   - CID: {}", cid);
    Ok(cid)
}

// 上传 JSON 数据的专用函数
fn upload_json_str_to_ipfs(data: &NftMetadata) -> Result<String> {
    println!("\n--- 正在上传 JSON 对象 ---");
    let json_string = serde_json::to_string(data)?;

    let mut child = Command::new("ipfs")
        .arg("add")
        .arg("-Q")
        .arg("--cid-version")
        .arg("1")
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()?;

    // 将 JSON 字符串写入子进程的标准输入
    if let Some(mut stdin) = child.stdin.take() {
        stdin.write_all(json_string.as_bytes())?;
    }

    let output = child.wait_with_output()?;
    if !output.status.success() {
        return Err(anyhow!(
            "❌ 上传 JSON 失败: {}",
            String::from_utf8_lossy(&output.stderr)
        ));
    }

    let cid = String::from_utf8(output.stdout)?.trim().to_string();
    println!("✅ JSON 元数据上传成功!\n   - CID: {}", cid);
    Ok(cid)
}

// 工作流一：处理单个 NFT
fn process_single_nft(image_path: &Path) -> Result<()> {
    println!("\n==============================================");
    println!("🚀 开始处理单个 NFT...");
    println!(
        "   - 文件后缀模式: {}",
        if USE_JSON_SUFFIX { ".json" } else { "无" }
    );
    println!("==============================================");

    let image_cid = upload_to_ipfs(image_path)?;
    println!("\n🖼️  图片 CID 已获取: {}", image_cid);

    let image_filename = image_path
        .file_name()
        .and_then(|s| s.to_str())
        .ok_or_else(|| anyhow!("无效的图片文件名"))?;
    let image_name_without_ext = image_path
        .file_stem()
        .and_then(|s| s.to_str())
        .ok_or_else(|| anyhow!("无效的图片文件名"))?;

    let metadata = NftMetadata {
        name: image_name_without_ext.to_string(),
        description: format!("这是一个为图片 {} 动态生成的元数据。", image_filename),
        image: format!("ipfs://{}", image_cid),
        attributes: vec![Attribute {
            trait_type: "类型".to_string(),
            value: serde_json::Value::String("单件艺术品".to_string()),
        }],
    };

    let metadata_cid = upload_json_str_to_ipfs(&metadata)?;

    let output_dir = PathBuf::from("output").join(image_name_without_ext);
    fs::create_dir_all(&output_dir)?;
    fs::copy(image_path, output_dir.join(image_filename))?;

    let file_name = if USE_JSON_SUFFIX {
        format!("{}.json", image_name_without_ext)
    } else {
        image_name_without_ext.to_string()
    };
    let mut metadata_file = File::create(output_dir.join(file_name))?;
    let pretty_json = serde_json::to_string_pretty(&metadata)?;
    metadata_file.write_all(pretty_json.as_bytes())?;

    println!("\n💾 图片和元数据已在本地打包保存至: {:?}", output_dir);
    println!("\n--- ✨ 单件流程完成 ✨ ---");
    println!(
        "下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://{}",
        metadata_cid
    );
    Ok(())
}

// 工作流二：处理批量 NFT 集合
fn process_batch_collection(images_input_dir: &Path) -> Result<()> {
    println!("\n==============================================");
    println!("🚀 开始处理批量 NFT 集合...");
    println!(
        "   - 文件后缀模式: {}",
        if USE_JSON_SUFFIX { ".json" } else { "无" }
    );
    println!("==============================================");

    let images_folder_cid = upload_to_ipfs(images_input_dir)?;
    println!("\n🖼️  图片文件夹 CID 已获取: {}", images_folder_cid);

    let timestamp = Utc::now().format("%Y%m%d_%H%M%S").to_string();
    let collection_output_dir = PathBuf::from("output").join(format!("collection_{}", timestamp));
    let images_output_dir = collection_output_dir.join("images");
    let metadata_output_dir = collection_output_dir.join("metadata");

    copy_directory(images_input_dir, &images_output_dir)?;
    println!("\n💾 所有图片已复制到: {:?}", images_output_dir);

    println!("\n--- 正在为每张图片生成元数据 JSON 文件 ---");
    fs::create_dir_all(&metadata_output_dir)?;

    let mut image_files: Vec<PathBuf> = fs::read_dir(images_input_dir)?
        .filter_map(Result::ok)
        .map(|entry| entry.path())
        .filter(|path| path.is_file())
        .collect();
    image_files.sort();

    for image_file in &image_files {
        let token_id_str = image_file
            .file_stem()
            .and_then(|s| s.to_str())
            .ok_or_else(|| anyhow!("无效的文件名"))?;
        let token_id: u64 = token_id_str.parse()?;
        let image_filename = image_file
            .file_name()
            .and_then(|s| s.to_str())
            .ok_or_else(|| anyhow!("无效的文件名"))?;

        let metadata = NftMetadata {
            name: format!("MetaCore #{}", token_id),
            description: "MetaCore 集合中的一个独特成员。".to_string(),
            image: format!("ipfs://{}/{}", images_folder_cid, image_filename),
            attributes: vec![Attribute {
                trait_type: "ID".to_string(),
                value: serde_json::Value::Number(token_id.into()),
            }],
        };
        let file_name = if USE_JSON_SUFFIX {
            format!("{}.json", token_id_str)
        } else {
            token_id_str.to_string()
        };
        let mut file = File::create(metadata_output_dir.join(file_name))?;
        let pretty_json = serde_json::to_string_pretty(&metadata)?;
        file.write_all(pretty_json.as_bytes())?;
    }
    println!(
        "✅ 成功生成 {} 个元数据文件到: {:?}",
        image_files.len(),
        metadata_output_dir
    );

    let metadata_folder_cid = upload_to_ipfs(&metadata_output_dir)?;
    println!("\n📄 元数据文件夹 CID 已获取: {}", metadata_folder_cid);
    println!("\n--- ✨ 批量流程完成 ✨ ---");
    println!(
        "下一步，您可以在合约中将 Base URI 设置为: ipfs://{}/",
        metadata_folder_cid
    );
    Ok(())
}

fn main() -> Result<()> {
    // 前置检查
    let status = Command::new("ipfs").arg("id").output()?.status;
    if !status.success() {
        eprintln!("❌ 连接 IPFS 节点失败。");
        eprintln!("请确保你的 IPFS 节点正在运行 (命令: ipfs daemon)。");
        return Err(anyhow!("IPFS daemon not running"));
    }
    println!("✅ 成功连接到 IPFS 节点");

    let single_image_path = PathBuf::from("../assets/image/IMG_20210626_180340.jpg");
    let batch_images_path = PathBuf::from("../assets/batch_images");
    fs::create_dir_all(&batch_images_path)?;

    // --- 在这里选择要运行的工作流 ---
    process_single_nft(&single_image_path)?;
    process_batch_collection(&batch_images_path)?;

    println!("\n======================================================================");
    println!("✅ 本地准备工作已完成！");
    println!("下一步是发布到专业的 Pinning 服务 (如 Pinata):");
    println!("1. 登录 Pinata。");
    println!("2. 上传您本地 `rust/output/collection_[时间戳]/images` 文件夹。");
    println!("3. 上传您本地 `rust/output/collection_[时间戳]/metadata` 文件夹。");
    println!("4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。");
    println!("======================================================================");

    Ok(())
}

// --- 辅助函数 ---
fn copy_directory(src: &Path, dst: &Path) -> io::Result<()> {
    fs::create_dir_all(dst)?;
    for entry in WalkDir::new(src) {
        let entry = entry?;
        let path = entry.path();
        let relative_path = path.strip_prefix(src).unwrap();
        let dest_path = dst.join(relative_path);
        if path.is_dir() {
            fs::create_dir_all(&dest_path)?;
        } else {
            fs::copy(path, &dest_path)?;
        }
    }
    Ok(())
}

```

### 编译构建

```bash
polyglot-ipfs-uploader/rust on  main [!] is 📦 0.1.0 via 🦀 1.88.0 on 🐳 v28.2.2 (orbstack)
➜ cargo build
warning: function `upload_json_str_to_ipfs` is never used
  --> src/main.rs:69:4
   |
69 | fn upload_json_str_to_ipfs(data: &NftMetadata) -> Result<String> {
   |    ^^^^^^^^^^^^^^^^^^^^^^^
   |
   = note: `#[warn(dead_code)]` on by default

warning: function `process_single_nft` is never used
   --> src/main.rs:102:4
    |
102 | fn process_single_nft(image_path: &Path) -> Result<()> {
    |    ^^^^^^^^^^^^^^^^^^

warning: `rust` (bin "rust") generated 2 warnings
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.14s
```

### 测试批量 NFT 集合且Metadata文件后缀模式: .json

```bash
polyglot-ipfs-uploader/rust on  main [!] is 📦 0.1.0 via 🦀 1.88.0 on 🐳 v28.2.2 (orbstack)
➜ cargo run
warning: function `upload_json_str_to_ipfs` is never used
  --> src/main.rs:69:4
   |
69 | fn upload_json_str_to_ipfs(data: &NftMetadata) -> Result<String> {
   |    ^^^^^^^^^^^^^^^^^^^^^^^
   |
   = note: `#[warn(dead_code)]` on by default

warning: function `process_single_nft` is never used
   --> src/main.rs:102:4
    |
102 | fn process_single_nft(image_path: &Path) -> Result<()> {
    |    ^^^^^^^^^^^^^^^^^^

warning: `rust` (bin "rust") generated 2 warnings
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.19s
     Running `target/debug/rust`
✅ 成功连接到 IPFS 节点

==============================================
🚀 开始处理批量 NFT 集合...
   - 文件后缀模式: .json
==============================================

--- 正在执行上传命令: ipfs add -r -Q --cid-version 1 ../assets/batch_images ---
✅ 上传成功!
   - 名称: batch_images
   - CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e

🖼️  图片文件夹 CID 已获取: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e

💾 所有图片已复制到: "output/collection_20250728_092506/images"

--- 正在为每张图片生成元数据 JSON 文件 ---
✅ 成功生成 3 个元数据文件到: "output/collection_20250728_092506/metadata"

--- 正在执行上传命令: ipfs add -r -Q --cid-version 1 output/collection_20250728_092506/metadata ---
✅ 上传成功!
   - 名称: metadata
   - CID: bafybeiguvcmspmkhyheyh5c7wmixuiiysjpcrw4hjvvydmfhqmwsopvjk4

📄 元数据文件夹 CID 已获取: bafybeiguvcmspmkhyheyh5c7wmixuiiysjpcrw4hjvvydmfhqmwsopvjk4

--- ✨ 批量流程完成 ✨ ---
下一步，您可以在合约中将 Base URI 设置为: ipfs://bafybeiguvcmspmkhyheyh5c7wmixuiiysjpcrw4hjvvydmfhqmwsopvjk4/

======================================================================
✅ 本地准备工作已完成！
下一步是发布到专业的 Pinning 服务 (如 Pinata):
1. 登录 Pinata。
2. 上传您本地 `rust/output/collection_[时间戳]/images` 文件夹。
3. 上传您本地 `rust/output/collection_[时间戳]/metadata` 文件夹。
4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。
======================================================================

```

### 测试单个NFT且Metadata文件后缀模式: .json

```bash
polyglot-ipfs-uploader/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 on 🐳 v28.2.2 (orbstack)
➜ cargo run
   Compiling rust v0.1.0 (/Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/rust)
warning: function `process_batch_collection` is never used
   --> src/main.rs:158:4
    |
158 | fn process_batch_collection(images_input_dir: &Path) -> Result<()> {
    |    ^^^^^^^^^^^^^^^^^^^^^^^^
    |
    = note: `#[warn(dead_code)]` on by default

warning: function `copy_directory` is never used
   --> src/main.rs:264:4
    |
264 | fn copy_directory(src: &Path, dst: &Path) -> io::Result<()> {
    |    ^^^^^^^^^^^^^^

warning: `rust` (bin "rust") generated 2 warnings
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.04s
     Running `target/debug/rust`
✅ 成功连接到 IPFS 节点

==============================================
🚀 开始处理单个 NFT...
   - 文件后缀模式: .json
==============================================

--- 正在执行上传命令: ipfs add -r -Q --cid-version 1 ../assets/image/IMG_20210626_180340.jpg ---
✅ 上传成功!
   - 名称: IMG_20210626_180340.jpg
   - CID: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

🖼️  图片 CID 已获取: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

--- 正在上传 JSON 对象 ---
✅ JSON 元数据上传成功!
   - CID: bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

💾 图片和元数据已在本地打包保存至: "output/IMG_20210626_180340"

--- ✨ 单件流程完成 ✨ ---
下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

======================================================================
✅ 本地准备工作已完成！
下一步是发布到专业的 Pinning 服务 (如 Pinata):
1. 登录 Pinata。
2. 上传您本地 `rust/output/collection_[时间戳]/images` 文件夹。
3. 上传您本地 `rust/output/collection_[时间戳]/metadata` 文件夹。
4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。
======================================================================
```

### 测试单个 NFT且Metadata文件无后缀模式

```bash
polyglot-ipfs-uploader/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 on 🐳 v28.2.2 (orbstack)
➜ cargo run
   Compiling rust v0.1.0 (/Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/rust)
warning: function `process_batch_collection` is never used
   --> src/main.rs:158:4
    |
158 | fn process_batch_collection(images_input_dir: &Path) -> Result<()> {
    |    ^^^^^^^^^^^^^^^^^^^^^^^^
    |
    = note: `#[warn(dead_code)]` on by default

warning: function `copy_directory` is never used
   --> src/main.rs:264:4
    |
264 | fn copy_directory(src: &Path, dst: &Path) -> io::Result<()> {
    |    ^^^^^^^^^^^^^^

warning: `rust` (bin "rust") generated 2 warnings
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.57s
     Running `target/debug/rust`
✅ 成功连接到 IPFS 节点

==============================================
🚀 开始处理单个 NFT...
   - 文件后缀模式: 无
==============================================

--- 正在执行上传命令: ipfs add -r -Q --cid-version 1 ../assets/image/IMG_20210626_180340.jpg ---
✅ 上传成功!
   - 名称: IMG_20210626_180340.jpg
   - CID: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

🖼️  图片 CID 已获取: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

--- 正在上传 JSON 对象 ---
✅ JSON 元数据上传成功!
   - CID: bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

💾 图片和元数据已在本地打包保存至: "output/IMG_20210626_180340"

--- ✨ 单件流程完成 ✨ ---
下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

======================================================================
✅ 本地准备工作已完成！
下一步是发布到专业的 Pinning 服务 (如 Pinata):
1. 登录 Pinata。
2. 上传您本地 `rust/output/collection_[时间戳]/images` 文件夹。
3. 上传您本地 `rust/output/collection_[时间戳]/metadata` 文件夹。
4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。
======================================================================
```

### 测试批量 NFT 集合且Metadata文件无后缀模式

```bash
polyglot-ipfs-uploader/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 on 🐳 v28.2.2 (orbstack)
➜ cargo run
   Compiling rust v0.1.0 (/Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/rust)
warning: function `upload_json_str_to_ipfs` is never used
  --> src/main.rs:69:4
   |
69 | fn upload_json_str_to_ipfs(data: &NftMetadata) -> Result<String> {
   |    ^^^^^^^^^^^^^^^^^^^^^^^
   |
   = note: `#[warn(dead_code)]` on by default

warning: function `process_single_nft` is never used
   --> src/main.rs:102:4
    |
102 | fn process_single_nft(image_path: &Path) -> Result<()> {
    |    ^^^^^^^^^^^^^^^^^^

warning: `rust` (bin "rust") generated 2 warnings
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.67s
     Running `target/debug/rust`
✅ 成功连接到 IPFS 节点

==============================================
🚀 开始处理批量 NFT 集合...
   - 文件后缀模式: 无
==============================================

--- 正在执行上传命令: ipfs add -r -Q --cid-version 1 ../assets/batch_images ---
✅ 上传成功!
   - 名称: batch_images
   - CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e

🖼️  图片文件夹 CID 已获取: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e

💾 所有图片已复制到: "output/collection_20250728_092723/images"

--- 正在为每张图片生成元数据 JSON 文件 ---
✅ 成功生成 3 个元数据文件到: "output/collection_20250728_092723/metadata"

--- 正在执行上传命令: ipfs add -r -Q --cid-version 1 output/collection_20250728_092723/metadata ---
✅ 上传成功!
   - 名称: metadata
   - CID: bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq

📄 元数据文件夹 CID 已获取: bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq

--- ✨ 批量流程完成 ✨ ---
下一步，您可以在合约中将 Base URI 设置为: ipfs://bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq/

======================================================================
✅ 本地准备工作已完成！
下一步是发布到专业的 Pinning 服务 (如 Pinata):
1. 登录 Pinata。
2. 上传您本地 `rust/output/collection_[时间戳]/images` 文件夹。
3. 上传您本地 `rust/output/collection_[时间戳]/metadata` 文件夹。
4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。
======================================================================

```

因为我们在main函数中通过注释来选择执行单个或批量流程，所以未被调用的函数会收到编译器警告，这在开发测试阶段是正常现象。

## 重构优化完善两种实现路径

### 走向生产：项目结构化重构

### `src/lib.rs` 文件

```rust
use std::{fs, path::Path};

use anyhow::Result;
use serde::{Deserialize, Serialize};
use walkdir::WalkDir;

// ✅ 定义元数据结构体
#[derive(Serialize, Deserialize, Debug)]
pub struct Attribute {
    pub trait_type: String,
    pub value: serde_json::Value,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct NftMetadata {
    pub name: String,
    pub description: String,
    pub image: String,
    pub attributes: Vec<Attribute>,
}

// ✅ 共享的辅助函数
pub fn copy_directory(src: &Path, dst: &Path) -> Result<()> {
    fs::create_dir_all(dst)?;
    for entry in WalkDir::new(src) {
        let entry = entry?;
        let path = entry.path();
        let relative_path = path.strip_prefix(src)?;
        let dest_path = dst.join(relative_path);
        if path.is_dir() {
            fs::create_dir_all(&dest_path)?;
        } else {
            fs::copy(path, &dest_path)?;
        }
    }
    Ok(())
}

```

### 路径一：基于命令行的快速实现 (`std::process::Command`)

### `examples/cli_uploader.rs` 文件

```rust
// examples/cli_uploader.rs

use anyhow::{Result, anyhow};
use chrono::Utc;
use rust::{Attribute, NftMetadata, copy_directory};
use std::fs::{self, File};
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

const USE_JSON_SUFFIX: bool = false;

// --- 核心上传函数 ---
fn upload_to_ipfs(target_path: &Path) -> Result<String> {
    if !target_path.exists() {
        return Err(anyhow!("路径不存在: {:?}", target_path));
    }
    let path_str = target_path.to_str().ok_or_else(|| anyhow!("无效路径"))?;
    println!(
        "\n--- 正在执行(命令行): ipfs add -r -Q --cid-version 1 {} ---",
        path_str
    );
    let output = Command::new("ipfs")
        .args(["add", "-r", "-Q", "--cid-version", "1", path_str])
        .output()?;
    if !output.status.success() {
        return Err(anyhow!(
            "上传失败: {}",
            String::from_utf8_lossy(&output.stderr)
        ));
    }
    let cid = String::from_utf8(output.stdout)?.trim().to_string();
    println!("✅ 上传成功! CID: {}", cid);
    Ok(cid)
}

fn upload_json_str_to_ipfs(data: &NftMetadata) -> Result<String> {
    let json_string = serde_json::to_string(data)?;
    let mut child = Command::new("ipfs")
        .args(["add", "-Q", "--cid-version", "1"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()?;
    if let Some(mut stdin) = child.stdin.take() {
        stdin.write_all(json_string.as_bytes())?;
    }
    let output = child.wait_with_output()?;
    if !output.status.success() {
        return Err(anyhow!(
            "上传JSON失败: {}",
            String::from_utf8_lossy(&output.stderr)
        ));
    }
    let cid = String::from_utf8(output.stdout)?.trim().to_string();
    println!("\n✅ JSON 元数据上传成功! CID: {}", cid);
    Ok(cid)
}

// --- 工作流一：处理单个 NFT ---
fn process_single_nft(image_path: &Path) -> Result<()> {
    println!("\n==============================================");
    println!("🚀 开始处理单个 NFT (命令行方式)...");
    println!("==============================================");

    let image_cid = upload_to_ipfs(image_path)?;
    println!("\n🖼️  图片 CID 已获取: {}", image_cid);

    let image_filename = image_path
        .file_name()
        .and_then(|s| s.to_str())
        .ok_or_else(|| anyhow!("无效的图片文件名"))?;
    let image_name_without_ext = image_path
        .file_stem()
        .and_then(|s| s.to_str())
        .ok_or_else(|| anyhow!("无效的图片文件名"))?;

    let metadata = NftMetadata {
        name: image_name_without_ext.to_string(),
        description: format!("这是一个为图片 {} 动态生成的元数据。", image_filename),
        image: format!("ipfs://{}", image_cid),
        attributes: vec![Attribute {
            trait_type: "类型".to_string(),
            value: serde_json::Value::String("单件艺术品".to_string()),
        }],
    };

    let metadata_cid = upload_json_str_to_ipfs(&metadata)?;

    let output_dir = PathBuf::from("output").join(image_name_without_ext);
    fs::create_dir_all(&output_dir)?;
    fs::copy(image_path, output_dir.join(image_filename))?;

    let file_name = if USE_JSON_SUFFIX {
        format!("{}.json", image_name_without_ext)
    } else {
        image_name_without_ext.to_string()
    };
    let mut metadata_file = File::create(output_dir.join(file_name))?;
    let pretty_json = serde_json::to_string_pretty(&metadata)?;
    metadata_file.write_all(pretty_json.as_bytes())?;

    println!("\n💾 图片和元数据已在本地打包保存至: {:?}", output_dir);
    println!("\n--- ✨ 单件流程完成 ✨ ---");
    println!(
        "下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://{}",
        metadata_cid
    );
    Ok(())
}

// --- 工作流二：处理批量 NFT 集合 ---
fn process_batch_collection(images_input_dir: &Path) -> Result<()> {
    println!("\n==============================================");
    println!("🚀 开始处理批量 NFT 集合 (命令行方式)...");
    println!("==============================================");
    let images_folder_cid = upload_to_ipfs(images_input_dir)?;
    let timestamp = Utc::now().format("%Y%m%d_%H%M%S").to_string();
    let collection_output_dir =
        PathBuf::from("output").join(format!("collection_cli_{}", timestamp));
    let images_output_dir = collection_output_dir.join("images");
    let metadata_output_dir = collection_output_dir.join("metadata");
    copy_directory(images_input_dir, &images_output_dir)?;
    println!("\n💾 所有图片已复制到: {:?}", images_output_dir);
    fs::create_dir_all(&metadata_output_dir)?;
    let mut image_files: Vec<PathBuf> = fs::read_dir(images_input_dir)?
        .filter_map(Result::ok)
        .map(|e| e.path())
        .filter(|p| p.is_file())
        .collect();
    image_files.sort();
    for image_file in &image_files {
        let token_id_str = image_file
            .file_stem()
            .and_then(|s| s.to_str())
            .ok_or_else(|| anyhow!("无效文件名"))?;
        let token_id: u64 = token_id_str.parse()?;
        let image_filename = image_file
            .file_name()
            .and_then(|s| s.to_str())
            .ok_or_else(|| anyhow!("无效文件名"))?;
        let metadata = NftMetadata {
            name: format!("MetaCore #{}", token_id),
            description: "MetaCore 集合中的一个独特成员。".to_string(),
            image: format!("ipfs://{}/{}", images_folder_cid, image_filename),
            attributes: vec![Attribute {
                trait_type: "ID".to_string(),
                value: token_id.into(),
            }],
        };
        let file_name = if USE_JSON_SUFFIX {
            format!("{}.json", token_id_str)
        } else {
            token_id_str.to_string()
        };
        let mut file = File::create(metadata_output_dir.join(file_name))?;
        file.write_all(serde_json::to_string_pretty(&metadata)?.as_bytes())?;
    }
    println!(
        "✅ 成功生成 {} 个元数据文件到: {:?}",
        image_files.len(),
        metadata_output_dir
    );
    let metadata_folder_cid = upload_to_ipfs(&metadata_output_dir)?;
    println!("\n📄 元数据文件夹 CID 已获取: {}", metadata_folder_cid);
    println!("\n--- ✨ 批量流程完成 ✨ ---");
    println!(
        "下一步，您可以在合约中将 Base URI 设置为: ipfs://{}/",
        metadata_folder_cid
    );
    Ok(())
}

fn main() -> Result<()> {
    let status = Command::new("ipfs").arg("id").output()?.status;
    if !status.success() {
        return Err(anyhow!("连接 IPFS 节点失败。请确保 ipfs daemon 正在运行。"));
    }
    println!("✅ 成功连接到 IPFS 节点");

    // ✅ 定义了两个路径，并允许用户选择
    let single_image_path = PathBuf::from("../assets/image/IMG_20210626_180340.jpg");
    let batch_images_path = PathBuf::from("../assets/batch_images");
    fs::create_dir_all(&batch_images_path)?;

    // --- 在这里选择要运行的工作流 ---
    process_single_nft(&single_image_path)?;
    process_batch_collection(&batch_images_path)?;

    Ok(())
}

```

### 测试Metadata文件为JSON后缀模式

```bash
polyglot-ipfs-uploader/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 on 🐳 v28.2.2 (orbstack)
➜ cargo run --example cli_uploader
   Compiling rust v0.1.0 (/Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/rust)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.97s
     Running `target/debug/examples/cli_uploader`
✅ 成功连接到 IPFS 节点

==============================================
🚀 开始处理单个 NFT (命令行方式)...
==============================================

--- 正在执行(命令行): ipfs add -r -Q --cid-version 1 ../assets/image/IMG_20210626_180340.jpg ---
✅ 上传成功! CID: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

🖼️  图片 CID 已获取: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

✅ JSON 元数据上传成功! CID: bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

💾 图片和元数据已在本地打包保存至: "output/IMG_20210626_180340"

--- ✨ 单件流程完成 ✨ ---
下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

==============================================
🚀 开始处理批量 NFT 集合 (命令行方式)...
==============================================

--- 正在执行(命令行): ipfs add -r -Q --cid-version 1 ../assets/batch_images ---
✅ 上传成功! CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e

💾 所有图片已复制到: "output/collection_cli_20250728_113659/images"
✅ 成功生成 3 个元数据文件到: "output/collection_cli_20250728_113659/metadata"

--- 正在执行(命令行): ipfs add -r -Q --cid-version 1 output/collection_cli_20250728_113659/metadata ---
✅ 上传成功! CID: bafybeiguvcmspmkhyheyh5c7wmixuiiysjpcrw4hjvvydmfhqmwsopvjk4

📄 元数据文件夹 CID 已获取: bafybeiguvcmspmkhyheyh5c7wmixuiiysjpcrw4hjvvydmfhqmwsopvjk4

--- ✨ 批量流程完成 ✨ ---
下一步，您可以在合约中将 Base URI 设置为: ipfs://bafybeiguvcmspmkhyheyh5c7wmixuiiysjpcrw4hjvvydmfhqmwsopvjk4/

```

### 测试Metadata文件无后缀模式

```bash
polyglot-ipfs-uploader/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 on 🐳 v28.2.2 (orbstack)
➜ cargo run --example cli_uploader
   Compiling rust v0.1.0 (/Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/rust)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.86s
     Running `target/debug/examples/cli_uploader`
✅ 成功连接到 IPFS 节点

==============================================
🚀 开始处理单个 NFT (命令行方式)...
==============================================

--- 正在执行(命令行): ipfs add -r -Q --cid-version 1 ../assets/image/IMG_20210626_180340.jpg ---
✅ 上传成功! CID: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

🖼️  图片 CID 已获取: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

✅ JSON 元数据上传成功! CID: bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

💾 图片和元数据已在本地打包保存至: "output/IMG_20210626_180340"

--- ✨ 单件流程完成 ✨ ---
下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

==============================================
🚀 开始处理批量 NFT 集合 (命令行方式)...
==============================================

--- 正在执行(命令行): ipfs add -r -Q --cid-version 1 ../assets/batch_images ---
✅ 上传成功! CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e

💾 所有图片已复制到: "output/collection_cli_20250728_113814/images"
✅ 成功生成 3 个元数据文件到: "output/collection_cli_20250728_113814/metadata"

--- 正在执行(命令行): ipfs add -r -Q --cid-version 1 output/collection_cli_20250728_113814/metadata ---
✅ 上传成功! CID: bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq

📄 元数据文件夹 CID 已获取: bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq

--- ✨ 批量流程完成 ✨ ---
下一步，您可以在合约中将 Base URI 设置为: ipfs://bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq/

```

### 路径二：基于官方库的专业实现 (`ipfs-api-backend-hyper`)

### `examples/library_uploader.rs` 文件

```rust
// examples/library_uploader.rs

use rust::{Attribute, NftMetadata, copy_directory};

use anyhow::{Result, anyhow};
use chrono::Utc;
use ipfs_api_backend_hyper::{IpfsApi, IpfsClient, TryFromUri};
use std::fs::{self, File};
use std::io::{Cursor, Write};
use std::path::{Path, PathBuf};

const USE_JSON_SUFFIX: bool = false;
const IPFS_API_URL: &str = "http://localhost:5001";

// --- 核心上传函数 ---

// 上传单个文件
async fn upload_file_to_ipfs(client: &IpfsClient, target_path: &Path) -> Result<String> {
    println!("\n--- 正在上传(库): {:?} ---", target_path);
    if !target_path.exists() {
        return Err(anyhow!("路径不存在: {:?}", target_path));
    }
    let data = fs::read(target_path)?;
    let cursor = Cursor::new(data);
    let res = client.add(cursor).await?;
    let cid = res.hash;
    println!("✅ 上传成功! CID: {}", cid);
    Ok(cid)
}

// 上传整个文件夹
async fn upload_directory_to_ipfs(client: &IpfsClient, dir_path: &Path) -> Result<String> {
    println!("\n--- 正在上传文件夹(库): {:?} ---", dir_path);
    // add_path 返回一个 Vec，最后一个元素是根目录的信息
    let responses = client.add_path(dir_path).await?;
    if let Some(root_res) = responses.last() {
        let cid = root_res.hash.clone();
        println!("✅ 文件夹上传成功! CID: {}", cid);
        Ok(cid)
    } else {
        Err(anyhow!("文件夹上传失败"))
    }
}

// 上传 JSON 数据
async fn upload_json_str_to_ipfs(client: &IpfsClient, data: &NftMetadata) -> Result<String> {
    let json_string = serde_json::to_string(data)?;
    let cursor = Cursor::new(json_string.into_bytes());
    let res = client.add(cursor).await?;
    let cid = res.hash;
    println!("\n✅ JSON 元数据上传成功! CID: {}", cid);
    Ok(cid)
}

// --- 工作流一：处理单个 NFT ---
async fn process_single_nft(client: &IpfsClient, image_path: &Path) -> Result<()> {
    println!("\n==============================================");
    println!("🚀 开始处理单个 NFT (官方库方式)...");
    println!("==============================================");

    let image_cid = upload_file_to_ipfs(client, image_path).await?;
    println!("\n🖼️  图片 CID 已获取: {}", image_cid);

    let image_filename = image_path
        .file_name()
        .and_then(|s| s.to_str())
        .ok_or_else(|| anyhow!("无效的图片文件名"))?;
    let image_name_without_ext = image_path
        .file_stem()
        .and_then(|s| s.to_str())
        .ok_or_else(|| anyhow!("无效的图片文件名"))?;

    let metadata = NftMetadata {
        name: image_name_without_ext.to_string(),
        description: format!("这是一个为图片 {} 动态生成的元数据。", image_filename),
        image: format!("ipfs://{}", image_cid),
        attributes: vec![Attribute {
            trait_type: "类型".to_string(),
            value: serde_json::Value::String("单件艺术品".to_string()),
        }],
    };

    let metadata_cid = upload_json_str_to_ipfs(client, &metadata).await?;

    let output_dir = PathBuf::from("output").join(image_name_without_ext);
    fs::create_dir_all(&output_dir)?;
    fs::copy(image_path, output_dir.join(image_filename))?;

    let file_name = if USE_JSON_SUFFIX {
        format!("{}.json", image_name_without_ext)
    } else {
        image_name_without_ext.to_string()
    };
    let mut metadata_file = File::create(output_dir.join(file_name))?;
    let pretty_json = serde_json::to_string_pretty(&metadata)?;
    metadata_file.write_all(pretty_json.as_bytes())?;

    println!("\n💾 图片和元数据已在本地打包保存至: {:?}", output_dir);
    println!("\n--- ✨ 单件流程完成 ✨ ---");
    println!(
        "下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://{}",
        metadata_cid
    );
    Ok(())
}

// --- 工作流二：处理批量 NFT 集合 ---
async fn process_batch_collection(client: &IpfsClient, images_input_dir: &Path) -> Result<()> {
    println!("\n==============================================");
    println!("🚀 开始处理批量 NFT 集合 (官方库方式)...");
    println!("==============================================");
    let images_folder_cid = upload_directory_to_ipfs(client, images_input_dir).await?;
    let timestamp = Utc::now().format("%Y%m%d_%H%M%S").to_string();
    let collection_output_dir =
        PathBuf::from("output").join(format!("collection_lib_{}", timestamp));
    let images_output_dir = collection_output_dir.join("images");
    let metadata_output_dir = collection_output_dir.join("metadata");
    copy_directory(images_input_dir, &images_output_dir)?;
    println!("\n💾 所有图片已复制到: {:?}", images_output_dir);
    fs::create_dir_all(&metadata_output_dir)?;
    let mut image_files: Vec<PathBuf> = fs::read_dir(images_input_dir)?
        .filter_map(Result::ok)
        .map(|e| e.path())
        .filter(|p| p.is_file())
        .collect();
    image_files.sort();
    for image_file in &image_files {
        let token_id_str = image_file
            .file_stem()
            .and_then(|s| s.to_str())
            .ok_or_else(|| anyhow!("无效文件名"))?;
        let token_id: u64 = token_id_str.parse()?;
        let image_filename = image_file
            .file_name()
            .and_then(|s| s.to_str())
            .ok_or_else(|| anyhow!("无效文件名"))?;
        let metadata = NftMetadata {
            name: format!("MetaCore #{}", token_id),
            description: "MetaCore 集合中的一个独特成员。".to_string(),
            image: format!("ipfs://{}/{}", images_folder_cid, image_filename),
            attributes: vec![Attribute {
                trait_type: "ID".to_string(),
                value: token_id.into(),
            }],
        };
        let file_name = if USE_JSON_SUFFIX {
            format!("{}.json", token_id_str)
        } else {
            token_id_str.to_string()
        };
        let mut file = File::create(metadata_output_dir.join(file_name))?;
        file.write_all(serde_json::to_string_pretty(&metadata)?.as_bytes())?;
    }
    println!(
        "✅ 成功生成 {} 个元数据文件到: {:?}",
        image_files.len(),
        metadata_output_dir
    );
    let metadata_folder_cid = upload_directory_to_ipfs(client, &metadata_output_dir).await?;
    println!("\n📄 元数据文件夹 CID 已获取: {}", metadata_folder_cid);
    println!("\n--- ✨ 批量流程完成 ✨ ---");
    println!(
        "下一步，您可以在合约中将 Base URI 设置为: ipfs://{}/",
        metadata_folder_cid
    );
    Ok(())
}

#[tokio::main]
async fn main() -> Result<()> {
    let client = IpfsClient::from_multiaddr_str(IPFS_API_URL)
        .map_err(|e| anyhow!("创建 IPFS 客户端失败: {}", e))?;

    if client.version().await.is_err() {
        eprintln!("❌ 连接 IPFS 节点失败。请确保 ipfs daemon 正在运行。");
        return Ok(());
    }
    println!("✅ 成功连接到 IPFS 节点");

    let single_image_path = PathBuf::from("../assets/image/IMG_20210626_180340.jpg");
    let batch_images_path = PathBuf::from("../assets/batch_images");
    fs::create_dir_all(&batch_images_path)?;

    // --- 在这里选择要运行的工作流 ---
    // 首先运行工作流一：处理单个 NFT
    process_single_nft(&client, &single_image_path).await?;
    // 然后运行工作流二：处理批量 NFT 集合
    process_batch_collection(&client, &batch_images_path).await?;

    Ok(())
}

```

### 测试Metadata文件JSON后缀方式

```bash
polyglot-ipfs-uploader/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 on 🐳 v28.2.2 (orbstack)
➜ cargo run --example library_uploader
   Compiling rust v0.1.0 (/Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/rust)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 2.95s
     Running `target/debug/examples/library_uploader`
✅ 成功连接到 IPFS 节点

==============================================
🚀 开始处理单个 NFT (官方库方式)...
==============================================

--- 正在上传(库): "../assets/image/IMG_20210626_180340.jpg" ---
✅ 上传成功! CID: QmXgwL18mcPFTJvbLmGXet4rpGwU9oNH9bDRGYuV1vNtQs

🖼️  图片 CID 已获取: QmXgwL18mcPFTJvbLmGXet4rpGwU9oNH9bDRGYuV1vNtQs

✅ JSON 元数据上传成功! CID: QmZj3odMubignuppJo93wBiNVDv1U1HbYRCmQcQQ8VS4rd

💾 图片和元数据已在本地打包保存至: "output/IMG_20210626_180340"

--- ✨ 单件流程完成 ✨ ---
下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://QmZj3odMubignuppJo93wBiNVDv1U1HbYRCmQcQQ8VS4rd

==============================================
🚀 开始处理批量 NFT 集合 (官方库方式)...
==============================================

--- 正在上传文件夹(库): "../assets/batch_images" ---
✅ 文件夹上传成功! CID: QmVKhPv53d3WKZi5if4Tm4sZnYEL9t2n7kD4v7ENMqx8WP

💾 所有图片已复制到: "output/collection_lib_20250728_114023/images"
✅ 成功生成 3 个元数据文件到: "output/collection_lib_20250728_114023/metadata"

--- 正在上传文件夹(库): "output/collection_lib_20250728_114023/metadata" ---
✅ 文件夹上传成功! CID: QmcZtafg6yiSzNaNsjyyh2ttHYbekbBVGubJnANPhHXwQM

📄 元数据文件夹 CID 已获取: QmcZtafg6yiSzNaNsjyyh2ttHYbekbBVGubJnANPhHXwQM

--- ✨ 批量流程完成 ✨ ---
下一步，您可以在合约中将 Base URI 设置为: ipfs://QmcZtafg6yiSzNaNsjyyh2ttHYbekbBVGubJnANPhHXwQM/

```

### 测试Metadata文件无后缀方式

```bash
polyglot-ipfs-uploader/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 on 🐳 v28.2.2 (orbstack) took 4.1s
➜ cargo run --example library_uploader
   Compiling rust v0.1.0 (/Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-ipfs-uploader/rust)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 1.25s
     Running `target/debug/examples/library_uploader`
✅ 成功连接到 IPFS 节点

==============================================
🚀 开始处理单个 NFT (官方库方式)...
==============================================

--- 正在上传(库): "../assets/image/IMG_20210626_180340.jpg" ---
✅ 上传成功! CID: QmXgwL18mcPFTJvbLmGXet4rpGwU9oNH9bDRGYuV1vNtQs

🖼️  图片 CID 已获取: QmXgwL18mcPFTJvbLmGXet4rpGwU9oNH9bDRGYuV1vNtQs

✅ JSON 元数据上传成功! CID: QmZj3odMubignuppJo93wBiNVDv1U1HbYRCmQcQQ8VS4rd

💾 图片和元数据已在本地打包保存至: "output/IMG_20210626_180340"

--- ✨ 单件流程完成 ✨ ---
下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://QmZj3odMubignuppJo93wBiNVDv1U1HbYRCmQcQQ8VS4rd

==============================================
🚀 开始处理批量 NFT 集合 (官方库方式)...
==============================================

--- 正在上传文件夹(库): "../assets/batch_images" ---
✅ 文件夹上传成功! CID: QmVKhPv53d3WKZi5if4Tm4sZnYEL9t2n7kD4v7ENMqx8WP

💾 所有图片已复制到: "output/collection_lib_20250728_114130/images"
✅ 成功生成 3 个元数据文件到: "output/collection_lib_20250728_114130/metadata"

--- 正在上传文件夹(库): "output/collection_lib_20250728_114130/metadata" ---
✅ 文件夹上传成功! CID: QmYcgHTuFBkwv3HRyxmjFmUBPZSwtt3LzFV4kZuCxX5Ti5

📄 元数据文件夹 CID 已获取: QmYcgHTuFBkwv3HRyxmjFmUBPZSwtt3LzFV4kZuCxX5Ti5

--- ✨ 批量流程完成 ✨ ---
下一步，您可以在合约中将 Base URI 设置为: ipfs://QmYcgHTuFBkwv3HRyxmjFmUBPZSwtt3LzFV4kZuCxX5Ti5/

```

## 总结

本文成功演示了如何运用 Rust 语言为 Web3 项目构建一个功能完善的 NFT 元数据 IPFS 上传器。我们从一个基础脚本出发，逐步迭代，最终形成了一个结构清晰、代码健壮的解决方案。

主要成果包括：

1. **两种实现路径**：我们深入探索并实现了两种主流的 IPFS 交互方法：
   - **命令行接口 (`std::process::Command`)**：此方法简单直接，易于快速实现，非常适合简单的脚本或当项目已经依赖于本地 IPFS 客户端时使用。
   - **官方 Rust 库 (`ipfs-api-backend-hyper`)**：此方法更为专业和健壮，提供了类型安全、异步支持和更佳的错误处理机制，是构建复杂、高性能应用程序的首选。
2. **两种核心工作流**：我们全面覆盖了 NFT 项目中最常见的两种需求场景——处理单个 NFT 和批量处理整个 NFT 集合，并为每种场景提供了明确的逻辑和代码实现。
3. **代码重构与优化**：通过将核心逻辑（如元数据结构体、辅助函数）提取到共享库 `lib.rs` 中，并使用 `examples` 目录来分离不同的实现方式，我们显著提升了代码的模块化、可读性和可维护性。

总而言之，无论您是倾向于快速原型开发的简洁性，还是追求生产环境的稳定与高效，本文都提供了相应的 Rust 实现方案，为您的 NFT 和 Web3 开发之旅提供了坚实的技术支持。

## 参考

- <https://ipfs.io/>
- <https://app.pinata.cloud/ipfs/files>
- <https://docs.rs/ipfs-api-backend-hyper/0.6.0/ipfs_api_backend_hyper/>

## 推荐阅读

- 《NFT 开发核心步骤：本地 IPFS 节点搭建与元数据上传实战》
- 《Python x IPFS：构建生产级的 NFT 元数据自动化流程》
- 《从命令行到官方库：用 Go 语言精通 NFT 元数据 IPFS 上传》
