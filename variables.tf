variable "name" {
  type = string
}

variable "vm_count" {
  type    = number
  default = 1
}

variable "prefix" {
  type    = string
  default = "ops"
}

variable "networks" {
  default = []
}

variable "tags" {
  default = []
}

variable "ansible_groups" {
  type    = list(list(string))
  default = []
}

variable "ansible_host_key_check" {
  type    = bool
  default = true
}

variable "vm" {}

variable "default_vm" {
  default = {
    network_timeout = 5
    domain          = "ad.balmerfamilyfarm.com"
    disks           = []
    datastore       = "vsanDatastore"
    template        = "centos7-2020-12-22"

    customize                            = false
    cloud_init                           = true
    cloud_init_custom                    = false
    cloud_config_template                = "centos-cloud-config.tpl"
    metadata_template                    = "centos-metadata.tpl"
    network_config_template              = "centos-network-config.tpl"
    cloud_config_guestinfo_path          = "cloud-init.config.data"
    cloud_config_guestinfo_encoding_path = "cloud-init.data.encoding"

    cpus   = 2
    memory = 4096

  }
}

variable "cluster_settings" {

  default = {
    datacenter = "farm"
    cluster    = "operations"
    pool       = "operations/Resources"
  }
}

variable "op_subdomain" {
  description = "The subdomain for your 1Password account."
  default     = "my"
}

variable "op_vault" {
  description = "Vault with the passwords for this module."
  default     = "homelab"
}

variable "op_vcenter_login" {
  description = "Login for vCenter."
  default     = "ad.balmerfamilyfarm.com - terraform-vsphere"
}

variable "ssh_keys" {
  description = "SSH keys to add to the node."
  type        = list(string)
}

variable "op_vm_login" {
  type        = string
  description = "The login data for the VM."
}

variable "vsphere_server" {
  type        = string
  description = "The vCenter server to use"
  default     = "vcenter.balmerfamilyfarm.com"
}
