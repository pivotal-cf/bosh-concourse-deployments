
output "gce_zone" {
    value = "${var.zone}"
}

output "director_cidr" {
    value = "${var.director_cidr}"
}

output "director_gateway" {
    value = "${cidrhost(var.director_cidr,1)}"
}

output "director_private_ip" {
    value = "${cidrhost(var.director_cidr,6)}"
}

output "director_public_ip" {
    value = "${google_compute_address.director.address}"
}

output "concourse_public_ip" {
    value = "${google_compute_address.concourse.address}"
}

output "bosh_external_tag" {
    value = "${var.bosh_external_tag}"
}

output "concourse_external_tag" {
    value = "${var.concourse_external_tag}"
}

output "bosh_internal_tag" {
    value = "${var.bosh_internal_tag}"
}

output "network_name" {
    value = "${var.network_name}"
}

output "subnetwork_name" {
    value = "${var.subnetwork_name}"
}
