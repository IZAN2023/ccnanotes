# enable secret是如何计算出来的

## 先看下如何计算哈希：

```bash
# https://www.python.org/downloads/release/python-3146/  官网显示 "Windows installer (64-bit)" 的 SHA-256 checksum 为：
# 14b3e9a710a3fcf0bd9b55ab6b60412bd91227563f813fc49040cabc0209e0bd

# 将 pypython-3.14.6-amd64.exe 下载到本地，在 gitbash 中运行 sha256sum
❯ sha256sum.exe pypython-3.14.6-amd64.exe
14b3e9a710a3fcf0bd9b55ab6b60412bd91227563f813fc49040cabc0209e0bd *python-3.14.6-amd64.exe

# 可以看到下载下来的文件的哈希值和官网一致，因此可以断定这个文件和官网保持一致，传输过程中没有损坏。
```

## 在 “I86BI_LINUX-ADVENTERPRISE-M Version 15.1”中设置enable secret：

```bash
# 配置 enable secret
r1(config)# enable secret cisco

# show run 检查
r1(config)# do sh run | include enable
enable secret 4 tnhtc92DXBhelxjYk8LWJrPV36S2i4ntXrpb4RFmfqY
# 4 代表 type 4，这一代 IOS 实现有 bug，实际只做了一次无盐 SHA256，因此 Cisco 后来直接废弃 type 4、改用 type 8/9。
```

## 在 windows 上复现enable secret是如何算出来的（用 gitbash 运行）

```bash
# 先算出sha哈希（不可逆）
❯ echo -n "cisco" | sha256sum
e73b79a0b10f8cdb6ac7dbe4c0a5e25776e1148784b86cf98f7d6719d472af69 *-


# 转成大写 - tr 'a-z' 'A-Z' 意思是a转成A，b转成B...z转成Z （可逆）
❯ echo "e73b79a0b10f8cdb6ac7dbe4c0a5e25776e1148784b86cf98f7d6719d472af69" | tr 'a-z' 'A-Z'
E73B79A0B10F8CDB6AC7DBE4C0A5E25776E1148784B86CF98F7D6719D472AF69


# 把上面得到的十六进制文本解码 还原成原始字节，再把这些字节编码成base64（可逆）
❯ echo "E73B79A0B10F8CDB6AC7DBE4C0A5E25776E1148784B86CF98F7D6719D472AF69" | basenc --base16 -d | openssl base64
5zt5oLEPjNtqx9vkwKXiV3bhFIeEuGz5j31nGdRyr2k=


# 把上面这段标准base64文本，逐字符换成Cisco自己的字母表（可逆）
❯ echo "5zt5oLEPjNtqx9vkwKXiV3bhFIeEuGz5j31nGdRyr2k=" | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' './0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
tnhtc92DXBhelxjYk8LWJrPV36S2i4ntXrpb4RFmfqY=

# 得到和show run一样的enable secret
```
