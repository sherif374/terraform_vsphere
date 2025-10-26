variable "vsphere_user" { type = string }
variable "vsphere_password" { type = string }
variable "vsphere_server" { type = string }
variable  "esxi_host_address" { type = string  }
variable  "esxi_username" { type = string  }
variable  "esxi_password" { type = string  }
variable  "esxi_thumbprint" { type = string  }
variable "esxi_hosts" {
type = map(object({
	address = string
	username = string
	password = string
	thumbprint= string
}))
}


variable "network_interfaces" {
  type        = list(string)
}

variable "web_server_count" {
  type        = number
}
