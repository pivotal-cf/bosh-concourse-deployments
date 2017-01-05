output "project_id" {
  value = "${var.project_id}"
}

output "region" {
  value  = "${module.asia_subnet.region}"
}

output "zone" {
  value = "${module.asia_subnet.zone}"
}

output "network" {
  value = "${var.network}"
}

output "subnetwork" {
  value = "${module.asia_subnet.name}"
}

output "internal_cidr" {
  value = "${module.asia_subnet.internal_cidr}"
}

output "internal_gw" {
  value = "${module.asia_subnet.internal_gw}"
}

output "internal_natbox_ip" {
  value = "${module.asia_subnet.internal_natbox_ip}"
}

output "external_natbox_ip" {
  value = "${module.asia_subnet.external_natbox_ip}"
}

output "natbox_tags" {
  value = ["${module.asia_subnet.natbox_tag}"]
}

output "nat_traffic_tag" {
  value = "${module.asia_subnet.nat_traffic_tag}"
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

output "internal_worker_ip" {
  value = "${module.create_env_thru_jumpbox.internal_ip}"
}

output "worker_tags" {
  value = ["${module.create_env_thru_jumpbox.tag}", "${module.asia_subnet.nat_traffic_tag}"]
}
