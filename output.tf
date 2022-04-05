output "lb_lsit" {
  value = libvirt_domain.loadbalancer.*.names
}

output "ctrl_list" {
  value = libvirt_domain.ctrl.*.name
}

output "nodes_list" {
  value = libvirt_domain.node.*.name
}

output "lb_ipv4" {
  value = libvirt_domain.loadbalancer.*.network_interface.0.addresses
}

output "ctrl_ipv4" {
  value = libvirt_domain.ctrl.*.network_interface.0.addresses
}

output "nodes_ipv4" {
  value = libvirt_domain.node.*.network_interface.0.addresses
}
