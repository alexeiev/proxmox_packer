variable "username" {
  type        = string
  description = "User for authentication"
}

variable "token" {
  type        = string
  sensitive   = true
  description = "Token for authentication"
}

variable "site" {
  type        = string
  description = "Proxmox URL"
}

variable "vmid" {
  type = number
  description = "VM identification number for template"
}

variable "node" {
  type        = string
  description = "Node name in cluster Proxmox"
}

variable "storage" {
  type        = string
  description = "Storage name in cluster Proxmox"
}

variable "iso" {
  type        = string
  description = "Full path the ISO in storage the cluster Proxmox"
}

variable "template" {
  type        = string
  description = "Name fof the new template"
}

variable "description" {
  type        = string
  default     = "Template"
  description = "Description for new template"
}

packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}
