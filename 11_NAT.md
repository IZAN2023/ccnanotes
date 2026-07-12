![[bc4217378f33071f184b9e4ca34dcfdc.png]]

#### 重点输入（R1）
```bash
interface Ethernet0/0
 ip address 218.1.1.1 255.255.255.224
 ip nat outside
 ip virtual-reassembly in
!
interface Ethernet0/1
 ip address 10.1.1.1 255.255.255.0
 ip nat inside
 ip virtual-reassembly in
!
ip nat pool abc 218.1.1.5 218.1.1.6 netmask 255.255.255.224
ip nat inside source list 10 pool abc overload

ip nat inside source static tcp 10.1.1.12 80 interface Ethernet0/0 8080

ip nat inside source static 10.1.1.11 218.1.1.3

ip route 0.0.0.0 0.0.0.0 218.1.1.2
!
access-list 10 permit 10.1.1.0 0.0.0.255
!
```
#### 测试结果
```bash
r1#show ip nat translations 
Pro Inside global      Inside local       Outside local      Outside global
--- 218.1.1.3          10.1.1.11          ---                ---
tcp 218.1.1.1:8080     10.1.1.12:80       ---                ---
icmp 218.1.1.6:38      10.1.1.13:38       218.1.1.2:38       218.1.1.2:38
r1#show ip nat statistics   
Total active translations: 3 (1 static, 2 dynamic; 2 extended)
Peak translations: 3, occurred 00:15:23 ago
Outside interfaces:
  Ethernet0/0
Inside interfaces: 
  Ethernet0/1
Hits: 48  Misses: 0
CEF Translated packets: 48, CEF Punted packets: 0
Expired translations: 4
Dynamic mappings:
-- Inside Source
[Id: 2] access-list 10 pool abc refcount 1
 pool abc: netmask 255.255.255.224
        start 218.1.1.5 end 218.1.1.6
        type generic, total addresses 2, allocated 1 (50%), misses 0

Total doors: 0
Appl doors: 0
Normal doors: 0
Queued Packets: 0
```



## 1. 静态 NAT，1:1

**特点：**

- 固定 **1 个私网 IP - 1 个公网 IP**
- 永久映射，常用于服务器

**配置**

```bash
ip nat inside source static 10.1.1.11 218.1.1.3
```

---

## 2. 动态 PAT，多对一

**特点：**

- 多个私网 IP 共用 **1 个公网 IP**
- 靠**端口号**区分连接
- 最常见的家庭路由器方式

**配置**

```bash
access-list 10 permit 10.1.1.0 0.0.0.255
ip nat inside source list 10 interface e0/0 overload
```

---

## 3. 静态端口映射

**特点：**

- 将**公网端口**映射到**内网端口**
- 常用于发布 Web、FTP 等服务

**配置**

```bash
ip nat inside source static tcp 10.1.1.12 80 interface e0/0 8080
```

表示：

```
218.1.1.1:8080 → 10.1.1.12:80
```

---

## 4. Dynamic NAT（NAT Pool，动态 1:1）

**特点：**

- 公网 IP 来自地址池
- 每台主机动态分配一个公网 IP（仍然是 **1:1**）
- 地址池用完就无法转换

**配置**

```bash
ip nat pool abc 218.1.1.5 218.1.1.6 netmask 255.255.255.224
ip nat inside source list 10 pool abc
```

---

## 5. Dynamic PAT（Pool Overload）

**特点：**

- 多个公网 IP + 端口复用
- 多台内网主机共享地址池中的公网 IP

**配置**

```bash
ip nat inside source list 10 pool abc overload
```

---

# 常用命令

查看转换表

```bash
show ip nat translations
```

查看统计

```bash
show ip nat statistics
```

清除动态转换

```bash
clear ip nat translation *
```

---

# 区分

| 类型             | 特点                                |
| ---------------- | ----------------------------------- |
| **Static NAT**   | 固定 **1:1**                        |
| **PAT Overload** | **多:1**（共享一个公网 IP，靠端口） |
| **Static PAT**   | **端口映射**（公网端口 → 内网端口） |
| **Dynamic NAT**  | **动态 1:1**（地址池）              |
| **Dynamic PAT**  | **多:多**（地址池 + 端口复用）      |
