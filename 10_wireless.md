# 1. WLAN 基础

- **WLAN（Wireless LAN）**：无线局域网，使用 **802.11（Wi-Fi）** 标准。
- 覆盖范围由 **AP（Access Point）** 提供。
- 无线客户端称为 **STA（Station）**。

---

# 2. 主要设备

- **AP（Access Point）**：连接无线设备与有线网络。
- **WLC（Wireless LAN Controller）**：集中管理多个 AP。
- **Lightweight AP（瘦 AP）**
    - 必须连接 WLC
    - 配置集中管理
- **Autonomous AP（胖 AP）**
    - 独立工作
    - 每台单独配置

---

# 3. WLAN 工作模式

- **Infrastructure Mode（基础架构）**
    - Client ↔ AP ↔ LAN
    - 最常见
- **Ad Hoc Mode**
    - Client ↔ Client
    - 不经过 AP

---

# 4. 802.11 频段

### 2.4 GHz

- 覆盖远
- 穿墙能力强
- 干扰多
- 非重叠信道：
    - **1、6、11**

### 5/5.8 GHz

- 速度快
- 干扰少
- 覆盖较小
- 更多可用信道

---

# 5. SSID

- **SSID（Service Set Identifier）**
    - 无线网络名称
    - 最多 32 字符
    - Beacon 中广播

---

# 6. 无线术语

- **BSS（Basic Service Set）**
    - 一个 AP + 客户端
- **BSSID**
    - AP 的无线 MAC 地址
- **ESS（Extended Service Set）**
    - 多个 AP
    - 相同 SSID
    - 支持漫游（Roaming）


---

# 7. CAPWAP

**CAPWAP（Control And Provisioning of Wireless Access Points）**

作用：

- AP 与 WLC 通信

端口：

- UDP **5246**（Control）
- UDP **5247**（Data）

---

# 8. AP 启动流程

1. 获取 IP（DHCP）
2. 找到 WLC
3. 建立 CAPWAP
4. 下载配置
5. 开始提供无线服务

---

# 9. WLC

1. 创建 WLAN
2. 配置 SSID
3. 绑定 VLAN
4. 配置安全策略
5. Enable WLAN
