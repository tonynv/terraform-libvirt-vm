# terraform-libvirt-vm

A reusable Terraform module for provisioning KVM/QEMU virtual machines using the [libvirt provider](https://registry.terraform.io/providers/dmacvicar/libvirt/latest).

## Features

- Provision one or more VMs from a pre-built qcow2 base image (Copy-on-Write clones)
- Auto-generated VM naming based on hypervisor hostname and OS type
- Serial console and VNC graphics support
- Cloud-init for automated guest configuration (hostname, users, SSH keys)
- Optional CIFS/SMB shared filesystem mounts
- Autostart support for Cockpit/virsh management

## Quick Start

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [libvirt provider](https://registry.terraform.io/providers/dmacvicar/libvirt/latest) ~> 0.8
- A KVM/QEMU hypervisor with `qemu:///system` access
- A pre-built qcow2 base image

### Usage

1. Clone this repository:

   ```bash
   git clone https://github.com/tonynv/terraform-libvirt-vm.git
   cd terraform-libvirt-vm
   ```

2. Edit `terraform.tfvars` to match your environment:

   ```hcl
   vm_count       = 1
   vm_name_prefix = ""  # Auto-generates: {hostname}-{ostype}-{index}
   memory         = 2048
   vcpus          = 2
   disk_size      = 21474836480  # 20 GB
   base_image     = "../output/tonynv-ubuntu2404.qcow2"
   network_name   = "vlan200"
   ```

3. Initialize and apply:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. View your VM details:

   ```bash
   terraform output vm_names
   terraform output vm_ips
   ```

## Variables

| Name             | Description                                                    | Type     | Default                                |
|------------------|----------------------------------------------------------------|----------|----------------------------------------|
| `vm_count`       | Number of VMs to create.                                       | `number` | `1`                                    |
| `vm_name_prefix` | Override VM name prefix. If empty, defaults to {hostname}-{ostype}. | `string` | `""`                                   |
| `memory`         | RAM in MB.                                                     | `number` | `2048`                                 |
| `vcpus`          | Number of virtual CPUs.                                        | `number` | `2`                                    |
| `disk_size`      | Disk size in bytes (default 20 GB).                            | `number` | `21474836480`                          |
| `base_image`     | Path to the pre-built qcow2 base image.                       | `string` | `"../output/tonynv-ubuntu2404.qcow2"` |
| `network_name`   | Libvirt network name to attach VMs to.                         | `string` | `"vlan200"`                            |
| `ssh_public_key` | Path to SSH public key to inject into VMs.                     | `string` | `"~/.ssh/id_rsa.pub"`                 |
| `autostart`      | Auto-start VMs on host boot (required for Cockpit management). | `bool`   | `true`                                 |
| `cifs_enabled`   | Mount CIFS shares on boot.                                     | `bool`   | `true`                                 |
| `cifs_server`    | CIFS/SMB server IP or hostname.                                | `string` | `"10.0.0.100"`                         |
| `cifs_username`  | CIFS authentication username.                                  | `string` | --                                     |
| `cifs_password`  | CIFS authentication password.                                  | `string` | --                                     |

## Outputs

| Name       | Description                                |
|------------|--------------------------------------------|
| `vm_names` | Names of the created VMs.                  |
| `vm_ips`   | IP addresses of the created VMs (from DHCP). |

## Cloud-Init Configuration

Each VM is provisioned with a cloud-init ISO generated from `cloud-init.cfg`. The template uses Terraform's `templatefile()` function to inject per-VM values at plan time.

### What cloud-init configures

- **Hostname** -- set to `{vm_name_prefix}-{index}` for each VM
- **User account** -- creates a `tonynv` user with passwordless sudo and your SSH public key
- **SSH access** -- injects the public key from `ssh_public_key` (defaults to `~/.ssh/id_rsa.pub`)
- **Packages** -- installs `git`, `curl`, and `zsh` on first boot
- **Serial console** -- enables `serial-getty@ttyS0` for `virsh console` access
- **CIFS mounts** -- optionally mounts a `/sharedfs` SMB share via `/etc/fstab`
- **Dotfiles** -- clones and runs a dotfiles setup script for the `tonynv` user

### CIFS/SMB Mounts

When `cifs_enabled = true`, cloud-init will:

1. Install `cifs-utils`
2. Write SMB credentials to `/root/.smbcredentials-sharedfs` (mode `0600`)
3. Add an `/etc/fstab` entry to mount `//{cifs_server}/sharedfs` at `/sharedfs`
4. Run `mount -a` to mount the share on first boot

The mount uses `nofail,_netdev` flags so the VM still boots if the share is unavailable. To disable CIFS entirely, set `cifs_enabled = false` in your `terraform.tfvars`.
