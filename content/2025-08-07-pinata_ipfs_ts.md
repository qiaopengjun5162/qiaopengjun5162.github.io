+++
title = "TypeScript NFT 开发实战：从零构建 Pinata IPFS 自动化上传工具 (附完整源码)"
description = "TypeScript NFT 开发实战：从零构建 Pinata IPFS 自动化上传工具 (附完整源码)"
date = 2025-08-07T03:35:28Z
[taxonomies]
categories = ["Web3", "NFT", "Pinata", "IPFS"]
tags = ["Web3", "NFT", "Pinata", "IPFS"]
+++

<!-- more -->

# **TypeScript NFT 开发实战：从零构建 Pinata IPFS 自动化上传工具 (附完整源码)**

对于每一位NFT项目开发者来说，将成百上千的图片和对应的元数据（Metadata）上传到IPFS都是一个相当繁琐且容易出错的环节。手动一个个上传不仅耗时耗力，还可能因为网络问题或操作失误导致数据混乱。

我们最初在《NFT 开发核心步骤》一文中，演示了如何与**本地IPFS节点**交互，这为理解其原理打下了基础。但要将流程真正投入**生产环境**，我们需要更专业的解决方案。

为了彻底解决这个痛点，我用 TypeScript 开发并开源了一款专为 **Pinata** 设计的自动化上传工具 🧰。它不仅能实现图片和元数据的一键批量上传，还能自动生成兼容不同智能合约的元数据文件。

这篇文章将带你从配置、代码实现到实战测试，全面解析这款工具，让你彻底告别繁琐的上传工作，专注于更有创造性的开发！🚀

一款高效的 TypeScript NFT 元数据上传工具，专为 Pinata IPFS 打造。支持单文件与批量上传，自动生成图片和元数据，并兼容带/不带后缀的合约。内置日志、重试、进度跟踪等功能，极大简化NFT发布流程，是开发者的效率利器。

## 项目概览

这是一个用于将 NFT 图片和元数据自动化上传到 Pinata IPFS 的 TypeScript 工具。在深入代码之前，我们先看一下它的整体结构和环境配置。

### 查看项目目录结构

```bash
➜ tree . -L 6 -I "migrations|mochawesome-report|.anchor|docs|target|node_modules"
.
├── package.json
├── pnpm-lock.yaml
├── README.md
├── src
│   └── index.ts
└── tsconfig.json

2 directories, 5 files

```

### 环境配置

创建 `.env` 文件：

```bash
# Pinata 配置
PINATA_JWT=your_pinata_jwt_here
PINATA_GATEWAY=your_pinata_gateway_here

# 元数据配置（可选）
# 可选值: .json, .txt, .md, .xml 等
# 默认值: .json
METADATA_SUFFIX=.json

# 上传配置（可选）
UPLOAD_TIMEOUT=300000    # 上传超时时间（毫秒，默认5分钟）
MAX_RETRIES=3           # 最大重试次数（默认3次）
RETRY_DELAY=5000        # 重试延迟（毫秒，默认5秒）
```

### `package.json` 文件

```json
{
  "name": "pinata-nft-uploader",
  "version": "1.0.0",
  "description": "A TypeScript tool for uploading NFT images and metadata to Pinata IPFS",
  "main": "index.js",
  "scripts": {
    "start": "ts-node src/index.ts",
    "batch": "ts-node src/index.ts batch",
    "batch:no-suffix": "ts-node src/index.ts batch --no-suffix",
    "single": "ts-node src/index.ts single",
    "test": "ts-node src/index.ts test",
    "pin": "ts-node src/index.ts pin",
    "queue": "ts-node src/index.ts queue"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "packageManager": "pnpm@10.8.1",
  "dependencies": {
    "dotenv": "^17.2.1",
    "pinata": "^2.4.9"
  },
  "devDependencies": {
    "@types/node": "^24.1.0",
    "ts-node": "^10.9.2",
    "typescript": "^5.8.3"
  }
}

```

### 代码实现`src/index.ts`

```ts
import { PinataSDK } from "pinata";
import * as fs from "fs/promises";
import { existsSync } from "fs";
import * as path from "path";
import * as dotenv from "dotenv";

// --- 类型定义 ---
interface UploadResult {
  cid: string;
  size?: number;
  timestamp: string;
}

interface BatchUploadResult {
  timestamp: string;
  imagesFolderCid: string;
  metadataWithSuffixCid?: string;
  metadataWithoutSuffixCid?: string;
  imageCount: number;
  metadataFiles: Array<{
    tokenId: string;
    metadataFileWithSuffix: string;
    metadataFileWithoutSuffix: string;
  }>;
  totalSize: number;
  uploadTime: number;
}

interface SingleUploadResult {
  timestamp: string;
  imageCid: string;
  metadataCid: string;
  imageUrl: string;
  metadataUrl: string;
  gatewayImageUrl: string;
  gatewayMetadataUrl: string;
  metadata: any;
  uploadTime: number;
}

interface Config {
  pinataJwt: string;
  pinataGateway: string;
  metadataSuffix: string;
  uploadTimeout: number;
  maxRetries: number;
  retryDelay: number;
  maxFileSize: number;
  maxTotalSize: number;
}

// --- 配置管理 ---
class ConfigManager {
  private config: Config;

  constructor() {
    dotenv.config();
    this.config = this.loadConfig();
  }

  private loadConfig(): Config {
    const pinataJwt = process.env.PINATA_JWT;
    const pinataGateway = process.env.PINATA_GATEWAY;

    if (!pinataJwt) {
      throw new Error("❌ 请在 .env 文件中设置 PINATA_JWT");
    }
    if (!pinataGateway) {
      throw new Error("❌ 请在 .env 文件中设置 PINATA_GATEWAY");
    }

    return {
      pinataJwt,
      pinataGateway,
      metadataSuffix: process.env.METADATA_SUFFIX || ".json",
      uploadTimeout: parseInt(process.env.UPLOAD_TIMEOUT || "300000"),
      maxRetries: parseInt(process.env.MAX_RETRIES || "3"),
      retryDelay: parseInt(process.env.RETRY_DELAY || "5000"),
      maxFileSize: parseInt(process.env.MAX_FILE_SIZE || "52428800"), // 50MB
      maxTotalSize: parseInt(process.env.MAX_TOTAL_SIZE || "524288000"), // 500MB
    };
  }

  getConfig(): Config {
    return this.config;
  }
}

// --- 日志管理 ---
class Logger {
  private static instance: Logger;
  private logLevel: "info" | "warn" | "error" | "debug" = "info";

  private constructor() {}

  static getInstance(): Logger {
    if (!Logger.instance) {
      Logger.instance = new Logger();
    }
    return Logger.instance;
  }

  setLogLevel(level: "info" | "warn" | "error" | "debug") {
    this.logLevel = level;
  }

  private shouldLog(level: "info" | "warn" | "error" | "debug"): boolean {
    const levels = { debug: 0, info: 1, warn: 2, error: 3 };
    return levels[level] >= levels[this.logLevel];
  }

  log(message: string, level: "info" | "warn" | "error" | "debug" = "info") {
    if (!this.shouldLog(level)) return;

    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] [${level.toUpperCase()}] ${message}`;

    switch (level) {
      case "error":
        console.error(logMessage);
        break;
      case "warn":
        console.warn(logMessage);
        break;
      case "debug":
        console.debug(logMessage);
        break;
      default:
        console.log(logMessage);
    }
  }

  info(message: string) {
    this.log(message, "info");
  }

  warn(message: string) {
    this.log(message, "warn");
  }

  error(message: string) {
    this.log(message, "error");
  }

  debug(message: string) {
    this.log(message, "debug");
  }
}

