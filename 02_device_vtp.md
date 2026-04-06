## 交换机工作原理

交换机处理一个以太网帧时，可以记成下面这个流程：

```text
Receive frame
  |
  v
[if src MAC exists in MAC table?]
  | yes -----------------------------> refresh aging timer
  |
  | no
  v
learn (src MAC -> ingress port)
  |
  v
[is dst MAC broadcast / multicast / unknown unicast?]
  | yes -----------------------------> flood to all ports except ingress
  |
  | no (known unicast)
  v
[is ingress port == dst MAC mapped port?]
  | yes -----------------------------> filter (drop)
  |
  | no
  v
forward to dst mapped port
```

一句话总结：

- 交换机先学源 MAC，再根据目标 MAC 决定 flood、filter 或 forward。
- 交换机工作在二层，核心依据是 MAC 地址表（CAM 表）。

## 路由器工作原理

```text
HostA (10.1.1.2 / 11-11-11-11-11-11)
                 |
                 |
Eth0 (10.1.1.1 / 33-33-33-33-33-33) [Router] Eth1 (172.16.1.1 / 44-44-44-44-44-44)
                                                             |
                                                             |
                                            HostB (172.16.1.2 / 22-22-22-22-22-22)

HostA -> Router(Eth0)
	Src IP  : 10.1.1.2
	Dst IP  : 172.16.1.2
	Src MAC : 11-11-11-11-11-11
	Dst MAC : 33-33-33-33-33-33   (Eth0 MAC)

Router(Eth1) -> HostB
	Src IP  : 10.1.1.2
	Dst IP  : 172.16.1.2
	Src MAC : 44-44-44-44-44-44   (Eth1 MAC)
	Dst MAC : 22-22-22-22-22-22
```

结论：路由转发时，IP 保持端到端不变，MAC 按下一跳重写。

## broadcast domain and collision domain

| Device | OSI | Collision Domain                           | Broadcast Domain                           | Key Point                                                  |
| ------ | --- | ------------------------------------------ | ------------------------------------------ | ---------------------------------------------------------- |
| Hub    | L1  | All ports share 1 collision domain         | All ports share 1 broadcast domain         | Bit repeater, no MAC learning                              |
| Switch | L2  | Each port is 1 collision domain            | One switched LAN is 1 broadcast domain     | Splits collision domains, does not split broadcast domains |
| Router | L3  | Each interface is its own collision domain | Each interface is its own broadcast domain | Stops L2 broadcast between interfaces                      |

Quick rules:

- Hub with N ports: collision domain = 1, broadcast domain = 1.
- Switch with N active ports in one switched LAN: collision domain = N, broadcast domain = 1.
- Router with N interfaces: collision domain = N, broadcast domain = N.

Exam memory line:

- Hub shares everything, Switch splits collisions, Router splits broadcasts.

注意（当前讨论的范围有一定局限性）:

- Switch behavior above is described as basic L2 switching only.（没有考虑VLAN）
- Router behavior above is described without NAT or other special features.（没有考虑NAT等特属行为）

## vlan配置

```bash
# 设置vtp server - 默认就是server mode
s2(config)#vtp domain nlc
s2(config)#vtp password cisco

# 设置vtp client
s1(config)#vtp domain nlc
s1(config)#vtp password cisco
s1(config)#vtp mode client

# 设置vtp transparent
s3(config)#vtp domain nlc
s3(config)#vtp password cisco
s3(config)#vtp mode transparent

# 检查vtp状态
s2#show vtp status
VTP Version capable             : 1 to 3
VTP version running             : 1
VTP Domain Name                 : nlc
VTP Pruning Mode                : Disabled
VTP Traps Generation            : Disabled
Device ID                       : aabb.cc00.1b00
Configuration last modified by 0.0.0.0 at 4-4-26 20:40:52
Local updater ID is 0.0.0.0 (no valid interface found)

Feature VLAN:
--------------
VTP Operating Mode                : Server
Maximum VLANs supported locally   : 1005
Number of existing VLANs          : 7
Configuration Revision            : 5
MD5 digest                        : 0x02 0xD9 0x22 0xDC 0x7D 0x35 0x0B 0x86
                                    0x44 0x4B 0x39 0x73 0x91 0x99 0x88 0xCF

s2#show vtp password
VTP Password: cisco


# 创建vlan
s2(config)#vlan 2
s2(config-vlan)#name sales
s2(config-vlan)#exit
s2(config)#vlan 3
s2(config-vlan)#name hr
s2(config-vlan)#exit
s2(config)#


# 将接口配置为trunk
s2(config)#interface e0/0
s2(config-if)#switchport trunk encapsulation dot1q
s2(config-if)#switchport mode trunk
s2(config-if)#exit

# 查看trunk接口
s2#show interface trunk
Port        Mode             Encapsulation  Status        Native vlan
Et0/0       on               802.1q         trunking      1
Et0/1       on               802.1q         trunking      1

# 将接口配置为access，并设定access vlan
s1(config)#interface e3/3
s1(config-if)#switchport mode access
s1(config-if)#switchport access vlan 2
s1(config-if)#exit

s1(config)#interface range e3/0 - 2
s1(config-if-range)#switchport mode access
s1(config-if-range)#switchport access vlan 2
s1(config-if-range)#exit

s1(config)#interface range e1/0 - 2, e2/0 - 2
s1(config-if-range)#switchport mode access
s1(config-if-range)#switchport access vlan 3
s1(config-if-range)#exit

# 检查vlan分配
s1(config)#do sh vlan

VLAN Name                             Status    Ports
---- -------------------------------- --------- -------------------------------
1    default                          active    Et0/1, Et0/2, Et0/3
2    sales                            active    Et3/0, Et3/1, Et3/2, Et3/3
3    hr                               active    Et1/0, Et1/1, Et1/2, Et1/3
                                                Et2/0, Et2/1, Et2/2, Et2/3

```


vlan prunning
```bash
s1(config)#int e0/0 
s1(config-if)#sw tr allowed vl remove 20
          
s1(config-if)#do show run int e0/0
interface Ethernet0/0
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 1-19,21-4094
 switchport mode trunk
 duplex auto
end


s1(config-if)#switchport trunk allowed vlan 1,30,10


s1(config-if)#do show run int e0/0
interface Ethernet0/0
 switchport trunk encapsulation dot1q
 switchport trunk allowed vlan 1,10,30
 switchport mode trunk
 duplex auto
end
```