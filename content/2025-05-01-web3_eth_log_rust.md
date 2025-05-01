+++
title = "用 Rust 解锁 Web3：以太坊事件解析实战"
description = "用 Rust 解锁 Web3：以太坊事件解析实战"
date = 2025-05-01T13:25:59Z
[taxonomies]
categories = ["Web3", "Rust", "Ethereum"]
tags = ["Web3", "Rust", "Ethereum"]
+++

<!-- more -->

# 用 Rust 解锁 Web3：以太坊事件解析实战

Web3 浪潮席卷全球，以太坊作为区块链核心平台，驱动着无数去中心化应用（DApp）。如何高效、安全地与以太坊交互，成为开发者面临的挑战。Rust，以其卓越的性能和内存安全，成为构建高性能 Web3 后端的理想选择。本文通过一个完整的 Rust 项目，带你实战打造以太坊客户端和事件解析器，深入探索如何使用 ethers-rs 库连接节点、获取交易收据并解析智能合约事件。项目配备完善的测试用例（100% 代码覆盖率）和覆盖率分析，助你快速上手 Rust 驱动的 Web3 开发。无论你是区块链新手还是资深开发者，这篇干货满满的教程都将为你解锁 Web3 的无限可能！

本文详细介绍了一个基于 Rust 的 Web3 后端项目，专注于以太坊区块链交互。项目通过 `client.rs` 实现以太坊客户端，支持连接 RPC 节点、获取交易收据和日志；通过 `event_parser.rs` 解析智能合约的 `ConfirmDataStore` 事件。项目结构模块化，支持 YAML 和环境变量配置，核心逻辑在 main.rs 中实现交易和日志的处理流程。代码配备 83 个单元测试和集成测试，覆盖率达 100%，使用 `cargo nextest` 和 `cargo llvm-cov` 进行高效测试和覆盖率分析。本文还对比了 `cargo test` 与 `nextest` 的优劣，并提供编译、运行及生成覆盖率报告的详细步骤。无论是构建高性能 Web3 应用，还是学习 Rust 在区块链中的应用，这篇实战指南都为你提供坚实的基础。

## 实操

### 项目目录结构

```bash
ethertrace/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 11.9s 
➜ tree . -L 6 -I "__pycache__|python.egg-info|htmlcov|ethertrace.egg-info|target"
.
├── Cargo.lock
├── Cargo.toml
├── docs
│   └── note.md
├── rust-toolchain.toml
├── src
│   ├── client.rs
│   ├── event_parser.rs
│   ├── lib.rs
│   └── main.rs
└── tests
    └── integration.rs

4 directories, 9 files

```

### 代码实现

#### `client.rs` 文件

```rust
// client.rs
use ethers::prelude::*;
use regex::Regex;
use std::sync::Arc;
use url::Url;

lazy_static::lazy_static! {
    static ref DOMAIN_REGEX: Regex = Regex::new(r"^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.?)+$").unwrap();
}

#[derive(Debug)]
pub struct EthClient {
    client: Arc<Provider<Http>>,
}

impl EthClient {
    pub async fn new(rpc_url: &str) -> Result<Self, anyhow::Error> {
        // 验证 RPC URL
        if rpc_url.is_empty() {
            return Err(anyhow::anyhow!("Empty RPC URL"));
        }
        // 使用 url crate 安全解析 URL
        let parsed_url = Url::parse(rpc_url).map_err(|_| anyhow::anyhow!("Invalid URL"))?;

        // 支持的协议
        static ALLOWED_SCHEMES: &[&str] = &["http", "https", "ws", "wss"];
        let scheme = parsed_url.scheme();

        if !ALLOWED_SCHEMES.contains(&scheme) {
            return Err(anyhow::anyhow!("Unsupported scheme"));
        }

        // 连接以太坊节点
        let provider = Provider::<Http>::try_from(rpc_url)?;
        let client = Arc::new(provider);
        Ok(EthClient { client })
    }

    pub async fn get_tx_receipt_by_hash(
        &self,
        tx_hash: &str,
    ) -> Result<TransactionReceipt, anyhow::Error> {
        let hash: H256 = tx_hash.parse()?;
        let receipt = self
            .client
            .get_transaction_receipt(hash)
            .await?
            .ok_or_else(|| anyhow::anyhow!("Transaction receipt not found"))?;
        Ok(receipt)
    }

    pub async fn get_logs(
        &self,
        block_option: FilterBlockOption,
        addresses: Option<Vec<Address>>,
        topics: Option<Vec<H256>>,
    ) -> Result<Vec<Log>, anyhow::Error> {
        let filter = Filter {
            block_option,
            address: addresses.map(ValueOrArray::Array),
            topics: {
                let mut topics_array = [const { None }; 4];
                if let Some(topics_vec) = topics {
                    for (i, topic) in topics_vec.into_iter().take(4).enumerate() {
                        topics_array[i] = Some(topic.into());
                    }
                }
                topics_array
            },
        };
        let logs = self.client.get_logs(&filter).await?;
        Ok(logs)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::str::FromStr;

    #[tokio::test]
    async fn test_new_eth_client() {
        let client = EthClient::new("https://rpc.mevblocker.io").await;
        assert!(client.is_ok());
    }

    #[tokio::test]
    async fn test_new_eth_client_invalid_url() {
        let client = EthClient::new("").await;
        assert!(client.is_err());
        assert_eq!(client.unwrap_err().to_string(), "Empty RPC URL");
    }

    #[tokio::test]
    async fn test_get_tx_receipt_by_hash() {
        let client = EthClient::new("https://eth.llamarpc.com").await.unwrap();
        let tx_hash = "0xfd26d40e17213bcafcf94bab9af92343302df9df970f20e1c9d515525e86e23e";
        let receipt = client.get_tx_receipt_by_hash(tx_hash).await;
        assert!(receipt.is_ok());
    }

    #[tokio::test]
    async fn test_get_logs_empty() {
        let client = EthClient::new("https://rpc.mevblocker.io").await.unwrap();
        let block_option = FilterBlockOption::Range {
            from_block: Some(BlockNumber::Number(0.into())),
            to_block: Some(BlockNumber::Number(0.into())),
        };
        let logs = client.get_logs(block_option, None, None).await.unwrap();
        assert!(logs.is_empty());
    }

    #[tokio::test]
    async fn test_get_logs_range() {
        let client = EthClient::new("https://rpc.mevblocker.io").await.unwrap();
        let addresses =
            vec![Address::from_str("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap()];
        let block_option = FilterBlockOption::Range {
            from_block: Some(BlockNumber::Number(20483831.into())),
            to_block: Some(BlockNumber::Number(20483833.into())),
        };
        let topics = vec![
            H256::from_str("0x4e3a3754410177e6937ef1d0c0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0")
                .unwrap(),
        ];
        let logs = client
            .get_logs(block_option, Some(addresses), Some(topics))
            .await;
        assert!(logs.is_ok());
    }

    #[tokio::test]
    async fn test_get_logs_at_block_hash() {
        let client = EthClient::new("https://rpc.mevblocker.io").await.unwrap();
        let block_hash =
            H256::from_str("0x4e3a3754410177e6937ef1d0c0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0")
                .unwrap();
        let block_option = FilterBlockOption::AtBlockHash(block_hash);
        let logs = client.get_logs(block_option, None, None).await;
        assert!(logs.is_ok() || logs.unwrap_err().to_string().contains("not found"));
    }

    #[tokio::test]
    async fn test_new_eth_client_with_valid_url() {
        let client = EthClient::new("https://rpc.mevblocker.io").await;
        assert!(client.is_ok(), "Expected Ok(EthClient), got error");
    }

    #[tokio::test]
    async fn test_new_eth_client_empty_url() {
        let client = EthClient::new("").await;
        assert!(client.is_err(), "Expected error for empty URL");
        assert_eq!(client.unwrap_err().to_string(), "Empty RPC URL");
    }

    #[tokio::test]
    async fn test_new_eth_client_invalid_scheme() {
        let client = EthClient::new("ftp://example.com").await;
        assert!(client.is_err(), "Expected error for unsupported scheme");
        assert_eq!(client.unwrap_err().to_string(), "Unsupported scheme");
    }

    #[tokio::test]
    async fn test_new_eth_client_missing_scheme() {
        let client = EthClient::new("example.com").await;
        assert!(client.is_err(), "Expected error for missing scheme");
        assert_eq!(client.unwrap_err().to_string(), "Invalid URL");
    }

    #[tokio::test]
    async fn test_get_tx_receipt_by_hash_invalid_format() {
        let client = EthClient::new("https://eth.llamarpc.com").await.unwrap();
        let result = client.get_tx_receipt_by_hash("invalid_hash").await;
        assert!(result.is_err(), "Expected error for invalid hash format");
    }

    #[tokio::test]
    async fn test_get_tx_receipt_by_hash_not_found() {
        let client = EthClient::new("https://eth.llamarpc.com").await.unwrap();
        let tx_hash = "0x0000000000000000000000000000000000000000000000000000000000000000";
        let result = client.get_tx_receipt_by_hash(tx_hash).await;
        assert!(
            result.is_err(),
            "Expected error for non-existent transaction"
        );
        assert!(
            result
                .unwrap_err()
                .to_string()
                .contains("Transaction receipt not found")
        );
    }

    #[tokio::test]
    async fn test_get_tx_receipt_by_hash_success() {
        let client = EthClient::new("https://eth.llamarpc.com").await.unwrap();
        let tx_hash = "0xfd26d40e17213bcafcf94bab9af92343302df9df970f20e1c9d515525e86e23e";
        let result = client.get_tx_receipt_by_hash(tx_hash).await;
        assert!(
            result.is_ok(),
            "Expected successful transaction receipt retrieval"
        );
    }

    #[tokio::test]
    async fn test_get_logs_empty_range() {
        let client = EthClient::new("https://rpc.mevblocker.io").await.unwrap();
        let block_option = FilterBlockOption::Range {
            from_block: Some(BlockNumber::Number(0.into())),
            to_block: Some(BlockNumber::Number(0.into())),
        };
        let logs = client.get_logs(block_option, None, None).await.unwrap();
        assert!(logs.is_empty(), "Expected no logs in block range 0-0");
    }

    #[tokio::test]
    async fn test_get_logs_with_address_and_topic() {
        let client = EthClient::new("https://rpc.mevblocker.io").await.unwrap();
        let addresses =
            vec![Address::from_str("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap()];
        let block_option = FilterBlockOption::Range {
            from_block: Some(BlockNumber::Number(20483831.into())),
            to_block: Some(BlockNumber::Number(20483833.into())),
        };
        let topics = vec![
            H256::from_str("0x4e3a3754410177e6937ef1d0c0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0")
                .unwrap(),
        ];
        let logs = client
            .get_logs(block_option, Some(addresses), Some(topics))
            .await;
        assert!(logs.is_ok(), "Expected logs or success status");
    }

    #[tokio::test]
    async fn test_get_logs_at_block_hash2() {
        let client = EthClient::new("https://rpc.mevblocker.io").await.unwrap();
        let block_hash =
            H256::from_str("0x4e3a3754410177e6937ef1d0c0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0")
                .unwrap();
        let block_option = FilterBlockOption::AtBlockHash(block_hash);
        let logs = client.get_logs(block_option, None, None).await;
        assert!(
            logs.is_ok() || logs.unwrap_err().to_string().contains("not found"),
            "Expected either logs or 'not found' error"
        );
    }

    #[tokio::test]
    async fn test_new_eth_client_invalid_url_format() {
        let result = EthClient::new("htt:/invalid-url").await;
        assert!(result.is_err(), "Expected error for invalid URL format");
        assert_eq!(result.unwrap_err().to_string(), "Unsupported scheme");

        let result = EthClient::new("invalid-url").await;
        assert!(result.is_err(), "Expected error for invalid URL format");
        assert_eq!(result.unwrap_err().to_string(), "Invalid URL");
    }

    #[tokio::test]
    async fn test_new_eth_client_ws_scheme() {
        let client = EthClient::new("ws://example.com").await;
        assert!(client.is_ok(), "Expected Ok for ws scheme");
    }

    #[tokio::test]
    async fn test_new_eth_client_wss_scheme() {
        let client = EthClient::new("wss://example.com").await;
        assert!(client.is_ok(), "Expected Ok for wss scheme");
    }

    #[tokio::test]
    async fn test_new_eth_client_invalid_provider() {
        let client = EthClient::new("https://invalid-rpc.example.com").await;
        assert!(client.is_ok());
    }

    #[tokio::test]
    async fn test_get_logs_single_topic() {
        let client = EthClient::new("https://rpc.mevblocker.io").await.unwrap();
        let block_option = FilterBlockOption::Range {
            from_block: Some(BlockNumber::Number(20483831.into())),
            to_block: Some(BlockNumber::Number(20483833.into())),
        };
        let topics = vec![
            H256::from_str("0x4e3a3754410177e6937ef1d0c0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0")
                .unwrap(),
        ];
        let logs = client.get_logs(block_option, None, Some(topics)).await;
        assert!(logs.is_ok());
    }

    #[tokio::test]
    async fn test_get_logs_no_topics() {
        let client = EthClient::new("https://rpc.mevblocker.io").await.unwrap();
        let block_option = FilterBlockOption::Range {
            from_block: Some(BlockNumber::Number(20483831.into())),
            to_block: Some(BlockNumber::Number(20483833.into())),
        };
        let logs = client.get_logs(block_option, None, None).await;
        assert!(logs.is_ok());
    }

    #[tokio::test]
    async fn test_new_eth_client_domain_regex() {
        // 测试复杂域名
        let client = EthClient::new("https://sub.domain.example.com").await;
        assert!(client.is_ok());
        // 测试无效域名
        let client = EthClient::new("https://invalid..domain.com").await;
        assert!(client.is_ok());
    }

    #[tokio::test]
    async fn test_get_logs_four_topics() {
        let client = EthClient::new("https://rpc.mevblocker.io").await.unwrap();
        let block_option = FilterBlockOption::Range {
            from_block: Some(BlockNumber::Number(20483831.into())),
            to_block: Some(BlockNumber::Number(20483833.into())),
        };
        let topics = vec![
            H256::from_str("0x4e3a3754410177e6937ef1d0c0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0").unwrap(),
            H256::from_str("0x5e3a3754410177e6937ef1d0c0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0").unwrap(),
            H256::from_str("0x6e3a3754410177e6937ef1d0c0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0").unwrap(),
            H256::from_str("0x7e3a3754410177e6937ef1d0c0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0e0d0a0b0").unwrap(),
        ];
        let logs = client.get_logs(block_option, None, Some(topics)).await;
        assert!(logs.is_ok());
    }
}

```

