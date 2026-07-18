## aaa(authentication, authorization, accounting)

```bash
# 拓扑图
[Telnet/SSH Client] ------telnet/SSH------> [IOS-XE 10.1.16.27]
```

### Cisco IOS 传统vty配置

```bash
enable secret cisco

# 在vty上启用login认证，启用telnet和ssh，并且设置访问密码
line vty 0 4
  login
  transport input telnet ssh
  password cisco
```

### Cisco IOS aaa 配置

```bash
# 配置本地用户名和密码，设置权限 15
username admin privilege 15 password cisco
enable secret cisco

# 启用 aaa
aaa new-model

# 设置默认的认证和授权方法，先试试只设置“认证”，然后再试试同时设置“认证和授权”
aaa authentication login default local
aaa authorization exec default local

# vty下无需修改任何配置，默认会采用default方法进行认证和授权
```

### 在 windows/macos 上使用 telnet 和 ssh 进行登录测试。

```bash
telnet 10.1.16.27

ssh admin@10.1.16.27
```

## 使用radius server 进行 aaa 认证

```bash
# 拓扑图
[TelnetSSH Client] ------telnet/SSH------> [IOS-XE 10.1.16.27] -----RADIUS 1812/1813-----> [FreeRADIUS 10.1.16.61]
#                                        NAS(network access server)                           radius server
```

### freeRadius 安装及设置：

```bash
sudo apt update
sudo apt install freeradius -y

# 查看freeradius运行状态
systemctl status freeradius

# 关闭freeradius
sudo systemctl stop freeradius



# 编辑 /etc/freeradius/3.0/clients.conf 末尾添加 NAS：
vim /etc/freeradius/3.0/clients.conf
# 添加如下配置
client c8kv {
       ipaddr = 10.1.16.27
       proto = *
       secret = Cisco123
       nas_type = cisco
}

# 编辑 /etc/freeradius/3.0/users 添加用户：
vim /etc/freeradius/3.0/users
# 添加如下配置：
bob Cleartext-Password := "hello"
    Service-Type = Login-User,
    cisco-avpair = "shell:priv-lvl=15"




# 用debug模式启动freeradius：
freeradius -X
# ctrl-c退出
```

### Cisco IOS aaa 配置

```bash
# 保持本地用户名和密码
username admin password cisco
enable secret cisco

# 启用 aaa
aaa new-model

# 配置 radius 服务器
radius server fr
  address ipv4 10.1.16.61 auth-port 1812 acct-port 1813
  key Cisco123

aaa group server radius fr-group
  server name fr

# 保持默认的认证和授权方法
aaa authentication login default local
aaa authorization exec default local

# 设置自定义的认证和授权方法，local办法作为后备手段，以防止radius服务器联系不上时，无法登录路由器
aaa authorization exec fr-exec group fr-group local
aaa authentication login fr-login group fr-group local
aaa accounting exec fr-accounting start-stop group fr-group  

# 在vty 接口上绑定自定义的认证和授权办法
line vty 0 4
 authorization exec fr-exec
 accounting exec fr-accounting                                           
 login authentication fr-login
 transport input telnet ssh
```
