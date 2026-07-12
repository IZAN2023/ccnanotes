# 配置与排错总结

## 1. 拓扑

```
R1 (Lo0: 2001:DB8:1:1::10/64)
  |
  Et0/0: 2001:DB8:2:2::1/64
  |
  ----------- (共享网段 2001:DB8:2:2::/64) -----------
  |
  Et0/0: 2001:DB8:2:2::2/64
  |
R2 (Lo0: 2001:DB8:3:3::1/64)
```

两台路由器通过 Ethernet0/0 直连，各自的 Loopback0 模拟内部/远端网络。

---

## 2. 实现方式

### 方式一：静态路由 (ipv6 route)

```
ipv6 unicast-routing
interface Loopback0
 ipv6 address 2001:DB8:1:1::10/64
interface Ethernet0/0
 ipv6 address 2001:DB8:2:2::1/64
ipv6 route 2001:DB8:3:3::/64 2001:DB8:2:2::2
```

### 方式二：OSPFv3 动态路由

```
ipv6 unicast-routing
interface Loopback0
 ipv6 address 2001:DB8:1:1::10/64
 ipv6 ospf 1 area 0
interface Ethernet0/0
 ipv6 address 2001:DB8:2:2::1/64
 ipv6 ospf 1 area 0
router ospfv3 1
 router-id 1.1.1.1
 address-family ipv6 unicast
 exit-address-family
```

**IPv6 下 OSPF 是直接在接口下用 `ipv6 ospf <process> area <area>` 挂载**，不像 IPv4 OSPF 那样在 router 模式下用 `network` 命令宣告网段。

---

## 3. 常用配置命令速查

| 命令                               | 作用                                                            |
| ---------------------------------- | --------------------------------------------------------------- |
| `ipv6 unicast-routing`             | 全局开启 IPv6 路由转发功能（前提条件）                          |
| `ipv6 address X::X/64`             | 接口配置 IPv6 地址                                              |
| `ipv6 ospf 1 area 0`               | 在接口下启用 OSPFv3 进程1，加入 area 0                          |
| `router ospfv3 1`                  | 进入 OSPFv3 进程配置模式                                        |
| `router-id x.x.x.x`                | 手动指定 Router ID（IPv6 下没有 IP 地址可自动选，建议手动配置） |
| `ipv6 ospf network point-to-point` | 修改接口 OSPF 网络类型                                          |
| `no shutdown`                      | **激活接口**（默认物理接口是 admin down，非常容易漏配！）       |

---

## 4. 验证命令速查

| 命令                             | 查看内容                                   |
| -------------------------------- | ------------------------------------------ |
| `show ipv6 interface brief`      | 接口 IPv6 地址及 up/down 状态              |
| `show ipv6 ospf neighbor`        | OSPF 邻居状态（是否为 FULL）               |
| `show ipv6 ospf interface brief` | 各接口上 OSPF 运行情况、网络类型、邻居数量 |
| `show ipv6 route ospf`           | 查看通过 OSPF 学到的路由条目               |
| `ping <IPv6地址>`                | 测试连通性                                 |

---

## 5. 问题与排查思路

### 问题 1：`show ipv6 ospf neighbor` 无输出（邻居建立不起来）

排查顺序（**由底层到上层**，非常重要的排错思路）：

1. **接口物理状态**：`show ipv6 interface brief`
    - 检查是否为 `up/up`
    - 常见原因：忘记 `no shutdown`（真实设备/模拟器接口默认关闭）
2. **二层连通性**：`ping` 对端接口地址
    - 确认链路本身没问题
3. **OSPF 是否真的挂载在接口上**：`show ipv6 ospf interface brief`
    - 确认接口出现在列表中，State 正常（DR/BDR/P2P等）
4. **两端网络类型是否一致**（broadcast vs point-to-point）
    - 不一致会导致无法建立邻居
5. **耐心等待 Hello/Dead 定时器**（默认 Hello=10s，Dead=40s）

结果：本次问题根源是接口未 `no shutdown`，激活后邻居正常从 `LOADING` 变为 `FULL`：

```
%OSPFv3-5-ADJCHG: Process 1, IPv6, Nbr 2.2.2.2 on Ethernet0/0 from LOADING to FULL, Loading Done
```

## 6. 总结

1. **IPv6 路由的两大前提**：
    - 全局开启 `ipv6 unicast-routing`
    - 接口必须 `no shutdown` 才能转发流量（无论静态还是动态路由都一样，这是最容易被忽略的基础项）

2. **OSPFv3 与 OSPFv2（IPv4）的配置方式不同**：
    - OSPFv2：在 `router ospf` 模式下用 `network` 命令宣告网段
    - OSPFv3：直接在**接口下**用 `ipv6 ospf <process> area <area>` 启用

3. **Router ID 的重要性**：
    - IPv6 接口没有 IPv4 地址可供自动选举 Router ID，因此**强烈建议手动配置** `router-id`，否则可能导致 OSPFv3 无法正常工作（尤其是没有配置任何 IPv4 地址的纯 IPv6 环境）

4. **排错的通用思路（自底向上）**：

    ```
    物理/接口状态 → 二层连通性 → 协议是否启用 → 协议状态/参数一致性 → 路由表 → 端到端连通性
    ```

    这个顺序适用于绝大多数网络故障排查，不仅限于 OSPFv3。

5. **FULL 状态才是正常的邻居关系**：
    - OSPF 邻居状态机：Down → Init → 2-Way → ExStart → Exchange → Loading → **Full**
    - 只有到达 Full，才代表双方数据库已完全同步，可以正常交换路由信息

---