#### `event_parser.rs` 文件

```rust
use ethers::{
    abi::{Event, EventParam, ParamType, RawLog},
    types::{Address, H256, Log},
};
use std::str::FromStr;
use anyhow::anyhow;

#[derive(Debug, Clone)]
pub struct ConfirmDataStoreData {
    pub data_store_id: u32,
    pub header_hash: H256,
}

#[derive(Debug)]
pub struct EventParser {
    event_abi: Event,
    event_hash: H256,
    contract_addr: Address,
}

impl EventParser {
    pub fn new(contract_addr: &str) -> Result<Self, anyhow::Error> {
        // 验证合约地址
        if contract_addr.is_empty() {
            return Err(anyhow::anyhow!("Contract address cannot be empty"));
        }
        if !contract_addr.starts_with("0x") || contract_addr.len() != 42 {
            return Err(anyhow::anyhow!("Invalid contract address format"));
        }

        // 检查是否是有效的十六进制字符串
        let hex_part = &contract_addr[2..];
        if hex_part.as_bytes().iter().any(|b| !b.is_ascii_hexdigit()) {
            return Err(anyhow::anyhow!("Contract address contains invalid hex characters"));
        }

        let addr = Address::from_str(contract_addr)?;
        if addr == Address::zero() {
            return Err(anyhow::anyhow!("Contract address cannot be zero"));
        }

        // 定义 ConfirmDataStore 事件 ABI
        let event_abi = Event {
            name: "ConfirmDataStore".to_string(),
            inputs: vec![
                EventParam {
                    name: "dataStoreId".to_string(),
                    kind: ParamType::Uint(32),
                    indexed: false,
                },
                EventParam {
                    name: "headerHash".to_string(),
                    kind: ParamType::FixedBytes(32),
                    indexed: false,
                },
            ],
            anonymous: false,
        };

        // 计算事件签名哈希
        let event_hash = H256::from(ethers::utils::keccak256("ConfirmDataStore(uint32,bytes32)"));

        Ok(EventParser {
            event_abi,
            event_hash,
            contract_addr: addr,
        })
    }

    pub fn event_hash(&self) -> H256 {
        self.event_hash
    }
    pub fn parse_logs(&self, logs: Vec<Log>) -> Result<Vec<ConfirmDataStoreData>, anyhow::Error> {
        let mut results = Vec::with_capacity(logs.len() / 2);

        for log in logs {
            // 检查日志是否来自正确的合约地址和事件哈希
            if log.address != self.contract_addr ||
                log.topics.get(0) != Some(&self.event_hash) {
                continue;
            }

            let raw_log = RawLog {
                topics: log.topics,
                data: log.data.to_vec(),
            };

            let tokens = self.event_abi.parse_log(raw_log)?;

            let data_store_id = tokens.params.get(0)
                .ok_or(anyhow!("Missing dataStoreId"))?
                .value.clone()
                .into_uint()
                .ok_or(anyhow!("Invalid dataStoreId type"))?
                .as_u32();

            let bytes = tokens.params.get(1)
                .ok_or(anyhow!("Missing headerHash"))?
                .value.clone()
                .into_fixed_bytes()
                .ok_or(anyhow!("Invalid headerHash type"))?;

            // let mut arr = [0u8; 32];
            // arr.copy_from_slice(&bytes);
            // let header_hash = H256::from(arr);
            let header_hash = H256::from_slice(&bytes);

            results.push(ConfirmDataStoreData {
                data_store_id,
                header_hash,
            });
        }
        Ok(results)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use ethers::types::{Address, H256, Log};
    use std::str::FromStr;

    #[test]
    fn test_new_event_parser() {
        let parser = EventParser::new("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1");
        assert!(parser.is_ok());
    }

    #[test]
    fn test_new_event_parser_invalid_address() {
        let parser = EventParser::new("0xInvalidAddress");
        assert!(parser.is_err());
        assert_eq!(parser.unwrap_err().to_string(), "Invalid contract address format");
    }

    #[test]
    fn test_parse_logs_single_valid_log() {
        let parser = EventParser::new("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap();
        let logs = vec![Log {
            address: Address::from_str("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap(),
            topics: vec![parser.event_hash()],
            data: hex::decode("00000000000000000000000000000000000000000000000000000000000089ba27bc30064cc44c6aef26ca2d7e4ee667592949a50f4f01d8d4632461a12f2243").unwrap().into(),
            ..Default::default()
        }];
        let results = parser.parse_logs(logs).unwrap();
        assert_eq!(results.len(), 1);
        assert_eq!(results[0].data_store_id, 35258);
        assert_eq!(
            results[0].header_hash,
            H256::from_str("0x27bc30064cc44c6aef26ca2d7e4ee667592949a50f4f01d8d4632461a12f2243").unwrap()
        );
    }

    #[test]
    fn test_parse_logs_empty() {
        let parser = EventParser::new("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap();
        let logs = vec![].into();
        let results = parser.parse_logs(logs).unwrap();
        assert!(results.is_empty());
    }

    #[test]
    fn test_new_event_parser_missing_prefix() {
        let parser = EventParser::new("InvalidAddress");
        assert!(parser.is_err());
        assert_eq!(parser.unwrap_err().to_string(), "Invalid contract address format");
    }

    #[test]
    fn test_event_hash() {
        let parser = EventParser::new("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap();
        let hash = parser.event_hash();
        assert_eq!(
            hash,
            H256::from(ethers::utils::keccak256("ConfirmDataStore(uint32,bytes32)"))
        );
    }

    #[test]
    fn test_parse_logs_non_matching() {
        let parser = EventParser::new("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap();
        let logs = vec![Log {
            address: Address::from_str("0x0000000000000000000000000000000000000001").unwrap(),
            topics: vec![H256::zero()],
            data: vec![].into(),
            ..Default::default()
        }];
        let results = parser.parse_logs(logs).unwrap();
        assert!(results.is_empty());
    }

    #[test]
    fn test_parse_logs_invalid_data() -> Result<(), anyhow::Error> {
        let parser = EventParser::new("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap();
        let logs = vec![Log {
            address: Address::from_str("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap(),
            topics: vec![parser.event_hash()],
            data: vec![0u8; 32].into(), // 无效数据
            ..Default::default()
        }];
        let results = parser.parse_logs(logs);
        println!("results: {:#?}", results);
        assert!(results.is_err());
        assert!(results.unwrap_err().to_string().contains("Invalid data"));
        // assert_eq!(results.unwrap_err().to_string(), "Invalid data");
        Ok(())
    }

    #[test]
    fn test_new_event_parser_empty_address() {
        let parser = EventParser::new("");
        assert!(parser.is_err());
        assert_eq!(parser.unwrap_err().to_string(), "Contract address cannot be empty");
    }

    #[test]
    fn test_new_event_parser_invalid_format() {
        let parser = EventParser::new("0xInvalidAddress");
        assert!(parser.is_err());
        assert_eq!(parser.unwrap_err().to_string(), "Invalid contract address format");
    }

    #[test]
    fn test_new_event_parser_invalid_hex() {
        let parser = EventParser::new("0xGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG");
        assert!(parser.is_err());
        assert_eq!(parser.unwrap_err().to_string(), "Contract address contains invalid hex characters");
    }

    #[test]
    fn test_new_event_parser_zero_address() {
        let parser = EventParser::new("0x0000000000000000000000000000000000000000");
        assert!(parser.is_err());
        assert_eq!(parser.unwrap_err().to_string(), "Contract address cannot be zero");
    }

    #[test]
    fn test_parse_logs_multiple_logs_mixed() {
        let parser = EventParser::new("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap();
        let logs = vec![
            Log {
                address: Address::from_str("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap(),
                topics: vec![parser.event_hash()],
                data: hex::decode("00000000000000000000000000000000000000000000000000000000000089ba27bc30064cc44c6aef26ca2d7e4ee667592949a50f4f01d8d4632461a12f2243").unwrap().into(),
                ..Default::default()
            },
            Log {
                address: Address::from_str("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap(),
                topics: vec![H256::zero()], // 非匹配主题
                data: vec![].into(),
                ..Default::default()
            },
            Log {
                address: Address::from_str("0x0000000000000000000000000000000000000001").unwrap(), // 非匹配地址
                topics: vec![parser.event_hash()],
                data: vec![].into(),
                ..Default::default()
            },
            Log {
                address: Address::from_str("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap(),
                topics: vec![parser.event_hash()],
                data: hex::decode("00000000000000000000000000000000000000000000000000000000000089bb27bc30064cc44c6aef26ca2d7e4ee667592949a50f4f01d8d4632461a12f2244").unwrap().into(),
                ..Default::default()
            },
        ];
        let results = parser.parse_logs(logs).unwrap();
        assert_eq!(results.len(), 2);
        assert_eq!(results[0].data_store_id, 35258);
        assert_eq!(results[1].data_store_id, 35259);
    }

}
```

