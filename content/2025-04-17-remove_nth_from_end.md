+++
title = "链表倒数 K 节点怎么删？Python/Go/Rust 实战"
description = "链表倒数 K 节点怎么删？Python/Go/Rust 实战"
date = 2025-04-17 20:00:37+08:00
[taxonomies]
categories = ["Python", "Go", "Rust", "算法"]
tags = ["Python", "Go", "Rust", "算法", "链表"]
+++

<!-- more -->

# 链表倒数 K 节点怎么删？Python/Go/Rust 实战

链表操作是算法学习和编程面试中的核心挑战，尤其是删除倒数第 K 个节点这一经典问题，常让开发者头疼。你是否在 LeetCode 上卡壳，或对如何高效实现感到困惑？本文通过 Python、Go、Rust 三种语言的实战代码，带你一步步破解链表倒数第 K 节点的删除难题！从双指针法的巧妙运用到全面的测试用例，我们不仅提供清晰的实现，还展示如何用覆盖率分析确保代码健壮性。无论你是算法新手还是多语言编程爱好者，这篇干货将让你快速上手，轻松应对链表挑战！

本文通过 Python、Go、Rust 三种语言，深入解析如何高效删除链表倒数第 K 个节点。采用双指针法结合虚拟头节点，代码简洁且处理了所有边界条件。文章提供完整的实现代码、测试用例（覆盖常规、边界及无效输入场景），并通过 pytest-cov（Python）、go test -cover（Go）、cargo-llvm-cov（Rust）生成 100% 覆盖率报告，确保代码质量。此外，介绍了 Python 的 uv 工具依赖管理，以及多语言测试的可视化报告生成方法。无论你是备战面试还是追求高质量代码，这篇实战指南都为你提供一站式解决方案。

## 删除链表的倒数第 K 个节点

### **问题描述**

给定一个单向链表，删除链表的倒数第 `K` 个节点，并返回头节点。

### **示例**

- 输入：`1 -> 2 -> 3 -> 4 -> 5`，`K = 2`
- 输出：`1 -> 2 -> 3 -> 5`（删除了倒数第 2 个节点 `4`）

### **解题思路（双指针法）**

1. **快指针先走 K 步**，让快慢指针之间保持 `K` 的间距。
2. **快慢指针同时移动**，直到快指针到达链表末尾。
3. **此时慢指针指向倒数第 K 个节点的前驱**，直接修改指针即可删除。

**关键点**：

- 使用**虚拟头节点（Dummy Node）**，避免处理头节点被删除的情况。
- 注意边界条件（如 `K > 链表长度` 时直接返回原链表）。

## Python 实操

### 代码

```python
# code-trio/packages/python/linked_list/list.py
class ListNode:
    def __init__(self, val=0, next=None):
        self.val = val
        self.next = next

def remove_nth_from_end(head: ListNode, k: int) -> ListNode:
    # 边界检查：空链表或 k <= 0 直接返回
    if not head or k <= 0:
        return head
    
    # 创建虚拟头节点，简化边界处理
    dummy = ListNode(0, head)
    fast = slow = dummy
    
    # fast 先走 k 步
    for _ in range(k):
        if not fast.next:  # 如果链表长度 < k，直接返回原链表
            return head
        fast = fast.next
    
    # fast 和 slow 同时移动，直到 fast 到达末尾
    while fast.next:
        fast = fast.next
        slow = slow.next
    
    # 删除 slow 指向的下一个节点
    slow.next = slow.next.next
    return dummy.next

# 辅助函数：创建链表
def create_linked_list(values):
    if not values:
        return None
    head = ListNode(values[0])
    current = head
    for val in values[1:]:
        current.next = ListNode(val)
        current = current.next
    return head

# 辅助函数：链表转列表
def linked_list_to_list(head):
    result = []
    while head:
        result.append(head.val)
        head = head.next
    return result

```

### 测试代码

