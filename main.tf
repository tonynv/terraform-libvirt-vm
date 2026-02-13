terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# --- Derive VM name prefix from hostname + OS type when not explicitly set ---

data "external" "hostname" {
  program = ["bash", "-c", "echo \"{\\\"hostname\\\": \\\"$(hostname -s)\\\"}\""]
}

locals {
  # Extract OS type from base_image filename: "../output/tonynv-ubuntu2404.qcow2" -> "ubuntu2404"
  image_basename = basename(var.base_image)
  os_type        = replace(regex("tonynv-(.+)\\.qcow2$", local.image_basename)[0], "/", "")

  # Default prefix: {hostname}-{ostype}, e.g. "hypervisor-ubuntu2404"
  vm_name_prefix = var.vm_name_prefix != "" ? var.vm_name_prefix : "${data.external.hostname.result.hostname}-${local.os_type}"
}

# --- Base volume from pre-built image ---

resource "libvirt_volume" "base" {
  name   = "${local.vm_name_prefix}-base.qcow2"
  pool   = "default"
  source = var.base_image
  format = "qcow2"
}

# --- Per-VM cloned volume (CoW) ---

resource "libvirt_volume" "vm_disk" {
  count          = var.vm_count
  name           = "${local.vm_name_prefix}-${count.index}.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.base.id
  size           = var.disk_size
  format         = "qcow2"
}

# --- Cloud-init disk per VM ---

resource "libvirt_cloudinit_disk" "vm_cloudinit" {
  count = var.vm_count
  name  = "${local.vm_name_prefix}-${count.index}-cloudinit.iso"
  pool  = "default"

  user_data = templatefile("${path.module}/cloud-init.cfg", {
    hostname       = "${local.vm_name_prefix}-${count.index}"
    ssh_public_key = trimspace(file(pathexpand(var.ssh_public_key)))
    cifs_enabled   = var.cifs_enabled
    cifs_server    = var.cifs_server
    cifs_username  = var.cifs_username
    cifs_password  = var.cifs_password
  })
}

# --- VM domain ---

resource "libvirt_domain" "vm" {
  count   = var.vm_count
  name    = "${local.vm_name_prefix}-${count.index}"
  memory  = var.memory
  vcpu    = var.vcpus
  machine = "q35"

  autostart = var.autostart
  cloudinit = libvirt_cloudinit_disk.vm_cloudinit[count.index].id

  disk {
    volume_id = libvirt_volume.vm_disk[count.index].id
  }

  network_interface {
    network_name   = var.network_name
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "vnc"
    listen_type = "none"
  }
}
