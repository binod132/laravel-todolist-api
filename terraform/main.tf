provider "vsphere" {
  user           = "root"
  password       = "Mid@s123"
  vsphere_server = "192.168.130.210"
  allow_unverified_ssl = true
}

# Define variables for flexibility
variable "vm_name" {
  default = "terraform-vm"
}

variable "template_uuid" {
  default = "your_template_uuid"  # Replace with your template UUID
}

# VM Resource Configuration
resource "vsphere_virtual_machine" "new_vm" {
  name             = var.vm_name
  resource_pool_id = "Resources"               # Default resource pool in ESXi
  datastore_id     = "datastore1"              # Replace with your datastore name or ID
  num_cpus         = 2                         # Set desired CPU count
  memory           = 4096                      # Set desired memory in MB (4GB)
  guest_id         = "ubuntu64Guest"           # Match the guest OS type of the template

  # Configure the disk
  disk {
    label            = "disk0"
    size             = 20                      # Disk size in GB
    eagerly_scrub    = false
    thin_provisioned = true                    # Use thin provisioning for disk
  }

  # Configure the network interface
  network_interface {
    network_id   = "VM Network"                # Replace with your network name or ID
    adapter_type = "vmxnet3"
  }

  # Clone from the template
  clone {
    template_uuid = var.template_uuid

    customize {
      linux_options {
        host_name = var.vm_name
        domain    = "local"
      }

      # Network configuration
      network_interface {
        ipv4_address = "192.168.130.115"         # Desired static IP
        ipv4_netmask = 24                      # Network mask (e.g., 24 for /24 network)
      }
      ipv4_gateway = "192.168.130.1"             # Network gateway
    }
  }
}