// --- 进度显示 ---
class ProgressTracker {
  private startTime: number;
  private intervalId?: NodeJS.Timeout;
  private logger: Logger;

  constructor() {
    this.startTime = Date.now();
    this.logger = Logger.getInstance();
  }

  startProgress(message: string) {
    this.logger.info(message);
    this.intervalId = setInterval(() => {
      const elapsed = Math.floor((Date.now() - this.startTime) / 1000);
      this.logger.info(`⏳ 进行中... 已用时: ${elapsed} 秒`);
    }, 10000); // 每10秒显示一次进度
  }

  stopProgress() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = undefined;
    }
    const totalTime = Math.floor((Date.now() - this.startTime) / 1000);
    this.logger.info(`✅ 完成! 总用时: ${totalTime} 秒`);
  }

  getElapsedTime(): number {
    return Math.floor((Date.now() - this.startTime) / 1000);
  }
}

// --- 文件工具类 ---
class FileUtils {
  private static logger = Logger.getInstance();

  static async getFileSize(filePath: string): Promise<number> {
    try {
      const stats = await fs.stat(filePath);
      return stats.size;
    } catch (error) {
      this.logger.error(`获取文件大小失败: ${filePath} - ${error}`);
      throw error;
    }
  }

  static async validateFiles(
    files: string[],
    maxFileSize: number,
    maxTotalSize: number
  ): Promise<{
    totalSize: number;
    warnings: string[];
  }> {
    let totalSize = 0;
    const warnings: string[] = [];

    for (const file of files) {
      try {
        const size = await this.getFileSize(file);
        totalSize += size;

        if (size > maxFileSize) {
          warnings.push(
            `文件 ${path.basename(file)} 过大 (${(size / 1024 / 1024).toFixed(
              2
            )} MB)`
          );
        }
      } catch (error) {
        this.logger.warn(`无法获取文件大小: ${file}`);
      }
    }

    if (totalSize > maxTotalSize) {
      warnings.push(
        `总文件大小过大 (${(totalSize / 1024 / 1024).toFixed(2)} MB)`
      );
    }

    return { totalSize, warnings };
  }

  static async createDirectory(dirPath: string): Promise<void> {
    try {
      await fs.mkdir(dirPath, { recursive: true });
    } catch (error) {
      this.logger.error(`创建目录失败: ${dirPath} - ${error}`);
      throw error;
    }
  }

  static async cleanupDirectory(dirPath: string): Promise<void> {
    try {
      if (existsSync(dirPath)) {
        await fs.rm(dirPath, { recursive: true, force: true });
      }
    } catch (error) {
      this.logger.warn(`清理目录失败: ${dirPath} - ${error}`);
    }
  }
}

// --- Pinata 上传器类 ---
class PinataUploader {
  private pinata: PinataSDK;
  private config: Config;
  private logger: Logger;

  constructor(config: Config) {
    this.config = config;
    this.pinata = new PinataSDK({
      pinataJwt: config.pinataJwt,
      pinataGateway: config.pinataGateway,
    });
    this.logger = Logger.getInstance();
  }

  async testAuthentication(): Promise<boolean> {
    try {
      const result = await this.pinata.testAuthentication();
      this.logger.info("✅ Pinata 认证成功!");
      return true;
    } catch (error) {
      this.logger.error(`Pinata 认证失败: ${error}`);
      return false;
    }
  }

  async uploadDirectoryWithRetry(dirPath: string): Promise<string> {
    this.logger.info(`📁 正在上传文件夹: ${dirPath}`);

    let lastError: Error | null = null;

    for (let attempt = 1; attempt <= this.config.maxRetries; attempt++) {
      try {
        const files = await this.readDirectoryFiles(dirPath);
        const totalSizeBytes = files.reduce((sum, file) => sum + file.size, 0);
        let sizeDisplay: string;
        if (totalSizeBytes < 1024) {
          sizeDisplay = `${totalSizeBytes} B`;
        } else if (totalSizeBytes < 1024 * 1024) {
          sizeDisplay = `${(totalSizeBytes / 1024).toFixed(2)} KB`;
        } else {
          sizeDisplay = `${(totalSizeBytes / 1024 / 1024).toFixed(2)} MB`;
        }
        this.logger.info(
          `📁 找到 ${files.length} 个文件，总大小: ${sizeDisplay}`
        );

        const progress = new ProgressTracker();
        progress.startProgress("🚀 开始上传到 Pinata...");

        try {
          const response = (await Promise.race([
            this.pinata.upload.public.fileArray(files),
            new Promise<never>((_, reject) =>
              setTimeout(
                () =>
                  reject(new Error("上传超时，请检查网络连接或尝试压缩文件")),
                this.config.uploadTimeout
              )
            ),
          ])) as any;

          progress.stopProgress();
          this.logger.info(`✅ 文件夹上传成功! CID: ${response.cid}`);
          return response.cid;
        } catch (error) {
          progress.stopProgress();
          throw error;
        }
      } catch (error) {
        lastError = error as Error;
        this.logger.error(`第 ${attempt} 次上传失败: ${error}`);

        if (attempt < this.config.maxRetries) {
          this.logger.info(
            `⏳ ${this.config.retryDelay / 1000} 秒后重试... (${attempt}/${
              this.config.maxRetries
            })`
          );
          await new Promise((resolve) =>
            setTimeout(resolve, this.config.retryDelay)
          );
        }
      }
    }

    this.logger.error(`上传失败，已重试 ${this.config.maxRetries} 次`);
    throw lastError;
  }

  async uploadSingleFile(
    filePath: string,
    options: { name?: string } = {}
  ): Promise<string> {
    this.logger.info(`📁 正在上传单个文件: ${filePath}`);

    try {
      const content = await fs.readFile(filePath);
      const fileName = options.name || path.basename(filePath);
      const file = new File([content], fileName, {
        type: this.getMimeType(fileName),
      });

      const response = await this.pinata.upload.public.file(file);
      this.logger.info(`✅ 单个文件上传成功! CID: ${response.cid}`);
      return response.cid;
    } catch (error) {
      this.logger.error(`单个文件上传失败: ${error}`);
      throw error;
    }
  }

  async uploadMetadata(metadata: any, fileName: string): Promise<string> {
    this.logger.info(`📄 正在上传元数据: ${fileName}`);

    try {
      const content = JSON.stringify(metadata, null, 2);
      const file = new File([content], fileName, {
        type: "application/json",
      });

      const response = await this.pinata.upload.public.file(file);
      this.logger.info(`✅ 元数据上传成功! CID: ${response.cid}`);
      return response.cid;
    } catch (error) {
      this.logger.error(`元数据上传失败: ${error}`);
      throw error;
    }
  }

  async pinByCid(cid: string): Promise<any> {
    this.logger.info(`📌 正在 Pin CID: ${cid}`);

    try {
      const response = await this.pinata.upload.public.cid(cid);
      this.logger.info(`✅ CID Pin 成功!`);
      return response;
    } catch (error) {
      this.logger.error(`CID Pin 失败: ${error}`);
      throw error;
    }
  }

  async checkPinQueue(): Promise<any> {
    this.logger.info(`📊 检查 Pin 队列状态`);

    try {
      const jobs = await this.pinata.files.public.queue().status("prechecking");
      this.logger.info(`✅ 队列状态获取成功!`);
      return jobs;
    } catch (error) {
      this.logger.error(`队列状态获取失败: ${error}`);
      throw error;
    }
  }

