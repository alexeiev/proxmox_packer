# Create Template VM in Proxmox 

How to create templates with HashiCorp Packer in the Proxmox. 
As an example, we will create an image to use Docker with Ubuntu 22.04.

## Requirements

[HashiCorp Packer](https://developer.hashicorp.com/packer/install)


## Providers

| Name | Version |
|------|---------|
|[proxmox](https://github.com/hashicorp/packer-plugin-proxmox)|1.1.3|


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
|username|Username for authentication on the Proxmox|`string`|| yes |
|token|Token for authentication on the Proxmox ( **sensitive**)|`string`|  | yes |
|site|Proxmox URL|`string`| | yes|
|vmid|VM identification number for template |`number`||yes|
|node|Node name in cluster Proxmox |`string`| |yes|
|storage|Storage name in cluster Proxmox|`string`| |yes|
|iso|Full path the ISO in storage the cluster Proxmox|`string`| |yes|
|template|Name fof the new template|`string`| | yes|
|description|Description for new template|`string`| Template | no 


Clone this repository 
```bash
git clone https://github.com/alexeiev/proxmox_packer.git
cd proxmox_packer
```

Create file .auto.pkrvars.hcl with this content

```bash
cat <<EOF>> .auto.pkrvars.hcl
username    =  "root@pam!terraform"
token       = "XXX"
site        =  "IP or NAME"
node        = ""
storage     = ""
iso         = "iso/ubuntu-22.04.3-live-server-amd64.iso"
vmid        = 9001
template    = "ubuntu-22.04-Base_docker_image"
description = ""
EOF
```

Customize the file with its variables.



To add new packages to the image, you can modify the *build_image.pkr.hcl* file right after the **### Install the package ###** by following the template shown.

Example:
```bash
provisioner "shell" {
    inline = [
      "echo '########## Install the packages ##########'",
      "sudo apt update",
      "DEBIAN_FRONTEND=noninteractive sudo -E sh -c 'apt install -y -qq Package > /dev/null '",
    ]
  }
```
Execute to build (in the directory)

```bash
packer build .
```
