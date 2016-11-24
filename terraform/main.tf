provider "google" {
    project     = "${var.google_project_id}"
    credentials = "${var.google_credentials_json}"
    region      = "${var.region}"
}

resource "google_compute_network" "bosh" {
  name = "${var.network}"
}

resource "google_compute_subnetwork" "bosh-subnet-1" {
  name          = "${var.subnetwork}"
  ip_cidr_range = "${var.internal_cidr}"
  network       = "${google_compute_network.bosh.self_link}"
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
    image = "ubuntu-1404-trusty-v20161109"
  }

  network_interface {
    subnetwork = "${var.subnetwork}"
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

// allow SSH, UAA, and BOSH traffic from `jumpbox` to Director
resource "google_compute_firewall" "bosh-jumpbox-director" {
  name    = "bosh-jumpbox-director"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "8443", "25555"]
  }

  source_tags = ["${var.jumpbox_tag}"]
  target_tags = ["${var.bosh_director_tag}"]
}

// allow BOSH ports to allow SSH tunneling from `trusted_cidr` to Director via Jumpbox
// This resource will not created by default, set `allow_director_access_via_jumpbox=1` to enable
resource "google_compute_firewall" "jumpbox-ssh" {
  count = "${var.allow_director_access_via_jumpbox}"

  name    = "jumpbox-ssh"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${var.trusted_cidr}"]
  target_tags = ["${var.jumpbox_tag}"]
}
resource "google_compute_firewall" "jumpbox-to-director" {
  count = "${var.allow_director_access_via_jumpbox}"

  name    = "jumpbox-to-director"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["6868", "8443", "25555"]
  }

  source_tags = ["${var.jumpbox_tag}"]
  target_tags = ["${var.bosh_director_tag}"]
}

// allow postgres from ATC to DB
resource "google_compute_firewall" "bosh-atc-to-db" {
  name    = "bosh-atc-to-db"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_tags = ["${var.concourse_atc_tag}"]
  target_tags = ["${var.concourse_db_tag}"]
}

// allow nats from `bosh_internal` to Director
resource "google_compute_firewall" "bosh-internal-to-director" {
  name    = "bosh-internal-to-director"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["6868"]
  }

  source_tags = ["${var.bosh_internal_tag}"]
  target_tags = ["${var.bosh_director_tag}"]
}

// allow SSH from Director to `bosh_internal`
resource "google_compute_firewall" "bosh-director-to-internal" {
  name    = "bosh-director-to-internal"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = ["${var.bosh_director_tag}"]
  target_tags = ["${var.bosh_internal_tag}"]
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
  target_tags = ["${var.concourse_atc_tag}"]
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
  target_tags = ["${var.bosh_director_tag}"]
}

// NAT
resource "google_compute_instance" "nat" {
  name         = "nat"
  machine_type = "n1-standard-1"
  zone         = "${var.zone}"

  tags = ["${var.natbox_tag}"]

  disk {
    image = "ubuntu-1404-trusty-v20161109"
  }

  network_interface {
    subnetwork = "${var.subnetwork}"
    access_config {
      // Ephemeral IP
    }
  }

  can_ip_forward = true

  metadata_startup_script = <<EOT
#!/bin/bash
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
EOT
}

resource "google_compute_route" "nat" {
  name        = "nat"
  dest_range  = "0.0.0.0/0"
  network       = "${var.network}"
  next_hop_instance = "${google_compute_instance.nat.name}"
  next_hop_instance_zone = "${var.zone}"
  priority    = 800
  tags = ["${var.nat_traffic_tag}"]
}

// allow all traffic out through NAT box
resource "google_compute_firewall" "nat-traffic" {
  name    = "bosh-nat-traffic"
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

  source_tags = ["${var.nat_traffic_tag}"]
  target_tags = ["${var.natbox_tag}"]
}

resource "google_compute_target_pool" "concourse_target_pool" {
  name = "${var.concourse_target_pool}"
}

resource "google_compute_forwarding_rule" "concourse_fowarding_rule_http" {
  name       = "concourse-forwarding-rule-http"
  target     = "${google_compute_target_pool.concourse_target_pool.self_link}"
  port_range = "80"
  ip_address = "${google_compute_address.concourse.address}"
}

resource "google_compute_forwarding_rule" "concourse_fowarding_rule_https" {
  name       = "concourse-forwarding-rule-https"
  target     = "${google_compute_target_pool.concourse_target_pool.self_link}"
  port_range = "443"
  ip_address = "${google_compute_address.concourse.address}"
}

resource "google_compute_forwarding_rule" "concourse_fowarding_rule_worker" {
  name       = "concourse-forwarding-rule-worker"
  target     = "${google_compute_target_pool.concourse_target_pool.self_link}"
  port_range = "2222"
  ip_address = "${google_compute_address.concourse.address}"
}
