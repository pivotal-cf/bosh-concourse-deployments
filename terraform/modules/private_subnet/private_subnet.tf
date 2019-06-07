// INPUTS
variable "region" {
  default = "us-west1"
}

variable "zone" {
  default = "us-west1-b"
}

variable "network" {
}

variable "name" {
}

variable "internal_cidr" {
}

variable "create_env_trusted_cidrs" {
  type = list(string)
}

variable "nat_traffic_tag" {
}

variable "natbox_tag" {
}

variable "allow_mbus_access_to_natbox" {
  description = "Set to `1` to allow traffic on 6868 from `create_env_trusted_cidrs` to the natbox. This should only be done temporarily to upgrade the natbox."
  default     = 0
}

resource "google_compute_subnetwork" "bosh-subnet" {
  name          = var.name
  ip_cidr_range = var.internal_cidr
  network       = var.network
  region        = var.region
}

resource "google_compute_address" "nat" {
  name   = "${var.name}-nat-external-ip"
  region = var.region
}

// allow 6868 from `create_env_trusted_cidrs` to Natbox
// This resource will not created by default, set `allow_mbus_access_to_natbox=1` to enable
resource "google_compute_firewall" "mbus-natbox" {
  count = var.allow_mbus_access_to_natbox

  name    = "${var.name}-natbox-mbus"
  network = var.network

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["6868"]
  }

  source_ranges = var.create_env_trusted_cidrs
  target_tags   = [var.natbox_tag]
}

resource "google_compute_route" "nat" {
  name        = "${var.name}-nat"
  dest_range  = "0.0.0.0/0"
  network     = var.network
  next_hop_ip = cidrhost(google_compute_subnetwork.bosh-subnet.ip_cidr_range, 4)
  priority    = 800
  tags        = [var.nat_traffic_tag]
}

// allow all traffic out through NAT box
resource "google_compute_firewall" "nat-traffic" {
  name    = "${var.name}-bosh-nat-traffic"
  network = var.network

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_tags = [var.nat_traffic_tag]
  target_tags = [var.natbox_tag]
}

output "region" {
  value = var.region
}

output "zone" {
  value = var.zone
}

output "network" {
  value = var.network
}

output "name" {
  value = var.name
}

output "internal_cidr" {
  value = var.internal_cidr
}

output "internal_gw" {
  value = cidrhost(var.internal_cidr, 1)
}

output "natbox_external_ip" {
  value = google_compute_address.nat.address
}

output "natbox_internal_ip" {
  value = cidrhost(var.internal_cidr, 4)
}

output "nat_traffic_tag" {
  value = var.nat_traffic_tag
}

output "natbox_tag" {
  value = var.natbox_tag
}
