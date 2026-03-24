# Copyright (c) Red Hat, Inc.
# SPDX-License-Identifier: MPL-2.0

# This example demonstrates how to use the kubevirt-iso builder
# without instance types, by specifying CPU and memory directly.
# This is useful for clusters that do not have instance types deployed.

packer {
  required_plugins {
    kubevirt = {
      source  = "github.com/hashicorp/kubevirt"
      version = ">= 0.8.0"
    }
  }
}

variable "kube_config" {
  type    = string
  default = "${env("KUBECONFIG")}"
}

source "kubevirt-iso" "fedora" {
  # Kubernetes configuration
  kube_config   = var.kube_config
  template_name = "fedora-42"
  namespace     = "images"

  # ISO configuration
  iso_volume_name = "fedora-42-x86-64-iso"

  # VM resources (instead of instance_type)
  disk_size = "10Gi"
  memory    = "4Gi"
  cpu       = 2
  os_type   = "linux"

  # Default network configuration
  networks {
    name = "default"

    pod {}
  }

  # Files to include in the ISO installation
  media_files = [
    "./ks.cfg"
  ]

  # Boot process configuration
  boot_command = [
    "<up>e",
    "<down><down><end>",
    " inst.ks=hd:LABEL=OEMDRV:/ks.cfg",
    "<leftCtrlOn>x<leftCtrlOff>"
  ]
  boot_wait          = "10s"
  agent_wait_timeout = "15m"

  # SSH configuration
  ssh_username = "user"
  ssh_password = "root"
  ssh_timeout  = "20m"
}

build {
  sources = ["source.kubevirt-iso.fedora"]

  provisioner "shell" {
    inline = [
      "ls -la"
    ]
  }
}
