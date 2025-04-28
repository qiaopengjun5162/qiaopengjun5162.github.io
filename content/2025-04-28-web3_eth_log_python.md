+++
title = "用 Python 解锁 Web3：以太坊日志解析实战"
description = "用 Python 解锁 Web3：以太坊日志解析实战"
date = 2025-04-28T14:16:29Z
[taxonomies]
categories = ["Web3", "Python", "以太坊", "Ethereum"]
tags = ["Web3", "Python", "以太坊", "Ethereum", "日志解析"]
+++

<!-- more -->

# 用 Python 解锁 Web3：以太坊日志解析实战

想用 Python 挖掘以太坊区块链的隐藏数据？Web3 开发正成为技术前沿的热点，而日志解析是解锁链上数据的关键！本文通过开源项目 EtherTrace，带你实战构建一个高效的以太坊日志解析器。基于 Python 和 Web3.py，我们将从连接以太坊节点到解析智能合约事件，一步步展示完整开发流程。项目不仅代码清晰、测试覆盖100%，还提供可复用的模板，助你在 Web3 开发中脱颖而出。无论你是区块链开发者还是 Python 爱好者，这场实战之旅都将让你大开眼界！

本文通过 EtherTrace 项目，深入展示如何用 Python 和 Web3.py 构建以太坊区块链日志解析器。项目涵盖核心模块（如 client.py、event_parser.py、main.py），实现从节点连接、交易收据获取到智能合约事件解析的全流程。通过 pytest 实现100% 测试覆盖，确保代码健壮性。本文详细解析项目结构、代码实现、测试用例及运行结果，并提供配置细节（如 pyproject.toml）。无论你想快速上手 Web3 开发还是优化区块链数据处理，这篇实战指南都为你提供清晰路径和可复用代码。

## 实操

### 查看项目目录结构

```bash
python on  main [?] via 🐍 3.13.3 via python 
➜ tree . -L 6 -I "__pycache__|python.egg-info|htmlcov|ethertrace.egg-info"
.
├── README.md
├── ethertrace
│   ├── __init__.py
│   ├── client.py
│   └── event_parser.py
├── main.py
├── pyproject.toml
├── tests
│   ├── test_client.py
│   ├── test_event_parser.py
│   └── test_main.py
└── uv.lock

3 directories, 10 files

```

### 代码实现

#### `client.py` 文件

```python
from web3 import Web3
import logging

logger = logging.getLogger(__name__)

import yaml

def load_config(config_path: str) -> dict:
    with open(config_path, "r") as f:
        return yaml.safe_load(f)

class EthClient:
    def __init__(self, rpc_url: str):
        """初始化以太坊客户端"""
        try:
            self.w3 = Web3(Web3.HTTPProvider(rpc_url))
            if not self.w3.is_connected():
                raise ConnectionError("Failed to connect to Ethereum node")
        except Exception as e:
            logger.error(f"Failed to connect to Ethereum node at {rpc_url}: {e}")
            raise

    def get_tx_receipt(self, tx_hash: str):
        """获取交易收据"""
        try:
            receipt = self.w3.eth.get_transaction_receipt(tx_hash)
            return receipt
        except Exception as e:
            logger.error(f"Failed to get transaction receipt for {tx_hash}: {e}")
            raise

    def get_logs(self, start_block: int, end_block: int, addresses: list):
        """获取指定区块范围内的日志"""
        try:
            filter_params = {
                "fromBlock": start_block,
                "toBlock": end_block,
                "address": addresses
            }
            logs = self.w3.eth.get_logs(filter_params)
            return logs
        except Exception as e:
            logger.error(f"Failed to get logs from {start_block} to {end_block}: {e}")
            raise
```

#### `event_parser.py` 文件