```python
# code-trio/packages/python/linked_list/test_list.py
import pytest
from .list import ListNode, remove_nth_from_end, create_linked_list, linked_list_to_list

@pytest.fixture
def setup_linked_list():
    """创建测试用链表"""
    def _create(values):
        return create_linked_list(values)
    return _create

def test_remove_nth_from_end_standard(setup_linked_list):
    """测试常规情况：删除倒数第 k 个节点"""
    head = setup_linked_list([1, 2, 6, 3, 4, 6])
    result = remove_nth_from_end(head, 2)
    assert linked_list_to_list(result) == [1, 2, 6, 3, 6]

def test_remove_nth_from_end_single_node(setup_linked_list):
    """测试只有一个节点的链表"""
    head = setup_linked_list([1])
    result = remove_nth_from_end(head, 1)
    assert linked_list_to_list(result) == []

def test_remove_nth_from_end_head(setup_linked_list):
    """测试删除头节点（k 等于链表长度）"""
    head = setup_linked_list([1, 2, 3])
    result = remove_nth_from_end(head, 3)
    assert linked_list_to_list(result) == [2, 3]

def test_remove_nth_from_end_empty():
    """测试空链表"""
    head = None
    result = remove_nth_from_end(head, 1)
    assert linked_list_to_list(result) == []

def test_remove_nth_from_end_last_node(setup_linked_list):
    """测试删除最后一个节点"""
    head = setup_linked_list([1, 2, 3])
    result = remove_nth_from_end(head, 1)
    assert linked_list_to_list(result) == [1, 2]

def test_remove_nth_from_end_invalid_k(setup_linked_list):
    """测试 k 无效（k 比链表长）"""
    head = setup_linked_list([1, 2, 3])
    result = remove_nth_from_end(head, 5)  # k=5 比链表长度大
    # 验证返回的是原链表
    assert result.val == 1
    assert result.next.val == 2
    assert result.next.next.val == 3

def test_remove_nth_from_end():
    # 空链表
    assert remove_nth_from_end(None, 1) is None
    
    # 链表长度 < k
    head = ListNode(1)
    assert remove_nth_from_end(head, 2) == head
    
    # 正常情况
    head = ListNode(1, ListNode(2, ListNode(3)))
    result = remove_nth_from_end(head, 2)
    assert result.val == 1
    assert result.next.val == 3

def test_create_empty_linked_list():
    """测试创建空链表"""
    head = create_linked_list([])
    assert head is None  # 空输入应返回 None

# 测试 create_linked_list 的所有分支
def test_create_linked_list():
    # 空列表
    assert create_linked_list([]) is None
    
    # 单元素链表
    head = create_linked_list([1])
    assert head.val == 1
    assert head.next is None
    
    # 多元素链表
    head = create_linked_list([1, 2, 3])
    assert linked_list_to_list(head) == [1, 2, 3]

```

### **在 `uv` 包管理工具中，`uv pip install` 和 `uv add` 的核心区别总结**

|    **对比项**    | `uv pip install` |                   `uv add`                    |
| :--------------: | :--------------: | :-------------------------------------------: |
|   **安装目标**   |  当前激活的环境  |          当前环境 + 更新项目依赖文件          |
|   **依赖管理**   |  不修改依赖文件  | 自动更新 `pyproject.toml`/`requirements.txt`  |
|   **适用场景**   |   临时工具安装   |               项目开发依赖管理                |
| **配置文件要求** |   无需配置文件   | 需存在 `pyproject.toml` 或 `requirements.txt` |

### 测试

### 安装覆盖率工具

```bash
# 添加到开发依赖（写入 pyproject.toml）
uv add --dev pytest-cov

python on  master [?] via 🐍 3.13.3 via python took 3.3s 
➜ uv add --dev pytest-cov            
Resolved 8 packages in 2.01s
Audited 6 packages in 0.68ms
```

### **常用参数组合**

|                 命令                 |         作用         |
| :----------------------------------: | :------------------: |
|        `pytest --cov=模块名`         |     检查指定模块     |
|  `pytest --cov=. --cov-report=term`  |  在终端显示详细报告  |
|  `pytest --cov=. --cov-report=html`  |  生成HTML可视化报告  |
| `pytest --cov=. --cov-fail-under=90` | 如果覆盖率<90%则失败 |

### 运行测试

```bash
python on  master [?] via 🐍 3.13.3 via python 
➜ pytest linked_list/test_list.py                  
========================================================================= test session starts ==========================================================================
platform darwin -- Python 3.13.3, pytest-8.3.5, pluggy-1.5.0
rootdir: /Users/qiaopengjun/Code/rust/2025/code-trio/packages/python
configfile: pyproject.toml
collected 7 items                                                                                                                                                      

linked_list/test_list.py .......                                                                                                                                 [100%]

========================================================================== 7 passed in 0.01s ===========================================================================

```

### **基本覆盖率检查**

运行测试并查看覆盖率报告：

```
# 检查单个文件覆盖率
pytest --cov=linked_list linked_list/test_list.py

# 检查整个项目的覆盖率
pytest --cov=.
```

- 运行指定测试文件，并输出**简化的覆盖率摘要**。

```bash
python on  master [?] via 🐍 3.13.3 via python 
➜ pytest --cov=linked_list linked_list/test_list.py                          
========================================================================= test session starts ==========================================================================
platform darwin -- Python 3.13.3, pytest-8.3.5, pluggy-1.5.0
rootdir: /Users/qiaopengjun/Code/rust/2025/code-trio/packages/python
configfile: pyproject.toml
plugins: cov-6.1.1
collected 9 items                                                                                                                                                      

linked_list/test_list.py .........                                                                                                                               [100%]

============================================================================ tests coverage ============================================================================
___________________________________________________________ coverage: platform darwin, python 3.13.3-final-0 ___________________________________________________________

Name                       Stmts   Miss  Cover
----------------------------------------------
linked_list/__init__.py        0      0   100%
linked_list/list.py           33      0   100%
linked_list/test_list.py      51      0   100%
----------------------------------------------
TOTAL                         84      0   100%
========================================================================== 9 passed in 0.05s ===========================================================================


```

- 运行测试并生成**带缺失行号的详细覆盖率报告**。

