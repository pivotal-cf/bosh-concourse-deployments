variable "name" {}
variable "network" {}
variable "jumpbox_tag" {}
variable "internal_cidr" {}
variable "ip_offset" {
  default = 7
}

// allow SSH and mbus traffic from `jumpbox` to VM
resource "google_compute_firewall" "bosh-jumpbox-to-vm" {
  name    = "${var.name}-jumpbox-to-vm"
  network = "${var.network}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "6868"]
  }

  source_tags = ["${var.jumpbox_tag}"]
  target_tags = ["${var.name}"]
}

output "tag" {
  value = "${var.name}"
}
output "internal_ip" {
  value = "${cidrhost(var.internal_cidr,var.ip_offset)}"
}
