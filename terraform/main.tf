provider "google" {
    project     = "${var.google_project_id}"
    credentials = "${var.google_credentials_json}"
    region      = "${var.region}"
}

resource "google_compute_network" "bosh" {
  name = "${var.network_name}"
}

resource "google_compute_subnetwork" "bosh-subnet-1" {
  name          = "${var.subnetwork_name}"
  ip_cidr_range = "${var.director_cidr}"
  network       = "${google_compute_network.bosh.self_link}"
}

resource "google_compute_address" "director" {
  name = "bosh-director-ip"
}

// allow SSH, UAA, and BOSH traffic from `trusted_cidr` to Director
resource "google_compute_firewall" "bosh-external" {
  name    = "bosh-external"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "6868", "8443", "25555"]
  }

  source_ranges = ["${var.trusted_cidr}"]
  target_tags = ["${var.bosh_external_tag}"]
}

// Allow all traffic within subnet
resource "google_compute_firewall" "bosh-internal" {
  name    = "bosh-internal"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_tags = ["${var.bosh_internal_tag}"]
}
