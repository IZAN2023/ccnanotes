# RIP 

## 一、基本概念

RIP（Routing Information Protocol）是一种**距离矢量（Distance Vector）路由协议**。是最早期、最简单的动态路由协议，适合小型网络。

---

## 二、版本对比

| 特性 | RIPv1 | RIPv2 |
|---|---|---|
| 通告方式 | 广播 255.255.255.255 | 组播 **224.0.0.9** |
| 子网掩码携带 | 不携带 | 携带（支持 **VLSM**，可变长子网掩码） |
| CIDR 支持 | 不支持 | 支持 |
| 认证 | 不支持 | 支持（明文 / MD5） |
| 自动汇总 | 强制开启 | 默认开启，可用 `no auto-summary` 关闭 |

> **实践建议**：现在基本只用 RIPv2，配置时必须写 `version 2`，否则默认是 v1，VLSM 环境下会出问题。

---

## 三、核心参数速查表

| 参数 | 值 | 说明 |
|---|---|---|
| 管理距离（AD） | **120** | 数值越小越优先，RIP 在常见协议里可信度最低（仅比未知/240高一点） |
| 度量值（Metric） | **跳数（hop count）** | 每经过一台路由器 +1，不考虑带宽、延迟 |
| 最大跳数 | **15** | 16 表示不可达（无穷大），超过则判定网络不可达 |
| 组播地址（v2） | 224.0.0.9 | RIPv2 更新报文的目的地址 |
| 默认端口 | UDP 520 | — |

---

## 四、四个定时器（重点记忆）

| 定时器 | 时间 | 作用 |
|---|---|---|
| **Update**（更新） | 30s | 周期性向邻居发送完整路由表 |
| **Invalid**（失效） | 180s | 超过此时间未收到某条路由更新，标记为 possibly down |
| **Holddown**（保持） | 180s | 路由标记不可达后，此期间内不接受关于该路由的"更差"更新，防止路由抖动/环路 |
| **Flush**（清除） | 240s | 超时后彻底从路由表删除该条目 |

> **抓包验证要点**：实际更新间隔常在 25-30s 之间波动（Cisco 实现加入随机负向抖动），这是为了防止多台路由器更新包同步冲突，**属于正常现象，不是异常**。

---

## 五、防环机制

RIP 作为距离矢量协议天生容易产生环路，依赖以下机制预防：

1. **水平分割（Split Horizon）**：从某接口学到的路由，不会再从该接口通告回去
2. **毒性逆转（Poison Reverse）**：配合水平分割，反向通告时把度量设为 16（不可达），更明确阻止环路
3. **触发更新（Triggered Update）**：拓扑变化时立即发送更新，不等待 30s 周期，加快收敛
4. **最大跳数限制**：15 跳限制本身也是一种朴素防环手段

---

## 六、配置模板

### 基本配置结构
```
router rip
 version 2
 network <主类网络地址>
 no auto-summary        ! 视情况添加，见下方说明
```

### 三节点示例拓扑配置

```
! ===== R1 =====
interface Loopback0
 ip address 10.1.1.1 255.255.255.0
interface Loopback1
 ip address 10.2.2.1 255.255.255.224
interface Ethernet0/0
 ip address 10.3.3.1 255.255.255.0
 no shutdown

router rip
 version 2
 network 10.0.0.0

! ===== R2 =====
interface Ethernet0/1
 ip address 10.3.3.2 255.255.255.0
 no shutdown
interface Serial2/1
 ip address 172.16.3.2 255.255.255.0
 clock rate 64000
 no shutdown
interface Loopback0
 ip address 192.168.1.1 255.255.255.0

router rip
 version 2
 network 10.0.0.0
 network 172.16.0.0
 network 192.168.1.0
 no auto-summary

! ===== R3 =====
interface Loopback0
 ip address 172.16.1.1 255.255.255.0
interface Loopback1
 ip address 172.16.2.1 255.255.255.224
interface Serial2/0
 ip address 172.16.3.1 255.255.255.0
 no shutdown

router rip
 version 2
 network 172.16.0.0
```

