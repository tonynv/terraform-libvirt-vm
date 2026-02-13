variable "vm_count" {
  description = "Number of VMs to create."
  type        = number
  default     = 1
}

variable "vm_name_prefix" {
  description = "Override VM name prefix. If empty, defaults to {hostname}-{ostype}."
  type        = string
  default     = ""
}

variable "memory" {
  description = "RAM in MB."
  type        = number
  default     = 2048
}

variable "vcpus" {
  description = "Number of virtual CPUs."
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "Disk size in bytes (default 20 GB)."
  type        = number
  default     = 21474836480 # 20 GB
}

variable "base_image" {
  description = "Path to the pre-built qcow2 base image."
  type        = string
  default     = "../output/tonynv-ubuntu2404.qcow2"
}

variable "network_name" {
  description = "Libvirt network name to attach VMs to."
  type        = string
  default     = "vlan200"
}

variable "autostart" {
  description = "Auto-start VMs on host boot (required for Cockpit management)."
  type        = bool
  default     = true
}
