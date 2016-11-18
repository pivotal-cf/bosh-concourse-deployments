
output "zone" {
    value = "${var.zone}"
}

output "network" {
    value = "${var.network}"
}

output "subnetwork" {
    value = "${var.subnetwork}"
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

output "director_external_ip" {
    value = "${google_compute_address.director.address}"
}

output "concourse_public_ip" {
    value = "${google_compute_address.concourse.address}"
}

output "director_tags" {
    value = ["${var.bosh_director_tag}"]
}

output "concourse_atc_tag" {
    value = "${var.concourse_atc_tag}"
}

output "concourse_db_tag" {
    value = "${var.concourse_db_tag}"
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