```python
from web3 import Web3
from eth_abi import decode
import logging

logger = logging.getLogger(__name__)

class EventParser:
    def __init__(self, contract_address: str):
        """初始化 ConfirmDataStore 事件解析器"""
        self.contract_address = Web3.to_checksum_address(contract_address)
        self.event_signature = Web3.keccak(text="ConfirmDataStore(uint32,bytes32)").hex()
        self.abi_types = ["uint32", "bytes32"]
        self.abi_names = ["dataStoreId", "headerHash"]

    def parse_logs(self, logs: list) -> list:
        """解析日志并提取 ConfirmDataStore 事件数据"""
        results = []
        for log in logs:
            # 过滤合约地址和事件签名
            if log["address"].lower() != self.contract_address.lower():
                continue
            if not log.get("topics") or log["topics"][0].hex() != self.event_signature:
                continue

            # 解码日志数据
            try:
                decoded_data = decode(self.abi_types, log["data"])
                result = dict(zip(self.abi_names, decoded_data))
                results.append({
                    "dataStoreId": result["dataStoreId"],
                    "headerHash": Web3.to_hex(result["headerHash"])
                })
            except Exception as e:
                logger.error(f"Failed to unpack log data: {e}")
                continue

        return results
```

#### `main.py` 文件

```python
import logging
from ethertrace.client import EthClient
from ethertrace.event_parser import EventParser

# 配置日志
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# 常量
RPC_URL = "https://rpc.mevblocker.io"
CONTRACT_ADDRESS = "0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1"
TX_HASH_EXAMPLE = "0xfd26d40e17213bcafcf94bab9af92343302df9df970f20e1c9d515525e86e23e"
START_BLOCK = 20483831
END_BLOCK = 20483833

def main():
    # 初始化客户端
    try:
        client = EthClient(RPC_URL)
    except Exception as e:
        logging.error(f"Failed to initialize client: {e}")
        return

    # 初始化事件解析器
    parser = EventParser(CONTRACT_ADDRESS)

    # 示例 1: 获取交易收据并解析日志
    try:
        receipt = client.get_tx_receipt(TX_HASH_EXAMPLE)
        tx_results = parser.parse_logs(receipt["logs"])
        for result in tx_results:
            logging.info(f"Tx Receipt - DataStoreID: {result['dataStoreId']}, HeaderHash: {result['headerHash']}")
    except Exception as e:
        logging.error(f"Failed to process tx receipt: {e}")

    # 示例 2: 获取区块范围内的日志并解析
    try:
        logs = client.get_logs(START_BLOCK, END_BLOCK, [CONTRACT_ADDRESS])
        log_results = parser.parse_logs(logs)
        for result in log_results:
            logging.info(f"Logs - DataStoreID: {result['dataStoreId']}, HeaderHash: {result['headerHash']}")
    except Exception as e:
        logging.error(f"Failed to process logs: {e}")

if __name__ == "__main__":
    main()
```

#### `pyproject.toml` 文件

```ts
[project]
name = "ethertrace"
version = "0.1.0"
description = "Add your description here"
readme = "README.md"
requires-python = ">=3.13"
dependencies = [
    "ruff>=0.11.7",
    "web3>=7.10.0",
]

[dependency-groups]
dev = [
    "pytest>=8.3.5",
    "pytest-cov>=6.1.1",
    "web3>=7.10.0",
]

[tool.pytest.ini_options]
addopts = "--cov=. --cov-report=term-missing --cov-report=html"
testpaths = ["tests"]                                     # 指定测试目录
python_files = "test_*.py"
pythonpath = "."
filterwarnings = [
    "ignore::DeprecationWarning:websockets[.*]:",
]

[tool.coverage.run]
omit = ["main.py"] # 忽略无需覆盖的文件
```

### 执行 `main` 文件

```bash
python on  main [?] via uv 3.13.3 
➜ source .venv/bin/activate                 

python on  main [?] via 🐍 3.13.3 via python 
➜ python main.py           
2025-04-28 18:54:12,556 - INFO - Tx Receipt - DataStoreID: 35258, HeaderHash: 0x27bc30064cc44c6aef26ca2d7e4ee667592949a50f4f01d8d4632461a12f2243
2025-04-28 18:54:12,861 - INFO - Logs - DataStoreID: 35210, HeaderHash: 0xf74adced62e27720c919bdbfa557b7b0b4d154e3faeb3649c6f4f2deed3456db

```

### 测试代码

#### `test_client.py` 文件