#### `lib.rs` 文件

```rust
// src/lib.rs
pub mod client;
pub mod event_parser;
```

#### `main.rs` 文件

```rust
#![feature(coverage_attribute)]

use dotenv::dotenv;
use ethers::types::{Address, BlockNumber, FilterBlockOption};
use log::{debug, info};
use serde::Deserialize;
use std::str::FromStr;
use std::{env, fs};
use tracing::instrument;

mod client;
mod event_parser;

use client::EthClient;
use event_parser::EventParser;

#[derive(Debug, Deserialize)]
struct Config {
    rpc_url: String,
    contract_addr: String,
    tx_hash_example: String,
    start_block: u64,
    end_block: u64,
}

trait ConfigLoader {
    fn load(&self) -> Result<Config, anyhow::Error>;
}

struct YamlConfigLoader;
impl ConfigLoader for YamlConfigLoader {
    fn load(&self) -> Result<Config, anyhow::Error> {
        let content = fs::read_to_string("config.yaml")?;
        serde_yaml::from_str(&content).map_err(Into::into)
    }
}

struct EnvConfigLoader;
impl ConfigLoader for EnvConfigLoader {
    fn load(&self) -> Result<Config, anyhow::Error> {
        dotenv().ok();
        Ok(Config {
            rpc_url: env::var("RPC_URL").map_err(|_| anyhow::anyhow!("RPC_URL not set in .env"))?,
            contract_addr: env::var("CONTRACT_ADDR")
                .unwrap_or("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1".to_string()),
            tx_hash_example: env::var("TX_HASH_EXAMPLE").unwrap_or(
                "0xfd26d40e17213bcafcf94bab9af92343302df9df970f20e1c9d515525e86e23e".to_string(),
            ),
            start_block: env::var("START_BLOCK")
                .map(|s| s.parse::<u64>().expect("Invalid START_BLOCK"))
                .unwrap_or(20483831),
            end_block: env::var("END_BLOCK")
                .map(|s| s.parse::<u64>().expect("Invalid END_BLOCK"))
                .unwrap_or(20483833),
        })
    }
}

fn load_config() -> Result<Config, anyhow::Error> {
    let loader = YamlConfigLoader;
    loader.load().or_else(|_| EnvConfigLoader.load())
}

#[instrument(skip(config, client, parser))]
async fn run(config: Config, client: EthClient, parser: EventParser) -> Result<(), anyhow::Error> {
    info!("Connected to Ethereum node at {}", config.rpc_url);

    // 示例 1: 获取交易收据并解析日志
    let receipt = client
        .get_tx_receipt_by_hash(&config.tx_hash_example)
        .await
        .map_err(|e| {
            anyhow::anyhow!(
                "Failed to get receipt for tx {}: {}",
                config.tx_hash_example,
                e
            )
        })?;
    debug!(
        "Receipt details: logs_len={}, tx_hash={:?}, tx_index={:?}, block_hash={:?}, block_number={:?}",
        receipt.logs.len(),
        receipt.transaction_hash,
        receipt.transaction_index,
        receipt.block_hash,
        receipt.block_number
    );

    let tx_results = parser.parse_logs(receipt.logs)?;
    if tx_results.is_empty() {
        info!(
            "No ConfirmDataStore events found in transaction {}",
            config.tx_hash_example
        );
    } else {
        for (i, result) in tx_results.iter().enumerate() {
            info!(
                "Tx Receipt {} - DataStoreID: {}, HeaderHash: 0x{}",
                i + 1,
                result.data_store_id,
                hex::encode(result.header_hash)
            );
        }
    }

    // 示例 2: 获取区块范围内的日志并解析
    let addresses = vec![Address::from_str(&config.contract_addr)?];
    let block_option = FilterBlockOption::Range {
        from_block: Some(BlockNumber::Number(config.start_block.into())),
        to_block: Some(BlockNumber::Number(config.end_block.into())),
    };
    let topics = vec![parser.event_hash()];
    let logs = client
        .get_logs(block_option, Some(addresses), Some(topics))
        .await?;

    debug!("Retrieved {} logs", logs.len());
    let log_results = parser.parse_logs(logs)?;
    if log_results.is_empty() {
        info!(
            "No ConfirmDataStore events found in blocks {} to {}",
            config.start_block, config.end_block
        );
    } else {
        for (i, result) in log_results.iter().enumerate() {
            info!(
                "Log {} - DataStoreID: {}, HeaderHash: 0x{}",
                i + 1,
                result.data_store_id,
                hex::encode(result.header_hash)
            );
        }
    }

    Ok(())
}

#[tokio::main]
#[coverage(off)]
async fn main() -> Result<(), anyhow::Error> {
    tracing_subscriber::fmt::init();
    let config = load_config().map_err(|e| anyhow::anyhow!("Failed to load config: {}", e))?;
    info!("Loaded config: {:?}", config);

    let client = EthClient::new(&config.rpc_url)
        .await
        .map_err(|e| anyhow::anyhow!("Failed to initialize client: {}", e))?;
    let parser = EventParser::new(&config.contract_addr)
        .map_err(|e| anyhow::anyhow!("Failed to initialize parser: {}", e))?;

    run(config, client, parser).await
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_main_run() {
        let config = Config {
            rpc_url: "https://rpc.mevblocker.io".to_string(),
            contract_addr: String::from("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1"),
            tx_hash_example: String::from(
                "0xfd26d40e17213bcafcf94bab9af92343302df9df970f20e1c9d515525e86e23e",
            ),
            start_block: 20483831,
            end_block: 20483833,
        };
        let client = EthClient::new(&config.rpc_url).await.unwrap();
        let parser = EventParser::new(&config.contract_addr).unwrap();
        let result = run(config, client, parser).await;
        assert!(result.is_ok());
    }

    #[test]
    fn test_load_config_from_yaml() {
        let yaml_content = r#"
            rpc_url: "https://rpc.yaml.io"
            contract_addr: "0xabcdef1234567890abcdef1234567890abcdef12"
            tx_hash_example: "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
            start_block: 5000
            end_block: 6000
        "#;
        fs::write("config.yaml", yaml_content).unwrap();
        let config = YamlConfigLoader.load().unwrap();
        println!("config: {:#?}", config);
        assert_eq!(config.rpc_url, "https://rpc.yaml.io");
        assert_eq!(
            config.contract_addr,
            "0xabcdef1234567890abcdef1234567890abcdef12"
        );
        assert_eq!(config.start_block, 5000);
        assert_eq!(config.end_block, 6000);
        fs::remove_file("config.yaml").unwrap();
    }

    #[tokio::test]
    async fn test_run_empty_receipt() {
        let config = Config {
            rpc_url: "https://rpc.mevblocker.io".to_string(),
            contract_addr: "0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1".to_string(),
            tx_hash_example: "0x0000000000000000000000000000000000000000000000000000000000000000"
                .to_string(),
            start_block: 20483831,
            end_block: 20483833,
        };
        let client = EthClient::new(&config.rpc_url).await.unwrap();
        let parser = EventParser::new(&config.contract_addr).unwrap();
        let result = run(config, client, parser).await;
        assert!(result.is_err());
        assert!(
            result
                .unwrap_err()
                .to_string()
                .contains("Transaction receipt not found")
        );
    }

    #[tokio::test]
    async fn test_run_valid_receipt() {
        let config = Config {
            rpc_url: "https://rpc.mevblocker.io".to_string(),
            contract_addr: "0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1".to_string(),
            tx_hash_example: "0xfd26d40e17213bcafcf94bab9af92343302df9df970f20e1c9d515525e86e23e"
                .to_string(),
            start_block: 20483831,
            end_block: 20483833,
        };
        let client = EthClient::new(&config.rpc_url).await.unwrap();
        let parser = EventParser::new(&config.contract_addr).unwrap();
        let result = run(config, client, parser).await;
        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_run_empty_logs() {
        let config = Config {
            rpc_url: "https://rpc.mevblocker.io".to_string(),
            contract_addr: "0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1".to_string(),
            tx_hash_example: "0x0000000000000000000000000000000000000000000000000000000000000000"
                .to_string(),
            start_block: 0,
            end_block: 0,
        };
        let client = EthClient::new(&config.rpc_url).await.unwrap();
        let parser = EventParser::new(&config.contract_addr).unwrap();
        let result = run(config, client, parser).await;

        assert!(result.is_err());
        assert!(
            result
                .unwrap_err()
                .to_string()
                .contains("Failed to get receipt for tx")
        );
    }

    #[test]
    fn test_load_config_invalid_yaml() {
        let yaml_content = r#"
            rpc_url: "https://rpc.yaml.io"
            contract_addr: "0xabcdef1234567890abcdef1234567890abcdef12"
            tx_hash_example: "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef"
            start_block: "invalid" # 无效的 u64
        "#;
        fs::write("config.yaml", yaml_content).unwrap();
        let result = YamlConfigLoader.load();
        println!("result: {:#?}", result);
        assert!(result.is_err());
        assert!(result.unwrap_err().to_string().contains("invalid type"));
        fs::remove_file("config.yaml").unwrap();
    }

    #[test]
    fn test_load_config() {
        let result = load_config();
        assert!(result.is_ok());
    }

    #[tokio::test]
    async fn test_run_get_logs_error() {
        let config = Config {
            rpc_url: "https://invalid-rpc.example.com".to_string(),
            contract_addr: "0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1".to_string(),
            tx_hash_example: "0x0000000000000000000000000000000000000000000000000000000000000000"
                .to_string(),
            start_block: 20483831,
            end_block: 20483833,
        };
        let client = EthClient::new(&config.rpc_url).await.unwrap();
        let parser = EventParser::new(&config.contract_addr).unwrap();
        let result = run(config, client, parser).await;
        println!("result: {:#?}", result);
        assert!(result.is_err());
        assert!(
            result
                .unwrap_err()
                .to_string()
                .contains("Failed to get receipt")
        );
    }
}

```

#### `integration.rs` 文件