### `network` 命令要点
- RIP 的 `network` **只能填主类网络地址**（不支持通配掩码，这点和 EIGRP/OSPF 不同）
- 作用：声明哪些接口参与 RIP 进程、对外发送/接收更新
- 一条 `network 10.0.0.0` 会激活该路由器上**所有**属于 10.0.0.0/8 的接口，无论实际子网掩码是 /24 还是 /27

### 自动汇总（auto-summary）关键判断逻辑

RIP 默认在**主类网络边界**做自动汇总。判断是否需要关闭的原则：

- ✅ **需要关闭**：路由器同时连接**多个不同主类网段**（如上例 R2 同时挂 10.x / 172.16.x / 192.168.1.x）。不关闭会导致 VLSM 精确子网（如 /27）被压缩成主类默认掩码（/8、/16、/24），造成路由不精确甚至不可达。
- ⚪ **可以不关**：路由器所有接口都属于**同一主类网段**（如上例 R1 只有 10.x，R3 只有 172.16.x），不会跨主类边界通告，不会触发自动汇总问题。
- 💡 **稳妥做法**：所有路由器统一加 `no auto-summary`，避免以后拓扑扩展时踩坑。

---

## 七、测试验证方法（按顺序排查）

### 1. 检查 RIP 进程与接口声明
```
show ip protocols
```
确认 "Routing for Networks" 和 "Interface" 列表与预期一致，同时可看到当前 version、是否 no auto-summary。

### 2. 检查 RIP 数据库（核心排查手段）
```
show ip rip database
```
- 能看到 RIP 学到的**所有路由条目**及来源
- **关键判断点**：如果这里看到的是 `10.0.0.0/8` 而不是精确的 `10.1.1.0/24` + `10.2.2.0/27`，说明自动汇总没关干净

### 3. 检查最终路由表
```
show ip route rip
```
确认掩码是否为精确子网（如 /27），而非被汇总后的主类网段。

### 4. 端到端连通性测试（建议专挑 VLSM 子网测试）
```
ping 172.16.2.1 source 10.2.2.1
```
特意用两端的 /27 子网互测，专门验证 VLSM 是否真正生效，比整段网段互通更能暴露掩码问题。

### 5. 报文抓取分析（Wireshark）
- 过滤 `rip` 或查看目的地址 `224.0.0.9`
- **正常现象**：
  - 更新间隔在 25-30s 波动（随机抖动）
  - 不同路由器的更新包长度不同（连接的网段数量越多，携带路由条目越多，包越大）
  - 两端更新周期彼此独立、不同步
- **重点排查**：展开某个 RIP 包详情，查看 Routing Information Protocol → IP Address / Subnet Mask / Metric 字段，直接确认通告的子网掩码是否精确（这是验证 auto-summary 是否生效最直接的方法）

### 6. 抓包时的干扰项识别（不是RIP问题）
| 帧类型 | 特征 | 说明 |
|---|---|---|
| LOOP | 约每10秒一次，MAC地址互发 | 模拟器（GNS3/EVE-NG）的二层保活帧，与路由协议无关 |
| CDP | 约每60秒一次，携带 Device ID / Port ID | Cisco 默认邻居发现协议，属正常底层机制 |

### 7. 版本差异验证实验（进阶）
临时将某台路由器改为 `version 1`：
```
router rip
 version 1
```
再执行 `show ip rip database`，应观察到 VLSM 子网（如 /27）学不到了 —— 直观验证"RIPv1 不支持 VLSM"这一特性。

### 8. Debug 排查（问题诊断用）
```
debug ip rip
```
实时查看每 30 秒左右的更新报文收发内容，可直接确认通告的到底是精确子网还是被汇总后的网段。

---

## 八、常见故障排查清单

| 现象 | 可能原因 |
|---|---|
| `show ip protocols` 里没有目标接口 | `network` 语句遗漏对应主类网段，或接口 `shutdown` |
| 邻居学不到路由 | 接口未 `no shutdown`；串口两端时钟未配对（DCE端缺 `clock rate`） |
| 学到的路由掩码不对（被汇总） | 跨主类网段的路由器忘记 `no auto-summary` |
| 路由能学到但 ping 不通 | 检查是否有 ACL 阻挡、接口 IP 配错、双向路由是否都存在 |
| 路由收敛慢 / 时断时续 | 检查 holddown 定时器是否触发（`show ip route` 中可能标记 possibly down） |

