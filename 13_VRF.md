
## 1. 什么是 VRF？

**VRF（Virtual Routing and Forwarding）** 是一种**虚拟路由技术**，可以让**一台路由器拥有多个彼此独立的路由表。

每个 VRF 都像是一台**独立的虚拟路由器**：

- 有自己的 Routing Table
    
- 有自己的接口
    
- 有自己的路由协议
    
- 不会与其他 VRF 的路由互相学习
    

---

## 2. 为什么需要 VRF？

如果多个网络使用**相同的 IP 地址**，普通路由器无法区分。

例如：

```
Company A
192.168.1.0/24

Company B
192.168.1.0/24
```

普通路由：

```
Routing Table

192.168.1.0/24
↑
不知道属于哪个公司
```

VRF：

```
VRF-A
192.168.1.0/24

VRF-B
192.168.1.0/24
```

互不影响。


---

# 3. VRF 与 VLAN 的区别

|VLAN|VRF|
|---|---|
|二层隔离|三层隔离|
|MAC 地址|IP Routing|
|Broadcast Domain|Routing Domain|
|Switch 使用|Router/L3 Switch 使用|

简单理解：

```
VLAN
隔离交换

VRF
隔离路由
```

---

# 4. 基本配置案例

---

```
vrf definition new
 !
 address-family ipv4
 exit-address-family
!
!
!
!
interface Loopback1
 vrf forwarding new
 ip address 1.1.1.1 255.255.255.0
!
interface Loopback2
 vrf forwarding new
 ip address 10.1.1.1 255.255.255.0
!
interface Ethernet0/0
 ip address 10.1.1.1 255.255.255.0
!
interface Ethernet0/2
 vrf forwarding new
 ip address 10.2.2.1 255.255.255.0
!
interface Serial2/0
 ip address 10.2.2.1 255.255.255.0

```

---

# 5. 查看 VRF

查看所有 VRF：

```
show vrf
```

查看 VRF 路由表：

```
show ip route vrf new
```

查看接口：

```
show ip vrf interfaces
```

---

# 6. 在 VRF 中 Ping

普通：

```
ping ...
```

VRF：

```
ping vrf new ...
```

---

# 7. VRF 常见应用

### ISP（最常见）

```
Internet Provider

A
↓

VRF-A

B
↓

VRF-B
```

