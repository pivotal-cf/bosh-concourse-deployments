
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

variable "allow_mbus_access_to_jumpbox" {
    description = "Set to `1` to allow traffic on 6868 from `trusted_cidr` to the jumpbox. This should only be done temporarily to upgrade the jumpbox."
    default = 0
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

variable "network" {
    type = "string"
    default = "concourse"
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

variable "concourse_subnet" {
  type = "map"
  default = {
    internal_cidr   = "10.0.0.0/24"
    name            = "concourse"
    zone            = "us-west1-b"
    region          = "us-west1"
    allow_mbus_access_to_natbox = 0
    allow_mbus_access_to_jumpbox = 0
    allow_ssh_access_to_jumpbox = 0
  }
}

variable "asia_subnet" {
  type = "map"
  default = {
    internal_cidr   = "10.0.1.0/24"
    name            = "asia"
    zone            = "asia-east1-b"
    region          = "asia-east1"
    allow_mbus_access_to_natbox = 0
  }
}
