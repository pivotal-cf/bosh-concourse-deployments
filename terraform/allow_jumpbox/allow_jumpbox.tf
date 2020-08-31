// INPUTS
variable "project_id" {
}

variable "gcp_credentials_json" {
}

variable "region" {
  default = "us-west1"
}

variable "allow_ssh_access_to_jumpbox" {
  default     = 0
  description = "Set to `1` to allow SSH from `trusted_cidrs` to the jumpbox. This should only be done temporarily for debugging or tunneling."
}

variable "allow_mbus_access_to_jumpbox" {
  default     = 0
  description = "Set to `1` to allow mbus traffic on 6868 from `trusted_cidrs` to the jumpbox. This should only be done temporarily to upgrade the jumpbox."
}

variable "trusted_cidrs" {
  type = string
}

variable "network" {
  default = "concourse"
}

variable "name" {
}

provider "google" {
  project     = var.project_id
  credentials = var.gcp_credentials_json
  region      = var.region
}

// allow BOSH ports to allow SSH tunneling from `trusted_cidrs` to Director via Jumpbox
// This resource will not created by default, set `allow_ssh_access_to_jumpbox=1` to enable
resource "google_compute_firewall" "jumpbox-ssh" {
  count = var.allow_ssh_access_to_jumpbox

  name    = "${var.name}-ssh"
  network = var.network

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.network}-jumpbox"]
}