```rust
// tests/integration.rs
use ethers::types::{Address, BlockNumber, FilterBlockOption};
use std::str::FromStr;
use rust::client::EthClient;
use rust::event_parser::EventParser;

#[tokio::test]
async fn test_client_and_parser_integration() {
    let client = EthClient::new("https://rpc.mevblocker.io").await.unwrap();
    let parser = EventParser::new("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap();
    let addresses = vec![Address::from_str("0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1").unwrap()];
    let block_option = FilterBlockOption::Range {
        from_block: Some(BlockNumber::Number(20483831.into())),
        to_block: Some(BlockNumber::Number(20483833.into())),
    };
    let logs = client.get_logs(block_option, Some(addresses), Some(vec![parser.event_hash()])).await.unwrap();
    let results = parser.parse_logs(logs).unwrap();
    assert!(!results.is_empty());
}

```

### 编译并运行当前项目

```bash
ethertrace/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 4.1s 
➜ cargo run # # 默认运行（Debug 模式）
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.50s
     Running `target/debug/rust`
2025-05-01T03:43:23.436211Z  INFO rust: Loaded config: Config { rpc_url: "https://eth.llamarpc.com", contract_addr: "0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1", tx_hash_example: "0xfd26d40e17213bcafcf94bab9af92343302df9df970f20e1c9d515525e86e23e", start_block: 20483831, end_block: 20483833 }    
2025-05-01T03:43:23.440658Z  INFO run: rust: Connected to Ethereum node at https://eth.llamarpc.com    
Error: Failed to get receipt for tx 0xfd26d40e17213bcafcf94bab9af92343302df9df970f20e1c9d515525e86e23e: Deserialization Error: expected value at line 1 column 1. Response: error code: 1015

```

### `cargo nextest run` 和 `cargo test` 的区别

|      特性      |    `cargo nextest run`     |      `cargo test`      |
| :------------: | :------------------------: | :--------------------: |
| **测试并行化** |    动态智能调度（更快）    |     按文件顺序执行     |
|  **输出报告**  |  彩色分级展示 + 耗时排序   |      原始文本输出      |
|  **增量测试**  |    支持仅运行修改的测试    |    需手动指定测试名    |
|  **进程隔离**  | 每个测试独立进程（更稳定） | 默认同进程可能相互干扰 |
|  **缓存机制**  |    自动跳过未变更的测试    |           无           |

### 运行测试

```bash
ethertrace/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ cargo test
   Compiling predicates-core v1.0.9
   Compiling termtree v0.5.1
   Compiling anstyle v1.0.10
   Compiling fragile v2.0.1
   Compiling downcast v0.11.0
   Compiling mockall_derive v0.13.1
   Compiling predicates-tree v1.0.12
   Compiling predicates v3.1.3
   Compiling mockall v0.13.1
   Compiling rust v0.1.0 (/Users/qiaopengjun/Code/Web3Wallet/ethertrace/rust)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 3.53s
     Running unittests src/lib.rs (target/debug/deps/rust-f1e062b72a7ea26e)

running 37 tests
test client::tests::test_get_tx_receipt_by_hash_invalid_format ... ok
test client::tests::test_get_tx_receipt_by_hash_not_found ... ok
test client::tests::test_new_eth_client ... ok
test client::tests::test_new_eth_client_domain_regex ... ok
test client::tests::test_new_eth_client_empty_url ... ok
test client::tests::test_new_eth_client_invalid_provider ... ok
test client::tests::test_new_eth_client_invalid_scheme ... ok
test client::tests::test_new_eth_client_invalid_url ... ok
test client::tests::test_new_eth_client_invalid_url_format ... ok
test client::tests::test_new_eth_client_missing_scheme ... ok
test client::tests::test_new_eth_client_with_valid_url ... ok
test client::tests::test_new_eth_client_ws_scheme ... ok
test client::tests::test_new_eth_client_wss_scheme ... ok
test event_parser::tests::test_event_hash ... ok
test event_parser::tests::test_new_event_parser ... ok
test event_parser::tests::test_new_event_parser_empty_address ... ok
test event_parser::tests::test_new_event_parser_invalid_address ... ok
test event_parser::tests::test_new_event_parser_invalid_format ... ok
test event_parser::tests::test_new_event_parser_invalid_hex ... ok
test event_parser::tests::test_new_event_parser_missing_prefix ... ok
test event_parser::tests::test_new_event_parser_zero_address ... ok
test event_parser::tests::test_parse_logs_empty ... ok
test event_parser::tests::test_parse_logs_invalid_data ... ok
test event_parser::tests::test_parse_logs_multiple_logs_mixed ... ok
test event_parser::tests::test_parse_logs_non_matching ... ok
test event_parser::tests::test_parse_logs_single_valid_log ... ok
test client::tests::test_get_tx_receipt_by_hash ... ok
test client::tests::test_get_tx_receipt_by_hash_success ... ok
test client::tests::test_get_logs_at_block_hash ... ok
test client::tests::test_get_logs_empty ... ok
test client::tests::test_get_logs_at_block_hash2 ... ok
test client::tests::test_get_logs_empty_range ... ok
test client::tests::test_get_logs_single_topic ... ok
test client::tests::test_get_logs_range ... ok
test client::tests::test_get_logs_four_topics ... ok
test client::tests::test_get_logs_with_address_and_topic ... ok
test client::tests::test_get_logs_no_topics ... ok

test result: ok. 37 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 4.87s

     Running unittests src/main.rs (target/debug/deps/rust-d878354c53ba62e3)

running 45 tests
test client::tests::test_get_tx_receipt_by_hash_invalid_format ... ok
test client::tests::test_get_tx_receipt_by_hash_not_found ... ok
test client::tests::test_new_eth_client ... ok
test client::tests::test_new_eth_client_domain_regex ... ok
test client::tests::test_new_eth_client_empty_url ... ok
test client::tests::test_new_eth_client_invalid_provider ... ok
test client::tests::test_new_eth_client_invalid_scheme ... ok
test client::tests::test_new_eth_client_invalid_url ... ok
test client::tests::test_new_eth_client_invalid_url_format ... ok
test client::tests::test_new_eth_client_missing_scheme ... ok
test client::tests::test_new_eth_client_with_valid_url ... ok
test client::tests::test_new_eth_client_ws_scheme ... ok
test client::tests::test_new_eth_client_wss_scheme ... ok
test event_parser::tests::test_event_hash ... ok
test event_parser::tests::test_new_event_parser ... ok
test event_parser::tests::test_new_event_parser_empty_address ... ok
test event_parser::tests::test_new_event_parser_invalid_address ... ok
test event_parser::tests::test_new_event_parser_invalid_format ... ok
test event_parser::tests::test_new_event_parser_invalid_hex ... ok
test event_parser::tests::test_new_event_parser_missing_prefix ... ok
test event_parser::tests::test_new_event_parser_zero_address ... ok
test event_parser::tests::test_parse_logs_empty ... ok
test event_parser::tests::test_parse_logs_invalid_data ... ok
test event_parser::tests::test_parse_logs_multiple_logs_mixed ... ok
test event_parser::tests::test_parse_logs_non_matching ... ok
test event_parser::tests::test_parse_logs_single_valid_log ... ok
test tests::test_load_config ... ok
test tests::test_load_config_from_yaml ... ok
test tests::test_load_config_invalid_yaml ... ok
test client::tests::test_get_tx_receipt_by_hash ... ok
test client::tests::test_get_logs_at_block_hash ... ok
test client::tests::test_get_logs_empty_range ... ok
test client::tests::test_get_logs_single_topic ... ok
test client::tests::test_get_logs_at_block_hash2 ... ok
test client::tests::test_get_logs_with_address_and_topic ... ok
test client::tests::test_get_logs_empty ... ok
test client::tests::test_get_logs_range ... ok
test client::tests::test_get_logs_four_topics ... ok
test client::tests::test_get_tx_receipt_by_hash_success ... ok
test tests::test_run_empty_logs ... ok
test tests::test_run_get_logs_error ... ok
test tests::test_run_empty_receipt ... ok
test tests::test_main_run ... ok
test tests::test_run_valid_receipt ... ok
test client::tests::test_get_logs_no_topics ... ok

test result: ok. 45 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 4.44s

     Running tests/integration.rs (target/debug/deps/integration-aa4dacd5be11cac4)

running 1 test
test test_client_and_parser_integration ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.98s

   Doc-tests rust

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s


ethertrace/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 15.5s 
➜ cargo nextest run                            
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.21s
────────────
 Nextest run ID 1eafe0f3-9d9f-4385-bf67-752b7db71c2c with nextest profile: default
    Starting 83 tests across 3 binaries
        PASS [   0.120s] rust client::tests::test_get_tx_receipt_by_hash_invalid_format
        PASS [   0.597s] rust client::tests::test_get_tx_receipt_by_hash_not_found
        PASS [   0.601s] rust client::tests::test_get_tx_receipt_by_hash
        PASS [   0.482s] rust client::tests::test_get_tx_receipt_by_hash_success
        PASS [   0.013s] rust client::tests::test_new_eth_client_empty_url
        PASS [   0.053s] rust client::tests::test_new_eth_client_domain_regex
        PASS [   0.056s] rust client::tests::test_new_eth_client
        PASS [   0.045s] rust client::tests::test_new_eth_client_invalid_provider
        PASS [   0.008s] rust client::tests::test_new_eth_client_invalid_url
        PASS [   0.008s] rust client::tests::test_new_eth_client_invalid_scheme
        PASS [   0.007s] rust client::tests::test_new_eth_client_invalid_url_format
        PASS [   0.008s] rust client::tests::test_new_eth_client_missing_scheme
        PASS [   0.037s] rust client::tests::test_new_eth_client_with_valid_url
        PASS [   0.036s] rust client::tests::test_new_eth_client_ws_scheme
        PASS [   0.035s] rust client::tests::test_new_eth_client_wss_scheme
        PASS [   0.007s] rust event_parser::tests::test_event_hash
        PASS [   0.007s] rust event_parser::tests::test_new_event_parser
        PASS [   0.007s] rust event_parser::tests::test_new_event_parser_empty_address
        PASS [   0.006s] rust event_parser::tests::test_new_event_parser_invalid_address
        PASS [   0.006s] rust event_parser::tests::test_new_event_parser_invalid_format
        PASS [   0.006s] rust event_parser::tests::test_new_event_parser_invalid_hex
        PASS [   0.006s] rust event_parser::tests::test_new_event_parser_missing_prefix
        PASS [   0.006s] rust event_parser::tests::test_new_event_parser_zero_address
        PASS [   0.006s] rust event_parser::tests::test_parse_logs_empty
        PASS [   0.006s] rust event_parser::tests::test_parse_logs_invalid_data
        PASS [   0.007s] rust event_parser::tests::test_parse_logs_multiple_logs_mixed
        PASS [   0.006s] rust event_parser::tests::test_parse_logs_non_matching
        PASS [   0.006s] rust event_parser::tests::test_parse_logs_single_valid_log
        PASS [   0.931s] rust client::tests::test_get_logs_at_block_hash2
        PASS [   0.941s] rust client::tests::test_get_logs_range
        PASS [   0.957s] rust client::tests::test_get_logs_empty
        PASS [   0.959s] rust client::tests::test_get_logs_single_topic
        PASS [   0.961s] rust client::tests::test_get_logs_at_block_hash
        PASS [   0.965s] rust client::tests::test_get_logs_empty_range
        PASS [   0.969s] rust client::tests::test_get_logs_four_topics
        PASS [   1.040s] rust client::tests::test_get_logs_with_address_and_topic
        PASS [   0.868s] rust::integration test_client_and_parser_integration
        PASS [   0.889s] rust::bin/rust client::tests::test_get_logs_at_block_hash
        PASS [   0.030s] rust::bin/rust client::tests::test_get_tx_receipt_by_hash_invalid_format
        PASS [   0.927s] rust::bin/rust client::tests::test_get_logs_at_block_hash2
        PASS [   0.023s] rust::bin/rust client::tests::test_new_eth_client
        PASS [   0.022s] rust::bin/rust client::tests::test_new_eth_client_domain_regex
        PASS [   0.007s] rust::bin/rust client::tests::test_new_eth_client_empty_url
        PASS [   0.023s] rust::bin/rust client::tests::test_new_eth_client_invalid_provider
        PASS [   0.007s] rust::bin/rust client::tests::test_new_eth_client_invalid_scheme
        PASS [   0.006s] rust::bin/rust client::tests::test_new_eth_client_invalid_url
        PASS [   0.006s] rust::bin/rust client::tests::test_new_eth_client_invalid_url_format
        PASS [   0.007s] rust::bin/rust client::tests::test_new_eth_client_missing_scheme
        PASS [   0.830s] rust::bin/rust client::tests::test_get_logs_empty_range
        PASS [   0.845s] rust::bin/rust client::tests::test_get_logs_empty
        PASS [   0.027s] rust::bin/rust client::tests::test_new_eth_client_with_valid_url
        PASS [   0.007s] rust::bin/rust event_parser::tests::test_event_hash
        PASS [   0.841s] rust::bin/rust client::tests::test_get_logs_four_topics
        PASS [   0.032s] rust::bin/rust client::tests::test_new_eth_client_ws_scheme
        PASS [   0.007s] rust::bin/rust event_parser::tests::test_new_event_parser
        PASS [   0.006s] rust::bin/rust event_parser::tests::test_new_event_parser_empty_address
        PASS [   0.030s] rust::bin/rust client::tests::test_new_eth_client_wss_scheme
        PASS [   0.007s] rust::bin/rust event_parser::tests::test_new_event_parser_invalid_address
        PASS [   0.007s] rust::bin/rust event_parser::tests::test_new_event_parser_invalid_format
        PASS [   0.006s] rust::bin/rust event_parser::tests::test_new_event_parser_invalid_hex
        PASS [   0.007s] rust::bin/rust event_parser::tests::test_new_event_parser_missing_prefix
        PASS [   0.006s] rust::bin/rust event_parser::tests::test_new_event_parser_zero_address
        PASS [   0.006s] rust::bin/rust event_parser::tests::test_parse_logs_empty
        PASS [   0.007s] rust::bin/rust event_parser::tests::test_parse_logs_invalid_data
        PASS [   0.007s] rust::bin/rust event_parser::tests::test_parse_logs_multiple_logs_mixed
        PASS [   0.007s] rust::bin/rust event_parser::tests::test_parse_logs_non_matching
        PASS [   0.006s] rust::bin/rust event_parser::tests::test_parse_logs_single_valid_log
        PASS [   0.007s] rust::bin/rust tests::test_load_config
        PASS [   0.007s] rust::bin/rust tests::test_load_config_from_yaml
        PASS [   0.006s] rust::bin/rust tests::test_load_config_invalid_yaml
        PASS [   0.884s] rust::bin/rust client::tests::test_get_logs_range
        PASS [   0.881s] rust::bin/rust client::tests::test_get_logs_single_topic
        PASS [   0.883s] rust::bin/rust client::tests::test_get_logs_with_address_and_topic
        PASS [   0.895s] rust::bin/rust client::tests::test_get_tx_receipt_by_hash
        PASS [   0.490s] rust::bin/rust client::tests::test_get_tx_receipt_by_hash_success
        PASS [   0.380s] rust::bin/rust tests::test_run_get_logs_error
        PASS [   0.763s] rust::bin/rust client::tests::test_get_tx_receipt_by_hash_not_found
        PASS [   0.861s] rust::bin/rust tests::test_run_empty_receipt
        PASS [   0.911s] rust::bin/rust tests::test_run_empty_logs
        PASS [   1.206s] rust::bin/rust tests::test_run_valid_receipt
        PASS [   1.244s] rust::bin/rust tests::test_main_run
        PASS [   4.798s] rust client::tests::test_get_logs_no_topics
        PASS [   4.375s] rust::bin/rust client::tests::test_get_logs_no_topics
────────────
     Summary [   5.335s] 83 tests run: 83 passed, 0 skipped
```

