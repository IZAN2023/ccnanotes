# HTTP 协议基础

## 一、HTTP 协议概述

### 什么是 HTTP

HTTP（HyperText Transfer Protocol，超文本传输协议）定义了浏览器（客户端）与 Web 服务器之间如何请求和传输数据。

- 基于文本的协议，数据以纯文本格式传输
- 采用**请求（Request）/ 响应（Response）**模型
- 默认端口：80（HTTP），443（HTTPS）

### 客户端-服务器模型

```
用户输入网址
     ↓
浏览器发起 HTTP 请求  →  服务器接收请求、处理数据
                      ←  服务器返回 HTTP 响应
     ↓
浏览器渲染响应内容
```

### 无状态协议

HTTP 是**无状态**的：每次请求之间没有上下文关联，服务器不会自动记住客户端的状态。

### HTTP 版本演进

| 版本     | 发布年份 | 主要特点                                           |
| -------- | -------- | -------------------------------------------------- |
| HTTP/1.0 | 1996     | 引入头部字段，但每次请求都重新建立连接             |
| HTTP/1.1 | 1997     | 长连接（Keep-Alive）、多种请求方法，目前最广泛使用 |
| HTTP/2   | 2015     | 二进制帧格式、多路复用、头部压缩                   |
| HTTP/3   | 2022+    | 基于 UDP（QUIC），连接更快，适合移动网络           |

---

## 二、HTTP 请求（Request）

### 请求方法（`request.method`）

| 方法     | 说明                     |
| -------- | ------------------------ |
| `GET`    | 获取资源（如网页、图片） |
| `POST`   | 提交数据（如表单、JSON） |
| `PUT`    | 替换整个资源             |
| `PATCH`  | 部分更新资源             |
| `DELETE` | 删除资源                 |

### 请求头（`request.headers`）

请求头提供额外的上下文信息，例如：

| 请求头          | 含义                                      |
| --------------- | ----------------------------------------- |
| `Content-Type`  | 请求体的数据类型（如 `application/json`） |
| `Accept`        | 客户端期望的响应类型                      |
| `User-Agent`    | 客户端软件标识（浏览器信息）              |
| `Authorization` | 授权令牌（如 `Bearer <token>`）           |
| `Cookie`        | 发送给服务器的 Cookie 内容                |

### 请求 URL（`request.path` / `request.args`）

```
http://example.com:80/api/users?name=jack&age=18
                      │          └────────────── 查询参数（request.args）
                      └───────────────────────── 路径（request.path）
```

---

## 三、HTTP 响应（Response）

服务器向客户端返回的完整响应由**状态码**、**响应头**、**响应体**三部分组成。

### 常用状态码

| 分类               | 状态码 | 含义                           |
| ------------------ | ------ | ------------------------------ |
| **2xx 成功**       | 200    | OK，请求成功                   |
|                    | 201    | Created，资源已创建            |
|                    | 204    | No Content，无响应体           |
| **3xx 重定向**     | 301    | 永久重定向                     |
|                    | 302    | 临时重定向                     |
|                    | 304    | 资源未修改（缓存命中）         |
| **4xx 客户端错误** | 400    | Bad Request，参数错误          |
|                    | 401    | Unauthorized，未认证           |
|                    | 403    | Forbidden，禁止访问            |
|                    | 404    | Not Found，资源不存在          |
|                    | 405    | Method Not Allowed，方法不允许 |
| **5xx 服务端错误** | 500    | Internal Server Error          |
|                    | 502    | Bad Gateway                    |
|                    | 503    | Service Unavailable            |

### 响应头

响应头提供额外的上下文信息，例如：

| 响应头         | 含义                                      |
| -------------- | ----------------------------------------- |
| `Content-Type` | 响应体的数据类型（如 `application/json`） |
| `Server`       | 服务器类型（如 `nginx/1.27.5`）           |

---

## 四、用 uv 管理 python 项目

```bash
pip install uv           # 只需要安装一次，MacOS 要带 sudo

cd xxx                   # 进入预配好的文件夹

uv init ./               # 初始化项目
nv add flask             # 添加依赖
uv run python main.py    # 运行 python 脚本，等同于 python main.py, uv 在执行前会先做一次环境同步检查


uv sync                  # 拿到别人写好的 uv 项目，第一件事就是 sync，uv 会自动安装必须的 package
```

---

## 五、代码演示，用 flask 自建 http server

### server1：最基础的 Flask 服务器

演示 HTTP 服务器的创建、状态码设置、响应头与响应体的写入。

```python
from flask import Flask

app = Flask(__name__)

@app.route("/", methods=["GET"])
def index():
    return "<h1>首页</h1><p>Hello World</p>"

app.run(port=3000, debug=True)
```

启动服务器后，用浏览器访问 `http://localhost:3000`，观察浏览器 inspection 输出。

---

### server2：观察请求头与请求方法

