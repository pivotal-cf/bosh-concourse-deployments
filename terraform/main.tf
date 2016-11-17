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

resource "google_compute_address" "concourse" {
  name = "concourse-ip"
}


resource "google_compute_address" "jumpbox" {
  name = "jumpbox-ip"
}

resource "google_compute_instance" "jumpbox" {
  name         = "bosh-jumpbox"
  machine_type = "n1-standard-1"
  zone         = "${var.zone}"

  tags = ["${var.jumpbox_tag}"]

  disk {
    image = "ubuntu-1604-xenial-v20161115"
  }

  network_interface {
    subnetwork = "${var.subnetwork_name}"
    access_config {
      nat_ip = "${google_compute_address.jumpbox.address}"
    }
  }

  metadata_startup_script = <<EOT
#!/bin/bash
set -e

apt-get update
apt-get install -y jq

version=$(curl -s https://api.github.com/repos/cloudfoundry/bosh-cli/releases/latest | jq -r .tag_name | sed -e "s/^v//")
wget -O /usr/local/bin/bosh https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-$version-linux-amd64
chmod +x /usr/local/bin/bosh
EOT
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

// Allow Concourse access
resource "google_compute_firewall" "concourse-external" {
  name    = "concourse-external"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "2222"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["${var.concourse_external_tag}"]
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

// allow nothing, open SSH manually for access
resource "google_compute_firewall" "jumpbox-external" {
  name    = "jumpbox-external"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "icmp"
  }

  source_ranges = ["${var.trusted_cidr}"]
  target_tags = ["${var.jumpbox_tag}"]
}

// allow SSH from jumpbox to Director
resource "google_compute_firewall" "jumpbox-internal" {
  name    = "jumpbox-internal"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["${var.jumpbox_tag}"]
  target_tags = ["${var.bosh_external_tag}"]
}