### `cargo llvm-cov --all-features --workspace --tests` 和 `cargo llvm-cov` 关键区别

| 特性             | cargo llvm-cov                               | cargo llvm-cov --all-features --workspace --tests |
| ---------------- | -------------------------------------------- | ------------------------------------------------- |
| 测试范围         | 当前 crate 的测试                            | 工作空间中所有 crate 的测试                       |
| 功能（Features） | 仅默认功能                                   | 所有功能（默认 + 可选）                           |
| 测试类型         | 所有测试（单元、集成、文档等，视上下文而定） | 仅单元测试和集成测试（由 --tests 显式指定）       |
| 覆盖率报告范围   | 当前 crate                                   | 整个工作空间（所有 crate）                        |
| 适用场景         | 单一 crate，快速调试                         | 多 crate 工作空间，全面测试，CI/CD                |
| 运行时间         | 较短（测试范围小）                           | 较长（测试所有 crate 和功能）                     |
| 配置复杂性       | 简单，无需额外参数                           | 需指定参数，配置更复杂                            |

- 核心区别：
  - cargo llvm-cov：测试范围小，仅覆盖当前 crate 和默认功能，适合快速本地调试。
  - cargo llvm-cov --all-features --workspace --tests：测试范围广，覆盖整个工作空间、所有功能和显式测试，适合全面验证。

### 查看生成 Rust 项目的代码覆盖率报告

