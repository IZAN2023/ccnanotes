## 🌳 Spanning Tree Protocol (STP) 状态机（IEEE 802.1D）

### 🧠 端口状态流转图（State Machine）

```
                 +------------------+
                 |    Blocking      |
                 | (不转发数据帧)     |
                 | (只接收 BPDU)     |
                 +--------+---------+
                       ^  |
                       |  | 拓扑变化 / 端口启用
                       |  v
                 +------------------+
                 |    Listening     |
                 | (不学习MAC)       |
                 | (不转发数据)       |
                 | (参与选举)         |
                 +--------+---------+
                          |
                          |  Forward Delay (15s)
                          v
                 +------------------+
                 |    Learning      |
                 | (学习MAC地址)      |
                 | (不转发数据)       |
                 +--------+---------+
                          |
                          |  Forward Delay (15s)
                          v
                 +------------------+
                 |    Forwarding    |
                 | (正常转发数据)     |
                 | (学习MAC)         |
                 +--------+---------+
```

---

### ⏱️ 关键 Timer 标注

- **Hello Time = 2s**
  - Root Bridge 每 2 秒发送 BPDU

- **Max Age = 20s**
  - 超过 20 秒没收到 BPDU → 认为 Root 不可达 → 触发重新收敛

- **Forward Delay = 15s**
  - Listening 状态停留 15 秒
  - Learning 状态停留 15 秒

---

### 🔍 各状态行为总结

| 状态       | 转发数据 | 学习MAC | 处理BPDU |
| ---------- | -------- | ------- | -------- |
| Blocking   | ❌       | ❌      | ✅       |
| Listening  | ❌       | ❌      | ✅       |
| Learning   | ❌       | ✅      | ✅       |
| Forwarding | ✅       | ✅      | ✅       |
| Disabled   | ❌       | ❌      | ❌       |

---

### 端口角色

#### Root Port（RP）

每台非根桥上，通往根桥“代价最小”的那个端口。
特点：每台非根桥通常只有 1 个根端口，会进入转发路径。

#### Designated Port（DP）

在每个二层网段上，负责该网段“对外转发”的端口。
特点：每个网段只有 1 个指定端口；根桥上的端口通常都是指定端口。

#### Non-Designated Port（NDP）（常说“BLK端口”）

既不是根端口，也不是该网段的指定端口。
特点：为防环路而被阻塞，不参与正常转发。

#### 常考的逻辑：

- root bridge 没有 RP。
- 每个 segment 只能有一个 DP。
- 其余冗余端口会成为 NDP（BLK）

### 生成树的相关配置及查看

```bash
# 查看stp状态
s5# show spanning-tree vlan 1

VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    4097
             Address     aabb.cc00.1d00
             Cost        100
             Port        4 (Ethernet0/3)
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    24577  (priority 24576 sys-id-ext 1)
             Address     aabb.cc00.1e00
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  300 sec

Interface           Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
Et0/2               Altn BLK 100       128.3    Shr
Et0/3               Root FWD 100       128.4    Shr

s4# show spanning-tree vlan 1

VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    4097
             Address     aabb.cc00.1d00
             This bridge is the root
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    4097   (priority 4096 sys-id-ext 1)
             Address     aabb.cc00.1d00
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  300 sec

Interface           Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
Et0/0               Desg FWD 100       128.1    Shr
Et0/1               Desg FWD 100       128.2    Shr

# 修改端口的cost
s5(config)# int e0/1
s5(config-if)# spanning-tree cost 100

# 也可以针对特定vlan修改cost
s5(config-if)# spanning-tree vlan 1 cost 100

# 修改自己的BID priority（要指定vlan xx）
s5(config)# spanning-tree vlan 1 priority 4096

```

## 🌪 Rapid Spanning Tree Protocol (RSTP, IEEE 802.1w)

### 核心变化

- 802.1D STP：**只有 Root Bridge 发送 BPDU**，其他交换机只是转发或生成配置 BPDU，在一个 segment 中，只有 DP 发送 bpdu
- 802.1w RSTP：**所有端口都主动发送 BPDU**，实现快速收敛

---

### 多了 Alternative port 的概念，在 None-root bridge上，当 RP down 掉以后，ALT port 直接成为 RP

### 4️⃣ 小结对比表

| 特性     | STP (802.1D)             | RSTP (802.1w)      |
| -------- | ------------------------ | ------------------ |
| BPDU 源  | Root bridge + DP（转发） | **所有端口主动发** |
| 收敛时间 | 30–50 s                  | 秒级（≈6–10 s）    |