  async uploadTestFile(): Promise<string> {
    this.logger.info(`🧪 正在上传测试文件`);

    try {
      const testContent = "Hello Pinata! This is a test file.";
      const testFile = new File([testContent], "test.txt", {
        type: "text/plain",
      });

      const response = await this.pinata.upload.public.file(testFile);
      this.logger.info(`✅ 测试文件上传成功! CID: ${response.cid}`);
      return response.cid;
    } catch (error) {
      this.logger.error(`测试文件上传失败: ${error}`);
      throw error;
    }
  }

  private async readDirectoryFiles(dirPath: string): Promise<File[]> {
    const files: File[] = [];
    const entries = await fs.readdir(dirPath, { withFileTypes: true });

    for (const entry of entries) {
      const fullPath = path.join(dirPath, entry.name);
      if (entry.isDirectory()) {
        files.push(...(await this.readDirectoryFiles(fullPath)));
      } else {
        const content = await fs.readFile(fullPath);
        const fileName = entry.name;
        const file = new File([content], fileName, {
          type: this.getMimeType(fileName),
        });
        files.push(file);
      }
    }
    return files;
  }

  private async readDirectoryFilesWithCustomName(
    dirPath: string,
    customName?: string
  ): Promise<File[]> {
    const files: File[] = [];
    const entries = await fs.readdir(dirPath, { withFileTypes: true });

    for (const entry of entries) {
      const fullPath = path.join(dirPath, entry.name);
      if (entry.isDirectory()) {
        files.push(
          ...(await this.readDirectoryFilesWithCustomName(fullPath, customName))
        );
      } else {
        const content = await fs.readFile(fullPath);
        const fileName = entry.name;
        const file = new File([content], fileName, {
          type: this.getMimeType(fileName),
        });
        files.push(file);
      }
    }
    return files;
  }

  private getMimeType(fileName: string): string {
    const ext = path.extname(fileName).toLowerCase();
    const mimeTypes: Record<string, string> = {
      ".png": "image/png",
      ".jpg": "image/jpeg",
      ".jpeg": "image/jpeg",
      ".gif": "image/gif",
      ".json": "application/json",
      ".txt": "text/plain",
      ".md": "text/markdown",
    };
    return mimeTypes[ext] || "application/octet-stream";
  }
}

// --- 批量处理类 ---
class BatchProcessor {
  private uploader: PinataUploader;
  private config: Config;
  private logger: Logger;

  constructor(uploader: PinataUploader, config: Config) {
    this.uploader = uploader;
    this.config = config;
    this.logger = Logger.getInstance();
  }

  async processBatchCollection(
    generateBothVersions: boolean = true
  ): Promise<BatchUploadResult> {
    this.logger.info("🚀 开始处理批量 NFT 集合");

    const assetsDir = path.resolve(__dirname, "..", "..", "assets");
    const imagesInputDir = path.join(assetsDir, "batch_images");

    if (!existsSync(imagesInputDir)) {
      throw new Error(`❌ 输入目录不存在: ${imagesInputDir}`);
    }

    // 1. 上传图片文件夹
    this.logger.info("📁 正在上传图片文件夹...");
    const imagesFolderCid = await this.uploader.uploadDirectoryWithRetry(
      imagesInputDir
    );
    this.logger.info(`✅ 图片文件夹上传完成! CID: ${imagesFolderCid}`);
    this.logger.info(`📝 文件夹名称说明:`);
    this.logger.info(`   - Pinata 界面显示: 'folder_from_sdk' (SDK 默认行为)`);
    this.logger.info(`   - 实际访问路径: ipfs://${imagesFolderCid}/文件名`);
    this.logger.info(
      `   - 例如: ipfs://${imagesFolderCid}/1.png, ipfs://${imagesFolderCid}/2.png`
    );
    this.logger.info(
      `   - Gateway 访问: https://gateway.pinata.cloud/ipfs/${imagesFolderCid}/`
    );

    // 2. 生成元数据
    const imageFiles = (await fs.readdir(imagesInputDir)).filter((f) =>
      /\.(png|jpg|jpeg|gif)$/i.test(f)
    );

    // 验证文件
    const { totalSize, warnings } = await FileUtils.validateFiles(
      imageFiles.map((f) => path.join(imagesInputDir, f)),
      this.config.maxFileSize,
      this.config.maxTotalSize
    );

    warnings.forEach((warning) => this.logger.warn(warning));

    // 3. 生成元数据文件
    const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
    const outputDir = path.join(
      __dirname,
      "..",
      "output",
      `batch-upload-${timestamp}`
    );
    const resultsDir = path.join(outputDir, "results");

    await FileUtils.createDirectory(outputDir);
    await FileUtils.createDirectory(resultsDir);

    // 重新排序图片文件
    imageFiles.sort(
      (a, b) => parseInt(path.parse(a).name) - parseInt(path.parse(b).name)
    );

    let metadataWithSuffixCid: string | undefined;
    let metadataWithoutSuffixCid: string | undefined;

    if (generateBothVersions) {
      const { withSuffixCid, withoutSuffixCid } =
        await this.generateBothMetadataVersions(
          imageFiles,
          imagesFolderCid,
          outputDir
        );
      metadataWithSuffixCid = withSuffixCid;
      metadataWithoutSuffixCid = withoutSuffixCid;
    } else {
      metadataWithoutSuffixCid = await this.generateSingleMetadataVersion(
        imageFiles,
        imagesFolderCid,
        outputDir
      );
    }

    // 4. 保存结果
    const uploadResult: BatchUploadResult = {
      timestamp: new Date().toISOString(),
      imagesFolderCid,
      metadataWithSuffixCid,
      metadataWithoutSuffixCid,
      imageCount: imageFiles.length,
      metadataFiles: imageFiles.map((fileName) => ({
        tokenId: path.parse(fileName).name,
        metadataFileWithSuffix: `${path.parse(fileName).name}${
          this.config.metadataSuffix
        }`,
        metadataFileWithoutSuffix: `${path.parse(fileName).name}`,
      })),
      totalSize,
      uploadTime: Date.now(),
    };

    await this.saveResults(
      uploadResult,
      resultsDir,
      outputDir,
      generateBothVersions
    );

    this.logger.info("✨ 批量流程完成");
    this.logger.info(`📊 上传统计:`);
    this.logger.info(`   - 图片数量: ${uploadResult.imageCount}`);
    this.logger.info(`   - 图片文件夹 CID: ${uploadResult.imagesFolderCid}`);
    if (generateBothVersions) {
      this.logger.info(
        `   - 带${this.config.metadataSuffix}后缀元数据 CID: ${uploadResult.metadataWithSuffixCid}`
      );
      this.logger.info(
        `   - 不带后缀元数据 CID: ${uploadResult.metadataWithoutSuffixCid}`
      );
      this.logger.info(`📝 根据你的 NFT 合约需求选择 Base URI:`);
      this.logger.info(
        `   - 需要${this.config.metadataSuffix}后缀: ipfs://${uploadResult.metadataWithSuffixCid}/`
      );
      this.logger.info(
        `   - 不需要后缀: ipfs://${uploadResult.metadataWithoutSuffixCid}/`
      );
    } else {
      this.logger.info(
        `   - 不带后缀元数据 CID: ${uploadResult.metadataWithoutSuffixCid}`
      );
      this.logger.info(
        `📝 在合约中将 Base URI 设置为: ipfs://${uploadResult.metadataWithoutSuffixCid}/`
      );
    }
    this.logger.info(
      `📄 详细结果已保存到: ${path.join(resultsDir, "upload-result.json")}`
    );

    return uploadResult;
  }

