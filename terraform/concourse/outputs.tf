output "project_id" {
  value = var.project_id
}

output "region" {
  value = module.concourse_subnet.region
}

output "zone" {
  value = module.concourse_subnet.zone
}

output "asia" {
  value = {
    zone       = var.asia_zone
    subnetwork = google_compute_subnetwork.asia-bosh-subnet.name
  }
}

output "network" {
  value = var.network
}

output "subnetwork" {
  value = module.concourse_subnet.name
}

output "windows_subnetwork" {
  value = var.windows_subnetwork
}

output "windows_internal_gw" {
  value = cidrhost(var.windows_internal_cidr, 1)
}

output "internal_cidr" {
  value = module.concourse_subnet.internal_cidr
}

output "windows_internal_cidr" {
  value = var.windows_internal_cidr
}

output "internal_gw" {
  value = module.concourse_subnet.internal_gw
}

output "natbox_internal_ip" {
  value = module.concourse_subnet.natbox_internal_ip
}

output "natbox_external_ip" {
  value = module.concourse_subnet.natbox_external_ip
}

output "natbox_tags" {
  value = [module.concourse_subnet.natbox_tag]
}

output "nat_traffic_tag" {
  value = module.concourse_subnet.nat_traffic_tag
}

output "jumpbox_tags" {
  value = [module.jumpbox.tag]
}

output "jumpbox_internal_management_tag" {
  value = module.jumpbox.internal_management_tag
}

output "jumpbox_internal_ip" {
  value = module.jumpbox.internal_ip
}

output "jumpbox_external_ip" {
  value = module.jumpbox.external_ip
}

output "director_internal_ip" {
  value = module.director.internal_ip
}

output "director_api_access_tag" {
  value = module.director.api_access_tag
}

output "director_tags" {
  value = [module.director.tag, module.concourse_subnet.nat_traffic_tag]
}

output "director_internal_tag" {
  value = module.director.internal_tag
}

# Concourse BOSH CPI outputs
output "bosh_cpi" {
  value = {
    external_ip = module.concourse.external_ip
    atc_tag     = module.concourse.atc_tag
    db_tag      = module.concourse.db_tag
    target_pool = module.concourse.target_pool
    worker_tag  = module.concourse.worker_tag
  }
}

# Concourse BOSH core outputs
output "bosh_core" {
  value = {
    external_ip = module.concourse_core.external_ip
    atc_tag     = module.concourse_core.atc_tag
    db_tag      = module.concourse_core.db_tag
    target_pool = module.concourse_core.target_pool
    worker_tag  = module.concourse_core.worker_tag
  }
}

output "vpn_server_external_ip" {
  value = google_compute_address.vpn_server.address
}

output "vpn_server_tag" {
  value = var.vpn_server_tag
}

