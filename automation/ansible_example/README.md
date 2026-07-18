# Ansible

## 演示步骤

```bash
# ad-hoc：批量到三台服务器上执行 `ip address show ens160` 命令，并打印输出
ansible webservers -i inventory.ini -m shell -a "ip address show ens160"


# ad-hoc：批量到三台服务器上执行 `df -h /` 命令，并打印输出
ansible webservers -i inventory.ini -m shell -a "df -h /"


# playbook：批量到三台服务器上安装 nginx，并写入测试页面
ansible-playbook -i inventory.ini enableweb.yml


# playbook：批量到三台服务器上卸载 nginx，并删除测试页面
ansible-playbook -i inventory.ini disableweb.yml


# playbook：用 Ansible 配置路由器
ansible-playbook -i inventory.ini router_configure.yml


# playbook：用 Ansible 配置路由器-删配置
ansible-playbook -i inventory.ini router_unconfigure.yml
```

## 批量到三台服务器上执行 `ip address show ens160` 命令，并打印输出

```bash
expert@desktop20:~/Documents/ccna/ansible_example$ ansible webservers -i inventory.ini -m shell -a "ip address show ens160"

node3 | CHANGED | rc=0 >>
2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:a7:ec:47 brd ff:ff:ff:ff:ff:ff
    altname enp3s0
    inet 10.1.16.33/24 brd 10.1.16.255 scope global ens160
       valid_lft forever preferred_lft forever
    inet6 fe80::250:56ff:fea7:ec47/64 scope link
       valid_lft forever preferred_lft forever
node2 | CHANGED | rc=0 >>
2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:a7:4f:3b brd ff:ff:ff:ff:ff:ff
    altname enp3s0
    inet 10.1.16.32/24 brd 10.1.16.255 scope global ens160
       valid_lft forever preferred_lft forever
    inet6 fe80::250:56ff:fea7:4f3b/64 scope link
       valid_lft forever preferred_lft forever
node1 | CHANGED | rc=0 >>
2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:50:56:a7:89:4c brd ff:ff:ff:ff:ff:ff
    altname enp3s0
    inet 10.1.16.31/24 brd 10.1.16.255 scope global ens160
       valid_lft forever preferred_lft forever
    inet6 fe80::250:56ff:fea7:894c/64 scope link
       valid_lft forever preferred_lft forever

```

## 批量到三台服务器上执行 `df -h /` 命令，并打印输出

```bash
expert@desktop20:~/Documents/ccna/ansible_example$ ansible webservers -i inventory.ini -m shell -a "df -h /"

node3 | CHANGED | rc=0 >>
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv   78G   14G   60G  20% /
node2 | CHANGED | rc=0 >>
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv   78G   15G   60G  20% /
node1 | CHANGED | rc=0 >>
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv   78G   14G   60G  19% /

```

## 批量到三台服务器上安装 nginx，并写入测试页面

```bash
expert@desktop20:~/Documents/ccna/ansible_example$ ansible-playbook -i inventory.ini enableweb.yml

PLAY [配置三台机器的 Web 服务] ***********************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************
ok: [node3]
ok: [node1]
ok: [node2]

TASK [安装 nginx] ************************************************************************************************************************************************************
changed: [node3]
changed: [node1]
changed: [node2]

TASK [确保 nginx 服务已启动并开机自启] ***************************************************************************************************************************************
ok: [node3]
ok: [node2]
ok: [node1]

TASK [写入测试首页，标明是哪台机器] ******************************************************************************************************************************************
changed: [node3]
changed: [node1]
changed: [node2]

PLAY RECAP *******************************************************************************************************************************************************************
node1                      : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
node2                      : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
node3                      : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## 批量到三台服务器上卸载 nginx，并删除测试页面

```bash
expert@desktop20:~/Documents/ccna/ansible_example$ ansible-playbook -i inventory.ini disableweb.yml

PLAY [关闭三台机器的 Web 服务] ***********************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************************
ok: [node3]
ok: [node1]
ok: [node2]

TASK [彻底卸载 nginx] ********************************************************************************************************************************************************
changed: [node3]
changed: [node1]
changed: [node2]

TASK [删除测试首页] **********************************************************************************************************************************************************
changed: [node2]
changed: [node1]
changed: [node3]

PLAY RECAP *******************************************************************************************************************************************************************
node1                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
node2                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
node3                      : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

## 用 Ansible 配置路由器

```bash
# 为设备打上配置
expert@desktop20:~/Documents/ccna/ansible_example$ ansible-playbook -i inventory.ini router_configure.yml

PLAY [配置 IOS-XE 路由器] ******************************************************************************************************************************************************************

TASK [配置 hostname] ***********************************************************************************************************************************************************************
[WARNING]: To ensure idempotency and correct diff the input configuration lines should be similar to how they appear if present in the running configuration on device
changed: [R1]

TASK [配置 Loopback10 接口地址] ************************************************************************************************************************************************************
changed: [R1]

TASK [配置 NTP 服务器] *********************************************************************************************************************************************************************
changed: [R1]

TASK [保存配置到 startup-config] ***********************************************************************************************************************************************************
changed: [R1]

PLAY RECAP *********************************************************************************************************************************************************************************
R1                         : ok=4    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0


# 删除刚才打上的配置
expert@desktop20:~/Documents/ccna/ansible_example$ ansible-playbook -i inventory.ini router_unconfigure.yml

PLAY [撤销 IOS-XE 路由器配置] **************************************************************************************************************************************************************

TASK [删除 Loopback10 接口] ****************************************************************************************************************************************************************
[WARNING]: To ensure idempotency and correct diff the input configuration lines should be similar to how they appear if present in the running configuration on device
changed: [R1]

TASK [删除 NTP 服务器配置] *****************************************************************************************************************************************************************
changed: [R1]

TASK [恢复默认 hostname] *******************************************************************************************************************************************************************
changed: [R1]

TASK [保存配置到 startup-config] ***********************************************************************************************************************************************************
changed: [R1]

PLAY RECAP *********************************************************************************************************************************************************************************
R1                         : ok=4    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