  private async generateBothMetadataVersions(
    imageFiles: string[],
    imagesFolderCid: string,
    outputDir: string
  ): Promise<{ withSuffixCid: string; withoutSuffixCid: string }> {
    const metadataWithSuffixDir = path.join(outputDir, "metadata-json");
    const metadataWithoutSuffixDir = path.join(outputDir, "metadata");

    await FileUtils.cleanupDirectory(metadataWithSuffixDir);
    await FileUtils.cleanupDirectory(metadataWithoutSuffixDir);
    await FileUtils.createDirectory(metadataWithSuffixDir);
    await FileUtils.createDirectory(metadataWithoutSuffixDir);

    // 生成两种版本的元数据文件
    for (const fileName of imageFiles) {
      const tokenId = path.parse(fileName).name;
      const metadata = this.createMetadata(tokenId, imagesFolderCid, fileName);

      await fs.writeFile(
        path.join(
          metadataWithSuffixDir,
          `${tokenId}${this.config.metadataSuffix}`
        ),
        JSON.stringify(metadata, null, 2)
      );

      await fs.writeFile(
        path.join(metadataWithoutSuffixDir, `${tokenId}`),
        JSON.stringify(metadata, null, 2)
      );
    }

    this.logger.info(
      `📁 正在上传带${this.config.metadataSuffix}后缀的元数据文件夹...`
    );
    const withSuffixCid = await this.uploader.uploadDirectoryWithRetry(
      metadataWithSuffixDir
    );
    this.logger.info(
      `✅ 带${this.config.metadataSuffix}后缀元数据文件夹上传完成! CID: ${withSuffixCid}`
    );

    this.logger.info("📁 正在上传不带后缀的元数据文件夹...");
    const withoutSuffixCid = await this.uploader.uploadDirectoryWithRetry(
      metadataWithoutSuffixDir
    );
    this.logger.info(
      `✅ 不带后缀元数据文件夹上传完成! CID: ${withoutSuffixCid}`
    );

    // 清理临时文件夹
    await FileUtils.cleanupDirectory(metadataWithSuffixDir);
    await FileUtils.cleanupDirectory(metadataWithoutSuffixDir);

    return { withSuffixCid, withoutSuffixCid };
  }

  private async generateSingleMetadataVersion(
    imageFiles: string[],
    imagesFolderCid: string,
    outputDir: string
  ): Promise<string> {
    const metadataWithoutSuffixDir = path.join(outputDir, "metadata");

    await FileUtils.cleanupDirectory(metadataWithoutSuffixDir);
    await FileUtils.createDirectory(metadataWithoutSuffixDir);

    for (const fileName of imageFiles) {
      const tokenId = path.parse(fileName).name;
      const metadata = this.createMetadata(tokenId, imagesFolderCid, fileName);

      await fs.writeFile(
        path.join(metadataWithoutSuffixDir, `${tokenId}`),
        JSON.stringify(metadata, null, 2)
      );
    }

    this.logger.info("📁 正在上传不带后缀的元数据文件夹...");
    const withoutSuffixCid = await this.uploader.uploadDirectoryWithRetry(
      metadataWithoutSuffixDir
    );

    await FileUtils.cleanupDirectory(metadataWithoutSuffixDir);
    return withoutSuffixCid;
  }

  private createMetadata(
    tokenId: string,
    imagesFolderCid: string,
    fileName: string
  ) {
    return {
      name: `MetaCore #${tokenId}`,
      description: "MetaCore 集合中的一个独特成员。",
      image: `ipfs://${imagesFolderCid}/${fileName}`,
      attributes: [{ trait_type: "ID", value: parseInt(tokenId) }],
    };
  }

  private async saveResults(
    uploadResult: BatchUploadResult,
    resultsDir: string,
    outputDir: string,
    generateBothVersions: boolean
  ): Promise<void> {
    const resultFilePath = path.join(resultsDir, "upload-result.json");
    await fs.writeFile(resultFilePath, JSON.stringify(uploadResult, null, 2));
    this.logger.info(`📄 上传结果已保存到: ${resultFilePath}`);

    const readmeContent = this.generateReadmeContent(
      uploadResult,
      generateBothVersions
    );
    const readmePath = path.join(outputDir, "README.md");
    await fs.writeFile(readmePath, readmeContent);
    this.logger.info(`📄 说明文档已保存到: ${readmePath}`);
  }

  private generateReadmeContent(
    uploadResult: BatchUploadResult,
    generateBothVersions: boolean
  ): string {
    return `# Pinata 批量上传结果

## 📅 上传时间
${new Date().toLocaleString()}

## 📊 上传统计
- 图片数量: ${uploadResult.imageCount}
- 图片文件夹 CID: ${uploadResult.imagesFolderCid}
${
  generateBothVersions
    ? `- 带${this.config.metadataSuffix}后缀元数据文件夹 CID: ${uploadResult.metadataWithSuffixCid}
- 不带后缀元数据文件夹 CID: ${uploadResult.metadataWithoutSuffixCid}
- 文件格式: 带${this.config.metadataSuffix}后缀 + 不带后缀（兼容所有 NFT 合约）`
    : `- 不带后缀元数据文件夹 CID: ${uploadResult.metadataWithoutSuffixCid}
- 文件格式: 不带后缀（标准 NFT 合约格式）`
}

## 🔗 访问链接
${
  generateBothVersions
    ? `- 带${this.config.metadataSuffix}后缀 Base URI: ipfs://${uploadResult.metadataWithSuffixCid}/
- 不带后缀 Base URI: ipfs://${uploadResult.metadataWithoutSuffixCid}/
- 带${this.config.metadataSuffix}后缀 Gateway: https://gateway.pinata.cloud/ipfs/${uploadResult.metadataWithSuffixCid}/
- 不带后缀 Gateway: https://gateway.pinata.cloud/ipfs/${uploadResult.metadataWithoutSuffixCid}/`
    : `- Base URI: ipfs://${uploadResult.metadataWithoutSuffixCid}/
- Gateway URL: https://gateway.pinata.cloud/ipfs/${uploadResult.metadataWithoutSuffixCid}/`
}

## 🚀 使用方法
${
  generateBothVersions
    ? `根据你的 NFT 合约需求选择：
- 需要${this.config.metadataSuffix}后缀: 使用 \`ipfs://${uploadResult.metadataWithSuffixCid}/\`
- 不需要后缀: 使用 \`ipfs://${uploadResult.metadataWithoutSuffixCid}/\``
    : `在智能合约中设置 Base URI 为: \`ipfs://${uploadResult.metadataWithoutSuffixCid}/\``
}
`;
  }
}

// --- 单个文件处理类 ---
class SingleFileProcessor {
  private uploader: PinataUploader;
  private logger: Logger;

  constructor(uploader: PinataUploader) {
    this.uploader = uploader;
    this.logger = Logger.getInstance();
  }

  async processSingleFile(): Promise<SingleUploadResult> {
    this.logger.info("🚀 开始处理单个文件上传");

    const assetsDir = path.resolve(__dirname, "..", "..", "assets");
    const singleImageDir = path.join(assetsDir, "image");

    if (!existsSync(singleImageDir)) {
      throw new Error(`⚠️  图片目录不存在: ${singleImageDir}`);
    }

    const imageFiles = (await fs.readdir(singleImageDir)).filter((f) =>
      /\.(png|jpg|jpeg|gif)$/i.test(f)
    );

    if (imageFiles.length === 0) {
      throw new Error("⚠️  image 目录下没有找到图片文件");
    }

    const firstImage = imageFiles[0];
    const singleImagePath = path.join(singleImageDir, firstImage);
    const imageName = path.parse(firstImage).name;
    this.logger.info(`📁 选择图片进行测试: ${firstImage}`);

    const imageCid = await this.uploader.uploadSingleFile(singleImagePath);

    const metadata = {
      name: `MetaCore #${imageName}`,
      description: "单个 NFT 示例",
      image: `ipfs://${imageCid}`,
      attributes: [{ trait_type: "Type", value: "Single" }],
    };

    const metadataFileName = `${imageName}-metadata.json`;
    const metadataCid = await this.uploader.uploadMetadata(
      metadata,
      metadataFileName
    );

    const uploadResult: SingleUploadResult = {
      timestamp: new Date().toISOString(),
      imageCid,
      metadataCid,
      imageUrl: `ipfs://${imageCid}`,
      metadataUrl: `ipfs://${metadataCid}`,
      gatewayImageUrl: `https://gateway.pinata.cloud/ipfs/${imageCid}`,
      gatewayMetadataUrl: `https://gateway.pinata.cloud/ipfs/${metadataCid}`,
      metadata,
      uploadTime: Date.now(),
    };

    await this.saveSingleFileResults(uploadResult);

    return uploadResult;
  }

  private async saveSingleFileResults(
    uploadResult: SingleUploadResult
  ): Promise<void> {
    const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
    const outputDir = path.join(
      __dirname,
      "..",
      "output",
      `single-upload-${timestamp}`
    );
    const resultsDir = path.join(outputDir, "results");

    await FileUtils.createDirectory(outputDir);
    await FileUtils.createDirectory(resultsDir);

    const singleResultFilePath = path.join(resultsDir, "upload-result.json");
    await fs.writeFile(
      singleResultFilePath,
      JSON.stringify(uploadResult, null, 2)
    );
    this.logger.info(`📄 单个文件上传结果已保存到: ${singleResultFilePath}`);

    const readmeContent = this.generateSingleFileReadme(uploadResult);
    const readmePath = path.join(outputDir, "README.md");
    await fs.writeFile(readmePath, readmeContent);
    this.logger.info(`📄 说明文档已保存到: ${readmePath}`);
  }

  private generateSingleFileReadme(uploadResult: SingleUploadResult): string {
    return `# Pinata 单个文件上传结果

## 📅 上传时间
${new Date().toLocaleString()}

## 📊 上传信息
- 图片 CID: ${uploadResult.imageCid}
- 元数据 CID: ${uploadResult.metadataCid}

## 🔗 访问链接
- 图片: https://gateway.pinata.cloud/ipfs/${uploadResult.imageCid}
- 元数据: https://gateway.pinata.cloud/ipfs/${uploadResult.metadataCid}

## 📁 文件结构
\`\`\`
${path.dirname(uploadResult.gatewayImageUrl)}/
├── results/
│   └── upload-result.json     # 详细上传结果
└── README.md                  # 说明文档
\`\`\`
`;
  }
}

