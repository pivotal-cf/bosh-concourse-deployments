variable "name" {}
variable "network" {}
variable "trusted_cidrs" {
  type = "list"
}
variable "internal_cidr" {}
variable "vpn_server_tag" {}

resource "google_compute_address" "concourse" {
  name = "${var.name}-ip"
}

// allow connection from ATC to DB
resource "google_compute_firewall" "bosh-atc-to-db" {
  name    = "${var.name}-atc-to-db"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_tags = ["${var.name}-atc"]
  target_tags = ["${var.name}-db"]
}

// allow connection from ATC to ATC
resource "google_compute_firewall" "bosh-atc-to-atc" {
  name    = "${var.name}-atc-to-atc"
  network = "${var.network}"

  allow {
    protocol = "tcp"
  }

  source_tags = ["${var.name}-atc"]
  target_tags = ["${var.name}-atc"]
}

// Allow Concourse access
resource "google_compute_firewall" "concourse-external" {
  name    = "${var.name}-external"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "2222"]
  }

  source_ranges = ["${var.trusted_cidrs}"]
  target_tags = ["${google_compute_firewall.bosh-atc-to-db.source_tags[0]}"]
}

// Allow external worker communication
resource "google_compute_firewall" "concourse-worker" {
  name    = "${var.name}-worker-to-atc"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "2222"]
  }

  source_tags = ["${var.name}-worker"]
  target_tags = ["${var.name}-atc"]
}

resource "google_compute_target_pool" "concourse_target_pool" {
  name = "${var.name}"
}

resource "google_compute_forwarding_rule" "concourse_forwarding_rule_http" {
  name       = "${var.name}-forwarding-rule-http"
  target     = "${google_compute_target_pool.concourse_target_pool.self_link}"
  port_range = "80-80"
  ip_address = "${google_compute_address.concourse.address}"
}

resource "google_compute_forwarding_rule" "concourse_forwarding_rule_https" {
  name       = "${var.name}-forwarding-rule-https"
  target     = "${google_compute_target_pool.concourse_target_pool.self_link}"
  port_range = "443-443"
  ip_address = "${google_compute_address.concourse.address}"
}

resource "google_compute_forwarding_rule" "concourse_forwarding_rule_worker" {
  name       = "${var.name}-forwarding-rule-worker"
  target     = "${google_compute_target_pool.concourse_target_pool.self_link}"
  port_range = "2222-2222"
  ip_address = "${google_compute_address.concourse.address}"
}

output "external_ip" {
  value = "${google_compute_address.concourse.address}"
}
output "atc_tag" {
  value = "${google_compute_firewall.bosh-atc-to-db.source_tags[0]}"
}
output "worker_tag" {
  value = "${google_compute_firewall.concourse-worker.source_tags[0]}"
}
output "db_tag" {
  value = "${google_compute_firewall.bosh-atc-to-db.target_tags[0]}"
}
output "target_pool" {
  value = "${var.name}"
}