```bash
python on  master [?] via 🐍 3.13.3 via python 
➜ pytest --cov=linked_list --cov-report=term-missing linked_list/test_list.py
========================================================================= test session starts ==========================================================================
platform darwin -- Python 3.13.3, pytest-8.3.5, pluggy-1.5.0
rootdir: /Users/qiaopengjun/Code/rust/2025/code-trio/packages/python
configfile: pyproject.toml
plugins: cov-6.1.1
collected 9 items                                                                                                                                                      

linked_list/test_list.py .........                                                                                                                               [100%]

============================================================================ tests coverage ============================================================================
___________________________________________________________ coverage: platform darwin, python 3.13.3-final-0 ___________________________________________________________

Name                       Stmts   Miss  Cover   Missing
--------------------------------------------------------
linked_list/__init__.py        0      0   100%
linked_list/list.py           33      0   100%
linked_list/test_list.py      51      0   100%
--------------------------------------------------------
TOTAL                         84      0   100%
========================================================================== 9 passed in 0.04s ===========================================================================

```

- 检查整个项目的覆盖率

```bash
python on  master [?] via 🐍 3.13.3 via python 
➜ pytest --cov=. --cov-report=term-missing            
========================================================================= test session starts ==========================================================================
platform darwin -- Python 3.13.3, pytest-8.3.5, pluggy-1.5.0
rootdir: /Users/qiaopengjun/Code/rust/2025/code-trio/packages/python
configfile: pyproject.toml
plugins: cov-6.1.1
collected 9 items                                                                                                                                                      

linked_list/test_list.py .........                                                                                                                               [100%]

============================================================================ tests coverage ============================================================================
___________________________________________________________ coverage: platform darwin, python 3.13.3-final-0 ___________________________________________________________

Name                       Stmts   Miss  Cover   Missing
--------------------------------------------------------
linked_list/list.py           33      0   100%
linked_list/test_list.py      51      0   100%
--------------------------------------------------------
TOTAL                         84      0   100%
Coverage HTML written to dir htmlcov
========================================================================== 9 passed in 0.06s ===========================================================================

```

### **HTML可视化报告**

```bash
python on  master [?] via 🐍 3.13.3 via python 
➜ pytest --cov=. --cov-report=html
========================================================================= test session starts ==========================================================================
platform darwin -- Python 3.13.3, pytest-8.3.5, pluggy-1.5.0
rootdir: /Users/qiaopengjun/Code/rust/2025/code-trio/packages/python
configfile: pyproject.toml
testpaths: linked_list
plugins: cov-6.1.1
collected 9 items                                                                                                                                                      

linked_list/test_list.py .........                                                                                                                               [100%]

============================================================================ tests coverage ============================================================================
___________________________________________________________ coverage: platform darwin, python 3.13.3-final-0 ___________________________________________________________

Name                       Stmts   Miss  Cover   Missing
--------------------------------------------------------
linked_list/list.py           33      0   100%
linked_list/test_list.py      51      0   100%
--------------------------------------------------------
TOTAL                         84      0   100%
Coverage HTML written to dir htmlcov
========================================================================== 9 pas
```

这会在当前目录生成 `htmlcov/` 文件夹，用浏览器打开 `index.html` 即可看到：

- **绿色**：已覆盖的代码
- **红色**：未覆盖的代码行

#### 浏览器查看报告

```bash
# 打开浏览器查看
open htmlcov/index.html

python on  master [?] via 🐍 3.13.3 via python 
➜ open htmlcov/index.html
```

#### Files

![image-20250416231826550](/images/image-20250416231826550.png)

#### Functions

![image-20250416231846382](/images/image-20250416231846382.png)

#### Classes

![image-20250416231905890](/images/image-20250416231905890.png)

## Go 实操

### list 代码

```go
// code-trio/packages/go/linked_list/list.go
package linked_list

type ListNode struct {
 Val  int
 Next *ListNode
}

func RemoveNthFromEnd(head *ListNode, k int) *ListNode {
 if head == nil || k <= 0 {
  return head
 }
 dummy := &ListNode{0, head}
 fast, slow := dummy, dummy

 // Fast pointer moves k steps
 for i := 0; i < k; i++ {
  if fast.Next == nil {
   return head
  }
  fast = fast.Next
 }

 // Move fast and slow together
 for fast.Next != nil {
  fast = fast.Next
  slow = slow.Next
 }

 // Remove the kth node from the end
 slow.Next = slow.Next.Next
 return dummy.Next
}

// Helper: Create a linked list from a slice
func CreateLinkedList(values []int) *ListNode {
 if len(values) == 0 {
  return nil
 }
 head := &ListNode{Val: values[0]}
 current := head
 for _, val := range values[1:] {
  current.Next = &ListNode{Val: val}
  current = current.Next
 }
 return head
}

// Helper: Convert linked list to slice
func LinkedListToSlice(head *ListNode) []int {
 result := []int{}
 for head != nil {
  result = append(result, head.Val)
  head = head.Next
 }
 return result
}

```

### 测试代码

