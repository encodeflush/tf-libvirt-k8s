output "lb_ipv4" {
  value = libvirt_domain.node.*.network_interface.0.addresses
}

output "ctrl_ipv4" {
  value = libvirt_domain.ctrl.*.network_interface.0.addresses
}

output "nodes_ipv4" {
  value = libvirt_domain.node.*.network_interface.0.addresses
}
