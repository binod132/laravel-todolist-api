provider "vsphere" {
  user           = "root"
  password       = "Mid@s123"
  vsphere_server = "192.168.130.210"

  # If your server uses a self-signed certificate
  allow_unverified_ssl = true
}

# Specify the ESXi datacenter
data "vsphere_datacenter" "dc" {
  name = "ha-datacenter"
}

# Define the datastore on ESXi
data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Define the network on ESXi
data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Define the VM template on ESXi
data "vsphere_virtual_machine" "template" {
  name          = "ubuntu.vmx"  # Template located under [datastore1] iso/os_template/ubuntu-24.04
  folder_path   = "iso/os_template/ubuntu-24.04"  # Ensure the path under the datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Define the folder for the VM (use the correct folder path)
data "vsphere_folder" "vm_folder" {
  path          = "vm"  # This is commonly used for the root VM folder in ESXi
}

# Create a new VM from the template
resource "vsphere_virtual_machine" "vm" {
  name             = "terraform-vm"
  resource_pool_id = "ha-datacenter/host/localhost/Resources"  # Use root resource pool for ESXi
  folder           = data.vsphere_folder.vm_folder.path  # Folder where the VM will be created
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 2
  memory           = 4096
  guest_id         = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    eagerly_scrub    = false
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "terraform-vm"
        domain    = "tv.local"
      }

      network_interface {
        ipv4_address = "192.168.130.112"
        ipv4_netmask = 24
      }

      ipv4_gateway = "192.168.130.1"
    }
  }
}