```python
from flask import Flask, request

app = Flask(__name__)


@app.route("/", methods=["GET"])
def index():
    return "<h1>首页</h1><p>Hello World</p>"

@app.route("/testpage", methods=["GET", "POST"])
def testpage():
    return f"""
            <h1>测试页面</h1>
            <p><b>request.headers: </b>{dict(request.headers)}</p>
            <p><b>request.path: </b>{request.path}</p>
            <p><b>request.args: </b>{dict(request.args)}</p>
            <p><b>request.method: </b>{request.method}</p>
            """

if __name__ == "__main__":
    app.run(port=3000, debug=True)
```

启动服务器后，用浏览器和 curl 发送请求，观察响应信息。curl 是命令行 HTTP 客户端，可直接向服务器发送各类请求。

```bash
# GET 首页
curl http://localhost:3000/

# -v 显示完整请求头和响应头
curl -v http://localhost:3000/

# GET /testpage
curl "http://localhost:3000/testpage"

# GET /testpage with query
curl "http://localhost:3000/testpage?username=jack&age=19"

# POST /testpage
curl -X POST http://localhost:3000/testpage

# DELETE /testpage（应返回 405）
curl -X DELETE http://localhost:3000/testpage
```

用 vscode rest client 发送请求，观察响应信息。

```bash
### GET 首页
GET http://localhost:3000/

### GET /testpage
GET http://localhost:3000/testpage

### GET /testpage with query
GET http://localhost:3000/testpage?username=jack&age=19

### POST /testpage
POST http://localhost:3000/testpage

### DELETE /testpage（应返回 405）
DELETE http://localhost:3000/testpage
```

---

### server3：REST API

```python
from flask import Flask, request, jsonify

app = Flask(__name__)

users = [
    {"id": 1, "name": "Jack", "deposit": 100},
    {"id": 2, "name": "Tom", "deposit": 200},
    {"id": 3, "name": "Jerry", "deposit": 300},
]

# 查询所有用户
@app.route("/api/users", methods=["GET"])
def list_users():
    return jsonify({"total": len(users), "data": users})

# 新增用户
@app.route("/api/users", methods=["POST"])
def create_user():
    data = request.get_json()
    if not data or "name" not in data or "deposit" not in data:
        return jsonify({"success": False, "message": "invalid request"}), 400
    new_id = max(u["id"] for u in users) + 1 if users else 1
    new_user = {"id": new_id, "name": data["name"], "deposit": data["deposit"]}
    users.append(new_user)
    return jsonify({"success": True, "data": new_user}), 201

# 查询指定用户
@app.route("/api/users/<int:id>", methods=["GET"])
def get_user_by_id(id):
    user = next((u for u in users if u["id"] == id), None)
    if user is None:
        return jsonify({"success": False, "message": "user not found"}), 404
    return jsonify({"success": True, "data": user})

# 删除指定用户
@app.route("/api/users/<int:id>", methods=["DELETE"])
def delete_user_by_id(id):
    user = next((u for u in users if u["id"] == id), None)
    if user is None:
        return jsonify({"success": False, "message": "user not found"}), 404
    users.remove(user)
    return jsonify(), 204

# 更新指定用户
@app.route("/api/users/<int:id>", methods=["PUT", "PATCH"])
def update_user_by_id(id):
    user = next((u for u in users if u["id"] == id), None)
    if user is None:
        return jsonify({"success": False, "message": "user not found"}), 404
    data = request.get_json()
    if not data.get("deposit"):
        return jsonify({"success": False, "message": "invalid request"}), 400
    user.update({"deposit": data["deposit"]})
    return jsonify({"success": True, "data": user})

if __name__ == "__main__":
    app.run(port=3000, debug=True)
```

用 curl 发送请求，观察响应信息。

```bash
# GET /api/users
curl "http://localhost:3000/api/users"

# GET /api/users/1
curl "http://localhost:3000/api/users/1"

# GET GET /api/users/999
curl "http://localhost:3000/api/users/999"

# DELETE /api/users/3
curl "http://localhost:3000/api/users/3"

# CREATE /api/users
curl -X POST http://localhost:3000/api/users \
 -H "Content-Type: application/json" \
 -d '{"name": "John Doe", "deposit": 5000}'

# PUT UPDATE /api/users/2
curl -X PUT http://localhost:3000/api/users/2 \
 -H "Content-Type: application/json" \
 -d '{"deposit": 2000}'
```

用 vscode rest client 发送请求，观察响应信息。

```bash
### GET /api/users
GET http://localhost:3000/api/users

### GET /api/users/1
GET http://localhost:3000/api/users/1

### GET /api/users/999
GET http://localhost:3000/api/users/999

### DELETE /api/users/3
DELETE http://localhost:3000/api/users/3

### CREATE /api/users
POST http://localhost:3000/api/users
Content-Type: application/json

{
  "name": "John Doe",
  "deposit": 5000
}

### UPDATE /api/users/2
PUT http://localhost:3000/api/users/2
Content-Type: application/json

{
  "deposit": 3000
}
```
