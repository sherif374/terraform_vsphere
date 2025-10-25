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

resource "vsphere_host" "esxi_host" {
	hostname = var.esxi_host_address
	username = var.esxi_username
        password = var.esxi_password
        thumbprint = var.esxi_thumbprint
	cluster = vsphere_compute_cluster.cluster.id
}


resource "vsphere_host_port_group" "vm_network" {
	name = "TF-VM-Network"
	host_system_id = vsphere_host.esxi_host.id
	virtual_switch_name = "vswitch0"
}

resource "vsphere_host_virtual_switch" "vmotion_switch" {
	name = "vswitch1"
	host_system_id = vsphere_host.esxi_host.id
	network_adapters = ["vmnic1"]
	active_nics = ["vmnic1"]

}

resource "vsphere_host_port_group" "pg_vmotion" {
        name = "TF-VM-Net"
        host_system_id = vsphere_host.esxi_host.id
        virtual_switch_name = vsphere_host_virtual_switch.vmotion_switch.name
}

resource "vsphere_vnic" "vmkernel_vmotion" {
	host = vsphere_host.esxi_host.id
	portgroup = vsphere_host_port_group.pg_vmotion.name
	ipv4 {
		ip = "192.168.1.1"
		netmask = "255.255.255.0"
  }
	services = ["vmotion"]
}

resource "vsphere_host_port_group" "pg_vsan" {
	name = "vsan"
	host_system_id = vsphere_host.esxi_host.id
	virtual_switch_name = vsphere_host_virtual_switch.vmotion_switch.name
}

resource "vsphere_vnic" "vmk_vsan" {
        host = vsphere_host.esxi_host.id
        portgroup = vsphere_host_port_group.pg_vsan.name
        ipv4 {
                ip = "192.168.1.2"
                netmask = "255.255.255.0"
  }
        services = ["vsan"]
}


data "vsphere_datastore" "vsan" {
  name          = "vsanDatastore"  
  datacenter_id = resource.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "web_server" {
	name = "tf-web-01"
	guest_id = "other_guest"
  	network_interface {
	network_id = vsphere_host_port_group.vm_network.id
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
	
