# terraform-libvirt-vm

A reusable Terraform module for provisioning KVM/QEMU virtual machines using the [libvirt provider](https://registry.terraform.io/providers/dmacvicar/libvirt/latest).

## Features

- Provision one or more VMs from a pre-built qcow2 base image (Copy-on-Write clones)
- Auto-generated VM naming based on hypervisor hostname and OS type
- Serial console and VNC graphics support
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
| `autostart`      | Auto-start VMs on host boot (required for Cockpit management). | `bool`   | `true`                                 |

## Outputs

| Name       | Description                                |
|------------|--------------------------------------------|
| `vm_names` | Names of the created VMs.                  |
| `vm_ips`   | IP addresses of the created VMs (from DHCP). |