---

## 九、RIP 在路由协议家族中的定位

```
RIP（跳数度量，15跳限制，收敛慢，配置最简单）
  ↓
EIGRP（带宽+延迟复合metric，支持通配掩码，DUAL算法快速收敛，AD 90/170）
  ↓
OSPF（链路状态，SPF算法，区域化设计，适合大型网络）
```

**RIP 优点**：配置极简单、CPU/内存开销小，适合小型或实验室网络
**RIP 缺点**：
- 只看跳数，不考虑链路质量（可能选出"跳数少但实际很慢"的路径）
- 15 跳上限，不适合大型网络
- 收敛速度慢，依赖多个定时器协同工作

![[4587186fc6bc433528d2a218317a4896.png]]![[be0bae7f8a51505fc6fe87aee348c164.png]]![[fc0fd8282a840c23a8315b275ed0fbbc.png]]



# EIGRP 

## 一、基本概念

EIGRP（Enhanced Interior Gateway Routing Protocol）是 Cisco 私有的**高级距离矢量协议（也称混合型协议）**，结合了距离矢量协议的简单性和链路状态协议的快速收敛能力，核心依赖 **DUAL（Diffusing Update Algorithm，弥散更新算法）** 实现无环快速收敛。

---

## 二、核心参数速查表

| 参数 | 值 | 说明 |
|---|---|---|
| 管理距离（AD） | **内部路由 90 / 外部路由 170** | 内部指 EIGRP 域内学到的路由，外部指重分发进来的路由 |
| 度量值（Metric） | 复合值，默认由**带宽 + 延迟**决定 | 比 RIP 的跳数更精细，能反映链路真实质量 |
| 组播地址 | **224.0.0.10** | EIGRP Hello / Update 报文目的地址 |
| 协议号 | IP 协议号 88 | 直接封装在 IP 之上，不用 UDP/TCP |
| Hello 间隔 | 5s（高速链路）/ 60s（慢速链路，如帧中继） | 决定邻居检测速度 |
| Hold 时间 | 默认为 Hello 的 3 倍（15s / 180s） | 超过此时间未收到 Hello，判定邻居失效 |

---

## 三、Metric 计算公式（重点）

```
Metric = [K1×BW + (K2×BW)/(256−load) + K3×Delay] × [K5/(reliability+K4)]

默认：K1=1, K2=0, K3=1, K4=0, K5=0
简化后（默认K值下）：Metric = 256 × (10^7 / BW_min + ΣDelay/10)
```

### 计算用参数换算
```
Bandwidth 项 = [10,000,000 / (带宽，单位Kbps)] × 256
Delay 项     = [延迟，单位为10微秒] × 256
```

### 常见接口默认值（用于手算）
| 接口类型 | 带宽（BW） | 延迟（DLY） |
|---|---|---|
| Ethernet 0/0 | 10000 Kbit/s | 1000 usec |
| Serial 2/0（默认串口） | 1544 Kbit/s | 20000 usec |
| Loopback | 8000000 Kbit/s | 5000 usec |

> **实践要点**：EIGRP 的 metric 取路径上**最小带宽**（瓶颈带宽）+ **累计延迟**，这也是为什么它比 RIP 更能反映真实链路质量——即便跳数少，如果中间有一段低速链路，metric 依然会很大。

### 手算示例
假设路径为 R1（Ethernet, BW=10000）→ R2 → R3（Serial, BW=1544）：
- 瓶颈带宽取路径中最小值：1544 Kbps
- 延迟累加：1000 + 20000 = 21000 usec → 转换为10微秒单位 = 2100
- Bandwidth 项 = (10,000,000 / 1544) × 256 ≈ 1,657,856
- Delay 项 = 2100 × 256 = 537,600
- Metric ≈ 1,657,856 + 537,600 = 2,195,456

可以用 `show ip eigrp topology` 里显示的 FD（Feasible Distance）反推验证这个手算结果。

---
## 四、DUAL 算法相关术语

