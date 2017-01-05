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

output "internal_natbox_ip" {
  value = "${module.concourse_subnet.internal_natbox_ip}"
}

output "external_natbox_ip" {
  value = "${module.concourse_subnet.external_natbox_ip}"
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

output "internal_jumpbox_ip" {
  value = "${module.jumpbox.internal_ip}"
}

output "external_jumpbox_ip" {
  value = "${module.jumpbox.external_ip}"
}

output "internal_director_ip" {
  value = "${module.director.internal_ip}"
}

output "director_tags" {
  value = ["${module.director.tag}", "${module.concourse_subnet.nat_traffic_tag}"]
}

output "director_internal_tag" {
  value = "${module.director.internal_tag}"
}

output "external_concourse_ip" {
  value = "${module.concourse.external_ip}"
}

output "concourse_atc_tags" {
  value = ["${module.concourse.atc_tag}"]
}

output "concourse_db_tags" {
  value = ["${module.concourse.db_tag}"]
}

output "concourse_target_pool" {
  value = ["${module.concourse.target_pool}"]
}
