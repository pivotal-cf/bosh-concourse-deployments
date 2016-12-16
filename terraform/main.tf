provider "google" {
    project     = "${var.project_id}"
    credentials = "${var.gcp_credentials_json}"
    region      = "${var.region}"
}

resource "google_compute_network" "bosh" {
  name = "${var.network}"
}

resource "google_compute_address" "concourse" {
  name = "concourse-ip"
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

module "concourse_subnet" {
  source                      = "./private_subnet/"

  name                        = "${var.concourse_subnet["name"]}"
  network                     = "${google_compute_network.bosh.name}"
  region                      = "${var.concourse_subnet["region"]}"
  zone                        = "${var.concourse_subnet["zone"]}"
  internal_cidr               = "${var.concourse_subnet["internal_cidr"]}"

  natbox_tag                  = "${var.concourse_subnet["name"]}-natbox"
  nat_traffic_tag             = "${var.concourse_subnet["name"]}-nat-traffic"
  trusted_cidr                = "${var.trusted_cidr}"
  allow_mbus_access_to_natbox = "${var.concourse_subnet["allow_mbus_access_to_natbox"]}"
}

module "asia_subnet" {
  source                      = "./private_subnet/"

  name                        = "${var.asia_subnet["name"]}"
  network                     = "${google_compute_network.bosh.name}"
  region                      = "${var.asia_subnet["region"]}"
  zone                        = "${var.asia_subnet["zone"]}"
  internal_cidr               = "${var.asia_subnet["internal_cidr"]}"

  natbox_tag                  = "${var.asia_subnet["name"]}-natbox"
  nat_traffic_tag             = "${var.asia_subnet["name"]}-nat-traffic"
  trusted_cidr                = "${var.trusted_cidr}"
  allow_mbus_access_to_natbox = "${var.asia_subnet["allow_mbus_access_to_natbox"]}"
}

module "jumpbox" {
  source                       = "./jumpbox/"

  name                         = "${var.concourse_subnet["name"]}-jumpbox"
  network                      = "${google_compute_network.bosh.name}"
  internal_cidr                = "${var.concourse_subnet["internal_cidr"]}"

  trusted_cidr                 = "${var.trusted_cidr}"
  allow_ssh_access_to_jumpbox  = "${var.concourse_subnet["allow_ssh_access_to_jumpbox"]}"
  allow_mbus_access_to_jumpbox = "${var.concourse_subnet["allow_mbus_access_to_jumpbox"]}"
}

module "director" {
  source                       = "./director/"

  name                         = "${var.concourse_subnet["name"]}-director"
  network                      = "${google_compute_network.bosh.name}"
  internal_cidr                = "${var.concourse_subnet["internal_cidr"]}"
  jumpbox_tag                  = "${module.jumpbox.tag}"
}
