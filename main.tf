resource "libvirt_pool" "node_image" {
  name = "ubuntu"
  type = "dir"
  path = "/var/lib/libvirt/images/terraform-provider-libvirt-pool-k8s"
}

resource "libvirt_volume" "node_volume" {
  name   = "ctrlr-volume"
  pool   = libvirt_pool.node_image.name
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "node_volume_resized" {
  name           = "node-volume-${count.index}"
  base_volume_id = libvirt_volume.node_volume.id
  pool           = libvirt_pool.node_image.name
  size           = 42949672960
  count          = var.lb_node_count + var.ctrl_node_count + var.data_node_count
}

data "template_file" "lb_user_data" {
  count    = var.lb_node_count
  template = file("${path.module}/config/lb_cloud_init.cfg")
  vars = {
    public_key = var.public_ssh_key
    hostname   = "lb-${count.index + 1}"
  }
}

data "template_file" "ctrl_user_data" {
  count    = var.ctrl_node_count
  template = file("${path.module}/config/ctrl_cloud_init.cfg")
  vars = {
    public_key = var.public_ssh_key
    hostname   = "ctrl-${count.index + 1}"
  }
}

data "template_file" "node_user_data" {
  count    = var.data_node_count
  template = file("${path.module}/config/node_cloud_init.cfg")
  vars = {
    public_key = var.public_ssh_key
    hostname   = "node-${count.index + 1}"
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/config/network_config.cfg")
}

resource "libvirt_cloudinit_disk" "lb_disk" {
  count          = var.lb_node_count
  name           = "lb-disk-${count.index}.iso"
  user_data      = data.template_file.lb_user_data[count.index].rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.node_image.name
}

resource "libvirt_cloudinit_disk" "ctrl_disk" {
  count          = var.ctrl_node_count
  name           = "ctrl-disk-${count.index}.iso"
  user_data      = data.template_file.ctrl_user_data[count.index].rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.node_image.name
}

resource "libvirt_cloudinit_disk" "node_disk" {
  count          = var.data_node_count
  name           = "node-disk-${count.index}.iso"
  user_data      = data.template_file.node_user_data[count.index].rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.node_image.name
}

resource "libvirt_domain" "loadbalancer" {
  count  = var.lb_node_count
  name   = "lb-${count.index + 1}"
  memory = "2048"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.lb_disk[count.index].id

  network_interface {
    network_name   = "default"
    wait_for_lease = "true"
  }

  disk {
    volume_id = libvirt_volume.node_volume_resized[count.index].id
  }
}

resource "libvirt_domain" "ctrl" {
  count  = var.ctrl_node_count
  name   = "ctrl-${count.index + 1}"
  memory = "2048"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.ctrl_disk[count.index].id

  network_interface {
    network_name   = "default"
    wait_for_lease = "true"
  }

  disk {
    volume_id = libvirt_volume.node_volume_resized[var.lb_node_count+count.index].id
  }
}

resource "libvirt_domain" "node" {
  count  = var.data_node_count
  name   = "node-${count.index + 1}"
  memory = "4096"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.node_disk[count.index].id

  network_interface {
    network_name   = "default"
    wait_for_lease = "true"
  }

  disk {
    volume_id = libvirt_volume.node_volume_resized[var.lb_node_count+var.ctrl_node_count+count.index].id
  }
}