```go
// code-trio/packages/go/linked_list/list_test.go
package linked_list

import (
 "reflect"
 "testing"
)

func TestRemoveNthFromEnd(t *testing.T) {
 tests := []struct {
  name     string
  values   []int
  k        int
  expected []int
 }{
  {
   name:     "Standard case: remove k=2 from [1,2,6,3,4,6]",
   values:   []int{1, 2, 6, 3, 4, 6},
   k:        2,
   expected: []int{1, 2, 6, 3, 6},
  },
  {
   name:     "Single node: remove k=1 from [1]",
   values:   []int{1},
   k:        1,
   expected: []int{},
  },
  {
   name:     "Remove head: remove k=3 from [1,2,3]",
   values:   []int{1, 2, 3},
   k:        3,
   expected: []int{2, 3},
  },
  {
   name:     "Empty list: remove k=1 from []",
   values:   []int{},
   k:        1,
   expected: []int{},
  },
  {
   name:     "Remove last node: remove k=1 from [1,2,3]",
   values:   []int{1, 2, 3},
   k:        1,
   expected: []int{1, 2},
  },
  {
   name:     "Invalid k: remove k=4 from [1,2,3]",
   values:   []int{1, 2, 3},
   k:        4,
   expected: []int{1, 2, 3},
  },
  {
   name:     "Invalid k: remove k=0 from [1,2,3]",
   values:   []int{1, 2, 3},
   k:        0,
   expected: []int{1, 2, 3},
  },
 }

 for _, tt := range tests {
  t.Run(tt.name, func(t *testing.T) {
   head := CreateLinkedList(tt.values)
   result := RemoveNthFromEnd(head, tt.k)
   got := LinkedListToSlice(result)
   if !reflect.DeepEqual(got, tt.expected) {
    t.Errorf("RemoveNthFromEnd(%v, %d) = %v; want %v", tt.values, tt.k, got, tt.expected)
   }
  })
 }
}

```

### **常用参数组合**

|                 命令                 |          作用          |
| :----------------------------------: | :--------------------: |
|           `go test -cover`           | 仅显示整体覆盖率百分比 |
| `go test -coverprofile=coverage.out` |   生成覆盖率数据文件   |
|  `go tool cover -html=coverage.out`  |   生成HTML可视化报告   |
|         `go test -cover -v`          |    显示详细测试过程    |

### 运行测试

```bash
packages/go/linked_list via ⬢ v22.1.0 via 🐹 v1.24.2 via 🅒 base 
➜ go test                                            
PASS
ok      github.com/qiaopengjun5162/code-trio/go/linked_list     0.007s

packages/go/linked_list via ⬢ v22.1.0 via 🐹 v1.24.2 via 🅒 base 
➜ go test -v             
=== RUN   TestRemoveNthFromEnd
=== RUN   TestRemoveNthFromEnd/Standard_case:_remove_k=2_from_[1,2,6,3,4,6]
=== RUN   TestRemoveNthFromEnd/Single_node:_remove_k=1_from_[1]
=== RUN   TestRemoveNthFromEnd/Remove_head:_remove_k=3_from_[1,2,3]
=== RUN   TestRemoveNthFromEnd/Empty_list:_remove_k=1_from_[]
=== RUN   TestRemoveNthFromEnd/Remove_last_node:_remove_k=1_from_[1,2,3]
=== RUN   TestRemoveNthFromEnd/Invalid_k:_remove_k=4_from_[1,2,3]
=== RUN   TestRemoveNthFromEnd/Invalid_k:_remove_k=0_from_[1,2,3]
--- PASS: TestRemoveNthFromEnd (0.00s)
    --- PASS: TestRemoveNthFromEnd/Standard_case:_remove_k=2_from_[1,2,6,3,4,6] (0.00s)
    --- PASS: TestRemoveNthFromEnd/Single_node:_remove_k=1_from_[1] (0.00s)
    --- PASS: TestRemoveNthFromEnd/Remove_head:_remove_k=3_from_[1,2,3] (0.00s)
    --- PASS: TestRemoveNthFromEnd/Empty_list:_remove_k=1_from_[] (0.00s)
    --- PASS: TestRemoveNthFromEnd/Remove_last_node:_remove_k=1_from_[1,2,3] (0.00s)
    --- PASS: TestRemoveNthFromEnd/Invalid_k:_remove_k=4_from_[1,2,3] (0.00s)
    --- PASS: TestRemoveNthFromEnd/Invalid_k:_remove_k=0_from_[1,2,3] (0.00s)
PASS
ok      github.com/qiaopengjun5162/code-trio/go/linked_list     0.011s

packages/go/linked_list via ⬢ v22.1.0 via 🐹 v1.24.2 via 🅒 base 
➜ cd ..         

code-trio/packages/go via ⬢ v22.1.0 via 🐹 v1.24.2 via 🅒 base 
➜ go test ./...
ok      github.com/qiaopengjun5162/code-trio/go/linked_list     0.012s
```

### 查看当前测试覆盖率

```bash
packages/go/linked_list via ⬢ v22.1.0 via 🐹 v1.24.2 via 🅒 base 
➜ go test -cover

PASS
coverage: 100.0% of statements
ok      github.com/qiaopengjun5162/code-trio/go/linked_list     0.011s
```

这个输出结果表示你的 Go 链表测试运行成功，并且达到了 100% 的代码覆盖率！

### 生成可视化报告

```bash
packages/go/linked_list via ⬢ v22.1.0 via 🐹 v1.24.2 via 🅒 base 
➜ # 1. 生成覆盖率数据文件
go test -coverprofile=coverage.out

# 2. 生成HTML报告（自动在浏览器打开）
go tool cover -html=coverage.out
PASS
coverage: 100.0% of statements
ok      github.com/qiaopengjun5162/code-trio/go/linked_list     0.011s

```

![image-20250416223649020](/images/image-20250416223649020.png)

浏览器报告会显示：