```python
import pytest
from unittest.mock import Mock, patch
from web3 import Web3
from ethertrace.client import EthClient, load_config
from web3.exceptions import Web3Exception

RPC_URL = "https://rpc.mevblocker.io"
INVALID_RPC_URL = "https://invalid-rpc-url"
TX_HASH = "0xfd26d40e17213bcafcf94bab9af92343302df9df970f20e1c9d515525e86e23e"
INVALID_TX_HASH = "0x" + "0" * 64
CONTRACT_ADDRESS = "0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1"
START_BLOCK = 20483831
END_BLOCK = 20483833

@pytest.fixture
def client():
    return EthClient(RPC_URL)

def test_client_initialization_success():
    client = EthClient(RPC_URL)
    assert client.w3.is_connected()

def test_client_initialization_failure():
    with pytest.raises(ConnectionError):
        EthClient(INVALID_RPC_URL)


def test_get_tx_receipt_success(client):
    receipt = client.get_tx_receipt(TX_HASH)
    assert receipt is not None
    assert "logs" in receipt
    assert receipt["transactionHash"].hex() == TX_HASH.lstrip("0x")  # 规范化比较

def test_get_tx_receipt_invalid_hash(client):
    with pytest.raises(Web3Exception):
        client.get_tx_receipt(INVALID_TX_HASH)  # 覆盖行 18-21

@patch("web3.eth.Eth.get_logs")
def test_get_logs_success(mock_get_logs, client):
    mock_log = {
        "address": CONTRACT_ADDRESS,
        "topics": [Web3.keccak(text="ConfirmDataStore(uint32,bytes32)")],
        "data": "0x000000000000000000000000000000000000000000000000000000000000007b" +
                "0000000000000000000000000000000000000000000000000000000000000123"
    }
    mock_get_logs.return_value = [mock_log]
    logs = client.get_logs(START_BLOCK, END_BLOCK, [CONTRACT_ADDRESS])
    print(logs, type(logs))
    assert isinstance(logs, list)
    assert len(logs) == 1
    assert logs[0]["address"] == CONTRACT_ADDRESS

def test_get_logs_invalid_block_range(client):
    with pytest.raises(Web3Exception):
        client.get_logs(END_BLOCK, START_BLOCK, [CONTRACT_ADDRESS])


@patch("yaml.safe_load")
def test_load_config(mock_yaml):
    mock_yaml.return_value = {"rpc_url": "https://rpc.mevblocker.io"}
    with patch("builtins.open", create=True) as mock_open:
        mock_open.return_value.__enter__.return_value = Mock()
        config = load_config("config.yaml")
        assert config == {"rpc_url": "https://rpc.mevblocker.io"}

@patch("yaml.safe_load")
def test_load_config_file_not_found(mock_yaml):
    with patch("builtins.open", side_effect=FileNotFoundError):
        with pytest.raises(FileNotFoundError):
            load_config("config.yaml")


```

#### `test_event_parser.py` 文件

