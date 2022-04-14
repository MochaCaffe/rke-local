terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  # Configuration options
  uri = "qemu:///system"
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name = "commoninit.iso"
  pool = "default"
  user_data      = data.template_cloudinit_config.config.rendered
}

data "template_cloudinit_config" "config" {
  gzip = false
  base64_encode = false
  part {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    content = "${data.template_file.user_data.rendered}"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    public_key = file("~/.ssh/id2.pub")
  }
}


# Defining VM Volume
resource "libvirt_volume" "rke_1" {
  name = "rke_1.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  source = "./CentOS-7-x86_64-GenericCloud.qcow2"
  format = "qcow2"
}
resource "libvirt_volume" "rke_2" {
  name = "rke_2.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  source = "./CentOS-7-x86_64-GenericCloud.qcow2"
  format = "qcow2"
}
resource "libvirt_volume" "rke_3" {
  name = "rke_3.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  source = "./CentOS-7-x86_64-GenericCloud.qcow2"
  format = "qcow2"
}


# Define KVM domain to create
resource "libvirt_domain" "rke_1" {
  name   = "rke_1"
  memory = "2048"
  vcpu   = 2
  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  network_interface {
    network_name = "default" # List networks with virsh net-list
    addresses      = ["192.168.122.2"]
    mac            = "AA:BB:CC:11:22:22"
    wait_for_lease = true
  }

  disk {
    volume_id = "${libvirt_volume.rke_1.id}"
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

resource "libvirt_domain" "rke_2" {
  name   = "rke_2"
  memory = "2048"
  vcpu   = 2
  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  network_interface {
    network_name = "default" # List networks with virsh net-list
    addresses      = ["192.168.122.3"]
    mac            = "AA:BB:CC:11:22:33"
    wait_for_lease = true
  }

  disk {
    volume_id = "${libvirt_volume.rke_2.id}"
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

resource "libvirt_domain" "rke_3" {
  name   = "rke_3"
  memory = "2048"
  vcpu   = 2
  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  network_interface {
    network_name = "default" # List networks with virsh net-list
    addresses      = ["192.168.122.4"]
    mac            = "AA:BB:CC:11:22:44"
    wait_for_lease = true
  }

  disk {
    volume_id = "${libvirt_volume.rke_3.id}"
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}