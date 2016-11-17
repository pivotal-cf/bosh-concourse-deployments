
variable "google_project_id" {
    type = "string"
}

variable "google_credentials_json" {
    type = "string"
}

variable "trusted_cidr" {
    type = "string"
}

variable "director_cidr" {
    type = "string"
    default = "10.0.0.0/24"
}

variable "bosh_external_tag" {
    type = "string"
    default = "bosh-external"
}

variable "concourse_external_tag" {
    type = "string"
    default = "concourse-external"
}

variable "bosh_internal_tag" {
    type = "string"
    default = "bosh-internal"
}

variable "jumpbox_tag" {
    type = "string"
    default = "bosh-jumpbox"
}

variable "natbox_tag" {
    type = "string"
    default = "bosh-natbox"
}

variable "nat_traffic_tag" {
    type = "string"
    default = "bosh-nat-traffic"
}
variable "network_name" {
    type = "string"
    default = "concourse"
}

variable "subnetwork_name" {
    type = "string"
    default = "concourse"
}

variable "zone" {
    type = "string"
    default = "us-west1-b"
}

variable "region" {
    type = "string"
    default = "us-west1"
}

variable "concourse_target_pool" {
    type = "string"
    default = "concourse-target-pool"
}