```python
import pytest
from web3 import Web3
from ethertrace.event_parser import EventParser

CONTRACT_ADDRESS = "0x5BD63a7ECc13b955C4F57e3F12A64c10263C14c1"
WRONG_ADDRESS = "0x0000000000000000000000000000000000000000"

@pytest.fixture
def parser():
    """提供 EventParser 实例"""
    return EventParser(CONTRACT_ADDRESS)

def test_parse_logs(parser):
    """测试解析有效日志"""
    log = {
        "address": Web3.to_checksum_address(CONTRACT_ADDRESS),
        "topics": [Web3.keccak(text="ConfirmDataStore(uint32,bytes32)")],
        "data": Web3.to_bytes(hexstr=(
            "0x" +
            "000000000000000000000000000000000000000000000000000000000000007b" +  # uint32: 123
            "0000000000000000000000000000000000000000000000000000000000000123"   # bytes32
        ))
    }
    results = parser.parse_logs([log])
    assert len(results) > 0, f"Expected parsed results, got {results}"
    assert results[0]["dataStoreId"] == 123
    assert results[0]["headerHash"] == "0x0000000000000000000000000000000000000000000000000000000000000123"

def test_parse_logs_wrong_address(parser):
    """测试错误合约地址"""
    log = {
        "address": WRONG_ADDRESS,
        "topics": [Web3.keccak(text="ConfirmDataStore(uint32,bytes32)")],
        "data": Web3.to_bytes(hexstr="0x" + "0" * 128)
    }
    results = parser.parse_logs([log])
    assert len(results) == 0

def test_parse_logs_wrong_topic(parser):
    """测试错误主题"""
    log = {
        "address": Web3.to_checksum_address(CONTRACT_ADDRESS),
        "topics": [Web3.keccak(text="InvalidEvent()")],
        "data": Web3.to_bytes(hexstr="0x" + "0" * 128)
    }
    results = parser.parse_logs([log])
    assert len(results) == 0


def test_parse_logs_invalid_data(parser):
    """测试无效数据"""
    log = {
        "address": Web3.to_checksum_address(CONTRACT_ADDRESS),
        "topics": [Web3.keccak(text="ConfirmDataStore(uint32,bytes32)")],
        "data": Web3.to_bytes(hexstr="0x1234")  # 无效长度
    }
    results = parser.parse_logs([log])
    assert len(results) == 0
```

#### `test_main.py` 文件

```bash
from unittest.mock import Mock, patch
from main import main

@patch("ethertrace.client.EthClient")
@patch("ethertrace.event_parser.EventParser")
def test_main(mock_parser, mock_client):
    mock_client.return_value.get_tx_receipt.return_value = {"logs": []}
    mock_client.return_value.get_logs.return_value = []
    mock_parser.return_value.parse_logs.return_value = []
    main()  # 确保无异常

@patch("ethertrace.client.EthClient")
@patch("ethertrace.event_parser.EventParser")
def test_main_tx_receipt_failure(mock_parser, mock_client):
    mock_client.return_value.get_tx_receipt.side_effect = Exception("Transaction not found")
    mock_client.return_value.get_logs.return_value = []
    mock_parser.return_value.parse_logs.return_value = []
    main()

@patch("ethertrace.client.EthClient")
@patch("ethertrace.event_parser.EventParser")
def test_main_logs_failure(mock_parser, mock_client):
    mock_client.return_value.get_tx_receipt.return_value = {"logs": []}
    mock_client.return_value.get_logs.side_effect = Exception("Logs fetch failed")
    mock_parser.return_value.parse_logs.return_value = []
    main()


```

### 运行测试

```bash
python on  main [?] via 🐍 3.13.3 via python 
➜ pytest                             
=========================================================================================== test session starts ===========================================================================================
platform darwin -- Python 3.13.3, pytest-8.3.5, pluggy-1.5.0
rootdir: /Users/qiaopengjun/Code/Web3Wallet/ethertrace/python
configfile: pyproject.toml
testpaths: tests
plugins: cov-6.1.1
collected 15 items                                                                                                                                                                                        

tests/test_client.py ........                                                                                                                                                                       [ 53%]
tests/test_event_parser.py ....                                                                                                                                                                     [ 80%]
tests/test_main.py ...                                                                                                                                                                              [100%]

============================================================================================= tests coverage ==============================================================================================
____________________________________________________________________________ coverage: platform darwin, python 3.13.3-final-0 _____________________________________________________________________________

Name                         Stmts   Miss  Cover   Missing
----------------------------------------------------------
ethertrace/__init__.py           0      0   100%
ethertrace/client.py            31      0   100%
ethertrace/event_parser.py      25      0   100%
tests/test_client.py            53      0   100%
tests/test_event_parser.py      26      0   100%
tests/test_main.py              23      0   100%
----------------------------------------------------------
TOTAL                          158      0   100%
Coverage HTML written to dir htmlcov
=========================================================================================== 15 passed in 15.20s ===========================================================================================

```

### 查看测试覆盖率

