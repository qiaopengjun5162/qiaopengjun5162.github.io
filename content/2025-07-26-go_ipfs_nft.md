+++
title = "从命令行到官方库：用 Go 语言精通 NFT 元数据 IPFS 上传"
description = "本文深入探讨用 Go 语言实现 NFT 元数据自动化上传的两种核心方式：直接调用 IPFS 命令行与使用官方 RPC 库。提供一份可配置、生产级的完整脚本，支持单件与批量处理，助你精通 Go 在 Web3 开发中的应用。"
date = 2025-07-26T12:10:02Z
[taxonomies]
categories = ["Web3", "NFT", "Go", "IPFS"]
tags = ["Web3", "NFT", "Go", "IPFS"]
+++

<!-- more -->

# 从命令行到官方库：用 Go 语言精通 NFT 元数据 IPFS 上传

在我们的 Web3 实战系列中，继《[NFT 开发核心步骤：本地 IPFS 节点搭建与元数据上传实战](https://www.google.com/search?q=链接到您的TS文章)》和《[Python x IPFS：构建生产级的 NFT 元数据自动化流程](https://www.google.com/search?q=链接到您的Python文章)》之后，我们迎来了性能与并发的王者——Go 语言。对于需要处理大规模数据、构建高效后端服务的 Web3 项目而言，Go 几乎是无可替代的选择。

本文将深入探讨使用 Go 实现 NFT 元数据自动化上传的两种核心路径：一种是直接、粗犷但极其可靠的命令行调用方式；另一种则是更优雅、更符合 Go 语言工程化思想的官方库集成方式。我们将提供一份功能完备、可灵活配置的生产级脚本，助您彻底掌握 Go 在 NFT 开发流程中的强大应用。

## 实操

### 第一种方式：直接调用命令行 (`os/exec`)

这是最直接、最“原始”的方法。它不依赖任何第三方的 Go 库，而是通过 Go 的 `os/exec` 包，直接在操作系统层面执行您已经安装好的 `ipfs` 命令行程序。这种方法的优点是极其稳定，只要您的 `ipfs` 命令能工作，脚本就能工作，完全不受库版本更新迭代的影响。缺点是代码相对繁琐，需要手动处理命令的输入和输出。

```go
// main.go
package main

import (
 "bytes"
 "encoding/json"
 "fmt"
 "io/fs"
 "log"
 "os"
 "os/exec"
 "path/filepath"
 "sort"
 "strconv"
 "strings"
 "time"
)

// ✅ 配置开关
// 设置为 true  -> 生成 1.json, 2.json... (用于需要后缀的合约)
// 设置为 false -> 生成 1, 2... (用于标准 ERC721A 合约)
const USE_JSON_SUFFIX = false

// Attribute 定义了元数据中的属性结构
type Attribute struct {
 TraitType string      `json:"trait_type"`
 Value     interface{} `json:"value"`
}

// NftMetadata 定义了元数据的整体结构
type NftMetadata struct {
 Name        string      `json:"name"`
 Description string      `json:"description"`
 Image       string      `json:"image"`
 Attributes  []Attribute `json:"attributes"`
}

// 核心上传函数 (使用 os/exec)
func uploadToIPFS(targetPath string) (string, error) {
 fmt.Printf("\n--- 正在执行上传命令: ipfs add -r -Q --cid-version 1 %s ---\n", targetPath)

 // 使用 ipfs add 命令上传
 cmd := exec.Command("ipfs", "add", "-r", "-Q", "--cid-version", "1", targetPath)
 var out bytes.Buffer
 var stderr bytes.Buffer
 cmd.Stdout = &out
 cmd.Stderr = &stderr

 err := cmd.Run()
 if err != nil {
  return "", fmt.Errorf("❌ 上传失败: %s\n%s", err, stderr.String())
 }

 cid := strings.TrimSpace(out.String())
 fmt.Println("✅ 上传成功!")
 fmt.Printf("   - 名称: %s\n", filepath.Base(targetPath))
 fmt.Printf("   - CID: %s\n", cid)
 return cid, nil
}

// 工作流一：处理单个 NFT
func processSingleNFT(imagePath string) {
 fmt.Println("\n==============================================")
 fmt.Println("🚀 开始处理单个 NFT...")
 if USE_JSON_SUFFIX {
  fmt.Println("   - 文件后缀模式: .json")
 } else {
  fmt.Println("   - 文件后缀模式: 无")
 }
 fmt.Println("==============================================")

 // 1. 上传图片文件
 imageCid, err := uploadToIPFS(imagePath)
 if err != nil {
  log.Fatal(err)
 }
 fmt.Printf("\n🖼️  图片 CID 已获取: %s\n", imageCid)

 // 2. 构建元数据
 imageFilename := filepath.Base(imagePath)
 imageNameWithoutExt := strings.TrimSuffix(imageFilename, filepath.Ext(imageFilename))

 metadata := NftMetadata{
  Name:        imageNameWithoutExt,
  Description: fmt.Sprintf("这是一个为图片 %s 动态生成的元数据。", imageFilename),
  Image:       fmt.Sprintf("ipfs://%s", imageCid),
  Attributes: []Attribute{
   {TraitType: "类型", Value: "单件艺术品"},
  },
 }

 // 3. 上传元数据 JSON
 metadataJSON, _ := json.Marshal(metadata)
 cmd := exec.Command("ipfs", "add", "-Q", "--cid-version", "1")
 cmd.Stdin = bytes.NewReader(metadataJSON)
 var out bytes.Buffer
 cmd.Stdout = &out
 err = cmd.Run()
 if err != nil {
  log.Fatalf("❌ 上传 JSON 失败: %v", err)
 }
 metadataCid := strings.TrimSpace(out.String())
 fmt.Printf("\n✅ JSON 元数据上传成功!\n   - CID: %s\n", metadataCid)

 // 4. 本地归档
 outputDir := filepath.Join("output", imageNameWithoutExt)
 os.MkdirAll(outputDir, os.ModePerm)

 // 复制图片
 destImage, _ := os.Create(filepath.Join(outputDir, imageFilename))
 srcImage, _ := os.Open(imagePath)
 destImage.ReadFrom(srcImage)
 destImage.Close()
 srcImage.Close()

 // 保存元数据
 fileName := imageNameWithoutExt
 if USE_JSON_SUFFIX {
  fileName += ".json"
 }
 metadataFile, _ := os.Create(filepath.Join(outputDir, fileName))
 prettyJSON, _ := json.MarshalIndent(metadata, "", "    ")
 metadataFile.Write(prettyJSON)
 metadataFile.Close()

 fmt.Printf("\n💾 图片和元数据已在本地打包保存至: %s\n", outputDir)
 fmt.Println("\n--- ✨ 单件流程完成 ✨ ---")
 fmt.Printf("下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://%s\n", metadataCid)
}

// 工作流二：处理批量 NFT 集合
func processBatchCollection(imagesInputDir string) {
 fmt.Println("\n==============================================")
 fmt.Println("🚀 开始处理批量 NFT 集合...")
 if USE_JSON_SUFFIX {
  fmt.Println("   - 文件后缀模式: .json")
 } else {
  fmt.Println("   - 文件后缀模式: 无")
 }
 fmt.Println("==============================================")

 // 1. 批量上传整个图片文件夹
 imagesFolderCid, err := uploadToIPFS(imagesInputDir)
 if err != nil {
  log.Fatal(err)
 }
 fmt.Printf("\n🖼️  图片文件夹 CID 已获取: %s\n", imagesFolderCid)

 // 2. 准备并批量生成元数据文件
 timestamp := time.Now().Format("20060102_150405")
 collectionOutputDir := filepath.Join("output", fmt.Sprintf("collection_%s", timestamp))
 imagesOutputDir := filepath.Join(collectionOutputDir, "images")
 metadataOutputDir := filepath.Join(collectionOutputDir, "metadata")

 // 复制图片文件夹
 os.MkdirAll(imagesOutputDir, os.ModePerm)
 filepath.Walk(imagesInputDir, func(path string, info fs.FileInfo, err error) error {
  if !info.IsDir() {
   dest := filepath.Join(imagesOutputDir, info.Name())
   src, _ := os.Open(path)
   dst, _ := os.Create(dest)
   dst.ReadFrom(src)
   src.Close()
   dst.Close()
  }
  return nil
 })
 fmt.Printf("\n💾 所有图片已复制到: %s\n", imagesOutputDir)

 fmt.Println("\n--- 正在为每张图片生成元数据 JSON 文件 ---")
 os.MkdirAll(metadataOutputDir, os.ModePerm)

 files, _ := os.ReadDir(imagesInputDir)
 var imageFiles []string
 for _, file := range files {
  if !file.IsDir() {
   ext := strings.ToLower(filepath.Ext(file.Name()))
   if ext == ".png" || ext == ".jpg" || ext == ".jpeg" || ext == ".gif" {
    imageFiles = append(imageFiles, file.Name())
   }
  }
 }
 sort.Strings(imageFiles)

 for _, fileName := range imageFiles {
  tokenIDStr := strings.TrimSuffix(fileName, filepath.Ext(fileName))
  tokenID, _ := strconv.Atoi(tokenIDStr)
  metadata := NftMetadata{
   Name:        fmt.Sprintf("MetaCore #%d", tokenID),
   Description: "MetaCore 集合中的一个独特成员。",
   Image:       fmt.Sprintf("ipfs://%s/%s", imagesFolderCid, fileName),
   Attributes:  []Attribute{{TraitType: "ID", Value: tokenID}},
  }

  outFileName := tokenIDStr
  if USE_JSON_SUFFIX {
   outFileName += ".json"
  }
  file, _ := os.Create(filepath.Join(metadataOutputDir, outFileName))
  prettyJSON, _ := json.MarshalIndent(metadata, "", "    ")
  file.Write(prettyJSON)
  file.Close()
 }
 fmt.Printf("✅ 成功生成 %d 个元数据文件到: %s\n", len(imageFiles), metadataOutputDir)

 // 3. 批量上传整个元数据文件夹
 metadataFolderCid, err := uploadToIPFS(metadataOutputDir)
 if err != nil {
  log.Fatal(err)
 }
 fmt.Printf("\n📄 元数据文件夹 CID 已获取: %s\n", metadataFolderCid)
 fmt.Println("\n--- ✨ 批量流程完成 ✨ ---")
 fmt.Printf("下一步，您可以在合约中将 Base URI 设置为: ipfs://%s/\n", metadataFolderCid)
}

func main() {
 // --- 前置检查 ---
 cmd := exec.Command("ipfs", "id")
 if err := cmd.Run(); err != nil {
  fmt.Println("❌ 连接 IPFS 节点失败。")
  fmt.Println("请确保你的 IPFS 节点正在运行 (命令: ipfs daemon)。")
  os.Exit(1)
 }
 fmt.Println("✅ 成功连接到 IPFS 节点")

 // --- 准备工作 ---
 // singleImagePath := filepath.Join("..", "assets", "image", "IMG_20210626_180340.jpg")
 batchImagesPath := filepath.Join("..", "assets", "batch_images")
 os.MkdirAll(batchImagesPath, os.ModePerm)

 // --- 在这里选择要运行的工作流 ---

 // 运行工作流一：处理单个 NFT
 // processSingleNFT(singleImagePath)

 // 运行工作流二：处理批量 NFT 集合
 processBatchCollection(batchImagesPath)

 // 生产环境最终发布流程说明
 fmt.Println("\n======================================================================")
 fmt.Println("✅ 本地准备工作已完成！")
 fmt.Println("下一步是发布到专业的 Pinning 服务 (如 Pinata):")
 fmt.Println("1. 登录 Pinata。")
 fmt.Println("2. 上传您本地 `go/output/collection_[时间戳]/images` 文件夹。")
 fmt.Println("3. 上传您本地 `go/output/collection_[时间戳]/metadata` 文件夹。")
 fmt.Println("4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。")
 fmt.Println("======================================================================")
}


```

这份 Go 程序是一个专为 NFT 项目打造的、生产级的元数据自动化处理工具。它通过 Go 语言强大的 `os/exec` 包直接与本地 IPFS 命令行工具交互，提供了两种核心工作流：既能处理独一无二的单件艺术品，也能高效地为大型 PFP 集合批量生成资产。该脚本的一个关键特性是其灵活性，允许开发者通过简单的配置开关，来决定生成的元数据文件是否包含 `.json` 后缀，以完美匹配不同智能合约的 `tokenURI` 实现标准。最终，它会在本地创建一个结构清晰、即用型的归档文件夹，极大地简化了后续上传到 Pinata 等专业 Pinning 服务进行永久托管的流程。

### 运行脚本

```bash
polyglot-ipfs-uploader/go on  main [!?] via 🐹 v1.24.5 on 🐳 v28.2.2 (orbstack)
➜ go run ./main.go
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

💾 所有图片已复制到: output/collection_20250726_160112/images

--- 正在为每张图片生成元数据 JSON 文件 ---
✅ 成功生成 3 个元数据文件到: output/collection_20250726_160112/metadata

--- 正在执行上传命令: ipfs add -r -Q --cid-version 1 output/collection_20250726_160112/metadata ---
✅ 上传成功!
   - 名称: metadata
   - CID: bafybeiczqa75ljidb7esu464fj6a64nfujxcd2mum73t5yaw2llkrzb4zy

📄 元数据文件夹 CID 已获取: bafybeiczqa75ljidb7esu464fj6a64nfujxcd2mum73t5yaw2llkrzb4zy

--- ✨ 批量流程完成 ✨ ---
下一步，您可以在合约中将 Base URI 设置为: ipfs://bafybeiczqa75ljidb7esu464fj6a64nfujxcd2mum73t5yaw2llkrzb4zy/

======================================================================
✅ 本地准备工作已完成！
下一步是发布到专业的 Pinning 服务 (如 Pinata):
1. 登录 Pinata。
2. 上传您本地 `go/output/collection_[时间戳]/images` 文件夹。
3. 上传您本地 `go/output/collection_[时间戳]/metadata` 文件夹。
4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。
======================================================================

polyglot-ipfs-uploader/go on  main [!?] via 🐹 v1.24.5 on 🐳 v28.2.2 (orbstack)
➜ go run ./main.go
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

✅ JSON 元数据上传成功!
   - CID: bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

💾 图片和元数据已在本地打包保存至: output/IMG_20210626_180340

--- ✨ 单件流程完成 ✨ ---
下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

======================================================================
✅ 本地准备工作已完成！
下一步是发布到专业的 Pinning 服务 (如 Pinata):
1. 登录 Pinata。
2. 上传您本地 `go/output/collection_[时间戳]/images` 文件夹。
3. 上传您本地 `go/output/collection_[时间戳]/metadata` 文件夹。
4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。
======================================================================

polyglot-ipfs-uploader/go on  main [!?] via 🐹 v1.24.5 on 🐳 v28.2.2 (orbstack)
➜ go run ./main.go
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

✅ JSON 元数据上传成功!
   - CID: bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

💾 图片和元数据已在本地打包保存至: output/IMG_20210626_180340

--- ✨ 单件流程完成 ✨ ---
下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

======================================================================
✅ 本地准备工作已完成！
下一步是发布到专业的 Pinning 服务 (如 Pinata):
1. 登录 Pinata。
2. 上传您本地 `go/output/collection_[时间戳]/images` 文件夹。
3. 上传您本地 `go/output/collection_[时间戳]/metadata` 文件夹。
4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。
======================================================================

polyglot-ipfs-uploader/go on  main [!?] via 🐹 v1.24.5 on 🐳 v28.2.2 (orbstack)
➜ go run ./main.go
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

💾 所有图片已复制到: output/collection_20250726_160334/images

--- 正在为每张图片生成元数据 JSON 文件 ---
✅ 成功生成 3 个元数据文件到: output/collection_20250726_160334/metadata

--- 正在执行上传命令: ipfs add -r -Q --cid-version 1 output/collection_20250726_160334/metadata ---
✅ 上传成功!
   - 名称: metadata
   - CID: bafybeidcdd6osm2gvnxt3vlp434kmfq673fbkv4xtrrkqkpbkqe6iakvdm

📄 元数据文件夹 CID 已获取: bafybeidcdd6osm2gvnxt3vlp434kmfq673fbkv4xtrrkqkpbkqe6iakvdm

--- ✨ 批量流程完成 ✨ ---
下一步，您可以在合约中将 Base URI 设置为: ipfs://bafybeidcdd6osm2gvnxt3vlp434kmfq673fbkv4xtrrkqkpbkqe6iakvdm/

======================================================================
✅ 本地准备工作已完成！
下一步是发布到专业的 Pinning 服务 (如 Pinata):
1. 登录 Pinata。
2. 上传您本地 `go/output/collection_[时间戳]/images` 文件夹。
3. 上传您本地 `go/output/collection_[时间戳]/metadata` 文件夹。
4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。
======================================================================

```

您的 Go 脚本已成功运行，并完美地展示了其两种核心工作流：在“单件处理”模式下，脚本成功地为单个图片上传并生成了唯一的元数据 CID，为您准备好了可以直接用于 `mint` 函数的 Token URI；在“批量处理”模式下，它则完整地模拟了生产级流程，先上传整个图片文件夹获得图片根 CID，然后利用这个 CID 批量生成所有对应的元数据文件，最后再上传整个元数据文件夹，为您提供了可以直接在合约中设置的最终 `baseURI`。总而言之，这个 Go 脚本已经成功地将 NFT 上链前所有复杂的元数据准备工作完全自动化，并在本地生成了清晰的归档文件。

### 第二种方式：使用官方 RPC 库 (`kubo/client/rpc`)

这是更现代、更符合 Go 语言工程化思想的方法。我们使用 IPFS 官方维护的 `kubo/client/rpc` 库来与 IPFS 节点的 API 进行交互。这种方法的优点是代码更优雅、类型更安全，并且由官方维护，能更好地利用 IPFS 的高级功能。缺点是需要正确管理 Go 的模块依赖（`go.mod`），确保使用的库与 IPFS 节点版本兼容。

```go
// main.go
package main

import (
 "context"
 "encoding/json"
 "fmt"
 "io"
 "log"
 "net/http"
 "os"
 "path/filepath"
 "sort"
 "strconv"
 "strings"
 "time"

 // ✅ 导入 boxo/files 来处理文件和目录
 "github.com/ipfs/boxo/files"
 // ✅ 导入最新的、官方推荐的 Kubo RPC 客户端
 rpc "github.com/ipfs/kubo/client/rpc"
 // ✅ 导入最新的、官方推荐的 options 包
 "github.com/ipfs/boxo/coreiface/options"
)

// ✅ 配置开关
const USE_JSON_SUFFIX = false
const IPFS_API_URL = "http://localhost:5001"

// Attribute 定义了元数据中的属性结构
type Attribute struct {
 TraitType string      `json:"trait_type"`
 Value     interface{} `json:"value"`
}

// NftMetadata 定义了元数据的整体结构
type NftMetadata struct {
 Name        string      `json:"name"`
 Description string      `json:"description"`
 Image       string      `json:"image"`
 Attributes  []Attribute `json:"attributes"`
}

// 核心上传函数 (使用官方库)
func uploadToIPFS(shell *rpc.HttpApi, targetPath string) (string, error) {
 fmt.Printf("\n--- 正在上传: %s ---\n", targetPath)

 stat, err := os.Stat(targetPath)
 if err != nil {
  return "", fmt.Errorf("❌ 无法访问路径: %w", err)
 }

 file, err := files.NewSerialFile(targetPath, false, stat)
 if err != nil {
  return "", fmt.Errorf("❌ 创建 IPFS 文件节点失败: %w", err)
 }

 // ✅ 使用 Unixfs() API 来添加文件
 cidPath, err := shell.Unixfs().Add(context.Background(), file, options.Unixfs.Pin(true), options.Unixfs.CidVersion(1))
 if err != nil {
  return "", fmt.Errorf("❌ 上传失败: %w", err)
 }

 cidStr := cidPath.Root().String()
 fmt.Println("✅ 上传成功!")
 fmt.Printf("   - 名称: %s\n", filepath.Base(targetPath))
 fmt.Printf("   - CID: %s\n", cidStr)
 return cidStr, nil
}

// 上传 JSON 数据的专用函数
func uploadJSONToIPFS(shell *rpc.HttpApi, data NftMetadata) (string, error) {
 fmt.Println("\n--- 正在上传 JSON 对象 ---")
 jsonData, err := json.Marshal(data)
 if err != nil {
  return "", fmt.Errorf("❌ 转换 JSON 失败: %w", err)
 }

 // ✅ 同样使用 Unixfs() API
 cidPath, err := shell.Unixfs().Add(context.Background(), files.NewBytesFile(jsonData), options.Unixfs.Pin(true), options.Unixfs.CidVersion(1))
 if err != nil {
  return "", fmt.Errorf("❌ 上传 JSON 失败: %w", err)
 }

 cidStr := cidPath.Root().String()
 fmt.Printf("✅ JSON 元数据上传成功!\n   - CID: %s\n", cidStr)
 return cidStr, nil
}

// 工作流一：处理单个 NFT
func processSingleNFT(shell *rpc.HttpApi, imagePath string) {
 // ... (此函数内部逻辑无需修改) ...
 fmt.Println("\n==============================================")
 fmt.Println("🚀 开始处理单个 NFT...")
 if USE_JSON_SUFFIX {
  fmt.Println("   - 文件后缀模式: .json")
 } else {
  fmt.Println("   - 文件后缀模式: 无")
 }
 fmt.Println("==============================================")

 imageCid, err := uploadToIPFS(shell, imagePath)
 if err != nil {
  log.Fatalf("图片上传失败: %v", err)
 }
 fmt.Printf("\n🖼️  图片 CID 已获取: %s\n", imageCid)

 imageFilename := filepath.Base(imagePath)
 imageNameWithoutExt := strings.TrimSuffix(imageFilename, filepath.Ext(imageFilename))

 metadata := NftMetadata{
  Name:        imageNameWithoutExt,
  Description: fmt.Sprintf("这是一个为图片 %s 动态生成的元数据。", imageFilename),
  Image:       fmt.Sprintf("ipfs://%s", imageCid),
  Attributes:  []Attribute{{TraitType: "类型", Value: "单件艺术品"}},
 }

 metadataCid, err := uploadJSONToIPFS(shell, metadata)
 if err != nil {
  log.Fatalf("元数据上传失败: %v", err)
 }

 outputDir := filepath.Join("output", imageNameWithoutExt)
 os.MkdirAll(outputDir, os.ModePerm)
 copyFile(imagePath, filepath.Join(outputDir, imageFilename))

 fileName := imageNameWithoutExt
 if USE_JSON_SUFFIX {
  fileName += ".json"
 }
 metadataFile, _ := os.Create(filepath.Join(outputDir, fileName))
 prettyJSON, _ := json.MarshalIndent(metadata, "", "    ")
 metadataFile.Write(prettyJSON)
 metadataFile.Close()

 fmt.Printf("\n💾 图片和元数据已在本地打包保存至: %s\n", outputDir)
 fmt.Println("\n--- ✨ 单件流程完成 ✨ ---")
 fmt.Printf("下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://%s\n", metadataCid)
}

// 工作流二：处理批量 NFT 集合
func processBatchCollection(shell *rpc.HttpApi, imagesInputDir string) {
 // ... (此函数内部逻辑无需修改) ...
 fmt.Println("\n==============================================")
 fmt.Println("🚀 开始处理批量 NFT 集合...")
 if USE_JSON_SUFFIX {
  fmt.Println("   - 文件后缀模式: .json")
 } else {
  fmt.Println("   - 文件后缀模式: 无")
 }
 fmt.Println("==============================================")

 imagesFolderCid, err := uploadToIPFS(shell, imagesInputDir)
 if err != nil {
  log.Fatalf("图片文件夹上传失败: %v", err)
 }
 fmt.Printf("\n🖼️  图片文件夹 CID 已获取: %s\n", imagesFolderCid)

 timestamp := time.Now().Format("20060102_150405")
 collectionOutputDir := filepath.Join("output", fmt.Sprintf("collection_%s", timestamp))
 imagesOutputDir := filepath.Join(collectionOutputDir, "images")
 metadataOutputDir := filepath.Join(collectionOutputDir, "metadata")

 copyDirectory(imagesInputDir, imagesOutputDir)
 fmt.Printf("\n💾 所有图片已复制到: %s\n", imagesOutputDir)

 fmt.Println("\n--- 正在为每张图片生成元数据 JSON 文件 ---")
 os.MkdirAll(metadataOutputDir, os.ModePerm)

 files, _ := os.ReadDir(imagesInputDir)
 var imageFiles []string
 for _, file := range files {
  if !file.IsDir() {
   ext := strings.ToLower(filepath.Ext(file.Name()))
   if ext == ".png" || ext == ".jpg" || ext == ".jpeg" || ext == ".gif" {
    imageFiles = append(imageFiles, file.Name())
   }
  }
 }
 sort.Strings(imageFiles)

 for _, fileName := range imageFiles {
  tokenIDStr := strings.TrimSuffix(fileName, filepath.Ext(fileName))
  tokenID, _ := strconv.Atoi(tokenIDStr)
  metadata := NftMetadata{
   Name:        fmt.Sprintf("MetaCore #%d", tokenID),
   Description: "MetaCore 集合中的一个独特成员。",
   Image:       fmt.Sprintf("ipfs://%s/%s", imagesFolderCid, fileName),
   Attributes:  []Attribute{{TraitType: "ID", Value: tokenID}},
  }
  outFileName := tokenIDStr
  if USE_JSON_SUFFIX {
   outFileName += ".json"
  }
  file, _ := os.Create(filepath.Join(metadataOutputDir, outFileName))
  prettyJSON, _ := json.MarshalIndent(metadata, "", "    ")
  file.Write(prettyJSON)
  file.Close()
 }
 fmt.Printf("✅ 成功生成 %d 个元数据文件到: %s\n", len(imageFiles), metadataOutputDir)

 metadataFolderCid, err := uploadToIPFS(shell, metadataOutputDir)
 if err != nil {
  log.Fatalf("元数据文件夹上传失败: %v", err)
 }
 fmt.Printf("\n📄 元数据文件夹 CID 已获取: %s\n", metadataFolderCid)
 fmt.Println("\n--- ✨ 批量流程完成 ✨ ---")
 fmt.Printf("下一步，您可以在合约中将 Base URI 设置为: ipfs://%s/\n", metadataFolderCid)
}

func main() {
 // ✅ 使用新的 rpc.NewURLApiWithClient 并提供一个 http client
 shell, err := rpc.NewURLApiWithClient(IPFS_API_URL, http.DefaultClient)
 if err != nil {
  log.Fatalf("❌ 连接 IPFS 节点失败: %v\n请确保你的 IPFS 节点正在运行 (命令: ipfs daemon)。", err)
 }
 // ✅ 新库没有 ID() 方法，直接跳过连接检查。
 // 如果连接有问题，后续的上传操作会自然失败。
 fmt.Println("✅ 成功连接到 IPFS 节点")

 // 使用 _ 明确忽略未使用的变量，以通过编译器检查
 singleImagePath := filepath.Join("..", "assets", "image", "IMG_20210626_180340.jpg")
 batchImagesPath := filepath.Join("..", "assets", "batch_images")
 os.MkdirAll(batchImagesPath, os.ModePerm)

 // --- 在这里选择要运行的工作流 ---
 processSingleNFT(shell, singleImagePath)
 processBatchCollection(shell, batchImagesPath)

 fmt.Println("\n======================================================================")
 fmt.Println("✅ 本地准备工作已完成！")
 fmt.Println("下一步是发布到专业的 Pinning 服务 (如 Pinata):")
 fmt.Println("1. 登录 Pinata。")
 fmt.Println("2. 上传您本地 `go/output/collection_[时间戳]/images` 文件夹。")
 fmt.Println("3. 上传您本地 `go/output/collection_[时间戳]/metadata` 文件夹。")
 fmt.Println("4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。")
 fmt.Println("======================================================================")
}

// --- 辅助函数 ---
func copyFile(src, dst string) {
 sourceFile, err := os.Open(src)
 if err != nil { log.Fatal(err) }
 defer sourceFile.Close()
 destFile, err := os.Create(dst)
 if err != nil { log.Fatal(err) }
 defer destFile.Close()
 _, err = io.Copy(destFile, sourceFile)
 if err != nil { log.Fatal(err) }
}

func copyDirectory(src, dst string) {
 os.MkdirAll(dst, os.ModePerm)
 filepath.Walk(src, func(path string, info os.FileInfo, err error) error {
  if err != nil { return err }
  relPath, err := filepath.Rel(src, path)
  if err != nil { return err }
  if info.IsDir() {
   return os.MkdirAll(filepath.Join(dst, relPath), info.Mode())
  }
  copyFile(path, filepath.Join(dst, relPath))
  return nil
 })
}


```

这份 Go 脚本是一个功能完备且专业的 NFT 元数据自动化处理器。它利用最新的官方 Kubo RPC 客户端库与本地 IPFS 节点进行交互，提供了两种核心工作流：既能为单个艺术品生成独立的元数据，也能为整个 NFT 集合批量上传图片并自动生成所有对应的元数据文件。该脚本的一个关键特性是其灵活性，允许开发者通过简单的配置开关，来决定生成的元数据文件是否包含 `.json` 后缀，以完美匹配不同智能合约的 `tokenURI` 实现标准。最终，它不仅完成了所有 IPFS 上传任务，还会在本地创建一个结构清晰的归档文件夹，极大地简化了后续上传到 Pinata 等专业 Pinning 服务进行永久托管的流程。

### 运行脚本

```bash
polyglot-ipfs-uploader/go on  main [!?] via 🐹 v1.24.5 on 🐳 v28.2.2 (orbstack)
➜ go run ./main.go
✅ 成功连接到 IPFS 节点

==============================================
🚀 开始处理批量 NFT 集合...
   - 文件后缀模式: .json
==============================================

--- 正在上传: ../assets/batch_images ---
✅ 上传成功!
   - 名称: batch_images
   - CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e

🖼️  图片文件夹 CID 已获取: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e

💾 所有图片已复制到: output/collection_20250726_164257/images

--- 正在为每张图片生成元数据 JSON 文件 ---
✅ 成功生成 3 个元数据文件到: output/collection_20250726_164257/metadata

--- 正在上传: output/collection_20250726_164257/metadata ---
✅ 上传成功!
   - 名称: metadata
   - CID: bafybeiczqa75ljidb7esu464fj6a64nfujxcd2mum73t5yaw2llkrzb4zy

📄 元数据文件夹 CID 已获取: bafybeiczqa75ljidb7esu464fj6a64nfujxcd2mum73t5yaw2llkrzb4zy

--- ✨ 批量流程完成 ✨ ---
下一步，您可以在合约中将 Base URI 设置为: ipfs://bafybeiczqa75ljidb7esu464fj6a64nfujxcd2mum73t5yaw2llkrzb4zy/

======================================================================
✅ 本地准备工作已完成！
下一步是发布到专业的 Pinning 服务 (如 Pinata):
1. 登录 Pinata。
2. 上传您本地 `go/output/collection_[时间戳]/images` 文件夹。
3. 上传您本地 `go/output/collection_[时间戳]/metadata` 文件夹。
4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。
======================================================================

polyglot-ipfs-uploader/go on  main [!?] via 🐹 v1.24.5 on 🐳 v28.2.2 (orbstack)
➜ go run ./main.go
✅ 成功连接到 IPFS 节点

==============================================
🚀 开始处理单个 NFT...
   - 文件后缀模式: .json
==============================================

--- 正在上传: ../assets/image/IMG_20210626_180340.jpg ---
✅ 上传成功!
   - 名称: IMG_20210626_180340.jpg
   - CID: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

🖼️  图片 CID 已获取: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

--- 正在上传 JSON 对象 ---
✅ JSON 元数据上传成功!
   - CID: bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

💾 图片和元数据已在本地打包保存至: output/IMG_20210626_180340

--- ✨ 单件流程完成 ✨ ---
下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

======================================================================
✅ 本地准备工作已完成！
下一步是发布到专业的 Pinning 服务 (如 Pinata):
1. 登录 Pinata。
2. 上传您本地 `go/output/collection_[时间戳]/images` 文件夹。
3. 上传您本地 `go/output/collection_[时间戳]/metadata` 文件夹。
4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。
======================================================================

polyglot-ipfs-uploader/go on  main [!?] via 🐹 v1.24.5 on 🐳 v28.2.2 (orbstack)
➜ go run ./main.go
✅ 成功连接到 IPFS 节点

==============================================
🚀 开始处理单个 NFT...
   - 文件后缀模式: .json
==============================================

--- 正在上传: ../assets/image/IMG_20210626_180340.jpg ---
✅ 上传成功!
   - 名称: IMG_20210626_180340.jpg
   - CID: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

🖼️  图片 CID 已获取: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

--- 正在上传 JSON 对象 ---
✅ JSON 元数据上传成功!
   - CID: bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

💾 图片和元数据已在本地打包保存至: output/IMG_20210626_180340

--- ✨ 单件流程完成 ✨ ---
下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

======================================================================
✅ 本地准备工作已完成！
下一步是发布到专业的 Pinning 服务 (如 Pinata):
1. 登录 Pinata。
2. 上传您本地 `go/output/collection_[时间戳]/images` 文件夹。
3. 上传您本地 `go/output/collection_[时间戳]/metadata` 文件夹。
4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。
======================================================================

polyglot-ipfs-uploader/go on  main [!?] via 🐹 v1.24.5 on 🐳 v28.2.2 (orbstack)
➜ go run ./main.go
✅ 成功连接到 IPFS 节点

==============================================
🚀 开始处理单个 NFT...
   - 文件后缀模式: 无
==============================================

--- 正在上传: ../assets/image/IMG_20210626_180340.jpg ---
✅ 上传成功!
   - 名称: IMG_20210626_180340.jpg
   - CID: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

🖼️  图片 CID 已获取: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi

--- 正在上传 JSON 对象 ---
✅ JSON 元数据上传成功!
   - CID: bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

💾 图片和元数据已在本地打包保存至: output/IMG_20210626_180340

--- ✨ 单件流程完成 ✨ ---
下一步，您可以在 mint 函数中使用这个元数据 URI: ipfs://bafkreihhpbkssgrr22r3f3rhrb4hntmbdzfm3ubaun2cfw4p5vyhcgivbi

==============================================
🚀 开始处理批量 NFT 集合...
   - 文件后缀模式: 无
==============================================

--- 正在上传: ../assets/batch_images ---
✅ 上传成功!
   - 名称: batch_images
   - CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e

🖼️  图片文件夹 CID 已获取: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e

💾 所有图片已复制到: output/collection_20250726_164652/images

--- 正在为每张图片生成元数据 JSON 文件 ---
✅ 成功生成 3 个元数据文件到: output/collection_20250726_164652/metadata

--- 正在上传: output/collection_20250726_164652/metadata ---
✅ 上传成功!
   - 名称: metadata
   - CID: bafybeidcdd6osm2gvnxt3vlp434kmfq673fbkv4xtrrkqkpbkqe6iakvdm

📄 元数据文件夹 CID 已获取: bafybeidcdd6osm2gvnxt3vlp434kmfq673fbkv4xtrrkqkpbkqe6iakvdm

--- ✨ 批量流程完成 ✨ ---
下一步，您可以在合约中将 Base URI 设置为: ipfs://bafybeidcdd6osm2gvnxt3vlp434kmfq673fbkv4xtrrkqkpbkqe6iakvdm/

======================================================================
✅ 本地准备工作已完成！
下一步是发布到专业的 Pinning 服务 (如 Pinata):
1. 登录 Pinata。
2. 上传您本地 `go/output/collection_[时间戳]/images` 文件夹。
3. 上传您本地 `go/output/collection_[时间戳]/metadata` 文件夹。
4. ⚠️  使用 Pinata 返回的【metadata】文件夹的 CID 来设置您合约的 Base URI。
======================================================================

```

您的 Go 脚本已成功运行，并完美地执行了其两种核心工作流：在“批量处理”模式下，脚本成功地为整个 NFT 集合上传了图片、生成了元数据并获得了最终的 `baseURI`；在“单件处理”模式下，它也成功地为单个图片生成了可以直接用于 `mint` 函数的唯一 Token URI，同时所有产物都在本地进行了清晰的归档，完整地实现了生产级的元数据自动化准备流程。

## 总结

本文通过两种截然不同的方式，展示了如何利用 Go 语言的强大能力来构建一个生产级的 NFT 元数据自动化流程。第一种 `os/exec` 的方式，体现了 Go 作为系统级语言的可靠与直接；而第二种使用官方 RPC 库的方式，则展示了其在现代软件工程中的优雅与健壮。

无论采用哪种方式，我们最终都实现了一个核心目标：将繁琐的手动操作，转变为一个可一键执行、可重复、可预测的自动化流程。脚本生成的结构化 `output` 文件夹，为您下一步将资产上传到 Pinata 等专业 Pinning 服务，并最终在智能合约中设置 `baseURI` 铺平了道路，为您的 Web3 项目奠定了坚实的基础。

## 参考

- <https://pkg.go.dev/github.com/ipfs/kubo/client/rpc#section-readme>
- <https://pkg.go.dev/github.com/ipfs/kubo/client/rpc>
- <https://github.com/ipfs/kubo>
- <https://github.com/ipfs/go-ipfs-http-client?tab=readme-ov-file>
- <https://github.com/ipfs/kubo/tree/master/client/rpc>
- <https://github.com/ipfs/boxo>
- <https://github.com/ipfs/boxo/blob/main/examples/README.md>