- **绿色**：已覆盖的代码
- **红色**：未覆盖的代码（需要补充测试用例）

## Rust 实操

### 项目目录结构

```bash
rust/linked_list on  master [?] is 📦 0.1.0 via 🦀 1.86.0 via 🅒 base 
➜ tree . -L 6 -I 'target|cache|lib|build|coverage_report'


.
├── Cargo.toml
├── lcov.info
├── src
│   ├── lib.rs
│   └── main.rs
└── tests
    └── integration.rs

3 directories, 5 files

```

### `lib.rs`代码

```rust
// 定义链表节点结构体
#[derive(PartialEq, Eq, Clone, Debug)]
pub struct ListNode {
    pub val: i32,
    pub next: Option<Box<ListNode>>,
}

impl ListNode {
    #[inline]
    fn new(val: i32) -> Self {
        ListNode { val, next: None }
    }
}

pub fn remove_nth_from_end(head: Option<Box<ListNode>>, k: i32) -> Option<Box<ListNode>> {
    if head.is_none() || k <= 0 {
        return head;
    }
    let mut dummy = Box::new(ListNode { val: 0, next: head });

    let mut fast = &mut dummy.clone();
    let mut slow = &mut dummy;

    for _ in 0..k {
        if fast.next.is_none() {
            return dummy.next;
        }
        fast = fast.next.as_mut().unwrap();
    }

    while fast.next.is_some() {
        fast = fast.next.as_mut().unwrap();
        slow = slow.next.as_mut().unwrap();
    }

    slow.next = slow.next.take().unwrap().next.clone();

    dummy.next
}

pub fn remove_nth_from_end_unsafe(head: Option<Box<ListNode>>, n: i32) -> Option<Box<ListNode>> {
    // 处理空链表或 n <= 0
    if head.is_none() || n <= 0 {
        return head;
    }
    let mut dummy = Box::new(ListNode { val: 0, next: head });

    unsafe {
        let mut slow = &mut dummy as *mut Box<ListNode>;
        let mut fast = &mut dummy as *mut Box<ListNode>;

        for _ in 0..n {
            if (*fast).next.is_none() {
                return dummy.next;
            }
            fast = (*fast).next.as_mut().unwrap();
        }

        while (*fast).next.is_some() {
            fast = (*fast).next.as_mut().unwrap();
            slow = (*slow).next.as_mut().unwrap();
        }

        (*slow).next = (*slow).next.take().unwrap().next;
    }

    dummy.next
}

pub fn vec_to_list(vec: Vec<i32>) -> Option<Box<ListNode>> {
    let mut dummy = Box::new(ListNode::new(0));
    let mut curr = &mut dummy;

    for &val in vec.iter() {
        curr.next = Some(Box::new(ListNode::new(val)));
        curr = curr.next.as_mut().unwrap();
    }

    dummy.next
}

pub fn list_to_vec(list: Option<Box<ListNode>>) -> Vec<i32> {
    let mut vec = Vec::new();
    let mut curr = list;

    while let Some(node) = curr {
        vec.push(node.val);
        curr = node.next;
    }

    vec
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_normal_case() {
        let input = vec_to_list(vec![1, 2, 3, 4, 5]);
        let result = remove_nth_from_end(input, 2);
        assert_eq!(list_to_vec(result), vec![1, 2, 3, 5]);
    }

    #[test]
    fn test_delete_head() {
        let input = vec_to_list(vec![1, 2, 3]);
        let result = remove_nth_from_end(input, 3);
        assert_eq!(list_to_vec(result), vec![2, 3]);
    }

    #[test]
    fn test_delete_tail() {
        let input = vec_to_list(vec![1, 2, 3]);
        let result = remove_nth_from_end(input, 1);
        assert_eq!(list_to_vec(result), vec![1, 2]);
    }

    #[test]
    fn test_single_node() {
        let input = vec_to_list(vec![1]);
        let result = remove_nth_from_end(input, 1);
        assert_eq!(list_to_vec(result), vec![]);
    }

    #[test]
    fn test_empty_list() {
        let input = vec_to_list(vec![]);
        let result = remove_nth_from_end(input, 1);
        assert_eq!(list_to_vec(result), vec![]);
    }

    #[test]
    fn test_k_greater_than_length() {
        let input = vec_to_list(vec![1, 2, 3]);
        let result = remove_nth_from_end(input, 4);
        assert_eq!(list_to_vec(result), vec![1, 2, 3]);
    }

    #[test]
    fn test_k_zero_or_negative() {
        let input = vec_to_list(vec![1, 2, 3]);
        let result = remove_nth_from_end(input, 0);
        assert_eq!(list_to_vec(result), vec![1, 2, 3]);

        let input = vec_to_list(vec![1, 2, 3]);
        let result = remove_nth_from_end(input, -1);
        assert_eq!(list_to_vec(result), vec![1, 2, 3]);
    }

    #[test]
    fn test_k_equals_length() {
        let input = vec_to_list(vec![1, 2, 3]);
        let result = remove_nth_from_end(input, 3);
        assert_eq!(list_to_vec(result), vec![2, 3]);
    }

    // 测试 remove_nth_from_end_unsafe
    #[test]
    fn test_unsafe_normal_case() {
        let input = vec_to_list(vec![1, 2, 3, 4, 5]);
        let result = remove_nth_from_end_unsafe(input, 2);
        assert_eq!(list_to_vec(result), vec![1, 2, 3, 5]);
    }

    #[test]
    fn test_unsafe_delete_head() {
        let input = vec_to_list(vec![1, 2, 3]);
        let result = remove_nth_from_end_unsafe(input, 3);
        assert_eq!(list_to_vec(result), vec![2, 3]);
    }

    #[test]
    fn test_unsafe_delete_tail() {
        let input = vec_to_list(vec![1, 2, 3]);
        let result = remove_nth_from_end_unsafe(input, 1);
        assert_eq!(list_to_vec(result), vec![1, 2]);
    }

    #[test]
    fn test_unsafe_single_node() {
        let input = vec_to_list(vec![1]);
        let result = remove_nth_from_end_unsafe(input, 1);
        assert_eq!(list_to_vec(result), vec![]);
    }

    #[test]
    fn test_unsafe_empty_list() {
        let input = vec_to_list(vec![]);
        let result = remove_nth_from_end_unsafe(input, 1);
        assert_eq!(list_to_vec(result), vec![]);
    }

    #[test]
    fn test_unsafe_k_greater_than_length() {
        let input = vec_to_list(vec![1, 2, 3]);
        let result = remove_nth_from_end_unsafe(input, 4);
        assert_eq!(list_to_vec(result), vec![1, 2, 3]);
    }

    #[test]
    fn test_unsafe_k_zero_or_negative() {
        let input = vec_to_list(vec![1, 2, 3]);
        let result = remove_nth_from_end_unsafe(input, 0);
        assert_eq!(list_to_vec(result), vec![1, 2, 3]);

        let input = vec_to_list(vec![1, 2, 3]);
        let result = remove_nth_from_end_unsafe(input, -1);
        assert_eq!(list_to_vec(result), vec![1, 2, 3]);
    }

    #[test]
    fn test_unsafe_k_much_larger_than_length() {
        let input = vec_to_list(vec![1, 2, 3]);
        let result = remove_nth_from_end_unsafe(input, 100);
        assert_eq!(list_to_vec(result), vec![1, 2, 3]);
    }

    #[test]
    fn test_unsafe_short_list_edge_case() {
        let input = vec_to_list(vec![1]);
        let result = remove_nth_from_end_unsafe(input, 2);
        assert_eq!(list_to_vec(result), vec![1]);
    }
}

```