```bash
python on  main [?] via 🐍 3.13.3 via python took 38.2s 
➜ pytest tests/test_main.py
=========================================================================================== test session starts ===========================================================================================
platform darwin -- Python 3.13.3, pytest-8.3.5, pluggy-1.5.0
rootdir: /Users/qiaopengjun/Code/Web3Wallet/ethertrace/python
configfile: pyproject.toml
plugins: cov-6.1.1
collected 3 items                                                                                                                                                                                         

tests/test_main.py ...                                                                                                                                                                              [100%]

============================================================================================= tests coverage ==============================================================================================
____________________________________________________________________________ coverage: platform darwin, python 3.13.3-final-0 _____________________________________________________________________________

Name                         Stmts   Miss  Cover   Missing
----------------------------------------------------------
ethertrace/__init__.py           0      0   100%
ethertrace/client.py            31     12    61%   9-10, 18-21, 28-30, 42-44
ethertrace/event_parser.py      25      4    84%   21, 33-35
tests/test_main.py              23      0   100%
----------------------------------------------------------
TOTAL                           79     16    80%
Coverage HTML written to dir htmlcov
============================================================================================ 3 passed in 5.38s ============================================================================================

python on  main [?] via 🐍 3.13.3 via python took 5.7s 
➜ pytest --cov=. --cov-report=term -v
=========================================================================================== test session starts ===========================================================================================
platform darwin -- Python 3.13.3, pytest-8.3.5, pluggy-1.5.0 -- /Users/qiaopengjun/Code/Web3Wallet/ethertrace/python/.venv/bin/python3
cachedir: .pytest_cache
rootdir: /Users/qiaopengjun/Code/Web3Wallet/ethertrace/python
configfile: pyproject.toml
testpaths: tests
plugins: cov-6.1.1
collected 15 items                                                                                                                                                                                        

tests/test_client.py::test_client_initialization_success PASSED                                                                                                                                     [  6%]
tests/test_client.py::test_client_initialization_failure PASSED                                                                                                                                     [ 13%]
tests/test_client.py::test_get_tx_receipt_success PASSED                                                                                                                                            [ 20%]
tests/test_client.py::test_get_tx_receipt_invalid_hash PASSED                                                                                                                                       [ 26%]
tests/test_client.py::test_get_logs_success PASSED                                                                                                                                                  [ 33%]
tests/test_client.py::test_get_logs_invalid_block_range PASSED                                                                                                                                      [ 40%]
tests/test_client.py::test_load_config PASSED                                                                                                                                                       [ 46%]
tests/test_client.py::test_load_config_file_not_found PASSED                                                                                                                                        [ 53%]
tests/test_event_parser.py::test_parse_logs PASSED                                                                                                                                                  [ 60%]
tests/test_event_parser.py::test_parse_logs_wrong_address PASSED                                                                                                                                    [ 66%]
tests/test_event_parser.py::test_parse_logs_wrong_topic PASSED                                                                                                                                      [ 73%]
tests/test_event_parser.py::test_parse_logs_invalid_data PASSED                                                                                                                                     [ 80%]
tests/test_main.py::test_main PASSED                                                                                                                                                                [ 86%]
tests/test_main.py::test_main_tx_receipt_failure PASSED                                                                                                                                             [ 93%]
tests/test_main.py::test_main_logs_failure PASSED                                                                                                                                                   [100%]

============================================================================================= tests coverage ==============================================================================================
____________________________________________________________________________ coverage: platform darwin, python 3.13.3-final-0 _____________________________________________________________________________

Name                         Stmts   Miss  Cover   Missing
----------------------------------------------------------
ethertrace/__init__.py           0      0   100%
ethertrace/client.py            31      0   100%
ethertrace/event_parser.py      25      0   100%
tests/test_client.py            53      0   100%
tests/test_event_parser.py      26      0   100%
tests/test_main.py              23      0   100%
----------------------------------------------------------
TOTAL                          158      0   100%
Coverage HTML written to dir htmlcov
=========================================================================================== 15 passed in 17.01s ===========================================================================================


```

### 生成详细覆盖率报告

