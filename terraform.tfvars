vm_count       = 1
vm_name_prefix = "" # Auto-generates: {hostname}-{ostype}-{index}
memory         = 2048
vcpus          = 2
disk_size      = 21474836480 # 20 GB
base_image     = "../output/tonynv-ubuntu2404.qcow2"
network_name   = "vlan200"
ssh_public_key = "~/.ssh/id_rsa.pub"

# CIFS mounts (enabled by default)
cifs_enabled = true
cifs_server  = "10.0.0.100"
# cifs_username and cifs_password are in secret.auto.tfvars (gitignored)

# Login banner (leave empty for default)
login_banner = ""