### `main.rs` 代码

```rust
// src/main.rs
use linked_list::{list_to_vec, remove_nth_from_end, vec_to_list};

fn main() {
    let input = vec_to_list(vec![1, 2, 3, 4, 5]);
    let result = remove_nth_from_end(input, 2);
    println!("Output: {:?}", list_to_vec(result)); // 应打印 [1, 2, 3, 5]
}

```

### `integration.rs` 代码

```rust
// tests/integration.rs
use linked_list::{list_to_vec, remove_nth_from_end, vec_to_list};

#[test]
fn test_main_case() {
    let input = vec_to_list(vec![1, 2, 3, 4, 5]);
    let result = remove_nth_from_end(input, 2);
    assert_eq!(list_to_vec(result), vec![1, 2, 3, 5]);
}

```

### `Cargo.toml` 文件

```toml
[package]
name = "linked_list"
version = "0.1.0"
edition = "2024"

[lib]
name = "linked_list"
path = "src/lib.rs"

[dependencies]

```

### 测试

### 安装 `cargo-llvm-cov`

```bash
brew install cargo-llvm-cov
```

#### 确保已安装必要的依赖

```bash
brew install llvm
rustup component add llvm-tools-preview
```

### 运行测试

```bash
rust/linked_list on  master [?] is 📦 0.1.0 via 🦀 1.86.0 via 🅒 base 
➜ cargo nextest run --all
   Compiling linked_list v0.1.0 (/Users/qiaopengjun/Code/rust/2025/code-trio/packages/rust/linked_list)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.90s
    Starting 18 tests across 4 binaries (run ID: 88c1fe4c-fd85-41a5-a293-051802d868e9, nextest profile: default)
        PASS [   0.052s] linked_list tests::test_delete_tail
        PASS [   0.052s] linked_list tests::test_k_greater_than_length
        PASS [   0.055s] linked_list tests::test_delete_head
        PASS [   0.052s] linked_list tests::test_unsafe_delete_head
        PASS [   0.058s] linked_list tests::test_empty_list
        PASS [   0.053s] linked_list tests::test_unsafe_delete_tail
        PASS [   0.057s] linked_list tests::test_k_zero_or_negative
        PASS [   0.059s] linked_list tests::test_k_equals_length
        PASS [   0.055s] linked_list tests::test_unsafe_empty_list
        PASS [   0.057s] linked_list tests::test_normal_case
        PASS [   0.054s] linked_list tests::test_unsafe_k_greater_than_length
        PASS [   0.057s] linked_list tests::test_single_node
        PASS [   0.019s] linked_list tests::test_unsafe_k_much_larger_than_length
        PASS [   0.017s] linked_list tests::test_unsafe_normal_case
        PASS [   0.017s] linked_list tests::test_unsafe_short_list_edge_case
        PASS [   0.017s] linked_list::integration test_main_case
        PASS [   0.018s] linked_list tests::test_unsafe_single_node
        PASS [   0.024s] linked_list tests::test_unsafe_k_zero_or_negative
------------
     Summary [   0.079s] 18 tests run: 18 passed, 0 skipped
```

