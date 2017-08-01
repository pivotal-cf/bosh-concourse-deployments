// INPUTS
variable "allow_ssh_access_to_jumpbox" {
  default = 0
  description = "Set to `1` to allow SSH from `trusted_cidrs` to the jumpbox. This should only be done temporarily for debugging or tunneling."
}
variable "allow_mbus_access_to_jumpbox" {
  default = 0
  description = "Set to `1` to allow mbus traffic on 6868 from `trusted_cidrs` to the jumpbox. This should only be done temporarily to upgrade the jumpbox."
}
variable "trusted_cidrs" {
  type = "list"
}
variable "network" {}
variable "internal_cidr" {}
variable "name" {}

resource "google_compute_address" "jumpbox" {
  name = "${var.name}-ip"
}

// allow BOSH ports to allow SSH tunneling from `trusted_cidrs` to Director via Jumpbox
// This resource will not created by default, set `allow_ssh_access_to_jumpbox=1` to enable
resource "google_compute_firewall" "jumpbox-ssh" {
  count = "${var.allow_ssh_access_to_jumpbox}"

  name    = "${var.name}-ssh"
  network = "${var.network}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${var.trusted_cidrs}"]
  target_tags = ["${var.network}-jumpbox"]
}

// allow 6868 from `trusted_cidrs` to Jumpbox
// This resource will not created by default, set `allow_mbus_access_to_jumpbox=1` to enable
resource "google_compute_firewall" "mbus-jumpbox" {
  count = "${var.allow_mbus_access_to_jumpbox}"

  name    = "${var.name}-mbus"
  network = "${var.network}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["6868"]
  }

  source_ranges = ["${var.trusted_cidrs}"]
  target_tags = ["${var.name}"]
}

output "tag" {
  value = "${var.name}"
}

output "internal_ip" {
  value = "${cidrhost(var.internal_cidr,5)}"
}

output "external_ip" {
  value = "${google_compute_address.jumpbox.address}"
}