// --- 主程序 ---
async function main() {
  const startTime = Date.now();
  const logger = Logger.getInstance();

  try {
    // 1. 加载配置
    const configManager = new ConfigManager();
    const config = configManager.getConfig();

    // 2. 初始化上传器
    const uploader = new PinataUploader(config);

    // 3. 测试认证
    const authSuccess = await uploader.testAuthentication();
    if (!authSuccess) {
      logger.error("Pinata 认证失败，程序退出");
      return;
    }

    // 4. 解析命令行参数
    const mode = process.argv[2] || "batch";
    const noSuffix = process.argv.includes("--no-suffix");

    logger.info("📋 上传模式说明:");
    logger.info("  🎯 single: 单个文件模式 - 上传单个图片 + 单个 JSON");
    logger.info("  📦 batch: 批量模式 - 上传整个文件夹 + 批量 JSON");
    logger.info("  🧪 test: 测试模式 - 上传测试文件");
    logger.info("  📌 pin: Pin by CID 模式");
    logger.info("  📊 queue: 检查 Pin 队列状态");

    // 5. 执行相应的模式
    switch (mode) {
      case "single":
        logger.info("🎯 选择: 单个文件模式");
        const singleProcessor = new SingleFileProcessor(uploader);
        await singleProcessor.processSingleFile();
        break;

      case "test":
        logger.info("🧪 选择: 测试模式");
        await uploader.uploadTestFile();
        break;

      case "pin":
        logger.info("📌 选择: Pin by CID 模式");
        const cid = process.argv[3];
        if (!cid) {
          logger.error("❌ 请提供 CID 参数，例如: pnpm pin <CID>");
          return;
        }
        await uploader.pinByCid(cid);
        break;

      case "queue":
        logger.info("📊 选择: 检查队列状态");
        await uploader.checkPinQueue();
        break;

      default:
        logger.info("📦 选择: 批量模式");
        const batchProcessor = new BatchProcessor(uploader, config);

        if (noSuffix) {
          logger.info("📝 模式: 只生成不带后缀的元数据文件");
          await batchProcessor.processBatchCollection(false);
        } else {
          logger.info(
            `📝 模式: 生成带${config.metadataSuffix}后缀和不带后缀的元数据文件`
          );
          await batchProcessor.processBatchCollection(true);
        }
        break;
    }
  } catch (error) {
    logger.error(`脚本执行失败: ${error}`);
    process.exit(1);
  } finally {
    const totalTime = Math.floor((Date.now() - startTime) / 1000);
    logger.info(`脚本总执行时间: ${totalTime} 秒`);
    logger.info("🎉 脚本执行完成，正在退出...");
    process.exit(0);
  }
}

// 如果直接运行此文件，则执行主程序
if (require.main === module) {
  main();
}

export {
  ConfigManager,
  Logger,
  ProgressTracker,
  FileUtils,
  PinataUploader,
  BatchProcessor,
  SingleFileProcessor,
  type UploadResult,
  type BatchUploadResult,
  type SingleUploadResult,
  type Config,
};

```

这是一个功能完整的 **NFT 元数据上传工具**，使用 TypeScript 开发，专门用于将 NFT 图片和元数据批量上传到 Pinata IPFS 平台。该工具采用面向对象的设计架构，包含配置管理、日志系统、进度跟踪、文件验证等核心模块，支持单个文件上传和批量文件夹上传两种模式。工具会自动生成符合 NFT 标准的 JSON 元数据文件，支持自定义文件后缀，并提供带后缀和不带后缀两种格式以兼容不同的智能合约需求。整个系统具备完善的错误处理机制、重试逻辑、超时控制，以及详细的上传结果保存和文档生成功能，确保 NFT 项目的元数据能够稳定可靠地部署到去中心化存储网络中。

现在！让我们一步一步测试验证脚本的各个功能。

## 第一步：编译检查

#### TypeScript 类型检查

检查代码语法和类型错误，但不生成 JavaScript 文件

确保代码可以正常编译，相当于"语法检查"

```bash
➜ npx tsc --noEmit
```

✅ 编译检查通过 - 没有语法错误

## 第二步：测试模式（验证连接）

### 运行测试模式

上传一个测试文件到 Pinata

验证 Pinata 连接和认证是否正常

```bash
➜ pnpm test

> pinata-nft-uploader@1.0.0 test /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript
> ts-node src/index.ts test

