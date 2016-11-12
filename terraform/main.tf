provider "google" {
    project     = "${var.project_id}"
    credentials = "${var.gcp_credentials_json}"
    region      = "us-west1"
}

resource "google_compute_network" "bosh" {
  name = "bosh"
}

resource "google_compute_subnetwork" "bosh-subnet-1" {
  name          = "bosh"
  ip_cidr_range = "10.0.0.0/24"
  network       = "${google_compute_network.bosh.self_link}"
}

resource "google_compute_address" "director" {
  name = "bosh-director-ip"
}

resource "google_compute_address" "concourse" {
  name = "concourse-ip"
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
  target_tags = ["bosh-external"]
}

resource "google_compute_firewall" "concourse-external" {
  name    = "concourse-external"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "2222"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["concourse-external"]
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
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }

  source_tags = ["bosh-internal"]
}