### 配置

```bash
# 启用RSTP
s5(config)# spanning-tree mod rapid-pvst

```

---

## 常见 STP 特性总结

#### PortFast

- 作用：让端口跳过 Listening → Learning，直接进入 Forwarding 状态，缩短收敛时间。
- 适用场景：接 PC、打印机、IP Phone 等终端设备的接口。

```bash
s5(config)#int e0/0
s5(config-if)#switchport mode access
s5(config-if)#switchport acc vlan 10
s5(config-if)#spanning-tree portfast
%Warning: portfast should only be enabled on ports connected to a single
 host. Connecting hubs, concentrators, switches, bridges, etc... to this
 interface  when portfast is enabled, can cause temporary bridging loops.
 Use with CAUTION

%Portfast has been configured on Ethernet0/0 but will only
 have effect when the interface is in a non-trunking mode.
```

#### BPDU Guard

- 作用：当启用了 PortFast 的端口收到 BPDU 时，立即将端口置为 err-disabled。
- 目的：防止本应连接终端的接口意外接入交换机，保护二层拓扑。
- 常见搭配：PortFast + BPDU Guard，这是接入口最常见的安全组合。

```bash
# s1的e0/0接着一台交换机，我们先把e0/0 shutdown，然后配置好portfast和bpduguard
s1(config)#do sh run int e0/0
interface Ethernet0/0
 switchport access vlan 10
 switchport mode access
 shutdown
 spanning-tree portfast
 spanning-tree bpduguard enable

# 启用e0/0，可以看到接口收到对方的bpdu以后，迅速进入err-disable状态
s1(config)# interface e0/0
s1(config-if)#no shut

*Apr  5 18:25:36.897: %SPANTREE-2-BLOCK_BPDUGUARD: Received BPDU on port Et0/0 with BPDU Guard enabled. Disabling port.
*Apr  5 18:25:36.897: %PM-4-ERR_DISABLE: bpduguard error detected on Et0/0, putting Et0/0 in err-disable state
*Apr  5 18:25:37.398: %LINK-3-UPDOWN: Interface Ethernet0/0, changed state to down

# 检查接口状态，可以看到接口已经被err-disable
s1(config-if)#do sh int e0/0
Ethernet0/0 is down, line protocol is down (err-disabled)
  Hardware is AmdP2, address is aabb.cc00.1700 (bia aabb.cc00.1700)
  MTU 1500 bytes, BW 10000 Kbit/sec, DLY 1000 usec,
     reliability 255/255, txload 1/255, rxload 1/255
  Encapsulation ARPA, loopback not set
  Keepalive set (10 sec)
  Auto-duplex, Auto-speed, media type is unknown
  input flow-control is off, output flow-control is unsupported
  ARP type: ARPA, ARP Timeout 04:00:00
  Last input 00:00:01, output 00:00:34, output hang never
  Last clearing of "show interface" counters never
  Input queue: 0/2000/0/0 (size/max/drops/flushes); Total output drops: 0
  Queueing strategy: fifo
  Output queue: 0/0 (size/max)
  5 minute input rate 0 bits/sec, 0 packets/sec
  5 minute output rate 0 bits/sec, 0 packets/sec
     134 packets input, 16621 bytes, 0 no buffer
     Received 132 broadcasts (0 multicasts)
     0 runts, 0 giants, 0 throttles
     0 input errors, 0 CRC, 0 frame, 0 overrun, 0 ignored
     0 input packets with dribble condition detected
     727 packets output, 52808 bytes, 0 underruns
     0 output errors, 0 collisions, 0 interface resets
     0 unknown protocol drops
     0 babbles, 0 late collision, 0 deferred
     0 lost carrier, 0 no carrier
     0 output buffer failures, 0 output buffers swapped out

# 要重新激活被err-disable的端口，必须手动shutdown，然后no shutdown
s1(config)# interface e0/0
s1(config-if)#shutdown
s1(config-if)#no shutdown

```

#### BPDU Filter

- 作用：过滤 BPDU，避免端口发送或接收 BPDU。
- 风险：会削弱 STP 的环路保护能力，配置不当容易引发二层环路。
- 全局配置下
  PortFast 端口启动时发送少量 BPDU（约11个），之后若收不到 BPDU 则停止发送；一旦收到 BPDU，立即撤销 PortFast，端口恢复正常 STP

  ```bash
  s1(config)# spanning-tree portfast bpdufilter default
  ```

