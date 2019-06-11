// INPUTS
variable "allow_ssh_access_to_jumpbox" {
  default     = 0
  description = "Set to `1` to allow SSH from `trusted_cidrs` to the jumpbox. This should only be done temporarily for debugging or tunneling."
}

variable "allow_mbus_access_to_jumpbox" {
  default     = 0
  description = "Set to `1` to allow mbus traffic on 6868 from `trusted_cidrs` to the jumpbox. This should only be done temporarily to upgrade the jumpbox."
}

variable "allow_internal_management" {
  default     = 0
  description = "Set to `1` to allow SSH and RDP traffic from Jumpbox VM to management tagged VMs."
}

variable "create_env_trusted_cidrs" {
  type = list(string)
}

variable "ssh_trusted_cidrs" {
  type = list(string)
}

variable "network" {
}

variable "internal_cidr" {
}

variable "name" {
}

resource "google_compute_address" "jumpbox" {
  name = "${var.name}-ip"
}

// allow BOSH ports to allow SSH tunneling from `ssh_trusted_cidrs` to Director via Jumpbox
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

  source_ranges = var.ssh_trusted_cidrs
  target_tags   = [var.name]
}

// allow 6868 from `create_env_trusted_cidrs` to Jumpbox
// This resource will not created by default, set `allow_mbus_access_to_jumpbox=1` to enable
resource "google_compute_firewall" "mbus-jumpbox" {
  count = var.allow_mbus_access_to_jumpbox

  name    = "${var.name}-mbus"
  network = var.network

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["6868"]
  }

  source_ranges = var.create_env_trusted_cidrs
  target_tags   = [var.name]
}

// allow SSH and RDP from Jumpbox to internal VM's
resource "google_compute_firewall" "jumpbox-internal-management" {
  count = var.allow_internal_management

  name    = "bosh-director-to-internal"
  network = var.network

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_tags = [var.name]
  target_tags = ["${var.name}-management"]
}

output "tag" {
  value = var.name
}

output "internal_management_tag" {
  value = "${var.name}-management"
}

output "internal_ip" {
  value = cidrhost(var.internal_cidr, 5)
}

output "external_ip" {
  value = google_compute_address.jumpbox.address
}

