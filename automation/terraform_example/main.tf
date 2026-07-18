# Provider 是 Terraform 用来对接某一类具体资源的插件，负责把 HCL 里声明的资源翻译成对应平台的 API 调用
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 4.5"
    }
  }
}

provider "docker" {
  # 不写 host 时，默认连本机的 /var/run/docker.sock 
  # 如果想让 tf 去操作其他 docker 主机，需要指定远程连接，例如：host = "ssh://user@docker-host:22"
  # 只能走密钥认证，不支持密码认证。
}

# 声明"我要哪个 docker 镜像"
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true # 销毁容器时不删本地镜像，方便重复实验
}

variable "containers" {
  default = {
    web1 = { port = 8081 }
    web2 = { port = 8082 }
    web3 = { port = 8083 }
  }
}

resource "docker_container" "web" {
  for_each = var.containers
  name  = each.key
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = each.value.port
  }

  # 上传测试首页
  upload {
    content = "<h1>Hello World from ${each.key}</h1>"
    file    = "/usr/share/nginx/html/index.html"
  }
}

output "container_urls" {
  description = "打印三个容器各自的访问地址"
  value       = { for name, c in var.containers : name => "http://localhost:${c.port}" }
}
