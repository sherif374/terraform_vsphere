terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.0" 
    }
  }
}



provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
  api_timeout          = 10
}

resource "vsphere_datacenter" "dc" {
 	name = "TF_Automated_DC"
}

resource "vsphere_compute_cluster" "cluster" {
	name = "TF-Compute-Cluster"
	datacenter_id = vsphere_datacenter.dc.id
        drs_enabled = true
        ha_enabled = true
	vsan_enabled = true

}

resource "vsphere_host" "esxi_hosts" {
	for_each = var.esxi_hosts

		hostname = each.value.address
		username = each.value.username
        	password = each.value.password
        	thumbprint = each.value.thumbprint
		cluster = vsphere_compute_cluster.cluster.id
}



resource "vsphere_distributed_virtual_switch" "VDS" {
	name = "vds-01"
	datacenter_id = resource.vsphere_datacenter.dc.id
	uplinks = ["uplink1", "uplink2", "uplink3", "uplink4","uplink5","uplink6" ]
	active_uplinks = ["uplink1","uplink3","uplink5"]
	standby_uplinks = ["uplink2","uplink4","uplink6"]

dynamic "host" {
for_each = vsphere_host.esxi_hosts
  content {
    host_system_id = host.value.id 
    devices = var.network_interfaces 
  }
}
}

resource "vsphere_distributed_port_group" "pg_vm" {                            
	name = "pg-00"
	distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.VDS.id                                                                     

	vlan_id = 110                                                              
}
resource "vsphere_distributed_port_group" "pg_vmotion" {
        name = "pg-01"
        distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.VDS.id
vlan_id = 120
}


resource "vsphere_vnic" "vmkernel_vmotion" {
 for_each = vsphere_host.esxi_hosts
 host = each.value.id
distributed_switch_port = vsphere_distributed_virtual_switch.VDS.id
 distributed_port_group  = vsphere_distributed_port_group.pg_vmotion.id
	ipv4 {
		dhcp = true
  }
	netstack = "vmotion"
}

resource "vsphere_distributed_port_group" "pg_vsan" {
       name = "pg-02"
        distributed_virtual_switch_uuid = vsphere_distributed_virtual_switch.VDS.id
vlan_id = 130
}

resource "vsphere_vnic" "vmk_vsan" {
for_each = vsphere_host.esxi_hosts
 host = each.value.id
distributed_switch_port = vsphere_distributed_virtual_switch.VDS.id
 distributed_port_group  = vsphere_distributed_port_group.pg_vsan.id        

 ipv4 {
                dhcp = true
  }
        netstack = "vsan"
}

data "vsphere_datastore" "vsan" {
  name          = "vsanDatastore"  
  datacenter_id = resource.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "web_server" {
	count = var.web_server_count
	name = format("web-server-%02d", count.index + 1)
	guest_id = "other_guest"
  	network_interface {
	network_id = vsphere_distributed_port_group.pg_vm.id
	}
  	resource_pool_id = vsphere_compute_cluster.cluster.resource_pool_id
	datastore_id = data.vsphere_datastore.vsan.id
	num_cpus = 2
	memory = 4096
	firmware = "bios"
	disk {
	label = "disk0"
	size = 40
	thin_provisioned = true
	}
}
	
