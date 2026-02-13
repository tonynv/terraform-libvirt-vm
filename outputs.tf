output "vm_names" {
  description = "Names of the created VMs."
  value       = libvirt_domain.vm[*].name
}

output "vm_ips" {
  description = "IP addresses of the created VMs (from DHCP)."
  value       = [for vm in libvirt_domain.vm : vm.network_interface[0].addresses]
}