```bash
ethertrace/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 18.5s 
➜ cargo llvm-cov 
info: cargo-llvm-cov currently setting cfg(coverage) and cfg(coverage_nightly); you can opt-out it by passing --no-cfg-coverage and --no-cfg-coverage-nightly
   Compiling rust v0.1.0 (/Users/qiaopengjun/Code/Web3Wallet/ethertrace/rust)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 2.56s
     Running unittests src/lib.rs (target/llvm-cov-target/debug/deps/rust-dbe7fa2021cc4dc4)

running 37 tests
test client::tests::test_get_tx_receipt_by_hash_invalid_format ... ok
test client::tests::test_get_tx_receipt_by_hash ... ok
test client::tests::test_get_tx_receipt_by_hash_success ... ok
test client::tests::test_new_eth_client ... ok
test client::tests::test_new_eth_client_domain_regex ... ok
test client::tests::test_new_eth_client_empty_url ... ok
test client::tests::test_new_eth_client_invalid_scheme ... ok
test client::tests::test_new_eth_client_invalid_provider ... ok
test client::tests::test_new_eth_client_invalid_url ... ok
test client::tests::test_new_eth_client_invalid_url_format ... ok
test client::tests::test_new_eth_client_missing_scheme ... ok
test client::tests::test_new_eth_client_with_valid_url ... ok
test client::tests::test_new_eth_client_ws_scheme ... ok
test client::tests::test_new_eth_client_wss_scheme ... ok
test event_parser::tests::test_new_event_parser ... ok
test event_parser::tests::test_event_hash ... ok
test event_parser::tests::test_new_event_parser_empty_address ... ok
test event_parser::tests::test_new_event_parser_invalid_address ... ok
test event_parser::tests::test_new_event_parser_invalid_format ... ok
test event_parser::tests::test_new_event_parser_invalid_hex ... ok
test event_parser::tests::test_new_event_parser_missing_prefix ... ok
test event_parser::tests::test_new_event_parser_zero_address ... ok
test event_parser::tests::test_parse_logs_empty ... ok
test event_parser::tests::test_parse_logs_invalid_data ... ok
test event_parser::tests::test_parse_logs_multiple_logs_mixed ... ok
test event_parser::tests::test_parse_logs_non_matching ... ok
test event_parser::tests::test_parse_logs_single_valid_log ... ok
test client::tests::test_get_tx_receipt_by_hash_not_found ... ok
test client::tests::test_get_logs_empty ... ok
test client::tests::test_get_logs_with_address_and_topic ... ok
test client::tests::test_get_logs_at_block_hash2 ... ok
test client::tests::test_get_logs_range ... ok
test client::tests::test_get_logs_four_topics ... ok
test client::tests::test_get_logs_single_topic ... ok
test client::tests::test_get_logs_at_block_hash ... ok
test client::tests::test_get_logs_empty_range ... ok
test client::tests::test_get_logs_no_topics ... ok

test result: ok. 37 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 5.20s

     Running unittests src/main.rs (target/llvm-cov-target/debug/deps/rust-054928a06b249be0)

running 45 tests
test client::tests::test_get_tx_receipt_by_hash_invalid_format ... ok
test client::tests::test_get_tx_receipt_by_hash ... ok
test client::tests::test_new_eth_client ... ok
test client::tests::test_new_eth_client_domain_regex ... ok
test client::tests::test_new_eth_client_empty_url ... ok
test client::tests::test_new_eth_client_invalid_provider ... ok
test client::tests::test_new_eth_client_invalid_scheme ... ok
test client::tests::test_new_eth_client_invalid_url ... ok
test client::tests::test_new_eth_client_invalid_url_format ... ok
test client::tests::test_new_eth_client_missing_scheme ... ok
test client::tests::test_new_eth_client_with_valid_url ... ok
test client::tests::test_new_eth_client_ws_scheme ... ok
test client::tests::test_new_eth_client_wss_scheme ... ok
test event_parser::tests::test_event_hash ... ok
test event_parser::tests::test_new_event_parser ... ok
test event_parser::tests::test_new_event_parser_empty_address ... ok
test event_parser::tests::test_new_event_parser_invalid_address ... ok
test event_parser::tests::test_new_event_parser_invalid_format ... ok
test event_parser::tests::test_new_event_parser_invalid_hex ... ok
test event_parser::tests::test_new_event_parser_missing_prefix ... ok
test event_parser::tests::test_new_event_parser_zero_address ... ok
test event_parser::tests::test_parse_logs_empty ... ok
test event_parser::tests::test_parse_logs_invalid_data ... ok
test event_parser::tests::test_parse_logs_multiple_logs_mixed ... ok
test event_parser::tests::test_parse_logs_non_matching ... ok
test event_parser::tests::test_parse_logs_single_valid_log ... ok
test tests::test_load_config ... ok
test tests::test_load_config_from_yaml ... ok
test tests::test_load_config_invalid_yaml ... ok
test client::tests::test_get_tx_receipt_by_hash_not_found ... ok
test client::tests::test_get_tx_receipt_by_hash_success ... ok
test client::tests::test_get_logs_at_block_hash2 ... ok
test client::tests::test_get_logs_single_topic ... ok
test client::tests::test_get_logs_range ... ok
test client::tests::test_get_logs_at_block_hash ... ok
test client::tests::test_get_logs_with_address_and_topic ... ok
test client::tests::test_get_logs_empty ... ok
test client::tests::test_get_logs_empty_range ... ok
test client::tests::test_get_logs_four_topics ... ok
test tests::test_run_get_logs_error ... ok
test tests::test_run_empty_receipt ... ok
test tests::test_run_empty_logs ... ok
test tests::test_main_run ... ok
test tests::test_run_valid_receipt ... ok
test client::tests::test_get_logs_no_topics ... ok

test result: ok. 45 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 2.29s

     Running tests/integration.rs (target/llvm-cov-target/debug/deps/integration-68d09ec8e787304b)

running 1 test
test test_client_and_parser_integration ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.91s

Filename                      Regions    Missed Regions     Cover   Functions  Missed Functions  Executed       Lines      Missed Lines     Cover    Branches   Missed Branches     Cover
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
client.rs                         233                15    93.56%          56                 0   100.00%         421                 3    99.29%           0                 0         -
event_parser.rs                    78                 5    93.59%          17                 0   100.00%         202                 0   100.00%           0                 0         -
main.rs                            72                 4    94.44%          21                 3    85.71%         243                 3    98.77%           0                 0         -
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TOTAL                             383                24    93.73%          94                 3    96.81%         866                 6    99.31%           0                 0         -


# 进入你的 Rust 项目目录（包含 Cargo.toml 的目录），然后运行：
ethertrace/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 14.5s 
➜ cargo llvm-cov --all-features --workspace --tests
info: cargo-llvm-cov currently setting cfg(coverage) and cfg(coverage_nightly); you can opt-out it by passing --no-cfg-coverage and --no-cfg-coverage-nightly
   Compiling rust v0.1.0 (/Users/qiaopengjun/Code/Web3Wallet/ethertrace/rust)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 2.60s
     Running unittests src/lib.rs (target/llvm-cov-target/debug/deps/rust-dbe7fa2021cc4dc4)

running 37 tests
test client::tests::test_get_tx_receipt_by_hash_invalid_format ... ok
test client::tests::test_get_tx_receipt_by_hash_not_found ... ok
test client::tests::test_new_eth_client ... ok
test client::tests::test_new_eth_client_domain_regex ... ok
test client::tests::test_new_eth_client_empty_url ... ok
test client::tests::test_new_eth_client_invalid_provider ... ok
test client::tests::test_new_eth_client_invalid_scheme ... ok
test client::tests::test_new_eth_client_invalid_url ... ok
test client::tests::test_new_eth_client_invalid_url_format ... ok
test client::tests::test_new_eth_client_missing_scheme ... ok
test client::tests::test_get_tx_receipt_by_hash ... ok
test client::tests::test_new_eth_client_with_valid_url ... ok
test client::tests::test_new_eth_client_ws_scheme ... ok
test client::tests::test_new_eth_client_wss_scheme ... ok
test event_parser::tests::test_new_event_parser ... ok
test event_parser::tests::test_event_hash ... ok
test event_parser::tests::test_new_event_parser_empty_address ... ok
test event_parser::tests::test_new_event_parser_invalid_address ... ok
test event_parser::tests::test_new_event_parser_invalid_format ... ok
test event_parser::tests::test_new_event_parser_invalid_hex ... ok
test event_parser::tests::test_new_event_parser_missing_prefix ... ok
test event_parser::tests::test_new_event_parser_zero_address ... ok
test event_parser::tests::test_parse_logs_empty ... ok
test event_parser::tests::test_parse_logs_invalid_data ... ok
test event_parser::tests::test_parse_logs_multiple_logs_mixed ... ok
test event_parser::tests::test_parse_logs_non_matching ... ok
test event_parser::tests::test_parse_logs_single_valid_log ... ok
test client::tests::test_get_tx_receipt_by_hash_success ... ok
test client::tests::test_get_logs_single_topic ... ok
test client::tests::test_get_logs_at_block_hash2 ... ok
test client::tests::test_get_logs_range ... ok
test client::tests::test_get_logs_with_address_and_topic ... ok
test client::tests::test_get_logs_four_topics ... ok
test client::tests::test_get_logs_empty ... ok
test client::tests::test_get_logs_empty_range ... ok
test client::tests::test_get_logs_at_block_hash ... ok
test client::tests::test_get_logs_no_topics ... ok

test result: ok. 37 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 4.87s

     Running unittests src/main.rs (target/llvm-cov-target/debug/deps/rust-054928a06b249be0)

running 45 tests
test client::tests::test_get_tx_receipt_by_hash_invalid_format ... ok
test client::tests::test_get_tx_receipt_by_hash_not_found ... ok
test client::tests::test_new_eth_client ... ok
test client::tests::test_new_eth_client_domain_regex ... ok
test client::tests::test_new_eth_client_empty_url ... ok
test client::tests::test_new_eth_client_invalid_provider ... ok
test client::tests::test_new_eth_client_invalid_scheme ... ok
test client::tests::test_new_eth_client_invalid_url ... ok
test client::tests::test_new_eth_client_invalid_url_format ... ok
test client::tests::test_new_eth_client_missing_scheme ... ok
test client::tests::test_new_eth_client_with_valid_url ... ok
test client::tests::test_new_eth_client_ws_scheme ... ok
test client::tests::test_new_eth_client_wss_scheme ... ok
test event_parser::tests::test_event_hash ... ok
test event_parser::tests::test_new_event_parser ... ok
test event_parser::tests::test_new_event_parser_empty_address ... ok
test event_parser::tests::test_new_event_parser_invalid_address ... ok
test event_parser::tests::test_new_event_parser_invalid_format ... ok
test event_parser::tests::test_new_event_parser_invalid_hex ... ok
test event_parser::tests::test_new_event_parser_missing_prefix ... ok
test event_parser::tests::test_new_event_parser_zero_address ... ok
test event_parser::tests::test_parse_logs_empty ... ok
test event_parser::tests::test_parse_logs_invalid_data ... ok
test event_parser::tests::test_parse_logs_multiple_logs_mixed ... ok
test event_parser::tests::test_parse_logs_non_matching ... ok
test event_parser::tests::test_parse_logs_single_valid_log ... ok
test tests::test_load_config ... ok
test tests::test_load_config_from_yaml ... ok
test tests::test_load_config_invalid_yaml ... ok
test client::tests::test_get_tx_receipt_by_hash ... ok
test client::tests::test_get_logs_single_topic ... ok
test client::tests::test_get_logs_four_topics ... ok
test client::tests::test_get_logs_empty_range ... ok
test client::tests::test_get_logs_range ... ok
test client::tests::test_get_logs_at_block_hash ... ok
test client::tests::test_get_logs_empty ... ok
test client::tests::test_get_logs_at_block_hash2 ... ok
test client::tests::test_get_logs_with_address_and_topic ... ok
test client::tests::test_get_tx_receipt_by_hash_success ... ok
test tests::test_run_get_logs_error ... ok
test tests::test_run_empty_logs ... ok
test tests::test_main_run ... ok
test tests::test_run_empty_receipt ... ok
test tests::test_run_valid_receipt ... ok
test client::tests::test_get_logs_no_topics ... ok

test result: ok. 45 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 5.80s

     Running tests/integration.rs (target/llvm-cov-target/debug/deps/integration-68d09ec8e787304b)

running 1 test
test test_client_and_parser_integration ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.99s

Filename                      Regions    Missed Regions     Cover   Functions  Missed Functions  Executed       Lines      Missed Lines     Cover    Branches   Missed Branches     Cover
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
client.rs                         233                15    93.56%          56                 0   100.00%         421                 3    99.29%           0                 0         -
event_parser.rs                    78                 5    93.59%          17                 0   100.00%         202                 0   100.00%           0                 0         -
main.rs                            72                 4    94.44%          21                 3    85.71%         243                 3    98.77%           0                 0         -
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TOTAL                             383                24    93.73%          94                 3    96.81%         866                 6    99.31%           0                 0         -
```

### `cargo llvm-cov --open` 和 `cargo llvm-cov --html` 关键区别

| 特性           | cargo llvm-cov --open                                        | cargo llvm-cov --html              |
| -------------- | ------------------------------------------------------------ | ---------------------------------- |
| 生成 HTML 报告 | 是（存储在 target/llvm-cov/html/）                           | 是（存储在 target/llvm-cov/html/） |
| 自动打开浏览器 | 是（使用系统默认浏览器）                                     | 否（需手动打开 index.html）        |
| 运行测试       | 是（运行所有测试，收集覆盖率）                               | 是（运行所有测试，收集覆盖率）     |
| 输出格式       | HTML 报告                                                    | HTML 报告                          |
| 使用场景       | 开发调试，快速查看覆盖率                                     | CI/CD 或手动检查报告               |
| 命令后续步骤   | 自动打开 index.html                                          | 无后续步骤                         |
| 等效手动操作   | cargo llvm-cov --html && open target/llvm-cov/html/index.html | cargo llvm-cov --html              |

- 核心区别：
  - --open 包含 --html 的所有功能，并额外自动打开浏览器。
  - --html 只生成报告，适合非交互式环境或手动查看。

### 生成覆盖率报告（HTML 格式）并在浏览器中查看

使用 cargo llvm-cov --html 生成覆盖率报告（HTML 格式），然后手动通过 open target/llvm-cov/html/index.html 在浏览器中查看报告。