- 接口级配置更激进，直接阻止 BPDU 交互

  ```bash
  s1(config)#int e0/0
  s1(config-if)#spanning-tree bpdufilter enable
  ```

#### Root Guard

- 作用：防止某个接入口意外成为 Root Bridge 的方向。
- 当端口收到更优的 BPDU 时，该端口会被限制，阻止拓扑被篡改。
- 常用于接入层到汇聚层之间的下行方向，保护根桥位置。

```bash
# 在s2的DP上启用root guard
s2(config)#int e0/1
s2(config-if)#spanning-tree guard root
*Apr  5 20:16:45.075: %SPANTREE-2-ROOTGUARD_CONFIG_CHANGE: Root guard enabled on port Ethernet0/1.

# 当s3修改自己的优先级以后，s2 root guard生效报警
*Apr  5 20:17:08.352: %SPANTREE-2-ROOTGUARD_BLOCK: Root guard blocking port Ethernet0/1 on VLAN0001.

# e0/1被blk
s2(config-if)#do sh spa

VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    32769
             Address     aabb.cc00.1700
             Cost        100
             Port        1 (Ethernet0/0)
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32769  (priority 32768 sys-id-ext 1)
             Address     aabb.cc00.1800
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  15  sec

Interface           Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
Et0/0               Root FWD 100       128.1    Shr
Et0/1               Desg BKN*100       128.2    Shr *ROOT_Inc
```

#### Loop Guard

- 作用：防止端口因为 BPDU 丢失而错误地从阻塞状态转为转发，形成环路。
- 常用于冗余链路上，保护本应保持阻塞的备份端口。
- 对 alternate / backup 这类本来不该转发的端口，Loop Guard 会盯住它们是否持续收到 BPDU。
- 一旦 BPDU 断了，它宁可把端口卡在 loop-inconsistent，也不让它因为“误以为链路正常”而转发。

```bash
# 正常情况下，e0/2被blk，因为对端有bpdu过来
s5#show spanning-tree

VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    32769
             Address     aabb.cc00.1d00
             Cost        100
             Port        4 (Ethernet0/3)
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32769  (priority 32768 sys-id-ext 1)
             Address     aabb.cc00.1e00
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  15  sec

Interface           Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
Et0/2               Altn BLK 100       128.3    Shr
Et0/3               Root FWD 100       128.4    Shr

# 如果把对端的bpdu关掉，则本端e0/2进入lis模式，随即进入learn和forward
s5#show spanning-tree

VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    32769
             Address     aabb.cc00.1d00
             Cost        100
             Port        4 (Ethernet0/3)
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32769  (priority 32768 sys-id-ext 1)
             Address     aabb.cc00.1e00
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  15  sec

Interface           Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
Et0/2               Desg LIS 100       128.3    Shr
Et0/3               Root FWD 100       128.4    Shr

# 开启loopguard
s5(config)#int e0/2
s5(config-if)#spanning-tree guard loop

# 如果把对端的bpdu关掉，则本端出现loop guard告警，并进入loop-inconsistent
*Apr  5 20:30:44.730: %SPANTREE-2-LOOPGUARD_BLOCK: Loop guard blocking port Ethernet0/2 on VLAN0001.

s5#show spanning-tree

VLAN0001
  Spanning tree enabled protocol ieee
  Root ID    Priority    32769
             Address     aabb.cc00.1d00
             Cost        100
             Port        4 (Ethernet0/3)
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec

  Bridge ID  Priority    32769  (priority 32768 sys-id-ext 1)
             Address     aabb.cc00.1e00
             Hello Time   2 sec  Max Age 20 sec  Forward Delay 15 sec
             Aging Time  15  sec

Interface           Role Sts Cost      Prio.Nbr Type
------------------- ---- --- --------- -------- --------------------------------
Et0/2               Desg BKN*100       128.3    Shr *LOOP_Inc
Et0/3               Root FWD 100       128.4    Shr

```

### 一句话记忆

- PortFast：让终端口快转发（跳过listen和learn）。
- BPDU Guard：端口收到 BPDU 就关掉（err-disable）。
- BPDU Filter：把 BPDU 过滤掉，慎用（接口下/全局）。
- Root Guard：不让别的交换机抢根桥地位。
- Loop Guard：防止阻塞口因 BPDU 丢失误转发。
