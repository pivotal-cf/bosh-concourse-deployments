provider "google" {
    project     = "${var.project_id}"
    credentials = "${var.gcp_credentials_json}"
    region      = "${var.region}"
}

resource "google_compute_network" "bosh" {
  name = "${var.network}"
}

module "concourse_subnet" {
  source                      = "../modules/private_subnet/"

  name                        = "${var.name}"
  network                     = "${google_compute_network.bosh.name}"
  region                      = "${var.region}"
  zone                        = "${var.zone}"
  internal_cidr               = "${var.internal_cidr}"

  natbox_tag                  = "${var.name}-natbox"
  nat_traffic_tag             = "${var.name}-nat-traffic"
  trusted_cidr                = "${var.trusted_cidr}"
  allow_mbus_access_to_natbox = "${var.allow_mbus_access_to_natbox}"
}

module "jumpbox" {
  source                       = "../modules/jumpbox/"

  name                         = "${var.name}-jumpbox"
  network                      = "${google_compute_network.bosh.name}"
  internal_cidr                = "${var.internal_cidr}"

  trusted_cidr                 = "${var.trusted_cidr}"
  allow_ssh_access_to_jumpbox  = "${var.allow_ssh_access_to_jumpbox}"
  allow_mbus_access_to_jumpbox = "${var.allow_mbus_access_to_jumpbox}"
}

module "director" {
  source                       = "../modules/director/"

  name                         = "${var.name}-director"
  network                      = "${google_compute_network.bosh.name}"
  internal_cidr                = "${var.internal_cidr}"
  jumpbox_tag                  = "${module.jumpbox.tag}"
}

module "concourse" {
  source                       = "../modules/concourse/"

  name                         = "${var.name}-concourse"
  network                      = "${google_compute_network.bosh.name}"
}
