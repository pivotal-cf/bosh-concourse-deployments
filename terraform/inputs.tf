
variable "project_id" {
    type = "string"
}

variable "gcp_credentials_json" {
    type = "string"
}

variable "trusted_cidr" {
    type = "string"
}

variable "allow_ssh_access_to_jumpbox" {
    description = "Set to `1` to allow SSH traffic from `trusted_cidr` to the jumpbox. This should only be done temporarily to upgrade the director or perform a deployment."
    default = 0
}

variable "allow_mbus_access_to_natbox" {
    description = "Set to `1` to allow traffic on 6868 from `trusted_cidr` to the natbox. This should only be done temporarily to upgrade the natbox."
    default = 0
}

variable "allow_mbus_access_to_jumpbox" {
    description = "Set to `1` to allow traffic on 6868 from `trusted_cidr` to the jumpbox. This should only be done temporarily to upgrade the jumpbox."
    default = 0
}

variable "internal_cidr" {
    type = "string"
    default = "10.0.0.0/24"
}

variable "bosh_director_tag" {
    type = "string"
    default = "bosh-external"
}

variable "concourse_atc_tag" {
    type = "string"
    default = "concourse-atc"
}

variable "concourse_db_tag" {
    type = "string"
    default = "concourse-db"
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
variable "network" {
    type = "string"
    default = "concourse"
}

variable "subnetwork" {
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

variable "blobstore_internal_tag" {
  type = "string"
  default = "blobstore-internal"
}
