# terraform-libvirt-vm

A reusable Terraform module for provisioning KVM/QEMU virtual machines using the [libvirt provider](https://registry.terraform.io/providers/dmacvicar/libvirt/latest).

## Features

- Provision one or more VMs from a pre-built qcow2 base image (Copy-on-Write clones)
- Cloud-init for automated guest configuration (hostname, users, SSH keys)
- Optional CIFS/SMB shared filesystem mounts
- Secrets management via `secret.auto.tfvars` (gitignored)
- Customizable login banners and dotfiles provisioning
