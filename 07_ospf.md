![ospf](./assets/rip.png)

```bash


r2#show ip ospf int e0/1
Ethernet0/1 is up, line protocol is up
  Internet Address 10.3.3.2/24, Area 0, Attached via Network Statement
  Process ID 1, Router ID 2.2.2.2, Network Type BROADCAST, Cost: 10
  Topology-MTID    Cost    Disabled    Shutdown      Topology Name
        0           10        no          no            Base
  Transmit Delay is 1 sec, State BDR, Priority 1
  Designated Router (ID) 1.1.1.1, Interface address 10.3.3.1
  Backup Designated router (ID) 2.2.2.2, Interface address 10.3.3.2
  Timer intervals configured, Hello 10, Dead 40, Wait 40, Retransmit 5
    oob-resync timeout 40
    Hello due in 00:00:09
  Supports Link-local Signaling (LLS)
  Cisco NSF helper support enabled
  IETF NSF helper support enabled
  Index 1/1, flood queue length 0
  Next 0x0(0)/0x0(0)
  Last flood scan length is 1, maximum is 1
  Last flood scan time is 0 msec, maximum is 0 msec
  Neighbor Count is 1, Adjacent neighbor count is 1
    Adjacent with neighbor 1.1.1.1  (Designated Router)
  Suppress hello for 0 neighbor(s)



r3#show ip ospf int s2/0
Serial2/0 is up, line protocol is up
  Internet Address 172.16.3.1/24, Area 0, Attached via Network Statement
  Process ID 1, Router ID 3.3.3.3, Network Type POINT_TO_POINT, Cost: 64
  Topology-MTID    Cost    Disabled    Shutdown      Topology Name
        0           64        no          no            Base
  Transmit Delay is 1 sec, State DOWN
  Timer intervals configured, Hello 10, Dead 40, Wait 40, Retransmit 5
    oob-resync timeout 40



r2#show ip ospf nei

Neighbor ID     Pri   State           Dead Time   Address         Interface
3.3.3.3           0   FULL/  -        00:00:34    172.16.3.1      Serial2/1
1.1.1.1           1   FULL/DR         00:00:31    10.3.3.1        Ethernet0/1




R3:
router ospf 1
 router-id 3.3.3.3
 network 0.0.0.0 255.255.255.255 area 0


或者：

!
!
!
!
interface Loopback0
 ip address 172.16.1.1 255.255.255.0
 ip ospf network point-to-point
 ip ospf 1 area 0
!
interface Loopback1
 ip address 172.16.2.1 255.255.255.224
 ip ospf 1 area 0
!
interface Serial2/0
 ip address 172.16.3.1 255.255.255.0
 ip ospf 1 area 0
 serial restart-delay 0
!
!
router ospf 1
 router-id 3.3.3.3
!
!


r3#show ip ospf database

            OSPF Router with ID (3.3.3.3) (Process ID 1)

                Router Link States (Area 0)

Link ID         ADV Router      Age         Seq#       Checksum Link count
1.1.1.1         1.1.1.1         141         0x80000005 0x0004DA 3
2.2.2.2         2.2.2.2         305         0x80000009 0x0085C0 4
3.3.3.3         3.3.3.3         163         0x80000005 0x00134C 4

                Net Link States (Area 0)

Link ID         ADV Router      Age         Seq#       Checksum
10.3.3.1        1.1.1.1         141         0x80000002 0x0034E3

```
