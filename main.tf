locals {
  vm = merge(var.default_vm, var.vm)
}

terraform {
  required_providers {
    ansible = {
      source  = "nbering/ansible"
      version = "1.0.4"
    }

    onepassword = {
      source  = "anasinnyk/onepassword"
      version = "1.2.1"
    }

    template = {
      version = "2.1"
    }

    vsphere = {
      version = "2.1.1"
    }
  }
}

provider "onepassword" {
  subdomain = var.op_subdomain
}

provider "vsphere" {
  user                 = data.onepassword_item_login.vcenter.username
  password             = data.onepassword_item_login.vcenter.password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "onepassword_vault" "op_homelab" {
  name = var.op_vault
}

data "onepassword_item_login" "vcenter" {
  name  = var.op_vcenter_login
  vault = data.onepassword_vault.op_homelab.name
}

data "onepassword_item_login" "vm" {
  name  = var.op_vm_login
  vault = data.onepassword_vault.op_homelab.name
}

module "server" {
  count  = var.vm_count
  source = "github.com/chrisbalmer/terraform-vsphere-vm?ref=v1.0.0"

  vm = merge(
    {
      name     = "${var.prefix}${var.name}${count.index + 1}"
      gateway  = length(var.networks) > 0 ? var.networks[count.index][0].gateway : local.vm.gateway
      networks = length(var.networks) > 0 ? var.networks[count.index] : local.vm.networks
      tags     = length(var.tags) > 0 ? var.tags[count.index] : local.vm.tags
    },
    local.vm
  )
  cluster_settings = var.cluster_settings

  ssh_keys   = var.ssh_keys
  cloud_user = data.onepassword_item_login.vm.username
  cloud_pass = data.onepassword_item_login.vm.password
}

resource "ansible_host" "vm" {
  count              = length(var.ansible_groups) > 0 ? var.vm_count : 0
  inventory_hostname = "${var.prefix}${var.name}${count.index + 1}.${local.vm.domain}"
  groups             = length(var.ansible_groups) > 1 ? var.ansible_groups[count.index] : var.ansible_groups[0]
  vars = {
    ansible_user           = data.onepassword_item_login.vm.username
    ansible_host           = length(var.networks) > 0 ? split("/", var.networks[count.index][0].ipv4_address)[0] : split("/", local.vm.networks[0].ipv4_address)[0]
    ansible_ssh_extra_args = var.ansible_host_key_check ? null : "-o StrictHostKeyChecking=no"
  }
}
