output "project_id" {
    value = "${var.project_id}"
}

output "zone" {
    value = "${var.zone}"
}

output "asia_zone" {
    value = "${var.asia_zone}"
}

output "network" {
    value = "${var.network}"
}

output "us_subnetwork" {
    value = "${var.us_subnetwork}"
}

output "asia_subnetwork" {
    value = "${var.asia_subnetwork}"
}

output "internal_cidr" {
    value = "${var.internal_cidr}"
}

output "internal_gw" {
    value = "${cidrhost(var.internal_cidr,1)}"
}

output "internal_director_ip" {
    value = "${cidrhost(var.internal_cidr,6)}"
}

output "internal_jumpbox_ip" {
    value = "${cidrhost(var.internal_cidr,5)}"
}

output "internal_natbox_ip" {
    value = "${cidrhost(var.internal_cidr,4)}"
}

output "external_jumpbox_ip" {
    value = "${google_compute_address.jumpbox.address}"
}

output "external_concourse_ip" {
    value = "${google_compute_address.concourse.address}"
}

output "director_tags" {
    value = ["${var.bosh_director_tag}", "${var.nat_traffic_tag}"]
}

output "concourse_atc_tags" {
    value = ["${var.concourse_atc_tag}", "${var.nat_traffic_tag}"]
}

output "concourse_worker_tags" {
    value = ["${var.nat_traffic_tag}"]
}

output "concourse_db_tags" {
    value = ["${var.concourse_db_tag}"]
}

output "bosh_internal_tag" {
    value = "${var.bosh_internal_tag}"
}

output "nat_traffic_tag" {
    value = "${var.nat_traffic_tag}"
}

output "concourse_target_pool" {
    value = "${var.concourse_target_pool}"
}

output "external_nat_ip" {
  value = "${google_compute_address.nat.address}"
}

output "natbox_tags" {
  value = ["${var.natbox_tag}"]
}

output "jumpbox_tags" {
  value = ["${var.jumpbox_tag}"]
}