[dotenv@17.2.1] injecting env (6) from .env -- tip: ⚙️  specify custom .env file path with { path: '/custom/path/.env' }
[2025-08-07T01:59:34.495Z] [INFO] ✅ Pinata 认证成功!
[2025-08-07T01:59:34.495Z] [INFO] 📋 上传模式说明:
[2025-08-07T01:59:34.495Z] [INFO]   🎯 single: 单个文件模式 - 上传单个图片 + 单个 JSON
[2025-08-07T01:59:34.495Z] [INFO]   📦 batch: 批量模式 - 上传整个文件夹 + 批量 JSON
[2025-08-07T01:59:34.495Z] [INFO]   🧪 test: 测试模式 - 上传测试文件
[2025-08-07T01:59:34.495Z] [INFO]   📌 pin: Pin by CID 模式
[2025-08-07T01:59:34.495Z] [INFO]   📊 queue: 检查 Pin 队列状态
[2025-08-07T01:59:34.495Z] [INFO] 🧪 选择: 测试模式
[2025-08-07T01:59:34.496Z] [INFO] 🧪 正在上传测试文件
[2025-08-07T01:59:36.225Z] [INFO] ✅ 测试文件上传成功! CID: bafkreibtmw4qacliibxj2uflkm7hf4bpkusaafkcp6g5opnvmyufymcqyy
[2025-08-07T01:59:36.225Z] [INFO] 脚本总执行时间: 2 秒
[2025-08-07T01:59:36.225Z] [INFO] 🎉 脚本执行完成，正在退出...

```

✅ 测试模式成功 - Pinata 连接正常，脚本正确退出

## 第三步：单个文件模式测试

### 单个文件上传模式

上传单个图片 + 对应的元数据

处理单个 NFT 的上传

```bash
➜ pnpm single

> pinata-nft-uploader@1.0.0 single /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript
> ts-node src/index.ts single

[dotenv@17.2.1] injecting env (6) from .env -- tip: 🔐 prevent committing .env to code: https://dotenvx.com/precommit
[2025-08-07T02:28:08.520Z] [INFO] ✅ Pinata 认证成功!
[2025-08-07T02:28:08.525Z] [INFO] 📋 上传模式说明:
[2025-08-07T02:28:08.525Z] [INFO]   🎯 single: 单个文件模式 - 上传单个图片 + 单个 JSON
[2025-08-07T02:28:08.525Z] [INFO]   📦 batch: 批量模式 - 上传整个文件夹 + 批量 JSON
[2025-08-07T02:28:08.525Z] [INFO]   🧪 test: 测试模式 - 上传测试文件
[2025-08-07T02:28:08.525Z] [INFO]   📌 pin: Pin by CID 模式
[2025-08-07T02:28:08.525Z] [INFO]   📊 queue: 检查 Pin 队列状态
[2025-08-07T02:28:08.525Z] [INFO] 🎯 选择: 单个文件模式
[2025-08-07T02:28:08.525Z] [INFO] 🚀 开始处理单个文件上传
[2025-08-07T02:28:08.526Z] [INFO] 📁 选择图片进行测试: IMG_20210626_180340.jpg
[2025-08-07T02:28:08.526Z] [INFO] 📁 正在上传单个文件: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/assets/image/IMG_20210626_180340.jpg
[2025-08-07T02:28:57.759Z] [INFO] ✅ 单个文件上传成功! CID: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi
[2025-08-07T02:28:57.760Z] [INFO] 📄 正在上传元数据: IMG_20210626_180340-metadata.json
[2025-08-07T02:28:58.834Z] [INFO] ✅ 元数据上传成功! CID: bafkreiddeekjrptrgdtuicyzgtwknvrweiqltlhs7bx7naj7s2mq3fo6um
[2025-08-07T02:28:58.836Z] [INFO] 📄 单个文件上传结果已保存到: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript/output/single-upload-2025-08-07T02-28-58-834Z/results/upload-result.json
[2025-08-07T02:28:58.872Z] [INFO] 📄 说明文档已保存到: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript/output/single-upload-2025-08-07T02-28-58-834Z/README.md
[2025-08-07T02:28:58.872Z] [INFO] 脚本总执行时间: 51 秒
[2025-08-07T02:28:58.872Z] [INFO] 🎉 脚本执行完成，正在退出...

```

✅ 单个文件模式测试成功！

从结果可以看到：

1. ✅ 认证成功 - Pinata 连接正常
2. ✅ 图片上传成功 - CID: bafybeifwvvo7qacd5ksephyxbqkqjih2dmm2ffgqa6u732b2evw5iijppi
3. ✅ 元数据文件名关联 - IMG_20210626_180340-metadata.json
4. ✅ 元数据上传成功 - CID: bafkreiddeekjrptrgdtuicyzgtwknvrweiqltlhs7bx7naj7s2mq3fo6um
5. ✅ 结果保存 - 自动保存到本地文件
6. ✅ 脚本正确退出 - 没有卡住

## 第四步：批量模式测试（不带后缀）

```bash
➜ pnpm batch:no-suffix

> pinata-nft-uploader@1.0.0 batch:no-suffix /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript
> ts-node src/index.ts batch --no-suffix

[dotenv@17.2.1] injecting env (6) from .env -- tip: ⚙️  enable debug logging with { debug: true }
[2025-08-07T02:33:17.412Z] [INFO] ✅ Pinata 认证成功!
[2025-08-07T02:33:17.415Z] [INFO] 📋 上传模式说明:
[2025-08-07T02:33:17.415Z] [INFO]   🎯 single: 单个文件模式 - 上传单个图片 + 单个 JSON
[2025-08-07T02:33:17.415Z] [INFO]   📦 batch: 批量模式 - 上传整个文件夹 + 批量 JSON
[2025-08-07T02:33:17.415Z] [INFO]   🧪 test: 测试模式 - 上传测试文件
[2025-08-07T02:33:17.415Z] [INFO]   📌 pin: Pin by CID 模式
[2025-08-07T02:33:17.415Z] [INFO]   📊 queue: 检查 Pin 队列状态
[2025-08-07T02:33:17.415Z] [INFO] 📦 选择: 批量模式
[2025-08-07T02:33:17.415Z] [INFO] 📝 模式: 只生成不带后缀的元数据文件
[2025-08-07T02:33:17.416Z] [INFO] 🚀 开始处理批量 NFT 集合
[2025-08-07T02:33:17.416Z] [INFO] 📁 正在上传图片文件夹...
[2025-08-07T02:33:17.416Z] [INFO] 📁 正在上传文件夹: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/assets/batch_images
[2025-08-07T02:33:17.430Z] [INFO] 📁 找到 3 个文件，总大小: 16.40 MB
[2025-08-07T02:33:17.430Z] [INFO] 🚀 开始上传到 Pinata...
[2025-08-07T02:33:27.431Z] [INFO] ⏳ 进行中... 已用时: 10 秒
[2025-08-07T02:33:37.432Z] [INFO] ⏳ 进行中... 已用时: 20 秒
[2025-08-07T02:33:47.433Z] [INFO] ⏳ 进行中... 已用时: 30 秒
[2025-08-07T02:33:48.234Z] [INFO] ✅ 完成! 总用时: 30 秒
[2025-08-07T02:33:48.235Z] [INFO] ✅ 文件夹上传成功! CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e
[2025-08-07T02:33:48.235Z] [INFO] ✅ 图片文件夹上传完成! CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e
[2025-08-07T02:33:48.235Z] [INFO] 📝 文件夹名称说明:
[2025-08-07T02:33:48.235Z] [INFO]    - Pinata 界面显示: 'folder_from_sdk' (SDK 默认行为)
[2025-08-07T02:33:48.235Z] [INFO]    - 实际访问路径: ipfs://bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e/文件名
[2025-08-07T02:33:48.235Z] [INFO]    - 例如: ipfs://bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e/1.png, ipfs://bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e/2.png
[2025-08-07T02:33:48.235Z] [INFO]    - Gateway 访问: https://gateway.pinata.cloud/ipfs/bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e/
[2025-08-07T02:33:48.238Z] [INFO] 📁 正在上传不带后缀的元数据文件夹...
[2025-08-07T02:33:48.238Z] [INFO] 📁 正在上传文件夹: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript/output/batch-upload-2025-08-07T02-33-48-236Z/metadata
[2025-08-07T02:33:48.239Z] [INFO] 📁 找到 3 个文件，总大小: 765 B
[2025-08-07T02:33:48.239Z] [INFO] 🚀 开始上传到 Pinata...
[2025-08-07T02:33:48.906Z] [INFO] ✅ 完成! 总用时: 0 秒
[2025-08-07T02:33:48.906Z] [INFO] ✅ 文件夹上传成功! CID: bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq
[2025-08-07T02:33:48.908Z] [INFO] 📄 上传结果已保存到: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript/output/batch-upload-2025-08-07T02-33-48-236Z/results/upload-result.json
[2025-08-07T02:33:48.948Z] [INFO] 📄 说明文档已保存到: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript/output/batch-upload-2025-08-07T02-33-48-236Z/README.md
[2025-08-07T02:33:48.948Z] [INFO] ✨ 批量流程完成
[2025-08-07T02:33:48.948Z] [INFO] 📊 上传统计:
[2025-08-07T02:33:48.948Z] [INFO]    - 图片数量: 3
[2025-08-07T02:33:48.948Z] [INFO]    - 图片文件夹 CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e
[2025-08-07T02:33:48.948Z] [INFO]    - 不带后缀元数据 CID: bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq
[2025-08-07T02:33:48.948Z] [INFO] 📝 在合约中将 Base URI 设置为: ipfs://bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq/
[2025-08-07T02:33:48.948Z] [INFO] 📄 详细结果已保存到: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript/output/batch-upload-2025-08-07T02-33-48-236Z/results/upload-result.json
[2025-08-07T02:33:48.948Z] [INFO] 脚本总执行时间: 33 秒
[2025-08-07T02:33:48.948Z] [INFO] 🎉 脚本执行完成，正在退出...

