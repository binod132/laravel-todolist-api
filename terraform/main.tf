provider "vsphere" {
  user                  = "root"
  password              = "Mid@s123"
  vsphere_server        = "192.168.130.210"
  allow_unverified_ssl  = true
  api_timeout           = 10
}

data "vsphere_datacenter" "datacenter" {
  name = "ha-datacenter"  # Change to your ESXi datacenter name
}

data "vsphere_host" "host" {
  name          = "localhost"  # Change to your ESXi host name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"  # Name of your datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = "VM Network"  # Change to your network name
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "ubuntu-vm"  # Name for the VM
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 2  # Set number of CPUs
  memory           = 4096  # Set memory in MB
  guest_id         = "ubuntu64Guest"  # Guest OS type

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "Hard Disk 1"
    size  = 20  # Size in GB
  }

  # Use existing .vmx file located on the datastore
  vmx_file = "/vmfs/volumes/datastore1/iso/os_template/ubuntu-server-template/ubuntu-22.04.vmx"  # Path to your .vmx file

  state = "poweredon"  # Power on the VM after creation
}

output "vm_ip" {
  value = vsphere_virtual_machine.vm.network_interface.0.ipv4_address
}
