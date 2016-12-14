provider "google" {
    project     = "${var.project_id}"
    credentials = "${var.gcp_credentials_json}"
    region      = "${var.region}"
}

resource "google_compute_network" "bosh" {
  name = "${var.network}"
}

resource "google_compute_subnetwork" "bosh-subnet-1" {
  name          = "${var.us_subnetwork}"
  ip_cidr_range = "${var.internal_cidr}"
  network       = "${google_compute_network.bosh.self_link}"
}

resource "google_compute_address" "concourse" {
  name = "concourse-ip"
}

resource "google_compute_address" "nat" {
  name = "nat-external-ip"
}

resource "google_compute_address" "jumpbox" {
  name = "jumpbox-ip"
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
// This resource will not created by default, set `allow_ssh_access_to_jumpbox=1` to enable
resource "google_compute_firewall" "jumpbox-ssh" {
  count = "${var.allow_ssh_access_to_jumpbox}"

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

// allow 6868 from `trusted_cidr` to Natbox
// This resource will not created by default, set `allow_mbus_access_to_natbox=1` to enable
resource "google_compute_firewall" "mbus-natbox" {
  count = "${var.allow_mbus_access_to_natbox}"

  name    = "natbox-mbus"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["6868"]
  }

  source_ranges = ["${var.trusted_cidr}"]
  target_tags = ["${var.natbox_tag}"]
}

// allow 6868 from `trusted_cidr` to Jumpbox
// This resource will not created by default, set `allow_mbus_access_to_jumpbox=1` to enable
resource "google_compute_firewall" "mbus-jumpbox" {
  count = "${var.allow_mbus_access_to_jumpbox}"

  name    = "jumpbox-mbus"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["6868"]
  }

  source_ranges = ["${var.trusted_cidr}"]
  target_tags = ["${var.jumpbox_tag}"]
}

resource "google_compute_firewall" "jumpbox-to-director" {
  count = "${var.allow_ssh_access_to_jumpbox}"

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

// allow nats and blobstore from `bosh_internal` to Director
resource "google_compute_firewall" "bosh-internal-to-director" {
  name    = "bosh-internal-to-director"
  network = "${google_compute_network.bosh.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["4222", "25250"]
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

resource "google_compute_route" "nat" {
  name        = "nat"
  dest_range  = "0.0.0.0/0"
  network     = "${var.network}"
  next_hop_ip = "${cidrhost(var.internal_cidr,4)}"
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
  port_range = "80-80"
  ip_address = "${google_compute_address.concourse.address}"
}

resource "google_compute_forwarding_rule" "concourse_fowarding_rule_https" {
  name       = "concourse-forwarding-rule-https"
  target     = "${google_compute_target_pool.concourse_target_pool.self_link}"
  port_range = "443-443"
  ip_address = "${google_compute_address.concourse.address}"
}

resource "google_compute_forwarding_rule" "concourse_fowarding_rule_worker" {
  name       = "concourse-forwarding-rule-worker"
  target     = "${google_compute_target_pool.concourse_target_pool.self_link}"
  port_range = "2222-2222"
  ip_address = "${google_compute_address.concourse.address}"
}
