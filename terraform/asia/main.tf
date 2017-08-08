provider "google" {
    project     = "${var.project_id}"
    credentials = "${var.gcp_credentials_json}"
    region      = "${var.region}"
}

module "asia_subnet" {
  source                      = "../modules/private_subnet/"

  name                        = "${var.name}"
  network                     = "${var.network}"
  region                      = "${var.region}"
  zone                        = "${var.zone}"
  internal_cidr               = "${var.internal_cidr}"

  natbox_tag                  = "${var.name}-natbox"
  nat_traffic_tag             = "${var.name}-nat-traffic"
  trusted_cidrs               = "${split(",", var.trusted_cidrs)}"
  allow_mbus_access_to_natbox = "${var.allow_mbus_access_to_natbox}"
}

resource "google_compute_firewall" "nat-atc-traffic" {
  name    = "${var.name}-nat-to-atc-traffic"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["443", "2222"]
  }

  source_ranges = ["${module.asia_subnet.natbox_external_ip}/32"]
  target_tags = ["${var.concourse_atc_tag}"]
}

module "jumpbox" {
  source                       = "../modules/jumpbox/"

  name                         = "${var.name}-jumpbox"
  network                      = "${var.network}"
  internal_cidr                = "${var.internal_cidr}"

  trusted_cidrs                = "${split(",", var.trusted_cidrs)}"
  allow_ssh_access_to_jumpbox  = "${var.allow_ssh_access_to_jumpbox}"
  allow_mbus_access_to_jumpbox = "${var.allow_mbus_access_to_jumpbox}"
}

module "create_env_thru_jumpbox" {
  source                       = "../modules/create_env_thru_jumpbox/"

  name                         = "${var.name}-concourse-worker"
  network                      = "${var.network}"
  internal_cidr                = "${var.internal_cidr}"
  jumpbox_tag                  = "${module.jumpbox.tag}"
}
