source "proxmox-iso" "ubuntu" {
  proxmox_url               = "https://${var.site}:8006/api2/json"
  username                  = "${var.username}"
  token                     = "${var.token}"
  insecure_skip_tls_verify  = true
  node                      = var.node
  vm_id                     = var.vmid
  vm_name                   = var.template
  template_description      = var.description

  iso_file                  = "${var.storage}:${var.iso}"
  iso_storage_pool          = var.storage
  unmount_iso               = true
  qemu_agent                = true

  scsi_controller           = "virtio-scsi-pci"
  bios                      = "ovmf"

  cores                     = "2"
  sockets                   = "1"
  memory                    = "4096"

  cloud_init                = true
  cloud_init_storage_pool   = var.storage

  vga {
    type                    = "virtio"
  }

  disks {
    disk_size               = "30G"
    format                  = "qcow2"
    storage_pool            = var.storage
    type                    = "scsi"
  }

  efi_config {
    efi_type                = "4m"
    efi_storage_pool        = var.storage
    pre_enrolled_keys       = true
  }

  network_adapters {
    model                   = "virtio"
    bridge                  = "vmbr0"
    firewall                = "true"
  }

  boot_command = [
      "c",
      "linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
      "<enter><wait>",
      "initrd /casper/initrd <enter><wait5s>",
      "boot<enter><wait5s>"
  ]
  
  boot_wait                 = "6s"
  communicator              = "ssh"

  http_directory            = "http"

  ssh_username              = "ubuntu"
  ssh_password              = "ubuntu"

  # Raise the timeout, when installation takes longer
  ssh_timeout               = "20m"
  ssh_pty                   = true
  ssh_handshake_attempts    = 15
}

build {

  name    = "ubuntu-jammy-2204"
  sources = [
      "source.proxmox-iso.ubuntu"
  ]

  # Waiting for Cloud-Init to finish
  provisioner "shell" {
    inline = ["cloud-init status --wait"]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  provisioner "shell" {
    execute_command = "echo -e '<user>' | sudo -S -E bash '{{ .Path }}'"
    inline = [
      "echo 'Starting Stage: Provisioning the VM Template for Cloud-Init Integration in Proxmox'",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync",
      "echo 'Done Stage: Provisioning the VM Template for Cloud-Init Integration in Proxmox'"
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }
  provisioner "shell" {
    inline = ["sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"]
  }
  provisioner "shell" {
    inline = [
      "echo '########## Install the packages ##########'",
      "sudo apt update",
      "sudo apt install -y ca-certificates curl",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      # Add the repository to Apt sources :
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt update",
      "DEBIAN_FRONTEND=noninteractive sudo -E sh -c 'apt install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null '",
    ]
  }
}