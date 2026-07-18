# Terraform 演示

任务：用 terraform 管理路由器的配置，感受声明式和命令式的区别。

> “命令式”：Ansible 告诉设备“执行什么动作”；
>
> “声明式”：Terraform 告诉系统“最终应该有什么资源”。

## 步骤

```bash
terraform init
terraform plan

# 先观察 apply
terraform apply

# 再观察 destroy
terraform destroy
```

## 输出

```bash
expert@desktop20:~/Documents/ccna/terraform_example2$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  + create

Terraform will perform the following actions:

  # iosxe_interface_ethernet.wan will be created
  + resource "iosxe_interface_ethernet" "wan" {
      + description       = "WAN-LINK"
      + id                = (known after apply)
      + ipv4_address      = "192.168.10.1"
      + ipv4_address_mask = "255.255.255.0"
      + name              = "3"
      + shutdown          = false
      + type              = "GigabitEthernet"
    }

  # iosxe_interface_loopback.loopback["11"] will be created
  + resource "iosxe_interface_loopback" "loopback" {
      + id                = (known after apply)
      + ipv4_address      = "11.11.11.1"
      + ipv4_address_mask = "255.255.255.255"
      + name              = 11
      + shutdown          = false
    }

  # iosxe_interface_loopback.loopback["12"] will be created
  + resource "iosxe_interface_loopback" "loopback" {
      + id                = (known after apply)
      + ipv4_address      = "12.12.12.1"
      + ipv4_address_mask = "255.255.255.255"
      + name              = 12
      + shutdown          = false
    }

  # iosxe_interface_loopback.loopback["13"] will be created
  + resource "iosxe_interface_loopback" "loopback" {
      + id                = (known after apply)
      + ipv4_address      = "13.13.13.1"
      + ipv4_address_mask = "255.255.255.255"
      + name              = 13
      + shutdown          = false
    }

  # iosxe_system.router will be created
  + resource "iosxe_system" "router" {
      + enable_secret_wo    = (write-only attribute)
      + hostname            = "TF-Router"
      + id                  = (known after apply)
      + ip_sftp_password_wo = (write-only attribute)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

iosxe_interface_loopback.loopback["13"]: Creating...
iosxe_interface_loopback.loopback["11"]: Creating...
iosxe_interface_loopback.loopback["12"]: Creating...
iosxe_interface_ethernet.wan: Creating...
iosxe_system.router: Creating...
iosxe_interface_loopback.loopback["13"]: Creation complete after 7s [id=Cisco-IOS-XE-native:native/interface/Loopback=13]
iosxe_interface_loopback.loopback["12"]: Creation complete after 7s [id=Cisco-IOS-XE-native:native/interface/Loopback=12]
iosxe_interface_loopback.loopback["11"]: Creation complete after 9s [id=Cisco-IOS-XE-native:native/interface/Loopback=11]
iosxe_interface_ethernet.wan: Still creating... [00m10s elapsed]
iosxe_system.router: Still creating... [00m10s elapsed]
iosxe_interface_ethernet.wan: Creation complete after 12s [id=Cisco-IOS-XE-native:native/interface/GigabitEthernet=3]
iosxe_system.router: Creation complete after 13s [id=Cisco-IOS-XE-native:native]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.








#######################################################################################################




expert@desktop20:~/Documents/ccna/terraform_example2$ terraform destroy
iosxe_interface_loopback.loopback["13"]: Refreshing state... [id=Cisco-IOS-XE-native:native/interface/Loopback=13]
iosxe_interface_loopback.loopback["12"]: Refreshing state... [id=Cisco-IOS-XE-native:native/interface/Loopback=12]
iosxe_interface_loopback.loopback["11"]: Refreshing state... [id=Cisco-IOS-XE-native:native/interface/Loopback=11]
iosxe_system.router: Refreshing state... [id=Cisco-IOS-XE-native:native]
iosxe_interface_ethernet.wan: Refreshing state... [id=Cisco-IOS-XE-native:native/interface/GigabitEthernet=3]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  - destroy

Terraform will perform the following actions:

  # iosxe_interface_ethernet.wan will be destroyed
  - resource "iosxe_interface_ethernet" "wan" {
      - description       = "WAN-LINK" -> null
      - id                = "Cisco-IOS-XE-native:native/interface/GigabitEthernet=3" -> null
      - ipv4_address      = "192.168.10.1" -> null
      - ipv4_address_mask = "255.255.255.0" -> null
      - name              = "3" -> null
      - shutdown          = false -> null
      - type              = "GigabitEthernet" -> null
    }

  # iosxe_interface_loopback.loopback["11"] will be destroyed
  - resource "iosxe_interface_loopback" "loopback" {
      - id                = "Cisco-IOS-XE-native:native/interface/Loopback=11" -> null
      - ipv4_address      = "11.11.11.1" -> null
      - ipv4_address_mask = "255.255.255.255" -> null
      - name              = 11 -> null
      - shutdown          = false -> null
    }

  # iosxe_interface_loopback.loopback["12"] will be destroyed
  - resource "iosxe_interface_loopback" "loopback" {
      - id                = "Cisco-IOS-XE-native:native/interface/Loopback=12" -> null
      - ipv4_address      = "12.12.12.1" -> null
      - ipv4_address_mask = "255.255.255.255" -> null
      - name              = 12 -> null
      - shutdown          = false -> null
    }

  # iosxe_interface_loopback.loopback["13"] will be destroyed
  - resource "iosxe_interface_loopback" "loopback" {
      - id                = "Cisco-IOS-XE-native:native/interface/Loopback=13" -> null
      - ipv4_address      = "13.13.13.1" -> null
      - ipv4_address_mask = "255.255.255.255" -> null
      - name              = 13 -> null
      - shutdown          = false -> null
    }

  # iosxe_system.router will be destroyed
  - resource "iosxe_system" "router" {
      - enable_secret_wo    = (write-only attribute) -> null
      - hostname            = "TF-Router" -> null
      - id                  = "Cisco-IOS-XE-native:native" -> null
      - ip_sftp_password_wo = (write-only attribute) -> null
    }

Plan: 0 to add, 0 to change, 5 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

iosxe_interface_loopback.loopback["11"]: Destroying... [id=Cisco-IOS-XE-native:native/interface/Loopback=11]
iosxe_interface_loopback.loopback["13"]: Destroying... [id=Cisco-IOS-XE-native:native/interface/Loopback=13]
iosxe_interface_loopback.loopback["12"]: Destroying... [id=Cisco-IOS-XE-native:native/interface/Loopback=12]
iosxe_interface_ethernet.wan: Destroying... [id=Cisco-IOS-XE-native:native/interface/GigabitEthernet=3]
iosxe_system.router: Destroying... [id=Cisco-IOS-XE-native:native]
iosxe_interface_loopback.loopback["11"]: Destruction complete after 3s
iosxe_interface_loopback.loopback["13"]: Destruction complete after 5s
iosxe_interface_loopback.loopback["12"]: Destruction complete after 7s
iosxe_interface_ethernet.wan: Still destroying... [id=Cisco-IOS-XE-native:native/interface/GigabitEthernet=3, 00m10s elapsed]
iosxe_system.router: Still destroying... [id=Cisco-IOS-XE-native:native, 00m10s elapsed]
iosxe_interface_ethernet.wan: Destruction complete after 13s
iosxe_system.router: Destruction complete after 18s

Destroy complete! Resources: 5 destroyed.
```
