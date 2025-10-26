vsphere_server = "vcenter.lab.local"
esxi_host_address = "esxi-01.yourdomain.local"
esxi_username = "foo"
esxi_thumbprint = "00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:01:23:45:67"
vsphere_password = "foo12345"
esxi_password = "foo0987"
vsphere_user = "foo.example"

esxi_hosts = {
host01 = {
		address = "foo1.example.com"
		username = "root"
		password = "12345"
		thumbprint = "AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD"
}

host02 = {
		                address = "foo2.example.com"
                username = "root"
                password = "09876"
                thumbprint = "BB:AA:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD"
}

host03 = {      
                address = "foo3.example.com"
                username = "root"
                password = "secure"
                thumbprint = "BB:CC:AA:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD"
}
}

network_interfaces = ["uplink1", "uplink2", "uplink3", "uplink4","uplink5","uplink6" ]

web_server_count = 9