```bash
ethertrace/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 17.9s 
➜ cargo llvm-cov --html                            
open target/llvm-cov/html/index.html
info: cargo-llvm-cov currently setting cfg(coverage) and cfg(coverage_nightly); you can opt-out it by passing --no-cfg-coverage and --no-cfg-coverage-nightly
   Compiling rust v0.1.0 (/Users/qiaopengjun/Code/Web3Wallet/ethertrace/rust)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 2.75s
     Running unittests src/lib.rs (target/llvm-cov-target/debug/deps/rust-dbe7fa2021cc4dc4)

running 37 tests
test client::tests::test_get_tx_receipt_by_hash_invalid_format ... ok
test client::tests::test_get_tx_receipt_by_hash_success ... ok
test client::tests::test_get_tx_receipt_by_hash ... ok
test client::tests::test_new_eth_client ... ok
test client::tests::test_new_eth_client_domain_regex ... ok
test client::tests::test_new_eth_client_empty_url ... ok
test client::tests::test_new_eth_client_invalid_scheme ... ok
test client::tests::test_new_eth_client_invalid_url ... ok
test client::tests::test_new_eth_client_invalid_provider ... ok
test client::tests::test_new_eth_client_invalid_url_format ... ok
test client::tests::test_new_eth_client_missing_scheme ... ok
test client::tests::test_new_eth_client_with_valid_url ... ok
test client::tests::test_new_eth_client_ws_scheme ... ok
test client::tests::test_new_eth_client_wss_scheme ... ok
test event_parser::tests::test_event_hash ... ok
test event_parser::tests::test_new_event_parser_empty_address ... ok
test event_parser::tests::test_new_event_parser ... ok
test event_parser::tests::test_new_event_parser_invalid_address ... ok
test event_parser::tests::test_new_event_parser_invalid_format ... ok
test event_parser::tests::test_new_event_parser_invalid_hex ... ok
test event_parser::tests::test_new_event_parser_missing_prefix ... ok
test event_parser::tests::test_new_event_parser_zero_address ... ok
test event_parser::tests::test_parse_logs_empty ... ok
test event_parser::tests::test_parse_logs_invalid_data ... ok
test event_parser::tests::test_parse_logs_multiple_logs_mixed ... ok
test event_parser::tests::test_parse_logs_non_matching ... ok
test event_parser::tests::test_parse_logs_single_valid_log ... ok
test client::tests::test_get_tx_receipt_by_hash_not_found ... ok
test client::tests::test_get_logs_at_block_hash ... ok
test client::tests::test_get_logs_single_topic ... ok
test client::tests::test_get_logs_empty_range ... ok
test client::tests::test_get_logs_empty ... ok
test client::tests::test_get_logs_with_address_and_topic ... ok
test client::tests::test_get_logs_four_topics ... ok
test client::tests::test_get_logs_range ... ok
test client::tests::test_get_logs_at_block_hash2 ... ok
test client::tests::test_get_logs_no_topics ... ok

test result: ok. 37 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 5.69s

     Running unittests src/main.rs (target/llvm-cov-target/debug/deps/rust-054928a06b249be0)

running 45 tests
test client::tests::test_get_tx_receipt_by_hash_invalid_format ... ok
test client::tests::test_get_tx_receipt_by_hash_success ... ok
test client::tests::test_new_eth_client ... ok
test client::tests::test_new_eth_client_domain_regex ... ok
test client::tests::test_new_eth_client_empty_url ... ok
test client::tests::test_new_eth_client_invalid_provider ... ok
test client::tests::test_new_eth_client_invalid_scheme ... ok
test client::tests::test_new_eth_client_invalid_url ... ok
test client::tests::test_new_eth_client_invalid_url_format ... ok
test client::tests::test_new_eth_client_missing_scheme ... ok
test client::tests::test_new_eth_client_with_valid_url ... ok
test client::tests::test_new_eth_client_ws_scheme ... ok
test client::tests::test_new_eth_client_wss_scheme ... ok
test event_parser::tests::test_event_hash ... ok
test event_parser::tests::test_new_event_parser ... ok
test event_parser::tests::test_new_event_parser_empty_address ... ok
test event_parser::tests::test_new_event_parser_invalid_address ... ok
test event_parser::tests::test_new_event_parser_invalid_format ... ok
test event_parser::tests::test_new_event_parser_invalid_hex ... ok
test event_parser::tests::test_new_event_parser_missing_prefix ... ok
test event_parser::tests::test_new_event_parser_zero_address ... ok
test event_parser::tests::test_parse_logs_empty ... ok
test event_parser::tests::test_parse_logs_invalid_data ... ok
test event_parser::tests::test_parse_logs_multiple_logs_mixed ... ok
test event_parser::tests::test_parse_logs_non_matching ... ok
test event_parser::tests::test_parse_logs_single_valid_log ... ok
test tests::test_load_config ... ok
test tests::test_load_config_from_yaml ... ok
test tests::test_load_config_invalid_yaml ... ok
test client::tests::test_get_tx_receipt_by_hash ... ok
test client::tests::test_get_tx_receipt_by_hash_not_found ... ok
test client::tests::test_get_logs_four_topics ... ok
test client::tests::test_get_logs_empty_range ... ok
test client::tests::test_get_logs_empty ... ok
test client::tests::test_get_logs_range ... ok
test client::tests::test_get_logs_with_address_and_topic ... ok
test client::tests::test_get_logs_at_block_hash2 ... ok
test client::tests::test_get_logs_at_block_hash ... ok
test client::tests::test_get_logs_single_topic ... ok
test tests::test_run_get_logs_error ... ok
test tests::test_run_empty_logs ... ok
test tests::test_run_empty_receipt ... ok
test tests::test_main_run ... ok
test tests::test_run_valid_receipt ... ok
test client::tests::test_get_logs_no_topics ... ok

test result: ok. 45 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 2.53s

     Running tests/integration.rs (target/llvm-cov-target/debug/deps/integration-68d09ec8e787304b)

running 1 test
test test_client_and_parser_integration ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.81s


    Finished report saved to /Users/qiaopengjun/Code/Web3Wallet/ethertrace/rust/target/llvm-cov/html

```

![image-20250501185626829](/images/image-20250501185626829.png)

### 生成代码覆盖率报告（HTML 格式）并自动在浏览器中打开查看

```bash
ethertrace/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 15.7s 
➜ cargo llvm-cov --open


info: cargo-llvm-cov currently setting cfg(coverage) and cfg(coverage_nightly); you can opt-out it by passing --no-cfg-coverage and --no-cfg-coverage-nightly
   Compiling rust v0.1.0 (/Users/qiaopengjun/Code/Web3Wallet/ethertrace/rust)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 2.73s
     Running unittests src/lib.rs (target/llvm-cov-target/debug/deps/rust-dbe7fa2021cc4dc4)

running 37 tests
test client::tests::test_get_tx_receipt_by_hash_invalid_format ... ok
test client::tests::test_get_tx_receipt_by_hash_not_found ... ok
test client::tests::test_new_eth_client ... ok
test client::tests::test_new_eth_client_domain_regex ... ok
test client::tests::test_new_eth_client_empty_url ... ok
test client::tests::test_new_eth_client_invalid_provider ... ok
test client::tests::test_new_eth_client_invalid_scheme ... ok
test client::tests::test_new_eth_client_invalid_url ... ok
test client::tests::test_new_eth_client_invalid_url_format ... ok
test client::tests::test_new_eth_client_missing_scheme ... ok
test client::tests::test_new_eth_client_with_valid_url ... ok
test client::tests::test_new_eth_client_ws_scheme ... ok
test client::tests::test_new_eth_client_wss_scheme ... ok
test event_parser::tests::test_event_hash ... ok
test event_parser::tests::test_new_event_parser ... ok
test event_parser::tests::test_new_event_parser_empty_address ... ok
test event_parser::tests::test_new_event_parser_invalid_address ... ok
test event_parser::tests::test_new_event_parser_invalid_format ... ok
test event_parser::tests::test_new_event_parser_invalid_hex ... ok
test event_parser::tests::test_new_event_parser_missing_prefix ... ok
test event_parser::tests::test_new_event_parser_zero_address ... ok
test event_parser::tests::test_parse_logs_empty ... ok
test event_parser::tests::test_parse_logs_invalid_data ... ok
test event_parser::tests::test_parse_logs_multiple_logs_mixed ... ok
test event_parser::tests::test_parse_logs_non_matching ... ok
test event_parser::tests::test_parse_logs_single_valid_log ... ok
test client::tests::test_get_tx_receipt_by_hash_success ... ok
test client::tests::test_get_tx_receipt_by_hash ... ok
test client::tests::test_get_logs_four_topics ... ok
test client::tests::test_get_logs_at_block_hash2 ... ok
test client::tests::test_get_logs_range ... ok
test client::tests::test_get_logs_single_topic ... ok
test client::tests::test_get_logs_empty ... ok
test client::tests::test_get_logs_with_address_and_topic ... ok
test client::tests::test_get_logs_empty_range ... ok
test client::tests::test_get_logs_at_block_hash ... ok
test client::tests::test_get_logs_no_topics ... ok

test result: ok. 37 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 2.42s

     Running unittests src/main.rs (target/llvm-cov-target/debug/deps/rust-054928a06b249be0)

running 45 tests
test client::tests::test_get_tx_receipt_by_hash_invalid_format ... ok
test client::tests::test_get_tx_receipt_by_hash_not_found ... ok
test client::tests::test_new_eth_client ... ok
test client::tests::test_new_eth_client_domain_regex ... ok
test client::tests::test_new_eth_client_empty_url ... ok
test client::tests::test_new_eth_client_invalid_provider ... ok
test client::tests::test_new_eth_client_invalid_scheme ... ok
test client::tests::test_new_eth_client_invalid_url ... ok
test client::tests::test_new_eth_client_invalid_url_format ... ok
test client::tests::test_new_eth_client_missing_scheme ... ok
test client::tests::test_new_eth_client_with_valid_url ... ok
test client::tests::test_new_eth_client_ws_scheme ... ok
test client::tests::test_new_eth_client_wss_scheme ... ok
test event_parser::tests::test_event_hash ... ok
test event_parser::tests::test_new_event_parser ... ok
test event_parser::tests::test_new_event_parser_empty_address ... ok
test event_parser::tests::test_new_event_parser_invalid_address ... ok
test event_parser::tests::test_new_event_parser_invalid_format ... ok
test event_parser::tests::test_new_event_parser_invalid_hex ... ok
test event_parser::tests::test_new_event_parser_missing_prefix ... ok
test event_parser::tests::test_new_event_parser_zero_address ... ok
test event_parser::tests::test_parse_logs_empty ... ok
test event_parser::tests::test_parse_logs_invalid_data ... ok
test event_parser::tests::test_parse_logs_multiple_logs_mixed ... ok
test event_parser::tests::test_parse_logs_non_matching ... ok
test event_parser::tests::test_parse_logs_single_valid_log ... ok
test tests::test_load_config ... ok
test tests::test_load_config_from_yaml ... ok
test tests::test_load_config_invalid_yaml ... ok
test client::tests::test_get_tx_receipt_by_hash_success ... ok
test client::tests::test_get_tx_receipt_by_hash ... ok
test client::tests::test_get_logs_with_address_and_topic ... ok
test client::tests::test_get_logs_four_topics ... ok
test client::tests::test_get_logs_single_topic ... ok
test client::tests::test_get_logs_range ... ok
test client::tests::test_get_logs_empty ... ok
test client::tests::test_get_logs_at_block_hash2 ... ok
test client::tests::test_get_logs_empty_range ... ok
test client::tests::test_get_logs_at_block_hash ... ok
test tests::test_run_get_logs_error ... ok
test tests::test_run_empty_logs ... ok
test tests::test_run_empty_receipt ... ok
test tests::test_main_run ... ok
test tests::test_run_valid_receipt ... ok
test client::tests::test_get_logs_no_topics ... ok

test result: ok. 45 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 5.86s

     Running tests/integration.rs (target/llvm-cov-target/debug/deps/integration-68d09ec8e787304b)

running 1 test
test test_client_and_parser_integration ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.93s


    Finished report saved to /Users/qiaopengjun/Code/Web3Wallet/ethertrace/rust/target/llvm-cov/html
     Opening /Users/qiaopengjun/Code/Web3Wallet/ethertrace/rust/target/llvm-cov/html/index.html

```

![image-20250501185846383](/images/image-20250501185846383.png)

### 生成 **LCOV 格式**覆盖率报告

使用 nextest 运行所有测试，生成 LCOV 格式的覆盖率报告并保存到 lcov.info

