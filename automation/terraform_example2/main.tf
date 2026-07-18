# Provider 是 Terraform 用来对接某一类具体资源的插件，负责把 HCL 里声明的资源翻译成对应平台的 API 调用
terraform {
  required_providers {
    iosxe = {
      source = "CiscoDevNet/iosxe"
    }
  }
}

provider "iosxe" {
  # 备注：CiscoDevNet/iosxe provider 走的是 REST API(restconf)
  host     = "10.1.16.25"
  username = "admin"
  password = "Cisco123"
  insecure = true
}

resource "iosxe_system" "router" {
  hostname = "TF-Router"
}

resource "iosxe_interface_ethernet" "wan" {
  type              = "GigabitEthernet"
  name              = "3"
  description       = "WAN-LINK"
  ipv4_address      = "192.168.10.1"
  ipv4_address_mask = "255.255.255.0"
  shutdown          = false
}

variable "loopbacks" {
  default = {
    "11" = "11.11.11.1"
    "12" = "12.12.12.1"
    "13" = "13.13.13.1"
  }
}

resource "iosxe_interface_loopback" "loopback" {
  for_each          = var.loopbacks
  name              = tonumber(each.key)
  ipv4_address      = each.value
  ipv4_address_mask = "255.255.255.255"
  shutdown          = false
}