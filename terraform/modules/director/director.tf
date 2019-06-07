variable "name" {
}

variable "network" {
}

variable "jumpbox_tag" {
}

variable "internal_cidr" {
}

// allow SSH, UAA, and BOSH traffic from `jumpbox` to Director
resource "google_compute_firewall" "bosh-jumpbox-director" {
  name    = "${var.name}-jumpbox-to-director"
  network = var.network

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "6868", "8443", "25555"]
  }

  source_tags = [var.jumpbox_tag]
  target_tags = [var.name]
}

// allow nats and blobstore from `bosh_internal` to Director
resource "google_compute_firewall" "bosh-internal-to-director" {
  name    = "${var.name}-internal-to-director"
  network = var.network

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["4222", "25250"]
  }

  source_tags = ["${var.name}-internal"]
  target_tags = [var.name]
}

// allow tagged vms to access director api
resource "google_compute_firewall" "api-access" {
  name    = "${var.name}-api-access"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["8443", "25555"]
  }

  source_tags = ["${var.name}-api-access"]
  target_tags = [var.name]
}

output "tag" {
  value = var.name
}

output "internal_tag" {
  value = "${var.name}-internal"
}

output "api_access_tag" {
  value = "${var.name}-api-access"
}

output "internal_ip" {
  value = cidrhost(var.internal_cidr, 6)
}