### 在 Rust 项目目录中生成覆盖率报告

进入你的 Rust 项目目录（包含 `Cargo.toml` 的目录），然后运行：

```bash
rust/linked_list on  master [?] is 📦 0.1.0 via 🦀 1.86.0 via 🅒 base 
➜ cargo llvm-cov --all-features --workspace --tests
info: cargo-llvm-cov currently setting cfg(coverage); you can opt-out it by passing --no-cfg-coverage
   Compiling linked_list v0.1.0 (/Users/qiaopengjun/Code/rust/2025/code-trio/packages/rust/linked_list)
   Compiling rust v0.1.0 (/Users/qiaopengjun/Code/rust/2025/code-trio/packages/rust)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.71s
     Running unittests src/lib.rs (/Users/qiaopengjun/Code/rust/2025/code-trio/packages/rust/target/llvm-cov-target/debug/deps/linked_list-e4d89e8c6ad35a24)

running 17 tests
test tests::test_delete_head ... ok
test tests::test_delete_tail ... ok
test tests::test_empty_list ... ok
test tests::test_k_equals_length ... ok
test tests::test_k_greater_than_length ... ok
test tests::test_k_zero_or_negative ... ok
test tests::test_normal_case ... ok
test tests::test_single_node ... ok
test tests::test_unsafe_delete_head ... ok
test tests::test_unsafe_delete_tail ... ok
test tests::test_unsafe_empty_list ... ok
test tests::test_unsafe_k_greater_than_length ... ok
test tests::test_unsafe_k_much_larger_than_length ... ok
test tests::test_unsafe_k_zero_or_negative ... ok
test tests::test_unsafe_normal_case ... ok
test tests::test_unsafe_short_list_edge_case ... ok
test tests::test_unsafe_single_node ... ok

test result: ok. 17 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

     Running unittests src/main.rs (/Users/qiaopengjun/Code/rust/2025/code-trio/packages/rust/target/llvm-cov-target/debug/deps/linked_list-2132f500c31ec04d)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

     Running tests/integration.rs (/Users/qiaopengjun/Code/rust/2025/code-trio/packages/rust/target/llvm-cov-target/debug/deps/integration-020665a53f12b167)

running 1 test
test test_main_case ... ok

test result: ok. 1 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

     Running unittests src/main.rs (/Users/qiaopengjun/Code/rust/2025/code-trio/packages/rust/target/llvm-cov-target/debug/deps/rust-b3c89251d3502352)

running 0 tests

test result: ok. 0 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.00s

Filename                      Regions    Missed Regions     Cover   Functions  Missed Functions  Executed       Lines      Missed Lines     Cover    Branches   Missed Branches     Cover
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
linked_list/src/lib.rs             69                 0   100.00%          22                 0   100.00%         159                 0   100.00%           0                 0         -
linked_list/src/main.rs             1                 1     0.00%           1                 1     0.00%           5                 5     0.00%           0                 0         -
src/main.rs                         1                 1     0.00%           1                 1     0.00%           3                 3     0.00%           0                 0         -
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
TOTAL                              71                 2    97.18%          24                 2    91.67%         167                 8    95.21%           0                 0         -

```

#### 关键参数说明

|       参数       |              作用               |
| :--------------: | :-----------------------------: |
| `--all-features` |     测试所有 Cargo features     |
|  `--workspace`   | 测试整个工作区（多 crate 项目） |
|    `--tests`     |     包含单元测试和集成测试      |
|     `--html`     |         生成 HTML 报告          |
|     `--open`     |   生成后自动在浏览器打开报告    |

### 针对库代码生成 HTML 报告

```bash
rust/linked_list on  master [?] is 📦 0.1.0 via 🦀 1.86.0 via 🅒 base 
➜ cargo llvm-cov nextest --lib --html

info: cargo-llvm-cov currently setting cfg(coverage); you can opt-out it by passing --no-cfg-coverage
   Compiling linked_list v0.1.0 (/Users/qiaopengjun/Code/rust/2025/code-trio/packages/rust/linked_list)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.93s
    Starting 17 tests across 1 binary (run ID: 01f1326e-fcb8-482d-8122-03a4d21aa8f7, nextest profile: default)
        PASS [   0.048s] linked_list tests::test_delete_head
        PASS [   0.049s] linked_list tests::test_empty_list
        PASS [   0.049s] linked_list tests::test_normal_case
        PASS [   0.049s] linked_list tests::test_unsafe_empty_list
        PASS [   0.051s] linked_list tests::test_k_greater_than_length
        PASS [   0.053s] linked_list tests::test_delete_tail
        PASS [   0.052s] linked_list tests::test_k_zero_or_negative
        PASS [   0.052s] linked_list tests::test_unsafe_delete_tail
        PASS [   0.049s] linked_list tests::test_unsafe_k_greater_than_length
        PASS [   0.053s] linked_list tests::test_k_equals_length
        PASS [   0.052s] linked_list tests::test_single_node
        PASS [   0.052s] linked_list tests::test_unsafe_delete_head
        PASS [   0.019s] linked_list tests::test_unsafe_k_zero_or_negative
        PASS [   0.018s] linked_list tests::test_unsafe_normal_case
        PASS [   0.020s] linked_list tests::test_unsafe_k_much_larger_than_length
        PASS [   0.017s] linked_list tests::test_unsafe_short_list_edge_case
        PASS [   0.018s] linked_list tests::test_unsafe_single_node
------------
     Summary [   0.071s] 17 tests run: 17 passed, 0 skipped

    Finished report saved to /Users/qiaopengjun/Code/rust/2025/code-trio/packages/rust/target/llvm-cov/html
```