```bash
python on  main [?] via 🐍 3.13.3 via python took 17.3s 
➜ pytest --cov=. --cov-report=html -v
=========================================================================================== test session starts ===========================================================================================
platform darwin -- Python 3.13.3, pytest-8.3.5, pluggy-1.5.0 -- /Users/qiaopengjun/Code/Web3Wallet/ethertrace/python/.venv/bin/python3
cachedir: .pytest_cache
rootdir: /Users/qiaopengjun/Code/Web3Wallet/ethertrace/python
configfile: pyproject.toml
testpaths: tests
plugins: cov-6.1.1
collected 15 items                                                                                                                                                                                        

tests/test_client.py::test_client_initialization_success PASSED                                                                                                                                     [  6%]
tests/test_client.py::test_client_initialization_failure PASSED                                                                                                                                     [ 13%]
tests/test_client.py::test_get_tx_receipt_success PASSED                                                                                                                                            [ 20%]
tests/test_client.py::test_get_tx_receipt_invalid_hash PASSED                                                                                                                                       [ 26%]
tests/test_client.py::test_get_logs_success PASSED                                                                                                                                                  [ 33%]
tests/test_client.py::test_get_logs_invalid_block_range PASSED                                                                                                                                      [ 40%]
tests/test_client.py::test_load_config PASSED                                                                                                                                                       [ 46%]
tests/test_client.py::test_load_config_file_not_found PASSED                                                                                                                                        [ 53%]
tests/test_event_parser.py::test_parse_logs PASSED                                                                                                                                                  [ 60%]
tests/test_event_parser.py::test_parse_logs_wrong_address PASSED                                                                                                                                    [ 66%]
tests/test_event_parser.py::test_parse_logs_wrong_topic PASSED                                                                                                                                      [ 73%]
tests/test_event_parser.py::test_parse_logs_invalid_data PASSED                                                                                                                                     [ 80%]
tests/test_main.py::test_main PASSED                                                                                                                                                                [ 86%]
tests/test_main.py::test_main_tx_receipt_failure PASSED                                                                                                                                             [ 93%]
tests/test_main.py::test_main_logs_failure PASSED                                                                                                                                                   [100%]

============================================================================================= tests coverage ==============================================================================================
____________________________________________________________________________ coverage: platform darwin, python 3.13.3-final-0 _____________________________________________________________________________

Name                         Stmts   Miss  Cover   Missing
----------------------------------------------------------
ethertrace/__init__.py           0      0   100%
ethertrace/client.py            31      0   100%
ethertrace/event_parser.py      25      0   100%
tests/test_client.py            53      0   100%
tests/test_event_parser.py      26      0   100%
tests/test_main.py              23      0   100%
----------------------------------------------------------
TOTAL                          158      0   100%
Coverage HTML written to dir htmlcov
=========================================================================================== 15 passed in 15.11s ===========================================================================================

python on  main [?] via 🐍 3.13.3 via python took 15.5s 
➜ open htmlcov/index.html

```

![image-20250426225341940](/images/image-20250426225341940.png)

确认测试覆盖率达到100%！

## 总结

EtherTrace 项目以 Python 和 Web3.py 为核心，展示了从以太坊节点交互到日志解析的完整开发流程。其模块化设计、100% 测试覆盖和详细文档，为 Web3 开发者提供了可靠的参考模板。通过本文，你不仅能掌握用 Python 解析以太坊链上数据的技术，还能学习到构建高质量区块链项目的实践经验。想深入 Web3 开发？立即访问 GitHub 仓库（<https://github.com/qiaopengjun5162/ethertrace），动手实践，解锁> Python 在区块链世界的无限可能！

## 参考

- <https://web3py.readthedocs.io/en/stable/>
- <https://docs.pydantic.dev/2.11/>
- <https://github.com/qiaopengjun5162/ethertrace>
- <https://web3py.readthedocs.io/en/stable/quickstart.html>
- <https://www.djangoproject.com/>
- <https://tornado-zh-cn.readthedocs.io/zh-cn/latest/>
- <https://github.com/ethereum/web3.py>
- <https://docs.moonbeam.network/cn/builders/libraries/web3py/>
- <https://www.quicknode.com/guides/ethereum-development/getting-started/connecting-to-blockchains/how-to-connect-to-the-ethereum-network-using-python-with-web3py>
