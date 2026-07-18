# Terraform 演示

任务：在一台已经装好 Docker 和 terraform 的机器上起几个 nginx 容器，用 terraform 管理容器的生命周期。

## 实验一

```bash
terraform init
terraform plan
terraform apply
```

跑完 `apply` 后：

```bash
curl http://localhost:8081
curl http://localhost:8082
curl http://localhost:8083

docker ps
```

应该看到三个容器各自不同的 "Hello World from webX"。

## 实验二：扩容

修改 variables，加入第四个容器

```tf
variable "containers" {
  default = {
    web1 = { port = 8081 }
    web2 = { port = 8082 }
    web3 = { port = 8083 }
    web4 = { port = 8084 }
  }
}
```

执行terraform

```bash
terraform plan
terraform apply
```

## 实验三：缩容

修改 variables，还原为三个容器

```tf
variable "containers" {
  default = {
    web1 = { port = 8081 }
    web2 = { port = 8082 }
    web3 = { port = 8083 }
  }
}
```

执行terraform

```bash
terraform plan
terraform apply
```

## 实验四：摧毁部署

```bash
terraform destroy
```

## 实验输出

```bash
############################################
# 第一步：部署三个容器
############################################


expert@desktop20:~/Documents/ccna/terraform_example$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # docker_container.web["web1"] will be created
  + resource "docker_container" "web" {
      + attach                                      = false
      + bridge                                      = (known after apply)
      + command                                     = (known after apply)
      + container_logs                              = (known after apply)
      + container_read_refresh_timeout_milliseconds = 15000
      + entrypoint                                  = (known after apply)
      + env                                         = (known after apply)
      + exit_code                                   = (known after apply)
      + hostname                                    = (known after apply)
      + id                                          = (known after apply)
      + image                                       = (known after apply)
      + init                                        = (known after apply)
      + ipc_mode                                    = (known after apply)
      + log_driver                                  = (known after apply)
      + logs                                        = false
      + memory_reservation                          = 0
      + must_run                                    = true
      + name                                        = "web1"
      + network_data                                = (known after apply)
      + network_mode                                = "bridge"
      + platform                                    = (known after apply)
      + read_only                                   = false
      + remove_volumes                              = true
      + restart                                     = "no"
      + rm                                          = false
      + runtime                                     = (known after apply)
      + security_opts                               = (known after apply)
      + shm_size                                    = (known after apply)
      + start                                       = true
      + stdin_open                                  = false
      + stop_signal                                 = (known after apply)
      + stop_timeout                                = (known after apply)
      + tty                                         = false
      + wait                                        = false
      + wait_timeout                                = 60

      + healthcheck (known after apply)

      + labels (known after apply)

      + ports {
          + external = 8081
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }

      + upload {
          + content        = "<h1>Hello World from web1</h1>"
          + executable     = false
          + file           = "/usr/share/nginx/html/index.html"
            # (4 unchanged attributes hidden)
        }
    }

  # docker_container.web["web2"] will be created
  + resource "docker_container" "web" {
      + attach                                      = false
      + bridge                                      = (known after apply)
      + command                                     = (known after apply)
      + container_logs                              = (known after apply)
      + container_read_refresh_timeout_milliseconds = 15000
      + entrypoint                                  = (known after apply)
      + env                                         = (known after apply)
      + exit_code                                   = (known after apply)
      + hostname                                    = (known after apply)
      + id                                          = (known after apply)
      + image                                       = (known after apply)
      + init                                        = (known after apply)
      + ipc_mode                                    = (known after apply)
      + log_driver                                  = (known after apply)
      + logs                                        = false
      + memory_reservation                          = 0
      + must_run                                    = true
      + name                                        = "web2"
      + network_data                                = (known after apply)
      + network_mode                                = "bridge"
      + platform                                    = (known after apply)
      + read_only                                   = false
      + remove_volumes                              = true
      + restart                                     = "no"
      + rm                                          = false
      + runtime                                     = (known after apply)
      + security_opts                               = (known after apply)
      + shm_size                                    = (known after apply)
      + start                                       = true
      + stdin_open                                  = false
      + stop_signal                                 = (known after apply)
      + stop_timeout                                = (known after apply)
      + tty                                         = false
      + wait                                        = false
      + wait_timeout                                = 60

      + healthcheck (known after apply)

      + labels (known after apply)

      + ports {
          + external = 8082
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }

      + upload {
          + content        = "<h1>Hello World from web2</h1>"
          + executable     = false
          + file           = "/usr/share/nginx/html/index.html"
            # (4 unchanged attributes hidden)
        }
    }

  # docker_container.web["web3"] will be created
  + resource "docker_container" "web" {
      + attach                                      = false
      + bridge                                      = (known after apply)
      + command                                     = (known after apply)
      + container_logs                              = (known after apply)
      + container_read_refresh_timeout_milliseconds = 15000
      + entrypoint                                  = (known after apply)
      + env                                         = (known after apply)
      + exit_code                                   = (known after apply)
      + hostname                                    = (known after apply)
      + id                                          = (known after apply)
      + image                                       = (known after apply)
      + init                                        = (known after apply)
      + ipc_mode                                    = (known after apply)
      + log_driver                                  = (known after apply)
      + logs                                        = false
      + memory_reservation                          = 0
      + must_run                                    = true
      + name                                        = "web3"
      + network_data                                = (known after apply)
      + network_mode                                = "bridge"
      + platform                                    = (known after apply)
      + read_only                                   = false
      + remove_volumes                              = true
      + restart                                     = "no"
      + rm                                          = false
      + runtime                                     = (known after apply)
      + security_opts                               = (known after apply)
      + shm_size                                    = (known after apply)
      + start                                       = true
      + stdin_open                                  = false
      + stop_signal                                 = (known after apply)
      + stop_timeout                                = (known after apply)
      + tty                                         = false
      + wait                                        = false
      + wait_timeout                                = 60

      + healthcheck (known after apply)

      + labels (known after apply)

      + ports {
          + external = 8083
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }

      + upload {
          + content        = "<h1>Hello World from web3</h1>"
          + executable     = false
          + file           = "/usr/share/nginx/html/index.html"
            # (4 unchanged attributes hidden)
        }
    }

  # docker_image.nginx will be created
  + resource "docker_image" "nginx" {
      + id           = (known after apply)
      + image_id     = (known after apply)
      + keep_locally = true
      + name         = "nginx:latest"
      + repo_digest  = (known after apply)
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + container_urls = {
      + web1 = "http://localhost:8081"
      + web2 = "http://localhost:8082"
      + web3 = "http://localhost:8083"
    }

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

docker_image.nginx: Creating...
docker_image.nginx: Creation complete after 0s [id=sha256:4e5db4761e0ff445f7fd29aad680ad28e8abf7d204895557f145d65535abcc1cnginx:latest]
docker_container.web["web3"]: Creating...
docker_container.web["web1"]: Creating...
docker_container.web["web2"]: Creating...
docker_container.web["web2"]: Creation complete after 2s [id=9c1ba4a7d2767d99b3e930fe81595a2a2226598e898c221908466f7dd3f3597b]
docker_container.web["web1"]: Creation complete after 2s [id=a4f2557e03c286d574c26c5b7b1dd65a2acc0fa9415ed0a7cbe18d9a5cfb26e5]
docker_container.web["web3"]: Creation complete after 2s [id=6d0fd8910184107c4c6aa81673a876e069de72ce08ae240bf87889706379c161]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

container_urls = {
  "web1" = "http://localhost:8081"
  "web2" = "http://localhost:8082"
  "web3" = "http://localhost:8083"
}


# 测试访问
expert@desktop20:~/Documents/ccna/terraform_example$ curl http://localhost:8081
<h1>Hello World from web1</h1>expert
expert@desktop20:~/Documents/ccna/terraform_example$ curl http://localhost:8082
<h1>Hello World from web2</h1>expert
expert@desktop20:~/Documents/ccna/terraform_example$ curl http://localhost:8083
<h1>Hello World from web3</h1>expert

# 检查 docker
expert@desktop20:~/Documents/ccna/terraform_example$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                  NAMES
a4f2557e03c2   4e5db4761e0f   "/docker-entrypoint.…"   35 seconds ago   Up 33 seconds   0.0.0.0:8081->80/tcp   web1
9c1ba4a7d276   4e5db4761e0f   "/docker-entrypoint.…"   35 seconds ago   Up 33 seconds   0.0.0.0:8082->80/tcp   web2
6d0fd8910184   4e5db4761e0f   "/docker-entrypoint.…"   35 seconds ago   Up 33 seconds   0.0.0.0:8083->80/tcp   web3



############################################
# 第二步：修改main.tf，扩容第四台容器，然后重新apply
############################################



expert@desktop20:~/Documents/ccna/terraform_example$ terraform apply
docker_image.nginx: Refreshing state... [id=sha256:4e5db4761e0ff445f7fd29aad680ad28e8abf7d204895557f145d65535abcc1cnginx:latest]
docker_container.web["web3"]: Refreshing state... [id=6d0fd8910184107c4c6aa81673a876e069de72ce08ae240bf87889706379c161]
docker_container.web["web1"]: Refreshing state... [id=a4f2557e03c286d574c26c5b7b1dd65a2acc0fa9415ed0a7cbe18d9a5cfb26e5]
docker_container.web["web2"]: Refreshing state... [id=9c1ba4a7d2767d99b3e930fe81595a2a2226598e898c221908466f7dd3f3597b]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # docker_container.web["web4"] will be created
  + resource "docker_container" "web" {
      + attach                                      = false
      + bridge                                      = (known after apply)
      + command                                     = (known after apply)
      + container_logs                              = (known after apply)
      + container_read_refresh_timeout_milliseconds = 15000
      + entrypoint                                  = (known after apply)
      + env                                         = (known after apply)
      + exit_code                                   = (known after apply)
      + hostname                                    = (known after apply)
      + id                                          = (known after apply)
      + image                                       = "sha256:4e5db4761e0ff445f7fd29aad680ad28e8abf7d204895557f145d65535abcc1c"
      + init                                        = (known after apply)
      + ipc_mode                                    = (known after apply)
      + log_driver                                  = (known after apply)
      + logs                                        = false
      + memory_reservation                          = 0
      + must_run                                    = true
      + name                                        = "web4"
      + network_data                                = (known after apply)
      + network_mode                                = "bridge"
      + platform                                    = (known after apply)
      + read_only                                   = false
      + remove_volumes                              = true
      + restart                                     = "no"
      + rm                                          = false
      + runtime                                     = (known after apply)
      + security_opts                               = (known after apply)
      + shm_size                                    = (known after apply)
      + start                                       = true
      + stdin_open                                  = false
      + stop_signal                                 = (known after apply)
      + stop_timeout                                = (known after apply)
      + tty                                         = false
      + wait                                        = false
      + wait_timeout                                = 60

      + healthcheck (known after apply)

      + labels (known after apply)

      + ports {
          + external = 8084
          + internal = 80
          + ip       = "0.0.0.0"
          + protocol = "tcp"
        }

      + upload {
          + content        = "<h1>Hello World from web4</h1>"
          + executable     = false
          + file           = "/usr/share/nginx/html/index.html"
            # (4 unchanged attributes hidden)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  ~ container_urls = {
      + web4 = "http://localhost:8084"
        # (3 unchanged attributes hidden)
    }

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

docker_container.web["web4"]: Creating...
docker_container.web["web4"]: Creation complete after 1s [id=972a48dc8176b5a7721de471342cfb30399708506aafc9e8a033f49e7ffeed5a]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

container_urls = {
  "web1" = "http://localhost:8081"
  "web2" = "http://localhost:8082"
  "web3" = "http://localhost:8083"
  "web4" = "http://localhost:8084"
}


# 检查 docker，发现增加了一个新的容器
expert@desktop20:~/Documents/ccna/terraform_example$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED              STATUS              PORTS                  NAMES
972a48dc8176   4e5db4761e0f   "/docker-entrypoint.…"   13 seconds ago       Up 12 seconds       0.0.0.0:8084->80/tcp   web4
a4f2557e03c2   4e5db4761e0f   "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:8081->80/tcp   web1
9c1ba4a7d276   4e5db4761e0f   "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:8082->80/tcp   web2
6d0fd8910184   4e5db4761e0f   "/docker-entrypoint.…"   About a minute ago   Up About a minute   0.0.0.0:8083->80/tcp   web3



############################################
# 第三步：修改main.tf，去掉第四台容器，然后重新apply
############################################


expert@desktop20:~/Documents/ccna/terraform_example$ terraform apply
docker_image.nginx: Refreshing state... [id=sha256:4e5db4761e0ff445f7fd29aad680ad28e8abf7d204895557f145d65535abcc1cnginx:latest]
docker_container.web["web4"]: Refreshing state... [id=972a48dc8176b5a7721de471342cfb30399708506aafc9e8a033f49e7ffeed5a]
docker_container.web["web3"]: Refreshing state... [id=6d0fd8910184107c4c6aa81673a876e069de72ce08ae240bf87889706379c161]
docker_container.web["web1"]: Refreshing state... [id=a4f2557e03c286d574c26c5b7b1dd65a2acc0fa9415ed0a7cbe18d9a5cfb26e5]
docker_container.web["web2"]: Refreshing state... [id=9c1ba4a7d2767d99b3e930fe81595a2a2226598e898c221908466f7dd3f3597b]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # docker_container.web["web4"] will be destroyed
  # (because key ["web4"] is not in for_each map)
  - resource "docker_container" "web" {
      - attach                                      = false -> null
      - command                                     = [
          - "nginx",
          - "-g",
          - "daemon off;",
        ] -> null
      - container_read_refresh_timeout_milliseconds = 15000 -> null
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      - entrypoint                                  = [
          - "/docker-entrypoint.sh",
        ] -> null
      - env                                         = [] -> null
      - group_add                                   = [] -> null
      - hostname                                    = "972a48dc8176" -> null
      - id                                          = "972a48dc8176b5a7721de471342cfb30399708506aafc9e8a033f49e7ffeed5a" -> null
      - image                                       = "sha256:4e5db4761e0ff445f7fd29aad680ad28e8abf7d204895557f145d65535abcc1c" -> null
      - init                                        = false -> null
      - ipc_mode                                    = "private" -> null
      - log_driver                                  = "json-file" -> null
      - log_opts                                    = {} -> null
      - logs                                        = false -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_reservation                          = 0 -> null
      - memory_swap                                 = 0 -> null
      - must_run                                    = true -> null
      - name                                        = "web4" -> null
      - network_data                                = [
          - {
              - gateway                   = "100.65.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "100.65.0.5"
              - ip_prefix_length          = 24
              - mac_address               = "42:f9:79:13:0b:c1"
              - network_name              = "bridge"
                # (2 unchanged attributes hidden)
            },
        ] -> null
      - network_mode                                = "bridge" -> null
      - platform                                    = "linux" -> null
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      - read_only                                   = false -> null
      - remove_volumes                              = true -> null
      - restart                                     = "no" -> null
      - rm                                          = false -> null
      - runtime                                     = "runc" -> null
      - security_opts                               = [] -> null
      - shm_size                                    = 64 -> null
      - start                                       = true -> null
      - stdin_open                                  = false -> null
      - stop_signal                                 = "SIGQUIT" -> null
      - stop_timeout                                = 0 -> null
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
      - tty                                         = false -> null
      - wait                                        = false -> null
      - wait_timeout                                = 60 -> null
        # (6 unchanged attributes hidden)

      - ports {
          - external = 8084 -> null
          - internal = 80 -> null
          - ip       = "0.0.0.0" -> null
          - protocol = "tcp" -> null
        }

      - upload {
          - content        = "<h1>Hello World from web4</h1>" -> null
          - executable     = false -> null
          - file           = "/usr/share/nginx/html/index.html" -> null
            # (4 unchanged attributes hidden)
        }
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  ~ container_urls = {
      - web4 = "http://localhost:8084"
        # (3 unchanged attributes hidden)
    }

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

docker_container.web["web4"]: Destroying... [id=972a48dc8176b5a7721de471342cfb30399708506aafc9e8a033f49e7ffeed5a]
docker_container.web["web4"]: Destruction complete after 1s

Apply complete! Resources: 0 added, 0 changed, 1 destroyed.

Outputs:

container_urls = {
  "web1" = "http://localhost:8081"
  "web2" = "http://localhost:8082"
  "web3" = "http://localhost:8083"
}


# 检查 docker，第四台容器已经被删除
expert@desktop20:~/Documents/ccna/terraform_example$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
a4f2557e03c2   4e5db4761e0f   "/docker-entrypoint.…"   5 minutes ago   Up 5 minutes   0.0.0.0:8081->80/tcp   web1
9c1ba4a7d276   4e5db4761e0f   "/docker-entrypoint.…"   5 minutes ago   Up 5 minutes   0.0.0.0:8082->80/tcp   web2
6d0fd8910184   4e5db4761e0f   "/docker-entrypoint.…"   5 minutes ago   Up 5 minutes   0.0.0.0:8083->80/tcp   web3



############################################
# 第四步：摧毁部署
############################################

expert@desktop20:~/Documents/ccna/terraform_example$ terraform destroy
docker_image.nginx: Refreshing state... [id=sha256:4e5db4761e0ff445f7fd29aad680ad28e8abf7d204895557f145d65535abcc1cnginx:latest]
docker_container.web["web2"]: Refreshing state... [id=9c1ba4a7d2767d99b3e930fe81595a2a2226598e898c221908466f7dd3f3597b]
docker_container.web["web3"]: Refreshing state... [id=6d0fd8910184107c4c6aa81673a876e069de72ce08ae240bf87889706379c161]
docker_container.web["web1"]: Refreshing state... [id=a4f2557e03c286d574c26c5b7b1dd65a2acc0fa9415ed0a7cbe18d9a5cfb26e5]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # docker_container.web["web1"] will be destroyed
  - resource "docker_container" "web" {
      - attach                                      = false -> null
      - command                                     = [
          - "nginx",
          - "-g",
          - "daemon off;",
        ] -> null
      - container_read_refresh_timeout_milliseconds = 15000 -> null
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      - entrypoint                                  = [
          - "/docker-entrypoint.sh",
        ] -> null
      - env                                         = [] -> null
      - group_add                                   = [] -> null
      - hostname                                    = "a4f2557e03c2" -> null
      - id                                          = "a4f2557e03c286d574c26c5b7b1dd65a2acc0fa9415ed0a7cbe18d9a5cfb26e5" -> null
      - image                                       = "sha256:4e5db4761e0ff445f7fd29aad680ad28e8abf7d204895557f145d65535abcc1c" -> null
      - init                                        = false -> null
      - ipc_mode                                    = "private" -> null
      - log_driver                                  = "json-file" -> null
      - log_opts                                    = {} -> null
      - logs                                        = false -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_reservation                          = 0 -> null
      - memory_swap                                 = 0 -> null
      - must_run                                    = true -> null
      - name                                        = "web1" -> null
      - network_data                                = [
          - {
              - gateway                   = "100.65.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "100.65.0.3"
              - ip_prefix_length          = 24
              - mac_address               = "ba:0a:2f:41:79:a0"
              - network_name              = "bridge"
                # (2 unchanged attributes hidden)
            },
        ] -> null
      - network_mode                                = "bridge" -> null
      - platform                                    = "linux" -> null
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      - read_only                                   = false -> null
      - remove_volumes                              = true -> null
      - restart                                     = "no" -> null
      - rm                                          = false -> null
      - runtime                                     = "runc" -> null
      - security_opts                               = [] -> null
      - shm_size                                    = 64 -> null
      - start                                       = true -> null
      - stdin_open                                  = false -> null
      - stop_signal                                 = "SIGQUIT" -> null
      - stop_timeout                                = 0 -> null
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
      - tty                                         = false -> null
      - wait                                        = false -> null
      - wait_timeout                                = 60 -> null
        # (6 unchanged attributes hidden)

      - ports {
          - external = 8081 -> null
          - internal = 80 -> null
          - ip       = "0.0.0.0" -> null
          - protocol = "tcp" -> null
        }

      - upload {
          - content        = "<h1>Hello World from web1</h1>" -> null
          - executable     = false -> null
          - file           = "/usr/share/nginx/html/index.html" -> null
            # (4 unchanged attributes hidden)
        }
    }

  # docker_container.web["web2"] will be destroyed
  - resource "docker_container" "web" {
      - attach                                      = false -> null
      - command                                     = [
          - "nginx",
          - "-g",
          - "daemon off;",
        ] -> null
      - container_read_refresh_timeout_milliseconds = 15000 -> null
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      - entrypoint                                  = [
          - "/docker-entrypoint.sh",
        ] -> null
      - env                                         = [] -> null
      - group_add                                   = [] -> null
      - hostname                                    = "9c1ba4a7d276" -> null
      - id                                          = "9c1ba4a7d2767d99b3e930fe81595a2a2226598e898c221908466f7dd3f3597b" -> null
      - image                                       = "sha256:4e5db4761e0ff445f7fd29aad680ad28e8abf7d204895557f145d65535abcc1c" -> null
      - init                                        = false -> null
      - ipc_mode                                    = "private" -> null
      - log_driver                                  = "json-file" -> null
      - log_opts                                    = {} -> null
      - logs                                        = false -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_reservation                          = 0 -> null
      - memory_swap                                 = 0 -> null
      - must_run                                    = true -> null
      - name                                        = "web2" -> null
      - network_data                                = [
          - {
              - gateway                   = "100.65.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "100.65.0.2"
              - ip_prefix_length          = 24
              - mac_address               = "96:3e:66:25:83:af"
              - network_name              = "bridge"
                # (2 unchanged attributes hidden)
            },
        ] -> null
      - network_mode                                = "bridge" -> null
      - platform                                    = "linux" -> null
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      - read_only                                   = false -> null
      - remove_volumes                              = true -> null
      - restart                                     = "no" -> null
      - rm                                          = false -> null
      - runtime                                     = "runc" -> null
      - security_opts                               = [] -> null
      - shm_size                                    = 64 -> null
      - start                                       = true -> null
      - stdin_open                                  = false -> null
      - stop_signal                                 = "SIGQUIT" -> null
      - stop_timeout                                = 0 -> null
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
      - tty                                         = false -> null
      - wait                                        = false -> null
      - wait_timeout                                = 60 -> null
        # (6 unchanged attributes hidden)

      - ports {
          - external = 8082 -> null
          - internal = 80 -> null
          - ip       = "0.0.0.0" -> null
          - protocol = "tcp" -> null
        }

      - upload {
          - content        = "<h1>Hello World from web2</h1>" -> null
          - executable     = false -> null
          - file           = "/usr/share/nginx/html/index.html" -> null
            # (4 unchanged attributes hidden)
        }
    }

  # docker_container.web["web3"] will be destroyed
  - resource "docker_container" "web" {
      - attach                                      = false -> null
      - command                                     = [
          - "nginx",
          - "-g",
          - "daemon off;",
        ] -> null
      - container_read_refresh_timeout_milliseconds = 15000 -> null
      - cpu_shares                                  = 0 -> null
      - dns                                         = [] -> null
      - dns_opts                                    = [] -> null
      - dns_search                                  = [] -> null
      - entrypoint                                  = [
          - "/docker-entrypoint.sh",
        ] -> null
      - env                                         = [] -> null
      - group_add                                   = [] -> null
      - hostname                                    = "6d0fd8910184" -> null
      - id                                          = "6d0fd8910184107c4c6aa81673a876e069de72ce08ae240bf87889706379c161" -> null
      - image                                       = "sha256:4e5db4761e0ff445f7fd29aad680ad28e8abf7d204895557f145d65535abcc1c" -> null
      - init                                        = false -> null
      - ipc_mode                                    = "private" -> null
      - log_driver                                  = "json-file" -> null
      - log_opts                                    = {} -> null
      - logs                                        = false -> null
      - max_retry_count                             = 0 -> null
      - memory                                      = 0 -> null
      - memory_reservation                          = 0 -> null
      - memory_swap                                 = 0 -> null
      - must_run                                    = true -> null
      - name                                        = "web3" -> null
      - network_data                                = [
          - {
              - gateway                   = "100.65.0.1"
              - global_ipv6_prefix_length = 0
              - ip_address                = "100.65.0.4"
              - ip_prefix_length          = 24
              - mac_address               = "e2:46:0c:78:c3:be"
              - network_name              = "bridge"
                # (2 unchanged attributes hidden)
            },
        ] -> null
      - network_mode                                = "bridge" -> null
      - platform                                    = "linux" -> null
      - privileged                                  = false -> null
      - publish_all_ports                           = false -> null
      - read_only                                   = false -> null
      - remove_volumes                              = true -> null
      - restart                                     = "no" -> null
      - rm                                          = false -> null
      - runtime                                     = "runc" -> null
      - security_opts                               = [] -> null
      - shm_size                                    = 64 -> null
      - start                                       = true -> null
      - stdin_open                                  = false -> null
      - stop_signal                                 = "SIGQUIT" -> null
      - stop_timeout                                = 0 -> null
      - storage_opts                                = {} -> null
      - sysctls                                     = {} -> null
      - tmpfs                                       = {} -> null
      - tty                                         = false -> null
      - wait                                        = false -> null
      - wait_timeout                                = 60 -> null
        # (6 unchanged attributes hidden)

      - ports {
          - external = 8083 -> null
          - internal = 80 -> null
          - ip       = "0.0.0.0" -> null
          - protocol = "tcp" -> null
        }

      - upload {
          - content        = "<h1>Hello World from web3</h1>" -> null
          - executable     = false -> null
          - file           = "/usr/share/nginx/html/index.html" -> null
            # (4 unchanged attributes hidden)
        }
    }

  # docker_image.nginx will be destroyed
  - resource "docker_image" "nginx" {
      - id           = "sha256:4e5db4761e0ff445f7fd29aad680ad28e8abf7d204895557f145d65535abcc1cnginx:latest" -> null
      - image_id     = "sha256:4e5db4761e0ff445f7fd29aad680ad28e8abf7d204895557f145d65535abcc1c" -> null
      - keep_locally = true -> null
      - name         = "nginx:latest" -> null
      - repo_digest  = "nginx@sha256:5a88c9c45479443d7be2eadc894b4ed0a9801bae03d97a5760ae13b5c2005942" -> null
    }

Plan: 0 to add, 0 to change, 4 to destroy.

Changes to Outputs:
  - container_urls = {
      - web1 = "http://localhost:8081"
      - web2 = "http://localhost:8082"
      - web3 = "http://localhost:8083"
    } -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

docker_container.web["web2"]: Destroying... [id=9c1ba4a7d2767d99b3e930fe81595a2a2226598e898c221908466f7dd3f3597b]
docker_container.web["web1"]: Destroying... [id=a4f2557e03c286d574c26c5b7b1dd65a2acc0fa9415ed0a7cbe18d9a5cfb26e5]
docker_container.web["web3"]: Destroying... [id=6d0fd8910184107c4c6aa81673a876e069de72ce08ae240bf87889706379c161]
docker_container.web["web1"]: Destruction complete after 1s
docker_container.web["web3"]: Destruction complete after 1s
docker_container.web["web2"]: Destruction complete after 1s
docker_image.nginx: Destroying... [id=sha256:4e5db4761e0ff445f7fd29aad680ad28e8abf7d204895557f145d65535abcc1cnginx:latest]
docker_image.nginx: Destruction complete after 0s

Destroy complete! Resources: 4 destroyed.


# 检查容器，发现容器已经全部被删除
expert@desktop20:~/Documents/ccna/terraform_example$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES


```