| 术语 | 含义 |
|---|---|
| **FD**（Feasible Distance） | 到目标网络的最优（最小）metric |
| **AD**（Advertised/Reported Distance） | 邻居通告给你的、它自己到目标网络的metric |
| **Successor**（后继） | 到达目标的最优下一跳，被放入路由表 |
| **Feasible Successor**（可行后继，FS） | 备份路径，满足 **可行性条件（Feasibility Condition, FC）**：该邻居的 AD < 本地FD，一旦主路径失效可**无需重新计算即时切换**，这是 EIGRP 收敛快的核心原因 |
| **主动（Active）/ 被动（Passive）状态** | 路由正常稳定时为 Passive；当 Successor 失效且没有可行后继时，进入 Active 状态，向所有邻居发送 Query 主动查询新路径 |

---

## 五、`network` 命令与通配掩码（EIGRP 的核心优势之一）

不同于 RIP 只能填主类网络地址，**EIGRP 的 `network` 命令支持通配掩码（反掩码）**，可以做到比 RIP 更精细的接口级控制：

```
network <网络号> [反掩码]
```

### 反掩码规则
- **不写反掩码**：按**有类默认掩码**处理
  - A类默认反掩码：0.255.255.255
  - B类默认反掩码：0.0.255.255
  - C类默认反掩码：0.0.0.255
- **写具体反掩码**：可以精确到单个接口地址（反掩码 `0.0.0.0`）或任意子网范围

### 特殊写法
```
network 0.0.0.0        ! 等效于 0.0.0.0 255.255.255.255，激活该路由器所有接口
```

---

## 六、配置模板

### 基本配置结构
```
router eigrp <AS号>
 network <网络地址> [反掩码]
 no auto-summary        ! 建议加，尤其跨主类网段的路由器
```

> **重要**：所有参与 EIGRP 的路由器必须使用**相同的 AS 号**（自治系统号），否则无法建立邻居关系。这个 AS 号本地有意义，仅用于标识同一个 EIGRP 域，不需要向 IANA 注册。

### 三节点示例拓扑配置

```
! ===== R1 =====
interface Loopback0
 ip address 10.1.1.1 255.255.255.0
interface Loopback1
 ip address 10.2.2.1 255.255.255.224
interface Ethernet0/0
 ip address 10.3.3.1 255.255.255.0
 no shutdown

router eigrp 100
 network 10.1.1.0 0.0.0.255
 network 10.2.2.1 0.0.0.0      ! 反掩码全0，仅精确匹配该地址，避免同网段其他接口被误激活
 network 10.3.3.0 0.0.0.255

! ===== R2 =====
interface Ethernet0/1
 ip address 10.3.3.2 255.255.255.0
 no shutdown
interface Serial2/1
 ip address 172.16.3.2 255.255.255.0
 clock rate 64000
 no shutdown
interface Loopback0
 ip address 192.168.1.1 255.255.255.0

router eigrp 100
 network 10.3.3.2 0.0.0.0
 network 172.16.0.0            ! 不写反掩码，走B类默认 0.0.255.255
 network 192.168.1.0           ! 不写反掩码，走C类默认 0.0.0.255

! ===== R3 =====
interface Loopback0
 ip address 172.16.1.1 255.255.255.0
interface Loopback1
 ip address 172.16.2.1 255.255.255.224
interface Serial2/0
 ip address 172.16.3.1 255.255.255.0
 no shutdown

router eigrp 100
 network 0.0.0.0                ! 激活所有接口，最简写法
```

---
## 七、测试验证方法（按顺序排查）

### 1. 检查邻居关系是否建立（最关键的第一步）
```
show ip eigrp neighbors
```
- 应能看到对端邻居的地址、接口、Hold time、Uptime
- **邻居建不起来的常见原因**：
  - 接口未 `no shutdown`
  - 串口两端时钟未配对（DCE 端缺 `clock rate`）
  - `network` 语句没覆盖到该接口
  - 两端 **K 值不一致**（K1-K5 必须完全相同，否则拒绝建邻）
  - 两端 **AS 号不一致**

### 2. 检查 EIGRP 声明的网络范围
```
show ip protocols
```
可以看到当前 EIGRP 通过 `network` 命令实际覆盖的网段，对照拓扑核实反掩码逻辑是否符合预期。