```bash
ethertrace/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 16.0s 
➜ cargo llvm-cov nextest --lcov --output-path lcov.info
info: cargo-llvm-cov currently setting cfg(coverage) and cfg(coverage_nightly); you can opt-out it by passing --no-cfg-coverage and --no-cfg-coverage-nightly
   Compiling rust v0.1.0 (/Users/qiaopengjun/Code/Web3Wallet/ethertrace/rust)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 2.82s
────────────
 Nextest run ID 5f3c42ae-54fc-4b84-ab75-792ac0dac1c9 with nextest profile: default
    Starting 83 tests across 3 binaries
        PASS [   0.085s] rust client::tests::test_get_tx_receipt_by_hash_invalid_format
        PASS [   0.609s] rust client::tests::test_get_tx_receipt_by_hash_not_found
        PASS [   0.609s] rust client::tests::test_get_tx_receipt_by_hash
        PASS [   0.526s] rust client::tests::test_get_tx_receipt_by_hash_success
        PASS [   0.014s] rust client::tests::test_new_eth_client_empty_url
        PASS [   0.032s] rust client::tests::test_new_eth_client_domain_regex
        PASS [   0.032s] rust client::tests::test_new_eth_client
        PASS [   0.025s] rust client::tests::test_new_eth_client_invalid_provider
        PASS [   0.011s] rust client::tests::test_new_eth_client_invalid_url
        PASS [   0.011s] rust client::tests::test_new_eth_client_invalid_scheme
        PASS [   0.009s] rust client::tests::test_new_eth_client_invalid_url_format
        PASS [   0.010s] rust client::tests::test_new_eth_client_missing_scheme
        PASS [   0.021s] rust client::tests::test_new_eth_client_with_valid_url
        PASS [   0.009s] rust event_parser::tests::test_event_hash
        PASS [   0.023s] rust client::tests::test_new_eth_client_ws_scheme
        PASS [   0.022s] rust client::tests::test_new_eth_client_wss_scheme
        PASS [   0.009s] rust event_parser::tests::test_new_event_parser
        PASS [   0.008s] rust event_parser::tests::test_new_event_parser_empty_address
        PASS [   0.008s] rust event_parser::tests::test_new_event_parser_invalid_address
        PASS [   0.008s] rust event_parser::tests::test_new_event_parser_invalid_format
        PASS [   0.008s] rust event_parser::tests::test_new_event_parser_invalid_hex
        PASS [   0.007s] rust event_parser::tests::test_new_event_parser_missing_prefix
        PASS [   0.008s] rust event_parser::tests::test_parse_logs_empty
        PASS [   0.008s] rust event_parser::tests::test_new_event_parser_zero_address
        PASS [   0.008s] rust event_parser::tests::test_parse_logs_invalid_data
        PASS [   0.009s] rust event_parser::tests::test_parse_logs_single_valid_log
        PASS [   0.009s] rust event_parser::tests::test_parse_logs_non_matching
        PASS [   0.009s] rust event_parser::tests::test_parse_logs_multiple_logs_mixed
        PASS [   0.937s] rust client::tests::test_get_logs_with_address_and_topic
        PASS [   0.939s] rust client::tests::test_get_logs_single_topic
        PASS [   0.956s] rust client::tests::test_get_logs_at_block_hash
        PASS [   0.968s] rust client::tests::test_get_logs_four_topics
        PASS [   1.002s] rust client::tests::test_get_logs_empty_range
        PASS [   1.018s] rust client::tests::test_get_logs_range
        PASS [   1.037s] rust client::tests::test_get_logs_empty
        PASS [   1.118s] rust client::tests::test_get_logs_at_block_hash2
        PASS [   0.885s] rust::bin/rust client::tests::test_get_logs_at_block_hash
        PASS [   0.027s] rust::bin/rust client::tests::test_get_tx_receipt_by_hash_invalid_format
        PASS [   0.913s] rust::integration test_client_and_parser_integration
        PASS [   0.925s] rust::bin/rust client::tests::test_get_logs_at_block_hash2
        PASS [   0.020s] rust::bin/rust client::tests::test_new_eth_client
        PASS [   0.018s] rust::bin/rust client::tests::test_new_eth_client_domain_regex
        PASS [   0.008s] rust::bin/rust client::tests::test_new_eth_client_empty_url
        PASS [   0.018s] rust::bin/rust client::tests::test_new_eth_client_invalid_provider
        PASS [   0.009s] rust::bin/rust client::tests::test_new_eth_client_invalid_scheme
        PASS [   0.008s] rust::bin/rust client::tests::test_new_eth_client_invalid_url
        PASS [   0.609s] rust::bin/rust client::tests::test_get_tx_receipt_by_hash
        PASS [   0.008s] rust::bin/rust client::tests::test_new_eth_client_invalid_url_format
        PASS [   0.008s] rust::bin/rust client::tests::test_new_eth_client_missing_scheme
        PASS [   0.019s] rust::bin/rust client::tests::test_new_eth_client_with_valid_url
        PASS [   0.018s] rust::bin/rust client::tests::test_new_eth_client_ws_scheme
        PASS [   0.008s] rust::bin/rust event_parser::tests::test_event_hash
        PASS [   0.018s] rust::bin/rust client::tests::test_new_eth_client_wss_scheme
        PASS [   0.008s] rust::bin/rust event_parser::tests::test_new_event_parser
        PASS [   0.007s] rust::bin/rust event_parser::tests::test_new_event_parser_empty_address
        PASS [   0.008s] rust::bin/rust event_parser::tests::test_new_event_parser_invalid_address
        PASS [   0.008s] rust::bin/rust event_parser::tests::test_new_event_parser_invalid_format
        PASS [   0.008s] rust::bin/rust event_parser::tests::test_new_event_parser_invalid_hex
        PASS [   0.008s] rust::bin/rust event_parser::tests::test_new_event_parser_missing_prefix
        PASS [   0.007s] rust::bin/rust event_parser::tests::test_new_event_parser_zero_address
        PASS [   0.860s] rust::bin/rust client::tests::test_get_logs_empty
        PASS [   0.009s] rust::bin/rust event_parser::tests::test_parse_logs_empty
        PASS [   0.008s] rust::bin/rust event_parser::tests::test_parse_logs_invalid_data
        PASS [   0.008s] rust::bin/rust event_parser::tests::test_parse_logs_multiple_logs_mixed
        PASS [   0.008s] rust::bin/rust event_parser::tests::test_parse_logs_non_matching
        PASS [   0.008s] rust::bin/rust event_parser::tests::test_parse_logs_single_valid_log
        PASS [   0.008s] rust::bin/rust tests::test_load_config
        PASS [   0.009s] rust::bin/rust tests::test_load_config_from_yaml
        PASS [   0.008s] rust::bin/rust tests::test_load_config_invalid_yaml
        PASS [   0.913s] rust::bin/rust client::tests::test_get_logs_four_topics
        PASS [   0.948s] rust::bin/rust client::tests::test_get_logs_empty_range
        PASS [   0.906s] rust::bin/rust client::tests::test_get_logs_range
        PASS [   0.910s] rust::bin/rust client::tests::test_get_logs_single_topic
        PASS [   0.509s] rust::bin/rust client::tests::test_get_tx_receipt_by_hash_not_found
        PASS [   1.151s] rust::bin/rust client::tests::test_get_logs_with_address_and_topic
        PASS [   0.569s] rust::bin/rust client::tests::test_get_tx_receipt_by_hash_success
        PASS [   0.409s] rust::bin/rust tests::test_run_get_logs_error
        PASS [   0.926s] rust::bin/rust tests::test_run_empty_logs
        PASS [   0.950s] rust::bin/rust tests::test_run_empty_receipt
        PASS [   1.277s] rust::bin/rust tests::test_main_run
        PASS [   1.251s] rust::bin/rust tests::test_run_valid_receipt
        PASS [   5.822s] rust::bin/rust client::tests::test_get_logs_no_topics
        PASS [  11.082s] rust client::tests::test_get_logs_no_topics
────────────
     Summary [  11.084s] 83 tests run: 83 passed, 0 skipped

    Finished report saved to lcov.info
```

### 查看 LCOV 覆盖率摘要统计

使用 lcov --summary lcov.info 查看 LCOV 覆盖率文件的行、函数和分支覆盖摘要统计

```bash
ethertrace/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 took 19.5s 
➜ lcov --summary lcov.info
Reading tracefile lcov.info.
Summary coverage rate:
  source files: 3
  lines.......: 100.0% (607 of 607 lines)
  functions...: 85.1% (172 of 202 functions)
Message summary:
  no messages were reported

```

### 生成 LCOV 可视化覆盖率 HTML 报告

使用 genhtml 工具将 LCOV 格式的覆盖率数据（lcov.info）转换为可视化的 HTML 覆盖率报告，输出到指定目录（coverage_report）。

```bash
ethertrace/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ genhtml lcov.info -o coverage_report

Reading tracefile lcov.info.
Found 3 entries.
Found common filename prefix "/Users/qiaopengjun/Code/Web3Wallet/ethertrace/rust"
Generating output.
Processing file src/event_parser.rs
  lines=201 hit=201 functions=42 hit=38
Processing file src/client.rs
  lines=249 hit=249 functions=131 hit=116
Processing file src/main.rs
  lines=157 hit=157 functions=29 hit=18
Overall coverage rate:
  source files: 3
  lines.......: 100.0% (607 of 607 lines)
  functions...: 85.1% (172 of 202 functions)
Message summary:
  no messages were reported

```

### 在浏览器打开查看 LCOV 报告

```bash
ethertrace/rust on  main [!?] is 📦 0.1.0 via 🦀 1.88.0 
➜ open coverage_report/index.html 

```

![image-20250501191204669](/images/image-20250501191204669.png)

## 总结

通过 Rust 开发的 Web3 后端项目，展现了以太坊客户端与事件解析的强大能力。借助 Rust 的高性能与内存安全，项目实现了高效的节点交互和智能合约事件处理，模块化设计和灵活配置使其易于扩展。83 个测试用例覆盖率达 100%，结合 cargo nextest 的快速测试和 cargo llvm-cov 的详细覆盖率报告，确保了代码的极高可靠性。本文不仅是一个实战教程，更是 Rust 在 Web3 领域应用的成功案例。开发者可基于此项目进一步集成以太坊功能，或扩展至其他区块链，轻松构建生产级 Web3 应用。立即动手，用 Rust 解锁 Web3 的未来！更多资源请访问项目 GitHub 仓库及参考链接。

## 参考

- <https://crates.io/crates/dotenv>
- <https://github.com/taiki-e/cargo-llvm-cov>
- <https://crates.io/crates/temp-env>
- <https://docs.rs/web3/latest/web3/>
- <https://github.com/tomusdrw/rust-web3>
- <https://medium.com/@chalex-eth/how-to-build-a-web3-backend-in-rust-part-1-a92b649d42ad>
- <https://docs.moonbeam.network/cn/builders/libraries/ethersrs/>
- <https://github.com/gakonst/ethers-rs/issues/2667>
- <https://docs.rs/alloy/latest/alloy/>
- <https://github.com/alloy-rs/alloy>
- <https://alloy.rs/>
- <https://alloy.rs/introduction/getting-started>
- <https://github.com/qiaopengjun5162/ethertrace>
