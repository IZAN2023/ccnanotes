## GRE隧道（IPinIP）

![ip in ip](./gre_ip_in_ip_ipsec.png)

```bash
r1#sh run
!
hostname r1
!
!
interface Tunnel0
 ip address 172.16.1.1 255.255.255.0
 tunnel source Ethernet0/0
 tunnel mode gre ip   (默认值，show run不显示)
 tunnel destination 58.1.1.1
!
interface Ethernet0/0
 ip address 218.1.1.1 255.255.255.0
!
interface Ethernet0/1
 ip address 10.1.1.1 255.255.255.0
!
ip route 0.0.0.0 0.0.0.0 218.1.1.2
ip route 10.2.2.0 255.255.255.0 Tunnel0
!

####

r2#sh run
!
hostname r2
!
!
interface Tunnel0
 ip address 172.16.1.2 255.255.255.0
 tunnel source Ethernet0/0
  tunnel mode gre ip   (默认值，show run不显示)
 tunnel destination 218.1.1.1
!
interface Ethernet0/0
 ip address 58.1.1.1 255.255.255.0
!
interface Ethernet0/1
 ip address 10.2.2.1 255.255.255.0
!
ip route 0.0.0.0 0.0.0.0 58.1.1.2
ip route 10.1.1.0 255.255.255.0 Tunnel0
!

####

r3#sh run
!
hostname r3
!
!
interface Ethernet0/0
 ip address 218.1.1.2 255.255.255.0
!
interface Ethernet0/1
 ip address 58.1.1.2 255.255.255.0
!
```

在R1与R3的链路上抓包：

![ip in ip pcap](./gre_ip_in_ip_pcap.png)

```
10.1.1.2
    │
    ▼
【R1 通过静态路由得知要走tunnel 0，将 IP 包头和 payload 原封不动，加上GRE头，并且打上新的包头（从隧道起点218.1.1.1到终点58.1.1.1）】
    │
  【R3 只能看到外层包头218.1.1.1 → 58.1.1.1，往下一跳转发】
    │
【R2 解析外层IP包头，解析GRE头，得知内部还有IP头，看到内层包头10.1.1.2 → 10.2.2.2】
    │
    ▼
10.2.2.2
```

---

## GRE隧道（IPinIPv6）

![ip in ipv6](./gre_ipv6.png)

```bash
r1#sh run
!
hostname r1
!
ipv6 unicast-routing
!
!
interface Tunnel1
ip address 172.17.1.1 255.255.255.0
tunnel source Ethernet0/0
tunnel mode gre ipv6
tunnel destination 2001:DB8:2:2::1
!
interface Ethernet0/0
ipv6 address 2001:DB8:1:1::1/64
!
interface Ethernet0/1
ip address 10.1.1.1 255.255.255.0
!
ip route 10.2.2.0 255.255.255.0 Tunnel1
!
ipv6 route ::/0 2001:DB8:1:1::2

####

r2#sh run
!
hostname r2
!
ipv6 unicast-routing
!
!
interface Tunnel1
ip address 172.17.1.2 255.255.255.0
tunnel source Ethernet0/0
tunnel mode gre ipv6
tunnel destination 2001:DB8:1:1::1
!
interface Ethernet0/0
ipv6 address 2001:DB8:2:2::1/64
!
interface Ethernet0/1
ip address 10.2.2.1 255.255.255.0
!
ip route 10.1.1.0 255.255.255.0 Tunnel1
!
ipv6 route ::/0 2001:DB8:2:2::2

####

r3#sh run
!
hostname r3
!
ipv6 unicast-routing
!
!
interface Ethernet0/0
ipv6 address 2001:DB8:1:1::2/64
!
interface Ethernet0/1
ipv6 address 2001:DB8:2:2::2/64
!
```

在R1与R3的链路上抓包：

![gre ip in ipv6 pcap](./gre_ip_in_ip6_pcap.png)

```
10.1.1.2
    │
    ▼
【R1 通过静态路由得知要走tunnel 0，将 IP 包头和 payload 原封不动，加上GRE头，并且打上新的ipv6包头】
    │
  【R3 只能看到外层IPv6包头，往下一跳转发】
    │
【R2 解析外层IPv6包头，解析GRE头，得知内部还有IP头，看到内层包头10.1.1.2 → 10.2.2.2】
    │
    ▼
10.2.2.2
```
