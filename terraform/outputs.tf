output "project_id" {
    value = "${var.project_id}"
}

output "concourse_subnet" {
  value = {
    region  = "${module.concourse_subnet.region}"
    zone    = "${module.concourse_subnet.zone}"

    network = "${var.network}"
    subnetwork = "${module.concourse_subnet.name}"
    internal_cidr = "${module.concourse_subnet.internal_cidr}"
    internal_gw = "${module.concourse_subnet.internal_gw}"
    internal_cidr = "${module.concourse_subnet.internal_cidr}"
    internal_natbox_ip = "${module.concourse_subnet.internal_natbox_ip}"
    external_natbox_ip = "${module.concourse_subnet.external_natbox_ip}"

    natbox_tags = "${jsonencode(list(module.concourse_subnet.natbox_tag))}"
    nat_traffic_tag = "${module.concourse_subnet.nat_traffic_tag}"
    project_id = "${var.project_id}"

    jumpbox_tag = "${module.jumpbox.tag}"
    internal_jumpbox_ip = "${module.jumpbox.internal_ip}"
    external_jumpbox_ip = "${module.jumpbox.external_ip}"

    internal_director_ip  = "${module.director.internal_ip}"
    director_tags         = "${jsonencode(list(module.director.tag))}"
    director_internal_tag = "${module.director.internal_tag}"
  }
}

output "asia_subnet" {
  value = {
    region  = "${module.asia_subnet.region}"
    zone    = "${module.asia_subnet.zone}"

    network = "${var.network}"
    subnetwork = "${module.asia_subnet.name}"
    internal_cidr = "${module.asia_subnet.internal_cidr}"
    internal_gw = "${module.asia_subnet.internal_gw}"
    internal_cidr = "${module.asia_subnet.internal_cidr}"
    internal_natbox_ip = "${module.asia_subnet.internal_natbox_ip}"
    external_natbox_ip = "${module.asia_subnet.external_natbox_ip}"

    natbox_tags = "${jsonencode(list(module.asia_subnet.natbox_tag))}"
    nat_traffic_tag = "${module.asia_subnet.nat_traffic_tag}"
    project_id = "${var.project_id}"
  }
}

output "network" {
    value = "${var.network}"
}

output "external_concourse_ip" {
    value = "${google_compute_address.concourse.address}"
}

output "director_tags" {
    value = ["${var.bosh_director_tag}", "${module.concourse_subnet.nat_traffic_tag}"]
}

output "concourse_atc_tags" {
    value = ["${var.concourse_atc_tag}", "${module.concourse_subnet.nat_traffic_tag}"]
}

output "concourse_worker_tags" {
    value = ["${module.concourse_subnet.nat_traffic_tag}"]
}

output "concourse_db_tags" {
    value = ["${var.concourse_db_tag}"]
}

output "bosh_internal_tag" {
    value = "${var.bosh_internal_tag}"
}

output "concourse_target_pool" {
    value = "${var.concourse_target_pool}"
}
