output "project_id" {
    value = "${var.project_id}"
}

output "region" {
    value  = "${module.concourse_subnet.region}"
}

output "zone" {
  value = "${module.concourse_subnet.zone}"
}

output "network" {
  value = "${var.network}"
}

output "subnetwork" {
  value = "${module.concourse_subnet.name}"
}

output "internal_cidr" {
  value = "${module.concourse_subnet.internal_cidr}"
}

output "internal_gw" {
  value = "${module.concourse_subnet.internal_gw}"
}

output "natbox_internal_ip" {
  value = "${module.concourse_subnet.natbox_internal_ip}"
}

output "natbox_external_ip" {
  value = "${module.concourse_subnet.natbox_external_ip}"
}

output "natbox_tags" {
  value = ["${module.concourse_subnet.natbox_tag}"]
}

output "nat_traffic_tag" {
  value = "${module.concourse_subnet.nat_traffic_tag}"
}

output "jumpbox_tags" {
  value = ["${module.jumpbox.tag}"]
}

output "jumpbox_internal_ip" {
  value = "${module.jumpbox.internal_ip}"
}

output "jumpbox_external_ip" {
  value = "${module.jumpbox.external_ip}"
}

output "director_internal_ip" {
  value = "${module.director.internal_ip}"
}

output "director_tags" {
  value = ["${module.director.tag}", "${module.concourse_subnet.nat_traffic_tag}"]
}

output "director_internal_tag" {
  value = "${module.director.internal_tag}"
}

output "concourse_external_ip" {
  value = "${module.concourse.external_ip}"
}

output "concourse_atc_tag" {
  value = "${module.concourse.atc_tag}"
}

output "concourse_worker_tag" {
  value = "${module.concourse.worker_tag}"
}

output "concourse_db_tag" {
  value = "${module.concourse.db_tag}"
}

output "concourse_target_pool" {
  value = "${module.concourse.target_pool}"
}

output "vpn_server_external_ip" {
  value = "${google_compute_address.vpn_server.address}"
}

output "vpn_server_tag" {
  value = "${var.vpn_server_tag}"
}