### 生成 **LCOV 格式**覆盖率报告

```bash
rust/linked_list on  master [?] is 📦 0.1.0 via 🦀 1.86.0 via 🅒 base 
➜ cargo llvm-cov nextest --lib --lcov --output-path lcov.info

info: cargo-llvm-cov currently setting cfg(coverage); you can opt-out it by passing --no-cfg-coverage
   Compiling linked_list v0.1.0 (/Users/qiaopengjun/Code/rust/2025/code-trio/packages/rust/linked_list)
    Finished `test` profile [unoptimized + debuginfo] target(s) in 0.92s
    Starting 17 tests across 1 binary (run ID: 117a4e8f-3b46-415b-a834-de8b6e423cf0, nextest profile: default)
        PASS [   0.099s] linked_list tests::test_delete_tail
        PASS [   0.113s] linked_list tests::test_unsafe_delete_head
        PASS [   0.116s] linked_list tests::test_k_zero_or_negative
        PASS [   0.119s] linked_list tests::test_empty_list
        PASS [   0.118s] linked_list tests::test_k_greater_than_length
        PASS [   0.118s] linked_list tests::test_normal_case
        PASS [   0.115s] linked_list tests::test_unsafe_k_greater_than_length
        PASS [   0.119s] linked_list tests::test_k_equals_length
        PASS [   0.118s] linked_list tests::test_unsafe_empty_list
        PASS [   0.119s] linked_list tests::test_unsafe_delete_tail
        PASS [   0.120s] linked_list tests::test_single_node
        PASS [   0.122s] linked_list tests::test_delete_head
        PASS [   0.033s] linked_list tests::test_unsafe_k_much_larger_than_length
        PASS [   0.021s] linked_list tests::test_unsafe_k_zero_or_negative
        PASS [   0.020s] linked_list tests::test_unsafe_short_list_edge_case
        PASS [   0.020s] linked_list tests::test_unsafe_single_node
        PASS [   0.023s] linked_list tests::test_unsafe_normal_case
------------
     Summary [   0.141s] 17 tests run: 17 passed, 0 skipped

    Finished report saved to lcov.info

```

### 查看 LCOV 格式覆盖率文件的摘要统计信息

```bash
rust/linked_list on  master [?] is 📦 0.1.0 via 🦀 1.86.0 via 🅒 base 
➜ lcov --summary lcov.info


Reading tracefile lcov.info.
Summary coverage rate:
  source files: 1
  lines.......: 100.0% (159 of 159 lines)
  functions...: 100.0% (22 of 22 functions)
Message summary:
  no messages were reported

```

### 使用 `genhtml` 从 `lcov.info` 生成可视化 HTML 覆盖率报告

```bash
rust/linked_list on  master [?] is 📦 0.1.0 via 🦀 1.86.0 via 🅒 base 
➜ genhtml lcov.info -o coverage_report


Reading tracefile lcov.info.
Found 1 entries.
Found common filename prefix "/Users/qiaopengjun/Code/rust/2025/code-trio/packages/rust/linked_list"
Generating output.
Processing file src/lib.rs
  lines=159 hit=159 functions=22 hit=22
Overall coverage rate:
  source files: 1
  lines.......: 100.0% (159 of 159 lines)
  functions...: 100.0% (22 of 22 functions)
Message summary:
  no messages were reported
```

### 浏览器查看测试报告

#### 测试覆盖率报告 genhtml

![image-20250417152923662](/images/image-20250417152923662.png)

#### 测试覆盖率报告 llvm-cov

![image-20250417152954457](/images/image-20250417152954457.png)

## 总结

删除链表倒数第 K 个节点看似复杂，但通过 Python、Go、Rust 的双指针法实现，你可以轻松掌握这一算法！本文通过清晰的代码、全面的测试用例和 100% 覆盖率分析，展示了如何高效解决链表难题。Python 的 uv 工具简化了依赖管理，Go 和 Rust 的测试工具则确保代码健壮性。无论你是为 LeetCode 面试备战，还是想探索多语言编程，这篇实战指南都能助你一臂之力。快来动手实践，征服链表算法吧！

## 参考

- <https://leetcode.cn/problems/remove-nth-node-from-end-of-list/>
- <https://github.com/taiki-e/cargo-llvm-cov?tab=readme-ov-file#installation>
- <https://nexte.st/>
- <https://github.com/nextest-rs/nextest>
- <https://www.rust-lang.org/zh-CN>
- <https://github.com/RustPython/RustPython>
- <https://www.python.org/>
- <https://go.dev/>
- <https://github.com/golang>
- <https://github.com/qiaopengjun5162/code-trio>