```

✅ 批量模式（不带后缀）测试成功！

从结果可以看到：

1. ✅ 图片文件夹上传成功 - CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e
2. ✅ 文件大小显示正确 - 16.40 MB (图片) / 765 B (元数据)
3. ✅ 文件夹名称说明 - 清楚解释了 folder_from_sdk 的问题
4. ✅ 元数据文件夹上传成功 - CID: bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq
5. ✅ 进度显示正常 - 每10秒显示一次进度
6. ✅ 详细统计信息 - 显示所有 CID 和 Base URI
7. ✅ 脚本正确退出 - 没有卡住

## 第五步：批量模式测试（带后缀）

```bash
➜ pnpm batch

> pinata-nft-uploader@1.0.0 batch /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript
> ts-node src/index.ts batch

[dotenv@17.2.1] injecting env (6) from .env -- tip: 🔐 prevent committing .env to code: https://dotenvx.com/precommit
[2025-08-07T02:37:34.559Z] [INFO] ✅ Pinata 认证成功!
[2025-08-07T02:37:34.563Z] [INFO] 📋 上传模式说明:
[2025-08-07T02:37:34.563Z] [INFO]   🎯 single: 单个文件模式 - 上传单个图片 + 单个 JSON
[2025-08-07T02:37:34.563Z] [INFO]   📦 batch: 批量模式 - 上传整个文件夹 + 批量 JSON
[2025-08-07T02:37:34.563Z] [INFO]   🧪 test: 测试模式 - 上传测试文件
[2025-08-07T02:37:34.563Z] [INFO]   📌 pin: Pin by CID 模式
[2025-08-07T02:37:34.563Z] [INFO]   📊 queue: 检查 Pin 队列状态
[2025-08-07T02:37:34.563Z] [INFO] 📦 选择: 批量模式
[2025-08-07T02:37:34.564Z] [INFO] 📝 模式: 生成带.json后缀和不带后缀的元数据文件
[2025-08-07T02:37:34.564Z] [INFO] 🚀 开始处理批量 NFT 集合
[2025-08-07T02:37:34.564Z] [INFO] 📁 正在上传图片文件夹...
[2025-08-07T02:37:34.565Z] [INFO] 📁 正在上传文件夹: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/assets/batch_images
[2025-08-07T02:37:34.583Z] [INFO] 📁 找到 3 个文件，总大小: 16.40 MB
[2025-08-07T02:37:34.583Z] [INFO] 🚀 开始上传到 Pinata...
[2025-08-07T02:37:44.584Z] [INFO] ⏳ 进行中... 已用时: 10 秒
[2025-08-07T02:37:54.585Z] [INFO] ⏳ 进行中... 已用时: 20 秒
[2025-08-07T02:38:04.586Z] [INFO] ⏳ 进行中... 已用时: 30 秒
[2025-08-07T02:38:14.587Z] [INFO] ⏳ 进行中... 已用时: 40 秒
[2025-08-07T02:38:24.588Z] [INFO] ⏳ 进行中... 已用时: 50 秒
[2025-08-07T02:38:34.590Z] [INFO] ⏳ 进行中... 已用时: 60 秒
[2025-08-07T02:38:44.591Z] [INFO] ⏳ 进行中... 已用时: 70 秒
[2025-08-07T02:38:54.592Z] [INFO] ⏳ 进行中... 已用时: 80 秒
[2025-08-07T02:39:04.593Z] [INFO] ⏳ 进行中... 已用时: 90 秒
[2025-08-07T02:39:14.594Z] [INFO] ⏳ 进行中... 已用时: 100 秒
[2025-08-07T02:39:24.594Z] [INFO] ⏳ 进行中... 已用时: 110 秒
[2025-08-07T02:39:34.596Z] [INFO] ⏳ 进行中... 已用时: 120 秒
[2025-08-07T02:39:44.597Z] [INFO] ⏳ 进行中... 已用时: 130 秒
[2025-08-07T02:39:54.598Z] [INFO] ⏳ 进行中... 已用时: 140 秒
[2025-08-07T02:40:04.600Z] [INFO] ⏳ 进行中... 已用时: 150 秒
[2025-08-07T02:40:14.601Z] [INFO] ⏳ 进行中... 已用时: 160 秒
[2025-08-07T02:40:24.602Z] [INFO] ⏳ 进行中... 已用时: 170 秒
[2025-08-07T02:40:34.604Z] [INFO] ⏳ 进行中... 已用时: 180 秒
[2025-08-07T02:40:44.604Z] [INFO] ⏳ 进行中... 已用时: 190 秒
[2025-08-07T02:40:54.605Z] [INFO] ⏳ 进行中... 已用时: 200 秒
[2025-08-07T02:41:04.605Z] [INFO] ⏳ 进行中... 已用时: 210 秒
[2025-08-07T02:41:14.553Z] [INFO] ⏳ 进行中... 已用时: 219 秒
[2025-08-07T02:41:24.554Z] [INFO] ⏳ 进行中... 已用时: 229 秒
[2025-08-07T02:41:32.290Z] [INFO] ✅ 完成! 总用时: 237 秒
[2025-08-07T02:41:32.290Z] [INFO] ✅ 文件夹上传成功! CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e
[2025-08-07T02:41:32.290Z] [INFO] ✅ 图片文件夹上传完成! CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e
[2025-08-07T02:41:32.290Z] [INFO] 📝 文件夹名称说明:
[2025-08-07T02:41:32.290Z] [INFO]    - Pinata 界面显示: 'folder_from_sdk' (SDK 默认行为)
[2025-08-07T02:41:32.290Z] [INFO]    - 实际访问路径: ipfs://bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e/文件名
[2025-08-07T02:41:32.290Z] [INFO]    - 例如: ipfs://bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e/1.png, ipfs://bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e/2.png
[2025-08-07T02:41:32.290Z] [INFO]    - Gateway 访问: https://gateway.pinata.cloud/ipfs/bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e/
[2025-08-07T02:41:32.305Z] [INFO] 📁 正在上传带.json后缀的元数据文件夹...
[2025-08-07T02:41:32.305Z] [INFO] 📁 正在上传文件夹: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript/output/batch-upload-2025-08-07T02-41-32-295Z/metadata-json
[2025-08-07T02:41:32.307Z] [INFO] 📁 找到 3 个文件，总大小: 765 B
[2025-08-07T02:41:32.307Z] [INFO] 🚀 开始上传到 Pinata...
[2025-08-07T02:41:33.014Z] [INFO] ✅ 完成! 总用时: 0 秒
[2025-08-07T02:41:33.014Z] [INFO] ✅ 文件夹上传成功! CID: bafybeiguvcmspmkhyheyh5c7wmixuiiysjpcrw4hjvvydmfhqmwsopvjk4
[2025-08-07T02:41:33.014Z] [INFO] ✅ 带.json后缀元数据文件夹上传完成! CID: bafybeiguvcmspmkhyheyh5c7wmixuiiysjpcrw4hjvvydmfhqmwsopvjk4
[2025-08-07T02:41:33.014Z] [INFO] 📁 正在上传不带后缀的元数据文件夹...
[2025-08-07T02:41:33.014Z] [INFO] 📁 正在上传文件夹: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript/output/batch-upload-2025-08-07T02-41-32-295Z/metadata
[2025-08-07T02:41:33.015Z] [INFO] 📁 找到 3 个文件，总大小: 765 B
[2025-08-07T02:41:33.015Z] [INFO] 🚀 开始上传到 Pinata...
[2025-08-07T02:41:33.591Z] [INFO] ✅ 完成! 总用时: 0 秒
[2025-08-07T02:41:33.592Z] [INFO] ✅ 文件夹上传成功! CID: bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq
[2025-08-07T02:41:33.592Z] [INFO] ✅ 不带后缀元数据文件夹上传完成! CID: bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq
[2025-08-07T02:41:33.596Z] [INFO] 📄 上传结果已保存到: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript/output/batch-upload-2025-08-07T02-41-32-295Z/results/upload-result.json
[2025-08-07T02:41:33.641Z] [INFO] 📄 说明文档已保存到: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript/output/batch-upload-2025-08-07T02-41-32-295Z/README.md
[2025-08-07T02:41:33.641Z] [INFO] ✨ 批量流程完成
[2025-08-07T02:41:33.641Z] [INFO] 📊 上传统计:
[2025-08-07T02:41:33.641Z] [INFO]    - 图片数量: 3
[2025-08-07T02:41:33.641Z] [INFO]    - 图片文件夹 CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e
[2025-08-07T02:41:33.641Z] [INFO]    - 带.json后缀元数据 CID: bafybeiguvcmspmkhyheyh5c7wmixuiiysjpcrw4hjvvydmfhqmwsopvjk4
[2025-08-07T02:41:33.641Z] [INFO]    - 不带后缀元数据 CID: bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq
[2025-08-07T02:41:33.642Z] [INFO] 📝 根据你的 NFT 合约需求选择 Base URI:
[2025-08-07T02:41:33.642Z] [INFO]    - 需要.json后缀: ipfs://bafybeiguvcmspmkhyheyh5c7wmixuiiysjpcrw4hjvvydmfhqmwsopvjk4/
[2025-08-07T02:41:33.642Z] [INFO]    - 不需要后缀: ipfs://bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq/
[2025-08-07T02:41:33.642Z] [INFO] 📄 详细结果已保存到: /Users/qiaopengjun/Code/Solidity/YuanqiGenesis/polyglot-pinata-uploader/typescript/output/batch-upload-2025-08-07T02-41-32-295Z/results/upload-result.json
[2025-08-07T02:41:33.642Z] [INFO] 脚本总执行时间: 240 秒
[2025-08-07T02:41:33.642Z] [INFO] 🎉 脚本执行完成，正在退出...
```

✅ 批量模式（带后缀）测试成功！

从结果可以看到：

1. ✅ 图片文件夹上传成功 - CID: bafybeia22ed2lhakgwu76ojojhuavlxkccpclciy6hgqsmn6o7ur7cw44e
2. ✅ 带后缀元数据上传成功 - CID: bafybeiguvcmspmkhyheyh5c7wmixuiiysjpcrw4hjvvydmfhqmwsopvjk4
3. ✅ 不带后缀元数据上传成功 - CID: bafybeihnyl6zp4q4xusvpt77nzl7ljg3ec6xhbgaflzrn6bzrpo7nivgzq
4. ✅ 进度显示正常 - 每10秒显示一次进度
5. ✅ 详细统计信息 - 显示所有 CID 和 Base URI 选项
6. ✅ 脚本正确退出 - 没有卡住

## �� 测试总结

所有功能都测试成功！

### ✅ 测试结果

- 编译检查 ✅ - 无语法错误

- 测试模式 ✅ - Pinata 连接正常

- 单个文件模式 ✅ - 图片和元数据上传成功

- 批量模式（不带后缀） ✅ - 批量上传成功

- 批量模式（带后缀） ✅ - 批量上传成功

脚本现在运行得很好，所有功能都正常工作！

## 总结

这篇文章详细介绍并演示了一款功能完备的 Pinata NFT 元数据上传工具。它不仅仅是一个简单的脚本，而是一个采用 TypeScript 构建、基于面向对象思想设计的综合解决方案。

其核心优势在于：

- **自动化与高效率**：无论是单个 NFT 还是上千个文件的集合，工具都能一键完成图片上传、元数据生成和元数据上传的全过程，并自动生成清晰的结果报告和说明文档。
- **高度灵活性**：支持单个文件和批量文件夹两种模式，并且在批量模式下，能同时生成带 `.json` 后缀和不带后缀的两种元数据文件夹，灵活适配各类智能合约对 `baseURI` 的不同要求。
- **稳健可靠**：内置了完善的配置管理、日志系统、进度跟踪、上传超时控制和自动重试机制，确保在处理大量文件或网络不稳定时，任务依然能可靠地完成。

通过文中的多轮实战测试可以看出，该工具在连接认证、单文件处理、批量处理等各个环节都表现出色，运行稳定。对于任何需要将NFT资产部署到 IPFS 的开发者来说，这都是一个可以**直接用于生产环境、显著提升开发效率的开源利器**。✨

## 参考

- <https://docs.pinata.cloud/tools/community-sdks>
- <https://app.pinata.cloud/ipfs/files>
- <https://github.com/perfectmak/pinata-sdk>
- <https://gitlab.com/benoit74/pinata-cli>
- <https://github.com/Vourhey/pinatapy>
- <https://github.com/qiaopengjun5162/polyglot-ipfs-uploader>

## 推荐阅读

- 《NFT 开发核心步骤：本地 IPFS 节点搭建与元数据上传实战》
- 《Python x IPFS：构建生产级的 NFT 元数据自动化流程》
- 《从命令行到官方库：用 Go 语言精通 NFT 元数据 IPFS 上传》
- 《Rust x IPFS：从命令行到官方库，精通NFT元数据上传》
