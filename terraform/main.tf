provider "google" {
    project     = "${var.project_id}"
    credentials = "${var.gcp_credentials_json}"
    region      = "${var.region}"
}

resource "google_compute_network" "bosh" {
  name = "${var.network}"
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

module "concourse" {
  source                       = "./concourse/"

  name                         = "${var.concourse_subnet["name"]}-concourse"
  network                      = "${google_compute_network.bosh.name}"
}
