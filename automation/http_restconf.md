# restconf

restconf 是一种基于 HTTP 的网络管理协议。它提供 Web 友好的 RESTful API（数据格式通常是 JSON）。你可以通过标准的操作（如获取、创建、修改和删除），管理网络设备。

netconf 是一种基于 SSH 的网络管理协议。它使用 XML 来传输数据，允许网络管理员通过脚本或程序远程安全地配置设备、读取状态或备份数据。

## 路由器配置

```bash
hostname c8kv
!
aaa new-model
!
aaa authentication login default local
aaa authorization exec default local
!
username admin privilege 15 password 0 Cisco123
!
enable secret 0 Cisco123
!
interface GigabitEthernet1
 ip address 10.1.16.25 255.255.255.0
!
interface Loopback0
 ip address 1.1.1.1 255.255.255.255
!
ip route 0.0.0.0 0.0.0.0 10.1.16.1
!
ip http server
ip http authentication local
ip http secure-server
!
netconf-yang
restconf
```

---

## 使用curl测试路由器rest接口

```bash
# 获取hostname
curl -k -u admin:Cisco123 -H "Accept: application/yang-data+json" https://10.1.16.25/restconf/data/Cisco-IOS-XE-native:native/hostname

# 获取接口配置
curl -k -u admin:Cisco123 -H "Accept: application/yang-data+json" https://10.1.16.25/restconf/data/Cisco-IOS-XE-native:native/interface/Loopback

# 修改hostname
curl -k -X PATCH "https://10.1.16.25/restconf/data/Cisco-IOS-XE-native:native/hostname" \
 -u admin:Cisco123 \
 -H "Content-Type: application/yang-data+json" \
 -H "Accept: application/yang-data+json" \
 -d '{"hostname": "newC8KName"}'
```

---

## 用 uv 管理 python 项目

```bash
pip install uv           # 只需要安装一次，MacOS 要带 sudo

cd xxx                   # 进入预配好的文件夹

uv init ./               # 初始化项目
nv add requests          # 添加依赖，requests 是用于在 python 代码里发起 http 请求的 package
uv run python main.py    # 运行 python 脚本，等同于 python main.py, uv 在执行前会先做一次环境同步检查


uv sync                  # 拿到别人写好的 uv 项目，第一件事就是 sync，uv 会自动安装必须的 package
```

## 用python脚本访问路由器的 rest api

```python
import requests
import json

ip_address = "10.1.16.25"
username = "admin"
password = "Cisco123"
headers = {
    'Content-Type': 'application/yang-data+json',
    'Accept': 'application/yang-data+json',
}

# 获取loopback接口的信息
def get_loopback_info():
    url = f"https://{ip_address}/restconf/data/Cisco-IOS-XE-native:native/interface/Loopback"
    response = requests.request("get", url, auth=(username, password), headers=headers, data={}, verify=False)
    print(response.json())

# 修改hostname
def modify_hostname(new_hostname):
    url = f"https://{ip_address}/restconf/data/Cisco-IOS-XE-native:native/hostname"
    payload = json.dumps({"hostname": f"{new_hostname}"})
    response = requests.request("put", url, auth=(username, password), headers=headers, data=payload, verify=False)
    print(response)


def main():
    get_loopback_info()
    # modify_hostname("newC8K123")

if __name__ == "__main__":
    main()
```