### 3. 检查拓扑表（DUAL 算法核心数据结构）
```
show ip eigrp topology
```
- 能看到每条目标网络的 **FD** 和 **AD**
- 如果存在 Feasible Successor，会额外显示备份路径
- 用这里的数字反推验证第三节的手算 metric 是否正确

### 4. 检查最终路由表
```
show ip route eigrp
```
确认对端网段（如 172.16.x.x、192.168.1.0）是否都学到，并确认下一跳、metric 是否合理。

### 5. 端到端连通性测试
```
ping 172.16.1.1 source 10.1.1.1
traceroute 172.16.1.1
```
用 `traceroute` 确认路径是否符合预期（经由中间路由器转发）。

### 6. Hello 报文抓包排查（邻居建立失败时使用）
```
debug eigrp packets hello
```
查看 Hello 包是否正常收发；如果只发不收或只收不发，通常是二层连通性或接口配置问题。

### 7. 报文抓取分析（Wireshark）
- 过滤 EIGRP，或查看目的组播地址 **224.0.0.10**
- 正常现象：
  - Hello 包周期性出现（高速链路5s一次）
  - 邻居建立时会有一次完整的拓扑表交换（Update包，体积较大）
  - 之后转为增量更新，只在拓扑变化时触发（体现"弥散更新"特性，而非像RIP一样周期性发送全表）

### 8. K值一致性检查（邻居异常时排查）
```
show ip protocols
```
留意输出中的 K1/K2/K3/K4/K5 值，确认两端路由器完全一致。默认情况下（K1=1, K3=1，其余为0）通常不需要手动改动，除非特别配置过 `metric weights`。

---

## 八、常见故障排查清单

| 现象 | 可能原因 |
|---|---|
| 邻居建不起来 | AS号不一致 / K值不一致 / 接口未激活 / 时钟未配对 |
| `show ip protocols` 里没有目标接口 | `network` 反掩码写错，未覆盖该接口地址 |
| 拓扑表里没有 Feasible Successor | 备份路径的 AD ≥ 本地 FD，不满足可行性条件，DUAL 只能进入 Active 状态重新计算 |
| 路由学到但 metric 异常偏大/偏小 | 接口带宽/延迟被手动改过（`bandwidth` / `delay` 命令），或路径经过慢速链路（如串口） |
| 路由收敛慢，出现 "stuck in active" | 网络中存在拓扑不稳定或邻居无响应，导致 DUAL 长时间处于 Active 状态查询无果 |

---

## 九、EIGRP 相较 RIP 的核心优势总结

| 维度 | RIP | EIGRP |
|---|---|---|
| Metric 依据 | 仅跳数 | 带宽 + 延迟（可反映真实链路质量） |
| 收敛速度 | 慢（依赖多个30-240s定时器） | 快（DUAL算法+可行后继，可实现近乎瞬时切换） |
| network 命令精细度 | 仅主类网络 | 支持通配掩码，可精确到单接口 |
| 是否支持 VLSM | 仅v2支持 | 支持 |
| 是否支持不等价负载均衡 | 不支持 | 支持（`variance` 命令） |
| 管理距离 | 120 | 90（内部）/ 170（外部） |

---

## 十、EIGRP 在路由协议家族中的定位

```
RIP（跳数度量，15跳限制，收敛慢，配置最简单）
  ↓
EIGRP（带宽+延迟复合metric，支持通配掩码，DUAL算法快速收敛，AD 90/170）
  ↓
OSPF（链路状态，SPF算法，区域化设计，适合大型网络）
```

**EIGRP 优点**：
- 收敛速度快（可行后继机制，很多场景下可实现"零延迟"切换到备份路径）
- Metric 更能反映真实链路质量
- 配置灵活度高于 RIP（通配掩码）
- 支持不等价负载均衡（RIP/OSPF均不支持）

**EIGRP 缺点**：
- Cisco 私有协议，早期仅 Cisco 设备支持（现已部分开源为 IETF 草案，但仍以 Cisco 生态为主）
- 大规模网络中拓扑表可能变得庞大，需要合理规划汇总和边界
![[129e4fd73821c36b46d259c9f5d22225.png]]![[b78e23cd0f63047fbafa7bedccb344d5.png]]